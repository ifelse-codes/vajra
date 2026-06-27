#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="19"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-32s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-32s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- Deliverable 1: the Varta skill ---
run_check "skill-exists"        test -f varta/SKILL.md
run_check "skill-frontmatter"   grep -q "^name: varta$" varta/SKILL.md
run_check "grammar-exists"      test -f varta/GRAMMAR.varta

# --- Deliverable 2: vajra.varta worked example ---
run_check "vajra-varta-exists"  test -f varta/vajra.varta

# all 9 constructs present in the worked example (the whole grammar, nothing more)
run_check "nine-constructs"     bash -c '
  f=varta/vajra.varta
  for k in "⚡project" "⚡forbid" "⚡require" "⚡max" "⚡pipeline" "⚡final" "⚡on" "⚡assert" "⚡enum"; do
    grep -qF "$k" "$f" || { echo "missing construct: $k"; exit 1; }
  done'

# the hard rule and the co-pilot load are both expressed
run_check "forbid-main"         grep -qF "work_on_main" varta/vajra.varta
run_check "copilot-compression" grep -qF "⚡on (compression)" varta/vajra.varta
run_check "human-lane"          grep -q "//" varta/vajra.varta

# --- Deliverable 3: the read-back test ---
run_check "readback-exists"     test -f varta/READBACK.md
run_check "readback-complete"   grep -qF "6/6" varta/READBACK.md

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-32s %s\n' "STEP" "RESULT"
printf '%-32s %s\n' "--------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
