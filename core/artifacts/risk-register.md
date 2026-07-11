---
title: Architecture Risk & Tech-Debt Register (living)
type: risk-register
agent: risk-assessment (legacy SKILL-006)
status: active
confidence: —
date: —
sources: []
---

# Architecture Risk & Tech-Debt Register

This is the living, canonical register of architecture risks and tech-debt items for the program, consolidated from `risk-assessment-agent` (legacy SKILL-006) runs. It carries a single global sequence **R-NN** and is updated **in place** as items change or new ones are added. The dated assessment run logs under `core/artifacts/logs/` remain as point-in-time analysis records; they are not updated. Change history lives in git (no change-log section, per repo rule). Closed items stay visible — unlike the action register, resolved rows are kept.

Status vocabulary: **open / mitigating / accepted / resolved** (source nuance kept in parentheses).

> TODO: one row per risk or tech-debt item, added by the `risk-assessment-agent`. Each row: stable `R-NN` ID (never reused), type (`risk` / `tech_debt`), cause → consequence description, likelihood, impact, derived severity, status, mitigation or acceptance (citing the ADR when accepted by decision), accountable owner, the trigger that re-opens review, and the source assessment log.

| ID | Type | Description (cause → consequence) | L | I | Severity | Status | Mitigation / acceptance | Owner | Review trigger | Source |
|----|------|-----------------------------------|---|---|----------|--------|------------------------|-------|----------------|--------|
