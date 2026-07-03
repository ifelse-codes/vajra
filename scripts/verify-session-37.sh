#!/usr/bin/env bash
# Session 37 — Close the enforcement leak (S36 headline finding).
# hook-publish-guard.sh turns the outward/irreversible actions the S36 agent took unstopped
# (git push, gh pr create, gh pr merge) into a real, maturity-gated BLOCK (exit 2 at L2/L3)
# unless the founder set VAJRA_ALLOW_PUBLISH=1 at launch. L1 advises; innocuous git commands
# (status/log/diff) pass. This script drives the hook with real-shaped PostToolUse payloads
# and asserts the exit code for each case — no paid `vajra claude` run needed.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="37"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

HOOK="$ROOT/scripts/hook-publish-guard.sh"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-36s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-36s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# Drive the hook with a real-shaped PostToolUse payload; assert its exit code.
#   expect_exit <expected> <maturity> <allow> <command>
expect_exit() {
  local expected="$1" mat="$2" allow="$3" cmd="$4" json rc
  json=$(printf '%s' "$cmd" | jq -Rs '{tool_name:"Bash",tool_input:{command:.}}')
  set +e
  VAJRA_GUARD_MATURITY="$mat" VAJRA_ALLOW_PUBLISH="$allow" \
    bash "$HOOK" <<<"$json" >/dev/null 2>&1
  rc=$?
  set -e
  [ "$rc" = "$expected" ]
}

# --- Rust gates (no src/ changed this session — these confirm nothing regressed) ---
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings
run_check "cargo-test"    cargo test

# --- Core: the leak actions are BLOCKED at L2/L3 without approval (exit 2) ---
run_check "block-git-push-L2"          expect_exit 2 L2 ""  "git push origin main"
run_check "block-gh-pr-create-L2"      expect_exit 2 L2 ""  "gh pr create --fill"
run_check "block-gh-pr-merge-L3"       expect_exit 2 L3 ""  "gh pr merge 1 --squash"
run_check "block-glab-mr-create-L2"    expect_exit 2 L2 ""  "glab mr create --fill"
run_check "block-force-push-L2"        expect_exit 2 L2 ""  "git push --force origin main"
run_check "block-compound-push-L2"     expect_exit 2 L2 ""  "cd /tmp/x && git push origin main"

# --- Approval + advise paths ---
run_check "allow-with-env-L2"          expect_exit 0 L2 "1" "git push origin main"
run_check "allow-with-env-pr-merge-L3" expect_exit 0 L3 "1" "gh pr merge 1"
run_check "advise-git-push-L1"         expect_exit 0 L1 ""  "git push origin main"

# --- Innocuous git commands are never guarded (exit 0) ---
run_check "pass-git-status-L2"         expect_exit 0 L2 ""  "git status"
run_check "pass-git-log-L2"            expect_exit 0 L2 ""  "git log --oneline -40"
run_check "pass-git-diff-stat-L2"      expect_exit 0 L2 ""  "git diff --stat"
run_check "pass-empty-cmd-L2"          expect_exit 0 L2 ""  ""

# --- S36 replay: the exact sequence that leaked is now blocked at L2 ---
run_check "s36-replay-push-blocked"    expect_exit 2 L2 ""  "git push origin main"
run_check "s36-replay-pr-create-block" expect_exit 2 L2 ""  "gh pr create --title x --body y"
run_check "s36-replay-pr-merge-block"  expect_exit 2 L2 ""  "gh pr merge --merge"

# --- Wiring + hygiene ---
run_check "hook-executable"            test -x "$HOOK"
run_check "wired-in-settings" bash -c \
  'grep -q "hook-publish-guard.sh" "'"$ROOT"'/.claude/settings.json"'
run_check "three-file-cap" bash -c \
  '[ "$(git diff --name-only main... 2>/dev/null | wc -l | tr -d " ")" -le 3 ] || \
   [ "$(git status --porcelain 2>/dev/null | wc -l | tr -d " ")" -le 3 ]'

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-36s %s\n' "STEP" "RESULT"
printf '%-36s %s\n' "------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
