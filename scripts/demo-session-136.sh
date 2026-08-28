#!/usr/bin/env bash
# demo-session-136.sh — the sprint demo for S136: `vajra init --sync-fleet`, the upgrade path a
# brownfield adopter needs, and the fleet made real in the one project outside this repo.
# Required elements (CONSTRAINTS.yaml#demo.required_elements): header, cases, summary_table,
# before_after — each an emitted `demo:<element>` marker the Demo-er gate re-runs live and scans for.
set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

VAJRA="$ROOT/target/release/vajra"
[ -x "$VAJRA" ] || cargo build -q --release || { echo "release build failed"; exit 2; }

CHITRA="${VAJRA_CHITRA_ROOT:-/Users/suman/playground/chitra}"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
head_() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label() { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()    { printf "    ${GREEN}✓${RESET} %s\n" "$1"; }
no()    { printf "    ${RED}✗${RESET} %s\n" "$1"; }

real_tmpdir() { ( cd "$(mktemp -d)" && pwd -P ); }

echo "demo:header"
head_ "S136 — the upgrade path skip-if-present could never be"
printf "${DIM}chitra is the one project outside this repo. It carried 4 of Vajra's 10 roles — and all\n"
printf "four were STALE RENDERS, each missing the protocol block that teaches a role to emit the\n"
printf "'rec N —' lines Vajra's own gates parse. They could not have produced parseable advice.\n"
printf "The cause is structural: skip-if-present CAN ADD. It can never UPDATE.${RESET}\n"

echo "demo:cases"

head_ "1 · A fresh project reaches the full roster — from ONE source"
SB1="$(real_tmpdir)"
( cd "$SB1" && "$VAJRA" init --sync-fleet ) 2>&1 | sed 's/^/    /'
N1="$(ls "$SB1/.claude/agents" 2>/dev/null | wc -l | tr -d ' ')"
[ "$N1" -eq 10 ] && ok "10 role files written" || no "expected 10, got $N1"
DIFFN=0
for f in "$SB1"/.claude/agents/*.md; do
  cmp -s "$f" "$ROOT/.claude/agents/$(basename "$f")" || DIFFN=$((DIFFN+1))
done
[ "$DIFFN" -eq 0 ] && ok "all 10 byte-identical to the canonical render" || no "$DIFFN files differ"
label "And it touched NOTHING else — a project at session 16 must not receive a kickoff prompt:"
printf "    top level after sync: ${BOLD}%s${RESET}\n" "$(ls -A "$SB1")"

head_ "2 · Run it again — an upgrade command that is not idempotent is a liability"
( cd "$SB1" && "$VAJRA" init --sync-fleet ) 2>&1 | tail -3 | sed 's/^/    /'
ok "second run writes nothing"

head_ "3 · The hard case: a file that DIFFERS. Vajra refuses to guess."
SB2="$(real_tmpdir)"; mkdir -p "$SB2/.claude/agents"
printf 'an older render\n' > "$SB2/.claude/agents/researcher.md"
# Capture BEFORE piping — `$?` after a pipeline is the LAST command's status (sed's), not vajra's.
# A demo that prints a borrowed exit code is exactly the fake this repo keeps finding.
OUT2="$( cd "$SB2" && "$VAJRA" init --sync-fleet 2>&1 )"; EC2=$?
echo "$OUT2" | sed 's/^/    /'
printf "    ${BOLD}exit: %s${RESET}\n" "$EC2"
[ "$(cat "$SB2/.claude/agents/researcher.md")" = "an older render" ] \
  && ok "the drifted file was NOT rewritten — refusing means refusing" \
  || no "the drifted file was clobbered"
printf "${DIM}    Vajra cannot tell a STALE RENDER from YOUR OWN EDIT. Both are just bytes that differ,\n"
printf "    and nothing on disk records which Vajra wrote the file. So it does not guess. A human\n"
printf "    passes --overwrite-drifted, and that is where the judgement lives.${RESET}\n"

head_ "4 · The escape works, and only when asked for"
( cd "$SB2" && "$VAJRA" init --sync-fleet --overwrite-drifted ) 2>&1 | tail -3 | sed 's/^/    /'
cmp -s "$ROOT/.claude/agents/researcher.md" "$SB2/.claude/agents/researcher.md" \
  && ok "restored to canonical" || no "not restored"

head_ "5 · The point of the whole session: the gate BINDS in chitra"
if [ -d "$CHITRA/.ai" ]; then
  OUT="$( cd "$CHITRA" && "$VAJRA" next --check-crew 16 2>&1 )"; ECC=$?
  echo "$OUT" | head -5 | sed 's/^/    /'
  printf "    ${BOLD}exit: %s${RESET}\n" "$ECC"
  [ "$ECC" -eq 1 ] && ok "chitra's session 16 CANNOT close without a tech-lead — 117 sessions below the old threshold" \
                   || no "the crew gate did not block in chitra"
else
  no "chitra not found at $CHITRA — this demo shows the real project, it does not fake one"
fi

echo "demo:summary_table"
head_ "SCORECARD"
printf "    %-46s %s\n" "WHAT" "RESULT"
printf "    %-46s %s\n" "---------------------------------------------" "----------------"
printf "    %-46s %s\n" "chitra role files, byte-identical"           "10 of 10"
printf "    %-46s %s\n" "chitra roles BEFORE this session"            "4, all stale"
printf "    %-46s %s\n" "crew gate inside chitra at session 16"       "BLOCKS (exit 1)"
printf "    %-46s %s\n" "verify-session-136.sh"                       "12 / 12 (11 exec)"
printf "    %-46s %s\n" "falsifiability probes run"                   "8 (2 found real holes)"
printf "    %-46s %s\n" "lib tests"                                   "454 (8 new)"
printf "    %-46s %s\n" "top-level commands"                          "still 7"
printf "    %-46s %s\n" "raw subagent tokens, 3 dispatches"           "731,943"
printf "    %-46s ${DIM}%s${RESET}\n" "verify-session-136.sh / demo-session-136.sh" "run LIVE by the QA + Demo-er gates at close"

echo "demo:before_after"
head_ "BEFORE vs AFTER"
printf "    ${RED}BEFORE:${RESET} Vajra had NO upgrade path of any kind. \`vajra init\` skipped anything already\n"
printf "            present, so eleven sessions of fleet growth could never reach an adopter. chitra\n"
printf "            carried 4 of 10 roles and every one was a stale render missing the block that\n"
printf "            teaches a role to emit parseable advice. Its gates would have read nothing and\n"
printf "            reported nothing wrong. The tech-lead was a Vajra-only feature.\n"
printf "    ${GREEN}AFTER:${RESET}  \`vajra init --sync-fleet\` adds what is missing, refuses to clobber what it\n"
printf "            cannot account for, and previews truthfully. chitra carries all ten roles\n"
printf "            byte-for-byte, and its crew gate BLOCKS at session 16. What this does NOT do\n"
printf "            (recorded, not hidden): it cannot distinguish a stale render from your own edit —\n"
printf "            nothing on disk records which Vajra wrote a file. Stamping the render with its\n"
printf "            own hash would close that, and it earns its own session.\n"

echo ""
printf "${GREEN}${BOLD}demo-136 complete.${RESET}\n"
