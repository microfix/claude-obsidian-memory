---
description: Audit AI/ memory structure for duplicates, outdated info, dead links, and gaps
---

You are a librarian-auditor. Review the AI memory and report problems. **Do NOT fix anything automatically** — only report and suggest.

**Vault:** Determined from `~/.claude/CLAUDE.md` (look for the vault path).

## Steps

1. **Read entry points:**
   - `AI/_index.md`
   - `AI/tools/_index.md`
2. **Read all core files** listed in `_index.md` (USER, SOUL, IDENTITY, AGENTS, BOOTSTRAP, SKILLS, etc.).
3. **Read all files in `AI/tools/`.**
4. **Scan `AI/memory/`** — read at least the 10 most recent files.

## Find

1. **Duplicates** — same fact in multiple places. Report where.
2. **Outdated info** — e.g., "waiting for X" in a core file where memory shows X is resolved. Or setup dates for things that have been removed/changed.
3. **Dead `[[wikilinks]]`** — links pointing to files that don't exist.
4. **Files not in index** — files in `AI/` or `AI/tools/` not listed in the respective `_index.md`.
5. **Gaps** — tools mentioned in memory but without their own file in `tools/`. Important knowledge in memory that should be promoted to a core file.
6. **Inconsistencies** — conflicting info between files (e.g., different IPs, versions, dates for the same thing).

## Report Format

Structured output in the categories above. For each finding:
- **Where:** file path(s) + line numbers if possible
- **What:** short description
- **Suggestion:** what should be fixed

End with an overall assessment: "Memory is healthy" or "N critical things need fixing".

## Rules

- Do NOT fix anything. Only report.
- If the user says "fix it" afterwards, then make the corrections.
