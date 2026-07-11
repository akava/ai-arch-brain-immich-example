# Repository Playbook

How to work inside this architecture brain day to day.

## The mental model

Two layers:

- **Core** (`core/`) — stable, governing knowledge: context, spec, agent governance, decisions, structured memory.
- **Execution** — inputs, exploration, agent definitions, and delivery.

Work flows: `input/ → lab/ → core/artifacts/ → core/decisions/ → factory/`.

## Before any substantial task

1. Read `core/1.ARCH-CONTEXT.md`, `core/3.ARCH-TARGET.md`, `core/AGENT-RULES.md`, `REPO_MAP.md`.
2. If the task relates to existing/as-is work, also read `core/2.ARCH-BASELINE.md` and the active `core/transitions/` phase (full conditional list: `CLAUDE.md` → Required Reading Order).
3. Run the `/drift-check` command.
4. Check `core/decisions/INDEX.md` and relevant `core/artifacts/`.

## Choosing where work goes

| What it is | Where it goes |
|------------|---------------|
| Raw source material | `input/` |
| An as-is architecture fact | `core/2.ARCH-BASELINE.md` |
| A target rule the work is validated against | `core/3.ARCH-TARGET.md` |
| A phase-scoped fact (scope, deltas, coexistence) | `core/transitions/<phase>.md` |
| A fact about the work on the architecture (access, capacity, review progress, cadence, ownership map) | `core/arch-processes/` |
| Rough thinking / experiment | `lab/` |
| Structured agent output — living artifact (`component-spec-*`, `integration-contract-*`, `risk-register.md`) | `core/artifacts/` (root) |
| Structured agent output — run log (`*-synthesis`, `*-nfr-analysis`, `*-risk-assessment`, `*-fitness-review`, `*-handoff`, `input-inventory-*`) | `core/artifacts/logs/` |
| A recorded decision | `core/decisions/` |
| Approved delivery | `factory/` |
| A human guide | `guides/` |
| A workflow entrypoint | `.claude/commands/` |

## Non-negotiables

- No silent invention — surface gaps and stop if a critical dependency is missing.
- Reuse before create — check ARCH-TARGET, artifacts, and decisions first.
- Surface decisions explicitly — route trade-offs and conflicts to the `decision-record-agent`.
- Human approval — all output is draft until an architect approves it.
- Keep indexes current — run the `librarian-agent` after creating files in `input/` or `core/artifacts/`.

## When something conflicts

Do not resolve it silently. State the conflict, name the affected artifacts/decisions, and route to the `decision-record-agent` for an ADR.
