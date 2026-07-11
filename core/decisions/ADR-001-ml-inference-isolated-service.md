# ADR-001 — Machine-learning inference isolated in a separate stateless service

## Decision Metadata

- **Title**: Machine-learning inference isolated in a separate stateless service (`immich-machine-learning`)
- **Date**: 2026-07-11
- **Author**: Simulated architect (demo)
- **Created by**: decision-record-agent
- **Severity**: MINOR
- **Decision type**: structural
- **Status**: approved — by architect instruction in a simulated unattended run (D1). Canonical lifecycle status is tracked in `core/decisions/INDEX.md`.

This is an **as-built** record: it documents a decision the upstream Immich project made and documents first-hand, adopted here as a recorded fact of the as-is system during discovery. It does not commit target direction (that is D3 work; ARCH-TARGET is untouched).

---

## Decision Impact

- [x] Introduces something new (records an as-built structural fact)
- [ ] Modifies an existing element
- [ ] Overrides a previous decision

---

## Context

Immich externalizes all machine-learning operations (CLIP smart-search embeddings, facial recognition) into a dedicated service, `immich-machine-learning`, rather than embedding inference in the Nest.js server that serves the REST API and runs background jobs. For the managed-hosting scale-up engagement this boundary matters because ML models are large and memory-intensive, and the ML workload has a fundamentally different resource profile (GPU/CPU-and-memory-bound inference) than the request-serving and job-dispatch path. Recording the as-built boundary establishes it as a fact the scale-up design builds on rather than re-derives.

- **Urgency**: low — discovery record, not a delivery blocker.
- **Scope**: `immich-machine-learning` service boundary and its integration with `immich-server`; as-is only.

---

## Options Considered

This ADR records an as-built decision already made upstream; the "options" are the design choices Immich resolved, recorded so future work does not re-litigate them silently.

### Option A: Isolated stateless ML service over HTTP (as-built, chosen)

- **Description**: ML runs as a distinct Python/FastAPI service exposing HTTP; the server calls it synchronously, passing model-task metadata and model name per request. Model settings persist in Postgres; the service holds no durable server-side state (it downloads, loads, and caches models in-process).
- **Pros**: ML can be deployed separately, independently sized, or disabled entirely; memory-intensive model loading is kept out of the server's deployable; different hardware profile can be provisioned for ML.
- **Cons**: adds a network hop and an HTTP integration surface; introduces a separately-operated unit; per-node ML throughput and hardware sizing are not quantified in the docs (→ R-03, OQ#2).

### Option B: In-process ML inside `immich-server`

- **Description**: Run inference inside the Nest.js server process alongside API serving and job workers.
- **Pros**: one fewer deployable; no service-to-service hop.
- **Cons**: large model memory would load into the serving/job container, risking memory pressure and OOM on the request path; ML could not be scaled or sized independently of serving. Not the path Immich took.

---

## Final Decision

- **Chosen option**: Option A — ML inference isolated in the separate stateless `immich-machine-learning` service, called synchronously over HTTP.
- **Rationale**: The upstream design deliberately externalizes all ML operations so the service can be deployed separately, sized to a memory-intensive workload, or disabled — matching the observed as-built structure and the engagement's need to plan ML capacity independently of serving.

---

## Evidence

- **vendor_doc** — `input/systems/immich/immich-architecture-overview.md:88` — "The machine learning service is written in Python and uses FastAPI for HTTP communication. All ML-related operations are externalized to this service, `immich-machine-learning`, which allows it to be deployed separately from the server, or disabled entirely if needed."
- **vendor_doc** — `input/systems/immich/immich-architecture-overview.md:90` — each request to the ML service carries model-task metadata and model name; models are downloaded/loaded/cached and reused; a thread pool keeps inference off the async event loop.
- **vendor_doc** — `input/systems/immich/immich-architecture-overview.md:92` — models are in ONNX format; "Machine learning models are large and memory-intensive."
- **discovery** — `core/2.ARCH-BASELINE.md` §1.2 (`immich-machine-learning` building block), §1.3 (synchronous HTTP server-to-ML integration).
- **discovery** — synthesis theme **T4** (`core/artifacts/logs/2026-07-11-immich-architecture-overview-synthesis.md:50`) — "Machine learning as a separable Python/ONNX service"; ML is the natural independent scaling and hardware-sizing unit.

---

## Constraints

- **technical_constraint** — server-to-ML integration is synchronous HTTP: an ML outage or backlog stalls the jobs that depend on it (`core/2.ARCH-BASELINE.md` §1.3).
- **technical_constraint** — per-node ML throughput and hardware requirements are not quantified in the D1 doc set (OQ#2), so isolation enables independent sizing but does not by itself supply the numbers to size with.

---

## Consequences

- **What this enables**: independent scaling and hardware sizing of the ML tier; ability to disable ML without touching the serving path; a clean unit to target for the D3 ML-throughput scale-up work (ties to **R-03**).
- **What this limits (trade-offs)**: an additional deployable to operate and a synchronous HTTP dependency on the ingest job chain; memory isolation from the serving path follows from separate deployment (the docs state models are large and memory-intensive) rather than from an explicitly documented enforced process/memory boundary — when co-located, that isolation is lost.
- **What to watch for (risks)**: **R-03** — ML is memory-intensive with no quantified throughput or hardware sizing; if co-located, model loading causes memory pressure and OOM/eviction; even when separated, capacity cannot be planned until throughput is measured (OQ#2).

---

## Success Metrics

- **Metric**: ML tier is deployed and sized as an independent unit in the hosting topology — measured by the pilot deployment topology separating `immich-machine-learning` from `immich-server`.
- **Measurement / when**: evaluated at D3 ML-throughput scale-up design, when per-node ML throughput and memory need (OQ#2) are quantified.

---

## System Alignment

- **Related ADRs**: related_to **ADR-002** (both record the as-built decomposition of the Immich estate; the ML dispatch is one stage of the ADR-002 job chain).
- **Affects `core/3.ARCH-TARGET.md`**: No (as-is record; target adoption is D3).
- **Affects `core/1.ARCH-CONTEXT.md`**: No.
- **Affected agents**: nfr-analysis-agent, risk-assessment-agent (R-03), component-spec-agent (future ML component spec).
- **Related artifacts**: `core/2.ARCH-BASELINE.md` §1.2/§1.3; `core/artifacts/risk-register.md` (R-03); `core/artifacts/logs/2026-07-11-immich-architecture-overview-synthesis.md` (T4).

---

## Lifecycle

| Status | Date | Reason |
|--------|------|--------|
| approved | 2026-07-11 | Approved on architect authority per session-D1 instruction (simulated unattended run); recorded as an as-built fact of the as-is system. |
