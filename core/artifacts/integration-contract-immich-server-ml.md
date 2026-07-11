---
title: Integration Contract — immich-server ↔ immich-machine-learning
type: integration-contract
agent: integration-contract-agent (SKILL-005)
status: active
confidence: high on the as-built channel (first-party-doc-cited); tentative on the ADR-004 target overlay (proposed, unapproved)
---

# Integration Contract — immich-server ↔ immich-machine-learning

**Interface:** the synchronous HTTP channel over which `immich-server` offloads ML inference to `immich-machine-learning` — the channel ADR-004 (proposed) puts a load balancer and auth+TLS proxy into.
**Parties:** caller **immich-server** (`api`/`microservices` workers dispatch ML jobs) → callee **immich-machine-learning**.
**Verdict:** the as-built contract is a **thin, undocumented-wire, unsecured synchronous HTTP call** — the doc set fixes the transport (HTTP, port 3003), the payload *nature* (image previews out, model outputs in), and the caller-side dispatch behaviour, but **publishes no request/response wire schema** and **specifies no auth, TLS, retry, timeout, or idempotency convention on the channel itself**. Every hosting-relevant gap is routed to its OQ/R row. The target overlay (LB-fronted dispatch, health-checking, single hardened URL) is entirely `[Tentative]` on **ADR-004 (proposed)** — not yet approved.
**Scope note:** as-built discovery record from first-party Immich docs, plus a pending target overlay per AGENT-RULES §8. Facts already homed in BASELINE / the component spec / ADRs are cited by §/ID, not restated.

This is the file skeleton (`integration-contract-agent` Output schema); each fact written once. Canonical names per `core/GLOSSARY.md`. Ownership gate (ARCH-TARGET §5.2): the callee side is owned by the **ML Platform Owner** (`core/arch-processes/ownership-map.md`) — gate satisfied for target design.

---

## 1. As-built contract [Confirmed where documented]

### 1.1 Parties & interaction style

- [Confirmed] **Caller:** `immich-server` — the ML dispatch is one stage of the BullMQ job chain (Smart Search / Face Detection run after Thumbnail Generation; BASELINE §1.3/§1.4, ADR-002). **Callee:** `immich-machine-learning` (component-spec-immich-machine-learning; ADR-001 approved).
- [Confirmed] **Style: synchronous request/response, server-to-ML.** Each request carries the model-task metadata and the model name; the server calls and **waits** (`immich-architecture-overview.md:90`; BASELINE §1.3; ADR-001). An ML outage or backlog therefore **stalls the dependent jobs** (ADR-001 Constraints).

### 1.2 Transport

- [Confirmed] **HTTP**, provided by the callee's FastAPI app (`immich-architecture-overview.md:88`).
- [Confirmed] **Port 3003** when the callee is deployed remotely; the remote container exposes `3003:3003` (`immich-remote-machine-learning.md:35-36`; BASELINE §1.2).
- [Confirmed] **Synchronous per-request**, one model-task per call (§1.1).

### 1.3 Payload nature — wire schema is a gap

- [Confirmed] **Request payload nature:** `immich-server` sends **image previews** (user photo content) to the callee for processing, plus **the model-task metadata and model name** per request (`immich-remote-machine-learning.md:11`; `immich-architecture-overview.md:90`).
- [Confirmed] **Response payload nature:** model outputs — Smart Search **embeddings** and Face **Detection** results — returned to the caller for downstream persistence/use (derived from the offloaded-operations definition, `immich-remote-machine-learning.md:15`; component-spec Responsibilities).
- **[TBD] — exact wire schema is NOT published in the doc set.** No first-party document in `input/` gives the request/response body format, field names, content-type, encoding of the preview, or the embedding/detection output shape for **this** channel. Recorded as a schema gap, not invented.
- **[Confirmed] The OpenAPI note does NOT cover this channel.** The architecture overview's OpenAPI/DTO statements (`immich-architecture-overview.md:9,71`) describe the **client-to-server REST surface** — mobile/web/CLI auto-generate REST clients from the server's OpenAPI schema, and server DTOs become OpenAPI schemas. That machinery is the *client↔server* contract (BASELINE §1.3 first bullet, §4.1). The server↔ML channel is a **separate internal HTTP call** the ML section (`:88-92`) describes only by *contents* ("relevant metadata for the model task and the model name"), never by published schema. Verified: the OpenAPI coverage is not the ML channel's schema.

### 1.4 Caller-side behaviour [Confirmed]

- [Confirmed] **Multi-URL, sequential, no load distribution.** The admin panel accepts multiple ML URLs, but they are **processed sequentially with no load distribution**; the docs direct operators to "use a dedicated load balancer for better resource allocation across multiple containers" (`immich-remote-machine-learning.md:53`; BASELINE §1.2/§3.1). Scale-out across nodes is therefore an **operator-supplied** capability, not a stock caller behaviour (NFR-004; QA-5, R-03, OQ#1).
- [Confirmed] **No automatic fallback when remote-only; manual retry.** Replacing the local URL entirely **disables fallback**; if the remote becomes unavailable, **failed jobs must be retried manually** via the Job Status page (`immich-remote-machine-learning.md:51`). No automatic retry/back-off semantics for this channel are documented (see §3).

### 1.5 Configuration surface [Confirmed]

- [Confirmed] **ML URL registration is via the admin panel, not an env var in the doc set.** Remote ML hosts are registered by **"Add URL" in Machine Learning Settings** (`immich-remote-machine-learning.md:42-43`). **Note:** `IMMICH_MACHINE_LEARNING_URL` (named in the run brief) **does not appear anywhere in the committed doc set** — searched `input/`; not present. The documented configuration path for the *caller* side of this channel is the admin-panel URL list, not a server env var. Flagged, not invented.
- [Confirmed] **Callee-side tuning env vars** (all on the `machine learning` container; `immich-environment-variables.md:83-107`): `MACHINE_LEARNING_MODEL_TTL` (300 s), `MACHINE_LEARNING_MODEL_TTL_POLL_S` (10 s), `MACHINE_LEARNING_REQUEST_THREADS` (CPU-core count), `MACHINE_LEARNING_MODEL_INTER/INTRA_OP_THREADS` (1 / 2), `MACHINE_LEARNING_WORKERS` (1), `MACHINE_LEARNING_HTTP_KEEPALIVE_TIMEOUT_S` (2 s), `MACHINE_LEARNING_WORKER_TIMEOUT` (**300 s; 900 s for ROCm**), `MACHINE_LEARNING_DEVICE_IDS` (0), the `MACHINE_LEARNING_PRELOAD__*` model-preload set, and the acceleration toggles (`MACHINE_LEARNING_ANN`, `_RKNN`, `_OPENVINO_PRECISION`, `MACHINE_LEARNING_MAX_BATCH_SIZE__*`). These tune the **callee's** capacity and timeout behaviour; none specifies a channel-level request timeout on the **caller** side (BASELINE §3.4).
- [Confirmed] **ML can be disabled** entirely or by model type in Machine Learning Settings (`immich-faq-scaling-excerpts.md:43`; ADR-001) — the caller then does not exercise this channel for disabled model types.

### 1.6 Version alignment [Confirmed]

- [Confirmed] **Server and callee must be version-aligned** — mismatches "may cause bugs and instability," requiring synchronized updates (`immich-remote-machine-learning.md:47`; BASELINE §1.2). This is a **hard compatibility precondition of the contract**: the two parties are not independently versionable, which couples ML-tier upgrades to server upgrades (R-05; NFR-002; CON-001).

### 1.7 Offloadable operations vs the server-bound exception [Confirmed]

- [Confirmed] **Offloaded to the callee:** **Smart Search** (embeddings) and **Face Detection** (inference on previews) (`immich-remote-machine-learning.md:15`; GLOSSARY).
- [Confirmed] **NOT offloaded — the documented exception:** **Facial Recognition** clusters previously saved model outputs stored in Postgres — a **server-to-database** operation that stays server-side and never traverses this channel (`immich-remote-machine-learning.md:15`; BASELINE §1.2; component-spec Boundaries). It is out of this contract's scope by design and is not scaled by the target overlay (ADR-004 Scope boundary).

---

## 2. Security posture [Confirmed]

- [Confirmed] **No built-in authentication and no transport encryption on the channel.** The ML container "lacks built-in security measures"; the docs warn to use the remote option carefully on a public computer or paid processing cloud (`immich-remote-machine-learning.md:19`; BASELINE §1.2; OQ#3). The channel carries **image previews (user photo content)** over port 3003 with no auth or TLS the docs supply.
- [Confirmed] The callee **does not retain or associate data with users** (`immich-remote-machine-learning.md:11`) — a data-handling fact, not a channel control; it does not close OQ#3.
- **Target direction** [Tentative]: operator-supplied **authentication + TLS terminated at a reverse proxy fronting port 3003**, on an isolated network segment, delivered as an M1 pilot gate (**ADR-004, proposed**; NFR-006; ARCH-TARGET §3.5).

---

## 3. Target overlay [Tentative — all citing ADR-004, proposed]

The following are **proposed, unapproved** (ADR-004 is an unattended-run design proposal; no human approval). Written at `[Tentative]` per AGENT-RULES §8; the ADR's own status is the tracker.

- [Tentative] **LB-fronted dispatch.** The caller is configured with **one** ML URL — a TLS-terminating, auth-enforcing reverse proxy in front of an **operator-run load balancer** distributing across a dedicated tier of N stock `immich-machine-learning` containers; topology `server → proxy/LB → ML nodes` on an isolated segment (ADR-004 Option C; NFR-004; GLOSSARY "dedicated ML tier"). This **replaces** the stock sequential multi-URL behaviour (§1.4) with balanced dispatch the caller cannot do natively.
- [Tentative] **Health-checking expectation.** The LB is expected to **health-check** ML nodes and retry across them (NFR-004; ADR-004 Option C) — a capability the stock channel lacks (§1.4: manual retry only).
- [Tentative] **Version alignment widens.** N ML nodes must all stay version-aligned with the server inside the ≤15 min upgrade window — the overlay widens the §1.6 coupling into N-node upgrade choreography (ADR-004 Cons; NFR-002; R-05).

### 3.1 What the contract does NOT yet define (§4.4-style conventions)

Documented vs undefined on the semantics ARCH-TARGET §4.4 governs (error handling, idempotency, retry, delivery guarantees):

- **Timeout — partially documented (callee-side only).** `MACHINE_LEARNING_WORKER_TIMEOUT` = **300 s (900 s for ROCm)** bounds the **callee's** max unresponsiveness; `MACHINE_LEARNING_HTTP_KEEPALIVE_TIMEOUT_S` = **2 s** (`immich-environment-variables.md:90-91`). **No caller-side request timeout** for this channel is documented → **[TBD]**.
- **Retry — [TBD].** Only **manual** retry via the Job Status page when remote-only and the remote is down (§1.4). No automatic retry, back-off, or dead-letter convention is documented for the channel; the proposed LB retry (§3) is target, not stock.
- **Idempotency — [TBD].** No idempotency key, dedup, or safe-replay semantics are documented for re-dispatched ML jobs. Undefined; not invented.
- **Delivery guarantee — n/a to define here / [TBD].** Synchronous request/response with no documented at-least-once/exactly-once contract on the ML call itself; the enclosing job's re-run semantics live in the BullMQ layer (BASELINE §1.3), not this channel.
- **Wire schema / versioning — [TBD].** Per §1.3, no published body schema and no schema-version field; version compatibility is enforced coarsely by whole-image version alignment (§1.6), not by a per-message schema version.

These are recorded as **undefined conventions**, routed below — the design must settle them at ARCH-TARGET §4.4 before the channel is handed to engineering.

---

## 4. Contract gaps (routed)

Pointers only — defined at their register rows; not resolved here (D3/benchmark work):

- **OQ#2 / R-03 — throughput.** No per-asset inference time or assets/sec figure exists → the channel's capacity (and the LB tier size N) is unquantified; **NFR-003 benchmark gate** (ADR-004, binding open point) must measure per-asset inference time on pilot hardware **before** the 72 h / N commitment. This contract's dispatch design cannot be sized until then.
- **OQ#3 — security.** No built-in auth/TLS on the channel (§2); operator-supplied auth+TLS+isolation is the target (NFR-006, ADR-004 proposed) — a pilot gate, not yet delivered.
- **Wire-schema gap (§1.3).** No published request/response schema for this channel; blocks any contract test or schema-versioning convention (ARCH-TARGET §4.1/§4.3, both `[TBD]`). Candidate follow-up if upstream source (code) inspection is ever in scope — out of the first-party-docs evidence boundary (R-04).
- **§4.4 conventions undefined (§3.1).** Caller-side timeout, retry, idempotency, delivery-guarantee, and schema-versioning conventions are `[TBD]` — must be defined at ARCH-TARGET §4.4 as part of the ADR-004 realization.

---

## 5. Owner & consumers

- **Contract owner (callee side):** **ML Platform Owner** (demo role) — accountable for ML scale-out (external LB, throughput sizing) and unsecured-channel remediation (`core/arch-processes/ownership-map.md`; OQ#2/OQ#3, R-03).
- **Caller side:** **Immich Runtime Owner** (demo role) owns `immich-server`, its workers, and the version-alignment upgrade choreography this contract depends on (§1.6; R-05).
- **Consumers of the contract:** ADR-004 realization (ML tier / LB / proxy design), the handoff-agent (engineering package), and the fitness-review-agent (channel-hardening pilot gate).

---

## 6. Open questions

- Exact request/response wire schema for the channel (§1.3) — unpublished in the doc set; [TBD], evidence-bounded by R-04.
- Whether a caller-side request timeout exists (only callee `WORKER_TIMEOUT` documented; §3.1) — [TBD].
- Per-asset inference time and tier size N (OQ#2, benchmark gate) — [TBD] until measured.
- ADR-004 approval — the entire §3 overlay is proposed/unapproved; promotion `[Tentative]` → `[Confirmed]` on ADR approval (AGENT-RULES §8).
