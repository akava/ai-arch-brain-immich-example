# Create a New Project From This Template

This repository itself is the template for another architecture engagement: copy the tree into a fresh repository (do not carry this engagement's git history) and reset the content.

## Steps

1. **Copy the structure.** Keep `core/`, `guides/`, `.claude/` (including `.claude/agents/` and `.claude/commands/`), `input/`, `lab/`, `factory/`, and the root governance files (`README.md`, `CLAUDE.md`, `AGENTS.md`, `REPO_MAP.md`).

2. **Reset `core/1.ARCH-CONTEXT.md`.** It gets the new project's engagement card (identity, phase), problem statement, goals, stakeholders, scope & constraints, and an empty requirements registry. Keep the section structure; AGENT-RULES.md §1 names the minimum-required fields.

3. **Reset `core/3.ARCH-TARGET.md` and `core/2.ARCH-BASELINE.md`.** Keep `core/0.ARCH-METAMODEL.md` as is (it is the structure, not content) and keep both files on its shared §1–§7 skeleton. Set sections to `TBD` until defined.

4. **Reset `core/GLOSSARY.md`.** Keep the purpose, status convention, and maintenance rules; clear the canonical-terms table — terms are project content.

5. **Reset the living registers.** `core/arch-processes/action-register.md`: keep the authoring rule, triage gate, required fields, lifecycle, and cross-linking sections; empty the register table and the dropped log. `core/arch-processes/open-question-register.md` and `core/artifacts/risk-register.md`: keep the header rules; empty the entries.

6. **Reset decisions.** Keep `core/decisions/ADR-000-template.md` and `README.md`. Clear `INDEX.md` back to the single template row.

7. **Reset artifacts.** Keep `core/artifacts/README.md` and the `core/artifacts/logs/` subfolder (dateless living artifacts sit at the root; run logs go under `logs/`); reset `INDEX.md` to meta rows only.

8. **Reset inputs.** Empty the `input/` subfolders (keep `.gitkeep`) and reset `input/INDEX.md`.

9. **Review agents.** The agents are general-purpose for architecture work; adjust the registry in `core/AGENT-RULES.md` if the new engagement needs different agents.

10. **Confirm readiness.** Run the `/drift-check` command. Execution should stop cleanly if the minimum context is not yet filled.

## Principle

The structure is the asset. Reset the content, keep the system.
