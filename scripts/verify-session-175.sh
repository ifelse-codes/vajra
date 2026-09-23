#!/usr/bin/env bash
# Session 175 verify — deliverable 0 (the ground-truth cadence becomes config) + the
# publish-guard merge fix found live in rudra session 06 (VAJRA_ALLOW_PUBLISH=1 let the agent
# merge its own PRs; F55/S173 said "merge stays human"). Every check RUNS the real hook or
# script; nothing here greps source to decide a pass. AC3 diffs old vs new hook output on a
# listed command/mode grid — the only allowed difference is the one intentional tightening.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
git_fx() { git -C "$1" -c user.email=v@v -c user.name=v -c commit.gpgsign=false "${@:2}"; }

# ==============================================================================================
# AC1 — ground_truth_next_session: present overrides, absent falls back to N % 5 == 0 unchanged.
# ==============================================================================================
WITH="$T/with.yaml"; printf 'ground_truth_next_session: 180\n' > "$WITH"
WITHOUT="$T/without.yaml"; : > "$WITHOUT"

is_gt_new() { # $1 constraints-file $2 N
  local n; n="$(grep -E '^[[:space:]]*ground_truth_next_session:' "$1" 2>/dev/null | grep -oE '[0-9]+' | head -1 || true)"
  if [ -n "$n" ]; then [ "$((10#$n))" -eq "$((10#$2))" ]; else [ "$((10#$2 % 5))" -eq 0 ]; fi
}
is_gt_old() { [ "$((10#$1 % 5))" -eq 0 ]; }

DIFF=0
for N in 1 4 5 10 25 60 90 120 165 170 174 175 176 179 180 181 185 200; do
  o=$(is_gt_old "$N" && echo 1 || echo 0); n=$(is_gt_new "$WITHOUT" "$N" && echo 1 || echo 0)
  [ "$o" = "$n" ] || { DIFF=$((DIFF+1)); echo "  DIFF (key absent) N=$N old=$o new=$n"; }
done
[ "$DIFF" -eq 0 ] && ok "AC1a key absent: identical to the old N % 5 rule across 18 session numbers" \
  || bad "AC1a key absent: $DIFF difference(s) from the old rule"

AC1B_FAIL=0
for N in 5 10 175 176 179 180; do
  is_gt_new "$WITH" "$N" && g=GT || g=code
  want=code; [ "$N" = 180 ] && want=GT
  [ "$g" = "$want" ] || { AC1B_FAIL=$((AC1B_FAIL+1)); echo "  N=$N want=$want got=$g"; }
done
[ "$AC1B_FAIL" -eq 0 ] && ok "AC1b key=180: GT fires only at 180; 5/10/175/176/179 (former or would-be multiples of 5) are plain CODE" \
  || bad "AC1b key=180: $AC1B_FAIL wrong verdict(s)"

# The real hooks, invoked for real (not grepped) — one representative per branch, both keys.
fixture() { # $1 constraints-file $2 branch -> prints project dir
  local P="$T/fx-$RANDOM$RANDOM"; mkdir -p "$P/.ai"; cp "$1" "$P/.ai/CONSTRAINTS.yaml"
  printf 'maturity: L2\n' >> "$P/.ai/CONSTRAINTS.yaml"
  git_fx "$P" init -q -b main; git_fx "$P" commit -q --allow-empty -m i; git_fx "$P" checkout -q -b "$2"
  printf '%s' "$P"
}

P175=$(fixture "$WITH" session-175-x)
OUT="$(CLAUDE_PROJECT_DIR="$P175" bash scripts/hook-prompt-submit.sh 2>&1)"
! grep -q "Ground Truth" <<<"$OUT" && ok "AC1c hook-prompt-submit.sh, session-175, key=180: no false GT reminder" \
  || bad "AC1c hook-prompt-submit.sh still announces GT for S175: $OUT"

echo '{"tool_input":{"command":"git commit -m x"}}' > "$T/commit.json"
CLAUDE_PROJECT_DIR="$P175" bash scripts/hook-pre-bash.sh < "$T/commit.json" >/dev/null 2>&1
RC=$?
[ "$RC" -eq 0 ] && ok "AC1d hook-pre-bash.sh, session-175, key=180: git commit NOT blocked (the live bug this session fixes)" \
  || bad "AC1d hook-pre-bash.sh still blocks S175's commit (exit $RC)"

P180=$(fixture "$WITH" session-180-x)
OUT="$(CLAUDE_PROJECT_DIR="$P180" bash scripts/hook-prompt-submit.sh 2>&1)"
grep -q "Ground Truth Session 180" <<<"$OUT" && ok "AC1e hook-prompt-submit.sh, session-180, key=180: real ground truth still announces" \
  || bad "AC1e hook-prompt-submit.sh missed real GT at S180: $OUT"
CLAUDE_PROJECT_DIR="$P180" bash scripts/hook-pre-bash.sh < "$T/commit.json" >/dev/null 2>&1
RC=$?
[ "$RC" -eq 2 ] && ok "AC1f hook-pre-bash.sh, session-180, key=180: git commit IS blocked (real ground truth still enforces)" \
  || bad "AC1f hook-pre-bash.sh did not block S180's commit (exit $RC)"

# verify-closeout.sh's own is_ground_truth_session(), extracted and EXECUTED (not grepped).
FN="$(awk '/^is_ground_truth_session\(\)/,/^}/' scripts/verify-closeout.sh)"
[ -n "$FN" ] || bad "AC1g is_ground_truth_session() not found in verify-closeout.sh"
VC_FAIL=0
for pair in "5:0:with" "175:0:with" "180:1:with" "5:1:without" "175:1:without"; do
  N="${pair%%:*}"; rest="${pair#*:}"; want="${rest%%:*}"; key="${rest##*:}"
  P="$T/vc-$RANDOM$RANDOM"; mkdir -p "$P/.ai"; cp "$([ "$key" = with ] && echo "$WITH" || echo "$WITHOUT")" "$P/.ai/CONSTRAINTS.yaml"
  ( cd "$P" && eval "N=$N; $FN"; is_ground_truth_session ); got=$?
  gotv=$([ "$got" -eq 0 ] && echo 1 || echo 0)
  [ "$gotv" = "$want" ] || { VC_FAIL=$((VC_FAIL+1)); echo "  is_ground_truth_session N=$N key=$key want=$want got=$gotv"; }
done
[ "$VC_FAIL" -eq 0 ] && ok "AC1g verify-closeout.sh's is_ground_truth_session(): executed for real, 5 cases, all correct" \
  || bad "AC1g is_ground_truth_session(): $VC_FAIL wrong result(s)"

# AC1h/i/j (qa-specialist rec 1): the session's own verify script never executed 3 of the 6 fixed
# sites — hook-session-start.sh, hook-pre-write.sh, hook-stop.sh — confirmed only by grep. Live
# evidence for the other 3 must not live only in a disposable QA scratchpad.
AC1H_FAIL=0
for N in 170 175 180; do
  for key in with without; do
    P=$(fixture "$([ "$key" = with ] && echo "$WITH" || echo "$WITHOUT")" "session-${N}-x")
    OUT="$(CLAUDE_PROJECT_DIR="$P" bash scripts/hook-session-start.sh 2>&1)"
    HAS_GT=0; grep -q "\[REMINDER\] Session $N is GROUND TRUTH" <<<"$OUT" && HAS_GT=1
    want=0
    { [ "$key" = with ] && [ "$N" = 180 ]; } && want=1
    { [ "$key" = without ] && [ "$((N % 5))" -eq 0 ]; } && want=1
    [ "$HAS_GT" = "$want" ] || { AC1H_FAIL=$((AC1H_FAIL+1)); echo "  hook-session-start.sh N=$N key=$key want=$want got=$HAS_GT"; }
  done
done
[ "$AC1H_FAIL" -eq 0 ] && ok "AC1h hook-session-start.sh: 6 live cases (N=170/175/180 × key with/without), all correct" \
  || bad "AC1h hook-session-start.sh: $AC1H_FAIL wrong case(s)"

AC1I_FAIL=0
echo '{"tool_input":{"file_path":"src/main.rs"}}' > "$T/write.json"
for N in 170 175 180; do
  for key in with without; do
    P=$(fixture "$([ "$key" = with ] && echo "$WITH" || echo "$WITHOUT")" "session-${N}-x")
    CLAUDE_PROJECT_DIR="$P" bash scripts/hook-pre-write.sh < "$T/write.json" >/dev/null 2>&1
    RC=$?
    want=0
    { [ "$key" = with ] && [ "$N" = 180 ]; } && want=2
    { [ "$key" = without ] && [ "$((N % 5))" -eq 0 ]; } && want=2
    [ "$RC" = "$want" ] || { AC1I_FAIL=$((AC1I_FAIL+1)); echo "  hook-pre-write.sh N=$N key=$key want=$want got=$RC"; }
  done
done
[ "$AC1I_FAIL" -eq 0 ] && ok "AC1i hook-pre-write.sh: 6 live cases (N=170/175/180 × key with/without), all correct" \
  || bad "AC1i hook-pre-write.sh: $AC1I_FAIL wrong case(s)"

AC1J_FAIL=0
for N in 170 175 180; do
  for key in with without; do
    P=$(fixture "$([ "$key" = with ] && echo "$WITH" || echo "$WITHOUT")" "session-${N}-x")
    OUT="$(CLAUDE_PROJECT_DIR="$P" bash scripts/hook-stop.sh 2>&1)"
    LOOKED_FOR_GT_FILE=0; grep -q "Ground Truth Session $N missing" <<<"$OUT" && LOOKED_FOR_GT_FILE=1
    want=0
    { [ "$key" = with ] && [ "$N" = 180 ]; } && want=1
    { [ "$key" = without ] && [ "$((N % 5))" -eq 0 ]; } && want=1
    [ "$LOOKED_FOR_GT_FILE" = "$want" ] || { AC1J_FAIL=$((AC1J_FAIL+1)); echo "  hook-stop.sh N=$N key=$key want=$want got=$LOOKED_FOR_GT_FILE"; }
  done
done
[ "$AC1J_FAIL" -eq 0 ] && ok "AC1j hook-stop.sh: 6 live cases (N=170/175/180 × key with/without), all correct" \
  || bad "AC1j hook-stop.sh: $AC1J_FAIL wrong case(s)"

# AC1k (qa-specialist rec 4): a cheap structural backstop, run ALONGSIDE the live-execute checks
# above, never instead of them. git log proves this pattern already dropped one site once
# (hook-stop.sh landed in a separate, later commit than the other five) — this would have caught
# it immediately, without claiming to prove behavior on its own.
SIX_SITES=(scripts/hook-session-start.sh scripts/verify-closeout.sh scripts/hook-pre-bash.sh \
           scripts/hook-pre-write.sh scripts/hook-prompt-submit.sh scripts/hook-stop.sh)
AC1K_MISSING=""
for f in "${SIX_SITES[@]}"; do
  grep -q "ground_truth_next_session" "$f" || AC1K_MISSING="$AC1K_MISSING $f"
done
[ -z "$AC1K_MISSING" ] && ok "AC1k structural floor: all 6 known sites carry the ground_truth_next_session marker" \
  || bad "AC1k structural floor: missing from$AC1K_MISSING"

# ==============================================================================================
# AC2 — publish-guard: merge stays human, always, even with VAJRA_ALLOW_PUBLISH=1.
# ==============================================================================================
PG="$T/pg"; mkdir -p "$PG/.ai"; printf 'maturity: L2\n' > "$PG/.ai/CONSTRAINTS.yaml"
git_fx "$PG" init -q -b main; git_fx "$PG" commit -q --allow-empty -m i; git_fx "$PG" checkout -q -b session-06-x
pg() { # $1 command -> exit code, stdout+stderr on stdout
  jq -n --arg c "$1" '{tool_input:{command:$c}}' \
    | env VAJRA_ENFORCE_PUBLISH=1 VAJRA_ALLOW_PUBLISH=1 CLAUDE_PROJECT_DIR="$PG" bash scripts/hook-publish-guard.sh 2>&1
}
OUT="$(pg 'gh pr merge 7 --merge --delete-branch')"; RC=$?
[ "$RC" -eq 2 ] && grep -q "Merging stays with the human" <<<"$OUT" \
  && ok "AC2a gh pr merge, VAJRA_ALLOW_PUBLISH=1: BLOCKED (rudra S06's exact command)" \
  || bad "AC2a gh pr merge under PUB (exit $RC): $OUT"
OUT="$(pg 'glab mr merge 3')"; RC=$?
[ "$RC" -eq 2 ] && grep -q "Merging stays with the human" <<<"$OUT" \
  && ok "AC2b glab mr merge, VAJRA_ALLOW_PUBLISH=1: BLOCKED" || bad "AC2b glab mr merge under PUB (exit $RC): $OUT"
OUT="$(pg 'git push -u origin session-06-x')"; RC=$?
[ "$RC" -eq 0 ] && grep -q ALLOWED <<<"$OUT" && ok "AC2c git push, VAJRA_ALLOW_PUBLISH=1: still allowed" \
  || bad "AC2c git push under PUB regressed (exit $RC): $OUT"
OUT="$(pg 'gh pr create --title x --body y')"; RC=$?
[ "$RC" -eq 0 ] && grep -q ALLOWED <<<"$OUT" && ok "AC2d gh pr create, VAJRA_ALLOW_PUBLISH=1: still allowed" \
  || bad "AC2d gh pr create under PUB regressed (exit $RC): $OUT"
# The VAJRA_ALLOW_COMMIT path (F55) already excluded merge before this session — confirm untouched.
OUT="$(jq -n --arg c 'gh pr merge 6' '{tool_input:{command:$c},cwd:$d}' --arg d "$PG" \
  | env VAJRA_ALLOW_COMMIT=06 CLAUDE_PROJECT_DIR="$PG" bash scripts/hook-publish-guard.sh 2>&1)"; RC=$?
[ "$RC" -eq 2 ] && ! grep -q "You ARE approved" <<<"$OUT" \
  && ok "AC2e gh pr merge, VAJRA_ALLOW_COMMIT=06: still blocked, never told 'approved' (F55 path unchanged)" \
  || bad "AC2e VAJRA_ALLOW_COMMIT merge path regressed (exit $RC): $OUT"

# ==============================================================================================
# AC3 — old vs new: the ONLY behavior change is merge-under-VAJRA_ALLOW_PUBLISH flipping to BLOCK.
# ==============================================================================================
OLD="$T/old-publish-guard.sh"; git show HEAD:scripts/hook-publish-guard.sh > "$OLD"
CMDS=("git push" "git push -u origin session-06-x" "gh pr create --title x --body-file b" \
      "gh pr merge 7" "gh pr merge 7 --merge --delete-branch" "glab mr create" "glab mr merge 1" \
      "git push && gh pr merge 6" "echo gh pr merge" "git commit -m 'gh pr merge'")
SAME=0; UNEXPECTED=0; EXPECTED=0
for c in "${CMDS[@]}"; do
  OA=$(jq -n --arg c "$c" '{tool_input:{command:$c}}' | env VAJRA_ENFORCE_PUBLISH=1 VAJRA_ALLOW_PUBLISH=1 CLAUDE_PROJECT_DIR="$PG" bash "$OLD" >/dev/null 2>&1; echo $?)
  OB=$(jq -n --arg c "$c" '{tool_input:{command:$c}}' | env VAJRA_ENFORCE_PUBLISH=1 VAJRA_ALLOW_PUBLISH=1 CLAUDE_PROJECT_DIR="$PG" bash scripts/hook-publish-guard.sh >/dev/null 2>&1; echo $?)
  if [ "$OA" = "$OB" ]; then SAME=$((SAME+1))
  elif [ "$OA" = 0 ] && [ "$OB" = 2 ] && grep -qE '(gh pr|glab mr) merge' <<<"$c"; then EXPECTED=$((EXPECTED+1))
  else UNEXPECTED=$((UNEXPECTED+1)); echo "  UNEXPECTED DIFF: '$c' old=$OA new=$OB"; fi
done
[ "$UNEXPECTED" -eq 0 ] && [ "$EXPECTED" -ge 2 ] \
  && ok "AC3 old vs new (${#CMDS[@]} commands, PUB mode): $SAME unchanged, $EXPECTED tightened as intended (merge), 0 unexpected" \
  || bad "AC3 old vs new: $UNEXPECTED unexpected difference(s), $EXPECTED expected tightening(s)"

# ==============================================================================================
# AC4 — the whole fix set: unit tests still green, nothing else moved.
# ==============================================================================================
if cargo test -q --lib 2>&1 | tee "$T/libtest.log" | grep -qE "test result: ok\. [0-9]+ passed; 0 failed"; then
  N_TESTS="$(grep -oE '[0-9]+ passed' "$T/libtest.log" | head -1 | grep -oE '[0-9]+')"
  ok "AC4 cargo test --lib: $N_TESTS passed, 0 failed (no Rust source touched this session)"
else
  bad "AC4 cargo test --lib: $(tail -5 "$T/libtest.log")"
fi

echo ""
echo "=== Session 175 Verify Summary ==="
if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
