#!/usr/bin/env bash
# Demo — Session 126: the fleet roster is complete (four roles → nine).
#
# Sprint-demo contract (CONSTRAINTS.yaml#demo.required_elements): header · cases · summary_table ·
# before_after. Cumulative: replays what the fleet could already do (S109 scaffold + governed
# handoff, S114/S116/S121 one-role-at-a-time growth), then shows what S126 changed — five roles in
# one pass, every one read-only, and `K of 8` deliberately unmoved.
#
# Everything scored below RUNS the real binary against a throwaway repo. What cannot be shown
# running here (the five live dispatches — they cost real money and need a fresh Claude session) is
# NARRATED and pointed at its committed evidence, never scored as a case.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="126"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}== %s ==${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}> %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}OK %s${RESET}\n" "$1"; }
no()     { printf "${RED}xx %s${RESET}\n" "$1"; }
dim()    { printf "${DIM}%s${RESET}\n" "$1"; }

VAJRA="$ROOT/target/release/vajra"
[ -x "$VAJRA" ] || cargo build -q --release || { echo "build failed"; exit 1; }

NEW_ROLES="requirements-analyst design-advisor implementation-advisor demo-producer release-coordinator"
DISPATCH="sessions/session-126-artifacts/dispatch"

PASS=0; FAIL=0; EXEC_N=0; STRUCT_N=0; BEHAV_N=0; ROWS=()
score() {
  case "$2" in
    exec)   EXEC_N=$((EXEC_N+1)) ;;
    struct) STRUCT_N=$((STRUCT_N+1)) ;;
    behav)  BEHAV_N=$((BEHAV_N+1)) ;;
    *) echo "demo bug: unknown class '$2' for $3"; exit 2 ;;
  esac
  if [ "$1" -eq 0 ]; then ok "$3"; PASS=$((PASS+1)); ROWS+=("$(printf '%-56s %-7s %s' "$3" "$2" PASS)")
  else no "$3"; FAIL=$((FAIL+1)); ROWS+=("$(printf '%-56s %-7s %s' "$3" "$2" FAIL)"); fi
}

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null </dev/null ) || { echo "init failed"; exit 1; }
echo "126" > "$TMP/.ai/SESSION"

# --- demo:header --------------------------------------------------------------------------------
header "Session ${SESSION} Demo — the roster is complete  [demo:header]"
label "One line: Vajra's pipeline has EIGHT stations; until today only four of them had a named \
agent role behind them. S126 registers the last five — Analyst, Architect, Coder, Demo-er, \
Releaser — taking the fleet from four roles to nine, in one pass instead of five sessions."
dim "Read this next line as the honest headline, not a footnote: the roster is now COMPLETE, and"
dim "nothing depends on it. No gate consumes a handoff. 'Done' ships today; 'working' does not."

# --- demo:before_after --------------------------------------------------------------------------
header "Before → after  [demo:before_after]"
label "BEFORE (S125 close): four roles — researcher, fidelity-reviewer, plan-advisor, qa-specialist."
label "AFTER (this session): nine roles. Five added, ALL read-only — the execution allowlist did not grow."
printf "\n  %-22s %-28s %s\n" "STATION (K of 8)" "ROLE BEFORE S126" "ROLE AFTER S126"
printf "  %-22s %-28s %s\n" "----------------" "----------------" "---------------"
printf "  %-22s %-28s %s\n" "Analyst"   "(none)"             "requirements-analyst"
printf "  %-22s %-28s %s\n" "Architect" "(none)"             "design-advisor"
printf "  %-22s %-28s %s\n" "Planner"   "plan-advisor"       "plan-advisor"
printf "  %-22s %-28s %s\n" "Coder"     "(none)"             "implementation-advisor"
printf "  %-22s %-28s %s\n" "QA"        "qa-specialist"      "qa-specialist"
printf "  %-22s %-28s %s\n" "Demo-er"   "(none)"             "demo-producer"
printf "  %-22s %-28s %s\n" "Releaser"  "(none)"             "release-coordinator"
printf "  %-22s %-28s %s\n" "Reviewer"  "fidelity-reviewer"  "fidelity-reviewer"
printf "  %-22s %-28s %s\n" "(no station)" "researcher"      "researcher"
echo ""
label "The BEFORE half is shown running, not asserted: this is git's copy of the roster at S125."
BEFORE_N="$(git show "$(git merge-base HEAD main)":src/fleet/mod.rs 2>/dev/null | grep -c '^        name: "')"
AFTER_N="$(grep -c '^        name: "' src/fleet/mod.rs)"
echo "  roles registered at the merge-base (before this session): ${BEFORE_N}"
echo "  roles registered on this branch (after):                  ${AFTER_N}"
[ "${BEFORE_N:-0}" = "4" ] && [ "$AFTER_N" = "9" ]; score $? exec "before=4 roles, after=9 roles (read from git, not typed)"

# --- demo:cases ---------------------------------------------------------------------------------
header "Cases — the real binary, on a throwaway repo  [demo:cases]"

label "1. \`vajra init\` scaffolds all NINE roles as native subagent definitions."
ls -1 "$TMP/.claude/agents"
N="$(ls -1 "$TMP/.claude/agents" | wc -l | tr -d ' ')"
[ "$N" = "9" ]; score $? exec "nine role files scaffolded by the real binary"

label "2. Each of the five NEW roles governs a real, validated handoff — unchanged S109 path."
GOOD=0
for r in $NEW_ROLES; do
  printf 'Findings for %s.\n' "$r" > "$TMP/b-$r.md"
  if ( cd "$TMP" && "$VAJRA" next --role "$r" --from "b-$r.md" >/dev/null 2>&1 ) \
     && grep -q "^role: $r$" "$TMP/.ai/handoffs/session-126-$r.md"; then
    echo "   $r → .ai/handoffs/session-126-$r.md"
    GOOD=$((GOOD+1))
  else
    echo "   $r → FAILED"
  fi
done
[ "$GOOD" = "5" ]; score $? exec "five governed handoffs written and validated"

label "3. A station's own word is NOT a role key — the collision the house rejects, five more times."
for w in analyst architect coder demoer releaser; do
  if ( cd "$TMP" && "$VAJRA" next --role "$w" --from "b-demo-producer.md" >/dev/null 2>&1 ); then
    echo "   '$w' resolved — COLLISION"; COLL=1
  else
    echo "   '$w' refused (station word, not a role key)"
  fi
done
[ -z "${COLL:-}" ]; score $? exec "no role shadows a station name"

label "4. Five roles added, ZERO new grants of Bash — the allowlist did not grow with the roster."
grep -h '^tools: ' "$TMP"/.claude/agents/*.md | sort | uniq -c
BASH_N="$(grep -l '^tools: .*Bash' "$TMP"/.claude/agents/*.md | wc -l | tr -d ' ')"
echo "  roles granted Bash: $BASH_N (qa-specialist, S121 — the only one)"
[ "$BASH_N" = "1" ]; score $? exec "exactly one role may execute, out of nine"

label "5. \`K of 8\` is untouched by the roster — the counter counts STATIONS, never roles."
OUT="$( cd "$TMP" && "$VAJRA" next --stations 126 2>&1 )"
grep -E 'of 8 stations passed|governed handoff' <<<"$OUT" | sed 's/^/   /'
grep -q "NOT counted in it" <<<"$OUT"; score $? exec "five handoffs reported beside K, not counted in it"

label "6. Each of the five was really DISPATCHED BY NAME (S111 two-file cross-check, committed evidence)."
for r in $NEW_ROLES; do
  ID="$(python3 -c "import json,sys;print(json.load(open(sys.argv[1]))[0]['id'])" "$DISPATCH/$r-parent-tooluse.json" 2>/dev/null)"
  MID="$(python3 -c "import json,sys;print(json.load(open(sys.argv[1]))['toolUseId'])" "$DISPATCH/$r-subagent-meta.json" 2>/dev/null)"
  printf "   %-24s parent tool_use.id=%s  subagent meta.toolUseId=%s\n" "$r" "${ID:0:18}…" "${MID:0:18}…"
  [ -n "$ID" ] && [ "$ID" = "$MID" ] || BAD=1
done
[ -z "${BAD:-}" ]; score $? exec "five dispatches, each agreeing on a tool-call id neither side chose"

label "NARRATED, not scored: the five dispatches themselves ran in five separate headless Claude"
dim "sessions and cost \$4.45 of real metered spend. They cannot be re-run inside a demo. What IS"
dim "re-run above is the cross-check over their committed evidence — see $DISPATCH/dispatch-run-note.md."

# --- demo:summary_table -------------------------------------------------------------------------
header "Summary  [demo:summary_table]"
printf '%-56s %-7s %s\n' "CASE" "CLASS" "RESULT"
printf '%-56s %-7s %s\n' "--------------------------------------------------------" "-------" "------"
for r in "${ROWS[@]}"; do echo "$r"; done
echo ""
echo "  execute-based: $EXEC_N · structural: $STRUCT_N · behavioral source grep: $BEHAV_N"
echo "  (a class label here is self-assigned, exactly as in the verify suite — S122)"
echo ""
echo "WHAT THIS DEMO DOES NOT SHOW: any gate, script or session REACHING FOR a role. Nine roles are"
echo "registered, scaffolded, dispatchable and governed, and nothing depends on a single one of"
echo "them. That is S127's subject, not a claim this demo makes."
echo ""
if [ "$FAIL" -eq 0 ]; then
  ok "DEMO GREEN ($PASS pass, $FAIL fail)"
  exit 0
else
  no "DEMO RED ($PASS pass, $FAIL fail)"
  exit 1
fi
