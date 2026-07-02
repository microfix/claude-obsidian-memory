# AI/ - Master Index

Entry point for AI memory. Read this file first at session start.

## Core Files (read at session start)

- [[USER]] — About the user (facts, preferences, work)
- [[SOUL]] — Agent personality and values
- [[IDENTITY]] — Agent self-identity (optional)
- [[AGENTS]] — Behavioral rules (session-start, memory, safety)
- [[BOOTSTRAP]] — Persistent startup context
- [[SKILLS]] — Overview of all Claude Code skills

## Subdirectories

- **[[tools/_index|tools/]]** — Setup-specific notes: servers, APIs, credentials, services
- **[[applied-learning/_index|applied-learning/]]** — Corrections and lessons from the user. ALWAYS is read every session, topic files load contextually.
- **[[decisions/_index|decisions/]]** — Decision graph: one node per significant decision, wikilinks = edges. Search here BEFORE new directional choices; update Outcome once known.
- **memory/** — Daily logs (`YYYY-MM-DD.md`). Read the 2-3 most recent at session start. Append on significant events.
- **raw/** — Inbox. Drop loose notes, outputs, clippings here. Run `/compile` to process.
- **assets/** — Images and media

## Rules (from ~/.claude/CLAUDE.md)

1. Read `_index.md` + `tools/_index.md` + `applied-learning/ALWAYS.md` + `applied-learning/_index.md` + 2-3 most recent `memory/` files at session start. Silently, no announcing.
2. Log significant events to `memory/YYYY-MM-DD.md`.
3. New user knowledge → `USER.md`. New tool → `tools/<name>.md` + update `tools/_index.md`. New skill → `Claude Code/skills/` + symlink + `SKILLS.md`.
4. When the user corrects the agent (auto-capture) → write the lesson to `applied-learning/ALWAYS.md` (universal) or `applied-learning/<topic>.md` (contextual) + update `applied-learning/_index.md` if new file.
5. Significant decisions (auto-capture) → node in `decisions/` with Context/Decision/Alternatives/Outcome + at least 2 wikilink edges. Update status once the outcome is known.
6. Obsidian is the only source of truth for memory. Never write to `.claude/projects/*/memory/`.

## Commands

- `/compile` — Process everything in `raw/` into correct files
- `/audit` — Find duplicates, outdated info, dead links, gaps
