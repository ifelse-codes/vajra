#!/usr/bin/env bash
# Verify — Session 104: the 8 stations now speak like a team (roles + plain status), one source,
# reused by both `vajra next --stations` and the `vajra next` packet; the gate logic is untouched.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="104"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-34s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-34s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- toolchain: the gate logic + reface both live behind the test suite (reface changes no logic) ---
run_check "cargo-test"   cargo test --all-targets
run_check "cargo-fmt"    cargo fmt -- --check
run_check "cargo-clippy" cargo clippy --all-targets -- -D warnings

# Build once; every surface check reads the real binary's output.
cargo build -q
BIN="./target/debug/vajra"
STATIONS="$($BIN next --stations 103)"
PACKET="$($BIN next 2>/dev/null)"
# The roster body = the lines between the team headline and the K-of-8 subtitle of --stations.
ROSTER="$(printf '%s\n' "$STATIONS" | sed -n '/the pipeline team/,/pipeline advance/p')"

# Substring tests use bash `[[ == *..* ]]` (not `printf|grep -q`): grepping a huge packet with
# `-q` exits early, the upstream printf takes SIGPIPE, and `pipefail` then reports a false FAIL.

# AC1 — reads like a team: named roles + a plain-language status line, not a bare number.
check_roster_names() {
  [[ "$ROSTER" == *"the pipeline team"* ]] || { echo "no team headline"; return 1; }
  for role in Analyst Architect Planner Coder QA Demo-er Releaser Reviewer; do
    [[ "$ROSTER" == *"$role"* ]] || { echo "roster missing role: $role"; return 1; }
  done
}
check_plain_status() {
  [[ "$ROSTER" == *"framed what to build"* ]] || { echo "no Analyst plain-done"; return 1; }
  [[ "$ROSTER" == *"no code committed yet"* ]] || { echo "no Coder plain-pending"; return 1; }
}
# The roster body itself must not leak the "K-of-8" plumbing — that stays a subtitle below it.
check_headline_not_bare_number() {
  [[ "$ROSTER" != *"of 8"* ]] || { echo "roster leaked K-of-8"; return 1; }
}
run_check "reads-like-a-team"     check_roster_names
run_check "plain-status-per-role" check_plain_status
run_check "headline-not-a-number" check_headline_not_bare_number

# AC3 — K unchanged: the number of ✓ roster marks equals the derived "N of 8 stations passed".
check_k_consistent() {
  local ticks subtitle
  ticks="$(grep -c '✓' <<<"$ROSTER")"
  subtitle="$(grep -oE '[0-9]+ of 8 stations passed' <<<"$STATIONS" | grep -oE '^[0-9]+')"
  [ "$ticks" = "$subtitle" ] || { echo "roster ✓=$ticks but subtitle K=$subtitle"; return 1; }
}
run_check "k-unchanged-vs-subtitle" check_k_consistent

# AC2 — one source, reused: the SAME roster narration appears in the `vajra next` packet.
check_single_source() {
  [[ "$PACKET" == *"pipeline team (session"* ]] || { echo "packet has no roster"; return 1; }
  [[ "$PACKET" == *"framed what to build"* ]] || { echo "packet roster not reused"; return 1; }
}
run_check "single-source-reuse" check_single_source

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-34s %s\n' "STEP" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
