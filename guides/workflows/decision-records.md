# Workflow: Decision Records (ADRs)

How architecture decisions are captured and tracked.

## What an ADR is

An Architecture Decision Record captures a significant decision: the context, the options, the chosen option, the rationale, and the consequences. It exists so future architects, engineers, and agents can retrieve the reasoning instead of re-deriving it.

It is acceptable for an ADR to record a process or governance ("harness/meta") decision, not only a pure architecture decision — as long as it is significant.

## When to create one

- a new system, service, or integration point is introduced
- an interface or contract changes significantly
- an NFR or quality-attribute trade-off is made
- a technology or platform is selected or replaced
- a structural direction changes
- a constraint forces a trade-off
- governance or agent-behaviour rules change materially

Do not create one for trivial config tweaks, typo fixes, or restating an already-active decision.

## How to create one

Use the `/record-decision` command, which routes to the `decision-record-agent`:

1. Provide the decision, context, alternatives, and evidence.
2. The agent assigns the next `ADR-[NNN]`, checks related decisions, and classifies it.
3. Review the draft; on approval it is stored and added to `core/decisions/INDEX.md`.

## Lifecycle and immutability

- ADR files are **immutable** once created.
- Status changes are tracked in `core/decisions/INDEX.md` (`proposed`, `approved`, `superseded`, `deprecated`).
- To change a decision, create a **new** ADR that supersedes the old one and update both rows in the index. Never edit the old ADR file.
- If an ADR changes `core/1.ARCH-CONTEXT.md` or `core/3.ARCH-TARGET.md`, update those files separately.
