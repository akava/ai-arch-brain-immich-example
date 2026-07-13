# ADR-000 — Architecture Decision Record Template

Copy this file and number sequentially as `ADR-001`, `ADR-002`, and so on.

---

## Decision Metadata

- **Title**: [Short descriptive title]
- **Date**: [YYYY-MM-DD]
- **Author**: [Name]
- **Severity**: [PATCH / MINOR / MAJOR]
- **Decision type**: [integration_interface / data_architecture / technology_platform / structural / nfr_quality_attribute / security / governance / trade_off]

Note:
The canonical lifecycle status is tracked in `core/decisions/INDEX.md`.

---

## When to Create an ADR

Create an ADR when:

- a new system, service, or integration point is introduced
- an interface or contract changes significantly
- an NFR or quality-attribute trade-off is made
- a technology or platform is selected or replaced
- a structural direction changes
- a constraint forces a trade-off
- project or architecture governance rules change materially

Do not create an ADR for:

- trivial configuration tweaks
- spelling fixes
- non-impactful housekeeping
- brain-machinery changes — their record is their commit (`core/AGENT-RULES.md` → Change history)

If in doubt, create the ADR.

---

## Decision Impact

- [ ] Introduces something new
- [ ] Modifies an existing element
- [ ] Overrides a previous decision

If overriding:

- **Supersedes ADR**: [ADR-XXX]

---

## Context

[Why did this decision need to be made?]

---

## Options Considered

### Option A: [Name]

- **Description**: [Description]
- **Pros**: [Pros]
- **Cons**: [Cons]

### Option B: [Name]

- **Description**: [Description]
- **Pros**: [Pros]
- **Cons**: [Cons]

### Option C: [Name if needed]

- **Description**: [Description]
- **Pros**: [Pros]
- **Cons**: [Cons]

---

## Final Decision

- **Chosen option**: [Option]
- **Rationale**: [Why this was chosen]

---

## Evidence

- [Discovery or analysis finding]
- [NFR / performance result]
- [Telemetry or data]
- [Artifact links]

---

## Constraints

- [Technical constraint]
- [Timeline constraint]
- [Compliance, regulatory, or security constraint]
- [Budget or scope constraint]

---

## Consequences

- **What this enables**: [Positive outcomes]
- **What this limits**: [Trade-offs]
- **What to watch for**: [Risks or signals]

---

## Success Metrics

- [How success will be measured]
- [When it will be evaluated]

---

## System Alignment

- **Related ADRs**: [ADR references]
- **Affects `core/3.ARCH-TARGET.md`**: [Yes / No]
- **Affects `core/1.ARCH-CONTEXT.md`**: [Yes / No]
- **Affected agents**: [agent names]
- **Related artifacts**: [Artifact links]
