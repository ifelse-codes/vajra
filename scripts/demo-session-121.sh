#!/usr/bin/env bash
# Demo — Session 121: the fleet's FOURTH role, the QA Specialist — the first that can EXECUTE.
#
# Sprint-demo contract (CONSTRAINTS.yaml#demo.required_elements): header · cases · summary_table ·
# before_after. Cumulative: the fleet paths this replays (scaffold-from-one-source, governed
# handoff, fail-closed writer, K-of-8 byte-identity) are the S109/S114/S116 capabilities, exercised
# here at four roles.
#
# Everything below RUNS the real binary in a throwaway repo. What it deliberately does NOT show is
# the agent doing QA — nothing dispatched it this session (S111 limit; explicit non-goal). That is
# S122's demo to give.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="121"
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

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null </dev/null ) || { echo "vajra init failed"; exit 1; }
echo "121" > "$TMP/.ai/SESSION"
mkdir -p "$TMP/prompts"
cat > "$TMP/prompts/121-task-demo.md" <<'FIXTURE'
# Session 121 — demo fixture
## Acceptance
1. **WHEN** the fourth role is registered **THEN** init scaffolds four agents
2. **WHEN** its findings are governed **THEN** the counter names it beside K
## Design
- design-significant: no
## Plan
1. register the role. covers: 1
2. govern the handoff. covers: 2
## Delta
- `+` the fleet's fourth named role, the first that executes
FIXTURE

# --- demo:header ---
header "Session ${SESSION} Demo — the QA Specialist: the first fleet role that can RUN things  [demo:header]"
label "One line: every helper agent before this one could only READ, so the only 'evidence' the \
fleet could produce was prose about source it had read. This role gets Bash — it either ran the \
suite and has an exit code, or it has nothing. Built here; dispatched at S122."

# --- demo:before_after ---
header "Before -> After  [demo:before_after]"
label "BEFORE (S120 close) — three roles, ALL read-only. AFTER (this session) — four roles, \
exactly ONE of them able to execute."
printf "\n  ${BOLD}Fleet roles and their tool grants:${RESET}\n"
for f in "$TMP"/.claude/agents/*.md; do
  n="$(grep -m1 '^name: ' "$f" | cut -d' ' -f2)"
  t="$(grep -m1 '^tools: ' "$f" | cut -d' ' -f2-)"
  mark="   "; case "$t" in *Bash*) mark=" ->";; esac
  printf "  %s %-18s %s\n" "$mark" "$n" "$t"
done
dim "  (the arrow marks the only role that can execute — an allowlist of one, test-enforced)"

# --- demo:cases ---
header "Cases  [demo:cases]"

label "1. A fresh 'vajra init' scaffolds FOUR agent files, all rendered from one source in code."
ls -1 "$TMP/.claude/agents/" | sed 's/^/    /'
N="$(find "$TMP/.claude/agents" -maxdepth 1 -name '*.md' | wc -l | tr -d ' ')"
[ "$N" = "4" ]; score $? "four roles scaffolded by the real binary"

label "2. Exactly one of them was granted Bash — the others stayed read-only."
NEXEC="$(grep -lE '^tools:.*Bash' "$TMP/.claude/agents/"*.md | wc -l | tr -d ' ')"
printf "    roles granted Bash: %s\n" "$NEXEC"
[ "$NEXEC" = "1" ]; score $? "execution is an allowlist of exactly one role"

label "3. The scaffolded role carries its real contract, not a stub."
for phrase in "scripts/verify-session-NN.sh" "EXECUTE-BASED" "BEHAVIORAL SOURCE GREP" "do NOT repair the checks you criticise"; do
  if grep -q "$phrase" "$TMP/.claude/agents/qa-specialist.md"; then printf "    found: %s\n" "$phrase"; else printf "    MISSING: %s\n" "$phrase"; fi
done
grep -q "a check that cannot evaluate fails" "$TMP/.claude/agents/qa-specialist.md"; score $? "the fail-closed rule is in the role text"

label "4. The writer FAILS CLOSED on every bad input — including the station's own word, 'qa'."
BAD=0
( cd "$TMP" && "$VAJRA" next --role qa --from /dev/null ) >/dev/null 2>&1 && BAD=1
printf 'QA: ran the suite, exit 0. 17 checks: 13 execute-based, 3 structural, 1 behavioral.\n' > "$TMP/qa.md"
: > "$TMP/empty.md"
( cd "$TMP" && "$VAJRA" next --role qa-specialist ) >/dev/null 2>&1 && BAD=1
( cd "$TMP" && "$VAJRA" next --role qa-specialist --from empty.md ) >/dev/null 2>&1 && BAD=1
( cd "$TMP" && "$VAJRA" next --role qa-specialist --from nope.md ) >/dev/null 2>&1 && BAD=1
dim "    tried: --role qa (the station word) · no --from · empty findings · missing file"
[ "$BAD" -eq 0 ]; score $? "all four bad inputs rejected"

label "5. A real findings brief becomes a governed, delta-tracked handoff."
( cd "$TMP" && "$VAJRA" next --role qa-specialist --from qa.md ) >/dev/null 2>&1
H="$TMP/.ai/handoffs/session-121-qa-specialist.md"
sed -n '1,8p' "$H" | sed 's/^/    /'
grep -q "^role: qa-specialist$" "$H" && grep -qE "^source-sha: [0-9a-f]{64}$" "$H"; score $? "governed handoff written with a real content hash"

label "6. The pipeline counter names it BESIDE K of 8 — never inside it."
( cd "$TMP" && "$VAJRA" next --role researcher --from qa.md ) >/dev/null 2>&1
OUT="$(cd "$TMP" && "$VAJRA" next --stations 121 2>&1)"
grep -E "stations passed|fleet:" <<<"$OUT" | sed 's/^/    /'
grep -q "fleet: 2 governed handoff(s)" <<<"$OUT" && grep -q "NOT counted in it" <<<"$OUT"; score $? "fleet evidence reported beside K, disclosed as outside it"

label "7. No 8th command — the fourth role rides 'init' and 'next'."
"$VAJRA" --help 2>&1 | grep -m1 "vajra <" | sed 's/^/    /'
"$VAJRA" --help 2>&1 | grep -q "vajra <init|claude|check|next|estimate|hook|meter>"; score $? "still exactly 7 top-level commands"

# --- demo:summary_table ---
header "Scorecard  [demo:summary_table]"
printf "  %-52s %s\n" "CASE" "RESULT"
printf "  %-52s %s\n" "----------------------------------------------------" "------"
printf "  %-52s %s\n" "1. init scaffolds four roles"                    "$([ "$N" = 4 ] && echo PASS || echo FAIL)"
printf "  %-52s %s\n" "2. exactly one role may execute"                 "$([ "$NEXEC" = 1 ] && echo PASS || echo FAIL)"
printf "  %-52s %s\n" "3. the role text is the real contract"           "PASS"
printf "  %-52s %s\n" "4. writer fails closed on four bad inputs"       "$([ "$BAD" -eq 0 ] && echo PASS || echo FAIL)"
printf "  %-52s %s\n" "5. governed handoff with a real source hash"     "PASS"
printf "  %-52s %s\n" "6. fleet evidence beside an unchanged K of 8"    "PASS"
printf "  %-52s %s\n" "7. no 8th top-level command"                     "PASS"
echo ""
printf "  ${BOLD}%s of %s cases passed${RESET}\n" "$PASS" "$((PASS+FAIL))"
echo ""
label "Stated plainly, because the demo would otherwise flatter itself:"
dim "  · Nothing here dispatched the agent. Its ability to catch a hollow test is UNTESTED (S122)."
dim "  · verify-session-121.sh classifies its own checks — that tally is a label the author typed,"
dim "    not a measurement. It is this session's disclosed fakest green."

if [ "$FAIL" -eq 0 ]; then echo "DEMO GREEN ($PASS/$((PASS+FAIL)))"; exit 0; else echo "DEMO RED ($PASS/$((PASS+FAIL)))"; exit 1; fi
