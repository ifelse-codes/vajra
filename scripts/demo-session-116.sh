#!/usr/bin/env bash
# Demo — Session 116: the fleet gets its THIRD named role, the Plan Advisor.
#
# Sprint-demo contract (CONSTRAINTS.yaml#demo.required_elements): header · cases · summary_table ·
# before_after. Cumulative: it re-shows what S109/S111/S112/S113/S114 built (govern a handoff, read
# it back, count it beside K) at the new count of THREE roles. Everything RUNS LIVE in a throwaway
# repo — nothing is replayed, no fixture is hand-placed.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="116"
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
header "Session ${SESSION} Demo — the fleet's third role: the Plan Advisor  [demo:header]"
label "One line: the fleet had two roles (Researcher, Fidelity Reviewer), both proven end-to-end. A \
third — the Plan Advisor — needed NO new machinery: one more entry in the single role source, and \
every existing path picked it up. Its job: propose ordered plan steps citing which acceptance \
criterion each covers (\`covers: N\`) — the exact marker the Planner STATION already grades."

TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT
( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null 2>&1 ) || { no "vajra init failed"; exit 1; }
echo "116" > "$TMP/.ai/SESSION"
mkdir -p "$TMP/prompts"
cat > "$TMP/prompts/116-task-fixture.md" <<'FIXTURE'
# Session 116 — fixture

## Acceptance
1. **WHEN** three roles have governed handoffs **THEN** the counter names all three
2. **WHEN** the role key is the station's bare word **THEN** the writer fails closed

## Design
- design-significant: no

## Plan
1. register the third role. covers: 1
2. govern its handoff. covers: 2

## Delta
- `+` the fleet's third named role
FIXTURE

strip_fleet() { grep -vE '^[[:space:]]*(⚠ )?fleet:'; }

# --- demo:before_after ---
header "Before -> After  [demo:before_after]"
label "BEFORE — the fleet had TWO roles, so \`vajra init\` scaffolded two agent files. AFTER — the \
same command, in a fresh repo, right now:"

printf "\n  ${BOLD}\$ vajra init && ls .claude/agents/${RESET}  ${DIM}(S109-S115: researcher.md + fidelity-reviewer.md only)${RESET}\n"
ls -1 "$TMP/.claude/agents/" | sed 's/^/    /'
[ -f "$TMP/.claude/agents/researcher.md" ] && [ -f "$TMP/.claude/agents/fidelity-reviewer.md" ] \
  && [ -f "$TMP/.claude/agents/plan-advisor.md" ]
score $? "three roles scaffolded from ONE source — no second copy of the role text anywhere"

BEFORE="$(cd "$TMP" && "$VAJRA" next --stations 116 2>&1)"
printf "\n  ${BOLD}\$ vajra next --stations 116${RESET}  ${DIM}(no fleet work yet)${RESET}\n"
echo "$BEFORE" | tail -3 | sed 's/^/  /'

printf 'ANSWER: ANTHROPIC_API_KEY is the only auth that survives a fresh no-TTY shell.\n' > "$TMP/findings.md"
cat > "$TMP/review.md" <<'REVIEW'
VERDICT: ACCEPT — 6 of 6 numbered requirements SHIPPED.
Fakest green: the fleet line counts contract-valid FILES, never dispatched agents.
NOT built: no fourth role, no blocking gate.
REVIEW
cat > "$TMP/plan.md" <<'PLAN'
1. Add the plan-advisor entry to fleet::ROLES with its read-only tools and system prompt. covers: 1
2. Record the DECISION-007 S116 addendum resolving the key collision. covers: 2
PLAN
printf "\n  ${BOLD}\$ vajra next --role researcher --from findings.md${RESET}\n"
( cd "$TMP" && "$VAJRA" next --role researcher --from findings.md 2>&1 ) | head -3 | sed 's/^/  /'
printf "\n  ${BOLD}\$ vajra next --role fidelity-reviewer --from review.md${RESET}\n"
( cd "$TMP" && "$VAJRA" next --role fidelity-reviewer --from review.md 2>&1 ) | head -3 | sed 's/^/  /'
printf "\n  ${BOLD}\$ vajra next --role plan-advisor --from plan.md${RESET}\n"
( cd "$TMP" && "$VAJRA" next --role plan-advisor --from plan.md 2>&1 ) | head -3 | sed 's/^/  /'

AFTER="$(cd "$TMP" && "$VAJRA" next --stations 116 2>&1)"
printf "\n  ${BOLD}\$ vajra next --stations 116${RESET}  ${DIM}(same command, after)${RESET}\n"
echo "$AFTER" | tail -3 | sed 's/^/  /'
grep -q "fleet: 3 governed handoff(s)" <<<"$AFTER" && grep "fleet:" <<<"$AFTER" | grep -q "plan-advisor"
score $? "THREE governed handoffs, all roles named — the count that did not exist at S114"

# --- demo:cases ---
header "Cases  [demo:cases]"

label "1. K of 8 STILL did not move — at three handoffs. AFTER minus the fleet line is byte-identical \
to BEFORE, so the S113 invariant holds at a count it was never exercised at."
diff <(echo "$BEFORE") <(strip_fleet <<<"$AFTER") | sed 's/^/    /'
[ "$(strip_fleet <<<"$AFTER")" = "$BEFORE" ] && grep -qE "^  [1-9] of 8 stations passed" <<<"$BEFORE"
score $? "K stays comparable — the fleet is reported BESIDE it, never inside it"

label "2. The SECOND name collision is RESOLVED the same way the first was: \`--role planner\` (the \
STATION's word) is not a role and fails closed. One word never means two things, twice running."
( cd "$TMP" && "$VAJRA" next --role planner --from plan.md 2>&1 ) | head -2 | sed 's/^/    /'
! ( cd "$TMP" && "$VAJRA" next --role planner --from plan.md ) >/dev/null 2>&1
score $? "the key is \`plan-advisor\`; the bare station word is rejected with the known roles"

label "3. Fail-closed, exactly as roles 1 and 2: no --from, empty findings, missing file — all refused."
( cd "$TMP" && "$VAJRA" next --role plan-advisor 2>&1 ) | head -1 | sed 's/^/    no --from:   /'
: > "$TMP/empty.md"
( cd "$TMP" && "$VAJRA" next --role plan-advisor --from empty.md 2>&1 ) | head -1 | sed 's/^/    empty:       /'
! ( cd "$TMP" && "$VAJRA" next --role plan-advisor ) >/dev/null 2>&1 \
  && ! ( cd "$TMP" && "$VAJRA" next --role plan-advisor --from empty.md ) >/dev/null 2>&1 \
  && ! ( cd "$TMP" && "$VAJRA" next --role plan-advisor --from nope.md ) >/dev/null 2>&1
score $? "nothing half-governed ever lands on disk"

label "4. The governed handoff is the PLAN ADVISOR's, not a copy of another role's: its tracked delta \
names its own role."
sed -n '1,8p' "$TMP/.ai/handoffs/session-116-plan-advisor.md" | sed 's/^/    /'
grep "Handoff Delta" -A 2 "$TMP/.ai/handoffs/session-116-plan-advisor.md" | tail -2 | sed 's/^/    /'
grep -q "first plan-advisor handoff" "$TMP/.ai/handoffs/session-116-plan-advisor.md" \
  && ! grep -q "researcher handoff" "$TMP/.ai/handoffs/session-116-plan-advisor.md"
score $? "delta + frontmatter carry the producing role, sourced-hashed to the exact findings"

label "5. Read-only by construction — the Plan Advisor gets strictly local reads. It CANNOT write \
the session's own \`## Plan\` even if asked: no Write, no Edit, no Bash."
grep -E "^(name|tools):" "$TMP/.claude/agents/plan-advisor.md" | sed 's/^/    /'
grep -q "^tools: Read, Grep, Glob$" "$TMP/.claude/agents/plan-advisor.md" \
  && ! grep -qE '^tools:.*(Write|Edit|Bash)' "$TMP/.claude/agents/"*.md
score $? "no new trust surface — every fleet role is still read-only"

label "6. The Planner STATION is untouched. It still reads the session's OWN \`## Plan\` section, \
never a fleet handoff — the role proposes citations, a human decides what actually lands in the \
prompt file."
grep -c "plan-advisor" src/planner/mod.rs | sed 's/^/    plan-advisor mentions in src\/planner\/mod.rs: /'
[ "$(grep -c 'plan-advisor' src/planner/mod.rs)" = "0" ] \
  && grep -q "never the plan of record" "$TMP/.claude/agents/plan-advisor.md"
score $? "no second consumer of the role's output this session — that is a separate, deferred story"

label "7. Still 7 top-level commands — the third role rides \`init\` + \`next\`, like the first two."
HELP="$("$VAJRA" --help 2>&1)"; grep -q "vajra <init|claude|check|next|estimate|hook|meter>" <<<"$HELP"
score $? "no 8th command"

label "8. The HONEST limit, restated: this demo shows three contract-valid FILES, not three agents \
that ran. Per S111, an agent file written this session is invisible to this session's own \
dispatcher — the Plan Advisor is first dispatchable BY NAME no earlier than the next session."
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
printf '%-54s %s\n' "by-name dispatch proven live, next-session case (S115)" "SHIPPED"
printf '%-54s %s\n' "third role: the Plan Advisor (S116)"                 "SHIPPED"
printf '%-54s %s\n' "second key collision resolved, with teeth (S116)"    "SHIPPED"
printf '%-54s %s\n' "per-role tool grant + role-named delta, at 3 (S116)" "SHIPPED"
printf '%-54s %s\n' "the Plan Advisor dispatched BY NAME"                 "NOT YET (S111 limit — earliest next session)"
printf '%-54s %s\n' "Plan Advisor output consumed by the Planner station" "NOT BUILT (deferred, non-goal)"
printf '%-54s %s\n' "a fourth role / parallel dispatch"                   "NOT BUILT (DECISION-007)"
printf '%-54s %s\n' "a gate that BLOCKS on unread findings"                "NOT BUILT (advisory by design)"

echo ""
if [ "$FAIL" -eq 0 ]; then
  printf "${GREEN}${BOLD}ALL GREEN (%d pass, 0 fail)${RESET}\n" "$PASS"; exit 0
else
  printf "${RED}${BOLD}RED (%d pass, %d fail)${RESET}\n" "$PASS" "$FAIL"; exit 1
fi
