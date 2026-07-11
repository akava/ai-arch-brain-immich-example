# Arch processes

The architecture processes we build — how the architecture work itself runs, and the ownership map that joins architecture to the org structure. Durable, governing knowledge: part of `core/`, not exploration. The folder evolves file by file; no fixed schema.

| File | Holds |
|------|-------|
| `operating-model.md` | The ways of working: posture, cadence, escalation discipline, governance instruments, reporting |
| `ownership-map.md` | Who is accountable for which component — the architecture × org view |
| `work-streams/` | The process side of the core deliverables — one stream per layer it populates (process vs deliverable) |
| `action-register.md` | Open architect-owned actions that improve the brain (`AI-NN`; live list, no DONE archive) — rules: `core/AGENT-RULES.md` §7 |
| `open-question-register.md` | Live registry of open questions (`OQ#n`; concluded rows deleted, answers land in their home) |

**Interim scaffolding.** `work-streams/` exists because the three description layers are still being populated — tracking that population is work about the brain, not about the system. Once `core/2.ARCH-BASELINE.md` is reviewed, `core/3.ARCH-TARGET.md` is stable, and transitions carry their own enabler packages, each transition manages its own work, the streams retire, and this folder converges on the operating model and the ownership map. The two work registers here (`action-register.md`, `open-question-register.md`) are on the same interim track: this folder is the single home for interim work-tracking items — keeping the architecture layers and `core/artifacts/` clean — and current-phase work items move to the active transition (and to the engagement's delivery-tracking tool once delivery tooling lands).

Boundaries — the **subject test**: facts about the *architecture* land in the architecture layers (system rules → `core/3.ARCH-TARGET.md`, §5 binding gates included; as-is estate → `core/2.ARCH-BASELINE.md`; phase movement → `core/transitions/`); facts about the *work on the architecture* (access, capacity, review progress, cadence, reporting) land here. The programme people roster stays in `lab/stakeholders/`.
