---
source_url: https://docs.immich.app/administration/user-management
fetched: 2026-07-12
provenance: first-party Immich documentation, converted to markdown; content abridged only where boilerplate (nav, badges, screenshots) was stripped
---

# User Management

## Admin Registration

The first user to register becomes the admin. Access the web app at `http://<machine-ip-address>:2283` and click "Getting Started" to complete admin registration.

## Creating New Users

Admins navigate to **Administration > Users** and click **Create user** to add accounts for family members or friends.

## Email Notifications

Admin can send a welcome email if the Email option is set (requires SMTP configuration).

## Storage Quota

Admins can limit per-user storage in GiB through the edit-user interface. Once the quota is reached, the user cannot upload. The default is unlimited. External libraries do not take up space from the storage quota.

## Storage Labels

Admins can assign a custom storage label per user, changing the upload path from `upload/{userId}/your-template` to `upload/{custom_user_label}/your-template`. A Storage Migration Job applies labels to previously uploaded assets.

## Password Reset

Via the **Administration > Users** context menu, admins reset a user's password to a random value; the user is required to change it at next sign-in.

## User Deletion

Deleted accounts are disabled immediately, but data removal takes 7 days by default (customizable in Settings). Admins can force immediate permanent deletion via the "Queue user and assets for immediate deletion" option.
