#!/usr/bin/env bash
# Session 41 — Fix the compression fail-gate (S36 finding, PROVEN), correctness-first.
#
# The bug: src/engine/default_engine.rs ran a fail-gate BEFORE selecting a heuristic —
#   `if !is_success(output) && line_count < 400 { passthrough }`. Real Claude Code omits
#   `exitCode` for Bash, so `is_success` infers "failure" and EVERY 30–399-line command
#   passed through (S36: 0 folds live). Only ≥400-line output ever folded.
#
# The fix (git-family only, never gamble): the fail-gate now applies ONLY to heuristics
#   whose fold is NOT guaranteed to preserve the failure signal. The git family
#   (git log head+tail; git status / git diff --stat passthrough) folds lossy-SAFE for
#   its format, so it declares `preserves_failure_signal()=true` and folds regardless of
#   exit code. The generic/unknown path stays gated — prefer passthrough over a fold that
#   might hide a marker-less failure. cargo/npm/pytest stay gated (their exit-code coupling
#   is a separate carry-forward). Proven for $0 by piping real-shaped payloads to `vajra hook`.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="41"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

ENGINE="$ROOT/src/engine/default_engine.rs"
TRAIT="$ROOT/src/engine/heuristic/mod.rs"
GIT="$ROOT/src/engine/heuristic/git.rs"
BIN="$ROOT/target/debug/vajra"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-42s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-42s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- Rust gates ---
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings
run_check "cargo-test"    cargo test
run_check "cargo-build"   cargo build

# --- Source assertions: the scoping predicate exists and is wired correctly ---
run_check "trait-declares-predicate" \
  grep -q "fn preserves_failure_signal" "$TRAIT"
run_check "trait-default-is-false" bash -c \
  "grep -A1 'fn preserves_failure_signal' '$TRAIT' | grep -q 'false'"
run_check "git-family-overrides-true" bash -c \
  "[ \"\$(grep -c 'fn preserves_failure_signal' '$GIT')\" = 3 ]"
run_check "engine-gate-uses-predicate" \
  grep -q "!heuristic.preserves_failure_signal()" "$ENGINE"
# The gate must come AFTER heuristic selection (else the predicate isn't known yet).
run_check "engine-selects-before-gate" bash -c '
  sel=$(grep -n "select_heuristic(request)" "'"$ENGINE"'" | head -1 | cut -d: -f1)
  gate=$(grep -n "preserves_failure_signal" "'"$ENGINE"'" | head -1 | cut -d: -f1)
  [ -n "$sel" ] && [ -n "$gate" ] && [ "$sel" -lt "$gate" ]'

# --- Named regression tests are present (proof discipline) ---
run_check "test-gitlog-folds-present" \
  grep -q "fn git_log_no_exit_code_folds_after_s41" tests/hook_adapter.rs
run_check "test-genuine-failure-present" \
  grep -q "fn genuine_failure_no_exit_code_passthroughs_both_ways" tests/hook_adapter.rs
run_check "test-generic-conservative-present" \
  grep -q "fn generic_ls_no_exit_code_stays_conservative" tests/hook_adapter.rs

# =====================================================================================
# Live fold-table proof — pipe complete real-shaped payloads (NO exitCode) to `vajra hook`.
# The S36 $0 method: no paid `vajra claude` run needed. Capture output THEN match (bash
# glob, not `grep -q` on a live pipe — dodges the S32 SIGPIPE-under-pipefail gotcha).
# =====================================================================================
payload()    { jq -nc --arg c "$1" --arg s "$2" \
  '{tool_name:"Bash",tool_input:{command:$c},tool_response:{stdout:$s,stderr:"",interrupted:false,isImage:false,noOutputExpected:false}}'; }
payload_ec() { jq -nc --arg c "$1" --arg s "$2" --argjson e "$3" \
  '{tool_name:"Bash",tool_input:{command:$c},tool_response:{stdout:$s,stderr:"",interrupted:false,isImage:false,noOutputExpected:false,exitCode:$e}}'; }
mklines()    { seq 0 "$1" | awk -v p="$2" '{print p, $0}'; }

GITLOG=$(mklines 59 "commit")     # 60 lines
LS=$(mklines 79 "src/file")       # 80 lines
BIG=$(mklines 449 "row")          # 450 lines
FAILOUT=$(printf 'error: cannot find config\n%s' "$(mklines 79 'retry')")  # error at HEAD, 81 lines

folds()      { local o; o=$(payload    "$1" "$2"      | "$BIN" hook 2>/dev/null); [[ "$o" == *"lines folded"* ]]; }
passes()     { local o; o=$(payload    "$1" "$2"      | "$BIN" hook 2>/dev/null); [[ "$o" == "{}" ]]; }
folds_ec()   { local o; o=$(payload_ec "$1" "$2" "$3" | "$BIN" hook 2>/dev/null); [[ "$o" == *"lines folded"* ]]; }
tail_survives() { local o; o=$(payload "$1" "$2" | "$BIN" hook 2>/dev/null); [[ "$o" == *"$3"* ]]; }

# THE WIN: git log, no exitCode → folds now (passed through before S41), tail preserved.
run_check "live-gitlog-folds"          folds        "git log --oneline -60" "$GITLOG"
run_check "live-gitlog-tail-survives"  tail_survives "git log --oneline -60" "$GITLOG" "commit 59"
# INVARIANT: a generic failure with the error NOT in the tail, no exitCode → passthrough.
run_check "live-genuine-failure-passes" passes      "./deploy.sh"            "$FAILOUT"
# CONSERVATIVE: an ordinary generic command, no exitCode, under the cap → passthrough.
run_check "live-generic-ls-passes"      passes      "ls -1 src"              "$LS"
# git status is decision-critical → its heuristic keeps full output → passthrough (unchanged).
run_check "live-gitstatus-stays-full"   passes      "git status"             "$LS"
# UNCHANGED: exitCode:0 present → generic folds as before (is_success short-circuits the gate).
run_check "live-exitcode0-folds"        folds_ec    "ls -1 src"              "$LS" 0
# UNCHANGED: ≥FAIL_PASSTHROUGH_CAP lines, no exitCode → generic still folds.
run_check "live-big-generic-folds"      folds       "find . -name *.rs"      "$BIG"

# --- ≤3 source files changed vs main (scope discipline) ---
run_check "three-src-file-cap" bash -c \
  '[ "$(git diff --name-only main -- src/ 2>/dev/null | wc -l | tr -d " ")" -le 3 ]'

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-42s %s\n' "STEP" "RESULT"
printf '%-42s %s\n' "------------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
