---
type: synthesis
session: D4 — identity, access & user management
date: 2026-07-12
run-slug: immich-identity-access
status: active
confidence: high — all themes derive from first-party Immich documentation committed to `input/systems/immich/`; per-fact [Confirmed] provenance below.
---

# D4 synthesis — Immich identity, access & user management

## Executive block

- **Purpose:** answer the five D4 identity questions from first-party docs; land identity/access as-is facts in BASELINE §1.6, seed GLOSSARY identity terms, register the API-key/session gap.
- **Verdict:** Immich has a documented, self-contained identity model — OIDC federation + two-tier admin/user + per-user quotas + an `immich-admin` break-glass CLI. Confidence **high** (first-party docs, four sources).
- **Themes:** 5 (T19–T23), incremental on D1–D3 (T1–T18).
- **Baseline delta:** §1.6 Cross-Cutting Concerns populated (was TODO); one line added to §1.4 (deletion lifecycle cross-ref) — see landings.
- **GLOSSARY:** 6 identity terms added (tentative).
- **OQ:** 1 new — OQ#4 (no documented API-key surface). Existing OQ#1–3 untouched (no D4 evidence bears on them).
- **Hand-offs:** identity ADR **supported** (per-customer IdP wiring via per-instance OIDC config); 3 risks warranted for the risk-assessment-agent (claims-never-re-synced drift, lockout, quota bypass via external libraries). Routed via fitness review as established. **No risk rows / ADR written here.**

## Sources

- `input/stakeholder/2026-07-12_D4_identity-access-brief.md` (five session questions)
- `input/systems/immich/immich-oauth-authentication.md`
- `input/systems/immich/immich-user-management.md`
- `input/systems/immich/immich-server-commands.md`
- `input/systems/immich/immich-system-settings-auth.md`

**Excluded** (this run): all other `input/systems/immich/*` and D1–D3 stakeholder briefs — not identity-scoped; identity facts appear in none of them. `input/INDEX.md` count verified (23, matches); `core/artifacts/INDEX.md` verified (16, matches) via `check-indexes.sh`.

**pending_inputs:** None.

## Themes (T19–T23)

### T19 — OIDC federation is first-party, per-instance, and claim-mapped (Q2, Q4)
**Evidence:** Immich supports third-party auth via OpenID Connect on OAuth2, working with Authentik/Authelia/Okta/Google/Keycloak; grant type Authorization Code, confidential web client (`immich-oauth-authentication.md:9,19-20`). Per-instance config surface (Administration settings): Enabled, Issuer URL (`.well-known/openid-configuration`, auto-appended), Client ID, Client Secret, Scope (default `openid email profile`), ID Token Signed Response Algorithm (default RS256), plus three claim mappings — Storage Label Claim (`preferred_username`), Role Claim (`immich_role`), Storage Quota Claim (`immich_quota`) — Default Storage Quota GiB (0 = unlimited), Auto Register (default true), Auto Launch (default false) (`immich-oauth-authentication.md:33-46`). Redirect URIs for mobile/web-login/web-settings; optional backchannel logout; mobile-redirect override endpoint (`immich-oauth-authentication.md:21-27,48-50`).
**Implications:** Each managed customer instance can be wired to that customer's IdP through the documented per-instance OIDC config — the mechanism for per-customer IdP federation exists first-party (answers Q4 in the affirmative). Role/quota/storage-label are all IdP-drivable via claims.
**Lands in:** BASELINE §1.6 (as-is auth path). Supports an identity ADR (see hand-offs).
**Open questions:** none new — the mechanism is documented end to end.

### T20 — OIDC claims are applied at user creation ONLY, never re-synced (Q2, Q4, Q5)
**Evidence:** "Claim options (storage label, role, storage quota) are only used during user creation, not synchronized afterward" (`immich-oauth-authentication.md:55`).
**Implications:** After first login, IdP-side changes to a user's role/quota/label do **not** propagate to Immich — the local record drifts from the IdP source of truth. In managed multi-customer hosting this is an operational nuance the operator must own (reconciliation is manual/out-of-band). Where the docs stop short (Q4): no documented re-sync mechanism.
**Lands in:** BASELINE §1.6.
**Open questions:** none new — behavior is documented; the *consequence* is a warranted risk (drift), routed to risk-assessment.

### T21 — Two-tier admin/user model with first-user-becomes-admin and CLI admin grant/revoke (Q1)
**Evidence:** The first user to register becomes the admin (`immich-user-management.md:11`); admins create users under Administration > Users, optional SMTP welcome email (`immich-user-management.md:15,20`). `immich-admin grant-admin` / `revoke-admin` toggle admin by email (`immich-server-commands.md:26-27`). Administrative functions (user management) are web-app only, not mobile (BASELINE §1.1).
**Implications:** A flat two-tier model (admin vs user) — no documented finer-grained RBAC. First-user-becomes-admin means instance bootstrapping order matters for managed provisioning. Admin membership is both UI- and CLI-managed.
**Lands in:** BASELINE §1.6.
**Open questions:** none new.

### T22 — Per-user quotas (GiB, unlimited default) with an external-libraries exemption (Q1)
**Evidence:** Admins limit per-user storage in GiB via edit-user; once reached the user cannot upload; default is unlimited; "External libraries do not take up space from the storage quota" (`immich-user-management.md:23`). Storage labels change the upload path `upload/{userId}/…` → `upload/{custom_user_label}/…`, applied retroactively by a Storage Migration Job (`immich-user-management.md:27`). Quota is also IdP-drivable via `immich_quota` claim at creation (T19).
**Implications:** Quota is an upload gate, not a hard storage cap — external libraries are exempt, so a user with external-library access can hold content beyond their nominal quota. Material to managed-hosting capacity accounting (the 50×5 TB estate, D3). Warranted risk: quota bypass via external libraries (routed to risk-assessment).
**Lands in:** BASELINE §1.6.
**Open questions:** none new.

### T23 — Auth control plane: instance-wide toggles, break-glass CLI, deletion lifecycle, and a lockout path (Q1, Q3, Q5)
**Evidence:**
- **Instance-wide toggles:** password login can be disabled across the whole instance including the administrator; if both OAuth and password are disabled, no one can log in (`immich-system-settings-auth.md:17`). **Changing the password-auth setting does not affect existing sessions, only new login attempts** (`immich-system-settings-auth.md:19`).
- **Break-glass CLI (`immich-admin`, run inside the `immich_server` container):** `reset-admin-password`, `enable/disable-password-login`, `enable/disable-oauth-login`, `enable/disable-maintenance-mode`, `list-users`, `grant/revoke-admin`, `version`, `change-media-location`, `schema-check` (`immich-server-commands.md:15-30`).
- **Lockout-recovery path:** if both auth methods are disabled (lockout), the Server CLI `immich-admin enable-password-login` re-enables password login (`immich-system-settings-auth.md:19`).
- **Admin password reset:** admins reset a user's password to a random value; user must change it at next sign-in (`immich-user-management.md:31`).
- **Deletion lifecycle:** deleted accounts are disabled immediately but data removal takes **7 days by default** (customizable); admins can force immediate permanent deletion; the deletion job runs at midnight, setting changes take effect at the next scheduled run (`immich-user-management.md:35`, `immich-system-settings-auth.md:24-27`). Trash retains deleted files 30 days by default (`immich-system-settings-auth.md:31-33`).
**Implications:** The `immich-admin` CLI is the operator break-glass surface — critically the only documented recovery from a both-methods-disabled lockout, and it requires container exec access. Auth-setting changes NOT invalidating existing sessions is a second operational nuance: disabling password login (or an equivalent security response) does not force existing sessions out — a gap for incident response in managed hosting. Warranted risk: lockout (routed to risk-assessment).
**Lands in:** BASELINE §1.6 (control plane, deletion lifecycle); deletion 7-day purge cross-referenced from §1.4 (job set already there).
**Open questions:** OQ#4 — the fetched system-settings page documents **no** API-key surface, and session management only indirectly (the "existing sessions" note). D4 brief Q3 asks for password/session/API-key documentation; password and partial session behavior are captured in baseline, the API-key/session-management gap becomes OQ#4.

## conflicts_detected
None. D4 evidence is additive to D1–D3; no contradiction with BASELINE, TARGET, or any ADR.

## glossary_updates
6 terms added `tentative` (identity discipline): **OIDC (Immich usage)**, **OIDC claim mappings**, **immich-admin CLI**, **break-glass (immich-admin)**, **two-tier admin/user model**, **per-user storage quota**. See `core/GLOSSARY.md`. (Judged canonicality: all are recurring first-party identity concepts this brain will re-cite; none encode a technology *choice* yet, so none proposed for `confirmed`.)

## terms_flagged
None.

## OQ register
**OQ#4 (new, pre-approved by architect):** no documented API-key or session-management surface. Material to managed hosting — API keys are the standard non-interactive/service-account credential path, and per-session invalidation is the standard incident-response control; both are absent from the fetched docs (the fetch report flagged it, `immich-system-settings-auth.md:35`). What *is* documented (auth-setting changes don't invalidate existing sessions) is captured in BASELINE §1.6; the gap is the OQ. Existing OQ#1–3: no D4 evidence bears on them — untouched.

## Hand-offs (downstream recommendations — for architect review, routed via fitness review)

- **Identity ADR: SUPPORTED.** The evidence supports a real decision: *per-customer IdP wiring via the per-instance OIDC config* (T19) is a genuine directional choice for managed hosting — whether the pilot standardizes on OIDC federation per customer instance (issuer/client/scopes/claim-map per tenant) vs local password accounts, and how the claims-never-re-synced constraint (T20) is operationally owned. Recommend `decision-record-agent`. Do not write the ADR here.
- **Warranted risks (for `risk-assessment-agent`, not written here):**
  1. **Claims-never-re-synced drift** (T20) — IdP-side role/quota/label changes never propagate post-creation; local records drift from the IdP source of truth. Managed-hosting operational + least-privilege concern.
  2. **Lockout** (T23) — disabling both OAuth and password login locks everyone out including admin; recovery requires `immich-admin enable-password-login` via container exec. Availability/recoverability of the auth control plane.
  3. **Quota bypass via external libraries** (T22) — external-library content is exempt from per-user quota, so nominal quotas do not bound a user's real footprint. Capacity-accounting concern for the 50×5 TB estate.
  - Secondary (for the assessor to weigh): auth-setting changes not invalidating existing sessions (T23) weakens incident response — no documented forced-logout control (ties to OQ#4).
- **Security-focused analysis (nfr-analysis-agent):** if the architect wants the identity posture scored against the managed-hosting security lens (federation, session invalidation gap, break-glass exposure), route after ADR direction is set.

## recommended_next_agents
`decision-record-agent` (identity ADR), `risk-assessment-agent` (3 warranted rows + OQ#4 linkage), optionally `nfr-analysis-agent` (identity security scenarios). All architect-gated; register updates routed through the fitness review.
