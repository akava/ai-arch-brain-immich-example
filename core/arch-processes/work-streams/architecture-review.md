# Architecture Review (baseline stream)

**Code:** `baseline` · **Populates:** `core/2.ARCH-BASELINE.md` · **Horizon:** current-state.
**Goal:** review and document the architecture as it is today; every durable fact lands in ARCH-BASELINE.

## Deliverable in flight

> TODO: Name the review deliverable currently being produced (e.g. an architecture review draft — observations, gaps, recommendations), its timeline, and what it feeds (action IDs where tracked).

## Work status

Discovery proceeding by session against the first-party Immich doc set (`input/systems/immich/`). Structural picture (components, workers, stores, integration, jobs) reviewed; ML/media/storage detail deepened in D2; scale-up posture in D3; identity/access in D4; operability/observability in D5; customer-library onboarding in D6. Blocked areas surface as open questions, not silent gaps: multi-node/HA posture (OQ#1) and ML throughput/hardware sizing (OQ#2, partially answered in D2 — hardware floors documented, throughput still unquantified) both await evidence beyond this doc set; the API-key/session-management gap (OQ#4), the operator-built log-routing/retention + container-health gap (OQ#5), the absent first-party migration guide (OQ#6), and the watch/nightly-scan operational bounds (OQ#7) are verified doc silences. No `AI-NN` tracking action opened yet.

## Landed so far

- **D1 (session 2026-07-11, run `immich-architecture-overview`):** BASELINE §1 (1.1 context/scope, 1.2 building blocks, 1.3 integration patterns, 1.4 data & flows) and §2 (tech stack & platforms) populated from `immich-architecture-overview.md`, `immich-jobs-and-workers.md`, `immich-repo-readme.md`.
- **D2 (session 2026-07-11, run `immich-ml-media-deep-dive`):** BASELINE §1.2/§1.4 deepened (remote-ML deployment mode and offload scope, storage-template mechanics, migrations-at-startup), §2 extended (ML hardware-acceleration and hardware-transcoding options), and §3 seeded (observed ML-acceleration hardware floors) from `immich-ml-hardware-acceleration.md`, `immich-hardware-transcoding.md`, `immich-remote-machine-learning.md`, `immich-storage-template.md`, `immich-database-migrations.md`.
- **D4 (session 2026-07-12, run `immich-identity-access`):** BASELINE §1.6 populated (identity/access cross-cutting — OIDC per-instance config + claim mappings, two-tier admin/user model, per-user quotas, `immich-admin` break-glass CLI + lockout recovery, deletion 7-day purge; two operational nuances: claims applied at creation only, auth changes don't invalidate sessions) from `immich-oauth-authentication.md`, `immich-user-management.md`, `immich-server-commands.md`, `immich-system-settings-auth.md`; OQ#4 opened.
- **D5 (session 2026-07-12, run `immich-operability-observability`):** BASELINE §1.6 extended (startup `.immich`-marker integrity check — the only first-party health mechanism, no container healthcheck), new §3.2 Observability populated (opt-in Prometheus/OTel metrics groups api/host/io on 8081/8082; structured JSON logging env-var-only, no logging page/routing/retention), and §6 extended (front-door reverse-proxy requirements — forwarded headers, no sub-path, 50000M uploads, buffering off, 600s timeouts) from `immich-monitoring.md`, `immich-reverse-proxy.md`, `immich-system-integrity.md`; OQ#5 opened.

- **D6 (session 2026-07-12, run `immich-library-onboarding`):** BASELINE §1.4 populated (customer-library onboarding — three first-party import paths: CLI upload (`@immich/cli`, concurrency 4, client-side-hash skip + always-on server-side dedup, no resume flag/idempotent re-run), raw API `POST /api/assets`, and external libraries (single-user unchangeable, recursive import paths, path-removal deletes assets, glob exclusions → PostgreSQL `LIKE`, experimental `--watch` + nightly scan job, `:ro` mount barrier, quota-exempt); verified absence of any first-party migration guide) from `immich-cli-upload.md`, `immich-api-assets.md`, `immich-external-libraries.md`, `immich-libraries-overview.md`; OQ#6 (migration guide) and OQ#7 (watch/scan bounds) opened.

Latest processed session: 2026-07-12 D6 (`immich-library-onboarding`).
