---
name: memory-guard
description: Pre-write gate for everything Claude writes into the memory vault or any shared or cloud-synced folder. Activate ALWAYS before writing notes, logs, learnings or decisions to the vault, before committing vault files to git, and when the user asks "can I share this". Scans for API keys, passwords, tokens, personal data (CPR, phone, email, health), customer data and private content, assigns a share level (private, team, public), and blocks the write if a secret is found. Defaults to private when in doubt.
---

# Memory Guard

The vault is long-lived and often synced (OneDrive, Google Drive, iCloud, git). Anything written there can end up on other devices, in backups or with colleagues. Run this check BEFORE every write. It takes seconds and is silent when everything is fine.

## The gate

1. **Secrets.** Block the write if the content contains API keys, tokens, passwords, private keys, connection strings, or anything matching `sk-`, `ghp_`, `AKIA`, `-----BEGIN`, `password=`, `Bearer `. Replace with a pointer ("key stored in the password manager under X") and tell the user what was left out.
2. **Personal data.** National ID numbers (CPR, SSN), health data, private phone/address, bank details, other people's private matters. Do not write them unless the user explicitly asks and the vault is private. Prefer a role or initials over full identity.
3. **Customer or client data.** Names and facts about the user's own customers belong in project notes only when the user's setup says so (see `AI/SETUP-PROFILE.md`, field `sensitive_data`). If `sensitive_data: yes`, keep such notes `share: private` and never copy them to team or public areas.
4. **Classify.** Add `share:` frontmatter to every new note:
   - `private`: default. Only the user.
   - `team`: safe for colleagues who share this vault.
   - `public`: safe for anyone (blog drafts, public docs).
   When unsure, use `private` and ask in one line.
5. **Never lower a level silently.** A `private` note is never copied into a `team` or `public` area without the user saying so.

## Restricted libraries

If `AI/SETUP-PROFILE.md` of the target vault says `access_model: restricted` and `sensitive_data: yes`, the vault is a restricted library (for example accounting or HR, only one person can open it). There, personal data (pay, HR, ID numbers, health) is allowed, because that is its purpose. Secrets (passwords, keys, tokens) are still blocked. Nothing from a restricted library is written into any other vault. When a session touches two vaults, check which one the write goes to before applying these rules.

## Before a git commit or a share

Scan the whole diff with the same rules. If the vault is a shared repo, only commit files with `share: team` or `share: public`. Refuse `--no-verify` and tell the user why in one sentence.

## Cloud-synced vaults

If `AI/SETUP-PROFILE.md` says the vault lives in OneDrive, SharePoint, Google Drive or iCloud: assume other people or devices can read it. Apply rule 1 and 2 strictly, and never store credentials in the vault at all.

## Report

Silent when clean. When something is blocked or redacted, one short line: what, where, and what to do instead.
