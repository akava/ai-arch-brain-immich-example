#!/usr/bin/env bash
# Enforce ADR immutability — mechanizes the "do not edit an approved ADR" rule
# (CLAUDE.md §7; core/decisions/INDEX.md Lifecycle Rules) that was previously prose-only.
#
# Canonical status is resolved from core/decisions/INDEX.md, NOT from the ADR body:
# ADR-003..006 carry only a prose "Status note:" and the registry is the single source
# of truth. Protected (immutable) states: approved, superseded, deprecated.
# Proposed / template ADRs remain freely editable (a proposed ADR is a reworkable draft).
#
# The documented label-only status-sync exception (INDEX.md) legitimately edits an
# approved ADR body to mirror a registry status change. Allow it explicitly:
#     ALLOW_ADR_STATUS_SYNC=1 git commit ...
#
# Usage:
#   check-adr-immutability.sh              # check staged changes (pre-commit)
#   check-adr-immutability.sh <base>..<head>   # check a commit range (CI)
set -uo pipefail
cd "$(dirname "$0")/../.."

INDEX="core/decisions/INDEX.md"
PROTECTED_RE='^(approved|superseded|deprecated)$'
rc=0

if [ ! -f "$INDEX" ]; then
  echo "check-adr-immutability: $INDEX not found — cannot resolve canonical ADR status." >&2
  exit 2
fi

resolve_status() {
  # $1 = ADR id (e.g. ADR-001); prints canonical status from the INDEX registry row.
  awk -F'|' -v id="$1" '
    { t=$2; gsub(/^[ \t]+|[ \t]+$/, "", t) }
    t == id { s=$5; gsub(/^[ \t]+|[ \t]+$/, "", s); print s; exit }
  ' "$INDEX"
}

if [ "$#" -ge 1 ]; then
  changes=$(git diff --name-status "$1" -- core/decisions/)
else
  changes=$(git diff --cached --name-status -- core/decisions/)
fi

[ -z "$changes" ] && exit 0

while IFS=$'\t' read -r st path _; do
  [ -z "${path:-}" ] && continue
  base=$(basename "$path")
  id=$(printf '%s' "$base" | grep -oE '^ADR-[0-9]+' || true)
  [ -z "$id" ] && continue           # INDEX.md, README, non-ADR files
  [ "$st" = "A" ] && continue        # a newly added ADR is fine
  adr_status=$(resolve_status "$id")
  [ -z "$adr_status" ] && { echo "WARN      $id — no status row in $INDEX; treating as unprotected"; continue; }
  if printf '%s' "$adr_status" | grep -qE "$PROTECTED_RE"; then
    if [ "${ALLOW_ADR_STATUS_SYNC:-0}" = "1" ]; then
      echo "ALLOW     $id ($adr_status) — change '$st' permitted under ALLOW_ADR_STATUS_SYNC (label-only status sync)"
    else
      echo "BLOCKED   $id is '$adr_status' and immutable (core/decisions/INDEX.md) — change '$st' to $path is not allowed."
      echo "          Supersede it with a new ADR. If this is the documented label-only status sync,"
      echo "          re-run with ALLOW_ADR_STATUS_SYNC=1."
      rc=1
    fi
  else
    echo "OK        $id ($adr_status) — editable"
  fi
done <<EOF
$changes
EOF

exit $rc
