---
description: Open the next milestone's arch transition — its vision slice and enabler package (architect-invoked; AGENT-RULES §9).
argument-hint: "<delivery-goal slug or phrase>"
allowed-tools: Read, Write, Edit, Bash
---

# New Arch Transition

Purpose: open the transition file for the next milestone (`Mn`) — the architecture-vision slice it delivers plus its enabler package. Invoking this command is the architect's explicit creation instruction required by `core/AGENT-RULES.md` §9; transitions are never created any other way. File traits and lifecycle: `core/transitions/README.md`; grounding: `core/0.ARCH-METAMODEL.md` → SAFe correspondence.

## Preconditions

- The previous transition is closed (`delivered` / `abandoned`) with its **Carried over** section recorded — run `/close-arch-transition` first. One transition open at a time; this is a hard gate, not a warning.
- `$1` names the delivery goal. Missing → stop and ask; never invent a goal.
- `/drift-check` passes, or drift items are explicitly accepted by the architect.

## Run

1. Assign the next `Mn`; confirm scope with the architect — goal, in/out, work streams, which baseline §N → target §N deltas the milestone delivers. Seed the delta list from the previous transition's **Carried over** section. Ask, don't assume.
2. Runway check per delta: is the foundation it needs already in `core/2.ARCH-BASELINE.md`, or built this milestone (an enabler delta)? Gaps are surfaced, never filled.
3. Scaffold `core/transitions/Mn-<goal-slug>.md` per `core/transitions/README.md`: frontmatter (`status: active`, `confidence` at what the evidence supports), goal, scope, work streams, enabler-shaped deltas keyed §N → §N, coexistence / feature-flag approach, binding gates (`core/3.ARCH-TARGET.md` §5.1/§5.2), Open / watch (IDs only — link, never restate).
4. Present the draft for architect review; save only on approval (Human approval rule). Transitions are not indexed — no librarian step.

## Stop conditions

- The previous transition is still `active`.
- Goal, scope, or delta set unconfirmed by the architect.
- A design delta has no accountable owner (ownership gate, `core/AGENT-RULES.md` §9): flag it — an enabler may be scoped to establish ownership, but design work does not proceed ownerless.
