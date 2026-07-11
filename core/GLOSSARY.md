# GLOSSARY.md — Canonical Terminology

## Purpose

`GLOSSARY.md` is the source of truth for **how terms are named and what they mean** in this brain. It exists to stop terminology drift — the same system, technology, or concept being written under different names across inputs and artifacts (e.g., "order-service" vs "Order Service API", "PostgreSQL" vs "the orders database").

Agents consult this file to use canonical names and to recognise variants. When an agent meets a term that is undefined here, or that conflicts with a canonical entry, it must **raise an ambiguity flag rather than silently pick a spelling** (see `core/AGENT-RULES.md` → Terminology consistency rule).

This file governs naming. It does not replace `core/3.ARCH-TARGET.md` (system rules) or `core/1.ARCH-CONTEXT.md` (project facts).

---

## Status convention

Reuses the `core/0.ARCH-METAMODEL.md` convention:

- **`confirmed`** — canonical name and meaning verified by an authoritative source or the architect.
- **`tentative`** — in use but not yet ratified; may change.
- **`ambiguous`** — meaning or correct form is unresolved; flagged for the architect.
- **`deprecated`** — an incorrect or superseded label; do not use (kept so old references stay traceable).

---

## How this file is maintained

- **The `synthesis` agent** (reads raw input) is the primary capture point: it adds new terms, records variants with provenance, and flags ambiguities.
- **The `component-spec` / `integration-contract` agents** add or confirm terms they coin (component and contract names).
- **The `decision-record` agent** (ADR) is the promotion authority when a term encodes a real technology/architecture choice; pure spelling/naming is confirmed by the architect.
- **When to propose promotion.** A `tentative` term is proposed for `confirmed` once it recurs in a second independent session's synthesis, or enters a proposed ADR, an ARCH-TARGET entry, or a living artifact. Proposals are batched into the `fitness-review` brain-hygiene step; promotion itself stays the architect's call.
- Immutable ADRs that used an old variant are **not** edited — the **Variants seen** column keeps them traceable to the canonical term.

---

## Canonical terms

> TODO: Populate as terms are captured. Each row carries: the **canonical** term (bold, the one spelling every artifact uses), the **variants seen** in sources (transcript spellings, diagram labels, aliases — with a note on where each was seen), a concise **definition** at the right altitude (what it is, where it sits, what it is distinct from), its **status** (per the convention above, ideally with the date and who confirmed it), and the **source / owner** (the session, document, ADR, or architect ruling the entry traces to).

| Canonical | Variants seen | Definition | Status | Source / owner |
|-----------|---------------|------------|--------|----------------|
| **Immich** | — | Self-hosted photo and video management platform; the system-of-interest of this engagement. Client-server architecture, AGPL v3. | tentative | 2026-07-11 D1 synthesis; `input/systems/immich/immich-repo-readme.md` |
| **immich-server** | "Immich Server", "the server", "the backend" | The Nest.js/Node.js backend container: serves the REST API and runs the background-job workers. Follows hexagonal architecture. | tentative | 2026-07-11 D1 synthesis; `input/systems/immich/immich-architecture-overview.md` |
| **immich-machine-learning** | "the ML service", "machine learning service" | Python/FastAPI service to which all ML operations are externalized; runs ONNX models; separately deployable or disableable. | confirmed | 2026-07-11 ADR-001 (approved); `input/systems/immich/immich-architecture-overview.md` |
| **api worker** | "api" (worker) | Worker inside `immich-server` that responds to API requests for data and files from the web and mobile clients. | confirmed | 2026-07-11 ADR-002 (approved); `input/systems/immich/immich-jobs-and-workers.md` |
| **microservices worker** | "microservices", `immich-microservices` (as the split-out container / diagram label) | Worker inside `immich-server` that handles background jobs (e.g. thumbnail generation, video encoding). Runs in the same container as the api worker by default; can be split into a separate `immich-microservices` container via env vars. | confirmed | 2026-07-11 ADR-002 (approved); `input/systems/immich/immich-jobs-and-workers.md` (see synthesis C1) |
| **split workers** | "worker split", "separate API and microservices containers" | Optional deployment configuration distributing the api and microservices workers across separate containers via `IMMICH_WORKERS_INCLUDE` / `IMMICH_WORKERS_EXCLUDE`. | confirmed | 2026-07-11 ADR-002 (approved); `input/systems/immich/immich-jobs-and-workers.md` |
| **BullMQ** | — | Library used over Redis to manage Immich's background-job queues, including job chaining. | confirmed | 2026-07-11 ADR-002 (approved); `input/systems/immich/immich-architecture-overview.md` |
| **Redis** (job-queue role) | "redis" (container) | In-memory store used via BullMQ for background-job queue management; holds queue state. | confirmed | 2026-07-11 ADR-002 (approved); `input/systems/immich/immich-architecture-overview.md` |
| **Postgres** (system-of-record role) | "postgres" (container), "the database" | Persistent data store for access/authorization, users, albums, assets, sharing, and ML model settings; Immich's system of record. | tentative | 2026-07-11 D1 synthesis; `input/systems/immich/immich-architecture-overview.md` |
| **ONNX** | — | Open model-exchange format in which all Immich ML models are stored, chosen for wide support and performance. | confirmed | 2026-07-11 ADR-001 (approved); `input/systems/immich/immich-architecture-overview.md` |
| **hexagonal architecture** (Immich usage) | "ports and adapters" | Structural principle of the `immich-server` codebase: separates technology-specific implementations (`src/repositories`) from core business logic (`src/services`). | tentative | 2026-07-11 D1 synthesis; `input/systems/immich/immich-architecture-overview.md` |

---

## Ambiguous / to-confirm

> TODO: Populate as ambiguities are flagged. Each row carries: the **term as seen** (the exact wording from the source), the **likely meaning** — including what conflicts (two candidate meanings, two spellings for one thing, or an unknown expansion) and what would resolve it (who to ask, which session or document would settle it), its **status** (`ambiguous — confirm with client`, or `resolved` with a pointer to the canonical row it became), and the **source** where the term appeared.

| Term as seen | Likely meaning | Status | Source |
|--------------|----------------|--------|--------|

---

## Deprecated / incorrect labels

> TODO: Populate as incorrect or superseded labels are ruled on. Each row carries: the deprecated **label**, the canonical term to **use instead**, and the **reason** it is wrong or superseded (mislabelled diagram, transcript spelling, an option evaluated but not selected).

| Label | Use instead | Reason |
|-------|-------------|--------|
