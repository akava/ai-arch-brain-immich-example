---
type: artifact_index
project: "TODO: project name — set when the engagement starts"
date_built: —
maintainer: librarian-agent (legacy SKILL-009)
---

# Artifacts Index

Compact map of all files in `core/artifacts/`. Agents must follow the indexed retrieval protocol — read this index first, verify count, then open only relevant files.

`core/artifacts/` is split in two: **living artifacts** at the root (component specs, integration contracts, and the risk register — kept current; the action and open-question work registers live in `core/arch-processes/`) and **run logs** under `logs/` (dated, point-in-time records of one session or review — syntheses, NFR analyses, risk assessments, fitness reviews, handoffs). This index covers both.

**Total files in core/artifacts/** (root + `logs/`, excl. `.gitkeep`): **6**

> **Inventory check:** before using this index, run `.claude/scripts/check-indexes.sh`. On MISMATCH, run the `librarian-agent` to update this index.

---

## Schema

| Column | Meaning |
|--------|---------|
| File | Filename — living artifacts at the `core/artifacts/` root; run logs under `logs/` named `[session-date]-[run-slug]-[type]` |
| Skill | Producing skill |
| Type | Artifact type |
| Date | Creation/processing date (distinct from the source-session date in run-log filenames) |
| Status | `active`, `superseded`, `archived` |
| Summary | ≤25 words — a pointer, not an abstract; `Keywords` carry retrieval |
| Keywords | Comma-separated search terms |

---

## Files

Meta and living artifacts sit at the `core/artifacts/` root; run logs carry the `logs/` prefix in the File column.

> TODO: one row per artifact, added by the `librarian-agent` as agents produce outputs. Keep the declared total above in step with the filesystem.

| File | Skill | Type | Date | Status | Summary | Keywords |
|------|-------|------|------|--------|---------|----------|
| README.md | — | meta | — | active | Overview of core/artifacts/ purpose and naming conventions. | artifacts, structure, naming |
| INDEX.md | SKILL-009 | meta | — | active | This file — compact map of all files in core/artifacts/. Agents verify count vs filesystem before use. | index, inventory, navigation, SKILL-009 |
| risk-register.md | SKILL-006 | risk-register | — | active | Living canonical register of all risks and tech-debt items; empty until the first risk-assessment run. | risk register, living artifact, risks, tech debt |
| logs/2026-07-11-immich-architecture-overview-synthesis.md | SKILL-001 | synthesis | 2026-07-11 | active | D1 discovery synthesis of Immich as-is architecture; 8 themes, container topology conflict resolved, seeds baseline §1/§2. | synthesis, D1, Immich, architecture, components, workers, BullMQ, ONNX, container topology, multi-node gap |
| logs/2026-07-11-immich-architecture-overview-risk-assessment.md | SKILL-006 | risk-assessment | 2026-07-11 | active | D1 risk assessment for managed-hosting goal; 5 rows (R-01…R-05), 1 critical, seeds the living risk register. | risk assessment, D1, Immich, managed hosting, HA, stateful stores, worker co-location, ML memory, docs-only evidence, upgrade path, R-01, OQ#1, OQ#2 |
| logs/2026-07-11-immich-architecture-overview-fitness-review.md | SKILL-007 | fitness-review | 2026-07-11 | active | D1 integrity audit of the full run; verdict proceed_with_caveats; 17 baseline facts verified verbatim, 5 findings (2 minor housekeeping, 3 info). | fitness review, D1, Immich, integrity audit, provenance, consistency, section parity, brain hygiene, proceed with caveats, F1-F5 |
