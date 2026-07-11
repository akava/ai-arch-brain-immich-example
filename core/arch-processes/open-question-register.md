---
title: Open Questions Register (living)
type: open-questions-register
status: active
date: —
---

# Open Questions Register

The live registry of what is not yet known — `OQ#n` / `Q#n`, cited across the brain (`core/0.ARCH-METAMODEL.md` → Shared registries). Open questions only: a concluded question's row is **removed** — its answer lands where it belongs (ARCH-TARGET, an ADR, or via the register action that closed it). The brain is the record; no answered-questions archive is kept here.

1. **Multi-node / high-availability posture is undocumented.** The D1 first-party doc set describes only the single-container default and the env-var worker split (`immich-server` + optional `immich-microservices`). It does not address running Immich across multiple nodes, replica coordination, HA of Postgres or Redis, or shared-storage assumptions for the media file system. This gap is material to the managed-hosting availability goal (`core/1.ARCH-CONTEXT.md` → Problem statement) and needs external evidence beyond this doc set. (Opened 2026-07-11 D1; source: `core/artifacts/logs/2026-07-11-immich-architecture-overview-synthesis.md` T5, C1; no tracking action yet.)

2. **ML-inference throughput remains unquantified** (hardware floors now documented). `immich-machine-learning` is documented as memory-intensive and separately deployable. **Partially answered by D2:** hardware *floors* for GPU acceleration are now on record — CUDA compute capability 5.2+ and driver ≥ 545, ROCm ≥ 35 GiB disk, RKNN 2–3 threads for RK3576/RK3588, multi-GPU via `MACHINE_LEARNING_DEVICE_IDS`/`MACHINE_LEARNING_WORKERS` (BASELINE §3.4). **Still open:** per-node/per-GPU throughput, concurrency limits, and memory footprint per model — no figures exist to size hosting capacity. Material to the D3 ML-throughput scale-up target and R-03. (Opened 2026-07-11 D1, source: `2026-07-11-immich-architecture-overview-synthesis.md` T4; partial answer 2026-07-11 D2, source: `2026-07-11-immich-ml-media-deep-dive-synthesis.md`. Resolution needs telemetry/benchmarking beyond the first-party doc set.)

3. **Remote-ML channel has no built-in security or transport protection.** When `immich-machine-learning` runs on a separate host, the server sends **image previews** (user photo content) to it over port 3003, and the docs state the ML container "lacks built-in security measures," warning against public/paid-cloud placement without added protection (`input/systems/immich/immich-remote-machine-learning.md`; BASELINE §1.2). In a managed-hosting topology where the ML tier is a separate scaling unit, this leaves the operator to supply auth, transport encryption, and network isolation — none of which the docs specify. Material to the managed-hosting security posture; needs an operator-side control design (candidate risk-register/NFR follow-up). (Opened 2026-07-11 D2; source: `core/artifacts/logs/2026-07-11-immich-ml-media-deep-dive-synthesis.md`.)
