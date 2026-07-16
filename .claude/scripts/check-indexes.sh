#!/usr/bin/env bash
# Verify input/INDEX.md and core/artifacts/INDEX.md declared totals match the filesystem.
# Exit 0: both match. Exit 1: mismatch or unparseable index — run SKILL-009 before reading that directory.
# NOTE: the SessionStart hook (.claude/settings.json) intentionally runs this WITHOUT `|| true`.
# A SessionStart hook cannot abort startup on any exit code, so the non-zero exit is a loud,
# unmissable warning — not a blocker. Do not re-add `|| true`; that only re-hides a real mismatch.
set -uo pipefail
cd "$(dirname "$0")/../.."

status=0

check() {
  local dir="$1" index="$1/INDEX.md" declared actual
  if [ ! -f "$index" ]; then
    echo "MISSING   $index — run SKILL-009 to build it"
    status=1
    return
  fi
  declared=$(grep -m1 '^\*\*Total files in' "$index" | sed -E 's/.*: \*\*([0-9]+)\*\*.*/\1/')
  if ! [[ "$declared" =~ ^[0-9]+$ ]]; then
    echo "UNPARSED  $index — no '**Total files in ...**: **N**' line; run SKILL-009"
    status=1
    return
  fi
  actual=$(find "$dir" -type f ! -name '.gitkeep' ! -name '.DS_Store' | wc -l | tr -d ' ')
  if [ "$declared" = "$actual" ]; then
    echo "OK        $dir — $actual files, index total matches"
  else
    echo "MISMATCH  $dir — $actual files on disk, index declares $declared; run SKILL-009 before reading it"
    status=1
  fi
}

check input
check core/artifacts
exit $status
