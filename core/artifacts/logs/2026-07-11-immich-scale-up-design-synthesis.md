---
title: Immich Managed-Hosting Scale-Up — D3 Design Synthesis
date: 2026-07-11
type: synthesis
run: 2026-07-11-immich-scale-up-design
skill: synthesis-agent (SKILL-001)
status: active
confidence: high
---

# Immich Managed-Hosting Scale-Up — D3 Design Synthesis

**Purpose:** process the six new first-party scaling/config/backup/k8s/FAQ docs plus the D3 design brief; deepen the as-is baseline with Immich's documented scaling posture, and turn the brief's client asks into labeled requirement raw material. Delta on the D1/D2 syntheses — new facts only.
**Verdict:** Immich now has a documented horizontal-scaling posture, but it is **topology-only, not capacity guidance**: parallel `immich-server` instances must share one Postgres, one Redis, and identical file mounts, yet the scaling guide explicitly gives **no sizing instructions** and there is **still no HA/failover** for those shared stores. FAQ adds coarse ML concurrency heuristics (2–3/CPU, ≤16/GPU) but no per-node throughput. Backup is DB-only-automated (daily 02:00, keep-14, metadata only); media backup is operator-supplied with a DB-then-filesystem ordering rule. Kubernetes support is thin (Helm-chart pointer + one Alpine DNS caveat, no sizing). All figures fit within R-01/R-03/R-05 and OQ#1/OQ#2 — no new open question warranted.
**Counts:** 5 themes (T14–T18, continuing D2's T9–T13); 0 conflicts; 4 glossary terms added (`tentative`); OQ#1 + OQ#2 both partially answered (updated in place); 0 new OQ; 0 action-register rows.
**Also this run (architect-directed):** BASELINE §3 canonical renumber (D2 fitness F1); ownership-map populated (3 demo rows — unblocks §5.2 gate); CONTEXT Business drivers / Goals / Scope narrative filled from the brief (client-stated fiction, [Tentative]) — no registry rows written (nfr-analysis lands those, per the D2 ruling).
**Hand-offs:** librarian indexes this log + updates artifacts INDEX total 10→11. Landings already applied to BASELINE §3/§6, ownership-map, GLOSSARY, OQ#1/OQ#2, CONTEXT per this run's brief. Next in chain: nfr-analysis-agent (land NFR/CON rows from the brief targets), decision-record-agent (D3 design ADRs), integration-contract-agent (server↔ML), and transition M1 (architect-created).

## Sources

- `input/stakeholder/2026-07-11_D3_scale-up-design-brief.md` — client-stated pilot targets + role-level ownership (engagement fiction).
- `input/systems/immich/immich-scaling-guide.md` — horizontal scaling: shared stores, single-machine caveat, no capacity guidance, k8s replicas, API-worker disable.
- `input/systems/immich/immich-environment-variables.md` — worker split vars; DB/Redis required on all workers; ML tuning defaults (WORKERS 1, MODEL_TTL 300, threads, batch sizes, DEVICE_IDS); DB_VECTOR_EXTENSION, DB_SKIP_MIGRATIONS; IMMICH_VERSION v3.
- `input/systems/immich/immich-docker-compose.md` — recommended production install; three steps; .env keys; DB_PASSWORD A-Za-z0-9 constraint; Docker Engine v25 start_interval caveat.
- `input/systems/immich/immich-kubernetes.md` — official immich-charts Helm chart; Alpine DNS search-domain bug; no sizing.
- `input/systems/immich/immich-backup-and-restore.md` — 3-2-1; DB dumps daily 02:00 keep-14 (metadata only); media backup operator-managed; DB-then-filesystem ordering.
- `input/systems/immich/immich-faq-scaling-excerpts.md` — ML concurrency 2–3/CPU, ≤16/GPU; transcoding threads 1–2; buffalo_s vs buffalo_l; external-library semantics; NTFS/FAT unsupported; checksums since v1.104.0.

**Excluded:** the nine D1/D2 inputs — already processed; re-cited by ID/§ where needed. Indexed-retrieval protocol run: `input/` (18) and `core/artifacts/` (10) counts verified OK before selection.
**Pending inputs:** none.
**Confidence:** high — every theme rests on first-party product documentation; residual gaps (store HA, per-node ML throughput) are explicit documented silences, not weak sources. Brief-derived targets are client-stated engagement fiction, carried as such.

## Themes

### T14 — Horizontal scaling is documented as topology, not capacity
- **Evidence:** parallel `immich-server` instances must share the **same Postgres and Redis** and have the **same files mounted**; all state lives in Postgres/Redis/filesystem (`immich-scaling-guide.md:9,23`). Single-machine multi-container scaling gives no benefit (`:13`); scale-out for background work can disable the API worker (`:19`); k8s scaling ≈ incrementing replicas (`:15`). The guide **explicitly gives no specific instructions** — "left as an exercise for the reader" (`:15`).
- **Implications:** the multi-node topology (OQ#1) is now confirmed, but the shared stores become a **single point of failure** for every instance behind them, and there is **no first-party sizing method**. Confirms R-01/R-03 severity; the operator must supply both HA and capacity planning.
- **Lands in:** ARCH-BASELINE §3.4 (scaling requirement + no-guidance stance); partially answers OQ#1.
- **Open questions:** OQ#1 (HA/failover + sizing still open).

### T15 — Reference deployment surface: Compose recommended, Kubernetes thin
- **Evidence:** Docker Compose is the **recommended production method**, three-step install, `.env` keys incl. `DB_PASSWORD` **A-Za-z0-9-only**, `IMMICH_VERSION` `v3` pinnable, Docker Engine <v25 `start_interval` caveat (`immich-docker-compose.md:9,33-36,51`). Kubernetes supported **only via the official `immich-charts` Helm chart**, one Alpine **DNS search-domain bug** caveat, **no sizing guidance** (`immich-kubernetes.md:9,11,15`). All `DB_`/`REDIS_` vars required on **every** worker (`immich-environment-variables.md:63,77`).
- **Implications:** the stock deployment path a managed operator inherits is Compose-first; k8s (the natural multi-instance substrate) is documented thinly — a gap the pilot design must close, not consume.
- **Lands in:** ARCH-BASELINE §6.
- **Open questions:** none new.

### T16 — Client pilot targets + ownership (engagement fiction, requirement raw material)
- **Evidence:** D3 brief — 50 instances, 5 TB/instance, 99.9% availability, ≤15 min upgrade downtime, 1M-asset ML backlog in 72 h, authenticated+encrypted ML channel; role owners: Hosting Platform Lead / Immich Runtime Owner / ML Platform Owner (`2026-07-11_D3_scale-up-design-brief.md`).
- **Implications:** requirement **raw material** — labeled client-stated fiction, not yet feasible-validated. Per the D2 ruling, **no `NFR-`/`CON-` registry rows written here** — the nfr-analysis-agent lands them. Ownership is landable now (role-level) and unblocks the §5.2 gate the ML component-spec flagged.
- **Lands in:** ARCH-CONTEXT (Business drivers / Goals / Scope narrative, [Tentative]); `core/arch-processes/ownership-map.md` (3 rows). NOT the requirements registry.
- **Open questions:** none new (feasibility validation is the nfr-analysis-agent's job, not an OQ).

### T17 — ML capacity levers now have numbers, throughput still unquantified
- **Evidence:** FAQ — **2–3 concurrent jobs max a CPU, ≤16 with a GPU**, transcoding threads **1–2**, lighter **`buffalo_s`** vs default `buffalo_l` (`immich-faq-scaling-excerpts.md:49,67`). Tuning defaults — `MACHINE_LEARNING_WORKERS=1`, `MODEL_TTL=300s`, request-threads=CPU cores, intra/inter-op 2/1, OCR batch 6, `DEVICE_IDS=0` (`immich-environment-variables.md:83,86-89,101,103`).
- **Implications:** first real ML throughput *heuristics* and the full tuning-knob set — but still no assets/sec figure to size the 72 h / 1M-asset onboarding target. Partial answer to OQ#2, not a close; R-03 unresolved.
- **Lands in:** ARCH-BASELINE §3.1 (concurrency heuristics) + §3.4 (tuning-knob defaults); partially answers OQ#2.
- **Open questions:** OQ#2 (per-node throughput/memory still open).

### T18 — Backup is DB-only-automated; media + Redis are operator gaps; storage filesystem constraints
- **Evidence:** 3-2-1 recommended; **DB dumps daily 02:00, keep-14**, in `UPLOAD_LOCATION/backups`, **metadata only** (`immich-backup-and-restore.md:9,15,17`). **Media backup not managed by Immich** — operator supplies it over `library|upload|profile` (`:42,44-46`). Consistency: **stop the server, or dump DB first then filesystem** (`:62`). Checksums default since **v1.104.0**, `pg_amcheck` available (`immich-faq-scaling-excerpts.md:77,94`). **NTFS/FAT unsupported**; CIFS/Samba + read-only `:ro` supported; duplicate checking per-library, not global (`:25,29,33,37,73`).
- **Implications:** the operator inherits the full media-backup and Redis-durability burden and a hard filesystem-support constraint on the 50×5 TB storage tier; DB-then-filesystem ordering is a fixed operational rule the pilot runbook must honour.
- **Lands in:** ARCH-BASELINE §3.3 (backup posture) + §3.4 (filesystem constraints).
- **Open questions:** none new (bears on OQ#1 store resilience).

## ARCHITECT-APPROVED CORRECTION — BASELINE §3 canonical renumber (D2 fitness F1)

Applied the pre-approved renumber to the shared §3 skeleton (`core/0.ARCH-METAMODEL.md` / TARGET §3). Old→new map:

| Old (D2-landed) | Concern | New (canonical) |
|-----------------|---------|-----------------|
| §3.1 | Availability & Resilience | **§3.3** |
| §3.2 | Performance & Throughput | **§3.1** |
| §3.4 | Scalability & Capacity | **§3.4** (unchanged) |

Subsections reordered to canonical sequence (3.1, 3.3, 3.4). **Cite fix-up in LIVING files:** none required — the only §3.x cites outside frozen run logs point at **§3.4** (`component-spec-immich-machine-learning.md` ×3) and **§2**, neither of which moves; the risk register cites only §1.1/§1.2. Grep confirmed **no living-file or register cite to §3.1/§3.2/§3.3**. The frozen **nfr-analysis run log** cites the old §3.1 (Availability) / §3.2 (Performance) at L118-119, L132 — a point-in-time record, **not edited** per AGENT-RULES §Change-history; readers resolve via this map.

## Glossary updates

4 terms added `tentative` (first-party-doc sourced, single session): **shared infrastructure** (scaling), **MODEL_TTL**, **buffalo_l / buffalo_s**, **immich-charts** (Helm chart). No ambiguity flagged — all are cleanly-defined config/deployment terms. See `core/GLOSSARY.md`.

**Terms flagged (ambiguous):** none.

## Register proposals

- **Open-question register:** OQ#1 updated in place (topology answered by scaling guide; HA/failover + sizing still open); OQ#2 updated in place (FAQ concurrency heuristics + tuning defaults added; per-node throughput still open). **0 new OQ** — D3 evidence answers rather than opens; the brief's targets are requirement raw material for the nfr-analysis-agent, not open questions.
- **Action register:** 0 rows. No D3 item passes the triage gate — discovery facts, brief-derived requirement raw material, and an already-approved correction, none an architect-owned brain-improving action not already tracked (the renumber was pre-approved and is executed this run; requirement landing is the nfr-analysis-agent's owned step).

## Recommended next agents

- `nfr-analysis-agent` — land the brief's client-stated targets as `NFR-`/`CON-` registry rows (the D2 ruling's owner), validating feasibility against BASELINE §3.
- `decision-record-agent` — D3 design ADRs (HA topology, ML LB + channel hardening, upgrade procedure).
- `integration-contract-agent` — the server↔ML contract the ML spec flagged as missing.
- `librarian-agent` — index this run log (main-loop step).
