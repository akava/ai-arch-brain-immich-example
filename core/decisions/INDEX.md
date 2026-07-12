# Decision Index

This file is the canonical registry of all Architecture Decision Records.

ADR files are immutable once created.
Lifecycle changes are tracked here.

---

## Registry

| ADR | Title | Date | Status | Severity | Supersedes | Superseded By | Author |
|-----|-------|------|--------|----------|------------|---------------|--------|
| ADR-007 | Fleet observability & health for managed instances: adopt an operator-run **central fleet observability plane** — Prometheus-compatible scrape of every instance's opt-in metrics (8081 API / 8082 microservices; groups `api`/`host`/`io`, enabled fleet-wide via `IMMICH_TELEMETRY_INCLUDE`), central shipping + defined retention of the JSON log stream (`IMMICH_LOG_FORMAT=json`), operator-built synthetic health probes + container healthchecks (upstream ships only a one-shot `.immich` startup marker-file check, no liveness/readiness, no healthcheck page — 404), and alerting rules tied to NFR-001's error budget — with per-instance data segregated per the isolated-instance philosophy (ADR-003 alignment). Chosen over per-instance ad-hoc/complaint-driven monitoring (A, fails 99.9% detection) and a full APM/end-to-end tracing platform (C, docs support metrics export only — no documented per-request tracing/span export). Front-door proxy `600s`/`50000M` settings become alerting-relevant thresholds (T26). Partially resolves OQ#5 (log routing/retention decided; container-health probe design remains M1 build work); detection window [TBD] at the pilot gate (T24–T27, BASELINE §3.2). | 2026-07-12 | proposed | MAJOR | — | — | Simulated architect (demo) |
| ADR-006 | Per-customer identity federation: per-instance OIDC to each customer's own IdP (documented issuer/client/scope + `immich_role`/`immich_quota`/`preferred_username` claim mappings), with password login retained for break-glass/admin fallback — chosen over local-accounts-only (no SSO) and an operator-central IdP (shared cross-tenant identity SPOF, ADR-003 blast-radius rejection). Requires an operator R-07 drift-reconciliation procedure (claims applied at creation only, never re-synced) and an R-08 lockout/break-glass runbook via immich-admin; R-09 quota/external-libraries caveat and OQ#4 session/API-key gap left open (T19–T23, BASELINE §1.6). | 2026-07-12 | proposed | MAJOR | — | — | Simulated architect (demo) |
| ADR-005 | Pilot media storage & backup: per-instance media volumes on supported (non-NTFS/FAT) filesystems + operator snapshot/replication media backup honoring the documented DB-first-then-filesystem consistency ordering; stock DB dumps retained + copied off-instance; shared network pool rejected for the pilot (cross-instance blast radius); object storage excluded as undocumented (NFR-005, T14/T18). | 2026-07-11 | proposed | MAJOR | — | — | Simulated architect (demo) |
| ADR-004 | ML scale-out & channel hardening: dedicated remote-ML tier behind an operator-run health-checked load balancer, auth+TLS terminated at a reverse proxy fronting port 3003 (docs: sequential no-LB dispatch, external LB required, no built-in security); NFR-003 benchmark gate open — tier size N and the 72 h commitment wait on measured per-asset inference time; Facial Recognition stays server-bound, out of scope (NFR-003/004/006, R-03, OQ#2/3). | 2026-07-11 | proposed | MAJOR | — | — | Simulated architect (demo) |
| ADR-003 | Stateful-store HA for the pilot: operator-managed per-instance HA Postgres/Redis (endpoint-transparent; stock containers untouched) recommended over single-node+fast-restore (budget-race) and shared cross-instance HA pools (T14 SPOF / blast radius) for NFR-001's ≤43.8 min/month budget; failover drill is a pilot gate; media store → ADR-005 (R-01, OQ#1, CON-001). | 2026-07-11 | proposed | MAJOR | — | — | Simulated architect (demo) |
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
