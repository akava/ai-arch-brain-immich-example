---
source_url: https://docs.immich.app/features/command-line-interface
fetched: 2026-07-12
provenance: first-party Immich documentation, converted to markdown; content abridged — installation prose and quick-start boilerplate condensed. All commands, the complete upload options table (flags, defaults, env vars), and the verbatim deduplication statement kept.
---

# The Immich CLI (bulk upload)

Immich ships a command-line interface for actions such as uploading photos and videos and checking the server version. The docs note "more features are planned for the future."

## Requirements & installation

- Node.js 20 or above, npm.
- Install: `npm i -g @immich/cli` (any previous legacy CLI must be uninstalled first).
- Docker alternative (no Node needed):

```bash
docker run -it -v "$(pwd)":/import:ro \
  -e IMMICH_INSTANCE_URL=https://your-immich-instance/api \
  -e IMMICH_API_KEY=your-api-key \
  ghcr.io/immich-app/immich-cli:latest
```

## Authentication

Retrieve an API key from the user settings panel in the web interface; permission scoping is available for enhanced security. Then:

```bash
immich login <instance-url>/api <api-key>
```

## Commands

| Command | Purpose |
|---------|---------|
| `login\|login-key <url> <key>` | Authenticate with API key |
| `logout` | Remove stored credentials |
| `server-info` | Display server information |
| `upload [options] [paths...]` | Upload assets |

## `upload` options (complete)

```
-r, --recursive             Recursive (default: false, env: IMMICH_RECURSIVE)
-i, --ignore <pattern>      Pattern to ignore (env: IMMICH_IGNORE_PATHS)
-h, --skip-hash             Don't hash files before upload (default: false, env: IMMICH_SKIP_HASH)
-H, --include-hidden        Include hidden folders (default: false, env: IMMICH_INCLUDE_HIDDEN)
-a, --album                 Automatically create albums based on folder name (default: false, env: IMMICH_AUTO_CREATE_ALBUM)
-A, --album-name <name>     Add all assets to specified album (env: IMMICH_ALBUM_NAME)
-n, --dry-run               Don't perform any actions, just show what will be done (default: false, env: IMMICH_DRY_RUN)
-c, --concurrency <number>  Number of assets to upload at the same time (default: 4, env: IMMICH_UPLOAD_CONCURRENCY)
-j, --json-output           Output detailed information in json format (default: false, env: IMMICH_JSON_OUTPUT)
--delete                    Delete local assets after upload (env: IMMICH_DELETE_ASSETS)
--delete-duplicates         Delete local assets that are duplicates (already exist on server) (env: IMMICH_DELETE_DUPLICATES)
--no-progress               Hide progress bars (env: IMMICH_PROGRESS_BAR)
--watch                     Watch for changes and upload automatically (default: false, env: IMMICH_WATCH_CHANGES)
```

Examples:

```bash
immich upload file1.jpg file2.jpg
immich upload --album --recursive directory/
```

## Deduplication (verbatim)

> "By default, the upload command will hash the files before uploading them. This is to avoid uploading the same file multiple times. If you are sure that the files are unique, you can skip this step by passing the `--skip-hash` option. Note that Immich always performs its own deduplication through hashing, so this is merely a performance consideration."

Notes:

- The page documents no explicit resume flag; client-side hashing means already-uploaded files are skipped, so re-running the same command after an interruption effectively continues where it left off (server-side dedupe applies regardless).
- `--watch` keeps the CLI running, monitoring the given paths and uploading changes automatically.
