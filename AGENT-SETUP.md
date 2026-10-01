# AGENT-SETUP.md: instructions for Claude (or any AI agent)

> **You are an AI agent and someone gave you this repo URL.**
> This file is your complete instruction set. Follow it top to bottom. **Interview first, install second.** Ask the user only where a step says to.

The user's message will look something like:

> Set up the memory system from github.com/microfix/claude-obsidian-memory

They may or may not name a folder. You do not need one yet: the interview finds it.

**Folder from the session:** if the user named no folder, take the session's working directory (`pwd`) as the proposed `vault_path`, especially when it already holds `.md` files or an `.obsidian` folder. Confirm it in one line in the interview ("I'm in `<path>`, shall the memory live here?") before using it. If you run in the Claude desktop app, the user picked this folder when starting the session, so this is almost always right.

**No terminal needed:** the user may only have pasted the GitHub link in the Claude app. Run the shell commands yourself. If you cannot run a shell, use Step 4b and the slash-command fallbacks in Step 4.

## Step 0: Get the repo

```bash
git clone https://github.com/microfix/claude-obsidian-memory.git /tmp/claude-obsidian-memory
cd /tmp/claude-obsidian-memory
```

If you have no shell access, read the files from the GitHub URL instead. Everything below still works, you just write the files by hand (Step 4b).

## Step 1: Interview the user

Read [INTERVIEW.md](INTERVIEW.md) and run it. It asks about language, what they do, what they already have (Markdown, Obsidian, Microsoft 365, Google Drive), where files live, whether they want Obsidian, devices, sharing and sensitive data. It ends with a plan the user must confirm.

**Do not install, write or change anything before they say yes to the plan.**

The interview gives you these decisions:

| Decision | Values |
|---|---|
| `storage_mode` | A new Obsidian vault · B existing Obsidian vault · C plain Markdown folder · D Microsoft 365 · E Google Drive |
| `vault_path` | folder that will contain `AI/` |
| `obsidian` | yes / no / later |
| `skills_install` | link / copy |
| `skill_packs` | core + any of obsidian, documents, microsoft-365, google, compliance, structure, code, builder |
| `shared_with`, `sensitive_data`, `language`, `style` | for `memory-guard`, tone and `AI/SETUP-PROFILE.md` |

Mode details and the exact steps for cloud drives: [docs/STORAGE-MODES.md](docs/STORAGE-MODES.md). Read the section for the chosen mode before Step 2.

## Step 2: Run the installer

The installer is idempotent. It only adds `AI/` and `Claude Code/` to the folder, never touches the user's existing files, and merges instead of overwriting if `AI/` already exists.

| Mode | Command |
|---|---|
| A new vault, B existing vault | `./install.sh --vault "<VAULT_PATH>" --yes` |
| C plain folder | `./install.sh --vault "<VAULT_PATH>" --yes --no-obsidian` |
| D Microsoft 365, E Google Drive | `./install.sh --vault "<VAULT_PATH>" --yes --skills-mode copy` (add `--no-obsidian` if they don't want Obsidian) |

Extra skills from the compliance and structure packs: append `--skills gdpr-check,icm-architect` (only the ones chosen). **Organize level 1 or 2: append `--organized`** (installs `vault-organizer`, adds the single-source-of-truth block to CLAUDE.md, and with level 2 keep Obsidian on, i.e. no `--no-obsidian`).

If the installer fails (unsupported OS, no shell, permissions), do the manual install in Step 4b.

## Step 3: Existing material (when files already exist)

Depends on `organize_level` from the interview:

- **Level 0:** the read-only orientation pass from [docs/STORAGE-MODES.md](docs/STORAGE-MODES.md). Nothing is moved.
- **Level 1 or 2:** hand over to the `vault-organizer` skill (installed with `--organized`). It runs: backup → inventory → company mapping → **plan the user approves** → move (level 2) → frontmatter → index files → Obsidian setup → verification → update the user's CLAUDE.md so the vault is the single source of truth. Everything is journaled and undoable. Follow its `SKILL.md` phase by phase and stop at every ✋.

Never move, rename or delete anything outside these approved phases.

## Step 4: Anthropic's own skills and connectors (if the packs call for them)

These are not copied into the repo, they come from the source. Details in [docs/SKILLS-CATALOG.md](docs/SKILLS-CATALOG.md).

- **Documents pack** (Word, Excel, PowerPoint, PDF): in Claude Code run
  ```
  /plugin marketplace add anthropics/skills
  /plugin install document-skills@anthropic-agent-skills
  ```
  Then run `/plugin` and confirm they show as installed. If a name has changed, follow <https://github.com/anthropics/skills>. If you cannot run slash commands yourself, tell the user to type them.
- **Builder / Code packs:** `/plugin install example-skills@anthropic-agent-skills` (contains `skill-creator`, `frontend-design`).
- **Microsoft 365 / Google packs:** these are claude.ai **connectors**. Tell the user to add them in Claude → Settings → Connectors and approve what they allow. You cannot do this for them. Explain what each connector can see before they approve.

## Step 4b: Manual install (fallback only)

Create this structure by hand:

```
<VAULT_PATH>/AI/
├── _index.md            # Master index, the entry point
├── SETUP-PROFILE.md     # Filled from the interview
├── USER.md              # Facts about the user
├── SOUL.md              # Personality, tone, language
├── IDENTITY.md          # Agent self-identity
├── AGENTS.md            # Behavioral rules
├── BOOTSTRAP.md         # Startup context
├── SKILLS.md            # Skill inventory
├── tools/_index.md
├── applied-learning/    # ALWAYS.md + _index.md
├── decisions/_index.md
├── memory/              # Daily logs, empty at start
└── raw/                 # Inbox for loose notes
```

Copy `vault/AI/` for the files and `vault/Claude Code/skills/<name>` for each chosen skill into `<VAULT_PATH>/Claude Code/skills/`. Install skills into `~/.claude/skills/<name>`:
symlinks in mode link, plain copies in mode copy or on native Windows. Copy `commands/*.md` to `~/.claude/commands/`.

## Step 5: CLAUDE.md, the bootstrap file

`CLAUDE.md` is what makes Claude read the memory at the start of every session. **Without it, nothing else works.** The installer writes it from `claude-md-template.md` (Obsidian-only parts removed in mode C, extra skill rows added for the chosen packs).

| Platform | Path |
|---|---|
| macOS / Linux | `~/.claude/CLAUDE.md` |
| Windows (native) | `C:\Users\<name>\.claude\CLAUDE.md` |
| Per-project alternative | `<project>/CLAUDE.md` (only applies inside that project) |

**If a CLAUDE.md already exists:** the installer asks, and keeps a `CLAUDE.md.bak`. If the user declines, do NOT overwrite. Read the existing file and merge in the missing sections (Memory, Rules, Skills, Documents). Preserve what the user wrote.

**If you cannot write to `~/.claude/` at all** (sandboxed, no filesystem access): output the fully rendered content in a code block, tell the user the exact path, and have them create the file.

## Step 6: Fill in the profile

From the interview answers, write:

1. `<VAULT_PATH>/AI/SETUP-PROFILE.md`: every field filled in (mode, paths, packs, flags). Delete none.
2. `<VAULT_PATH>/AI/USER.md`: name, work, language, devices, preferences.
3. `<VAULT_PATH>/AI/SOUL.md`: tone and language ("answer in Danish, short and direct", whatever they chose).
4. `<VAULT_PATH>/AI/SKILLS.md`: tick the installed skills.

Run `memory-guard`'s checks on all four before writing: no secrets, no ID numbers.

## Step 7: Verify

Show the user the result:

```bash
ls "<VAULT_PATH>/AI/_index.md" "<VAULT_PATH>/AI/SETUP-PROFILE.md"
ls ~/.claude/skills/                           # chosen skills present
ls ~/.claude/commands/compile.md ~/.claude/commands/audit.md
head -5 ~/.claude/CLAUDE.md
grep -c "<VAULT_PATH>" ~/.claude/CLAUDE.md     # must be 0, no unreplaced placeholders
grep -E "storage_mode|sensitive_data|shared_with" "<VAULT_PATH>/AI/SETUP-PROFILE.md"
anydoc --version 2>/dev/null || echo "anydoc not installed (optional, needs npm)"
```

Cloud modes: also check that a note you just created appears in the synced folder on the cloud side, and that `ls` on a file inside it shows real size (not a 0-byte placeholder).

Then tell the user: **restart Claude Code** (new session) so CLAUDE.md is picked up. From the next session on, Claude reads its memory silently at the start and writes to it as it works. Offer to re-run the interview any time ("run the setup interview again").

## What you just set up

- **Persistent memory** in `AI/`: indexes, daily logs, applied learning, decision graph, setup profile.
- **Skills** from the packs the user chose. See [docs/SKILLS-CATALOG.md](docs/SKILLS-CATALOG.md) for which come from Anthropic, which from the Obsidian community and which are included here.
- **2 commands**: `/compile` (process the raw inbox), `/audit` (memory health check).

Full documentation: [README.md](README.md)
