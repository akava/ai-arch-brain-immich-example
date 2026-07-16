# ADR-009 — Isolated ML service is an inherited upstream constraint (supersedes ADR-001)

## Decision Metadata

- **Title**: The isolated `immich-machine-learning` service is an inherited upstream as-built constraint this engagement works within — not a decision made here
- **Date**: 2026-07-16
- **Author**: Simulated architect (demo)
- **Created by**: decision-record-agent
- **Severity**: MINOR
- **Decision type**: structural
- **Status**: proposed (canonical lifecycle: `core/decisions/INDEX.md`)

**Status note:** This ADR is an **unattended-run reclassification proposal**. **No human has reviewed or approved it.** Per the Human Approval Rule it is a draft until the architect explicitly approves; nothing here is final delivery. It **supersedes ADR-001** but does not take effect until approved — ADR-001 remains `approved` and immutable until then.

---

## Decision Impact

- [ ] Introduces something new
- [x] Modifies an existing element (reclassifies ADR-001)
- [x] Overrides a previous decision (supersedes ADR-001's framing)

---

## Context

ADR-001 was recorded as an `approved` engagement decision selecting an isolated, stateless `immich-machine-learning` service ("Option A") over in-process ML ("Option B"). A fitness review found this framing inaccurate: **Immich ships this topology upstream.** The ML service being a separate Python/FastAPI + ONNX process, called synchronously over HTTP, is a first-party as-built fact of the product — not a choice this engagement made or could make. Dressing an inherited fact as a here-and-now decision, complete with a counterfactual "Option B" that was never on the table, is process theater: there was no live in-process alternative to weigh because the topology is fixed by the codebase we are hosting.

This ADR corrects the record. The isolated ML service is an **inherited / upstream constraint** the engagement **adopts and works within**. The decisions this engagement actually owns are the ones **layered on top of** that constraint — most directly **ADR-004** (dedicated remote-ML tier, load balancer, channel hardening), which builds on the inherited isolated-ML-service fact rather than establishing it.

- **Urgency**: low — corrects a governance/record-accuracy issue; no system behaviour changes.
- **Scope**: the classification of the ML-service-isolation fact only; the durable technical fact itself is unchanged and stays homed in BASELINE.

---

## Options Considered

This is a reclassification, not a technology choice. There is **no live engagement alternative** to record.

### The framing this ADR adopts (chosen): inherited upstream constraint

- **Description**: Record ML-service isolation as an inherited as-built constraint the engagement adopts. The durable technical fact lives once in `core/2.ARCH-BASELINE.md` §1.2 (`immich-machine-learning` building block) and §1.3 (synchronous HTTP server-to-ML integration); this ADR points there rather than restating it. Engagement-owned ML decisions (ADR-004) are what build on top.

### The "in-process ML" counterfactual (context only — never a real option)

- **Description**: ADR-001's "Option B" (run inference inside `immich-server`) is retained here **only as context**, not as a considered alternative. It was never a real engagement option: the topology is upstream-fixed, so there was nothing to choose between. Presenting it as a weighed alternative is precisely the misframing this ADR removes.

---

## Final Decision

- **Chosen**: Reclassify the isolated `immich-machine-learning` service as an **inherited / upstream as-built constraint** the engagement adopts and works within, superseding ADR-001's decision framing. The technical fact is not re-decided; it is cited from `core/2.ARCH-BASELINE.md` §1.2/§1.3 as an as-is fact.
- **Rationale**: One home per fact. The durable fact belongs in BASELINE as an as-is fact; the ADR layer should record decisions the engagement actually made. ADR-001 conflated the two by recording an inherited fact as an engagement choice with a fabricated alternative. This ADR keeps the record honest and points to the real engagement decisions (ADR-004) that stand on this constraint.

---

## Evidence

- **vendor_doc** — `input/systems/immich/immich-architecture-overview.md:88` — "All ML-related operations are externalized to this service, `immich-machine-learning`, which allows it to be deployed separately from the server, or disabled entirely if needed." Upstream-documented; the topology is shipped, not chosen here.
- **vendor_doc** — `input/systems/immich/immich-architecture-overview.md:90,92` — per-request model-task metadata/model name; ONNX models are large and memory-intensive. (Same citations ADR-001 used.)
- **discovery** — `core/2.ARCH-BASELINE.md` §1.2 (`immich-machine-learning` building block) and §1.3 (synchronous HTTP server-to-ML integration) — where the durable as-is fact is homed.
- **judgement** — fitness-review finding: ADR-001 recorded an inherited upstream fact as an engagement decision with a counterfactual alternative; architect approved reclassifying it via supersession rather than editing the immutable ADR-001.

---

## Constraints

- **technical_constraint** — server-to-ML integration is synchronous HTTP; an ML outage/backlog stalls dependent jobs (`core/2.ARCH-BASELINE.md` §1.3). Inherited, not chosen.
- **technical_constraint** — the topology is upstream-fixed: the engagement cannot make ML in-process, so isolation is a constraint to design within, not a lever it selected.

---

## Consequences

- **What this enables**: an honest decision record — the engagement's owned ML decisions (**ADR-004** scale-out and channel hardening) are visibly layered on an inherited constraint, not confused with establishing it; future readers do not re-litigate a choice that was never open.
- **What this limits (trade-offs)**: none technically — the durable fact and all downstream design are unchanged. The change is purely to classification and provenance.
- **What to watch for (risks)**: **R-03** (ML memory-intensive, throughput/hardware unquantified; OQ#2) is unchanged and stays tracked; reclassification does not resolve it.

---

## Success Metrics

- **Metric**: the ML-isolation fact is cited (not restated) from `core/2.ARCH-BASELINE.md` §1.2/§1.3, and the ADR layer records only engagement-owned ML decisions.
- **Measurement / when**: at architect approval of this ADR — on approval, ADR-001 flips to `superseded` in the registry and this ADR to `approved`.

---

## System Alignment

- **Related ADRs**: **supersedes ADR-001**; related_to **ADR-004** (the engagement-owned ML decision that builds on this inherited constraint) and **ADR-010** (the parallel reclassification of the Redis/BullMQ worker-split as-built fact).
- **Affects `core/3.ARCH-TARGET.md`**: No.
- **Affects `core/1.ARCH-CONTEXT.md`**: No.
- **Related artifacts**: `core/2.ARCH-BASELINE.md` §1.2/§1.3; `core/artifacts/risk-register.md` (R-03).

---

## Lifecycle

| Status | Date | Reason |
|--------|------|--------|
| proposed | 2026-07-16 | Drafted to reclassify ADR-001's inherited upstream fact via supersession; awaiting architect approval. Does not take effect until approved. |
