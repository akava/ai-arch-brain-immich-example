# ADR-005 — Media storage and backup strategy for the pilot

## Decision Metadata

- **Title**: Per-instance media volumes on supported filesystems, with operator-side snapshot/replication backup honoring the documented consistency ordering
- **Date**: 2026-07-11
- **Author**: Simulated architect (demo)
- **Severity**: MAJOR
- **Decision type**: data_architecture
- **Status**: proposed (canonical lifecycle: `core/decisions/INDEX.md`)

**Status note:** This ADR is an **unattended-run design proposal** (session D3). **No human has reviewed or approved it.** Per the Human Approval Rule, it is a draft until the architect explicitly approves; nothing here is final delivery.

---

## Decision Impact

- [x] Introduces something new (the pilot's media storage & backup posture)
- [ ] Modifies an existing element
- [ ] Overrides a previous decision

---

## Context

NFR-005 requires provisioning for **up to 5 TB media × 50 instances (≥ 250 TB aggregate)** with **operator-supplied media backup**. The documented constraints (all upstream-documented; synthesis **T18**):

- On-disk layout is governed by the **storage template** (Handlebars pattern; default `Year/Year-Month-Day/Filename.Extension`; changes applied retroactively only via the Storage Template Migration job) — media is **plain files on a filesystem**, addressed by path (`immich-storage-template.md:13-16,43`; BASELINE §1.4).
- **NTFS and exFAT/FAT32 filesystems are not supported** (`immich-faq-scaling-excerpts.md:73`; BASELINE §3.4). CIFS/Samba appears only for **read-only external libraries** — not for the primary `UPLOAD_LOCATION`.
- Immich automates **database backup only**: daily 02:00 dumps, keep-14, **metadata only — no photos or videos** (`immich-backup-and-restore.md:15,17`). **"Immich does not manage filesystem backups"** — the critical folders are `UPLOAD_LOCATION/library|upload|profile` (`immich-backup-and-restore.md:42-46`). No documented backup of Redis queue state.
- **Consistency ordering** (documented): stop `immich-server` during backup, or **back up the database first, then the filesystem**, so the DB never references assets missing from the media backup (`immich-backup-and-restore.md:62`). The documented fresh-install **restore** sequence places the media directories into `UPLOAD_LOCATION` first, then restores the DB dump at the welcome screen (`immich-backup-and-restore.md:30-36`).
- The GPU-transcode **storage-growth multiplier is unquantified** (transcodes are typically larger than software output — BASELINE §3.1/§3.4), so 250 TB is a floor, not a plan.

Per-instance sizing has no first-party guidance (T14: "left as an exercise for the reader") — sizing and backup are **operator-side design**; only the constraints above are upstream-documented.

---

## Options Considered

### Option A: Per-instance dedicated media volumes + operator snapshot/replication — **recommended**

- **Description**: Each instance mounts its own dedicated media volume (block/local), formatted with a supported Linux filesystem (explicitly not NTFS/exFAT/FAT32), sized 5 TB + headroom for the unquantified transcode multiplier. Media backup is operator-side: filesystem snapshots plus replication of the snapshot set off-instance (3-2-1 per the docs' recommendation), covering `UPLOAD_LOCATION/library|upload|profile`. Each backup cycle is orchestrated to honour the documented ordering: DB dump first (stock daily dump retained, plus an operator-triggered dump at cycle start, copied off-instance), then the filesystem snapshot. Restore runbook follows the documented sequence: media directories in place, then DB restore.
- **Pros**: Blast radius and capacity accounting per instance — matches the 50-isolated-instances pilot shape and ADR-003's isolation posture; snapshots make the DB-then-filesystem ordering cheap to honour (point-in-time capture right after the dump); every element sits directly on documented constraints; no new shared infrastructure to become a cross-customer SPOF.
- **Cons**: 50 backup schedules and 50 headroom allocations — capacity is stranded per instance rather than pooled, and the unquantified transcode growth must be padded ×50; if an instance later runs **multiple parallel `immich-server` replicas**, the scaling guide requires **identical file mounts** across them (`immich-scaling-guide.md:9`), so that instance's volume must then be exported as a network mount — a known, per-instance follow-up, not a redesign.

### Option B: Shared network/pooled filesystem, carved per instance

- **Description**: A pooled storage backend (distributed/network filesystem class) exporting one share per instance as its `UPLOAD_LOCATION`; centralized snapshots and replication at the pool.
- **Pros**: Pooled headroom absorbs the unquantified transcode growth across instances instead of ×50 padding; natively satisfies the identical-mounts requirement if instances go multi-replica; one snapshot/replication regime instead of 50.
- **Cons**: The storage backend becomes shared infrastructure under all 50 instances — the same cross-customer blast-radius argument that rejected shared store pools in ADR-003 (T14 SPOF finding, applied at the media layer). Running the **primary** `UPLOAD_LOCATION` over a network filesystem is **not upstream-validated** (docs document network mounts only for read-only external libraries); locking/performance semantics would rest on operator verification alone (R-04).

### Excluded (not a weighed option): object storage for `UPLOAD_LOCATION`

The doc set documents media as **path-addressed files under a storage template** on a POSIX filesystem; no object-storage backend for the primary media store is documented. An option that cannot be built from documented facts is recorded as excluded, not weighed (No-invention rule).

---

## Final Decision

- **Chosen option**: **Option A** — per-instance dedicated media volumes on supported filesystems, with operator-side snapshot + off-instance replication backup honouring the documented DB-first-then-filesystem ordering (recommended posture, pending architect approval). Option B is the named fallback **per instance** if multi-replica scaling makes a network mount necessary — applied per instance, never as a cross-instance pool.
- **Rationale**: The pilot's shape is isolation; Option A keeps storage failure, capacity, and backup accounting inside one customer boundary and builds only on documented constraints. Option B trades that isolation for pooling efficiency the pilot does not yet need, while standing on an unvalidated primary-storage mode. Snapshots are the mechanism that makes the documented consistency ordering (and restore sequence) operationally cheap at 5 TB scale — file-level copy of 5 TB inside a consistency window is not credible.

**Explicit open points** (not resolved by this ADR):
- **Headroom figure**: the transcode storage-growth multiplier is unquantified — the per-instance headroom % is **[TBD]** until pilot telemetry exists (ties the ADR-004 benchmark discipline).
- **Redis queue-state durability** is *not* solved by media backup (no documented Redis backup — T18); it is carried by ADR-003's Redis replica posture and remains flagged there.
- Snapshot technology selection (filesystem/volume-manager/SAN level) is operator-side evaluation; nothing here claims Immich documents it.

---

## Evidence

- **vendor_doc** — `input/systems/immich/immich-backup-and-restore.md:9,15,17,30-36,42-46,62`: 3-2-1 recommendation; DB-only automated backup (metadata only); operator-side media backup and its folder set; DB-first-then-filesystem ordering; documented restore sequence.
- **vendor_doc** — `input/systems/immich/immich-faq-scaling-excerpts.md:73`: NTFS/exFAT/FAT32 unsupported.
- **vendor_doc** — `input/systems/immich/immich-storage-template.md:13-16,43`: path-addressed template layout; Storage Template Migration job.
- **vendor_doc** — `input/systems/immich/immich-scaling-guide.md:9` (T14): identical file mounts required across parallel replicas.
- **nfr_analysis** — ARCH-TARGET §3.4 (run `2026-07-11-immich-scale-up-design`): ≥250 TB aggregate; unquantified transcode multiplier; backup-capability requirement.
- **judgement** — The snapshot-over-file-copy argument and the Option B blast-radius rejection are architect-style judgement over documented facts, flagged as such.

---

## Constraints

- **CON-001**: storage posture must not alter stock containers or paths — `UPLOAD_LOCATION` mount semantics stay stock.
- Supported-filesystem constraint (no NTFS/exFAT/FAT32) binds every volume choice.
- Consistency ordering (DB first, then filesystem — or stopped server) binds every backup cycle.
- Evidence is first-party docs only (**R-04**).

---

## Consequences

- **What this enables**: NFR-005's operator-supplied media backup capability gets a concrete, documented-constraint-grounded shape; restore has a runbook matching the documented sequence; per-instance capacity accounting supports customer-level billing/quota later.
- **What this limits**: No pooled headroom — transcode growth padding is paid 50 times; backup orchestration ×50 requires automation from day one.
- **What to watch for**: Measured transcode growth vs headroom (first pilot telemetry); backup-window collisions with the stock 02:00 DB dump; any instance approaching multi-replica scaling (triggers the per-instance network-mount follow-up); restore drill duration vs ADR-003 Option A assumptions (restore time feeds the availability argument).

---

## Success Metrics

- Quarterly restore drill: full instance restore (media in place, then DB) completes successfully with **zero DB references to missing assets**.
- Media backup coverage: 100% of `UPLOAD_LOCATION/library|upload|profile` captured per cycle, verified by audit, across all 50 instances.
- Capacity: no instance exceeds volume capacity before headroom telemetry review; aggregate provisioning ≥ 250 TB + agreed headroom at pilot go-live.

---

## System Alignment

- **Related ADRs**: related_to ADR-003 (completes the third stateful store's protection; Redis durability stays with ADR-003), ADR-004 (transcode/ML growth interplay), ADR-002 (microservices worker runs the transcode jobs that drive growth).
- **Affects `core/3.ARCH-TARGET.md`**: Yes — §3.4 NFR-005 entry cites this ADR (reconciled at `[Tentative]` per AGENT-RULES §8).
- **Affects `core/1.ARCH-CONTEXT.md`**: No.
- **Affected agents**: component-spec-agent, risk-assessment-agent, fitness-review-agent, handoff-agent.
- **Related artifacts**: `core/artifacts/risk-register.md` (R-01 filesystem leg, R-04); `core/artifacts/logs/2026-07-11-immich-scale-up-design-synthesis.md` (T14, T18).

---

## Lifecycle

| Status | Date | Reason |
|--------|------|--------|
| proposed | 2026-07-11 | Unattended-run design proposal (session D3); awaiting architect review |
