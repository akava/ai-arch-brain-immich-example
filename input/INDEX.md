---
type: input_index
project: "Immich Managed-Hosting Scale-Up (simulated demo engagement)"
date_built: 2026-07-11
maintainer: librarian-agent (legacy SKILL-009)
---

# Input Index

Compact map of all files in `input/`. Agents must follow the indexed retrieval protocol — read this index first, verify count, then open only relevant files.

**Total files in input/** (excl. `.gitkeep`): **11** (incl. this `INDEX.md`)

> **Inventory check:** before using this index, run `.claude/scripts/check-indexes.sh`. On MISMATCH, run the `librarian-agent` to update this index.

## Source systems (where inputs come from)

> TODO: list the systems raw inputs are pulled from (documentation repositories, API catalogues, project management, team communication, sibling-brain artifact folders). Check off each as it is connected.

- [x] First-party product documentation: Immich docs (docs.immich.app) and repo README, filed under `systems/immich/`
- [ ] Integration / API catalogue: TBD
- [ ] Project management: TBD
- [ ] Team communication: TBD
- [ ] Sibling brain (read-only inputs): TBD

---

## Folders

| Folder | Holds |
|--------|-------|
| `reference/` | external standards, regulations, vendor and domain material |
| `systems/` | hard-fact documents on the existing estate — decks, inventories, repo/service overviews, diagrams; no talks or transcripts |
| `stakeholder/` | human accounts — briefs, internal direction, and session notes/summaries under `calls/` |
| `transitions/` | phase-bounded evidence (requirements, calls) per `Mn` transition; a closed transition's folder freezes as its evidence archive |
| `research/` | evidence-grade analysis received from outside; own exploration homes in `lab/researches/` |
| `analytics/` | telemetry, performance, and behavioural evidence |

Form decides between `systems/` and `stakeholder/`: a document that *is* the fact → `systems/`; an account of what people said → `stakeholder/`. Phase-scoped material → `transitions/<Mn>/`.

---

## Schema

| Column | Meaning |
|--------|---------|
| File | Path within `input/` |
| Category | Source folder |
| Use Case | When this input is relevant |
| Summary | ≤25 words — a pointer, not an abstract; `Keywords` carry retrieval |
| Keywords | Comma-separated search terms |

---

## Files

| File | Category | Use Case | Summary | Keywords |
|------|----------|----------|---------|----------|
| `stakeholder/2026-07-11_D1_engagement-kickoff-brief.md` | `stakeholder/` | Frames session D1 scope, client questions, and engagement arc | Simulated kickoff brief: client questions on Immich components, integrations, stack, operations, multi-node gaps; D1–D3 arc; first-party-evidence ground rule. | kickoff, D1, engagement brief, managed hosting, scale-up, session questions, simulated client |
| `stakeholder/2026-07-11_D2_ml-media-deep-dive-brief.md` | `stakeholder/` | Frames session D2 scope: ML service and media/storage pipeline deep dive | Simulated D2 brief: ML operations, storage layout, database operation questions; expected outputs ML component spec and NFR analysis; feeds OQ#2, R-03, F1/F3 follow-ups. | D2, session brief, ML deep dive, media pipeline, storage, database, component spec, NFR analysis, OQ#2, R-03, fitness follow-up |
| `systems/immich/immich-architecture-overview.md` | `systems/` | Baseline Immich runtime components, tech stack, integration points | First-party architecture doc: clients, Nest.js server, Python/ONNX ML service, Postgres, Redis/BullMQ job queues, hexagonal codebase structure. | architecture, client-server, REST, OpenAPI, Nest.js, FastAPI, ONNX, Postgres, Redis, BullMQ, background jobs |
| `systems/immich/immich-repo-readme.md` | `systems/` | Product scope and mobile/web feature coverage | Immich repo README: self-hosted photo/video platform, AGPL v3, demo instance, mobile-vs-web feature matrix, translations. | README, features, feature matrix, mobile app, web app, AGPL, demo, backup |
| `systems/immich/immich-jobs-and-workers.md` | `systems/` | Worker packaging, split-worker scaling, job pipeline behaviour | Admin doc: api and microservices workers share one container, env-var split (IMMICH_WORKERS_INCLUDE/EXCLUDE), upload-triggered job chain, scheduled nightly jobs. | jobs, workers, microservices, split workers, environment variables, scaling, scheduled jobs, thumbnail generation |
| `systems/immich/immich-ml-hardware-acceleration.md` | `systems/` | GPU acceleration options and prerequisites for the ML service | Feature doc: experimental GPU backends for Smart Search/Facial Recognition (ARM NN, CUDA, ROCm, OpenVINO, RKNN); per-backend prerequisites; multi-GPU via env vars; Linux/WSL2 only. | ML hardware acceleration, CUDA compute capability 5.2+, driver 545+, ROCm 35GiB disk, OpenVINO, ARM NN Mali, RKNN RK3588, MACHINE_LEARNING_RKNN_THREADS 2-3, MACHINE_LEARNING_DEVICE_IDS, MACHINE_LEARNING_WORKERS, multi-GPU, experimental, hwaccel.ml.yml, VRAM |
| `systems/immich/immich-hardware-transcoding.md` | `systems/` | GPU video transcoding options, limits, and setup | Feature doc: experimental GPU transcoding via NVENC/QSV/RKMPP/VAAPI; encoding-only by default; larger, lower-quality output than software; Linux/WSL2 only. | hardware transcoding, NVENC, Quick Sync, QSV, RKMPP, VAAPI, encoding-only default, two-pass NVENC-only, no VP9 on NVIDIA/AMD, RK3588 tonemapping, hwaccel.transcoding.yml, H.264, HEVC, ffmpeg accel |
| `systems/immich/immich-remote-machine-learning.md` | `systems/` | Running the ML container on a separate host; offload scope and limits | Guide: host ML container remotely; Smart Search and Face Detection offload, Facial Recognition stays server-side; no built-in security; sequential URLs, no load balancing. | remote ML, port 3003, no load balancing, sequential URLs, facial recognition not offloaded, image previews sent, no built-in security, version alignment, model-cache, external load balancer, remote-only fallback |
| `systems/immich/immich-storage-template.md` | `systems/` | On-disk asset layout rules and template configuration | Admin doc: configurable directory/filename patterns; default Year/Year-Month-Day/Filename; Handlebars variables and conditionals; server-timezone rendering; migration job applies template changes. | storage template, storage layout, Handlebars, album variable, sequence numbers, server local timezone, character escaping, Storage Template Migration job, per-user storage label, filename collisions |
| `systems/immich/immich-database-migrations.md` | `systems/` | How schema changes are generated, applied, and reverted | Developer doc: TypeScript migrations generated via mise from server/src/schema; new migrations applied automatically at server startup; single-step revert supported. | database migrations, migrations at startup, mise, generate migration, revert, server/src/schema, TypeScript, Postgres schema change |
