# Remediation Plan — "Linus Review" of the Arch Brain

**Author:** Architect (draft plan, not yet executed)
**Date:** 2026-07-16
**Status:** Proposed — pending architect approval before any edit lands
**Scope:** Machinery (metamodel, rules, agents, commands, hooks) + Content (context/baseline/target, ADRs, glossary)

> This plan **surfaces** the fixes. Per `CLAUDE.md` §7 and `AGENT-RULES.md` §9, nothing here is
> executed until approved. Items that touch approved ADRs or flip a transition/baseline state are
> flagged as **architect-gated** and, where a direction changes, are routed through `decision-record-agent`.

---

## 1. The review, distilled

Two audits (machinery + content) were run against the brain. The findings, stripped of diplomacy:

**What's genuinely good (do not "fix"):**
- The demo/fiction boundary is honest and consistently labeled everywhere (README, CONTEXT preamble, per-file banners).
- Where BASELINE/TARGET are filled in, claims are specific, falsifiable, and cited to `input/` with line numbers.
- Real evidence discipline exists: fabricated facts are caught and flagged, not invented (e.g. the ML-URL env var absence, the `[TBD]` per-asset inference time).
- Tool-scoping is real: no agent has `Agent` in its `tools:`, so "agents don't spawn agents" is structurally true.

**What's broken or bloated (the target of this plan):**

| # | Finding | Class | Evidence |
|---|---------|-------|----------|
| F1 | Index-check hook swallows its own failure (`\|\| true`) — reports MISMATCH, blocks nothing | Enforcement | `.claude/settings.json`; `check-indexes.sh` ends `exit $status` |
| F2 | Placement rule stated in 3 places, reading order in 3, agent list in 4 — no single source | Duplication | `0.ARCH-METAMODEL.md` / `AGENT-RULES.md` / `REPO_MAP.md` / commands |
| F3 | "No silent invention" rule stated twice in different wording | Duplication | `CLAUDE.md` §2 vs `AGENT-RULES.md` Non-negotiables |
| F4 | BASELINE §3 header says "registry unpopulated" after NFR-001..006/CON-001 landed | Content bug | `core/2.ARCH-BASELINE.md:209` |
| F5 | ADR-001/002 marked `approved` but record upstream Immich's history, not a decision this engagement made; sole alternative "Option B: in-process ML" is a strawman | Process theater | `ADR-001…:44`, `ADR-002…:44` |
| F6 | `"Immich"` — the most-used term in the repo — still `status: tentative` | Bureaucratic gap | `core/GLOSSARY.md` |
| F7 | Framework name-dropping (SAFe/ArchiMate/ISO 42010/arc42/TOGAF) stacked with no falsifiable content | Ceremony | `0.ARCH-METAMODEL.md:15` |
| F8 | `.claude/mcp/` and `.claude/prompts/` are empty `.gitkeep`-only scaffolds, unreferenced | Dead machinery | dirs listed |
| F9 | Fitness review spends real budget auditing the bureaucracy (brain-hygiene, run-yield) not just the architecture | Circularity | `fitness-review-agent.md` steps 6–7 |
| F10 | Every "must not" beyond tool-scoping is prompt-text only — no mechanical backing for ADR immutability, approval gate, ownership gate | Enforcement | all agents hold `Read/Write/Edit/Bash` |

The through-line: **the brain describes its own governance more rigorously than it enforces it, and states each rule in more places than it defines it.** The fixes below are mostly *subtraction* and *single-sourcing*, plus a few small pieces of real enforcement.

---

## 2. Fix plan, prioritized

### P0 — Real defects. Fix first, low risk, no direction change.

**P0.1 — Stop the index hook lying (F1)**
- **Change:** In `.claude/settings.json`, drop the `|| true` so a MISMATCH surfaces as a real non-zero SessionStart signal; keep `timeout` so a hang can't wedge startup. If the concern is "don't hard-block a session on a stale index," keep it non-fatal but make the failure *loud and unmissable* (dedicated warning line) rather than swallowed silently.
- **Decision to make (architect):** block vs. warn-loudly. Recommendation: **warn-loudly, non-blocking** — a session should start, but the mismatch must not be cosmetic. Encode the choice in a one-line comment next to the hook so the intent is explicit.
- **Files:** `.claude/settings.json` (+ optional note in `check-indexes.sh`).
- **Effort:** XS. **Risk:** low. **Gate:** none.

**P0.2 — Fix the stale BASELINE §3 header (F4)**
- **Change:** Reconcile `core/2.ARCH-BASELINE.md:209` with the actual registry state in `core/1.ARCH-CONTEXT.md`. If NFR-001..006/CON-001 are now landed, remove "registry unpopulated" / "candidates" language and cite the governing rows by ID.
- **Pre-req:** confirm current registry state in CONTEXT before editing (don't trust the audit's snapshot).
- **Files:** `core/2.ARCH-BASELINE.md`. **Effort:** S. **Risk:** low. **Gate:** none (BASELINE is as-is, editable; not an approved ADR).

**P0.3 — Promote `"Immich"` in the glossary (F6)**
- **Change:** Flip `Immich` from `tentative` → `confirmed` with a one-line promotion note. It is the subject system named in every file; leaving it tentative discredits the promotion mechanism for the cases that matter.
- **Files:** `core/GLOSSARY.md`. **Effort:** XS. **Risk:** none. **Gate:** none.

### P1 — Single-source the duplicated rules. Medium effort, medium payoff, must not lose content.

> Method for every P1 item: pick **one canonical home**, replace the other copies with a one-line pointer, and diff the copies first so no unique clause is silently dropped in the merge.

**P1.1 — Placement / content-boundary rule → one home (F2)**
- **Canonical:** `0.ARCH-METAMODEL.md` → Content boundary rule (it owns the time-boundary semantics).
- **Change:** `REPO_MAP.md` Placement Rules and `AGENT-RULES.md` Delivery Location Rules become *pointers* to it, retaining only the path table (the "which folder" lookup) that is genuinely REPO_MAP's job. Reconcile the 4-file vs 6-step reading-order variants into one list, referenced from the others.
- **Files:** `0.ARCH-METAMODEL.md`, `REPO_MAP.md`, `AGENT-RULES.md`. **Effort:** M. **Risk:** medium (easy to drop a clause). **Gate:** none, but re-read all three before/after.

**P1.2 — "No silent invention" stated once (F3)**
- **Canonical:** `AGENT-RULES.md` Non-negotiables (execution mechanics live there).
- **Change:** `CLAUDE.md` §2 keeps the *behavioral statement* but points to AGENT-RULES for the operative wording — consistent with CLAUDE.md's own "state behavior, point there" header principle, which it currently violates.
- **Files:** `CLAUDE.md`, `AGENT-RULES.md`. **Effort:** S. **Risk:** low. **Gate:** none.

**P1.3 — Agent roster: one source of truth (F2)**
- **Change:** The `.claude/agents/` directory *is* the roster. `AGENT-RULES.md` registry table stays (it adds the dependency-chain semantics the directory can't express), but `REPO_MAP.md` and `improve-agents.md` stop hardcoding the 9-name list and instead say "every file in `.claude/agents/`." Removes 2 of 4 copies that can drift.
- **Files:** `REPO_MAP.md`, `.claude/commands/improve-agents.md`. **Effort:** S. **Risk:** low. **Gate:** none.

### P2 — Kill the theater. Subtraction; needs architect sign-off on intent.

**P2.1 — Delete dead scaffolding (F8)**
- **Change:** Remove `.claude/mcp/` and `.claude/prompts/` (empty `.gitkeep` only, referenced by nothing). If they're placeholders for a real roadmap, replace each `.gitkeep` with a one-line README stating what will live there and when — otherwise delete.
- **Files:** `.claude/mcp/`, `.claude/prompts/`. **Effort:** XS. **Risk:** low. **Gate:** architect confirms they're not a planned slot.

**P2.2 — Trim the framework name-drop (F7)**
- **Change:** In `0.ARCH-METAMODEL.md:15`, cut the SAFe/ArchiMate/ISO-42010/arc42/TOGAF stack down to *at most* the one or two mappings that do real work, and only keep a mapping if a downstream rule actually consumes it. Name-checking five frameworks in one paragraph is credentialism, not constraint.
- **Files:** `0.ARCH-METAMODEL.md`. **Effort:** S. **Risk:** low (prose only). **Gate:** architect — this is the repo's "voice," confirm the trim.

**P2.3 — Right-size the fitness review (F9)**
- **Change:** Keep brain-hygiene/run-yield checks but **demote** them: a stale glossary status or a missing filing-cabinet row should be a *warning*, not a finding that can fail a review whose subject is the Immich architecture. Separate "is the architecture sound" (blocking) from "is the paperwork tidy" (advisory) in `fitness-review-agent.md` steps 6–7.
- **Files:** `.claude/agents/fitness-review-agent.md`. **Effort:** M. **Risk:** medium (changes review semantics). **Gate:** architect.

### P3 — Honesty on ADRs + real enforcement. Highest care.

**P3.1 — Relabel ADR-001/002 as retrospective, not decisions this engagement made (F5)** — **architect-gated, ADR-routed**
- **Problem:** They're `approved` but record upstream Immich's own historical design with a strawman "Option B." That uses the ADR process to check a box.
- **Options (for the architect, not for me to pick silently):**
  - **A —** Add a `Nature: retrospective / upstream-inherited` field marking them as *documenting an inherited constraint*, not a choice made here; soften "Option B" to "the counterfactual, retained for context." Least disruptive; keeps the ID chain.
  - **B —** Move them out of `decisions/` into an "inherited constraints" artifact and free the ADR numbers for real decisions.
  - **C —** Leave as-is and accept the caveat, since the repo already discloses "no human reviewed these runs."
- **Recommendation:** **A**. It's honest, cheap, and preserves references.
- **Constraint:** ADR-001/002 are `approved` → **immutable** per `decisions/INDEX.md`. This change therefore cannot be an in-place edit; it must go through `decision-record-agent` as a **supersession or a status-metadata amendment**, per the ADR lifecycle. **Do not edit the approved files directly.**
- **Files:** `core/decisions/ADR-001*.md`, `ADR-002*.md`, `core/decisions/INDEX.md`. **Effort:** M. **Risk:** high (lifecycle rules). **Gate:** architect + `decision-record-agent`.

**P3.2 — Add mechanical backing to at least the cheapest "must not" (F10)** — **architect-gated**
- **Reality:** Every guarantee beyond tool-scoping is prompt-text only. An agent with `Write/Edit` can rewrite an approved ADR; nothing stops it.
- **Change (proposed, pick a subset):**
  - A pre-commit / CI check that fails if any file matching `core/decisions/ADR-*` with `Status: approved` is modified without a corresponding supersession entry in `INDEX.md`. This makes ADR immutability *enforced*, not requested.
  - Extend `check-indexes.sh` (once P0.1 makes it non-cosmetic) as the template for other structural invariants.
- **Explicitly out of scope:** trying to sandbox agent tool access further — the demo needs `Write/Edit`. Enforcement belongs at the git/CI boundary, not by starving the agents.
- **Files:** new `.claude/scripts/check-adr-immutability.sh` + hook or CI wiring; `INDEX.md` format may need a machine-readable supersession marker.
- **Effort:** M–L. **Risk:** medium. **Gate:** architect — this adds a real gate to their workflow; they must want it.

---

## 3. Sequencing

1. **P0** (P0.1, P0.2, P0.3) — independent, land together; pure defect fixes, no gate.
2. **P1** (P1.1 → P1.3) — do the diff-before-merge dedup; land as one "single-source the rules" change so cross-references stay consistent.
3. **P2** (P2.1, P2.2, P2.3) — subtraction; each needs a one-line architect confirm, none blocks the others.
4. **P3** — last, most care. P3.1 through `decision-record-agent`; P3.2 only if the architect wants a real gate.

Do **not** batch P3 with the rest — it touches approved ADRs and the enforcement model, which are exactly the things this repo says must not move without explicit instruction.

## 4. What this plan deliberately does NOT do

- It does not fill the TODO sections of BASELINE/TARGET (§1.5, §2, §4.x, §5). That's architecture *work*, not review remediation — different backlog, needs real evidence, out of scope here.
- It does not "fix" the demo/fiction labeling — that's a strength, not a defect.
- It does not re-tool the agent framework or add indirection. Every change above removes a copy, deletes an empty folder, or turns a swallowed check into a real one. The brain does not need more machinery; it needs less, and for the little that remains to actually bite.

---

## 5. Open decisions for the architect (blocking their respective items)

1. **P0.1** — index-hook on mismatch: block the session, or warn-loudly-but-continue? *(rec: warn-loudly)*
2. **P2.1** — are `.claude/mcp/` & `.claude/prompts/` planned slots or cruft? *(rec: delete unless roadmapped)*
3. **P2.2** — how much of the framework-mapping paragraph is load-bearing "voice" to keep?
4. **P3.1** — ADR-001/002 relabel path: A (retrospective field), B (move out), or C (leave + caveat)? *(rec: A, via `decision-record-agent`)*
5. **P3.2** — do you want a real ADR-immutability git/CI gate, or is prompt-text discipline acceptable for a demo? *(rec: add the gate — it's the finding with the highest credibility payoff)*
