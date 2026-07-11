# ADR-003 — Stateful-store HA topology for the pilot

## Decision Metadata

- **Title**: Stateful-store HA topology for the 50-instance pilot
- **Date**: 2026-07-11
- **Author**: Simulated architect (demo)
- **Severity**: MAJOR
- **Decision type**: nfr_quality_attribute
- **Status**: proposed (canonical lifecycle: `core/decisions/INDEX.md`)

**Status note:** This ADR is an **unattended-run design proposal** (session D3). **No human has reviewed or approved it.** Per the Human Approval Rule, it is a draft until the architect explicitly approves; nothing here is final delivery.

---

## Decision Impact

- [x] Introduces something new (an operator-side HA layer for the stateful stores)
- [ ] Modifies an existing element
- [ ] Overrides a previous decision

---

## Context

NFR-001 requires **99.9% monthly availability (≤ 43.8 min/month)** per managed instance on the API/serving path, but the three stateful stores (Postgres system-of-record, Redis queue state, filesystem media) have **no documented HA, replication, or failover path** in the first-party doc set (BASELINE §3.3; **R-01** critical; **OQ#1**). The D3 scaling guide (synthesis **T14**) confirms the multi-node *topology* — parallel `immich-server` replicas share one Postgres, one Redis, and identical file mounts — while explicitly giving no sizing ("left as an exercise for the reader") and confirming the shared stores as a **single point of failure** for everything behind them. The pilot shape is **50 isolated instances**; **CON-001** bounds any HA machinery to stay minimal and reversible against the stock upgrade path. ARCH-TARGET §3.3 already establishes the capability need (operator-supplied store HA — no stock path); this ADR names the recommended realization posture.

Upstream-documented vs operator-side: Immich documents *that* all state lives in the three stores and *that* external Postgres/Redis endpoints are how replicas connect (scaling guide). It documents **no** HA mechanism. Every HA option below is therefore **operator-side design** using generic, well-known technology categories (e.g. "Postgres streaming replication + failover manager", "Redis replica + sentinel-class failover") — **not** capabilities Immich documents (R-04 caveat applies).

---

## Options Considered

### Option A: Per-instance single-node stores + fast-restore

- **Description**: Keep each instance's Postgres/Redis/media single-node (stock shape). Invest in detection, runbooks, and fast restore from backups/snapshots; accept downtime inside the 43.8 min/month budget.
- **Pros**: Closest to stock (best CON-001 fit); cheapest; no HA machinery to operate or upgrade around; failure blast radius is one instance.
- **Cons**: Budget math is unforgiving — a single incident must be *detected and fully restored* within ~43.8 min, at most about once a month, with zero budget left for upgrades (NFR-002's ≤15 min window already spends ~34% of the monthly budget — ARCH-TARGET §3.3). No measured restore duration exists at 5 TB/instance scale. Redis queue state has **no documented backup at all** (T18) — a Redis loss silently drops in-flight job state. Hardware-class failures (host, volume) routinely exceed the budget.

### Option B: Operator-managed HA Postgres/Redis per instance — **recommended**

- **Description**: Each instance gets its own small HA pair/cluster for the two availability-critical service stores: Postgres under streaming replication with an automated failover manager, Redis with a replica and sentinel-class failover — generic operator-side patterns, endpoint-transparent to Immich (the stock containers keep connecting to one DB/Redis endpoint; images and compose files unmodified). Media-volume protection and backup are decided separately in **ADR-005**.
- **Pros**: Removes the single-node failure mode for the stores where availability risk concentrates (BASELINE §3.3: server/ML/web hold no durable state); failover is seconds-to-minutes, fitting the 43.8 min budget deterministically rather than probabilistically; blast radius stays **one instance** (matches the isolated-instance pilot shape); reversible under CON-001 — HA sits below the application, so the stock upgrade path is untouched.
- **Cons**: 50 instances × HA machinery = real operational cost (provisioning, monitoring, drills); the HA stack itself is new operator-owned surface Immich's docs say nothing about — client reconnect behaviour through a failover is **unverified** (R-04); upgrade coordination with HA Postgres is undocumented (R-05).

### Option C: Shared HA store pools across instances

- **Description**: Consolidate stores into shared HA pools (e.g. one HA Postgres cluster hosting 50 databases, one HA Redis serving 50 logical queues), extending the scaling guide's shared-store topology (T14) across instances.
- **Pros**: Amortizes HA machinery once instead of ×50; centralizes expertise, monitoring, and capacity headroom.
- **Cons**: The T14/OQ#1 finding cuts directly against it: the shared stores are a confirmed **SPOF for every instance behind them** — a pool failure becomes a cross-customer outage, contradicting the 50-isolated-instances pilot shape and multiplying the NFR-001 breach. Cross-instance coupling also creates noisy-neighbour contention and forces lock-step upgrade constraints against a shared Postgres (R-05: replica coordination/rolling upgrade behaviour undocumented). Note the scaling guide documents shared stores **within one instance's replica set**, not cross-instance pooling — pooling is an operator extrapolation beyond the documented pattern.

---

## Final Decision

- **Chosen option**: **Option B** — operator-managed HA Postgres/Redis per instance (recommended posture, pending architect approval). Option A is retained as a documented fallback for any future customer tier that contractually tolerates restore-based recovery; Option C is rejected for the pilot on blast-radius grounds.
- **Rationale**: NFR-001 has **no stock path** (ARCH-TARGET §3.3), so some operator machinery is unavoidable; the question is where. Option B is the only option that both meets the availability budget by design (failover, not restore-race) and preserves the per-instance isolation the pilot is shaped around. It honours CON-001 because the divergence sits *below* the application boundary — stock containers, compose topology, and upgrade path are unchanged; removing the HA layer degrades to stock, which is the reversibility test.

**Explicit open points** (not resolved by this ADR):
- Failover behaviour of Immich's DB/Redis clients through a failover event is unverified — a **failover drill is a pilot gate** before the posture is committed.
- Concrete HA product selection (which failover manager, which Redis HA mode) is operator-side evaluation work; nothing here claims Immich documents them.
- Filesystem/media availability and backup → **ADR-005**. ML-tier availability → **ADR-004**. **OQ#1** remains partially open (store sizing still has no first-party method).

---

## Evidence

- **discovery** — `input/systems/immich/immich-scaling-guide.md:9,13,15,23` (T14): all state in Postgres/Redis/filesystem; replicas require shared access to them; no capacity guidance; shared stores = SPOF.
- **nfr_analysis** — ARCH-TARGET §3.3 (run `2026-07-11-immich-scale-up-design`): 43.8 min/month budget; no stock HA path; upgrade window consumes ~34% of budget.
- **technical_constraint** — BASELINE §3.3: no documented HA/replication/failover for the three stores (a documented silence); no documented Redis backup (T18).
- **stakeholder_input** — CONTEXT engagement card: 50 isolated instances, 99.9% per instance.
- **judgement** — Blast-radius reasoning (Option C rejection) and the failover-vs-restore budget argument are architect-style judgement over the documented facts, flagged as such.

---

## Constraints

- **CON-001**: stock upgrade path / single-codebase model preserved — HA must stay endpoint-transparent and removable.
- Evidence base is first-party documentation only (**R-04**): no telemetry or code inspection backs failover behaviour claims.
- NFR-002 upgrade window co-constrains the availability budget (ARCH-TARGET §3.3).

---

## Consequences

- **What this enables**: A designed (not hoped-for) path to NFR-001; per-instance blast radius preserved; Redis queue-state durability gets an owner (replica) where stock offers nothing.
- **What this limits**: 50× HA stacks to operate — tooling/automation for provisioning and drills becomes mandatory, not optional; some infra cost per instance that Option A would avoid.
- **What to watch for**: Immich client reconnect behaviour on failover (drill before commit); upgrade interplay between startup-applied migrations and HA Postgres (R-05); creeping divergence — if the HA layer starts requiring stock-file changes, CON-001 is being breached and this ADR must be revisited.

---

## Success Metrics

- Failover drill per store class recovers the instance API path in **< 5 min**, measured before pilot go-live.
- Pilot instances sustain **≥ 99.9% monthly availability** over the pilot period.
- **Zero cross-instance outages** caused by a store failure (validates the per-instance posture over Option C).

---

## System Alignment

- **Related ADRs**: related_to ADR-001, ADR-002 (as-built shape); related_to ADR-004 (ML tier), ADR-005 (media storage & backup — completes the third store).
- **Affects `core/3.ARCH-TARGET.md`**: Yes — §3.3 NFR-001 entry cites this ADR (reconciled at `[Tentative]` per AGENT-RULES §8).
- **Affects `core/1.ARCH-CONTEXT.md`**: No.
- **Affected agents**: component-spec-agent, risk-assessment-agent (R-01 mitigation path), fitness-review-agent, handoff-agent.
- **Related artifacts**: `core/artifacts/risk-register.md` (R-01, R-05); `core/artifacts/logs/2026-07-11-immich-scale-up-design-synthesis.md` (T14).

---

## Lifecycle

| Status | Date | Reason |
|--------|------|--------|
| proposed | 2026-07-11 | Unattended-run design proposal (session D3); awaiting architect review |
