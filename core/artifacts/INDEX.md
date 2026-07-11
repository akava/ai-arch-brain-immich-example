---
type: artifact_index
project: "TODO: project name — set when the engagement starts"
date_built: —
maintainer: librarian-agent (legacy SKILL-009)
---

# Artifacts Index

Compact map of all files in `core/artifacts/`. Agents must follow the indexed retrieval protocol — read this index first, verify count, then open only relevant files.

`core/artifacts/` is split in two: **living artifacts** at the root (component specs, integration contracts, and the risk register — kept current; the action and open-question work registers live in `core/arch-processes/`) and **run logs** under `logs/` (dated, point-in-time records of one session or review — syntheses, NFR analyses, risk assessments, fitness reviews, handoffs). This index covers both.

**Total files in core/artifacts/** (root + `logs/`, excl. `.gitkeep`): **16**

> **Inventory check:** before using this index, run `.claude/scripts/check-indexes.sh`. On MISMATCH, run the `librarian-agent` to update this index.

---

## Schema

| Column | Meaning |
|--------|---------|
| File | Filename — living artifacts at the `core/artifacts/` root; run logs under `logs/` named `[session-date]-[run-slug]-[type]` |
| Skill | Producing skill |
| Type | Artifact type |
| Date | Creation/processing date (distinct from the source-session date in run-log filenames) |
| Status | `active`, `superseded`, `archived` |
| Summary | ≤25 words — a pointer, not an abstract; `Keywords` carry retrieval |
| Keywords | Comma-separated search terms |

---

## Files

Meta and living artifacts sit at the `core/artifacts/` root; run logs carry the `logs/` prefix in the File column.

> TODO: one row per artifact, added by the `librarian-agent` as agents produce outputs. Keep the declared total above in step with the filesystem.

| File | Skill | Type | Date | Status | Summary | Keywords |
|------|-------|------|------|--------|---------|----------|
| README.md | — | meta | — | active | Overview of core/artifacts/ purpose and naming conventions. | artifacts, structure, naming |
| INDEX.md | SKILL-009 | meta | — | active | This file — compact map of all files in core/artifacts/. Agents verify count vs filesystem before use. | index, inventory, navigation, SKILL-009 |
| risk-register.md | SKILL-006 | risk-register | — | active | Living canonical register of all risks and tech-debt items; empty until the first risk-assessment run. | risk register, living artifact, risks, tech debt |
| component-spec-immich-machine-learning.md | SKILL-002 | component-spec | 2026-07-11 | active | AS-IS spec of the immich-machine-learning service: Smart Search/Face Detection responsibilities, Facial Recognition server-bound exception, HTTP port 3003 interface, stateless model cache, co-located/remote modes, five GPU backends, scaling levers, no-auth channel, throughput gaps. | component spec, immich-machine-learning, ML service, Smart Search, Face Detection, Facial Recognition, port 3003, remote ML, ONNX, hardware acceleration, GPU backends, load balancing, stateless, ADR-001, OQ#2, OQ#3, R-03 |
| integration-contract-immich-server-ml.md | SKILL-005 | integration-contract | 2026-07-11 | active | As-built contract for the synchronous HTTP server↔ML channel (port 3003): image previews out / model outputs in, wire schema unpublished [TBD], sequential multi-URL no-LB dispatch, manual retry, version alignment, no built-in auth/TLS; ADR-004 LB+proxy target overlay [Tentative]; §4.4 timeout/retry/idempotency conventions undefined. | integration contract, server-to-ML, immich-machine-learning, port 3003, synchronous HTTP, image previews, embeddings, Face Detection, Smart Search, Facial Recognition exception, wire schema gap, OpenAPI not this channel, sequential no load balancing, manual retry, version alignment, no auth no TLS, MACHINE_LEARNING env vars, WORKER_TIMEOUT 300 900 ROCm, load balancer, reverse proxy, ADR-001, ADR-004, NFR-003, NFR-004, NFR-006, OQ#2, OQ#3, R-03, R-05 |
| logs/2026-07-11-immich-architecture-overview-synthesis.md | SKILL-001 | synthesis | 2026-07-11 | active | D1 discovery synthesis of Immich as-is architecture; 8 themes, container topology conflict resolved, seeds baseline §1/§2. | synthesis, D1, Immich, architecture, components, workers, BullMQ, ONNX, container topology, multi-node gap |
| logs/2026-07-11-immich-architecture-overview-risk-assessment.md | SKILL-006 | risk-assessment | 2026-07-11 | active | D1 risk assessment for managed-hosting goal; 5 rows (R-01…R-05), 1 critical, seeds the living risk register. | risk assessment, D1, Immich, managed hosting, HA, stateful stores, worker co-location, ML memory, docs-only evidence, upgrade path, R-01, OQ#1, OQ#2 |
| logs/2026-07-11-immich-architecture-overview-fitness-review.md | SKILL-007 | fitness-review | 2026-07-11 | active | D1 integrity audit of the full run; verdict proceed_with_caveats; 17 baseline facts verified verbatim, 5 findings (2 minor housekeeping, 3 info). | fitness review, D1, Immich, integrity audit, provenance, consistency, section parity, brain hygiene, proceed with caveats, F1-F5 |
| logs/2026-07-11-immich-ml-media-deep-dive-synthesis.md | SKILL-001 | synthesis | 2026-07-11 | active | D2 deep-dive synthesis of Immich ML and media/storage pipeline; 5 themes (T9-T13), remote-ML/storage-template/migrations facts, seeds baseline §1.2/§1.4/§2/§3.4. | synthesis, D2, Immich, remote machine learning, hardware acceleration, hardware transcoding, storage template, database migrations, OQ#2, OQ#3, ML throughput |
| logs/2026-07-11-immich-ml-media-deep-dive-nfr-analysis.md | SKILL-004 | nfr-analysis | 2026-07-11 | active | D2 NFR analysis under managed-hosting lens; 8 QA scenarios (QA-1..QA-8) across availability/performance/security/operability, all target-TBD-D3; lands BASELINE §3.1/§3.2; proposes 7 candidate NFR/CON rows (not written to CONTEXT, architect-gated). | nfr analysis, D2, Immich, quality attributes, availability, performance, capacity, security, operability, QA scenarios, stateful stores HA, startup migrations, ML memory, GPU floors, sequential remote ML, encoding-only transcoding, unauth ML channel, storage-template migration, target TBD, D3, candidate requirements, NFR-001, CON-001, R-01, R-03, R-05, OQ#1, OQ#2, OQ#3 |
| logs/2026-07-11-immich-ml-media-deep-dive-fitness-review.md | SKILL-007 | fitness-review | 2026-07-11 | active | D2 integrity audit of the full run; verdict proceed_with_caveats; 21 D2 facts verified verbatim; F1 §3 subsection-ID skeleton drift (machinery); D1 F1/F3 follow-ups confirmed executed; candidate NFR rows confirmed not leaked to CONTEXT. | fitness review, D2, Immich, integrity audit, provenance, consistency, section parity, subsection-ID drift, brain hygiene, glossary promotion, proceed with caveats, F1-F4 |
| logs/2026-07-11-immich-scale-up-design-synthesis.md | SKILL-001 | synthesis | 2026-07-11 | active | D3 scale-up design synthesis; 5 themes (T14-T18) on horizontal-scaling posture, deployment surface, ML capacity levers, backup, client pilot targets; executes BASELINE §3 canonical renumber (D2 F1); populates ownership-map + CONTEXT narrative; OQ#1/OQ#2 partially answered. | synthesis, D3, Immich, scale-up, horizontal scaling, shared Postgres Redis filesystem, no capacity guidance, docker compose, kubernetes helm, environment variables, MODEL_TTL, ML concurrency 2-3 16, buffalo models, backup 3-2-1 daily 2AM keep-14, NTFS FAT unsupported, section 3 renumber F1, ownership map, client pilot targets fiction, OQ#1, OQ#2, R-01, R-03, R-05 |
| logs/2026-07-11-immich-scale-up-design-nfr-analysis.md | SKILL-004 | nfr-analysis | 2026-07-11 | active | D3 target-setting NFR analysis; validates the 6 client-stated pilot targets against first-party evidence and lands NFR-001..006 + CON-001 in CONTEXT (client figures bound); creates ARCH-TARGET §3.1/§3.3/§3.4/§3.5 as required-capability directions. 72h/1M ML-drain [TBD] (no per-asset inference time; derived ≤~4.15s/asset bound); availability/upgrade/security mechanism-validated. | nfr analysis, D3, Immich, target setting, 99.9% availability 43.8min budget, 15min upgrade window, 1M assets 72h ML drain, 3.86 assets/sec, per-asset inference absent, 50x5TB 250TB storage, DB-only backup gap, ML channel auth encryption, NFR-001, NFR-002, NFR-003, NFR-004, NFR-005, NFR-006, CON-001, R-01, R-03, R-05, OQ#1, OQ#2, OQ#3, QA-1..QA-8 |
| logs/2026-07-11-immich-scale-up-design-fitness-review.md | SKILL-007 | fitness-review | 2026-07-11 | active | D3 integrity audit of the full scale-up run; verdict proceed_with_caveats; 11 checks (5 minor, 6 info), load-bearing D3 facts re-verified against input docs, §-parity sound in its first live BASELINE↔TARGET §3 test, fiction-hygiene clean. Routes 4 risk-register updates (incl. a new unsecured-ML-channel row for OQ#3) and 1 action-register row (NFR-003 benchmark/rescope) as architect-owned proposals; flags empty action register, stale baseline work-stream, fired risk triggers. | fitness review, D3, Immich, scale-up, integrity audit, section parity BASELINE TARGET 3.5, fiction hygiene, evidence spot-check, DB_PASSWORD A-Za-z0-9, IMMICH_MACHINE_LEARNING_URL absent, backup ordering both directions, risk routing, R-01 R-03 R-05 mitigating, new risk OQ#3 unsecured channel, action register NFR-003 benchmark, work-stream currency, proceed with caveats, F1-F11, ADR-003, ADR-004, ADR-005 |
| logs/2026-07-11-immich-scale-up-design-risk-assessment.md | SKILL-006 | risk-assessment | 2026-07-11 | active | D3 risk-register reconciliation executing the architect-approved fitness-review routing: R-01/R-03 open→mitigating (ADR-003/ADR-004 proposed), R-05 cross-links added (stays open), new R-06 unsecured server↔ML channel (L med/I high, mitigating via ADR-004, before-pilot gate, ML Platform Owner). Fixes OQ#3 stale cross-link → R-06/NFR-006; adds action AI-001 (NFR-003 benchmark/rescope). | risk assessment, D3, Immich, scale-up, register reconciliation, R-01 R-03 mitigating, R-05 CON-001, R-06 unsecured ML channel, port 3003, photo previews, no auth no TLS, ADR-003, ADR-004, NFR-003 NFR-006, OQ#3, AI-001, ML Platform Owner, fitness routing RR-1 RR-4 |
| logs/2026-07-11-immich-scale-up-design-handoff.md | SKILL-008 | handoff | 2026-07-11 | active | DRAFT M1 pilot-enablement handoff (pending architect approval; nothing to factory/): the four operator enablers E-01…E-04 with acceptance gates, dependency-derived build sequencing (Gate 0 approve ADR-003/004/005 → Gate 1 NFR-003 ML benchmark before ML-tier sizing → E-02 channel hardening before real content → E-01/E-03 → E-02 sizing → E-04 upgrade rehearsal, per-instance staged), decided/proposed/open split, owners, evidence, risks R-01…R-06. | handoff, DRAFT, D3, Immich, scale-up, pilot enablement, M1, E-01 E-02 E-03 E-04 enablers, acceptance gates, failover drill, NFR-003 benchmark gate, secured channel before pilot, restore rehearsal, 15-min upgrade rehearsal, sequencing, ADR-001 ADR-002 approved, ADR-003 ADR-004 ADR-005 proposed, NFR-001..006 CON-001, integration-contract server-ML port 3003, component-spec ML, R-01..R-06, AI-001, OQ#1 OQ#2 OQ#3, ownership map, Hosting Platform Lead ML Platform Owner Immich Runtime Owner, not approved, no factory, fiction |
