---
title: D6 — Customer library onboarding at scale (risk assessment)
date: 2026-07-12
run: 2026-07-12-immich-library-onboarding
agent: risk-assessment (legacy SKILL-006)
confidence: high — all Immich mechanisms first-party & source-verified; rate/likelihood posture rests on ADR-008 (proposed, unapproved)
sources:
  - core/artifacts/logs/2026-07-12-immich-library-onboarding-synthesis.md (T28–T31)
  - core/decisions/ADR-008-pilot-customer-library-onboarding.md (proposed)
  - core/2.ARCH-BASELINE.md §1.4
  - core/arch-processes/open-question-register.md (OQ#6, OQ#7)
  - core/1.ARCH-CONTEXT.md (NFR-003, NFR-005)
  - input/systems/immich/immich-external-libraries.md:13,21-24,27-28,32-33
  - input/systems/immich/immich-external-library-guide.md:20-23,35
  - input/systems/immich/immich-user-management.md:23
---

# D6 risk assessment — customer library onboarding at scale

**Purpose & verdict.** Judge the D6 onboarding candidates against source under ADR-008's B-exception-only posture. **3 rows added** (R-10/R-11/R-12), **R-09 updated** (exposure shrunk), **2 ownership-map rows added** by architect ruling. All load-bearing Immich mechanisms source-verified (external-libraries, external-library-guide, user-management). Ratings honour the mitigation posture: the B-exception being opt-in + signed-off pulls the data-loss likelihood to **low**; OQ#7's *unknown throughput bound* stays a question, its *certain nightly-scan occurrence* is rated (R-12).

- **Added:** R-10 (external-library exception data-loss, L low/I high → high, mitigating), R-11 (staging-ingest operational dependency, med/med → med, open), R-12 (nightly-scan recurring load — certain part of OQ#7, med/med → med, open).
- **Updated:** R-09 → L medium→**low**, status open→**mitigating**, ADR-008 disposition + conditionality noted.
- **Architect ruling executed:** ownership-map E-05 + E-06 → Hosting Platform Lead (demo).
- **Owners (new rows):** all three → **Hosting Platform Lead (demo)** per the map after this edit (E-06 onboarding; E-05/E-06 platform-side operability).
- **Not written:** no ADR/OQ/action edits. OQ#7 stays a live row (split noted below). Register + frontmatter updated; INDEX + total updated; `check-indexes.sh` passes.

## Candidate judgments (one line each)

- **R-10 — external-library exception data-loss (candidate a): ADDED, L low / I high / severity high, mitigating.** Path-removal-deletes (`immich-external-libraries.md:23`) + `:ro`-as-only-barrier (`immich-external-library-guide.md:23`) + single-user-unchangeable ownership (`immich-external-libraries.md:13`) → operator misconfig destroys/mutates real customer originals; **L is low because the hazard lives only on the ADR-008 B-exception path, which is opt-in and gated on `:ro` + a signed-off import-path config** — that gate is the mitigation posture, so severity is high (I high) not critical (L low).
- **R-11 — staging-ingest operational dependency (candidate b): ADDED, L medium / I medium / severity medium, open.** No first-party onboarding guide (OQ#6, verified doc silence) → the ADR-008 staged-CLI default is operator-authored per arrival profile → per-customer variance, stalled onboardings on unmapped formats, transient staging-capacity pressure (bytes held twice, up to 5 TB/onboarding — ADR-005/E-03 tie); medium/medium because it is an operability/throughput drag, not data loss, and E-06 is the planned mitigation.
- **R-12 — nightly-scan recurring load (candidate c, certain slice of OQ#7): ADDED, L medium / I medium / severity medium, open.** Applying the D4 precedent honestly: the nightly scan **runs by design on any B-exception instance** (`immich-external-libraries.md:33`) — a *certain* recurring consequence (re-enqueues scan+thumbnail+metadata jobs feeding the NFR-003 chain + nightly Postgres `LIKE` matching), so it is ratable now; the **multi-TB scan duration / throughput / inotify-budget / watch-viability bounds stay unquantified and remain OQ#7** (verified doc silence — no scan figure at any library size). The row rates only the certain occurrence; the unknown bound stays a question.
- **R-09 — quota bypass via external libraries: UPDATED (not new).** ADR-008 makes B exception-only and the default (staged/direct CLI) quota-counted → the exemption applies only to opt-in B instances, not the pilot baseline. L medium→**low**, status open→**mitigating**, mitigation/note cite ADR-008 (proposed) with honest conditionality (unapproved; medium returns if B-as-default is chosen). Second source log added to the row.

**Rejected candidate:** candidate (c) as a *single* multi-TB-throughput risk row — **rejected as unratable now.** Per the D4 precedent (documented silence stays OQ unless a certain consequence exists), the throughput/duration/inotify bound has no first-party figure and cannot be rated; only the nightly-scan *occurrence* is certain, which is what R-12 captures. The split is recorded in R-12 and OQ#7 remains a live open-question row (not edited here).

## OQ#7 disposition (split, not closed)

OQ#7 is **not** resolved or removed. R-12 carves out and rates the part that is certain (the recurring nightly scan by design); OQ#7 retains the genuinely-unknown part (scan duration/throughput/resource cost and watch viability at 5 TB — verified doc silence, needs benchmarking). No OQ-register edit made (agent scope: cite, don't write OQs).

## Ownership ruling (executed)

Two ownership-map rows added per the architect ruling, format-exact, nothing else touched:
- **Fleet observability & health plane (E-05)** → **Hosting Platform Lead (demo role)** — note: "Interim architect ruling 2026-07-12; platform-side operability; pending client confirmation."
- **Customer onboarding pipeline & staging (E-06)** → **Hosting Platform Lead (demo role)** — same note.

Consequently the three new risk rows carry owner **Hosting Platform Lead (demo)** (E-06 onboarding + E-05/E-06 platform operability), satisfying the §5.2 ownership gate at role granularity for demo scope.

## Architect follow-ups (noted, not written)

- These rows' likelihood posture is load-bearing on **ADR-008 (proposed)**; on its `approved` flip, R-09/R-10 conditionality notes can drop the "unapproved" caveat. No action-register row written (§7).
- OQ#7 benchmarking (scan/watch bounds at 5 TB) remains the standing resolution path — already an open OQ; no new action created here.
