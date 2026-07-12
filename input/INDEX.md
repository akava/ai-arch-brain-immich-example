---
type: input_index
project: "Immich Managed-Hosting Scale-Up (simulated demo engagement)"
date_built: 2026-07-12
maintainer: librarian-agent (legacy SKILL-009)
---

# Input Index

Compact map of all files in `input/`. Agents must follow the indexed retrieval protocol — read this index first, verify count, then open only relevant files.

**Total files in input/** (excl. `.gitkeep`): **27** (incl. this `INDEX.md`)

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
| `stakeholder/2026-07-12_D4_identity-access-brief.md` | `stakeholder/` | Frames session D4 scope: identity, access, and user management questions | Simulated D4 brief: user/account model, OAuth/OIDC support, password/session/API-key documentation, per-customer IdP wiring feasibility; expected outputs synthesis delta, security update, possible identity ADR. | D4, session brief, identity, access, user management, OAuth, OIDC, identity provider integration, per-instance IdP, admin separation, quotas, password auth, sessions, API keys, identity ADR |
| `stakeholder/2026-07-11_D3_scale-up-design-brief.md` | `stakeholder/` | Frames session D3 scope: scale-up design targets, ownership, expected outputs | Simulated D3 brief: fictional pilot targets — 50 instances, 5 TB media each, 99.9% availability, ≤15 min upgrade downtime, 1M-asset ML backlog in 72h; role-level owners. | D3, design session, pilot targets, 50 instances, 5TB, 99.9% availability, 15-minute upgrade window, 1M assets 72 hours, ML auth encryption, ownership, transition M1, enablers |
| `stakeholder/2026-07-12_D5_operability-observability-brief.md` | `stakeholder/` | Frames session D5 scope: monitoring, logging, reverse proxy, container health signals | Simulated D5 brief: telemetry, logging, front-door proxy, health-signal questions for operating 50 instances at 99.9%; expected outputs synthesis delta, possible observability ADR, M1 enabler. | D5, session brief, operability, observability, monitoring, logging, reverse proxy, health checks, day-2 operations, NFR-001, 99.9%, 50 instances, ADR-004 hardening, M1 enabler, D4 fitness follow-ups F2 F3 |
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
| `systems/immich/immich-oauth-authentication.md` | `systems/` | OAuth/OIDC integration surface per instance — provider setup, claims, quotas | Admin doc: OIDC via Authorization Code; issuer URL, client ID/secret, default scope openid email profile; role/quota/storage-label claims applied at user creation only. | OAuth, OIDC, Authentik, Authelia, Okta, Keycloak, issuer URL, client secret, scope openid email profile, RS256, Role Claim immich_role, Storage Quota Claim immich_quota, Storage Label Claim preferred_username, Default Storage Quota 0 unlimited, Auto Register true, Auto Launch, app.immich:///oauth-callback, mobile-redirect, backchannel logout, claims not synchronized after creation |
| `systems/immich/immich-user-management.md` | `systems/` | User/account model — admin role, quotas, labels, password reset, deletion | Admin doc: first registered user becomes admin; per-user GiB quota (default unlimited); storage labels; admin password reset to random value; 7-day delayed deletion. | user management, first user admin, Administration Users, create user, welcome email SMTP, storage quota GiB, quota blocks upload, external libraries excluded from quota, storage label upload path, password reset random, change at next sign-in, delete user 7 days, immediate deletion queue |
| `systems/immich/immich-server-commands.md` | `systems/` | Admin CLI (immich-admin) — auth toggles, admin recovery, user listing | Admin doc: immich-admin CLI in immich_server container; reset-admin-password, enable/disable password and OAuth login, grant/revoke-admin by email, list-users, maintenance mode. | immich-admin, server commands, reset-admin-password, disable-password-login, enable-password-login, enable-oauth-login, disable-oauth-login, list-users, grant-admin by email, revoke-admin, maintenance mode, change-media-location, schema-check, version |
| `systems/immich/immich-system-settings-auth.md` | `systems/` | Instance-wide auth toggles, user-deletion delay, trash settings | System-settings excerpts: password login can be disabled instance-wide incl. admin; setting change spares existing sessions; delete delay default 7 days; trash 30 days. | system settings, password authentication disable, applies to administrator, existing sessions unaffected, both OAuth and password disabled lockout, Server CLI re-enable, user delete delay 7 days, deletion job midnight, trash 30 days, trash disable not recommended, Ctrl Del permanent delete, no API key section, no session management section |
| `systems/immich/immich-monitoring.md` | `systems/` | Metrics/telemetry surface and structured-logging format for the observability stack | Feature doc: opt-in Prometheus/OpenTelemetry metrics; IMMICH_TELEMETRY_INCLUDE groups api/host/io; metrics ports 8081/8082; Prometheus/Grafana compose setup; JSON log format option. | monitoring, Prometheus, OpenTelemetry, telemetry opt-in disabled by default, IMMICH_TELEMETRY_INCLUDE all, IMMICH_TELEMETRY_EXCLUDE, metric groups api host io, port 8081 API metrics, port 8082 microservices metrics, IMMICH_API_METRICS_PORT, IMMICH_MICROSERVICES_METRICS_PORT, Prometheus 9090, Grafana 3000, counters gauges histograms, IMMICH_LOG_FORMAT json, level pid timestamp message context, no dedicated logging page |
| `systems/immich/immich-reverse-proxy.md` | `systems/` | Front-door proxy requirements and per-proxy configuration directives | Admin doc: forwarded-header requirements, no sub-path serving, large-upload headroom; nginx client_max_body_size 50000M, buffering off, 600s timeouts; Traefik respondingTimeouts 600s. | reverse proxy, forward all headers, Host X-Real-IP X-Forwarded-Proto X-Forwarded-For, sub-path unsupported, root path of subdomain, .well-known/immich Let's Encrypt http-01, client_max_body_size 50000M, proxy_request_buffering off, client_body_buffer_size 1024k, proxy_read_timeout 600s, WebSocket Upgrade Connection HTTP/1.1, Caddy automatic HTTPS, Apache ProxyPass, Traefik v3 respondingTimeouts 600 video upload |
| `systems/immich/immich-system-integrity.md` | `systems/` | Startup storage-mount integrity checks — closest first-party health mechanism | Admin doc: startup create/read/overwrite of .immich marker in six upload-location folders; catches permission and mount errors; IMMICH_IGNORE_MOUNT_CHECK_ERRORS escape hatch. | system integrity, folder checks, .immich marker hidden file, upload library thumbs encoded-video profile backups, create read overwrite, ENOENT no such file, permissions, volume mount misconfiguration, touch .immich, incomplete backup restoration, IMMICH_IGNORE_MOUNT_CHECK_ERRORS true, no container healthcheck page, no logging page 404 |
