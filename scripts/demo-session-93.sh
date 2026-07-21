#!/usr/bin/env bash
# Session 93 demo — the commit gate now has teeth (no-autonomous-commit: voluntary -> ENFORCED).
# Cumulative: prior sessions' capabilities still hold; this adds the un-forgeable commit gate.
# Emits demo:header / demo:before_after / demo:cases / demo:summary_table (Demo-er gate, S71).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="93"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"; YELLOW="\033[33m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
no()     { printf "${RED}✗ %s${RESET}\n" "$1"; }

GUARD="$ROOT/scripts/hook-commit-guard.sh"

# A throwaway repo on a session branch with L3 ON (no `commit_guard: off`).
D=$(mktemp -d); mkdir -p "$D/.ai"
printf 'maturity: L2\n' > "$D/.ai/CONSTRAINTS.yaml"
( cd "$D" && git init -q && git symbolic-ref HEAD refs/heads/session-93-demo )
trap 'rm -rf "$D"' EXIT

# Fire the L3 guard against a `git commit` payload; echo its exit code.
fire() {  # <marker>
  local mk="$1" json rc
  json=$(printf '%s' 'git commit -m "feat: autonomous change"' | jq -Rs '{tool_name:"Bash",tool_input:{command:.}}')
  set +e
  VAJRA_ALLOW_COMMIT="$mk" CLAUDE_PROJECT_DIR="$D" bash "$GUARD" <<<"$json" >/dev/null 2>&1
  rc=$?; set -e; echo "$rc"
}

# --- demo:header ---
header "Session ${SESSION} Demo  [demo:header]"
label "no-autonomous-commit is now ENFORCED, fail-closed — not merely constitution-followed."

# --- demo:before_after ---
header "Before → After  [demo:before_after]"
label "BEFORE — the S76/S92 dogfood gap: the agent self-stopped at the commit gate only by CHOICE."
echo "  .githooks/pre-commit blocked main / >3 files / .ai drift — an autonomous commit on a clean"
echo "  session branch PASSED. No hook checked for approval evidence. Obedience was VOLUNTARY."
label "AFTER — an unapproved 'git commit' is BLOCKED at two layers:"
RC=$(fire "")
if [ "$RC" = 2 ]; then ok "L3 hook-commit-guard.sh → exit $RC (BLOCKED, no VAJRA_ALLOW_COMMIT)"
else no "expected block (exit 2), got $RC"; fi

# --- demo:cases ---
header "Cases  [demo:cases]"
header "1 · No approval → blocked"
RC=$(fire ""); [ "$RC" = 2 ] && ok "no marker → exit 2 (blocked)" || no "got $RC"
header "2 · Founder approval (un-forgeable env marker) → allowed"
RC=$(fire "93"); [ "$RC" = 0 ] && ok "VAJRA_ALLOW_COMMIT=93 → exit 0 (allowed)" || no "got $RC"
header "3 · Stale marker from another session → rejected (session-scoped)"
RC=$(fire "92"); [ "$RC" = 2 ] && ok "VAJRA_ALLOW_COMMIT=92 on session-93 → exit 2 (blocked)" || no "got $RC"
header "4 · Agent self-grant attempt (inline env in the command) → blocked"
json=$(printf '%s' 'VAJRA_ALLOW_COMMIT=93 git commit -m "x"' | jq -Rs '{tool_name:"Bash",tool_input:{command:.}}')
set +e; CLAUDE_PROJECT_DIR="$D" bash "$GUARD" <<<"$json" >/dev/null 2>&1; RC=$?; set -e
[ "$RC" = 2 ] && ok "inline VAJRA_ALLOW_COMMIT= never reaches the hook's env → exit 2 (blocked)" || no "got $RC"

# --- demo:summary_table ---
header "Summary  [demo:summary_table]"
printf "\n"
printf "  %-40s %s\n" "Capability" "Status"
printf "  %-40s %s\n" "----------------------------------------" "------"
printf "  %-40s %s\n" "L2 belt: pre-commit marker gate"        "ENFORCED"
printf "  %-40s %s\n" "L3 teeth: PreToolUse commit-guard"      "ENFORCED (scaffold ON)"
printf "  %-40s %s\n" "Marker un-forgeable (env, not a file)"  "YES"
printf "  %-40s %s\n" "Session-scoped (==NN)"                  "YES"
printf "  %-40s %s\n" "Fires on --no-verify"                   "YES (L3)"
printf "\n"

ok "Session ${SESSION} demo complete."
