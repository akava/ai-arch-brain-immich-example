---
title: M1 — Managed-Hosting Pilot
type: arch-transition
milestone: M1
status: active
confidence: low — design directions are proposed-ADR-backed, not approved; the load-bearing throughput figure NFR-003 is [TBD] (unmeasured). Mechanisms validated; commitments and sizing pending.
---

# M1 — Managed-Hosting Pilot

> **Simulated demonstration engagement.** The engagement, client, and all pilot figures are fiction created to exercise this repository's operating model (`core/1.ARCH-CONTEXT.md` → Engagement); run outputs are unreviewed AI drafts. The subject system (Immich) and its documented behaviour are real, drawn only from first-party docs under `input/`.

The delivery-phase view (`core/0.ARCH-METAMODEL.md` → Transitions): how this milestone moves the architecture from `core/2.ARCH-BASELINE.md` toward `core/3.ARCH-TARGET.md`. Tracked items are referenced by ID, never restated here.

## Goal

Stand up the managed-hosting pilot for **up to 50 isolated single-tenant Immich instances**, proving the **operator-side capabilities that wrap stock Immich** — per-instance store HA, a hardened scalable ML tier, media storage & backup, a bounded-window upgrade procedure, fleet observability & health, and a customer onboarding pipeline — while keeping the stock upgrade path and single-codebase deployment model intact (`CON-001`). The milestone's vision slice is the client-stated pilot shape (`core/1.ARCH-CONTEXT.md` → Goals, client-stated fiction); its enabler package is `E-01`…`E-06` below (`core/transitions/ENABLER-CATALOG.md`).

The pilot proves operability *around* stock Immich — it does not modify the stock containers. Immich is documented for single-node self-hosting; the operator capabilities are the layer the upstream docs do not provide.

## Scope & work streams

Each stream is tracked in `core/` by the cited IDs; this file is the phase view over them, not a second registry.

| WS | Scope | Realizes | Tracked in `core/` |
|----|-------|----------|--------------------|
| **WS1 — Store HA** | Per-instance operator-managed HA for Postgres and Redis, endpoint-transparent to the stock containers; shared cross-instance store pools rejected for blast radius. Media store protection handled by WS3. | `E-01` / NFR-001 | ADR-003 (proposed); R-01; OQ#1; TARGET §3.3; BASELINE §3.3 |
| **WS2 — ML tier** | Dedicated remote-ML tier behind an operator-run, health-checked **load balancer**; **channel hardening** (auth + TLS at a reverse proxy fronting port 3003, network isolation); **benchmark** of per-asset inference time to size the tier and decide the NFR-003 commitment. Facial Recognition stays server-bound, out of scope. | `E-02` / NFR-003, NFR-004, NFR-006 | ADR-004 (proposed); R-03, R-06; AI-001; OQ#2, OQ#3; TARGET §3.1/§3.5; BASELINE §3.1 |
| **WS3 — Media storage & backup** | Per-instance dedicated media volumes on supported (non-NTFS/FAT) filesystems; operator snapshot + off-instance replication backup honoring the documented **DB-first-then-filesystem** ordering; stock DB dumps retained and copied off-instance; Redis-queue-state durability. | `E-03` / NFR-005 | ADR-005 (proposed); R-01 (Redis via ADR-003); TARGET §3.4/§3.3; BASELINE §3.4/§3.3 |
| **WS4 — Upgrade procedure** | A controlled maintenance-window upgrade covering server + startup Postgres migrations + version-aligned ML restart, rehearsed within NFR-002's **≤15 min** window; operator customizations kept minimal and reversible to preserve the stock upgrade path. | `E-04` / NFR-002, CON-001 | R-05; CON-001; TARGET §3.3; BASELINE §3.3 |
| **WS5 — Fleet observability & health** | An operator-run **central observability plane** over the 50 stock instances: fleet-wide telemetry (opt-in, enabled as a config baseline), Prometheus-compatible scrape of every instance's **8081/8082**; central **log shipping + defined retention** of the JSON stream; operator-built **synthetic health probes + container healthchecks** over the stock `.immich` startup gate; **alerting tied to NFR-001's error budget**; per-instance data **segregated** (ADR-003). Front-door proxy `600s`/`50000M` (T26) monitored as thresholds. End-to-end tracing out of scope (docs: metrics-export only). | `E-05` / NFR-001 | ADR-007 (proposed); R-01, R-08; OQ#5; TARGET §3.2; BASELINE §3.2 |
| **WS6 — Customer onboarding pipeline** | The operator procedure that ingests a customer's existing library into a managed instance — the **ingest-and-map** step the missing first-party migration guide leaves undocumented (source discovery → format normalization → CLI ingest → dedup/verification, OQ#6). Runs the chosen mode per ADR-008: **staged operator-driven CLI ingest** as the pilot default (customer data → operator **staging volume** → `immich upload` into the instance → **retire staging**), **direct CLI upload** for small libraries, and an **external-library opt-in exception** gated on a `:ro` mount + **signed-off import-path config**. Default is quota-counted + storage-template-governed (single storage class, ties WS3/E-03 for staging capacity + the second-class exception); the operator-side `--concurrency` **arrival-rate lever** shapes the ML-backlog arrival profile (ties WS2/E-02). | `E-06` / NFR-003, NFR-005 | ADR-008 (proposed); R-09; OQ#6, OQ#7; AI-001; BASELINE §1.4; TARGET §1.4/§1.5 |

## Baseline → target deltas (enabler-shaped)

Keyed by the shared skeleton (`core/0.ARCH-METAMODEL.md`): baseline §N → target §N. One row per enabler; each acceptance criterion is the pilot gate already recorded against its ADR / NFR. Full statement, benefit, and acceptance detail live once here (build detail); the catalog links in.

### E-01 — Per-instance store HA · §3.3 → §3.3

- **Type:** infrastructure
- **Delta:** stock offers no HA path for the three stateful stores (§3.3); the pilot adds operator-managed per-instance HA Postgres/Redis, endpoint-transparent to the untouched stock containers.
- **Benefit hypothesis:** brings each instance's API/serving path within NFR-001's ≤ 43.8 min/month unavailability budget, which stock alone cannot meet (R-01, OQ#1).
- **Acceptance criteria (pilot gate):** a **failover drill** demonstrating store failover within the availability budget (ADR-003 pilot gate). *Media store protection is E-03, not this gate.*

### E-02 — Hardened scalable ML tier · §3.1 → §3.1 (+ channel §3.5)

- **Type:** architectural + infrastructure (with an exploration lead: the benchmark)
- **Delta:** stock multi-URL ML dispatch is sequential with no load balancing (§3.1) and the port-3003 channel has no built-in security (§3.5/§1.2); the pilot adds an operator-run health-checked LB fronting a dedicated ML tier and terminates auth + TLS at a reverse proxy on an isolated segment.
- **Benefit hypothesis:** balanced, health-checked dispatch reaches the NFR-003/004 aggregate throughput, and the hardened channel lets the ML tier carry real user photo previews safely (NFR-006, R-03, R-06).
- **Acceptance criteria (pilot gates):** (a) the **NFR-003 benchmark gate** — measured per-asset inference time sizing tier `N` and deciding the go/no-go on the 72 h / 1M commitment (AI-001, OQ#2); (b) the **secured channel** in place before the tier carries real content (NFR-006 "before pilot", OQ#3). *NFR-003's 72 h figure stays **[TBD]** until (a) is measured — the enabler is delivered against a benchmarked, not assumed, target.*

### E-03 — Media storage & backup capability · §3.4 → §3.4 (+ backup §3.3)

- **Type:** infrastructure
- **Delta:** Immich automates DB-only backup (metadata, no media) and NTFS/FAT are unsupported (§3.3/§3.4); the pilot adds per-instance media volumes on supported filesystems with operator-supplied media backup, plus Redis-queue-state durability.
- **Benefit hypothesis:** provisions ≥ 250 TB aggregate (5 TB × 50) with recoverable media and queue state, closing the operator-supplied-media-backup gap NFR-005 names (T18).
- **Acceptance criteria (pilot gate):** a **restore rehearsal** that recovers an instance honoring the documented **DB-first-then-filesystem** consistency ordering (ADR-005). Transcode storage-growth headroom % stays [TBD] until telemetry exists.

### E-04 — Bounded-window upgrade procedure · §3.3 → §3.3

- **Type:** architectural
- **Delta:** migrations apply at server startup and the ML tier is version-aligned, with no stock rolling/zero-downtime path (§3.3); the pilot establishes an upgrade procedure over the split/HA topology, kept minimal and reversible per CON-001.
- **Benefit hypothesis:** upgrades complete within NFR-002's window without breaking customized instances, preserving the stock upgrade path (R-05, CON-001). Note the co-constraint: a ≤15 min upgrade spends ~34% of the NFR-001 monthly budget.
- **Acceptance criteria (pilot gate):** a **≤ 15-min upgrade rehearsal** on a split/HA instance, with migration duration measured at pilot scale (NFR-002; the fits-window sub-claim is unverifiable from evidence until measured — R-05).

### E-05 — Fleet observability & health · §3.2 → §3.2

- **Type:** infrastructure
- **Delta:** stock ships observability *primitives without a control plane* (§3.2) — opt-in 8081/8082 metrics, env-var-only JSON logging with no routing/retention/alerting, and a one-shot `.immich` startup marker-file check as the only health mechanism (no container-healthcheck guidance, OQ#5); the pilot adds an operator-run central fleet observability plane: fleet-wide-enabled scrape, central log shipping + retention, operator-built health/readiness probes + container healthchecks, and NFR-001-error-budget-tied alerting, with per-instance data segregated (ADR-003 isolated-instance alignment).
- **Benefit hypothesis:** provides the proactive, budget-tied detection layer NFR-001 depends on across 50 instances — you cannot hold 99.9% you cannot observe (T24–T27, OQ#5); reactive complaint-driven detection (option A) cannot evidence the budget.
- **Acceptance criteria (pilot gate):** an **induced instance failure raises an alert within the pilot detection window** — window **[TBD]** (no first-party figure to inherit; set at this gate), and every pilot instance carries an operator container health/readiness probe wired to alerting with telemetry enabled on both 8081/8082. *Log routing/retention is decided by ADR-007; the container-health probe design remains build work within this WS.*

### E-06 — Customer onboarding pipeline · §1.4 → §1.4 (+ coexistence §1.5)

- **Type:** infrastructure (operator procedure) + architectural (mode-selection rule)
- **Delta:** Immich documents three import paths and **no migration/bulk-import guide** (§1.4) — customer-arrival formats are undocumented (OQ#6); the pilot adds an operator **customer onboarding pipeline** that ingests each customer's existing library, defaulting to **staged operator-driven CLI ingest** (customer data → operator staging volume → `immich upload` → retire staging), with **direct CLI upload** for small libraries and an **external-library opt-in exception** (`:ro` + signed-off import-path config only). Default ingest is quota-counted and storage-template-governed (single storage class); external-library ingest, when taken, adds the second in-place storage class E-03 must back up (T31).
- **Benefit hypothesis:** gives managed hosting a repeatable onboarding for multi-hundred-GB-to-TB libraries with **no stock migration feature**, preserving NFR-005 quota accounting on the default path (R-09 exposure confined to the B exception) and holding the ML-backlog **arrival rate operator-side** via `--concurrency` (T30 — the one lever over the NFR-003 arrival profile; onboarding mode does not change the backlog physics, both modes feed the same scan-triggered thumbnail→ML chain).
- **Acceptance criteria (pilot gate):** a **rehearsed onboarding of a representative multi-hundred-GB library completing without manual intervention** via the staged-ingest path (staging → operator CLI upload → retire staging), with the **ML backlog drained per the NFR-003 disposition** — the drain figure stays **[TBD] pending AI-001** (per-asset benchmark; the 72 h / 1M figure is not committed). *Every external-library (exception) onboarding carries a `:ro` mount and a signed-off import-path config before scan.*

### Gap discipline (§ reviewed, no delta — carried over)

Skeleton sections this milestone reviewed but does not move, recorded not omitted (`core/0.ARCH-METAMODEL.md`, TOGAF gap analysis):

- **§1.1–§1.6, §2** — reference architecture, building blocks, and tech stack: stock Immich carries over unchanged (CON-001); no target delta. §1.2 is touched only as the location of the ML-channel fact E-02 hardens.
- **§4 (Interface & Contract Conventions)** — not populated in TARGET; no phase delta. Carried over.
- **§6 (Deployment & Environments)** — per-instance rollout staging (below) is phase sequencing, not a TARGET §6 rule; §6 itself carries over.
- **§7** — pointer section only.

## Coexistence approach

- **Stock containers untouched** (`CON-001`): the operator capabilities (`E-01`…`E-06`) **wrap around** stock Immich — HA endpoints are transparent to the stock containers, the LB/proxy front stock `immich-machine-learning`, backup operates on the stock stores/volumes, and onboarding drives stock import paths (CLI/API) via the operator staging procedure. No stock modification; customizations minimal and reversible so the stock upgrade path survives (§1.5, §5 when populated carry the coexistence/gating realization).
- **Per-instance rollout staging:** instances are brought onto the operator capabilities one at a time — each instance's HA, ML-tier binding, backup, and upgrade rehearsal validated on that instance before the next — bounding blast radius during the pilot (up to 50 instances).

## Binding gates

Design work in this phase passes the gates in `core/3.ARCH-TARGET.md` §5 (`core/AGENT-RULES.md` §9 → binding gates apply to design work):

- **§5 delivery & operating constraints** — the release/change/window gates the design must fit. *Watch:* TARGET §5 is a TODO stub (unpopulated); the constraints binding this pilot are carried by the requirement/constraint rows (`NFR-`/`CON-`) and their §3 responses until §5 is populated. Flagged in Open / watch.
- **§5.2 ownership gate** — no design without a clear accountable owner. Satisfied at role granularity via `core/arch-processes/ownership-map.md`: **Hosting Platform Lead** (store HA — WS1/E-01), **ML Platform Owner** (ML tier + channel — WS2/E-02), **Immich Runtime Owner** (upgrades — WS4/E-04). WS3 media/backup falls under the Hosting Platform Lead's stateful-store operability scope. Roles are client-confirmed at role level (demo fiction); name-level confirmation is out of scope for the simulated engagement.

## Open / watch

Referenced by ID; the Delivery Enablement stream (`core/arch-processes/work-streams/delivery-enablement.md`) owns chasing these.

- **AI-001** — decide the NFR-003 disposition (run the ML per-asset benchmark before committing the 72 h / 1M figure, or re-scope/gate it in M1). Gates the E-02 benchmark acceptance criterion. Checkpoint 2026-07-18.
- **OQ#1** — multi-node HA/failover path for the shared stores still absent (store HA design + sizing need evidence beyond the doc set). Gates E-01.
- **OQ#2** — per-node/per-GPU ML throughput in assets/sec still unquantified; the NFR-003 figure is unmeasurable from evidence. Gates E-02's benchmark.
- **OQ#3** — remote-ML channel security remnant: operator must supply auth / transport encryption / network isolation the docs do not specify. Gates E-02's channel hardening.
- **OQ#5 (partially resolved by ADR-007)** — log routing/retention and container-health are operator-built with no first-party guidance. ADR-007 **decides the log-routing/retention half** (central shipping + defined retention); the **container-health/readiness probe design and the detection-window figure remain [TBD] build work** in WS5/E-05. Gates E-05.
- **OQ#6** — no first-party migration/bulk-import guide; customer-arrival formats (platform takeouts, other photo apps, prior layouts) are undocumented → the operator ingest-and-map procedure is undelivered build work in WS6/E-06 (formats not invented — ADR-008). Gates E-06.
- **OQ#7** — external-library watch/scan behaviour has no documented bounds at multi-TB scale (nightly-scan duration, watch viability on a network-attached tier, inotify ceiling at 5 TB). Bears on any external-library (B) exception onboarding and ties E-03's storage design. Watched under WS6/E-06.
- **Proposed ADRs awaiting approval** — ADR-003, ADR-004, ADR-005, ADR-007, ADR-008 are all `proposed` (ADR-006 covers identity, tracked at TARGET §3.5). The deltas above are written at `[Tentative]` confidence against them; the `active` → `delivered` flip and any baseline promotion are the architect's explicit call on approval (`core/AGENT-RULES.md` §9).
- **TARGET §5 unpopulated** — the binding-gate section is a stub; populating it is architect-approved content work (watch, not an M1 deliverable).

## Low-level design

The teams' per-feature build-approval (permit-to-build) artefacts are the low-level design for `E-01`…`E-06`; they live with the delivery teams and are referenced here, not stored (`core/transitions/README.md` → HLA here, LLD with the teams). None registered yet.
