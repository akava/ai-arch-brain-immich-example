# Operating model — the ways of working

How the architecture engagement actually runs: posture, cadence, escalation discipline, governance instruments, reporting. Facts about the *work on the architecture* live here; facts about the architecture itself land in the description layers (the subject test: `README.md`).

> TODO: Note the primary sources for this file (e.g. kickoff or ways-of-working session logs in `core/artifacts/logs/`) and the date the model was last re-baselined, so staleness is visible.

## Posture

- Work is organised across the three architecture layers — as-is (`core/2.ARCH-BASELINE.md`), target (`core/3.ARCH-TARGET.md`), phase movement (`core/transitions/`) — plus the tactical duty of keeping the active transition unblocked.

> TODO: State the engagement's current working posture — deliberate sequencing choices (e.g. gather client context before broadening questions or overlaying industry best practice), capacity ramp, and access constraints. Source: ways-of-working sessions and architect direction.

## Cadence

> TODO: List the agreed meeting cadence — the recurring project/architecture forums, who represents the team there, and any internal preparation checkpoints before them. Source: the ways of working agreed with the client.

## Escalation discipline

- Distinguish a **genuine blocker** from a **job to be done** — a gap with a known workaround is work for this group, not a blocker.
- Try component-level options first; escalate **with evidence** (what was tried, why it failed); handle pain points in a small room with the right people; the broad forum gets only what is genuinely unresolved.
- **Reframe an unqualified "blocker" into a challenge with a proposed direction** — it changes the message to leadership entirely.

> TODO: Add the engagement-specific escalation path and a canonical non-blocker example once they emerge from real cases.

## Governance instruments

- **Ownership precedes design** — the binding gate lives in `core/3.ARCH-TARGET.md` §5; the live map: `ownership-map.md`.

> TODO: Name the client's approval and governance instruments (design authority, review board, release/change gates), state what each is — and is not — used for, and link the binding gates in `core/3.ARCH-TARGET.md` §5 and the canonical terms in `core/GLOSSARY.md`.

## Reporting

- Present the architecture position as **problems positioned on the landscape, with red flags and open points**; give formal feedback when confident — the sooner the better.
- For internal working purposes, content over polish: a small "who is who" diagram plus the landscape positioning is enough.

> TODO: Name the deliverable(s) that feed leadership reporting, the reporting rhythm, and any formal-feedback expectations the client holds.

## Work streams

The process side of the core deliverables — goals, work status, in-flight items — lives in `work-streams/` (one file per stream; each populates its core counterpart and links, never restates).
