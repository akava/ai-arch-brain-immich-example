# REPO_MAP.md

## Purpose

This file explains how the repository is structured and how information should move through it.

It is not a project brief and it is not an architecture specification.
It is a guide to **where things live, how they connect, and how to work inside the system**.

---

## Overview

This repository is organized into two layers:

- **Core** -> stable project knowledge and governance
- **Execution** -> inputs, exploration, skill definitions, and delivery outputs

The goal is to keep:

- stable knowledge clear and reusable
- working files separate from governing files
- outputs traceable from input to delivery

---

## Repository Map

```text
/
  README.md         -> repository overview
  CLAUDE.md         -> agent operating rules
  REPO_MAP.md       -> structure and file flow guide
  AGENTS.md         -> universal agent boot file

/core
  0.ARCH-METAMODEL.md -> the description model: shared section skeleton, status convention, entry anatomy (the gate)
  1.ARCH-CONTEXT.md   -> problem space + engagement card: stakeholders, goals, scope & constraints, essential requirements (NFR-/FR-/CON-NNN)
  2.ARCH-BASELINE.md  -> as-is architecture on the shared skeleton: current estate, as-built patterns, observed values
  3.ARCH-TARGET.md    -> target architecture: patterns, tech stack, quality adoptions, conventions
  /transitions      -> one living file per milestone (Mn) moving baseline toward target — the vision slice + enabler package
  /arch-processes   -> the architecture processes: operating model (ways of working), ownership map (arch × org), interim work registers
    action-register.md          -> open architect-owned actions that improve the brain (AI-NN; live list, no DONE archive)
    open-question-register.md   -> live registry of open questions (OQ#n; concluded rows deleted)
  AGENT-RULES.md         -> execution rules, dependencies, and skill registry
  GLOSSARY.md       -> canonical terminology: terms, variants, definitions, status
  /decisions        -> Architecture Decision Records and decision index
  /artifacts        -> structured working outputs created by agents + the risk register
    INDEX.md        -> lightweight map of structured artifacts
    risk-register.md            -> living risk & tech-debt register (R-NN)

/.claude/agents     -> the architecture agents (synthesis-agent ... librarian-agent; legacy SKILL-001...009) — the directory is the roster; AGENT-RULES.md registry adds dependency-chain semantics
/.claude/commands   -> workflow entrypoints as Claude Code commands (user-invoked chains)
/guides             -> human-facing playbooks, onboarding, and workflows
/input              -> raw project inputs
  INDEX.md          -> lightweight map of raw inputs
/lab                -> experiments, drafts, and exploration
/factory            -> approved delivery-ready outputs
```

---

## Core Layer

The `core/` folder is the stable knowledge layer of the repository.

Use it for:

- project context
- reference architecture constraints
- workflow governance
- architecture decisions
- structured project memory

This is the most important part of the system.

### `core/1.ARCH-CONTEXT.md`

`1.ARCH-CONTEXT.md` is the problem space plus the engagement card (project identity, phase): the problem statement, goals and success metrics, scope & constraints, the stakeholder table, and the essential-requirements registry (`NFR-`/`FR-`/`CON-NNN` — defined only there; solution files cite by ID). All substantial work must align with both.

### `core/0.ARCH-METAMODEL.md`

The description model — the constitution of the architecture description: one system-of-interest across problem / solution / process spaces, the shared section skeleton for BASELINE and TARGET, entry anatomy, status convention, source and naming rules. Structure changes (sections, viewpoints, ID schemes) land here first — this file is the gate.

### `core/3.ARCH-TARGET.md`

Defines (on the shared skeleton):

- the reference architecture and approved patterns
- the sanctioned tech stack and platforms
- quality-attribute adoptions per requirement ID
- interface and naming conventions
- binding delivery and operating constraints

No structured architecture output should contradict this file.

### `core/2.ARCH-BASELINE.md` and `core/transitions/`

Three files describe the architecture across time: `2.ARCH-BASELINE.md` (what it **is** — evidence-backed as-is), `3.ARCH-TARGET.md` (what it must **become** — the target rules), and one `transitions/` file per delivery phase (how **this phase** moves baseline toward target; named after its delivery goal, living while active). BASELINE and TARGET share one section skeleton (`core/0.ARCH-METAMODEL.md`): same §N = same concern, the tense decides the file — which makes gap analysis a §-to-§ comparison and transition deltas mechanical. Facts live once: as-is-only facts in ARCH-BASELINE, target rules in ARCH-TARGET, phase scope in the transition — each references the others by section, never restates. These layers hold facts about the **architecture** only; facts about the **work on it** (access, capacity, review progress, cadence) live in `core/arch-processes/` and reach the baseline solely as evidence-confidence qualifiers (the subject test). Each layer has its populating work stream in `core/arch-processes/work-streams/` — mapped 1:1 but different in kind: the stream is the process, the layer file is the deliverable.

### `core/AGENT-RULES.md`

Defines:

- how work is executed
- what dependencies apply
- how outputs are validated
- which agents exist and when to use them

This governs the system behaviour.

### `core/GLOSSARY.md`

Defines:

- canonical terms and their meaning
- variants/aliases seen in inputs (so drift is recognised, not repeated)
- term status (`confirmed` / `tentative` / `ambiguous` / `deprecated`)

Stops terminology drift across inputs and artifacts. Agents consult it for canonical names, update it with terms they coin, and flag ambiguities rather than silently picking a spelling (see `core/AGENT-RULES.md` → Terminology consistency rule).

### The living registers

Three registers, one per shared-concern type (`core/0.ARCH-METAMODEL.md` → Shared registries). The risk register describes the **system** and sits with the artifacts; the two work registers track **work on the brain** (subject test) and sit in `core/arch-processes/` — the single home for interim work-tracking items, which drain into the active transition (Azure DevOps once delivery tooling lands):

- **`core/arch-processes/action-register.md`** — live list of **architect-owned actions whose completion improves the brain** (an ADR to approve, a ARCH-TARGET section to reconcile, a question to conclude). Not a delivery/PM backlog. Open actions only: a done item's row is removed (no DONE archive); a dropped item is removed and logged with a reason. The `synthesis-agent`, `nfr-analysis-agent`, `risk-assessment-agent`, and `fitness-review-agent` reconcile it as a wrap-up step (see `core/AGENT-RULES.md` → Action register rule).
- **`core/arch-processes/open-question-register.md`** — the live registry of what is not yet known (`OQ#n`); a concluded question's row is removed, its answer lands in its home.
- **`core/artifacts/risk-register.md`** — the living risk & tech-debt register (`R-NN`); resolved rows stay visible.

### `core/decisions/`

Stores Architecture Decision Records.

Use this folder when:

- direction changes
- trade-offs are made
- assumptions are challenged
- system rules or structural logic change

ADR files are the memory of important decisions.

### `core/artifacts/`

Stores structured outputs created by agents.

Examples:

- input inventories
- discovery synthesis
- component and service specifications
- NFR / quality-attribute analyses
- integration contracts and interface specifications
- risk and tech-debt assessments
- architecture fitness reviews
- handoff drafts

This is the working memory of the project.

`core/artifacts/INDEX.md` is a compact retrieval map for major artifacts. It helps agents reuse project memory without scanning the whole folder.

---

## Execution Layer

The execution layer contains files that support active work.

### `.claude/agents/`

Contains the individual agent definitions. Each agent runs in its own context window; its frontmatter `description` is the delegation trigger.

Each agent:

- defines a workflow
- declares dependencies
- produces a structured output
- follows the rules in `core/AGENT-RULES.md`

The canonical set (legacy `SKILL-001`…`SKILL-009`; mapping in `core/AGENT-RULES.md`):

- `synthesis-agent`, `component-spec-agent`, `decision-record-agent` — discovery synthesis, specification, decision records
- `nfr-analysis-agent`, `integration-contract-agent`, `risk-assessment-agent`, `fitness-review-agent` — the analysis layer
- `handoff-agent` — implementation-facing handoff documentation
- `librarian-agent` — building, updating, and auditing `input/INDEX.md` and `core/artifacts/INDEX.md`

### `input/`

Stores raw source material.

Examples:

- meeting transcripts
- system and integration documentation
- stakeholder briefs
- telemetry and performance data
- exports from project tools

These are not structured outputs yet.

`input/INDEX.md` is a committed map of raw inputs. It may use file-level rows for traceability or group-level rows for sensitive and large folders.

Indexes are retrieval aids, not proof of completeness. For coverage-sensitive work, agents must verify actual files from the filesystem before narrowing scope.

### `lab/`

Stores exploration and temporary work.

Examples:

- prompt experiments
- rough ideas
- temporary notes
- early drafts not yet formalized

This is useful for thinking, but it is not authoritative.

### `guides/`

Contains human-facing documentation for using the repository.

Use this folder for:

- repository playbooks
- agent playbooks
- onboarding guides
- workflow explanations

Guides explain the system, but they do not replace the source of truth in `core/` or the executable agent definitions in `.claude/agents/`.

### `.claude/commands/`

Contains workflow entrypoints as Claude Code commands (user-invoked).

Use these commands for common operations such as:

- checking input drift
- running the architecture chain
- running a fitness review
- recording a decision
- preparing handoff
- opening and closing an arch transition

Commands route work to agents. They do not redefine agent behavior.

### `factory/`

Stores approved delivery-ready outputs.

Examples:

- final handoff documentation
- approved integration contracts
- engineering-ready artifacts
- CI/delivery-ready outputs

Only approved outputs should go here. What "approved" means — the status flip, the fitness-review prerequisite, and the handoff-agent packaging — is defined by the factory approval gate in `core/AGENT-RULES.md` → Delivery Location Rules.

---

## Information Flow

The intended system flow is:

1. Raw information enters through `input/`
2. Exploration and rough thinking may happen in `lab/`
3. Agents convert validated inputs into structured outputs in `core/artifacts/`
4. Important decisions are recorded in `core/decisions/`
5. Approved delivery outputs are moved to `factory/`

Nothing should skip this flow without an explicit reason.

The default end-to-end path is:

1. Evidence and understanding: `synthesis-agent`
2. Specification and analysis: `component-spec-agent`, `nfr-analysis-agent`, `integration-contract-agent`
3. Validation: `fitness-review-agent`
4. Decision and delivery: `decision-record-agent` -> `handoff-agent`
5. Cross-cutting support as needed: `risk-assessment-agent`, `librarian-agent`

---

## Placement Rules

Ask this before saving a file:

**What kind of thing is this?**

- Stable project knowledge -> save in `core/`
- Structured working output -> save in `core/artifacts/`
- Decision record -> save in `core/decisions/`
- Raw source material -> save in `input/`
- Experiment or temporary draft -> save in `lab/`
- A fact about the architecture -> the layer the time test picks: as-is -> `core/2.ARCH-BASELINE.md`, must-become rule -> `core/3.ARCH-TARGET.md`, phase-scoped -> `core/transitions/` (subject + time tests: `core/0.ARCH-METAMODEL.md` -> Content boundary rule; shared skeleton: `core/0.ARCH-METAMODEL.md`)
- A stakeholder need, goal, or requirement statement (`NFR-`/`FR-`/`CON-NNN`) -> `core/1.ARCH-CONTEXT.md` — defined only there; solution files cite the ID
- A fact about the work on the architecture (access, capacity, review progress, cadence, reporting, ownership map) -> save in `core/arch-processes/` — never in an architecture layer
- Exploratory material or the programme people roster -> save in `lab/`
- Approved delivery output -> save in `factory/`
- Human guide or playbook -> save in `guides/`
- Workflow entrypoint -> save in `.claude/commands/`

If the answer is unclear, the file probably is not defined well enough yet.

---

## Working Principle

Use the repository in this order:

1. Start with `core/1.ARCH-CONTEXT.md`
2. Validate against `core/3.ARCH-TARGET.md` (structure rules: `core/0.ARCH-METAMODEL.md`)
3. Follow the rules in `core/AGENT-RULES.md`
4. Save structured outputs in `core/artifacts/`
5. Record decisions in `core/decisions/`
6. Move approved outputs to `factory/`

This structure matters because the system only works when context, execution, decisions, and delivery stay connected.

---

## Final Note

If you are unsure where something belongs, ask:

**Is this governing knowledge, working output, raw input, exploration, or delivery?**

That question usually gives the answer.

---

## Sibling Repository

This architecture brain can be part of a multi-brain program: a sibling brain — for example a UX brain — may exist for the same program.

- A UX brain owns user, journey, and design-system knowledge.
- This brain owns architecture context, decisions, and delivery.

Sibling-brain artifacts (for example data-field matrices, domain deep-dives, and front-end architecture syntheses) may be used as **inputs** here, but they are not authoritative for architecture decisions. The source of truth for architecture remains `core/` and `.claude/agents/` in this repository.
