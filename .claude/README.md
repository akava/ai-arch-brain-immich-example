# .claude — Execution Layer

Claude-specific execution helpers that sit on top of the tool-agnostic core. They do not replace `core/`.

## Folders

- `prompts/` — reusable Claude prompts (e.g. project kickoff)
- `agents/` — the architecture agents (synthesis-agent, component-spec-agent, decision-record-agent, nfr-analysis-agent, integration-contract-agent, risk-assessment-agent, fitness-review-agent, handoff-agent, librarian-agent), each running in its own context window
- `commands/` — workflow entrypoints as Claude Code commands (user-invoked chains: drift-check, run-arch-chain, fitness-review, record-decision, prepare-handoff, improve-agents)
- `scripts/` — mechanical checks (e.g. `check-indexes.sh`)
- `mcp/` — MCP server references

## Principle

Agents and commands are Claude Code-native: an agent is delegated automatically when its frontmatter description matches the work, or spawned via a command; commands are user-invoked workflow entrypoints. The source of truth for agent governance remains `core/AGENT-RULES.md`.
