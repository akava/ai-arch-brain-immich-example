---
type: risk-assessment
session: D4 — identity, access & user management
date: 2026-07-12
run-slug: immich-identity-access
status: active
confidence: high — all rated facts are [Confirmed] first-party doc claims (BASELINE §1.6, verified at source); ratings applied against the managed-hosting goal are the assessor's judgment.
---

# D4 risk assessment — Immich identity, access & user management

## Executive block

- **Purpose:** rate the three warranted identity risks from D4 synthesis (T20/T22/T23) against the managed-hosting goal; adjudicate candidate (d); register rows.
- **Verdict:** 3 rows added — **R-07** (claims-drift, medium), **R-08** (auth lockout + IdP-outage, high), **R-09** (quota bypass via external libraries, medium). Candidate (d) rejected as a standalone row (folded into R-08; the control-existence gap stays at OQ#4).
- **Ownership:** identity/access is **unmapped** in `ownership-map.md` (its three rows cover stores/runtime/ML, not auth). Owners set to **Simulated architect (demo)** pending an ownership-map decision — map NOT edited (per instruction; §5.2 ownership gate flagged for the architect).
- **No ADR / OQ / action rows written.** Identity ADR (synthesis hand-off) and OQ#4 are cited, not authored.

## Sources

- `core/artifacts/logs/2026-07-12-immich-identity-access-synthesis.md` (T19–T23; candidate risks a–d)
- BASELINE §1.6 (identity as-is facts, each carrying `path:line` provenance)
- Source verification: the four load-bearing claims (creation-only claims, both-disabled lockout + CLI recovery, sessions-not-invalidated, external-library quota exemption) re-checked verbatim against `input/systems/immich/immich-oauth-authentication.md:55`, `immich-system-settings-auth.md:17,19`, `immich-server-commands.md:10-11,24`, `immich-user-management.md:23`. All supported.
- Engagement goal / estate scope: CONTEXT §Problem statement, §Goals (50 instances × 5 TB); NFR-001 (availability), NFR-005 (capacity).

## Rating rationale (deltas only — full rows live in the register)

- **R-07 (candidate a, T20) — claims-never-re-synced drift.** IdP-side role/quota/label changes never propagate post-creation (`oauth:55`); local record drifts from the customer IdP source of truth. Managed-hosting least-privilege + quota-accuracy concern. **L medium** (role/quota changes are routine over an instance's life across a 50-tenant fleet), **I medium** (per-user drift, not instance-wide; correctable by manual reconciliation), **severity medium**. Ties the identity ADR's "how the claims-never-re-synced constraint is operationally owned" question.
- **R-08 (candidate b, T23) — instance-wide auth lockout; recovery only via container CLI.** Both methods disabled ⇒ no login incl. admin (`auth:17`); the only documented recovery is `immich-admin enable-password-login`, requiring `immich_server` container exec (`auth:19`, `server-commands:10-11`). Second limb (inference from the same both-disabled rule, not a distinct doc claim): if the pilot standardizes on **OIDC-only per customer** — the direction the identity ADR contemplates — and password login is disabled, a **customer IdP outage** leaves all users of that instance locked out with no fallback. **L medium** (misconfiguration and third-party IdP outage are both plausible at fleet scale), **I high** (full per-instance auth outage → breaches NFR-001; recovery needs privileged container access, not a self-service control), **severity high**. Candidate (d)'s incident-response weakness (sessions survive an auth-policy change — `auth:19`) is recorded here as a **secondary aggravator**: during a compromise, disabling the compromised method does not evict live sessions, so recovery is slower.
- **R-09 (candidate c, T22) — per-user quota bypass via external libraries.** External-library content is exempt from the per-user quota (`user-management:23`); the quota is an upload gate, not a footprint cap. A user with external-library access holds content beyond their nominal quota, so per-user quotas do not bound real per-instance footprint. Capacity-accounting concern against the 50 × 5 TB estate (NFR-005). **L medium**, **I medium** (capacity mis-planning, not an outage; correctable once the operator accounts for external-library footprint separately), **severity medium**.

## Candidate (d) adjudication — held at OQ#4, not a standalone row

Candidate (d): "no forced-logout / session-invalidation control documented (auth changes don't invalidate sessions)."

**Rejected as a standalone risk row.** The *documented behavior* — an auth-setting change does not invalidate existing sessions (`auth:19`) — is a real fact and is captured in BASELINE §1.6:82. But asserting a *risk* that "no per-session invalidation control exists" would overstate a **documented silence**: the fetched system-settings page has no session-management section at all (`auth:35`), so whether such a control exists (just undocumented here) is unknown. That knowledge gap is precisely what **OQ#4** holds. A risk needs a rated likelihood/impact; the impact of a *missing* control whose existence is unconfirmed cannot be honestly rated without inventing the absence. The **operational consequence that is documented and certain** — sessions persist across an auth-policy change, weakening incident response — is real, so it is folded into **R-08** as a secondary aggravator (not lost). If OQ#4 resolves to "no session-invalidation mechanism exists," that converts to a first-class risk row at that point. This matches the synthesis, which flagged (d) as "secondary, for the assessor to weigh."

## Ownership call

`core/arch-processes/ownership-map.md` has three component/stream rows: Hosting Platform Lead (stores HA), Immich Runtime Owner (server/workers/upgrades), ML Platform Owner (ML tier + channel). **None covers identity, access, or the auth control plane.** Identity/access ownership is therefore **unmapped**. Per the run instruction, the three new rows carry **Simulated architect (demo)** as owner, pending an ownership-map decision. The ownership map is **not edited** here (instruction; and §9 layer-write rule — ownership-map changes are architect-owned). This is a §5.2 ownership-gate gap the architect should close before identity design work: recommend adding an identity/access-management stream owner (e.g. an "IAM Owner" demo role) to `ownership-map.md`, at which point R-07/R-08/R-09 re-route from the placeholder.

## Not written (cited, per instruction)

- **Identity ADR** — supported by the synthesis hand-off (per-customer IdP wiring via per-instance OIDC; and how the claims-never-re-synced constraint is owned). R-07 and R-08's OIDC-only limb both bear on it. Route to `decision-record-agent` (architect-gated).
- **OQ#4** — cited by R-08 (secondary) and by candidate (d)'s adjudication; not modified.
- **Action register** — no row written (AGENT-RULES §7). Architect-owned to-do implied: map an identity/access owner (see Ownership call).

confidence: high
