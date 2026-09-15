#!/usr/bin/env bash
# Session 169 verify — the close gate refuses made-up evidence.
# Every check runs a REAL close gate against a REAL git fixture and matches the exact BLOCK
# reason, not just the exit code (tech-lead rec 4). Each case runs on TWO gates: Vajra's own
# scripts/verify-closeout.sh and the one a fresh `vajra init` scaffolds (design-advisor rec 6) —
# so a check carried into one copy but not the other goes red here.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
VAJRA_BIN="${VAJRA_BIN:-$ROOT/target/release/vajra}"
# The gates must not inherit a waiver from the caller's shell — each case sets its own.
unset VAJRA_CLOSEOUT_WAIVER VAJRA_CLOSEOUT_WAIVER_REASON

# --- the fixture: a real git repo with one real commit --------------------------------------
FX="$T/fx"; mkdir -p "$FX/prompts" "$FX/sessions" "$FX/.ai/handoffs"
git -C "$FX" init -q && git -C "$FX" -c user.email=v@v -c user.name=v commit -q --allow-empty -m seed
SHORT="$(git -C "$FX" rev-parse --short=7 HEAD)"; FULL="$(git -C "$FX" rev-parse HEAD)"
GHOST="0123456789abcdef0123456789abcdef01234567"   # well-formed 40-hex, names no commit

# prompt N TYPE EXEC-LINE... — one real plan step per ## Execution line.
prompt() {
  local n="$1" type="$2"; shift 2
  {
    printf '# Session %s\n## Type\n- %s\n## Plan\n' "$n" "$type"
    local i=1 l
    for l in "$@"; do printf '%s. build part %s\n' "$i" "$i"; i=$((i+1)); done
    printf '## Execution\n'
    for l in "$@"; do printf -- '- %s\n' "$l"; done
  } > "$FX/prompts/$n-task-fx.md"
}
run()    { OUT="$(CLAUDE_PROJECT_DIR="$FX" bash "$@" 2>&1)" && RC=0 || RC=$?; }
expect() { # label want-rc fixed-string
  if [ "$RC" -eq "$2" ] && grep -qF -- "$3" <<<"$OUT"; then ok "$1"
  else bad "$1 — wanted exit $2 + '$3', got exit $RC"; fi
}

prompt 41 '**CODE**' "step 1 — done: defacedprose"
prompt 42 '**CODE**' "step 1 — done: ${SHORT:0:6}"
prompt 43 '**CODE**' "step 1 — done: ${FULL}0"
prompt 44 '**CODE**' "step 1 — done: defaced prose"
prompt 45 '**CODE**' "step 1 — done: $GHOST"
prompt 46 '**CODE**' "step 1 — done: $SHORT"
prompt 47 '**CODE**' "step 1 — done: $FULL (landed)"
prompt 48 '**CODE**' "step 1 — done: $SHORT" "step 2 — pending: the release waits for the merge"

# Claimed-evidence fixtures.
prompt 51 '**CODE**' "step 1 — done: $SHORT"
printf '**Verdict:** ACCEPT (fidelity-reviewer, all SHIPPED)\n' > "$FX/sessions/session-51-summary.md"
prompt 52 '**CODE**' "step 1 — done: $SHORT"
printf '**Verdict:** ACCEPT\n' > "$FX/sessions/session-52-summary.md"
echo "review" > "$FX/sessions/session-52-review.md"; echo "crew" > "$FX/.ai/handoffs/session-52-tech-lead.md"
prompt 53 '**CODE**' "step 1 — done: $SHORT"
printf '**Verdict:** ACCEPT\n' > "$FX/sessions/session-53-summary.md"
echo "review" > "$FX/sessions/session-53-review.md"
echo "fr" > "$FX/.ai/handoffs/session-53-fidelity-reviewer.md"; echo "crew" > "$FX/.ai/handoffs/session-53-tech-lead.md"
prompt 54 '**CODE**' "step 1 — done: $SHORT"
prompt 55 '**NO-CODE** ground truth' "step 1 — done: $SHORT"

run_cases() { # gate tag
  local g="$1" t="$2"
  # AC1 — format: word boundary + 7–40 length, named by line.
  run "$g" --check-exec-shas 41; expect "[$t] AC1a: 'done: defacedprose' (7 hex glued to prose) BLOCKs, line named" 1 "BAD-SHA:  - step 1 — done: defacedprose"
  run "$g" --check-exec-shas 42; expect "[$t] AC1b: a 6-char sha BLOCKs, line named (a real commit's prefix — length, not existence)" 1 "BAD-SHA:  - step 1 — done: ${SHORT:0:6}"
  run "$g" --check-exec-shas 43; expect "[$t] AC1c: a 41-char sha BLOCKs, line named" 1 "BAD-SHA:  - step 1 — done: ${FULL}0"
  # AC2 — existence: well-formed but no such commit, named by sha.
  run "$g" --check-exec-shas 44; expect "[$t] AC2a: 'done: defaced prose' BLOCKs — no commit 'defaced'" 1 "NO-SUCH-COMMIT defaced"
  run "$g" --check-exec-shas 45; expect "[$t] AC2b: a well-formed 40-hex sha with no commit BLOCKs, sha named" 1 "NO-SUCH-COMMIT $GHOST"
  # Controls — the same check passes real shas (so AC1/AC2 cannot be red for every input).
  run "$g" --check-exec-shas 46; expect "[$t] control: a real 7-char sha passes" 0 "EXEC-SHAS: PASS"
  run "$g" --check-exec-shas 47; expect "[$t] control: a real 40-char sha followed by a note passes" 0 "EXEC-SHAS: PASS"
  # AC5 — a post-merge step recorded as a plan step BLOCKs at close.
  run "$g" --check-exec-shas 48; expect "[$t] AC5: a 'pending:' plan step BLOCKs at close, step named" 1 "NO-DONE step 2"
  # AC3 — a claimed verdict with nothing behind it BLOCKs even under the waiver.
  VAJRA_CLOSEOUT_WAIVER=51 run "$g" --check-claimed 51
  expect "[$t] AC3a: claimed verdict, no review file, waiver set → BLOCK" 1 "sessions/session-51-review.md is absent"
  expect "[$t] AC3b: … and the waiver is refused by name" 1 "NOT WAIVABLE: VAJRA_CLOSEOUT_WAIVER=51"
  VAJRA_CLOSEOUT_WAIVER=52 run "$g" --check-claimed 52
  expect "[$t] AC3c: review file present but no fidelity-reviewer handoff, waiver set → BLOCK" 1 ".ai/handoffs/session-52-fidelity-reviewer.md is absent"
  run "$g" --check-claimed 53; expect "[$t] control: claimed verdict with review + handoff + tech-lead passes" 0 "CLAIMED: PASS"
  # AC4 — a CODE session with no tech-lead file BLOCKs even under the waiver; a GT session does not.
  VAJRA_CLOSEOUT_WAIVER=54 run "$g" --check-claimed 54
  expect "[$t] AC4a: CODE session, no tech-lead handoff, waiver set → BLOCK" 1 "no .ai/handoffs/session-54-tech-lead.md"
  run "$g" --check-claimed 55; expect "[$t] AC4b control: a NO-CODE / GT session needs no tech-lead file" 0 "N/A: session 55 is not a CODE session"
  # Wiring — the check runs in the FULL close, and it is this check (not the waived review check) that refuses.
  echo 51 > "$FX/.ai/SESSION"
  VAJRA_CLOSEOUT_WAIVER=51 run "$g"
  if grep -qE '^claimed-evidence-real +FAIL' <<<"$OUT" && grep -qE '^fidelity-review-accept +PASS' <<<"$OUT" && [ "$RC" -ne 0 ]; then
    ok "[$t] wiring: full close under VAJRA_CLOSEOUT_WAIVER=51 — fidelity-review-accept PASS (waived), claimed-evidence-real FAIL, exit $RC"
  else
    bad "[$t] wiring: full close did not show claimed-evidence-real FAIL beside a waived fidelity-review-accept PASS (exit $RC)"
  fi
  rm -f "$FX/.ai/SESSION"
}

# Gate 1: Vajra's own.
run_cases "$ROOT/scripts/verify-closeout.sh" live

# Gate 2: the one a stranger gets from a REAL `vajra init` with the REAL binary.
INIT="$T/init"; mkdir -p "$INIT"; git -C "$INIT" init -q
if [ -x "$VAJRA_BIN" ] && ( cd "$INIT" && "$VAJRA_BIN" init </dev/null >/dev/null 2>&1 ) && [ -f "$INIT/scripts/verify-closeout.sh" ]; then
  ok "scaffold: vajra init wrote scripts/verify-closeout.sh"
  run_cases "$INIT/scripts/verify-closeout.sh" scaffold
else
  bad "scaffold: vajra init did not produce scripts/verify-closeout.sh (binary: $VAJRA_BIN)"
fi

echo ""
echo "verify-session-169: $PASS pass, $FAIL fail"
[ "$FAIL" -eq 0 ]
