# Fixing Plan — Machinery & Content Review Remediation

**Author:** Architect mode (this plan analyzes and sequences the review; it does not execute anything)
**Date:** 2026-07-16
**Status:** Proposed — nothing below is applied until the architect approves it
**Source:** Two independent research passes over this repo — one over the metamodel/agent/command machinery, one over the ARCH-CONTEXT/BASELINE/TARGET/ADR/artifact content — synthesized into a review, now turned into a plan.

> Per `CLAUDE.md` §7 and `AGENT-RULES.md` §9, edits to approved artifacts and transition/baseline state require explicit architect instruction. Items below that touch an **approved** ADR are marked **architect-gated + ADR-routed**: they go through `decision-record-agent`, not a direct edit.

---

## 1. What the review found, kept short

Two things came out clean, and one thing didn't.

**Content generation discipline holds up.** `core/1.ARCH-CONTEXT.md` states outright that this is a simulated engagement — Immich's technical facts are real and cited, the client/org/scale figures are invented and tagged `[Tentative]` everywhere. Claims in `2.ARCH-BASELINE.md` / `3.ARCH-TARGET.md` are specific and traceable (`DB_PASSWORD` charset, OIDC claim-sync behavior, sequential remote-ML processing — each with an `input/` citation, often to a line number). Where evidence doesn't exist, it's left `[TBD]` or explicitly flagged as absent (`core/artifacts/integration-contract-immich-server-ml.md` §1.5: searched for `IMMICH_MACHINE_LEARNING_URL`, not found, "flagged, not invented") rather than fabricated. **Do not touch this pattern — it's the thing working correctly.**

**Tool-scoping enforcement holds up.** No agent in `.claude/agents/` lists `Agent` in its `tools:` frontmatter, so "agents don't spawn other agents" is structurally true, not aspirational. **Also leave alone.**

**Everything else the review flagged is either duplicated text, unenforced text, or a rule used to check a box instead of record a real decision.** That's the target of this plan.

---

## 2. Findings register

| ID | Finding | Class | Where |
|----|---------|-------|-------|
| M1 | Seven hops between a user request and a landed fact in `TARGET.md` (reading order → 4 gate files → registry/dependency chain → optional command staging file → agent definition → index/routing → architect approval) | Over-indirection | `CLAUDE.md`, `AGENT-RULES.md`, `.claude/commands/*` |
| M2 | Five frameworks (SAFe, ArchiMate, ISO/IEC/IEEE 42010, arc42, TOGAF-ADM) stacked in one paragraph with no downstream rule that consumes any of them | Ceremony | `core/0.ARCH-METAMODEL.md` (line ~15) |
| M3 | `AGENTS.md` states "one operating model, lives in CLAUDE.md, no rules here — a copy would drift," but `CLAUDE.md`'s own no-invention rule is independently restated (different wording) in `AGENT-RULES.md` Non-negotiables | Duplication | `AGENTS.md`, `CLAUDE.md` §2, `AGENT-RULES.md` |
| M4 | Placement / content-boundary logic stated fully three times: `0.ARCH-METAMODEL.md` (canonical), `AGENT-RULES.md` Delivery Location Rules (partial restatement), `REPO_MAP.md` Placement Rules (full independent restatement) | Duplication | all three files |
| M5 | Onboarding reading order stated three times with three different file lists — `CLAUDE.md` (4 files), `AGENTS.md` (copies the 4), `REPO_MAP.md` Working Principle (a 6-step variant) | Duplication | `CLAUDE.md`, `AGENTS.md`, `REPO_MAP.md` |
| M6 | The 9-agent roster is hardcoded independently in four places — `AGENT-RULES.md` registry table, `REPO_MAP.md`, `.claude/commands/improve-agents.md`, and `.claude/agents/` itself — currently consistent, nothing forces it to stay so | Duplication | listed |
| M7 | `.claude/mcp/` and `.claude/prompts/` contain only `.gitkeep`, unreferenced by any agent or command | Dead scaffolding | listed dirs |
| M8 | `0.ARCH-METAMODEL.md` draws a "machinery, not architecture" line, and `fitness-review-agent.md` step 6 ("Brain hygiene check") + step 7 ("Run-yield check") spend real review budget auditing glossary promotion status and filing-cabinet completeness — able to fail a review on process grounds independent of whether the Immich architecture itself is sound | Circularity | `core/0.ARCH-METAMODEL.md`, `.claude/agents/fitness-review-agent.md` |
| M9 | `.claude/settings.json` runs `check-indexes.sh` on `SessionStart`, wired as `... || true` — a MISMATCH prints but the exit code is swallowed, so it blocks nothing. Beyond tool-scoping, every other "must not" (ADR immutability, ownership gate, human-approval gate, transition-status lock) has zero mechanical backing; all 9 agents hold `Read/Write/Edit/Bash` and nothing stops a direct edit to an approved file | Enforcement gap | `.claude/settings.json`, `.claude/scripts/check-indexes.sh`, all agent frontmatter |
| C1 | `core/2.ARCH-BASELINE.md` §3 header still reads "no `NFR-NNN` row yet governs these attributes (registry unpopulated)," but NFR-001..006/CON-001 had already landed in `core/1.ARCH-CONTEXT.md` by the same-day D3 run. Stale cross-reference the fitness review didn't catch. | Content bug | `core/2.ARCH-BASELINE.md` §3 |
| C2 | ADR-001 and ADR-002 are marked **approved**, but they record upstream Immich's own historical design choices, not a decision made in this engagement — each carries an invented "Option B" (e.g. "in-process ML") that was never a real alternative under consideration | Process theater | `core/decisions/ADR-001*.md`, `ADR-002*.md` |
| C3 | `"Immich"` — the single most-cited term in the repo — is still `status: tentative` in the glossary; the batch-promotion review that would flip it apparently never ran, while less-central terms (`remote machine learning`, `Smart Search`) are properly `confirmed` with a promotion trail | Bureaucratic gap | `core/GLOSSARY.md` |
| C4 | Large sections of `2.ARCH-BASELINE.md` and `3.ARCH-TARGET.md` (§1.5, §2, §4.1–4.5, §5) are still bare `> TODO:` scaffolding | Coverage gap (not a defect — honestly marked) | `core/2.ARCH-BASELINE.md`, `core/3.ARCH-TARGET.md` |

The through-line: **the machinery states its own rules more times than it enforces them, and the content is honest about what it hasn't finished but occasionally forgets to update what it already has.**

---

## 3. Remediation plan

### P0 — Real defects, fix first, no direction change, no gate

**P0.1 — Un-swallow the index check (M9, partial)**
- Remove `|| true` from the `check-indexes.sh` invocation in `.claude/settings.json`. Decide once, explicitly: should a MISMATCH block session start, or just surface loudly and continue? Recommendation: **non-blocking but unmissable** — print the mismatch as a distinct warning line a session can't silently proceed past unnoticed, without wedging startup on a stale index. Whichever is chosen, encode the choice as a one-line comment next to the hook so it's not an accident next time someone edits it.
- **Files:** `.claude/settings.json`, `.claude/scripts/check-indexes.sh`. **Effort:** XS. **Gate:** none.

**P0.2 — Reconcile the stale BASELINE header (C1)**
- `core/2.ARCH-BASELINE.md` §3 needs to cite the actual governing `NFR-001..006`/`CON-001` rows from `core/1.ARCH-CONTEXT.md` instead of claiming the registry is unpopulated. Re-verify current registry state before editing — don't trust the audit snapshot as still-current by the time this lands.
- **Files:** `core/2.ARCH-BASELINE.md`. **Effort:** S. **Gate:** none — BASELINE is as-is/editable, not an approved decision record.

**P0.3 — Promote `"Immich"` in the glossary (C3)**
- Flip `Immich` from `tentative` to `confirmed` with a one-line promotion note. It is the subject system named on every page; leaving the most-used term in the repo perpetually unpromoted undercuts the promotion mechanism for the terms where it actually matters.
- **Files:** `core/GLOSSARY.md`. **Effort:** XS. **Gate:** none.

### P1 — Single-source the duplicated rules

> Method for each item: name one canonical home, diff the copies before merging so no unique clause silently disappears, then replace the other copies with a one-line pointer.

**P1.1 — Content-boundary / placement rule → one home (M4)**
- Canonical home: `0.ARCH-METAMODEL.md`'s Content boundary rule (it owns the as-is/must-become time semantics). `REPO_MAP.md` keeps only the "which folder" path lookup table and points to the metamodel for the underlying rule; `AGENT-RULES.md` Delivery Location Rules becomes a pointer, not a restatement.
- **Files:** `core/0.ARCH-METAMODEL.md`, `REPO_MAP.md`, `core/AGENT-RULES.md`. **Effort:** M. **Risk:** medium — read all three fully before and after to confirm no clause was lost.

**P1.2 — Reading order → one list (M5)**
- Reconcile the 4-file `CLAUDE.md`/`AGENTS.md` version against `REPO_MAP.md`'s 6-step version. Canonical home: `CLAUDE.md` Required Reading Order, since it's the entrypoint every agent is told to read first. `AGENTS.md` already points here for everything else — make it point here for this too, instead of maintaining its own copy of the list. `REPO_MAP.md`'s extra steps (artifacts/decisions/factory) get folded in as an explicit "if the request touches existing work, also check" continuation of the same list, not a separate one.
- **Files:** `CLAUDE.md`, `AGENTS.md`, `REPO_MAP.md`. **Effort:** S.

**P1.3 — No-silent-invention rule → one wording (M3)**
- Canonical home: `AGENT-RULES.md` Non-negotiables (execution mechanics live there per `CLAUDE.md`'s own header). `CLAUDE.md` §2 keeps the behavioral statement (what it means, when it applies) but stops independently restating the operative wording — consistent with the "define each rule once; reference, don't paste" principle `CLAUDE.md` already states and currently doesn't follow for this rule.
- **Files:** `CLAUDE.md`, `core/AGENT-RULES.md`. **Effort:** S.

**P1.4 — Agent roster → one source (M6)**
- The `.claude/agents/` directory is the roster. `AGENT-RULES.md`'s registry table stays as-is (it adds dependency-chain semantics the bare directory listing can't express), but `REPO_MAP.md` and `.claude/commands/improve-agents.md` stop hardcoding the 9-name list and instead say "every file currently in `.claude/agents/`."
- **Files:** `REPO_MAP.md`, `.claude/commands/improve-agents.md`. **Effort:** S.

### P2 — Subtraction and rebalancing; each needs a one-line architect confirm

**P2.1 — Resolve the empty scaffolding (M7)**
- `.claude/mcp/` and `.claude/prompts/` hold only `.gitkeep` and nothing references them. Either delete them, or — if they're a placeholder for a real near-term addition — replace the `.gitkeep` with a one-line note stating what's planned and roughly when. An unexplained empty folder in a repo that otherwise insists on no invention and no dead weight is itself an inconsistency.
- **Files:** `.claude/mcp/`, `.claude/prompts/`. **Effort:** XS. **Gate:** architect confirms whether either is a live roadmap item.

**P2.2 — Trim the framework stack (M2)**
- In `core/0.ARCH-METAMODEL.md`, cut the SAFe/ArchiMate/ISO-42010/arc42/TOGAF-ADM paragraph down to only the mappings that a downstream rule actually consumes today. If none currently drive a concrete gate or template section, say so plainly rather than gesturing at five frameworks at once.
- **Files:** `core/0.ARCH-METAMODEL.md`. **Effort:** S. **Gate:** architect — this is close to the repo's stated "voice," confirm the cut.

**P2.3 — Rebalance the fitness review (M8)**
- Keep the brain-hygiene and run-yield checks, but separate them explicitly from architecture-soundness checks in `fitness-review-agent.md` steps 6–7: a stale glossary status or a missing filing-cabinet entry should be logged as an advisory note, not a finding that can fail a review whose actual subject is the Immich architecture. The point of the split: a review should never pass a bad architecture because the paperwork was tidy, and should never fail a good one because the paperwork wasn't.
- **Files:** `.claude/agents/fitness-review-agent.md`. **Effort:** M. **Risk:** medium — this changes what "review passed" means. **Gate:** architect.

### P3 — Highest care: touches an approved ADR and the enforcement model

**P3.1 — Relabel ADR-001/002 as inherited, not decided-here (C2)** — **architect-gated, ADR-routed**
- **Problem:** both are `approved` but document upstream Immich's pre-existing design, not a choice this engagement made; the "Option B" alternative in each was never a real candidate.
- **Options for the architect:**
  - **A.** Add a `Nature: inherited / upstream` field to both, softening "Option B" to "the counterfactual, retained for context, not a live alternative." Cheapest, keeps the ADR numbering and every existing reference intact.
  - **B.** Move both out of `core/decisions/` into a separate "inherited constraints" record, freeing ADR-001/002 for actual decisions made in this engagement.
  - **C.** Leave as-is; rely on the repo's existing "no human reviewed these runs" disclosure to cover it.
- **Recommendation:** **A** — cheapest, most honest, least disruptive to anything that already cites ADR-001/002.
- **Constraint:** both are `approved` → immutable per `core/decisions/INDEX.md`. This cannot be a direct in-place edit; it goes through `decision-record-agent` as a status-metadata amendment or supersession, per the ADR lifecycle rule.
- **Files:** `core/decisions/ADR-001*.md`, `core/decisions/ADR-002*.md`, `core/decisions/INDEX.md`. **Effort:** M. **Gate:** architect + `decision-record-agent`.

**P3.2 — Give at least ADR immutability a mechanical backstop (M9, remainder)** — **architect-gated**
- **Problem:** nothing besides tool-scoping is enforced. An agent with `Write/Edit` can currently rewrite an approved ADR outright.
- **Proposed:** a pre-commit or CI check that fails if a file under `core/decisions/ADR-*` carrying `Status: approved` is modified without a matching supersession entry landing in `INDEX.md` in the same change. Once P0.1 makes `check-indexes.sh` a real signal instead of a decoration, it's the template to extend for this and any future structural invariant.
- **Explicitly out of scope:** further restricting agent tool access — the demo needs `Write/Edit` to function. This belongs at the git/CI boundary, not by starving the agents of the tools they need for legitimate work.
- **Files:** new `.claude/scripts/check-adr-immutability.sh` + hook wiring; `INDEX.md` may need a machine-checkable supersession marker. **Effort:** M–L. **Gate:** architect — this adds a real gate to the workflow, confirm it's wanted before building it.

---

## 4. Sequencing

1. **P0** (P0.1, P0.2, P0.3) — independent, land together, no gate.
2. **P1** (P1.1 → P1.4) — dedup with diff-before-merge discipline; land as one "single-source the rules" change so cross-references stay internally consistent.
3. **P2** (P2.1 → P2.3) — subtraction and rebalancing; each item needs its own one-line architect confirm but doesn't block the others.
4. **P3** — last, highest care, do not batch with the rest. P3.1 goes through `decision-record-agent`; P3.2 only if the architect actually wants a real enforcement gate, not just a documented aspiration.

## 5. What this plan does not do

- It does not fill in `2.ARCH-BASELINE.md` / `3.ARCH-TARGET.md`'s remaining `TODO` sections (C4). That's architecture work requiring real evidence — a different backlog, not review remediation.
- It does not touch the demo/fiction disclosure pattern or the evidence-citation discipline. Those are the parts of this repo working as intended.
- It does not add new machinery. Every item above either removes a duplicate, deletes or explains an empty folder, rebalances what a check is allowed to fail on, or turns a check that already exists from decorative into real. The brain doesn't need more structure — it needs the structure it already claims to have.

## 6. Open decisions for the architect

1. **P0.1** — on index mismatch: block the session, or warn loudly and continue? *(recommendation: warn loudly, don't block)*
2. **P2.1** — are `.claude/mcp/` and `.claude/prompts/` planned work or leftover scaffolding? *(recommendation: delete unless there's a near-term plan for either)*
3. **P2.2** — how much of the framework-mapping paragraph in the metamodel is intentional "voice" versus filler?
4. **P3.1** — ADR-001/002 path: A (inherited-field amendment), B (move out of decisions/), or C (leave, rely on existing disclosure)? *(recommendation: A, via `decision-record-agent`)*
5. **P3.2** — is a real ADR-immutability CI/git gate worth building for this repo, or is prompt-text discipline an accepted trade-off for a demo? *(recommendation: build it — it's the single highest-credibility fix on this list)*
