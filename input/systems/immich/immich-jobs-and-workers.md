---
source_url: https://docs.immich.app/administration/jobs-workers/
fetched: 2026-07-11
provenance: first-party Immich documentation, converted to markdown; content abridged only where boilerplate (nav, badges) was stripped
---

# Jobs and Workers

*(Directly linked from the architecture overview page as "Administration > Jobs".)*

## Workers

### Architecture

The `immich-server` container contains multiple workers:

- **api**: responds to API requests for data and files for the web and mobile app
- **microservices**: handles most other work, such as thumbnail generation and video encoding, in the form of *jobs*

### Split Workers

Workers can be distributed across separate containers using environment variables. To create separate API and microservices containers:

1. Copy the `immich-server` service block in the compose file
2. Rename the copy to `immich-microservices`
3. Remove the ports mapping from the microservices container
4. Add environment variables:
   - Original (API) container: `IMMICH_WORKERS_INCLUDE: 'api'`
   - New (microservices) container: `IMMICH_WORKERS_EXCLUDE: 'api'`

This allows one container to serve the web UI and API while another handles background tasks.

## Jobs

When a new asset is uploaded it kicks off a series of jobs, which include metadata extraction, thumbnail generation, machine learning tasks, and storage template migration, if enabled.

Job status is visible via the **Administration → Jobs** page.

### Scheduled Jobs

Some jobs run on a schedule (default: nightly at midnight). These are configured via **System Settings → Nightly Tasks Settings**. External Libraries scanning and Database Dump jobs are configured in their respective System Settings sections instead.

### Job Processing Order

*(Diagram described in text.)* The page includes a diagram showing the job run sequence for newly uploaded files; per the architecture overview, thumbnail generation runs first, and Smart Search and Facial Recognition automatically execute after thumbnail generation completes.
