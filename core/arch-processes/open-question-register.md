---
title: Open Questions Register (living)
type: open-questions-register
status: active
date: —
---

# Open Questions Register

The live registry of what is not yet known — `OQ#n` / `Q#n`, cited across the brain (`core/0.ARCH-METAMODEL.md` → Shared registries). Open questions only: a concluded question's row is **removed** — its answer lands where it belongs (ARCH-TARGET, an ADR, or via the register action that closed it). The brain is the record; no answered-questions archive is kept here.

1. **Multi-node / high-availability posture is undocumented.** The D1 first-party doc set describes only the single-container default and the env-var worker split (`immich-server` + optional `immich-microservices`). It does not address running Immich across multiple nodes, replica coordination, HA of Postgres or Redis, or shared-storage assumptions for the media file system. This gap is material to the managed-hosting availability goal (`core/1.ARCH-CONTEXT.md` → Problem statement) and needs external evidence beyond this doc set. (Opened 2026-07-11 D1; source: `core/artifacts/logs/2026-07-11-immich-architecture-overview-synthesis.md` T5, C1; no tracking action yet.)

2. **ML-inference throughput and hardware sizing are unquantified.** `immich-machine-learning` is documented qualitatively as memory-intensive and separately deployable, but the doc set gives no throughput figures, concurrency limits, or hardware/GPU requirements. Material to the D3 ML-throughput scale-up target. (Opened 2026-07-11 D1; source: `core/artifacts/logs/2026-07-11-immich-architecture-overview-synthesis.md` T4; planned D2 ML deep dive is the expected resolution path.)
