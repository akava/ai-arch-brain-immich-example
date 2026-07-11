---
title: Immich ML & Media Pipeline — D2 Deep-Dive Synthesis
date: 2026-07-11
type: synthesis
run: 2026-07-11-immich-ml-media-deep-dive
skill: synthesis-agent (SKILL-001)
status: active
confidence: high
---

# Immich ML & Media Pipeline — D2 Deep-Dive Synthesis

**Purpose:** answer the five D2 questions (ML operations, storage/media layout, DB operation, documented capacity, as-built decisions) from five new first-party Immich docs; deepen the as-is baseline. Delta on the D1 synthesis — new facts only, no restatement.
**Verdict:** all five questions answerable from evidence. ML runs remotely as a separate tier with a **partial** offload (Facial Recognition stays server-bound), **no load balancing** across sequential URLs, and **no built-in security** on the remote channel. Storage layout is a configurable server-timezone Handlebars template; schema migrations apply automatically at server startup. GPU acceleration (ML + transcoding) is experimental, Linux/WSL2-only, with documented hardware **floors** — but per-node throughput stays unquantified.
**Counts:** 5 themes (T9–T13, continuing the D1 sequence); 0 conflicts; 6 glossary terms added (`tentative`); OQ#2 partially answered (updated in place); 1 new OQ (OQ#3, remote-ML security) added under pre-approval; 0 action-register rows.
**Hand-offs:** librarian indexes this log + adds the INDEX row; landings await architect review before layer writes (already applied to BASELINE §1.2/§1.4/§2/§3.4 per this run's brief); next in chain = component-spec-agent (ML service spec) and nfr-analysis-agent (documented QAs).

## Sources

- `input/stakeholder/2026-07-11_D2_ml-media-deep-dive-brief.md` — the five session questions, expected outputs, ground rules.
- `input/systems/immich/immich-ml-hardware-acceleration.md` — GPU backends, prerequisites, hardware floors, multi-GPU env vars.
- `input/systems/immich/immich-hardware-transcoding.md` — GPU transcoding backends, encoding-only default, codec/quality limits.
- `input/systems/immich/immich-remote-machine-learning.md` — remote ML deployment, offload scope, sequential-URL/no-LB, security posture.
- `input/systems/immich/immich-storage-template.md` — on-disk layout, Handlebars template, migration job.
- `input/systems/immich/immich-database-migrations.md` — TypeScript migrations, startup application, single-step revert.

**Excluded:** the four D1 inputs (already processed in the D1 synthesis; re-cited by ID/§ where needed). `input/INDEX.md` (11) and `core/artifacts/INDEX.md` (6) counts verified OK.
**Pending inputs:** none.
**Confidence:** high — every theme rests on first-party product documentation; the residual gaps (ML throughput, remote-ML security controls) are explicit silences, not weak sources.

## Themes

### T9 — Remote ML as a separate tier with a partial, unbalanced, unsecured offload
- **Evidence:** ML container runs on a separate host over HTTP port 3003; server sends image previews to it (`immich-remote-machine-learning.md:11,36`). Smart Search and Face Detection offload; **Facial Recognition does not** — it reads model outputs from Postgres (server-to-database) (`:15`). Multiple URLs processed **sequentially, no load distribution**; external load balancer needed to spread work (`:53`). Container **lacks built-in security**; warns against public/paid-cloud placement (`:19`). Version alignment required (`:47`).
- **Implications:** ML is confirmed as the independent scaling/hardware-sizing unit — but scaling it out is not turnkey: sequential URLs mean the operator must front an external LB, and the channel carries user photo content with no auth/transport protection the docs supply. Facial Recognition's DB-bound step caps how fully ML load leaves the server.
- **Lands in:** ARCH-BASELINE §1.2.
- **Open questions:** OQ#3 (remote-ML channel security — new).

### T10 — Storage template governs on-disk media layout, server-timezone, migration-applied
- **Evidence:** configurable Handlebars pattern (`{{y}}`, `{{MM}}`, `{{album}}`, `{{filename}}` + conditionals); default `Year/Year-Month-Day/Filename.Extension` (`immich-storage-template.md:15-17,21,37-39`). Rendered in **server local timezone**; sequence numbers prevent collisions; most-recent album fills `{{album}}` (`:23,21,25`). **Storage Template Migration** job applies template changes to the existing library (`:43`).
- **Implications:** media file paths are a governed, mutable convention, not fixed — relevant to backup/restore path assumptions and to multi-tenant per-user storage labels. Timezone and collision handling are operator-visible behaviours.
- **Lands in:** ARCH-BASELINE §1.4.
- **Open questions:** none.

### T11 — Schema migrations apply automatically at server startup
- **Evidence:** TypeScript migrations generated via `mise` from `server/src/schema`; new migrations **applied immediately during startup**; single-step revert rolls back the latest migration (`immich-database-migrations.md:16,23,30-33`).
- **Implications:** DB schema evolution is coupled to the server-container lifecycle — a startup-time step. Material to the stock-upgrade-path tension (R-05): a rolling/multi-node upgrade must reckon with startup-applied migrations against a shared Postgres. No direct-DB-access or extension posture is documented (an evidence gap, not asserted).
- **Lands in:** ARCH-BASELINE §1.4.
- **Open questions:** none (direct-access/extension posture noted as undocumented, not raised as a formal OQ this run).

### T12 — ML hardware acceleration: five experimental GPU backends with documented floors
- **Evidence:** Smart Search + Facial Recognition GPU-acceleratable via ARM NN / CUDA / ROCm / OpenVINO / RKNN; `hwaccel.ml.yml`; Linux/WSL2 only; experimental (`immich-ml-hardware-acceleration.md:9,13-17,22,65`). Floors: CUDA compute capability 5.2+, driver ≥ 545 (`:36,38`); ROCm ≥ 35 GiB disk + slow first inferences (`:44,46`); RKNN threads 2–3 for RK3576/RK3588 (`:61`). Multi-GPU via `MACHINE_LEARNING_DEVICE_IDS` + `MACHINE_LEARNING_WORKERS` (`:85`).
- **Implications:** hardware *floors* now exist to plan ML nodes, but throughput/concurrency/per-model memory remain unquantified — partial answer to OQ#2, not a close.
- **Lands in:** ARCH-BASELINE §2 (options) + §3.4 (observed hardware floors).
- **Open questions:** OQ#2 (partially answered — throughput still open).

### T13 — Hardware transcoding: encoding-only, larger/lower-quality, codec-limited
- **Evidence:** GPU transcoding via NVENC / Quick Sync / RKMPP / VAAPI; `hwaccel.transcoding.yml`; Linux/WSL2 only (WSL2 no Quick Sync; Pi unsupported) (`immich-hardware-transcoding.md:17-20,25-27,55`). **Encoding-only by default** (CPU decodes + tone-maps) (`:29`); typically **larger, lower-quality** than software (`:11`); two-pass NVENC-only (`:28`); no VP9 on NVIDIA/AMD (`:31`).
- **Implications:** GPU transcoding trades output size/quality for throughput and is not a free win — a capacity-vs-quality tradeoff for the media pipeline, and a QA fact for storage-growth planning.
- **Lands in:** ARCH-BASELINE §2 (options) + §3.4 (observed tradeoff).
- **Open questions:** none.

## Glossary updates

6 terms added as `tentative` (first-party-doc sourced, single session): remote machine learning, storage template, Storage Template Migration (job), hardware transcoding, ML hardware acceleration. Face Detection (offloadable inference step) vs Facial Recognition (DB-bound clustering step) captured inside the remote-ML term definition — a clean documented distinction, not an ambiguity, so no `ambiguous` row raised. See `core/GLOSSARY.md`.

**Terms flagged (ambiguous):** none.

## Register proposals

**Open-question register:**
- **OQ#2** — updated in place (partial-answer convention): hardware floors now documented (BASELINE §3.4); per-node throughput/concurrency/memory still open.
- **OQ#3 (new, pre-approved)** — remote-ML channel has no built-in security or transport protection; server sends image previews (user photo content) over port 3003 with no auth, operator must supply controls. Material to managed-hosting security posture; candidate risk-register/NFR follow-up.

**Action register:** 0 rows. No D2 item passes the triage gate — discovery facts and open questions, not architect-owned brain-improving actions.

## Recommended next agents

- `component-spec-agent` — the ML-service component spec (D2 expected output; living artifact).
- `nfr-analysis-agent` — analyse the documented ML/media QAs (hardware floors, transcoding tradeoff) and the OQ#3 security gap.
- `risk-assessment-agent` — consider OQ#3 as a new remote-ML-security risk row.
- `librarian-agent` — index this run log (main-loop step).
