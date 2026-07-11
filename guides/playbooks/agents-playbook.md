# Agents Playbook

How to pick and run the right agent. Agent governance lives in `core/AGENT-RULES.md`; definitions live in `.claude/agents/`. (Legacy `SKILL-00N` IDs appear in older artifacts; the mapping is in the registry.)

## The agent set

| Agent | Legacy ID | Use when |
|-------|-----------|----------|
| synthesis-agent | SKILL-001 | Raw material needs structuring into insight |
| component-spec-agent | SKILL-002 | A service/component/integration node must be defined or changed |
| decision-record-agent | SKILL-003 | A decision/trade-off must be recorded, or a conflict needs an owner |
| nfr-analysis-agent | SKILL-004 | Quality attributes or trade-offs need analysis |
| integration-contract-agent | SKILL-005 | An interface/contract between systems must be defined or tracked |
| risk-assessment-agent | SKILL-006 | A risk or debt item must be surfaced and tracked (maintains the living risk register) |
| fitness-review-agent | SKILL-007 | Validate architecture before handoff/delivery |
| handoff-agent | SKILL-008 | Approved work is ready for engineering |
| librarian-agent | SKILL-009 | Keep `input/` and `core/artifacts/` indexes complete |

## The default chain

```text
synthesis-agent -> (component-spec-agent / nfr-analysis-agent / integration-contract-agent) -> fitness-review-agent -> decision-record-agent -> handoff-agent
```

`risk-assessment-agent` runs whenever risk/debt surfaces. The `librarian-agent` runs around any agent that reads or writes files in `input/` or `core/artifacts/`.

## Rules that apply to every agent

- Validate inputs and dependencies before running.
- Produce structured output with Title, Date, Source, Summary, content, and Confidence.
- Scale depth to the work (`lean` / `standard` / `deep`); do not over-produce.
- Cite the inputs used.
- Index new artifacts with the `librarian-agent`.

## Conflict ownership

Any agent may detect a conflict, but only `decision-record-agent` resolves a material one. The detecting agent records what conflicts, what is affected, and whether work can proceed with caveats.
