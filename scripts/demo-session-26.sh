#!/usr/bin/env bash
# Session 26 — enforce one-session-per-chat (AGENTS.md step 10). The rule was
# convention-only; now scripts/hook-session-guard.sh BLOCKS starting session N+1 in
# the same chat that closed N — live, like S21's git-commit block. Cumulative demo
# (S21 enforce · S22 propagate · S23 felt · S24 render · S26 chat boundary).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="26"
HOOK="$ROOT/scripts/hook-session-guard.sh"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
blk()    { printf "${RED}⛔ %s${RESET}\n" "$1"; }

OWN="$(mktemp)"; trap 'rm -f "$OWN"' EXIT
payload() { jq -nc --arg c "$1" --arg s "$2" '{tool_input:{command:$c}, session_id:$s}'; }
fire() { # <maturity> <cmd> <sid>  -> prints hook output, returns its exit
  payload "$2" "$3" | VAJRA_SESSION_OWNER_FILE="$OWN" VAJRA_GUARD_MATURITY="$1" bash "$HOOK"
}

header "Session ${SESSION} Demo — one vajra-session per chat, now ENFORCED"
printf "${DIM}  Hard Rule (AGENTS.md step 10): a new session starts in a NEW chat.${RESET}\n"
printf "${DIM}  Until now: words only. Now: the hook blocks the N→N+1 boundary.${RESET}\n"

header "1. chatA opens session 26 — fresh chat, allowed"
label "git checkout -b session-26-chat-guard   (session_id=chatA)"
rm -f "$OWN"
fire L2 "git checkout -b session-26-chat-guard" "chatA" >/dev/null 2>&1 \
  && ok "allowed — chatA now OWNS session 26  ($(cat "$OWN"))"

header "2. SAME chat tries to start session 27 — BLOCKED"
label "git checkout -b session-27-next   (session_id=chatA, still)"
rc=0; fire L2 "git checkout -b session-27-next" "chatA" 1>/dev/null 2>"$OWN.err" || rc=$?
sed 's/^/    /' "$OWN.err"; rm -f "$OWN.err"
[ "$rc" -eq 2 ] && blk "exit 2 — the exact goodwill-gap Vajra exists to close"

header "3. The fix the hook tells you: open a NEW chat"
label "git checkout -b session-27-next   (session_id=chatB — a fresh chat)"
fire L2 "git checkout -b session-27-next" "chatB" >/dev/null 2>&1 \
  && ok "allowed — chatB owns 27. The boundary is honored, not just hoped for."

header "4. Not a nag: only the boundary blocks"
printf "    "; fire L2 "git checkout -b feature/refactor" "chatB" >/dev/null 2>&1 \
  && ok "non-session branch — ignored"
printf "    "; fire L1 "git checkout -b session-28-x" "chatB" >/dev/null 2>&1 \
  && ok "L1 maturity — advises, never blocks (same gate as every Vajra hook)"

header "5. Why this matters (cumulative)"
printf "    ${DIM}• S21 made Varta enforce · S26 makes the session loop itself enforce.${RESET}\n"
printf "    ${DIM}• No 8th command: a PreToolUse(Bash) hook beside hook-pre-bash / copilot-loader.${RESET}\n"
printf "    ${DIM}• Signal = Claude session_id; owner record is local + gitignored; no new dep.${RESET}\n"
printf "    ${DIM}• Scaffold propagation to \`vajra init\` deferred to S27 (kept to 1 story).${RESET}\n"

header "Done"
ok "Starting the next session in this chat is now blocked — open a new one."
