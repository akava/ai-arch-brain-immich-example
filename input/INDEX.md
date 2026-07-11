---
type: input_index
project: "Immich Managed-Hosting Scale-Up (simulated demo engagement)"
date_built: 2026-07-11
maintainer: librarian-agent (legacy SKILL-009)
---

# Input Index

Compact map of all files in `input/`. Agents must follow the indexed retrieval protocol — read this index first, verify count, then open only relevant files.

**Total files in input/** (excl. `.gitkeep`): **5** (incl. this `INDEX.md`)

> **Inventory check:** before using this index, run `.claude/scripts/check-indexes.sh`. On MISMATCH, run the `librarian-agent` to update this index.

## Source systems (where inputs come from)

> TODO: list the systems raw inputs are pulled from (documentation repositories, API catalogues, project management, team communication, sibling-brain artifact folders). Check off each as it is connected.

- [x] First-party product documentation: Immich docs (docs.immich.app) and repo README, filed under `systems/immich/`
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

| File | Category | Use Case | Summary | Keywords |
|------|----------|----------|---------|----------|
| `stakeholder/2026-07-11_D1_engagement-kickoff-brief.md` | `stakeholder/` | Frames session D1 scope, client questions, and engagement arc | Simulated kickoff brief: client questions on Immich components, integrations, stack, operations, multi-node gaps; D1–D3 arc; first-party-evidence ground rule. | kickoff, D1, engagement brief, managed hosting, scale-up, session questions, simulated client |
| `systems/immich/immich-architecture-overview.md` | `systems/` | Baseline Immich runtime components, tech stack, integration points | First-party architecture doc: clients, Nest.js server, Python/ONNX ML service, Postgres, Redis/BullMQ job queues, hexagonal codebase structure. | architecture, client-server, REST, OpenAPI, Nest.js, FastAPI, ONNX, Postgres, Redis, BullMQ, background jobs |
| `systems/immich/immich-repo-readme.md` | `systems/` | Product scope and mobile/web feature coverage | Immich repo README: self-hosted photo/video platform, AGPL v3, demo instance, mobile-vs-web feature matrix, translations. | README, features, feature matrix, mobile app, web app, AGPL, demo, backup |
| `systems/immich/immich-jobs-and-workers.md` | `systems/` | Worker packaging, split-worker scaling, job pipeline behaviour | Admin doc: api and microservices workers share one container, env-var split (IMMICH_WORKERS_INCLUDE/EXCLUDE), upload-triggered job chain, scheduled nightly jobs. | jobs, workers, microservices, split workers, environment variables, scaling, scheduled jobs, thumbnail generation |
