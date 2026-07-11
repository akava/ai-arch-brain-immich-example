# Decisions

This folder stores Architecture Decision Records (ADRs).

Use ADRs when a decision:

- changes direction
- accepts a trade-off
- resolves a conflict
- affects future architecture or implementation work
- overrides or clarifies prior assumptions
- would need to be understood by a future team member

It is acceptable for an ADR to record a process or governance ("harness/meta") decision, not only a pure architecture decision — as long as it is significant and worth retrieving later.

## Files

- `INDEX.md` is the decision registry.
- `ADR-000-template.md` is the template for new decisions.
- `ADR-[###]-[slug].md` files are individual decision records.

## Rules

- Do not silently resolve meaningful conflicts.
- Lifecycle mechanics — immutability, proposed-ADR rework-in-place, status changes, supersession, and the status-label sync — live in `INDEX.md` → Lifecycle Rules.
- Keep `INDEX.md` current when an ADR is added or its status changes.

Use the `decision-record` agent (entrypoint: `/record-decision`) to create or update decision records.
