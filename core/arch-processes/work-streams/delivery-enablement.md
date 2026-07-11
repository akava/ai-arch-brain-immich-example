# Delivery Enablement (tactical stream)

**Code:** `tactical` · **Populates:** `core/transitions/M1-managed-hosting-pilot.md` (active) · **Horizon:** now.
**Goal:** keep the active delivery phase unblocked and on the rails of the target architecture. The phase content itself — scope, deltas, gates — is the transition file (the deliverable); this stream tracks the work of executing and keeping it current.

This file is re-pointed (or re-instantiated) per active transition `Mn`: when a transition closes and the next opens, update the Populates line and reset the status below.

## Work status

Active transition **M1 — Managed-Hosting Pilot** (`core/transitions/M1-managed-hosting-pilot.md`, status `active`). The stream owns chasing its Open / watch items:

- **AI-001** — NFR-003 benchmark disposition; gates E-02's benchmark acceptance criterion. Checkpoint 2026-07-18.
- **OQ#1 / OQ#2 / OQ#3** — store HA/failover path (E-01), ML throughput sizing (E-02 benchmark), remote-ML channel security (E-02 hardening); each needs evidence/design beyond the first-party doc set.
- **ADR-003 / ADR-004 / ADR-005** — all `proposed`; the transition's deltas are `[Tentative]` against them. The `active` → `delivered` flip and any baseline promotion are the architect's call on approval (`core/AGENT-RULES.md` §9).

Cross-stream gating: TARGET §5 (binding-gate section) is a stub — populating it is architect-approved content work in the Target Architecture stream, not an M1 deliverable.
