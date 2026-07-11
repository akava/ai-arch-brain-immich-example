---
source_url: https://docs.immich.app/administration/system-settings
fetched: 2026-07-12
provenance: first-party Immich documentation, converted to markdown; abridged — only authentication-, user-, and trash-related settings extracted from the full system-settings page; other setting groups (jobs, ffmpeg, ML, etc.) omitted
---

# System Settings — Authentication and User Settings (excerpts)

## Authentication Settings

### OAuth Authentication

Immich supports OAuth authentication. See the dedicated OAuth configuration documentation for setup details.

### Password Authentication

Administrators can disable username-and-password login across the entire instance. This restriction applies to all users, including the system administrator. If both OAuth and password authentication are disabled, users cannot log in through any method.

Changing this setting does not affect existing sessions, just new login attempts. The Server CLI (`immich-admin enable-password-login`) can re-enable password login if needed.

## User Settings

### Delete Delay

System administrators can configure user deletion timing through the administration panel. Users can be removed immediately or with a delayed deletion (default 7 days). This action permanently deletes a user's account and assets.

The user deletion job runs at midnight to process accounts ready for removal. Setting changes take effect at the next scheduled execution.

## Trash Settings

Administrators can configure a trash system for deleted files. Files remain in trash for a configurable period (30 days by default) before permanent deletion.

The trash can be disabled, however this is not recommended, as files deleted afterwards will be permanently deleted. Users can select assets and press Ctrl + Del from the timeline for immediate permanent deletion without using trash.

> Note (fetch observation): the system-settings page as fetched contains no dedicated API-key, new-user, or session-management sections; session invalidation is only addressed indirectly ("existing sessions" note above).
