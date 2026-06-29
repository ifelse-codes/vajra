#!/usr/bin/env bash
# Session 26 — enforce one-session-per-chat (AGENTS.md step 10). The hook
# scripts/hook-session-guard.sh blocks `git checkout -b session-(N+1)-*` when the
# SAME Claude session_id (chat) already owns session N. Proven against the real
# boundary, the allowed cross-chat path, the maturity gate, and the enable flag.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="26"
HOOK="$ROOT/scripts/hook-session-guard.sh"

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

# Drive the hook with a synthetic owner file so no real chat is needed.
OWN="$ARTIFACTS/owner"
payload() { jq -nc --arg c "$1" --arg s "$2" '{tool_input:{command:$c}, session_id:$s}'; }
# run <expected_exit> <maturity> <cmd> <sid>
run() {
  local want="$1" mat="$2" cmd="$3" sid="$4" rc=0
  payload "$cmd" "$sid" | VAJRA_SESSION_OWNER_FILE="$OWN" VAJRA_GUARD_MATURITY="$mat" \
    bash "$HOOK" >/dev/null 2>&1 || rc=$?
  [ "$rc" -eq "$want" ]
}

# --- Rust gates (no source change, but keep the bar) ---
run_check "cargo-fmt"        cargo fmt -- --check
run_check "cargo-clippy"     cargo clippy --all-targets -- -D warnings
run_check "cargo-test"       cargo test
run_check "shellcheck"       bash -n "$HOOK"

# --- Wiring: hook is registered on PreToolUse(Bash) and owner file is gitignored ---
run_check "wired-in-settings" grep -qF "hook-session-guard.sh" "$ROOT/.claude/settings.json"
run_check "owner-gitignored"  grep -qxF ".ai/.session-owner" "$ROOT/.gitignore"

# --- Behavior: the L2 boundary block (the headline) ---
seed_owner_26() { printf '26\tchatA\n' > "$OWN"; }

# fresh chat, no record -> allow + claims ownership
fresh_allows() { rm -f "$OWN"; run 0 L2 "git checkout -b session-26-chat-guard" "chatA" \
                 && grep -q "^26	chatA$" "$OWN"; }
run_check "fresh-chat-allows"     fresh_allows

# SAME chat crossing 26->27 -> BLOCK (exit 2)  [the rule]
same_chat_blocks() { seed_owner_26; run 2 L2 "git checkout -b session-27-foo" "chatA"; }
run_check "same-chat-blocks"      same_chat_blocks

# NEW chat starting 27 -> allowed (cross-chat path is the correct one)
new_chat_allows() { seed_owner_26; run 0 L2 "git checkout -b session-27-foo" "chatB"; }
run_check "new-chat-allows"       new_chat_allows

# same session re-checkout (same NN, same chat) -> not a boundary -> allow
same_session_reok() { seed_owner_26; run 0 L2 "git checkout -b session-26-other" "chatA"; }
run_check "same-session-reallowed" same_session_reok

# non-session branch -> ignored
nonsession_ignored() { seed_owner_26; run 0 L2 "git checkout -b feature/x" "chatA"; }
run_check "nonsession-ignored"    nonsession_ignored

# --- Maturity gate: L1 advises (exit 0) on the very boundary L2 blocks ---
l1_advises() { seed_owner_26; run 0 L1 "git checkout -b session-27-foo" "chatA"; }
run_check "l1-advises-not-blocks" l1_advises

# --- Enable flag: with one_session_per_chat:false the hook is a no-op ---
flag_off_noop() {
  local tmp; tmp="$ARTIFACTS/constraints-off.yaml"
  sed 's/one_session_per_chat: true/one_session_per_chat: false/' "$ROOT/.ai/CONSTRAINTS.yaml" > "$tmp"
  seed_owner_26
  local rc=0
  payload "git checkout -b session-27-foo" "chatA" \
    | VAJRA_SESSION_OWNER_FILE="$OWN" CLAUDE_PROJECT_DIR="$ARTIFACTS/root" bash -c '
        mkdir -p "$CLAUDE_PROJECT_DIR/.ai"; cp "'"$tmp"'" "$CLAUDE_PROJECT_DIR/.ai/CONSTRAINTS.yaml";
        exec bash "'"$HOOK"'"' >/dev/null 2>&1 || rc=$?
  [ "$rc" -eq 0 ]
}
run_check "flag-off-is-noop"      flag_off_noop

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-34s %s\n' "STEP" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
