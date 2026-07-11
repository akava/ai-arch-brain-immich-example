# ADR-006 — Per-customer identity federation for managed instances

## Decision Metadata

- **Title**: Per-instance OIDC federation to each customer's own IdP, with password login retained for break-glass/admin fallback
- **Date**: 2026-07-12
- **Author**: Simulated architect (demo)
- **Severity**: MAJOR
- **Decision type**: security
- **Status**: proposed (canonical lifecycle: `core/decisions/INDEX.md`)

**Status note:** This ADR is an **unattended-run design proposal** (session D4). **No human has reviewed or approved it.** Per the Human Approval Rule, it is a draft until the architect explicitly approves; nothing here is final delivery. (Status-note convention per ADR-003/004/005.)

---

## Decision Impact

- [x] Introduces something new (the managed estate's per-customer identity-federation posture)
- [ ] Modifies an existing element
- [ ] Overrides a previous decision

---

## Context

Managed multi-customer hosting of 50 isolated Immich instances needs an **identity & access posture per customer** — how each customer's users authenticate, how role/quota are assigned, and how the operator recovers a locked-out instance. The doc set (D4 synthesis T19–T23; BASELINE §1.6) makes the auth surface first-party and per-instance:

- **OIDC is first-party and per-instance** (T19). Immich supports OpenID Connect on OAuth2 (Authorization Code grant, confidential web client), working with Authentik/Authelia/Okta/Google/Keycloak. The per-instance config surface is documented end to end: Enabled, Issuer URL (`.well-known/openid-configuration`), Client ID, Client Secret, Scope (default `openid email profile`), ID Token Signed Response Algorithm (default RS256), three **claim mappings** — Storage Label Claim (`preferred_username`), Role Claim (`immich_role`), Storage Quota Claim (`immich_quota`) — Default Storage Quota GiB (0 = unlimited), **Auto Register** (default `true`), **Auto Launch** (default `false`) (`immich-oauth-authentication.md:9,19-20,33-46,21-27,48-50`; BASELINE §1.6). The mechanism for per-customer IdP federation therefore exists first-party — a customer instance is wired to that customer's IdP through this config.
- **Claims are applied at user creation ONLY, never re-synced** (T20). Storage-label/role/quota claims are used at creation and not synchronized on later logins (`immich-oauth-authentication.md:55`). IdP-side role/quota changes never propagate to the local record → drift from the customer IdP source of truth (**R-07**).
- **A two-tier admin/user model** (T21): flat admin-vs-user, no finer RBAC; first registered user becomes admin; admin membership toggled by email via `immich-admin grant-admin`/`revoke-admin` (`immich-user-management.md:11`; `immich-server-commands.md:26-27`).
- **Per-user quota with an external-libraries exemption** (T22): quota gates uploads (GiB, default unlimited) but **external libraries are exempt** — an upload gate, not a footprint cap (`immich-user-management.md:23`) (**R-09**).
- **The auth control plane lives in the server container + the `immich-admin` CLI** (T23): password login is disableable instance-wide **including the administrator**; if both OAuth and password are disabled, **no one can log in**, and the only documented recovery is `immich-admin enable-password-login` via `immich_server` container exec (`immich-system-settings-auth.md:17,19`; `immich-server-commands.md:10-11,15-30`). Auth-setting changes **do not invalidate existing sessions** (`immich-system-settings-auth.md:19`) (**R-08**).
- **No documented API-key surface; session management documented only indirectly** — the fetched settings page has no API-key or session-management section (`immich-system-settings-auth.md:35`) (**OQ#4**).

The decision this ADR settles: **how each customer instance authenticates, and how the never-re-synced constraint and the lockout path are operationally owned.** The D4 synthesis explicitly routed this here (SUPPORTED — genuine directional choice) and told the assessor not to write the decision in synthesis.

**Urgency:** the identity posture gates managed-hosting provisioning design and is the deciding input for R-07/R-08/R-09; it also unblocks the §5.2 ownership gate the D4 risk run flagged (identity/access was unmapped in the ownership map).

---

## Options Considered

### Option A: Local accounts only per instance (admin-managed)

- **Description**: Each instance uses local password accounts only; the operator/admin provisions users, sets roles and quotas in the UI, and manages the lifecycle. No IdP coupling.
- **Pros**: Simplest; no per-customer IdP wiring; no dependency on a customer's IdP availability; no claims-at-creation drift (R-07 does not arise — roles/quota are set locally). Break-glass is the ordinary path, not an exception.
- **Cons**: **No SSO** — customers cannot use their own identity provider, a baseline expectation for managed B2B hosting. **Manual account lifecycle** per instance (joiners/movers/leavers handled by the operator or the customer admin, not the IdP), which does not scale cleanly across 50 tenants and puts deprovisioning latency on manual process.

### Option B: Per-instance OIDC federation to the customer's own IdP, password login retained for break-glass/admin fallback — **recommended**

- **Description**: Each managed instance is wired to **that customer's own IdP** through the documented per-instance OIDC config (issuer/client/scopes + `immich_role`/`immich_quota`/`preferred_username` claim mappings). **Password login is retained** (not disabled) as a break-glass/admin fallback rather than standardizing on OIDC-only. `Auto Register` behaviour is a per-tenant provisioning decision (on = self-service first-login creation against the customer IdP; off = pre-provisioned accounts) — set deliberately per customer, not left at the default unexamined.
- **Pros**: **First-party-supported** — builds directly on the documented per-instance OIDC surface (T19), no invented mechanism. Delivers per-customer SSO and IdP-driven role/quota at creation. **Retaining password login mitigates R-08's IdP-outage limb**: a customer IdP outage does not become a total per-instance lockout, because a non-federated admin fallback remains. Keeps each customer inside its own identity boundary — consistent with the D3 per-instance isolation philosophy and ADR-003's rejection of shared pools.
- **Cons**: Carries **R-07** (claims-at-creation-only drift) — IdP-side role/quota changes never propagate, so this option **requires an operator re-sync/reconciliation procedure** as a standing operational consequence (there is no stock re-sync). Retaining password login widens the break-glass admin surface that must be governed (guarded operation, container-exec access pre-provisioned). Per-tenant OIDC wiring is 50 client registrations to manage.

### Option C: Operator-central IdP fronting all instances

- **Description**: The operator runs one central IdP that fronts all 50 instances; every customer's users authenticate through the operator's identity domain.
- **Pros**: Uniform operations — one IdP to run, one claim-mapping regime, consistent lifecycle tooling across the estate.
- **Cons**: **Couples every customer to the operator's identity domain** (customers cannot use their own IdP) and introduces a **shared identity dependency under all 50 instances** — the same cross-customer blast-radius argument that rejected shared store pools in ADR-003 (T14 SPOF), now at the identity layer: a central-IdP outage or compromise reaches every tenant at once. Runs against the D3 per-instance philosophy.

---

## Final Decision

- **Chosen option**: **Option B** — per-instance OIDC federation to each customer's own IdP, **with password login retained** for break-glass/admin fallback (recommended posture, pending architect approval).
- **Rationale**: Option B is the only option that is both **first-party-supported** (the per-instance OIDC surface is documented end to end — T19, no invention) and **consistent with the pilot's isolation shape** (each customer stays in its own identity boundary; no shared identity plane to become a cross-tenant SPOF). Retaining password login rather than going OIDC-only is a deliberate mitigation of **R-08**: the documented lockout rule means an OIDC-only instance suffers a full per-instance auth outage on a **customer IdP outage**, recoverable only via privileged container exec — retaining a password/break-glass path removes that single dependency. Option A forgoes SSO and IdP-driven lifecycle that managed B2B hosting expects; Option C buys uniform operations at the cost of coupling every tenant to a shared operator identity domain — the exact blast-radius trade ADR-003 rejected. The residual cost of B is real and owned, not waved away: it **requires** an operator reconciliation procedure for the never-re-synced claims (R-07) and disciplined governance of the retained break-glass surface — both recorded below as consequences, not left implicit.

**Explicit open points** (not resolved by this ADR):
- **Session/API-key gap (OQ#4)** stays open: there is **no documented API-key surface** for service-account automation and **no documented per-session invalidation / forced-logout** control — auth-setting changes do not evict live sessions (`immich-system-settings-auth.md:19,35`). Federation does not close this; it needs the full API-key/session docs or source inspection. Carried as an open point, not filled.
- **Auto Register per tenant**: whether self-service first-login creation is enabled is a per-customer provisioning decision, set case by case — not fixed by this ADR.
- **Reconciliation cadence/mechanism** for R-07 drift is an operator-side procedure to design; this ADR establishes the requirement, not the schedule.

---

## Evidence

- **vendor_doc** — `input/systems/immich/immich-oauth-authentication.md:9,19-20,33-46,21-27,48-50,55`: first-party OIDC (Authorization Code, confidential web client); full per-instance config surface incl. `immich_role`/`immich_quota`/`preferred_username` claim mappings, Auto Register/Auto Launch; **claims applied at creation only, never re-synced** (`:55`).
- **vendor_doc** — `input/systems/immich/immich-system-settings-auth.md:17,19,35`: instance-wide auth toggles incl. admin; both-methods-disabled lockout; auth-setting changes do not invalidate existing sessions; no API-key/session-management section.
- **vendor_doc** — `input/systems/immich/immich-server-commands.md:10-11,15-30`: the `immich-admin` break-glass CLI (`enable-password-login`, `reset-admin-password`, `grant/revoke-admin`, …), run via `immich_server` container exec.
- **vendor_doc** — `input/systems/immich/immich-user-management.md:11,23,27`: first-user-becomes-admin; per-user quota with the **external-libraries exemption**; storage-label upload paths.
- **discovery** — `core/artifacts/logs/2026-07-12-immich-identity-access-synthesis.md` T19–T23 (identity ADR routed here, SUPPORTED); BASELINE §1.6.
- **judgement** — The Option C blast-radius rejection (identity-layer application of the ADR-003/T14 SPOF argument) and the OIDC-only-vs-password-fallback trade are architect-style judgement over documented facts, flagged as such.

---

## Constraints

- **CON-001**: identity posture must not alter stock containers or paths — OIDC is the stock config surface; the `immich-admin` CLI is the stock container-bundled tool; nothing here forks the stock auth model.
- **Claims-at-creation-only** (`immich-oauth-authentication.md:55`) binds every federation design — no stock re-sync exists, so reconciliation is an operator obligation (R-07).
- **Lockout rule** (`immich-system-settings-auth.md:17`): "disable both methods" is a guarded operation; recovery is container-exec-gated (R-08).
- Evidence is first-party docs only (**R-04**).

---

## Consequences

- **What this enables**: per-customer SSO to each customer's own IdP on a first-party-supported surface; IdP-driven role/quota at creation; each customer contained in its own identity boundary (no shared identity SPOF); the §5.2 ownership gate for identity/access is unblockable once an owner is assigned (see the interim ruling in `core/arch-processes/ownership-map.md`).
- **What this requires (standing operational consequences)**:
  - **R-07 drift procedure** — because claims are applied at creation only and never re-synced, the operator **must** own an out-of-band re-sync/reconciliation of role/quota/label against each customer IdP (least-privilege + quota-accuracy). This is a required procedure, not optional hygiene.
  - **R-08 lockout / break-glass runbook tie** — retaining password login is the mitigation, and it must be backed by an operator runbook: a non-federated break-glass admin path, pre-provisioned `immich_server` container-exec access for `immich-admin enable-password-login` (the **immich-admin** CLI is the recovery surface), and "disable both methods" treated as a guarded operation.
- **What to watch for (risk carried forward)**:
  - **R-09 quota-claims caveat** — the `immich_quota` claim sets an upload gate, **not** a footprint cap; **external libraries are exempt**, so IdP-driven quotas do not bound real per-instance footprint. Capacity accounting (NFR-005, 50 × 5 TB) must count external-library footprint separately.
  - **OQ#4 session/API-key gap** — no documented API-key surface for service-account automation and no per-session forced-logout; disabling a compromised auth method does not evict live sessions. Remains an **open point**, not closed by this decision.
  - First-registered-user-becomes-admin (T21) means instance-bootstrapping order matters for managed provisioning.

---

## Success Metrics

- **Federation coverage**: 100% of pilot customer instances authenticate against the intended customer IdP via the per-instance OIDC config, with a working password break-glass admin path verified per instance.
- **R-07 reconciliation**: a scheduled role/quota/label reconciliation runs per instance; zero unreconciled IdP↔instance role/quota divergences persist beyond one reconciliation cycle in the pilot.
- **R-08 recoverability**: break-glass drill — from a simulated customer-IdP outage, an authorized operator restores admin access via the retained password path / `immich-admin` CLI within the runbook's target time, without breaching NFR-001.

---

## System Alignment

- **Related ADRs**: related_to ADR-003 (applies the same shared-dependency / blast-radius rejection at the identity layer that ADR-003 applied to stores — the basis for rejecting Option C), ADR-004 (auth+TLS reverse-proxy hardening of the ML channel — a sibling security posture, distinct plane), ADR-005 (external-library footprint interacts with the R-09 quota caveat and NFR-005 capacity accounting). Supersedes none; conflicts with none.
- **Affects `core/3.ARCH-TARGET.md`**: Yes — §3.5 Security & Compliance gains an identity-federation entry, and §1.6 Cross-Cutting Concerns gains an identity & access row; both cite this ADR and are reconciled at `[Tentative]` per AGENT-RULES §8.
- **Affects `core/1.ARCH-CONTEXT.md`**: No.
- **Affected agents**: risk-assessment-agent (R-07/R-08/R-09 owner cells re-route to the newly-assigned identity/access owner — routed, not written by this ADR), fitness-review-agent, component-spec-agent, handoff-agent.
- **Related artifacts**: `core/artifacts/risk-register.md` (R-07, R-08, R-09); `core/arch-processes/open-question-register.md` (OQ#4); `core/arch-processes/ownership-map.md` (interim identity/access ruling); `core/artifacts/logs/2026-07-12-immich-identity-access-synthesis.md` (T19–T23).

---

## Lifecycle

| Status | Date | Reason |
|--------|------|--------|
| proposed | 2026-07-12 | Unattended-run design proposal (session D4); awaiting architect review |
