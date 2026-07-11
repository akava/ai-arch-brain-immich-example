---
title: Immich Managed-Hosting Scale-Up — D1 Risk Assessment
date: 2026-07-11
type: risk-assessment
run: 2026-07-11-immich-architecture-overview
skill: risk-assessment-agent (SKILL-006)
status: active
confidence: medium
---

# Immich Managed-Hosting Scale-Up — D1 Risk Assessment

**Purpose:** surface the initial architecture risks for the managed-hosting goal from the D1 as-is picture (docs-only), seeding the living register.
**Verdict:** the documented as-is is single-node-oriented; the engagement goal is commercial-grade multi-tenant hosting. The gap concentrates in stateful HA, worker/ML co-location under load, and the evidence base itself.
**Rows added:** 5 (R-01…R-05) to `core/artifacts/risk-register.md` — rows live there, not restated here.
**Severity:** 1 critical (R-01), 4 high (R-02…R-05); 0 medium/low.
**Sources:** synthesis run log (T3/T4/T5/T7, C1); ARCH-BASELINE §1.1/§1.2; ARCH-CONTEXT §Engagement/§Problem statement; OQ#1 (multi-node/HA), OQ#2 (ML throughput).
**Hand-offs:** librarian indexes this log + updates the register/INDEX totals; rows are drafts pending architect review. No ADR routed (no directional choice forced yet); no action-register rows (§7 — architect-owned).

## Basis and judgment

All five rows are grounded in what the evidence establishes, not in generic hosting checklists. The register carries the full cause→consequence text; this log records why each made the cut and what was deliberately excluded.

- **R-01 (critical)** — the only critical: three stateful stores with an explicit documented silence on HA (OQ#1) directly contradicts the availability goal. Likelihood high (single-node default is the documented reality), impact high (instance-down breaches SLA).
- **R-02 / R-03 (high)** — the two co-location risks are kept **separate**: R-02 is api↔background-job contention in the default single container (T3/T5); R-03 is ML memory sizing (T4, OQ#2). Different failure modes, different owners, different review triggers — not one padded row.
- **R-04 (high)** — an **engagement-level** risk, not a system risk: docs-only discovery (no code/telemetry/interviews per context §Budget) means every as-is fact is documentation-confidence. Recorded so downstream design does not treat documented intent as observed behaviour.
- **R-05 (high)** — the engagement's own central tension (stock upgrade path vs customized/HA topology) recast as tech_debt: the customization needed for hosting is undocumented against upgrades.

## Excluded (judged not well-grounded)

- Backup/DR as a standalone risk — upstream already flags 3-2-1 (synthesis T7); it is an operator practice, not an architecture gap the evidence exposes. Folded into R-01's stateful-store scope.
- Security / multi-tenant isolation — the problem statement mentions later shared infrastructure, but the D1 doc set establishes no isolation facts to ground a risk; premature (would be invention). Revisit when tenancy model is in scope.

**Confidence:** medium — risks are well-grounded in first-party docs, but likelihood/impact ratings inherit R-04's docs-only limitation; ratings should firm up once OQ#1/OQ#2 resolve.
