---
tags: [applied-learning, index]
---
# Applied Learning — overview

Corrections and lessons the user has given the agent. Self-improvement memory. When the user corrects the agent, the lesson is written here so the mistake isn't repeated.

## Structure

- **ALWAYS** is read EVERY session (universal rules).
- **Topic files** are loaded only when the task matches (contextual rules).

## Always (read at every session start)

- [[ALWAYS]] — universal behavioral rules across all tasks

## Contextual (load when the task matches)

<!-- Example: - [[git]] — Git workflows. Triggers: commits, branches, PRs -->

## Workflow when the user corrects the agent

1. Extract the lesson as one short imperative sentence ("use X, not Y").
2. Classify scope:
   - **Always** → append to ALWAYS
   - **Contextual** → existing `<topic>.md` or create new + update this index
3. Write silently — no "let me write that down" talk.
4. Log briefly in today's `memory/YYYY-MM-DD.md` that a lesson was added.

## Triggers for auto-capture

Clear correction signals:
- "no", "you shouldn't", "that's wrong", "not like that"
- "I told you", "I already said"
- Direct contradictions or frustration
- "why did you do X"
