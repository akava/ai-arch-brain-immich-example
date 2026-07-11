# Artifacts

This folder stores structured working outputs created by agents.

These are the working memory of the architecture project: discovery syntheses, component/service specifications, NFR analyses, integration contracts, risk assessments, fitness reviews, and handoff drafts.

## Layout

`core/artifacts/` is split by lifespan:

- **Living artifacts** — kept at the root. These are the canonical definition of the system, maintained and superseded as the architecture progresses: component/service specifications and integration contracts. Other work points back to them.
- **Run logs** — kept under `logs/`. These are dated, point-in-time records of a single session, run, or review: syntheses, NFR analyses, risk assessments, fitness reviews, handoff drafts, and input inventories. New runs produce new files; old ones are not reopened.

`README.md` and `INDEX.md` (meta) also live at the root.

## Files

- `INDEX.md` is the compact retrieval map for every artifact — root and `logs/` alike. Read it first; verify its count against the filesystem (the `find` count recurses into `logs/`) before narrowing scope.

## Naming Conventions

Living artifacts (root) — no date in the filename; they are updated in place:

- `component-spec-[component-name].md`
- `integration-contract-[interface-name].md`

Run logs (`logs/`) — named `[session-date]-[run-slug]-[type]` so a run's artifacts group together (`[session-date]` = source session date; `[run-slug]` = a stable topic slug shared across the run):

- `logs/[session-date]-[run-slug]-synthesis.md`
- `logs/[session-date]-[run-slug]-nfr-analysis.md`
- `logs/[session-date]-[run-slug]-risk-assessment.md`
- `logs/[session-date]-[run-slug]-fitness-review.md`
- `logs/[session-date]-[run-slug]-handoff.md`
- `logs/input-inventory-[YYYY-MM-DD].md` (exception — not tied to a run)

## Living-document lifecycle

Living artifacts are maintained in place, not reissued as new dated files:

- **No date in the filename** — the filename is stable; dates live in the content.
- **State** — carried in frontmatter: `status` (`active` / `superseded` / `archived`) and `confidence`.
- **History** — git; artifacts keep no change-log section.

Run logs, by contrast, keep the date in the filename and are never reopened.

## Rules

- Every new artifact — living or log — must be added to `INDEX.md` (run the `librarian` agent).
- Artifacts are working outputs, not approved delivery. Approved outputs move to `factory/`.
- Drafts and experiments belong in `lab/`, not here.
