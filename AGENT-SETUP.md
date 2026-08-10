# AGENT-SETUP.md — Instructions for Claude (or any AI agent)

> **You are an AI agent and someone gave you this repo URL plus a vault folder to use.**
> This file is your complete instruction set. Follow it top to bottom. Ask the user only when a step explicitly says to.

The user's message will look something like:

> Set up the memory system from github.com/microfix/claude-obsidian-memory using folder `~/Documents/MyVault`

The folder they name is the **vault path** — referred to as `<VAULT_PATH>` below. If they didn't name a folder, ask for one before doing anything else.

## Step 1: Clone the repo

```bash
git clone https://github.com/microfix/claude-obsidian-memory.git /tmp/claude-obsidian-memory
cd /tmp/claude-obsidian-memory
```

## Step 2: Run the installer

The installer is idempotent and handles everything — Obsidian check, vault creation, file copies, symlinks, commands, CLAUDE.md:

```bash
./install.sh --vault "<VAULT_PATH>" --yes
```

**If install.sh succeeds, skip to Step 4.** If it fails (unsupported OS, no shell access, permissions), do the manual install in Step 3.

## Step 3: Manual install (fallback only)

Create this exact structure:

**3a. Vault memory structure** — copy `vault/AI/` from the repo into `<VAULT_PATH>/AI/`:

```
<VAULT_PATH>/AI/
├── _index.md            # Master index — the entry point
├── USER.md              # Facts about the user
├── SOUL.md              # Agent personality
├── IDENTITY.md          # Agent self-identity
├── AGENTS.md            # Behavioral rules
├── BOOTSTRAP.md         # Startup context
├── SKILLS.md            # Skill inventory
├── tools/_index.md      # Registry of the user's tools/services
├── applied-learning/    # ALWAYS.md + _index.md
├── decisions/_index.md  # Decision graph convention
├── memory/              # Daily logs (empty at start)
└── raw/                 # Inbox for loose notes
```

**3b. Skills** — copy `vault/Claude Code/` from the repo into `<VAULT_PATH>/Claude Code/`. The skills live in the vault (source of truth) so the user can edit and sync them in Obsidian.

**3c. Symlinks** — Claude Code discovers skills in `~/.claude/skills/`, so symlink each one:

```bash
mkdir -p ~/.claude/skills
for skill in skill-builder obsidian-markdown obsidian-bases obsidian-cli json-canvas anydoc defuddle; do
  ln -sf "<VAULT_PATH>/Claude Code/skills/$skill" ~/.claude/skills/$skill
done
```

On Windows (native, no symlink rights): copy the folders instead, and tell the user that skill edits in Obsidian won't propagate automatically.

**3d. Commands** — copy `commands/*.md` to `~/.claude/commands/`.

**3e. CLAUDE.md** — see Step 5.

## Step 4: Optional CLI dependencies

Two skills use external CLIs. Offer to install them (needs npm):

```bash
npm install -g @firecrawl/anydoc   # anydoc — document → markdown conversion
npm install -g defuddle            # defuddle — web page → markdown extraction
```

If npm's global bin dir isn't on PATH (common on servers), note the path from `npm bin -g` and add an `export PATH=...` line to the user's shell profile.

## Step 5: CLAUDE.md — the bootstrap file

`CLAUDE.md` is the global instruction file Claude Code reads at every session start. It's what tells Claude that the memory system exists and where the vault is. **Without it, nothing else works.**

**Where it lives:**

| Platform | Path |
|----------|------|
| macOS / Linux | `~/.claude/CLAUDE.md` |
| Windows (native) | `C:\Users\<name>\.claude\CLAUDE.md` |
| Per-project alternative | `<project>/CLAUDE.md` (only applies inside that project) |

**What must be in it:** take `claude-md-template.md` from this repo and replace every `<VAULT_PATH>` with the actual vault path:

```bash
sed "s|<VAULT_PATH>|<VAULT_PATH>|g" claude-md-template.md > ~/.claude/CLAUDE.md
```

**If a CLAUDE.md already exists:** do NOT overwrite it. Read it, then merge in the missing sections from the template (Memory, Rules, Skills, Documents). Preserve the user's existing content.

**If you cannot write to `~/.claude/` at all** (sandboxed, no filesystem access): output the fully rendered CLAUDE.md content in a code block, tell the user the exact path where it must be saved (table above), and tell them to create the file there themselves.

## Step 6: Personalize

Ask the user (or fill in from what you already know about them):

1. `<VAULT_PATH>/AI/USER.md` — name, timezone, GitHub username, tech level, current projects
2. `~/.claude/CLAUDE.md` "About Me" section — same facts, short form
3. `<VAULT_PATH>/AI/SOUL.md` — language and tone preferences (e.g. "answer in Danish, short and direct")

## Step 7: Verify

Run these checks and show the user the result:

```bash
ls "<VAULT_PATH>/AI/_index.md"                 # vault structure exists
ls -la ~/.claude/skills/ | grep -c '\->'       # symlinks created (expect 7)
ls ~/.claude/commands/compile.md ~/.claude/commands/audit.md
head -5 ~/.claude/CLAUDE.md                    # CLAUDE.md in place
grep -c "<VAULT_PATH>" ~/.claude/CLAUDE.md     # must be 0 — no unreplaced placeholders
anydoc --version 2>/dev/null || echo "anydoc not installed (optional)"
```

Then tell the user: **restart Claude Code** (new session) so CLAUDE.md is picked up. From the next session on, Claude reads its memory silently at start and writes to it as it works.

## What you just installed

- **Persistent memory**: `AI/` in the vault — indexes, daily logs, applied learning, decision graph. The rules in CLAUDE.md make every future session read it at start and maintain it silently.
- **7 skills** (in vault, symlinked): `skill-builder`, `obsidian-markdown`, `obsidian-bases`, `obsidian-cli`, `json-canvas`, `anydoc`, `defuddle`
- **2 commands**: `/compile` (process the raw inbox), `/audit` (memory health check)

Full documentation: [README.md](README.md)
