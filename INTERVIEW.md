# INTERVIEW.md: onboarding interview for Claude

> **You are Claude, running the first-time setup for a new user.** Before you install or write anything, you interview them. The answers decide where the memory lives, which skills get installed, and how you will talk to them from now on.
> Called from [AGENT-SETUP.md](AGENT-SETUP.md) (Step 1). Do not skip it, and do not install anything before the user has confirmed the plan in question 11.

## How to run it

- **Speak the user's language.** Ask question 1 first, in the language they wrote to you in, then switch to the language they choose.
- **One question at a time.** Short. Offer 2-4 concrete options. If your client has a question/choice tool (`AskUserQuestion`), use it. Otherwise numbered options in plain text. Always allow "something else".
- **Adapt.** Skip a question when an earlier answer already settled it. Don't ask about Obsidian vs. cloud if they said "everything is in Google Drive and I never want to install anything".
- **No jargon.** Say "a folder of notes", not "vault", until you've explained the word. Say "sync" not "LiveSync".
- **Detect before you ask.** If you have shell access, check quietly: OS (`uname`), whether Obsidian is installed, whether `~/.claude/CLAUDE.md` exists, whether folders like `~/Library/CloudStorage`, `~/OneDrive*`, `~/Google Drive*`, `~/Documents` contain `.obsidian` or many `.md` files. Use that to propose a default ("I can see an Obsidian vault at X. Is that the one?") instead of asking blind.
- **Never judge.** Every answer has a path. If they say "I just want it simple", that is mode C (plain folder). Obsidian is a recommendation, not a requirement.
- **Be honest about limits.** Where a choice has a real downside (see [docs/STORAGE-MODES.md](docs/STORAGE-MODES.md)), say it in one sentence before they choose.

## The questions

### 1. Language and tone
"Which language should I speak with you, and do you want short answers or thorough ones?"
Options: their language · short and direct / balanced / thorough.
→ `AI/SOUL.md`, `AI/USER.md` (language, style).

### 2. Who are you and what do you do
"What's your name, what do you do for work, and roughly what do you want Claude to help you with?"
Free text. Listen for: documents, mail and calendar, code, presentations, spreadsheets, research, customers/projects, teaching, writing.
→ `AI/USER.md` (identity, work). Drives the **skill packs** in question 10.

### 3. What do you have today?
"Do you already keep notes or documents somewhere that Claude should know about?"
Options:
- Nothing yet, start fresh
- A folder of Markdown (`.md`) files, with or without Obsidian
- An Obsidian vault
- Word / Excel / PowerPoint in Microsoft 365 (OneDrive, SharePoint, Teams)
- Google Drive (Docs, Sheets, Slides)
- Another tool (Notion, Evernote, Apple Notes, Dropbox ...) → explain it must be exported or lives outside the memory; the memory itself will still be one of the options below

### 4. Where do the files live?
Skip if question 3 already told you.
"Where are they stored?"
Options: only on this computer · iCloud · OneDrive / SharePoint · Google Drive · Dropbox · on a server I reach over SSH.
Ask for the folder path. If it's a cloud drive, find the locally synced folder (see [docs/STORAGE-MODES.md](docs/STORAGE-MODES.md)) and confirm the path with them.

### 5. Start fresh or build on what exists?
Only when something exists.
"Should I create a new, separate memory area next to your existing files, or work inside your existing structure?"
Recommend: **new `AI/` folder next to existing files; I never move, rename or delete what you already have.** That is the default and the safe choice. Only deviate if they insist.

### 5b. Organize what exists?
Only when files already exist (answer to 3 was not "nothing").
"Should I just add my memory next to your files, or also organize your files so Claude (and Obsidian) can find everything easily?"
- **Level 0: only add memory.** Nothing of yours is touched.
- **Level 1: index and tag.** Index files, links and frontmatter added, current folders stay where they are.
- **Level 2: full organization.** Files are sorted per company into one structure, moved, indexed and linked. Needs a plan you approve first, a backup, and it is undoable (journal). Recommend this when **several companies share one archive** or the user says the archive is messy.

If level 1 or 2: ask "Which companies does the archive cover?" (exact names) and "Which folders are sensitive (HR, salary, contracts, personal data)?". Install the `vault-organizer` skill and hand over to it after the install (see AGENT-SETUP Step 3). Level 2 implies Obsidian rules for all notes, so the Obsidian skills are installed even if Obsidian is not yet used, and the user is told how to open the folder in Obsidian.

### 6. Obsidian: yes, no, or not sure?
"Do you want to use Obsidian as the app for reading and browsing the notes?"
- **Yes, I already use it**: mode B (existing vault) or A.
- **Yes, new to it**: mode A. You install it for them (the installer can), and explain in two sentences what it gives them: links between notes, a graph, a fast editor, all on plain files.
- **No / not now**: mode C. Memory is plain `.md` files in a folder. Works the same for Claude. They can open the folder in Obsidian later without migrating anything.
- **Not sure**: give a one-line honest summary. Obsidian is optional. It is nice for browsing and linking, but Claude does the writing, so a user who never opens the notes gets little extra from it. Then recommend: yes if they like to read and browse notes themselves, no if they just want Claude to remember. Let them choose.

### 7. Devices and sync
"Will you use Claude on more than one computer, or also on a phone/tablet?"
Options: one computer · two or more computers · also mobile.
Two or more computers means the folder must sync (cloud drive, iCloud, Obsidian Sync, git). Warn once: two machines writing at the same moment can create conflicts. Recommend one cloud drive and not editing the same note on two machines at once.
→ `AI/USER.md` (setup, sync).

### 8. Alone or with others?
"Is this memory only for you, or will colleagues share it?"
Options: only me · me + 1-3 colleagues · a whole team.
Shared means: `memory-guard` runs in team mode (`share:` on every note), no personal notes in the shared area, and each person gets their own `AI/USER.md`. For more than a few people, advise separate personal memory plus a shared knowledge folder instead of one common memory.

### 9. Sensitive data
"Will you work with customer data, personal data (names, CPR/SSN, health), or confidential contracts together with Claude?"
Options: no · some · yes, a lot.
- Record `sensitive_data: none | some | yes` in `AI/SETUP-PROFILE.md`.
- `some`/`yes`: install `gdpr-check`, run `memory-guard` strictly, remind them that content sent to Claude is processed by Anthropic under their plan's terms (consumer vs. Team/Enterprise/API differ, so they should check their agreement or DPA), and that nothing secret goes in the vault. Cloud-synced folders mean the data also sits with Microsoft or Google.
- Do not give legal advice. Point to `gdpr-check` and their own data protection contact.

### 10. What will you use it for? (skill packs)
Derive from question 2, then confirm: "Based on what you told me, I suggest these. Want to change anything?"

| If they say | Pack | Skills |
|---|---|---|
| (always) | **Core** | `skill-builder`, `memory-guard`, `anydoc`, `defuddle` |
| Uses Obsidian | **Obsidian** | `obsidian-markdown`, `obsidian-bases`, `obsidian-cli`, `json-canvas` |
| Word, Excel, PowerPoint, PDF | **Documents (Anthropic)** | `docx`, `xlsx`, `pptx`, `pdf` from Anthropic's `document-skills` |
| Mail, calendar, Teams, SharePoint (Microsoft) | **Microsoft 365** | claude.ai Microsoft 365 connector |
| Gmail, Drive, Docs (Google) | **Google** | claude.ai Gmail + Google Drive connectors |
| Customers, personal data, EU/Denmark | **Compliance** | `gdpr-check` (Danish), `memory-guard` strict |
| Processes, team knowledge, "organize our company for AI" | **Structure** | `icm-architect` |
| Existing files to sort, several companies in one archive | **Organize** | `vault-organizer` |
| Writes code | **Code** | built-in `/code-review`, `/simplify`, `/security-review`, plus `frontend-design` from Anthropic's example skills if they build web UIs |
| Wants to build their own automations | **Builder** | `skill-builder` (core), Anthropic `skill-creator` |

Full descriptions and sources: [docs/SKILLS-CATALOG.md](docs/SKILLS-CATALOG.md).

### 11. Confirm the plan, then install
Summarize in 6-8 lines, in their language:

```
Memory location:   <path>   (new folder | inside existing)
Storage mode:      A new Obsidian vault | B existing vault | C plain folder | D Microsoft 365 | E Google Drive
Obsidian:          install / already installed / not used
Skills:            <list>
Shared with:       only you | <n> colleagues
Sensitive data:    none | some | yes
Organize level:    0 | 1 | 2   (companies: <names>)
I will NOT:        delete any file. Files are only moved at level 2, after you approve the plan, with a backup and an undo journal
```

Ask: "Shall I go ahead?" Only on an explicit yes, continue with [AGENT-SETUP.md](AGENT-SETUP.md) Step 2.

## What to write down

Save the answers in **two** places so every future session knows them:

1. `<VAULT_PATH>/AI/SETUP-PROFILE.md`: fill in every field of the blank `AI/SETUP-PROFILE.md` the installer put in the vault (template: [vault/AI/SETUP-PROFILE.md](vault/AI/SETUP-PROFILE.md)). This is the machine-readable record (mode, paths, packs, flags such as `sensitive_data`).
2. `<VAULT_PATH>/AI/USER.md` and `AI/SOUL.md`: the human part (name, work, language, tone).

Run `memory-guard` on both before writing. No secrets, no ID numbers.

## Re-running the interview

The user can say "run the setup interview again" at any time. Read `AI/SETUP-PROFILE.md`, show what is currently set, ask only what they want to change, and update the file and the installed skills. Never reset their notes.
