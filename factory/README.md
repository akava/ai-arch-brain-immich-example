# Factory

Approved, delivery-ready outputs. Only outputs that have been reviewed and approved by an architect belong here.

## Folders

| Folder | Holds |
|--------|-------|
| `ci/` | delivery and CI-facing outputs (pipelines, conformance checks, machine-readable artifacts) |
| `components/` | approved component/service and integration-contract outputs ready for consumption |
| `handoff/` | implementation-facing handoff documentation for engineering |

> Folder set mirrors the program's shared brain structure (`ci/`, `components/`, `handoff/`).

## Rules

- Nothing enters `factory/` without explicit human approval.
- Working drafts stay in `core/artifacts/`; only the approved version is promoted here.
- Approved outputs should trace back to the artifacts and ADRs that produced them.
