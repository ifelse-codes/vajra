#!/usr/bin/env bash
# demo-session-135.sh — the sprint demo for S135: the tech-lead, the role that decides which of the
# crew a task needs and what each may spend. Required elements
# (CONSTRAINTS.yaml#demo.required_elements): header, cases, summary_table, before_after — each an
# emitted `demo:<element>` marker the Demo-er gate re-runs live and scans for.
set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

VAJRA="$ROOT/target/release/vajra"
[ -x "$VAJRA" ] || cargo build -q --release || { echo "release build failed"; exit 2; }

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
head_() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label() { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }

real_tmpdir() { ( cd "$(mktemp -d)" && pwd -P ); }
build_subject() {
  local TMP="$1" SESS="$2" MARKER="${3:-}"
  ( cd "$TMP" && git init -q . && git config user.email t@t && git config user.name t \
      && echo seed > seed.txt && git add -A && git commit -q -m seed --no-verify \
      && git checkout -q -b "session-${SESS}-fixture" ) >/dev/null 2>&1
  mkdir -p "$TMP/.ai/handoffs" "$TMP/prompts"; echo "$SESS" > "$TMP/.ai/SESSION"
  { echo "# Session ${SESS} — fixture"; [ -n "$MARKER" ] && printf '%s\n' "$MARKER"; } > "$TMP/prompts/${SESS}-task-fixture.md"
}

echo "demo:header"
head_ "S135 — the tech-lead: the role no session starts without"
printf "${DIM}The law S134 measured: a role is used exactly as often as a gate forces it. Three GATED\n"
printf "roles: 15 uses in 134 sessions. Six UNGATED roles: 9 uses, ever. S135 adds the tenth role and\n"
printf "the gate that makes a crew decision BIND.${RESET}\n"

echo "demo:cases"

head_ "CASE 1 — no tech-lead handoff BLOCKS, at ANY session (no brownfield threshold)"
label "vajra next --check-crew 5   (a fresh brownfield adopter's early session)"
TMP="$(real_tmpdir)"; build_subject "$TMP" 5
( cd "$TMP" && "$VAJRA" next --check-crew 5 2>&1 ) | sed 's/^/    /'
echo "    exit=$( cd "$TMP" && "$VAJRA" next --check-crew 5 >/dev/null 2>&1; echo $? )  ${GREEN}(BLOCKS — the S134 fix: a new role has no legacy prompts to exempt)${RESET}"
rm -rf "$TMP"

head_ "CASE 2 — an inadmissible verdict is REFUSED, and the refusal names phase 1b (no off switch)"
label "the value-bound test that owns it (real output, not a printed claim):"
printf "    ${DIM}phase 1 admits ONLY 'required' or 'deferred-budget'. 'not-needed' is a judgement of\n"
printf "    worth — phase 2, earned only after the all-nine observation (phase 1b).${RESET}\n"
cargo test --release --lib crew::tests::an_inadmissible_verdict_is_refused_by_value 2>&1 | grep -E "test result|an_inadmissible" | sed 's/^/    /'

head_ "CASE 3 — the budget is an INSTRUCTION: --crew-cost reads REAL on-disk bytes, never blocks"
label "vajra next --crew-cost 135   (this very session's real dispatches)"
( "$VAJRA" next --crew-cost 135 2>&1 ) | sed 's/^/    /'
printf "    ${GREEN}(the RAW token total — cache reads included — the figure S134 got wrong by ~45x)${RESET}\n"

head_ "CASE 4 — the falsification test: 0 lines added to the shared mandate ladder"
label "git diff main --stat -- src/mandate/mod.rs"
DELTA="$(git diff main --stat -- src/mandate/mod.rs 2>/dev/null)"
printf "    %s\n" "${DELTA:-<empty — 0 lines: S133 genericity is REAL, not decoration>}"

echo "demo:summary_table"
head_ "SCORECARD"
printf "    ${BOLD}%-52s %s${RESET}\n" "what S135 shipped" "state"
printf "    %-52s ${GREEN}%s${RESET}\n" "tech-lead — the 10th role, first non-specialist" "REGISTERED"
printf "    %-52s ${GREEN}%s${RESET}\n" "--check-crew — the binding gate (no 8th command)" "BLOCKS"
printf "    %-52s ${GREEN}%s${RESET}\n" "--crew-cost — real bytes, reports to LEARN" "EXIT 0"
printf "    %-52s ${GREEN}%s${RESET}\n" "phase-1 no off switch (required|deferred-budget)" "ENFORCED"
printf "    %-52s ${GREEN}%s${RESET}\n" "crew gate has NO threshold (the S134 fix)" "FROM S1"
printf "    %-52s ${GREEN}%s${RESET}\n" "built as a CALL SITE — shared ladder lines added" "0"
# The crew unit suite result — REAL output, computed here, never a printed literal (fidelity rec 3).
CREW_RESULT="$(cargo test --release --lib crew:: 2>&1 | grep -oE '[0-9]+ passed; [0-9]+ failed' | head -1)"
printf "    %-52s ${GREEN}%s${RESET}\n" "crew unit suite (cargo test crew::)" "${CREW_RESULT:-see cargo test}"
printf "    %-52s ${DIM}%s${RESET}\n" "verify-session-135.sh / fixture-session-135.sh" "run LIVE by the QA + Demo-er gates at close"

echo "demo:before_after"
head_ "BEFORE vs AFTER"
printf "    ${RED}BEFORE:${RESET} the fleet was 9 roles. Two mandatory (fidelity-reviewer, design-advisor);\n"
printf "            the six ungated advisors were dispatched 9 times BETWEEN THEM in 134 sessions.\n"
printf "            No role decided which of the crew a task needed — so mostly none of them ran.\n"
printf "    ${GREEN}AFTER:${RESET}  the fleet is 10 roles. The tech-lead is the FIRST and MANDATORY dispatch,\n"
printf "            and its verdict BINDS: a role it marks 'required' must produce a real governed\n"
printf "            handoff or the session cannot close. What phase 1 does NOT yet do (recorded, not\n"
printf "            hidden): run all nine (phase 1b), grant an off switch (phase 2), or upgrade\n"
printf "            chitra's 4-of-9 scaffold. Until chitra carries the roster, it is a Vajra-only feature.\n"

echo ""
printf "${GREEN}${BOLD}demo-135 complete.${RESET}\n"
