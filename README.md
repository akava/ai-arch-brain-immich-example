# AI-Native Architecture Repository — the "Architecture Brain"

## What This Is

This repository is a structured system for AI-assisted architecture work across discovery, integration design, decision-making, quality attributes, risk tracking, and implementation-facing delivery — an **architecture brain**: the machinery (metamodel, agent rules, nine agents, workflow commands) is reusable, and the content layers (`core/` documents, `input/`, artifacts, decisions) are filled per engagement.

This public repository is both a **template** and a **worked demo**:

- The **`template` tag** holds the clean skeleton — every content section carries a `> TODO:` placeholder describing what belongs there; nothing engagement-specific is filled in.
- **`main`** additionally contains **demo runs**: the architecture chain executed against the public documentation of **Immich** (a self-hosted photo/video platform) across six simulated discovery/design sessions — D1 architecture overview, D2 ML & media deep dive, D3 managed-hosting scale-up design, D4 identity & access, D5 operability & observability, and D6 customer-library onboarding. The AI agents run unattended, with the orchestrating agent acting as the architect, so you can see what the brain produces — syntheses, component specs, contracts, NFR analyses, risks, ADRs — without any confidential material. Demo outputs are unreviewed agent drafts; the proposed ADRs are deliberately left unapproved. A guided tour of the demo — including the moments where the machinery caught real errors — is in **Explore the Demo** below.

It is designed to:

- turn architecture work into a repeatable process
- reduce ambiguity
- improve consistency
- connect context, decisions, structure, and delivery
- help AI support the work without taking control away from architects

The goal is simple:
**make architecture work more scalable, traceable, and reliable.**

An architecture brain serves one program. A sibling brain — for example a UX brain — may exist for the same program; this brain may reference its outputs as inputs, but it owns architecture context, decisions, and delivery independently.

---

## Core Model

The system is built around three core files:

- **`core/1.ARCH-CONTEXT.md`** -> the problem space + engagement card: who the client is, stakeholders, goals, scope & constraints, essential requirements (shared by every architecture layer; the live registers sit nearby — risks in `core/artifacts/`, actions and open questions in `core/arch-processes/`)
- **`core/3.ARCH-TARGET.md`** -> the reference architecture, sanctioned tech, patterns, and platform rules
- **`core/AGENT-RULES.md`** -> how work is executed, validated, and governed

`core/0.ARCH-METAMODEL.md` is the description model behind them — the shared section skeleton for baseline/target and the gate for structure changes.

Together, these files form the **project brain**.

Nine named agents operate on top of this foundation to produce structured outputs (legacy `SKILL-00N` IDs appear in older artifacts; the mapping lives in `core/AGENT-RULES.md`):

- **synthesis-agent, component-spec-agent, decision-record-agent** -> cross-cutting: discovery synthesis, component/service specification, and architecture decision records
- **nfr-analysis-agent, integration-contract-agent, risk-assessment-agent, fitness-review-agent** -> the architecture analysis layer: NFR & quality attributes, integration contracts, risk & tech-debt, and fitness review
- **handoff-agent** -> implementation-facing handoff documentation
- **librarian-agent** -> index maintenance for token-efficient, coverage-aware retrieval

---

## Explore the Demo (guided tour)

The fastest way to understand this repository is to read the demo engagement the way a reviewer would. The fiction: a managed-hosting operator evaluates Immich for a 50-instance pilot; six sessions (D1–D6) ran the chain from raw documentation to a pilot-enablement handoff. Every commit pair on `main` is one session: inputs first, chain artifacts second.

**Suggested reading path** (~30 minutes):

| Step | Read | What you'll see |
|------|------|-----------------|
| 1 | `core/1.ARCH-CONTEXT.md` | The engagement card, problem statement, and requirements registry — including how fiction is labeled and how an unknowable figure stays `[TBD]` |
| 2 | `core/artifacts/logs/` for one run-slug (e.g. `immich-identity-access-*`) | One full session end-to-end: synthesis → risk assessment → decision → fitness review |
| 3 | `core/2.ARCH-BASELINE.md` vs `core/3.ARCH-TARGET.md` | The as-is/target split and the shared section skeleton (§ parity) in action |
| 4 | `core/decisions/INDEX.md` | Eight ADRs: two approved as-built records vs six deliberately-unapproved design proposals |
| 5 | `core/artifacts/risk-register.md` + `core/arch-processes/` registers | Living registers with real status motion: R-01…R-12, open questions OQ#1…#7, the action row, ownership rulings |
| 6 | `core/transitions/M1-managed-hosting-pilot.md` + `ENABLER-CATALOG.md` | The delivery view: six enablers with pilot-gate acceptance criteria |
| 7 | `core/artifacts/logs/2026-07-12-immich-pilot-enablement-handoff.md` | The final DRAFT handoff — verdict "not ready to build," and why that's the honest answer |

**Moments worth finding** — the machinery catching real errors during the unattended runs:

- The integration contract (`core/artifacts/integration-contract-immich-server-ml.md`) records that a config variable named in the architect's own brief **does not exist in the evidence** — the agent refused to write it and documented the real mechanism instead.
- The D2 fitness review caught a section-numbering drift against the shared skeleton; the D3 synthesis executed the correction; the D5 fitness review formally adjudicated the convention (`logs/*fitness-review.md`).
- The D3 handoff was later **superseded, not edited** — frozen run logs stay frozen; the index carries the status flip (`core/artifacts/INDEX.md`).
- A session-limit crash left the input index stale mid-D5; the mechanical index gate (`.claude/scripts/check-indexes.sh`) blocked work until the librarian cured it — visible in the D5 commit messages.
- The 72-hour ML-backlog target could not be validated from evidence, so it stays `[TBD]` with a derived bound and a benchmark gate (`AI-001`) — no invented feasibility anywhere.

**What the demo deliberately does not show:** ADR approval flips, transition close/baseline promotion, and `factory/` delivery — all of these require a human architect's sign-off, and no human reviewed these runs. The empty `factory/` is the human-approval rule working as designed. Evidence limits are equally explicit: the whole engagement runs on first-party documentation only (recorded as risk R-04), and the committed evidence files are agent-abridged conversions carrying their source URLs and fetch dates for verification.

---

## Repository Structure

```text
/
  README.md
  CLAUDE.md
  REPO_MAP.md
  AGENTS.md

/core
  0.ARCH-METAMODEL.md -> Description model: shared skeleton, status convention (the gate)
  1.ARCH-CONTEXT.md   -> Problem space + engagement card: stakeholders, goals, requirements
  2.ARCH-BASELINE.md  -> As-is architecture (what it IS)
  3.ARCH-TARGET.md    -> Target architecture (what it must BECOME)
  transitions/      -> One file per delivery phase moving baseline toward target
  arch-processes/   -> The work ON the architecture: operating model, ownership map
  AGENT-RULES.md    -> Execution rules and agent registry
  GLOSSARY.md       -> Canonical terminology: terms, variants, definitions
  decisions/        -> Architecture Decision Records (ADRs)
  artifacts/        -> Structured working outputs

  Two classification tests govern what lands where (core/AGENT-RULES.md -> Content
  boundary rule): the SUBJECT test — a fact about the architecture goes to the
  architecture layers; a fact about the work on it (access, capacity, review
  progress, cadence) goes to arch-processes/ — then the TIME test — is
  (baseline) / must become (target) / this phase moves it (transition).

/guides
  Human-facing playbooks, onboarding, and workflows

/input
  Raw inputs such as system docs, transcripts, briefs, telemetry

/lab
  Experiments, drafts, and exploration

/factory
  Approved delivery-ready outputs

/.claude
  prompts/          -> Reusable Claude prompts
  agents/           -> The nine architecture agents
  commands/         -> Workflow entrypoints as Claude Code commands
  scripts/          -> Mechanical checks (index inventory)
  mcp/              -> MCP references
```

---

## Getting Started (using this as a template)

New here? Take the **Explore the Demo** tour above first — seeing one worked engagement makes every rule below concrete.

1. **Start from the clean skeleton** — check out the `template` tag (or delete the demo content from `main`: empty `input/`, `core/artifacts/logs/`, the demo rows in the registers, and the demo ADRs).
2. **Boot your AI host** — Claude Code boots from `CLAUDE.md`; other hosts boot through `AGENTS.md`. The required reading order and operating rules are defined there, not here.
3. **Fill the problem space** — every content file in `core/` carries per-section `> TODO:` placeholders saying exactly what lands where. Begin with the engagement card in `core/1.ARCH-CONTEXT.md`.
4. **Land evidence** — drop raw material into `input/` (folder semantics are described in `input/INDEX.md`), then run the `librarian-agent` to index it.
5. **Run the chain** — use the workflow entrypoints in `.claude/commands/` (e.g. `/run-arch-chain` from raw input to validated, decision-backed output) or invoke the nine agents individually per `core/AGENT-RULES.md`.

---

## How It Works

Use the repository in this order:

### 1. Define the context

Start with `core/1.ARCH-CONTEXT.md`.

Document:

- what engagement this is, what problem is being solved, for whom, and within what constraints (problem statement, stakeholders, goals, scope & constraints, requirements)

This is the foundation for everything else.

### 2. Define the system

Fill in `core/3.ARCH-TARGET.md`.

Document:

- the reference architecture and approved patterns
- sanctioned technologies and platforms
- NFR / quality-attribute baselines
- interface and naming conventions

This prevents reinvention and keeps outputs aligned with engineering reality.

### 3. Execute the architecture workflow

Use the agents defined in `core/AGENT-RULES.md`.

The default architecture workflow is:

- **synthesis-agent** -> research / discovery synthesis
- **component-spec-agent** -> component / service specification
- **nfr-analysis-agent** -> NFR & quality-attribute analysis
- **integration-contract-agent** -> integration contract / interface specification
- **fitness-review-agent** -> architecture fitness review

Then record decisions and prepare delivery:

- **decision-record-agent** -> architecture decision record (ADR)
- **handoff-agent** -> handoff / implementation documentation

Supporting agents are used when needed:

- **risk-assessment-agent** -> risk & tech-debt assessment (maintains the living risk register)
- **librarian-agent** -> index maintenance

Each step depends on validated inputs from the previous step.

Run **fitness-review-agent** before implementation handoff or delivery work begins.

Delivery work should not contradict approved architecture logic or decisions without creating a new ADR.

---

## Output Lifecycle

Use each area for a clear purpose:

- **`input/`** -> raw source material
- **`lab/`** -> early thinking and experiments
- **`core/artifacts/`** -> structured working outputs created by agents
- **`core/decisions/`** -> important architecture decisions and trade-offs
- **`factory/`** -> approved delivery-ready outputs

Nothing should skip this flow.

---

## What To Expect

This system is designed to:

- surface gaps in thinking
- make assumptions visible
- support consistent execution
- create traceable outputs
- keep human decision-making in control

It will not produce perfect work automatically.

Its value comes from helping architects think, structure, validate, and document the work properly.

---

## Core Principles

- **No silent invention**
  Outputs must come from defined context, system rules, validated inputs, or explicit decisions.

- **Human ownership**
  AI produces drafts and structured support. Architects make decisions and approve outcomes.

- **Structured outputs**
  Important work should be stored as artifacts and decisions, not scattered across random files.

- **Traceability**
  Context, outputs, and decisions must stay connected over time.

- **Reuse before creation**
  Existing patterns, services, and decisions must be checked before creating new ones.

---

## Architecture Decision Records

Important decisions must be documented in `core/decisions/`.

Create an ADR when:

- a new system, service, or integration point is introduced
- an interface or contract changes significantly
- an NFR or quality-attribute trade-off is made
- a technology or platform is selected or replaced
- a structural direction changes
- a constraint forces a trade-off
- project or architecture governance rules change materially

This keeps the system transparent and maintainable over time.

It is acceptable for some ADRs to record process or governance ("harness/meta") decisions, not only pure architecture decisions — as long as they are significant and worth retrieving later.

---

## What This Repository Is Not

- Not a replacement for architects
- Not a documentation dump
- Not a static reference architecture
- Not a system for blind automation

It is a structured way to do better architecture work with AI assistance.

## Tool Support

This repository is designed to remain tool-agnostic at its core.

The shared `core/` structure works across different AI-assisted environments.

Tool-specific folders (`.claude/`) act as execution layers on top of the shared system, not replacements. Agents and commands live under `.claude/` as Claude Code-native agent definitions and commands.

This allows the repository to be used with multiple environments, including Claude-based and Codex-based workflows. Non-Claude hosts boot through `AGENTS.md`, which points them into the same operating model defined in `CLAUDE.md`.

---

## Final Note

This repository should evolve through real use. Keep the structure clear, keep the context current, and keep decisions visible.

The system is only as strong as how consistently it is applied.
