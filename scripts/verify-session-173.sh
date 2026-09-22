#!/usr/bin/env bash
# Session 173 verify — the findings from the founder's own rudra session 04 (F45–F55). Every check
# RUNS the real thing: the real hooks fed the real commands rudra's agent typed, the real binary
# against a clone of rudra pinned at its merged session 04 (3c401ec), and the unit tests by name.
# Nothing here greps source to decide a pass.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
BIN="${VAJRA_BIN:-$ROOT/target/release/vajra}"
[ -x "$BIN" ] || { echo "FAIL: $BIN not built — run cargo build --release"; exit 1; }
NEWER="$(find src Cargo.toml -newer "$BIN" -name '*' -print -quit 2>/dev/null || true)"
[ -z "$NEWER" ] || { echo "FAIL: $BIN is older than $NEWER — run: cargo build --release"; exit 1; }
# A caller's own markers must not decide any case.
unset VAJRA_ALLOW_COMMIT VAJRA_ALLOW_PUBLISH VAJRA_ENFORCE_PUBLISH VAJRA_CLOSEOUT_WAIVER
git_fx() { git -C "$1" -c user.email=v@v -c user.name=v "${@:2}"; }

# rudra, pinned at the merge of its session 04 — the run these findings came from.
RUDRA="${VAJRA_SYNC_TARGET:-$HOME/playground/rudra}"
PIN=3c401ec
RC="$T/rudra"
if [ -d "$RUDRA/.git" ] && git clone -q "$RUDRA" "$RC" 2>/dev/null && git_fx "$RC" checkout -q "$PIN" 2>/dev/null; then
  HAVE_RUDRA=1
else
  HAVE_RUDRA=0
  bad "setup rudra-at-$PIN — no clone of $RUDRA at $PIN; set VAJRA_SYNC_TARGET (a check that cannot evaluate FAILS)"
fi

# ==============================================================================================
# AC1 (F45) — boot survives a handover that names no prompt file.
# ==============================================================================================
B="$T/boot"; mkdir -p "$B/.ai"
printf '# Session Boot\n\n## Next Session\n- author the next prompt from the summary\n' > "$B/.ai/SESSION-BOOT.md"
printf '# Task\n\nNothing named here.\n' > "$B/.ai/TASK.md"
git_fx "$B" init -q -b main
mkdir -p "$T/bin"; ln -sf "$BIN" "$T/bin/vajra"; echo 01 > "$B/.ai/SESSION"
OUT="$(PATH="$T/bin:$PATH" CLAUDE_PROJECT_DIR="$B" bash scripts/hook-session-start.sh 2>&1)"; RCODE=$?
if [ "$RCODE" -eq 0 ] && grep -q "^Current branch: main" <<<"$OUT" && grep -q "^\[commit approval\]" <<<"$OUT" \
   && grep -q "what is left in session" <<<"$OUT"; then
  ok "AC1 boot-runs-to-the-end-with-no-prompt-named"
else
  bad "AC1 boot-runs-to-the-end-with-no-prompt-named — exit $RCODE, tail: $(tail -2 <<<"$OUT")"
fi

# ==============================================================================================
# AC2 (F46) — a merged ACCEPT is not sent back for review; a REJECT never reads as done.
# ==============================================================================================
cargo test -q --lib a_merged_session_with_an_accept_on_file_is_not_sent_back_for_review >"$T/ac2.log" 2>&1 \
  && grep -q "1 passed" "$T/ac2.log" \
  && ok "AC2 merged-accept-not-sent-back (unit test ran)" \
  || bad "AC2 merged-accept-not-sent-back — $(tail -3 "$T/ac2.log")"
if [ "$HAVE_RUDRA" = 1 ]; then
  OUT="$(cd "$RC" && "$BIN" next --steps 2>&1)"
  grep -q "✓ an independent review has read the work and said ACCEPT" <<<"$OUT" \
    && ! grep -q "YOUR NEXT STEP: an independent review" <<<"$OUT" \
    && ok "AC2 rudra-S04-review-read-as-done" \
    || bad "AC2 rudra-S04-review-read-as-done — $(grep -m2 -E 'review|NEXT STEP' <<<"$OUT")"
fi

# ==============================================================================================
# AC3 + AC4 (F51, F52) — the advance on rudra after its merged S04.
# ==============================================================================================
if [ "$HAVE_RUDRA" = 1 ]; then
  git_fx "$RC" checkout -q -b session-05-directive-monitors
  sed -i.bak 's/Status:\*\* DRAFT/Status:** APPROVED/' "$RC/prompts/05-task-directive-monitors.md"
  OUT="$(cd "$RC" && "$BIN" next --advance </dev/null 2>&1)"
  # Only the S04 (closing) checks are compact; S05's own design reasons still print per item.
  S04_ITEMS="$(sed -n '/already merged/,/\[vajra architect\]/p' <<<"$OUT" | grep -c '^    ✗ ' || true)"
  if grep -q "session 04 was merged; for the record" <<<"$OUT" && [ "$S04_ITEMS" = 0 ] \
     && ! grep -q "session 04 cannot close" <<<"$OUT"; then
    ok "AC3 merged-S04-reported-as-counts-not-a-wall ($(wc -l <<<"$OUT" | tr -d ' ') lines)"
  else
    bad "AC3 merged-S04-reported-as-counts-not-a-wall — $S04_ITEMS per-item lines"
  fi
  grep -A1 "^\[vajra architect\] session 05" <<<"$OUT" | grep -q "^    ✗ " \
    && ok "AC3 next-session-reasons-still-in-full" \
    || bad "AC3 next-session-reasons-still-in-full — the S05 design reason was hidden"

  OUT="$(cd "$RC" && VAJRA_SKIP_ARCHITECT_GATE=1 VAJRA_SKIP_PLANNER_GATE=1 "$BIN" next --advance </dev/null 2>&1)"
  if grep -q "not asked: no terminal to ask on" <<<"$OUT" && [ "$(cat "$RC/.ai/SESSION")" = 05 ] \
     && ! grep -q "\[y/N\]" <<<"$OUT"; then
    ok "AC4 no-keyboard-advance-says-nobody-was-asked"
  else
    bad "AC4 no-keyboard-advance-says-nobody-was-asked — $(tail -3 <<<"$OUT")"
  fi
fi
if [ "$HAVE_RUDRA" = 1 ]; then
  C3="$T/rudra3"; git clone -q "$RUDRA" "$C3" && git_fx "$C3" checkout -q "$PIN" && git_fx "$C3" checkout -q -b session-05-directive-monitors
  sed -i.bak 's/Status:\*\* DRAFT/Status:** APPROVED/' "$C3/prompts/05-task-directive-monitors.md"
  OUT="$(cd "$C3" && echo n | VAJRA_SKIP_ARCHITECT_GATE=1 VAJRA_SKIP_PLANNER_GATE=1 "$BIN" next --advance 2>&1)"
  [ "$(cat "$C3/.ai/SESSION")" = 04 ] && grep -q "Aborted" <<<"$OUT" \
    && ok "AC4 a-piped-n-still-stops-the-advance" || bad "AC4 a-piped-n-still-stops-the-advance — $(tail -2 <<<"$OUT")"
fi
cargo test -q --lib no_step_tells_the_agent_to_answer_the_advance_question >"$T/ac4.log" 2>&1 \
  && grep -q "1 passed" "$T/ac4.log" \
  && ok "AC4 no-step-says-echo-y (unit test over every step ran)" \
  || bad "AC4 no-step-says-echo-y — $(tail -3 "$T/ac4.log")"
E="$T/empty"; mkdir -p "$E/.ai" "$E/prompts" "$E/sessions"; echo 01 > "$E/.ai/SESSION"; git_fx "$E" init -q -b main

# ==============================================================================================
# AC5 (F50, F44) — the session guard reads commands, not commit-message prose.
# ==============================================================================================
G="$T/sg"; mkdir -p "$G/.ai"
printf 'maturity: L2\nsession:\n  one_session_per_chat: true\n' > "$G/.ai/CONSTRAINTS.yaml"; echo 04 > "$G/.ai/SESSION"
sg() { # sg <want-exit> <label> <command>
  printf '4\tSID\n' > "$G/.ai/.session-owner"
  jq -n --arg c "$3" '{session_id:"SID",tool_input:{command:$c}}' \
    | CLAUDE_PROJECT_DIR="$G" bash scripts/hook-session-guard.sh >/dev/null 2>&1
  local got=$?; [ "$got" = "$1" ] && ok "AC5 $2" || bad "AC5 $2 — exit $got, want $1"
}
RUDRA_MSG="$(printf 'git commit -q -m "$(cat <<'"'"'EOF'"'"'\nS04 setup: advance session pointer 03 → 04\n\nvajra next --advance: .ai/SESSION=04, boot + task pointers synced.\nEOF\n)"')"
# F50, after five review passes: no exception. rudra's heredoc message blocks again (as before
# S173); the one-line quoted mention passes (as before S173); the block message names the way out.
sg 2 "rudra's-own-heredoc-commit-blocks-as-before-S173" "$RUDRA_MSG"
sg 0 "quoted-mention-passes" 'git commit -m "note: run vajra next --advance in the next chat"'
sg 0 "message-from-a-file-passes" 'git commit -F /tmp/msg.txt'
printf '4\tSID\n' > "$G/.ai/.session-owner"
MSG="$(jq -n --arg c "$RUDRA_MSG" '{session_id:"SID",tool_input:{command:$c}}' | CLAUDE_PROJECT_DIR="$G" bash scripts/hook-session-guard.sh 2>&1 >/dev/null)"
grep -q "git commit -F <file>" <<<"$MSG" && ok "AC5 the-block-names-git-commit-F" || bad "AC5 the-block-names-git-commit-F"
# The cold review's fakest green, reversed: bash RUNS backticks and $( ) — those are commands.
sg 2 "backticked-advance-blocked" 'echo x `vajra next --advance` >/dev/null'
sg 2 "advance-inside-dollar-paren-in-quotes-blocked" 'echo "$(vajra next --advance)"'
sg 2 "advance-on-the-heredoc-opening-line-blocked" "$(printf 'cat <<EOF >n.md && vajra next --advance\nx\nEOF')"
sg 2 "advance-inside-bash-c-blocked" "$(printf 'bash -c "\nvajra next --advance\n"')"
sg 2 "advance-in-a-heredoc-fed-to-bash-blocked" "$(printf 'bash <<EOF\nvajra next --advance\nEOF')"
sg 2 "real-advance-blocked" 'vajra next --advance'
sg 2 "piped-advance-blocked" 'echo y | vajra next --advance 2>&1 | tail'
sg 2 "next-branch-blocked" 'git checkout -b session-05-x'
sg 2 "heredoc-then-real-advance-blocked" "$(printf 'cat <<EOF > n.md\nnote\nEOF\nvajra next --advance')"

# ==============================================================================================
# AC6 (F53, F54) — the checklist names the advice answers and the stamp, LAST.
# ==============================================================================================
OUT="$(cd "$E" && "$BIN" next --steps 2>&1)"
ADV=$(grep -n "advisor recommendation has an answer" <<<"$OUT" | cut -d: -f1)
STAMP=$(grep -n "stamp matches the finished work (do this LAST)" <<<"$OUT" | cut -d: -f1)
MERGE=$(grep -n "the work is merged and the branch is gone" <<<"$OUT" | cut -d: -f1)
if [ -n "$ADV" ] && [ -n "$STAMP" ] && [ -n "$MERGE" ] && [ "$ADV" -lt "$STAMP" ] && [ "$((STAMP + 1))" = "$MERGE" ]; then
  ok "AC6 advice-then-stamp-last-then-merge"
else
  bad "AC6 advice-then-stamp-last-then-merge — lines adv=$ADV stamp=$STAMP merge=$MERGE"
fi
# The binary prints the how for the NEXT step only; the unit test reads every step's how.
cargo test -q --lib advice_and_the_stamp_are_steps_and_the_stamp_is_last_before_merge >"$T/ac6.log" 2>&1 \
  && grep -q "1 passed" "$T/ac6.log" \
  && ok "AC6 exact-formats-named (unit test ran)" \
  || bad "AC6 exact-formats-named — $(tail -3 "$T/ac6.log")"

# ==============================================================================================
# AC7 (F55) — the launch approval ships the session's own branch; nothing more.
# ==============================================================================================
P="$T/pg"; mkdir -p "$P/.ai"; printf 'maturity: L2\n' > "$P/.ai/CONSTRAINTS.yaml"
git_fx "$P" init -q -b main; git_fx "$P" checkout -qb session-04-partial-fill
pg() { # pg <want-exit> <env> <command> [cwd] — the hook gets `cwd` as Claude Code sends it
  jq -n --arg c "$3" --arg d "${4:-$P}" '{cwd:$d,tool_input:{command:$c}}' \
    | env $2 CLAUDE_PROJECT_DIR="$P" bash scripts/hook-publish-guard.sh >/dev/null 2>&1
  local got=$?; [ "$got" = "$1" ] && ok "AC7 [$2] $3" || bad "AC7 [$2] $3 — exit $got, want $1"
}
A=VAJRA_ALLOW_COMMIT=04
pg 0 $A 'git push -u origin session-04-partial-fill'
pg 0 $A 'git push'
pg 0 $A 'gh pr create --base main --title "S04" --body "x"'
pg 2 $A 'gh pr merge 5 --merge'
pg 2 $A 'git push -u origin session-04-partial-fill && gh pr merge 5'
pg 2 $A 'git push origin main'
pg 2 $A 'git push origin HEAD:main'
pg 2 $A 'git push --force'
pg 2 $A 'git push origin +session-04-partial-fill'
pg 2 $A 'git push origin --delete session-04-partial-fill'
pg 2 $A 'git push --tags'
pg 2 $A 'git push origin session-03-old'
pg 0 $A "cd $P && git push -u origin session-04-partial-fill 2>&1 | tail -5"
pg 2 $A "$(printf 'gh pr create --title S04 --body "$(cat <<EOF\nruns gh pr merge later\nEOF\n)"')"
# The S173 design-advisor's forms a block-list missed — each must fall back to the human.
pg 2 $A 'git push origin HEAD:session-05-y'
pg 2 $A 'git push origin :session-05-y'
pg 2 $A 'git push -uf origin session-04-partial-fill'
pg 2 $A 'git push origin "+session-04-partial-fill"'
pg 2 $A 'git push --no-verify'
pg 2 $A 'git push -o merge_request.create -o merge_request.target=main'
pg 2 $A 'git push https://other.example/repo.git HEAD'
pg 2 $A 'git push origin HEAD:feature-x'
pg 2 $A 'git push origin feature-x'
pg 2 $A 'git push --follow-tags'
pg 2 $A 'cd ../other-repo && git push'
pg 2 $A 'gh pr create --head session-05-y --title x'
pg 2 $A 'gh pr create --title x && gh api -X PUT repos/o/r/pulls/5/merge'
# Cold review recs 3-4: forms the first S173 cut let through — each must reach the human.
pg 2 $A 'gh pr create -Hsession-03-y --title x'
pg 2 $A 'gh pr create --head session-04-partial-fill --head session-03-y --title x'
pg 2 $A 'gh pr create --he\\ad session-03-y --title x'
pg 0 $A 'gh pr create --head session-04-partial-fill --title x'
# Cold review pass 5 R1: the shell's directory, not the project's, decides. A worktree on another
# session's branch, a nested clone, or no cwd at all gets no permission.
git_fx "$P" commit -q --allow-empty -m seed
git_fx "$P" branch session-03-y
git_fx "$P" worktree add -q "$P/.wt/s03" session-03-y 2>/dev/null
mkdir -p "$P/nested"; git_fx "$P/nested" init -q -b main; git_fx "$P/nested" checkout -qb session-04-partial-fill
pg 2 $A 'git push -u origin HEAD' "$P/.wt/s03"
pg 2 $A 'gh pr create --title x' "$P/.wt/s03"
pg 2 $A 'git push -u origin HEAD' "$P/nested"
pg 2 $A 'git push' "/tmp"
jq -n --arg c 'git push' '{tool_input:{command:$c}}' | env $A CLAUDE_PROJECT_DIR="$P" bash scripts/hook-publish-guard.sh >/dev/null 2>&1
[ $? = 2 ] && ok "AC7 no-cwd-no-permission" || bad "AC7 no-cwd-no-permission"
pg 2 VAJRA_ALLOW_COMMIT=05 'git push'
pg 2 NONE=1 'git push'
# ...and with NO approval at all, what bash would run is still seen (the S173 regression, rec 3).
pg 2 NONE=1 'echo `git push -f --no-verify origin HEAD:main`'
pg 2 NONE=1 "$(printf 'cat <<EOF >/dev/null; git push -f --no-verify origin HEAD:main\nx\nEOF')"
pg 2 NONE=1 "$(printf 'bash -c "\ngit push -f origin main\n"')"
pg 2 NONE=1 'echo "$(git push -f origin main)"'
pg 0 NONE=1 'git commit -m "we will git push later"'

# ==============================================================================================
# AC5 + AC7, old rule vs new on a LIST of shapes (cold review pass 2 rec 5; relabelled pass 4 rec 5): nothing bash would RUN that the guard blocked
# before S173 gets through now. Every form the two reviews found × every trigger, with NO approval,
# through the hook as it was at f02d8e1 and as it is today. A list of known cases can be patched
# example by example; this compares the two rules on all of them at once.
# ==============================================================================================
OLDH="$T/oldhooks"; mkdir -p "$OLDH"
git show f02d8e1:scripts/hook-publish-guard.sh > "$OLDH/pub.sh"
git show f02d8e1:scripts/hook-session-guard.sh > "$OLDH/ses.sh"
PROP_BAD=0; PROP_N=0
forms() { # forms <trigger> — each line of output is one command (NUL-separated), all of which RUN <trigger>
  local t="$1"
  printf '%s\0' \
    "$t" \
    "echo x; $t" \
    "echo \`$t\`" \
    "echo \"\$($t)\"" \
    "$(printf 'cat <<EOF > n.md\n$(%s)\nEOF' "$t")" \
    "$(printf 'cat <<EOF | bash\n%s\nEOF' "$t")" \
    "$(printf 'bash -s <<EOF\n%s\nEOF' "$t")" \
    "$(printf 'cat <<EOF\nEOF\n%s\nEOF' "$t")" \
    "$(printf "echo '<<EOF'\n%s\nEOF" "$t")" \
    "$(printf "# don't push yet\n%s\necho 'done'" "$t")" \
    "$(printf 'cat <<EOF >/dev/null; %s\nx\nEOF' "$t")" \
    "$(printf 'bash -c "\n%s\n"' "$t")" \
    "eval \"$t\"" \
    "$(printf 'git commit -m "$(cat <<'"'"'EOF'"'"'\nmsg\nEOF\n)" && %s' "$t")" \
    "$(printf "echo 'x \"\$(cat <<'EOF'\n'; %s; echo '\nEOF\n)\"'" "$t")" \
    "$(printf 'git commit -m "$(cat <<'"'"'EOF'"'"'\nmsg\nEOF\n%s\nEOF\n)"' "$t")" \
    "$(printf 'git commit -m "$(cat <<-'"'"'EOF'"'"'\nmsg\n\tEOF\n%s\nEOF\n)"' "$t")" \
    "$(printf 'git commit -m "$(cat <<'"'"'EOF'"'"'\nmsg\n  EOF\n%s\nEOF\n)"' "$t")" \
    "$(printf 'echo "it'"'"'s" && git commit -m "$(cat <<'"'"'EOF'"'"'\n'"'"'; %s; echo '"'"'\nEOF\n)"' "$t")" \
    "$(printf 'echo \\'"'"' ; git commit -m "$(cat <<'"'"'EOF'"'"'\n'"'"'; %s; echo '"'"'\nEOF\n)"' "$t")" \
    "$(printf "echo 'abc\ngit commit -m \"\$(cat <<'EOF'\n'; %s; echo '\nEOF\n)\"'" "$t")" \
    "$(printf 'cat <<EOF\nit'"'"'s\nEOF\ngit commit -m "$(cat <<'"'"'EOF'"'"'\n'"'"'; %s; echo '"'"'\nEOF\n)"' "$t")" \
    "$(printf 'echo "it'"'"'s" '"'"'x git commit -m "$(cat <<'"'"'EOF'"'"'\n'"'"'; %s; echo '"'"'\nEOF\n)"' "$t")" \
    "$(printf 'echo a \\\n; %s' "$t")" \
    "$(printf 'echo a\r\n%s\r' "$t")" \
    "$(printf 'cat <<<"x"; %s' "$t")" \
    "$(printf '(( 1 )) && %s' "$t")" \
    "$(printf 'git commit -m "$(cat <<'"'"'D'"'"'\n)"\n%s\nD\n)"' "$t")"
}
# (The last is cold review pass 5's R2: macOS /bin/bash 3.2 ends the `$( )` at the body's `)"`
# line and RUNS the next line — confirmed on this machine.)
# (The last shape is cold review pass 4's: quote marks count EVEN while bash is inside a quote.
# The 3bad781 exception hid it — exit 0 — and today's keeps it visible.)
prop() { # prop <old-hook> <new-hook> <fixture-root> <trigger> [session-owner-line]
  local old="$1" new="$2" root="$3" t="$4" own="${5:-}" c o n
  while IFS= read -r -d '' c; do
    PROP_N=$((PROP_N+1))
    [ -n "$own" ] && printf '%s' "$own" > "$root/.ai/.session-owner"
    o=$(jq -n --arg c "$c" '{session_id:"SID",tool_input:{command:$c}}' | CLAUDE_PROJECT_DIR="$root" bash "$old" >/dev/null 2>&1; echo $?)
    [ -n "$own" ] && printf '%s' "$own" > "$root/.ai/.session-owner"
    n=$(jq -n --arg c "$c" '{session_id:"SID",tool_input:{command:$c}}' | CLAUDE_PROJECT_DIR="$root" bash "$new" >/dev/null 2>&1; echo $?)
    if [ "$o" = 2 ] && [ "$n" != 2 ]; then PROP_BAD=$((PROP_BAD+1)); echo "  regressed: $(printf '%s' "$c" | tr '\n' '⏎')"; fi
  done < <(forms "$t")
}
prop "$OLDH/pub.sh" scripts/hook-publish-guard.sh "$P" 'git push -f origin HEAD:main'
prop "$OLDH/pub.sh" scripts/hook-publish-guard.sh "$P" 'gh pr merge 5 --admin'
prop "$OLDH/ses.sh" scripts/hook-session-guard.sh "$G" 'vajra next --advance' "$(printf '4\tSID\n')"
prop "$OLDH/ses.sh" scripts/hook-session-guard.sh "$G" 'git checkout -b session-05-x' "$(printf '4\tSID\n')"
[ "$PROP_BAD" = 0 ] && ok "AC5+AC7 old-vs-new: 0 of $PROP_N listed commands went from blocked to allowed (no approval)" \
  || bad "AC5+AC7 old-vs-new: $PROP_BAD of $PROP_N listed commands went from blocked to allowed"

# The same forms WITH the launch approval: the agent may push its own branch only in plain shapes —
# none of these (each also runs a merge or a push to main) may ride the F55 permission.
APPROVED_BAD=0; APPROVED_N=0
for t in 'gh pr merge 5 --admin' 'git push -f origin HEAD:main'; do
  while IFS= read -r -d '' c; do
    for wrap in "gh pr create --title x --body \"\$(cat <<EOF
\$($t)
EOF
)\"" "$c"; do
      APPROVED_N=$((APPROVED_N+1))
      n=$(jq -n --arg c "$wrap" --arg d "$P" '{cwd:$d,tool_input:{command:$c}}' | env VAJRA_ALLOW_COMMIT=04 CLAUDE_PROJECT_DIR="$P" bash scripts/hook-publish-guard.sh >/dev/null 2>&1; echo $?)
      [ "$n" = 2 ] || { APPROVED_BAD=$((APPROVED_BAD+1)); echo "  let through: $(printf '%s' "$wrap" | tr '\n' '⏎')"; }
    done
  done < <(forms "$t")
done
[ "$APPROVED_BAD" = 0 ] && ok "AC7 old-vs-new: 0 of $APPROVED_N listed merge/main commands ride the launch approval" \
  || bad "AC7 old-vs-new: $APPROVED_BAD of $APPROVED_N listed merge/main commands rode the launch approval"
# ...and the shapes an agent really writes still go through with it.
pg 2 $A "$(printf 'gh pr create --title S04 --body "$(cat <<'"'"'EOF'"'"'\n## Summary\nEOF\n)"')"
pg 2 $A 'gh pr create -R other/repo --title x'
pg 2 $A 'gh pr create -Rother/repo --title x'
pg 2 $A 'gh pr create -dR other/repo --title x'
pg 2 $A 'gh pr create --repo=other/repo --title x'
pg 0 $A 'gh pr create --title "S04: x" --body-file sessions/session-04-summary.md'
# rudra S04's agent's own shapes (from its transcript): `cd <project>; …` with the output tail.
pg 0 $A "cd $P; git push -u origin session-04-partial-fill 2>&1 | tail -8"
pg 0 $A "cd $P; gh pr create --base main --head session-04-partial-fill --title \"S04: x\" --body \"Session 04 — (RETRANSMIT_GREEN, transmit_events==2)\""
pg 2 $A "cd /tmp; git push -u origin session-04-partial-fill"
pg 2 $A "$(printf 'gh pr create --title x --body "$(cat <<EOF\nSummary\n$(gh pr merge 5 --admin)\nEOF\n)"')"

# ==============================================================================================
# AC8 + AC9 (F49) — sync says whose files it wrote; the suite and formatter; a clean sync.
# ==============================================================================================
if [ "$HAVE_RUDRA" = 1 ]; then
  C2="$T/rudra2"; git clone -q "$RUDRA" "$C2" && git_fx "$C2" checkout -q "$PIN"
  OUT="$(cd "$C2" && "$BIN" init --sync-fleet 2>&1)"
  grep -qE "^0 created, [0-9]+ upgraded, .*0 drifted" <<<"$OUT" \
    && ok "AC9 sync-fleet-upgrades-rudra-cleanly ($(grep -cE '^  upgrade' <<<"$OUT") files)" \
    || bad "AC9 sync-fleet-upgrades-rudra-cleanly — $(tail -2 <<<"$OUT")"
  grep -q "are Vajra's, not your edits" <<<"$OUT" \
    && ok "AC8 sync-names-whose-files-it-wrote" || bad "AC8 sync-names-whose-files-it-wrote"
fi
cargo test -q >"$T/test.log" 2>&1 \
  && ok "AC9 cargo-test-green ($(grep -h -oE '[0-9]+ passed' "$T/test.log" | sort -t' ' -k1 -n | tail -1))" \
  || bad "AC9 cargo-test-green — $(grep -E 'FAILED|panicked' "$T/test.log" | head -3)"
cargo fmt --check >/dev/null 2>&1 && ok "AC9 cargo-fmt-clean" || bad "AC9 cargo-fmt-clean"

echo ""
echo "=== Session 173 verify: $PASS pass, $FAIL fail ==="
[ "$FAIL" -eq 0 ]
