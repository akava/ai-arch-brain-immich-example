---
type: stakeholder-brief
session: D2 — machine-learning & media/storage pipeline deep dive
date: 2026-07-11
provenance: simulated engagement fiction (demo) — architect-authored session brief; all facts
  about Immich come from the first-party documentation filed under input/systems/immich/
---

# D2 brief — ML & media pipeline deep dive (simulated)

Following the D1 architecture overview, session D2 deep-dives the two areas the scale-up most
depends on and D1 flagged as unquantified: the machine-learning service (OQ#2) and the media/
storage pipeline. Findings should firm up the baseline and produce the first component-level
specification and quality-attribute analysis.

## Questions for this session

1. How does the ML service work operationally: model lifecycle, hardware acceleration options,
   and what the docs say about running it remotely / separately from the server?
2. What does media storage look like on disk (layout, storage template), and what governs it?
3. How is the database operated (migrations, direct access posture) and what does the project
   document about its extensions?
4. What do the docs quantify — and leave unquantified — about ML and media-pipeline capacity
   (feeds OQ#2, R-03)?
5. Which as-built design decisions in these areas are stated first-hand and worth recording?

## Expected outputs

Incremental synthesis; a component spec for the ML service (living artifact); an NFR analysis of
the documented quality attributes (observed/stated values to BASELINE §3; targets remain D3 work);
follow-ups from the D1 fitness review (F1, F3) executed as architect-approved corrections.

## Ground rules

Unchanged: first-party documentation only; gaps surface as open questions, never assumptions.
