---
description: Assemble implementation-facing handoff documentation for engineering from approved architecture work (`handoff-agent`).
allowed-tools: Read, Write, Edit, Bash, Agent
---

# Prepare Handoff

Routes to: the `handoff-agent` — assembly, approval marking, and the move to `factory/handoff/` are defined there and in the factory approval gate (`core/AGENT-RULES.md` → Delivery Location Rules); this command only stages it.

## Preconditions

- Source artifacts (component specs, integration contracts, NFR analyses, ADRs) exist, approved or clearly marked draft.
- A fitness review covers the target — run `/fitness-review` first if missing; otherwise the `handoff-agent` records the gap on the handoff.

## Run

Spawn the `handoff-agent` (Agent tool) to run end to end per its definition.

## Stop conditions

Do not present drafts as final delivery. Do not hand off work that failed fitness review without an explicit, recorded caveat.
