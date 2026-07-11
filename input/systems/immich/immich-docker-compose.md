---
source_url: https://docs.immich.app/install/docker-compose
fetched: 2026-07-11
provenance: first-party Immich documentation, converted to markdown; content abridged only where boilerplate (nav, footer) was stripped
---

# Docker Compose [Recommended] — Immich Installation

Docker Compose is the recommended production deployment method for Immich. The installation process involves three primary steps.

## Step 1 — Download the required files

Create a dedicated directory to store the configuration files:

```bash
mkdir ./immich-app
cd ./immich-app
```

Download the necessary files:

```bash
wget -O docker-compose.yml https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml
wget -O .env https://github.com/immich-app/immich/releases/latest/download/example.env
```

Alternatively, download the files through a browser and rename `example.env` to `.env`.

## Step 2 — Populate the .env file with custom values

Key configuration parameters to customize:

- **`UPLOAD_LOCATION`**: set your preferred directory for storing uploaded assets, with sufficient free space
- **`DB_PASSWORD`**: change from the default `postgres` to a custom value using only characters `A-Za-z0-9` (avoid special characters)
- **`TZ`**: uncomment and set your timezone using standard TZ identifiers
- **`IMMICH_VERSION`**: defaults to `v3`; can be pinned to a specific version like `v2.1.0`

Other defaults include `DB_USERNAME=postgres` and `DB_DATABASE_NAME=immich`.

## Step 3 — Start the containers

From the directory containing `docker-compose.yml` and `.env`:

```bash
docker compose up -d
```

### Troubleshooting notes

- Ensure the official Docker Engine is used (not distro packages), with the `docker compose` syntax rather than `docker-compose`
- For Docker Engine versions earlier than v25, comment out the `start_interval` line in the database section of `docker-compose.yml`

## Next steps

Review the Post Installation documentation and the upgrade instructions for additional configuration guidance.
