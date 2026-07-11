# GLOSSARY.md — Canonical Terminology

## Purpose

`GLOSSARY.md` is the source of truth for **how terms are named and what they mean** in this brain. It exists to stop terminology drift — the same system, technology, or concept being written under different names across inputs and artifacts (e.g., "order-service" vs "Order Service API", "PostgreSQL" vs "the orders database").

Agents consult this file to use canonical names and to recognise variants. When an agent meets a term that is undefined here, or that conflicts with a canonical entry, it must **raise an ambiguity flag rather than silently pick a spelling** (see `core/AGENT-RULES.md` → Terminology consistency rule).

This file governs naming. It does not replace `core/3.ARCH-TARGET.md` (system rules) or `core/1.ARCH-CONTEXT.md` (project facts).

---

## Status convention

Reuses the `core/0.ARCH-METAMODEL.md` convention:

- **`confirmed`** — canonical name and meaning verified by an authoritative source or the architect.
- **`tentative`** — in use but not yet ratified; may change.
- **`ambiguous`** — meaning or correct form is unresolved; flagged for the architect.
- **`deprecated`** — an incorrect or superseded label; do not use (kept so old references stay traceable).

---

## How this file is maintained

- **The `synthesis` agent** (reads raw input) is the primary capture point: it adds new terms, records variants with provenance, and flags ambiguities.
- **The `component-spec` / `integration-contract` agents** add or confirm terms they coin (component and contract names).
- **The `decision-record` agent** (ADR) is the promotion authority when a term encodes a real technology/architecture choice; pure spelling/naming is confirmed by the architect.
- **When to propose promotion.** A `tentative` term is proposed for `confirmed` once it recurs in a second independent session's synthesis, or enters a proposed ADR, an ARCH-TARGET entry, or a living artifact. Proposals are batched into the `fitness-review` brain-hygiene step; promotion itself stays the architect's call.
- Immutable ADRs that used an old variant are **not** edited — the **Variants seen** column keeps them traceable to the canonical term.

---

## Canonical terms

> TODO: Populate as terms are captured. Each row carries: the **canonical** term (bold, the one spelling every artifact uses), the **variants seen** in sources (transcript spellings, diagram labels, aliases — with a note on where each was seen), a concise **definition** at the right altitude (what it is, where it sits, what it is distinct from), its **status** (per the convention above, ideally with the date and who confirmed it), and the **source / owner** (the session, document, ADR, or architect ruling the entry traces to).

| Canonical | Variants seen | Definition | Status | Source / owner |
|-----------|---------------|------------|--------|----------------|

---

## Ambiguous / to-confirm

> TODO: Populate as ambiguities are flagged. Each row carries: the **term as seen** (the exact wording from the source), the **likely meaning** — including what conflicts (two candidate meanings, two spellings for one thing, or an unknown expansion) and what would resolve it (who to ask, which session or document would settle it), its **status** (`ambiguous — confirm with client`, or `resolved` with a pointer to the canonical row it became), and the **source** where the term appeared.

| Term as seen | Likely meaning | Status | Source |
|--------------|----------------|--------|--------|

---

## Deprecated / incorrect labels

> TODO: Populate as incorrect or superseded labels are ruled on. Each row carries: the deprecated **label**, the canonical term to **use instead**, and the **reason** it is wrong or superseded (mislabelled diagram, transcript spelling, an option evaluated but not selected).

| Label | Use instead | Reason |
|-------|-------------|--------|
