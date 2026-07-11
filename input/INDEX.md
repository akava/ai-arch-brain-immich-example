---
type: input_index
project: "TODO: project name — set when the engagement starts"
date_built: —
maintainer: librarian-agent (legacy SKILL-009)
---

# Input Index

Compact map of all files in `input/`. Agents must follow the indexed retrieval protocol — read this index first, verify count, then open only relevant files.

**Total files in input/** (excl. `.gitkeep`): **1** (this `INDEX.md`; no raw inputs yet)

> **Inventory check:** before using this index, run `.claude/scripts/check-indexes.sh`. On MISMATCH, run the `librarian-agent` to update this index.

## Source systems (where inputs come from)

> TODO: list the systems raw inputs are pulled from (documentation repositories, API catalogues, project management, team communication, sibling-brain artifact folders). Check off each as it is connected.

- [ ] Architecture documentation repository: TBD
- [ ] Integration / API catalogue: TBD
- [ ] Project management: TBD
- [ ] Team communication: TBD
- [ ] Sibling brain (read-only inputs): TBD

---

## Folders

| Folder | Holds |
|--------|-------|
| `reference/` | external standards, regulations, vendor and domain material |
| `systems/` | hard-fact documents on the existing estate — decks, inventories, repo/service overviews, diagrams; no talks or transcripts |
| `stakeholder/` | human accounts — briefs, internal direction, and session notes/summaries under `calls/` |
| `transitions/` | phase-bounded evidence (requirements, calls) per `Mn` transition; a closed transition's folder freezes as its evidence archive |
| `research/` | evidence-grade analysis received from outside; own exploration homes in `lab/researches/` |
| `analytics/` | telemetry, performance, and behavioural evidence |

Form decides between `systems/` and `stakeholder/`: a document that *is* the fact → `systems/`; an account of what people said → `stakeholder/`. Phase-scoped material → `transitions/<Mn>/`.

---

## Schema

| Column | Meaning |
|--------|---------|
| File | Path within `input/` |
| Category | Source folder |
| Use Case | When this input is relevant |
| Summary | ≤25 words — a pointer, not an abstract; `Keywords` carry retrieval |
| Keywords | Comma-separated search terms |

---

## Files

> TODO: one row per raw input file, added by the `librarian-agent` as inputs land. Keep the declared total above in step with the filesystem.

| File | Category | Use Case | Summary | Keywords |
|------|----------|----------|---------|----------|
