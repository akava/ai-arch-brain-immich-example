---
source_url: https://docs.immich.app/administration/backup-and-restore
fetched: 2026-07-11
provenance: first-party Immich documentation, converted to markdown; content abridged only where boilerplate (nav, footer, OS-specific command listings noted inline) was stripped
---

# Backup and Restore (Immich)

Immich recommends a 3-2-1 backup strategy. Two things must be backed up for comprehensive protection: the **database** and the **user-uploaded assets** (filesystem).

## Database backup

### Automatic backups

Immich creates automatic database backups stored in `UPLOAD_LOCATION/backups`. By default the **last 14 backups** are kept, created **daily at 2:00 AM**; configurable via Administration > Settings > Backup.

**Important:** "Database backups do **not** contain photos or videos — only metadata."

### Manual backup creation

Trigger a backup through Administration > Job Queues by selecting Create Database Dump.

### Restoration methods

**Via web interface (recommended):**
- Navigate to Administration > Maintenance
- Expand the "Restore database backup" section
- Select the desired backup and confirm restoration

**During a fresh installation:**
1. Configure `.env` and `docker-compose.yml` per the installation instructions
2. Move the previous instance's directories (`backups`, `encoded-video`, `library`, `profile`, `thumbs`, `upload`) to the new `UPLOAD_LOCATION`
3. Adjust external library mount settings if applicable
4. Start services and access the welcome screen
5. Select "Restore from backup"
6. Choose a backup or upload a `.sql.gz` file

**Command line restore:** advanced users can restore via Docker commands with PostgreSQL utilities; the source page carries separate command listings for Linux and Windows (PowerShell), abridged here.

## Filesystem backup

Immich does not manage filesystem backups. The critical asset folders to back up are:

- `UPLOAD_LOCATION/library`
- `UPLOAD_LOCATION/upload`
- `UPLOAD_LOCATION/profile`

### Asset storage locations

**Without Storage Template (default):**
- Source assets: `UPLOAD_LOCATION/upload/<userID>`
- Avatars: `UPLOAD_LOCATION/profile/<userID>`
- Thumbnails: `UPLOAD_LOCATION/thumbs/<userID>`
- Encoded videos: `UPLOAD_LOCATION/encoded-video/<userID>`

**With Storage Template enabled:**
- Source assets: `UPLOAD_LOCATION/library/<userID>`
- Profile, thumbs, and encoded-video locations are the same as above

## Backup ordering

To keep database and filesystem consistent: "stop the immich-server container while you take a backup." If that is not feasible, back up the **database first, then the filesystem**, to avoid the database referencing assets missing from the filesystem backup.
