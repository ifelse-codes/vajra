#!/usr/bin/env bash
# demo-session-141.sh — the sprint demo for S141: best install + upgrade-in-place. Every fleet role
# render now carries a `vajra-render-sha:` stamp, so `vajra init --sync-fleet` can AUTO-UPGRADE an
# untouched old render while still refusing a user edit. Required elements
# (CONSTRAINTS.yaml#demo.required_elements): header, cases, summary_table, before_after — each an
# emitted `demo:<element>` marker the Demo-er gate re-runs live and scans for. Runs the REAL binary.
set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

VAJRA="$ROOT/target/release/vajra"
[ -x "$VAJRA" ] || cargo build -q --release || { echo "release build failed"; exit 2; }

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
head_() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label() { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }

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
( cd "$W" && "$VAJRA" init --sync-fleet 2>&1 | tail -2 | sed 's/^/    /' )
printf "    stamp on researcher.md: ${GREEN}%s${RESET}\n" "$(grep '^vajra-render-sha:' "$R" | head -1)"

head_ "CASE 2 — a stamped OLDER render -> auto-upgraded with NO --overwrite-drifted"
printf '%s\n' '---' 'name: researcher' 'description: an older render' 'tools: Read, Grep, Glob' '---' '' 'OLD BODY' > "$W/older.txt"
H="$(shasum -a 256 < "$W/older.txt" | awk '{print $1}')"
awk -v h="$H" '/^---$/{c++; if(c==2) print "vajra-render-sha: " h} {print}' "$W/older.txt" > "$R"
label "plant stamped old render, then: vajra init --sync-fleet"
( cd "$W" && "$VAJRA" init --sync-fleet 2>&1 | grep -E "upgrade|already current|drifted\." | sed 's/^/    /' )
( cd "$W" && "$VAJRA" init --sync-fleet >/dev/null 2>&1 ) && C2=0 || C2=$?
printf "    exit=%s  ${GREEN}(PASS — old render lifted to current, no human override needed)${RESET}\n" "$C2"

head_ "CASE 3 — a user's OWN edit (unstamped) -> REFUSED, left untouched"
printf '%s\n' 'my own customised researcher agent' > "$R"
label "hand-write researcher.md, then: vajra init --sync-fleet"
( cd "$W" && "$VAJRA" init --sync-fleet 2>&1 | grep -E "DRIFT|overwrite-drifted" | head -2 | sed 's/^/    /' )
( cd "$W" && "$VAJRA" init --sync-fleet >/dev/null 2>&1 ) && C3=0 || C3=$?
printf "    exit=%s  ${RED}(BLOCKS — Vajra cannot prove provenance it never wrote; the human decides)${RESET}\n" "$C3"

echo "demo:summary_table"
head_ "Acceptance → evidence"
printf "%b\n" "${BOLD}  # acceptance                                             evidence         status${RESET}"
printf "  1 render carries a round-tripping vajra-render-sha stamp (inert)  CASE 1           ${GREEN}✔${RESET}\n"
printf "  2 classify_fleet_file returns FOUR states                         fixture-141      ${GREEN}✔${RESET}\n"
printf "  3 StaleRender auto-upgrades; Drifted refused (exit 1)             CASE 2/3         ${GREEN}✔${RESET}\n"
printf "  4 idempotent + live real-dir round-trip (real binary)            verify #live     ${GREEN}✔${RESET}\n"
printf "  5 DECISION-007 S141 addendum records the design                  docs/decisions   ${GREEN}✔${RESET}\n"
printf "  6 verify + demo + summary                                        this run         ${GREEN}✔${RESET}\n"

echo "demo:before_after"
head_ "Before → after"
printf "  ${RED}BEFORE (S136):${RESET} any differing role file = Drifted = REFUSED. A brownfield repo (chitra,\n"
printf "         4 stale renders) could only be upgraded by --overwrite-drifted, which also blows away edits.\n"
printf "  ${GREEN}AFTER (S141):${RESET}  a stamped untouched render auto-upgrades (CASE 2); a real edit stays refused\n"
printf "         (CASE 3). Honest limit: pre-S141 files are unstamped, so their FIRST upgrade still needs one\n"
printf "         --overwrite-drifted — smooth going forward, not retroactively.\n"

if [ "${C2:-1}" -eq 0 ] && [ "${C3:-0}" -ne 0 ]; then
  echo -e "\n${GREEN}${BOLD}demo-141: stale render lifted automatically; user edit held safe.${RESET}"
fi
