---
type: stakeholder-brief
session: D4 — identity, access & user management
date: 2026-07-12
provenance: simulated engagement fiction (demo) — architect-authored session brief; all facts
  about Immich come from the first-party documentation filed under input/systems/immich/
---

# D4 brief — identity, access & user management (simulated)

With the pilot design package drafted (D3, transition M1), the client's next concern is
**identity**: every managed customer instance needs user accounts, admin separation, and —
where the customer has one — integration with the customer's identity provider. Today the
engagement has no evidence on Immich's identity model at all.

## Questions for this session

1. What is Immich's user/account model (roles, admin separation, quotas if any), as documented?
2. What external authentication does Immich support (OAuth/OIDC?), and what does its
   configuration surface look like per instance?
3. What does the documentation say about password auth, session behavior, and API keys?
4. Can an operator technically wire each customer instance to that customer's identity provider,
   per the documented mechanisms — and where do the docs stop short?
5. Which identity-related risks and decisions does the pilot need recorded now?

## Expected outputs

Incremental synthesis; baseline delta (identity/access facts); a security-focused analysis update
if warranted; a proposed identity ADR if the evidence supports a real decision; register updates
routed through the fitness review as established.

## Ground rules

Unchanged: first-party documentation only; the client's multi-customer ambitions are engagement
fiction and labeled as such; gaps surface as open questions, never assumptions.
