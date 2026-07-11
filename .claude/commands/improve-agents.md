---
description: Audit an agent or rule file against the authoring rubric and propose a lean, rule-compliant rewrite. Runs the audit in an independent (forked) agent.
argument-hint: "<all|agent-name|spec|rules> [focus]"
allowed-tools: Read, Edit, Write, Bash, Agent
---

# Improve Agents

Purpose: run the agent/rule improvement cycle — audit a target against the authoring rubric,
then propose a lean, rule-compliant rewrite for architect approval. The audit runs in an
**independent (forked) agent** so the analysis and draft don't clutter the main thread.

Rubric: `guides/playbooks/agent-authoring-rubric.md` (the single source for what "good" looks
like — frontmatter-as-trigger, lean body shape, no stale content, rules referenced not pasted,
explained over forbidden, lifecycle compliance).

Target: `$1` — one of `all`, an agent name (`synthesis-agent`, `component-spec-agent`, `decision-record-agent`,
`nfr-analysis-agent`, `integration-contract-agent`, `risk-assessment-agent`, `fitness-review-agent`, `handoff-agent`,
`librarian-agent`), `spec`, or `rules`. Optional `$2` = a focus (e.g. `verbosity`, `lifecycle`,
`duplication`).

## Steps

1. Resolve `$1` to file(s):
   - an agent name → `.claude/agents/<name>.md`
   - `spec` → `core/3.ARCH-TARGET.md`
   - `rules` → `core/AGENT-RULES.md` and `CLAUDE.md`
   - `all` → every `.claude/agents/*.md` plus `core/AGENT-RULES.md`, `CLAUDE.md`, `core/3.ARCH-TARGET.md`
   If nothing resolves, stop and report.

2. Spawn a **fork** (Agent tool, `subagent_type: "fork"`) with this brief:
   - Read `guides/playbooks/agent-authoring-rubric.md` and the canonical rules in
     `core/AGENT-RULES.md` and `core/3.ARCH-TARGET.md`.
   - Read the resolved target file(s); `$2`, if given, narrows the focus.
   - Score each target against every rubric check (**pass / partial / fail**), citing
     `file:line` and a short quote for anything not passing.
   - Propose a lean rewrite **as draft text in the reply — do not write or overwrite any file.**
     Keep every real instruction (step, guardrail, output field); cut only words that don't
     pull their weight.
   - Return: the score table, the violation list, and the proposed rewrite per file.

3. Relay the fork's score table, violations, and draft rewrite to the architect.

4. Apply the rewrite only after the architect approves (Human Approval Rule, `core/AGENT-RULES.md`).
   After editing any indexed file, run the `librarian-agent` if `input/` or `core/artifacts/` changed.

## Stop conditions

- Rubric file or target file missing → stop and report.
- Do not present the draft as final or write approved-looking output without architect sign-off.
- If a rewrite would drop a real instruction, flag it instead of silently cutting.
