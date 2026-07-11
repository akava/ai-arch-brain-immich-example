---
title: Immich ML & Media Deep-Dive — D2 Fitness Review
date: 2026-07-11
type: fitness-review
run: 2026-07-11-immich-ml-media-deep-dive
skill: fitness-review-agent (SKILL-007)
status: active
confidence: high
---

# Immich ML & Media Deep-Dive — D2 Fitness Review

**Purpose:** independent integrity audit of the complete D2 run — synthesis (T9–T13), NFR analysis (QA-1..QA-8), the new `component-spec-immich-machine-learning` living artifact, and the layer landings (BASELINE §1.2/§1.4/§2/§3.1/§3.2/§3.4, GLOSSARY 6 D2 terms, OQ#2 partial-update + OQ#3 new).
**Verdict:** **proceed_with_caveats** — the run is evidence-clean, provenance-tagged, and invention-free; one real machinery finding (F1: §3 subsection-ID drift vs the shared skeleton), otherwise consistent. Nothing blocks D3.
**Confidence:** high — 21/21 load-bearing D2 facts verified verbatim against the five `input/systems/immich/` docs (0 unsupported); all cross-cites resolve.
**D1 follow-ups:** F1(D1) work-stream currency — **executed** (architecture-review stream now records D1+D2, "Latest processed session: 2026-07-11 D2"). F3(D1) risk-register `date` frontmatter — **executed** (removed; only `status`/`confidence` remain).
**Findings:** F1 minor (machinery/internal_consistency), F2 info (machinery), F3 info (brain_hygiene), F4 info (context_alignment). No blockers, no conflicts routed.
**Hand-offs:** librarian indexes this log + updates artifacts INDEX total 9→10; F1 routes to the architect via `core/0.ARCH-METAMODEL.md` (skeleton gate); glossary promotion (F3) is an architect/decision-record call.

## Run yield

Landed durable brain changes: BASELINE §1.2/§1.4 deepened, §2 extended, §3.1/§3.2 added + §3.4 addition; GLOSSARY 6 `tentative` terms; `component-spec-immich-machine-learning.md` (new living artifact); OQ#2 partial-answer update-in-place + OQ#3 new. **Verdict: landed.**

## Checks

- **F1 — internal_consistency / machinery — minor.** BASELINE §3 landed its D2 subsections at non-canonical IDs: **§3.1 = Availability & Resilience** and **§3.2 = Performance & Throughput**. The shared BASELINE↔TARGET skeleton (`core/0.ARCH-METAMODEL.md` §3; enumerated in the TARGET §3 TODO) assigns **3.1 Performance & Throughput, 3.3 Availability & Resilience, 3.4 Scalability & Capacity**. §3.x IDs are stable cite anchors where *same §N = same concern* across both files, so Availability landing at §3.1 (should be §3.3) and Performance at §3.2 (should be §3.1) is a skeleton mismatch that will collide when TARGET §3 populates. Blast radius: internally self-consistent today (NFR-analysis, spec, and register all cite the as-landed numbers — `NFR-001/002 → §3.1`, `NFR-005 → §3.2`, evidence: nfr-analysis L118-122, L131-132), so a renumber must move the cites with it. Correction is a skeleton change → land via `core/0.ARCH-METAMODEL.md` first (confirm/relax the §3 ID convention), then re-anchor BASELINE §3 and its cites. *Route: architect (metamodel gate, §9); not fixed in-run.*
- **F2 — machinery — info.** D1 review F4 vouched "§-parity holds: BASELINE and TARGET expose identical 3.x/4.x subsection skeletons." True at D1 (BASELINE §3 was empty), but D2 populated §3 off-convention (F1), so that parity assertion no longer holds for §3. Top-level §1–§7 parity and §4.1–§4.5 parity **do** hold. Recorded so F4(D1) is not read as still-green for §3. *Route: none (tied to F1).*
- **F3 — brain_hygiene — info.** GLOSSARY promotion triggers have now fired for several D2 `tentative` terms: `remote machine learning` (as variant "remote ML", 3 hits), `Smart Search`, `Face Detection`, `Facial Recognition`, `ML hardware acceleration` all now appear in the **living** `component-spec-immich-machine-learning.md` — the "enters a living artifact" trigger (AGENT-RULES §6 / GLOSSARY → How maintained). These meet the promotion bar; per the run brief this is **recorded as a pending decision-record/architect promotion run, not fixed here** (glossary status is approval-owned). `storage template`, `Storage Template Migration`, `hardware transcoding` do **not** yet meet the bar (single session, not in a living artifact) — correctly left `tentative`. *Route: architect / decision-record-agent (batch promotion).*
- **F4 — context_alignment — info.** Verified the D2 candidate requirement rows (NFR-001..006, CON-001) were **NOT** written to `core/1.ARCH-CONTEXT.md` — the registry table is header-only, zero `NFR-/FR-/CON-` rows present. The architect-gated ruling held; none leaked in. NFR-analysis correctly homes them as "proposed only" (L112-126). *Route: none.*

### Verified consistent (no finding)

- **Provenance / no invention.** 21/21 load-bearing D2 facts (port 3003, partial offload with server-bound Facial Recognition, sequential-URL/no-LB, no built-in security, version-alignment, no-fallback/manual-retry, storage-template mechanics + server-timezone + collision sequencing, migration-at-startup + single-step revert, 5 ML GPU backends + CUDA 5.2/≥545 + ROCm ≥35 GiB + RKNN 2–3 threads, multi-GPU env vars, transcoding encoding-only/larger-lower-quality/two-pass-NVENC/no-VP9, OpenVINO notes) checked verbatim against the five source docs: all SUPPORTED, 0 embellished, no unsupported number or qualifier. The two residual gaps (ML throughput OQ#2, remote-ML security OQ#3) are genuine documented silences, not filled.
- **Cross-layer consistency.** spec ↔ BASELINE §1.2/§1.4/§3.4 ↔ synthesis T9–T13 ↔ QA-1..QA-8 ↔ risk R-01/R-03/R-05 ↔ OQ#1/OQ#2/OQ#3 cross-links all resolve. Facial Recognition (DB-bound) vs Face Detection (offloadable inference) distinction is consistent across spec §Boundaries, GLOSSARY, and synthesis T9. Spec `spec_update_required: no` is correct — AS-IS discovery, ARCH-TARGET untouched (matches ADR-001 / engagement brief).
- **ADR registry.** Untouched this session (expected) — still ADR-001/ADR-002 approved + ADR-000 template; no D2 ADR owed (no new decision/trade-off — the run records observed facts and open questions). No §8 `[Tentative]` reconciliation owed (no proposed ADR commits target direction).
- **Register hygiene.** OQ#2 partial-answer update-in-place well-formed (floors landed, throughput still open, provenance dual-dated D1+D2); OQ#3 new, well-formed with materiality + resolution path. Action register empty — no stale checkpoints (none expected; no D2 item passes the triage gate — discovery facts, not architect-owned brain-improving actions). No active transition file (architect-created only).
- **METAMODEL / skeleton.** Entry anatomy holds (every BASELINE §3 entry carries `[Confirmed]` + one provenance citation); one-home-per-fact respected (ML floors in §3.4 referenced from §3.2, not duplicated; transcoding trade-off framed once as capacity in §3.4, once as performance/storage in §3.2 with explicit cross-ref). Top-level §1–§7 skeleton parity holds (F1 is the §3 *subsection*-ID exception).

## Coverage gaps

- ARCH-TARGET §1–§7 all-`[TBD]` — expected at D2 (discovery; target-setting is D3). Not a coverage gap against a populated section.

## Hand-offs

- `librarian-agent` — index this log; update `core/artifacts/INDEX.md` declared total 9→10 (row added in this run).
- Architect — **F1** (§3 subsection-ID skeleton drift; metamodel-gated, §9); **F3** (batch-promote the 5 trigger-met GLOSSARY terms via architect/decision-record). No ADR or risk routed.
