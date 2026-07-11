---
type: input_index
project: "Immich Managed-Hosting Scale-Up (simulated demo engagement)"
date_built: 2026-07-11
maintainer: librarian-agent (legacy SKILL-009)
---

# Input Index

Compact map of all files in `input/`. Agents must follow the indexed retrieval protocol — read this index first, verify count, then open only relevant files.

**Total files in input/** (excl. `.gitkeep`): **18** (incl. this `INDEX.md`)

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
| `stakeholder/2026-07-11_D3_scale-up-design-brief.md` | `stakeholder/` | Frames session D3 scope: scale-up design targets, ownership, expected outputs | Simulated D3 brief: fictional pilot targets — 50 instances, 5 TB media each, 99.9% availability, ≤15 min upgrade downtime, 1M-asset ML backlog in 72h; role-level owners. | D3, design session, pilot targets, 50 instances, 5TB, 99.9% availability, 15-minute upgrade window, 1M assets 72 hours, ML auth encryption, ownership, transition M1, enablers |
| `systems/immich/immich-architecture-overview.md` | `systems/` | Baseline Immich runtime components, tech stack, integration points | First-party architecture doc: clients, Nest.js server, Python/ONNX ML service, Postgres, Redis/BullMQ job queues, hexagonal codebase structure. | architecture, client-server, REST, OpenAPI, Nest.js, FastAPI, ONNX, Postgres, Redis, BullMQ, background jobs |
| `systems/immich/immich-repo-readme.md` | `systems/` | Product scope and mobile/web feature coverage | Immich repo README: self-hosted photo/video platform, AGPL v3, demo instance, mobile-vs-web feature matrix, translations. | README, features, feature matrix, mobile app, web app, AGPL, demo, backup |
| `systems/immich/immich-jobs-and-workers.md` | `systems/` | Worker packaging, split-worker scaling, job pipeline behaviour | Admin doc: api and microservices workers share one container, env-var split (IMMICH_WORKERS_INCLUDE/EXCLUDE), upload-triggered job chain, scheduled nightly jobs. | jobs, workers, microservices, split workers, environment variables, scaling, scheduled jobs, thumbnail generation |
| `systems/immich/immich-ml-hardware-acceleration.md` | `systems/` | GPU acceleration options and prerequisites for the ML service | Feature doc: experimental GPU backends for Smart Search/Facial Recognition (ARM NN, CUDA, ROCm, OpenVINO, RKNN); per-backend prerequisites; multi-GPU via env vars; Linux/WSL2 only. | ML hardware acceleration, CUDA compute capability 5.2+, driver 545+, ROCm 35GiB disk, OpenVINO, ARM NN Mali, RKNN RK3588, MACHINE_LEARNING_RKNN_THREADS 2-3, MACHINE_LEARNING_DEVICE_IDS, MACHINE_LEARNING_WORKERS, multi-GPU, experimental, hwaccel.ml.yml, VRAM |
| `systems/immich/immich-hardware-transcoding.md` | `systems/` | GPU video transcoding options, limits, and setup | Feature doc: experimental GPU transcoding via NVENC/QSV/RKMPP/VAAPI; encoding-only by default; larger, lower-quality output than software; Linux/WSL2 only. | hardware transcoding, NVENC, Quick Sync, QSV, RKMPP, VAAPI, encoding-only default, two-pass NVENC-only, no VP9 on NVIDIA/AMD, RK3588 tonemapping, hwaccel.transcoding.yml, H.264, HEVC, ffmpeg accel |
| `systems/immich/immich-remote-machine-learning.md` | `systems/` | Running the ML container on a separate host; offload scope and limits | Guide: host ML container remotely; Smart Search and Face Detection offload, Facial Recognition stays server-side; no built-in security; sequential URLs, no load balancing. | remote ML, port 3003, no load balancing, sequential URLs, facial recognition not offloaded, image previews sent, no built-in security, version alignment, model-cache, external load balancer, remote-only fallback |
| `systems/immich/immich-storage-template.md` | `systems/` | On-disk asset layout rules and template configuration | Admin doc: configurable directory/filename patterns; default Year/Year-Month-Day/Filename; Handlebars variables and conditionals; server-timezone rendering; migration job applies template changes. | storage template, storage layout, Handlebars, album variable, sequence numbers, server local timezone, character escaping, Storage Template Migration job, per-user storage label, filename collisions |
| `systems/immich/immich-database-migrations.md` | `systems/` | How schema changes are generated, applied, and reverted | Developer doc: TypeScript migrations generated via mise from server/src/schema; new migrations applied automatically at server startup; single-step revert supported. | database migrations, migrations at startup, mise, generate migration, revert, server/src/schema, TypeScript, Postgres schema change |
| `systems/immich/immich-scaling-guide.md` | `systems/` | First-party horizontal scaling guidance and its limits | Official scaling guide: parallel immich-server instances need shared Postgres, Redis, and identical file mounts; single-machine scaling discouraged; no environment-specific instructions given. | scaling, horizontal scaling, multiple instances, shared Postgres, shared Redis, shared filesystem, NFS, Kubernetes replicas, disable API worker, scale down, jobs queue, no specific instructions |
| `systems/immich/immich-environment-variables.md` | `systems/` | Deployment configuration surface for server, workers, DB, Redis, ML | Env-var tables: worker include/exclude split; DB/Redis vars required by all workers; ML tuning — MACHINE_LEARNING_WORKERS default 1, model TTL 300s, batch sizes. | environment variables, IMMICH_WORKERS_INCLUDE, IMMICH_WORKERS_EXCLUDE, DB_URL, DB_VECTOR_EXTENSION, DB_SKIP_MIGRATIONS, REDIS_URL, MACHINE_LEARNING_WORKERS 1, MODEL_TTL 300, REQUEST_THREADS, DEVICE_IDS, OCR batch 6, IMMICH_VERSION v3, UPLOAD_LOCATION, CPU_CORES |
| `systems/immich/immich-docker-compose.md` | `systems/` | Reference (recommended) production deployment procedure | Install doc: three-step Docker Compose install; .env keys UPLOAD_LOCATION, DB_PASSWORD (A-Za-z0-9 only), TZ, IMMICH_VERSION pinnable; Docker Engine v25 start_interval caveat. | docker compose, recommended install, .env, example.env, UPLOAD_LOCATION, DB_PASSWORD, IMMICH_VERSION pin, v2.1.0, Docker Engine v25, start_interval, docker compose up |
| `systems/immich/immich-kubernetes.md` | `systems/` | Kubernetes support status and known caveat | Install doc: official Helm chart (immich-charts) is the supported route; Alpine-image DNS resolution bug when nodes set a search domain; no sizing guidance. | kubernetes, helm chart, immich-charts, kubesearch.dev, Alpine DNS bug, search domain, resolv.conf, no sizing guidance |
| `systems/immich/immich-backup-and-restore.md` | `systems/` | Backup/restore procedures and consistency ordering | Admin doc: 3-2-1 strategy; automatic DB dumps daily 2:00 AM, last 14 kept; filesystem backup user-managed; stop server or DB-first ordering for consistency. | backup, restore, 3-2-1, database dump, 14 backups, daily 2AM, UPLOAD_LOCATION/backups, sql.gz, library upload profile thumbs encoded-video, stop container, DB-before-filesystem ordering, metadata only |
| `systems/immich/immich-faq-scaling-excerpts.md` | `systems/` | FAQ facts on ML capacity, storage semantics, DB integrity, purge | FAQ excerpts: ML concurrency 2-3 maxes CPU, ≤16 with GPU; buffalo_s vs buffalo_l; external-library duplicate/deletion semantics; NTFS/FAT unsupported; checksums since v1.104.0. | FAQ, ML concurrency 2-3, GPU concurrency 16, buffalo_s, transcoding threads 1-2, external library, per-library duplicates, read-only :ro, CIFS Samba, NTFS FAT32 unsupported, data_checksums v1.104.0, pg_amcheck, docker compose down -v, purge |
