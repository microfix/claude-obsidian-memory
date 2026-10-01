---
type: company-rules
share: team
tags: [company, setup]
---
# Personal setup: instructions for Claude

> **You are Claude, and a colleague asked you to set up their personal Claude for the company archive.** The archive already exists (the librarian built it). You do **not** need GitHub or an install script: everything is in this folder. Interview first, write second. Speak the user's language, short messages, one question at a time.

## Step 0: Orient (silently)

Read `<ARCHIVE>/CLAUDE.md` (shared rules), `AI/company/ROLES.md`, `AI/company/SYSTEMS.md` and `People/_index.md`. `<ARCHIVE>` is this session's working directory. If one of these is missing, stop and tell the user to ask the librarian to finish the archive setup.

## Step 1: Interview

Ask these, one at a time, offering options taken from `ROLES.md` and `SYSTEMS.md` where possible:

1. **Name.** "What should I call you, and what is your full name?" (slug = lowercase, `æ→ae ø→oe å→aa`, spaces to `-`.)
2. **Title and company.** "What is your title, and which company or companies do you work for?" (options: the companies from the shared CLAUDE.md)
3. **Role.** "Which of these roles is closest to yours?" (rows of `ROLES.md`; or "something else", then describe it and note it for the librarian).
4. **A normal week.** "What do you do in a normal week?" Listen for tasks. Derive the folders you normally read and write.
5. **Data in.** "What do you produce or collect that others need? Meeting notes, quotes, site photos, customer calls, orders?" Confirm in which folders it should land (defaults from `ROLES.md`).
6. **Data out.** "What do you need to get out of the archive, or produce for others? Status, offers, overviews, reports, summaries?"
7. **Systems.** "Which of our systems do you use?" (rows of `SYSTEMS.md`). Remember: those systems own their data, the archive only points to them.
8. **How should I behave?** Language, short or thorough answers, and anything Claude should always or never do for you.
9. **Confirm.** Show a 8-line summary of the profile, and say plainly: "Your name, title, role and what you work with will be visible to everyone in the archive (`People/<slug>.md`). Your own preferences stay in your private file." Continue only on a yes.

Work information only. No private data, no salary, no health, no ID numbers.

## Step 2: Install on this Mac

1. **Skills.** Copy the skills from the archive into the user's Claude (copies, not symlinks, because the archive is in a sync folder):
   ```bash
   mkdir -p ~/.claude/skills ~/.claude/commands
   for d in "<ARCHIVE>/Claude Code/skills"/*/; do n="$(basename "$d")"; rm -rf ~/.claude/skills/"$n"; cp -R "$d" ~/.claude/skills/"$n"; done
   ```
   If the archive has `Claude Code/commands/`, copy those `.md` files to `~/.claude/commands/` as well.
2. **Personal CLAUDE.md.** Render `AI/company/PERSONAL-CLAUDE-TEMPLATE.md` (the part under the line `---`) with the interview answers into `~/.claude/CLAUDE.md`. **If a CLAUDE.md already exists:** read it, keep the user's own preferences, drop company facts that now live in the archive (list them for the user), save the old file as `CLAUDE.md.bak-<date>`, show the user a short before/after, and replace only after a yes.
3. **Profile in the archive.** Create `People/<slug>.md` (frontmatter `type: person`, `company`, `role`, `title`, `tags: [people]`, `share: team`, `updated`) with the work information the user confirmed, and `People/<slug>/` for their own log. Add them to `People/_index.md` (re-run `vault.py indexes --only People --apply` if Python is available, or add the line by hand).
4. **Obsidian (optional).** If they want to browse the archive: Obsidian → "Open folder as vault" → the archive folder.

## Step 3: Verify

Tell the user to open a **new** session on the archive folder and try:

| Ask | Expected |
|---|---|
| "Who am I?" | Your name, title, role, from the profile |
| "What do we know about <a customer>?" | Answer from the archive, naming the notes |
| "Save this: <a short fact>" | A new note in the right folder, with author, source and `status: unverified`, linked from the index |
| "Save my salary" (test) | Refused, with where it belongs instead |

Then log the setup in `People/<slug>/log/` (one line). Done. Offer: "run the personal setup again" any time to change role or preferences.
