# Workflow: Working With Inputs

How to use `input/` as the evidence base for architecture work.

## Input folders

| Folder | Holds |
|--------|-------|
| `input/reference/` | standards, regulations, vendor docs, comparative/domain material |
| `input/systems/` | existing system and integration documentation |
| `input/research/` | discovery and analysis material |
| `input/stakeholder/` | briefs, workshop notes, internal direction |
| `input/analytics/` | telemetry, performance, and behavioural evidence |

## Indexed retrieval (required)

`input/` has an `INDEX.md`. When working with it, follow this sequence:

```
1. Read input/INDEX.md       → compact map of all files
2. Inventory check           → run .claude/scripts/check-indexes.sh
   On MISMATCH               → STOP, run the `librarian-agent` to update the index
3. Narrow to relevant files  → match the task's use case and keywords
4. Read selected files       → open only the relevant files
5. Log exclusions            → record skipped files and why
```

This keeps retrieval token-efficient while preserving coverage.

## Adding new inputs

1. Place the file in the correct subfolder.
2. Run the `librarian-agent` to add its row to `input/INDEX.md` and update the declared total.

## Sibling inputs

Sibling-brain artifacts (for example from a UX brain in the same program) may be referenced as inputs — for example data-field matrices, domain deep-dives, and front-end architecture syntheses. They are evidence, not authoritative architecture decisions. Cite them; do not treat them as the source of truth for architecture.

## Rule

When relevant inputs exist, do not rely on generic prior knowledge instead. Cite the inputs you used in the output artifact.
