# ADR-010 — Redis/BullMQ job model and worker split are an inherited upstream constraint (supersedes ADR-002)

## Decision Metadata

- **Title**: Redis/BullMQ background-job execution and the env-var api/microservices worker split are inherited upstream as-built constraints this engagement works within — not decisions made here
- **Date**: 2026-07-16
- **Author**: Simulated architect (demo)
- **Created by**: decision-record-agent
- **Severity**: MINOR
- **Decision type**: structural
- **Status**: proposed (canonical lifecycle: `core/decisions/INDEX.md`)

**Status note:** This ADR is an **unattended-run reclassification proposal**. **No human has reviewed or approved it.** Per the Human Approval Rule it is a draft until the architect explicitly approves; nothing here is final delivery. It **supersedes ADR-002** but does not take effect until approved — ADR-002 remains `approved` and immutable until then.

---

## Decision Impact

- [ ] Introduces something new
- [x] Modifies an existing element (reclassifies ADR-002)
- [x] Overrides a previous decision (supersedes ADR-002's framing)

---

## Context

ADR-002 was recorded as an `approved` engagement decision selecting Redis/BullMQ job queues with a splittable api/microservices worker packaging ("Option A") over in-process synchronous processing ("Option B"). A fitness review found this framing inaccurate: **Immich ships this design upstream.** Background work running as BullMQ jobs on Redis, with **api** and **microservices** workers co-located in one `immich-server` container by default and splittable via `IMMICH_WORKERS_INCLUDE`/`IMMICH_WORKERS_EXCLUDE`, is a first-party as-built fact of the product — not a choice this engagement made or could make. The "Option B" no-queue counterfactual was never on the table: the queue topology and the worker-split lever are fixed by the codebase we are hosting.

This ADR corrects the record. The Redis/BullMQ job model and the env-var worker split are **inherited / upstream constraints** the engagement **adopts and works within**. The worker split is the sanctioned scaling lever the engagement *uses*, and Redis being availability-critical queue state is a constraint the engagement *designs around* — most directly in **ADR-003** (stateful-store HA for Redis) — but neither fact was decided here.

- **Urgency**: low — corrects a governance/record-accuracy issue; no system behaviour changes.
- **Scope**: the classification of the Redis/BullMQ job-model and worker-split facts only; the durable technical facts themselves are unchanged and stay homed in BASELINE.

---

## Options Considered

This is a reclassification, not a technology choice. There is **no live engagement alternative** to record.

### The framing this ADR adopts (chosen): inherited upstream constraint

- **Description**: Record the Redis/BullMQ job model and the api/microservices worker split as inherited as-built constraints the engagement adopts. The durable technical facts live once in `core/2.ARCH-BASELINE.md` §1.2 (worker packaging + env-var split; Redis as BullMQ queue state) and §1.3 (queue-based background work, chained jobs) and §1.4 (upload job chain); this ADR points there rather than restating them. Engagement-owned decisions built on top — the worker-split hosting topology and Redis HA posture (**ADR-003**) — are what the ADR layer should record.

### The "in-process, no-queue" counterfactual (context only — never a real option)

- **Description**: ADR-002's "Option B" (run background work synchronously with no Redis/BullMQ) is retained here **only as context**, not as a considered alternative. It was never a real engagement option: the queue topology is upstream-fixed, so there was nothing to choose between. Presenting it as a weighed alternative is precisely the misframing this ADR removes.

---

## Final Decision

- **Chosen**: Reclassify the Redis/BullMQ job model and the env-var api/microservices worker split as **inherited / upstream as-built constraints** the engagement adopts and works within, superseding ADR-002's decision framing. The technical facts are not re-decided; they are cited from `core/2.ARCH-BASELINE.md` §1.2/§1.3/§1.4 as as-is facts.
- **Rationale**: One home per fact. The durable facts belong in BASELINE as as-is facts; the ADR layer should record decisions the engagement actually made. ADR-002 conflated the two by recording inherited facts as an engagement choice with a fabricated no-queue alternative. This ADR keeps the record honest and points to the real engagement decisions (worker-split hosting topology, Redis HA via ADR-003) that stand on these constraints.

---

## Evidence

- **vendor_doc** — `input/systems/immich/immich-architecture-overview.md:100` — "Immich uses Redis via BullMQ to manage job queues. Some jobs trigger subsequent jobs…". Upstream-documented; the model is shipped, not chosen here.
- **vendor_doc** — `input/systems/immich/immich-jobs-and-workers.md:15` — the `immich-server` container contains **api** and **microservices** workers.
- **vendor_doc** — `input/systems/immich/immich-jobs-and-workers.md:22` — the split recipe (copy the block, strip ports, set `IMMICH_WORKERS_INCLUDE`/`EXCLUDE`). (Same citations ADR-002 used.)
- **vendor_doc** — `input/systems/immich/immich-jobs-and-workers.md:35` — a new asset upload kicks off a chain of jobs.
- **discovery** — `core/2.ARCH-BASELINE.md` §1.2 (worker packaging + env-var split; Redis as queue state), §1.3 (queue-based background work), §1.4 (upload job chain and dependency ordering) — where the durable as-is facts are homed.
- **judgement** — fitness-review finding: ADR-002 recorded inherited upstream facts as an engagement decision with a counterfactual alternative; architect approved reclassifying it via supersession rather than editing the immutable ADR-002.

---

## Constraints

- **technical_constraint** — the env-var worker split is the only documented horizontal-scaling lever; no orchestration/replica-count/multi-node guidance accompanies it (OQ#1). Inherited, not chosen.
- **technical_constraint** — Redis holds job-queue state with no documented HA/failover in the first-party docs; it is availability-critical (`core/2.ARCH-BASELINE.md` §1.2). A constraint to design around, not a lever selected.

---

## Consequences

- **What this enables**: an honest decision record — the engagement's owned decisions (**ADR-003** Redis/stateful-store HA; the worker-split hosting topology) are visibly layered on inherited constraints, not confused with establishing them; future readers do not re-litigate a no-queue choice that was never open.
- **What this limits (trade-offs)**: none technically — the durable facts and all downstream design are unchanged. The change is purely to classification and provenance.
- **What to watch for (risks)**: **R-01** (Redis availability-critical, no documented HA) and **R-02** (default co-location contention if the split is not adopted) are unchanged and stay tracked; reclassification does not resolve them.

---

## Success Metrics

- **Metric**: the Redis/BullMQ and worker-split facts are cited (not restated) from `core/2.ARCH-BASELINE.md` §1.2/§1.3/§1.4, and the ADR layer records only engagement-owned decisions.
- **Measurement / when**: at architect approval of this ADR — on approval, ADR-002 flips to `superseded` in the registry and this ADR to `approved`.

---

## System Alignment

- **Related ADRs**: **supersedes ADR-002**; related_to **ADR-003** (Redis/stateful-store HA — the engagement-owned decision built on the inherited Redis-as-critical-state constraint) and **ADR-009** (the parallel reclassification of the ML-service-isolation as-built fact).
- **Affects `core/3.ARCH-TARGET.md`**: No.
- **Affects `core/1.ARCH-CONTEXT.md`**: No.
- **Related artifacts**: `core/2.ARCH-BASELINE.md` §1.2/§1.3/§1.4; `core/artifacts/risk-register.md` (R-01, R-02).

---

## Lifecycle

| Status | Date | Reason |
|--------|------|--------|
| proposed | 2026-07-16 | Drafted to reclassify ADR-002's inherited upstream facts via supersession; awaiting architect approval. Does not take effect until approved. |
