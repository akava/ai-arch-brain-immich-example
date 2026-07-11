---
title: Immich Managed-Hosting Scale-Up — D3 Design Fitness Review
date: 2026-07-11
type: fitness-review
run: 2026-07-11-immich-scale-up-design
agent: fitness-review-agent (SKILL-007)
status: active
confidence: high
---

# Immich Managed-Hosting Scale-Up — D3 Design Fitness Review

**Target:** the full D3 run — synthesis + nfr-analysis logs; ADR-003/004/005 (proposed) + registry; CONTEXT drivers/goals/scope + requirements registry NFR-001..006/CON-001; ARCH-TARGET §3.1/§3.3/§3.4/§3.5; BASELINE §3 canonical renumber + §6; two living artifacts (integration contract new, ML component-spec renumber-touched); ownership-map, OQ#1/OQ#2 in-place updates, GLOSSARY promotions/coined terms.
**Verdict:** **proceed_with_caveats** — the run is internally consistent, evidence-faithful, fiction-labeled, and §-parity is sound in its first live test. Caveats are hygiene/routing, not integrity: the risk register never absorbed the D3 outputs (deliberate skip → this review routes the row updates), the action register is empty despite two architect to-dos + three ADR pilot gates now live, and the baseline work-stream's "latest processed session" still reads D2.
**Independence:** producing agents not assumed correct — load-bearing facts re-verified against `input/systems/immich/` (F7); §-parity, fiction-hygiene, ADR/registry status, and cross-references checked directly.
**Counts:** 11 checks; 0 blocker, 0 major, 5 minor, 6 info. Risk-routing proposals: 4 (all architect-owned). Action-routing proposals: 1. Fiction-hygiene: clean. §-parity: pass.
**Hand-offs:** librarian indexes this log + updates artifacts INDEX total 13→14 (main-loop). Risk-routing → risk-assessment-agent (register untouched this run, per brief). Action-routing → architect (register untouched, AGENT-RULES §7).

---

## Checks

- **F1 — context_alignment — info.** Every CONTEXT landing (drivers D1–D3, goals, scope, NFR-001..006/CON-001) traces to the D3/D1 briefs via synthesis T16 and is bound to a source ID. Registry altitude respected: capability-level statements only; milestone-specific realization deferred to transition M1 (cited, not restated). No solution facts leaked into CONTEXT. Route: none.
- **F2 — spec_conformance — info.** ARCH-TARGET §3.1/§3.3/§3.4/§3.5 all written at `[Tentative]` citing the proposed ADRs (ADR-003/004/005) per AGENT-RULES §8 — nothing over-claimed to `[Confirmed]`. Design responses framed as required capabilities, not products (realization deferred to the ADRs). NFR-003's 72h figure honestly held `[TBD]` in both CONTEXT and §3.1 with the benchmark condition named. Route: none.
- **F3 — adr_consistency — info.** ADR-003/004/005 are self-sufficient proposed drafts; registry rows match body `Status: proposed`; each carries the unattended-run/no-human-approval note. Options-considered + explicit-open-points present; ADR-004 benchmark gate and ADR-005 headroom-[TBD] correctly left unfilled (No-invention). ADR-001/002 remain approved; no proposed ADR contradicts them. Route: none.
- **F4 — internal_consistency — info.** Synthesis T14/T17/T18 → nfr-analysis A–F → ADR-003/004/005 → integration contract §3 form one unbroken chain; the ML channel overlay (LB + auth/TLS) is `[Tentative]` on ADR-004 throughout, never asserted as built. Facilit­ation: 6 NFR + 1 CON = 7 registry rows (matches nfr-analysis "6+1" count). Route: none.
- **F5 — internal_consistency (§-parity, FIRST LIVE TEST) — minor→resolved-as-pass.** BASELINE and TARGET now BOTH populate §3. Top-level skeleton §1–§7: identical. §3 subsections diverge — TARGET has §3.5 (Security), BASELINE does not. Per METAMODEL §3 note ("only populated subsections appear — no empty stubs") this is **correct**, not a parity break: BASELINE's security *observation* is homed at §1.2 (no-built-in-security), and NFR-006's CONTEXT trace + TARGET §3.5 entry both cite **BASELINE §1.2**, not a phantom §3.5. No dangling reference to a non-existent BASELINE subsection. Canonical renumber (3.1 Perf / 3.3 Avail / 3.4 Scale) applied consistently across BASELINE, TARGET, CONTEXT traces, and nfr-analysis. **Verdict: parity sound.** Route: none.
- **F6 — internal_consistency (renumber cite-integrity) — info.** Synthesis claimed "no living-file/register cite to old §3.1/§3.2/§3.3." Verified: living-file §3.x cites resolve to §3.4/§2 (unmoved); frozen D2 nfr-analysis log still cites old §3.1/§3.2 (Availability/Performance) at L118-119/L132 — correctly NOT edited (point-in-time record, AGENT-RULES §Change-history); readers resolve via the synthesis old→new map. Route: none.
- **F7 — evidence fidelity (spot-check) — info.** Load-bearing D3 facts re-verified against `input/systems/immich/`: scaling-guide shared-store + explicit no-capacity stance (`:9,13,15,19,23`) ✓; FAQ concurrency 2–3 CPU / ≤16 GPU (`:67`), NTFS/FAT unsupported (`:73`), checksums-since-v1.104.0 + pg_amcheck (`:77,94`) ✓; backup ordering verified **both directions** — backup DB-first-then-filesystem (`backup:62`) vs restore media-first-then-DB (`backup:30-36`), the opposite-ordering the ADR-005/synthesis assert ✓; env-var values (WORKERS 1, MODEL_TTL 300, WORKER_TIMEOUT 300/900-ROCm, KEEPALIVE 2s, DEVICE_IDS 0, OCR batch 6 @ env-vars:103, DB_/REDIS_ on all workers :63/:77) ✓; **DB_PASSWORD `A-Za-z0-9` constraint verified at its true citation `immich-docker-compose.md:33-36`** ✓; **`IMMICH_MACHINE_LEARNING_URL` confirmed absent from the whole committed doc set** — the integration contract's §1.5 flag is accurate. No mis-citation found. Route: none.
- **F8 — brain_hygiene (fiction hygiene) — info.** Every client-target figure (50 instances, 5 TB, 99.9%/43.8min, ≤15min, 1M/72h/3.86-4.15, auth+encrypted channel) appears in core/ only inside `[Tentative]`/`[TBD]` rows explicitly tagged "client-stated fiction / simulated demo," or inside proposed ADRs / frozen logs that inherit the label. **No leak found** where a fiction figure reads as an Immich-documented fact. Route: none.
- **F9 — brain_hygiene (risk register vs D3 outputs — REGISTER NOT UPDATED THIS SESSION) — minor.** A standalone risk-assessment run was deliberately skipped; the register still reflects the D1 state (5 rows, all `open`), but D3 materially moved several. This review routes the proposed row updates (see Risk-routing). The gap is that R-01/R-03/R-05 now have *proposed mitigating designs* (ADR-003/004/005) yet still read `open` with no mitigation link, and OQ#3's channel exposure has no risk row at all. Route: **risk-assessment-agent** (architect decides).
- **F10 — brain_hygiene (action register empty — NOW WRONG?) — minor.** The register is empty. Two nfr-analysis "architect to-dos" (benchmark-or-rescope NFR-003; record the D3 design ADRs) and three ADR pilot gates (failover drill / benchmark gate / restore drill) are now live and architect-owned. Judgement: the *ADR-recording* to-do is self-tracked by the proposed ADRs' own status (AGENT-RULES §8 — no row needed) and the pilot gates belong to transition M1 (not yet created), so they are premature as register rows. **But** the NFR-003 "benchmark-before-commit-or-explicitly-rescope in M1" decision is a genuine architect-owned, brain-improving, not-otherwise-tracked action → passes the triage gate. One row proposed (see Action-routing). Route: **architect** (propose, don't write — §7).
- **F11 — brain_hygiene (work-stream currency + OQ cross-links + register triggers) — minor.** (a) `work-streams/architecture-review.md` "Latest processed session: 2026-07-11 D2" is stale — D3 landed BASELINE §3 renumber + §6 + §3.1 concurrency heuristics; main-loop §9 step to update it to D3. (b) OQ#3 row still reads "candidate risk-register/NFR follow-up" though NFR-006 has landed and ADR-004 routes it — its cross-link is now stale (the follow-up materialized); propose updating OQ#3 to cite NFR-006/ADR-004/OQ#3-covered-by. (c) R-01 review-trigger "start of D2/D3 availability design" and R-03 "D3 ML-throughput scale-up work" are event triggers that have now **fired** (D3 design happened) — flag for the architect, folded into the risk-routing below. Route: architect / main-loop.

---

## Risk-routing proposals (findings only — register NOT edited this run, per brief + AGENT-RULES §5)

The architect decides; the `risk-assessment-agent` executes any accepted change.

- **RR-1 — R-01 (stateful-store HA):** now has a proposed mitigating design (ADR-003 Option B, per-instance HA Postgres/Redis). Propose status `open → mitigating`, add mitigation link `[[ADR-003]]` (proposed) + `ARCH-TARGET §3.3`, and refresh the fired review-trigger to "ADR-003 approval / M1 failover-drill gate."
- **RR-2 — R-03 (ML throughput/memory unquantified):** now has a proposed capacity design (ADR-004 dedicated tier + benchmark gate) and a landed requirement (NFR-003 [TBD]). Propose `open → mitigating`, link `[[ADR-004]]` + `NFR-003` + `OQ#2`; refresh fired trigger to "NFR-003 benchmark gate result."
- **RR-3 — R-05 (stock-upgrade-path tension):** now bound by CON-001 (landed) and constrained across ADR-003/004 (HA/version-alignment upgrade choreography). Propose keeping `open` (no upgrade rehearsal yet) but add cross-links `[[CON-001]]`, `[[ADR-003]]`, `[[ADR-004]]`; note NFR-002 co-constraint.
- **RR-4 — NEW risk row for OQ#3 (unsecured ML channel):** **recommend a new row.** The exposure — user photo previews over unauthenticated, cleartext HTTP:3003 — is a genuine architecture *risk* currently tracked only as an open question (OQ#3) + requirement (NFR-006) + proposed ADR (ADR-004). None of those carries L/I/severity/mitigation-status. A register row makes the exposure a tracked, rated risk with ADR-004 as its mitigation link. My read: OQ#3 is **not** adequately covered by NFR-006/ADR-004 for *risk-tracking* purposes — the requirement and routing exist, but the rated risk does not. Recommend the architect authorize the new row (candidate: L med / I high, `mitigating` via ADR-004 auth+TLS pilot gate).

## Action-routing proposal (findings only — register NOT edited this run, AGENT-RULES §7)

- **AR-1 — propose one row:** *"Decide NFR-003 disposition: benchmark per-asset inference on pilot hardware before committing the 72h/1M figure, or explicitly re-scope/gate it in transition M1."* Owner: Simulated architect (demo). Checkpoint: set at M1 creation. Links: `NFR-003`, `[[ADR-004]]` benchmark gate, `OQ#2`, `R-03`. Passes all four triage gates (architectural, architect-owned, brain-improving, not-otherwise-tracked — the ADR fixes topology not the go/no-go decision). The ADR-recording and pilot-gate to-dos do **not** get rows (ADR self-tracks per §8; gates belong to the not-yet-created M1).

## Glossary promotions

- 4 D3 `tentative` terms added cleanly (shared infrastructure, MODEL_TTL, buffalo_l/buffalo_s, immich-charts) + 3 coined ADR terms (dedicated ML tier, per-instance store HA, per-instance media volume). None meets the promotion bar this run (single-session, proposed-ADR-only for the coined trio — promote on ADR approval). No ambiguity to flag. No promotion proposed.

## Run yield

- **landed:** ARCH-CONTEXT (drivers/goals/scope narrative + NFR-001..006/CON-001 registry rows); ARCH-TARGET §3.1/§3.3/§3.4/§3.5; ARCH-BASELINE §3 canonical renumber + §6 + §3.1 concurrency heuristics; ADR-003/004/005 (proposed); integration-contract-immich-server-ml (new living artifact); component-spec-immich-machine-learning (renumber-touched); ownership-map (3 rows); GLOSSARY (7 terms); OQ#1/OQ#2 in-place updates.
- **verdict:** landed.
- **blocked_reason:** n/a.

## Coverage gaps

- ARCH-TARGET §1.x/§2/§4/§5/§6/§7 remain `[TBD]` — expected at this phase (design responses live in §3; realization is transition M1 + ADR work). Not a D3 defect; logged as standing coverage.
- No transition M1 file yet exists — the pilot gates (failover/benchmark/restore drills) and milestone-specific requirements have no home until the architect creates it (AGENT-RULES §9). Design directions currently sit in §3 + ADRs, which is correct pending M1.

## Verdict

- **verdict:** proceed_with_caveats
- **confidence:** high
