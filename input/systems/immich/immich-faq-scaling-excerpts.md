---
source_url: https://docs.immich.app/FAQ
fetched: 2026-07-11
provenance: first-party Immich documentation, converted to markdown; content abridged only where boilerplate was stripped. Selection note — only FAQ sections relevant to scaling/HA, storage and external libraries, ML capacity/performance, database integrity, and backups are kept. Omitted topic areas — commercial guidelines, user management, mobile app features, assets (editing/transcoding details), albums, Docker log operations, low-memory (Raspberry Pi) tuning, WebSocket/server-status issues.
---

# Immich FAQ — scaling / storage / ML / database / backup excerpts

## Storage

### Can I add my existing photo library?

"Yes, with an External Library."

### What happens to existing files after I choose a new Storage Template?

"Template changes will only apply to _new_ assets. To retroactively apply the template to previously uploaded assets, run the Storage Migration Job, available on the Jobs page."

### Why do my file names appear as a random string in the file manager?

"When Storage Template is off (default) Immich saves the file names in a random string (also known as random UUIDs) to prevent duplicate file names. To retrieve the original file names, you must enable the Storage Template and then run the STORAGE TEMPLATE MIGRATION job."

### What happens to duplicates in external libraries?

"Duplicate checking only exists for upload libraries, using the file hash. Furthermore, duplicate checking is not global, but _per library_. Therefore, a situation where the same file appears twice in the timeline is possible, especially for external libraries."

### Why are my edits to files not being saved in read-only external libraries?

"Images in read-write external libraries (the default) can be edited as normal. In read-only libraries (`:ro` in the `docker-compose.yml`), Immich is unable to create the `.xmp` sidecar files to store edited file metadata."

### How are deletions of files handled in external libraries?

"Immich will attempt to delete original files that have been trashed when the trash is emptied. In read-write external libraries (the default), Immich will delete the original file. In read-only libraries (`:ro` in the `docker-compose.yml`), files can still be trashed in the UI. However, when the trash is emptied, the files will re-appear in the main timeline since Immich is unable to delete the original file."

### How can I mount a CIFS/Samba volume within Docker?

The FAQ provides an example `docker-compose.yml` volume configuration with fields for username, password, local IP, and share name.

## Machine Learning

### How can I disable machine learning?

"Machine learning can be disabled under Administration > Settings > Machine Learning Settings, either entirely or by model type. For instance, you can choose to disable smart search with CLIP, but keep facial recognition enabled. This means that the machine learning service will only process the enabled jobs."

### Can I lower CPU and RAM usage?

"The initial backup is the most intensive due to the number of jobs running. The most CPU-intensive ones are transcoding and machine learning jobs (Smart Search, Face Detection), and to a lesser extent thumbnail generation."

Recommendations include: lowering job concurrency to 1, setting transcoding threads to 1-2, changing the facial recognition model to `buffalo_s` instead of `buffalo_l`, and applying container-level resource constraints.

### Can I limit CPU and RAM usage?

Example `docker-compose.yml` configuration:

```yaml
deploy:
  resources:
    limits:
      cpus: '1.00'
      memory: '1G'
```

### How can I boost machine learning speed?

"You can increase throughput by increasing the job concurrency for machine learning jobs (Smart Search, Face Detection). With higher concurrency, the host will work on more assets in parallel. You can do this by navigating to Administration > Settings > Job Settings and increasing concurrency as needed."

Warning: "On a normal machine, 2 or 3 concurrent jobs can probably max the CPU. Storage speed and latency can quickly become the limiting factor beyond this, particularly when using HDDs. The concurrency can be increased more comfortably with a GPU, but should still not be above 16 in most cases."

## Database

### Why am I getting database ownership errors?

"If you get database errors such as `FATAL: data directory "/var/lib/postgresql/data" has wrong ownership` upon database startup, this is likely due to an issue with your filesystem. NTFS and ex/FAT/32 filesystems are not supported."

### How can I verify the integrity of my database?

"Database checksums are enabled by default for new installations since v1.104.0."

Check if checksums are enabled:

```
docker exec -it immich_postgres psql --dbname=postgres --username=<DB_USERNAME> --command="show data_checksums"
```

Check for corruption:

```
docker exec -it immich_postgres psql --dbname=postgres --username=<DB_USERNAME> --command="SELECT datname, checksum_failures, checksum_last_failure FROM pg_stat_database WHERE datname IS NOT NULL"
```

Scan the file structure:

```
docker exec -it immich_postgres pg_amcheck --username=<DB_USERNAME> --heapallindexed --parent-check --rootdescend --progress --all --install-missing
```

"A normal result will end something like this and return with an exit code of `0`: 7470/8832 relations (84%), 730829/734735 pages (99%)8425/8832 relations (95%), 734367/734735 pages (99%)8832/8832 relations (100%), 734735/734735 pages (100%)"

## Backups

### How can I backup data from Immich?

"See Backup and Restore."

### How can I purge data from Immich?

"This will destroy your database and reset your instance, meaning that you start from scratch."

Removal command:

```
docker compose down -v
```

"After removing the containers and volumes, there are a few directories that need to be deleted to reset Immich to a new installation. Once they are deleted, Immich can be started back up and will be a fresh installation: `DB_DATA_LOCATION` contains the database, media info, and settings. `UPLOAD_LOCATION` contains all the media uploaded to Immich."
