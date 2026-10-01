---
tags:
  - core
  - skills
---

# Skills Overview

All Claude Code skills installed in this system. Skills live in the vault under `Claude Code/skills/` and are linked (or, for cloud folders, copied) into `~/.claude/skills/`. See `SETUP-PROFILE.md` field `skills_install`.

## Installed Skills

Tick what the interview installed. Origin in brackets: **A** = Anthropic, **O** = Obsidian community, **H** = included in the memory-system repo.

| Skill | Origin | Purpose | Trigger |
|-------|--------|---------|---------|
| `skill-builder` | H | Create and improve Claude Code skills | "create a skill", "new skill", "improve skill" |
| `memory-guard` | H | Pre-write gate: secrets, personal data, share level | Before any write to the vault, before committing vault files |
| `anydoc` | H | Convert documents (PDF, Word, Excel, PowerPoint...) to markdown | Any task needing the content of a binary document |
| `defuddle` | O | Extract clean markdown from web pages | Reading URLs, web articles, documentation |
| `obsidian-markdown` | O | Write correct Obsidian Flavored Markdown | Working with `.md` files, wikilinks, callouts, embeds |
| `obsidian-bases` | O | Create `.base` files with views, filters, formulas | Working with `.base` files, database views |
| `obsidian-cli` | O | Interact with running Obsidian via CLI | Vault operations, note management, plugin dev |
| `json-canvas` | O | Create and edit `.canvas` files (mind maps, flowcharts) | Working with `.canvas` files, visual canvases |
| `gdpr-check` | H | GDPR audit of software and data flows | Personal data, cookies, tracking, consent, login |
| `icm-architect` | H | Turn a process or team knowledge into an agent-walkable folder structure | "organize this for agents", repeated multi-step flows |
| `docx` `xlsx` `pptx` `pdf` | A | Create and edit Office files and PDFs | Word, Excel, PowerPoint, PDF as input or output |
| `skill-creator` `frontend-design` | A | Build and test skills; distinctive web UI | New skill; new web UI |

Anthropic skills are installed with `/plugin marketplace add anthropics/skills`. Details: the repo's `docs/SKILLS-CATALOG.md`.

## Adding Skills

Use `/skill-builder` to create new skills. It handles:
1. Creating `SKILL.md` with proper YAML frontmatter
2. Saving to vault under `Claude Code/skills/<name>/`
3. Creating symlink to `~/.claude/skills/<name>`
4. Registering in this file

## Skill Architecture

```
skill-name/
├── SKILL.md          # Required — main instructions
├── scripts/          # Optional — executable code
├── references/       # Optional — detailed docs loaded on-demand
└── assets/           # Optional — templates, icons
```

Skills are stored in the vault (source of truth) and symlinked to `~/.claude/skills/` (where Claude Code reads them).
