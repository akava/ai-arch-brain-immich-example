---
title: Component Spec — immich-machine-learning
type: component-spec
agent: component-spec-agent (SKILL-002)
status: active
confidence: high
---

# Component Spec — immich-machine-learning

**Type:** service (Python/FastAPI, ONNX inference)
**Responsibility (single):** run all externalized ML inference for Immich — Smart Search embeddings and Face Detection — exposed over HTTP, called synchronously by `immich-server`.
**Verdict:** as-built spec of the component the scale-up most depends on. Stateless service, isolated per **ADR-001** (approved). Cleanly separable and independently sizeable, but scale-out is **not turnkey**: sequential multi-URL processing with **no built-in load balancing**, **no built-in security** on a channel that carries user photo content, and **no quantified per-node throughput**. Every hosting-relevant gap is pointed at its OQ/R row, not resolved here (D3 work).
**Scope note:** AS-IS discovery record from first-party Immich docs. Does not design the target; ARCH-TARGET untouched.

This is the file skeleton (`component-spec-agent` Output schema); each fact written once. Canonical names per `core/GLOSSARY.md`. Facts already homed in `core/2.ARCH-BASELINE.md` are cited by §, not restated.

## Responsibilities

- [Confirmed] **Smart Search** — generates search embeddings for uploaded assets; offloadable to a remote ML host (`input/systems/immich/immich-remote-machine-learning.md:15`).
- [Confirmed] **Face Detection** — detects faces in image previews; offloadable to a remote ML host (`immich-remote-machine-learning.md:15`).
- [Confirmed] For each request, the service downloads/loads/configures the named model, then processes the request payload; loaded models are cached and reused across requests; a thread pool runs inference off the async event loop (`input/systems/immich/immich-architecture-overview.md:90`; ADR-001).
- [Confirmed] All ML operations are externalized to this one service; it can be deployed separately from `immich-server` or disabled entirely (`immich-architecture-overview.md:88`; ADR-001).

### Boundaries (what it does NOT do)

- [Confirmed] **Facial Recognition is server-bound — the documented exception.** Facial Recognition reads previously saved model outputs stored in Postgres, making it a server-to-database operation; it does **not** use the (remote) ML service (`immich-remote-machine-learning.md:15`; BASELINE §1.2). Face **Detection** (inference) and Facial **Recognition** (DB-bound clustering of stored outputs) are distinct steps — see `core/GLOSSARY.md`.
- [Confirmed] Holds no durable server-side state; owns no application data. Model **settings** persist in Postgres, owned by `immich-server` (`immich-architecture-overview.md:90`; ADR-001).
- Does not schedule or enqueue its own work — it is invoked synchronously by the caller (see Interface); job orchestration is `immich-server` + Redis/BullMQ (BASELINE §1.3).
- Does not video-transcode — hardware **transcoding** is a separate `immich-server`-side concern (`core/GLOSSARY.md`; BASELINE §2, §3.4), distinct from ML hardware acceleration.

## Interface

- [Confirmed] **Protocol:** HTTP; the service uses FastAPI for HTTP communication (`immich-architecture-overview.md:88`).
- [Confirmed] **Port:** 3003 when deployed remotely (`immich-remote-machine-learning.md:35-36`).
- [Confirmed] **Call pattern:** synchronous, server-to-ML. Each request carries the model-task metadata and model name; `immich-server` calls the service and waits (`immich-architecture-overview.md:90`; BASELINE §1.3; ADR-001).
- [Confirmed] **Payload:** `immich-server` sends **image previews** to the (remote) container for processing (`immich-remote-machine-learning.md:11`).
- [Confirmed] **Multi-URL / no load balancing:** the admin panel accepts multiple ML URLs, but they are **processed sequentially with no load distribution**; an external load balancer is required to spread work across multiple ML containers (`immich-remote-machine-learning.md:53`; BASELINE §1.2).
- [Confirmed] **Remote-only / fallback:** replacing the local URL entirely disables fallback; if the remote is unavailable, failed jobs must be retried manually via the Job Status page (`immich-remote-machine-learning.md:51`).
- No standalone integration contract exists yet; a `integration-contract-server-to-ml` contract is the natural follow-up (see Open questions / spec-update).

## State model

- [Confirmed] **Stateless service** (ADR-001, approved). No durable server-side state; the service downloads, loads, and caches models in-process (`immich-architecture-overview.md:90`; ADR-001).
- [Confirmed] **Local model cache:** loaded models are cached and reused across requests; in the remote deployment a `model-cache` volume backs the cache (`immich-architecture-overview.md:90`; `immich-remote-machine-learning.md:32-38`). The cache is ephemeral warm state, not a system of record — losing it forces re-download/reload, not data loss.
- [Confirmed] **Models:** ONNX format; large and memory-intensive (`immich-architecture-overview.md:92`; `core/GLOSSARY.md`).
- [Confirmed] **Model settings** live in Postgres, not in this service (`immich-architecture-overview.md:90`) — reconfiguring models is a server/DB concern.

## Deployment modes

- [Confirmed] **Co-located (default):** runs as an individual Docker container alongside `immich-server`, `postgres`, `redis` (`immich-architecture-overview.md:48`; BASELINE §1.2, §2).
- [Confirmed] **Remote tier:** runs on a separate, more powerful host to relieve resource-limited systems; deployed via its own `docker-compose.yml`, reached over HTTP on port 3003; registered by adding its URL in Machine Learning Settings (`immich-remote-machine-learning.md:11,22-43`; BASELINE §1.2).
- [Confirmed] **Disable-able:** ML can be disabled entirely (`immich-architecture-overview.md:88`; ADR-001).
- [Confirmed] **Version alignment required:** server and remote-ML hosts must be version-aligned — mismatches may cause bugs and instability, requiring synchronized updates (`immich-remote-machine-learning.md:47`; BASELINE §1.2). **Hosting-relevant:** couples ML-tier upgrades to server upgrades (ties to the stock-upgrade-path tension, R-05).

## Hardware acceleration matrix (experimental)

[Confirmed] GPU acceleration of Smart Search and Facial Recognition is **experimental**, enabled via the `hwaccel.ml.yml` compose file, and supported **only on Linux and Windows-via-WSL2** (`input/systems/immich/immich-ml-hardware-acceleration.md:9,21-22,65`; BASELINE §2). Five backends with documented floors:

| Backend | Vendor | Documented floor / note | Evidence |
|---------|--------|-------------------------|----------|
| ARM NN | Mali GPUs | Mali GPUs only; `/dev/mali0` + closed-source `libmali.so` required; does not improve search latency (jobs do benefit) | `immich-ml-hardware-acceleration.md:13,25,29-33` |
| CUDA | NVIDIA | Compute capability **5.2+**, NVIDIA driver **≥ 545** (CUDA 12.3); most reliable backend | `immich-ml-hardware-acceleration.md:14,24,36-38` |
| ROCm | AMD | **≥ 35 GiB free disk**; MIGraphX compiles at runtime → **slow initial inferences**; new backend, may raise power draw | `immich-ml-hardware-acceleration.md:15,44-46` |
| OpenVINO | Intel | Discrete GPUs more reliable than integrated; **higher RAM** than CPU; WSL variant needs `/dev/dri` | `immich-ml-hardware-acceleration.md:16,48-55` |
| RKNN | Rockchip | SoCs RK3566/3568/3576/3588; RKNPU driver ≥ V0.9.8; `MACHINE_LEARNING_RKNN_THREADS` **2–3** for RK3576/3588 | `immich-ml-hardware-acceleration.md:17,57-61` |

- [Confirmed] **Floors, not throughput.** These are minimum-viability requirements; per-node throughput, concurrency, and per-model memory remain **unquantified** (→ **OQ#2**, **R-03**). Concurrency is tunable for utilisation but raises VRAM (`immich-ml-hardware-acceleration.md:94-95`; BASELINE §3.4).

## Scaling levers (documented today)

- [Confirmed] **Multi-GPU on one node:** `MACHINE_LEARNING_DEVICE_IDS` (comma-separated device list) + `MACHINE_LEARNING_WORKERS` (device count) spread work across GPUs (`immich-ml-hardware-acceleration.md:85`; BASELINE §2).
- [Confirmed] **Scale-out across nodes:** register multiple remote ML URLs — but they run **sequentially with no load distribution**, so an **external load balancer is required** to actually spread work (`immich-remote-machine-learning.md:53`; BASELINE §1.2). **Hosting-relevant:** scale-out is an operator-supplied capability, not a stock feature — points at OQ#2 (throughput unquantified) and R-03.
- No documented replica-count, autoscaling, or orchestration guidance beyond the above; multi-node/HA posture is undocumented estate-wide (OQ#1).

## Security posture

- [Confirmed] **No built-in auth or transport protection on the ML channel.** The ML container lacks built-in security measures; the docs warn to use the remote option carefully on a public computer or a paid processing cloud (`immich-remote-machine-learning.md:19`; BASELINE §1.2). The channel carries **image previews (user photo content)** over port 3003 with no auth the docs supply. **Hosting-relevant, unresolved → OQ#3** — operator must supply the controls; this spec does not design them.
- [Confirmed] The remote container **does not retain or associate data with users** (`immich-remote-machine-learning.md:11`) — a data-handling fact, not a channel control.

## Open gaps

Pointers only — defined at their register rows; not resolved here (D3 work per the engagement brief):

- **OQ#2 / R-03** — per-node ML throughput, concurrency, and per-model memory are **unquantified**; hardware *floors* exist but supply no sizing numbers (BASELINE §3.4).
- **OQ#3** — remote-ML channel has no built-in security/transport protection (see Security posture).
- **OQ#1** — multi-node/HA posture undocumented estate-wide; bears on how the ML tier is made resilient behind the required external LB.
- **R-05** — version-alignment requirement couples ML-tier upgrades to the server, feeding the stock-upgrade-path tension.
- **Interface contract gap** — no server-to-ML integration contract artifact yet (request/response schema, error/timeout/retry semantics on the synchronous call). Candidate `integration-contract-agent` follow-up.
- **Ownership gap** — `core/arch-processes/ownership-map.md` is unpopulated; no accountable owner is registered for this component. Per ARCH-TARGET §5.2 the ownership gate binds **target design** work — this AS-IS discovery spec proceeds (as ADR-001 did), but a registered owner is required before this component is carried into D3 design/handoff. Flagged, not resolved.

## Assumptions

- None load-bearing. Every fact above is first-party-doc- or ADR-cited; unquantified items are flagged as gaps, not filled.

## ARCH-TARGET impact

**spec_update_required: no** — this is an AS-IS discovery spec; per ADR-001 and the engagement brief, target adoption of the ML tier (independent sizing, LB fronting, channel hardening) is D3 work. No `core/3.ARCH-TARGET.md` entry is written now. When D3 opens, this spec plus OQ#2/OQ#3 resolutions feed ARCH-TARGET §1.2 (building block), §3.4 (capacity), §3.5 (security), and §6 (deployment).
