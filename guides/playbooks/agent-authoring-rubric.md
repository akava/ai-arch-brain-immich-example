# Agent & Rule Authoring Rubric

The standard for writing and reviewing the brain's agents (`.claude/agents/<name>.md`)
and rule files (`core/AGENT-RULES.md`, `core/3.ARCH-TARGET.md`, `CLAUDE.md`). It distils the Anthropic
skill-creator guidance and the lifecycle rules this brain runs on. Use it when authoring a new
agent, reviewing an existing one, or running `/improve-agents`.

The goal is files a **future executor** can act on without wading through history or repetition —
not files that record how they came to be.

---

## The checks

### 1. Frontmatter is the only trigger surface

- `description` states **when to use** the agent and **what it does**, in one place. Keep it
  slightly "pushy" so the agent is delegated to when it should be.
- The body must **not** restate the description. Drop `**Goal:**`, `**Trigger:**`, and
  `**Agent:**` lines — a trigger line that echoes the frontmatter is pure duplication, and the
  label changes nothing at execution time.

### 2. Lean, predictable body shape

An agent body should read:

```
# <Name> agent
<1–2 line purpose: what it produces and why>

Reads: ...
Writes: ...
Routes to: <agent> (when) · <agent> (when)   # replaces a "SCOPE BOUNDARY" section

## Before running   (pre-conditions / guardrails)
## Steps            (numbered workflow)
## Output           (lean schema or a pointer to the naming convention)
## Done when        (the checks that confirm a good result)
```

Scope is expressed positively as a one-line `Routes to:` — what this agent hands off and to
whom. A dedicated "what this agent does NOT do" section is rarely worth its length.

### 3. No stale or meta content

Write for the next executor, not the last conversation. Cut session narrative, dated
justifications, debates about why a design was chosen ("we decided X because earlier…"), and
any wording that only made sense in the thread that produced it. State the rule, not its
backstory.

### 4. Define each rule once; reference, don't paste

A rule belongs in one canonical place — almost always `core/AGENT-RULES.md`. Agents point to it:
- Action register → `propose entries for the architect's approval; never write unprompted (AGENT-RULES.md §7)`.
- Terminology → `(AGENT-RULES.md §6)`.
- Pending-ADR ARCH-TARGET handling → `(AGENT-RULES.md §8)`.

If you find the same paragraph in two files, one is a copy — replace it with a pointer.
`CLAUDE.md` references the canonical rules in `core/AGENT-RULES.md`; it does not re-state them.

### 5. Explain, don't just forbid

Prefer one explained sentence over a stack of `MUST` / `NEVER` bullets. "Specify only behaviour
supported by inputs; mark unknowns instead of inventing them" beats five "do not invent X"
lines. Reserve emphasis for the few rules that genuinely carry risk.

### 6. Progressive disclosure / size

Keep an agent definition well under 500 lines (most belong under ~80). If it grows, push detail
into a referenced file and link to it. Trim schema comments and enums to what the producer
actually needs.

### 7. Lifecycle compliance (fact-writing agents)

Any agent that writes or proposes a `core/3.ARCH-TARGET.md` entry must follow the lifecycle in
`0.ARCH-METAMODEL.md` → Status convention and `AGENT-RULES.md` §8:

- A **proposed** ADR, or recorded architect direction with an ADR still pending, is enough to
  write the entry at `[Tentative]`, cited `(ADR-NNN, proposed)`.
- **Never block** a ARCH-TARGET entry only because its ADR is not yet approved — write it at lower
  confidence instead.
- A point with **no** backing at all stays `[TBD]` and is surfaced, not filled.
- A `[Confirmed]` entry needs **no** ADR citation — its provenance is the authoritative source.
- The proposed ADR's status is the tracker; no action-register row is needed for promotion.

An agent that routes conflicts must say *when* (a directional choice or a change to approved
scope), not just "route material ones" — leave "material" undefined and it won't be applied.

### 8. Consistent references

Use `core/AGENT-RULES.md §N`, agent names (`synthesis-agent`, `fitness-review-agent`, …), `ADR-NNN`,
`core/3.ARCH-TARGET.md §1.4`. Don't mix arrow, parenthetical, and prose forms for the same target.
Legacy `SKILL-00N` IDs appear only in the registry's mapping column and in immutable artifacts.

---

## Scoring

For each target, mark every check **pass / partial / fail** with a file:line and a short quote
for anything not passing. A rewrite is ready when every check passes and no real instruction was
lost — leanness must not drop a step, a guardrail, or an output field.
