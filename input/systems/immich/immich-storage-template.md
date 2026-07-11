---
source_url: https://docs.immich.app/administration/storage-template
fetched: 2026-07-11
provenance: first-party Immich documentation, converted to markdown; content abridged only where boilerplate (nav, badges) was stripped
---

# Storage Template

Immich enables administrators to configure how uploaded files are organized through customizable directory and filename patterns, plus per-user storage labels.

## Overview

The storage template feature allows you to define where and how assets are stored. The default organization pattern is:

```
Year/Year-Month-Day/Filename.Extension
```

## Key Features

**Template Variables**: Immich provides a set of variables for constructing custom storage paths alongside custom text. The complete variable reference is exposed in the template builder UI rather than enumerated on this page; variables appearing in the page's examples include `{{y}}`, `{{MM}}`, `{{album}}`, and `{{filename}}`. The system appends sequence numbers to prevent filename collisions.

**Timezone Handling**: "Date and time variables in storage templates are rendered in the server's local timezone."

**Multiple Albums**: When an asset belongs to several albums, the most recently created album name is used for the `{{album}}` variable.

**Character Escaping**: By default, special characters convert to HTML entities (e.g., `&` becomes `&amp;`). Use triple braces `{{{variable}}}` to prevent this conversion.

## Configuration

Access the template builder via `Administration -> Settings -> Storage Template`. Enable the feature during initial setup before customizing your pattern.

## Conditional Logic

Create conditional statements using Handlebars syntax to handle assets without albums:

```
{{y}}/{{#if album}}{{album}}{{else}}Other{{/if}}/{{MM}}/{{filename}}
```

## Migration

After changing templates, run the `Storage Template Migration` job to apply changes to your existing library.
