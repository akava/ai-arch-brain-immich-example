# ADR-007 — Fleet observability & health for managed instances

**Status:** proposed (2026-07-12) · unattended-run proposal, no human approval yet — the `proposed` → `approved` flip is the architect's explicit call (status-note convention as ADR-003…006).
**Severity:** MAJOR · **Decision type:** nfr_quality_attribute · **Version level:** MAJOR
**Date:** 2026-07-12 · **Author:** Simulated architect (demo) · **Created by:** decision-record-agent (D5 run)

> **Simulated demonstration engagement.** The engagement and its pilot figures are fiction exercising this repository's operating model (`core/1.ARCH-CONTEXT.md` → Engagement); this is an unreviewed AI draft. The subject system (Immich) and its documented behaviour are real, drawn from first-party docs under `input/`.

## Summary

For 50 isolated managed Immich instances, adopt an **operator-run central fleet observability plane** — Prometheus-compatible scrape of every instance's opt-in metrics (8081/8082), central shipping + defined retention of the JSON log stream, operator-built synthetic health probes and container healthchecks, and alerting rules tied to NFR-001's error budget — with per-instance data kept segregated per the isolated-instance philosophy (ADR-003 alignment). Chosen over per-instance ad-hoc monitoring (A) and a full APM/tracing platform (C, partially unsupported by the docs).

## Context

**Problem.** Immich ships observability *primitives without a control plane* (BASELINE §3.2): opt-in Prometheus/OpenTelemetry metrics on ports **8081 (API)** / **8082 (microservices)** across three toggleable groups (`api`/`host`/`io`), disabled by default and enabled per container via `IMMICH_TELEMETRY_INCLUDE`; env-var-only JSON logging (`IMMICH_LOG_FORMAT=json`, level via `IMMICH_LOG_LEVEL`) with **no documented routing, aggregation, rotation, retention, or alerting** — logs go to stdout/stderr; a **one-shot startup marker-file (`.immich`) folder integrity check** as the only first-party health mechanism (six upload folders), which is a startup gate, not a liveness/readiness probe; and **no container-healthcheck guidance** (`docs.immich.app` logging + healthcheck pages return 404 — session finding, verified at source `input/systems/immich/immich-monitoring.md:9,13-19,36-38`, `immich-system-integrity.md:9,13-24`). To hold **NFR-001** (99.9% / ≤ 43.8 min-month per instance) across the fleet, everything above the primitives is operator-built. You cannot hold an availability budget you cannot observe.

**Urgency.** Material to NFR-001 and to M1 delivery — the operator monitoring capability is the detection layer the pilot's availability gate depends on. Opened as **OQ#5** (D5 synthesis).
**Scope.** The operator-side observability/health plane wrapping 50 stock instances; the stock containers are untouched (CON-001). Front-door proxy *correctness* (T26) is in scope only as a monitored surface and alerting threshold, not re-decided here (its config discipline is a separate front-door concern, ties ADR-004's distinct ML-tier proxy).

## Options

### A — Per-instance minimal (rejected)
Enable telemetry where convenient, scrape ad hoc, rely on customer complaints as the failure signal; no central alerting or log retention.
- **Pros:** near-zero operator build; no central plane to run; smallest CON-001 footprint.
- **Cons:** **detection is reactive** — a complaint-driven signal cannot demonstrate 99.9% detection across 50 instances; no cross-fleet view; no retained logs for post-incident analysis; container health never surfaced after boot. Does not meet NFR-001's implicit detection need.
- **Effort:** low. **Verdict:** rejected — recorded for completeness; fails the availability-budget detection requirement.

### B — Central fleet observability plane (chosen)
An operator-run Prometheus-compatible scrape of every instance's 8081/8082 with telemetry enabled fleet-wide (`IMMICH_TELEMETRY_INCLUDE` as a baseline instance-config setting); central shipping of each instance's JSON log stream to an aggregation tier with **defined retention**; operator-authored **synthetic health probes + container healthchecks** (compose/k8s liveness/readiness) built on top of the startup gate the stock provides; **alerting rules tied to NFR-001's error budget**. Per-instance metric/log data kept **segregated** so one tenant's observability data and blast radius stay isolated (ADR-003 isolated-instance alignment).
- **Pros:** proactive, budget-tied detection; single fleet view with per-tenant isolation preserved; retained logs for RCA; realizes OQ#5's log-routing/retention half and frames the container-health build. Directly serves NFR-001. Uses only documented primitives — no stock modification.
- **Cons:** operator builds and runs the whole plane (scrape config, dashboards, log pipeline, alerting, probes — none upstream-specified); per-instance scrape-target multiplier (2 endpoints × 50 = 100 targets) is a real scale/cost load; segregation-vs-fleet-view is an ongoing design tension.
- **Effort:** medium-high. **Verdict:** **chosen** — the only option that satisfies NFR-001 detection at fleet scale using documented primitives.

### C — Full APM / end-to-end tracing platform (rejected for the pilot)
Adopt an OTel tracing platform with end-to-end per-request spans across server/ML/DB, on top of B's metrics + logs.
- **Pros:** deepest diagnostic power; per-request latency attribution.
- **Cons:** **partially speculative on the evidence** — the docs' OpenTelemetry mention covers **metrics export only** (`api`/`host`/`io` groups: counters/gauges/histograms); **no per-request tracing or span export is documented** (`input/systems/immich/immich-monitoring.md:9,14-18`). End-to-end tracing would require instrumentation Immich does not document shipping, and would touch the stock path (CON-001 tension). Effort and unknowns exceed pilot need.
- **Effort:** high (+ unquantified instrumentation risk). **Verdict:** rejected for M1 — prefer B; revisit tracing only if first-party span export is confirmed.

## Decision

**Adopt Option B — the central fleet observability plane.** Telemetry is enabled fleet-wide as a baseline instance-config setting; the operator runs a Prometheus-compatible scrape of 8081/8082, ships and retains the JSON log stream centrally, authors synthetic + container health probes over the stock startup gate, and drives NFR-001-error-budget-tied alerting — all with per-instance data segregation. Tracing (C) is deferred as docs-unsupported.

**Rationale.** Immich provides primitives and no control plane (T24/T25/T27); NFR-001 across 50 instances cannot be held or evidenced without operator-built metrics-alerting, log retention, and health probes. B is the minimal plane that meets the detection need using only documented surfaces, keeps CON-001 intact, and preserves ADR-003 isolation. A is reactive and fails detection; C reaches past what the docs support.

## Evidence

| Type | Source | What it establishes |
|------|--------|---------------------|
| vendor_doc | `input/systems/immich/immich-monitoring.md:9,13-19,25-27` | Opt-in Prometheus/OTel metrics; groups `api`/`host`/`io`; ports 8081 (API) / 8082 (microservices); telemetry disabled by default, data local. |
| vendor_doc | `input/systems/immich/immich-monitoring.md:36-38` | JSON logging via `IMMICH_LOG_FORMAT`/`IMMICH_LOG_LEVEL` only; no routing/aggregation/rotation/retention; no first-party logging page (404). |
| vendor_doc | `input/systems/immich/immich-system-integrity.md:9,13-24` | Startup `.immich` marker-file check across six folders is the **only** first-party health mechanism; a startup gate, not liveness/readiness; no container-healthcheck page (404). |
| vendor_doc | `input/systems/immich/immich-monitoring.md:9,14-18` | OTel mention is **metrics-export only** — no documented per-request tracing/span export (scopes C as partially speculative). |
| vendor_doc | `input/systems/immich/immich-reverse-proxy.md:20,23` | Front-door proxy requirements: `client_max_body_size 50000M`, `proxy_read_timeout 600s` — monitored-surface thresholds (T26). |
| nfr_analysis | `core/1.ARCH-CONTEXT.md:97` (NFR-001) | 99.9% / ≤ 43.8 min-month per-instance availability — the error budget alerting is tied to. |
| discovery | D5 synthesis `core/artifacts/logs/2026-07-12-immich-operability-observability-synthesis.md` (T24–T27, OQ#5) | Primitives-without-control-plane finding; OQ#5 opened; observability ADR + M1 enabler recommended. |
| technical_constraint | ADR-003 (proposed); CON-001 (`core/1.ARCH-CONTEXT.md:103`) | Isolated-instance philosophy → per-tenant data segregation; stock-untouched reversibility bound. |

## Constraints

| Constraint | Source |
|------------|--------|
| Telemetry is **opt-in and off by default** — must be enabled fleet-wide as a baseline instance-config setting (fleet config obligation). | immich-monitoring.md:9,13 |
| Per-instance data segregation — one tenant's metrics/logs isolated, per the isolated-instance philosophy. | ADR-003 (proposed) |
| Stock containers untouched; the plane wraps stock, adds nothing that breaks the stock upgrade path. | CON-001 |
| Two scrape endpoints per instance (100 targets at 50 instances) — scrape-target scale is a design load, not free. | immich-monitoring.md:22-27 |
| Front-door proxy `600s` timeout and `50000M` body-size are **alerting-relevant thresholds** and a monitored surface, not re-decided here. | immich-reverse-proxy.md:20,23 |

## Consequences

**Enables.** Proactive, budget-tied fleet detection for NFR-001; central retained logs for RCA; operator-authored health/readiness surfaced beyond the stock startup gate; a single fleet view with per-tenant isolation intact. Partially resolves **OQ#5**: the **log routing/retention half is decided** (central shipping + defined retention); the **container-health/probe design remains build work** in M1.

**Trade-offs.** The operator owns and runs the entire plane (scrape config, dashboards, log pipeline, retention, alerting, probes) — cost and operational load Immich does not carry; telemetry must be turned on everywhere (config baseline); segregation-vs-single-pane is a standing design tension; the front-door proxy's `600s`/`50000M` settings become monitored thresholds the operator must alert on.

**Risks.** Scrape-target scale (100 endpoints) and log volume at 50 instances are unsized here ([TBD] until pilot telemetry); the container-health probe design is undelivered build work (OQ#5 remnant); tracing (C) stays unavailable unless first-party span export is later confirmed; ties **R-01** (store availability — the thing being observed) and **R-08** (break-glass/lockout events are an alerting-relevant health signal, ADR-006).

## Success metrics

| Metric | Measurement |
|--------|-------------|
| Fleet detection latency | An induced instance failure raises an alert within the pilot detection window (**[TBD]** — window set at the M1 pilot gate; no first-party figure exists to inherit). |
| Telemetry coverage | 100% of pilot instances have telemetry enabled and are scraped (both 8081/8082 endpoints as live targets). |
| Log retention | JSON log stream centrally shipped and retained for the defined retention period (period **[TBD]** — operator policy, set at pilot). |
| Health-probe coverage | Every instance carries an operator container health/readiness probe wired to alerting (beyond the stock startup gate). |

## Relationships

- **related_to:** ADR-003 (proposed) — isolated-instance philosophy drives per-tenant data segregation; ADR-004 (proposed) — its ML-tier auth+TLS proxy is a **distinct** proxy from the front-door proxy referenced here (must not be conflated); ADR-006 (proposed) — break-glass/lockout events are alerting-relevant health signals.
- **supersedes / conflicts_with:** none.
- **artifact_refs:** D5 synthesis `core/artifacts/logs/2026-07-12-immich-operability-observability-synthesis.md` (T24–T27, OQ#5); BASELINE §3.2; TARGET §3.2; `core/transitions/M1-managed-hosting-pilot.md` (E-05/WS5); `core/transitions/ENABLER-CATALOG.md` (E-05).
- **agent_refs:** decision-record-agent (this record); synthesis-agent (D5, evidence).

## Lifecycle

| Status | Date | Reason |
|--------|------|--------|
| proposed | 2026-07-12 | Recorded in unattended D5 run; awaiting architect approval. Reconciliation into TARGET §3.2 is `[Tentative]` per AGENT-RULES §8; the flip to `approved` and any baseline promotion are the architect's explicit call (§9). |
