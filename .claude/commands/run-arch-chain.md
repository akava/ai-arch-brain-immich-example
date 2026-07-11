---
description: Run the full architecture chain from raw input to validated, decision-backed output (synthesis-agent through handoff-agent).
allowed-tools: Read, Write, Edit, Bash, Agent
---

# Run Architecture Chain

Purpose: move from raw input to a validated, decision-backed architecture output. The chain and its dependency rules are defined in `core/AGENT-RULES.md` → Agent Dependency Chain; each agent executes per its own definition. This command sequences them and holds the human-review gates.

```text
synthesis-agent -> (component-spec-agent / nfr-analysis-agent / integration-contract-agent) -> fitness-review-agent -> decision-record-agent -> handoff-agent
```

## Preconditions

- `core/1.ARCH-CONTEXT.md` has the required project context.
- Raw materials exist in `input/`, or lack of inputs is intentionally accepted.
- `/drift-check` passes (covers index inventory checks and recent-decision review).

## Run

1. `synthesis-agent` — establishes the run's `[session-date]-[run-slug]`, reused by every later artifact. **Pause for architect review of the synthesis and its proposed landings; apply landings only as approved (AGENT-RULES.md §9).**
2. `component-spec-agent` / `nfr-analysis-agent` / `integration-contract-agent` as the work requires; `risk-assessment-agent` whenever risk or debt surfaces.
3. `fitness-review-agent` as an independent audit. **The architect resolves or explicitly accepts findings before the chain continues.**
4. `decision-record-agent` for any decision or trade-off that must be recorded.
5. `handoff-agent` when work is approved.

## Stop conditions

Stop if dependencies are missing or any agent returns `do_not_proceed`.
