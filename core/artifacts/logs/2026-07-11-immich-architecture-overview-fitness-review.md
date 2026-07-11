---
title: Immich Architecture Overview — D1 Fitness Review
date: 2026-07-11
type: fitness-review
run: 2026-07-11-immich-architecture-overview
skill: fitness-review-agent (SKILL-007)
status: active
confidence: high
---

# Immich Architecture Overview — D1 Fitness Review

**Purpose:** independent integrity audit of the complete D1 run — synthesis, risk assessment + register (R-01…R-05), ADR-001/002, and the layer landings (BASELINE §1/§2, GLOSSARY, ARCH-CONTEXT engagement/problem, OQ#1/OQ#2).
**Verdict:** **proceed_with_caveats** — the run is internally consistent, fully provenance-tagged, and invention-free; two housekeeping findings (F1 work-stream currency, F3 register `date` field) are for the architect, neither blocks D2/D3.
**Confidence:** high — all consistency and provenance checks pass; 17 load-bearing baseline facts verified verbatim against `input/systems/immich/` (0 unsupported).
**Findings:** F1 minor (brain_hygiene), F2 info (context_alignment), F3 minor (internal_consistency), F4 info (spec_conformance), F5 info (brain_hygiene). No blockers, no conflicts routed.
**Coverage note:** ARCH-TARGET is all-TODO by design (D1 is discovery; both ADRs are as-built records that explicitly leave TARGET untouched) — recorded as expected, not a gap.
**Hand-offs:** librarian indexes this log + updates the artifacts INDEX total (5→6); F1 is a main-loop/architect §9 step; no ADR or risk routed.

## What the run landed (run-yield)

BASELINE §1.1–§1.4 and §2 populated (`[Confirmed]`, cited); GLOSSARY 11 terms (7 promoted to `confirmed` via ADR-001/002, 4 `tentative`); ARCH-CONTEXT engagement card + problem statement; ADR-001, ADR-002 (approved, registry-synced); risk register R-01…R-05; OQ#1, OQ#2. **Verdict: landed.**

## Checks

- **F1 — brain_hygiene — minor.** `core/arch-processes/work-streams/architecture-review.md` "Landed so far" (and Work status) is still all-TODO; it does not record that BASELINE §1/§2 landed from the D1 synthesis. Definition step 6 requires the latest processed session be reflected in its populating work stream. Content/process finding — the work-stream update is a main-loop step gated on the architect's review of landings (AGENT-RULES §9); flagged, not fixed. *Route: none (architect).*
- **F2 — context_alignment — info.** ARCH-CONTEXT beyond the engagement card + problem statement (business drivers, goals/metrics, scope & constraints, stakeholders, requirements registry) is all-TODO. Correct for D1 — no `NFR-/FR-/CON-` requirement yet exists, so risk/ADR entries cite risks and OQs rather than requirement IDs, which is consistent. Recorded so D2 NFR work knows the registry is empty by design, not by omission. *Route: none.*
- **F3 — internal_consistency — minor.** `core/artifacts/risk-register.md` frontmatter carries `date: 2026-07-11`. Living artifacts are updated in place and (per AGENT-RULES → Naming conventions) carry `status` + `confidence`, not a fixed creation date that will silently go stale on the next risk run. The artifacts INDEX correctly shows `—` for the register's Date. Harmless today; propose dropping the frontmatter `date` (or treating it as last-touched) so it does not misrepresent currency after R-06+. Single-artifact correction owned by the risk-assessment-agent/architect. *Route: none (architect).*
- **F4 — spec_conformance — info.** ARCH-TARGET §1–§7 are all-TODO. Verified this is expected: D1 is discovery, and ADR-001/ADR-002 are as-built records that each state "ARCH-TARGET is untouched" and set `Affects core/3.ARCH-TARGET.md: No`. Per AGENT-RULES §8 no `[Tentative]` reconciliation is owed — the ADRs commit no target direction. §-parity holds: BASELINE and TARGET expose identical §1–§7 headings and identical 3.x/4.x subsection skeletons. *Route: none.*
- **F5 — brain_hygiene — info.** GLOSSARY: the 4 `tentative` terms (Immich, immich-server, Postgres system-of-record, hexagonal architecture) do **not** yet meet the promotion bar — they appear only in the single D1 synthesis and BASELINE, and have not entered an ADR, ARCH-TARGET, or a living artifact (the promotion triggers). Leaving them `tentative` is correct; no promotion proposed. The 7 `confirmed` terms each entered ADR-001/002 — promotion justified. Action register empty (no stale checkpoints — none expected D1); no active transition file (expected — architect-created only). *Route: none.*

### Verified consistent (no finding)

- **Provenance / no invention.** 17 load-bearing BASELINE facts checked verbatim against `input/systems/immich/immich-architecture-overview.md`, `-jobs-and-workers.md`, `-repo-readme.md`: all SUPPORTED, 0 embellished. Postgres holding ML-model settings is sourced across two doc passages (overview lines 90 + 96) — both cited in T7/§1.2, accurate. The two documented silences (multi-node/HA, ML throughput) are genuine — correctly captured as OQ#1/OQ#2 and grounding R-01/R-03, not filled with assumptions.
- **Cross-layer consistency.** ADR-001↔R-03↔OQ#2 (ML isolation/sizing) and ADR-002↔R-01/R-02↔OQ#1 (Redis/BullMQ + worker split) cross-links all resolve; conflict C1 (two-container vs one) resolved by the source's own reconciling note and reflected identically in synthesis, BASELINE §1.2, GLOSSARY (microservices worker variants), and ADR-002. No structured output contradicts a populated entry.
- **Register hygiene.** OQ#1/OQ#2 well-formed (statement, materiality, provenance, resolution path). All 5 risk rows complete per the register's column format (L/I/severity/status/mitigation/owner/trigger/source); severities (1 critical + 4 high) match the risk-assessment log. ADR registry ↔ body status labels sync (both `approved`); ADR-000 template row intact.
- **METAMODEL conformance.** BASELINE entries carry status tag + one provenance citation (entry anatomy); one-home-per-fact respected (store roles defined in §1.2, cross-referenced from §1.1/§1.4, not restated); as-built ADRs correctly do not mutate BASELINE by decision.

## Coverage gaps

- ARCH-TARGET §1–§7 `[TBD]` — expected at D1 (discovery); not a coverage gap against a populated section.

## Hand-offs

- `librarian-agent` — index this log; update `core/artifacts/INDEX.md` declared total 5→6 (main-loop step; row added in this run).
- Architect — F1 (work-stream currency, §9-gated), F3 (register `date` frontmatter). No ADR or risk routed.
