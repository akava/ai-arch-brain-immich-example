# Fixing Plan — Linus Review Remediation

Status: proposed (architect approval required before execution)
Source: external-style review of the brain (2026-07-16), three verified passes: metamodel, machinery, content.
Scope type: machinery + hygiene. Per the "machinery, not architecture" rule, execution lands as commits, not ADRs — except F-07/F-08, which touch the decision registry and are architect-gated.

---

## 1. Review results (findings register)

Every claim below was verified against files during the review, not taken from vibes.

| ID | Finding | Evidence | Severity |
|----|---------|----------|----------|
| F-01 | Only executable enforcement is `check-indexes.sh` (file count vs declared total), run from a SessionStart hook with `\|\| true`. No check for ADR immutability, line budgets, index summary caps, transition status flips. | `.claude/scripts/check-indexes.sh`, `.claude/settings.json` | Critical |
| F-02 | Index-count check cannot detect renames, stale rows, wrong paths, or oversized summaries. `core/artifacts/INDEX.md` rows run ~120-word summaries + ~200-word keyword blobs vs the librarian's own ≤25-word cap — index has drifted into a shadow database. | `core/artifacts/INDEX.md`, `.claude/agents/librarian-agent.md` step 5 | High |
| F-03 | "Define once, reference don't paste" violated by the boot files themselves: no-invention rule in 3 copies (CLAUDE.md §2, AGENT-RULES non-negotiables, AGENTS.md), human-approval rule ×2, index protocol ×3. AGENTS.md states "a second copy would only drift" then lists five copied rules. | `CLAUDE.md`, `AGENTS.md`, `core/AGENT-RULES.md` | High |
| F-04 | Agent boilerplate duplicated: skeleton paragraph verbatim in 8/9 agents, librarian hand-off line in 7/9 — against the authoring rubric's own check #4; `/improve-agents` never flagged it. | `.claude/agents/*.md`, `guides/playbooks/agent-authoring-rubric.md` | Medium |
| F-05 | Required-reading list omits `core/0.ARCH-METAMODEL.md` and `2.ARCH-BASELINE.md` even though AGENT-RULES §1 requires baseline consultation and everything cites the metamodel. | `CLAUDE.md` → Required Reading Order | Medium |
| F-06 | TODO rot in the constitution: "engagement card (TODO: name it there when the engagement starts)" still present after 8 ADRs / 6 sessions. CONTEXT stakeholder table still an empty header row. | `core/0.ARCH-METAMODEL.md`, `core/1.ARCH-CONTEXT.md` | Low |
| F-07 | ADR-001/002 are upstream Immich facts costumed as decisions, with a fabricated Option B and self-approval: "approved — by architect instruction in a simulated unattended run." Six of eight ADRs permanently `proposed` — no human has closed a decision loop. | `core/decisions/ADR-001…008`, `core/decisions/INDEX.md` | High |
| F-08 | Circularity: the "client-stated pilot targets" the analysis validates were authored by the system itself into `input/stakeholder/2026-07-11_D3_scale-up-design-brief.md`. Self-authored requirements, self-validated. | `input/stakeholder/`, `input/INDEX.md` | High |
| F-09 | Fitness reviews audit paperwork (citations, §-parity, hygiene) — zero checks challenge design soundness. All six verdicts `proceed_with_caveats`; caveats always housekeeping. | `.claude/agents/fitness-review-agent.md`, review logs in `core/artifacts/` | High |
| F-10 | Amplification 6.3:1 (~9k words input → ~57k artifacts); single facts restated in up to 8 homes (e.g. sequential-multi-URL/no-LB) despite the one-home-per-fact rule. | BASELINE §1.2/§3.1, component spec, contract §1.4, ADR-004, TARGET §3.1, M1 WS2, handoff, R-03 | Medium |
| F-11 | `ARCH-TARGET.md` mostly `TODO:` stubs after six sessions (§1.1–1.3, §2, §4–§7); real content is six §3 NFR adoptions + ADR mermaid renders. | `core/3.ARCH-TARGET.md` | Medium |
| F-12 | `[Pending-verification]` tag carries two unrelated semantics (unconfirmed external ref vs genuinely open proposed decision). | `core/0.ARCH-METAMODEL.md` | Low |

Strengths to preserve (do not regress while fixing): hard line budgets; §8 `[Tentative]` reconciliation; tool-allowlist orchestration; stable-ID delta discipline; `no_durable_landing` run-yield check; non-invention honesty (`[TBD]` + derived bounds, "flagged, not invented"); "machinery decisions are commits, not ADRs".

---

## 2. Triage

Accepted as-is: F-01, F-02, F-05, F-06, F-09, F-12.
Accepted with modification: F-03/F-04 (copies exist for a reason — minimal-boot hosts and fresh subagent contexts; fix is single-source-plus-sync-check, not deletion), F-10 (full dedup of 57k words is not worth the churn; fix forward via lint + targeted compaction).
Architect decision required: F-07 (approved ADRs are immutable — retyping ADR-001/002 needs supersession or an explicit registry annotation, architect's call), F-08 (provenance policy for synthetic inputs), F-11 (fill vs. explicitly de-scope TARGET sections — content decision, not machinery).

---

## 3. Workstreams

### WS-A — Enforcement kernel (P0; fixes F-01, F-02)

Principle: every rule that can be a script becomes a script; prose keeps only what needs judgement.

1. **A1. PreToolUse guard hook** (`.claude/scripts/guard-writes.sh`, wired in `.claude/settings.json`):
   - Deny Edit/Write to any `core/decisions/ADR-*.md` whose status line is `approved` (allow the label-only status-sync exception via an explicit allowlist pattern).
   - Deny Edit/Write to `core/transitions/*` status lines and `core/2.ARCH-BASELINE.md` unless a session flag file set by the architect-invoked skills (`new-arch-transition` / `close-arch-transition`) is present — mechanizes AGENT-RULES §9.
   - Deny writes to `core/arch-processes/action-register.md` rows not marked `proposed` (propose-never-write discipline).
2. **A2. Brain linter** (`.claude/scripts/lint-brain.sh`):
   - Line budgets: synthesis ≤120, fitness review ≤80 (parse artifact type from path/frontmatter).
   - INDEX summary cell ≤25 words; keyword cell capped (propose ≤15 words).
   - Reject appended-YAML-restatement blocks (heuristic: trailing ```yaml fence duplicating headings).
3. **A3. Index manifest**: extend `check-indexes.sh` from count-vs-total to a per-file check — every file on disk has a row, every row's path exists, plus an mtime/hash column so stale rows are detectable. Librarian agent updated to maintain it.
4. **A4. Kill `|| true`**: SessionStart hook reports loudly; A1/A2 run as PreToolUse/PostToolUse where they can actually block. CI-style invocation documented so `lint-brain.sh` can gate commits later.
5. Acceptance: deliberately editing an approved ADR is blocked; a 130-line synthesis fails lint; renaming an input file without touching INDEX fails the manifest check.

### WS-B — Single-source rules (P1; fixes F-03, F-04, F-05, F-06, F-12)

1. **B1.** Canonicalize no-invention, human-approval, and index protocol in `core/AGENT-RULES.md`; reduce CLAUDE.md and AGENTS.md occurrences to one-line pointers. Where AGENTS.md must stay self-contained for minimal-boot hosts, mark the block `<!-- sync: AGENT-RULES §n -->` and add **B2. sync-check** to `lint-brain.sh` (fail when a marked block no longer matches its source). Copies stop being silent drift and become checked mirrors.
2. **B3.** Factor the 8×-duplicated agent skeleton paragraph into the rubric as the canonical text with the same sync-marker mechanism (agent files must stay self-contained — fresh subagent contexts — so generated/checked copies, not references).
3. **B4.** Add `core/0.ARCH-METAMODEL.md` and `core/2.ARCH-BASELINE.md` to CLAUDE.md Required Reading Order.
4. **B5.** Resolve the metamodel TODO (name the engagement card); split `[Pending-verification]` into `[Unverified-ref]` and `[Open-decision]`, with a one-pass migration of existing uses.
5. Acceptance: `lint-brain.sh` sync-check passes; grep finds each rule's full text in exactly one file.

### WS-C — Review with teeth (P1; fixes F-09)

1. **C1.** Add a mandatory adversarial step to `fitness-review-agent.md`: for each ADR in scope, argue the decision is wrong (strongest counter-case, conditions under which the rejected option wins, what evidence would flip it). Output as a `challenge` block per ADR; verdict may not be `proceed_with_caveats` when a challenge lands unanswered.
2. **C2.** Separate the two jobs the agent currently conflates: paperwork/hygiene checks stay (they caught real drift in D2/D5/D6) but move to a distinct checklist section so a review that only did hygiene cannot present as an architecture review.
3. Acceptance: next fitness run over ADR-003/008 produces at least one substantive challenge per ADR or an explicit "no credible counter-case found, because…" — not silence.

### WS-D — Close the loop (P1–P2; fixes F-07, F-08; architect-gated)

1. **D1.** Rule addition to AGENT-RULES: "simulated architect approval" is banned; an ADR reaches `approved` only via an explicit human instruction recorded in the ADR's history line. (Machinery rule — no hook can check semantics, but fitness C1 checks for it.)
2. **D2.** Provenance column in `input/INDEX.md`: `source: client | synthetic | vendor-doc`. Synthetic inputs require an architect sign-off marker before any chain run may treat them as requirements. Librarian enforces column presence; lint checks it.
3. **D3.** *Architect decision:* disposition of ADR-001/002 — recommend superseding both with a note retyping the content as BASELINE facts (keeps immutability intact), and re-presenting the six `proposed` ADRs for genuine accept/reject. I will prepare the supersession drafts; you decide.
4. Acceptance: every input row carries provenance; no ADR reads "simulated" in its approval line; the six open ADRs each have a real disposition.

### WS-E — Compaction (P2; fixes F-10, F-11, F-02 residue)

1. **E1.** Librarian pass compressing all `core/artifacts/INDEX.md` rows to the ≤25-word cap (now lint-enforced from WS-A, so it stays fixed).
2. **E2.** One-home-per-fact sweep for the worst offender facts (start with the sequential-multi-URL/no-LB fact, 8 homes → 1 home + pointers). Fitness hygiene checklist gains a "fact restated?" spot-check; full dedup not attempted.
3. **E3.** *Architect decision:* for each TARGET stub section — fill in the next chain run or mark `out-of-scope (pilot)` explicitly. Empty headers stop masquerading as pending work.
4. Acceptance: INDEX passes lint; TARGET contains no bare `TODO:` without an owner or an out-of-scope marker.

---

## 4. Sequencing and effort

| Order | WS | Effort | Blocked on |
|-------|----|--------|-----------|
| 1 | WS-A | ~1 session | nothing — pure machinery |
| 2 | WS-B | ~1 session | WS-A (lint exists to host sync-check) |
| 3 | WS-C | ~0.5 session | nothing |
| 4 | WS-D | ~0.5 session + architect decisions D3 | D1/D2 machinery; D3 needs you |
| 5 | WS-E | ~1 session | WS-A lint; E3 needs you |

Definition of done for the whole plan: every F-xx maps to a landed commit or an explicit architect rejection recorded here; `lint-brain.sh` + guard hook green on a clean checkout; strengths list unregressed (spot-check §8 reconciliation and delta discipline still described and used).

Open decision points for the architect before execution: D3 (ADR-001/002 disposition), E3 (TARGET stub scoping), and whether AGENTS.md keeps checked mirrors (B1) or becomes pointer-only.
