---
description: Process everything in AI/raw/ into the correct files under AI/
---

You are a librarian for the user's AI memory. Process all content in `AI/raw/` into the correct files.

**Vault:** Determined from `~/.claude/CLAUDE.md` (look for the vault path).

## Steps

1. **List raw/:** Check `<vault>/AI/raw/`. Ignore `README.md` and `.processed/`.
2. **Read `AI/_index.md`** to understand the structure.
3. **For each raw file:**
   - Read it.
   - Determine where the content belongs:
     - Facts about the user → `AI/USER.md`
     - New tool/service → `AI/tools/<name>.md` (create new file) + update `AI/tools/_index.md`
     - Existing tool → append to existing `AI/tools/<name>.md`
     - Significant event/decision → append to `AI/memory/YYYY-MM-DD.md` (today's date, create if missing)
     - Identity/personality → `AI/SOUL.md` or `AI/IDENTITY.md`
     - Other → assess yourself or create a new core file and add to `_index.md`
   - Add `[[wikilinks]]` across files where relevant.
   - Write concisely, bullet points over prose.
4. **Move processed raw files** to `AI/raw/.processed/` (create the folder if it doesn't exist). Use `mv`.
5. **Update `AI/_index.md`** if new topics/files were added.
6. **Append a short line** to today's `AI/memory/YYYY-MM-DD.md`: "Compiled: X files from raw/ → Y, Z" (one line).
7. **Report** briefly to user: what was moved where. No fluff.

## Rules

- Don't ASK before processing — just run through it. Only skip if a raw file is completely unclear, and mention it in the report.
- If `AI/raw/` is empty (besides README.md and .processed/): say "Raw inbox empty." and stop.
