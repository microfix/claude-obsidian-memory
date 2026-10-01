---
name: vault-keeper
description: The company-wide rules for reading and writing the shared Markdown archive (the vault) that several people use at once. Activate ALWAYS when a session works in the shared archive, when the user asks about a company, customer, project, offer, meeting or process, when the user hands over a document, mail, photo or meeting transcript to be saved, when new facts should be remembered for the company, or when the user says "save this", "note this", "add to the archive", "what do we know about". Defines where things are found and filed, the note format with author and source, how several writers avoid conflicts, how facts get verified, and which data stays out of the archive.
---

# Vault Keeper

The shared archive is the company's single source of truth. Several people and several Claudes write to it. Everyone has the same rights, so the rules below are what keeps it clean. Speak the user's language, keep messages short, and apply the rules silently.

Company-specific details (names of companies, roles, systems) are in the archive, not here:
- `CLAUDE.md` in the archive root: company rules and the list of companies
- `AI/company/ROLES.md`: who does what and which areas each role normally writes to
- `AI/company/SYSTEMS.md`: which external system owns which kind of data
- `People/<name>.md`: who the current user is (see "Who am I")

## Who am I

At session start read the personal profile named in the personal `CLAUDE.md` (`People/<name>.md`). It tells you the user's name, title, which company they work for, what they normally read and write, and which systems they use. Adapt: a project manager gets project and customer material first, an accountant gets finance first. Roles shape focus and defaults. They are **not** access control: everyone can read everything, so never rely on a role to hide something.

## Reading

1. `Home.md` → `Companies/<Company>/_index.md` → the folder's `_index.md` → the notes. Never answer company facts from memory.
2. Who is who: `People/_index.md`. Which system owns what: `AI/company/SYSTEMS.md`.
3. Answer with the source: name the note (`[[Note]]`), so people can check.
4. If the archive says nothing, say "that is not in the archive". Do not guess. If notes contradict each other, show both with dates and ask which is right.
5. Data that lives in an external system of record (cases, hours, invoices, accounting) is not in the archive. Point to the system, do not invent numbers.

## Writing

**One writer per file, new notes over edits.** Two people editing the same note at once makes OneDrive create conflict copies. So:

- **New information → a new note**, not an edit of someone else's. Meetings, calls, decisions, offers, findings: one note each, dated.
- **Editing an existing note** is allowed for corrections and additions. Make small targeted edits, never rewrite a whole note, never delete other people's text. Outdated text is marked with `> [!warning] Outdated YYYY-MM-DD, see [[New note]]`, not deleted. Update `updated` and `updated_by`.
- **Before editing**, check that no conflict copy of the note exists (`name-<computer>.md`). If one does, tell the user and do not edit.
- **Personal material** (your own log, your own lessons) goes in `People/<name>/`. Only you write there.
- **Never delete** files. Ask first, and then move to `Inbox/` marked for the librarian.

### Where it goes

| What | Where |
|---|---|
| About one company | `Companies/<Company>/<topic folder>/` (use the folder the company already uses) |
| Applies to several companies | `Shared/` |
| Unsure where it belongs | `Inbox/` and tell the user in one line |
| Your own log and personal notes | `People/<name>/` |
| Company-level rules, roles, systems | `AI/company/` (rarely edited; ask before changing) |

### Note format

```markdown
---
company: <Company>
type: <customer | project | offer | meeting | decision | process | finance | note>
tags: [company/<slug>]
share: team
author: <who asked for it>
created: YYYY-MM-DD
updated: YYYY-MM-DD
source: "<where this comes from: a document, a mail, 'said by X in a meeting on date'>"
status: unverified
---
# Title

Short, factual. Wikilinks to customers, projects and people: [[Customer]], [[Project]].
```

- File name: `YYYY-MM-DD Title.md` for events, `Name.md` for things that last. No `/ \ : * ? " < > |`. If the name already exists in another folder, add the company: `Hansen (Company A).md`.
- Use the `obsidian-markdown` skill for syntax: wikilinks, callouts, properties.
- **Provenance is mandatory.** `author`, `created` and `source` always. Facts the user just told you: `source: "told by <name>, <date>"`. Facts from a document: the document's path or name. Never write a fact you cannot give a source for.
- **`status: unverified`** on everything Claude writes. A person changes it to `verified` after checking. Do not set `verified` yourself unless the user says so in this session.
- Every note is linked from the nearest `_index.md`. After writing, update the index: `python3 "<archive>/Claude Code/skills/vault-organizer/scripts/vault.py" indexes --root "<archive>" --only "<folder>" --apply`. If Python is not available, add the line by hand inside the folder's `_index.md`. Conflicts in the generated index block heal by re-running the command.

## When the user hands you something

A document, mail, photo, spreadsheet or meeting transcript to save:

1. Read it (`anydoc` for Word, Excel, PDF, PowerPoint; never the raw binary).
2. Decide company, type and folder from the table above. Ask one short question if it is unclear.
3. Write one note with the format above. Keep the original file next to it (same folder) and link it: `[[original.docx]]`. Extract only what is useful: facts, decisions, amounts, dates, names, next steps.
4. Link the note from the customer, project or company note it belongs to.
5. Tell the user in one line where it went.

## Taking data out

Reports, summaries, offers, slides: write them with the Anthropic document skills (`docx`, `xlsx`, `pptx`) into the right company folder, or on the user's request elsewhere, and link them from a note. State the notes used as sources in the document.

## What never goes in the archive

Everyone can read everything here, so the archive must not hold: salaries and pay, HR cases and evaluations, health information, national ID numbers (CPR), private addresses and phone numbers, bank details, passwords and API keys, confidential personal matters about a colleague or customer. If the user asks you to save such a thing, refuse in one sentence, say where it should go instead (outside the archive), and save a neutral note without the sensitive part if that helps. If you find such material already in the archive, do not copy it anywhere, and tell the user who maintains the archive. `memory-guard` backs this up.

## Keeping it healthy

- Now and then run `vault.py check` (the `/audit` command does). It lists broken links, folders without index, notes without frontmatter, conflict copies and notes still `unverified`.
- Conflict copies: list them to the user, never delete. The two people involved decide which version stays.
- Periodic review (the archive's librarian): go through `status: unverified` notes oldest first, confirm or correct, set `verified`.
