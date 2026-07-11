---
title: Immich Managed-Hosting Scale-Up — D3 Risk-Register Reconciliation
date: 2026-07-11
type: risk-assessment
run: 2026-07-11-immich-scale-up-design
agent: risk-assessment-agent (SKILL-006)
status: active
confidence: high
---

# Immich Managed-Hosting Scale-Up — D3 Risk-Register Reconciliation

**Purpose/verdict:** Execute the four risk-routing proposals (RR-1..RR-4) + OQ#3 cross-link fix + one action row, all architect-approved from the D3 fitness review (`logs/2026-07-11-immich-scale-up-design-fitness-review.md` F9/F10/F11). The register never absorbed the D3 outputs (standalone risk run was deliberately skipped that session); this run lands them. No new risks discovered beyond the routed set.
**Counts:** 3 rows updated (R-01/R-03/R-05), 1 new row (R-06), 1 OQ cross-link fixed, 1 action row added (AI-001).
**Authority:** every change traces to a fitness-review routing proposal + the architect's explicit approval this session (session D3). No invention — ratings/links reuse the review's evidence and the proposed ADRs.
**Hand-offs:** librarian indexes this new log + bumps artifacts INDEX total 14→15 (main-loop).

---

## Register changes

- **R-01** (RR-1, F9): `open → mitigating`. Mitigation = [[ADR-003]] (proposed) per-instance HA Postgres/Redis + ARCH-TARGET §3.3. Conditionality kept explicit — ADR proposed not approved, failover drill is a pilot gate, not resolved until validated. Fired trigger refreshed to "ADR-003 approval / M1 failover-drill gate."
- **R-03** (RR-2, F9): `open → mitigating`. Mitigation = [[ADR-004]] (proposed) dedicated ML tier + the NFR-003 benchmark gate. Row now cites NFR-003 honestly — [TBD], no per-asset inference figure, 72h/1M **not** committed. Links NFR-003 / OQ#2. Fired trigger refreshed to "NFR-003 benchmark-gate result."
- **R-05** (RR-3, F9): stays `open` (design not yet validated against the 15-min upgrade window). Added cross-links [[CON-001]] + [[ADR-003]]/[[ADR-004]] (both proposed) + NFR-002 co-constraint — the upgrade-path tension is now bounded by a recorded constraint and two proposed decisions.
- **R-06** (RR-4, F9 — NEW): unsecured server↔ML channel (port 3003, user photo previews, no auth/no TLS). **L medium / I high → severity high.** Rating rationale: exposure likely absent an added control but the ML tier's network placement is operator-controllable (medium); user-photo/PII disclosure or tampering (high). `mitigating` via [[ADR-004]] auth+TLS-at-reverse-proxy hardening, gated **before pilot**. Owner = ML Platform Owner (demo, per ownership-map — role explicitly owns OQ#3 remediation, §5.2 gate satisfied). Links NFR-006 / OQ#3. Evidence: OQ#3, NFR-006, integration-contract §2, baseline §1.2.
- Frontmatter `sources` extended with this log + the fitness review.

## OQ register fix

- **OQ#3** (F11 stale cross-link): parenthetical "candidate risk-register/NFR follow-up" replaced in place with "now tracked as risk R-06 and requirement NFR-006; hardening direction set by ADR-004 (proposed)." Row body otherwise untouched — OQ#3 stays open (design not yet built/validated).

## Action register

- **AI-001** added (AR-1, F10): "Decide the NFR-003 disposition — benchmark before committing 72h/1M, or re-scope/gate in M1." Owner Simulated architect (demo); checkpoint 2026-07-18; status open; links NFR-003 / OQ#2 / R-03 / [[ADR-004]]; trigger "benchmark results or M1 scoping." The ADR-recording + pilot-gate to-dos correctly got no row (ADR self-tracks per §8; gates belong to the not-yet-created M1).
