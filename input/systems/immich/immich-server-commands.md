---
source_url: https://docs.immich.app/administration/server-commands
fetched: 2026-07-12
provenance: first-party Immich documentation, converted to markdown; content abridged only where boilerplate (nav, badges) was stripped
---

# Server Commands

The `immich-server` Docker image includes an administrative CLI tool called `immich-admin` for server management tasks.

To run a command, connect to the `immich_server` container and then execute the command via `immich-admin <command>`.

## Available Commands

| Command | Description |
|---------|-------------|
| `help` | Display help |
| `reset-admin-password` | Reset the password for the admin user |
| `disable-password-login` | Disable password login |
| `enable-password-login` | Enable password login |
| `disable-maintenance-mode` | Disable maintenance mode |
| `enable-maintenance-mode` | Enable maintenance mode |
| `enable-oauth-login` | Enable OAuth login |
| `disable-oauth-login` | Disable OAuth login |
| `list-users` | List Immich users |
| `grant-admin` | Grant admin privileges to a user (by email) |
| `revoke-admin` | Revoke admin privileges from a user (by email) |
| `version` | Print Immich version |
| `change-media-location` | Change database file paths to align with a new media location |
| `schema-check` | Verify database migrations and check for schema drift |

## Example Usage

```
immich-admin reset-admin-password
immich-admin disable-password-login
immich-admin enable-password-login
immich-admin disable-maintenance-mode
immich-admin enable-maintenance-mode
immich-admin enable-oauth-login
immich-admin disable-oauth-login
immich-admin list-users
immich-admin grant-admin
immich-admin revoke-admin
immich-admin version
immich-admin schema-check
immich-admin change-media-location
```
