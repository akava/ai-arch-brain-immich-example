---
source_url: https://docs.immich.app/guides/python-file-upload
fetched: 2026-07-12
provenance: first-party Immich documentation, converted to markdown; content abridged — full Python script condensed to its request anatomy. Endpoint, headers, form fields, and duplicate-response semantics kept.
---

# Python file upload guide (Immich)

First-party guide for uploading files programmatically via the Immich API — the documented "roll your own importer" route alongside the CLI and external libraries.

## Request anatomy

- **Endpoint:** `POST /api/assets` (example `BASE_URL`: `http://127.0.0.1:2283/api`)
- **Headers:** `Accept: application/json`, `x-api-key: <YOUR_API_KEY>`
- **Multipart form fields:**
  - `fileCreatedAt`, `fileModifiedAt` — timestamps taken from file metadata (the example uses `os.stat()`)
  - `isFavorite` — boolean (default `false`)
  - `assetData` — the file itself

## Response and deduplication

The response returns the asset ID and a duplicate flag:

```json
{"id": "ef96f635-61c7-4639-9e60-61a11c4bbfba", "duplicate": false}
```

`duplicate` indicates whether an identical asset already exists on the server — i.e. server-side deduplication applies to raw API uploads as well.

## Notes

- Example implementation uses Python `requests`.
- Authentication is by API key only; no other setup required.
