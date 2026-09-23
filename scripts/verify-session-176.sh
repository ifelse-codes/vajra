#!/usr/bin/env bash
# Session 176 verify — F70: the Planner said READY on a plan citing acceptance items the prompt no
# longer had (rudra S08's agent deleted its own `## Acceptance` mid-session). Every check RUNS a
# binary: the NEW build (this checkout) and, for the before/after and the sweep, the OLD build
# compiled from the pinned pre-fix commit cd4302b (pinned, never `merge-base`/`HEAD~` — S175's AC3
# HEAD-drift lesson: a relative ref stops meaning "before" once the fix lands on main).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(mktemp -d)"; trap 'git worktree remove --force "$T/old" >/dev/null 2>&1; rm -rf "$T"' EXIT
PRE_FIX=cd4302b

# --- the two binaries ---------------------------------------------------------------------------
cargo build --release -q 2>/dev/null || { bad "new build failed"; exit 1; }
NEW="$ROOT/target/release/vajra"
git worktree add -q --detach "$T/old" "$PRE_FIX" >/dev/null 2>&1
( cd "$T/old" && CARGO_TARGET_DIR="$ROOT/target/verify-176-old" cargo build --release -q 2>/dev/null )
OLD="$ROOT/target/verify-176-old/release/vajra"
[ -x "$OLD" ] && ok "old build compiled from pinned pre-fix commit $PRE_FIX" || { bad "old build missing"; exit 1; }

# fixture project: prompts/NN-task-x.md only
proj() { local P="$T/p$RANDOM$RANDOM"; mkdir -p "$P/prompts" "$P/.ai"; cp "$2" "$P/prompts/$1-task-x.md"; printf '%s' "$P"; }
plan() { ( cd "$1" && "$2" next --check-plan "$3" 2>&1 ); }

# --- AC1: whole Acceptance section gone, plan still cites --------------------------------------
printf '# S20\n## Goal\ng\n## Plan\n1. a — covers: 1, 2\n2. b — covers: 3\n' > "$T/gone.md"
P=$(proj 20 "$T/gone.md"); OUT=$(plan "$P" "$NEW" 20); RC=$?
if [ "$RC" -ne 0 ] && grep -q "verdict: NOT READY" <<<"$OUT" && grep -q "cites acceptance item(s) 1, 2, 3" <<<"$OUT"; then
  ok "AC1 no Acceptance + plan cites 1,2,3 → NOT READY, names 1, 2, 3, exit $RC"
else bad "AC1 (exit $RC): $OUT"; fi

# --- AC2: list cut short -----------------------------------------------------------------------
printf '# S21\n## Acceptance\n1. x\n2. y\n3. z\n## Plan\n1. a — covers: 1, 2, 3\n2. b — covers: 4, 5\n' > "$T/cut.md"
P=$(proj 21 "$T/cut.md"); OUT=$(plan "$P" "$NEW" 21); RC=$?
if [ "$RC" -ne 0 ] && grep -q "cites acceptance item(s) 4, 5" <<<"$OUT" && grep -q "(3 numbered item(s)" <<<"$OUT"; then
  ok "AC2 list cut to 1–3, plan cites 4,5 → NOT READY, names 4, 5, exit $RC"
else bad "AC2 (exit $RC): $OUT"; fi

# --- AC3: the live case, old vs new ------------------------------------------------------------
P=$(proj 08 tests/fixtures/f70-rudra-s08-wiped.md)
O=$(plan "$P" "$OLD" 8); ORC=$?; N=$(plan "$P" "$NEW" 8); NRC=$?
if grep -q "verdict: READY" <<<"$O" && [ "$ORC" -eq 0 ] && grep -q "verdict: NOT READY" <<<"$N" && [ "$NRC" -ne 0 ] \
   && grep -q "cites acceptance item(s) 1, 2, 3, 4, 5, 6, 7" <<<"$N"; then
  ok "AC3 rudra S08 wiped prompt: OLD READY (exit 0) → NEW NOT READY (exit $NRC), names 1–7"
else bad "AC3 old=$ORC new=$NRC | $O | $N"; fi

# --- AC4: old vs new over every real prompt ----------------------------------------------------
# Expected flips are LISTED, each one real (see prompts/176 findings): 155 has no Acceptance but its
# plan cites `covers: 1`; 157's plan never cites AC5; 166's never cites AC1 (the last two were never
# checked before — their `| ACn |` tables parsed as zero criteria). Sessions > 176 are out of scope.
sweep() { # $1 root, $2 max session → prints "flipped-list|count"
  local flips="" c=0
  for n in $(ls "$1"/prompts/*-task-*.md | sed -E 's|.*/prompts/0*([0-9]+)-.*|\1|' | sort -un); do
    [ "$n" -le "$2" ] || continue; c=$((c+1))
    o=$( cd "$1" && "$OLD" next --check-plan "$n" 2>&1 | grep -m1 '^verdict')
    w=$( cd "$1" && "$NEW" next --check-plan "$n" 2>&1 | grep -m1 '^verdict')
    [ "$o" = "$w" ] || flips="$flips $n"
  done
  printf '%s|%s' "${flips# }" "$c"
}
R=$(sweep "$ROOT" 176); FL=${R%|*}; CNT=${R#*|}
[ "$FL" = "155 157 166" ] && ok "AC4 vajra: $CNT session prompts, flips exactly the 3 listed real ones (155 157 166)" \
  || bad "AC4 vajra flips = [$FL] of $CNT (expected 155 157 166)"
# (Captured into a variable before grep: `set -o pipefail` + an early-exiting `grep -q` turns the
# writer's SIGPIPE into a false FAIL.)
for n in 155 157 166; do
  V=$(plan "$ROOT" "$NEW" "$n"); grep -q "verdict: NOT READY" <<<"$V" || bad "AC4 #$n not NOT READY"
done
V157=$(plan "$ROOT" "$NEW" 157); V166=$(plan "$ROOT" "$NEW" 166)
grep -q "criterion(s) 5 " <<<"$V157" && grep -q "criterion(s) 1 " <<<"$V166" \
  && ok "AC4 reasons: 157 misses AC5, 166 misses AC1 (table rows now read as criteria)" || bad "AC4 reasons for 157/166"
RUDRA="$HOME/playground/rudra"
if [ -d "$RUDRA/prompts" ]; then
  R=$(sweep "$RUDRA" 9); FL=${R%|*}; CNT=${R#*|}
  [ -z "$FL" ] && ok "AC4 rudra: $CNT prompts (00–09), 0 flips" || bad "AC4 rudra flips = [$FL]"
else echo "NOTE: $RUDRA absent — rudra sweep not run (machine-local evidence)"; fi

# --- AC5: stations counter + --steps read Dangling as not passed ------------------------------
P=$(proj 08 tests/fixtures/f70-rudra-s08-wiped.md)
ST=$( cd "$P" && "$NEW" next --stations 8 2>&1 )
grep -q "\[ABSENT\] Planner.*plan cites missing criteria 1, 2, 3, 4, 5, 6, 7" <<<"$ST" \
  && ok "AC5 --stations: Planner ABSENT, 'plan cites missing criteria 1–7'" || bad "AC5 stations: $ST"
( cd "$P" && printf '08\n' > .ai/SESSION && git init -q -b session-08-x )
SO=$( cd "$P" && "$OLD" next --steps 2>&1 ); SN=$( cd "$P" && "$NEW" next --steps 2>&1 )
# Old vs new on the SAME wiped prompt, so the ✗ is the fix, not some other fixture gap.
grep -q "✓ every acceptance item is covered by a plan step" <<<"$SO" \
  && grep -q "✗ every acceptance item is covered by a plan step" <<<"$SN" \
  && ok "AC5 --steps Planner line: OLD ✓ → NEW ✗ on the wiped prompt" \
  || bad "AC5 steps old=[$(grep 'acceptance item' <<<"$SO")] new=[$(grep 'acceptance item' <<<"$SN")]"

# --- unit tests (the edge fixtures, dangling-wins, table rows, adds-only no-criteria) ---------
UT=$(cargo test --release -q --lib planner 2>&1); grep -q "test result: ok. 22 passed" <<<"$UT" \
  && ok "unit: planner 22/22 (dangling, cut, dangling-wins, edge a/b/c, AC tables, gate message)" || bad "unit planner"

echo; echo "=== verify-session-176: $PASS pass, $FAIL fail ==="
[ "$FAIL" -eq 0 ]
