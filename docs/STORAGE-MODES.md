# Storage modes

Where the memory lives decides how it is installed. The interview ([INTERVIEW.md](../INTERVIEW.md)) picks one mode. All modes use the same `AI/` structure and the same rules, so a user can move between modes later by moving the folder.

| Mode | Situation | Obsidian | Skills install |
|---|---|---|---|
| **A** New Obsidian vault | Nothing exists yet, or the user wants a clean start | yes (installed if missing) | link |
| **B** Existing Obsidian vault | User already has a vault | yes | link |
| **C** Plain Markdown folder | Notes exist as `.md` without Obsidian, or user wants no Obsidian | no (optional later) | link |
| **D** Microsoft 365 | Files in OneDrive / SharePoint / Teams | optional | copy |
| **E** Google Drive | Files in Google Drive | optional | copy |

## What every mode does the same way

1. **Memory goes in a new `AI/` folder** beside the user's own files. Existing files are never moved, renamed, reformatted or deleted.
2. **Orientation pass (read-only)** for B-E when content exists. Claude lists the top-level folders, counts files per type, samples a few, and writes one map note: `AI/_index.md` section "Existing material" with one line per folder ("`Projects/`: 42 notes, customer projects"). This lets Claude find things later without reading everything. Ask before reading anything the user marked private.
3. **Same rules and skills core**: `CLAUDE.md` bootstrap, `memory-guard`, `anydoc`, `defuddle`, `skill-builder`, `/compile`, `/audit`.
4. `AI/SETUP-PROFILE.md` records the mode.

## Mode A: New Obsidian vault

Run `install.sh --vault <path> --yes` (creates the vault, installs Obsidian if missing, copies `AI/` and skills, symlinks skills, writes `CLAUDE.md`). User opens the folder in Obsidian once to register it as a vault.

## Mode B: Existing Obsidian vault

Run the installer pointing at the existing vault. It only **adds** `AI/` and `Claude Code/`. It will not overwrite an existing `AI/` without asking. If the vault already has its own `AI/` or `Claude Code/` folder with different content, stop and ask: use another folder name (`AI-Memory/`) and set it in `CLAUDE.md`, or merge by hand with the user.

Obsidian skills are installed. If the vault uses its own conventions (tags, folder names, link style), read 3-5 notes during the orientation pass and follow those conventions for the notes you write.

## Mode C: Plain Markdown folder

Same as A, minus Obsidian:

```bash
./install.sh --vault <path> --yes --no-obsidian
```

`--no-obsidian` skips the Obsidian install, leaves out the four Obsidian skills, and strips the Obsidian-specific rules from `CLAUDE.md`. Notes still use `[[wikilinks]]` because they are readable as plain text and the user can open the folder in Obsidian later without migration.

## Mode D: Microsoft 365 (OneDrive, SharePoint, Teams)

**The honest picture.** Claude Code works on files on disk. It cannot mount SharePoint. It can reach Microsoft 365 in two ways, and they do different jobs:

| Job | How |
|---|---|
| **Memory** (`AI/` notes: logs, decisions, learnings) | Lives in a folder **synced to the computer** by the OneDrive client. SharePoint libraries and Teams files work the same way once synced ("Sync" button in the library). |
| **Mail, calendar, Teams chat, searching SharePoint** | The claude.ai **Microsoft 365 connector** (Outlook, Teams, SharePoint). Needs the user to sign in to Claude with their claude.ai account and approve the connector. |
| **Reading Word / Excel / PowerPoint / PDF** | `anydoc` (files on disk) or the connector (files not synced). |
| **Creating Word / Excel / PowerPoint** | Anthropic's `docx`, `xlsx`, `pptx` skills. |

**Setup**

1. Find the synced folder: Windows `C:\Users\<name>\OneDrive - <Company>\`, macOS `~/Library/CloudStorage/OneDrive-<Company>/`. Confirm the exact path with the user.
2. Right-click the target folder → **Always keep on this device**. Without this, OneDrive "Files On-Demand" shows placeholders that Claude cannot read until opened.
3. Create or choose a folder, e.g. `<synced>\Claude-Memory\`. That is `<VAULT_PATH>`.
4. Install with `--skills copy`: skills are copied to `~/.claude/skills/` instead of symlinked. Reason: symlinks into a sync folder break on Windows, and a sync client can lock or version skill files mid-session.
5. Offer the Microsoft 365 connector: in Claude, Settings → Connectors → Microsoft 365. Explain what it can see before they approve. Mail and Teams content is personal data, so `memory-guard` applies when writing anything from it into notes.
6. Obsidian is optional: it can open the synced folder as a vault. Obsidian plugins and `.obsidian/` settings will sync too, which is fine.

**macOS specifics (OneDrive)**

- Path: `~/Library/CloudStorage/OneDrive-<Company>/`. Folder names may contain spaces: always quote paths.
- Finder → right-click the folder → **Always Keep on This Device**. In OneDrive settings, Files On-Demand can stay on; this setting makes the chosen folder real files.
- First access: macOS may ask whether Terminal (or the app running Claude Code) may access files in the OneDrive folder. Answer **Allow**. If Claude says it cannot read the folder, check System Settings → Privacy & Security → Files and Folders (or Full Disk Access) for the terminal app.
- Claude Team plan: the owner of the Claude organization can enable the Microsoft 365 connector for everyone (Admin settings → Connectors). Each user then signs in to Microsoft and approves it for themselves.

**Warnings to say out loud**

- Never store passwords or API keys in the folder. It is synced and may be shared.
- Don't edit the same note on two machines at the same moment. OneDrive makes conflict copies (`note-DESKTOP-ABC.md`). `/audit` finds them.
- Business accounts: the company's admin may block connectors or personal-data processing. The user should ask their IT or data protection contact before pointing Claude at mail or customer files.

### Existing Markdown archive in OneDrive (typical handover case)

The user already has a folder of `.md` files in OneDrive and wants Claude to work with it. Use mode D with `existing_content: markdown`, usually without Obsidian:

```bash
./install.sh --vault "<path to the archive folder>" --yes --no-obsidian --skills-mode copy
```

This adds only `AI/` and `Claude Code/` inside the archive. Then do the orientation pass, tuned for a large archive:

1. **Do not read everything.** Count files per folder (`find`), list the top two levels, read 5-10 representative notes.
2. **Learn the archive's conventions** and write them into `AI/tools/archive-conventions.md`: filename pattern, language, frontmatter fields (if any), link style (`[[wikilinks]]` or `[text](file.md)`), date format, how projects/customers are separated. From then on, **new notes outside `AI/` follow those conventions**, not this system's defaults.
3. **Write the map** in `AI/_index.md` under "Existing material": one line per top-level folder with what it holds and roughly how many notes.
4. **Ask before the first write outside `AI/`.** Default: all of Claude's own notes (logs, decisions, learnings) go in `AI/`; edits to the user's existing notes happen only when asked.
5. **Mark sensitive folders** (customers, HR, finance, contracts) in `AI/SETUP-PROFILE.md` notes and keep them `share: private`; `memory-guard` applies.
6. **Duplicates and conflict copies** (`name-MACBOOK.md`, `name 2.md`): list them for the user, never delete.

## Mode E: Google Drive

**The honest picture.** Google Docs, Sheets and Slides are **not files**. On disk they are tiny `.gdoc`/`.gsheet`/`.gslides` pointers Claude cannot read. Plain files (`.md`, `.docx`, `.xlsx`, `.pdf`) work normally.

| Job | How |
|---|---|
| **Memory** | A Drive folder **mirrored** to the computer by Google Drive for desktop. Settings → Google Drive → Preferences → **Mirror files** (not "Stream"), so every file is really on disk. |
| **Reading Google Docs / Sheets** | The claude.ai **Google Drive connector**, or the user exports to `.docx`/`.xlsx` into a folder Claude can read. |
| **Gmail / Calendar** | claude.ai Gmail connector (Calendar if available on their plan). |
| **Creating documents** | Create `.docx`/`.xlsx`/`.pptx` with Anthropic's skills; Drive opens them in Docs/Sheets/Slides on demand. Creating native Google Docs from Claude Code needs the connector's create function. |

**Setup**

1. Install Google Drive for desktop if missing. Choose **Mirror files**.
2. Path: macOS `~/Library/CloudStorage/GoogleDrive-<account>/My Drive/`, Windows `G:\My Drive\` (or the mapped letter). Confirm with the user.
3. Create `Claude-Memory/` inside it; that is `<VAULT_PATH>`.
4. Install with `--skills copy`.
5. Offer the Google connectors as in mode D.
6. Same warnings as mode D: no secrets, one writer at a time, ask the company's admin before connecting a work account.

## Nothing fits

- **Notion, Evernote, Apple Notes, etc.**: the memory still needs files. Use mode C in a local folder and let the user export the old material to Markdown when they want it searchable. Don't promise a live link to those tools.
- **Server over SSH**: use the mode that matches where the folder is (usually C). Run the installer on the server.
- **Dropbox / iCloud**: treat like D/E without a connector: a synced local folder, `--skills copy`.

## Moving between modes later

The memory is a folder. To move: copy `AI/` and `Claude Code/` to the new location, re-run `install.sh --vault <new path> --yes` (it re-points `CLAUDE.md` and the skill links), update `vault_path` and `storage_mode` in `AI/SETUP-PROFILE.md`.
