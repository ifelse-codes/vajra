#!/usr/bin/env bash
# Session 42 — Gap 1: jq-preflight, fail-closed (AGENTS.md L147).
#
# The leak (S40 constitution finding): every Vajra hook parses the CC payload with jq
# (`X=$(echo "$INPUT" | jq -r … || echo "")`). With jq absent, X is empty → the classifiers
# match nothing → `exit 0` → the guard passes EVERYTHING. "A check that cannot evaluate FAILS."
#
# The fix: an identical fail-closed preflight block sits right after `set -euo pipefail` in all
# five jq-parsing hooks. jq missing → L2/L3 exit 2 (block), L1 exit 0 (advise). The block is
# self-contained (own _VROOT/_VMAT locals), so it is byte-identical across hooks and travels
# INSIDE the include_str!'d copies → scaffolded projects inherit the fix with no init.rs change.
#
# Proof strategy: run each hook under a jq-less PATH shim (symlinks to the real tools, jq
# deliberately omitted) and assert exit 2 at L2 / exit 0 at L1; then, with jq present, assert
# every hook still classifies exactly as before (zero regression); assert the block is identical
# across all five; assert a real `vajra init` inherits the three scaffolded hooks byte-for-byte.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="42"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PUB="$ROOT/scripts/hook-publish-guard.sh"
SGUARD="$ROOT/scripts/hook-session-guard.sh"
COPILOT="$ROOT/scripts/hook-copilot-loader.sh"
PREBASH="$ROOT/scripts/hook-pre-bash.sh"
PREWRITE="$ROOT/scripts/hook-pre-write.sh"
ALL_HOOKS=("$PUB" "$SGUARD" "$COPILOT" "$PREBASH" "$PREWRITE")

BASH_BIN=$(command -v bash)

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

# --- Rust gates (no src/ changed — confirm nothing regressed; init.rs scaffold-drift unit
#     tests assert the three scaffolded hooks stay byte-identical to the edited sources) ---
run_check "cargo-fmt"        cargo fmt -- --check
run_check "cargo-clippy"     cargo clippy --all-targets -- -D warnings
run_check "cargo-test"       cargo test
run_check "cargo-build"      cargo build
for h in "${ALL_HOOKS[@]}"; do
  run_check "shellcheck-$(basename "$h" .sh)"  bash -n "$h"
done

# =====================================================================================
# The preflight block is byte-identical across all five hooks (one source, no drift).
# Extract the block (marker line → the first standalone `fi`) and compare.
# =====================================================================================
block() { awk '/# jq preflight/{f=1} f{print} f&&/^fi$/{exit}' "$1"; }
block_identical() {
  local ref; ref=$(block "$PUB")
  [ -n "$ref" ] || return 1
  local h
  for h in "$SGUARD" "$COPILOT" "$PREBASH" "$PREWRITE"; do
    [ "$(block "$h")" = "$ref" ] || return 1
  done
}
run_check "preflight-block-identical"  block_identical

# =====================================================================================
# Gap 1 core: jq MISSING → fail-closed. Build a PATH shim with the real tools symlinked
# but jq deliberately omitted, then drive each hook under it.
# =====================================================================================
SHIM=$(mktemp -d)
for t in bash sh dirname basename grep egrep awk sed cat tr git mkdir cksum env printf head tail wc rm; do
  p=$(command -v "$t" 2>/dev/null || true)
  [ -n "$p" ] && ln -sf "$p" "$SHIM/$t"
done
# Sanity: jq must be UNreachable under the shim, or the whole test is meaningless.
run_check "shim-has-no-jq" bash -c 'PATH="'"$SHIM"'" command -v jq >/dev/null 2>&1 && exit 1 || exit 0'

# expect_nojq <expected-rc> <maturity> <hook>
expect_nojq() {
  local expected="$1" mat="$2" hook="$3" rc
  set +e
  printf '{"tool_input":{"command":"git push origin main","file_path":"src/engine/x.rs"},"session_id":"s"}' | \
    PATH="$SHIM" CLAUDE_PROJECT_DIR="$ROOT" VAJRA_GUARD_MATURITY="$mat" "$BASH_BIN" "$hook" >/dev/null 2>&1
  rc=$?
  set -e
  [ "$rc" = "$expected" ]
}
# L2/L3 → BLOCK (exit 2) for every hook (was exit 0 — the leak).
for h in "${ALL_HOOKS[@]}"; do
  run_check "nojq-L2-blocks-$(basename "$h" .sh)"  expect_nojq 2 L2 "$h"
done
# L1 → ADVISE (exit 0), consistent with the maturity gate.
for h in "${ALL_HOOKS[@]}"; do
  run_check "nojq-L1-advises-$(basename "$h" .sh)"  expect_nojq 0 L1 "$h"
done

# =====================================================================================
# Zero regression: jq PRESENT → every hook still classifies exactly as before.
# =====================================================================================
# publish-guard: real push blocks, benign passes.
expect_pub() {
  local expected="$1" mat="$2" cmd="$3" json rc
  json=$(printf '%s' "$cmd" | jq -Rs '{tool_name:"Bash",tool_input:{command:.}}')
  set +e
  VAJRA_GUARD_MATURITY="$mat" bash "$PUB" <<<"$json" >/dev/null 2>&1
  rc=$?
  set -e
  [ "$rc" = "$expected" ]
}
run_check "reg-pub-blocks-push"   expect_pub 2 L2 'git push origin main'
run_check "reg-pub-passes-status" expect_pub 0 L2 'git status'

# session-guard: same-chat N→N+1 boundary still blocks, fresh chat passes (verify-39 pattern).
GROOT=$(mktemp -d)
mkdir -p "$GROOT/.ai"
printf '41\n' > "$GROOT/.ai/SESSION"
printf 'maturity: L2\nsession:\n  one_session_per_chat: true\n' > "$GROOT/.ai/CONSTRAINTS.yaml"
GOWN="$GROOT/owner"
expect_guard() {
  local expected="$1" cmd="$2" sid="$3" json rc
  printf '41\tchatA\n' > "$GOWN"
  json=$(jq -nc --arg c "$cmd" --arg s "$sid" '{tool_input:{command:$c}, session_id:$s}')
  set +e
  printf '%s' "$json" | CLAUDE_PROJECT_DIR="$GROOT" VAJRA_SESSION_OWNER_FILE="$GOWN" \
    VAJRA_GUARD_MATURITY=L2 bash "$SGUARD" >/dev/null 2>&1
  rc=$?
  set -e
  [ "$rc" = "$expected" ]
}
run_check "reg-guard-blocks-boundary" expect_guard 2 'git checkout -b session-42-foo' chatA
run_check "reg-guard-passes-fresh"    expect_guard 0 'git checkout -b session-42-foo' chatB

# copilot-loader: a matching src/engine/* touch fires (exit 2), a non-match passes (exit 0).
expect_copilot() {
  local expected="$1" file="$2" json rc sdir
  sdir=$(mktemp -d)
  json=$(jq -nc --arg f "$ROOT/$file" '{tool_input:{file_path:$f}, session_id:"regs"}')
  set +e
  printf '%s' "$json" | CLAUDE_PROJECT_DIR="$ROOT" VAJRA_COPILOT_STATE_DIR="$sdir" \
    VAJRA_GUARD_MATURITY=L2 bash "$COPILOT" >/dev/null 2>&1
  rc=$?
  set -e
  rm -rf "$sdir"
  [ "$rc" = "$expected" ]
}
run_check "reg-copilot-fires-engine"  expect_copilot 2 'src/engine/default_engine.rs'
run_check "reg-copilot-passes-readme" expect_copilot 0 'README.md'

# =====================================================================================
# Scaffold propagation: a real `vajra init` inherits the three scaffolded hooks with the
# preflight baked in, byte-for-byte (the include_str! one-source guarantee).
# =====================================================================================
SCRATCH=$(mktemp -d)
trap 'rm -rf "$SHIM" "$GROOT" "$SCRATCH"' EXIT
( cd "$SCRATCH" && git init -q )
printf 'demo-proj\nbuild it\n\n' | ( cd "$SCRATCH" && "$ROOT/target/debug/vajra" init ) >/dev/null 2>&1 || true
run_check "e2e-pub-byte-identical"     cmp -s "$SCRATCH/.ai/hooks/hook-publish-guard.sh" "$PUB"
run_check "e2e-guard-byte-identical"   cmp -s "$SCRATCH/.ai/hooks/hook-session-guard.sh" "$SGUARD"
run_check "e2e-copilot-byte-identical" cmp -s "$SCRATCH/.ai/hooks/hook-copilot-loader.sh" "$COPILOT"
run_check "e2e-scaffold-has-preflight" grep -q "# jq preflight" "$SCRATCH/.ai/hooks/hook-publish-guard.sh"

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-42s %s\n' "STEP" "RESULT"
printf '%-42s %s\n' "------------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
