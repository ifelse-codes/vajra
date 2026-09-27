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
  add="$(diff <(echo "$o") <(echo "$n2") | grep '^> ' | grep -vcE "$NOTE|changes this check's answer")"
  [ "$rem" = 0 ] && [ "$add" = 0 ] || { bad "$tag: other text changed (removed=$rem added=$add)"; diff <(echo "$o") <(echo "$n2") | head -6; return; }
  if [ "$want" = yes ]; then
    grep -q "$NOTE" <<<"$n2" || { bad "$tag: the non-Claude note is missing"; return; }
  fi
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
  echo "SKIP: rudra not found at $RUDRA"; SKIP=$((SKIP+3))
fi
# Vajra's own real records (Claude Code): S176, S177
for n in 176 177; do
  for f in --check-crew --check-design-handoff --check-fidelity-handoff; do cmp_gate "$ROOT" "$n" "$f" no; done
done

# --- AC6: the false sentence is gone; what replaces it is true at close ----------------------------
O="$("$OLD" next --check-crew 999 2>&1)"; N="$("$NEW" next --check-crew 999 2>&1)"
grep -q "can satisfy or bypass" <<<"$O" && ! grep -q "can satisfy or bypass" <<<"$N" \
  && grep -q "VAJRA_CLOSEOUT_WAIVER=<NN>" <<<"$N" && grep -q "no waiver replaces" <<<"$N" \
  && ok "AC6 --check-crew with no tech-lead: OLD says 'can satisfy or bypass' → NEW names the close waiver + the unwaivable file check" \
  || bad "AC6 wording: old/new not as expected"
# the claim is true: the close script really waives required-crew, and really does NOT waive the tech-lead file
grep -q 'VAJRA_CLOSEOUT_WAIVER' <(sed -n '/^check_required_crew()/,/^}/p' scripts/verify-closeout-scaffold.sh) \
  && grep -q 'NOT WAIVABLE' <(sed -n '/^check_claimed_evidence()/,/^}/p' scripts/verify-closeout-scaffold.sh) \
  && ok "AC6 the new sentence matches the close script: required-crew is waivable, the tech-lead file is not" \
  || bad "AC6 the close script does not match the new sentence"
# rudra's real S13 close log: the check the old text said nothing could bypass WAS waived
if [ -f "$RUDRA/.ai/verify/closeout/20260927T060821Z/required-crew.log" ]; then
  grep -q "^WAIVED: VAJRA_CLOSEOUT_WAIVER=13" "$RUDRA/.ai/verify/closeout/20260927T060821Z/required-crew.log" \
    && ok "AC6 evidence: rudra S13's real close log shows required-crew WAIVED — the old sentence was false" \
    || bad "AC6 evidence log does not show the waiver"
fi

# --- AC4: the tech-lead template carries the plain-lines rule (Vajra, a fresh init, rudra) ---------
RULE="PLAIN lines, NOT inside a"
grep -q "$RULE" .claude/agents/tech-lead.md && ok "AC4 Vajra's own .claude/agents/tech-lead.md says it" || bad "AC4 Vajra copy"
P="$T/fresh"; mkdir -p "$P" && ( cd "$P" && git init -q && "$NEW" init >/dev/null 2>&1 )
grep -q "$RULE" "$P/.claude/agents/tech-lead.md" 2>/dev/null \
  && ok "AC4 a fresh \`vajra init\` project's tech-lead.md says it" || bad "AC4 fresh init"
P2="$T/fresh-old"; mkdir -p "$P2" && ( cd "$P2" && git init -q && "$OLD" init >/dev/null 2>&1 )
grep -q "$RULE" "$P2/.claude/agents/tech-lead.md" 2>/dev/null \
  && bad "AC4 the OLD render already said it (proof would be hollow)" || ok "AC4 the OLD render did not say it"
if [ -f "$RUDRA/.claude/agents/tech-lead.md" ]; then
  grep -q "$RULE" "$RUDRA/.claude/agents/tech-lead.md" \
    && ok "AC4 rudra's synced tech-lead.md says it" || bad "AC4 rudra not synced (run: vajra init --sync-fleet in rudra)"
fi

# --- unit tests for the changed messages ----------------------------------------------------------
cargo test --release -q --lib -- non_claude_note names_the_close_waiver 2>&1 | grep -q "test result: ok. 3 passed" \
  && ok "unit: 3 tests (mandate, fidelity: note added + reason kept; crew: truthful waiver)" || bad "unit tests"

echo "----"; echo "session 178 verify: $PASS pass, $FAIL fail, $SKIP skipped"
[ "$FAIL" -eq 0 ]
