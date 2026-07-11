---
title: D4 Identity/Access Fitness Review — Immich Managed-Hosting Scale-Up (simulated)
type: fitness-review
agent: fitness-review (legacy SKILL-007)
date: 2026-07-12
status: active
confidence: high
target: D4 run end-to-end (synthesis T19–T23, risk-assessment R-07/R-08/R-09, ADR-006 proposed, BASELINE §1.6, TARGET §3.5/§1.6, GLOSSARY D4 terms, OQ#4, ownership-map interim identity row)
---

# D4 Identity/Access Fitness Review

**Verdict: proceed_with_caveats · confidence high.** The D4 run is internally consistent, evidence-faithful, and correctly layered. All load-bearing identity facts verify verbatim against the four `input/systems/immich/` identity docs. ADR-006 body↔registry status sync holds (both `proposed`); §-parity holds (BASELINE §1.6 populated, TARGET §1.6 row added, §1 headings identical); fiction hygiene clean (no new client figures). One approved fix executed (R-07/R-08/R-09 owner re-route). Two findings, both minor. Librarian hand-off: index this artifact (row added below; total 18→19).

## Checks

| id | dimension | finding | severity | evidence | route_to |
|----|-----------|---------|----------|----------|----------|
| F1 | internal_consistency | **Approved owner-cell re-route executed.** R-07/R-08/R-09 owner cells re-read `Immich Runtime Owner (demo; interim ruling 2026-07-12, ownership-map)`, matching the interim identity ruling. Narrow pre-approved scope; nothing else in the register touched. | info | risk-register.md R-07/08/09; ownership-map.md:14 | none |
| F2 | brain_hygiene | **Work-stream currency stale.** `work-streams/architecture-review.md:19` "Latest processed session" reads `2026-07-11 D3`; D4 landed BASELINE §1.6 (new) and is unlisted in "Landed so far". Should read D4 after this run. Main-loop update (§9), not fixed here. | minor | work-streams/architecture-review.md:12,16-19 | none |
| F3 | brain_hygiene | **OQ#4 carries no inline owning cross-link.** OQ#4 cites its home (BASELINE §1.6) + source (D4 synthesis T23) but not R-08 (candidate (d) session-invalidation folded there) or ADR-006 (leaves OQ#4 open as an explicit open point). Adding an `R-08`/`ADR-006` inline ref aids retrieval (convention is outbound where one exists). | minor | open-question-register.md OQ#4; risk-register R-08; ADR-006 §Final Decision | none |
| F4 | evidence | Load-bearing identity facts spot-checked verbatim: R-07 `oauth:55` ("used during user creation, not synchronized afterward"); R-08 `system-settings-auth:17,19` (lockout incl. admin; recovery + sessions-not-invalidated) + `server-commands:10-11` (container exec); R-09 `user-management:23` ("External libraries do not take up space from the storage quota"); OIDC first-party `oauth:9,19`; first-user-admin `user-management:11`; no-API-key `system-settings-auth:35`. All match; no overstatement. | info | input/systems/immich/{oauth,system-settings-auth,server-commands,user-management} | none |
| F5 | spec_conformance | AGENT-RULES §8 reconciliation correct: TARGET §3.5 identity entry + §1.6 concern row written at `[Tentative]` citing `(ADR-006, proposed)`; no ADR-file or INDEX status flip. Cross-refs (§1.6↔§3.5↔BASELINE §1.6) present, no restatement. | info | TARGET §3.5:92, §1.6:60 | none |
| F6 | adr_consistency | ADR-006 body `Status: proposed` (line 10) == INDEX row `proposed` (MAJOR, 2026-07-12). Options A/B/C reasoned; Option C rejection reuses ADR-003/T14 blast-radius argument coherently; no silent contradiction of approved ADRs. | info | ADR-006:10; decisions/INDEX.md:14 | none |
| F7 | internal_consistency | §-parity: BASELINE and TARGET expose identical §1.1–§1.6 headings; §3 asymmetry (BASELINE §3.1/§3.3/§3.4, TARGET adds §3.5) is the pre-existing populated-subsections-only case validated at D3 — not a D4 regression. Skeleton holds. | info | BASELINE §1/§3 headings; TARGET §1/§3 headings | none |
| F8 | brain_hygiene | **AI-001 checkpoint not yet due** — dated 2026-07-18, status open; today 2026-07-11. No past-due checkpoint/trigger in the action register. Confirmed, no action. | info | action-register.md:70 | none |
| F9 | brain_hygiene | **Glossary promotion state consistent with proposed-ADR precedent.** Six D4 terms (OIDC, OIDC claim mappings, immich-admin CLI, break-glass, two-tier admin/user model, per-user storage quota) all `tentative`, citing ADR-006 (proposed) — correctly held below `confirmed` (that bar was met for D2 terms only via approved ADR-001/002). No premature promotion. | info | GLOSSARY.md:70-75 | none |
| F10 | context_alignment | Run aligns with CONTEXT §Problem/§Goals (per-customer identity posture for the 50-instance managed estate); OQ#4 correctly records the API-key/session gap as knowingly-open, not silently filled. | info | CONTEXT §Problem; open-question-register OQ#4 | none |

## Run yield

- **landed:** BASELINE §1.6 (new); TARGET §3.5 identity entry + §1.6 concern row (both `[Tentative]`); ADR-006 (proposed) + INDEX row; GLOSSARY 6 tentative terms; OQ#4 (new); risk-register R-07/R-08/R-09 (new); ownership-map interim identity row.
- **verdict:** landed.

## Coverage gaps

- OQ#4 (no documented API-key surface / per-session forced-logout) — knowingly open, needs evidence beyond the fetched settings page. Correctly recorded, not a run defect.

## Proposals for the architect (not written)

- F2: main loop update `work-streams/architecture-review.md` to D4 (§9).
- F3: add inline `R-08`/`ADR-006` cross-link to OQ#4 (single-artifact tidy; left for approval as OQ rows are register content).
