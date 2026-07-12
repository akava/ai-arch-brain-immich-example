---
title: D5 operability & observability fitness review (Immich)
date: 2026-07-12
run: 2026-07-12-immich-operability-observability
type: fitness-review
inputs_reviewed:
  - core/artifacts/logs/2026-07-12-immich-operability-observability-synthesis.md (T24–T27, OQ#5)
  - core/decisions/ADR-007-fleet-observability-health.md (proposed) + core/decisions/INDEX.md
  - core/3.ARCH-TARGET.md §3.2 · core/2.ARCH-BASELINE.md §1.6/§3.2/§6
  - core/transitions/M1-managed-hosting-pilot.md (WS5, E-05) · core/transitions/ENABLER-CATALOG.md (E-05)
  - core/GLOSSARY.md (5 D5 terms) · core/arch-processes/open-question-register.md (OQ#5, OQ#4) · action-register.md (AI-001) · work-streams/architecture-review.md
  - input/systems/immich/{immich-monitoring,immich-reverse-proxy,immich-system-integrity}.md (source spot-check)
confidence: high
---

# D5 fitness review — operability & observability

## Executive summary

Independent integrity audit of the complete D5 run: synthesis (T24–T27), ADR-007 (proposed) + reconciliation (TARGET §3.2), §9 transition edits (E-05 catalog row, WS5 + E-05 delta + Open/watch in M1), and the landings (BASELINE §1.6/§3.2/§6; 5 GLOSSARY terms; OQ#5 new + OQ#4 D4-F3 cross-links; work-stream currency). **Verdict: proceed_with_caveats.** Run yield: **landed** (durable ADR, reconciled §3.2, new enabler E-05, BASELINE deltas, 5 glossary terms, OQ#5). All 12 load-bearing D5 facts (ports/groups, proxy directives, marker/folder checks, logging-absence 404, tracing-absence) **verified verbatim at source**. ADR-007 body↔registry in sync. §3.2 placement adjudication **recorded and upheld** (below). **One content finding (F1, minor):** M1 transition prose still enumerates the enabler package as "E-01…E-04" after E-05 was added to the same file — flagged for architect, not fixed. Two-proxies distinction clean everywhere; fiction hygiene clean (no new client figures). AI-001 checkpoint 2026-07-18 still future — confirmed.

## §3.2 placement adjudication (explicit architect ask)

**Ruling validated and recorded: §3.2 = Observability & Operability stands as this engagement's convention.**

- **(a) Both files' §3 subsection sets are consistent.** TARGET §3: 3.1 Performance & Throughput · **3.2 Observability & Operability** · 3.3 Availability & Resilience · 3.4 Scalability & Capacity · 3.5 Security & Compliance. BASELINE §3: 3.1 Performance & Throughput · **3.2 Observability & Operability** · 3.3 Availability & Resilience · 3.4 Scalability & Capacity. Every populated §N carries the same concern in both files — §-parity holds (metamodel §Shared skeleton, Integrity rule). Nothing was displaced: no "Latency & Freshness" (or any other) section exists at §3.2 or anywhere in either file, so homing Observability at §3.2 filled a vacant slot rather than overwriting a concern.
- **Governing rule.** The D2-F1 finding treated the then-TARGET-§3-TODO enumeration (3.1 Performance / 3.3 Availability) as canonical; D3 renumbered BASELINE to it and its population **consumed that TODO** (TARGET §3 now holds live entries, not the enumerating TODO). With the TODO guidance consumed, the standing rule is the metamodel's §-parity (same §N = same concern, both files agree) — which §3.2 = Observability now satisfies in its first two-file test.
- **(b) No stale §3.2 meaning in any LIVING file.** Grep of `§3.2`/`### 3.2` across `core/` excluding `logs/`: every live occurrence (TARGET:79/81, BASELINE:99/130, decisions/INDEX ADR-007, work-streams/architecture-review, M1 WS5 + E-05, ADR-007 body) reads §3.2 = Observability & Operability. The only surviving §3.2 = Performance meaning sits in **frozen run logs** (D2 nfr-analysis L118-132, D2 fitness-review F1, D3 synthesis old→new map) and in the **INDEX summary describing** the frozen D2 nfr-analysis log ("lands BASELINE §3.1/§3.2") — acceptable history recording what that point-in-time log did; not a live assertion. No living-file correction needed.
- **Result:** convention documented here; the D2-F1 skeleton-drift finding is now fully closed by the D3 renumber + D5 population, not re-flagged.

## Checks

- **F1 — internal_consistency / content — minor.** M1 transition prose still names the enabler package as "`E-01`…`E-04`" at Goal (`M1-managed-hosting-pilot.md:17`), Coexistence (`:83`), and Low-level design (`:107`), but the same D5 run added **E-05 / WS5** to that file's scope table (`:31`) and deltas (`:65-70`). The package is now E-01…E-05; the three prose enumerations are stale. Blast radius: internal to the transition file (catalog, WS table, delta, and Open/watch all correctly carry E-05). *Route: architect — content fix in the transition (extend the three enumerations to E-05, or reword to "the enabler package below"); not fixed in-run.*
- **F2 — spec_conformance / evidence — info.** All 12 load-bearing D5 facts spot-checked verbatim at source (`immich-monitoring.md` A–D: opt-in/local :9, groups api/host/io :13-18, ports 8081/8082/9090/3000 :25-27/:32, JSON fields + no-logging-page :36-38; `immich-reverse-proxy.md` E–G: headers/root-path/well-known :13-16, nginx 50000M/buffering-off/1024k/600s :20-24, Traefik 600s :36; `immich-system-integrity.md` H–K: six folders + .immich marker :13-19, ENOENT example :29, escape hatch :37, closest-to-healthcheck / no page :9). Tracing-absence confirmed — `immich-monitoring.md` documents metrics export only, no span/per-request text (scopes ADR-007 option C correctly). Route: none.
- **F3 — adr_consistency — info.** ADR-007 body ↔ `decisions/INDEX.md:14` in sync (title, chosen option B, A/C rejections, 8081/8082, fleet-wide `IMMICH_TELEMETRY_INCLUDE`, ADR-003 segregation alignment, OQ#5 partial-resolution, [TBD] detection window, T26 thresholds all match). Status `proposed` mirrored in body Status line + Lifecycle row; reconciliation-into-TARGET-§3.2-as-[Tentative] correctly cited per AGENT-RULES §8. Relationships correctly flag ADR-004's ML-tier proxy as **distinct** from the front-door proxy (not conflated). Route: none.
- **F4 — spec_conformance (§8 reconciliation) — info.** TARGET §3.2 entry carries `[Tentative]` + `(ADR-007, proposed)`, with container-health/probe design and detection window left `[TBD]` (not invented to complete the section) — conforms to AGENT-RULES §8. Route: none.
- **F5 — internal_consistency (transition §9 edits) — info.** E-05 catalog row (ENABLER-CATALOG.md:23), WS5 scope row (M1:31), E-05 delta `§3.2 → §3.2` (M1:65), and OQ#5 Open/watch (M1:101) are mutually consistent and conform to transitions/README (deltas key baseline §N→target §N; enabler-shaped with type/delta/benefit/acceptance; catalog = what/how-to-use, transition = how-to-build; no restatement). E-05 realizes NFR-001. Route: none (F1 is the lone gap).
- **F6 — internal_consistency (two-proxies) — info.** Front-door proxy (API serving path, BASELINE §6/§3.2, T26) and ML-tier auth+TLS proxy (port 3003, ADR-004, TARGET §3.5, E-02) kept distinct in every living file that names both; ADR-007, BASELINE:194, and the glossary "front-door reverse proxy" entry each explicitly state the two must not be conflated. Route: none.
- **F7 — brain_hygiene — info.** (a) AI-001 checkpoint **2026-07-18 still future** (today 2026-07-12) — confirmed, not past-due; no other register checkpoints/triggers. (b) OQ#5 well-formed (source-cited, NFR-001/E-05 cross-linked, doc-silence resolution noted); OQ#4 D4-F3 cross-links (R-08, ADR-006) present. (c) 5 D5 glossary terms all `tentative` with source + ADR-007 provenance; the E-05 canonical **"Fleet observability & health"** matches the catalog/WS5 name and the four primitive terms (Immich telemetry, structured JSON logging, front-door reverse proxy, startup folder integrity check) each note distinction from what E-05 wraps — batched for architect promotion consideration (all newly coined this session; promotion is the architect's call). (d) architecture-review work-stream advanced to D5 (F2 follow-up executed). (e) CONTEXT accumulates no solution facts. (f) M1 status `active` / confidence `low` unchanged — no unapproved flip or baseline promotion.

## Run yield

- **landed:** ADR-007 (proposed, new); TARGET §3.2 reconciled entry; BASELINE §1.6 (health mechanism) + §3.2 (new Observability subsection) + §6 (front-door proxy) deltas; enabler E-05 (catalog + M1 WS5/delta); OQ#5 (new); 5 GLOSSARY tentative terms; OQ#4 cross-links + work-stream currency (D4 F2/F3 follow-ups).
- **verdict:** landed.

## Coverage gaps

- TARGET §5 remains a TODO stub (pre-existing, tracked in M1 Open/watch as watch-not-deliverable) — the observability plane's operating/gating constraints have no §5 home yet; not a D5 regression.
- Detection-window figure and container-health probe design are `[TBD]` by design (OQ#5 remnant, pilot-gate build work) — correctly surfaced, not filled.

## Verdict

**proceed_with_caveats** · confidence **high**. The D5 run is evidence-faithful, layer-consistent, and §-parity-clean; ADR-007 and the transition edits conform. The single caveat is F1 (stale E-01…E-04 enumeration in M1 prose) — a minor content fix for the architect. §3.2 adjudication upheld and documented.

## Librarian hand-off

This run log is new under `logs/`. Main loop: run `librarian-agent` to add the row and bump the artifacts total, then re-run `.claude/scripts/check-indexes.sh`. (INDEX row + total added inline this session; check run and passing.)
