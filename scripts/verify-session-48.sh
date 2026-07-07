#!/usr/bin/env bash
# Session 48 — The OBEDIENCE METRIC (direction B, founder pick A): measure before building more.
# S47 shipped the mid-run murmur but left an honest gap — mechanism verified, value UNMEASURED.
# This session mines a single number from the session trace: obedience % = clean / (clean + blocked),
# where a "block" is a Vajra rail (a PreToolUse hook exit-2) that already surfaces IN the transcript as
# a tool_result{is_error, "PreToolUse:… hook error … [vajra …]"}. Read-only, no hook change, no new dep,
# no blocking, no 8th command — it rides `vajra meter`. Honest bar: it measures obedience to the rails,
# NOT whether the work was better (a floor, first rung of the ladder).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="48"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

MODULE="$ROOT/src/obedience/mod.rs"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-40s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-40s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- Rust gates ---
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings
run_check "cargo-test"    cargo test

# --- The five obedience unit tests must exist and pass ---
run_check "test-clean-100"        cargo test --lib obedience::tests::clean_session_is_100_percent
run_check "test-block-50"         cargo test --lib obedience::tests::one_block_out_of_two_is_fifty_percent
run_check "test-plain-fail"       cargo test --lib obedience::tests::plain_tool_failure_is_not_a_block
run_check "test-dedupe"           cargo test --lib obedience::tests::duplicate_block_line_counts_once
run_check "test-empty"            cargo test --lib obedience::tests::empty_transcript_reports_no_tool_calls

# --- Instrumentation only: the module is read-only (never writes, spawns, or exits) ---
module_is_read_only() {
  ! grep -qE 'fs::write|File::create|OpenOptions|process::(exit|Command)|Command::new' "$MODULE"
}
run_check "obedience-read-only" module_is_read_only

# --- No new dependency (S21 rule): Cargo.toml unchanged vs main ---
run_check "no-new-dependency" bash -c 'git diff --quiet main -- Cargo.toml'

# --- No 8th command: the command dispatch is untouched vs main; obedience rides `vajra meter` ---
run_check "no-8th-command"        bash -c 'git diff --quiet main -- src/main.rs && ! grep -q obedience src/main.rs'
run_check "rides-meter"           grep -q 'obedience' "$ROOT/src/cli/meter.rs"

# --- Build the binary the E2E drives ---
run_check "cargo-build" cargo build

# --- End-to-end: a REPLAYED transcript with known counts prints the right obedience receipt ---
# 3 tool-call attempts (A,B,C); C is blocked by a Vajra rail (publish-guard); B fails as a plain
# command error (is_error but NO hook signature -> must NOT count as a block).
# Expected: 3 tool calls, 2 clean, 1 blocked, 66.7%, source = hook-publish-guard.sh.
FIX="$ARTIFACTS/replay-session.jsonl"
cat > "$FIX" <<'EOF'
{"type":"assistant","message":{"content":[{"type":"tool_use","id":"toolu_A","name":"Bash","input":{}}]}}
{"type":"assistant","message":{"content":[{"type":"tool_use","id":"toolu_B","name":"Bash","input":{}}]}}
{"type":"assistant","message":{"content":[{"type":"tool_use","id":"toolu_C","name":"Bash","input":{}}]}}
{"type":"user","message":{"content":[{"type":"tool_result","is_error":true,"tool_use_id":"toolu_C","content":"PreToolUse:Bash hook error: [bash \"$CLAUDE_PROJECT_DIR/.ai/hooks/hook-publish-guard.sh\"]: [vajra publish-guard] BLOCKED: git push"}]}}
{"type":"user","message":{"content":[{"type":"tool_result","is_error":true,"tool_use_id":"toolu_B","content":"npm ERR! build failed"}]}}
EOF

METER_OUT="$ARTIFACTS/meter-out.txt"
"$ROOT/target/debug/vajra" meter "$FIX" > "$METER_OUT" 2>&1 || true

run_check "e2e-obedience-pct"     grep -q 'obedience 66.7%' "$METER_OUT"
run_check "e2e-clean-blocked"     grep -q '2 clean / 1 blocked' "$METER_OUT"
run_check "e2e-total-calls"       grep -q '(3 tool calls)' "$METER_OUT"
run_check "e2e-source-traceable"  grep -q 'hook-publish-guard.sh' "$METER_OUT"
# Honesty bar: the receipt must state what it does NOT prove (a floor, not work-quality).
run_check "e2e-honesty-caveat"    grep -q 'NOT proof the work was better' "$METER_OUT"

# --- Determinism: same transcript -> byte-identical obedience block on a re-run ---
deterministic() {
  local a b
  a=$("$ROOT/target/debug/vajra" meter "$FIX" 2>&1 | grep obedience)
  b=$("$ROOT/target/debug/vajra" meter "$FIX" 2>&1 | grep obedience)
  [ "$a" = "$b" ] && [ -n "$a" ]
}
run_check "e2e-deterministic" deterministic

# --- Hard rule: no commit on this branch touches >3 files (≤3 files per atomic commit) ---
per_commit_file_cap() {
  local sha n
  for sha in $(git rev-list main..HEAD 2>/dev/null || true); do
    n=$(git show --name-only --format= "$sha" | grep -c . || true)
    [ "$n" -le 3 ] || return 1
  done
  return 0
}
run_check "per-commit-file-cap" per_commit_file_cap

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-40s %s\n' "STEP" "RESULT"
printf '%-40s %s\n' "----------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
