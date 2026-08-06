#!/usr/bin/env bash
# Demo — Session 114: the fleet gets its SECOND named role, the Fidelity Reviewer.
#
# Sprint-demo contract (CONSTRAINTS.yaml#demo.required_elements): header · cases · summary_table ·
# before_after. Cumulative: it re-shows what S109/S111/S112/S113 built (govern a handoff, read it
# back, count it beside K) at the new count of TWO roles. Everything RUNS LIVE in a throwaway repo —
# nothing is replayed, no fixture is hand-placed.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="114"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}== %s ==${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}> %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}OK %s${RESET}\n" "$1"; }
no()     { printf "${RED}xx %s${RESET}\n" "$1"; }
dim()    { printf "${DIM}%s${RESET}\n" "$1"; }

VAJRA="$ROOT/target/debug/vajra"
[ -x "$VAJRA" ] || cargo build -q || { echo "build failed"; exit 1; }

PASS=0; FAIL=0
score() { if [ "$1" -eq 0 ]; then ok "$2"; PASS=$((PASS+1)); else no "$2"; FAIL=$((FAIL+1)); fi; }

# --- demo:header ---
header "Session ${SESSION} Demo — the fleet's second role: the Fidelity Reviewer  [demo:header]"
label "One line: the independent cold review this repo has run 47 times BY HAND — its brief re-typed \
from memory every session — is now a canonical, scaffolded, governed role. No new machinery: one \
more entry in the single role source, and every existing path picked it up."

TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT
( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null 2>&1 ) || { no "vajra init failed"; exit 1; }
echo "114" > "$TMP/.ai/SESSION"
mkdir -p "$TMP/prompts"
cat > "$TMP/prompts/114-task-fixture.md" <<'FIXTURE'
# Session 114 — fixture

## Acceptance
1. **WHEN** two roles have governed handoffs **THEN** the counter names both
2. **WHEN** the role key is unknown **THEN** the writer fails closed

## Design
- design-significant: no

## Plan
1. register the second role. covers: 1
2. govern its handoff. covers: 2

## Delta
- `+` the fleet's second named role
FIXTURE

strip_fleet() { grep -vE '^[[:space:]]*(⚠ )?fleet:'; }

# --- demo:before_after ---
header "Before -> After  [demo:before_after]"
label "BEFORE — the fleet had ONE role, so \`vajra init\` scaffolded one agent file and the counter \
could only ever report one handoff. AFTER — the same command, in a fresh repo, right now:"

printf "\n  ${BOLD}$ vajra init && ls .claude/agents/${RESET}  ${DIM}(S109-S113: researcher.md only)${RESET}\n"
ls -1 "$TMP/.claude/agents/" | sed 's/^/    /'
[ -f "$TMP/.claude/agents/researcher.md" ] && [ -f "$TMP/.claude/agents/fidelity-reviewer.md" ]
score $? "two roles scaffolded from ONE source — no second copy of the role text anywhere"

BEFORE="$(cd "$TMP" && "$VAJRA" next --stations 114 2>&1)"
printf "\n  ${BOLD}$ vajra next --stations 114${RESET}  ${DIM}(no fleet work yet)${RESET}\n"
echo "$BEFORE" | tail -3 | sed 's/^/  /'

printf 'ANSWER: ANTHROPIC_API_KEY is the only auth that survives a fresh no-TTY shell.\n' > "$TMP/findings.md"
cat > "$TMP/review.md" <<'REVIEW'
VERDICT: ACCEPT — 6 of 6 numbered requirements SHIPPED.
Fakest green: the fleet line counts contract-valid FILES, never dispatched agents.
NOT built: no third role, no blocking gate.
REVIEW
printf "\n  ${BOLD}$ vajra next --role researcher --from findings.md${RESET}\n"
( cd "$TMP" && "$VAJRA" next --role researcher --from findings.md 2>&1 ) | head -3 | sed 's/^/  /'
printf "\n  ${BOLD}$ vajra next --role fidelity-reviewer --from review.md${RESET}\n"
( cd "$TMP" && "$VAJRA" next --role fidelity-reviewer --from review.md 2>&1 ) | head -3 | sed 's/^/  /'

AFTER="$(cd "$TMP" && "$VAJRA" next --stations 114 2>&1)"
printf "\n  ${BOLD}$ vajra next --stations 114${RESET}  ${DIM}(same command, after)${RESET}\n"
echo "$AFTER" | tail -3 | sed 's/^/  /'
grep -q "fleet: 2 governed handoff(s)" <<<"$AFTER" && grep "fleet:" <<<"$AFTER" | grep -q "fidelity-reviewer"
score $? "TWO governed handoffs, both roles named — the count that did not exist at S113"

# --- demo:cases ---
header "Cases  [demo:cases]"

label "1. K of 8 STILL did not move — at two handoffs. AFTER minus the fleet line is byte-identical \
to BEFORE, so the S113 invariant holds at a count it was never exercised at."
diff <(echo "$BEFORE") <(strip_fleet <<<"$AFTER") | sed 's/^/    /'
[ "$(strip_fleet <<<"$AFTER")" = "$BEFORE" ] && grep -qE "^  [1-9] of 8 stations passed" <<<"$BEFORE"
score $? "K stays comparable — the fleet is reported BESIDE it, never inside it"

label "2. The name collision is RESOLVED, and the resolution has teeth: \`--role reviewer\` (the \
STATION's word) is not a role and fails closed. One word never means two things."
( cd "$TMP" && "$VAJRA" next --role reviewer --from review.md 2>&1 ) | head -2 | sed 's/^/    /'
! ( cd "$TMP" && "$VAJRA" next --role reviewer --from review.md ) >/dev/null 2>&1
score $? "the key is \`fidelity-reviewer\`; the bare station word is rejected with the known roles"

label "3. Fail-closed, exactly as slice 1: no --from, empty findings, missing file — all refused."
( cd "$TMP" && "$VAJRA" next --role fidelity-reviewer 2>&1 ) | head -1 | sed 's/^/    no --from:   /'
: > "$TMP/empty.md"
( cd "$TMP" && "$VAJRA" next --role fidelity-reviewer --from empty.md 2>&1 ) | head -1 | sed 's/^/    empty:       /'
! ( cd "$TMP" && "$VAJRA" next --role fidelity-reviewer ) >/dev/null 2>&1 \
  && ! ( cd "$TMP" && "$VAJRA" next --role fidelity-reviewer --from empty.md ) >/dev/null 2>&1 \
  && ! ( cd "$TMP" && "$VAJRA" next --role fidelity-reviewer --from nope.md ) >/dev/null 2>&1
score $? "nothing half-governed ever lands on disk"

label "4. The governed handoff is the REVIEWER's, not a copy of the Researcher's: its tracked delta \
names its own role. (Hardcoded to 'researcher' until a second role existed — the exact drift the \
one-source rule exists to kill.)"
sed -n '1,8p' "$TMP/.ai/handoffs/session-114-fidelity-reviewer.md" | sed 's/^/    /'
grep "Handoff Delta" -A 2 "$TMP/.ai/handoffs/session-114-fidelity-reviewer.md" | tail -2 | sed 's/^/    /'
grep -q "first fidelity-reviewer handoff" "$TMP/.ai/handoffs/session-114-fidelity-reviewer.md" \
  && ! grep -q "researcher handoff" "$TMP/.ai/handoffs/session-114-fidelity-reviewer.md"
score $? "delta + frontmatter carry the producing role, sourced-hashed to the exact findings"

label "5. Read-only by construction — the Reviewer gets strictly local reads. It CANNOT write the \
record of record even if asked: no Write, no Edit, no Bash."
grep -E "^(name|tools):" "$TMP/.claude/agents/fidelity-reviewer.md" | sed 's/^/    /'
grep -q "^tools: Read, Grep, Glob$" "$TMP/.claude/agents/fidelity-reviewer.md" \
  && ! grep -qE '^tools:.*(Write|Edit|Bash)' "$TMP/.claude/agents/"*.md
score $? "no new trust surface — every fleet role is still read-only"

label "6. ONE record of record. The handoff is a PRE-STAGE INPUT (the captured raw verdict, hashed \
and timestamped); sessions/session-NN-review.md stays the only artifact any gate reads. The closeout \
gate did not learn about handoffs:"
grep -c "handoffs/" scripts/verify-closeout.sh | sed 's/^/    handoff mentions in verify-closeout.sh: /'
[ "$(grep -c 'handoffs/' scripts/verify-closeout.sh)" = "0" ] \
  && grep -q "PRE-STAGE INPUT" "$TMP/.claude/agents/fidelity-reviewer.md"
score $? "no second competing verdict — the role says so in its own canonical brief"

label "7. Still 7 top-level commands — the second role rides \`init\` + \`next\`, like the first."
HELP="$("$VAJRA" --help 2>&1)"; grep -q "vajra <init|claude|check|next|estimate|hook|meter>" <<<"$HELP"
score $? "no 8th command"

label "8. The HONEST limit, restated: this demo shows two contract-valid FILES, not two agents that \
ran. And per S111, an agent file written this session is invisible to this session's dispatcher — \
the Reviewer is first dispatchable BY NAME at S115."
dim "    a handoff proves a file; only a transcript proves a dispatch (S111 evidence trail)"
true; score $? "claim stated narrowly, on purpose"

# --- demo:summary_table ---
header "Summary  [demo:summary_table]"
printf '%-54s %s\n' "CAPABILITY" "STATE"
printf '%-54s %s\n' "------------------------------------------------------" "------"
printf '%-54s %s\n' "govern a named agent's findings (S109)"              "SHIPPED"
printf '%-54s %s\n' "prove the by-name dispatch wire (S111)"              "SHIPPED"
printf '%-54s %s\n' "pipeline reads the handoff back (S112)"              "SHIPPED"
printf '%-54s %s\n' "counter reports fleet work beside K (S113)"          "SHIPPED"
printf '%-54s %s\n' "second role: the Fidelity Reviewer (S114)"           "SHIPPED"
printf '%-54s %s\n' "name collision resolved, with teeth (S114)"          "SHIPPED"
printf '%-54s %s\n' "one record of record, decided in writing (S114)"     "SHIPPED"
printf '%-54s %s\n' "per-role tool grant + role-named delta (S114)"       "SHIPPED"
printf '%-54s %s\n' "the role dispatched BY NAME"                         "NEXT SESSION (S111 limit)"
printf '%-54s %s\n' "a third role / parallel dispatch"                    "NOT BUILT (DECISION-007)"
printf '%-54s %s\n' "a gate that BLOCKS on unread findings"               "NOT BUILT (advisory by design)"

echo ""
if [ "$FAIL" -eq 0 ]; then
  printf "${GREEN}${BOLD}ALL GREEN (%d pass, 0 fail)${RESET}\n" "$PASS"; exit 0
else
  printf "${RED}${BOLD}RED (%d pass, %d fail)${RESET}\n" "$PASS" "$FAIL"; exit 1
fi
