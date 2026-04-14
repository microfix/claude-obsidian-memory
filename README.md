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
- **Skills system** — reusable prompt modules for common tasks
- **Maintenance commands** — `/compile` to process raw notes, `/audit` to find issues
- **Daily logs** — automatic session logging for full history

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
│  ├── SKILLS.md         ← Skill inventory         │
│  ├── tools/            ← Setup & service docs     │
│  │   └── _index.md     ← Tools registry          │
│  ├── memory/           ← Daily logs (YYYY-MM-DD) │
│  └── raw/              ← Inbox for loose notes    │
│                                                 │
│  Claude Code/skills/   ← Skill definitions       │
│  ├── skill-builder/                              │
│  ├── obsidian-markdown/                          │
│  ├── obsidian-bases/                             │
│  ├── obsidian-cli/                               │
│  └── defuddle/                                   │
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
3. Reads the 2-3 most recent `memory/` files
4. Loads relevant context based on what you're working on
5. Answers — without you explaining anything

## What's Included

| Component | Description |
|-----------|-------------|
| **Vault template** | Pre-structured Obsidian vault with AI memory architecture |
| **CLAUDE.md** | Global instructions that teach Claude how to use the vault |
| **5 skills** | Skill builder, Obsidian Markdown, Obsidian Bases, Obsidian CLI, Defuddle |
| **2 commands** | `/compile` (process raw notes) and `/audit` (find issues) |
| **Install script** | One command to set up everything |

### Skills Included

| Skill | Purpose |
|-------|---------|
| `skill-builder` | Create and improve new skills with proper structure |
| `obsidian-markdown` | Write correct Obsidian Flavored Markdown (wikilinks, callouts, embeds, properties) |
| `obsidian-bases` | Create `.base` files (database-like views with filters and formulas) |
| `obsidian-cli` | Interact with running Obsidian via CLI (read, create, search, manage notes) |
| `defuddle` | Extract clean markdown from web pages (saves tokens vs raw HTML) |

### Commands Included

| Command | Purpose |
|---------|---------|
| `/compile` | Process everything in `AI/raw/` inbox into the correct files |
| `/audit` | Scan memory for duplicates, dead links, outdated info, gaps |

---

## Installation

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- [Obsidian](https://obsidian.md/) installed (free)
- An existing Obsidian vault (or create a new one)

### Quick Install

```bash
git clone https://github.com/microfix/claude-obsidian-memory.git
cd claude-obsidian-memory
./install.sh
```

The install script will:
1. Ask for your Obsidian vault path
2. Copy the `AI/` memory structure into your vault
3. Copy skills into your vault under `Claude Code/skills/`
4. Create symlinks from `~/.claude/skills/` to your vault
5. Install commands to `~/.claude/commands/`
6. Generate a `CLAUDE.md` with your vault path

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
for skill in skill-builder obsidian-markdown obsidian-bases obsidian-cli defuddle; do
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

**How much does it cost?**
Nothing. Obsidian is free. Claude Code is the only cost, and this system *reduces* your token usage.

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
