---
tags:
  - core
  - skills
---

# Skills Overview

All Claude Code skills installed in this system. Skills live in the vault under `Claude Code/skills/` and are symlinked to `~/.claude/skills/`.

## Installed Skills

| Skill | Purpose | Trigger |
|-------|---------|---------|
| `skill-builder` | Create and improve Claude Code skills | "create a skill", "new skill", "improve skill" |
| `obsidian-markdown` | Write correct Obsidian Flavored Markdown | Working with `.md` files, wikilinks, callouts, embeds |
| `obsidian-bases` | Create `.base` files with views, filters, formulas | Working with `.base` files, database views |
| `obsidian-cli` | Interact with running Obsidian via CLI | Vault operations, note management, plugin dev |
| `defuddle` | Extract clean markdown from web pages | Reading URLs, web articles, documentation |

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
