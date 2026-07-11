---
description: Close the active arch transition — formal checks, baseline promotion, carry-over of unfinished enablers (architect-invoked; AGENT-RULES §9).
allowed-tools: Read, Write, Edit, Bash, Agent
---

# Close Arch Transition

Purpose: close the active transition — the formal checks, the promotion of delivered outcomes into `core/2.ARCH-BASELINE.md` (the runway extension), and the carry-over of unfinished work. Invoking this command is the architect's explicit close instruction (`core/AGENT-RULES.md` §9). Lifecycle: `core/transitions/README.md`.

## Preconditions

- An `active` transition exists in `core/transitions/`.
- `/drift-check` passes, or drift items are explicitly accepted by the architect.

## Run

1. Walk the transition's enabler deltas against their acceptance criteria: delivered / partially delivered / not implemented. Delivered means observed or evidence-confirmed — never self-attested (`core/2.ARCH-BASELINE.md` changes only when reality changes).
2. Spawn the `fitness-review-agent` (Agent tool) on the promotion set: delivered outcomes proposed as ARCH-BASELINE entries, § by §; layer-placement and entry-anatomy checks apply.
3. Architect review: the ARCH-BASELINE promotion and the status flip (`delivered` / `abandoned`) are each the architect's explicit call — never inferred from review silence.
4. Write the **Carried over** section into the closing file: every unimplemented or partial enabler and open work item — the seed list for the next transition's deltas; nothing dropped silently. Open / watch IDs are re-homed or explicitly retired by the architect.
5. Apply the approved promotion, flip the status, and state the librarian hand-off for any indexed file changed.

## Stop conditions

- No active transition.
- Fitness review verdict `do_not_proceed` on the promotion set — the architect resolves or explicitly accepts findings first.
- Architect approval missing for the promotion or the flip.
