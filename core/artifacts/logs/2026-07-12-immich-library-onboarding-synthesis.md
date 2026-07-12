---
title: D6 — Customer library onboarding at scale (synthesis)
date: 2026-07-12
run: 2026-07-12-immich-library-onboarding
confidence: high — all Immich facts first-party; onboarding-strategy tensions are architect judgment flagged for an ADR
---

# D6 synthesis — customer library onboarding at scale

**Purpose & verdict.** Sixth synthesis in the chain; answers the D6 brief's five onboarding questions from four first-party docs. Immich documents **three** first-party import paths — CLI upload, raw API upload, external libraries — and **no first-party migration/bulk-import guide** (the API-upload guide is the closest; absence verified against the docs nav). Evidence **supports an onboarding ADR** (CLI-upload vs external-library vs hybrid for the pilot) and an **M1 operator-onboarding enabler**; the two onboarding modes diverge sharply on quota, ownership, deletion blast-radius, and ML-backlog behaviour.

- **Themes:** T28–T31 (4 new). **Baseline delta:** §1.4 (import/library data flows), §1.6 cross-refs. **Glossary:** 5 tentative terms added.
- **OQ:** OQ#6 added (no first-party migration guide — customer-arrival formats undocumented); OQ#7 added (no documented bounds on external-library watch/scan at multi-TB scale). **R-09** touched (external-library quota exemption — no new risk, cross-ref only).
- **Downstream:** onboarding ADR recommended; M1 "Customer onboarding pipeline" enabler (E-06) recommended. Decision tensions listed under §Downstream.
- **Seeding finding carried:** NO first-party migration/bulk-import guide exists (§T28, OQ#6).
- **D5 fitness F1 fix** (M1 prose enumerations E-01…E-04 → full E-01…E-05 package) is a transition-file correction — flagged for the fitness-review/main loop to execute where M1 is touched, per §9; not written by this synthesis.

## Sources

- `input/stakeholder/2026-07-12_D6_library-onboarding-brief.md` (five questions)
- `input/systems/immich/immich-cli-upload.md`
- `input/systems/immich/immich-external-libraries.md`
- `input/systems/immich/immich-external-library-guide.md`
- `input/systems/immich/immich-python-file-upload.md`

Excluded: the other 27 `input/` files — not onboarding/import evidence (index-narrowed to the D6 set per the brief). Recurring context (`1.ARCH-CONTEXT.md`, `2.ARCH-BASELINE.md`, `3.ARCH-TARGET.md`, `GLOSSARY.md`, M1 transition, OQ/action registers) read once for this pass.

pending_inputs: None — every cited file is on disk and indexed.

## Themes

### T28 — Three first-party import paths; NO first-party migration guide

**Evidence.**
- **CLI upload** — `@immich/cli` (Node 20+ or Docker) drives the instance via API key; `upload [options] [paths...]` with `--recursive`, `--concurrency` (**default 4**), `--ignore <pattern>`, `--album`/`--album-name`, `--watch`, `--delete`/`--delete-duplicates`, `--dry-run` (`immich-cli-upload.md:43-57`). Dedup is two-layered: the CLI **hashes files client-side to skip already-uploaded files**, and *"Immich always performs its own deduplication through hashing, so [`--skip-hash`] is merely a performance consideration"* — **server-side dedup always applies** (`immich-cli-upload.md:66-68`).
- **Raw API upload** — `POST /api/assets` with `x-api-key`, multipart `fileCreatedAt`/`fileModifiedAt`/`isFavorite`/`assetData`; response `{"id": …, "duplicate": false}` — the same server-side dedup surfaced as a per-asset `duplicate` flag (`immich-python-file-upload.md:13-28`). Framed by the doc as the *"roll your own importer"* route (`immich-python-file-upload.md:9`).
- **External libraries** — the third path; distinct semantics (T29).
- **No first-party migration/bulk-import guide.** No doc covers importing from platform takeouts / other photo apps / prior storage layouts. The API-upload guide is the closest first-party artifact; **absence verified against the docs nav** — a session finding, not an assumption (brief Q1; the four D6 docs are the complete import surface).

**Implications.** The pilot has two mechanically distinct onboarding modes (upload-based: CLI or API, both quota-counted + dedup-safe; external-library-based: mount + scan, quota-exempt). Server-side dedup makes upload re-runs idempotent, so **CLI re-run substitutes for the absent resume flag** — an interrupted terabyte-scale upload continues where it left off (`immich-cli-upload.md:72`). The missing migration guide is an **operator-procedure gap**: customer-arrival formats are undocumented, so the operator must author the ingest-and-map procedure (OQ#6).

**lands_in:** BASELINE §1.4 (CLI + API upload semantics as as-is data-flow facts). **open_questions:** OQ#6.

### T29 — External-library semantics: quota-exempt, single-owner, path-removal deletes

**Evidence.**
- **Single-user ownership, set at creation and unchangeable** (`immich-external-libraries.md:13`); creation is **admin-only** (`immich-external-library-guide.md:9,29-30`).
- **Import paths are recursive**; a file under multiple paths is **imported once**; **removing an import path DELETES the external assets** no longer matching any path (same handling as removed files) (`immich-external-libraries.md:21-24`).
- **Exclusion patterns** are globs matched against the full path (`**/*.tif`, `**/Raw/**`, escaped `**/\@eaDir/**`), implemented via npm `glob` and **translated to PostgreSQL `LIKE`** internally (`immich-external-libraries.md:27-28`).
- **Watch is experimental**, **not supported on network drives**, and hits an inotify ceiling (`ENOSPC` → raise `fs.inotify.max_user_watches`) (`immich-external-libraries.md:32`); a **nightly scan job** runs on a configurable schedule and also cleans up libraries stuck in deletion (`immich-external-libraries.md:33`).
- **Metadata is not written back** to external files (albums/descriptions not persisted); **moving an asset makes Immich treat it as a new file** with Immich-side metadata lost (`immich-external-libraries.md:14-16`).
- **Quota-exempt:** external libraries do **not** consume the per-user storage quota (BASELINE §1.6; already tracked as **R-09**) — cross-ref, not restated.
- **`:ro` mount protection:** mounting read-only is the documented safety measure; **removing `:ro` permits Immich to delete images and write XMP sidecars** to the customer's original files (`immich-external-library-guide.md:20-23`).
- **Scan triggers thumbnail + metadata jobs** — the Jobs tab shows library scanning, thumbnail generation, and metadata extraction on scan (`immich-external-library-guide.md:35`).

**Implications.** External libraries are attractive for terabyte onboarding — **quota-exempt, no data copy, in-place tracking** — but carry sharp hazards for managed hosting: single-user ownership is unchangeable (no reassignment on account changes); **path-removal is destructive** (a mount/config error deletes the customer's tracked assets); the **`:ro` mount is the only barrier** between Immich and the customer's original files; watch is experimental and network-drive-hostile (and the pilot's storage tier may be network-attached — ties OQ#7). The quota exemption means external-library footprint is invisible to the NFR-005 5 TB cap enforcement (R-09).

**lands_in:** BASELINE §1.4 (external-library semantics), §3.4 (`:ro`/unsupported-fs already there — cross-ref). **open_questions:** OQ#7; R-09 (existing).

### T30 — Onboarding import feeds the same scan-triggered job chain → the NFR-003 ML backlog

**Evidence.** Both onboarding modes converge on the same job pipeline: a CLI/API upload kicks off the metadata→thumbnail→ML job chain (BASELINE §1.4, cross-ref — not restated); an external-library **scan** triggers **library scanning + thumbnail generation + metadata extraction** jobs (`immich-external-library-guide.md:35`), and thumbnail completion cascades to Smart Search + Facial Recognition (BASELINE §1.4). So a 1M-asset onboarding — by either mode — **is** the ML backlog NFR-003/AI-001 sizes.

**Implications.** Onboarding mode does not change the ML-backlog physics (the same job chain, the same 72 h / 1M question) — it changes *when and how fast assets arrive at it*: CLI `--concurrency` (default 4) is a customer-side ingest-rate lever; external-library scan enqueues in bulk on scan. The E-02 benchmark (AI-001, OQ#2) is therefore **mode-independent** for the ML tier, but onboarding mode sets the arrival profile the tier must absorb. No new ML fact — this is the connection from onboarding to the existing NFR-003 chain.

**lands_in:** none (cross-ref to BASELINE §1.4 job chain + NFR-003/AI-001/E-02; no new durable fact). **open_questions:** none new (folds into OQ#2/AI-001).

### T31 — Storage-layout divergence between the two modes

**Evidence.** Uploaded assets land under `UPLOAD_LOCATION` and are governed by the **storage template** (BASELINE §1.4, cross-ref — Handlebars layout, Storage Template Migration job). External-library assets are **tracked in place** at their mounted import paths — Immich does not move them into `UPLOAD_LOCATION` and **does not write metadata back** (`immich-external-libraries.md:14`); the storage template does not govern their on-disk layout.

**Implications.** The two modes produce **different storage postures**: upload-based onboarding is storage-template-governed and lives in the per-instance media volume (ADR-005 / E-03 scope); external-library onboarding keeps the customer's original directory structure on a separately mounted (ideally `:ro`) volume, outside storage-template control and outside the quota. This is decision-relevant for ADR-005 (storage template) and E-03 (media volume/backup) — external libraries are a **second storage class** the backup/consistency design must cover.

**lands_in:** BASELINE §1.4 (external-library-in-place vs upload-template divergence). **open_questions:** none new.

## Conflicts detected

None. D6 evidence corroborates and extends prior baseline facts (dedup, job chain, `:ro`, unsupported filesystems, quota exemption) without contradicting any ADR or artifact.

## Glossary updates

Five tentative terms added (per-discipline onboarding vocabulary):

- **external library** — single-user, admin-created collection tracking assets in place outside `UPLOAD_LOCATION`; quota-exempt; recursive import paths; path-removal deletes.
- **import path** — a readable directory an external library scans recursively; a file under several paths is imported once; removing a path deletes its no-longer-matched assets.
- **CLI upload** — bulk asset upload via `@immich/cli` (`immich upload`); client-side hash-skip + always-on server-side dedup; `--concurrency` default 4; re-run substitutes for a resume flag.
- **server-side deduplication** — Immich's always-on hash-based dedup on ingest (CLI, API, upload libraries); surfaced on the API path as the `duplicate` response flag.
- **read-only library mount (`:ro`)** — the documented protection for external-library source files; removing `:ro` lets Immich delete images and write XMP sidecars to the customer's originals.

## Terms flagged

None ambiguous. "External libraries" vs "upload libraries" (both first-party) are distinct concepts, both captured; no spelling conflict.

## Open questions

- **OQ#6 (new)** — No first-party migration/bulk-import guide; customer-arrival formats (platform takeouts, other photo apps, prior layouts) are undocumented → operator ingest-and-map procedure needed. (T28.)
- **OQ#7 (new)** — External-library watch/scan behaviour has no documented bounds at multi-TB scale (nightly-scan duration, watch viability on the pilot's storage tier, inotify ceiling at 5 TB). (T29.)
- **R-09 (existing)** — external-library quota exemption; D6 confirms the mechanism, no new risk — cross-ref only.

## Recommended next agents

- **decision-record-agent** — onboarding ADR (CLI-upload vs external-library vs hybrid for the pilot).
- **risk-assessment-agent** — judge whether T29's path-removal-deletes + `:ro`-only-barrier hazards and OQ#6/OQ#7 warrant register rows (candidate, not written here).
- **fitness-review-agent** — close the D6 run; execute the D5 F1 M1-prose fix where the transition file is touched.

## Downstream note

**Onboarding ADR — supported.** The evidence is decision-ready: three import paths, two mechanically distinct onboarding modes, with a clear trade-off axis for the pilot. Decision-relevant tensions:

| Axis | Upload-based (CLI / API) | External-library-based |
|------|--------------------------|------------------------|
| Quota | **Counted** against NFR-005 5 TB cap | **Exempt** (R-09) — footprint invisible to the cap |
| Ownership | Per uploading user | **Single-user, unchangeable** (no reassignment) |
| Deletion blast-radius | Normal asset delete | **Path-removal DELETES tracked assets**; `:ro` is the only barrier to Immich touching originals |
| Data movement | Copies into `UPLOAD_LOCATION`, storage-template-governed (E-03) | **In place**, outside template, second storage class |
| Resumability | **Idempotent re-run** (server-side dedup; no resume flag needed) | Scan re-run; nightly scan |
| Driver | **Customer-driven** (customer runs CLI / API) | **Operator-driven** (admin mounts + creates library) |
| ML backlog | Same job chain → NFR-003 (T30) | Same job chain → NFR-003 (T30) |

A **hybrid** is plausible (external library for the initial in-place terabyte-scale seed under `:ro`; CLI/API for ongoing customer additions) but multiplies the storage classes E-03 must back up and leaves the quota-exemption gap open. The ADR must resolve: quota enforcement vs exemption under NFR-005; who owns the onboarding action (customer vs operator); and the `:ro`/path-removal safety gate.

**M1 enabler — supported.** Recommend **E-06 "Customer onboarding pipeline"** (operator procedure: the ingest-and-map step the missing migration guide leaves undocumented — OQ#6; a chosen onboarding mode per the ADR; the `:ro`-mount + path-config safety gate; ties to E-02 for ML-backlog arrival-rate and E-03 for the storage class). Not written here — architect-gated (§9). Ties: NFR-003/AI-001 (backlog), NFR-005 (quota/cap), ADR-005 (storage), R-09 (quota exemption).
