---
type: stakeholder-brief
session: D3 — managed-hosting scale-up design
date: 2026-07-11
provenance: simulated engagement fiction (demo) — architect-authored session brief carrying the
  fictional client's stated pilot targets and ownership assignments; all facts about Immich come
  from the first-party documentation filed under input/systems/immich/
---

# D3 brief — managed-hosting scale-up design (simulated)

Discovery (D1, D2) established the as-is picture. D3 is the design session: turn the client's
pilot ambitions into validated targets, design decisions, and a pilot enablement package.

## Client-stated pilot targets (fictional client asks — to be validated, not assumed feasible)

- **Pilot shape**: up to 50 isolated customer instances (one Immich deployment per customer).
- **Media scale**: up to 5 TB media per instance.
- **Availability**: 99.9% monthly per instance for the API/serving path.
- **Upgrades**: planned-upgrade downtime ≤ 15 minutes per instance.
- **ML onboarding**: an initial import of 1M assets should drain its ML backlog within 72 hours.
- **Security**: the ML channel must be authenticated and encrypted before pilot (raised from OQ#3).

The client understands targets may be re-scoped by the analysis; unvalidated ones stay tentative.

## Ownership assignments (client-confirmed, role-level)

- Hosting platform (Postgres / Redis / storage HA): **Hosting Platform Lead (demo)**
- Immich runtime (server, workers, upgrades): **Immich Runtime Owner (demo)**
- ML tier (immich-machine-learning): **ML Platform Owner (demo)**

## Questions for this session

1. What does first-party guidance say about scaling Immich (the scaling guide, kubernetes/compose
   options, environment variables), and where does it stop short of the pilot targets?
2. How should the stateful stores (Postgres, Redis, media storage) be operated to meet the
   availability target, given upstream documents no HA path (OQ#1, R-01)?
3. How should the ML tier scale to the onboarding target, given sequential-no-LB dispatch and
   unquantified throughput (OQ#2, R-03, QA-5)?
4. What storage strategy fits 50 × 5 TB (filesystem semantics, backup/restore guidance)?
5. What upgrade procedure respects migrations-at-startup and version-alignment (R-05, QA-2)
   within the 15-minute window?
6. Which decisions must be recorded now (proposed ADRs), and what enablers does the pilot need?

## Expected outputs

Requirement targets landed in the registry; ARCH-TARGET populated (status-tagged); proposed design
ADRs; the server↔ML integration contract; transition M1 (pilot enablement) with its enabler
package; a DRAFT handoff. Design decisions remain proposed until human review — nothing in this
simulated run is client-approved delivery.

## Ground rules

Unchanged: first-party documentation only for Immich facts; client asks above are engagement
fiction and must be labeled as such where cited; gaps surface, never fill.
