# AGENT-RULES.md — Agent Governance and Registry

## Purpose

`AGENT-RULES.md` defines:

- global execution guardrails
- agent dependencies
- output standards
- the canonical agent registry

This file governs how the architecture agents work. (The filename is kept for pointer stability — rules across the repo cite `AGENT-RULES.md §N`.)

The `.claude/agents/` folder contains the individual agent definitions. Each agent runs in its own context window; the main loop delegates to it via the Agent tool or a `.claude/commands/` entrypoint. An agent's frontmatter `description` is the delegation trigger — when to use an agent is defined there and in the registry's Purpose column, nowhere else.

Agents were previously defined as numbered skills (`SKILL-001`…`SKILL-009`). Run logs, ADRs, and register rows written before the rename use those IDs; the registry below maps them.

**Orchestration.** Agents do not spawn other agents. A "Routes to" hand-off and the `librarian-agent` indexing step are fulfilled by the **main loop** when the agent returns: it routes the follow-up to the next agent, runs the `librarian-agent` after any artifact save, and carries every proposal (register rows, ADR drafts, term promotions) to the architect. Applying reviewed landings to the description layers and keeping the populating work-stream current are main-loop steps as well, gated by §9. An agent's report states what it hands off; it does not perform the hand-off.

The report itself is lean: hand-offs, proposals, verification results (what was checked and how), and deltas — never a paste of the artifact it wrote. Keep it under ~250 words unless the main loop asked for more.

---

## Global Guardrails

### Non-negotiables

- No invention of missing facts, goals, constraints, systems, or components
- No silent contradiction of approved decisions
- No skipping required dependencies
- No delivery without human approval
- No silent terminology choices — use canonical names from `core/GLOSSARY.md`; flag ambiguities, do not pick a spelling

### Human approval rule

All AI outputs are drafts until approved by an architect.

No output may be:

- sent to a client
- treated as final delivery
- handed to engineering as approved work

without explicit human approval.

---

## Execution Rules

### 1. Required input validation

Before running an agent, confirm:

- `core/1.ARCH-CONTEXT.md` contains the minimum required context: project name and current phase (→ Engagement), the problem statement, the primary goal, and core constraints (→ Scope & constraints)
- `core/3.ARCH-TARGET.md` is present for system-dependent work (note sections may still be `TBD`)
- `core/2.ARCH-BASELINE.md` and the active `core/transitions/` file are consulted when the work depends on the current estate or a delivery phase
- required upstream artifacts exist
- the request is clear enough to execute
- relevant raw inputs in `input/` have been checked when the task depends on system docs, regulations, telemetry, or stakeholder direction

If a critical dependency is missing, execution must stop.

### 2. Dependency rule

Agents must follow their prerequisite chain.

An agent must not execute if:

- required upstream outputs are missing
- required decisions are unresolved
- the request depends on undefined components or constraints

### 3. Freshness rule

Agents must use the latest valid project state.

Inputs must not be:

- outdated
- superseded
- contradicted by approved ADRs

When relevant project inputs exist in the repository, agents should prefer them over generic prior knowledge.

Default input lookup order:

1. `input/reference/` for external standards, regulations, vendor and domain material
2. `input/systems/` for hard-fact documents on the existing estate — decks, inventories, repo/service overviews, diagrams; no talks or transcripts
3. `input/stakeholder/` for human accounts — briefs, internal direction, and session notes/summaries under `stakeholder/calls/`
4. `input/transitions/<Mn>/` for evidence bounded to one delivery phase — its requirements and calls; a closed transition's folder freezes as its evidence archive
5. `input/research/` for evidence-grade analysis received from outside — own exploration homes in `lab/researches/`, never here
6. `input/analytics/` for telemetry and performance evidence

Form decides between `systems/` and `stakeholder/`: a document that *is* the fact homes in `systems/`; an account of what people said homes in `stakeholder/`. The order expresses default weight — when the question itself is phase-scoped, start at `input/transitions/<Mn>/`.

### 4. Explicit iteration rule

Iteration is allowed, but changes must be explicit.

If later work invalidates earlier outputs:

- update the relevant artifact
- log the change appropriately
- create an ADR if the change is directional or structural

### 5. Conflict ownership rule

Agents may detect conflicts, but they must not silently resolve conflicts outside their scope.

When a conflict affects approved artifacts, constraints, decisions, NFRs, or integration feasibility, route it to the `decision-record-agent` unless it is an obvious correction to a single upstream artifact.

The detecting agent must record:

- what conflicts
- which artifacts or decisions are affected
- whether work can proceed with caveats
- which downstream outputs must be updated after resolution

### 6. Terminology consistency rule

`core/GLOSSARY.md` is the source of truth for naming. Every agent must consult it and use canonical terms in every output, map variants to their canonical term, and **flag, never guess**: when a term is undefined or two names appear for one thing, raise an ambiguity flag for the architect (record it in the artifact and add an `ambiguous` row) rather than silently choosing a spelling.

Capture points, promotion triggers, and the variants convention live in `core/GLOSSARY.md` → How this file is maintained. Promotion to `confirmed` stays the architect's call (or an ADR when the term encodes a real technology/architecture choice).

### 7. Action register rule

`core/arch-processes/action-register.md` is a **do-not-forget list of architect-owned action items** — a live list of OPEN actions only, not a delivery backlog or PM tool. The register is interim (`core/arch-processes/README.md` → Interim scaffolding).

**The architect owns every row. The agent never adds, removes, or drops a row on its own — it proposes each change and writes only what the architect has explicitly approved, one change at a time.**

- New items come from call/discovery material (proposed by the `synthesis-agent`, after the register's triage gate) or from the architect directly. Other agents surface candidates in their own output; they do not write to the register.
- **Stale checkpoints and triggers.** A passed checkpoint — or a passed dated trigger/depends-on — is flagged to the architect with a proposed new date (or a removal/drop proposal), never silently advanced. The check fires at every `fitness-review-agent` run (brain-hygiene step) and every drift-check.

Triage gates, required fields, lifecycle (resolve/drop), and the cross-linking convention live in `core/arch-processes/action-register.md`.

### 8. Pending-approval ARCH-TARGET reconciliation rule

Reconcile `core/3.ARCH-TARGET.md` against a **proposed** (not-yet-approved) ADR as soon as the decision is captured, so the spec reflects the built system without breaching "approval = ownership" — a `[Tentative]` entry is not presented as final. Leaving the spec contradicting the built system until every ADR clears approval lets stale guidance misdirect downstream specs and contracts.

**Never block a ARCH-TARGET entry solely because its backing ADR is not yet approved.** Write the evidence at lower confidence instead. Per reconciled entry:

- **Write it at `[Tentative]`** with an inline citation to the ADR and its state — e.g. `(ADR-002, proposed)`. A proposed ADR, or recorded architect direction with an ADR still pending, is enough to write the entry. Only a point with no backing at all stays `[TBD]` — surface it and recommend the `decision-record-agent`.
- **Do not invent what the ADR leaves open.** Sub-questions it does not resolve stay `[TBD]`; never filled to complete a section.
- **Do not touch the ADR.** No edits to ADR files; no status flip in `core/decisions/INDEX.md`. Reconciliation is target-side and pending.

The proposed ADR's own status is the tracker for the pending entry — no separate action-register row is needed for the promotion.

**Promotion (on ADR approval):** flip the cited entries `[Tentative]` → `[Confirmed]`. A `[Confirmed]` entry needs no ADR citation — its provenance is the authoritative source — though keeping the reference is harmless.

### 9. Layer write and lifecycle rule

The description layers are approval-owned to different degrees. Per layer:

- `core/0.ARCH-METAMODEL.md` — the structure gate. Skeleton or convention changes land here first, only as an architect-approved machinery change; no agent restructures a layer directly.
- `core/1.ARCH-CONTEXT.md` — requirement rows (`NFR-`/`FR-`/`CON-NNN`) may be added with provenance; changes to the problem, goals, or scope are architect-approved and recorded through an ADR (the file's integrity rule) — never landed silently.
- `core/2.ARCH-BASELINE.md` — evidence-backed observed facts only, at the confidence the evidence supports; never changed because a target was decided. Promoting a delivered phase's outcomes into the baseline follows the transition lifecycle below.
- `core/3.ARCH-TARGET.md` — per §8 (status-tagged, ADR-cited reconciliation).
- `core/transitions/` — a transition file is created only on the architect's explicit instruction, never inferred from scope talk. One transition is open at a time: the next is created only after the previous closes with its carry-over recorded (`core/transitions/README.md`). Agents propose deltas and status changes; the `active` → `delivered`/`abandoned` flip is the architect's explicit call, and the outcome-fact promotion into `core/2.ARCH-BASELINE.md` is executed only on that approval.
- `core/arch-processes/` — process facts (subject test). After a run's landings are reviewed, the main loop updates the populating work-stream's status/landed section (`core/arch-processes/work-streams/`).

**Landings are proposals.** A `lands_in` assignment in a synthesis or analysis artifact is a routing proposal; the main loop applies it to a layer only after the architect has reviewed the producing artifact (the chain's review pause). No layer entry is written from an unreviewed run.

**Binding gates apply to design work.** The gates in `core/3.ARCH-TARGET.md` §5 constrain specs, contracts, and handoffs — in particular the ownership gate (§5.2): no design without a clear accountable owner, confirmed via `core/arch-processes/ownership-map.md`. A missing owner is a stop-and-flag, not a footnote.

---

## Output Standards

### Structured output requirements

All agent outputs saved to `core/artifacts/` must include:

- Title
- Date in `YYYY-MM-DD`
- Source
- Summary
- Main structured content
- Confidence level

### Lean output standard

The artifacts are required — their weight is not. Every generated file follows:

1. **One format.** Each fact is written once. An agent's Output schema is the **skeleton of the file** (its headings, tables, fields) — never an appended yaml restatement of the prose above it.
2. **Executive block first.** Every run log opens with ≤10 lines: purpose and verdict, key counts, what the architect must know, hand-offs. The default reader stops there.
3. **Deltas, not restatement.** Reference upstream facts by ID (`T1`, `C2`, `R-32`, `OQ#8`, `AI-014`, `QA-5`); re-state a fact only to correct it. A fitness review records what it checked and concluded, not a retelling of what it read. Producers make this possible: every theme, conflict, finding, and scenario carries a stable ID (`Tn`, `Cn`, `Fn`, `QA-n`; risks use the register's `R-NN`). Cite evidence as `path:line` or ID pointers; quote source text only when the exact wording is itself the finding.
4. **Conditional sections.** A section whose content would be "None" is omitted. Trailing lists (excluded inputs, coverage gaps, next hand-offs) are one line per item, no narrative.
5. **Budgets** — exceed only with the reason stated in the executive block:

| Artifact | Budget |
|----------|--------|
| synthesis | ≤ 120 lines |
| fitness-review | ≤ 80 lines |
| nfr-analysis | ≤ 90 lines |
| risk-assessment narrative log | ≤ 40 lines (rows live in the register) |
| handoff | ≤ 150 lines |
| INDEX `Summary` cell | ≤ 25 words (`Keywords` carry retrieval) |

### Change history

Change history lives in git. Files keep no version-history tables, change-log sections, or audit rows — and no meta-commentary about an edit inside the artifact itself; the commit message carries it. This covers decisions about the brain's own machinery too: a machinery decision's record is its commit — the project ADR registry records system decisions, not brain-tooling ones.

### Quality bar

Structured output is required, but structure is not the goal.

All agents should optimise for:

- usefulness before completeness
- prioritised insight before exhaustive field-filling
- clear judgment before generic neutrality
- adaptive depth based on confidence, scope, and project phase

Avoid producing verbose, low-signal output merely to satisfy a schema.

### Adaptive depth rule

Agents should scale detail to the work.

Use:

- `lean` for early, low-confidence, or time-constrained work
- `standard` for most project work
- `deep` only when the project complexity and input confidence justify it

Low-confidence inputs must not produce high-certainty outputs.

### Naming conventions

`core/artifacts/` is split by lifespan: **living artifacts** (component specs, integration contracts, and the risk register — the canonical definition of the system and its risks, kept current) at the root, and **run logs** (dated, point-in-time records of one session or review) under `logs/`. Save each artifact to the location its type dictates.

Living artifacts (root) — no date in the filename; updated in place, carrying `status` + `confidence` in frontmatter:

- `component-spec-[component-name].md`
- `integration-contract-[interface-name].md`
- `risk-register.md` (single global `R-NN` sequence; updated in place by the `risk-assessment-agent`)

Run logs (`logs/`) — named `[session-date]-[run-slug]-[type]` so every artifact of one chain-run groups together. `[session-date]` is the source session's date (`YYYY-MM-DD`); `[run-slug]` is a short, stable topic slug. The run's `[session-date]-[run-slug]` is established with the first artifact (synthesis) and **reused unchanged** by every downstream artifact (nfr-analysis, risk-assessment, fitness-review, handoff) — do not coin a new slug per artifact:

- `logs/[session-date]-[run-slug]-synthesis.md`
- `logs/[session-date]-[run-slug]-nfr-analysis.md`
- `logs/[session-date]-[run-slug]-risk-assessment.md`
- `logs/[session-date]-[run-slug]-fitness-review.md`
- `logs/[session-date]-[run-slug]-handoff.md`
- `logs/input-inventory-[YYYY-MM-DD].md` (exception — a folder snapshot, not tied to a run)

Decisions:

- `ADR-[NNN]-[slug].md`

---

## Delivery Location Rules

Placement rules for every output type live in `REPO_MAP.md` → Placement Rules. The rules below govern the two location decisions agents actually make: when something is *approved delivery* and when something is *not architecture*.

### Factory approval gate

Nothing lands in `factory/` without explicit architect sign-off (Human approval rule). The gate, per artifact:

1. The underlying living artifact's `status` flips `draft` → `approved` on the architect's word.
2. A fitness review covering the artifact exists — or the missing review is recorded as a gap on the handoff itself.
3. The `handoff-agent` produces the delivery-ready packaging and moves it to `factory/`; the working original stays in `core/artifacts/`.

Approval means ownership: the architect owns everything `factory/` contains.

### Content boundary rule

Where facts land is description-model jurisdiction: the rule — core vs lab, the subject test, process vs deliverable, the time boundary test — lives at `core/0.ARCH-METAMODEL.md` → Content boundary rule. Apply it at intake (synthesis theme homing), not only at fitness review.

### Evidence Usage Rule

If an agent produces analysis, synthesis, prioritisation, or recommendations, it should cite or reference the most relevant repository inputs it used.

Do not act as though `input/` is optional when raw project materials are present.

---

## Canonical Agent Registry

| Agent | Legacy ID | Purpose | Requires | Produces |
|-------|-----------|---------|----------|----------|
| synthesis-agent | SKILL-001 | Transform raw system docs, transcripts, or discovery input into structured insight themes | Raw input, relevant context | `logs/*-synthesis` artifact |
| component-spec-agent | SKILL-002 | Define a missing or changed component, service, or integration node explicitly | `core/3.ARCH-TARGET.md`, relevant context | `component-spec-*` artifact and ARCH-TARGET update |
| decision-record-agent | SKILL-003 | Record a meaningful decision or trade-off; owns formal conflict resolution | Relevant context and evidence | New ADR in `core/decisions/` and index update |
| nfr-analysis-agent | SKILL-004 | Analyse quality attributes, scenarios, and trade-offs for a system or capability | Relevant context, target system or capability | `logs/*-nfr-analysis` artifact |
| integration-contract-agent | SKILL-005 | Define and track API, event, or message contracts between systems | Relevant context, the systems and interface in question | `integration-contract-*` artifact |
| risk-assessment-agent | SKILL-006 | Surface architecture risks and tech debt with mitigation and tracking | Relevant context, target scope | `risk-register.md` update (living); optional `logs/*-risk-assessment` narrative |
| fitness-review-agent | SKILL-007 | Validate proposed or existing architecture against `core/1.ARCH-CONTEXT.md`, `core/3.ARCH-TARGET.md`, and ADRs | Target architecture or artifact and current core files | `logs/*-fitness-review` artifact |
| handoff-agent | SKILL-008 | Produce implementation-facing handoff output for engineering | Approved structure, contracts, or decisions | `logs/*-handoff` artifact or `factory/` output |
| librarian-agent | SKILL-009 | Build, update, or audit `input/INDEX.md` and `core/artifacts/INDEX.md` so agents can perform indexed retrieval instead of ad-hoc scanning | Target directory (`input/` or `core/artifacts/`) | Updated `INDEX.md` in the target directory |

---

## Agent Dependency Chain

The default architecture workflow is:

1. `synthesis-agent`
2. `component-spec-agent` — and/or `nfr-analysis-agent` and `integration-contract-agent`
3. `fitness-review-agent`
4. `decision-record-agent` (when a decision or trade-off must be recorded)
5. `handoff-agent`

Parallel or partial execution is allowed only when dependencies are still satisfied.

### Cross-cutting agents

- `risk-assessment-agent` can run at any point a risk or debt item needs to be surfaced and tracked.
- `decision-record-agent` is also the owner for formal conflict resolution when another agent surfaces a conflict it cannot resolve in its own scope.

```text
Conflict detected by any agent -> decision-record-agent -> proceed, revise, record decision, or route back to the relevant agents
```

### Index Maintenance (utility — not step-bound)

The `librarian-agent` is a utility agent, not a step in the architecture chain. It runs **before** any agent that reads from `input/` or `core/artifacts/` when the index may be stale (the inventory check below), **after** any agent that creates a file in either directory (add the new rows), and on request for a periodic coverage audit.

**Indexed retrieval protocol.** `input/` and `core/artifacts/` each carry an `INDEX.md` — a compact map of every file (File / Category / Use Case / Summary / Keywords). `core/artifacts/INDEX.md` covers both the living artifacts at its root and the run logs under `logs/`; the file count recurses into `logs/`. Before reading either directory, follow this sequence so files in a large set are never partially missed:

1. Read `INDEX.md`.
2. Inventory check — run `.claude/scripts/check-indexes.sh` (or count index rows vs actual files). On mismatch, **stop** and run the `librarian-agent`; do not proceed on an incomplete index.
3. Narrow to files matching the task's use case and keywords.
4. Read only those files, not the full set.
5. Log exclusions — list the skipped files and why.
