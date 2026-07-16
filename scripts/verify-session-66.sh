#!/usr/bin/env bash
# Session 66 — Make the receipt AUTHORITATIVE (retire the ~4.71x overstatement).
# Root cause (S65 GT): `src/meter/mod.rs` recomputed cost from a compiled-in table lacking
# `claude-fable-5` -> it fell through to opus pricing (15/75), and the SDK-authoritative
# `total_cost_usd` was never read. The S63 fable run showed $5.9665 vs the real $1.2662 (4.71x).
#   PREFER   — the receipt headline is the JSONL's own `total_cost_usd` when present.
#   LABEL    — absent it, the token recompute is shown, explicitly tagged `[estimate]`.
#   GUARD    — an unknown model (fable-5) is flagged; its opus-priced estimate is labeled, never
#              presented as the charge, and the authoritative figure is what we bill/budget against.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="66"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

BIN="$ROOT/target/debug/vajra"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-52s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-52s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- Rust gates ---
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings
run_check "cargo-test"    cargo test
run_check "cargo-build"   cargo build

# --- The new meter unit tests must exist and pass ---
run_check "test-authoritative-headline" cargo test --lib meter::tests::authoritative_total_is_the_headline_estimate_is_labeled
run_check "test-fallback-labeled"        cargo test --lib meter::tests::missing_authoritative_falls_back_to_labeled_estimate

# ============================================================================
# E2E on the REAL binary. Fixture A reproduces S63: a `claude-fable-5` line whose token counts
# estimate to ~$5.97 at the opus fallback, plus the headless terminal result line carrying the
# authoritative $1.2662. Fixture B is a known model with NO `total_cost_usd` (interactive/legacy).
# ============================================================================
FA="$ARTIFACTS/fable-authoritative.jsonl"
cat > "$FA" <<'EOF'
{"type":"assistant","message":{"model":"claude-fable-5","usage":{"input_tokens":32687,"output_tokens":18781,"cache_read_input_tokens":593200,"cache_creation":{"ephemeral_5m_input_tokens":0,"ephemeral_1h_input_tokens":105923},"server_tool_use":{"web_search_requests":0,"web_fetch_requests":0}}}}
{"type":"result","subtype":"success","total_cost_usd":1.2662,"num_turns":17}
EOF

FB="$ARTIFACTS/known-no-authoritative.jsonl"
cat > "$FB" <<'EOF'
{"type":"assistant","message":{"model":"claude-opus-4-8","usage":{"input_tokens":500,"output_tokens":1000,"cache_read_input_tokens":11000,"cache_creation":{"ephemeral_5m_input_tokens":0,"ephemeral_1h_input_tokens":5000}}}}
EOF

# Criterion 1 + 4: headline == total_cost_usd; the two figures are distinguished.
headline_is_authoritative() {
  local out; out="$( "$BIN" meter "$FA" 2>&1 )"
  echo "$out" | grep -qE '^\s*\$1\.2662\s+total' \
    && echo "$out" | grep -q 'token estimate'
}
run_check "e2e-headline-is-total-cost-usd" headline_is_authoritative

# Criterion 3: the fable-priced-as-opus estimate ($5.9664) is NEVER the headline charge, and the
# unknown-model fallback is labeled/warned — not silently applied.
no_fable_as_opus_overstatement() {
  local out; out="$( "$BIN" meter "$FA" 2>&1 )"
  # The inflated estimate exists (proving the S63 bug is real) but is tagged, not billed.
  echo "$out" | grep -q '5.9664' \
    && echo "$out" | grep -q 'priced as opus upper bound' \
    && echo "$out" | grep -q 'not in pricing table' \
    && ! echo "$out" | grep -qE '^\s*\$5\.9664\s+total'
}
run_check "e2e-no-fable-priced-as-opus" no_fable_as_opus_overstatement

# Criterion 2: no `total_cost_usd` -> headline is the estimate, explicitly labeled `[estimate]`.
fallback_estimate_is_labeled() {
  local out; out="$( "$BIN" meter "$FB" 2>&1 )"
  echo "$out" | grep -qE '^\s*\$0\.2490\s+total\s+\[estimate\]' \
    && echo "$out" | grep -q 'no total_cost_usd in JSONL'
}
run_check "e2e-fallback-labeled-estimate" fallback_estimate_is_labeled

# ============================================================================
# Scope discipline (guardrails): meter/receipt path only; no 8th command; no new dependency.
# ============================================================================
run_check "no-8th-command"    bash -c 'git diff --quiet main -- src/main.rs'
run_check "no-new-dependency" bash -c 'git diff --quiet main -- Cargo.toml'
# Only the meter path (+ its budget caller) + verify/demo/session docs changed.
scope_is_meter_path() {
  local changed
  changed="$(git diff --name-only main..HEAD)"
  # Every changed source file must be within the sanctioned set.
  echo "$changed" | grep -E '^src/' | grep -vqE '^src/(meter/mod\.rs|cli/launch\.rs)$' && return 1
  return 0
}
run_check "scope-is-meter-receipt-path" scope_is_meter_path

# The authoritative preference is real code, not a doc claim: the parser reads `total_cost_usd`
# and the receipt/budget bill against `billed_dollars()`.
run_check "reads-total-cost-usd"   bash -c "grep -q 'total_cost_usd' '$ROOT/src/meter/mod.rs'"
run_check "budgets-billed-dollars" bash -c "grep -q 'billed_dollars' '$ROOT/src/cli/launch.rs'"

# --- Deliverable artifacts present ---
summary_present() {
  local S="$ROOT/sessions/session-66-summary.md"
  [ -f "$S" ] && grep -qi 'total_cost_usd\|authoritative' "$S"
}
run_check "summary-artifact-present" summary_present
run_check "cold-review-present"      test -f "$ROOT/sessions/session-66-review.md"

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
printf '%-52s %s\n' "STEP" "RESULT"
printf '%-52s %s\n' "----------------------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
