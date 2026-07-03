#!/usr/bin/env bash
# Session 39 — Harden the guards (make the enforcement moat correct).
#   Story B: hook-publish-guard.sh no longer over-blocks. It classifies against the command
#            with QUOTED SPANS REMOVED, so a trigger phrase inside a message/arg
#            (git commit -m "…git push…", echo "gh pr create") stops false-blocking, while
#            every real unquoted push/PR still blocks (fail-safe: over-block > leak).
#   Story A: hook-session-guard.sh now arms on `vajra next --advance` (the S36 root cause —
#            the brownfield agent advanced 00→01 without ever `checkout -b`), not just on
#            branch creation. Same "same-chat crosses N→N+1" block, target = .ai/SESSION + 1.
# Both hooks are include_str!'d into `vajra init`, so scaffolded copies inherit the fix — the
# byte-identical cmp asserts no drift. No paid `vajra claude` run needed.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="39"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PUB="$ROOT/scripts/hook-publish-guard.sh"
SGUARD="$ROOT/scripts/hook-session-guard.sh"

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

# --- Rust gates (no src/ changed this session — these confirm nothing regressed, and the
#     existing scaffold drift unit tests assert both hooks stay byte-identical) ---
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings
run_check "cargo-test"    cargo test
run_check "shellcheck-pub"   bash -n "$PUB"
run_check "shellcheck-guard"  bash -n "$SGUARD"

# =====================================================================================
# Story B — publish-guard: fix the over-block, keep every real block.
# =====================================================================================
# expect_pub <expected-rc> <maturity> <allow> <command>
expect_pub() {
  local expected="$1" mat="$2" allow="$3" cmd="$4" json rc
  json=$(printf '%s' "$cmd" | jq -Rs '{tool_name:"Bash",tool_input:{command:.}}')
  set +e
  VAJRA_GUARD_MATURITY="$mat" VAJRA_ALLOW_PUBLISH="$allow" bash "$PUB" <<<"$json" >/dev/null 2>&1
  rc=$?
  set -e
  [ "$rc" = "$expected" ]
}

# B.1 — the over-block is fixed: a trigger phrase buried in a message/arg NO LONGER blocks (0).
run_check "B-commit-msg-mentions-push"  expect_pub 0 L2 "" 'git commit -m "mentions git push"'
run_check "B-echo-pr-create-quoted"     expect_pub 0 L2 "" 'echo "gh pr create"'
run_check "B-singlequote-push-in-msg"   expect_pub 0 L2 "" "git commit -m 'fix: git push guard'"
run_check "B-commit-F-file"             expect_pub 0 L2 "" 'git commit -F /tmp/msg'
run_check "B-body-mentions-pr-merge"    expect_pub 0 L2 "" 'gh issue comment 1 --body "then gh pr merge"'

# B.2 — zero regression: every real (unquoted) push/PR still BLOCKS at L2 (exit 2).
run_check "B-block-real-push"           expect_pub 2 L2 "" 'git push origin main'
run_check "B-block-force-push"          expect_pub 2 L2 "" 'git push --force origin main'
run_check "B-block-compound-push"       expect_pub 2 L2 "" 'cd /tmp/x && git push origin main'
run_check "B-block-push-quoted-branch"  expect_pub 2 L2 "" 'git push origin "my-branch"'
run_check "B-block-commit-then-push"    expect_pub 2 L2 "" 'git commit -m "wip" && git push origin main'
run_check "B-block-gh-pr-create"        expect_pub 2 L2 "" 'gh pr create --title "x" --body "y"'
run_check "B-block-gh-pr-merge"         expect_pub 2 L3 "" 'gh pr merge 1 --squash'
run_check "B-block-glab-mr-create"      expect_pub 2 L2 "" 'glab mr create --fill'

# B.3 — approval + advise + innocuous paths unchanged.
run_check "B-allow-with-env"            expect_pub 0 L2 "1" 'git push origin main'
run_check "B-advise-L1"                 expect_pub 0 L1 "" 'git push origin main'
run_check "B-pass-git-status"           expect_pub 0 L2 "" 'git status'

# =====================================================================================
# Story A — session-guard: arm on `vajra next --advance`, not just `checkout -b`.
# Drive the hook against a temp root that controls .ai/SESSION (=38) and the enable flag,
# with a synthetic owner record (38 owned by chatA) — no real chat needed (verify-26 pattern).
# =====================================================================================
AROOT=$(mktemp -d)
mkdir -p "$AROOT/.ai"
printf '38\n' > "$AROOT/.ai/SESSION"
printf 'maturity: L2\nsession:\n  one_session_per_chat: true\n' > "$AROOT/.ai/CONSTRAINTS.yaml"
AOWN="$AROOT/owner"
# expect_guard <expected-rc> <maturity> <cmd> <sid>   (owner is always 38 -> chatA)
expect_guard() {
  local expected="$1" mat="$2" cmd="$3" sid="$4" json rc
  printf '38\tchatA\n' > "$AOWN"
  json=$(jq -nc --arg c "$cmd" --arg s "$sid" '{tool_input:{command:$c}, session_id:$s}')
  set +e
  printf '%s' "$json" | CLAUDE_PROJECT_DIR="$AROOT" VAJRA_SESSION_OWNER_FILE="$AOWN" \
    VAJRA_GUARD_MATURITY="$mat" bash "$SGUARD" >/dev/null 2>&1
  rc=$?
  set -e
  [ "$rc" = "$expected" ]
}
# A.1 — the S36 root cause is closed: same chat that owns 38, on `vajra next --advance`
#        (target 39), is BLOCKED at L2 — even though it never ran `checkout -b`.
run_check "A-advance-same-chat-blocks"  expect_guard 2 L2 'vajra next --advance' chatA
run_check "A-advance-cargo-run-form"    expect_guard 2 L2 'cargo run -- next --advance' chatA
# A.2 — a fresh chat advancing is the correct path -> allowed.
run_check "A-advance-fresh-chat-allows" expect_guard 0 L2 'vajra next --advance' chatB
# A.3 — L1 advises, never blocks, on the same boundary.
run_check "A-advance-L1-advises"        expect_guard 0 L1 'vajra next --advance' chatA
# A.4 — non-advance activity never arms (plain next, a read, or the phrase inside a message).
run_check "A-plain-next-passes"         expect_guard 0 L2 'vajra next' chatA
run_check "A-cat-session-no-arm"        expect_guard 0 L2 'cat .ai/SESSION' chatA
run_check "A-advance-phrase-in-msg"     expect_guard 0 L2 'git commit -m "run vajra next --advance later"' chatA
# A.5 — the S26/S29 checkout boundary still holds (zero regression).
run_check "A-checkout-same-chat-blocks" expect_guard 2 L2 'git checkout -b session-39-foo' chatA
run_check "A-checkout-fresh-allows"     expect_guard 0 L2 'git checkout -b session-39-foo' chatB
run_check "A-checkout-nonsession"       expect_guard 0 L2 'git checkout -b feature/x' chatA

# =====================================================================================
# Byte-identical: a real `vajra init` inherits BOTH hardened hooks with no drift.
# =====================================================================================
run_check "cargo-build" cargo build
SCRATCH=$(mktemp -d)
trap 'rm -rf "$SCRATCH" "$AROOT"' EXIT
( cd "$SCRATCH" && git init -q )
printf 'demo-proj\nbuild it\n\n' | ( cd "$SCRATCH" && "$ROOT/target/debug/vajra" init ) >/dev/null 2>&1 || true
run_check "e2e-pub-byte-identical"   cmp -s "$SCRATCH/.ai/hooks/hook-publish-guard.sh" "$PUB"
run_check "e2e-guard-byte-identical" cmp -s "$SCRATCH/.ai/hooks/hook-session-guard.sh" "$SGUARD"
run_check "e2e-pub-wired"            grep -q "hook-publish-guard.sh" "$SCRATCH/.claude/settings.json"
run_check "e2e-guard-wired"          grep -q "hook-session-guard.sh" "$SCRATCH/.claude/settings.json"

# --- ≤3 files changed vs main (feature slice) ---
run_check "three-file-cap" bash -c \
  '[ "$(git diff --name-only main... 2>/dev/null | wc -l | tr -d " ")" -le 3 ] || \
   [ "$(git status --porcelain 2>/dev/null | wc -l | tr -d " ")" -le 3 ]'

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-40s %s\n' "STEP" "RESULT"
printf '%-40s %s\n' "----------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
