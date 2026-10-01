---
name: vault-organizer
description: Organize an existing archive of Markdown files and documents (for example in OneDrive) into a clean Obsidian vault split by company, with index files, links, frontmatter and a journal so everything can be undone. Activate ALWAYS when the user wants to "organize", "index", "clean up", "structure" or "sort" an existing folder of notes or files, when the setup interview picked organize level 1 or 2, when files for several companies are mixed in one archive, when the user wants Obsidian on top of existing files, or when the user wants their CLAUDE.md updated so the archive becomes the single source of truth.
---

# Vault Organizer

Turns a grown archive into a vault Claude can read quickly and Obsidian can open directly. Speak the user's language. Short messages. Nothing destructive happens before the user has seen the plan and said yes.

Tool: `scripts/vault.py` (Python 3, standard library only). Path after install: `<VAULT_PATH>/Claude Code/skills/vault-organizer/scripts/vault.py`, or `~/.claude/skills/vault-organizer/scripts/vault.py`. Below, `VAULT=python3 <that path>`. `<ROOT>` is the archive folder.

## Levels (from `AI/SETUP-PROFILE.md`, field `organize_level`)

| Level | Does | Moves files? |
|---|---|---|
| 0 | Only adds `AI/` | no |
| 1 | Index files, frontmatter, Obsidian setup, link check. Current folder structure stays | no |
| 2 | Level 1 plus a new structure split by company, files moved, links fixed | **yes** |

If the field is missing, ask which level (explain in one sentence each; recommend 2 when several companies are mixed, 1 otherwise).

## Target structure (level 2)

```
<ROOT>/
├── Home.md                  # entry point: lists companies, Shared, Inbox, AI
├── Companies/
│   └── <Company>/
│       ├── _index.md        # company hub: what the company is, key facts, links
│       └── <their own topic folders, kept as they were>/_index.md
├── Shared/                  # applies to several companies (group, templates, people)
├── Inbox/                   # files Claude could not place; the user decides
├── AI/                      # Claude's memory (never touched by this skill except AI/migration/)
└── Claude Code/skills/
```

Keep the user's own folder and file names below the company level. Do not invent a new taxonomy and do not rename files (only on a name collision: ` (2)` is appended). Never nest deeper than the archive already was.

## Phases (stop at every ✋)

### 0. Safety

1. `python3 --version`. If missing on a Mac, macOS offers to install developer tools: tell the user to accept (takes a few minutes). If they refuse, do the work with your own file tools, slower, still following the same phases and the journal idea (write every move into `AI/migration/moves.csv`).
2. Backup: check size (`du -sh "<ROOT>"`), offer a copy **outside the synced folder**, e.g. `cp -R "<ROOT>" ~/Documents/Archive-backup-$(date +%F)`. Also tell them OneDrive keeps previous versions and a recycle bin as a second safety net. Do not continue at level 2 until the user confirms a backup exists or explicitly accepts the risk.
3. Tell the user to warn colleagues: while files move, nobody should edit in the archive. After the run OneDrive needs time to sync.

### 1. Inventory

`VAULT inventory --root "<ROOT>"` prints file counts, extensions, top-level folders, notes without frontmatter, duplicate names, identical duplicates and likely sync-conflict copies. Read the summary and 8-10 representative notes from different folders. Summarize for the user in 6-8 lines.

### 2. Companies and structure ✋ (level 2)

Ask, one at a time:

1. "Which companies does this archive cover?" Get the exact short names to use as folder names.
2. For each existing top-level folder: which company does it belong to, or is it shared? Propose a mapping from folder names and from names found inside notes; let the user correct it.
3. Which folders are sensitive (HR, salary, contracts, customer personal data)? Record them in `AI/SETUP-PROFILE.md` notes. They stay `share: private`.

Files that cannot be assigned go to `Inbox/` and are listed in the plan. If more than 15% would end up in Inbox, stop and ask for more guidance first.

### 3. Plan ✋

Write `AI/migration/plan.csv` (columns `old,new`; a row with a folder path and trailing `/` moves the whole folder) and a readable `AI/migration/PLAN.md`: mapping table with file counts per row, Inbox candidates, duplicate names, sync-conflict copies (never deleted, just listed), identical duplicates (never deleted, just listed), what will NOT change (file contents except link fixes and added frontmatter, file names), how to undo.

Run `VAULT apply --root "<ROOT>" --plan AI/migration/plan.csv` (dry run) and show the summary. Ask: "Shall I move the files now?" Only an explicit yes continues. For level 1 skip phases 2-4.

### 4. Move (level 2)

`VAULT apply --root "<ROOT>" --plan AI/migration/plan.csv --apply`. The tool refuses to overwrite, verifies a SHA-256 hash of every moved file, rewrites links that pointed at moved files (wikilinks with paths, relative Markdown links, embeds; code blocks are ignored), and journals every change in `AI/migration/journal.jsonl`. Any hash mismatch: run `VAULT rollback --root "<ROOT>" --apply` and report. Read the warnings (ambiguous links, collisions) and tell the user in one line each.

### 5. Frontmatter

Agree a type map with the user (topic folder name → `type`, e.g. `Kunder: customer`, `Tilbud: offer`). Write it to `AI/migration/type-map.json`. Dry run then apply:
`VAULT frontmatter --root "<ROOT>" --type-map AI/migration/type-map.json --apply`. It only **adds** missing keys (`company`, `type`, `tags: [company/<slug>]`, `share: private`) and never touches the note body or existing keys. At level 1 (no `Companies/` folder) tell the user that company tags need level 2, or add them by folder mapping.

### 6. Indexes

`VAULT indexes --root "<ROOT>" --lang da --apply` creates `_index.md` in every folder (links to sub-indexes and notes with a one-line summary, files listed too) and `Home.md`. The generated block between `<!-- INDEX:AUTO -->` markers is rewritten on every run; text outside the markers is yours and is kept.

Then fill the **intro** line of each index by reading a few notes of that folder: 1-3 sentences, only what the notes support. Company hubs first (what the company is, what it does, where the key material is, who the key people are *if the notes say so*), then top-level topic folders. Never invent facts. For a big archive do the hubs and two levels now and tell the user the rest follows in later sessions. Optionally add `summary:` frontmatter to the most important notes; the index shows it.

### 7. Obsidian

Use the `obsidian-markdown` skill for every note you write or edit from now on. Create `<ROOT>/.obsidian/app.json` if the folder has none:

```json
{ "useMarkdownLinks": false, "newLinkFormat": "shortest", "showFrontmatter": true, "showUnsupportedFiles": true, "readableLineLength": true }
```

`showUnsupportedFiles` makes `.docx`, `.xlsx` and other non-Markdown files visible and linkable. Tell the user: open Obsidian → "Open folder as vault" → choose `<ROOT>`. It works in OneDrive; if two people open the same vault at once, Obsidian's own workspace files may create conflict copies, so each person should use their own Mac and not edit the same note simultaneously.

### 8. Verify

1. `VAULT check --root "<ROOT>"`: broken links, ambiguous names, folders without `_index.md`, notes without frontmatter, orphans, conflict copies. Fix what is fixable (broken links that pointed to something that never existed are reported to the user, not guessed at).
2. Count: files before (inventory) equal files after, apart from the index files created.
3. Write `AI/migration/REPORT.md` (what moved, counts, warnings, open items) and log the event in `AI/memory/YYYY-MM-DD.md`.

### 9. CLAUDE.md as "one true source" ✋

1. Find every `CLAUDE.md` that applies: `~/.claude/CLAUDE.md`, `<ROOT>/CLAUDE.md`, parent folders of `<ROOT>`.
2. Read them and sort the content into: **(a) behavior and rules** (keep), **(b) facts about companies, customers, prices, processes, people** (move into the right company notes with a source line, then replace by a pointer in CLAUDE.md), **(c) outdated or contradicting** (list for the user, do not decide), **(d) duplicates** of what the template already says (drop).
3. Write the proposed new CLAUDE.md: slim, rules and pointers only, plus this block (fill the company list):

```markdown
## Single source of truth: the vault
Everything about our companies, customers, projects, prices and processes lives in the vault at `<ROOT>`. It is the only source.
- Companies: <Company A>, <Company B>, ...
- To answer anything about a company: read `Home.md` → `Companies/<Company>/_index.md` → the folder `_index.md` → the notes. Never answer company facts from memory or from this file.
- If the vault and your memory disagree, the vault wins. If the vault has nothing, say so. Do not guess.
- New facts go into the vault, in the right company folder, written with the `obsidian-markdown` skill (frontmatter `company`, `type`, `tags`, `share`), and the nearest `_index.md` is updated (`vault.py indexes --only <folder> --apply`).
- Facts that apply to several companies go in `Shared/`. Unsure where something belongs: ask, or put it in `Inbox/`.
```

4. Back up the old file as `CLAUDE.md.bak-<date>`, show the user a short before/after summary, and only on a yes replace it. Run `/audit` afterwards.

## Ongoing (every later session)

- Read `Home.md` and the relevant company hub before answering company questions.
- Put new information into the company folder, not in chat memory, and keep the `_index.md` files current.
- Run `VAULT check --root "<ROOT>"` now and then (the `/audit` command does). New sync-conflict copies are listed for the user, never deleted.
- Re-run `VAULT indexes --only <folder> --apply` after adding notes.

## Undo

`VAULT rollback --root "<ROOT>"` (dry run) and `--apply` restore every moved file, every rewritten note and removes the index files created, newest change first. The journal is `AI/migration/journal.jsonl`; originals are in `AI/migration/originals/`. Keep `AI/migration/` until the user is happy.

## Rules that never bend

- No move, frontmatter edit or index write without the user's yes to the plan.
- Never delete a file. Duplicates and conflict copies are listed, not removed.
- Never change a note's text except link targets (phase 4) and added frontmatter (phase 5).
- Never write secrets or personal ID numbers into indexes or summaries (`memory-guard`).
- Stop and ask when unsure where a file belongs.
