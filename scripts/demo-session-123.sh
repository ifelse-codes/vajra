#!/usr/bin/env bash
# Demo — Session 123: the QA role's Write/Edit grant is fenced, not just documented.
#
# Sprint-demo contract (CONSTRAINTS.yaml#demo.required_elements): header · cases · summary_table ·
# before_after. Cumulative: replays the S119 clean-room primitive and the S121 fleet grant, then
# shows what S123 changed — a disposable checkout the QA role's dispatch is actually pointed at,
# and a real write attempt shown landing there instead of the source repo.
#
# Everything below RUNS the real binary or the real check functions against a throwaway repo.
# Where a claim cannot be shown running, it is narrated as such, not scored as a case.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="123"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}== %s ==${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}> %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}OK %s${RESET}\n" "$1"; }
no()     { printf "${RED}xx %s${RESET}\n" "$1"; }
dim()    { printf "${DIM}%s${RESET}\n" "$1"; }

VAJRA="$ROOT/target/debug/vajra"
[ -x "$VAJRA" ] || cargo build -q || { echo "build failed"; exit 1; }

PASS=0; FAIL=0; EXEC_N=0; STRUCT_N=0; BEHAV_N=0; ROWS=()
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
mkdir -p "$TMP/.ai"; echo "1" > "$TMP/.ai/SESSION"
( cd "$TMP" && git init -q . && git config user.email t@t.com && git config user.name T \
  && echo original > tracked.txt && git add -A && git commit -q -m subject )

# --- demo:header ---
header "Session ${SESSION} Demo — the fence  [demo:header]"
label "One line: qa-specialist is the fleet's only role that can execute, and its Write/Edit grant \
was documented, not controlled. S121's own words: the tree stayed clean on both live runs 'because \
I chose to hold it, which is not a control.' S123 measures whether a tool grant is even enforced, \
then routes the role's dispatch through a disposable checkout instead of the source repo."

# --- demo:before_after ---
header "Before -> After  [demo:before_after]"

label "1. The grant. BEFORE: Bash, Read, Write, Edit, Grep, Glob. AFTER: Bash, Read, Grep, Glob."
grep '^tools:' "$ROOT/.claude/agents/qa-specialist.md" | sed 's/^/    /'
grep -q '^tools: Bash, Read, Grep, Glob$' "$ROOT/.claude/agents/qa-specialist.md"
score $? exec "Write/Edit dropped from the live scaffolded grant"

label "2. The dispatch target. BEFORE: the source repo, always. AFTER: a disposable checkout, by default."
OPEN_OUT="$(cd "$TMP" && "$VAJRA" next --role qa-specialist --clean-room-open 2>&1)"
CR_PATH="$(head -1 <<<"$OPEN_OUT" | sed -E 's/^clean room opened for [^:]+: //')"
printf "    %s\n" "$OPEN_OUT" | sed 's/^/  /'
[ -d "$CR_PATH" ] && [ -f "$CR_PATH/tracked.txt" ]
score $? exec "a real disposable checkout materialised on the real CLI path"

# --- demo:cases ---
header "Cases  [demo:cases]"

label "1. A write attempted while pointed at the clean room lands there, not in the source."
HEAD_BEFORE="$(git -C "$TMP" rev-parse HEAD)"
STATUS_BEFORE="$(git -C "$TMP" status --porcelain)"
echo "PROBE-FROM-DEMO" >> "$CR_PATH/tracked.txt"
HEAD_AFTER="$(git -C "$TMP" rev-parse HEAD)"
STATUS_AFTER="$(git -C "$TMP" status --porcelain)"
printf "    clean room copy : %s\n    source copy      : %s\n" \
  "$(tail -1 "$CR_PATH/tracked.txt")" "$(tail -1 "$TMP/tracked.txt")"
grep -q "PROBE-FROM-DEMO" "$CR_PATH/tracked.txt" \
  && ! grep -q "PROBE-FROM-DEMO" "$TMP/tracked.txt" \
  && [ "$HEAD_BEFORE" = "$HEAD_AFTER" ] && [ "$STATUS_BEFORE" = "$STATUS_AFTER" ]
score $? exec "source HEAD + porcelain unchanged by a write that DID happen"

( cd "$TMP" && "$VAJRA" next --role qa-specialist --clean-room-close "$CR_PATH" >/dev/null 2>&1 )

label "2. A read-only role is refused a clean room — nothing to isolate."
OUT="$(cd "$TMP" && "$VAJRA" next --role researcher --clean-room-open 2>&1)"; RC=$?
printf "    %s\n" "$OUT" | sed 's/^/  /'
[ "$RC" -ne 0 ]
score $? exec "researcher (Read-only) refused, on the real CLI path"

label "3. The tally is one source across three suites now, not a byte-duplicated pair."
shopt -s extdebug 2>/dev/null || true
bash -c '
  set -uo pipefail; shopt -s extdebug
  source scripts/lib-tally.sh
  declare -F print_tally | awk "{print \$NF}"
'
score $? struct "print_tally resolves from scripts/lib-tally.sh"

label "4. No 8th command — the fence rides \`next\`, not a new verb."
"$VAJRA" --help 2>&1 | grep -m1 "vajra <" | sed 's/^/    /'
"$VAJRA" --help 2>&1 | grep -q "vajra <init|claude|check|next|estimate|hook|meter>"
score $? behav "still exactly 7 top-level commands"

# --- demo:summary_table ---
header "Scorecard  [demo:summary_table]"
printf "  %-54s %-7s %s\n" "CASE" "CLASS" "RESULT"
printf "  %-54s %-7s %s\n" "------------------------------------------------------" "-------" "------"
for r in "${ROWS[@]}"; do echo "  $r"; done
echo ""
printf "  ${BOLD}%s of %s cases passed${RESET}\n" "$PASS" "$((PASS+FAIL))"
echo "  CHECK CLASSES (this demo's own cases only) — execute-based: ${EXEC_N} · structural: ${STRUCT_N} · behavioral: ${BEHAV_N}"
echo ""
label "Stated plainly, because the demo would otherwise flatter itself:"
dim "  · Not shown here (needs the live Claude Code dispatch mechanism, not a bash script): S123's"
dim "    own measurement that a role's tools: grant is enforced MECHANICALLY — no Write/Edit/Bash"
dim "    tool was present at all for a role not granted one. See DECISION-007's S123 addendum."
dim "  · The clean room isolates the REPO, not the MACHINE. qa-specialist still holds Bash; nothing"
dim "    stops 'cd /real/path && echo x > file' by name. What changed is DEFAULT isolation plus"
dim "    TAMPER-EVIDENCE (HEAD sha / ls-files hash / porcelain, compared — never tamper-PROOF)."
dim "  · The executor thesis is STILL UNPROVEN. This fences one way the role could cheat; it does"
dim "    not establish that no executor can fake a pass by any means. Never restate it as measured."
dim "  · The check-class labels are still typed by the author — same unpicked S121 option B."

if [ "$FAIL" -eq 0 ]; then echo "DEMO GREEN ($PASS/$((PASS+FAIL)))"; exit 0; else echo "DEMO RED ($PASS/$((PASS+FAIL)))"; exit 1; fi
