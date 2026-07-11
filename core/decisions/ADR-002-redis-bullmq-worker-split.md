# ADR-002 — Background work executed via Redis/BullMQ job queues with env-var worker split

## Decision Metadata

- **Title**: Background work via Redis/BullMQ job queues; api + microservices workers co-located by default and split via `IMMICH_WORKERS_INCLUDE`/`EXCLUDE`
- **Date**: 2026-07-11
- **Author**: Simulated architect (demo)
- **Created by**: decision-record-agent
- **Severity**: MINOR
- **Decision type**: structural
- **Status**: approved — by architect instruction in a simulated unattended run (D1). Canonical lifecycle status is tracked in `core/decisions/INDEX.md`.

This is an **as-built** record: it documents a decision the upstream Immich project made and documents first-hand, adopted here as a recorded fact of the as-is system during discovery. It does not commit target direction (that is D3 work; ARCH-TARGET is untouched).

---

## Decision Impact

- [x] Introduces something new (records an as-built structural fact)
- [ ] Modifies an existing element
- [ ] Overrides a previous decision

---

## Context

Immich runs all background work — thumbnail generation, metadata extraction, video transcoding, smart search, facial recognition, storage-template migration, sidecar, deletions — as *jobs* on Redis-backed queues managed via BullMQ. Two workers, **api** (serves data/file requests to web and mobile) and **microservices** (runs the jobs), ship inside a single `immich-server` container by default; they can be distributed across separate containers via environment variables. For a managed-hosting scale-up this is the pivot point: the worker split is the only documented horizontal-scaling lever, and Redis becomes queue-state infrastructure on the critical ingest path. Recording it fixes both facts for the availability and scalability design.

- **Urgency**: low — discovery record, not a delivery blocker.
- **Scope**: background-job execution model, worker packaging/split, and the upload job chain; as-is only.

---

## Options Considered

This ADR records an as-built decision already made upstream; the "options" are the design choices Immich resolved, recorded so future work does not re-litigate them silently. The default-vs-split packaging tension was reconciled in discovery (synthesis **C1**) and is not a live conflict.

### Option A: Redis/BullMQ queues, one container by default, optional env-var worker split (as-built, chosen)

- **Description**: Server enqueues jobs to Redis via BullMQ; the microservices worker consumes them. Both workers run in one `immich-server` container by default; an operator can copy the service block, strip ports, and set `IMMICH_WORKERS_INCLUDE: 'api'` / `IMMICH_WORKERS_EXCLUDE: 'api'` to run serving and jobs in separate containers.
- **Pros**: single-node default is simple to run; the env-var split lets serving and background work be scaled and sized independently without a code change or orchestration layer; chained jobs (upload → metadata → thumbnail → ML → storage-template) are coordinated through the queue.
- **Cons**: default co-location means heavy jobs contend with request serving in one deployable (→ R-02); Redis holds queue state and has no documented HA/failover in the docs, making it availability-critical (→ R-01); the split is the *only* documented horizontal-scaling lever — no replica-count or multi-node guidance accompanies it (OQ#1).

### Option B: In-process synchronous background processing (no queue)

- **Description**: Run background work synchronously within request handling or in-process timers, without Redis/BullMQ.
- **Pros**: no Redis dependency; no queue-state store to operate.
- **Cons**: long-running work (transcoding, ML) would block or couple to requests; no chaining, retry, or scheduling; no independent scaling of background work. Not the path Immich took.

---

## Final Decision

- **Chosen option**: Option A — Redis/BullMQ job queues with the api and microservices workers co-located by default and splittable via `IMMICH_WORKERS_INCLUDE`/`IMMICH_WORKERS_EXCLUDE`.
- **Rationale**: Matches the observed as-built model and gives the scale-up a sanctioned, code-free lever (the worker split) to separate serving from background work, while naming Redis as availability-critical queue state.

---

## Evidence

- **vendor_doc** — `input/systems/immich/immich-architecture-overview.md:100` — "Immich uses Redis via BullMQ to manage job queues. Some jobs trigger subsequent jobs — for example, Smart Search and Facial Recognition automatically execute after thumbnail generation completes."
- **vendor_doc** — `input/systems/immich/immich-jobs-and-workers.md:15` — the `immich-server` container contains **api** and **microservices** workers.
- **vendor_doc** — `input/systems/immich/immich-jobs-and-workers.md:22` — split recipe: copy the service block, rename to `immich-microservices`, remove ports, set `IMMICH_WORKERS_INCLUDE: 'api'` (original) and `IMMICH_WORKERS_EXCLUDE: 'api'` (copy) so one container serves API/UI and another runs background tasks.
- **vendor_doc** — `input/systems/immich/immich-jobs-and-workers.md:35` — a new asset upload kicks off a series of jobs: metadata extraction, thumbnail generation, machine-learning tasks, storage-template migration (if enabled).
- **discovery** — `core/2.ARCH-BASELINE.md` §1.2 (worker packaging + env-var split), §1.4 (upload job chain and dependency ordering).
- **discovery** — synthesis themes **T3** (server also runs workers), **T5** (worker packaging and env-var split scaling), **T6** (Redis/BullMQ queue with chained jobs) — `core/artifacts/logs/2026-07-11-immich-architecture-overview-synthesis.md:44,56,62`. Packaging default-vs-split reconciled in **C1**.

---

## Constraints

- **technical_constraint** — the env-var worker split is the only documented horizontal-scaling lever; no orchestration, replica-count, or multi-node guidance accompanies it (OQ#1).
- **technical_constraint** — job ordering is partly dependency-driven (thumbnail generation first; smart search and facial recognition after), constraining how the chain can be parallelized or sharded (`core/2.ARCH-BASELINE.md` §1.4).

---

## Consequences

- **What this enables**: the worker split is the sanctioned, code-free scaling lever — serving and background-job tiers can be sized independently as the baseline hosting topology (ties to **R-02**).
- **What this limits (trade-offs)**: the default single-container packaging co-locates serving and heavy background jobs, so without the split they contend in one deployable, degrading API latency under load (**R-02**).
- **What to watch for (risks)**: **R-01** — Redis holds job-queue state and carries no documented HA, replication, or failover path in the first-party docs; it becomes availability-critical state whose loss stalls the ingest pipeline. Also **R-02** contention if the split is not adopted in the hosting topology.

---

## Success Metrics

- **Metric**: hosting topology adopts the env-var worker split with independently sized serving and microservices tiers, and Redis is provisioned with a defined availability posture.
- **Measurement / when**: evaluated at D2/D3 availability and scalability design — worker-split topology in place before pilot; Redis HA posture resolved via OQ#1.

---

## System Alignment

- **Related ADRs**: related_to **ADR-001** (the ML dispatch is one stage of this job chain; ML isolation and the worker/queue model are complementary as-built structural facts).
- **Affects `core/3.ARCH-TARGET.md`**: No (as-is record; target adoption is D3).
- **Affects `core/1.ARCH-CONTEXT.md`**: No.
- **Affected agents**: nfr-analysis-agent, risk-assessment-agent (R-01, R-02), component-spec-agent (future worker/queue component specs).
- **Related artifacts**: `core/2.ARCH-BASELINE.md` §1.2/§1.4; `core/artifacts/risk-register.md` (R-01, R-02); `core/artifacts/logs/2026-07-11-immich-architecture-overview-synthesis.md` (T3/T5/T6, C1).

---

## Lifecycle

| Status | Date | Reason |
|--------|------|--------|
| approved | 2026-07-11 | Approved on architect authority per session-D1 instruction (simulated unattended run); recorded as an as-built fact of the as-is system. |
