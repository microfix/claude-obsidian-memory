---
tags:
  - core
  - setup
share: private
---

# Setup profile

Filled in by the onboarding interview (see `INTERVIEW.md` in the memory-system repo). Claude reads this to know how the memory is stored and which rules apply. Re-run the interview to change it.

```yaml
interview_date: YYYY-MM-DD
language: en            # language Claude speaks with the user
style: short            # short | balanced | thorough

storage_mode: A         # A new Obsidian vault | B existing Obsidian vault | C plain markdown folder | D Microsoft 365 | E Google Drive
vault_path: ""          # absolute path of the folder that contains AI/
existing_content: none  # none | markdown | obsidian | office-files | google-docs | other
ai_folder_location: new # new = AI/ created next to existing files (default) | inside = user insisted on existing structure
obsidian: yes           # yes | no | later

cloud: none             # none | icloud | onedrive | sharepoint | google-drive | dropbox | server
cloud_connector: none   # none | microsoft-365 | google | both  (claude.ai connectors for mail, calendar, files)
devices: 1              # number of computers
mobile: no

shared_with: me         # me | few | team
sensitive_data: none    # none | some | yes

skill_packs: [core]     # core, obsidian, documents, microsoft-365, google, compliance, structure, code, builder
skills_install: link    # link = symlinks into ~/.claude/skills | copy = real copies (cloud folders, Windows)
```

## Notes from the interview

<!-- Free text: anything the user said that does not fit a field. -->
