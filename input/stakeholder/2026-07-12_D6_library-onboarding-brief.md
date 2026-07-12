---
type: stakeholder-brief
session: D6 — customer library onboarding at scale
date: 2026-07-12
provenance: simulated engagement fiction (demo) — architect-authored session brief; all facts
  about Immich come from the first-party documentation filed under input/systems/immich/
---

# D6 brief — customer library onboarding at scale (simulated)

The last unexamined pilot journey is the first one every customer takes: **getting an existing
photo library into their managed instance**. The client expects customers to arrive with libraries
in the hundreds-of-gigabytes-to-terabytes range (up to the 5 TB instance cap, NFR-005), and the
onboarding import is what triggers the ML backlog the 72-hour question (NFR-003, AI-001) is about.

## Questions for this session

1. What bulk-import mechanisms does Immich document (CLI upload, external libraries, anything
   else), and how does each behave (deduplication, resumability, what triggers job processing)?
2. What are external libraries exactly — semantics, scanning, exclusion patterns, and the
   already-noted quota exemption (R-09) — and when are they appropriate vs uploaded assets?
3. What does an onboarding import imply for the job pipeline and ML tier (ties to NFR-003/AI-001,
   E-02) and for storage layout (ADR-005, storage template)?
4. Which onboarding approach should the pilot standardize on — and what decision must be recorded?
5. What operator tooling/procedure does onboarding need (an enabler?), and what stays with the
   customer?

## Expected outputs

Incremental synthesis; baseline delta (import/library facts); a proposed onboarding ADR; a new M1
enabler + work stream if warranted; the D5 fitness F1 fix (M1 prose enumerations updated to the
full enabler package) executed as an approved correction wherever the transition file is touched;
fitness review closing the session.

## Ground rules

Unchanged: first-party documentation only; customer-arrival expectations above are engagement
fiction; gaps surface as open questions, never assumptions.
