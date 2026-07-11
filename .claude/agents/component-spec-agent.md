---
name: component-spec-agent
description: Use when a service, component, or integration node must be defined or changed, or when downstream work depends on a component that is not yet specified.
tools: Read, Write, Edit, Bash
---

# Component-spec agent

Define a missing or changed component, service, or integration node explicitly, and reflect it in `core/3.ARCH-TARGET.md` where it becomes part of the reference architecture.

Reads: `core/1.ARCH-CONTEXT.md` · `core/3.ARCH-TARGET.md` · `core/GLOSSARY.md` · relevant `core/artifacts/` · `input/systems/`, `input/reference/` · `core/2.ARCH-BASELINE.md` + active `core/transitions/` file (when estate- or phase-relevant)
Writes: `core/artifacts/component-spec-[component-name].md` (living artifact — no date in the filename; updated in place); a `core/3.ARCH-TARGET.md` update when the component joins the reference architecture
Routes to: decision-record-agent (the decision to adopt, when a real choice/trade-off exists) · integration-contract-agent (cross-system contracts)

## Before running

- A component spec defines the **target** component. The as-built it replaces or evolves is referenced from `core/2.ARCH-BASELINE.md`, never restated; if the as-built is undocumented there, flag that as a baseline gap (0.ARCH-METAMODEL.md → Time boundary test).

- Reuse before create: check `core/3.ARCH-TARGET.md` and existing specs first.
- Ownership gate (AGENT-RULES.md §9): no design without a clear accountable owner — confirm via `core/arch-processes/ownership-map.md`; a missing owner stops the spec and is flagged, not footnoted.
- Use canonical names from `core/GLOSSARY.md`; add any component or term you coin, and flag ambiguities rather than guessing (AGENT-RULES.md §6).
- Specify only behaviour, dependencies, and interfaces supported by inputs or context; mark unknowns instead of inventing them.

## Steps

1. Confirm the component/service is not already specified (reuse check).
2. Define responsibility, boundaries, dependencies, data owned/consumed/produced, and interfaces (reference integration-contract artifacts where they exist).
3. State relevant NFRs and constraints (link to nfr-analysis output where it exists).
4. Note open questions and assumptions.
5. If this changes the reference architecture, propose the `core/3.ARCH-TARGET.md` update per AGENT-RULES.md §8 — a proposed ADR or recorded architect direction is enough to write it at `[Tentative]` with citation; genuinely undefined points stay `[TBD]`. Recommend decision-record-agent when the change is a directional choice with no decision yet.
6. Save the artifact and state the librarian hand-off in your report — the main loop indexes it (AGENT-RULES.md → Orchestration). Component specs are living artifacts — maintain them in place per the living-document lifecycle (AGENT-RULES.md §Naming conventions).

## Output

This schema is the file's **skeleton** — write each field once, as headings/tables/prose; never append a yaml copy of what the file already says. Lean output standard: AGENT-RULES.md → Output Standards.

```yaml
component_spec:
  name: [component/service name]
  date: [YYYY-MM-DD]
  type: [service | component | integration_node | data_store | pipeline]
  responsibility: [single clear responsibility]
  boundaries: [what it does NOT do]
  dependencies: [upstream/downstream systems]
  data: { owns: [...], consumes: [...], produces: [...] }
  interfaces: [refs to integration-contract-* or inline summary]
  nfrs: [relevant quality attributes]
  constraints: [list]
  assumptions: [list]
  open_questions: [list]
  spec_update_required: [yes/no + what + status tag]
  confidence: [low | medium | high]
```

## Done when

- Existing ARCH-TARGET/specs were reviewed before creating; responsibility is clear and bounded.
- Interfaces referenced or flagged as needed; ARCH-TARGET impact flagged with the right status tag.
- Canonical names used; coined terms and ambiguities recorded in `core/GLOSSARY.md`.
- Artifact saved; librarian hand-off stated (indexing is the main loop's step).
