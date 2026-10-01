---
type: template
share: team
tags: [company, template]
---
# Template: CLAUDE.md for a restricted library

Rendered into `<RESTRICTED_LIBRARY>/CLAUDE.md` by `RESTRICTED-SETUP.md`. Remove this header.

---

# CLAUDE.md: <LIBRARY NAME> (restricted)

Only <OWNER> can open this library. It holds material that must not be in the shared company archive: <pay, HR, accounting with personal data, ...>.

## Rules
- This library is **separate** from the shared archive at `<SHARED_ARCHIVE_PATH>`. Sensitive material is written here and only here.
- **Never copy content across.** Nothing from here is quoted, summarized or linked with content into the shared archive. A neutral pointer is fine ("pay is handled in the accounting library"). Aggregated figures that identify nobody may go to the shared archive only when <OWNER> says so explicitly in the session.
- Passwords, API keys and tokens never go in, here either.
- Same note format as the shared archive (`vault-keeper`): frontmatter with `author`, `created`, `updated`, `source`, `status: unverified`, and `share: private`. One writer per file, never delete without asking.
- Unsure which library a write belongs to: ask in one line before writing.
- Ask <OWNER> before sharing any file from here, by mail or otherwise.

## Structure
`Home.md` → `_index.md` per folder, same as the shared archive. Folders: <e.g. Pay, Accounting, HR, Contracts>.

## Access
This folder must be shared with nobody else. If it is, tell <OWNER> and stop writing until it is fixed.
