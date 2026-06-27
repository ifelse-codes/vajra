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

# --- Deliverable 1: the skill teaches the language ---
run_check "skill-exists"        test -f varta/SKILL.md
run_check "skill-frontmatter"   grep -q "^name: varta$" varta/SKILL.md
run_check "skill-language-not-file" grep -qi "language, not a file" varta/SKILL.md
run_check "skill-reads-live-ai" grep -qF ".ai/" varta/SKILL.md

# --- Deliverable 2: the self-describing grammar (the 9 constructs, frozen) ---
run_check "grammar-exists"      test -f varta/GRAMMAR.varta
run_check "nine-constructs"     bash -c '
  f=varta/GRAMMAR.varta
  for k in "⚡project" "⚡forbid" "⚡require" "⚡max" "⚡pipeline" "⚡final" "⚡on" "⚡assert" "⚡enum"; do
    grep -qF "$k" "$f" || { echo "missing construct: $k"; exit 1; }
  done'
run_check "grammar-copilot"     grep -qF "⚡on (" varta/GRAMMAR.varta
run_check "grammar-human-lane"  grep -q "//" varta/GRAMMAR.varta

# --- The no-drift guarantee, encoded structurally (S19 decision) ---
# Varta is a language spoken from live .ai/, NOT a hand-kept copy. No companion file may exist.
run_check "no-handcopy-companion" bash -c '! test -f varta/vajra.varta'

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-32s %s\n' "STEP" "RESULT"
printf '%-32s %s\n' "--------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
