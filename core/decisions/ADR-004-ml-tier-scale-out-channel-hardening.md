# ADR-004 — ML tier scale-out and channel hardening

## Decision Metadata

- **Title**: Dedicated ML tier behind an operator-run load balancer, with auth + TLS at a reverse proxy fronting port 3003
- **Date**: 2026-07-11
- **Author**: Simulated architect (demo)
- **Severity**: MAJOR
- **Decision type**: structural
- **Status**: proposed (canonical lifecycle: `core/decisions/INDEX.md`)

**Status note:** This ADR is an **unattended-run design proposal** (session D3). **No human has reviewed or approved it.** Per the Human Approval Rule, it is a draft until the architect explicitly approves; nothing here is final delivery.

---

## Decision Impact

- [x] Introduces something new (a dedicated ML tier, an operator-run LB, and a hardened channel proxy)
- [ ] Modifies an existing element
- [ ] Overrides a previous decision

---

## Context

NFR-003 requires draining a **1M-asset import within 72 h (≈ 3.86 assets/sec aggregate)**; NFR-004 requires **balanced, health-checked distribution** across ML nodes; NFR-006 requires the remote-ML channel — which carries **user photo previews** — to be **authenticated and transport-encrypted** with network isolation before pilot. The upstream docs state (all upstream-documented):

- Remote ML runs on a separate host over HTTP on **port 3003**; the server sends image previews to it (`immich-remote-machine-learning.md:11,35-36`; BASELINE §1.2).
- **"Multiple URLs are processed sequentially without load distribution. Use a dedicated load balancer for better resource allocation across multiple containers."** (`immich-remote-machine-learning.md:53`) — stock multi-URL dispatch cannot meet NFR-004; the docs themselves direct operators to an external LB.
- **"The ML container lacks built-in security measures"**, with an explicit warning against public/paid-cloud placement (`immich-remote-machine-learning.md:19`; OQ#3) — channel hardening is entirely operator-side.
- **Facial Recognition does not offload**: it clusters previously saved model outputs in Postgres — a server-to-database operation (`immich-remote-machine-learning.md:15`). Only Smart Search and Face Detection reach the remote tier.
- Coarse capacity heuristics only: **≤ 16 concurrent jobs with a GPU** (2–3 on CPU) per the FAQ; **no per-asset inference time or assets/sec figure exists anywhere in the doc set** (OQ#2, R-03; component-spec-immich-machine-learning "floors, not throughput").

Upstream-documented vs operator-side: the need for an external LB and the absence of channel security are Immich's own statements. The LB and the auth/TLS reverse proxy themselves are **operator-side design** using generic technology categories (an HTTP load balancer with health checks; a TLS-terminating reverse proxy enforcing authentication) — Immich documents no specific product or configuration for them.

---

## Options Considered

### Option A: Single scaled-up remote ML host (vertical only)

- **Description**: One remote ML host with GPU acceleration, sized as large as needed; no LB. Channel hardening still required separately.
- **Pros**: Simplest topology; exactly the documented remote-ML mode; no LB failure surface; version alignment is one host.
- **Cons**: The FAQ's **≤ 16 GPU-concurrency ceiling** caps a single node; if the benchmark shows per-asset time above the acceptance bound (~4.15 s/asset mean at ≤16 concurrency — ARCH-TARGET §3.1), there is **no headroom path** without redesign. Single node = ML SPOF for the ingest job chain (R-03). Does not satisfy NFR-004's scale-out premise.

### Option B: Stock multi-URL list across several ML hosts (no LB)

- **Description**: Configure multiple ML URLs in the admin panel and rely on stock dispatch.
- **Pros**: Zero added components; pure stock configuration (best CON-001 optics).
- **Cons**: **Documented to fail the requirement**: dispatch is sequential with no load distribution (`immich-remote-machine-learning.md:53`), so aggregate throughput does not scale with node count and there is no health-checking — NFR-004 is unmet by the docs' own statement. Rejected on documented behaviour, not judgement.

### Option C: Dedicated ML tier behind an operator-run load balancer, hardened channel — **recommended**

- **Description**: A dedicated tier of N `immich-machine-learning` containers (GPU-backed) behind an **operator-run load balancer** with health checks and retry. The server is configured with **one** ML URL: a **TLS-terminating reverse proxy that enforces authentication** in front of the tier's port-3003 endpoints, on an isolated network segment (server-tier → proxy/LB → ML nodes). N is set by the benchmark gate below.
- **Pros**: Matches the docs' own direction (external LB); satisfies NFR-004 (balanced, health-checked) and NFR-006 (auth + TLS + isolation) in one channel; horizontal headroom under the per-node ≤16 concurrency ceiling; ML nodes remain stock containers — the LB/proxy are external, reversible additions (CON-001).
- **Cons**: LB + proxy add latency and failure surface to the **synchronous** ingest path (ARCH-TARGET §3.1/§3.5 tie); N nodes must stay **version-aligned** with the server (BASELINE §1.2), widening the NFR-002 upgrade choreography (R-05); TLS/auth overhead on every preview transfer is unmeasured.

---

## Final Decision

- **Chosen option**: **Option C** — dedicated ML tier behind an operator-run LB, with auth + TLS terminated at a reverse proxy in front of port 3003 (recommended posture, pending architect approval).
- **Rationale**: Option B is eliminated by documented behaviour; Option A has no headroom path against an unquantified workload. Option C is the only topology that reaches NFR-003's aggregate figure by adding nodes, satisfies NFR-004's balanced/health-checked requirement, and closes OQ#3's security gap at a single enforcement point — while keeping every Immich container stock (CON-001: the LB and proxy are removable, config-level additions).

**Explicit open point — NFR-003 benchmark gate (binding):** no per-asset inference time exists in the doc set (**OQ#2**). **Per-asset inference time must be measured on representative pilot hardware before the 72 h / 1M-asset figure is committed** and before tier size N is fixed. Acceptance bound from ARCH-TARGET §3.1: mean ≤ ~4.15 s/asset at the ≤16 GPU-concurrency ceiling per node, or proportional horizontal scale-out. Until the benchmark runs, N and the 72 h commitment are **[TBD]** — this ADR fixes the topology, not the size.

**Scope boundary:** **Facial Recognition stays server-bound** (server-to-Postgres clustering of stored outputs) and is **not scaled by this ADR**; its load remains on the server + Postgres path and is governed by ADR-002 (worker split) and ADR-003 (store HA). The lighter `buffalo_s` model remains the documented lever if recognition load becomes limiting.

---

## Evidence

- **vendor_doc** — `input/systems/immich/immich-remote-machine-learning.md:11,15,19,35-36,53`: port 3003; previews sent; Facial Recognition exception; no built-in security; sequential-no-LB + "use a dedicated load balancer".
- **vendor_doc** — `input/systems/immich/immich-faq-scaling-excerpts.md:49,67`: ≤16 GPU concurrency, 2–3 CPU; `buffalo_s` lever.
- **nfr_analysis** — ARCH-TARGET §3.1/§3.5 (run `2026-07-11-immich-scale-up-design`): 3.86 assets/sec aggregate; ~4.15 s/asset acceptance bound; benchmark-before-commit; channel hardening as pilot gate.
- **discovery** — `core/artifacts/component-spec-immich-machine-learning.md`: stateless tier, floors-not-throughput, OQ#2/R-03 linkage; ML hardware acceleration backends (CUDA/ROCm/OpenVINO etc.) as documented floors.
- **technical_constraint** — BASELINE §1.2: server/ML version alignment requirement.

---

## Constraints

- **CON-001**: LB and proxy must remain external, config-level, removable additions; ML containers stay stock.
- **NFR-002 / R-05**: upgrade choreography must cover N version-aligned ML nodes inside the ≤15 min window.
- Evidence is first-party docs only (**R-04**); no throughput telemetry exists (OQ#2).

---

## Consequences

- **What this enables**: A scaling unit for ML that grows with measured demand; NFR-006 closed at one enforcement point; the ingest backlog risk (R-03) gains a capacity lever.
- **What this limits**: Ingest-path latency now includes proxy/LB hops and TLS; ML tier cost scales with N GPUs; upgrades touch N+1 hosts in lock-step.
- **What to watch for**: Benchmark result vs the 4.15 s bound (gate); LB/proxy as new SPOFs — they need their own redundancy posture (ties ADR-003's drill discipline); recognition (server-bound) becoming the new bottleneck after detection scales.

---

## Success Metrics

- Benchmark gate executed: measured per-asset inference time on pilot hardware recorded **before** the 72 h commitment; N derived from it.
- Pilot backlog drill: 1M-asset synthetic import drains within **72 h** at the chosen N.
- Channel audit: no unauthenticated, unencrypted path to any ML node from outside the isolated segment (pilot gate for transition M1, per ARCH-TARGET §3.5).

---

## System Alignment

- **Related ADRs**: related_to ADR-001 (ML isolation — this ADR scales that unit), ADR-002 (server-side workers, recognition path), ADR-003 (store HA; LB/proxy redundancy discipline), ADR-005 (media/storage).
- **Affects `core/3.ARCH-TARGET.md`**: Yes — §3.1 (NFR-003, NFR-004) and §3.5 (NFR-006) entries cite this ADR (reconciled at `[Tentative]` per AGENT-RULES §8).
- **Affects `core/1.ARCH-CONTEXT.md`**: No.
- **Affected agents**: component-spec-agent (ML spec realization section), integration-contract-agent (server↔ML channel contract), nfr-analysis-agent (benchmark gate), fitness-review-agent, handoff-agent.
- **Related artifacts**: `core/artifacts/component-spec-immich-machine-learning.md`; `core/artifacts/risk-register.md` (R-03, R-05); OQ#2/OQ#3 register rows.

---

## Lifecycle

| Status | Date | Reason |
|--------|------|--------|
| proposed | 2026-07-11 | Unattended-run design proposal (session D3); awaiting architect review |
