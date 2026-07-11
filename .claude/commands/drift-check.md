---
description: Confirm context, spec, inputs, decisions, and open actions are still consistent before doing work.
allowed-tools: Read, Bash
---

# Drift Check

Purpose: confirm context, spec, inputs, decisions, and open actions are still consistent before doing work.

## Steps

1. Read `core/1.ARCH-CONTEXT.md`. Confirm the minimum required fields are present and current.
2. Read `core/3.ARCH-TARGET.md`; same for `core/2.ARCH-BASELINE.md` and the active `core/transitions/` file. Note which sections are populated vs `TBD`.
3. Run `.claude/scripts/check-indexes.sh` (the `librarian-agent`'s inventory check for `input/` and `core/artifacts/`). On any MISMATCH, run the `librarian-agent` before proceeding.
4. Review `core/decisions/INDEX.md` for recent or superseded decisions relevant to the task.
5. Check `core/arch-processes/action-register.md` for past-due checkpoints. List each as a drift item with a proposed new date — flag, never advance (AGENT-RULES.md §7).
6. Flag any drift: stale context, unmet/`TBD` spec baselines, index mismatch, superseded decisions, or past-due register checkpoints.

## Output

A short readiness statement: ready to proceed, or a list of drift items to resolve first.
