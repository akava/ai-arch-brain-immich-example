---
type: stakeholder-brief
session: D5 — operability & observability
date: 2026-07-12
provenance: simulated engagement fiction (demo) — architect-authored session brief; all facts
  about Immich come from the first-party documentation filed under input/systems/immich/
---

# D5 brief — operability & observability (simulated)

Running 50 instances to a 99.9% target (NFR-001) is impossible without knowing when instances are
unhealthy. The environment-variables evidence (D3) already hinted at a metrics surface (ports
8081/8082); this session establishes what Immich documents about monitoring, logging, and the
front-door path (reverse proxy) — the operator's day-2 toolkit.

## Questions for this session

1. What telemetry does Immich expose first-hand (metrics endpoints, format, what they cover)?
2. What logging does it document (levels, configuration, where logs go)?
3. What does the documentation prescribe for the reverse proxy in front of the server — and what
   does that imply for the ADR-004 hardening direction and the API serving path?
4. What health/readiness signals exist for the containers (if documented)?
5. What must the operator build around these primitives to operate 50 instances against NFR-001 —
   and which parts deserve an enabler in transition M1?

## Expected outputs

Incremental synthesis; baseline delta (observability/front-door facts); an observability decision
(proposed ADR) if the evidence supports one; a new M1 enabler for the operator monitoring
capability if warranted; register updates routed via fitness as established; D4 fitness follow-ups
(F2 work-stream currency, F3 OQ#4 cross-link) executed as approved corrections.

## Ground rules

Unchanged: first-party documentation only; gaps surface as open questions, never assumptions.
