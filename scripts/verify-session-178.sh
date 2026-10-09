#!/usr/bin/env bash
# Session 178 verify — three close messages made true (F83 template, F86 non-Claude note, F87 the
# "no environment variable can satisfy or bypass" sentence). Wording only: every check RUNS the real
# `vajra next` gates, OLD (built from the pinned commit this session started from — dc57eb0, never
# `main`: after the merge main IS new) vs NEW (this checkout), on real records in rudra and Vajra.
# Pass = same verdict, same exit code, and the only changed lines are the new/replaced wording.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0; SKIP=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(mktemp -d)"; trap 'rm -rf "$T"; git worktree remove --force "$T.old" >/dev/null 2>&1' EXIT
PRE_FIX=dc57eb0
RUDRA="${RUDRA:-/Users/suman/playground/rudra}"
NOTE="ran in an agent other than Claude Code"
CMPS=0

# --- binaries -----------------------------------------------------------------------------------
cargo build --release -q 2>/dev/null || { bad "new build failed"; exit 1; }
NEW="$ROOT/target/release/vajra"
OLD="${OLD_VAJRA:-}"
if [ -z "$OLD" ]; then
  git worktree add -q --detach "$T.old" "$PRE_FIX" 2>/dev/null || { bad "cannot check out $PRE_FIX"; exit 1; }
  ( cd "$T.old" && CARGO_TARGET_DIR="$ROOT/target/s178-old" cargo build --release -q 2>/dev/null ) \
    || { bad "old build ($PRE_FIX) failed"; exit 1; }
  OLD="$ROOT/target/s178-old/release/vajra"
fi

# cmp_gate DIR N FLAG EXPECT_NOTE(yes|no) → old vs new on one real record
cmp_gate() {
  local dir="$1" n="$2" flag="$3" want="$4" o n2 oc nc
  o="$(cd "$dir" && "$OLD" next "$flag" "$n" 2>&1)"; oc=$?
  n2="$(cd "$dir" && "$NEW" next "$flag" "$n" 2>&1)"; nc=$?
  local tag="$(basename "$dir") S$n $flag"
  grep -q "^=== " <<<"$n2" || { bad "$tag: the gate did not run (no header)"; return; }
  [ "$oc" = "$nc" ] || { bad "$tag: exit changed old=$oc new=$nc"; return; }
  [ "$(grep -c '^verdict:' <<<"$o")" = "$(grep -c '^verdict:' <<<"$n2")" ] \
    && [ "$(grep '^verdict:' <<<"$o")" = "$(grep '^verdict:' <<<"$n2")" ] \
    || { bad "$tag: verdict line changed"; return; }
  # every removed line must carry the false sentence; every added line must carry new wording
  local rem add
  rem="$(diff <(echo "$o") <(echo "$n2") | grep '^< ' | grep -vc 'can satisfy or bypass')"
  add="$(diff <(echo "$o") <(echo "$n2") | grep '^> ' | grep -vcE "$NOTE|flag turns this check off")"
  [ "$rem" = 0 ] && [ "$add" = 0 ] || { bad "$tag: other text changed (removed=$rem added=$add)"; diff <(echo "$o") <(echo "$n2") | head -6; return; }
  if [ "$want" = yes ]; then
    grep -q "$NOTE" <<<"$n2" || { bad "$tag: the non-Claude note is missing"; return; }
  else
    grep -q "$NOTE" <<<"$n2" && { bad "$tag: the non-Claude note shows on a record that passes"; return; }
  fi
  CMPS=$((CMPS+1))
  ok "$tag: exit $oc both, same verdict, only the new wording differs$( [ "$want" = yes ] && echo ' — non-Claude note shown')"
}

# --- AC5: rudra S13 (OpenCode, the 3 blocked checks) ----------------------------------------------
if [ -d "$RUDRA/.ai" ]; then
  cmp_gate "$RUDRA" 13 --check-crew             yes
  cmp_gate "$RUDRA" 13 --check-design-handoff   yes
  cmp_gate "$RUDRA" 13 --check-fidelity-handoff yes
  # rudra S11 (omp, hand-typed stamps) shows the note too; S12 (Claude Code, 21/21) is unchanged
  for f in --check-crew --check-design-handoff --check-fidelity-handoff; do cmp_gate "$RUDRA" 11 "$f" yes; done
  for n in 12; do
    for f in --check-crew --check-design-handoff --check-fidelity-handoff; do cmp_gate "$RUDRA" "$n" "$f" no; done
  done
else
  echo "SKIP: rudra not found at $RUDRA"; SKIP=$((SKIP+9))
fi
# Vajra's own real records (Claude Code): S176, S177
for n in 176 177; do
  for f in --check-crew --check-design-handoff --check-fidelity-handoff; do cmp_gate "$ROOT" "$n" "$f" no; done
done


# --- rec 3: crew call site 2 (a verified tech-lead, a required role that cannot be confirmed) -------
# A copy of THIS session's real, verified tech-lead handoff (it marks fidelity-reviewer required) in a
# fixture repo whose Claude Code history points at Vajra's own; plus a fidelity-reviewer handoff whose
# dispatch id is made up — the rudra S13 recovery shape. OLD: no note. NEW: the note.
CC_PROJECTS="${VAJRA_CLAUDE_PROJECTS_DIR:-$HOME/.claude/projects}"
REAL_CC="$CC_PROJECTS/$(printf '%s' "$ROOT" | sed 's#[^A-Za-z0-9]#-#g')"   # S192: Claude Code's own folder name
if [ -f .ai/handoffs/session-178-tech-lead.md ] && [ -d "$REAL_CC" ]; then
  X="$T/site2"; mkdir -p "$X/prompts" "$X/.ai/handoffs" "$T/cc" && ( cd "$X" && git init -q )
  XR="$(cd "$X" && git rev-parse --show-toplevel)"
  # S192: the new name (every non-alphanumeric → `-`) for today's vajra, the old (`/` only) for the old one.
  ln -s "$REAL_CC" "$T/cc/$(printf '%s' "$XR" | sed 's#[^A-Za-z0-9]#-#g')"
  [ -e "$T/cc/$(printf '%s' "$XR" | tr '/' '-')" ] || ln -s "$REAL_CC" "$T/cc/$(printf '%s' "$XR" | tr '/' '-')"
  cp prompts/178-task-keep-testing.md "$X/prompts/"
  cp .ai/handoffs/session-178-tech-lead.md "$X/.ai/handoffs/"
  sed -e 's/^role: tech-lead/role: fidelity-reviewer/' \
      -e 's/^agent: .*/agent: claude-code-subagent (verified: toolu_FAKEFAKEFAKE)/' \
      .ai/handoffs/session-178-tech-lead.md > "$X/.ai/handoffs/session-178-fidelity-reviewer.md"
  o="$(cd "$X" && VAJRA_CLAUDE_PROJECTS_DIR="$T/cc" "$OLD" next --check-crew 178 2>&1)"; oc=$?
  n="$(cd "$X" && VAJRA_CLAUDE_PROJECTS_DIR="$T/cc" "$NEW" next --check-crew 178 2>&1)"; nc=$?
  if grep -q "marked these roles \`required\`" <<<"$n" && [ "$oc" = 1 ] && [ "$nc" = 1 ] \
     && ! grep -q "$NOTE" <<<"$o" && grep -q "$NOTE" <<<"$n"; then
    ok "rec 3 crew call site 2: verified tech-lead + unconfirmable required role — exit 1 both; OLD no note → NEW note"
  else
    bad "rec 3 site 2: old=$oc new=$nc; $(grep -E '✗' <<<"$n" | head -2 | cut -c1-120 | tr '\n' ' ')"
  fi
else
  echo "SKIP: no S178 tech-lead handoff or Claude Code history for the site-2 fixture"; SKIP=$((SKIP+1))
fi

# --- AC6: the false sentence is gone; what replaces it is true at close ----------------------------
O="$("$OLD" next --check-crew 999 2>&1)"; N="$("$NEW" next --check-crew 999 2>&1)"
grep -q "can satisfy or bypass" <<<"$O" && ! grep -q "can satisfy or bypass" <<<"$N" \
  && grep -q "VAJRA_CLOSEOUT_WAIVER=<NN>" <<<"$N" && grep -q "no waiver replaces" <<<"$N" \
  && grep -q "flag turns this check off" <<<"$N" \
  && ok "AC6 --check-crew with no tech-lead: OLD says 'can satisfy or bypass' → NEW names the close waiver + the unwaivable file check" \
  || bad "AC6 wording: old/new not as expected"
# The claim is true, LIVE (review rec 4): (a) no VAJRA_SKIP_* flag turns the check off; (b) the
# close script's required-crew check really takes the waiver; (c) its claimed-evidence check really
# refuses it for a CODE session with no tech-lead file. A fixture CODE session 42, no handoffs.
F="$T/fx42"; mkdir -p "$F/prompts" "$F/.ai" && ( cd "$F" && git init -q )
printf 'session:\n  ground_truth_every_n_sessions: 5\n' > "$F/.ai/CONSTRAINTS.yaml"
printf '# S42\n\n## Type\n- **CODE**, one story.\n' > "$F/prompts/42-task-x.md"
( cd "$F" && env VAJRA_SKIP_CREW_GATE=1 VAJRA_SKIP_TECH_LEAD_GATE=1 VAJRA_SKIP_MANDATE_GATE=1 \
    "$NEW" next --check-crew 42 >/dev/null 2>&1 ); c=$?
[ "$c" = 1 ] && ok "AC6 (a) VAJRA_SKIP_CREW/TECH_LEAD/MANDATE_GATE=1 set: the crew check still blocks (exit 1)" \
  || bad "AC6 (a) a skip flag changed the answer (exit $c)"
closefn() { # closefn FN → the function's log, run from the real close script with the NEW vajra on PATH
  ( cd "$F" && PATH="$(dirname "$NEW"):$PATH" VAJRA_CLOSEOUT_WAIVER=42 bash -c '
    for f in is_ground_truth_session is_code_session waiver_ok '"$1"'; do
      source /dev/stdin <<<"$(sed -n "/^$f()/,/^}/p" "$0")"
    done
    ok() { echo "RESULT: ok"; }; bad() { echo "RESULT: bad"; }
    N=42; ARTIFACTS=$(mktemp -d); '"$1"'; cat "$ARTIFACTS"/*.log' "$ROOT/scripts/verify-closeout-scaffold.sh" )
}
R="$(closefn check_required_crew)"
grep -q "^WAIVED: VAJRA_CLOSEOUT_WAIVER=42" <<<"$R" && grep -q "RESULT: ok" <<<"$R" \
  && ok "AC6 (b) the real close check required-crew takes VAJRA_CLOSEOUT_WAIVER=42 (WAIVED)" \
  || bad "AC6 (b) required-crew did not take the waiver: $(tail -2 <<<"$R" | tr '\n' ' ')"
R="$(closefn check_claimed_evidence)"
grep -q "^NOT WAIVABLE" <<<"$R" && grep -q "RESULT: bad" <<<"$R" \
  && ok "AC6 (c) the real close check claimed-evidence-real refuses the waiver for a missing tech-lead file" \
  || bad "AC6 (c) claimed-evidence-real did not refuse: $(tail -2 <<<"$R" | tr '\n' ' ')"
# rudra's real S13 close log: the check the old text said nothing could bypass WAS waived
if [ -f "$RUDRA/.ai/verify/closeout/20260927T060821Z/required-crew.log" ]; then
  grep -q "^WAIVED: VAJRA_CLOSEOUT_WAIVER=13" "$RUDRA/.ai/verify/closeout/20260927T060821Z/required-crew.log" \
    && ok "AC6 evidence: rudra S13's real close log shows required-crew WAIVED — the old sentence was false" \
    || bad "AC6 evidence log does not show the waiver"
else
  echo "SKIP: rudra S13 close log not found"; SKIP=$((SKIP+1))
fi

# --- AC4: the tech-lead template carries the plain-lines rule (Vajra, a fresh init, rudra) ---------
RULE="PLAIN lines, NOT inside a"
grep -q "$RULE" .claude/agents/tech-lead.md && ok "AC4 Vajra's own .claude/agents/tech-lead.md says it" || bad "AC4 Vajra copy"
P="$T/fresh"; mkdir -p "$P" && ( cd "$P" && git init -q && "$NEW" init </dev/null >/dev/null 2>&1 )
grep -q "$RULE" "$P/.claude/agents/tech-lead.md" 2>/dev/null \
  && ok "AC4 a fresh \`vajra init\` project's tech-lead.md says it" || bad "AC4 fresh init"
P2="$T/fresh-old"; mkdir -p "$P2" && ( cd "$P2" && git init -q && "$OLD" init </dev/null >/dev/null 2>&1 )
grep -q "$RULE" "$P2/.claude/agents/tech-lead.md" 2>/dev/null \
  && bad "AC4 the OLD render already said it (proof would be hollow)" || ok "AC4 the OLD render did not say it"
if [ -f "$RUDRA/.claude/agents/tech-lead.md" ]; then
  grep -q "$RULE" "$RUDRA/.claude/agents/tech-lead.md" \
    && ok "AC4 rudra's synced tech-lead.md says it" || bad "AC4 rudra not synced (run: vajra init --sync-fleet in rudra)"
else
  echo "SKIP: rudra tech-lead.md not found"; SKIP=$((SKIP+1))
fi

# --- unit tests for the changed messages ----------------------------------------------------------
cargo test --release -q --lib -- non_claude_note names_the_close_waiver 2>&1 | grep -q "test result: ok. 3 passed" \
  && ok "unit: 3 tests (mandate, fidelity: note added + reason kept; crew: truthful waiver)" || bad "unit tests"

echo "old-vs-new comparisons run: $CMPS"
echo "----"; echo "session 178 verify: $PASS pass, $FAIL fail, $SKIP skipped"
[ "$FAIL" -eq 0 ]
