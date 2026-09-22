#!/usr/bin/env bash
# Session 174 verify — the findings from the founder's rudra session 05 run (F58–F63). Every check
# RUNS the real thing: the real hooks fed the commands rudra's agent typed, the real binary against a
# clone of rudra pinned at its merged session 05 (512c71a), the real `vajra init --sync-fleet`, and
# the unit tests by name. AC6 runs the hooks as they were before S174 (f170e1c) side by side with
# today's and compares every allow/deny decision. Nothing here greps source to decide a pass.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
BIN="${VAJRA_BIN:-$ROOT/target/release/vajra}"
[ -x "$BIN" ] || { echo "FAIL: $BIN not built — run cargo build --release"; exit 1; }
NEWER="$(find src Cargo.toml scripts/hook-*.sh .githooks -newer "$BIN" -print -quit 2>/dev/null || true)"
[ -z "$NEWER" ] || { echo "FAIL: $BIN is older than $NEWER — run: cargo build --release"; exit 1; }
unset VAJRA_ALLOW_COMMIT VAJRA_ALLOW_PUBLISH VAJRA_ENFORCE_PUBLISH VAJRA_CLOSEOUT_WAIVER VAJRA_SESSION_OWNER_FILE VAJRA_GUARD_MATURITY CLAUDECODE CLAUDE_CODE_ENTRYPOINT CURSOR_TRACE_ID VAJRA_AGENT
git_fx() { git -C "$1" -c user.email=v@v -c user.name=v -c commit.gpgsign=false "${@:2}"; }
mkdir -p "$T/bin"; ln -sf "$BIN" "$T/bin/vajra"

# The hooks before S174, for AC6.
OLD="$T/old"; mkdir -p "$OLD"
git show f170e1c:scripts/hook-publish-guard.sh > "$OLD/publish-guard.sh"
git show f170e1c:.githooks/pre-commit > "$OLD/pre-commit"

# rudra, pinned at the merge of its session 05 — the run these findings came from.
RUDRA="${VAJRA_SYNC_TARGET:-$HOME/playground/rudra}"
RUDRA_BEFORE="$(git -C "$RUDRA" rev-parse HEAD 2>/dev/null; git -C "$RUDRA" status --short 2>/dev/null)"
PIN=512c71a
RC="$T/rudra"
if [ -d "$RUDRA/.git" ] && git clone -q "$RUDRA" "$RC" 2>/dev/null && git_fx "$RC" checkout -q -B main "$PIN" 2>/dev/null; then
  git_fx "$RC" update-ref refs/remotes/origin/main "$PIN"
  HAVE_RUDRA=1
else
  HAVE_RUDRA=0
  bad "setup rudra-at-$PIN — no clone of $RUDRA at $PIN; set VAJRA_SYNC_TARGET (a check that cannot evaluate FAILS)"
fi

# A scratch project on a session branch with an enforcing publish guard (L3, guard not switched off).
P="$T/proj"; mkdir -p "$P/.ai"; echo "maturity: L3" > "$P/.ai/CONSTRAINTS.yaml"
git_fx "$P" init -q -b main; git_fx "$P" commit -q --allow-empty -m i; git_fx "$P" checkout -q -b session-05-x
pg() { # $1 hook, $2 command, $3 approval → prints output, returns exit code
  jq -n --arg c "$2" --arg d "$P" '{tool_input:{command:$c},cwd:$d}' \
    | CLAUDE_PROJECT_DIR="$P" VAJRA_ALLOW_COMMIT="$3" bash "$1" 2>&1
}
HEREDOC_PR='gh pr create --title "S05" --body "$(cat <<'"'"'EOF'"'"'
## What shipped
EOF
)" 2>&1 | tail -5'

# ==============================================================================================
# AC1 (F58) — approved but off-list: still blocked, told it IS approved and how.
# ==============================================================================================
OUT="$(pg scripts/hook-publish-guard.sh "$HEREDOC_PR" 05)"; RC1=$?
if [ "$RC1" -eq 2 ] && grep -q "NOT THIS SPELLING" <<<"$OUT" && grep -q "You ARE approved" <<<"$OUT" \
   && grep -q -- "--body-file <file>" <<<"$OUT" && ! grep -q "relaunch with VAJRA_ALLOW_PUBLISH" <<<"$OUT"; then
  ok "AC1 rudra S05's exact PR command: still blocked (exit 2), says approved + --body-file"
else bad "AC1 heredoc PR under approval (exit $RC1): $OUT"; fi
OUT="$(pg scripts/hook-publish-guard.sh 'gh pr create --title "S05" --body-file /tmp/b.md' 05)"; RC1=$?
[ "$RC1" -eq 0 ] && grep -q ALLOWED <<<"$OUT" && ok "AC1 the --body-file shape it is told to use passes" || bad "AC1 body-file (exit $RC1): $OUT"
OUT="$(pg scripts/hook-publish-guard.sh 'gh pr merge 6' 05)"; RC1=$?
[ "$RC1" -eq 2 ] && grep -q "BLOCKED: gh pr merge" <<<"$OUT" && ! grep -q "You ARE approved" <<<"$OUT" \
  && ok "AC1 a merge under approval: blocked with the old message, never 'approved'" || bad "AC1 merge (exit $RC1): $OUT"
OUT="$(pg scripts/hook-publish-guard.sh 'gh pr create --title x --body-file b' "")"; RC1=$?
[ "$RC1" -eq 2 ] && grep -q "relaunch with VAJRA_ALLOW_PUBLISH" <<<"$OUT" && ! grep -q "You ARE approved" <<<"$OUT" \
  && ok "AC1 no approval: blocked with the old message" || bad "AC1 unapproved (exit $RC1): $OUT"
OUT="$(pg scripts/hook-publish-guard.sh 'gh pr create --title x --body-file b' 06)"; RC1=$?
[ "$RC1" -eq 2 ] && ! grep -q "You ARE approved" <<<"$OUT" \
  && ok "AC1 approval for another session: not called approved" || bad "AC1 wrong-session approval (exit $RC1): $OUT"
B="$T/boot1"; mkdir -p "$B/.ai"; git_fx "$B" init -q -b main; git_fx "$B" commit -q --allow-empty -m i; git_fx "$B" checkout -q -b session-05-x
OUT="$(PATH="$T/bin:$PATH" CLAUDE_PROJECT_DIR="$B" VAJRA_ALLOW_COMMIT=05 bash scripts/hook-session-start.sh 2>&1)"
grep -q -- "--body-file <file>" <<<"$OUT" && grep -q "never \$( ) or a heredoc" <<<"$OUT" \
  && ok "AC1 the boot note under approval names --body-file" || bad "AC1 boot note: $(grep -A4 'commit approval' <<<"$OUT")"

# ==============================================================================================
# AC2 (F59/F62) — a merged session hands over to the next start.
# ==============================================================================================
if [ "$HAVE_RUDRA" = 1 ]; then
  OUT="$(cd "$RC" && "$BIN" next --steps 2>&1)"
  if grep -q "session 05 is merged — session 06 starts here" <<<"$OUT" \
     && grep -q "YOUR NEXT STEP: you are on this session's own branch" <<<"$OUT" \
     && ! grep -q "what is left in session 05" <<<"$OUT" && ! grep -q "nothing left — close the session" <<<"$OUT" \
     && grep -q "Re-run \`vajra next --steps\` after each step" <<<"$OUT"; then
    ok "AC2 rudra main at $PIN: 'session 05 is merged — session 06 starts here', branch first, no S05 ✗"
  else bad "AC2 rudra --steps: $(head -5 <<<"$OUT")"; fi
fi
if cargo test -q --lib nextstep::tests 2>&1 | grep -qE "test result: ok\. [0-9]+ passed; 0 failed"; then
  for t in a_merged_session_hands_over_to_the_next_ones_start a_lagging_counter_rolls_past_every_merged_session \
           a_green_but_unmerged_close_keeps_its_own_list the_new_sessions_branch_gets_the_normal_list no_git_means_no_rollover; do
    cargo test -q --lib "nextstep::tests::$t" -- --exact 2>&1 | grep -q "1 passed" && ok "AC2 unit: $t" || bad "AC2 unit: $t"
  done
else bad "AC2 nextstep unit tests"; fi

# ==============================================================================================
# AC3 (F60) — boot names Vajra's own uncommitted update; a hand edit is named as one.
# ==============================================================================================
if [ "$HAVE_RUDRA" = 1 ]; then
  (cd "$RC" && "$BIN" init --sync-fleet >/dev/null 2>&1)
  CH="$(git -C "$RC" diff --name-only | grep -c '^\.ai/hooks/' || true)"
  OUT="$(PATH="$T/bin:$PATH" CLAUDE_PROJECT_DIR="$RC" bash scripts/hook-session-start.sh 2>&1)"
  if [ "${CH:-0}" -ge 1 ] && grep -q "Vajra's own update" <<<"$OUT" && grep -q "Never revert" <<<"$OUT" \
     && grep -q "hook-session-start.sh" <<<"$(sed -n "/Vajra's own update/,/Never revert/p" <<<"$OUT")"; then
    ok "AC3 real sync into rudra ($CH hooks changed): boot names them Vajra's update, 'Never revert'"
  else bad "AC3 sync notice ($CH changed): $(grep -A6 'vajra update' <<<"$OUT")"; fi
  F="$RC/.ai/hooks/hook-session-guard.sh"
  if git -C "$RC" diff --quiet -- .ai/hooks/hook-session-guard.sh; then printf '\n' >> "$F"; fi
  sed -i.bak '2i\
# a hand edit
' "$F" && rm -f "$F.bak"
  OUT="$(PATH="$T/bin:$PATH" CLAUDE_PROJECT_DIR="$RC" bash scripts/hook-session-start.sh 2>&1)"
  HAND="$(sed -n '/changed by hand/,/^$/p' <<<"$OUT")"; OWN="$(sed -n "/Vajra's own update/,/Never revert/p" <<<"$OUT")"
  if grep -q "hook-session-guard.sh" <<<"$HAND" && ! grep -q "hook-session-guard.sh" <<<"$OWN"; then
    ok "AC3 a hand-edited hook is named as a hand edit, not as Vajra's"
  else bad "AC3 hand edit: $(grep -A8 'vajra update' <<<"$OUT")"; fi
fi

# ==============================================================================================
# AC4 (F61) / AC5 (F63) — the two commit blocks say how to get past them.
# ==============================================================================================
C="$T/commit"; mkdir -p "$C/.ai"; git_fx "$C" init -q -b main; git_fx "$C" commit -q --allow-empty -m i; git_fx "$C" checkout -q -b session-05-x
echo 05 > "$C/.ai/SESSION"; printf '## Current Session\n- **Number:** 05\n' > "$C/.ai/SESSION-BOOT.md"
pc() { (cd "$C" && CLAUDECODE=1 VAJRA_ALLOW_COMMIT=05 bash "$1" 2>&1); }
for i in 1 2 3 4 5; do echo "$i" > "$C/f$i"; done; git_fx "$C" add f1 f2 f3 f4 f5
OUT="$(pc "$ROOT/.githooks/pre-commit")"; RC1=$?
[ "$RC1" -ne 0 ] && grep -q "STILL STAGED — unstage first: git reset -q" <<<"$OUT" \
  && ok "AC4 a 5-file agent commit: blocked, told the files are still staged" || bad "AC4 (exit $RC1): $OUT"
git_fx "$C" reset -q
printf '## Current Session\n- **Number:** 04\n' > "$C/.ai/SESSION-BOOT.md"; git_fx "$C" add .ai/SESSION
OUT="$(pc "$ROOT/.githooks/pre-commit")"; RC1=$?
[ "$RC1" -ne 0 ] && grep -q -- '- \*\*Number:\*\* 05' <<<"$OUT" \
  && ok "AC5 SESSION 05 vs BOOT 04: blocked, names the line to set" || bad "AC5 (exit $RC1): $OUT"
git_fx "$C" reset -q
cargo test -q --lib nextstep::tests::the_counter_step_says_session_and_boot_move_together -- --exact 2>&1 | grep -q "1 passed" \
  && ok "AC5 unit: the counter step says SESSION and SESSION-BOOT move together" || bad "AC5 unit: counter step text"

# ==============================================================================================
# AC6 — no check got looser: every decision, old hooks vs new, on a listed set.
# ==============================================================================================
SAME=0; DIFF=0; LIST=""
CMDS=(
  "git push" "git push -u origin session-05-x" "git push origin HEAD" "git push origin main"
  "git push --force" "git push origin :session-05-x" "git push origin HEAD:main" "git push --tags"
  "gh pr create --title x --body-file b" "gh pr create --title x --body y" "gh pr create --head session-05-x --body-file b"
  "gh pr create --head other --body-file b" "gh pr create -R x/y --body-file b" "gh pr merge 6" "gh pr merge --squash"
  "git push && gh pr merge 6" "$HEREDOC_PR" 'gh pr create --title x --body "$(id)"' "git push; rm -rf /"
  "echo gh pr create" "git commit -m 'gh pr create'" "glab mr create" "glab mr merge 1"
  # QA rec 1: the allow-path spellings earlier cold reviews found holes in.
  "gh pr create --head=session-05-x --body-file b" "gh pr create -H session-05-x --body-file b"
  "gh pr create -Hsession-05-y --body-file b" "gh pr create --head session-05-x --head other --body-file b"
  "cd $P && git push" "cd /tmp && git push" "cd $P && gh pr create --body-file b"
  "git push origin session-05-x:main" "git push origin +session-05-x" "git push origin '+session-05-x'"
  "gh pr create --repo x/y --body-file b" 'gh pr create --title `id` --body-file b' "git push 2>&1 | tail -3"
  "gh pr create --body-file b | tail -5" "git push -uf origin session-05-x" "git -c x=y push"
)
# QA rec 2: every maturity, the explicit publish approval, and the guard switched off.
POFF="$T/proj-off"; mkdir -p "$POFF/.ai"; printf 'maturity: L3\npublish_guard: off\n' > "$POFF/.ai/CONSTRAINTS.yaml"
git_fx "$POFF" init -q -b main; git_fx "$POFF" commit -q --allow-empty -m i; git_fx "$POFF" checkout -q -b session-05-x
pgx() { # $1 mode, $2 hook, $3 command, $4 approval → exit code
  # `${e[@]+…}`: macOS bash 3.2 calls an empty array unbound under set -u; the failing pipeline
  # subshell then ran the EXIT trap and deleted $T mid-run.
  local d="$P" e=()
  case "$1" in L1|L2) e=(VAJRA_GUARD_MATURITY="$1") ;; PUB) e=(VAJRA_ALLOW_PUBLISH=1) ;; OFF) d="$POFF" ;; esac
  jq -n --arg c "$3" --arg d "$d" '{tool_input:{command:$c},cwd:$d}' \
    | env ${e[@]+"${e[@]}"} CLAUDE_PROJECT_DIR="$d" VAJRA_ALLOW_COMMIT="$4" bash "$2" >/dev/null 2>&1
}
for mode in L3 L2 L1 PUB OFF; do
  for appr in 05 "" 06; do
    for c in "${CMDS[@]}"; do
      pgx "$mode" "$OLD/publish-guard.sh" "$c" "$appr"; a=$?
      pgx "$mode" scripts/hook-publish-guard.sh "$c" "$appr"; b=$?
      if [ "$a" = "$b" ]; then SAME=$((SAME+1)); else DIFF=$((DIFF+1)); LIST="$LIST [$mode/$appr] $c: $a→$b;"; fi
    done
  done
done
for n in 1 3 4 8; do
  rm -f "$C"/g*; for i in $(seq 1 "$n"); do echo "$i" > "$C/g$i"; done
  for sb in 05 04; do
    printf '## Current Session\n- **Number:** %s\n' "$sb" > "$C/.ai/SESSION-BOOT.md"
    git_fx "$C" reset -q; git_fx "$C" add "$C"/g* .ai/SESSION .ai/SESSION-BOOT.md 2>/dev/null
    pc "$OLD/pre-commit" >/dev/null; a=$?; pc "$ROOT/.githooks/pre-commit" >/dev/null; b=$?
    if [ "$a" = "$b" ]; then SAME=$((SAME+1)); else DIFF=$((DIFF+1)); LIST="$LIST pre-commit n=$n boot=$sb: $a→$b;"; fi
  done
done
[ "$DIFF" -eq 0 ] && [ "$SAME" -ge 500 ] && ok "AC6 old vs new: $SAME of $SAME decisions identical (publish guard: ${#CMDS[@]} commands × 3 approvals × L3/L2/L1/ALLOW_PUBLISH/off; pre-commit)" \
  || bad "AC6 $DIFF decisions changed:$LIST"

# ==============================================================================================
# AC7 — carried items stay in the findings table.
# ==============================================================================================
P174="prompts/174-task-keep-testing.md"
MISS=""; for f in F47 F56 F57 F64; do grep -qE "^\| $f \|.*\| (⚪|🟡|🔴)" "$P174" || MISS="$MISS $f"; done
[ -z "$MISS" ] && ok "AC7 F47, F56, F57, F64 each in the findings table with a severity" || bad "AC7 missing:$MISS"

# QA rec 4: every rudra run above used a clone — prove the real one is as it was.
if [ "$HAVE_RUDRA" = 1 ]; then
  RUDRA_AFTER="$(git -C "$RUDRA" rev-parse HEAD 2>/dev/null; git -C "$RUDRA" status --short 2>/dev/null)"
  [ "$RUDRA_BEFORE" = "$RUDRA_AFTER" ] && ok "the real rudra is untouched (same HEAD, same git status)" \
    || bad "the real rudra changed during verify"
fi

echo ""
echo "=== session 174 verify: $PASS pass, $FAIL fail ==="
[ "$FAIL" -eq 0 ]
