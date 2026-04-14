---
name: skill-builder
description: Build new Claude Code skills, improve existing skills, and structure them correctly. Use this skill when the user wants to create a new skill, edit an existing one, or optimize a skill's trigger description. Also activate on "create a skill", "new skill", "skill for X".
---

# Skill Builder

This skill guides creation and improvement of Claude Code skills.

## Workflow

### 1. Understand the Skill

Start by understanding what the user wants. Deduce what you can from context first, then ask:

1. What should the skill do? What's the purpose?
2. When should it trigger? (which user prompts activate it)
3. What's the expected output format?
4. Does it need access to specific tools, files, or APIs?

### 2. Skill Anatomy

```
skill-name/
├── SKILL.md          # Required — main instructions
├── scripts/          # Optional — executable code for deterministic tasks
├── references/       # Optional — docs loaded into context on-demand
└── assets/           # Optional — files used in output (templates, icons, fonts)
```

#### Progressive Disclosure (three levels)

1. **Metadata** (name + description) — Always in context (~100 words). Determines whether the skill triggers.
2. **SKILL.md body** — Loaded when the skill activates. Keep under 500 lines.
3. **Bundled resources** — Loaded on-demand. Scripts can execute without loading the entire file.

Use this to keep SKILL.md lean. If approaching 500 lines, move details to `references/` files with clear pointers from SKILL.md.

**Domain organization** — When a skill supports multiple frameworks/variants:
```
cloud-deploy/
├── SKILL.md (workflow + choice logic)
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```
Claude reads only the relevant reference file.

### 3. Create the Skill File

Skill files live physically in the Obsidian vault and are symlinked to Claude Code:
- **Physical location:** `<vault>/Claude Code/skills/<skill-name>/SKILL.md`
- **Symlink:** `~/.claude/skills/<skill-name>` → vault folder

Create both:
```bash
# 1. Create directory in vault
mkdir -p "<vault>/Claude Code/skills/<skill-name>"

# 2. Write SKILL.md in vault directory

# 3. Symlink to Claude Code
ln -sf "<vault>/Claude Code/skills/<skill-name>" ~/.claude/skills/<skill-name>
```

### 4. YAML Frontmatter

The first lines MUST be YAML frontmatter:
```yaml
---
name: <skill-name>
description: <Description that explains both WHAT the skill does AND WHEN to use it>
---
```

- `name`: Kebab-case (e.g., `skill-builder`, `frontend-design`)
- `description`: This is the primary trigger mechanism. See "Writing good descriptions" below.

### 5. Write the Skill Content

#### Writing Style

- **Explain WHY, not just WHAT.** Instead of rigid MUST/NEVER rules, explain reasoning. LLMs are smart — they understand intent and can generalize when they understand the purpose.
- **Use imperative form** in instructions.
- **Include examples** — they're more effective than abstract rules.
- **Keep it general** — avoid overfitting to specific examples.
- **Remove what doesn't work** — if something wastes Claude's time, remove it.

#### Output Format Pattern
```markdown
## Report Structure
Always use this template:
# [Title]
## Executive summary
## Key findings
## Recommendations
```

#### Examples Pattern
```markdown
## Commit message format
**Example 1:**
Input: Added user authentication with JWT tokens
Output: feat(auth): implement JWT-based authentication
```

### 6. Writing Good Descriptions

The description field determines whether Claude activates the skill. Good descriptions:

- Explain **what** the skill does AND **when** to use it
- Are slightly "pushy" — Claude tends to *under*-trigger skills
- Include concrete trigger words and contexts

**Bad:**
```yaml
description: Builds dashboards for internal data.
```

**Good:**
```yaml
description: Build simple, fast dashboards for internal data. Use this skill when the user mentions dashboards, data visualization, internal metrics, or wants to display data — even if they don't explicitly say "dashboard".
```

### 7. Test the Skill

Create 2-3 realistic test prompts — things a real user would type. Run them and evaluate results qualitatively.

### 8. Register the Skill

After creation:

1. **Update the skills overview** in `<vault>/AI/SKILLS.md` — add skill name and short description
2. **Verify** the skill appears in Claude Code's skill list

## Improving Existing Skills

When improving an existing skill:

1. Read the current SKILL.md
2. Understand what needs to change and why
3. Generalize from feedback — don't overfit to specific examples
4. Keep the prompt lean — remove what doesn't pull its weight
5. Explain *why* behind changes — it's more effective than rigid rules
6. Test with a couple of prompts to verify the improvement

## Rules

- Skill files ALWAYS live in the Obsidian vault: `<vault>/Claude Code/skills/`
- Symlinks in `~/.claude/skills/` point to the vault folder
- Skills overview in `<vault>/AI/SKILLS.md`
- YAML frontmatter is REQUIRED
- Description must be "pushy" enough for correct triggering
- Keep SKILL.md under 500 lines — use references/ for details
