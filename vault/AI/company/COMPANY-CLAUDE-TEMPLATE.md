---
type: template
share: team
tags: [company, template]
---
# Template: shared CLAUDE.md for the archive root

The librarian renders this into `<ARCHIVE>/CLAUDE.md` (fill the `<...>` fields, remove this header). Claude reads it automatically in every session opened on the archive folder, for everyone. Keep it short: rules and pointers only, no company facts (facts live in the notes).

---

# CLAUDE.md: shared rules for <GROUP / COMPANY NAME>

Applies to everyone who opens a session in this folder. Personal details (who you are, your role) are in your own CLAUDE.md. If the two disagree about company rules, this file wins.

## What this folder is
The company's single source of truth, an Obsidian vault. Everything about our companies, customers, projects, offers, meetings and processes lives here. It is the only source.

## Companies
<Company A>, <Company B>, <Company C>. Shared across companies: `Shared/`. Unsorted: `Inbox/`. People and roles: `People/`.

## Finding things
`Home.md` → `Companies/<Company>/_index.md` → the folder's `_index.md` → the notes. Never answer company facts from memory. If the vault and your memory disagree, the vault wins. If the vault has nothing, say so. Do not guess. Name the note you used.

## Writing
Use the `vault-keeper` skill for everything you read or write here. Short version: new information is a new note, one writer per file, every note has author, source and `status: unverified`, link it from the nearest `_index.md`, never delete.

## What never goes in
Salaries and pay, HR cases, health information, CPR numbers, private addresses and phone numbers, bank details, passwords and keys. Everyone can read this archive. Refuse, say where it belongs instead, and tell <LIBRARIAN> if such material is already here. People who handle such material have a separate restricted library that only they can open. Which ones exist: `AI/company/RESTRICTED.md` (names and owners, never content). If you need something that lives there, say "that is handled by <owner>, it is not in the shared archive".

## Systems of record
Cases, hours, invoices and accounting live in other systems. See `AI/company/SYSTEMS.md`. Point to the system, never invent numbers.

## People and roles
`People/_index.md` and `AI/company/ROLES.md`. Roles shape what you show first. They do not limit access.

## Maintained by
<LIBRARIAN>. Ask before changing this file, `AI/company/` or the folder structure.
