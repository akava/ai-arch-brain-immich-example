---
source_url: https://docs.immich.app/guides/external-library
fetched: 2026-07-12
provenance: first-party Immich documentation, converted to markdown; near-complete — UI click-path prose lightly condensed. Compose example, read-only mount semantics, and job-monitoring note kept.
---

# External Library setup guide (Immich)

Step-by-step guide for adding an external library to a Docker-hosted Immich, assuming the files live on the same machine. External library management **requires administrator access**; the steps assume an admin account.

## Step 1 — mount the directory into the server container

Add volume mounts under `immich-server:` → `volumes:` in `docker-compose.yml`:

```yaml
immich-server:
  volumes:
    - ${UPLOAD_LOCATION}:/data
    - /home/user/photos1:/home/user/photos1:ro
    - /mnt/photos2:/mnt/photos2:ro
```

- `:ro` mounts the path read-only. Removing `:ro` permits Immich to **delete images** and **add XMP sidecar metadata** to the external files.
- Apply with `docker compose up -d`.

## Step 2 — create the library in the web UI

1. **Administration** (upper right) → **External Libraries** tab → **Create Library**.
2. Choose which **user owns** the library.
3. **Add** a folder path (e.g. `/home/user/photos1`) and confirm.
4. Three-dots menu → **Scan New Library Files**.

## Step 3 — monitor progress

**Administration** → **Jobs** tab: the scan shows active jobs for **library scanning, thumbnail generation, and metadata extraction**.
