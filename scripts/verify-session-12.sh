#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="12"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-30s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-30s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

run_check "cargo-check"  cargo check --all-targets
run_check "cargo-test"   cargo test --all-targets
run_check "cargo-fmt"    cargo fmt -- --check
run_check "cargo-clippy" cargo clippy --all-targets -- -D warnings

# E2E loop proof: init → next → advance through 3 sessions
e2e_loop_proof() {
  local TMP
  TMP=$(mktemp -d)
  trap "rm -rf '$TMP'" RETURN

  cd "$TMP"
  git init -q
  git commit --allow-empty -q -m "init"

  echo -e "testproj\ncreate files" | "$ROOT/target/release/vajra" init >/dev/null 2>&1

  # Write 3 session prompts
  cat > prompts/01-task-kickoff.md <<'PROMPT'
# Session 01 — Create hello.txt
## Goal
Create hello.txt
PROMPT
  cat > prompts/02-task-step-two.md <<'PROMPT'
# Session 02 — Create goodbye.txt
## Goal
Create goodbye.txt
PROMPT
  cat > prompts/03-task-step-three.md <<'PROMPT'
# Session 03 — Create README
## Goal
Create README.md
PROMPT

  git add -A && git commit -q -m "scaffold"
  git checkout -q -b session-01-test

  # S01: vajra next shows session 01 + correct prompt
  local OUT
  OUT=$("$ROOT/target/release/vajra" next 2>&1)
  echo "$OUT" | grep -q "session: 01" || { echo "FAIL: next did not show session 01"; return 1; }
  echo "$OUT" | grep -q "prompts/01-task-kickoff.md" || { echo "FAIL: next did not show S01 prompt"; return 1; }

  # Do S01 work
  echo "hello" > hello.txt && git add hello.txt && git commit -q -m "s01"

  # Advance S01 → S02
  echo "y" | "$ROOT/target/release/vajra" next --advance >/dev/null 2>&1
  [ "$(cat .ai/SESSION | tr -d '[:space:]')" = "02" ] || { echo "FAIL: SESSION not 02"; return 1; }

  # S02: vajra next shows session 02 + correct prompt
  OUT=$("$ROOT/target/release/vajra" next 2>&1)
  echo "$OUT" | grep -q "session: 02" || { echo "FAIL: next did not show session 02"; return 1; }
  echo "$OUT" | grep -q "prompts/02-task-step-two.md" || { echo "FAIL: next did not show S02 prompt"; return 1; }

  # Do S02 work
  echo "goodbye" > goodbye.txt && git add goodbye.txt && git commit -q -m "s02"

  # Advance S02 → S03
  echo "y" | "$ROOT/target/release/vajra" next --advance >/dev/null 2>&1
  [ "$(cat .ai/SESSION | tr -d '[:space:]')" = "03" ] || { echo "FAIL: SESSION not 03"; return 1; }

  # S03: prompt pointer updated
  OUT=$("$ROOT/target/release/vajra" next 2>&1)
  echo "$OUT" | grep -q "prompts/03-task-step-three.md" || { echo "FAIL: next did not show S03 prompt"; return 1; }

  echo "PASS: full 3-session loop completed"
}

run_check "e2e-loop-proof" e2e_loop_proof

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-30s %s\n' "STEP" "RESULT"
printf '%-30s %s\n' "------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
