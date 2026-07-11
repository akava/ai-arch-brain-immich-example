---
type: artifact_index
project: "TODO: project name — set when the engagement starts"
date_built: —
maintainer: librarian-agent (legacy SKILL-009)
---

# Artifacts Index

Compact map of all files in `core/artifacts/`. Agents must follow the indexed retrieval protocol — read this index first, verify count, then open only relevant files.

`core/artifacts/` is split in two: **living artifacts** at the root (component specs, integration contracts, and the risk register — kept current; the action and open-question work registers live in `core/arch-processes/`) and **run logs** under `logs/` (dated, point-in-time records of one session or review — syntheses, NFR analyses, risk assessments, fitness reviews, handoffs). This index covers both.

**Total files in core/artifacts/** (root + `logs/`, excl. `.gitkeep`): **10**

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
| component-spec-immich-machine-learning.md | SKILL-002 | component-spec | 2026-07-11 | active | AS-IS spec of the immich-machine-learning service: Smart Search/Face Detection responsibilities, Facial Recognition server-bound exception, HTTP port 3003 interface, stateless model cache, co-located/remote modes, five GPU backends, scaling levers, no-auth channel, throughput gaps. | component spec, immich-machine-learning, ML service, Smart Search, Face Detection, Facial Recognition, port 3003, remote ML, ONNX, hardware acceleration, GPU backends, load balancing, stateless, ADR-001, OQ#2, OQ#3, R-03 |
| logs/2026-07-11-immich-architecture-overview-synthesis.md | SKILL-001 | synthesis | 2026-07-11 | active | D1 discovery synthesis of Immich as-is architecture; 8 themes, container topology conflict resolved, seeds baseline §1/§2. | synthesis, D1, Immich, architecture, components, workers, BullMQ, ONNX, container topology, multi-node gap |
| logs/2026-07-11-immich-architecture-overview-risk-assessment.md | SKILL-006 | risk-assessment | 2026-07-11 | active | D1 risk assessment for managed-hosting goal; 5 rows (R-01…R-05), 1 critical, seeds the living risk register. | risk assessment, D1, Immich, managed hosting, HA, stateful stores, worker co-location, ML memory, docs-only evidence, upgrade path, R-01, OQ#1, OQ#2 |
| logs/2026-07-11-immich-architecture-overview-fitness-review.md | SKILL-007 | fitness-review | 2026-07-11 | active | D1 integrity audit of the full run; verdict proceed_with_caveats; 17 baseline facts verified verbatim, 5 findings (2 minor housekeeping, 3 info). | fitness review, D1, Immich, integrity audit, provenance, consistency, section parity, brain hygiene, proceed with caveats, F1-F5 |
| logs/2026-07-11-immich-ml-media-deep-dive-synthesis.md | SKILL-001 | synthesis | 2026-07-11 | active | D2 deep-dive synthesis of Immich ML and media/storage pipeline; 5 themes (T9-T13), remote-ML/storage-template/migrations facts, seeds baseline §1.2/§1.4/§2/§3.4. | synthesis, D2, Immich, remote machine learning, hardware acceleration, hardware transcoding, storage template, database migrations, OQ#2, OQ#3, ML throughput |
| logs/2026-07-11-immich-ml-media-deep-dive-nfr-analysis.md | SKILL-004 | nfr-analysis | 2026-07-11 | active | D2 NFR analysis under managed-hosting lens; 8 QA scenarios (QA-1..QA-8) across availability/performance/security/operability, all target-TBD-D3; lands BASELINE §3.1/§3.2; proposes 7 candidate NFR/CON rows (not written to CONTEXT, architect-gated). | nfr analysis, D2, Immich, quality attributes, availability, performance, capacity, security, operability, QA scenarios, stateful stores HA, startup migrations, ML memory, GPU floors, sequential remote ML, encoding-only transcoding, unauth ML channel, storage-template migration, target TBD, D3, candidate requirements, NFR-001, CON-001, R-01, R-03, R-05, OQ#1, OQ#2, OQ#3 |
| logs/2026-07-11-immich-ml-media-deep-dive-fitness-review.md | SKILL-007 | fitness-review | 2026-07-11 | active | D2 integrity audit of the full run; verdict proceed_with_caveats; 21 D2 facts verified verbatim; F1 §3 subsection-ID skeleton drift (machinery); D1 F1/F3 follow-ups confirmed executed; candidate NFR rows confirmed not leaked to CONTEXT. | fitness review, D2, Immich, integrity audit, provenance, consistency, section parity, subsection-ID drift, brain hygiene, glossary promotion, proceed with caveats, F1-F4 |
