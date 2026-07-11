# Workflow: Artifact Lifecycle

How a piece of work moves from raw material to approved delivery.

## The flow

```text
input/ → lab/ → core/artifacts/ → core/decisions/ → factory/
```

Nothing should skip this flow without an explicit reason.

## Stages

1. **`input/`** — raw source material lands here (system docs, transcripts, briefs, telemetry). It is catalogued in `input/INDEX.md`.
2. **`lab/`** — optional space for rough thinking, experiments, and early drafts. Not authoritative.
3. **`core/artifacts/`** — agents convert validated inputs into structured outputs. The folder splits into two zones: **living artifacts** (canonical, kept-current) stay at the root — `component-spec-*`, `integration-contract-*`, and `risk-register.md`; **run logs** (dated, point-in-time records) go under `core/artifacts/logs/` — `*-synthesis`, `*-nfr-analysis`, `*-risk-assessment`, `*-fitness-review`, `*-handoff`, `input-inventory-*`. Every artifact, in either zone, is added to `core/artifacts/INDEX.md`.
4. **`core/decisions/`** — significant decisions and trade-offs are recorded as ADRs.
5. **`factory/`** — only approved, delivery-ready outputs (e.g. final handoff in `factory/handoff/`).

## Rules

- Structured outputs go in `core/artifacts/`, not scattered in `lab/` or `input/`.
- An artifact is a working output, not approved delivery — approval moves it to `factory/` (see the factory approval gate in `core/AGENT-RULES.md`).
- Every new artifact must be indexed via the `librarian-agent`.
- Outputs must include Title, Date, Source, Summary, content, and Confidence (see `core/AGENT-RULES.md`).

## Status vocabulary

- Artifacts: `active`, `superseded`, `archived` (tracked in `core/artifacts/INDEX.md`).
- Decisions: `proposed`, `approved`, `superseded`, `deprecated`, `template` (tracked in `core/decisions/INDEX.md`).
