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
OUT="$(CLAUDE_PROJECT_DIR="$B" bash scripts/hook-session-start.sh 2>&1)"; RCODE=$?
if [ "$RCODE" -eq 0 ] && grep -q "^Current branch: main" <<<"$OUT" && grep -q "^\[commit approval\]" <<<"$OUT"; then
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
sg 0 "rudra's-own-heredoc-commit-passes" "$RUDRA_MSG"
sg 0 "backticked-mention-passes" 'echo x `vajra next --advance` >/dev/null'
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
pg() { # pg <want-exit> <env> <command>
  jq -n --arg c "$3" '{tool_input:{command:$c}}' \
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
pg 0 $A "$(printf 'gh pr create --title S04 --body "$(cat <<EOF\nruns gh pr merge later\nEOF\n)"')"
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
pg 2 VAJRA_ALLOW_COMMIT=05 'git push'
pg 2 NONE=1 'git push'

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
