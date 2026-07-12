# ADR-008 — Pilot customer-library onboarding approach

**Status:** proposed (2026-07-12) · unattended-run proposal, no human approval yet — the `proposed` → `approved` flip is the architect's explicit call (status-note convention as ADR-003…007).
**Severity:** MAJOR · **Decision type:** data_architecture · **Version level:** MAJOR
**Date:** 2026-07-12 · **Author:** Simulated architect (demo) · **Created by:** decision-record-agent (D6 run)

> **Simulated demonstration engagement.** The engagement and its pilot figures are fiction exercising this repository's operating model (`core/1.ARCH-CONTEXT.md` → Engagement); this is an unreviewed AI draft. The subject system (Immich) and its documented behaviour are real, drawn from first-party docs under `input/`.

## Summary

For onboarding a customer's existing multi-hundred-GB-to-multi-TB library into a managed Immich instance, adopt **staged operator-driven CLI ingest (C) as the pilot default** — the customer's data lands on an operator staging volume, the operator runs `immich upload` into the instance, then the staging volume is retired — with **direct CLI upload (A)** allowed for small libraries. This keeps A's quota-counted, storage-template-governed, dedup-safe, idempotent properties while decoupling the customer transfer from the instance front door. **External-library-based onboarding (B) is rejected as the pilot default** (quota exemption defeats NFR-005 accounting — R-09; single-user unchangeable ownership; path-removal-deletes hazard) but is recorded as an **explicit opt-in exception path** requiring a `:ro` mount and a signed-off import-path configuration. Chosen over A-as-default (couples customer transfer to the instance front door and shifts operator control) and B-as-default (rejected on the accounting/ownership/deletion grounds above).

## Context

**Problem.** Managed hosting makes **onboarding the first journey every customer takes** (D6 brief), and each customer arrives with a differently-shaped library up to the **5 TB per-instance cap** (NFR-005). Immich documents **three first-party import paths** — CLI upload, raw API upload (`POST /api/assets`), external libraries — and **no first-party migration/bulk-import guide**: customer-arrival formats (platform takeouts, other photo apps, prior storage layouts) are undocumented, absence verified against the docs nav (T28, **OQ#6**). The two onboarding *modes* the paths collapse into diverge sharply on the properties managed hosting cares about — quota accounting, ownership, deletion blast-radius, storage class, resumability, and who drives the action (T29/T31, D6 downstream table):

- **Upload-based** (CLI or raw API) — assets are copied into `UPLOAD_LOCATION`, **counted against the NFR-005 quota**, governed by the **storage template** (single storage class, E-03 scope), and subject to **always-on server-side deduplication by hash** (BASELINE §1.4). The CLI has **no resume flag**, but client-side hashing + server-side dedup make a **re-run idempotent** — an interrupted terabyte upload continues where it left off (`immich-cli-upload.md:66-72`). Transfer runs through the front door: the reverse proxy's **`50000M` body-size / `600s` timeout** settings are the relevant transfer surface (T26; GLOSSARY *front-door reverse proxy*; monitored per ADR-007).
- **External-library-based** — assets are **tracked in place** outside `UPLOAD_LOCATION`, giving **fast arrival for a shipped volume** but with **single-user, creation-fixed, unchangeable ownership**; **quota-exempt** (invisible to the NFR-005 cap — R-09); a **path-removal-deletes hazard** (removing an import path DELETES the no-longer-matched assets); the **`:ro` mount as the only barrier** between Immich and the customer's originals (removing it permits deletion + XMP sidecar writes); **experimental watch**, unsupported on network drives; and a **second storage class** outside storage-template control that E-03's backup/consistency design must then cover (T29/T31, `immich-external-libraries.md:13,21-24,32`, `immich-external-library-guide.md:20-23`).

**Both modes feed the same scan-triggered job chain → the NFR-003 ML backlog** (T30): onboarding mode does not change the ML-backlog physics (same metadata→thumbnail→ML chain, same 72 h / 1M question), but it sets **when and how fast assets arrive** at the tier — the arrival profile the ML tier (E-02) must absorb.

**Urgency.** Material to M1 delivery — onboarding is the first customer journey and the operator must author the ingest-and-map procedure the first-party docs leave undocumented (OQ#6). Opened as the D6 onboarding decision.
**Scope.** The pilot's default onboarding *approach* and its allowed exceptions; the stock containers are untouched (CON-001). The ML-tier sizing (E-02, AI-001), the media-volume/backup design (E-03, ADR-005), and the identity/quota model (ADR-006) are referenced, not re-decided here.

## Options

### A — Direct CLI upload (customer or operator runs `immich upload`)
The library is uploaded straight into the instance via `@immich/cli` with an API key.
- **Pros:** quota-counted (NFR-005 accounting intact); single storage-template-governed storage class (E-03 scope only); always-on server-side dedup; **idempotent re-run substitutes for the absent resume flag** at terabyte scale; nothing new to build beyond the CLI procedure.
- **Cons:** the transfer runs **through the instance front door** — the customer (or an operator session) pushes bytes across the reverse proxy (`50000M`/`600s` are the governing settings), coupling customer transfer to the live serving path; `--concurrency` (default 4) is the only arrival-rate lever and it sits **customer-side** when the customer drives it; no decoupling of a large one-time seed from the running instance.
- **Effort:** low. **Verdict:** **allowed for small libraries** — its properties are correct; it is not the default for large seeds because it couples the bulk transfer to the front door and cedes the arrival-rate lever.

### B — External-library-based onboarding (mount customer data in place)
An admin mounts the shipped customer volume and creates an external library tracking it in place.
- **Pros:** **fast arrival** for a shipped volume — no copy, no re-encode of the transfer; in-place tracking; the customer's original directory structure is preserved.
- **Cons:** **quota-exempt — defeats NFR-005 accounting (R-09)**, so per-user quotas no longer bound per-instance footprint; **single-user, unchangeable ownership** (no reassignment on account changes); **path-removal-deletes hazard** (a mount/config error deletes the customer's tracked assets); the **`:ro` mount is the only safety barrier** (remove it and Immich may delete originals + write XMP sidecars); **watch is experimental / unsupported on network drives** (and the pilot media tier may be network-attached — OQ#7); introduces a **second storage class** (E-03 must back up in-place-outside-template media, T31).
- **Effort:** low to arrive, high in governance. **Verdict:** **rejected as pilot default**; recorded as an **explicit opt-in exception path** — permitted only with a `:ro` mount and a **signed-off import-path configuration**, when a customer's constraints make in-place tracking necessary.

### C — Staged operator-driven CLI ingest (chosen default)
Customer data lands on an **operator staging volume**; the operator runs `immich upload` from staging into the instance; the staging volume is then retired.
- **Pros:** keeps **all of A's properties** — quota-counted, single storage-template-governed storage class, always-on server-side dedup, idempotent re-run — while **decoupling the customer transfer from the instance front door** (the customer ships/copies to staging out-of-band; only the operator-run CLI touches the instance); the **arrival-rate lever (`--concurrency`) moves operator-side** — the one control the operator holds over the NFR-003 arrival profile (T30); a clean retire-staging step bounds the transient capacity.
- **Cons:** adds **staging capacity** (transient per-onboarding volume, sized against the incoming library up to 5 TB) and an **operator staging/ingest/retire procedure**; the staged bytes are held twice (staging + instance) for the duration of ingest.
- **Effort:** medium. **Verdict:** **chosen as the pilot default** — the only option that preserves A's correct storage/quota/dedup properties *and* gives the operator the arrival-rate control and front-door decoupling large seeds need.

## Decision

**Adopt Option C — staged operator-driven CLI ingest — as the pilot default onboarding approach, with Option A (direct CLI upload) allowed for small libraries.** Both use the CLI-upload mechanism, so both inherit quota accounting, the single storage-template-governed storage class, always-on server-side dedup, and idempotent re-run. **Option B (external-library-based) is rejected as the default** and permitted only as an **explicit opt-in exception** requiring a `:ro` mount and a signed-off import-path configuration.

**Rationale.** The pilot's binding concerns are NFR-005 accounting, ownership clarity, deletion safety, and a single backable storage class. A and C satisfy all four; B fails accounting (R-09 quota exemption), ownership (unchangeable single-user), and deletion safety (path-removal-deletes with `:ro` as the only barrier), and forces a second storage class on E-03 (T31). C is preferred over A as the default because a multi-hundred-GB-to-TB seed should not run through the instance front door, and the operator — not the customer — should hold the `--concurrency` arrival-rate lever that shapes the NFR-003 ML backlog (T30, the one lever the operator holds). B is not banned outright: where a customer's constraints make in-place tracking necessary, it is an audited exception with the `:ro` barrier and a signed-off path config as mandatory gates. Onboarding mode does not change the ML-backlog physics — the E-02 benchmark (AI-001, OQ#2) is mode-independent (T30).

## Evidence

| Type | Source | What it establishes |
|------|--------|---------------------|
| vendor_doc | `input/systems/immich/immich-cli-upload.md:43-57` | `@immich/cli upload` flags: `--recursive`, `--ignore`, `--album`, `--delete`, `--dry-run`, `--concurrency` (default 4) — the arrival-rate lever. |
| vendor_doc | `input/systems/immich/immich-cli-upload.md:66-68,72` | Client-side hash-skip + **always-on server-side dedup** ("Immich always performs its own deduplication"); no resume flag → **idempotent re-run** continues where it left off. |
| vendor_doc | `input/systems/immich/immich-python-file-upload.md:9,13-28` | Raw API upload `POST /api/assets` with `x-api-key`; `duplicate` flag = same server-side dedup; the "roll your own importer" route. |
| vendor_doc | `input/systems/immich/immich-external-libraries.md:13,21-24,32-33` | External library: single-user unchangeable ownership; recursive import paths; **removing a path DELETES assets**; experimental watch, network-drive-hostile; nightly scan. |
| vendor_doc | `input/systems/immich/immich-external-library-guide.md:9,20-23,29,35` | Admin-only creation; **`:ro` mount is the barrier** (removing it permits delete + XMP writes); scan triggers thumbnail + metadata jobs. |
| vendor_doc | `input/systems/immich/immich-storage-template.md:13-16,43` | Uploaded assets governed by the storage template under `UPLOAD_LOCATION`; external-library assets are outside it (second storage class). |
| vendor_doc | `input/systems/immich/immich-reverse-proxy.md:20,23` | Front-door proxy `client_max_body_size 50000M`, `proxy_read_timeout 600s` — the CLI-upload transfer surface (T26; monitored per ADR-007). |
| discovery | D6 synthesis `core/artifacts/logs/2026-07-12-immich-library-onboarding-synthesis.md` (T28–T31, OQ#6/OQ#7) | Three import paths, no migration guide; two mechanically distinct modes; both feed the NFR-003 ML backlog; storage-layout divergence. |
| nfr_analysis | `core/1.ARCH-CONTEXT.md:99,101` (NFR-003, NFR-005) | ML backlog drain (72 h / 1M — [TBD] figure, AI-001); quota/media-capacity accounting the mode choice must preserve. |
| technical_constraint | R-09 (`core/artifacts/risk-register.md`); ADR-005 (proposed); CON-001 (`core/1.ARCH-CONTEXT.md:103`) | External-library quota-exemption accounting exposure; E-03 media/backup scope; stock-untouched reversibility bound. |

## Constraints

| Constraint | Source |
|------------|--------|
| External-library content is **quota-exempt** — quota gates uploads, not footprint; per-user quotas cannot bound a B-onboarded instance's storage (the reason B is exception-only). | R-09; `immich-user-management.md:23` |
| **Removing an import path DELETES** its no-longer-matched external assets; the **`:ro` mount is the only barrier** to Immich touching originals — both mandatory gates on the B exception. | `immich-external-libraries.md:21-24`; `immich-external-library-guide.md:20-23` |
| Server-side dedup is **always on**; the CLI has **no resume flag** — re-run is the resume mechanism (idempotent). | `immich-cli-upload.md:66-68,72` |
| CLI upload transfers through the **front-door proxy** (`50000M` / `600s`); a large seed via A loads the live serving path — the reason C stages off the front door. | `immich-reverse-proxy.md:20,23` |
| Stock containers untouched; the onboarding capability is operator procedure wrapping stock (no stock modification). | CON-001 |
| Arrival-format mapping (source discovery, format normalization, chosen mode, dedup/verification) is **operator procedure** — the first-party docs leave it undocumented; **formats are not invented here** (OQ#6). | OQ#6; T28 |

## Consequences

**Enables.** A pilot onboarding default that keeps NFR-005 quota accounting intact, holds a single storage-template-governed storage class (E-03 backs up one class, not two), decouples the bulk customer transfer from the instance front door, and puts the `--concurrency` arrival-rate lever operator-side. Frames the missing-migration-guide gap (OQ#6) as an operator ingest-and-map procedure (source discovery → format normalization → CLI ingest → dedup/verification) rather than a stock feature. B stays available as an audited exception for customers who need in-place tracking.

**Trade-offs.** C adds **transient staging capacity** (sized against the incoming library up to 5 TB per onboarding) and an operator staging/ingest/retire procedure — bytes held twice for the ingest duration; this is **staging capacity the E-03 / ADR-005 media-volume plan must account for** (transient, per-onboarding, distinct from the instance's steady-state 5 TB). The **arrival-format mapping is operator procedure, not a stock capability** — the operator authors it per arrival profile; **formats are not enumerated here** (no first-party source — OQ#6, cite-don't-invent). The B exception, when taken, reintroduces the second storage class E-03 must cover (T31) and the quota-exemption accounting gap (R-09) for that instance.

**Risks / dispositions.**
- **NFR-003 backlog tie (T30).** Onboarding is the arrival profile the ML tier must absorb; the operator's **one lever is `--concurrency`** (arrival rate), mode-independent of the E-02 benchmark. The acceptance figure — ML backlog drained per NFR-003 — **stays [TBD] pending AI-001** (the per-asset benchmark; the 72 h / 1M figure is not committed).
- **R-09 disposition.** Making **B exception-only shrinks R-09's exposure** — the default (C, and A for small libraries) is quota-counted, so the quota-exemption accounting gap applies only to instances that take the B exception, not to the pilot baseline. *(Stated here; the register row is not edited by this ADR.)*
- **OQ#6 remnant.** The arrival-format ingest-and-map procedure is undelivered operator build work (E-06 scope) with no first-party guidance.
- **OQ#7 remnant.** External-library watch/scan bounds at multi-TB scale are unquantified — bears on any B-exception instance and ties E-03's storage design.
- Ties **R-04** (first-party-evidence-only — the no-migration-guide finding is verified doc silence, not an assumption).

## Success metrics

| Metric | Measurement |
|--------|-------------|
| Onboarding rehearsal | A rehearsed onboarding of a **representative multi-hundred-GB library completes without manual intervention** via the C staged-ingest path (staging → operator CLI upload → retire staging). |
| ML backlog drain | The onboarding's ML backlog **drains per the NFR-003 disposition** — target figure **[TBD] pending AI-001** (per-asset benchmark; 72 h / 1M not committed). |
| Quota accounting integrity | Post-onboarding, the instance's counted footprint reconciles against the per-user quota for A/C-onboarded content; any B-exception content is accounted **separately** from quota (R-09). |
| B-exception gate coverage | Every external-library (B) onboarding carries a `:ro` mount and a signed-off import-path configuration before scan. |

## Relationships

- **related_to:** ADR-005 (proposed) — the storage template + per-instance media volume the upload-based default lands in, and the staging-capacity implication for E-03; ADR-004 (proposed) — the ML tier that absorbs the onboarding arrival profile (E-02 benchmark, AI-001); ADR-006 (proposed) — the per-user quota (`immich_quota` claim) whose accounting B's exemption undermines (R-09), and the ownership model B's single-user constraint interacts with.
- **supersedes / conflicts_with:** none.
- **artifact_refs:** D6 synthesis `core/artifacts/logs/2026-07-12-immich-library-onboarding-synthesis.md` (T28–T31, OQ#6/OQ#7, downstream E-06 recommendation); BASELINE §1.4 (import/library data flows); TARGET §1.4/§1.5; `core/transitions/M1-managed-hosting-pilot.md` (E-06/WS6); `core/transitions/ENABLER-CATALOG.md` (E-06); `core/artifacts/risk-register.md` (R-09); `core/arch-processes/action-register.md` (AI-001).
- **agent_refs:** decision-record-agent (this record); synthesis-agent (D6, evidence).

## Lifecycle

| Status | Date | Reason |
|--------|------|--------|
| proposed | 2026-07-12 | Recorded in unattended D6 run; awaiting architect approval. Reconciliation into TARGET §1.4/§1.5 is `[Tentative]` per AGENT-RULES §8; the flip to `approved` and any baseline promotion are the architect's explicit call (§9). |
