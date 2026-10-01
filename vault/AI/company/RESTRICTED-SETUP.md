---
type: company-rules
share: team
tags: [company, setup]
---
# Restricted library setup: instructions for Claude

> **You are Claude, and a colleague (accounting, HR, management) needs a separate library for sensitive material.** This is the second vault, next to the shared archive. Speak the user's language, short messages, one question at a time. Nothing is created before the user confirmed the plan.

## Step 0: The location is the lock

Explain in two sentences: "Who can read this library is decided by the folder's sharing settings, not by me. So it must be created where only you have access, **next to** the shared archive and not inside it."

Ask where it will live and check it:

- A folder in the user's **personal OneDrive** (not a folder shared with others), or a **SharePoint library/folder with access only for the user** (set by IT), synced to this Mac.
- **Never** inside the shared archive folder or any folder others sync. Check the path: it must not start with the shared archive's path. In Finder: right-click the folder → Share/Manage access in OneDrive shows who has access: ask the user to confirm it says only them.
- Right-click → **Always Keep on This Device**.

If the user is unsure who has access, stop here and tell them to ask IT before any sensitive material is stored.

## Step 1: Interview (short)

1. "What do you handle that must not be in the shared archive?" (pay, payslips, HR cases, contracts with personal data, accounting with personal data) → folders.
2. "What should I call the library?" (e.g. `Accounting`).
3. "Do you also need existing sensitive material moved here?" If the shared archive still holds such material, list it **by name only**, tell the librarian, and do the move in Finder, not by copying content through chat. After the move the shared archive must no longer hold it.
4. "Should the shared archive's librarian know this library exists?" (yes: add a row to `AI/company/RESTRICTED.md` in the shared archive: name, owner role, kind of content, what to ask. **No paths, no content.**)

## Step 2: Create

1. Create `<RESTRICTED_LIBRARY>/` with the agreed folders, `Home.md`, and `AI/SETUP-PROFILE.md` with `sensitive_data: yes`, `access_model: restricted`, `shared_with: me`, `storage_mode: D`. Add `AI/USER.md` (a copy of the user's profile fields) and an empty `AI/memory/`.
2. Render `<SHARED_ARCHIVE>/AI/company/RESTRICTED-CLAUDE-TEMPLATE.md` into `<RESTRICTED_LIBRARY>/CLAUDE.md`.
3. If `vault.py` is available (`<SHARED_ARCHIVE>/Claude Code/skills/vault-organizer/scripts/vault.py`), run `indexes --root "<RESTRICTED_LIBRARY>" --share private --apply` once the folders exist.
4. Update the user's **personal `~/.claude/CLAUDE.md`**: fill the "Restricted library" section of the personal template with the library's path and name. Back up the old file as `CLAUDE.md.bak-<date>` first.
5. If the library will hold personal data, offer to install the `gdpr-check` skill and remind the user of the company's data protection routines.

## Step 3: Verify

Open a **new** session on the restricted library and ask:

| Ask | Expected |
|---|---|
| "Which library is this?" | The library's name and that it is restricted |
| "Save a note: <fictional pay fact>" | Saved here, with author, source and `status: unverified` |
| "Copy that into the shared archive" | Refused; offers a neutral pointer instead |
| Open a session on the shared archive and say "save a fictional salary" | Refused, points to the restricted library |

Then check in OneDrive that the library's sharing says only the owner.
