#!/usr/bin/env bash
# Demo — Session 122: the guardrails got audited, and four of them did not survive it.
#
# Sprint-demo contract (CONSTRAINTS.yaml#demo.required_elements): header · cases · summary_table ·
# before_after. Cumulative: it replays the S109/S114/S116/S121 fleet capabilities (scaffold from one
# source, per-role tool grants, governed handoff) and then shows what S122 changed about the checks
# that police them.
#
# Everything below RUNS the real binary or the real check functions in a throwaway repo. Where a
# claim cannot be shown running, it is not made.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="122"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}== %s ==${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}> %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}OK %s${RESET}\n" "$1"; }
no()     { printf "${RED}xx %s${RESET}\n" "$1"; }
dim()    { printf "${DIM}%s${RESET}\n" "$1"; }

VAJRA="$ROOT/target/debug/vajra"
[ -x "$VAJRA" ] || cargo build -q || { echo "build failed"; exit 1; }

# Every case carries a CLASS, in the same vocabulary the verify suites use, and the demo prints its
# own tally at the end. Plan step 5 asked for it; the first cut of this file shipped without it
# (cold review, S122 pass 3). Same caveat as everywhere else: the label is still typed by the
# author, so it says what a case DOES, not what has been proven about it.
PASS=0; FAIL=0; EXEC_N=0; STRUCT_N=0; BEHAV_N=0; ROWS=()
# $1 = exit status, $2 = class (exec|struct|behav), $3 = the case name.
score() {
  case "$2" in
    exec)   EXEC_N=$((EXEC_N+1)) ;;
    struct) STRUCT_N=$((STRUCT_N+1)) ;;
    behav)  BEHAV_N=$((BEHAV_N+1)) ;;
    *) echo "demo bug: unknown class '$2' for $3"; exit 2 ;;
  esac
  if [ "$1" -eq 0 ]; then ok "$3"; PASS=$((PASS+1)); ROWS+=("$(printf '%-54s %-7s %s' "$3" "$2" PASS)")
  else no "$3"; FAIL=$((FAIL+1)); ROWS+=("$(printf '%-54s %-7s %s' "$3" "$2" FAIL)"); fi
}

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
# `vajra init` blocks forever on stdin without EOF (S121, 10 minutes lost) — always </dev/null.
( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null </dev/null ) || { echo "vajra init failed"; exit 1; }

# --- demo:header ---
header "Session ${SESSION} Demo — the checks got checked  [demo:header]"
label "One line: S121 shipped a 17/17-green suite and a cold review that said ACCEPT. Then the QA \
role it had just built was pointed at that suite and found FOUR defects in the guardrails \
themselves. S122 closes all four — and every fix had to be SEEN RED before it counted."
dim "  The lesson, stated plainly: a check that has never failed is not evidence."

# --- demo:before_after ---
header "Before -> After  [demo:before_after]"

label "1. The read-only guard. BEFORE: a PREFIX grep. AFTER: whole-token comparison."
printf -- '---\nname: fidelity-reviewer\ndescription: d\ntools: Read, Grep, Glob, Write\n---\n' > "$TMP/leak.md"
printf "\n  the agent file under test (a role that leaked a Write grant):\n"
grep '^tools:' "$TMP/leak.md" | sed 's/^/      /'
printf "\n  ${BOLD}BEFORE${RESET}  grep -q \"^tools: Read, Grep, Glob\"   -> "
if grep -q "^tools: Read, Grep, Glob" "$TMP/leak.md"; then printf "${RED}PASSES the leak${RESET}\n"; else printf "rejects\n"; fi
TOKENS="$(sed -n 's/^tools: //p' "$TMP/leak.md" | tr ',' '\n' | sed 's/ //g')"
printf "  ${BOLD}AFTER${RESET}   whole-token comparison             -> "
if grep -qx 'Write' <<<"$TOKENS"; then printf "${GREEN}REJECTS the leak (token 'Write' found)${RESET}\n"; else printf "passes\n"; fi
grep -q "^tools: Read, Grep, Glob" "$TMP/leak.md" && grep -qx 'Write' <<<"$TOKENS"
score $? exec "the old grep passed it; the new guard rejects it"

label "2. The check-class tally. BEFORE: one line implying a complete count. AFTER: nesting named."
# THE REAL FUNCTION, lifted out of the suite and executed — not four hand-typed lines imitating it.
# The first cut of this case printed a retyped copy of the tally and scored it with a literal
# `true`, so the demo's proof that the tally is honest could not fail. That is a hollow green
# demonstrating the fix for hollowness (cold review, S122 pass 3).
eval "$(sed -n '/^print_tally() {/,/^}/p' scripts/verify-session-122.sh)"
OLD_TALLY="CHECK CLASSES — execute-based: 13 · structural grep: 3 · behavioral source grep: 1"
NEW_TALLY="$(print_tally 16 2 1 3 "s121-suite-green" "fleet-smoke" "s113-counter-still-green")"
printf "\n  ${BOLD}BEFORE${RESET} (S121 — and two of those slots were whole suites of 14 and 7 checks):\n"
dim "    $OLD_TALLY"
printf "\n  ${BOLD}AFTER${RESET} (the real print_tally from verify-session-122.sh, executed right here):\n"
sed 's/^/    /' <<<"$NEW_TALLY" | while IFS= read -r l; do dim "$l"; done
TALLY_OK=0
grep -q "NOT a census of everything that ran" <<<"$NEW_TALLY" || TALLY_OK=1
grep -q "s113-counter-still-green" <<<"$NEW_TALLY" || TALLY_OK=1
grep -q "is a FLOOR" <<<"$NEW_TALLY" || TALLY_OK=1
grep -q "NOT a census" <<<"$OLD_TALLY" && TALLY_OK=1     # the old line must NOT qualify
[ "$TALLY_OK" -eq 0 ]; score $? exec "the real tally names what it hides; the old line does not"

# --- demo:cases ---
header "Cases  [demo:cases]"

label "1. The fleet still scaffolds from ONE source — four roles, real binary, throwaway repo."
ls -1 "$TMP/.claude/agents/" | sed 's/^/    /'
N="$(find "$TMP/.claude/agents" -maxdepth 1 -name '*.md' | wc -l | tr -d ' ')"
[ "$N" = "4" ]; score $? exec "four roles scaffolded"

label "2. Exactly one role may execute — and now the check that says so cannot be fooled."
for f in "$TMP"/.claude/agents/*.md; do
  n="$(sed -n 's/^name: //p' "$f" | head -1)"; t="$(sed -n 's/^tools: //p' "$f" | head -1)"
  mark="   "; case " $(tr ',' ' ' <<<"$t") " in *" Bash "*) mark=" ->";; esac
  printf "  %s %-18s %s\n" "$mark" "$n" "$t"
done
NEXEC="$(grep -lE '^tools:.*Bash' "$TMP/.claude/agents/"*.md | wc -l | tr -d ' ')"
[ "$NEXEC" = "1" ]; score $? exec "execution is an allowlist of exactly one role"

label "3. The forbidden-tool list is ONE set across all three places it is written."
RUST="$(grep -o 'for forbidden in \[[^]]*\]' src/fleet/mod.rs | head -1 | tr -d '[]"' | sed 's/for forbidden in //' | tr ',' '\n' | tr -d ' ' | grep . | sort | tr '\n' ' ')"
SH1="$(grep -m1 '^FORBIDDEN_TOOLS=' scripts/verify-session-121.sh | cut -d'"' -f2 | tr ' ' '\n' | grep . | sort | tr '\n' ' ')"
SH2="$(grep -m1 '^FORBIDDEN=' scripts/verify-session-122.sh | cut -d'"' -f2 | tr ' ' '\n' | grep . | sort | tr '\n' ' ')"
printf "    src/fleet/mod.rs      : %s\n    verify-session-121.sh : %s\n    verify-session-122.sh : %s\n" "$RUST" "$SH1" "$SH2"
dim "    (the QA role found these HAD drifted — 'Task' was missing from the Rust list, so a role"
dim "     granted execution-by-proxy passed the unit test and was rejected by both scripts)"
[ "$RUST" = "$SH1" ] && [ "$RUST" = "$SH2" ]; score $? struct "one policy, three copies, no drift"

label "4. The booby-trap is LIVE in this repo — and the suite is green with it armed."
# DELIBERATELY A FRAGMENT, never the whole probe sentence. The cold review caught the first cut
# of this script hardcoding the full sentence — which made THIS FILE a second hand-maintained
# carrier of the role text and turned verify-session-121.sh's one-source check RED. That is the
# S121 booby-trap reborn a second time inside the session that was fixing it. Widening the check's
# exclusion list to cover demo scripts would have been the wrong repair: the exclusion list is the
# hole. The right repair is for this file not to carry the sentence at all.
FRAGMENT="destroys the independence"
H=".ai/handoffs/session-122-qa-specialist.md"
if [ -f "$H" ] && grep -q "$FRAGMENT" "$H"; then
  grep -n "$FRAGMENT" "$H" | head -1 | cut -c1-96 | sed 's/^/    /'
  dim "    a real governed handoff, written by the binary, quoting the exact sentence that used to"
  dim "    turn the whole suite red"
  true
else false; fi
score $? exec "a governed handoff quotes the probe sentence and nothing breaks"

label "5. The render test can now fail. An empty role prompt is rejected."
cargo test --lib fleet::tests::render_test_cannot_pass_on_an_empty_system_prompt 2>&1 | grep -E '^test |test result' | sed 's/^/    /'
cargo test --lib fleet::tests::every_role_renders_substantive_content_unique_to_its_own_contract 2>&1 | grep -E 'test result' | sed 's/^/    /'
cargo test --lib fleet::tests::render_test_cannot_pass_on_an_empty_system_prompt 2>&1 | grep -q 'test result: ok. 1 passed'
score $? exec "the tautology is gone and its replacement is falsifiable"

label "6. The governed-handoff path is unchanged — it still fails closed."
echo "122" > "$TMP/.ai/SESSION"; : > "$TMP/empty.md"
BAD=0
( cd "$TMP" && "$VAJRA" next --role qa --from empty.md ) >/dev/null 2>&1 && BAD=1
( cd "$TMP" && "$VAJRA" next --role qa-specialist ) >/dev/null 2>&1 && BAD=1
( cd "$TMP" && "$VAJRA" next --role qa-specialist --from empty.md ) >/dev/null 2>&1 && BAD=1
( cd "$TMP" && "$VAJRA" next --role qa-specialist --from nope.md ) >/dev/null 2>&1 && BAD=1
printf "    unknown role · missing --from · empty findings · missing file\n"
[ "$BAD" -eq 0 ]; score $? exec "all four bad inputs still rejected"

label "7. No 8th command — every fix rides 'init' and 'next'."
"$VAJRA" --help 2>&1 | grep -m1 "vajra <" | sed 's/^/    /'
"$VAJRA" --help 2>&1 | grep -q "vajra <init|claude|check|next|estimate|hook|meter>"; score $? behav "still exactly 7 top-level commands"

# --- demo:summary_table ---
header "Scorecard  [demo:summary_table]"
# Every row is the RECORDED result of the case that ran. The first cut hardcoded the string "PASS"
# on six of nine rows (cold review, S122 pass 3) — a scorecard that could not report a failure.
printf "  %-54s %-7s %s\n" "CASE" "CLASS" "RESULT"
printf "  %-54s %-7s %s\n" "------------------------------------------------------" "-------" "------"
for r in "${ROWS[@]}"; do echo "  $r"; done
echo ""
printf "  ${BOLD}%s of %s cases passed${RESET}\n" "$PASS" "$((PASS+FAIL))"
echo "  CHECK CLASSES (this demo's own cases only) — execute-based: ${EXEC_N} · structural: ${STRUCT_N} · behavioral: ${BEHAV_N}"
echo "  STILL A SELF-ASSIGNED LABEL: nothing here proves a case marked \`exec\` executes anything."
echo ""
label "Stated plainly, because the demo would otherwise flatter itself:"
dim "  · The check-class labels are STILL typed by the author. S122 made the tally honest about"
dim "    NESTING; it did not make a single label EARNED. That is the unpicked option B from S121."
dim "  · 'no-eighth-command' is still a hardcoded-banner grep, here and in S113's suite."
dim "  · The executor thesis is STILL UNPROVEN. The QA role found three more real defects this"
dim "    session (seven across its two runs) — every one by READING. Execution bought exit codes."
dim "  · Three cold-review passes were needed. Pass 1 REJECT, pass 2 ACCEPT-with-findings, pass 3"
dim "    REJECT — and pass 3 found the same tautology on a THIRD field the guard did not name."
dim "  · The Write/Edit grant is still documented, not FENCED. Next session's candidate."

if [ "$FAIL" -eq 0 ]; then echo "DEMO GREEN ($PASS/$((PASS+FAIL)))"; exit 0; else echo "DEMO RED ($PASS/$((PASS+FAIL)))"; exit 1; fi
