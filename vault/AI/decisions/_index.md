---
tags: [decisions, index]
---
# Decisions — the graph of chosen routes

One note per significant decision. Notes are **nodes**, wikilinks are **edges** — Obsidian's graph view then shows the chains: decision → context → outcome → next decision. Purpose: when a similar situation comes up, look up the route instead of re-discovering it.

## When to create a decision note

- The user makes a directional choice (design direction, architecture, tool, process, something rejected)
- A decision noticeably changes the output of a task
- A route turned out to work particularly well — or particularly badly (both are gold)

NOT for trivial choices (file names, small fixes). Rule of thumb: would we be annoyed to have to re-discover this in 3 months? Yes → note.

## Format

File name: `YYYY-MM-DD <short title>.md`

```markdown
---
tags: [decision]
status: chosen | rejected | awaiting-outcome | confirmed-good | confirmed-bad
---
# <Title>

**Context:** What was the situation/task. Link to [[AI/memory/YYYY-MM-DD|the daily log]].
**Decision:** What was chosen (and by whom — the user or an AI recommendation).
**Alternatives:** What was rejected and why.
**Outcome:** Filled in once known. Did it work? Is it still holding up?

Edges: [[related decision]] · [[tools/relevant-tool]] · [[project-note]]
```

## Rules

1. **Create the note when the decision happens** — not later. Status: `chosen` or `awaiting-outcome`.
2. **Update `status` + Outcome** once the result is known (user happy/unhappy, production held/broke). A decision without an outcome is half a node.
3. **Always link at least 2 edges:** the daily memory log + the relevant topic (tool/project/earlier decision). Otherwise the node dangles loose in the graph.
4. **Revisit before new choices:** facing a directional choice, search here first (`status: confirmed-good` = reuse the route; `confirmed-bad` = avoid it).

## Nodes

<!-- List decision notes here as they are created -->
