#!/usr/bin/env python3
"""vault.py: deterministic tooling for organizing a Markdown archive as an Obsidian vault.

Subcommands (all take --root <archive folder>; all mutating ones are dry-run unless --apply):
  inventory   scan the archive, write AI/migration/inventory.json, print a summary
  apply       move files per a plan CSV (old,new), fix links, verify hashes, journal everything
  frontmatter add missing frontmatter keys (company, type, tags) without touching the body
  indexes     create/update _index.md in every folder and Home.md at the root
  check       report broken links, ambiguous names, missing frontmatter/indexes, orphans
  rollback    undo the journal (moves, rewritten files, created files), newest first

Standard library only. Python 3.8+.
"""
import argparse, csv, hashlib, json, os, re, sys, time, shutil
from urllib.parse import quote, unquote

SKIP_DIRS = {".obsidian", ".git", ".trash", "node_modules", "AI", "Claude Code"}
SKIP_FILES = {".DS_Store", "desktop.ini", "Thumbs.db"}
MIGRATION = os.path.join("AI", "migration")
JOURNAL = os.path.join(MIGRATION, "journal.jsonl")
ORIG = os.path.join(MIGRATION, "originals")
CONFLICT_RE = re.compile(r"(-[A-Za-z0-9_]+-MacBook[^/]*|-DESKTOP-[A-Z0-9]+|-MACBOOK[^/]*| \(\d+\)| 2| kopi| copy|-conflict)\.[A-Za-z0-9]+$", re.I)

# ---------- helpers ----------
def rel(p, root): return os.path.relpath(p, root).replace(os.sep, "/")

def skip_name(name):
    return name in SKIP_FILES or name.startswith("~$") or name.startswith(".")

def iter_files(root, include_ai=False):
    """all files; the root-level AI/ and Claude Code/ folders only when include_ai"""
    for dp, dns, fns in os.walk(root):
        dns[:] = [d for d in sorted(dns) if not d.startswith(".") and d != "node_modules"
                  and (include_ai or not (dp == root and d in SKIP_DIRS))]
        for fn in sorted(fns):
            if skip_name(fn): continue
            yield os.path.join(dp, fn)

def in_scope(r): return not (r.startswith("AI/") or r.startswith("Claude Code/"))

def sha256(p):
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for b in iter(lambda: f.read(1 << 20), b""): h.update(b)
    return h.hexdigest()

def read(p):
    with open(p, "r", encoding="utf-8", errors="surrogateescape", newline="") as f: return f.read()

def write(p, s):
    with open(p, "w", encoding="utf-8", errors="surrogateescape", newline="") as f: f.write(s)

def split_frontmatter(text):
    """return (fm_inner or None, body_start_index)"""
    m = re.match(r"﻿?---[ \t]*\r?\n(.*?)(\r?\n)---[ \t]*(\r?\n|$)", text, re.S)
    if not m: return None, 0
    return m.group(1), m.end()

def fm_keys(fm):
    return set(re.findall(r"^([A-Za-z0-9_\-]+)\s*:", fm or "", re.M))

def slugify(s):
    s = s.lower().replace("æ", "ae").replace("ø", "oe").replace("å", "aa")
    return re.sub(r"[^a-z0-9]+", "-", s).strip("-") or "x"

def mask_code(text):
    """blank out fenced and inline code so links inside are ignored (same length)"""
    def blank(m): return re.sub(r"[^\n]", " ", m.group(0))
    text = re.sub(r"```.*?```|~~~.*?~~~", blank, text, flags=re.S)
    return re.sub(r"`[^`\n]*`", blank, text)

WIKI = re.compile(r"(!?)\[\[([^\]\|#\^]*)((?:[#\^][^\]\|]*)?)((?:\|[^\]]*)?)\]\]")
MDL = re.compile(r"(!?)\[([^\]]*)\]\((<[^>\n]*>|[^)\s]*)((?:\s+\"[^\"]*\")?)\)")

def is_external(u): return bool(re.match(r"^[a-zA-Z][a-zA-Z0-9+.\-]*:", u)) or u.startswith("#") or u.startswith("//")

class Index:
    """lookup of files in the vault, Obsidian-style"""
    def __init__(self, root, files):
        self.root = root
        self.rels = [rel(f, root) for f in files]
        self.set = set(self.rels)
        self.by_base = {}
        self.suffix = {}
        for r in self.rels:
            parts = r.split("/")
            for i in range(len(parts)):
                k = "/".join(parts[i:]).lower()
                self.suffix.setdefault(k, []).append(r)
                if k.endswith(".md"): self.suffix.setdefault(k[:-3], []).append(r)
            b = os.path.basename(r)
            self.by_base.setdefault(b.lower(), []).append(r)
            if b.lower().endswith(".md"):
                self.by_base.setdefault(b[:-3].lower(), []).append(r)
    def resolve_wiki(self, target, from_rel):
        t = target.strip()
        if not t: return None, False
        cands = []
        if "/" in t:
            cands = list(dict.fromkeys(self.suffix.get(t.lower().lstrip("/"), [])))
        else:
            cands = list(self.by_base.get(t.lower(), []))
        if not cands: return None, False
        if len(cands) == 1: return cands[0], False
        d = os.path.dirname(from_rel)
        cands.sort(key=lambda r: (os.path.dirname(r) != d, r.count("/"), r))
        return cands[0], True  # ambiguous
    def resolve_md(self, url, from_rel):
        u = unquote(url.strip("<>")).split("#")[0].split("?")[0]
        if not u: return None
        base = os.path.dirname(from_rel)
        for cand in (os.path.normpath(os.path.join(base, u)).replace(os.sep, "/"), u.lstrip("/")):
            if cand in self.set: return cand
            if cand + ".md" in self.set: return cand + ".md"
        return None

def md_files(idx): return [r for r in idx.rels if r.lower().endswith(".md") and in_scope(r)]

def extract_links(text):
    masked = mask_code(text)
    out = []
    for m in WIKI.finditer(masked): out.append(("wiki", m))
    for m in MDL.finditer(masked): out.append(("md", m))
    return out

def vault_files(root): return list(iter_files(root))
def all_files(root): return list(iter_files(root, include_ai=True))

def journal_append(root, rec):
    p = os.path.join(root, JOURNAL); os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "a", encoding="utf-8") as f: f.write(json.dumps(rec, ensure_ascii=False) + "\n")

def save_original(root, relpath):
    os.makedirs(os.path.join(root, ORIG), exist_ok=True)
    n = len(os.listdir(os.path.join(root, ORIG)))
    name = f"{n:06d}.orig"
    shutil.copy2(os.path.join(root, relpath), os.path.join(root, ORIG, name))
    return name

# ---------- inventory ----------
def cmd_inventory(a):
    root = os.path.abspath(a.root)
    files = vault_files(root)
    recs, bybase, byhash = [], {}, {}
    exts, tops = {}, {}
    for f in files:
        r = rel(f, root); st = os.stat(f)
        e = os.path.splitext(r)[1].lower() or "(none)"
        exts[e] = exts.get(e, 0) + 1
        top = r.split("/")[0] if "/" in r else "(root)"
        tops[top] = tops.get(top, 0) + 1
        rec = {"path": r, "size": st.st_size, "mtime": int(st.st_mtime), "ext": e,
               "sha256": sha256(f) if st.st_size < a.hash_limit_mb * 1048576 else None}
        if e == ".md":
            t = read(f); fm, bs = split_frontmatter(t)
            rec["frontmatter_keys"] = sorted(fm_keys(fm)) if fm is not None else None
            rec["links"] = len(extract_links(t))
        recs.append(rec)
        bybase.setdefault(os.path.basename(r).lower(), []).append(r)
        if rec["sha256"]: byhash.setdefault(rec["sha256"], []).append(r)
    dup_names = {k: v for k, v in bybase.items() if len(v) > 1}
    dup_hash = [v for v in byhash.values() if len(v) > 1]
    conflicts = [r["path"] for r in recs if CONFLICT_RE.search(r["path"])]
    nofm = [r["path"] for r in recs if r["ext"] == ".md" and r.get("frontmatter_keys") is None]
    out = {"root": root, "generated": time.strftime("%Y-%m-%d %H:%M:%S"), "files": recs}
    os.makedirs(os.path.join(root, MIGRATION), exist_ok=True)
    with open(os.path.join(root, MIGRATION, "inventory.json"), "w", encoding="utf-8") as f: json.dump(out, f, ensure_ascii=False)
    md = sum(1 for r in recs if r["ext"] == ".md")
    print(f"files: {len(recs)}  (markdown: {md}, other: {len(recs) - md})")
    print("by extension: " + ", ".join(f"{k}={v}" for k, v in sorted(exts.items(), key=lambda x: -x[1])[:12]))
    print("top-level folders:"); [print(f"  {k}: {v}") for k, v in sorted(tops.items(), key=lambda x: -x[1])]
    print(f"markdown without frontmatter: {len(nofm)}")
    print(f"duplicate file names (different folders): {len(dup_names)}")
    for k, v in list(dup_names.items())[:10]: print("   ", k, "->", v)
    print(f"identical-content duplicates: {len(dup_hash)} groups")
    for v in dup_hash[:10]: print("   ", v)
    print(f"likely sync-conflict copies: {len(conflicts)}")
    for c in conflicts[:10]: print("   ", c)
    print(f"written: {MIGRATION}/inventory.json")

# ---------- apply (moves + link fixes) ----------
def load_plan(root, plan_path, files):
    rels = [rel(f, root) for f in files]
    moves = {}
    with open(plan_path, newline="", encoding="utf-8") as f:
        for row in csv.reader(f):
            if not row or row[0].startswith("#") or row[0].strip().lower() in ("old", "from"): continue
            old, new = row[0].strip().strip("/"), row[1].strip().strip("/")
            if not old or not new: continue
            if os.path.isdir(os.path.join(root, old)):
                pref = old + "/"
                for r in rels:
                    if r.startswith(pref): moves[r] = new + "/" + r[len(pref):]
            elif old in rels: moves[old] = new
            else: print(f"warning: not found, skipped: {old}", file=sys.stderr)
    return moves

def uniquify(new, taken):
    if new not in taken: return new
    base, ext = os.path.splitext(new); i = 2
    while f"{base} ({i}){ext}" in taken: i += 1
    return f"{base} ({i}){ext}"

def rewrite_links(text, from_old, from_new, idx_old, idx_new, mapping):
    """mapping old_rel -> new_rel. Returns (new_text, changed_count, warnings)"""
    warns, changed = [], 0
    spans = []
    for kind, m in extract_links(text):
        if kind == "wiki":
            emb, target, frag, alias = m.groups()
            tgt, amb = idx_old.resolve_wiki(target, from_old)
            if tgt is None: continue
            newt = mapping.get(tgt, tgt)
            if "/" in target.strip() or amb or len(idx_new.by_base.get(os.path.basename(newt)[:-3].lower() if newt.lower().endswith(".md") else os.path.basename(newt).lower(), [])) > 1:
                shown = newt[:-3] if newt.lower().endswith(".md") else newt
            else:
                shown = os.path.basename(newt)[:-3] if newt.lower().endswith(".md") else os.path.basename(newt)
            # keep the user's original form when the target did not change and the link was name-only
            if newt == tgt and "/" not in target.strip() and not amb: continue
            if shown == target.strip(): continue
            if amb: warns.append(f"ambiguous wikilink [[{target}]] in {from_old}, resolved to {tgt}")
            spans.append((m.start(), m.end(), f"{emb}[[{shown}{frag}{alias}]]"))
        else:
            emb, txt, url, title = m.groups()
            if is_external(url.strip("<>")): continue
            tgt = idx_old.resolve_md(url, from_old)
            if tgt is None: continue
            newt = mapping.get(tgt, tgt)
            if newt == tgt and from_old == from_new: continue
            raw = unquote(url.strip("<>")); frag = ""
            if "#" in raw: frag = "#" + raw.split("#", 1)[1]
            was_rel = os.path.normpath(os.path.join(os.path.dirname(from_old), raw.split("#")[0])).replace(os.sep, "/") == tgt
            newpath = os.path.relpath(newt, os.path.dirname(from_new) or ".").replace(os.sep, "/") if was_rel else newt
            enc = ("%20" in url) or ("%" in url)
            s = quote(newpath, safe="/") if enc else newpath
            if (" " in s) and not enc: s = f"<{s}>"
            s = s + frag if not s.endswith(">") else s[:-1] + frag + ">"
            spans.append((m.start(), m.end(), f"{emb}[{txt}]({s}{title})"))
    if not spans: return text, 0, warns
    spans.sort(); out, pos = [], 0
    for s0, e0, rep in spans:
        if s0 < pos: continue
        out.append(text[pos:s0]); out.append(rep); pos = e0; changed += 1
    out.append(text[pos:])
    return "".join(out), changed, warns

def cmd_apply(a):
    root = os.path.abspath(a.root)
    files = vault_files(root)
    moves = load_plan(root, a.plan, files)
    taken = set(rel(f, root) for f in files)
    final = {}
    for old, new in sorted(moves.items()):
        if old == new: continue
        n = uniquify(new, (taken - {old}) | set(final.values()))
        if n != new: print(f"collision: {new} exists, using {n}")
        final[old] = n
    print(f"planned moves: {len(final)} of {len(moves)} rows; files unaffected: {len(taken) - len(final)}")
    for o, n in list(final.items())[:15]: print(f"  {o}  ->  {n}")
    if len(final) > 15: print(f"  ... and {len(final) - 15} more")
    if not a.apply: print("\nDRY RUN. Nothing changed. Re-run with --apply after the user approved the plan."); return
    idx_old = Index(root, all_files(root))
    hashes = {o: sha256(os.path.join(root, o)) for o in final}
    for old, new in final.items():
        dst = os.path.join(root, new); os.makedirs(os.path.dirname(dst), exist_ok=True)
        if os.path.exists(dst): sys.exit(f"refusing to overwrite {new}")
        os.rename(os.path.join(root, old), dst)
        journal_append(root, {"op": "move", "old": old, "new": new})
    bad = [n for o, n in final.items() if sha256(os.path.join(root, n)) != hashes[o]]
    if bad: sys.exit(f"HASH MISMATCH after move: {bad[:5]}. Run rollback.")
    idx_new = Index(root, all_files(root))
    inv_new2old = {n: o for o, n in final.items()}
    total, warns_all, touched = 0, [], 0
    for r in md_files(idx_new):
        old_r = inv_new2old.get(r, r)
        p = os.path.join(root, r); t = read(p)
        nt, c, w = rewrite_links(t, old_r, r, idx_old, idx_new, final)
        warns_all += w
        if c and nt != t:
            name = save_original(root, r); write(p, nt)
            journal_append(root, {"op": "write", "path": r, "original": name, "why": "links"})
            total += c; touched += 1
    print(f"moved {len(final)} files (hash verified). Rewrote {total} links in {touched} notes.")
    for w in warns_all[:20]: print("warning:", w)

# ---------- frontmatter ----------
def company_of(r, companies_dir="Companies"):
    parts = r.split("/")
    if parts[0] == companies_dir and len(parts) > 2: return parts[1]
    if parts[0] == "Shared": return "Shared"
    return None

def cmd_frontmatter(a):
    root = os.path.abspath(a.root); idx = Index(root, vault_files(root))
    tmap = json.load(open(a.type_map)) if a.type_map else {}
    n = 0; shown = 0
    for r in md_files(idx):
        comp = company_of(r)
        if not comp: continue
        p = os.path.join(root, r); t = read(p); fm, bs = split_frontmatter(t)
        have = fm_keys(fm); add = []
        parts = r.split("/"); sub = parts[2] if (parts[0] == "Companies" and len(parts) > 3) else ""
        if "company" not in have: add.append(f"company: {comp}")
        if "type" not in have: add.append(f"type: {tmap.get(sub, 'note')}")
        if "tags" not in have: add.append(f"tags: [company/{slugify(comp)}]")
        if "share" not in have and a.share: add.append(f"share: {a.share}")
        if not add: continue
        n += 1
        if fm is None: new = "---\n" + "\n".join(add) + "\n---\n" + t
        else:
            m = re.match(r"(﻿?---[ \t]*\r?\n.*?)((\r?\n)---[ \t]*(\r?\n|$))", t, re.S)
            nl = "\r\n" if "\r\n" in t[:200] else "\n"
            new = m.group(1) + nl + nl.join(add) + t[m.start(2):]
        if shown < 5 and not a.apply: print(f"+ {r}: " + "; ".join(add)); shown += 1
        if a.apply:
            name = save_original(root, r); write(p, new)
            journal_append(root, {"op": "write", "path": r, "original": name, "why": "frontmatter"})
    print(f"{'updated' if a.apply else 'would update'} {n} notes" + ("" if a.apply else "  (DRY RUN, add --apply)"))

# ---------- indexes ----------
A0, A1 = "<!-- INDEX:AUTO -->", "<!-- /INDEX:AUTO -->"
L = {"da": dict(sub="Mapper", notes="Noter", files="Filer", count="noter", more="og {n} flere (se mappen)", intro="<!-- Skriv 1-3 sætninger: hvad ligger i denne mappe, og hvornår skal man kigge her? -->", home="Overblik over hele arkivet. Start her.", comps="Virksomheder", shared="Fælles for flere virksomheder", inbox="Ikke sorteret endnu", people="Hvem er hvem og hvad de arbejder med", ai="Claudes hukommelse"),
     "en": dict(sub="Folders", notes="Notes", files="Files", count="notes", more="and {n} more (see the folder)", intro="<!-- Write 1-3 sentences: what is in this folder and when to look here? -->", home="Overview of the whole archive. Start here.", comps="Companies", shared="Shared across companies", inbox="Not sorted yet", people="Who is who and what they work on", ai="Claude's memory")}

def summary_of(path):
    t = read(path); fm, bs = split_frontmatter(t)
    if fm:
        m = re.search(r"^(?:summary|description)\s*:\s*(.+)$", fm, re.M)
        if m: return m.group(1).strip().strip("\"'")[:120]
    for line in t[bs:].splitlines():
        s = line.strip()
        if not s or s.startswith(("#", "---", "<!--", "|", "```", ">", "![[")): continue
        s = re.sub(r"\[\[([^\]|]*\|)?([^\]]*)\]\]", r"\2", s); s = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", s)
        s = re.sub(r"[*_`#]", "", s).strip()
        if s: return (s[:117] + "...") if len(s) > 120 else s
    return ""

def cmd_indexes(a):
    root = os.path.abspath(a.root); T = L[a.lang]
    files = vault_files(root); idx = Index(root, files)
    dirs = {"": set()}
    for r in idx.rels:
        d = os.path.dirname(r)
        while True:
            dirs.setdefault(d, set())
            if not d: break
            d = os.path.dirname(d)
    created = updated = 0
    for d in sorted(dirs):
        if d == "": continue
        if a.only and not (d == a.only or d.startswith(a.only.rstrip("/") + "/")): continue
        full = os.path.join(root, d)
        subs = sorted(s for s in os.listdir(full) if os.path.isdir(os.path.join(full, s)) and not s.startswith(".") and rel(os.path.join(full, s), root) in dirs)
        items = sorted(f for f in os.listdir(full) if os.path.isfile(os.path.join(full, f)) and not skip_name(f) and f != "_index.md")
        notes = [f for f in items if f.lower().endswith(".md")]; others = [f for f in items if not f.lower().endswith(".md")]
        def count_notes(dd): return sum(1 for r in idx.rels if r.startswith(dd + "/") and r.lower().endswith(".md") and not r.endswith("/_index.md"))
        lines = [A0]
        if subs:
            lines.append(f"## {T['sub']}")
            for s in subs:
                sp = f"{d}/{s}"; lines.append(f"- [[{sp}/_index|{s}]] ({count_notes(sp)} {T['count']})")
            lines.append("")
        if notes:
            lines.append(f"## {T['notes']}")
            for f in notes[:a.max_list]:
                r = f"{d}/{f}"; base = f[:-3]
                link = f"[[{base}]]" if len(idx.by_base.get(base.lower(), [])) == 1 else f"[[{r[:-3]}|{base}]]"
                sm = summary_of(os.path.join(full, f)); lines.append(f"- {link}" + (f" — {sm}" if sm else ""))
            if len(notes) > a.max_list: lines.append("- " + T["more"].format(n=len(notes) - a.max_list))
            lines.append("")
        if others:
            lines.append(f"## {T['files']}")
            for f in others[:a.max_list]:
                link = f"[[{f}]]" if len(idx.by_base.get(f.lower(), [])) == 1 else f"[[{d}/{f}|{f}]]"
                lines.append(f"- {link}")
            if len(others) > a.max_list: lines.append("- " + T["more"].format(n=len(others) - a.max_list))
            lines.append("")
        lines.append(A1); block = "\n".join(lines)
        ip = os.path.join(full, "_index.md"); parts = d.split("/")
        comp = company_of(d + "/x") if (parts[0] in ("Companies", "Shared")) else None
        if os.path.exists(ip):
            t = read(ip)
            if A0 in t and A1 in t: nt = t[:t.index(A0)] + block + t[t.index(A1) + len(A1):]
            else: nt = t.rstrip("\n") + "\n\n" + block + "\n"
            if nt != t:
                updated += 1
                if a.apply:
                    name = save_original(root, rel(ip, root)); write(ip, nt)
                    journal_append(root, {"op": "write", "path": rel(ip, root), "original": name, "why": "index"})
        else:
            is_company = parts[0] == "Companies" and len(parts) == 2
            fmk = ["type: company" if is_company else "type: index"]
            if comp: fmk += [f"company: {comp}"]
            fmk += [f"tags: [index{', company/' + slugify(comp) if comp else ''}]"] + ([f"share: {a.share}"] if a.share else [])
            body = f"---\n" + "\n".join(fmk) + f"\n---\n# {parts[-1]}\n\n{T['intro']}\n\n{block}\n"
            created += 1
            if a.apply:
                write(ip, body); journal_append(root, {"op": "create", "path": rel(ip, root)})
    # Home.md
    hp = os.path.join(root, "Home.md")
    if not a.only:
        top = [d for d in sorted(dirs) if d and "/" not in d]
        hl = [A0]
        cdir = os.path.join(root, "Companies")
        if os.path.isdir(cdir):
            hl.append(f"## {T['comps']}")
            for c in sorted(os.listdir(cdir)):
                if os.path.isdir(os.path.join(cdir, c)) and not c.startswith("."): hl.append(f"- [[Companies/{c}/_index|{c}]]")
            hl.append("")
        extra = [("Shared", T["shared"]), ("Inbox", T["inbox"]), ("People", T["people"])]
        for n, label in extra:
            if n in top: hl.append(f"- [[{n}/_index|{n}]]: {label}")
        if os.path.isdir(os.path.join(root, "AI")): hl.append(f"- [[AI/_index|AI]]: {T['ai']}")
        hl.append(A1); block = "\n".join(hl)
        if os.path.exists(hp):
            t = read(hp)
            nt = (t[:t.index(A0)] + block + t[t.index(A1) + len(A1):]) if (A0 in t and A1 in t) else t.rstrip("\n") + "\n\n" + block + "\n"
            if nt != t:
                updated += 1
                if a.apply:
                    name = save_original(root, "Home.md"); write(hp, nt); journal_append(root, {"op": "write", "path": "Home.md", "original": name, "why": "index"})
        else:
            created += 1
            if a.apply: write(hp, f"---\ntype: home\ntags: [index]\n---\n# Home\n\n{T['home']}\n\n{block}\n"); journal_append(root, {"op": "create", "path": "Home.md"})
    print(f"{'created' if a.apply else 'would create'} {created} index files, {'updated' if a.apply else 'would update'} {updated}" + ("" if a.apply else "  (DRY RUN, add --apply)"))

# ---------- check ----------
def fm_date(fm):
    m = re.search(r"^(?:created|updated)\s*:\s*(\d{4}-\d{2}-\d{2})", fm, re.M)
    return m.group(1) if m else ""

def cmd_check(a):
    root = os.path.abspath(a.root); idx = Index(root, all_files(root))
    broken, amb, nofm, noidx, conflicts, unver = [], [], [], [], [], []
    inbound = {r: 0 for r in idx.rels}
    for r in md_files(idx):
        t = read(os.path.join(root, r)); fm, bs = split_frontmatter(t)
        if fm is None and not r.endswith("_index.md"): nofm.append(r)
        if fm and re.search(r"^status\s*:\s*unverified\s*$", fm, re.M): unver.append((fm_date(fm), r))
        for kind, m in extract_links(t):
            if kind == "wiki":
                target = m.group(2).strip()
                if not target: continue
                tgt, ambig = idx.resolve_wiki(target, r)
                if tgt is None: broken.append((r, f"[[{target}]]"))
                else:
                    inbound[tgt] += 1
                    if ambig: amb.append((r, target))
            else:
                url = m.group(3)
                if is_external(url.strip("<>")): continue
                tgt = idx.resolve_md(url, r)
                if tgt is None and unquote(url.strip("<>")).split("#")[0]: broken.append((r, url))
                elif tgt: inbound[tgt] += 1
    dirs = set(os.path.dirname(r) for r in idx.rels if os.path.dirname(r) and in_scope(r))
    for d in sorted(dirs):
        if not os.path.exists(os.path.join(root, d, "_index.md")): noidx.append(d)
    orphans = [r for r in md_files(idx) if inbound[r] == 0 and not r.endswith("_index.md") and r != "Home.md"]
    conflicts = [r for r in idx.rels if in_scope(r) and CONFLICT_RE.search(r)]
    dupn = {k: v for k, v in idx.by_base.items() if len(set(v)) > 1 and k.endswith(".md") is False and not k.startswith("_index")}
    print(f"broken links: {len(broken)}"); [print("  ", x) for x in broken[:a.limit]]
    print(f"ambiguous wikilinks (duplicate names): {len(amb)}"); [print("  ", x) for x in amb[:a.limit]]
    print(f"folders without _index.md: {len(noidx)}"); [print("  ", x) for x in noidx[:a.limit]]
    print(f"notes without frontmatter: {len(nofm)}"); [print("  ", x) for x in nofm[:a.limit]]
    print(f"notes nobody links to (orphans): {len(orphans)}"); [print("  ", x) for x in orphans[:a.limit]]
    print(f"likely sync-conflict copies: {len(conflicts)}"); [print("  ", x) for x in conflicts[:a.limit]]
    unver.sort()
    print(f"notes still marked unverified (oldest first): {len(unver)}"); [print("  ", f"{d or '?'}  {r}") for d, r in unver[:a.limit]]
    if a.strict and (broken or noidx): sys.exit(1)

# ---------- rollback ----------
def cmd_rollback(a):
    root = os.path.abspath(a.root); jp = os.path.join(root, JOURNAL)
    if not os.path.exists(jp): sys.exit("no journal, nothing to roll back")
    recs = [json.loads(l) for l in open(jp, encoding="utf-8") if l.strip()]
    print(f"journal entries: {len(recs)}")
    if not a.apply: print("DRY RUN. Re-run with --apply to undo everything, newest first."); return
    for r in reversed(recs):
        if r["op"] == "move":
            src, dst = os.path.join(root, r["new"]), os.path.join(root, r["old"])
            if os.path.exists(src) and not os.path.exists(dst):
                os.makedirs(os.path.dirname(dst), exist_ok=True); os.rename(src, dst)
        elif r["op"] == "write":
            p = os.path.join(root, r["path"])
            if os.path.exists(p): shutil.copy2(os.path.join(root, ORIG, r["original"]), p)
        elif r["op"] == "create":
            p = os.path.join(root, r["path"])
            if os.path.exists(p): os.remove(p)
    for r in recs:  # remove folders left empty by the moves (only the ones the journal touched)
        if r["op"] == "move":
            d = os.path.dirname(os.path.join(root, r["new"]))
            while d != root and os.path.isdir(d) and not os.listdir(d):
                os.rmdir(d); d = os.path.dirname(d)
    os.rename(jp, jp + f".rolledback-{int(time.time())}")
    print("rolled back.")

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sp = ap.add_subparsers(dest="cmd", required=True)
    def add(name, fn, **kw):
        p = sp.add_parser(name); p.add_argument("--root", required=True); p.set_defaults(fn=fn); return p
    p = add("inventory", cmd_inventory); p.add_argument("--hash-limit-mb", type=int, default=200)
    p = add("apply", cmd_apply); p.add_argument("--plan", required=True); p.add_argument("--apply", action="store_true")
    p = add("frontmatter", cmd_frontmatter); p.add_argument("--apply", action="store_true"); p.add_argument("--type-map"); p.add_argument("--share", default="private")
    p = add("indexes", cmd_indexes); p.add_argument("--apply", action="store_true"); p.add_argument("--lang", choices=["da", "en"], default="da"); p.add_argument("--only"); p.add_argument("--max-list", type=int, default=200); p.add_argument("--share", default="private")
    p = add("check", cmd_check); p.add_argument("--limit", type=int, default=25); p.add_argument("--strict", action="store_true")
    p = add("rollback", cmd_rollback); p.add_argument("--apply", action="store_true")
    a = ap.parse_args(); a.fn(a)

if __name__ == "__main__": main()
