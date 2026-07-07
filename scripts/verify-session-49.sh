#!/usr/bin/env bash
# Session 49 — The OBEDIENCE BASELINE (direction B, founder pick A): give the S48 number a yardstick.
# S48 shipped `obedience %` but one reading has no context. This session batches the S48 metric over a
# directory of past transcripts (`vajra meter --all [dir]`) → a ranked table (worst-first) + aggregate
# (median / range) so "98.9%" means something. Reporting only ($0), read-only, no hook change, no new dep,
# no 8th command — it rides `vajra meter`. The S48 floor caveat carries: obedience = obeyed the RAILS,
# NOT proof the work was better; and a baseline is DESCRIPTIVE, not causal.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="49"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

MODULE="$ROOT/src/obedience/mod.rs"

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

# --- The five baseline unit tests must exist and pass ---
run_check "test-rank-median-range" cargo test --lib obedience::tests::baseline_ranks_worst_first_and_computes_median_range
run_check "test-even-median"       cargo test --lib obedience::tests::baseline_median_averages_two_middle_values_for_even_n
run_check "test-skip-empty"        cargo test --lib obedience::tests::baseline_skips_zero_tool_call_transcripts
run_check "test-agg-none"          cargo test --lib obedience::tests::baseline_aggregate_none_when_nothing_counted
run_check "test-table-caveat"      cargo test --lib obedience::tests::baseline_table_lists_counted_rows_and_carries_the_floor_caveat

# --- Instrumentation only: the module is read-only (never writes, spawns, or exits) ---
module_is_read_only() {
  ! grep -qE 'fs::write|File::create|OpenOptions|process::(exit|Command)|Command::new' "$MODULE"
}
run_check "obedience-read-only" module_is_read_only

# --- No new dependency (S21 rule): Cargo.toml unchanged vs main ---
run_check "no-new-dependency" bash -c 'git diff --quiet main -- Cargo.toml'

# --- No 8th command: the command dispatch is untouched vs main; baseline rides `vajra meter --all` ---
run_check "no-8th-command"  bash -c 'git diff --quiet main -- src/main.rs && ! grep -q obedience src/main.rs'
run_check "rides-meter"     grep -q -- '--all' "$ROOT/src/cli/meter.rs"

# --- Build the binary the E2E drives ---
run_check "cargo-build" cargo build

# --- End-to-end: a directory of REPLAYED transcripts with known counts prints the right baseline ---
# sA: 2 tool calls, 0 blocked          -> 100.0%
# sB: 2 tool calls, 1 blocked (guard)  ->  50.0%, top hook = hook-publish-guard.sh
# sC: empty transcript (0 tool calls)  -> skipped, not counted
# Expected aggregate: n=2, median 75.0% ((50+100)/2), range 50.0-100.0%, 1 total block, 1 skipped.
# Expected order (worst-first): sB before sA.
FIXDIR="$ARTIFACTS/transcripts"
mkdir -p "$FIXDIR"
cat > "$FIXDIR/sA.jsonl" <<'EOF'
{"type":"assistant","message":{"content":[{"type":"tool_use","id":"a1","name":"Bash","input":{}}]}}
{"type":"assistant","message":{"content":[{"type":"tool_use","id":"a2","name":"Bash","input":{}}]}}
EOF
cat > "$FIXDIR/sB.jsonl" <<'EOF'
{"type":"assistant","message":{"content":[{"type":"tool_use","id":"b1","name":"Bash","input":{}}]}}
{"type":"assistant","message":{"content":[{"type":"tool_use","id":"b2","name":"Bash","input":{}}]}}
{"type":"user","message":{"content":[{"type":"tool_result","is_error":true,"tool_use_id":"b2","content":"PreToolUse:Bash hook error: [bash \"$CLAUDE_PROJECT_DIR/.ai/hooks/hook-publish-guard.sh\"]: [vajra publish-guard] BLOCKED: git push"}]}}
EOF
: > "$FIXDIR/sC.jsonl"   # empty transcript — 0 tool calls

BASE_OUT="$ARTIFACTS/baseline-out.txt"
"$ROOT/target/debug/vajra" meter --all "$FIXDIR" > "$BASE_OUT" 2>&1 || true

run_check "e2e-aggregate-n"       grep -q 'n=2 sessions' "$BASE_OUT"
run_check "e2e-aggregate-median"  grep -q 'median 75.0%' "$BASE_OUT"
run_check "e2e-aggregate-range"   grep -q 'range 50.0' "$BASE_OUT"
run_check "e2e-total-blocks"      grep -q '1 total block' "$BASE_OUT"
run_check "e2e-empty-skipped"     grep -q '1 empty transcript(s) skipped' "$BASE_OUT"
run_check "e2e-row-sB-shown"      grep -q 'sB' "$BASE_OUT"
run_check "e2e-row-sC-hidden"     bash -c '! grep -q "sC" "'"$BASE_OUT"'"'
run_check "e2e-top-hook"          grep -q 'hook-publish-guard.sh' "$BASE_OUT"
# Honesty bar: descriptive-not-causal + the S48 floor caveat must both survive.
run_check "e2e-descriptive"       grep -q 'descriptive, not causal' "$BASE_OUT"
run_check "e2e-floor-caveat"      grep -q 'NOT proof the work was better' "$BASE_OUT"

# Worst-first ordering: sB (50%) must appear before sA (100%).
worst_first() {
  local nb na
  nb=$(grep -n 'sB' "$BASE_OUT" | head -1 | cut -d: -f1)
  na=$(grep -n 'sA' "$BASE_OUT" | head -1 | cut -d: -f1)
  [ -n "$nb" ] && [ -n "$na" ] && [ "$nb" -lt "$na" ]
}
run_check "e2e-worst-first-order" worst_first

# --- Determinism: same directory -> byte-identical baseline on a re-run ---
deterministic() {
  local a b
  a=$("$ROOT/target/debug/vajra" meter --all "$FIXDIR" 2>&1)
  b=$("$ROOT/target/debug/vajra" meter --all "$FIXDIR" 2>&1)
  [ "$a" = "$b" ] && [ -n "$a" ]
}
run_check "e2e-deterministic" deterministic

# --- The committed baseline artifact exists and carries its honesty read ---
artifact_present() {
  [ -f "$ROOT/sessions/session-49-baseline.md" ] \
    && grep -q 'descriptive' "$ROOT/sessions/session-49-baseline.md" \
    && grep -qi 'floor' "$ROOT/sessions/session-49-baseline.md"
}
run_check "baseline-artifact-present" artifact_present

# --- Hard rule: no commit on this branch touches >3 files (<=3 files per atomic commit) ---
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
printf '%-42s %s\n' "STEP" "RESULT"
printf '%-42s %s\n' "------------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
