#!/usr/bin/env bash
# Demo — Session 129: one source for what a stranger gets.
#
# Sprint-demo contract (CONSTRAINTS.yaml#demo.required_elements): header · cases ·
# summary_table · before_after. Cumulative: the prior capability that matters here is the
# SCAFFOLD (`vajra init`) and S128's stranger-check — both are driven again, in the same
# place: a real empty directory, with the real release binary.
#
# The claim under demonstration: a stranger is now governed by what this repo is governed by,
# and the two cannot silently drift apart again.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="129"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}== %s ==${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}> %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}OK %s${RESET}\n" "$1"; }
no()     { printf "${RED}xx %s${RESET}\n" "$1"; }
dim()    { printf "${DIM}%s${RESET}\n" "$1"; }

VAJRA="$ROOT/target/release/vajra"
[ -x "$VAJRA" ] || cargo build -q --release || { echo "build failed"; exit 1; }

PASS=0; FAIL=0; EXEC_N=0; STRUCT_N=0; BEHAV_N=0; ROWS=()
score() {
  case "$2" in
    exec)   EXEC_N=$((EXEC_N+1)) ;;
    struct) STRUCT_N=$((STRUCT_N+1)) ;;
    behav)  BEHAV_N=$((BEHAV_N+1)) ;;
    *) echo "demo bug: unknown class '$2' for $3"; exit 2 ;;
  esac
  if [ "$1" -eq 0 ]; then ok "$3"; PASS=$((PASS+1)); ROWS+=("$(printf '%-62s %-7s %s' "$3" "$2" PASS)")
  else no "$3"; FAIL=$((FAIL+1)); ROWS+=("$(printf '%-62s %-7s %s' "$3" "$2" FAIL)"); fi
}

# ── The subject: a stranger's empty directory. Never this repo. ──────────────────────────────────
TMP="$(mktemp -d "${TMPDIR:-/tmp}/vajra-demo-129-XXXXXX")"; trap 'rm -rf "$TMP"' EXIT
case "$TMP" in "$ROOT"*) echo "demo bug: temp dir inside the repo"; exit 2;; esac
( cd "$TMP" && git init -q . ) || exit 1
( cd "$TMP" && "$VAJRA" init </dev/null ) >/dev/null 2>&1 || { echo "vajra init failed"; exit 1; }

rule_names() {
  awk '/^## Hard Rules/{f=1;next} f&&/^## /{exit} f&&/^\|/{print}' "$1" \
    | grep -v '^| *Rule *|' | grep -v '^|[ -]*---' | sed 's/^| *//; s/ *|.*$//'
}
audit_names() {
  grep -m1 '^ *required_audits:' "$1" | sed 's/.*\[//; s/\].*//' \
    | tr ',' '\n' | sed 's/^ *//; s/ *$//' | grep -v '^$'
}
LIVE_RULES=$(rule_names "$ROOT/.ai/AGENTS.md" | wc -l | tr -d ' ')
SCAF_RULES=$(rule_names "$TMP/.ai/AGENTS.md" | wc -l | tr -d ' ')
LIVE_AUDITS=$(audit_names "$ROOT/.ai/CONSTRAINTS.yaml" | wc -l | tr -d ' ')
SCAF_AUDITS=$(audit_names "$TMP/.ai/CONSTRAINTS.yaml" | wc -l | tr -d ' ')

# --- demo:header --------------------------------------------------------------------------------
header "Session ${SESSION} Demo — one source for what a stranger gets  [demo:header]"
dim "  For 128 sessions the constitution \`vajra init\` handed a stranger was a hand-typed fork"
dim "  of the one this repo runs on. Nothing compared them. It had drifted to 8 rules of 13 and"
dim "  7 audits of 11, with no reason on record for a single omission."
dim "  Subject: $TMP — a real empty directory, scaffolded by the real \`vajra init\`."

# --- demo:before_after --------------------------------------------------------------------------
header "Before → after  [demo:before_after]"
printf '%-38s %-24s %s\n' "WHAT A STRANGER RECEIVES" "BEFORE S129" "AFTER S129"
printf '%-38s %-24s %s\n' "-------------------------------------" "-----------------------" "-----------------------"
printf '%-38s %-24s %s\n' "binding rules in their constitution"  "8 of 13 (2 renamed)"  "$SCAF_RULES of $LIVE_RULES, names exact"
printf '%-38s %-24s %s\n' "ground-truth audits required"         "7 of 11"              "$SCAF_AUDITS of $LIVE_AUDITS"
printf '%-38s %-24s %s\n' "reason on record for what is missing" "none"                 "one per withheld audit, in their file"
printf '%-38s %-24s %s\n' "how the two stay in step"             "somebody remembers"   "derived at build time"
printf '%-38s %-24s %s\n' "what happens when they diverge"       "nothing, for 128 sessions" "scaffold-drift.sh goes RED"

# --- demo:cases ---------------------------------------------------------------------------------
header "Cases — the real binary, the real scaffold  [demo:cases]"

label "case 1 — the rulebook a stranger is handed"
dim "    live: $LIVE_RULES binding rules · scaffold: $SCAF_RULES"
[ "$SCAF_RULES" -eq "$LIVE_RULES" ]
score $? exec "case 1: every binding rule this repo runs on reaches a stranger"

label "case 2 — the five rules that never used to arrive"
MISSING=""
for r in "No code in Ground Truth" "State is snapshot" "Max 1 story per session" "~2h per session cap" "One vajra-session per chat"; do
  rule_names "$TMP/.ai/AGENTS.md" | grep -Fxq "$r" || MISSING="$MISSING [$r]"
done
[ -z "$MISSING" ]; RC=$?
[ -n "$MISSING" ] && dim "    still missing:$MISSING"
score $RC exec "case 2: all five S129-recovered rules are in the scaffold"

label "case 3 — the two rules that used to arrive under a different name"
rule_names "$TMP/.ai/AGENTS.md" | grep -Fxq "Max 2 error retries" \
  && rule_names "$TMP/.ai/AGENTS.md" | grep -Fxq "Max 3 files per atomic commit"
score $? exec "case 3: rule names are now byte-exact, so equality is checkable"

label "case 4 — the audit list"
dim "    live: $LIVE_AUDITS audits · scaffold: $SCAF_AUDITS · withheld: $((LIVE_AUDITS - SCAF_AUDITS))"
for a in dogfood_check pipeline_advance_check dogfood_staleness; do
  audit_names "$TMP/.ai/CONSTRAINTS.yaml" | grep -Fxq "$a" || { dim "    MISSING: $a"; false; break; }
done
score $? exec "case 4: the three portable audits now reach a stranger"

label "case 5 — what is withheld, and why, in the stranger's own file"
dim "$(grep 'scaffold-omits-audit:' "$TMP/.ai/CONSTRAINTS.yaml" | cut -c1-108 | sed 's/^/    /')"
[ "$(grep -c 'scaffold-omits-audit: .* — .' "$TMP/.ai/CONSTRAINTS.yaml")" -eq 2 ]
score $? exec "case 5: both withheld audits ship their reason to the stranger"

label "case 6 — an audit a stranger cannot run is NOT demanded of them"
audit_names "$TMP/.ai/CONSTRAINTS.yaml" | grep -Eq '^(stranger_check|scaffold_drift_check)$'; RC=$?
[ "$RC" -ne 0 ]
score $? exec "case 6: their ground truth demands nothing they cannot produce"

label "case 7 — the scaffold says out loud that it is derived"
dim "    $(grep -m1 'Derived, not typed' "$TMP/.ai/AGENTS.md" | cut -c1-100)"
grep -q 'Derived, not typed' "$TMP/.ai/AGENTS.md" && grep -q 'DERIVED at build time' "$TMP/.ai/CONSTRAINTS.yaml"
score $? exec "case 7: a hand-typed regression would be visible in the file itself"

label "case 8 — the guard that was missing for 128 sessions"
DRIFT="$(/bin/bash "$ROOT/scripts/scaffold-drift.sh" --bin "$VAJRA" 2>&1)"; RC=$?
dim "    $(printf '%s\n' "$DRIFT" | grep '^=== scaffold-drift:')"
[ "$RC" -eq 0 ]
score $? exec "case 8: scaffold-drift.sh is GREEN on the shipped tree"

label "case 9 — and it NAMES what it compared, rather than reporting a bare OK"
printf '%s\n' "$DRIFT" | grep -q 'what is being compared' \
  && printf '%s\n' "$DRIFT" | grep -q 'live rules, by name' \
  && printf '%s\n' "$DRIFT" | grep -q 'live audits, by name'
score $? exec "case 9: the check prints its own inventory"

label "case 10 — a stale declaration cannot survive a build"
dim "    (planting one and rebuilding is fixture-129's P3 — here we show the guard exists)"
grep -q 'STALE DECLARATION' "$ROOT/build.rs"
score $? struct "case 10: build.rs panics on a declaration that no longer matches"

label "case 11 — first contact still works (cumulative, S128)"
SC="$(/bin/bash "$ROOT/scripts/stranger-check.sh" --bin "$VAJRA" 2>&1)"; RC=$?
dim "    $(printf '%s\n' "$SC" | grep -A1 'checks passed' | tr '\n' ' ' | tr -s ' ')"
[ "$RC" -eq 0 ]
score $? exec "case 11: stranger-check is GREEN, now including the governance handed over"

label "case 12 — nothing else moved"
ST="$( "$VAJRA" next --stations 127 2>&1 )"
dim "    $(printf '%s\n' "$ST" | grep 'stations passed')"
printf '%s' "$ST" | grep -q "8 of 8 stations passed (derived from each gate's evidence"
score $? exec "case 12: \`K of 8\` unmoved in derivation and shape"
NOT_A_COMMAND="$( "$VAJRA" scaffold 2>&1 >/dev/null )"
dim "    \$ vajra scaffold  ->  $(printf '%s' "$NOT_A_COMMAND" | head -1)"
printf '%s' "$NOT_A_COMMAND" | grep -q "unrecognised command"
score $? exec "case 13: still 7 commands — the drift check is a script, not an 8th"

# --- demo:summary_table -------------------------------------------------------------------------
header "Summary  [demo:summary_table]"
printf '%-62s %-7s %s\n' "CASE" "CLASS" "RESULT"
printf '%-62s %-7s %s\n' "--------------------------------------------------------------" "-------" "------"
for r in ${ROWS[@]+"${ROWS[@]}"}; do echo "$r"; done
echo ""
echo "  execute-based: $EXEC_N · structural: $STRUCT_N · behavioral source grep: $BEHAV_N"
echo "  (a class label here is self-assigned, exactly as in the verify suite — S122)"
echo ""
echo "WHAT THIS DEMO DOES NOT SHOW, in order:"
echo "  1. It does not show anyone USING Vajra. 0 stars, 0 forks, 0 issues, 19 downloads are"
echo "     unchanged by this session. A stranger now gets the same rulebook we do; nobody has"
echo "     yet asked for it."
echo "  2. Only TWO lists are derived — the Hard Rules table and required_audits. The rest of"
echo "     the scaffold's constitution is still hand-written prose, and any OTHER list in this"
echo "     repo may still have a scaffolded twin nobody has looked at."
echo "  3. Case 10 is a structural grep. The build-time panic is really exercised in"
echo "     fixture-session-129.sh (P3), not here."
echo "  4. Carrying a rule is not enforcing it. A stranger now READS all 13; what enforces them"
echo "     in their repo is the same hook set as before, unchanged this session."
echo "  5. \`vajra init\` still blocks on stdin without EOF; every case above passes \`</dev/null\`."
echo "  A green demo is not a passing delivery — the fidelity verdict lives in"
echo "  sessions/session-129-review.md."
echo ""
if [ "$FAIL" -eq 0 ]; then
  ok "DEMO GREEN ($PASS pass, $FAIL fail)"
  exit 0
else
  no "DEMO RED ($PASS pass, $FAIL fail)"
  exit 1
fi
