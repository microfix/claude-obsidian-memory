# Claude Code + Obsidian: Persistent Memory System

> Give Claude Code a brain that survives between sessions.

A production-tested system that turns an Obsidian vault into persistent, structured memory for Claude Code. No more re-explaining your project every session. No amnesia. No wasted tokens.

**This isn't a weekend hack.** It's been running daily in production across multiple projects for months — handling everything from startup codebases to personal automation.

---

## What This Is

Claude Code is powerful but forgetful. Every new session starts from zero — you re-explain your stack, your decisions, your progress. This system fixes that by giving Claude Code:

- **Persistent memory** — decisions, context, and progress survive across sessions
- **Structured knowledge** — atomic notes with wikilinks, not one giant file
- **Auto-bootstrap** — Claude reads its memory silently at session start
- **Applied learning** — when you correct Claude, the lesson is saved and never repeated
- **Decision graph** — every significant decision becomes a linked node, so good routes are found again instead of re-discovered
- **Skills system** — reusable prompt modules for common tasks
- **Maintenance commands** — `/compile` to process raw notes, `/audit` to find issues
- **Daily logs** — automatic session logging for full history

## Set up in one message: the Claude interview

Paste one line into Claude Code. Claude interviews you, then builds the right setup for you. Nothing is installed before you approve the plan.

> Set up the memory system from github.com/microfix/claude-obsidian-memory

Claude asks (one question at a time, in your language): what you do, what you already have, where your files live, whether you want Obsidian, how many devices, whether it is shared, and whether you handle personal data. Then it picks one of five storage modes and the matching skills:

| Mode | You have | Result |
|---|---|---|
| **A** New Obsidian vault | Nothing yet | Fresh vault, Obsidian installed if missing |
| **B** Existing Obsidian vault | A vault | `AI/` memory added next to your notes, nothing moved |
| **C** Plain Markdown folder | `.md` files, no Obsidian (or you don't want it) | Same memory, no Obsidian parts |
| **D** Microsoft 365 | Word/Excel/PowerPoint in OneDrive, SharePoint, Teams | Memory in a synced folder + Microsoft 365 connector for mail, calendar, Teams |
| **E** Google Drive | Drive, Docs, Sheets | Memory in a mirrored Drive folder + Google connectors |

Setting this up for a customer on Mac + OneDrive with an existing archive, possibly several companies mixed together? Hand the implementer [docs/GUIDE-ONEDRIVE-MAC.da.md](docs/GUIDE-ONEDRIVE-MAC.da.md) (Danish, step by step, for the Claude desktop app: open a session on the archive folder, paste the link, done).

The interview script is [INTERVIEW.md](INTERVIEW.md), the step-by-step for each mode is [docs/STORAGE-MODES.md](docs/STORAGE-MODES.md), and the agent's full instructions are [AGENT-SETUP.md](AGENT-SETUP.md).

---

## How It Works

```
┌─────────────────────────────────────────────────┐
│              OBSIDIAN VAULT                      │
│                                                 │
│  AI/                                            │
│  ├── _index.md         ← Master index           │
│  ├── USER.md           ← Facts about you        │
│  ├── SOUL.md           ← Agent personality       │
│  ├── AGENTS.md         ← Behavioral rules        │
│  ├── BOOTSTRAP.md      ← Startup context         │
│  ├── SETUP-PROFILE.md  ← Interview answers       │
│  ├── SKILLS.md         ← Skill inventory         │
│  ├── tools/            ← Setup & service docs     │
│  │   └── _index.md     ← Tools registry          │
│  ├── applied-learning/ ← Lessons from corrections │
│  │   ├── ALWAYS.md     ← Read every session       │
│  │   └── <topic>.md    ← Loaded contextually      │
│  ├── decisions/        ← Decision graph (nodes)   │
│  │   └── _index.md     ← Convention & node list   │
│  ├── memory/           ← Daily logs (YYYY-MM-DD) │
│  └── raw/              ← Inbox for loose notes    │
│                                                 │
│  Claude Code/skills/   ← Skill definitions       │
│  ├── skill-builder/  memory-guard/  anydoc/      │
│  ├── defuddle/                                   │
│  ├── obsidian-*/  json-canvas/  (Obsidian modes) │
│  └── gdpr-check/  icm-architect/  vault-organizer │
└───────────────────┬─────────────────────────────┘
                    │
              Claude Code reads/writes
                    │
┌───────────────────┴─────────────────────────────┐
│  ~/.claude/                                      │
│  ├── CLAUDE.md         ← Global instructions     │
│  ├── skills/           ← Symlinks → vault        │
│  └── commands/         ← /compile, /audit        │
└─────────────────────────────────────────────────┘
```

At every session start, Claude Code:
1. Reads `AI/_index.md` (master index)
2. Reads `AI/tools/_index.md` (your setup)
3. Reads `AI/applied-learning/ALWAYS.md` (your standing corrections)
4. Reads the 2-3 most recent `memory/` files
5. Loads relevant context based on what you're working on
6. Answers — without you explaining anything

## What's Included

| Component | Description |
|-----------|-------------|
| **Onboarding interview** | `INTERVIEW.md`: Claude asks 11 short questions and builds your setup from the answers |
| **Five storage modes** | New or existing Obsidian vault, plain Markdown folder, Microsoft 365, Google Drive |
| **Vault template** | Pre-structured memory (`AI/`) with a `SETUP-PROFILE.md` that records your choices |
| **CLAUDE.md** | Global instructions that teach Claude how to use the memory, with a skill routing table |
| **Skills** | Core, Obsidian, Compliance and Structure packs included. Anthropic's document skills installed from source |
| **2 commands** | `/compile` (process raw notes) and `/audit` (find issues) |
| **Install script** | Flags for every mode: `--no-obsidian`, `--skills-mode copy`, `--skills gdpr-check,icm-architect` |
| **AGENT-SETUP.md** | Instructions Claude follows to run the interview and install everything itself |

### Skills

Where each skill comes from (full detail in [docs/SKILLS-CATALOG.md](docs/SKILLS-CATALOG.md)):

**Made by Anthropic** (installed from the source, not copied here)

| Skill | Purpose |
|-------|---------|
| `docx`, `xlsx`, `pptx`, `pdf` | Create and edit Word, Excel, PowerPoint and PDF files |
| `skill-creator`, `frontend-design` | Build and test skills; distinctive web UI |
| `/code-review`, `/simplify`, `/security-review`, `/loop`, `/schedule` | Built into Claude Code |

```
/plugin marketplace add anthropics/skills
/plugin install document-skills@anthropic-agent-skills
```

**From the Obsidian community** (included, only installed when you use Obsidian)

| Skill | Purpose |
|-------|---------|
| `obsidian-markdown` | Write correct Obsidian Flavored Markdown (wikilinks, callouts, embeds, properties) |
| `obsidian-bases` | Create `.base` files (database-like views with filters and formulas) |
| `obsidian-cli` | Interact with running Obsidian via CLI (read, create, search, manage notes) |
| `json-canvas` | Create and edit `.canvas` files: mind maps, flowcharts, visual boards |
| `defuddle` | Extract clean markdown from web pages (saves tokens vs raw HTML) |

**Included here**

| Skill | Purpose |
|-------|---------|
| `skill-builder` | Create and improve skills with proper structure |
| `memory-guard` | Pre-write gate: blocks secrets, flags personal data, sets `share:` level on notes |
| `anydoc` | Convert PDF, Word, Excel, PowerPoint, ODF, RTF, EPUB, CSV to clean markdown |
| `gdpr-check` | GDPR audit of software and data flows, with article references (Danish report, not legal advice) |
| `icm-architect` | Turn a process or a team's knowledge into a folder structure an agent can walk (MIT, Van Clief & McDermott) |
| `vault-organizer` | Sort an existing archive into an Obsidian vault per company: index files, links, frontmatter, undo journal, and a CLAUDE.md that makes the vault the single source of truth |

**Connectors** (claude.ai account): Microsoft 365 (Outlook, Teams, SharePoint), Gmail, Google Drive. Used by modes D and E.

### Commands Included

| Command | Purpose |
|---------|---------|
| `/compile` | Process everything in `AI/raw/` inbox into the correct files |
| `/audit` | Scan memory for duplicates, dead links, outdated info, gaps |

---

## Prerequisites

You need **Claude Code** installed before using this system. Obsidian is handled by the install script, but Claude Code must be set up first.

### Claude Code Account

Claude Code requires a **paid plan** — the free Claude.ai plan does not include Claude Code access:
- Claude Pro, Max, Team, or Enterprise subscription
- Or an Anthropic Console account with API credits
- Or a third-party provider (Amazon Bedrock, Google Vertex AI)

### macOS

**Requirements:** macOS with 4 GB+ RAM. That's it.

```bash
# Install Claude Code
curl -fsSL https://claude.ai/install.sh | bash

# Verify installation
claude --version
```

Or via Homebrew:
```bash
brew install claude-code
```

### Windows

Windows has two options: **Native** or **WSL** (Windows Subsystem for Linux).

#### Option 1: Native Windows (easiest)

**Requirements:**
- Windows 10/11, 4 GB+ RAM
- **[Git for Windows](https://git-scm.com/downloads/win)** — required, install this first

Install Claude Code from **PowerShell**:
```powershell
irm https://claude.ai/install.ps1 | iex
```

Or from **CMD** (not PowerShell):
```bat
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```

> **Tip:** Your prompt shows `PS C:\` in PowerShell and `C:\` in CMD. Use the matching command.

After installation, Claude Code uses Git Bash internally to execute commands. If it can't find Git Bash, add this to your settings:
```json
{
  "env": {
    "CLAUDE_CODE_GIT_BASH_PATH": "C:\\Program Files\\Git\\bin\\bash.exe"
  }
}
```

#### Option 2: WSL (Linux toolchains)

**Requirements:**
- WSL 2 enabled (supports sandboxing)
- A Linux distribution installed (e.g., Ubuntu from Microsoft Store)

Install from inside your WSL terminal:
```bash
curl -fsSL https://claude.ai/install.sh | bash
```

### Linux

**Requirements:** 4 GB+ RAM, x64 or ARM64.

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

For **Alpine/musl-based** distros, install extra dependencies first:
```bash
apk add libgcc libstdc++ ripgrep
```

### Verify Installation

On all platforms:
```bash
claude --version
claude doctor    # Detailed health check
```

Then start Claude Code and follow the browser prompt to log in:
```bash
claude
```

---

## Installation

### Just tell Claude Code (recommended)

If you already have Claude Code running, paste this:

> Set up the memory system from github.com/microfix/claude-obsidian-memory

Claude clones the repo, runs the interview in [INTERVIEW.md](INTERVIEW.md), shows you the plan, and only after your yes follows [AGENT-SETUP.md](AGENT-SETUP.md): it creates the structure, installs the skills you chose, and writes `~/.claude/CLAUDE.md` pointing at your memory folder. If it can't write CLAUDE.md (sandboxed environment), it tells you exactly where the file goes and what to put in it.

You can also name the folder up front ("... using folder `~/Documents/MyVault`") and Claude skips that question.

### Quick Install (Terminal)

```bash
git clone https://github.com/microfix/claude-obsidian-memory.git
cd claude-obsidian-memory
./install.sh
```

### Non-Interactive Install

For scripting or when Claude Code runs it for you:

```bash
./install.sh --vault ~/Documents/MyVault --yes                       # Obsidian vault (new or existing)
./install.sh --vault ~/Notes --yes --no-obsidian                      # plain Markdown folder
./install.sh --vault "$HOME/OneDrive/Claude-Memory" --yes \
             --skills-mode copy --skills gdpr-check                   # cloud folder (OneDrive, Google Drive)
```

| Flag | Meaning |
|------|---------|
| `--no-obsidian` | Skip Obsidian install, the four Obsidian skills and the Obsidian rules in CLAUDE.md |
| `--skills-mode copy` | Copy skills into `~/.claude/skills/` instead of symlinking (cloud folders, native Windows; default on Windows) |
| `--skills a,b` | Extra skills: `gdpr-check`, `icm-architect` |

### What the Installer Does

1. **Installs Obsidian** if not found and wanted (Homebrew on macOS, Snap/Flatpak on Linux). Skipped with `--no-obsidian`
2. **Creates the folder** if the path doesn't exist (with `.obsidian` config when Obsidian is used)
3. **Adds** the `AI/` memory structure. If `AI/` exists, it merges and keeps your files. Nothing outside `AI/` and `Claude Code/` is touched
4. Copies the chosen skills into the vault under `Claude Code/skills/`
5. Links (or copies, with `--skills-mode copy`) the skills into `~/.claude/skills/`
6. Installs `/compile` and `/audit` commands to `~/.claude/commands/`
7. Generates `~/.claude/CLAUDE.md` with your folder path (keeps a `.bak` of an existing one)
8. Optionally installs the `anydoc` CLI (document conversion) and `defuddle` CLI (web content extraction)

Anthropic's document skills are installed separately (see Skills above).

### Manual Install

If you prefer to do it yourself:

**1. Copy the vault template:**
```bash
cp -r vault/AI/ "/path/to/your/vault/AI/"
cp -r vault/Claude\ Code/ "/path/to/your/vault/Claude Code/"
```

**2. Create skill symlinks:**
```bash
mkdir -p ~/.claude/skills
for skill in skill-builder memory-guard anydoc defuddle obsidian-markdown obsidian-bases obsidian-cli json-canvas; do
  ln -sf "/path/to/your/vault/Claude Code/skills/$skill" ~/.claude/skills/$skill
done
```

**3. Install commands:**
```bash
mkdir -p ~/.claude/commands
cp commands/*.md ~/.claude/commands/
```

**4. Install CLAUDE.md:**
```bash
cp claude-md-template.md ~/.claude/CLAUDE.md
```
Then edit `~/.claude/CLAUDE.md` and replace `<VAULT_PATH>` with your actual vault path.

---

## Configuration

After installation, personalize the system:

### 0. Check `AI/SETUP-PROFILE.md`

Written by the interview. It records your storage mode, folder, packs and flags like `sensitive_data`. Change it by asking Claude to "run the setup interview again".

### 1. Edit `AI/USER.md`

Add facts about yourself — your name, timezone, tech stack, projects. Claude uses this to understand your context without you repeating it.

### 2. Edit `AI/SOUL.md`

Define how you want Claude to behave — personality, communication style, language preferences. This is philosophy, not rules.

### 3. Edit `AI/AGENTS.md`

Behavioral rules for the agent — what to do at session start, how to handle memory, what's off-limits.

### 4. Add your tools

For each service/tool in your setup, create a file in `AI/tools/`:
```bash
# Example: document your server
cat > "/path/to/vault/AI/tools/my-server.md" << 'EOF'
# My Server

- **IP:** 10.0.0.1 (via Tailscale)
- **SSH:** `ssh myserver`
- **OS:** Ubuntu 24.04
- **Purpose:** Development server
- **Services:** Docker, PostgreSQL, Redis

Setup date: 2024-01-15
EOF
```

Then add it to `AI/tools/_index.md`.

### 5. Build your own skills

Use `/skill-builder` to create skills for your specific workflows:
```
> Create a skill for deploying my app to production
```

Skills are stored in your vault and symlinked to Claude Code — they survive updates and sync across machines.

---

## Usage

### Daily Workflow

```
Start Claude Code session
    │
    ├── Claude auto-reads memory (silent)
    │   ├── _index.md (master index)
    │   ├── tools/_index.md (your setup)
    │   └── Recent memory/ files (what happened lately)
    │
    ├── Work normally
    │   Claude already knows your context
    │
    ├── Claude logs important events
    │   → memory/YYYY-MM-DD.md (automatic)
    │
    └── End session
        Everything is persisted for next time
```

### Commands

**Process raw notes:**
```
/compile
```
Dump anything into `AI/raw/` — quick notes, ideas, outputs, whatever. `/compile` sorts them into the right files automatically.

**Audit memory health:**
```
/audit
```
Finds duplicates, dead wikilinks, outdated info, files missing from indexes, and gaps. Reports issues without fixing them — you decide what to action.

### Adding Memory Manually

Claude logs automatically, but you can also:

- **Quick capture:** Drop files in `AI/raw/`, run `/compile`
- **Direct edit:** Edit any file in `AI/` — it's just markdown
- **Tell Claude:** "Remember that we decided to use PostgreSQL instead of SQLite" — Claude updates the right file

---

## Applied Learning — Claude Stops Repeating Mistakes

Every time you correct Claude ("no, don't do it like that", "I told you already"), the lesson is captured as one short imperative sentence — silently, without ceremony:

- **Universal lessons** (apply to everything) go to `applied-learning/ALWAYS.md`, which Claude reads at every session start.
- **Contextual lessons** (only relevant for git, or CSS, or your deploy flow) go to topic files that load only when the task matches — so they don't cost tokens in unrelated sessions.

Example of what ends up in `ALWAYS.md`:

```markdown
## Process
- Never declare a feature broken from indirect signs — verify the actual
  data path or test the running flow before concluding.
- Ask before destructive git operations.
```

Over months this becomes the difference between an assistant that resets to factory settings every session and one that actually works the way you've taught it to.

## Decision Graph — Save the Routes That Worked

Beyond raw memory, the system captures **decisions as a graph**. Every significant decision becomes a note (a **node**) in `AI/decisions/`, and wikilinks between notes are the **edges**. Obsidian's graph view then literally shows the chains: decision → context → outcome → next decision.

Each node records:

```markdown
---
tags: [decision]
status: chosen | rejected | awaiting-outcome | confirmed-good | confirmed-bad
---
# Editorial minimal redesign of the landing page

**Context:** Homepage needed to look premium. Two rounds of animation missed the mark.
**Decision:** User picked "editorial minimal" from concrete visual previews.
**Alternatives:** More animation (rejected — motion wasn't the problem), dark tech-luxury.
**Outcome:** Nailed it. THE ROUTE: "make it prettier" = ask for VISUAL DIRECTION with previews first.

Edges: [[AI/memory/2026-07-01|daily log]] · [[2026-07-02 Related decision]]
```

The lifecycle matters: a decision is created as `chosen` or `awaiting-outcome`, and **updated once the result is known**. Before making a new directional choice, Claude searches the graph first — `confirmed-good` routes get reused, `confirmed-bad` routes get avoided. That's the whole point: stop paying twice for the same discovery.

---

## System Design

### Why Obsidian?

- **Local-first** — your data stays on your machine
- **Plain markdown** — no lock-in, works with any editor
- **Wikilinks** — dense linking between notes creates a knowledge graph
- **Graph view** — visualize connections between your notes
- **Sync** — LiveSync, iCloud, Syncthing, or git for multi-device
- **Extensible** — plugins for everything

### Why Not Just CLAUDE.md?

A single `CLAUDE.md` works for small projects. But it doesn't scale:

- **Token cost** — one big file means Claude reads everything every session
- **No structure** — hard to find or update specific information
- **No history** — no record of what happened when
- **No composability** — can't share knowledge between projects

This system uses `CLAUDE.md` as the *bootstrap* — it tells Claude where to find the vault and what rules to follow. The actual knowledge lives in structured, interlinked notes.

### Core Principles

1. **Single source of truth** — Obsidian vault only. Never `.claude/projects/*/memory/`.
2. **Progressive disclosure** — Claude reads indexes first, then dives deeper as needed.
3. **Skills in vault** — never create skills directly in `~/.claude/skills/`. Vault is the source, symlinks are references.
4. **Atomic notes** — one concept per file, densely interlinked with `[[wikilinks]]`.
5. **Silent bootstrap** — Claude reads memory without announcing it. No "let me check my notes" — just knows.

### File Hierarchy

```
AI/
├── _index.md          # START HERE — master index, lists everything
├── USER.md            # Facts about you (name, timezone, stack, projects)
├── SOUL.md            # Agent personality and values
├── IDENTITY.md        # Agent's self-identity (optional, for persona)
├── AGENTS.md          # Behavioral rules (session-start, memory, safety)
├── BOOTSTRAP.md       # Persistent startup context
├── SKILLS.md          # Inventory of all installed skills
├── tools/
│   ├── _index.md      # Registry of all tools/services
│   ├── my-server.md   # Example: server documentation
│   └── my-api.md      # Example: API credentials & usage
├── applied-learning/
│   ├── _index.md      # Overview + capture workflow
│   ├── ALWAYS.md      # Universal lessons — read every session
│   └── <topic>.md     # Contextual lessons — loaded when relevant
├── decisions/
│   ├── _index.md      # Convention + list of nodes
│   └── YYYY-MM-DD *.md  # One node per significant decision
├── memory/
│   ├── 2024-01-15.md  # Daily log
│   ├── 2024-01-16.md  # Daily log
│   └── ...
└── raw/
    ├── .processed/    # Processed files moved here
    └── (drop files here for /compile)
```

---

## Creating Your Own Skills

Skills are the most powerful part of the system. They're reusable prompt modules that activate based on context.

### Skill Anatomy

```
skill-name/
├── SKILL.md          # Required — main instructions
├── scripts/          # Optional — executable code
├── references/       # Optional — detailed docs loaded on-demand
└── assets/           # Optional — templates, icons
```

### SKILL.md Structure

```yaml
---
name: my-skill
description: What it does AND when to use it. Be specific about triggers.
---

# My Skill

Instructions for Claude when this skill activates.
```

The `description` field is critical — it determines when Claude activates the skill. Make it "pushy" (Claude tends to under-trigger).

### Example: Creating a Deploy Skill

```
> /skill-builder

"Create a skill for deploying to my production server via SSH"
```

The skill builder will:
1. Ask clarifying questions
2. Create `SKILL.md` with proper YAML frontmatter
3. Save to vault under `Claude Code/skills/deploy/`
4. Create symlink to `~/.claude/skills/deploy`
5. Register in `AI/SKILLS.md`

### Progressive Disclosure

Keep `SKILL.md` under 500 lines. For complex skills:

```
cloud-deploy/
├── SKILL.md              # Workflow + decision logic
└── references/
    ├── aws.md            # AWS-specific details
    ├── gcp.md            # GCP-specific details
    └── azure.md          # Azure-specific details
```

Claude reads only the relevant reference file.

---

## Tips & Patterns

### Token Savings

The memory system drastically reduces token usage because Claude doesn't re-read your entire project every session. Instead:

| Without memory | With memory |
|----------------|-------------|
| Re-explain project context | Claude already knows |
| Re-read all project files | Claude reads indexes + relevant notes |
| Repeat past decisions | Decisions logged in memory |
| Re-discover tool configs | Tools documented in `tools/` |

### Multi-Machine Sync

The vault is just files. Sync with any method:

- **iCloud** — automatic on Apple devices
- **Obsidian Sync** — official, paid
- **LiveSync** — free, self-hosted CouchDB
- **Syncthing** — free, P2P
- **Git** — version controlled

Skills and memory travel with the vault. `~/.claude/skills/` symlinks need to be recreated on each machine (run `install.sh` again).

### Headless Server Sync (advanced)

If Claude Code also runs on a headless server (agents, bots, cron jobs) and writes to a server-side copy of the vault, that copy needs a running Obsidian client for LiveSync to work. On a Linux server, run Obsidian headless under Xvfb as a systemd service so it survives reboots:

```ini
# /etc/systemd/system/obsidian-headless.service
[Unit]
Description=Headless Obsidian (LiveSync to CouchDB)
After=network-online.target docker.service
Wants=network-online.target

[Service]
User=youruser
Environment=HOME=/home/youruser
ExecStart=/usr/bin/xvfb-run -a /snap/bin/obsidian
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
sudo apt install xvfb && sudo snap install obsidian --classic
sudo systemctl enable --now obsidian-headless
```

> **Warning — learned the hard way:** if the server-side Obsidian dies silently while agents keep writing to the vault files, those writes exist only locally. When sync comes back up, conflict resolution can pick the wrong side and discard content. Two defenses: (1) systemd's `Restart=on-failure` keeps the client alive; (2) health-check it — a quick `systemctl is-active obsidian-headless` in your monitoring, or check that files in the server vault have fresh mtimes.

### Multi-Project

One vault handles multiple projects. Create project-specific notes under `AI/tools/` or dedicated subfolders:

```
AI/tools/
├── _index.md
├── project-alpha.md    # Stack, decisions, status
├── project-beta.md     # Stack, decisions, status
└── shared-server.md    # Shared infrastructure
```

Cross-project knowledge connects through `[[wikilinks]]`.

---

## Comparison

| Feature | This system | Single CLAUDE.md | claude-code-memory-setup |
|---------|-------------|-------------------|--------------------------|
| Persistent memory | Yes (structured vault) | No | Yes (basic) |
| Auto-bootstrap | Silent, at session start | Manual | Requires `/resume` command |
| Self-improving | Correction capture (applied-learning) | No | No |
| Decision graph | Linked nodes with outcome lifecycle | No | No |
| Skills system | Full (builder + symlinks) | No | No |
| Knowledge graph | Wikilinks + Obsidian graph | No | Basic |
| Maintenance commands | `/compile` + `/audit` | No | No |
| Daily logs | Automatic | No | Manual `/save` |
| Multi-project | Single vault, cross-linked | Per-project | Per-project |
| Token efficiency | Progressive disclosure | Read everything | Read everything |

---

## FAQ

**Does this work with Claude Code on a remote server?**
Yes. Point the vault path to wherever your vault is mounted. If using SSH, mount via SSHFS or sync with Syncthing/rsync.

**Can I use this with other AI coding tools?**
The vault structure and skills are Claude Code specific (uses `CLAUDE.md` and `~/.claude/skills/`). The Obsidian vault itself is just markdown — you could adapt the concept for other tools.

**Do I have to use Obsidian?**
No. Mode C is plain Markdown files in a folder. Claude does the reading and writing, so the memory works the same. Obsidian adds browsing, links and a graph for you as a human. You can open the folder in Obsidian later without migrating.

**Can the memory live in OneDrive, SharePoint or Google Drive?**
Yes, as a synced folder (modes D and E). Claude Code works on files on disk, so the cloud folder must be synced to the computer ("Always keep on this device" in OneDrive, "Mirror files" in Google Drive). Mail, calendar and Teams/Drive documents that are not synced are reached through the claude.ai connectors. Native Google Docs and Sheets are not files and are read through the connector. Details and warnings in [docs/STORAGE-MODES.md](docs/STORAGE-MODES.md).

**Is it safe for customer or personal data?**
The interview asks. With `sensitive_data: some|yes`, `memory-guard` runs strictly (no secrets, no ID numbers, `share:` level on every note) and `gdpr-check` is installed. Note that content you send to Claude is processed by Anthropic under the terms of your plan, and cloud folders also sit with Microsoft or Google. Check your own agreement and ask your data protection contact. This repo is not legal advice.

**How much does it cost?**
Nothing extra. Obsidian itself is free to use. Claude Code is the only cost, and this system *reduces* your token usage.

**Will Claude modify my vault?**
Yes — that's the point. Claude writes to `memory/` logs, updates core files when relevant, and processes `raw/` inbox. It follows the rules in `AGENTS.md` and never deletes without asking.

**What if my vault gets messy?**
Run `/audit`. It finds duplicates, dead links, outdated info, and gaps. Fix what it reports.

---

## Credits

Built by [@microfix](https://github.com/microfix). Tested daily across startup development, business automation, and personal productivity.

- [Obsidian](https://obsidian.md/) — local-first knowledge management
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — Anthropic's coding agent

---

**If this helps you, give it a star and share it with other Claude Code users.**
