# Ownership map — architecture × org structure

Who is accountable for which component. The binding principle — no design without a clear internal accountable owner — is the gate at `core/3.ARCH-TARGET.md` §5.2. Ownership means accountability for the decisions taken and the component's future maintenance; maintenance may be performed by the vendor, but internal accountability must be explicit, and the vendor engages the actual component owner. The people roster itself lives in `lab/stakeholders/`; this map answers "who is accountable for what."

> TODO: one row per architecture component or stream, sourced from stakeholder sessions (cite the synthesis log). Each row: the component / stream, the accountable owner (name, with role where it disambiguates), and notes — correction history, delivery vs accountability distinctions, known couplings to open actions (`AI-NN`). Record owner corrections explicitly (date + what changed) so downstream actions re-route to the right person.

**Provenance:** the three rows below are client-confirmed role-level assignments from the D3 scale-up design brief (`input/stakeholder/2026-07-11_D3_scale-up-design-brief.md`; via `core/artifacts/logs/2026-07-11-immich-scale-up-design-synthesis.md` T16). These are **demo roles under the simulated engagement fiction** — no real named individuals. They satisfy the ARCH-TARGET §5.2 ownership gate for D3 design work at role granularity; name-level confirmation is out of scope for the simulated engagement.

| Component / stream | Accountable owner | Notes |
|--------------------|-------------------|-------|
| Hosting platform — Postgres / Redis / storage HA (baseline §1.1/§1.2, §3.3, §3.4) | **Hosting Platform Lead** (demo role) | Accountable for the stateful-store operability the availability target rests on (R-01, OQ#1). Client-confirmed role-level (D3 brief); engagement fiction. |
| Immich runtime — server, workers, upgrades (baseline §1.2, §3.3) | **Immich Runtime Owner** (demo role) | Owns the stock-upgrade-path tension: startup migrations, version alignment, worker split (R-02, R-05, QA-2). Client-confirmed role-level (D3 brief); engagement fiction. |
| ML tier — `immich-machine-learning` (baseline §1.2, §3.1, §3.4; `component-spec-immich-machine-learning.md`) | **ML Platform Owner** (demo role) | Owns ML scale-out (external LB, throughput sizing) and the unsecured-channel remediation (OQ#2, OQ#3, R-03). Unblocks the §5.2 ownership gate this spec flagged. Client-confirmed role-level (D3 brief); engagement fiction. |
