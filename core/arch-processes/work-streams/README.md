# Work streams — the process side of the core deliverables

Three work streams organise the architecture work. Each maps **1:1 to a core deliverable, but the purpose is different**: the stream is the **process** — its goal is to populate and keep current its core counterpart; the core file is the **deliverable** — the facts. Stream files hold goals, work status, and blockers, and **link, never restate**: every durable fact lands in the layer the stream populates.

| Stream | Code | Populates (the deliverable) | File |
|--------|------|-----------------------------|------|
| **Architecture Review** | `baseline` | `core/2.ARCH-BASELINE.md` | `architecture-review.md` |
| **Target Architecture** | `target` | `core/3.ARCH-TARGET.md` (+ `core/decisions/`) | `target-architecture.md` |
| **Delivery Enablement** | `tactical` | the active transition file in `core/transitions/` | `delivery-enablement.md` |

Cross-cutting constraints gating all three (e.g. access or capacity) are recorded in `../operating-model.md`.
