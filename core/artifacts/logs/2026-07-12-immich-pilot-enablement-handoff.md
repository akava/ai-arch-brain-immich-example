---
title: Immich Managed-Hosting Scale-Up — M1 Pilot-Enablement Handoff (DRAFT, supersedes 2026-07-11)
date: 2026-07-12
type: handoff
run: 2026-07-12-immich-pilot-enablement
agent: handoff-agent (SKILL-008)
status: draft
supersedes: logs/2026-07-11-immich-scale-up-design-handoff.md (four-enabler package; frozen, not edited)
confidence: medium — six design ADRs (ADR-003…008) are proposed, not approved; NFR-003's 72 h/1M figure is [TBD] (unmeasured, AI-001); three ownership rulings are interim, pending client confirmation
target: M1 Managed-Hosting Pilot — operator capabilities E-01…E-06 wrapping stock Immich
sources:
  - core/transitions/M1-managed-hosting-pilot.md · core/transitions/ENABLER-CATALOG.md (E-01…E-06)
  - core/decisions/ADR-001, ADR-002 (approved) · ADR-003…ADR-008 (proposed)
  - core/1.ARCH-CONTEXT.md (NFR-001…006, CON-001)
  - core/artifacts/component-spec-immich-machine-learning.md · integration-contract-immich-server-ml.md · risk-register.md (R-01…R-12)
  - core/arch-processes/action-register.md (AI-001) · open-question-register.md (OQ#1…#7) · ownership-map.md
  - core/artifacts/logs/ D3 nfr-analysis · D3–D6 fitness reviews · D4/D6 risk assessments
---

# Immich Managed-Hosting Scale-Up — M1 Pilot-Enablement Handoff (DRAFT)

> **DRAFT — pending architect approval. Do NOT start implementation.** No design ADR is approved (ADR-003…008 are `proposed`). This is a run log in `core/artifacts/logs/`, **not** a `factory/` delivery. Nothing here is engineering-approved work.
>
> **Supersedes** the 2026-07-11 four-enabler handoff (`logs/2026-07-11-immich-scale-up-design-handoff.md`): the package has grown to six enablers via D4 (identity & access), D5 (operability & observability), and D6 (customer-library onboarding). The old log stays frozen; its INDEX row is flipped to `superseded`.
>
> **Simulated demonstration engagement.** The engagement, client, and all pilot figures (50 instances, 5 TB/instance, 99.9%, 72 h/1M, ≤15 min) are **fiction** created to exercise this repository's operating model (`core/1.ARCH-CONTEXT.md` → Engagement). The subject system (Immich) and its documented behaviour are real, drawn only from first-party docs under `input/`. Outputs are unreviewed AI drafts.

**Purpose:** orient an engineering team on the M1 Managed-Hosting Pilot — what to build (six operator enablers wrapping stock Immich), in what order, what is decided vs proposed vs open, who owns each, and the evidence behind each gate. Facts are referenced by ID per the one-home rule; this handoff links out and does not restate.

**Verdict / readiness: NOT ready to build.** Two prerequisites gate all work: (1) architect approval of ADR-003…008; (2) the NFR-003 per-asset ML benchmark (AI-001, checkpoint 2026-07-18), which sizes the ML tier **and** sets E-06's backlog-drain figure. Three ownership rulings (identity plane, E-05, E-06) are interim architect rulings of 2026-07-12, **pending client confirmation**. Mechanisms are validated against first-party docs; sizing and commitments are not (R-04).

**Scope in:** operator-side capabilities that *wrap* stock Immich for up to 50 isolated single-tenant instances — per-instance store HA (E-01), a hardened scalable ML tier (E-02), media storage & backup (E-03), a bounded-window upgrade procedure (E-04), fleet observability & health (E-05), a customer onboarding pipeline (E-06).
**Scope out:** any modification to stock Immich containers (CON-001); Facial Recognition remote-offload (server-bound; ADR-001/004); shared cross-instance store pools (ADR-003); object storage for media (ADR-005); external libraries as onboarding default (ADR-008 — opt-in exception only); per-instance sizing beyond the pilot figures.

**Hand-offs (main-loop):** librarian indexes this log; `core/artifacts/INDEX.md` old-handoff row flips `active → superseded`, total 24→25. On architect approval of the ADRs + status flip, the delivery-ready version moves to `factory/handoff/` (not done — draft).

---

## What to build — six enablers with acceptance gates

Each enabler is defined once in `core/transitions/ENABLER-CATALOG.md`; build detail (delta, benefit, acceptance) lives in `core/transitions/M1-managed-hosting-pilot.md` § Deltas. This table is the implementer's index — it does not restate the delta.

| Enabler | Capability | Backing ADR | Realizes | Acceptance gate (pilot) | Owner (WS) |
|---------|-----------|-------------|----------|-------------------------|------------|
| **E-01** — Per-instance store HA | Operator-managed HA Postgres + Redis per instance, endpoint-transparent to untouched stock containers | ADR-003 (**proposed**) | NFR-001 | **Failover drill** within the availability budget. *Media store is E-03, not this gate.* | Hosting Platform Lead (WS1) |
| **E-02** — Hardened scalable ML tier | Dedicated remote-ML tier behind operator-run health-checked LB; auth+TLS reverse proxy fronting port 3003 on an isolated segment; tier size `N` from benchmark | ADR-004 (**proposed**) | NFR-003, NFR-004, NFR-006 | (a) **NFR-003 benchmark gate** — measured per-asset inference time sizes `N`, go/no-go on 72 h/1M (AI-001, OQ#2); (b) **secured channel before the tier carries real content** (NFR-006 "before pilot", OQ#3) | ML Platform Owner (WS2) |
| **E-03** — Media storage & backup | Per-instance media volumes on supported (non-NTFS/FAT) filesystems; operator snapshot + off-instance replication honoring **DB-first-then-filesystem** ordering; Redis-queue-state durability; E-06 transient staging capacity sized in (R-11) | ADR-005 (**proposed**) | NFR-005 | **Restore rehearsal** honoring the DB-first-then-filesystem ordering. Transcode growth headroom % [TBD]. | Hosting Platform Lead (WS3) |
| **E-04** — Bounded-window upgrade procedure | Rehearsed maintenance-window upgrade over the split/HA topology: server + startup Postgres migrations + version-aligned ML restart; customizations minimal + reversible | — (R-05, CON-001; procedure) | NFR-002, CON-001 | **≤ 15-min upgrade rehearsal** on a split/HA instance, migration duration measured at pilot scale | Immich Runtime Owner (WS4) |
| **E-05** — Fleet observability & health | Operator-run central observability plane: fleet-wide Prometheus scrape (8081/8082, groups api/host/io), central JSON log shipping + retention, operator-built health/readiness probes over the stock one-shot `.immich` startup check, NFR-001-error-budget-tied alerting; per-instance data segregated | ADR-007 (**proposed**) | NFR-001 | **Induced instance failure raises an alert within the pilot detection window** — window [TBD], set at this gate; every pilot instance carries a container health/readiness probe wired to alerting with telemetry on both ports (OQ#5 remnant: probe design is build work) | Hosting Platform Lead (WS5) |
| **E-06** — Customer onboarding pipeline | Staged operator-driven CLI ingest as default (customer data → staging volume → `immich upload` → retire staging); direct CLI upload for small libraries; external-library **opt-in exception only** (`:ro` mount + signed-off import-path config); operator-side `--concurrency` arrival-rate lever shapes the NFR-003 ML backlog | ADR-008 (**proposed**) | NFR-003, NFR-005 | **Rehearsed onboarding of a representative multi-hundred-GB library** via the staged-ingest path, ML backlog drained per the NFR-003 disposition ([TBD] pending AI-001); every B-exception onboarding carries `:ro` + signed-off import paths before scan | Hosting Platform Lead (WS6) |

**Component & contract references** (living artifacts, link out): `component-spec-immich-machine-learning.md` — the ML service E-02 scales (remote-eligible Smart Search + Face Detection, Facial Recognition server-bound, stateless, five GPU backends; throughput gap OQ#2/R-03). `integration-contract-immich-server-ml.md` — the channel E-02 hardens (synchronous HTTP 3003, wire schema **[TBD]**, sequential no-LB dispatch, version alignment, no built-in auth/TLS; ADR-004 overlay `[Tentative]`; §4.4 timeout/retry/idempotency **[TBD]**).

---

## Sequencing — what order, and why (dependency-derived, six enablers)

Order falls out of the recorded dependencies (M1 § Deltas gates; AI-001; OQ#1/2/3/6/7; R-06/R-11). Two hard gates sit ahead of everything.

**Gate 0 — Approve the design ADRs (blocks ALL implementation).** ADR-003…008 are `proposed`; their deltas are `[Tentative]`. Per `core/AGENT-RULES.md` §9, no enabler build starts until its backing ADR is approved. E-04 has no design ADR but presupposes ADR-003/004 topology.

**Gate 1 — Run the NFR-003 ML benchmark before sizing the ML tier (AI-001, OQ#2, checkpoint 2026-07-18).** The 72 h/1M figure is **[TBD]**; derived bound: mean ≤ ~4.15 s/asset at 16-way GPU concurrency, or proportional scale-out (D3 nfr-analysis §C). The benchmark now gates **two** enablers: E-02 tier size `N` and E-06's backlog-drain acceptance figure.

Build order:

1. **NFR-003 ML benchmark** (parallel prerequisite, no instance impact; AI-001) — start immediately on ADR-004 approval; its result sizes E-02 and sets E-06's drain gate.
2. **E-02 channel hardening** (auth + TLS proxy + network isolation) — before the ML tier carries any real content (NFR-006 "before pilot", R-06, OQ#3); also a precondition for the E-06 rehearsal, which pushes real customer previews down this channel.
3. **E-05 observability-plane standup** — early, in parallel with step 4, so the failover drill (E-01), restore rehearsal (E-03), tier sizing (E-02), onboarding rehearsal (E-06), and upgrade rehearsal (E-04) all land **under observation**; its per-instance data segregation follows ADR-003's model, and its own alert-induction gate is validated once the first HA instance exists.
4. **E-01 store HA + E-03 media storage & backup** — foundational per-instance data durability; largely independent of each other (Redis durability spans both — E-03 depends on E-01's Redis via ADR-003). E-03 sizing includes E-06's transient staging headroom (staged bytes held twice per onboarding, R-11).
5. **E-02 ML tier sizing + LB standup** — once the benchmark (1) yields `N` and the channel (2) is hardened, deploy the balanced tier (NFR-003/004).
6. **E-06 onboarding rehearsal** — after staging capacity (E-03), a hardened sized ML tier to drain the backlog (E-02), and the observability plane to watch it (E-05); blocked on the NFR-003 disposition (AI-001) for its drain figure. B-exception onboardings additionally gate on `:ro` + signed-off import paths (R-10) and nightly-scan capacity budgeting (R-12, OQ#7).
7. **E-04 upgrade rehearsal — last**, because it exercises the *assembled* split/HA topology (server + migrations + version-aligned ML restart) and is only meaningful once E-01/E-02 exist; rehearsed under E-05 observation so the ≤15-min window is measured, not assumed (NFR-002, R-05).

**Per-instance rollout staging (cross-cutting).** Instances are brought onto the operator capabilities one at a time — each instance's HA, ML-tier binding, backup, probes, onboarding, and upgrade rehearsal validated before the next — bounding blast radius across the up-to-50-instance pilot (M1 § Coexistence).

**Co-constraint for E-04:** a ≤15-min upgrade spends ~34% of NFR-001's 43.8 min/month availability budget in one monthly upgrade (D3 nfr-analysis §A×B) — planned and unplanned downtime share one budget; E-05's error-budget alerting must account for planned windows.

---

## Decided vs proposed vs open

**Decided (approved, as-built — build against these):**
- **ADR-001** — ML inference isolated in the stateless `immich-machine-learning` service (Python/FastAPI + ONNX), called synchronously over HTTP; independent ML scaling + memory isolation (R-03).
- **ADR-002** — background work on Redis/BullMQ; api + microservices workers co-located by default, splittable via `IMMICH_WORKERS_INCLUDE`/`EXCLUDE` (the sanctioned scaling lever, R-02); Redis is availability-critical queue state (R-01).

**Proposed (direction set, awaiting architect approval — DO NOT build until approved):**
- **ADR-003** — per-instance HA Postgres/Redis, endpoint-transparent; shared cross-instance pools rejected; failover drill gate (E-01; R-01, OQ#1, CON-001).
- **ADR-004** — remote-ML tier behind operator LB, auth+TLS proxy at 3003; benchmark gate open; Facial Recognition stays server-bound (E-02; R-03, R-06, OQ#2/3).
- **ADR-005** — per-instance media volumes + operator snapshot/replication backup, DB-first-then-filesystem; network pool + object storage rejected (E-03; NFR-005, T18).
- **ADR-006** — per-customer identity federation: per-instance OIDC to the customer's own IdP, password login retained for break-glass (identity posture; R-07/R-08/R-09, OQ#4). No enabler of its own — its runbook obligations land in E-04/E-05 operations.
- **ADR-007** — central fleet observability plane: fleet-wide scrape, central log shipping + retention, operator probes, error-budget alerting (E-05; NFR-001; partially resolves OQ#5).
- **ADR-008** — staged operator-driven CLI ingest as onboarding default; direct CLI for small libraries; external libraries B-exception-only with `:ro` + sign-off (E-06; NFR-003/005; R-09…R-12, OQ#6).

**Open — must be closed before/within the pilot (link out, not restated):**
- **AI-001** — NFR-003 disposition: benchmark before committing 72 h/1M, or re-scope/gate in M1. Checkpoint **2026-07-18**. Gates E-02 (a) and E-06's drain figure.
- **OQ#1** (store HA/failover evidence gap — gates E-01) · **OQ#2** (per-node ML throughput — gates the benchmark) · **OQ#3** (channel security operator-supplied — gates E-02 hardening) · **OQ#4** (no API-key/session-invalidation surface — R-08 aggravator, incident-response gap) · **OQ#5** remnant (container-health probe design + detection window — E-05 build work) · **OQ#6** (no first-party migration guide — E-06 procedure is operator-authored, formats not invented) · **OQ#7** (external-library watch/nightly-scan bounds at multi-TB — bounds E-03/E-06 B-exceptions).
- **[TBD] figures carried into the pilot:** NFR-003 72 h/1M; NFR-002 migration-fits-window; transcode storage-growth multiplier bounding 250 TB; E-05 alert detection window; contract wire schema + §4.4 conventions.
- **TARGET §5 unpopulated** — binding-gate section is a stub; constraints are carried by the `NFR-`/`CON-` rows and §3 responses until populated (M1 § Binding gates).

---

## Who owns what

Role-level accountability per `core/arch-processes/ownership-map.md` (satisfies the ARCH-TARGET §5.2 ownership gate at role granularity; name-level out of scope for the demo). **Three rows are interim architect rulings of 2026-07-12, pending client confirmation — flag at pilot kickoff:**

- **Hosting Platform Lead** — store HA (E-01/WS1), media/backup (E-03/WS3); *interim, pending client confirmation:* fleet observability & health (E-05/WS5) and customer onboarding pipeline & staging (E-06/WS6). Availability target rests here (R-01, OQ#1; R-10…R-12).
- **ML Platform Owner** — ML scale-out, LB, throughput sizing, unsecured-channel remediation (E-02/WS2; R-03, R-06, OQ#2/3).
- **Immich Runtime Owner** — server, workers, upgrades (E-04/WS4; R-02, R-05, CON-001); *interim, pending client confirmation:* the identity & access control plane (ADR-006; R-07/R-08/R-09, OQ#4).

---

## Coexistence — new vs stock (CON-001)

Stock containers are **untouched**: HA endpoints transparent, LB/auth-proxy front stock `immich-machine-learning`, backup operates on stock stores/volumes, observability scrapes stock telemetry ports and wraps (not modifies) the stock startup check, onboarding uses stock CLI/API import paths, external-library exceptions mount customer data `:ro`. Customizations minimal + reversible so the stock single-codebase upgrade path survives (CON-001, R-05).

---

## Evidence backing (provenance)

Every gate traces to first-party Immich docs under `input/systems/immich/`, carried through the D1–D6 runs. The **R-04 documentation-confidence caveat applies throughout** — as-is facts rest on documented intent, not code inspection or telemetry; load-bearing assumptions (HA, throughput, migration duration, scan bounds) are explicit gaps, not silent assumptions.

- Availability / store HA → BASELINE §3.3; R-01; OQ#1; D3 nfr-analysis §A. · ML throughput/sizing → BASELINE §3.1/§3.4; OQ#2; R-03; component-spec; D3 §C. · Channel security → BASELINE §1.2; contract §2; R-06; OQ#3; NFR-006. · Media/backup → BASELINE §3.3/§3.4; ADR-005; D3 §D. · Upgrade/migrations → BASELINE §3.3/§1.4; R-05; CON-001; D3 §B. · Identity → BASELINE §1.6; ADR-006; D4 run. · Observability → BASELINE §3.2/§6; ADR-007; D5 run. · Onboarding → BASELINE §1.4; ADR-008; D6 run.
- Fitness reviews: D3–D6 all **proceed_with_caveats**; D6 spot-checked all seven load-bearing onboarding fact groups verbatim with zero discrepancies (`logs/2026-07-12-immich-library-onboarding-fitness-review.md`).

---

## Risks (link out to `risk-register.md`, R-01…R-12)

- **R-01** (critical, mitigating) — stores no HA → E-01/ADR-003; failover-drill gate. · **R-03** (high, mitigating) — ML throughput unquantified → E-02/ADR-004 + benchmark gate. · **R-06** (high, mitigating) — unsecured 3003 channel carries photos → E-02 hardening, before-pilot gate. · **R-09** (medium, mitigating) — external-library quota exemption, contained by ADR-008 B-exception-only. · **R-10** (high, mitigating) — B-exception data loss (path-removal deletes; `:ro` sole barrier) → ADR-008 mandatory gates.
- **R-02** (high, open) — worker co-location contention → env-var split as hosting baseline. · **R-04** (high, open) — docs-only evidence → validate before pilot sign-off. · **R-05** (high, open) — stock upgrade path vs split/HA topology → E-04 rehearsal. · **R-07** (medium, open) — OIDC claims never re-synced → operator reconciliation runbook (ADR-006). · **R-08** (high, open) — auth lockout / OIDC-only IdP outage, container-exec-only recovery → break-glass runbook (ADR-006). · **R-11** (medium, open) — staging-ingest operational dependency, no first-party guide → E-06 procedure + staging capacity in E-03. · **R-12** (medium, open) — nightly scan recurring load on B-exception instances → capacity budgeting; bounds at OQ#7.

## Open items (this handoff)

- Delivery-ready packaging withheld from `factory/` — blocked on architect approval of ADR-003…008 and a `draft → approved` status flip (factory approval gate). This handoff is the draft.
- Fitness-review coverage exists per run (D3…D6 reviews); the factory-gate review prerequisite is met on that axis — approval is the remaining blocker.
- Ownership: three interim rulings (identity, E-05, E-06) pending client confirmation — confirm before pilot kickoff (§5.2 ownership gate).
