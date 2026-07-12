---
title: D5 operability & observability synthesis (Immich)
date: 2026-07-12
run: 2026-07-12-immich-operability-observability
sources:
  - input/stakeholder/2026-07-12_D5_operability-observability-brief.md
  - input/systems/immich/immich-monitoring.md
  - input/systems/immich/immich-reverse-proxy.md
  - input/systems/immich/immich-system-integrity.md
confidence: high — §1/§3/§6 as-is facts derive verbatim from first-party Immich docs in input/systems/immich/
---

# D5 synthesis — operability & observability

## Executive summary

Fifth incremental synthesis (D1 architecture → D2 ML/media → D3 scale-up → D4 identity → **D5 operability/observability**). Processes the D5 brief's five questions against three first-party docs. **Four themes T24–T27**, all landing as as-is facts in BASELINE §1.6 / §3.2 / §6. **Key finding:** Immich's first-party operability surface is a set of **primitives without a control plane** — opt-in metrics, env-var-only structured logging, strict reverse-proxy requirements, and startup marker-file mount checks — with **no first-party logging page** (404, absent from nav — session finding, not a gap to fill), **no log routing/retention**, and **no documented container healthcheck**. Everything above the primitives is operator-built.
Glossary: 4 tentative terms added. OQ: 1 new (OQ#5 log-routing/retention + container-health gap); OQ#4 cross-links added (F3). Baseline: §1.6, new §3.2, §6 deltas proposed. Downstream: evidence **supports** an observability ADR and a new M1 enabler — both recommended below.

## Themes

### T24 — Opt-in Prometheus/OTel telemetry surface (metrics primitive)
- **Evidence:** Metrics exposed via Prometheus/OpenTelemetry, **opt-in, disabled by default**, all data local (`immich-monitoring.md:9`). Enable per server container with `IMMICH_TELEMETRY_INCLUDE=all`; comma-separated **metric groups api / host / io**, toggleable, with `IMMICH_TELEMETRY_EXCLUDE` (`immich-monitoring.md:13-18`). Types: counters, gauges, histograms (`:19`). Ports **8081 API metrics** (`IMMICH_API_METRICS_PORT`), **8082 microservices metrics** (`IMMICH_MICROSERVICES_METRICS_PORT`), 9090 Prometheus default (`immich-monitoring.md:22-27`). Reference compose adds `immich-prometheus` + `immich-grafana` (port 3000) (`:31-32`).
- **Implications:** Immich gives a **scrapeable metric surface but not a monitoring system** — the operator supplies Prometheus, Grafana, scrape config, dashboards, and (critically) **alerting**, none of which the docs specify. Two metrics endpoints per instance (api + microservices) is a per-instance scrape-target multiplier across 50 instances (NFR-001 material). Metrics are off unless the operator turns them on — a fleet-wide config obligation.
- **Lands in:** BASELINE §3.2 (Observability — new subsection).

### T25 — Structured logging via env var only; no first-party logging page (logging primitive)
- **Evidence:** `IMMICH_LOG_FORMAT=json` switches output to JSON (default `console`); JSON records carry `level`, `pid`, `timestamp` (Unix ms), `message`, `context` (`immich-monitoring.md:36-37`). Verbosity is `IMMICH_LOG_LEVEL`, set separately, and **"there is no dedicated first-party logging page"** (`immich-monitoring.md:38`). **Session finding (seeding-verified):** `docs.immich.app/administration/logging` returns 404, absent from nav/sitemap (`immich-system-integrity.md` provenance note; `immich-monitoring.md:38`).
- **Implications:** Logging is configurable in **format and level only**. There is **no documented log destination, routing, aggregation, rotation, or retention** — logs go to container stdout/stderr and the operator owns everything downstream (ship, aggregate, retain, alert). This is a documented silence, treated as a session finding, not filled. Bundles with T24 into the operator-built control-plane gap (OQ#5).
- **Lands in:** BASELINE §3.2.

### T26 — Reverse-proxy hard requirements (front-door / API serving path)
- **Evidence:** Proxy **must** forward all headers, correctly setting `Host`, `X-Real-IP`, `X-Forwarded-Proto`, `X-Forwarded-For` (`immich-reverse-proxy.md:13`); must allow large uploads (`:14`); **sub-path serving unsupported — root of a (sub)domain only** (`:15`); `/.well-known/immich` must still route to Immich or mobile connections break (`:16`). Nginx directives: `client_max_body_size 50000M`, `proxy_request_buffering off`, `client_body_buffer_size 1024k`, `proxy_read/send_timeout 600s`, WebSocket Upgrade/Connection on HTTP/1.1 (`:20-25`). Apache: 600s + WebSocket (`:32`). **Traefik v3: `respondingTimeouts` 600s or video uploads fail after one minute** (`:36`).
- **Implications for ADR-004 (D5 Q3):** ADR-004 already puts an **auth+TLS reverse proxy in front of the ML tier (port 3003)**; this doc governs the **separate front-door proxy in front of the API serving path** (immich-server). Same class of component, different channel — the two proxy roles must not be conflated. The front-door requirements constrain the API serving path NFR-001 depends on: a proxy that buffers uploads, imposes a small body cap, applies a <600s timeout, or serves on a sub-path **breaks large media uploads and mobile connectivity** — hard failure modes, not tuning. These are per-instance front-door config obligations across the fleet. No conflict with ADR-004; it **extends** the proxy discipline to the API path and is a candidate input to the observability/front-door ADR direction.
- **Lands in:** BASELINE §6 (Deployment & Environments — front-door proxy requirements).

### T27 — Startup marker-file integrity check is the only first-party health mechanism; no container healthcheck
- **Evidence:** On startup Immich validates **six upload-location folders** — `upload/`, `library/`, `thumbs/`, `encoded-video/`, `profile/`, `backups/` — performing **create / read / overwrite of a hidden `.immich` marker** in each (`immich-system-integrity.md:13-19`). Catches wrong permissions and missing/misconfigured mounts (absent marker) (`:22-24`); failure example `ENOENT ... 'upload/encoded-video/.immich'` (`:29`). Escape hatch `IMMICH_IGNORE_MOUNT_CHECK_ERRORS=true`, documented for users who understand the implications (`:37`). **Session finding:** this is "**the closest first-party page to container health checks**; Immich docs have no dedicated healthcheck … page" (`immich-system-integrity.md` provenance note + `:9`).
- **Implications:** The only first-party health signal is a **one-shot startup gate**, not a **liveness/readiness probe** — it does not report ongoing health, does not surface unhealthiness after boot, and can be silenced. For 99.9% across 50 instances the operator must **author container healthchecks/readiness probes** (compose/k8s) and wire them to the alerting T24 metrics feed. Bundles into OQ#5.
- **Lands in:** BASELINE §1.6 (health mechanism, cross-cutting) — with the integrity-check operability posture; also referenced from §3.2.

## Conflicts detected
None. T26 clarifies (does not contradict) ADR-004: front-door API proxy vs ML-tier proxy are distinct roles.

## Open questions
- **OQ#5 (new, warranted):** Log routing/retention and container-health are operator-built with **no first-party guidance.** Immich documents logging as **format+level env vars only** (no destination/aggregation/rotation/retention — T25) and offers **no container healthcheck** beyond a silenceable startup mount gate (T27); metrics exist but Immich ships **no alerting** (T24). To run 50 instances at NFR-001 the operator must build log shipping/retention, health/readiness probes, and metric-driven alerting from these primitives — none specified upstream. Material to NFR-001 and the M1 operator monitoring capability. (Opened 2026-07-12 D5.)

## Glossary updates (proposed, tentative)
- **Immich telemetry (metric groups)** — variants "telemetry groups", "IMMICH_TELEMETRY_INCLUDE"; opt-in Prometheus/OTel metrics in three toggleable groups api/host/io on ports 8081/8082. (T24)
- **structured JSON logging (Immich)** — variants "IMMICH_LOG_FORMAT json", "json log format"; env-var-selected JSON log output (level/pid/timestamp/message/context); format+level only, no routing/retention. (T25)
- **front-door reverse proxy (Immich)** — variants "reverse proxy", "the proxy"; the operator proxy in front of immich-server's API path with mandatory forwarded-header, large-upload, root-path, and 600s-timeout requirements. Distinct from the ML-tier proxy (ADR-004). (T26)
- **startup folder integrity check (`.immich` marker)** — variants "system integrity check", "marker-file check", "folder checks"; the create/read/overwrite `.immich`-marker startup validation across the six upload folders — Immich's only first-party health mechanism; no ongoing healthcheck. (T27)

## Downstream note (for the architect's next instruction)

**Observability ADR — supported, recommended.** The evidence establishes a coherent directional decision: adopt an **operator monitoring stack** (Prometheus scrape of api/host/io on 8081/8082 + Grafana + operator-authored alerting), an **operator log pipeline** (ship JSON stdout → aggregation + retention), and **operator container health/readiness probes** — because Immich ships primitives but no control plane (T24/T25/T27) and no first-party guidance (OQ#5). This is a genuine cross-cutting direction with trade-offs (per-instance vs fleet-shared monitoring; scrape-target scale; where retention lives) — ADR-worthy. Recommend routing to `decision-record-agent`.

**New M1 enabler — warranted, recommended.** An **operator monitoring/alerting capability** (call it "Fleet observability & health" — metrics+alerting, log routing/retention, container health probes per instance) is the delivery vehicle for OQ#5 and a direct enabler of NFR-001 (you cannot hold 99.9% you cannot observe). It pairs with the observability ADR the way E-01…E-04 pair with ADR-003/004/005. Recommend the architect open it in the M1 transition alongside the ADR.

Both are recommendations for the architect's approval — neither the ADR nor the enabler is written by this run.

## Fitness follow-ups executed (architect-approved this session)
- **F2** — architecture-review work-stream currency advanced to D4+D5 (records the §1.6 D4 landing and this D5 landing). Applied to `core/arch-processes/work-streams/architecture-review.md`.
- **F3** — OQ#4 parenthetical given inline cross-links: **R-08** (holds the folded session-invalidation aggravator) and **ADR-006** (leaves the gap as an open point). Applied to `core/arch-processes/open-question-register.md`.

## Librarian hand-off
This run log is new under `logs/`. Main loop: run `librarian-agent` to add the row and bump the artifacts total (done inline this session per instruction), then re-run `.claude/scripts/check-indexes.sh`.

## Landings summary (proposals — architect-gated)
| Fact | Lands in |
|------|----------|
| Opt-in Prometheus/OTel metrics, groups api/host/io, ports 8081/8082 (T24) | BASELINE §3.2 |
| Structured JSON logging env-var-only; no logging page (T25) | BASELINE §3.2 |
| No log routing/retention; operator-built (T25, OQ#5) | BASELINE §3.2 |
| Reverse-proxy hard requirements, front-door/API path (T26) | BASELINE §6 |
| Startup `.immich` marker integrity check; no container healthcheck (T27) | BASELINE §1.6 (+ §3.2 ref) |
