---
source_url: https://docs.immich.app/features/monitoring
fetched: 2026-07-12
provenance: first-party Immich documentation, converted to markdown; content abridged — full prometheus.yml/Grafana compose snippets condensed to their essential parameters, prose boilerplate stripped. All metric surface facts (env vars, ports, metric groups, log format) kept.
---

# Monitoring (Immich)

Immich exposes performance metrics via Prometheus / OpenTelemetry. Telemetry is **opt-in** — disabled by default; all data stays local to the deployment.

## Prometheus metrics

- Enable with `IMMICH_TELEMETRY_INCLUDE=all` (server container only).
- Granular control: `IMMICH_TELEMETRY_INCLUDE` accepts a comma-separated list of metric groups; `IMMICH_TELEMETRY_EXCLUDE` removes groups from the enabled set.
- Metric groups (independently toggleable):
  - **api** — API request metrics
  - **host** — host metrics (memory, CPU)
  - **io** — IO metrics (database query timings, image processing)
- Metric types exposed: counters (monotonic), gauges, histograms (cumulative buckets).

## Metrics ports

| Port | Endpoint | Override variable |
|------|----------|-------------------|
| `8081` | API metrics endpoint | `IMMICH_API_METRICS_PORT` |
| `8082` | Microservices metrics endpoint | `IMMICH_MICROSERVICES_METRICS_PORT` |
| `9090` | Prometheus server default | — |

## Scraping / visualization setup (docker-compose)

- Add an `immich-prometheus` service using the `prom/prometheus` image, volume-mount a `prometheus.yml` scrape config, and persist to a named `prometheus-data` volume.
- Add an `immich-grafana` service using the `grafana/grafana` image on port `3000` with a `grafana-data:/var/lib/grafana` volume; configure Prometheus data source at `http://immich-prometheus:9090`.

## Structured logging

- `IMMICH_LOG_FORMAT=json` switches log output to JSON (default is `console`).
- JSON log records include: `level`, `pid`, `timestamp` (Unix milliseconds), `message`, and `context` fields.
- (Log verbosity is set separately via `IMMICH_LOG_LEVEL` — see the environment-variables doc; there is no dedicated first-party logging page.)
