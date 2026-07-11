---
description: Run an independent architecture fitness review (`fitness-review-agent`) before handoff or delivery.
allowed-tools: Read, Write, Edit, Bash, Agent
---

# Fitness Review

Routes to: the `fitness-review-agent` — checks, findings, verdict, routing, and indexing are defined there; this command only stages it.

## Preconditions

- A review target exists (proposed or existing architecture, or specific artifacts).
- `core/1.ARCH-CONTEXT.md`, `core/3.ARCH-TARGET.md`, and `core/decisions/` are current — run `/drift-check` first.

## Run

Identify the review target, then spawn the `fitness-review-agent` (Agent tool) to run end to end per its definition.

## Stop conditions

Stop downstream handoff if the verdict is `do_not_proceed`.
