# Enabler Catalog

The canonical index of **enablers** — the capabilities the architecture delivers across transitions.

**Separation of concerns:**
- **This catalog = *what* an enabler is and *how to use* it** (name, description, the requirements it realizes, the milestone that builds it). The durable, cross-transition view.
- **The transition file = *how to build* it** (delta, benefit hypothesis, acceptance criteria, sequencing, open decisions), per `core/transitions/README.md`. Each catalog row links to that build detail.

Each enabler carries a stable ID **`E-NN`**, is defined once here (ID + name + description), and is built in exactly one transition; later transitions that extend it add a note referencing the extending phase. Names are the canonical terms — keep them in step with `core/GLOSSARY.md`.

**Enablers are not features.** An enabler is a technical / infrastructure / architectural capability built to support delivery. User-facing **features** are tracked in the transition (scope / work streams / deltas), **not** catalogued here.

---

## Catalog

> TODO: one row per enabler, added when a transition introduces one. Each row: stable `E-NN` ID, canonical name (bold), the milestone (and work stream) that builds it, a description of what the capability is and how consumers use it, the requirement IDs it realizes, and a link to the building transition's file plus any governing ADR.

| ID | Enabler | Milestone | Description — what it is & how to use | Related requirements | Build detail |
|----|---------|-----------|----------------------------------------|----------------------|--------------|

---

## Maintenance

- A new enabler is added here when a transition introduces one; the row names it and links to that transition's build detail.
- Enabler **names are canonical terms** — add/confirm them in `core/GLOSSARY.md` (the `component-spec` / `decision-record` agents coin/confirm names).
- When a transition closes (`core/transitions/README.md`), delivered enablers remain catalogued; carried-over enablers keep their row and re-point to the next transition.
