# Decision Index

This file is the canonical registry of all Architecture Decision Records.

ADR files are immutable once created.
Lifecycle changes are tracked here.

---

## Registry

| ADR | Title | Date | Status | Severity | Supersedes | Superseded By | Author |
|-----|-------|------|--------|----------|------------|---------------|--------|
| ADR-002 | As-built: background work runs on Redis/BullMQ job queues; api + microservices workers co-located in one `immich-server` container by default, splittable via `IMMICH_WORKERS_INCLUDE`/`EXCLUDE` — worker split is the sanctioned scaling lever (R-02); Redis is availability-critical queue state (R-01). | 2026-07-11 | approved | MINOR | — | — | Simulated architect (demo) |
| ADR-001 | As-built: ML inference isolated in the separate stateless `immich-machine-learning` (Python/FastAPI + ONNX) service, called synchronously over HTTP — enables independent ML scaling/sizing and memory isolation from the serving path (R-03). | 2026-07-11 | approved | MINOR | — | — | Simulated architect (demo) |
| ADR-000 | Template | — | template | — | — | — | — |

---

## Status Definitions

| Status | Meaning |
|--------|---------|
| proposed | Decision documented and awaiting approval |
| approved | Decision approved and active |
| superseded | Replaced by a newer decision |
| deprecated | No longer applicable to the current project state |
| template | Template entry only |

---

## Lifecycle Rules

- Do not edit an **approved** ADR file; an approved ADR is immutable — supersede it with a new ADR. A **proposed** (not-yet-approved) ADR is a self-sufficient draft and may be reworked in place (a dated revision note in the ADR suffices — in-body notes keep ADRs portable outside git), done deliberately rather than often
- Record status changes in this index
- **Status-label sync (not a decision change).** The `Status:` line in an ADR body mirrors this registry. When this registry changes an ADR's status, sync the body label to match and add a dated revision note. A label-only sync does not breach immutability; the decision content is never edited, and this registry stays canonical
- When superseding an ADR, create a new ADR and update both rows in this table
- If an ADR changes `core/1.ARCH-CONTEXT.md` or `core/3.ARCH-TARGET.md`, update those files separately
