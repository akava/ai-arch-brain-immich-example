---
title: Immich Architecture Overview — D1 Discovery Synthesis
date: 2026-07-11
type: synthesis
run: 2026-07-11-immich-architecture-overview
skill: synthesis-agent (SKILL-001)
status: active
confidence: high
---

# Immich Architecture Overview — D1 Discovery Synthesis

**Purpose:** answer the five D1 kickoff questions from first-party Immich docs; seed the as-is baseline.
**Verdict:** Immich's as-is architecture is well documented at container/component level — a client-server system with a Nest.js server (also running background workers), a separable Python/ONNX ML service, Postgres (stateful), and Redis/BullMQ (job-queue state). All five questions answerable from evidence except multi-node/HA posture, which the docs do not address (→ OQ#1).
**Counts:** 8 themes (T1–T8); 1 conflict (C1, resolved by the evidence); 11 glossary terms added; 2 open-question rows proposed; 0 action-register rows (none pass triage).
**Conflict C1 disposition:** overview diagram (separate `immich-microservices` container) vs jobs/workers doc (both workers in one `immich-server` container, env-var split) — **resolved** by the overview doc's own note that the jobs page states the *current* packaging.
**Hand-offs:** librarian indexes this log; landings await architect review before layer writes; next in chain = nfr-analysis-agent (D2/D3 scope).

## Sources

- `input/stakeholder/2026-07-11_D1_engagement-kickoff-brief.md` — the five session questions, engagement arc, evidence ground rule.
- `input/systems/immich/immich-architecture-overview.md` — first-party architecture doc (clients, server, ML, Postgres, Redis).
- `input/systems/immich/immich-jobs-and-workers.md` — first-party admin doc (worker packaging, split workers, job chain).
- `input/systems/immich/immich-repo-readme.md` — product scope, feature matrix, licence.

**Excluded:** none (all four D1 inputs in scope; `input/INDEX.md` and `core/artifacts/INDEX.md` counts verified OK).
**Pending inputs:** none.
**Confidence:** high — every theme rests on first-party product documentation; the one gap (multi-node) is an explicit silence, not a low-quality source.

## Themes

### T1 — Client-server core with generated REST clients
- **Evidence:** traditional client-server, dedicated DB, clients talk to server over HTTP REST; clients auto-generate REST clients from OpenAPI (overview:9,24-25); DTOs → OpenAPI schemas drive generated client code (overview:69-71).
- **Implications:** a single REST/OpenAPI surface is the integration contract for every client; managed hosting inherits one API boundary to operate and version.
- **Lands in:** ARCH-BASELINE §1.1, §4.1.
- **Open questions:** none.

### T2 — Three first-party clients on distinct stacks
- **Evidence:** mobile (Dart/Flutter, Isar local DB, Riverpod state) (overview:28-36); web (TypeScript/SvelteKit/Tailwind) (overview:39-40); CLI (npm package, uses API for bulk upload) (overview:42-44). Feature parity split mobile vs web (readme:42-74) — admin/user-management is web-only (readme:55), offline support mobile-only (readme:69).
- **Implications:** clients are stateless against the server except the mobile on-device Isar DB; admin surface is web-only, relevant to operator tooling.
- **Lands in:** ARCH-BASELINE §1.1, §2.
- **Open questions:** none.

### T3 — Server: Nest.js hexagonal monolith that also runs workers
- **Evidence:** `immich-server` is TypeScript/Node.js, Nest.js + Express + Kysely; hexagonal architecture separating `src/repositories` from `src/services` (overview:56-57). Same container runs the `api` and `microservices` workers (jobs:12-18). Server "handles REST API requests, and executes background jobs" (overview:52).
- **Implications:** API serving and job processing are co-located by default in one deployable — a scale coupling: request-serving and heavy background work share a container unless split (see T5).
- **Lands in:** ARCH-BASELINE §1.2.
- **Open questions:** none.

### T4 — Machine learning as a separable Python/ONNX service
- **Evidence:** `immich-machine-learning` is Python/FastAPI; all ML operations externalized; can be deployed separately or disabled (overview:88). ONNX model format; models downloaded/loaded/cached and reused; thread pool off the async event loop; model settings in Postgres (overview:90-92). Models are large and memory-intensive (overview:92).
- **Implications:** ML is the natural independent scaling and hardware-sizing unit (memory-heavy); separability is stated, but per-node throughput and hardware needs are not quantified (→ deep dive D2).
- **Lands in:** ARCH-BASELINE §1.2, §2, §3.1 (as observed qualitative characteristic).
- **Open questions:** OQ#2 (ML throughput/hardware not quantified).

### T5 — Worker packaging and env-var split scaling
- **Evidence:** workers split across containers via `IMMICH_WORKERS_INCLUDE`/`IMMICH_WORKERS_EXCLUDE`; recipe = copy `immich-server` block, drop ports, set env vars so one container serves API and another runs background jobs (jobs:20-32).
- **Implications:** the only documented horizontal-scaling lever is worker separation via env config — no orchestration, replica-count, or multi-node guidance accompanies it.
- **Lands in:** ARCH-BASELINE §1.2, §3.4 (observed scaling lever).
- **Open questions:** OQ#1 (multi-node/HA posture undocumented).

### T6 — Redis/BullMQ job queue with chained jobs
- **Evidence:** Redis via BullMQ manages job queues (overview:99); uploading an asset kicks off a job chain — metadata extraction, thumbnail generation, ML tasks, storage-template migration (jobs:34-35); Smart Search and Facial Recognition auto-run after thumbnail generation (overview:100, jobs:45). Job list: thumbnail gen, metadata extraction, video transcoding, smart search, facial recognition, storage template migration, sidecar, deletions (overview:75-84).
- **Implications:** Redis is queue-state infrastructure on the critical ingest path; job dependencies (thumbnail → smart search/facial recognition) constrain how work can be parallelized or sharded.
- **Lands in:** ARCH-BASELINE §1.3, §1.4.
- **Open questions:** none.

### T7 — Stateful vs stateless components (Q1)
- **Evidence:** Postgres persists access/authorization, users, albums, assets, sharing, ML model settings (overview:94-96) — stateful. Redis holds job-queue state (overview:98-99) — stateful (operational). File system holds media, accessed via repository interfaces (overview:13). Server/ML/clients hold no durable state (mobile app excepted — on-device Isar DB, overview:36).
- **Implications:** three stateful stores to operate under a hosting SLA — Postgres (system of record), Redis (queue), file system (media); backup discipline flagged by upstream ("3-2-1", readme:14).
- **Lands in:** ARCH-BASELINE §1.1, §1.2, §1.4.
- **Open questions:** none.

### T8 — Design-decision documentation location (Q3)
- **Evidence:** deliberate design is documented in the developer architecture docs (hexagonal structure, DTO/OpenAPI contract discipline, repository-interface rule) (overview:36,56-57,69-71) and admin docs (worker split) (jobs:20-32); no formal ADR/decision log is referenced in this input set.
- **Implications:** design rationale is prose in first-party docs, not a decision register — assessment must derive intent from documented structure.
- **Lands in:** none (meta-observation; informs how evidence is read).
- **Open questions:** none.

## Conflicts

**C1 — Server container topology: two containers vs one.** The architecture overview's high-level diagram depicts the server as two separate containers, `immich-server` and `immich-microservices`, the latter processing Redis job requests (overview:13). The jobs/workers doc states both `api` and `microservices` workers run inside the single `immich-server` container, optionally split via environment variables (jobs:12-32).
- **Affected:** ARCH-BASELINE §1.2 (component inventory), §3.4 (scaling).
- **Disposition — resolved by the evidence, no ADR needed.** The overview doc itself carries the reconciliation: its note states the linked Jobs page "describes the current packaging, where the `api` and `microservices` workers run inside the single `immich-server` container and can optionally be split" (overview:15). The jobs/workers doc is the more operational and current statement; the diagram depicts a possible (split) topology, not the default. Baseline records: default = single `immich-server` container running both workers; separate `immich-microservices` container is an optional split configuration (T3, T5). No conflict routed to decision-record-agent.

## Glossary updates

11 terms added as `tentative` (first-party-doc sourced, single session): Immich, immich-server, immich-machine-learning, api worker, microservices worker, split workers, BullMQ, Redis (job queue role), Postgres (system of record role), ONNX, hexagonal architecture (Immich usage). See `core/GLOSSARY.md`.

**Terms flagged (ambiguous):** none — `immich-microservices` is captured as a variant of the microservices worker / optional split container, not a separate canonical component (per C1).

## Register proposals

**Open-question register (2 proposed, pre-approved for this run):**
- **OQ#1** — multi-node / high-availability posture: the doc set states only the single-container default and the env-var worker split; it does not address running Immich across multiple nodes, replica coordination, HA of Postgres/Redis, or shared-storage assumptions. Material to the managed-hosting availability goal.
- **OQ#2** — ML-inference throughput and hardware sizing: ML is described qualitatively as memory-intensive and separable, with no throughput figures or hardware requirements. Material to the D3 ML-throughput scale-up target.

**Action register:** 0 rows. No D1 item passes the triage gate — the session produced discovery facts and open questions, not architect-owned brain-improving actions (no ADR to approve, no ARCH-TARGET to reconcile yet, no spec due). OQ#1/OQ#2 are tracked as questions, not actions.

## Recommended next agents

- `nfr-analysis-agent` — when D2/D3 quality-attribute work (availability, ML throughput, storage growth) begins.
- `librarian-agent` — index this run log (main-loop step).
