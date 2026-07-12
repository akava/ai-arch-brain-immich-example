# Enabler Catalog

The canonical index of **enablers** — the capabilities the architecture delivers across transitions.

**Separation of concerns:**
- **This catalog = *what* an enabler is and *how to use* it** (name, description, the requirements it realizes, the milestone that builds it). The durable, cross-transition view.
- **The transition file = *how to build* it** (delta, benefit hypothesis, acceptance criteria, sequencing, open decisions), per `core/transitions/README.md`. Each catalog row links to that build detail.

Each enabler carries a stable ID **`E-NN`**, is defined once here (ID + name + description), and is built in exactly one transition; later transitions that extend it add a note referencing the extending phase. Names are the canonical terms — keep them in step with `core/GLOSSARY.md`.

**Enablers are not features.** An enabler is a technical / infrastructure / architectural capability built to support delivery. User-facing **features** are tracked in the transition (scope / work streams / deltas), **not** catalogued here.

---

## Catalog

| ID | Enabler | Milestone | Description — what it is & how to use | Related requirements | Build detail |
|----|---------|-----------|----------------------------------------|----------------------|--------------|
| E-01 | **Per-instance store HA** | M1 · WS1 | Operator-managed high-availability Postgres and Redis per managed instance, endpoint-transparent to the untouched stock containers (generic replication + failover). Consumers: each Immich instance connects to its HA store endpoints unchanged; brings the API/serving path within the availability budget stock cannot meet. | NFR-001 | [M1 → E-01](M1-managed-hosting-pilot.md) (§ Deltas → E-01) · ADR-003 (proposed) |
| E-02 | **Hardened scalable ML tier** | M1 · WS2 | A dedicated `immich-machine-learning` tier behind an operator-run, health-checked load balancer, reached by the server as a single ML URL via an auth+TLS reverse proxy fronting port 3003 on an isolated segment; sized by a per-asset inference benchmark. Consumers: the server dispatches ML work to one hardened, balanced endpoint instead of the stock sequential no-LB, no-security channel. | NFR-003, NFR-004, NFR-006 | [M1 → E-02](M1-managed-hosting-pilot.md) (§ Deltas → E-02) · ADR-004 (proposed) |
| E-03 | **Media storage & backup capability** | M1 · WS3 | Per-instance dedicated media volumes on supported (non-NTFS/FAT) filesystems, backed up operator-side via snapshot + off-instance replication honoring the documented DB-first-then-filesystem ordering, with Redis-queue-state durability. Consumers: closes the media-backup gap Immich leaves (DB-only automation) and provisions the aggregate capacity target. | NFR-005 | [M1 → E-03](M1-managed-hosting-pilot.md) (§ Deltas → E-03) · ADR-005 (proposed) |
| E-04 | **Bounded-window upgrade procedure** | M1 · WS4 | A rehearsed maintenance-window upgrade covering server + startup Postgres migrations + version-aligned ML restart over the split/HA topology, kept minimal and reversible to preserve the stock upgrade path. Consumers: the operator upgrades an instance within the planned-downtime window without breaking customizations. | NFR-002, CON-001 | [M1 → E-04](M1-managed-hosting-pilot.md) (§ Deltas → E-04) · R-05 |
| E-05 | **Fleet observability & health** | M1 · WS5 | An operator-run central observability plane over the 50 stock instances: fleet-wide-enabled Prometheus-compatible scrape of each instance's 8081/8082 metrics (`api`/`host`/`io`), central shipping + defined retention of the JSON log stream, operator-built synthetic health probes + container healthchecks over the stock `.immich` startup gate, and NFR-001-error-budget-tied alerting — per-instance data segregated per the isolated-instance philosophy (ADR-003). Consumers: the operator detects and diagnoses per-instance failures across the fleet from documented primitives Immich ships without a control plane; the detection layer NFR-001's availability gate depends on. | NFR-001 | [M1 → E-05](M1-managed-hosting-pilot.md) (§ Deltas → E-05) · ADR-007 (proposed) |

---

## Maintenance

- A new enabler is added here when a transition introduces one; the row names it and links to that transition's build detail.
- Enabler **names are canonical terms** — add/confirm them in `core/GLOSSARY.md` (the `component-spec` / `decision-record` agents coin/confirm names).
- When a transition closes (`core/transitions/README.md`), delivered enablers remain catalogued; carried-over enablers keep their row and re-point to the next transition.
