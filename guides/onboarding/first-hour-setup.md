# First Hour Setup

A fast path to being productive in this architecture brain.

## 1. Read the core

In order:

1. `core/1.ARCH-CONTEXT.md` — the problem space + engagement card (engagement identity, problem, goals, stakeholders, constraints, requirements); the live registers (questions, actions, risks) sit in `core/artifacts/`
2. `core/3.ARCH-TARGET.md` — the reference architecture (note which sections are still `TBD`); its structure follows `core/0.ARCH-METAMODEL.md`
3. `core/AGENT-RULES.md` — how work is executed and which agents exist
4. `REPO_MAP.md` — where things live and how they flow

When the task relates to existing/as-is work, also read `core/2.ARCH-BASELINE.md` — the as-is architecture, sharing TARGET's `core/0.ARCH-METAMODEL.md` skeleton (same §N = same concern, tense decides the file) — plus the active `core/transitions/` phase. Full conditional list: `CLAUDE.md` → Required Reading Order.

## 2. Understand the lifecycle

```text
input/ → lab/ → core/artifacts/ → core/decisions/ → factory/
```

Raw material enters via `input/`. Rough thinking happens in `lab/`. Agents produce structured outputs in `core/artifacts/`, split by lifespan:

- **Living artifacts** (`component-spec-*`, `integration-contract-*`) sit at the root and are kept current in place — no date in the filename; lifecycle state is `status` + `confidence` in frontmatter.
- **Run logs** live under `core/artifacts/logs/`, named `[session-date]-[run-slug]-[type]` so every artifact of one chain-run (synthesis, nfr-analysis, risk-assessment, fitness-review, handoff) groups together. The run's `[session-date]-[run-slug]` is set by the `synthesis-agent` and reused by the rest of the chain.

Decisions are recorded in `core/decisions/`. Approved delivery moves to `factory/`.

## 3. Check current state

- Review `core/decisions/INDEX.md` for recorded decisions.
- Run the inventory check via the `/drift-check` command.

## 4. Do your first task

- Pick the matching command in `.claude/commands/` (e.g. `/record-decision`, `/fitness-review`).
- Follow the agent it routes to.
- Save outputs in the correct location and update the relevant `INDEX.md` via the `librarian-agent`.

## 5. Remember the rules

- No silent invention. Surface gaps.
- Reuse before create.
- All AI output is draft until an architect approves it.
