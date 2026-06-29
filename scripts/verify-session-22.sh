#!/usr/bin/env bash
# Session 22 — scaffold propagation: `vajra init` emits the S20 ground-truth audits +
# the S21 co-pilot loader, so every scaffolded project inherits them (not just this repo).
# Proven against a REAL `vajra init` into a temp dir, not just the in-memory templates.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="22"
BIN="$ROOT/target/debug/vajra"
CANON="$ROOT/scripts/hook-copilot-loader.sh"

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

# --- Rust gates: the change compiles clean and the init unit tests pass ---
run_check "cargo-fmt"      cargo fmt -- --check
run_check "cargo-clippy"   cargo clippy --all-targets -- -D warnings
run_check "cargo-test-init" cargo test --lib cli::init
run_check "cargo-build"    cargo build

# --- Scaffold a real project into a temp dir (non-interactive stdin → L2 defaults) ---
SCAFFOLD=$(mktemp -d)
( cd "$SCAFFOLD" && "$BIN" init < /dev/null ) > "$ARTIFACTS/init.log" 2>&1 || true
C="$SCAFFOLD/.ai/CONSTRAINTS.yaml"
SHOOK="$SCAFFOLD/scripts/hook-copilot-loader.sh"
SSETTINGS="$SCAFFOLD/.claude/settings.json"
run_check "init-produced-constraints" test -f "$C"

# --- Deliverable 1: the S20 ground-truth hardening is scaffolded ---
gt_audits() {
  local n
  for n in "ground_truth:" "vision_alignment" "roadmap_alignment" "constitution_review" \
           "drift_axes:" "vision_questions:"; do
    grep -qF "$n" "$C" || { echo "scaffolded CONSTRAINTS missing: $n"; return 1; }
  done
}
run_check "scaffold-has-gt-audits" gt_audits

# --- Deliverable 2: the S21 co-pilot rules + the stale-bit refreshes are scaffolded ---
copilot_block() {
  grep -qF "copilot:" "$C"                                   || { echo "no copilot block"; return 1; }
  grep -qE '^[[:space:]]*-[[:space:]]*".*=>.*"' "$C"         || { echo "no ⚡on rule"; return 1; }
  grep -qF "go ahead and commit" "$C"                       || { echo "stale approval_tokens"; return 1; }
  grep -qF "ground_truth_commit_exempt_branch_suffixes" "$C" || { echo "no GT exempt suffixes"; return 1; }
}
run_check "scaffold-has-copilot" copilot_block

# --- Deliverable 3: the hook ships executable and is wired into PreToolUse (twice) ---
run_check "scaffold-hook-exec"   test -x "$SHOOK"
wired_twice() { test "$(grep -c 'hook-copilot-loader.sh' "$SSETTINGS")" -eq 2; }
run_check "scaffold-wired-twice" wired_twice

# --- Key decision (option b): the scaffolded hook is BYTE-IDENTICAL to canonical ---
# This is the no-drift guarantee: include_str! → one source of truth, never a hand-copy.
run_check "hook-no-drift"        cmp -s "$CANON" "$SHOOK"

# --- Deliverable 4: the PROPAGATED co-pilot actually FIRES (exit 2 at L2) + surfaces ---
HOOK_OUT=""
call_hook() { # $1=json $2=project_dir $3=state_dir $4=hook
  HOOK_OUT=$(printf '%s' "$1" | VAJRA_COPILOT_STATE_DIR="$3" CLAUDE_PROJECT_DIR="$2" bash "$4" 2>&1)
}
scaffold_copilot_fires() {
  local sd rc
  sd=$(mktemp -d)
  call_hook '{"tool_name":"Bash","tool_input":{"command":"git commit -m wip"},"session_id":"v22"}' \
    "$SCAFFOLD" "$sd" "$SHOOK"; rc=$?
  rm -rf "$sd"
  [ "$rc" -eq 2 ] || { echo "expected exit 2 (enforce), got $rc"; return 1; }
  echo "$HOOK_OUT" | grep -qF ".ai/STATE.md" || { echo "missing STATE.md include; got: $HOOK_OUT"; return 1; }
}
run_check "scaffold-copilot-fires" scaffold_copilot_fires

# --- Anti-rot: every scaffolded ⚡include target actually exists in the scaffold ---
scaffold_includes_exist() {
  local missing=0 f rhs
  while IFS= read -r line; do
    rhs=$(echo "$line" | sed -E 's/^[^=]*=>[[:space:]]*//; s/[[:space:]]*\|.*//')
    local OLDIFS="$IFS"; IFS=','
    for f in $rhs; do
      f=$(echo "$f" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')
      [ -n "$f" ] && [ ! -f "$SCAFFOLD/$f" ] && { echo "missing scaffolded include: $f"; missing=1; }
    done
    IFS="$OLDIFS"
  done < <(grep -E '^[[:space:]]*-[[:space:]]*".*=>.*"' "$C" | sed -E 's/^[[:space:]]*-[[:space:]]*"(.*)"[[:space:]]*$/\1/')
  [ "$missing" -eq 0 ]
}
run_check "scaffold-includes-exist" scaffold_includes_exist

rm -rf "$SCAFFOLD"

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-34s %s\n' "STEP" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
