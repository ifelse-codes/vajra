#!/usr/bin/env bash
# Session 172 verify — the findings from the founder's own rudra session 03 (F35–F43), plus the
# carried belt-split test. Every check RUNS the real thing: the real binary against a real git
# fixture, the real hooks with a real transcript file, the real close-gate function out of the
# scaffold. Three checks DO read source, and say so in their names (`*-wires-*`): they prove the
# new close gates are CALLED, which running the helper alone cannot show. Everything else executes.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
BIN="${VAJRA_BIN:-$ROOT/target/release/vajra}"
[ -x "$BIN" ] || { echo "FAIL: $BIN not built — run cargo build --release"; exit 1; }
# A caller's own markers must not decide any case (the S172 qa-specialist's rec 1).
unset VAJRA_ALLOW_COMMIT VAJRA_CLOSEOUT_WAIVER VAJRA_SKIP_QA_GATE VAJRA_SKIP_DEMOER_GATE

git_fx() { git -C "$1" -c user.email=v@v -c user.name=v "${@:2}"; }

# ==============================================================================================
# AC1 — a session the human already merged is REPORTED on, not blocked (F39); an unmerged one
#       still blocks. Both run the real `vajra next --advance` against a real repo.
# ==============================================================================================
mk_repo() { # mk_repo <dir> <put-summary-on-main: yes|no>
  local d="$1" on_main="$2"
  mkdir -p "$d/.ai" "$d/prompts" "$d/sessions"
  printf 'maturity: L2\n' > "$d/.ai/CONSTRAINTS.yaml"
  printf '02\n' > "$d/.ai/SESSION"
  printf '# S02\n\n## Next session candidates\n1. a\n2. b\n3. c\n' > "$d/sessions/session-02-summary.md"
  # Well-formed AND approved: the Analyst gate must not be what stops this fixture — the point is
  # what the CLOSING gates do (S122: a fixture that goes red for the wrong reason proves nothing).
  printf '# Session 03\n\n> **Status:** APPROVED\n\n## Type\n- **CODE**\n\n## Goal\n- ship x\n\n## Deliverables\n1. x\n\n## Acceptance\n1. x works\n\n## Design\n- design-significant: no — pure fix\n\n## Plan\n- step 1 — do x. covers: 1\n\n## Guardrails\n- none\n\n## Delta\n- `+` x\n' \
    > "$d/prompts/03-task-fx.md"
  git_fx "$d" init -q -b main
  if [ "$on_main" = yes ]; then
    git_fx "$d" add -A; git_fx "$d" commit -qm seed
  else
    # The summary exists in the worktree but was never merged: seed main without it.
    git_fx "$d" add .ai prompts; git_fx "$d" commit -qm seed
  fi
  git_fx "$d" checkout -qb session-03-x
}

MERGED="$T/merged"; mk_repo "$MERGED" yes
OUT="$(cd "$MERGED" && echo n | "$BIN" next --advance 2>&1)"
grep -q "already merged by you" <<<"$OUT" \
  && ok "AC1 merged-session-checks-report" \
  || bad "AC1 merged-session-checks-report — no 'already merged by you' in: $OUT"
grep -q "not re-running it here" <<<"$OUT" \
  && ok "AC1 no-live-rerun-after-merge" \
  || bad "AC1 no-live-rerun-after-merge — the slow re-runs still fired: $OUT"

UNMERGED="$T/unmerged"; mk_repo "$UNMERGED" no
OUT="$(cd "$UNMERGED" && echo n | "$BIN" next --advance 2>&1)"; RC=$?
if grep -q "already merged by you" <<<"$OUT"; then
  bad "AC1 unmerged-session-still-blocks — an unmerged session was treated as shipped"
elif grep -q "no approved, well-formed prompt" <<<"$OUT"; then
  bad "AC1 unmerged-session-still-blocks — stopped at the Analyst gate, so the closing gates never ran"
elif grep -qE "cannot close" <<<"$OUT"; then
  ok "AC1 unmerged-session-still-blocks ($(grep -oE '\[vajra [a-z]+\]' <<<"$OUT" | head -1))"
else
  bad "AC1 unmerged-session-still-blocks — nothing blocked (rc=$RC): $OUT"
fi

# ==============================================================================================
# AC2 — what advance stopped blocking, the CLOSE check now blocks: check_live_gate runs the real
#       binary and fails on a non-zero gate AND on a build too old to know the flag.
# ==============================================================================================
run_live_gate() { # run_live_gate <scaffold|own> <fake-vajra-body>   -> RESULT=PASS|FAIL
  local which="$1" body="$2" d="$T/lg.$RANDOM"
  mkdir -p "$d/bin"
  cp "$ROOT/scripts/verify-closeout$([ "$which" = scaffold ] && echo -scaffold).sh" "$d/gate.sh"
  printf '#!/bin/sh\n%s\n' "$body" > "$d/bin/vajra"; chmod +x "$d/bin/vajra"
  # The fake `vajra` must be the one that answers: both copies resolve PATH-first, and a missing
  # binary would green this check on the cannot-evaluate branch instead of the branch it names
  # (S172 cold review, the FAKEST GREEN).
  ( cd "$d" && PATH="$d/bin:/usr/bin:/bin:/usr/sbin:/sbin" bash -c '
      source /dev/stdin <<<"$(sed -n "/^check_live_gate()/,/^}/p" gate.sh)"
      N=72; ARTIFACTS=.
      ok()  { echo "RESULT=PASS"; }
      bad() { echo "RESULT=FAIL"; }
      waiver_ok() { false; }
      check_live_gate advice-answered --check-advice "=== advice: dispositions for session" "fix it"
      cat advice-answered.log
    ' )
}
OUT="$(run_live_gate scaffold 'echo "=== advice: dispositions for session 72 ==="; exit 0')"
grep -q "RESULT=PASS" <<<"$OUT" && ok "AC2 close-check-passes-a-green-gate" \
  || bad "AC2 close-check-passes-a-green-gate — $OUT"
OUT="$(run_live_gate scaffold 'echo "=== advice: dispositions for session 72 ==="; exit 1')"
grep -q "RESULT=FAIL" <<<"$OUT" && ok "AC2 close-check-blocks-unanswered-advice" \
  || bad "AC2 close-check-blocks-unanswered-advice — $OUT"
OUT="$(run_live_gate scaffold 'echo "=== vajra: handoff packet ==="; exit 0')"
grep -q "RESULT=FAIL" <<<"$OUT" && ok "AC2 close-check-fails-on-a-build-that-cannot-evaluate" \
  || bad "AC2 close-check-fails-on-a-build-that-cannot-evaluate — $OUT"
OUT="$(run_live_gate own 'echo "=== advice: dispositions for session 72 ==="; exit 1')"
if grep -q "RESULT=FAIL" <<<"$OUT" && grep -q "binary: .*/bin/vajra" <<<"$OUT"; then
  ok "AC2 same-check-in-vajras-own-gate"
elif grep -q "RESULT=FAIL" <<<"$OUT"; then
  bad "AC2 same-check-in-vajras-own-gate — FAILED on the wrong branch (the gate never ran the binary)"
else
  bad "AC2 same-check-in-vajras-own-gate — $OUT"
fi
for flag in --check-advice --check-qa --check-fidelity-handoff; do
  grep -q -- "check_live_gate .* $flag " "$ROOT/scripts/verify-closeout.sh" \
    && ok "AC2 own-gate-wires $flag" || bad "AC2 own-gate-wires $flag"
done
for flag in --check-advice --check-qa --check-demo --check-fidelity-handoff; do
  grep -q -- "check_live_gate .* $flag " "$ROOT/scripts/verify-closeout-scaffold.sh" \
    && ok "AC2 project-gate-wires $flag" || bad "AC2 project-gate-wires $flag"
done

# ==============================================================================================
# AC3 — the design check sees rudra's ADR layout (F35), and a made-up id still blocks.
# ==============================================================================================
D="$T/adr"; mkdir -p "$D/docs/ADR" "$D/prompts" "$D/.ai"
printf 'maturity: L2\n' > "$D/.ai/CONSTRAINTS.yaml"
printf '# ADR-010: Foundation scope\n' > "$D/docs/ADR/ADR-010-foundation.md"
design_prompt() { printf '# S05\n\n## Type\n- **CODE**\n\n## Design\n- design-significant: yes\n- %s\n' "$1" > "$D/prompts/05-task-fx.md"; }
design_prompt "the slice rests on ADR-010's locked scope, extending it at the adapter boundary."
OUT="$(cd "$D" && "$BIN" next --design 05 2>&1)"
grep -q "ADR-0010" <<<"$OUT" && ok "AC3 capital-ADR-folder-is-read" \
  || bad "AC3 capital-ADR-folder-is-read — spine empty: $OUT"
( cd "$D" && "$BIN" next --check-design 05 >/dev/null 2>&1 ) \
  && ok "AC3 real-citation-passes" || bad "AC3 real-citation-passes"
design_prompt "the slice rests on ADR-077's locked scope, extending it at the adapter boundary."
( cd "$D" && "$BIN" next --check-design 05 >/dev/null 2>&1 ) \
  && bad "AC3 made-up-citation-blocks — ADR-077 passed" || ok "AC3 made-up-citation-blocks"

# ==============================================================================================
# AC4 — the belt split is executable (S171 pass-3 rec 7): the real test binary runs here, and a
#       direct probe of the real hook proves the agent case independently of it.
# ==============================================================================================
if cargo test -q --test commit_belt >"$T/belt.log" 2>&1; then
  ok "AC4 commit-belt-tests-pass ($(grep -oE '[0-9]+ passed' "$T/belt.log" | head -1))"
else
  bad "AC4 commit-belt-tests-pass — $(tail -3 "$T/belt.log")"
fi
# Negative control (S172 cold review rec 5): with agent detection disabled in a COPY of the real
# hook, the agent cases must stop blocking — otherwise the tests prove nothing about the hook.
MUT="$T/mut"; mkdir -p "$MUT/.githooks"
sed 's/^  agent_shell=1$/  agent_shell=0/' .githooks/pre-commit > "$MUT/.githooks/pre-commit"
chmod +x "$MUT/.githooks/pre-commit"
grep -q "agent_shell=0" "$MUT/.githooks/pre-commit" || bad "AC4 mutation-applied"
git_fx "$MUT" init -q -b main >/dev/null 2>&1
git_fx "$MUT" add -A >/dev/null; git_fx "$MUT" commit -qm seed >/dev/null
git_fx "$MUT" config core.hooksPath .githooks; git_fx "$MUT" checkout -qb session-07-x
echo x > "$MUT/f.txt"; git_fx "$MUT" add f.txt >/dev/null
if ( cd "$MUT" && env -u VAJRA_ALLOW_COMMIT CLAUDECODE=1 git -c user.email=v@v -c user.name=v commit -qm t >/dev/null 2>&1 ); then
  ok "AC4 the-tests-would-go-red-if-agent-detection-were-removed (mutant lets an unapproved agent commit)"
else
  bad "AC4 the-tests-would-go-red-if-agent-detection-were-removed — the mutant still blocked, so the cases do not bind on that code"
fi
B="$T/belt"; mkdir -p "$B/.githooks"
git_fx "$B" init -q -b main >/dev/null 2>&1
cp .githooks/pre-commit "$B/.githooks/"; chmod +x "$B/.githooks/pre-commit"
git_fx "$B" add -A >/dev/null; git_fx "$B" commit -qm seed >/dev/null
git_fx "$B" config core.hooksPath .githooks
git_fx "$B" checkout -qb session-07-x
echo x > "$B/f.txt"; git_fx "$B" add f.txt >/dev/null
( cd "$B" && env -u VAJRA_ALLOW_COMMIT CLAUDECODE=1 git -c user.email=v@v -c user.name=v commit -qm t >/dev/null 2>&1 ) \
  && bad "AC4 real-hook-stops-an-unapproved-agent" || ok "AC4 real-hook-stops-an-unapproved-agent"
( cd "$B" && env -u CLAUDECODE -u CLAUDE_CODE_ENTRYPOINT -u CURSOR_TRACE_ID -u VAJRA_AGENT -u VAJRA_ALLOW_COMMIT \
    git -c user.email=v@v -c user.name=v commit -qm t >/dev/null 2>&1 ) \
  && ok "AC4 real-hook-lets-the-human-through" || bad "AC4 real-hook-lets-the-human-through"

# ==============================================================================================
# AC5 — the reading pause names only what was NOT read this session (F36).
# ==============================================================================================
L="$T/loader"; mkdir -p "$L/.ai"
printf 'maturity: L2\ncopilot:\n  on:\n    - "prompts/* => .ai/TASK.md, .ai/ROADMAP.md | re-read the contract"\n' \
  > "$L/.ai/CONSTRAINTS.yaml"
loader() { # loader <transcript-body> <state-key>
  printf '%s\n' "$1" > "$L/t.jsonl"
  echo "{\"session_id\":\"$2\",\"transcript_path\":\"$L/t.jsonl\",\"tool_input\":{\"file_path\":\"$L/prompts/03-task-x.md\"}}" \
    | CLAUDE_PROJECT_DIR="$L" VAJRA_COPILOT_STATE_DIR="$L/st-$2" bash "$ROOT/scripts/hook-copilot-loader.sh" 2>&1
  echo "exit=$?"
}
OUT="$(loader '{}' none)"
grep -q "exit=2" <<<"$OUT" && grep -q "TASK.md" <<<"$OUT" && grep -q "ROADMAP.md" <<<"$OUT" \
  && ok "AC5 unread-files-still-pause" || bad "AC5 unread-files-still-pause — $OUT"
OUT="$(loader '{"x":"----- .ai/TASK.md -----"}' one)"
if grep -q "exit=2" <<<"$OUT" && grep -q "ROADMAP.md" <<<"$OUT" && ! grep -q "TASK.md" <<<"$OUT"; then
  ok "AC5 only-the-unread-file-is-named"
else bad "AC5 only-the-unread-file-is-named — $OUT"; fi
OUT="$(loader "{\"x\":\"----- .ai/TASK.md -----\"}
{\"tool_input\":{\"file_path\":\"$L/.ai/ROADMAP.md\"}}" all)"
grep -q "exit=0" <<<"$OUT" && ! grep -q "paused" <<<"$OUT" \
  && ok "AC5 no-pause-when-everything-was-read" || bad "AC5 no-pause-when-everything-was-read — $OUT"

# ==============================================================================================
# AC6 — boot warns when the handover names a prompt file that does not exist (F38).
# ==============================================================================================
H="$T/boot"; mkdir -p "$H/.ai" "$H/prompts"
printf '# Task\n\nRead prompt: author `prompts/03-execution-oms-ems.md` first.\n' > "$H/.ai/TASK.md"
: > "$H/prompts/03-task-execution-oms-ems.md"
OUT="$(CLAUDE_PROJECT_DIR="$H" bash scripts/hook-session-start.sh 2>&1)"
grep -q "the handover names prompts/03-execution-oms-ems.md" <<<"$OUT" \
  && grep -q "Did it mean prompts/03-task-execution-oms-ems.md" <<<"$OUT" \
  && ok "AC6 missing-prompt-warned-with-the-right-suggestion" \
  || bad "AC6 missing-prompt-warned-with-the-right-suggestion — $OUT"
OUT="$(bash scripts/hook-session-start.sh 2>&1)"
# Match the warning LINE, not the words: boot dumps STATE.md, which describes this very check.
# A placeholder like `prompts/173-task-<slug>.md` is a shape, not a missing file, and must not warn.
grep -q "^\[hook warn\] the handover names" <<<"$OUT" \
  && bad "AC6 no-false-warning-on-this-repo — $(grep -m1 '^\[hook warn\] the handover' <<<"$OUT")" \
  || ok "AC6 no-false-warning-on-this-repo"
grep -q "PLAIN WORDS" <<<"$OUT" && ok "AC6 boot-demands-plain-words (F42)" \
  || bad "AC6 boot-demands-plain-words (F42)"

# ==============================================================================================
# AC7 — the suite, the formatter, and the fixes reaching a real project.
# ==============================================================================================
cargo test -q >"$T/test.log" 2>&1 \
  && ok "AC7 cargo-test-green ($(grep -h -oE '[0-9]+ passed' "$T/test.log" | head -1))" \
  || bad "AC7 cargo-test-green — $(grep -E 'FAILED|panicked' "$T/test.log" | head -3)"
cargo fmt --check >/dev/null 2>&1 && ok "AC7 cargo-fmt-clean" || bad "AC7 cargo-fmt-clean"

RUDRA="${VAJRA_SYNC_TARGET:-$HOME/playground/rudra}"
if [ -d "$RUDRA/.git" ]; then
  C="$T/rc"; git clone -q "$RUDRA" "$C" 2>/dev/null
  OUT="$(cd "$C" && "$BIN" init --sync-fleet 2>&1)"
  if grep -qE "^0 created, [0-9]+ upgraded, .*0 drifted" <<<"$OUT"; then
    ok "AC7 sync-fleet-upgrades-a-real-project-cleanly ($(grep -cE '^  upgrade' <<<"$OUT") files)"
  else
    bad "AC7 sync-fleet-upgrades-a-real-project-cleanly — $(tail -2 <<<"$OUT")"
  fi
else
  # A check that cannot evaluate FAILS (this repo's own rule, applied to itself — cold review rec 7).
  bad "AC7 sync-fleet-upgrades-a-real-project-cleanly — no project at $RUDRA to sync into; set VAJRA_SYNC_TARGET"
fi

echo ""
echo "=== Session 172 verify: $PASS pass, $FAIL fail ==="
[ "$FAIL" -eq 0 ]
