---
source_url: https://docs.immich.app/developer/database-migrations
fetched: 2026-07-11
provenance: first-party Immich documentation, converted to markdown; content abridged only where boilerplate (nav, badges) was stripped
---

# Database Migrations

After making any changes in the `server/src/schema`, a database migration must run to register those changes in the database. Follow these steps to create a new migration.

## Creating a Migration

1. Run the command:

   ```
   mise //server:migrations generate <migration-name>
   ```

2. Verify the generated migration file looks correct.

3. Move the migration file to `./server/src/schema/migrations` in your code editor.

The server automatically detects `*.ts` file changes and restarts. During startup, any new migrations are applied immediately.

## Reverting a Migration

To undo the most recently applied migration—useful when developing or testing schema changes—run:

```
mise //server:migrations revert
```

"This command rolls back the latest migration and brings the database schema back to its previous state."
