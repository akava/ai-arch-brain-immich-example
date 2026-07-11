---
title: Immich Managed-Hosting Scale-Up — M1 Pilot-Enablement Handoff (DRAFT)
date: 2026-07-11
type: handoff
run: 2026-07-11-immich-scale-up-design
agent: handoff-agent (SKILL-008)
status: draft
confidence: medium — design directions are proposed-ADR-backed, not approved; NFR-003's 72h/1M throughput figure is [TBD] (unmeasured)
target: M1 Managed-Hosting Pilot — operator capabilities E-01…E-04 wrapping stock Immich
sources:
  - core/transitions/M1-managed-hosting-pilot.md
  - core/transitions/ENABLER-CATALOG.md (E-01…E-04)
  - core/decisions/ADR-001, ADR-002 (approved) · ADR-003, ADR-004, ADR-005 (proposed)
  - core/1.ARCH-CONTEXT.md (NFR-001…006, CON-001)
  - core/artifacts/integration-contract-immich-server-ml.md
  - core/artifacts/component-spec-immich-machine-learning.md
  - core/artifacts/risk-register.md (R-01…R-06)
  - core/arch-processes/action-register.md (AI-001); open-question-register.md (OQ#1/2/3); ownership-map.md
  - core/artifacts/logs/2026-07-11-immich-scale-up-design-nfr-analysis.md, -fitness-review.md
---

# Immich Managed-Hosting Scale-Up — M1 Pilot-Enablement Handoff (DRAFT)

> **DRAFT — pending architect approval. Do NOT start implementation.** No architect has approved the design ADRs (ADR-003/004/005 are `proposed`). This is a run log in `core/artifacts/logs/`, **not** a `factory/` delivery. Nothing here is engineering-approved work.
>
> **Simulated demonstration engagement.** The engagement, client, and all pilot figures (50 instances, 5 TB/instance, 99.9%, 72 h/1M, ≤15 min) are **fiction** created to exercise this repository's operating model (`core/1.ARCH-CONTEXT.md` → Engagement). The subject system (Immich) and its documented behaviour are real, drawn only from first-party docs under `input/`. Outputs are unreviewed AI drafts.

**Purpose:** orient an engineering team on the M1 Managed-Hosting Pilot — what to build (four operator enablers wrapping stock Immich), in what order, what is decided vs proposed vs open, who owns each, and the evidence behind each gate. Facts are referenced by ID per the one-home rule; this handoff links out and does not restate.

**Verdict / readiness:** **NOT ready to build.** Two prerequisites gate all work: (1) architect approval of ADR-003/004/005; (2) the NFR-003 per-asset ML benchmark (AI-001), which must run **before** ML-tier sizing. Mechanisms are validated against first-party docs; sizing and commitments are not.

**Scope in:** operator-side capabilities that *wrap* stock Immich — per-instance store HA (E-01), a hardened scalable ML tier (E-02), media storage & backup (E-03), a bounded-window upgrade procedure (E-04), for up to 50 isolated single-tenant instances.
**Scope out:** any modification to stock Immich containers (CON-001); Facial Recognition remote-offload (stays server-bound — reads Postgres; ADR-004, ADR-001); shared cross-instance store pools (rejected for blast radius — ADR-003); object storage for media (excluded as undocumented — ADR-005); per-instance sizing beyond the pilot figures.

**Hand-offs (main-loop):** librarian indexes this log + updates `core/artifacts/INDEX.md` total 15→16. On architect approval of the ADRs + a status flip, the delivery-ready version moves to `factory/handoff/` (not done — draft).

---

## What to build — the four enablers with acceptance gates

Each enabler is defined once in `core/transitions/ENABLER-CATALOG.md`; build detail (delta, benefit, acceptance) lives in `core/transitions/M1-managed-hosting-pilot.md` § Deltas. This table is the implementer's index into them — it does not restate the delta.

| Enabler | Capability | Backing ADR | Realizes | Acceptance gate (pilot) | Owner |
|---------|-----------|-------------|----------|-------------------------|-------|
| **E-01** — Per-instance store HA | Operator-managed HA Postgres + Redis per instance, endpoint-transparent to untouched stock containers | ADR-003 (**proposed**) | NFR-001 | **Failover drill**: store failover within the availability budget (M1 § E-01). *Media store is E-03, not this gate.* | Hosting Platform Lead |
| **E-02** — Hardened scalable ML tier | Dedicated remote-ML tier behind an operator-run health-checked **load balancer**; **auth+TLS reverse proxy** fronting port 3003 on an isolated segment; tier size `N` from benchmark | ADR-004 (**proposed**) | NFR-003, NFR-004, NFR-006 | (a) **NFR-003 benchmark gate** — measured per-asset inference time sizes tier `N` and decides go/no-go on the 72 h/1M commitment (AI-001, OQ#2); (b) **secured channel in place before the tier carries real content** (NFR-006 "before pilot", OQ#3) | ML Platform Owner |
| **E-03** — Media storage & backup | Per-instance media volumes on supported (non-NTFS/FAT) filesystems; operator snapshot + off-instance replication honoring **DB-first-then-filesystem** ordering; Redis-queue-state durability | ADR-005 (**proposed**) | NFR-005 | **Restore rehearsal** recovering an instance honoring the DB-first-then-filesystem ordering (M1 § E-03) | Hosting Platform Lead (stateful-store scope) |
| **E-04** — Bounded-window upgrade procedure | Rehearsed maintenance-window upgrade over the split/HA topology: server + startup Postgres migrations + version-aligned ML restart; customizations minimal + reversible | R-05, CON-001 (no design ADR; procedure) | NFR-002, CON-001 | **≤ 15-min upgrade rehearsal** on a split/HA instance, migration duration measured at pilot scale (NFR-002) | Immich Runtime Owner |

**Component & contract references** (link out, not restated):
- `component-spec-immich-machine-learning.md` — the ML service E-02 scales: Smart Search + Face Detection (remote-eligible), Facial Recognition server-bound, HTTP port 3003, stateless model cache, five GPU backends, scaling levers; throughput/sizing gap (OQ#2, R-03).
- `integration-contract-immich-server-ml.md` — the server↔ML channel E-02 hardens: synchronous HTTP port 3003, image previews out / model outputs in, wire schema **[TBD]**, sequential multi-URL **no-LB** dispatch, manual retry, **version alignment** required, **no built-in auth/TLS**. ADR-004 overlays the LB + auth/TLS reverse proxy as `[Tentative]` target; §4.4 timeout/retry/idempotency conventions **[TBD]**.

---

## Sequencing — what order, and why (dependency-derived)

Order is **not** free; it falls out of the recorded dependencies (M1 § Open/watch; AI-001; OQ#1/2/3; ADR pilot gates). Two hard gates sit ahead of everything.

**Gate 0 — Approve the design ADRs (blocks ALL implementation).** ADR-003/004/005 are `proposed`. Their deltas are written at `[Tentative]`. Per `core/AGENT-RULES.md` §9, the `active → delivered` flip and any baseline promotion are the architect's explicit call. **No enabler build starts until its backing ADR is approved.**

**Gate 1 — Run the NFR-003 ML benchmark before sizing the ML tier (AI-001, OQ#2).** NFR-003's 72 h/1M figure is **[TBD]** — no per-asset inference time exists in the doc set; the derived acceptance bound is mean **≤ ~4.15 s/asset at 16-way GPU concurrency**, or proportional scale-out behind the operator LB (D3 nfr-analysis §C). Tier size `N` **cannot be chosen** until this is measured. AI-001 checkpoint 2026-07-18. **The benchmark gate precedes E-02 tier sizing** — this is the load-bearing sequencing call.

Given the gates, the build order across enablers is:

1. **Prerequisite (parallel, no instance impact): NFR-003 ML benchmark** (E-02 exploration lead, AI-001). Runs first because its result sizes E-02 and decides the 72 h/1M go/no-go. Independent of E-01/E-03/E-04 — start immediately on ADR-004 approval.
2. **E-02 channel hardening (auth + TLS reverse proxy + network isolation)** before the ML tier carries any real user content (NFR-006 "before pilot", R-06, OQ#3). This is a gating precondition for the tier going live — sequence it ahead of pointing real previews at the remote tier, independent of the benchmark.
3. **E-01 store HA** and **E-03 media storage & backup** — foundational per-instance data-durability capabilities; stand these up so an instance has HA stores and recoverable media/queue state before it is exercised. E-01 and E-03 are largely independent of the ML benchmark and of each other (Redis durability spans both — E-03 depends on E-01's Redis via ADR-003).
4. **E-02 ML tier sizing + LB standup** — once the benchmark (step 1) yields `N` and the channel (step 2) is hardened, size and deploy the balanced tier (NFR-003/004).
5. **E-04 upgrade procedure rehearsal** — last, because it exercises the *assembled* split/HA topology (server + migrations + version-aligned ML restart). It cannot be rehearsed meaningfully until E-01 (HA stores) and E-02 (split ML tier) exist.

**Per-instance rollout staging (cross-cutting).** Instances are brought onto the operator capabilities **one at a time** — each instance's HA, ML-tier binding, backup, and upgrade rehearsal validated before the next — bounding blast radius across the up-to-50-instance pilot (M1 § Coexistence).

**Co-constraint to honor in E-04:** a ≤15-min upgrade spends ~34% of NFR-001's 43.8 min/month availability budget in a single monthly upgrade (D3 nfr-analysis §A×B) — planned and unplanned downtime share one budget.

---

## Decided vs proposed vs open

**Decided (approved, as-built — build against these):**
- **ADR-001** — ML inference isolated in the stateless `immich-machine-learning` service (Python/FastAPI + ONNX), called synchronously over HTTP; enables independent ML scaling + memory isolation (R-03).
- **ADR-002** — background work on Redis/BullMQ queues; api + microservices workers co-located in one `immich-server` by default, splittable via `IMMICH_WORKERS_INCLUDE`/`EXCLUDE` (the sanctioned scaling lever, R-02); Redis is availability-critical queue state (R-01).

**Proposed (design direction set, awaiting architect approval — DO NOT build until approved):**
- **ADR-003** — per-instance HA Postgres/Redis (endpoint-transparent), over single-node+fast-restore and shared cross-instance HA pools; failover drill is a pilot gate (R-01, OQ#1, CON-001).
- **ADR-004** — dedicated remote-ML tier behind an operator LB, auth+TLS at a reverse proxy fronting port 3003; NFR-003 benchmark gate open; Facial Recognition stays server-bound (R-03, R-06, OQ#2/3).
- **ADR-005** — per-instance media volumes on supported filesystems + operator snapshot/replication media backup honoring DB-first-then-filesystem ordering; stock DB dumps retained + copied off-instance; shared network pool and object storage rejected (NFR-005, T18).

**Open — must be closed before/within the pilot (link out, not restated):**
- **AI-001** — NFR-003 disposition: run the ML per-asset benchmark before committing 72 h/1M, or re-scope/gate in M1. Checkpoint 2026-07-18. Gates E-02 (a).
- **OQ#1** — multi-node HA/failover path for the shared stores absent; store-HA design + sizing need evidence beyond the doc set. Gates E-01.
- **OQ#2** — per-node/per-GPU ML throughput (assets/sec) unquantified; NFR-003 unmeasurable from evidence. Gates E-02 benchmark.
- **OQ#3** — remote-ML channel security remnant: operator must supply auth / transport encryption / network isolation the docs do not specify. Gates E-02 channel hardening.
- **[TBD] figures carried into the pilot:** NFR-003 72 h/1M (unmeasured); NFR-002 migration-duration-fits-15-min (no published figure); GPU-transcode storage-growth multiplier bounding the 250 TB provisioning; integration-contract wire schema + §4.4 timeout/retry/idempotency.
- **TARGET §5 unpopulated** — the binding-gate section is a stub; the constraints binding this pilot are carried by the `NFR-`/`CON-` rows and their §3 responses until §5 is populated (M1 § Binding gates).

---

## Who owns what

Role-level accountability, client-confirmed under the engagement fiction (`core/arch-processes/ownership-map.md`; satisfies the ARCH-TARGET §5.2 ownership gate at role granularity — name-level confirmation out of scope for the demo):

- **Hosting Platform Lead** — store HA (E-01/WS1) and media/backup (E-03/WS3, stateful-store operability scope); the availability target rests here (R-01, OQ#1).
- **ML Platform Owner** — ML scale-out, LB, throughput sizing, and the unsecured-channel remediation (E-02/WS2; R-03, R-06, OQ#2/3).
- **Immich Runtime Owner** — server, workers, upgrades; owns the stock-upgrade-path tension (E-04/WS4; R-02, R-05, CON-001).

---

## Coexistence — new vs stock (CON-001)

Stock containers are **untouched**: operator capabilities wrap around stock Immich — HA endpoints are transparent to the stock containers, the LB/auth-proxy front stock `immich-machine-learning`, backup operates on stock stores/volumes. Customizations kept **minimal and reversible** so the stock single-codebase upgrade path survives (CON-001, R-05). No stock modification is in scope.

---

## Evidence backing (provenance)

Every gate traces to first-party Immich docs under `input/systems/immich/`, carried through the D3 run. The **R-04 documentation-confidence caveat applies throughout** — as-is facts rest on documented intent, not code inspection or telemetry; load-bearing assumptions (HA, throughput, migration duration) are explicit gaps, not silent assumptions.

- Availability / store-HA gap → BASELINE §3.3; R-01 (critical); OQ#1; D3 nfr-analysis §A.
- ML throughput / sizing → BASELINE §3.1/§3.4 (FAQ concurrency heuristics 2–3 CPU / ≤16 GPU); OQ#2; R-03; component-spec; D3 nfr-analysis §C (3.86 assets/sec derivation, ≤~4.15 s/asset bound).
- ML channel security → BASELINE §1.2; integration-contract §2; R-06; OQ#3; NFR-006; D3 nfr-analysis §E.
- Media / backup → BASELINE §3.3 (DB-only backup, daily 02:00, keep-14) / §3.4 (NTFS/FAT unsupported); ADR-005; D3 nfr-analysis §D.
- Upgrade / migrations → BASELINE §3.3/§1.4 (migrations at startup, version-aligned ML); R-05; CON-001; D3 nfr-analysis §B.
- D3 fitness review — verdict **proceed_with_caveats**; load-bearing D3 facts re-verified against input docs; §-parity sound; fiction-hygiene clean (`logs/2026-07-11-immich-scale-up-design-fitness-review.md`).

---

## Risks (link out to `risk-register.md`)

- **R-01** (critical, mitigating) — stateful stores no HA → E-01 (ADR-003) mitigates; failover drill gate.
- **R-03** (high, mitigating) — ML memory-intensive, throughput unquantified → E-02 (ADR-004) + NFR-003 benchmark gate.
- **R-05** (high, open) — stock upgrade path vs split/HA topology → E-04 rehearsal; bounded by CON-001, NFR-002.
- **R-06** (high, mitigating) — unsecured server↔ML port-3003 channel carries user photos → E-02 channel hardening (ADR-004), **before pilot** gate.
- **R-02** (high, open) — worker co-location contention → env-var worker split (ADR-002) as hosting baseline; carried, not an E-01…E-04 gate.
- **R-04** (high, open) — docs-only evidence base → validate load-bearing assumptions against code/telemetry before pilot sign-off.

## Open items (this handoff)

- Delivery-ready packaging withheld from `factory/` — blocked on architect approval of ADR-003/004/005 and a `draft → approved` status flip (factory approval gate, `core/AGENT-RULES.md`). This handoff is the draft.
- A fitness review covering this run exists (`logs/2026-07-11-immich-scale-up-design-fitness-review.md`) — the factory-gate review prerequisite is met on that axis; approval is the remaining blocker.
