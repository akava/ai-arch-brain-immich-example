---
title: Immich Managed-Hosting Scale-Up — D3 NFR Analysis (target-setting)
date: 2026-07-11
type: nfr-analysis
run: 2026-07-11-immich-scale-up-design
agent: nfr-analysis-agent (SKILL-004)
status: active
confidence: medium
sources:
  - input/stakeholder/2026-07-11_D3_scale-up-design-brief.md (client-stated targets, fiction)
  - logs/2026-07-11-immich-ml-media-deep-dive-nfr-analysis.md (candidates NFR-001..006, CON-001; QA-1..QA-8)
  - logs/2026-07-11-immich-scale-up-design-synthesis.md (T14/T17/T18)
  - core/2.ARCH-BASELINE.md §3.1/§3.3/§3.4 (observed values, renumbered canonical)
  - input/systems/immich/immich-faq-scaling-excerpts.md, immich-environment-variables.md, immich-backup-and-restore.md, immich-scaling-guide.md
  - risk-register.md R-01/R-03/R-05; open-question-register OQ#1/OQ#2/OQ#3
---

# Immich Managed-Hosting Scale-Up — D3 NFR Analysis (target-setting)

**Purpose:** the target-setting run the D2 analysis deferred — validate the D3 brief's six client-stated targets against first-party documented evidence, then land NFR-001..006 + CON-001 in the registry at the confidence the evidence supports.
**Verdict:** targets are **client-stated fiction**; analysis binds each figure and rules its evidential status. Two figures are **analysis-validated as feasibility-bounded** (availability mechanism, upgrade coupling — the *number* is a client choice, the *gap* is real). Four rest on numbers the docs do not contain; of these the **72h/1M ML-drain is derivable to a bound but not verifiable** (no per-asset inference time exists → figure stays [TBD] with the derived condition). Storage 50×5 TB is arithmetically clear but its **backup burden** is the real finding (T18). No target invented; every derived implication shows its arithmetic.
**Counts:** 6 NFR + 1 CON landed in CONTEXT (client figures bound, bolded); TARGET §3 subsections created: 3.1, 3.3, 3.4, 3.5. 0 new OQ, 0 new risk, 0 GLOSSARY term, 0 action-register row (2 architect to-dos noted below).
**Hand-offs:** librarian indexes this log + updates artifacts INDEX total 11→12 (main-loop). Next: decision-record-agent (HA topology, ML LB + channel hardening, upgrade procedure ADRs — the design responses framed here as capabilities are theirs to realize), integration-contract-agent (server↔ML).

**Scope note:** first-party docs only (R-04 documentation-confidence caveat applies throughout). Every per-asset/per-node ML *timing* number is confirmed ABSENT from the doc set (extraction pass over the six D3 inputs + D2 inputs). Facts already homed are cited by ID/§, not restated.

---

## Per-target analysis

Each target below: the **client figure** (D3 brief, fiction) → the **documented evidence** → **arithmetic / derived bound** (only bounds and conditions where per-job numbers are absent — no invented measurements) → **verdict + status the registry row carries**.

### A. Availability — 99.9% monthly per instance, API/serving path → NFR-001

- **Evidence:** the three stateful stores (Postgres, Redis, filesystem media) carry **no documented HA, replication, or failover** (BASELINE §3.3; R-01 critical; OQ#1). Horizontal scaling shares *one* Postgres + *one* Redis across parallel `immich-server` instances (BASELINE §3.4, T14) → the shared stores are a **single point of failure for every instance behind them** (OQ#1). Server/ML/web/CLI hold no durable state — availability risk concentrates wholly in the stores.
- **Arithmetic:** 99.9% monthly = **≤ 43.8 min/month** unavailability budget (0.001 × 30 d). Planned-upgrade downtime (target D, ≤15 min) consumes ~34% of that budget in a single monthly upgrade before *any* unplanned failure. Stock offers no mechanism to keep the budget: a single store restart/failure with no failover exceeds 43.8 min trivially.
- **Verdict — analysis-validated (mechanism gap real; figure is a client choice):** 99.9% is *not met by stock* and *cannot be assessed as feasible* on documented Immich alone — it is achievable **only** if the operator supplies HA for all three stores (external evidence, beyond this doc set — OQ#1). The 99.9% *number* is a legitimate client target; the design must add store HA to have any path to it. **Status: figure [Tentative]** (client-stated, mechanism-validated: the requirement stands, its realization is operator-supplied capability, not stock).

### B. Upgrade window — ≤15 min planned downtime per instance → NFR-002

- **Evidence:** Postgres migrations are **applied automatically at server startup** (BASELINE §3.3/§1.4); single-step revert rolls back only the latest migration; **no rolling / zero-downtime path against a shared Postgres is documented** (T11 implication). `DB_SKIP_MIGRATIONS` (default `false`) is an operator lever, **not** a documented rolling-upgrade path (BASELINE §3.3, env-vars:60). Remote-ML hosts must be **version-aligned** with the server → the ML tier upgrades in lockstep (BASELINE §1.2/§3.3, `immich-remote-machine-learning.md`). `IMMICH_VERSION` is pinnable (default `v3`) (BASELINE §6).
- **Arithmetic / derived bound:** **no migration-duration figure exists** in the docs. The ≤15 min budget is therefore a *ceiling the migration step must fit under*, unverifiable from evidence: whether a given release's migrations complete within 15 min at 5 TB/1M-asset scale is unknown (migration cost is schema-change-dependent, not asset-count-dependent, but no timing is published). The version-alignment coupling means the window must also cover ML-tier restart, not the server alone.
- **Verdict — analysis-validated (coupling real; duration unknowable):** the ≤15 min *target* is coherent, but stock provides **no evidence it is achievable** and no rolling path to shrink it; the shared-Postgres migration-at-startup model *forecloses* zero-downtime upgrade without bespoke operator machinery (R-05). **Status: figure [Tentative]** (client-stated; coupling analysis-validated). The *migration-duration-fits-15-min* sub-claim is the unverifiable part — flagged, not filled.

### C. ML onboarding — 1M assets drain ML backlog within 72 h → NFR-003

This is the target the instruction asks be tested against the FAQ heuristics. **Honest arithmetic, bounds only.**

- **Evidence available:** FAQ concurrency heuristics — **2–3 concurrent jobs max a CPU**; with a GPU concurrency **should not exceed 16 in most cases** (`immich-faq-scaling-excerpts.md:67`; BASELINE §3.1). `MACHINE_LEARNING_WORKERS` default **1** (env-vars:89); `MODEL_TTL` 300 s, request-threads = CPU cores, intra/inter-op 2/1, OCR batch 6, `DEVICE_IDS=0` (BASELINE §3.4). These are **concurrency/tuning levers, not throughput** — the heuristics measure *concurrent jobs a machine can sustain*, **not assets/sec**.
- **Evidence ABSENT (confirmed):** **no per-asset ML inference time, no assets/sec, no concurrency→throughput mapping** exists anywhere in the doc set (OQ#2 still open; R-03). Per-asset ML is also **multi-task** — Smart Search + Face Detection (remote-eligible) plus **Facial Recognition which stays server-bound** (reads Postgres; BASELINE §1.2) — so "one asset" is several inference jobs, not one.
- **Derived bound (the only honest analyzable result):**
  - Required sustained aggregate throughput = 1,000,000 / (72 × 3600 s) = **3.86 assets/sec** (≈ 13,889 assets/hour).
  - Turning the FAQ concurrency into an *implied* per-asset wall-time ceiling (throughput = concurrency ÷ per-asset-time ⇒ per-asset-time = concurrency ÷ throughput):
    - at **16 concurrent** (one GPU node, FAQ ceiling): mean per-asset inference must be **≤ ~4.15 s** to hit 3.86/sec.
    - at **2–3 concurrent** (one CPU node, FAQ ceiling): mean per-asset must be **≤ ~0.52–0.78 s** — implausibly fast for memory-intensive ONNX face+CLIP inference on CPU, so **one CPU node is almost certainly insufficient**; the target implies GPU and/or horizontal ML scale-out.
  - Because Facial Recognition is server-bound and remote-ML dispatch is **sequential-no-LB** (NFR-004 territory; T-cross to QA-5), aggregate throughput does **not** scale linearly by simply adding remote URLs without an operator LB.
- **Verdict — NOT verifiable; derivable to a condition only:** feasibility **cannot be asserted** — it hinges on the unpublished per-asset inference time. The analysis yields the *condition* the target implies (≈ ≤4.15 s/asset mean at 16-way GPU concurrency on a single node, or proportionally more nodes behind an operator LB). **Status: figure [TBD]** — the 72h/1M figure is carried as a client aspiration whose validation **requires benchmarking/telemetry beyond the doc set (OQ#2, R-03)**; the derived ≤~4.15 s/asset condition is recorded as the acceptance bound, not a claim it is met.

### D. Storage & backup — up to 5 TB media × 50 instances → NFR-005

- **Arithmetic:** 50 × 5 TB = **250 TB media** aggregate — *media only*, excluding Postgres, thumbnails, GPU-transcode output (larger than software — BASELINE §3.1/§3.4, storage-growth multiplier unquantified), and backup copies. A 3-2-1 posture (T18) implies materially more than 250 TB of provisioned storage.
- **Evidence — the real finding (T18):** backup is **DB-only-automated** (daily 02:00, keep-14, **metadata only — no photos/videos**; `immich-backup-and-restore.md:15,17`). **Media backup is not managed by Immich** — operator-supplied over `library|upload|profile` (`:42-46`), with a fixed **DB-first-then-filesystem** consistency ordering (`:62`). **No Redis-queue-state backup** is documented. Hard filesystem constraint: **NTFS/FAT unsupported**; CIFS/Samba + read-only `:ro` supported (BASELINE §3.4). No per-instance storage-sizing guidance exists.
- **Verdict — figure feasibility-clear, gap is the point:** the 5 TB×50 *number* is a straightforward capacity statement (analysis-validated). What the analysis surfaces is that **stock automates none of the 250 TB media backup** — the entire media-durability burden plus Redis durability is operator-supplied, and the DB-then-filesystem ordering is a fixed runbook rule. **Status: figure [Tentative]** (capacity clear; the requirement binds both the 5 TB/instance figure and the operator-supplied-media-backup obligation).

### E. ML channel security — authenticated + encrypted before pilot → NFR-006

- **Evidence:** remote ML sends **image previews (user photo content)** over HTTP **port 3003** with the container having **no built-in security measures**; docs warn against public/paid-cloud placement without added protection (BASELINE §1.2; OQ#3). Container does not retain/associate data with users — a data-handling fact, not a channel control.
- **Verdict — analysis-validated (control gap real, target is qualitative):** "authenticated + encrypted" is not a numeric target — it is a **control requirement** the stock channel does not meet on any managed-hosting security baseline. Feasible via operator-supplied auth + TLS/mTLS + network isolation (OQ#3). **Status: [Tentative]** — requirement stands, realization is operator-supplied; "before pilot" is a delivery gate for transition M1.

### F. Stock upgrade-path preservation (constraint) → CON-001

- **Evidence:** central engagement tension (context §Problem statement; R-05). Every operator addition (store HA per A, rolling-upgrade machinery per B, ML LB per C/NFR-004) erodes the stock single-codebase / single-startup-migration model. Version-alignment (ML↔server) and migrations-at-startup are the stock behaviours to preserve.
- **Verdict — binding constraint (not a metric):** carries no figure; it is the reversibility/minimality bound on how far A–E's operator machinery may diverge from stock. **Status: [Tentative]** (client-stated central tension; validated as the trade-off axis across NFR-001/002/004).

## Cross-target trade-offs

- **Availability ⇄ upgrade window ⇄ stock-path** (A×B×F): the 43.8 min/month budget is *shared* by planned upgrades and unplanned failures; a single ≤15 min upgrade spends ~34% of it. Buying either (store HA, rolling upgrades) adds machinery that erodes CON-001. Named at R-01/R-05.
- **ML throughput ⇄ memory ⇄ LB surface** (C): raising concurrency toward the 16 ceiling raises VRAM/OOM risk (R-03); horizontal ML scale-out to hit 3.86/sec needs an operator LB (NFR-004) whose own HA becomes a new availability surface (ties A).
- **Storage growth ⇄ transcode quality** (D): GPU transcoding inflates output size (BASELINE §3.1) → the 250 TB figure is a floor, growth-multiplier unquantified.

## Gaps (unknowable from evidence — carried, not filled)

- **Per-asset ML inference time / assets-sec** — the load-bearing unknown for NFR-003; needs benchmarking (OQ#2, R-03). NFR-003 figure stays [TBD].
- **Migration duration at 5 TB/1M-asset scale** — the load-bearing unknown for NFR-002's ≤15 min; no published figure.
- **GPU-transcode storage-growth multiplier** — bounds the true 50×5 TB provisioning; unquantified (BASELINE §3.1/§3.4).

## Architect to-dos (noted, not written to action register — AGENT-RULES §7)

- NFR-003's 72h/1M figure is [TBD] pending benchmarking (OQ#2). If the pilot cannot benchmark before commit, the target should be explicitly re-scoped or gated in transition M1.
- Decision-record-agent should record the HA topology, ML LB + channel-hardening, and upgrade-procedure decisions — the "requires X capability" design directions in TARGET §3 are theirs to turn into product/realization choices.

## Confidence

**medium** — mechanism verdicts (A, B, D-backup, E, F) rest on high-confidence first-party facts and are firm. The one *quantitative* target that can be reasoned about (C) is bounded but unverifiable (per-asset timing absent); its status honestly reflects that. R-04 documentation-only caveat applies to every as-is premise.
