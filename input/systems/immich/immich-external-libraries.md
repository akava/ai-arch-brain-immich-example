---
source_url: https://docs.immich.app/features/libraries
fetched: 2026-07-12
provenance: first-party Immich documentation, converted to markdown; content abridged — troubleshooting walkthrough condensed to its causes list. All semantics (ownership, import paths, exclusion patterns, scan/watch behaviour, deletion) kept.
---

# External Libraries (Immich)

External libraries let Immich track and manage photos/videos stored **outside** its standard upload storage. Once scanned, external assets appear in the timeline and behave the same as natively uploaded media.

## Key limitations

- Each external library belongs to a **single user**, set at creation and unchangeable.
- Metadata added inside Immich (albums, descriptions) is **not persisted** to the external files.
- Moving assets within a library makes Immich treat them as **new files** — Immich-side metadata is lost.
- Browser cache can delay display of refreshed assets.

## Import paths

- A library scans one or more **import paths**; scanning is **recursive**.
- A file that appears under multiple import paths is imported **only once**.
- All paths must be readable directories; inaccessible paths trigger alerts during setup.
- Removing an import path deletes any external files no longer matching any path (same handling as removed files).

## Exclusion patterns

- Glob patterns matched against the **full file path**, e.g. `**/*.tif` (exclude TIFs), `**/Raw/**` (exclude directories named `Raw`); special characters need escaping, e.g. `**/\@eaDir/**`.
- Implemented with the npm `glob` package; patterns are translated to PostgreSQL `LIKE` syntax internally.

## Scanning behaviour

- **Automatic watching (experimental):** when enabled, new assets are imported automatically without manual rescans. Network drives typically do **not** support watching. An `ENOSPC` error means the file-watcher limit must be raised via `fs.inotify.max_user_watches`.
- **Nightly job:** an automatic daily scan runs on a configurable schedule; it also cleans up libraries stuck in deletion.
- Manual trigger: "Scan all libraries".

## Deletion

Deleting a library immediately removes the library listing and its assets from view; actual deletion continues in the background. If interrupted, the next nightly job completes the cleanup.

## Troubleshooting (common causes)

Incorrect Docker volume mounting; import paths in the library settings not matching the compose mounts; symlinks or backward slashes in paths; permission problems; mounts missing from worker containers. Verify by opening a container shell and confirming the path is accessible.
