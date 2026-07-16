# Consolidated Remediation Plan — Brain Review (Execution-Ready)

**Author:** Architect (consolidation of three independent review passes)
**Date:** 2026-07-16
**Status:** Proposed — approval required before execution. Architect-gated items are marked; they do not move without explicit instruction (`CLAUDE.md` §7, `AGENT-RULES.md` §9).
**Sources consolidated:** `opus_linus_fixing_plan.md`, `sonnet_linus_fixing_plan.md`, `fable_linus_fixing_plan.md` — three passes over metamodel, machinery, and content. This file supersedes all three for execution; the originals are kept as provenance.

> **Scope class:** machinery + hygiene. Per the "machinery, not architecture" rule, execution lands as **commits, not ADRs** — except the ADR-registry items (CF-07), which are architect-gated and ADR-routed.

---

## Execution log (branch `linus-review-remediation`)

Executed 2026-07-16 after v2 reconciliation + a second independent review. One commit per item.

**Landed (verified):**
- **A1** — un-swallowed the index hook (`\|\| true` removed; intent documented in the script).
- **A2** — `check-adr-immutability.sh` + version-controlled `.githooks/pre-commit`: resolves ADR status from `INDEX.md`, blocks edits/deletes to approved/superseded/deprecated ADRs, `ALLOW_ADR_STATUS_SYNC=1` escape hatch for the label-only sync. Tested: blocks approved edit, allows under flag, permits proposed edit.
- **A3** — `lint-brain.sh`: caps artifacts-INDEX Summary ≤25 words, synthesis ≤120 / fitness ≤80 lines, + the B1/B3 sync-check. Manual/CI (not pre-commit-wired).
- **C1/C2** — fitness review gains a mandatory adversarial per-ADR challenge (new step 6, verdict-gating) and marks the hygiene checks advisory/separate.
- **B4/B5** — metamodel is a required read (AGENTS.md points, doesn't copy); drift-prone "nine agents" counts removed.
- **B1/B3** — CLAUDE.md §2 → pointer; AGENTS.md mirror declared; agent Output-preamble canonicalized in the rubric with a verbatim drift check (tested).
- **E1/E2** — BASELINE §3 anchors reconciled to the landed NFR rows; `Immich` promoted `confirmed`.
- **E3** — deleted empty `.claude/mcp` + `.claude/prompts`.
- **E6** — 18 over-length artifacts-INDEX summaries compacted to ≤25 words (librarian-agent); lint clean, count intact.
- **D3** — ADR-009/010 drafted (**proposed**) superseding ADR-001/002 as inherited-constraint records; INDEX updated; ADR-001/002 bodies untouched. **Awaiting architect approval.**

**Deferred by architect decision:** B6 (split `[Pending-verification]` tag — metamodel vocabulary change), A4 (per-file index manifest — INDEX-format change).

**Dropped by architect decision:** E4 (framework mappings are load-bearing — no removal), E7 (TODO stubs left as honest markers), CF-08 provenance machinery (already disclosed; downgraded in v2).

**Open for architect (surfaced, not actioned):**
1. Approve/reject ADR-009/010 (on approval, flip ADR-001/002 → `superseded`).
2. Re-adjudicate the six permanently-`proposed` ADRs (003–008) — proposed as an action-register row, not written unilaterally (register rule: propose, never write).
3. Residual lint: one synthesis log is 122 lines (cap 120) — trim via librarian or accept.

---

## 0. Reconciliation after independent review (v2 — authoritative)

A fourth, skeptical pass verified this plan's claims against the repo and returned **SOUND-WITH-CHANGES**. The following overrides take precedence over anything below that conflicts:

- **CF-10 — metrics were false, corrected.** Measured: `input/` ≈ 10.7k words, `core/artifacts/` ≈ **34.9k** words → amplification **~2.7:1**, not "6.3:1 / 57k." Those numbers are struck. The qualitative finding stands and is understated: the worst fact (sequential-multi-URL / no-LB) lives in **~10 substantive files** (+2 index rows). E6 keeps the one-home sweep of that fact; drops the false headline.
- **CF-08 — mostly false, downgraded.** The D3 brief front-matter reads `provenance: simulated engagement fiction (demo) — architect-authored`; every derived row is bolded "client-stated fiction" `[Tentative]` and NFR-003 is `[TBD] — not verifiable`. The self-authored/self-validated loop is *already disclosed at every layer*. **WS-D D2 is reduced to at most a one-line `source:` tag in `input/INDEX.md`; the sign-off gate + librarian/lint enforcement are dropped** (they'd add the machinery §6 says to avoid).
- **A1 — SessionStart cannot block; decision-gate #1 is moot.** Just remove `|| true`; the only possible outcome is warn-loudly. Done.
- **A2 — guard hook redesigned.** ADR status is **not uniformly in bodies** (ADR-003–006 carry only a prose `Status note:`; canonical status is `core/decisions/INDEX.md`). Therefore: **primary guard = a committed `check-adr-immutability.sh` resolving status from `INDEX.md`, runnable as pre-commit/CI** (handles Write+Edit uniformly, no mid-session false-block). Optional live PreToolUse hook, if built, must **hard-deny `Write` only** to approved-ADR paths and **`ask` (not deny) on `Edit`** — never hard-deny Edit, or it breaks the documented label-only status-sync exception (`INDEX.md:44`). Drop the action-register row enforcement and the stateful transition/BASELINE session-flag from v1 (no such flag mechanism exists in the repo).
- **A2/E1 contradiction resolved.** A2 must **not** cover `core/2.ARCH-BASELINE.md` header edits — that would block E1, which runs earlier. BASELINE promotion is left to the semantic rule (D1) + adversarial fitness review (C1).
- **CF-02 / A3 — cap Summary only.** The ≤25-word cap applies to the Summary cell; keyword cells are uncapped *by design* ("Keywords carry retrieval," `librarian-agent.md`). Only `core/artifacts/INDEX.md` breaches (avg ~42, worst ~100); `input/INDEX.md` is compliant. Drop A3's "keyword cell capped."
- **CF-15 / E4 — premise corrected; do not strip.** The framework mappings *are* consumed (C-ID spell-out rule, arc42 §-mapping, SAFe baseline/target/transition correspondence). E4 stays architect-gated and is reduced to "optionally annotate which mappings are load-bearing" — **no removal**.
- **CF-14 / B5 — roster is in 5 homes**, not 4: add `guides/playbooks/agents-playbook.md` and `guides/onboarding/create-new-project-from-template.md` to the de-hardcode list.
- **B1 — AGENTS.md is already pointer-style** (deliberate 5-rule minimal-boot list). Drop the sync-marker-mirror treatment for it and decision-gate #7; the genuine self-containment case is the **agent skeletons (B3)** only.
- **CF-07 phrasing** — drop "fabricated Option B"; it's the standard rejected-alternative section. The real finding is self-/simulated-approval + 6 of 8 ADRs stuck `proposed`.

Confirmed TRUE and safe to execute as written: **CF-01, CF-06, CF-07(core), CF-09, CF-11, CF-16, CF-17, CF-18, CF-19; A1; E1; E2.**

---

## 1. How the three reviews relate

The three passes overlap on the core defects and are otherwise complementary. Merged coverage:

- **All three agreed:** index hook swallows its own failure; the "no-invention" rule is duplicated; ADR-001/002 are upstream facts costumed as decisions; fitness review audits paperwork not soundness.
- **opus + sonnet added:** placement rule tripled, agent roster in 4 places, framework name-drop, empty `mcp/`+`prompts/` scaffolds, stale BASELINE §3 header, `Immich` stuck `tentative`, seven-hop indirection.
- **fable added (missed by the other two):** INDEX summaries bloated into a shadow DB, self-authored-then-self-validated requirements, six ADRs stuck `proposed`, 6.3:1 content amplification, `[Pending-verification]` carrying two meanings, TODO rot in the constitution — plus the strongest **enforcement** design (PreToolUse guard hook) and the **adversarial fitness-review** upgrade.

**Three cross-review disagreements, reconciled (this is the substance of consolidation):**

| Topic | opus / sonnet | fable | **Reconciled decision** |
|-------|---------------|-------|------------------------|
| De-duplication | delete copies → pointers | keep copies (boot self-containment), add sync-markers + lint | **Pointers only inside the always-read chain (CLAUDE→AGENT-RULES); sync-markers + lint sync-check for files that must stay self-contained (AGENTS.md, agent skeletons).** Blind deletion would break minimal-boot hosts and fresh subagent contexts. |
| Enforcement | commit/CI check | PreToolUse guard hook that blocks mid-run | **Guard hook is primary (blocks the agent, not just the commit); CI/commit gate is the durable backstop.** |
| Fitness review | demote hygiene → advisory | add adversarial per-ADR challenge | **Both: separate hygiene from soundness AND add the adversarial challenge step.** |
| ADR-001/002 | add `Nature: inherited` field via `decision-record-agent` | supersede, retype content as BASELINE facts | **Supersede/reclassify as inherited-constraint via `decision-record-agent`; move durable facts into BASELINE.** Both routes honor immutability; merged into one. |

---

## 2. Unified findings register

Verified = I re-checked the file this session. Reported = raised by a review, **must be re-verified before its fix executes**.

| ID | Finding | Class | Raised by | Status |
|----|---------|-------|-----------|--------|
| CF-01 | `check-indexes.sh` wired `\|\| true` on SessionStart — MISMATCH prints, exit code swallowed, blocks nothing | Enforcement | all 3 | **Verified** |
| CF-02 | INDEX summary/keyword cells run ~120–200 words vs librarian's own ≤25-word cap — index drifted into a shadow database; can't detect renames/stale rows/wrong paths | Enforcement | fable | Reported |
| CF-03 | "No silent invention" (and human-approval, index-protocol) rule stated in multiple files in different wording; AGENTS.md says "a copy would only drift" then carries copies | Duplication | all 3 | **Verified** (opus) |
| CF-04 | Agent skeleton paragraph duplicated verbatim in 8/9 agents; librarian hand-off line in 7/9 — violates authoring rubric check #4; `/improve-agents` never flagged it | Duplication | fable | Reported |
| CF-05 | Required Reading Order omits `0.ARCH-METAMODEL.md` and `2.ARCH-BASELINE.md`; reading order also stated 3× with different lists | Duplication / gap | all 3 | Reported |
| CF-06 | TODO rot in the constitution: metamodel "engagement card (TODO: name it…)" and empty CONTEXT stakeholder table still present after 8 ADRs / 6 sessions | Stale content | fable | Reported |
| CF-07 | ADR-001/002 marked `approved` but record upstream Immich history with a fabricated "Option B" and self-approval ("simulated unattended run"); 6 of 8 ADRs permanently `proposed` — no human closed a loop | Process theater | all 3 | **Verified** |
| CF-08 | The "client-stated pilot targets" the analysis validates were authored by the system itself into `input/stakeholder/…D3…brief.md` — self-authored, self-validated requirements | Circularity | fable | Reported |
| CF-09 | Fitness reviews audit paperwork (citations, §-parity, hygiene); zero checks challenge design soundness — all 6 verdicts `proceed_with_caveats`, caveats always housekeeping | Circularity | all 3 | Reported |
| CF-10 | 6.3:1 amplification (~9k words in → ~57k artifacts); single facts restated in up to 8 homes despite one-home-per-fact rule | Bloat | fable | Reported |
| CF-11 | Large sections of BASELINE/TARGET (§1.5, §2, §4.x, §5–7) are bare `TODO:` stubs after 6 sessions | Coverage gap (honestly marked) | all 3 | **Verified** (baseline) |
| CF-12 | `[Pending-verification]` carries two unrelated meanings (unconfirmed external ref vs open proposed decision) | Ambiguity | fable | Reported |
| CF-13 | Placement / content-boundary rule stated fully 3× (metamodel canonical, AGENT-RULES, REPO_MAP) | Duplication | opus + sonnet | Reported |
| CF-14 | 9-agent roster hardcoded in 4 places; nothing forces consistency | Duplication | opus + sonnet | Reported |
| CF-15 | Five frameworks (SAFe/ArchiMate/ISO-42010/arc42/TOGAF) stacked in one metamodel paragraph, no downstream rule consumes them | Ceremony | opus + sonnet | Reported |
| CF-16 | `.claude/mcp/` and `.claude/prompts/` are `.gitkeep`-only, unreferenced | Dead scaffolding | opus + sonnet | **Verified** |
| CF-17 | Beyond tool-scoping, every "must not" (ADR immutability, ownership gate, approval gate, transition lock) is prompt-text only; all agents hold `Read/Write/Edit/Bash` | Enforcement | all 3 | **Verified** |
| CF-18 | BASELINE §3 header says "registry unpopulated" after NFR-001..006/CON-001 landed in CONTEXT | Content bug | opus + sonnet | **Verified** |
| CF-19 | `Immich` — most-cited term in the repo — still `status: tentative` in glossary | Bureaucratic gap | opus + sonnet | Reported |
| CF-20 | Seven hops between a user request and a landed fact; framework ceremony inflates the path | Over-indirection | opus + sonnet | Reported (design-level; addressed indirectly via CF-13/14/15) |

**Strengths to preserve — do not regress while fixing:** honest demo/fiction labeling; `input/`-cited falsifiable claims; "flagged, not invented" evidence discipline; `[TBD]` + derived bounds; hard line budgets; §8 `[Tentative]` reconciliation; tool-allowlist orchestration (no agent spawns agents); stable-ID delta discipline; `no_durable_landing` run-yield check; "machinery decisions are commits, not ADRs."

---

## 3. Execution workstreams

### WS-A — Enforcement kernel (P0 · CF-01, CF-02, CF-17)
*Principle: every rule that can be a script becomes a script; prose keeps only what needs judgement.*

- **A1. Kill `|| true`** in `.claude/settings.json`. Decide once, comment it inline: **non-blocking but unmissable** — MISMATCH surfaces as a distinct warning a session can't silently pass, without wedging startup.
- **A2. PreToolUse guard hook** (`.claude/scripts/guard-writes.sh`, wired in settings):
  - Deny Edit/Write to any `core/decisions/ADR-*.md` whose status is `approved` (allow the label-only status-sync exception via explicit allowlist).
  - Deny Edit/Write to `core/transitions/*` status lines and `core/2.ARCH-BASELINE.md` unless the architect-invoked transition skills have set a session flag (mechanizes `AGENT-RULES` §9).
  - Deny writes to `core/arch-processes/action-register.md` rows not marked `proposed`.
- **A3. Brain linter** (`.claude/scripts/lint-brain.sh`): line budgets (synthesis ≤120, fitness ≤80); INDEX summary cell ≤25 words, keyword cell capped; reject appended-YAML-restatement blocks. Hosts the WS-B sync-check.
- **A4. Index manifest**: extend `check-indexes.sh` from count-vs-total to per-file — every disk file has a row, every row's path exists, add mtime/hash so stale rows are detectable. Update `librarian-agent` to maintain it.
- **Acceptance:** editing an approved ADR is blocked; a 130-line synthesis fails lint; renaming an input file without touching INDEX fails the manifest check.

### WS-B — Single-source the rules (P1 · CF-03, CF-04, CF-05, CF-12, CF-13, CF-14)
*Reconciled method: pointers inside the always-read chain; sync-markers + lint for self-contained files.*

- **B1.** Canonicalize no-invention / human-approval / index-protocol / placement-boundary in `core/AGENT-RULES.md` (+ metamodel for content-boundary). Reduce `CLAUDE.md` to one-line pointers (it's always read first). For `AGENTS.md` (minimal-boot hosts) keep the block but mark `<!-- sync: AGENT-RULES §n -->` and add **B2 sync-check** to `lint-brain.sh` (fail when a marked mirror diverges). Copies become checked mirrors, not silent drift.
- **B3.** Factor the 8×-duplicated agent skeleton into the authoring rubric as canonical text, same sync-marker mechanism (agent files stay self-contained for fresh subagent contexts).
- **B4.** Add `0.ARCH-METAMODEL.md` and `2.ARCH-BASELINE.md` to `CLAUDE.md` Required Reading Order; reconcile the 4-file vs 6-step lists into one, referenced from `AGENTS.md`/`REPO_MAP.md`.
- **B5.** Roster (CF-14): `.claude/agents/` is the source; `REPO_MAP.md` and `improve-agents.md` stop hardcoding names → "every file in `.claude/agents/`." AGENT-RULES registry table stays (adds dependency-chain semantics).
- **B6.** Split `[Pending-verification]` (CF-12) into `[Unverified-ref]` and `[Open-decision]`; one-pass migration of existing uses.
- **Acceptance:** `lint-brain.sh` sync-check green; grep finds each rule's full text in exactly one canonical file.

### WS-C — Review with teeth (P1 · CF-09)
- **C1.** Add a mandatory adversarial step to `fitness-review-agent.md`: per in-scope ADR, argue the decision is *wrong* — strongest counter-case, conditions under which the rejected option wins, what evidence would flip it. Output a `challenge` block per ADR; verdict may not be `proceed_with_caveats` with an unanswered challenge.
- **C2.** Separate the two jobs: hygiene/paperwork checks (they caught real drift in D2/D5/D6) move to a distinct advisory section so a hygiene-only pass can't present as an architecture review; demote hygiene findings from review-failing to advisory.
- **Acceptance:** next run over ADR-003/008 produces ≥1 substantive challenge per ADR (or explicit "no credible counter-case, because…"), not silence.

### WS-D — Close the loop (P1–P2 · CF-07, CF-08 · **architect-gated**)
- **D1.** AGENT-RULES addition: "simulated architect approval" banned — an ADR reaches `approved` only via an explicit human instruction recorded in its history line. (Semantic; enforced by fitness C1, not a hook.)
- **D2.** Provenance column in `input/INDEX.md`: `source: client | synthetic | vendor-doc`. Synthetic inputs need an architect sign-off marker before any chain run treats them as requirements (fixes the self-authored/self-validated loop, CF-08). Librarian enforces presence; lint checks it.
- **D3. Architect decision — ADR-001/002 disposition (CF-07):** recommended path — supersede both via `decision-record-agent`, reclassifying them as inherited-constraint records and moving the durable facts into `core/2.ARCH-BASELINE.md` (keeps immutability intact); re-present the six `proposed` ADRs for genuine accept/reject. I prepare the supersession drafts; **architect decides**. Direct edits to the approved files are forbidden.
- **Acceptance:** every input row carries provenance; no ADR approval line reads "simulated"; the six open ADRs each have a real disposition.

### WS-E — Subtraction & compaction (P2 · CF-06, CF-10, CF-11, CF-15, CF-16, CF-18, CF-19)
- **E1.** CF-18: reconcile BASELINE §3 header with the actual CONTEXT registry (cite governing NFR/CON rows). *Re-verify registry state first.* No gate.
- **E2.** CF-19: promote `Immich` `tentative`→`confirmed` with a one-line note. No gate.
- **E3.** CF-16: delete `.claude/mcp/` and `.claude/prompts/`, or replace `.gitkeep` with a one-line roadmap note. **Gate:** architect confirms not a planned slot.
- **E4.** CF-15: trim the metamodel framework paragraph to only mappings a downstream rule consumes; if none, say so plainly. **Gate:** architect (touches repo "voice").
- **E5.** CF-06: resolve the metamodel engagement-card TODO and the empty stakeholder table (fill or explicitly de-scope).
- **E6.** CF-10 / CF-02 residue: librarian pass compressing INDEX rows to the ≤25-word cap (now lint-enforced); one-home-per-fact sweep of the worst offender (sequential-multi-URL/no-LB, ~8 homes → 1 + pointers). Full dedup not attempted.
- **E7. Architect decision — CF-11:** each TARGET/BASELINE stub either filled next chain run or marked `out-of-scope (pilot)`; empty headers stop masquerading as pending work.

---

## 4. Sequencing

| Order | WS | Priority | Effort | Blocked on |
|-------|----|----------|--------|-----------|
| 1 | WS-A | P0 | ~1 session | nothing — pure machinery |
| 2 | WS-E: E1, E2 | P0 | XS | nothing (independent quick defect fixes; can land with WS-A) |
| 3 | WS-B | P1 | ~1 session | WS-A (lint hosts sync-check) |
| 4 | WS-C | P1 | ~0.5 session | nothing |
| 5 | WS-D | P1–P2 | ~0.5 session + D3 decision | D1/D2 machinery; D3 needs architect |
| 6 | WS-E: E3–E7 | P2 | ~1 session | WS-A lint; E3/E4/E7 need architect confirms |

**Definition of done:** every CF-xx maps to a landed commit or an explicit architect rejection recorded here; `lint-brain.sh` + guard hook green on a clean checkout; strengths list spot-checked as unregressed (§8 reconciliation, delta discipline, evidence honesty still present and used).

---

## 5. Architect decision gates (block their items until answered)

1. **A1** — index mismatch: block session, or warn-loudly-and-continue? *(rec: warn loudly, don't block)*
2. **D3** — ADR-001/002: supersede→inherited-constraint + facts to BASELINE (rec), add `Nature` field only, or leave with existing disclosure? Plus: re-adjudicate the six `proposed` ADRs?
3. **D1/D2** — adopt "no simulated approval" rule and input provenance column with sign-off gate?
4. **E3** — are `.claude/mcp/` & `.claude/prompts/` planned or cruft? *(rec: delete unless roadmapped)*
5. **E4** — how much of the framework-mapping paragraph is load-bearing "voice" to keep?
6. **E7** — fill vs. explicitly de-scope each TARGET/BASELINE stub.
7. **B1** — does `AGENTS.md` keep checked mirrors (rec) or become pointer-only?

## 6. Out of scope (deliberately not in this plan)

- Filling BASELINE/TARGET architecture content (CF-11 fill path) — that's architecture work needing real evidence, a separate backlog; here we only force the stubs to declare fill-or-de-scope.
- The demo/fiction labeling and evidence-citation discipline — working as intended, do not touch.
- Adding new indirection or machinery. Every item above removes a copy, deletes dead weight, or turns an existing decorative check into one that bites. The brain needs *less* structure that actually holds, not more.
