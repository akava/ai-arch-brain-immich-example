# Architecture Review (baseline stream)

**Code:** `baseline` · **Populates:** `core/2.ARCH-BASELINE.md` · **Horizon:** current-state.
**Goal:** review and document the architecture as it is today; every durable fact lands in ARCH-BASELINE.

## Deliverable in flight

> TODO: Name the review deliverable currently being produced (e.g. an architecture review draft — observations, gaps, recommendations), its timeline, and what it feeds (action IDs where tracked).

## Work status

Discovery proceeding by session against the first-party Immich doc set (`input/systems/immich/`). Structural picture (components, workers, stores, integration, jobs) reviewed; ML/media/storage detail deepened in D2. Blocked areas surface as open questions, not silent gaps: multi-node/HA posture (OQ#1) and ML throughput/hardware sizing (OQ#2, partially answered in D2 — hardware floors documented, throughput still unquantified) both await evidence beyond this doc set. No `AI-NN` tracking action opened yet.

## Landed so far

- **D1 (session 2026-07-11, run `immich-architecture-overview`):** BASELINE §1 (1.1 context/scope, 1.2 building blocks, 1.3 integration patterns, 1.4 data & flows) and §2 (tech stack & platforms) populated from `immich-architecture-overview.md`, `immich-jobs-and-workers.md`, `immich-repo-readme.md`.
- **D2 (session 2026-07-11, run `immich-ml-media-deep-dive`):** BASELINE §1.2/§1.4 deepened (remote-ML deployment mode and offload scope, storage-template mechanics, migrations-at-startup), §2 extended (ML hardware-acceleration and hardware-transcoding options), and §3 seeded (observed ML-acceleration hardware floors) from `immich-ml-hardware-acceleration.md`, `immich-hardware-transcoding.md`, `immich-remote-machine-learning.md`, `immich-storage-template.md`, `immich-database-migrations.md`.

Latest processed session: 2026-07-11 D3 (`immich-scale-up-design`).
