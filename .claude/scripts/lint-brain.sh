#!/usr/bin/env bash
# Brain linter — turns two prose caps the brain already declares into checked rules
# (the plan's WS-A A3). v1 scope is deliberately narrow and matches the repo's own rules:
#
#  1. core/artifacts/INDEX.md Summary cell  ≤ 25 words  (the schema's own stated cap;
#     Keywords are UNCAPPED by design — "Keywords carry retrieval" — and not checked).
#  2. Run-log line budgets: *-synthesis.md ≤ 120 lines, *-fitness-review.md ≤ 80 lines.
#
# Reports every violation and exits non-zero if any are found. Intended for manual/CI use;
# NOT wired into pre-commit yet (existing artifact summaries breach #1 until the WS-E
# compaction pass lands — wiring it before then would wedge every commit).
set -uo pipefail
cd "$(dirname "$0")/../.."

rc=0
ARTIFACT_INDEX="core/artifacts/INDEX.md"
SUMMARY_MAX=25
SYNTH_MAX=120
FITNESS_MAX=80

# --- 1. Summary word cap on the artifacts index -----------------------------
if [ -f "$ARTIFACT_INDEX" ]; then
  # Data rows in the Files table have 7 columns (File|Skill|Type|Date|Status|Summary|Keywords)
  # => 9 fields when split on '|'. Summary is field 7. Skip the 2-column schema table,
  # the header row, and separator rows.
  while IFS= read -r line; do
    printf '%s' "$line" | grep -qE '^\|' || continue
    printf '%s' "$line" | grep -qE '^\|[ -]+\|' && continue          # separator
    nf=$(printf '%s' "$line" | awk -F'|' '{print NF}')
    [ "$nf" -eq 9 ] || continue                                       # only 7-col data rows
    file=$(printf '%s' "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$2); print $2}')
    case "$file" in File|"") continue ;; esac                         # header row
    summary=$(printf '%s' "$line" | awk -F'|' '{print $7}')
    words=$(printf '%s' "$summary" | wc -w | tr -d ' ')
    if [ "$words" -gt "$SUMMARY_MAX" ]; then
      echo "SUMMARY>25  $ARTIFACT_INDEX — '$file' summary is $words words (cap $SUMMARY_MAX)"
      rc=1
    fi
  done < "$ARTIFACT_INDEX"
fi

# --- 2. Run-log line budgets ------------------------------------------------
check_budget() {
  local glob="$1" max="$2" f lines
  for f in $glob; do
    [ -e "$f" ] || continue
    lines=$(wc -l < "$f" | tr -d ' ')
    if [ "$lines" -gt "$max" ]; then
      echo "LINES>$max  $f — $lines lines (cap $max)"
      rc=1
    fi
  done
}
check_budget 'core/artifacts/logs/*-synthesis.md' "$SYNTH_MAX"
check_budget 'core/artifacts/logs/*-fitness-review.md' "$FITNESS_MAX"

# --- 3. Canonical-text sync check (B1/B3) -----------------------------------
# The Output-schema preamble is defined once in the authoring rubric between
# <!-- canon:output-preamble --> markers and mirrored verbatim by every schema-bearing
# agent. Fail if any agent's copy diverges from the canon (silent drift of a duplicated line).
RUBRIC="guides/playbooks/agent-authoring-rubric.md"
if [ -f "$RUBRIC" ]; then
  canon=$(awk '/<!-- canon:output-preamble -->/{f=1;next} /<!-- \/canon:output-preamble -->/{f=0} f' "$RUBRIC" \
          | sed '/^[[:space:]]*$/d' | head -1)
  if [ -z "$canon" ]; then
    echo "SYNC-CANON  $RUBRIC — canon:output-preamble block is empty or missing"
    rc=1
  else
    for a in .claude/agents/*.md; do
      [ -e "$a" ] || continue
      # only agents that carry the preamble line (skip agents with no such line, e.g. utilities)
      copy=$(grep -F 'This schema is the file' "$a" | head -1)
      [ -z "$copy" ] && continue
      if [ "$copy" != "$canon" ]; then
        echo "SYNC-DRIFT  $a — Output preamble diverges from canon in $RUBRIC"
        rc=1
      fi
    done
  fi
fi

[ "$rc" -eq 0 ] && echo "lint-brain: OK — no violations"
exit $rc
