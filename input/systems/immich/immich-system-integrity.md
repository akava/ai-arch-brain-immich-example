---
source_url: https://docs.immich.app/administration/system-integrity
fetched: 2026-07-12
provenance: first-party Immich documentation, converted to markdown; lightly abridged — prose condensed, checks/causes/error example kept verbatim. Note — this is the closest first-party page to container health checks; Immich docs have no dedicated healthcheck or logging page (docs.immich.app/administration/logging returns 404; sitemap confirms no relocation).
---

# System Integrity (Immich)

Startup folder checks that verify the server can read and write its storage volume mounts. This is Immich's first-party integrity/health mechanism at startup (there is no dedicated container-healthcheck documentation page).

## Folder checks

On startup Immich validates six folders under the upload location: `upload/`, `library/`, `thumbs/`, `encoded-video/`, `profile/`, `backups/`.

For each folder it performs three operations:

1. "Creating an initial hidden file (`.immich`) in each folder"
2. "Reading a hidden file (`.immich`) in each folder"
3. "Overwriting a hidden file (`.immich`) in each folder"

## What the checks catch

- Incorrect permissions preventing file read/write
- Missing or misconfigured volume mounts (expected `.immich` marker files absent)

## Failure example

```
Verifying system mount folder checks (enabled=true)...ENOENT: no such file or directory, open 'upload/encoded-video/.immich'
```

Possible causes: permission errors, volume mount configuration changes, manual deletion of the marker file (recreate with `touch .immich`), or an incomplete backup restoration.

## Disabling

```
IMMICH_IGNORE_MOUNT_CHECK_ERRORS=true
```

Documented as an escape hatch only for users who understand the implications — failing checks normally indicate a real configuration problem.
