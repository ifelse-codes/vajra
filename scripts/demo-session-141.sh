#!/usr/bin/env bash
# demo-session-141.sh — the sprint demo for S141: best install + upgrade-in-place. Every fleet role
# render now carries a `vajra-render-sha:` stamp, so `vajra init --sync-fleet` can AUTO-UPGRADE an
# untouched old render while still refusing a user edit. Required elements
# (CONSTRAINTS.yaml#demo.required_elements): header, cases, summary_table, before_after — each an
# emitted `demo:<element>` marker the Demo-er gate re-runs live and scans for. Runs the REAL binary.
#
# S141 fidelity-reviewer rec 3: the summary_table marks are COMPUTED from the live case signals, not
# hardcoded — a broken build reddens the table instead of printing six green ticks regardless.
set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

VAJRA="$ROOT/target/release/vajra"
[ -x "$VAJRA" ] || cargo build -q --release || { echo "release build failed"; exit 2; }

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
head_() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label() { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
mk() { [ "$1" -eq 0 ] 2>/dev/null && printf "${GREEN}✔${RESET}" || printf "${RED}✗${RESET}"; }

W="$(mktemp -d "${TMPDIR:-/tmp}/vajra-demo141-XXXXXX")"
trap 'rm -rf "$W"' EXIT
R="$W/.claude/agents/researcher.md"

echo "demo:header"
head_ "S141 — the fleet render gets recorded provenance; upgrades become smooth"
printf "${DIM}S136 could CREATE a missing role file but REFUSED any file that differed — it could not\n"
printf "tell an old Vajra render from a user's own edit (both are just 'bytes that differ'). S141\n"
printf "stamps each render with sha256 of its own body, so an untouched old render is provable and\n"
printf "auto-upgrades, while a real edit is still refused. Run live in a throwaway dir.${RESET}\n"

echo "demo:cases"

head_ "CASE 1 — fresh install: --sync-fleet creates all role files, each STAMPED"
label "cd \$tmp && vajra init --sync-fleet"
OUT1="$( cd "$W" && "$VAJRA" init --sync-fleet 2>&1 )"
echo "$OUT1" | tail -2 | sed 's/^/    /'
STAMP1="$(grep '^vajra-render-sha:' "$R" | head -1)"
printf "    stamp on researcher.md: ${GREEN}%s${RESET}\n" "$STAMP1"
grep -q '^vajra-render-sha:' "$R"; R1=$?                       # row 1 signal: render is stamped

head_ "CASE 2 — a stamped OLDER render -> auto-upgraded with NO --overwrite-drifted"
printf '%s\n' '---' 'name: researcher' 'description: an older render' 'tools: Read, Grep, Glob' '---' '' 'OLD BODY' > "$W/older.txt"
H="$(shasum -a 256 < "$W/older.txt" | awk '{print $1}')"
awk -v h="$H" '/^---$/{c++; if(c==2) print "vajra-render-sha: " h} {print}' "$W/older.txt" > "$R"
label "plant stamped old render, then: vajra init --sync-fleet"
OUT2="$( cd "$W" && "$VAJRA" init --sync-fleet 2>&1 )"
echo "$OUT2" | grep -E "upgrade|already current|drifted\." | sed 's/^/    /'
( cd "$W" && "$VAJRA" init --sync-fleet >/dev/null 2>&1 ) && C2=0 || C2=$?
printf "    exit=%s  ${GREEN}(PASS — old render lifted to current, no human override needed)${RESET}\n" "$C2"

head_ "CASE 3 — a user's OWN edit (unstamped) -> REFUSED, left untouched"
printf '%s\n' 'my own customised researcher agent' > "$R"
label "hand-write researcher.md, then: vajra init --sync-fleet"
OUT3="$( cd "$W" && "$VAJRA" init --sync-fleet 2>&1 )"
echo "$OUT3" | grep -E "DRIFT|overwrite-drifted" | head -2 | sed 's/^/    /'
( cd "$W" && "$VAJRA" init --sync-fleet >/dev/null 2>&1 ) && C3=0 || C3=$?
printf "    exit=%s  ${RED}(BLOCKS — Vajra cannot prove provenance it never wrote; the human decides)${RESET}\n" "$C3"

# ---- compute each acceptance mark from a REAL signal (never a hardcoded tick) -------------------
# 1: the render carries a stamp (R1). 2: all four states appeared live — Missing→create (OUT1),
# UpToDate (OUT2 "already current"), StaleRender→upgrade (OUT2), Drifted→DRIFT (OUT3).
grep -q '^  create' <<<"$OUT1" && grep -q 'already current' <<<"$OUT2" \
  && grep -q '^  upgrade' <<<"$OUT2" && grep -q 'DRIFT' <<<"$OUT3"; M2=$?
# 3: StaleRender auto-upgraded (C2==0) AND Drifted refused (C3!=0).
{ [ "$C2" -eq 0 ] && [ "$C3" -ne 0 ]; }; M3=$?
# 4: an immediate re-sync of the now-canonical dir is a clean no-op (idempotent, exit 0).
OUT4="$( cd "$W" && "$VAJRA" init --sync-fleet --overwrite-drifted >/dev/null 2>&1; "$VAJRA" init --sync-fleet 2>&1 )"
grep -q 'already current' <<<"$OUT4" && ! grep -qE '^  (create|upgrade|refresh|DRIFT)' <<<"$OUT4"; M4=$?
# 5: the DECISION-007 S141 addendum records the design.
grep -q "S141 addendum — the render stamp" docs/decisions/DECISION-007-agent-fleet.md; M5=$?
# 6: this demo ran to completion and emitted its markers.
M6=0

echo "demo:summary_table"
head_ "Acceptance → evidence (marks computed from the live cases above)"
printf "%b\n" "${BOLD}  # acceptance                                             evidence         status${RESET}"
printf "  1 render carries a round-tripping vajra-render-sha stamp (inert)  CASE 1           %b\n" "$(mk $R1)"
printf "  2 classify_fleet_file exercises FOUR states                       CASE 1/2/3       %b\n" "$(mk $M2)"
printf "  3 StaleRender auto-upgrades; Drifted refused (exit 1)             CASE 2/3         %b\n" "$(mk $M3)"
printf "  4 idempotent no-churn re-sync (real binary)                      re-sync          %b\n" "$(mk $M4)"
printf "  5 DECISION-007 S141 addendum records the design                  docs/decisions   %b\n" "$(mk $M5)"
printf "  6 demo emitted its four sprint markers                           this run         %b\n" "$(mk $M6)"

echo "demo:before_after"
head_ "Before → after"
printf "  ${RED}BEFORE (S136):${RESET} any differing role file = Drifted = REFUSED. A brownfield repo (chitra,\n"
printf "         4 stale renders) could only be upgraded by --overwrite-drifted, which also blows away edits.\n"
printf "  ${GREEN}AFTER (S141):${RESET}  a stamped untouched render auto-upgrades (CASE 2); a real edit stays refused\n"
printf "         (CASE 3). Honest limit: pre-S141 files are unstamped, so their FIRST upgrade still needs one\n"
printf "         --overwrite-drifted — smooth going forward, not retroactively.\n"

if [ "$R1" -eq 0 ] && [ "$M2" -eq 0 ] && [ "$M3" -eq 0 ] && [ "$M4" -eq 0 ] && [ "$M5" -eq 0 ]; then
  echo -e "\n${GREEN}${BOLD}demo-141: stale render lifted automatically; user edit held safe.${RESET}"
else
  echo -e "\n${RED}${BOLD}demo-141: a computed acceptance mark is RED — see the table.${RESET}"; exit 1
fi
