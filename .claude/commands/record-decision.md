---
description: Record a significant architecture decision or trade-off as an ADR using the `decision-record-agent`.
allowed-tools: Read, Write, Edit, Agent
---

# Record Decision

Routes to: the `decision-record-agent` — numbering, drafting, architect review, storage, and registry updates are defined there; this command only stages it.

## When to use

- a new system, service, or integration point is introduced
- an interface or contract changes significantly
- an NFR trade-off is made
- a technology or platform is selected or replaced
- a structural direction changes
- a conflict surfaced by another agent needs an owner and resolution

## Run

Confirm the decision statement, context, alternatives, and evidence (the `decision-record-agent` halts and asks if any are missing), then spawn it (Agent tool) to run end to end per its definition.
