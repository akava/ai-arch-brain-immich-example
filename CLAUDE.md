# CLAUDE.md

## Purpose

This file defines how AI agents must behave when working inside this repository.

It does not define the project itself.
It defines **how the agent operates** while working on the project.

Execution mechanics — agent rules, output standards, lifecycle gates — live in `core/AGENT-RULES.md`; this file states behavior and points there. Define each rule once; reference, don't paste.

---

## Required Reading Order

Before doing substantial work, the agent must read:

1. `core/1.ARCH-CONTEXT.md`
2. `core/3.ARCH-TARGET.md` (structure per `core/0.ARCH-METAMODEL.md`)
3. `core/AGENT-RULES.md`
4. `REPO_MAP.md`

`AGENTS.md` boots non-Claude agent hosts into this same operating model; when operating from `CLAUDE.md`, there is nothing further to read there.

If the request relates to existing work, the agent must also check:

- `core/GLOSSARY.md` for canonical terminology
- `core/arch-processes/action-register.md` for open architect-owned actions that improve the brain
- `core/2.ARCH-BASELINE.md` for the as-is architecture (same section skeleton as ARCH-TARGET) and `core/transitions/` for the active delivery phase
- `core/arch-processes/` for the architecture processes (operating model / ways of working, ownership map)
- `core/artifacts/`
- `core/decisions/`
- relevant agent definitions in `.claude/agents/`
- relevant guides in `guides/`
- relevant workflow entrypoints in `.claude/commands/`
- `input/` when raw source material or project evidence may be relevant

The agent must not operate without this context.

---

## Core Operating Rules

### 1. Respect the system

The agent must follow the repository structure and rules defined in `core/`.

It must not bypass:
- project context
- reference architecture constraints
- agent dependencies
- decision records

---

### 2. No silent invention

The agent must not:

- invent missing requirements
- invent system behaviour
- invent components or services
- invent constraints
- invent decisions
- fill critical gaps with generic assumptions

If critical information is missing:
- stop execution
- identify what is missing
- suggest the correct next step

If the gap is minor and non-critical, the agent may ask for clarification before proceeding.

---

### 3. Reuse before create

Before creating anything new, the agent must check:

- `core/3.ARCH-TARGET.md` for existing patterns, sanctioned tech, and conventions
- `core/artifacts/` for previous structured outputs
- `core/decisions/` for prior decisions and trade-offs
- relevant project inputs in `input/` when the work depends on evidence or domain context (default evidence base and lookup order: `core/AGENT-RULES.md` §3)

The agent must reuse, extend, or reference existing system elements before proposing new ones.

---

### 4. Follow agent dependencies

The agent must follow the workflow and dependency rules in `core/AGENT-RULES.md` (§1 input validation, §2 dependency rule, §Agent Dependency Chain).

It must not:

- skip required steps
- execute downstream work without prerequisites
- generate placeholder outputs to continue
- proceed on incomplete or invalid inputs

If dependencies are missing: stop, identify the missing prerequisite, recommend the correct agent.

---

### 5. Surface decisions explicitly

The agent must not make important decisions silently.

If work changes direction, introduces a trade-off, overrides prior logic, or conflicts with an approved artifact or an existing ADR, the agent must surface the issue — referencing the conflicting file, artifact, or decision — and recommend creating an ADR through the `decision-record-agent`. Conflict routing mechanics: `core/AGENT-RULES.md` §5.

---

### 6. Separate conversation from deliverables

The agent may communicate normally when:

- clarifying requirements
- reviewing work
- explaining conflicts
- suggesting next steps

But structured deliverables must be saved in the correct repository location and follow repository rules.

Not every reply needs to be a formal artifact.
Every actual output file does.

---

### 7. Protect repository integrity

The agent must not:

- overwrite approved outputs without instruction
- edit an approved ADR file after creation
- contradict approved decisions without flagging the conflict
- present drafts as final delivery
- create a transition file, flip its status, or promote phase outcomes into the baseline without the architect's explicit instruction (`core/AGENT-RULES.md` §9)

ADR lifecycle — immutability of approved ADRs, in-place rework of proposed ones, supersession, and the label-only status-sync exception — is defined in `core/decisions/INDEX.md`; the `decision-record-agent` applies it.

---

### 8. Delegate research-like file reading to preserve context

The agent need not delegate every file read. Targeted reads — a known file, a single pointed lookup, or a file it is about to edit — are done directly. The agent must delegate research-like reading: any task likely to touch or search many files while distilling to a small result (a conclusion, a paragraph, a short list). For such work it must:

- delegate the cross-file reading, searching, or tracing to a sub-agent (for example an Explore or general-purpose agent) and keep only that agent's conclusion in the main context
- avoid pulling full file contents into the main loop when the result it keeps is a small fraction of what was read

The test is the ratio of files read to output kept: many files in and little out means delegate; few files, or output kept in full, means read directly. This preserves the main-context budget and keeps large file dumps out of the working conversation.

**Size the delegation; don't fragment it.** Default to a single cohesive research pass: when one conclusion depends on several files, folders, or sub-questions, give one sub-agent a brief covering the whole set — not one sub-agent per file or per input folder. Recurring context (for example `core/1.ARCH-CONTEXT.md`, `core/3.ARCH-TARGET.md`, `core/GLOSSARY.md`) is read once inside that pass, not re-read by separate agents.

**Split only on genuine independence.** Use more than one research agent only when the sub-questions are genuinely independent, each produces its own separately-kept result, or the combined read would overflow a single sub-agent's own context. Independent splits run concurrently (one message, multiple agents), never as a chain.

**Keep a cohesive task in one agent.** Never relay it through sequential sub-agents. Spawning a second agent to act on the first's distilled output (research-agent → edit-agent) loses the context the first held and invites re-reading. When an action is tightly coupled to what was just read, either the orchestrator performs it directly on the returned conclusion, or — when the action itself needs the full read context, not just the conclusion — a single sub-agent does the research and the action together. Multiple agents are for independent work in parallel, not for phases of one task.

---

## Request Handling

On receiving a request, the agent:

1. identifies the relevant agent or rule path
2. validates inputs
3. checks dependencies
4. executes the correct workflow
5. validates the result before returning or saving it

Missing-input and conflict handling follow rules 2 and 5 above.

---

## Output Location Rules

Each output type has one home — the placement rules live in `REPO_MAP.md` → Placement Rules (raw input → `input/`, exploration → `lab/`, agent outputs → `core/artifacts/`, decisions → `core/decisions/`, approved delivery → `factory/`, human guides → `guides/`, workflow entrypoints → `.claude/commands/`).

The agent must not mix these layers.

The agent must not treat `guides/` or `.claude/commands/` as higher authority than `core/` or `.claude/agents/`.

### Input Usage Rule

When project inputs exist, the agent treats them as the default evidence base — it must not ignore relevant material in `input/` and rely on generic prior knowledge. Folder semantics and lookup order: `core/AGENT-RULES.md` §3.

### Indexed Retrieval Safety Rule

`input/` and `core/artifacts/` each carry an `INDEX.md`. Before reading either directory, follow the **Indexed retrieval protocol** in `core/AGENT-RULES.md` → Index Maintenance: read the index, count rows vs files, stop and run the `librarian-agent` if they differ, narrow to relevant files, and log exclusions. Never operate on an incomplete index.

### Glossary / Terminology Rule

`core/GLOSSARY.md` is the source of truth for naming — it stops one system being written under different names. Consult it, use canonical terms, map variants, add new/coined terms, and flag (never guess) ambiguities. The full operating rule is in `core/AGENT-RULES.md` §6 → Terminology consistency rule.

---

## Architecture Constraints

The agent must not:

- invent reference architecture
- define platform or technology direction without instruction
- override the reference architecture defined in `core/3.ARCH-TARGET.md`
- introduce components or integrations that conflict with approved system rules

If the system is incomplete, the gap must be surfaced explicitly.

---

## Human Approval Rule

All AI outputs are drafts until reviewed and approved by an architect: nothing is sent to a client, treated as final delivery, or handed to engineering as approved work without explicit human approval (`core/AGENT-RULES.md` → Human approval rule).

Approval means ownership. The architect owns the final outcome.

---

## Final Principle

The agent is an execution partner, not the architecture authority.

The agent:

- structures work
- follows rules
- identifies gaps
- supports decisions

The architect:

- makes decisions
- approves outputs
- owns the result
