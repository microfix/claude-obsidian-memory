---
type: template
share: team
tags: [company, template]
---
# Template: personal CLAUDE.md

Rendered by Claude during the personal setup interview into `~/.claude/CLAUDE.md` on the user's Mac. Fill the `<...>` fields from the interview. Keep it short.

---

# CLAUDE.md: <NAME>

## About me
- **Name:** <NAME> (call me <FIRST NAME>)
- **Title:** <TITLE>
- **Company:** <COMPANY OR COMPANIES>
- **Role:** <ROLE from AI/company/ROLES.md>
- **Language and tone:** <LANGUAGE>, <short | balanced | thorough>. <Personal wishes in one line>

## The company archive
- **Archive:** `<ARCHIVE_PATH>`
- At the start of every session read `<ARCHIVE_PATH>/CLAUDE.md` (shared company rules), then `<ARCHIVE_PATH>/People/<SLUG>.md` (my profile). Silently, no announcing.
- Use the `vault-keeper` skill for everything in the archive.

## What I do with it
- **I normally write to:** <FOLDERS>
- **I normally read:** <FOLDERS>
- **Data I put in:** <e.g. meeting notes, offers, site photos>
- **Data I take out:** <e.g. status reports, offers, overviews>
- **Systems I use:** <from AI/company/SYSTEMS.md>
- **My own log:** `<ARCHIVE_PATH>/People/<SLUG>/` (only I write there)

## My restricted library (only if I have one)
- **Library:** `<RESTRICTED_LIBRARY_PATH>` (<NAME>). Only I can open it. Read `<RESTRICTED_LIBRARY_PATH>/CLAUDE.md` when working there.
- Sensitive material (<pay, HR, accounting with personal data>) is written **only** there, never in the shared archive.
- Never copy content from it into the shared archive. A neutral pointer is fine. Aggregated figures only when I say so in the session.
- Unsure which library a write belongs to: ask in one line first.
<!-- Remove this whole section if I have no restricted library. -->

## Rules that apply in every folder
- The archive is the only source for company facts. If it disagrees with your memory, the archive wins. If it has nothing, say so. Do not guess. Name the note you used.
- New information is a new note with author, source and `status: unverified`. One writer per file. Never delete.
- No salaries, HR matters, health, CPR numbers, private contact details, passwords or keys in the shared archive. Refuse and say where it belongs (my restricted library if I have one).
- Cases, hours, invoices and accounting live in the systems of record: point there.
- Documents: read with `anydoc`, never the raw binary.
