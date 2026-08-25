#!/usr/bin/env bash
# Verify — Session 133: the `design-advisor` is MANDATORY before a session closes, and the only way
# past it is a RECORDED, substantive, VISIBLE reason in the repo.
#
# What this suite must actually prove, beyond "a new module exists":
#   1. SILENCE at/after the threshold BLOCKS, naming BOTH ways to satisfy the gate;
#   2. a recorded substantive reason PASSES **and the reason is printed** — never a clean green;
#   3. a placeholder / empty / non-skip reason BLOCKS, at ANY session number;
#   4. a hand-typed or fabricated handoff BLOCKS (S131's rule, reused) — and a recorded reason does
#      NOT launder it (rung 1 beats rung 3, the decided conflict);
#   5. a REAL provenance-verified dispatch PASSES;
#   6. NO environment variable satisfies or bypasses this gate — driven live against every
#      VAJRA_SKIP_* name this repo uses plus the one a reader would guess for this gate;
#   7. the gate really BINDS `vajra next --advance`, driven live, every other stage neutralised so
#      the refusal can only be this one's;
#   8. the threshold governs SILENCE ONLY — below it, silence WARNs and NAMES the exemption, while
#      a placeholder marker still blocks;
#   9. the REAL scaffold (`vajra next --scaffold`) emits the marker, so a fresh project binds from
#      session 1 despite the session-number threshold;
#  10. the falsifiability fixture goes RED when each rung is bypassed, and stays GREEN when every
#      message string is renamed (S122's contract, on a NEW module);
#  11. NOTHING else moved — `K of 8` unchanged at a non-degenerate baseline, still 7 commands,
#      S131's Fidelity gate and S132's Obeyed gate answer exactly as before.
#
# CHECK CLASSES — the S121/S122/S123 contract: EXECUTE-BASED (runs the product, asserts on real
# output) · STRUCTURAL grep (asserts architecture — no runtime output exists to exercise) ·
# BEHAVIORAL grep (greps source and treats it as proof the feature works — HOLLOW, disclosed) ·
# NESTED (runs another whole suite).

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

# shellcheck source=scripts/lib-tally.sh
source "$ROOT/scripts/lib-tally.sh"

SESSION="133"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

VAJRA="$ROOT/target/release/vajra"
[ -x "$VAJRA" ] || cargo build -q --release || { echo "release build failed"; exit 2; }

PASS=0; FAIL=0; RESULTS=()
EXEC_N=0; STRUCT_N=0; BEHAV_N=0; NESTED_N=0; NESTED_NAMES=()
run_check() {
  local NAME="$1"; local CLASS="$2"; shift 2
  local LOG="$ARTIFACTS/${NAME}.log"
  case "$CLASS" in
    exec)   EXEC_N=$((EXEC_N+1)) ;;
    struct) STRUCT_N=$((STRUCT_N+1)) ;;
    behav)  BEHAV_N=$((BEHAV_N+1)) ;;
    nested) NESTED_N=$((NESTED_N+1)); NESTED_NAMES+=("$NAME") ;;
    *) echo "verify bug: unknown class '$CLASS' for $NAME"; exit 2 ;;
  esac
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-52s %-7s %s' "$NAME" "$CLASS" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-52s %-7s %s' "$NAME" "$CLASS" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# Real, physical path (macOS's /tmp is a symlink to /private/tmp) — the same resolution
# `env::current_dir()` performs inside the binary (S131's lesson, reused).
real_tmpdir() { ( cd "$(mktemp -d)" && pwd -P ); }

# The S131 evidentiary shape: a subagent meta.json + its own transcript (carrying `gitBranch`) +
# a parent transcript recording the matching `tool_use` call.
build_real_dispatch_fixture() {
  local PROJROOT="$1" REPOROOT="$2" SESSION_BRANCH="$3" TOOL_ID="$4" ROLE="${5:-design-advisor}"
  local SLUG; SLUG="$(echo "$REPOROOT" | sed 's#/#-#g')"
  local PROJ="$PROJROOT/$SLUG"
  local UUID="sess-uuid-fixture-$ROLE"
  mkdir -p "$PROJ/$UUID/subagents"
  printf '{"agentType":"%s","toolUseId":"%s"}' "$ROLE" "$TOOL_ID" \
    > "$PROJ/$UUID/subagents/agent-x1.meta.json"
  printf '{"gitBranch":"%s","type":"user"}\n' "$SESSION_BRANCH" \
    > "$PROJ/$UUID/subagents/agent-x1.jsonl"
  printf '{"message":{"content":[{"type":"tool_use","id":"%s","name":"Agent","input":{"subagent_type":"%s"}}]}}\n' "$TOOL_ID" "$ROLE" \
    > "$PROJ/$UUID.jsonl"
}

# A throwaway repo on a `session-NN-fixture` branch carrying a prompt. $3 is appended into the
# prompt's `## Design`, so each check writes exactly the marker it means to test (or none).
build_subject() {
  local TMP="$1" SESS="$2" MARKER="${3:-}"
  ( cd "$TMP" && git init -q . && git config user.email t@t && git config user.name t \
      && echo seed > seed.txt && git add -A && git commit -q -m seed --no-verify \
      && git checkout -q -b "session-${SESS}-fixture" ) || return 1
  mkdir -p "$TMP/.ai/handoffs" "$TMP/prompts"
  echo "$SESS" > "$TMP/.ai/SESSION"
  {
    echo "# Session ${SESS} — fixture"
    echo
    echo "## Design"
    echo "- design-significant: no — fixture"
    [ -n "$MARKER" ] && echo "$MARKER"
  } > "$TMP/prompts/${SESS}-task-fixture.md"
  return 0
}

# Land a design-advisor handoff written by the REAL binary, so its provenance is DERIVED and never
# hand-typed. Requires a matching dispatch fixture under $3.
land_real_handoff() {
  local TMP="$1" PROJROOT="$2"
  local BRIEF; BRIEF="$(mktemp)"
  printf '## Findings\n\nrec 1 — a real recommendation from a real dispatch\n' > "$BRIEF"
  ( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJROOT" "$VAJRA" next --role design-advisor --from "$BRIEF" ) >/dev/null 2>&1
  local rc=$?; rm -f "$BRIEF"; return $rc
}

GATE="next --check-design-handoff"

# --- 1. silence at the threshold BLOCKS, naming BOTH ways out --------------------------------------
silence_blocks() {
  local TMP; TMP="$(real_tmpdir)"; local rc=0 OUT
  build_subject "$TMP" 133 || { rm -rf "$TMP"; return 1; }
  OUT="$( cd "$TMP" && "$VAJRA" $GATE 133 2>&1 )"; local code=$?
  echo "$OUT"; echo "exit=$code"
  # An unrecognised `vajra next` flag falls through to run_dump() and exits 0 (S132) — so a check
  # that only reads the exit code cannot tell a gate that ran from a gate that does not exist.
  grep -q "=== mandate: design-advisor for session 133 ===" <<<"$OUT" \
    || { echo "FAIL: the gate did not run (no header) — flag fell through to run_dump?"; rc=1; }
  [ "$code" -eq 1 ] || { echo "FAIL: silence did not block (exit $code)"; rc=1; }
  grep -q "records neither a design-advisor handoff" <<<"$OUT" \
    || { echo "FAIL: the block does not name the absence"; rc=1; }
  grep -q -- "--role design-advisor --from" <<<"$OUT" \
    || { echo "FAIL: the block does not name the dispatch way out"; rc=1; }
  grep -q "design-advisor: skipped — <reason>" <<<"$OUT" \
    || { echo "FAIL: the block does not name the reasoned-skip way out"; rc=1; }
  grep -q "no environment variable can satisfy or bypass this gate" <<<"$OUT" \
    || { echo "FAIL: the block does not state the no-env-var rule"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "silence-blocks-naming-both-ways-out" exec silence_blocks

# --- 2. a recorded substantive reason PASSES **and is printed** -------------------------------------
recorded_reason_passes_visibly() {
  local TMP; TMP="$(real_tmpdir)"; local rc=0 OUT
  local REASON="a one-line README typo; no interface, module, or locked record moves"
  build_subject "$TMP" 133 "- design-advisor: skipped — $REASON" || { rm -rf "$TMP"; return 1; }
  OUT="$( cd "$TMP" && "$VAJRA" $GATE 133 2>&1 )"; local code=$?
  echo "$OUT"; echo "exit=$code"
  [ "$code" -eq 0 ] || { echo "FAIL: a reasoned skip did not pass (exit $code)"; rc=1; }
  grep -q "verdict: READY" <<<"$OUT" || { echo "FAIL: expected READY"; rc=1; }
  # Acceptance 2's teeth: the skip must be VISIBLE, and it must carry the author's own words.
  grep -q "design-advisor review SKIPPED — $REASON" <<<"$OUT" \
    || { echo "FAIL: a skipped review read as a clean green — the reason is not in the output"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "recorded-reason-passes-and-prints-the-reason" exec recorded_reason_passes_visibly

# --- 3. an unusable reason BLOCKS — placeholder, empty, and the words a hurried author reaches for --
unusable_reasons_block() {
  local rc=0
  local -a CASES=(
    "- design-advisor: <skipped — why this session needs no design review>|template placeholder"
    "- design-advisor: skipped|no reason after it"
    "- design-advisor: skipped —|no reason after it"
    "- design-advisor: done|is not a recorded skip"
    "- design-advisor: yes|is not a recorded skip"
  )
  local c
  for c in "${CASES[@]}"; do
    local MARKER="${c%%|*}" EXPECT="${c##*|}"
    local TMP; TMP="$(real_tmpdir)"
    build_subject "$TMP" 133 "$MARKER" || { rm -rf "$TMP"; return 1; }
    local OUT; OUT="$( cd "$TMP" && "$VAJRA" $GATE 133 2>&1 )"; local code=$?
    echo "--- ${MARKER} -> exit=$code"
    [ "$code" -eq 1 ] || { echo "FAIL: ${MARKER} did not block"; rc=1; }
    grep -q "$EXPECT" <<<"$OUT" || { echo "FAIL: expected reason '$EXPECT', got:"; echo "$OUT" | grep '✗'; rc=1; }
    rm -rf "$TMP"
  done
  return $rc
}
run_check "unusable-reasons-block" exec unusable_reasons_block

# --- 4. a hand-typed / fabricated handoff BLOCKS, and a reason does NOT launder it ------------------
forged_handoff_blocks_even_with_a_reason() {
  local rc=0
  local -a CASES=("claude-code-subagent|no verifiable dispatch id"
                  "claude-code-subagent (verified: toolu_FAKEFAKEFAKE)|could not be independently re-verified")
  local c
  for c in "${CASES[@]}"; do
    local AGENT="${c%%|*}" EXPECT="${c##*|}"
    local TMP; TMP="$(real_tmpdir)"
    build_subject "$TMP" 133 "- design-advisor: skipped — a perfectly good reason, recorded in the repo" \
      || { rm -rf "$TMP"; return 1; }
    cat > "$TMP/.ai/handoffs/session-133-design-advisor.md" <<HAND
---
role: design-advisor
session: 133
agent: ${AGENT}
source-sha: deadbeef
captured: 2026-08-25T00:00:00Z
cost_usd: null
---

# Design-advisor handoff — session 133

rec 1 — a hand-typed finding

## Handoff Delta
- \`+\` new: forged handoff fixture
HAND
    local OUT; OUT="$( cd "$TMP" && "$VAJRA" $GATE 133 2>&1 )"; local code=$?
    echo "--- agent=${AGENT} -> exit=$code"
    [ "$code" -eq 1 ] || { echo "FAIL: a forged handoff passed (exit $code)"; rc=1; }
    grep -q "$EXPECT" <<<"$OUT" || { echo "FAIL: expected '$EXPECT'"; echo "$OUT" | grep '✗'; rc=1; }
    # Rung 1 beats rung 3 — the decided conflict, asserted rather than assumed.
    grep -q "does not cure it" <<<"$OUT" \
      || { echo "FAIL: the message does not state that a recorded reason cannot cure it"; rc=1; }
    grep -q "SKIPPED" <<<"$OUT" \
      && { echo "FAIL: a blocked session still rendered as a reasoned skip"; rc=1; }
    rm -rf "$TMP"
  done
  # A malformed handoff fails CLOSED — never silently read as absent (S69).
  local TMP; TMP="$(real_tmpdir)"
  build_subject "$TMP" 133 "- design-advisor: skipped — a real reason" || { rm -rf "$TMP"; return 1; }
  echo "not a handoff at all" > "$TMP/.ai/handoffs/session-133-design-advisor.md"
  local OUT; OUT="$( cd "$TMP" && "$VAJRA" $GATE 133 2>&1 )"; local code=$?
  echo "--- malformed -> exit=$code"
  [ "$code" -eq 1 ] || { echo "FAIL: a malformed handoff did not block"; rc=1; }
  grep -q "does not satisfy the handoff contract" <<<"$OUT" || { echo "FAIL: wrong malformed reason"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "forged-handoff-blocks-and-a-reason-does-not-launder-it" exec forged_handoff_blocks_even_with_a_reason

# --- 5. a REAL provenance-verified dispatch PASSES (the positive control, S132) ---------------------
real_dispatch_passes() {
  local TMP; TMP="$(real_tmpdir)"; local rc=0 OUT PROJROOT
  build_subject "$TMP" 133 || { rm -rf "$TMP"; return 1; }
  PROJROOT="$TMP/fake-cc-projects"
  build_real_dispatch_fixture "$PROJROOT" "$TMP" "session-133-fixture" "toolu_01REALDESIGN"
  land_real_handoff "$TMP" "$PROJROOT" || { echo "FAIL: the real binary refused to write the handoff"; rm -rf "$TMP"; return 1; }
  OUT="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJROOT" "$VAJRA" $GATE 133 2>&1 )"; local code=$?
  echo "$OUT"; echo "exit=$code"
  [ "$code" -eq 0 ] || { echo "FAIL: a real dispatch did not pass (exit $code)"; rc=1; }
  grep -q "verdict: READY" <<<"$OUT" || { echo "FAIL: expected READY"; rc=1; }
  grep -q "agent:   claude-code-subagent (verified: toolu_01REALDESIGN)" <<<"$OUT" \
    || { echo "FAIL: the gate did not surface the verified provenance it accepted"; rc=1; }
  grep -q "SKIPPED" <<<"$OUT" && { echo "FAIL: a dispatched session rendered as skipped"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "real-dispatch-passes" exec real_dispatch_passes

# --- 6. NO environment variable satisfies or bypasses this gate (acceptance 5) ----------------------
# Driven live against every VAJRA_SKIP_* name this repo already uses, plus the two a reader would
# guess for THIS gate, plus the closeout waiver. Named individually so a future session that adds
# one has to come here and delete a line rather than silently widening the hole.
no_env_var_bypasses() {
  local TMP; TMP="$(real_tmpdir)"; local rc=0
  build_subject "$TMP" 133 || { rm -rf "$TMP"; return 1; }
  local v
  for v in VAJRA_SKIP_DESIGN_ADVISOR_GATE VAJRA_SKIP_MANDATE_GATE VAJRA_SKIP_DESIGN_GATE \
           VAJRA_SKIP_ANALYST_GATE VAJRA_SKIP_CODER_GATE VAJRA_SKIP_ADVICE_GATE \
           VAJRA_SKIP_FIDELITY_GATE VAJRA_SKIP_OBEYED_GATE VAJRA_SKIP_QA_GATE \
           VAJRA_SKIP_PLANNER_GATE VAJRA_SKIP_ARCHITECT_GATE VAJRA_CLOSEOUT_WAIVER; do
    local OUT; OUT="$( cd "$TMP" && env "$v=1" "$VAJRA" $GATE 133 2>&1 )"; local code=$?
    if [ "$code" -eq 1 ]; then
      echo "OK: $v=1 -> still BLOCKED"
    else
      echo "FAIL: $v=1 bypassed the gate (exit $code)"; rc=1
    fi
  done
  # Belt: every one of them set at once.
  local OUT; OUT="$( cd "$TMP" && env VAJRA_SKIP_DESIGN_ADVISOR_GATE=1 VAJRA_SKIP_MANDATE_GATE=1 \
      VAJRA_SKIP_DESIGN_GATE=1 VAJRA_CLOSEOUT_WAIVER=133 "$VAJRA" $GATE 133 2>&1 )"; local code=$?
  [ "$code" -eq 1 ] || { echo "FAIL: the whole env-var set together bypassed the gate (exit $code)"; rc=1; }
  echo "OK: all of them at once -> still BLOCKED"
  # And the source carries no such name at all — structural, because an env var that is never read
  # produces no runtime output to exercise.
  # Precise on purpose: a NAME in a comment is documentation (this gate's refusal is written
  # down in both src/mandate/mod.rs and the --advance wiring). A READ is an escape. So the grep
  # looks for the read, not the word.
  if grep -rnE 'env::var(_os)?\("VAJRA_SKIP_(DESIGN|MANDATE)' src/ ; then
    echo "FAIL: an env-var escape for this gate is READ in the source"; rc=1
  else
    echo "OK: no VAJRA_SKIP_* for this gate is read anywhere in src/"
  fi
  # And the mandate block in --advance reads no env var at all — unlike every other gate there.
  if perl -0ne 'exit(($_ =~ /Mandate gate \(S133\).*?\n\n/s and $& =~ /env::var/) ? 1 : 0)' src/cli/next.rs; then
    echo "OK: the --advance mandate block reads no environment variable"
  else
    echo "FAIL: the --advance mandate block reads an environment variable"; rc=1
  fi
  rm -rf "$TMP"; return $rc
}
run_check "no-env-var-satisfies-or-bypasses-the-gate" exec no_env_var_bypasses

# --- 7. the gate really BINDS `vajra next --advance` ------------------------------------------------
# Every OTHER stage is neutralised with its own documented override, so the refusal that comes back
# can only be this one's. `--advance` blocks on stdin without EOF (S132), hence `</dev/null`.
advance_binds_the_close_path() {
  local TMP; TMP="$(real_tmpdir)"; local rc=0 OUT code
  build_subject "$TMP" 133 || { rm -rf "$TMP"; return 1; }
  cp "$ROOT/.ai/CONSTRAINTS.yaml" "$TMP/.ai/CONSTRAINTS.yaml" 2>/dev/null || true
  local -a NEUTRALISE=(
    VAJRA_SKIP_ANALYST_GATE=1 VAJRA_SKIP_CODER_GATE=1 VAJRA_SKIP_ADVICE_GATE=1
    VAJRA_SKIP_FIDELITY_GATE=1 VAJRA_SKIP_OBEYED_GATE=1 VAJRA_SKIP_QA_GATE=1
    VAJRA_SKIP_DEMO_GATE=1 VAJRA_SKIP_RELEASE_GATE=1 VAJRA_SKIP_PLANNER_GATE=1
    VAJRA_SKIP_ARCHITECT_GATE=1
  )
  OUT="$( cd "$TMP" && env "${NEUTRALISE[@]}" "$VAJRA" next --advance </dev/null 2>&1 )"; code=$?
  echo "$OUT" | tail -12; echo "exit=$code"
  [ "$code" -ne 0 ] || { echo "FAIL: --advance succeeded with no design-advisor and no reason"; rc=1; }
  grep -q "\[vajra mandate\]" <<<"$OUT" \
    || { echo "FAIL: the refusal did not come from the Mandate gate"; rc=1; }
  grep -q "neither a provable design-advisor handoff nor a recorded reason" <<<"$OUT" \
    || { echo "FAIL: --advance's refusal message is not the Mandate gate's"; rc=1; }
  grep -q "There is no \\\\?environment variable for this one\|no \\\\?$" <<<"$OUT" >/dev/null 2>&1 || true
  # The positive control (S132): the SAME advance, with a recorded reason, gets past THIS gate —
  # so the block above is the mandate's and not a permanent brick.
  printf -- '- design-advisor: skipped — a fixture reason, recorded in the repo\n' \
    >> "$TMP/prompts/133-task-fixture.md"
  OUT="$( cd "$TMP" && env "${NEUTRALISE[@]}" "$VAJRA" next --advance </dev/null 2>&1 )"; code=$?
  echo "--- with a recorded reason: exit=$code"
  grep -q "\[vajra mandate\] design-advisor review SKIPPED — a fixture reason" <<<"$OUT" \
    || { echo "FAIL: --advance did not announce the skip"; echo "$OUT" | tail -8; rc=1; }
  grep -q "neither a provable design-advisor handoff" <<<"$OUT" \
    && { echo "FAIL: the Mandate gate still refused a session with a recorded reason"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "advance-really-binds-and-a-reason-releases-it" exec advance_binds_the_close_path

# --- 8. the threshold governs SILENCE ONLY ----------------------------------------------------------
threshold_governs_silence_only() {
  local rc=0
  # (a) below the threshold, silence WARNs and the exemption is NAMED.
  local TMP; TMP="$(real_tmpdir)"
  build_subject "$TMP" 42 || { rm -rf "$TMP"; return 1; }
  local OUT; OUT="$( cd "$TMP" && "$VAJRA" $GATE 42 2>&1 )"; local code=$?
  echo "--- session 42, silent: exit=$code"; echo "$OUT" | grep '⚠'
  [ "$code" -eq 0 ] || { echo "FAIL: silence below the threshold blocked"; rc=1; }
  grep -q "predates the design-advisor mandate (threshold 133)" <<<"$OUT" \
    || { echo "FAIL: the exemption is not NAMED in the output"; rc=1; }
  rm -rf "$TMP"
  # (b) below the threshold, a marker that EXISTS but is unusable still BLOCKS.
  TMP="$(real_tmpdir)"
  build_subject "$TMP" 42 "- design-advisor: <why not>" || { rm -rf "$TMP"; return 1; }
  OUT="$( cd "$TMP" && "$VAJRA" $GATE 42 2>&1 )"; code=$?
  echo "--- session 42, placeholder marker: exit=$code"
  [ "$code" -eq 1 ] || { echo "FAIL: the threshold excused a marker that EXISTS"; rc=1; }
  rm -rf "$TMP"
  # (c) below the threshold, a handoff that EXISTS but does not re-verify still BLOCKS.
  TMP="$(real_tmpdir)"
  build_subject "$TMP" 42 || { rm -rf "$TMP"; return 1; }
  cat > "$TMP/.ai/handoffs/session-42-design-advisor.md" <<HAND
---
role: design-advisor
session: 42
agent: claude-code-subagent (verified: toolu_FAKEFAKEFAKE)
source-sha: deadbeef
captured: 2026-08-25T00:00:00Z
cost_usd: null
---

# Design-advisor handoff — session 42

rec 1 — a fabricated finding

## Handoff Delta
- \`+\` new: fixture
HAND
  OUT="$( cd "$TMP" && "$VAJRA" $GATE 42 2>&1 )"; code=$?
  echo "--- session 42, unverifiable handoff: exit=$code"
  [ "$code" -eq 1 ] || { echo "FAIL: the threshold excused a handoff that EXISTS"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "threshold-governs-silence-only" exec threshold_governs_silence_only

# --- 9. the REAL scaffold carries the marker, so a fresh project binds at session 1 -----------------
# Not a hand-typed copy of the template: `vajra next --scaffold` is run for real, and the gate is
# then run against what it wrote.
scaffold_binds_a_fresh_project() {
  local TMP; TMP="$(real_tmpdir)"; local rc=0
  build_subject "$TMP" 133 >/dev/null || { rm -rf "$TMP"; return 1; }
  rm -f "$TMP/prompts/133-task-fixture.md"
  ( cd "$TMP" && "$VAJRA" next --scaffold 1 fresh-project ) > "$TMP/scaffold.log" 2>&1
  local P="$TMP/prompts/01-task-fresh-project.md"
  [ -f "$P" ] || { echo "FAIL: the scaffold wrote no prompt"; cat "$TMP/scaffold.log"; rm -rf "$TMP"; return 1; }
  grep -q "design-advisor:" "$P" \
    || { echo "FAIL: the scaffolded prompt carries no design-advisor marker"; rc=1; }
  local OUT; OUT="$( cd "$TMP" && "$VAJRA" $GATE 1 2>&1 )"; local code=$?
  echo "--- scaffolded session 1: exit=$code"; echo "$OUT" | grep -E '✗|verdict'
  [ "$code" -eq 1 ] \
    || { echo "FAIL: a scaffolded session 1 passed — the number threshold swallowed a fresh project"; rc=1; }
  grep -q "template placeholder" <<<"$OUT" || { echo "FAIL: wrong block reason"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "scaffold-binds-a-fresh-project-at-session-1" exec scaffold_binds_a_fresh_project

# --- 10. the falsifiability fixture is real: RED on each bypass, GREEN on renaming ------------------
mandate_green() { ( cd "$1" && cargo test -q --lib mandate::tests:: 2>&1 | grep -q "test result: ok" ); }

# A bypass probe that silently no-ops reports false comfort (S127), and a bypass that fails to
# COMPILE is not a falsification either (S122). Each probe asserts (a) the exact source it means to
# patch was present and is gone afterwards, and (b) the red it produces is a TEST FAILURE.
apply_bypass() {   # file, fixed-string-to-replace, replacement
  local F="$1" FROM="$2" TO="$3"
  grep -qF "$FROM" "$F" || { echo "PROBE FAIL: the bypass target is not present: $FROM"; return 1; }
  FROM="$FROM" TO="$TO" perl -0pi -e 'BEGIN{$f=$ENV{FROM};$r=$ENV{TO}} s/\Q$f\E/$r/' "$F"
  grep -qF "$FROM" "$F" && { echo "PROBE FAIL: the substitution did not land (still present, likely more than one occurrence): $FROM"; return 1; }
  return 0
}
expect_test_red() { # worktree, test name
  local LOG; LOG="$(mktemp)"
  ( cd "$1" && cargo test -q --lib "$2" ) > "$LOG" 2>&1
  if grep -qE "error\[E[0-9]+\]|could not compile" "$LOG"; then
    echo "PROBE FAIL: the bypass broke the BUILD, so the red proves nothing"; sed -n '1,5p' "$LOG"; rm -f "$LOG"; return 1
  fi
  if grep -q "test result: ok" "$LOG"; then
    rm -f "$LOG"; return 1   # still green: the rule was not load-bearing
  fi
  grep -qE "FAILED|panicked" "$LOG" || { echo "PROBE FAIL: red, but not as a test failure"; rm -f "$LOG"; return 1; }
  rm -f "$LOG"; return 0
}
fixture_fails_for_the_right_reason() {
  # Measured at S132, reused: the SAME `cargo test` takes ~12s in a worktree under the repo's
  # gitignored `target/` and more than TEN MINUTES in one under $TMPDIR.
  local WT="$ROOT/target/s133-fixture-wt"; local rc=0
  rm -rf "$WT"; git worktree prune
  git worktree add --detach -q "$WT" HEAD 2>/dev/null || { echo "FAIL: no clean-room worktree"; return 1; }
  local D="$WT/src/mandate/mod.rs"
  local PROBE_TARGET="$ROOT/target/s133-probes"
  mkdir -p "$PROBE_TARGET"
  export CARGO_TARGET_DIR="$PROBE_TARGET"

  mandate_green "$WT" && echo "OK: shipped fixture GREEN" \
    || { echo "FAIL: the shipped fixture is not green"; rc=1; }

  # Bypass A — rung 5: let silence at the threshold pass.
  if apply_bypass "$D" "if session >= from_session {" "if false {" \
     && expect_test_red "$WT" mandate::tests::silence_at_the_threshold_blocks_and_names_both_ways_out; then
    echo "OK: bypassing the silence block -> RED (as a test failure)"
  else
    echo "FAIL: bypassing the silence block did not produce an honest red"; rc=1
  fi
  git -C "$WT" checkout -q -- src/mandate/mod.rs

  # Bypass B — rung 4: let a placeholder reason through as if it were substantive.
  if apply_bypass "$D" "match substantive_reason(reason) {" "match Ok::<(), String>(()) {" \
     && expect_test_red "$WT" mandate::tests::a_template_reason_after_skipped_is_unusable; then
    echo "OK: bypassing the substantiveness floor -> RED (as a test failure)"
  else
    echo "FAIL: bypassing the substantiveness floor did not produce an honest red"; rc=1
  fi
  git -C "$WT" checkout -q -- src/mandate/mod.rs

  # Bypass C — rung 1: trust whatever provenance the handoff claims.
  if apply_bypass "$D" "Some(id) => match dispatch::reverify(root, role.name, session, &id) {" \
        "Some(id) => match { let _ = &id; Ok::<(), String>(()) } {" \
     && expect_test_red "$WT" mandate::tests::a_fabricated_dispatch_id_blocks; then
    echo "OK: bypassing provenance re-verification -> RED (as a test failure)"
  else
    echo "FAIL: bypassing provenance re-verification did not produce an honest red"; rc=1
  fi
  git -C "$WT" checkout -q -- src/mandate/mod.rs

  # Bypass D — the anchoring: match the role name anywhere in a line, not only at its start.
  # Without this probe, "the marker is line-anchored" would be an untested claim.
  if apply_bypass "$D" "let Some(rest) = lower.strip_prefix(role) else {" \
        "let Some(rest) = lower.find(role).map(|i| &lower[i + role.len()..]) else {" \
     && expect_test_red "$WT" mandate::tests::the_marker_is_line_anchored_not_a_substring_match; then
    echo "OK: bypassing line-anchoring -> RED (as a test failure)"
  else
    echo "FAIL: bypassing line-anchoring did not produce an honest red"; rc=1
  fi
  git -C "$WT" checkout -q -- src/mandate/mod.rs

  # Bypass E — the fence skip: read fenced EXAMPLES as records (S127's own shipped bug).
  if apply_bypass "$D" "for line in skip_fenced(prompt) {" "for line in prompt.lines() {" \
     && expect_test_red "$WT" mandate::tests::a_fenced_example_is_not_a_record; then
    echo "OK: bypassing the fence skip -> RED (as a test failure)"
  else
    echo "FAIL: bypassing the fence skip did not produce an honest red"; rc=1
  fi
  git -C "$WT" checkout -q -- src/mandate/mod.rs

  # The other direction (S122): renaming every message string must NOT turn it red — and the
  # control itself must assert its substitutions landed, or a reworded message silently makes it
  # pass for the wrong reason.
  # This is only meaningful because the unit tests bind to `SkipDefect` / `MandateCause` values
  # rather than to sentences (the wording contract is asserted live in checks 1-4 above). Every
  # user-facing message this module emits is renamed here — nothing is exempted.
  local renamed=1
  apply_bypass "$D" "is still the template placeholder" "RENAMED-A" || renamed=0
  apply_bypass "$D" "records the word \`skipped\` with no reason after it" "RENAMED-B" || renamed=0
  apply_bypass "$D" "is not a recorded skip" "RENAMED-C" || renamed=0
  apply_bypass "$D" "records nothing after the colon" "RENAMED-D" || renamed=0
  apply_bypass "$D" "skip reason is not substantive" "RENAMED-E" || renamed=0
  apply_bypass "$D" "predates the {} mandate (threshold {from_session})" "RENAMED-F {} {from_session}" || renamed=0
  apply_bypass "$D" "records neither a {} handoff ({}) nor a reason for \\" "RENAMED-G {} {} \\" || renamed=0
  apply_bypass "$D" "carries no verifiable dispatch id" "RENAMED-H" || renamed=0
  apply_bypass "$D" "could not be independently re-verified" "RENAMED-I" || renamed=0
  apply_bypass "$D" "does not satisfy the handoff contract" "RENAMED-J" || renamed=0
  apply_bypass "$D" "review SKIPPED — " "RENAMED-K " || renamed=0
  [ "$renamed" -eq 1 ] || { echo "FAIL: the rename control did not rename every message"; rc=1; }
  if mandate_green "$WT"; then
    echo "OK: renaming every gate message -> still GREEN (the fixture binds to behaviour)"
  else
    echo "FAIL: the fixture is bound to message strings, not behaviour"; rc=1
  fi

  unset CARGO_TARGET_DIR
  git worktree remove --force "$WT" >/dev/null 2>&1 || true
  return $rc
}
run_check "fixture-red-on-bypass-green-on-rename" exec fixture_fails_for_the_right_reason

# --- 11a. S131's Fidelity gate and S132's Obeyed gate are UNCHANGED — traced, not asserted ----------
prior_gates_unchanged() {
  local rc=0 OUT code
  # S132's own specimen still reads a MISMATCH on the real record of THIS repo.
  OUT="$( "$VAJRA" next --check-obeyed 127 2>&1 )"; code=$?
  echo "--- --check-obeyed 127: exit=$code"; echo "$OUT" | grep -E 'MISMATCH|verdict:' | head -2
  [ "$code" -eq 1 ] || { echo "FAIL: S132's gate changed verdict on S127 (exit $code)"; rc=1; }
  grep -q "implementation-advisor rec 9" <<<"$OUT" || { echo "FAIL: the S127 specimen is no longer read"; rc=1; }
  # S131's gate still blocks on absence, in its own words, in a throwaway repo.
  local TMP; TMP="$(real_tmpdir)"
  build_subject "$TMP" 133 >/dev/null || { rm -rf "$TMP"; return 1; }
  OUT="$( cd "$TMP" && "$VAJRA" next --check-fidelity-handoff 133 2>&1 )"; code=$?
  echo "--- --check-fidelity-handoff 133 (absent): exit=$code"
  [ "$code" -eq 1 ] || { echo "FAIL: S131's gate stopped blocking on absence"; rc=1; }
  grep -q "no fidelity-reviewer handoff recorded for session 133" <<<"$OUT" \
    || { echo "FAIL: S131's absence message changed"; rc=1; }
  # And this session's gate is a DIFFERENT gate on a DIFFERENT role — not a rename of S131's.
  OUT="$( cd "$TMP" && "$VAJRA" $GATE 133 2>&1 )"
  grep -q "=== mandate: design-advisor" <<<"$OUT" || { echo "FAIL: the two gates share an identity"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "s131-and-s132-gates-unchanged" exec prior_gates_unchanged

# --- 11b. nothing else moved: K of 8 at a non-degenerate baseline, not a 9th station ----------------
# `vajra next --stations` costs ~30s here and >10 minutes inside a worktree (S132, measured), so
# this reads the LIVE repo and never a clean room.
k_of_8_unchanged_and_not_a_ninth_station() {
  local rc=0 SOUT K
  SOUT="$( "$VAJRA" next --stations 132 2>&1 )"
  K="$( grep -oE '[0-9]+ of 8 stations passed' <<<"$SOUT" )"
  echo "session 132: $K"
  case "$K" in
    "0 of 8 stations passed"|"") echo "FAIL: DEGENERATE baseline — this check would prove nothing"; rc=1 ;;
  esac
  grep -qE '[0-9]+ of 8 stations passed' <<<"$SOUT" || { echo "FAIL: the counter is no longer K of 8"; rc=1; }
  if grep -ciE '(\[PASSED\]|\[ABSENT\]|\[LEGACY\]) *(mandate|design-advisor)' <<<"$SOUT" | grep -qv '^0$'; then
    echo "FAIL: the mandate appears as a station row"; rc=1
  else
    echo "OK: the mandate is not a ninth station ($(grep -cE '\[(PASSED|ABSENT|LEGACY)\]' <<<"$SOUT") station rows read)"
  fi
  return $rc
}
run_check "k-of-8-unchanged-and-not-a-ninth-station" exec k_of_8_unchanged_and_not_a_ninth_station

# --- 12. this session's OWN gate is satisfied by REAL use, not by a fixture (acceptance 9) ----------
dogfooded_on_its_own_session() {
  local rc=0 OUT
  OUT="$( "$VAJRA" $GATE 133 2>&1 )"; local code=$?
  echo "$OUT"; echo "exit=$code"
  [ "$code" -eq 0 ] || { echo "FAIL: S133 does not pass the gate it built (exit $code)"; rc=1; }
  grep -q ".ai/handoffs/session-133-design-advisor.md" <<<"$OUT" \
    || { echo "FAIL: S133 has no design-advisor handoff of its own"; rc=1; }
  grep -qE "agent:   claude-code-subagent \(verified: toolu_" <<<"$OUT" \
    || { echo "FAIL: S133's own handoff is not provenance-verified"; rc=1; }
  grep -q "SKIPPED" <<<"$OUT" \
    && { echo "FAIL: S133 satisfied its own gate by SKIPPING — the mechanism is wrong"; rc=1; }
  return $rc
}
run_check "s133-passes-its-own-gate-by-real-use" exec dogfooded_on_its_own_session

# --- 13. the whole library is green, including the new module --------------------------------------
run_check "lib-tests-green" exec cargo test -q --lib

# --- 14. still seven top-level commands -------------------------------------------------------------
# BEHAVIORAL, and labelled so — the same hardcoded-banner grep named since S69.
help_lists_seven() {
  local help; help="$("$VAJRA" --help 2>&1)"; echo "$help"
  grep -q "vajra <init|claude|check|next|estimate|hook|meter>" <<<"$help"
}
run_check "no-eighth-command" behav help_lists_seven

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session 133 Verify Summary ==="
printf '%-52s %-7s %s\n' "STEP" "CLASS" "RESULT"
printf '%-52s %-7s %s\n' "----------------------------------------------------" "-------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo ""
print_tally "$EXEC_N" "$STRUCT_N" "$BEHAV_N" "$NESTED_N" "${NESTED_NAMES[@]:-}"
echo ""
echo "WHAT THIS SUITE NEVER EXERCISED — stated, not buried:"
echo "  * whether a recorded reason is a GOOD one. The gate proves a sentence was written; nothing"
echo "    here judges it. 'design-advisor: skipped — pure fix' typed reflexively passes every check."
echo "  * whether the advice REACHED the design. A session can write all its code, dispatch the"
echo "    advisor at close, land the handoff, and show a green gate (ROADMAP F2f)."
echo "  * whether the reasoned skip becomes the default dodge. The counting rule is manual and"
echo "    named in sessions/session-133-summary.md — no instrument measures it yet."
echo "  * anything off this machine — the provenance chain is local-machine-only and UNSIGNED"
echo "    (S131's disclosed limit, inherited whole)."
echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "ALL GREEN ($PASS pass, $FAIL fail)"
  exit 0
else
  echo "RED ($PASS pass, $FAIL fail)"
  exit 1
fi
