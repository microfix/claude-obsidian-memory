# Skills catalog

Three kinds of skills, kept apart so you can tell customers exactly where each one comes from.

## 1. Made by Anthropic

Not copied into this repo. They are maintained by Anthropic, so install them from the source and they stay up to date.

| Skill | What it does | Pack |
|---|---|---|
| `docx` | Create and edit Word documents | Documents |
| `xlsx` | Create and edit Excel spreadsheets (formulas, formatting, charts) | Documents |
| `pptx` | Create and edit PowerPoint decks | Documents |
| `pdf` | Read, fill and create PDFs | Documents |
| `skill-creator` | Anthropic's own tool for building and testing skills | Builder |
| `frontend-design` | Distinctive web UI instead of generic AI look | Code |

**Install** (in Claude Code):

```
/plugin marketplace add anthropics/skills
/plugin install document-skills@anthropic-agent-skills
/plugin install example-skills@anthropic-agent-skills
```

`document-skills` holds docx/xlsx/pptx/pdf; `example-skills` holds `skill-creator`, `frontend-design` and others. Run `/plugin` afterwards and check they show as installed, because plugin and marketplace names can change. Source: <https://github.com/anthropics/skills>. In the Claude apps (claude.ai, desktop) the same document skills are switched on under Settings → Capabilities → Skills.

**Built into Claude Code** (nothing to install, available in current versions): `/code-review`, `/simplify`, `/security-review`, `/loop` (repeat a task on an interval), `/schedule` (cloud routines on a cron schedule), `/init` (create a CLAUDE.md for a codebase), `/run`.

**Connectors** (claude.ai account, Settings → Connectors): Microsoft 365 (Outlook, Teams, SharePoint, calendar), Gmail, Google Drive, Slack and more. These are not skills but they are what makes the cloud modes useful. See [STORAGE-MODES.md](STORAGE-MODES.md).

## 2. From the Obsidian community

Included in this repo under `vault/Claude Code/skills/`. Origin: the Obsidian skills published by Steph Ango (kepano), the creator of Obsidian. Check the upstream repository for newer versions.

| Skill | What it does |
|---|---|
| `obsidian-markdown` | Correct Obsidian Flavored Markdown: wikilinks, embeds, callouts, properties |
| `obsidian-bases` | `.base` files: database-like views with filters and formulas |
| `obsidian-cli` | Drive a running Obsidian from the command line (search, create, read) |
| `json-canvas` | `.canvas` files: mind maps, flowcharts, visual boards |
| `defuddle` | Clean Markdown from a web page (saves tokens vs raw HTML) |

Only installed when Obsidian is used (modes A, B; optional in D, E). `defuddle` is useful in every mode and is part of Core.

## 3. Included here (ours or third-party with licence)

| Skill | What it does | Pack | Notes |
|---|---|---|---|
| `skill-builder` | Create and improve skills with correct structure, registers them in `AI/SKILLS.md` | Core | |
| `memory-guard` | Pre-write gate: blocks secrets, flags personal data, sets `share:` level | Core | Written for this system |
| `anydoc` | Any document (PDF, Word, Excel, PowerPoint, ODF, RTF, EPUB, CSV) to Markdown before reading | Core | Needs `npm install -g @firecrawl/anydoc` |
| `gdpr-check` | Audits software, flows and specs against GDPR with article references | Compliance | Danish-language report; includes the GDPR text and 2026 Digital Omnibus notes. Not legal advice |
| `icm-architect` | Turns a process, team or body of knowledge into a folder structure an agent can walk | Structure | MIT licence, Van Clief and McDermott (Interpretable Context Methodology) |

## Picking packs from the interview

See question 10 in [INTERVIEW.md](../INTERVIEW.md). Short version:

- **Everyone:** Core.
- **Uses Obsidian:** + Obsidian.
- **Lives in Word/Excel/PowerPoint:** + Documents (Anthropic).
- **Microsoft or Google workspace:** + the matching connector.
- **Customer or personal data:** + Compliance.
- **Wants a team knowledge base or repeatable workflows:** + Structure.

## Adding your own

Ask Claude: "create a skill for X". `skill-builder` writes it into the vault (`Claude Code/skills/<name>/SKILL.md`), links or copies it into `~/.claude/skills/`, and adds it to `AI/SKILLS.md`. Make the `description:` specific about when to trigger. That line decides whether the skill ever fires.

## Skill routing in CLAUDE.md

Skills only fire when Claude chooses to use them. `claude-md-template.md` therefore ships a short "Skills: when to use which" table. The installer fills it with the skills the interview selected. If a skill never fires, strengthen its `description:` or add a row to that table.
