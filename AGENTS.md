# AGENTS.md

Universal boot file for agent hosts that follow the `AGENTS.md` convention. This repository has **one** operating model; it lives in `CLAUDE.md` (host-agnostic despite the name) and `core/AGENT-RULES.md`. No rules are maintained here — a second copy would only drift.

## Boot sequence

1. Read `CLAUDE.md` — the agent operating rules (behavior, delegation, approval, output locations).
2. Follow its Required Reading Order (defined once in `CLAUDE.md` — not duplicated here, so it can't drift).
3. Execute work through the agent definitions in `.claude/agents/` and the workflow entrypoints in `.claude/commands/`.

## If your host loads only this file

The five rules that must survive even a minimal boot:

- `core/` is the source of truth; follow the execution rules and agent dependencies in `core/AGENT-RULES.md`.
- Invent nothing — missing facts, components, constraints, or decisions stop the work; name the gap and the next step.
- All output is draft until an architect explicitly approves it; approval means ownership.
- Before reading `input/` or `core/artifacts/`, verify their `INDEX.md` matches the filesystem (count rows vs files); on mismatch run the `librarian-agent` (`.claude/agents/librarian-agent.md`) first.
- Use canonical names from `core/GLOSSARY.md`; flag ambiguities, never silently pick a spelling.

## Host notes

- `.claude/agents/` and `.claude/commands/` are Claude Code-native. On other hosts, treat each agent definition as the executable workflow spec and run it manually.
- Placement questions (`where does this file go?`) → `REPO_MAP.md` → Placement Rules.
