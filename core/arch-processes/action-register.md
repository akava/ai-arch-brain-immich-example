# arch-processes/action-register.md — Architect-Owned Action Register

This file is a **do-not-forget list of architect-owned action items** drawn from calls — decisions to approve, ARCH-TARGET sections to reconcile, open questions to conclude, skills to run when an input lands.

It is a **live list of OPEN actions only**. It is not a delivery backlog and does not track engineering or PM tasks.

---

## Authoring rule — nothing is written without approval

The architect owns every row. **The agent never adds, removes, or drops a row on its own.** It proposes each change and writes only what the architect has explicitly approved, **one change at a time**.

- **Items come from** the action items in call/discovery material (proposed by the `synthesis-agent`) or the architect directly. Other agents may surface a candidate in their own output, but do not write here.
- **Propose, don't write.** Present each candidate add — and each removal or drop — for review. The architect approves, edits, or rejects it; only an approved change is written.
- This applies to **every** mutation: adds, removals, drops, and edits to existing rows.

---

## Triage gate — before you propose a row

Most action items in a call summary are **not** architectural. Do **not** propose an item unless it passes **every** gate below. Triage first; propose second; write only on approval.

1. **Architectural** — completing it changes architecture understanding, a decision, a spec, a contract, or a tracked risk. Delivery, ops, scheduling, comms, and vendor-execution tasks fail this gate.
2. **Architect-owned** — the **architect** must do or decide it. If the owner is engineering, the vendor, or a PM, it fails (a risk the architect tracks may still qualify if the architect owns the *decision*).
3. **Brain-improving** — completing it will update a `core/` file (flip an ADR, reconcile ARCH-TARGET, conclude an open question, produce a missing spec/contract).
4. **Open and not already tracked** — not yet done, and not already captured as an open ADR/open-question/risk that fully implies the action. If it is, link to that instead of duplicating; register a row only when the action needs its own owner and checkpoint.

**Fails the gate (do not propose):** "implement the CDC connector", "share the whiteboard / NFR doc", "schedule the follow-up Q&A", "run on-site workshops", "respond to the emailed question list." These stay in the source call summary.

**Passes the gate (propose):** "approve the streaming-engine ADR", "decide the PII strategy", "conclude and document the customer-data JDBC approach", "reconcile ARCH-TARGET to the implemented engine."

When in doubt, **do not propose** — leave it in the source summary and, if it is borderline-architectural, flag it for the architect to decide.

## Required fields (every row)

A proposed row is invalid unless it carries all of these — present it complete for approval, never with a missing owner or checkpoint.

- **Owner** — a named person or a specific role (not "team", not blank).
- **Next checkpoint** — a concrete date (`YYYY-MM-DD`) by which the item is reviewed or actioned. Required **even when the trigger is an event** ("data-contract session"): set the date you will next chase it. Past-due checkpoints are a signal to act, not to delete.
- **Status** — `open`, `in-progress`, or `blocked` (with `depends-on`).
- **Why / what it unblocks**, **Links**, and a **Trigger / depends-on** where one exists.

---

## Lifecycle

| Transition | What happens |
|------------|--------------|
| **Open → resolved** | Once the action is done and the **brain is updated** (flip the ADR status, reconcile ARCH-TARGET, answer the open question, save the spec/contract), propose deleting the row; on approval it is removed. The brain *is* the record — no DONE archive is kept here. |
| **Open → dropped** | If a decision is made *not* to do the item, propose deleting the row and logging a one-line entry in the **Dropped log** below with the reason; on approval it is removed and logged. Dropping is explicit, never silent. |

Both transitions are proposed and approved before the row is touched (see Authoring rule). Resolved items leave no trace here by design — their trace is the brain change they produced. Only **dropped** items are logged, because nothing else would record the decision not to act.

---

## Cross-linking convention (outbound-only)

- The register **links out** to the things an action touches: `[[ADR-002]]`, `OQ#8`, `R-03`, `ARCH-TARGET §1.4`. This is the only maintained direction — this file is the single home of action tracking.
- No back-reference tables are kept elsewhere. To find what tracks a thing, grep its ID (`AI-NNN`, `ADR-NNN`, `R-NN`). An open question or risk row may cite its owning `AI-NNN` inline where it helps the reader, but nothing is obliged to stay in sync.
- **ADR bodies are immutable** (`core/decisions/` lifecycle rule) and never carry action references.

---

## Register

> TODO: one row per open architect-owned action, added only after the architect approves it (see Authoring rule). Each row: stable `AI-NN` ID (never reused), the action, why / what brain change it unblocks, a named owner, a concrete `YYYY-MM-DD` checkpoint, status (`open` / `in-progress` / `blocked`), outbound links (`[[ADR-NNN]]`, `OQ#n`, `R-NN`, `ARCH-TARGET §N`), and any trigger / depends-on.

| ID | Action | Why / what it unblocks | Owner | Next checkpoint | Status | Links | Trigger / depends-on |
|----|--------|------------------------|-------|-----------------|--------|-------|----------------------|


---

## Dropped log

Items explicitly decided *not* to do. One line each: date, ID, action, reason.

| Date | ID | Action (short) | Reason dropped |
|------|----|----------------|----------------|

---

## Maintenance

Maintenance is **proposal + approval**, never an automatic edit (see Authoring rule and `core/AGENT-RULES.md` → Action register rule):

1. **Propose adds.** The `synthesis-agent` extracts action items from call/discovery material, runs each through the Triage gate, and presents those that pass — complete with all required fields and the next free `AI-NNN` — for the architect's approval. The architect may also add an item directly. Nothing is written unapproved.
2. **Propose removals.** When a registered action's brain change has landed (e.g. an ADR approved during a `fitness-review-agent` run, an ARCH-TARGET section reconciled), propose removing the row — after confirming the `core/` file was actually updated. On approval, remove it.
3. **Propose drops.** For an item decided against, propose deleting the row and logging it in the Dropped log with a reason.
4. **Flag stale checkpoints and triggers.** If a checkpoint date — or a dated trigger/depends-on — has passed, flag it to the architect; do not silently advance or delete it. The check fires at every `fitness-review-agent` run (brain-hygiene step) and every drift-check; each past-due row is presented with a proposed new date (or a removal/drop proposal) for approval.
