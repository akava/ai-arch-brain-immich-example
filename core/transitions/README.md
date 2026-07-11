# Transitions

One file per transition — a named, delivery-goal-scoped phase that moves the architecture from the baseline (`core/2.ARCH-BASELINE.md`) toward the target (`core/3.ARCH-TARGET.md`). The three files answer three questions: what the architecture **is** (ARCH-BASELINE), what it must **become** (ARCH-TARGET), and **how this phase moves it** (the transition).

## Rules

- **Named `Mn-` plus its delivery goal**, not a number alone: `M1-resilient-checkout.md`. The milestone prefix `Mn` is the transition's identity — one milestone, one transition.
- **Living while active** — carries `status` (`active` / `delivered` / `abandoned`) and `confidence` in frontmatter; updated in place; change history lives in git.
- **Contains:** the goal, scope and work streams, the baseline→target deltas this phase delivers, the coexistence / feature-flag approach, the binding gates it passes through (`core/3.ARCH-TARGET.md` §5), and its open decisions.
- **Links out, never restates** — tracked items are referenced by ID (`AI-NNN`, `ADR-NNN`, `OQ#n`, `R-NN`, `Tn`); the transition is the phase view over them, not a second registry.
- **Deltas key by the shared skeleton** (`core/0.ARCH-METAMODEL.md`): baseline §N → target §N. Gap discipline: a § reviewed with no delta is recorded as carried-over, not omitted.
- **Deltas are enabler-shaped** — the transition is the milestone's vision slice plus its enabler package (`core/0.ARCH-METAMODEL.md` → SAFe correspondence): each delta carries an enabler type (`architectural` / `infrastructure` / `compliance` / `exploration`), a one-phrase statement, a benefit hypothesis, and acceptance criteria, sized to fit the milestone.
- **Enabler catalog vs transition** — `ENABLER-CATALOG.md` is the canonical cross-transition index of enablers: name, description, *what & how to use*, and the requirements each realizes. The transition holds *how to build* (delta / benefit / acceptance / sequencing). The catalog links into the transition; neither restates the other.
- **HLA here, LLD with the teams** — the transition file is the architect-owned high-level architecture of the phase; the teams' low-level design (their per-feature build-approval artefacts) is referenced, never stored here.
- **One transition is open at a time; close before create.** A new transition is created only once the previous one is closed. The close runs the formal checks — the phase's delivered outcome facts land in `core/2.ARCH-BASELINE.md` (the new as-is) under a fitness review — and **records every unimplemented enabler and open piece of work in the closing file's "Carried over" section**, the seed list for the next transition; nothing is dropped silently. The status flips to `delivered` (or `abandoned`) and the file stays as the phase record. Creation and close are the architect's explicit calls (`core/AGENT-RULES.md` §9).
