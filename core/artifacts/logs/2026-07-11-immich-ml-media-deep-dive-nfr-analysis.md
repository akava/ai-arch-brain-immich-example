---
title: Immich ML & Media Pipeline — D2 NFR Analysis
date: 2026-07-11
type: nfr-analysis
run: 2026-07-11-immich-ml-media-deep-dive
agent: nfr-analysis-agent (SKILL-004)
status: active
confidence: medium
sources:
  - logs/2026-07-11-immich-architecture-overview-synthesis.md
  - logs/2026-07-11-immich-ml-media-deep-dive-synthesis.md
  - component-spec-immich-machine-learning.md
  - core/2.ARCH-BASELINE.md (§1, §2, §3.4)
  - risk-register.md (R-01..R-05)
  - core/arch-processes/open-question-register.md (OQ#1..OQ#3)
---

# Immich ML & Media Pipeline — D2 NFR Analysis

**Purpose:** derive quality-attribute scenarios for Immich under the managed-hosting lens from D1+D2 evidence, so D3 target-setting starts from grounded scenarios rather than a blank page.
**Verdict:** 8 QA scenarios (QA-1..QA-8) across availability, performance/capacity, security, operability. Every scenario is **evidence-grounded but target-unset** — the docs establish behaviours, floors, and gaps, not numeric targets. No target is invented; each names the specific figure it needs and defers it to D3 with the client brief.
**Counts:** 8 scenarios; 4 attributes in scope; BASELINE §3 landed 2 new observed-value subsections (§3.1, §3.2) + 1 addition to §3.4; 7 candidate requirement rows proposed (NFR/CON) — **not written to CONTEXT** (architect-gated, this run's ruling). 0 action-register rows. 0 new OQ, 0 new risk, 0 glossary term.
**Hand-offs:** librarian indexes this log + adds the INDEX row (main-loop step). Candidate rows below await architect approval + D3 target-setting before landing in CONTEXT. No ARCH-TARGET / risk / OQ / GLOSSARY writes this run (cite-only).

**Scope note:** AS-IS QA analysis from first-party docs. Assessments are `unknown` wherever no target exists — this is the honest state, not a gap in the analysis. Facts already homed are cited by ID/§, not restated.

---

## Attributes in scope

availability · performance/capacity · security · operability. (Observability, data-residency: no D2 evidence — omitted rather than asserted.)

## Scenarios

Format: stimulus / environment / response / measure. `assessment` uses meets | at-risk | unmet | unknown; **unknown** = behaviour is evidenced but no target exists to assess against (the dominant state at D2). Each scenario states **what evidence says**, **what is missing to make it a target**, and **visible trade-offs**.

### QA-1 — Stateful-store failure takes an instance offline (availability)

- **Scenario:** a single node hosting Postgres, Redis, or the media filesystem fails / restarts under managed-hosting operation → the customer instance is unavailable until the store recovers → target uptime / RTO / RPO per instance.
- **Evidence:** three stateful stores (BASELINE §1.1/§1.2) carry **no documented HA, replication, or failover** in the first-party docs (R-01, OQ#1). Server, ML, web/CLI hold no durable server-side state — availability risk concentrates entirely in the three stores.
- **Assessment:** **unknown** — no availability target set; the *mechanism* gap (no stock HA) is a confirmed risk (R-01, critical).
- **Missing to make it a target:** per-instance uptime %, RTO, RPO from the client brief. **target TBD (D3).**
- **Trade-offs:** operator-side HA (Postgres replication, Redis persistence/HA, shared resilient media storage) adds cost and moving parts, and each added tier complicates the stock-upgrade path (QA-2, R-05). Availability bought against operability + upgrade simplicity.

### QA-2 — Startup-applied migrations gate the upgrade window (availability)

- **Scenario:** an operator upgrades an instance to a new Immich version → new Postgres migrations are **applied automatically at server startup** (BASELINE §1.4, synthesis T11) → the server is unavailable / in-migration for the duration of the migration step → tolerable upgrade-window downtime per instance.
- **Evidence:** migrations apply immediately during startup; single-step revert rolls back only the latest migration (T11). Remote-ML hosts must be **version-aligned** with the server (component-spec §Deployment modes; BASELINE §1.2, R-05) — the ML tier upgrades in lockstep. No rolling / zero-downtime migration path is documented against a shared Postgres (T11 implication).
- **Assessment:** **unknown** — no upgrade-window / migration-duration target; the coupling is confirmed, the tolerance is unset.
- **Missing to make it a target:** acceptable per-instance upgrade downtime, and whether migrations are expected to run online. **target TBD (D3).**
- **Trade-offs:** the stock single-startup-migration model is simple and matches upstream (protects R-05), but forecloses rolling multi-node upgrades without bespoke operator runbooks. Upgrade simplicity vs availability during upgrades.

### QA-3 — ML memory intensity drives node sizing / OOM risk (performance/capacity)

- **Scenario:** ML models (ONNX, **large and memory-intensive** — BASELINE §1.2, component-spec §State model) load and are cached in-process under ingest load → co-located ML contends for server memory (OOM/eviction); separated ML still cannot be capacity-planned → per-node memory headroom and safe concurrency.
- **Evidence:** models cached and reused across requests; concurrency is tunable for utilisation but **raises VRAM** (component-spec §Hardware acceleration matrix). Per-node throughput, concurrency limits, and per-model memory footprint are **unquantified** (OQ#2 still-open, R-03).
- **Assessment:** **unknown** — floors exist (QA-4), sizing numbers do not.
- **Missing to make it a target:** per-model memory footprint, safe concurrent-request count per node/GPU, throughput (assets/sec). Needs telemetry/benchmarking beyond the doc set (OQ#2). **target TBD (D3).**
- **Trade-offs:** higher ML concurrency improves node utilisation but raises VRAM and OOM risk; co-location saves a node but risks starving request serving (ties R-02, R-03).

### QA-4 — GPU hardware floors bound ML-node eligibility (performance/capacity)

- **Scenario:** an operator provisions a GPU ML node → the backend imposes a **minimum-viability floor** below which acceleration is unsupported → which hardware qualifies, and cold-start cost.
- **Evidence:** documented floors (BASELINE §3.4, synthesis T12): CUDA compute capability **5.2+** + driver **≥ 545**; ROCm **≥ 35 GiB** free disk + slow first inferences (runtime MIGraphX compile); RKNN threads **2–3** (RK3576/3588); Linux/WSL2-only, experimental. Multi-GPU via `MACHINE_LEARNING_DEVICE_IDS`/`MACHINE_LEARNING_WORKERS`.
- **Assessment:** **meets (as floors)** — these are firm minimums the operator can plan against; they are **not** throughput targets.
- **Missing to make it a target:** throughput *above* the floor (QA-3). The floors are eligibility gates, not capacity numbers. **throughput target TBD (D3).**
- **Trade-offs:** ROCm's runtime-compile trades steady-state performance for slow cold starts (matters for autoscaled/short-lived ML nodes); experimental status trades capability for stability risk.

### QA-5 — Sequential multi-URL remote ML has no stock load balancing (performance/capacity)

- **Scenario:** an operator registers multiple remote ML URLs to scale ML out → the server processes them **sequentially with no load distribution** (BASELINE §1.2, component-spec §Scaling levers) → an **external load balancer is required** to actually spread work → ML dispatch throughput and fair distribution across the tier.
- **Evidence:** multi-URL is accepted but not balanced; scale-out is an **operator-supplied capability, not a stock feature** (component-spec §Scaling levers; synthesis T9). Replacing the local URL entirely disables fallback — a failed remote requires **manual retry** via Job Status (component-spec §Interface). Facial Recognition stays **server-bound** (reads Postgres), capping how fully ML load leaves the server (component-spec §Boundaries, T9).
- **Assessment:** **unmet (mechanism)** — the stock behaviour does not distribute load; assessed against the managed-hosting scale-out intent, the gap is real. Numeric throughput target: **unknown**.
- **Missing to make it a target:** target ML-dispatch throughput and the LB behaviour (health-checking, retry) the operator must supply. **target TBD (D3).**
- **Trade-offs:** the external LB adds an operator-owned component and its own failure/HA surface (ties OQ#1, R-03); the no-fallback + manual-retry behaviour trades simplicity for availability of the ingest job chain.

### QA-6 — Encoding-only hardware transcoding shifts CPU load and inflates storage (performance/capacity)

- **Scenario:** an operator enables GPU transcoding to raise media-pipeline throughput → transcoding is **encoding-only by default**, CPU still decodes and tone-maps (BASELINE §3.4, synthesis T13) → CPU load is not eliminated and output is typically **larger / lower quality** → per-node transcode throughput and the storage-growth multiplier it implies.
- **Evidence:** encoding-only default; larger/lower-quality output than software; two-pass NVENC-only; no VP9 on NVIDIA/AMD; Linux/WSL2-only (T13, BASELINE §3.4).
- **Assessment:** **unknown** — the trade-off is documented; no throughput or storage-growth target exists.
- **Missing to make it a target:** transcode throughput/node, and the storage-growth factor from larger GPU output (feeds storage capacity planning). **target TBD (D3).**
- **Trade-offs:** GPU transcoding buys throughput at the cost of output size (storage growth) and quality, and leaves residual CPU load (decode/tone-map) — a capacity-vs-quality-vs-storage tension in one lever.

### QA-7 — Unauthenticated ML channel carries user photo previews (security)

- **Scenario:** remote ML is deployed as a separate tier → the server sends **image previews (user photo content)** to it over HTTP **port 3003** with **no built-in auth or transport protection** (BASELINE §1.2, component-spec §Security posture, OQ#3) → in a multi-tenant hosting network, user photo content is exposed on an unsecured channel → required auth / transport-encryption / network-isolation posture.
- **Evidence:** ML container "lacks built-in security measures"; docs warn against public/paid-cloud placement without added protection (OQ#3, synthesis T9). The remote container **does not retain or associate data with users** (component-spec §Security posture) — a data-handling fact, not a channel control.
- **Assessment:** **unmet (control)** — assessed against any managed-hosting security baseline, an unauthenticated cleartext channel carrying user photos is a gap; the operator must supply the controls (OQ#3).
- **Missing to make it a target:** the security requirement itself — mandated auth, transport encryption (TLS/mTLS), and network isolation for the ML channel. **control design + target TBD (D3).**
- **Trade-offs:** adding auth/TLS/isolation adds latency and operational surface to the synchronous ingest path (ties QA-5); isolation may constrain how freely the ML tier is scaled out behind the required LB.

### QA-8 — Storage-template migration is a bulk-I/O reorganisation (operability)

- **Scenario:** an operator changes the storage template (or must relabel per-tenant layout) → the **Storage Template Migration** job rewrites the existing library's on-disk paths (BASELINE §1.4, synthesis T10) → a bulk filesystem reorganisation runs against live media at library scale → tolerable migration duration / I/O impact and its effect on backup-path assumptions.
- **Evidence:** template is a mutable server-timezone Handlebars convention; changes are **not retroactive** without the migration job; sequence numbers prevent collisions (T10, BASELINE §1.4). Media paths are a **governed, mutable convention** — backup/restore path assumptions and multi-tenant per-user storage labels depend on it (T10 implication).
- **Assessment:** **unknown** — the operation is documented; no duration / throughput / I/O-budget target exists.
- **Missing to make it a target:** acceptable migration duration and I/O ceiling at library scale, and whether it may run online. **target TBD (D3).**
- **Trade-offs:** richer per-tenant templates aid operability/labelling but make any later template change a heavier bulk migration; mutable paths complicate backup/restore path stability. Operator-split levers (`IMMICH_WORKERS_INCLUDE`/`EXCLUDE`, R-02) let the migration/job load be isolated from API serving — buying API stability at the cost of an extra container to operate (QA cross-tie to R-02).

## Trade-offs (cross-scenario)

- **Availability vs upgrade simplicity vs operability** — operator-added HA (QA-1) and any rolling-upgrade path (QA-2) each erode the stock single-codebase upgrade model (R-05). More resilience = more bespoke operator machinery.
- **ML utilisation vs memory safety** — concurrency raises throughput and VRAM together (QA-3/QA-4); co-location saves nodes but risks request-serving starvation (R-02/R-03).
- **Transcode throughput vs storage + quality** — encoding-only GPU transcoding (QA-6) inflates storage and lowers quality; a single lever spans three attributes.
- **ML security vs ingest latency** — hardening the ML channel (QA-7) adds latency/surface to the synchronous dispatch path that already lacks balancing (QA-5).

## Gaps (targets needed, unknowable from evidence — all D3)

Every scenario's measure is `[TBD]` — the docs give behaviours and floors, not targets. Named figures needed, all **target TBD (D3)** with the client brief: per-instance uptime/RTO/RPO (QA-1); upgrade-window downtime (QA-2); ML per-node throughput/concurrency/per-model memory (QA-3, OQ#2); ML-dispatch throughput + LB behaviour (QA-5); transcode throughput + storage-growth factor (QA-6); ML-channel security controls (QA-7, OQ#3); storage-template-migration duration/I-O ceiling (QA-8). Resolution of QA-3/QA-5 numbers needs telemetry/benchmarking (OQ#2, R-04 documentation-confidence caveat).

## Candidate requirement rows (proposed only — NOT written to CONTEXT)

**Architect ruling for this run:** registry population is architect-gated and target-setting is D3 work with the client brief. The rows below are **statements only, targets TBD** — proposed for `core/1.ARCH-CONTEXT.md` → Requirements when the architect opens D3 population. IDs are provisional (next free is NFR-001 / CON-001; sequence to be confirmed at write time). None written this run.

| Provisional ID | Candidate essential statement (target TBD) | Driver / need | Trace | Backing |
|----------------|--------------------------------------------|---------------|-------|---------|
| NFR-001 | Each managed customer instance must meet a defined availability target (uptime %, RTO, RPO) despite stateful stores having no stock HA. | Managed-hosting commercial-availability (context §Problem statement) | QA-1, BASELINE §1.1/§1.2, §3.1 | R-01, OQ#1 |
| NFR-002 | Instance upgrades (including startup-applied Postgres migrations and version-aligned ML tier) must complete within a defined upgrade-window downtime per instance. | Preserve stock upgrade path at hosting availability (context §Problem statement) | QA-2, BASELINE §1.4, §3.1 | R-05 |
| NFR-003 | The ML tier must sustain a defined per-node inference throughput and concurrency within a defined memory footprint. | ML-throughput scale-up (context §Problem statement) | QA-3, QA-4, BASELINE §3.4 | OQ#2, R-03 |
| NFR-004 | ML scale-out across nodes must achieve a defined aggregate dispatch throughput with balanced, health-checked distribution (stock is sequential, unbalanced). | ML-throughput scale-up | QA-5, BASELINE §1.2 | R-03, OQ#1 |
| NFR-005 | The media transcoding pipeline must meet a defined throughput target within a defined storage-growth budget. | Storage-growth + media-pipeline capacity (context §Problem statement) | QA-6, BASELINE §3.2, §3.4 | — |
| NFR-006 | The remote-ML channel carrying user photo previews must enforce authentication, transport encryption, and network isolation to a defined baseline. | Managed-hosting security posture | QA-7, BASELINE §1.2 | OQ#3 |
| CON-001 | Scale-up topology must preserve Immich's stock upgrade path / single-codebase deployment model (operator customizations minimal and reversible). | Central engagement tension (context §Problem statement) | QA-2, QA-8 | R-05 |

An operability requirement for the storage-template-migration operation (QA-8) is a **candidate but not tabled** as a distinct row — it is captured under CON-001 (upgrade/operability preservation) and QA-8; the architect may split it out at D3 if the client brief warrants a standalone operability target.

## Landed this run — BASELINE §3

Only genuinely stated observed values, coordinated with existing §3.4 (no duplication): §3.4 already holds the ML hardware floors + the encoding-only transcoding trade-off — left intact. Added:
- **§3.1 Availability & Resilience** — the observed *absence* of documented HA/failover for the three stateful stores, and the startup-applied-migration upgrade-window coupling. Anchored to R-01/R-05/OQ#1, pending NFR-001/NFR-002.
- **§3.2 Performance & Throughput** — the observed encoding-only transcoding CPU-residual + larger-output behaviour as a *performance/storage* observed value (distinct from the §3.4 capacity-floor framing), cross-referenced not duplicated.

## Architect to-do (noted, not written to action register)

- Open CONTEXT requirements-registry population for D3 and rule on the provisional ID sequence (NFR-001.. / CON-001..) before these candidate rows are written.
- D3 target-setting for all QA measures above requires the client brief (uptime/RTO/RPO, throughput, storage budget, security baseline).

## Confidence

**medium** — scenarios rest on high-confidence first-party docs, but every *target* is absent and every ML/transcode capacity number is unquantified (OQ#2); the R-04 documentation-only caveat applies. The analysis is as firm as the evidence; the assessments are honestly `unknown` where no target exists.
