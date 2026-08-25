#!/usr/bin/env bash
# Verify — Session 132: an `obeyed: <sha>` disposition must be JUDGED TRUE by an independent
# party, not merely carry a sha that resolves.
#
# What this suite must actually prove, beyond "a new module exists":
#   1. an UNJUDGED `obeyed:` BLOCKS the close from the recorded threshold (session 132) onward;
#   2. a `mismatch:` judgment BLOCKS, naming the role, the recommendation number and the
#      disagreement — not a bare exit code;
#   3. a real `implemented:` judgment from a provenance-verified independent role PASSES;
#   4. the three inadmissible judgments (self-graded · stale sha · hand-typed provenance) are all
#      REFUSED, each with its own reason — the ways a recorded judgment can look real and be worth
#      nothing;
#   5. below the threshold a missing judgment WARNs and the exemption is NAMED in the output;
#   6. the S127 HISTORICAL specimen (`implementation-advisor` rec 9, `obeyed: 8cd3bea`, the `_uses`
#      stub still present) is reported a MISMATCH on the REAL record of this repo — no fixture;
#   7. the gate really BINDS `vajra next --advance`, driven live, every other stage neutralised so
#      the refusal can only be this one's, and the documented override announces itself;
#   8. the falsifiability fixture goes RED when each admissibility rule is bypassed, and stays
#      GREEN when every message string is renamed (S122's contract, on a NEW module);
#   9. NOTHING else moved — `K of 8` unchanged at a non-degenerate baseline, still 7 commands.
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

SESSION="132"
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
# `env::current_dir()` performs inside the binary (S131's own lesson, reused).
real_tmpdir() { ( cd "$(mktemp -d)" && pwd -P ); }

# The S131 evidentiary shape: a subagent meta.json + its own transcript (carrying `gitBranch`) +
# a parent transcript recording the matching `tool_use` call.
build_real_dispatch_fixture() {
  local PROJROOT="$1" REPOROOT="$2" SESSION_BRANCH="$3" TOOL_ID="$4" ROLE="${5:-fidelity-reviewer}"
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

# A throwaway repo carrying: one REAL commit to cite, a session prompt whose `## Advice` records
# `obeyed: <that sha>`, and the ADVISOR's handoff recording the recommendation being answered.
# Echoes the real sha so each check can bind its assertions to it.
build_subject() {
  local TMP="$1" SESS="$2"
  ( cd "$TMP" && git init -q . && git config user.email t@t && git config user.name t \
      && echo seed > seed.txt && git add -A && git commit -q -m seed --no-verify \
      && git checkout -q -b "session-${SESS}-fixture" ) || return 1
  mkdir -p "$TMP/.ai/handoffs" "$TMP/prompts"
  echo "$SESS" > "$TMP/.ai/SESSION"
  local SHA; SHA="$( cd "$TMP" && git rev-parse --short=7 HEAD )"
  cat > "$TMP/prompts/${SESS}-task-fixture.md" <<PROMPT
# Session ${SESS} — fixture

## Advice

- plan-advisor rec 1 — obeyed: ${SHA}
PROMPT
  cat > "$TMP/.ai/handoffs/session-${SESS}-plan-advisor.md" <<HAND
---
role: plan-advisor
session: ${SESS}
agent: claude-code-subagent (verified: toolu_ADVISOR)
source-sha: deadbeef
captured: 2026-08-24T00:00:00Z
cost_usd: null
---

# Plan-advisor handoff — session ${SESS}

rec 1 — record a covers: tag on every plan step

## Handoff Delta
- \`+\` new: fixture advisor brief
HAND
  echo "$SHA"
}

# Land a JUDGE handoff written by the REAL binary, so its provenance is derived (never hand-typed).
# $5.. is the obeyed-check line(s) to record in the findings.
land_judge_handoff() {
  local TMP="$1" SESS="$2" PROJROOT="$3" ROLE="$4"; shift 4
  { printf 'rec 1 — a fixture finding from the judge\n\n'; printf '%s\n' "$@"; } > "$TMP/judge.md"
  ( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJROOT" "$VAJRA" next --role "$ROLE" --from judge.md ) >/dev/null 2>&1
}

# --- 1. an UNJUDGED obeyed: BLOCKS from the threshold onward --------------------------------------
unjudged_blocks_at_the_threshold() {
  local TMP; TMP="$(real_tmpdir)"; local rc=0 OUT SHA
  SHA="$(build_subject "$TMP" 132)" || { rm -rf "$TMP"; return 1; }
  OUT="$( cd "$TMP" && "$VAJRA" next --check-obeyed 132 2>&1 )"; local code=$?
  echo "$OUT"; echo "exit=$code (disposition sha $SHA)"
  [ "$code" -eq 1 ] || { echo "FAIL: expected exit 1, got $code"; rc=1; }
  grep -q "UNJUDGED" <<<"$OUT" || { echo "FAIL: does not report the disposition unjudged"; rc=1; }
  grep -q "plan-advisor rec 1 — \`obeyed: ${SHA}\` carries no independent judgment" <<<"$OUT" \
    || { echo "FAIL: the blocking reason does not name the label and the sha"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "unjudged-obeyed-blocks-from-the-threshold" exec unjudged_blocks_at_the_threshold

# --- 2. a mismatch judgment BLOCKS, naming role, number and disagreement ---------------------------
mismatch_blocks_and_names_the_disagreement() {
  local TMP; TMP="$(real_tmpdir)"; local rc=0 OUT SHA PROJROOT
  SHA="$(build_subject "$TMP" 132)" || { rm -rf "$TMP"; return 1; }
  PROJROOT="$TMP/fake-cc-projects"
  build_real_dispatch_fixture "$PROJROOT" "$TMP" "session-132-fixture" "toolu_01JUDGE"
  land_judge_handoff "$TMP" 132 "$PROJROOT" fidelity-reviewer \
    "obeyed-check plan-advisor rec 1 — mismatch: ${SHA} — the commit adds a seed file and records no covers: tag"
  OUT="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJROOT" "$VAJRA" next --check-obeyed 132 2>&1 )"; local code=$?
  echo "$OUT"; echo "exit=$code"
  [ "$code" -eq 1 ] || { echo "FAIL: expected exit 1, got $code"; rc=1; }
  grep -q "MISMATCH" <<<"$OUT" || { echo "FAIL: the mismatch is not surfaced"; rc=1; }
  grep -q "plan-advisor rec 1" <<<"$OUT" || { echo "FAIL: does not name the role and rec number"; rc=1; }
  grep -q "records no covers: tag" <<<"$OUT" \
    || { echo "FAIL: does not name the judge's actual disagreement"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "mismatch-blocks-and-names-the-disagreement" exec mismatch_blocks_and_names_the_disagreement

# --- 3. a real implemented: judgment from a verified independent role PASSES ------------------------
true_judgment_passes() {
  local TMP; TMP="$(real_tmpdir)"; local rc=0 OUT SHA PROJROOT
  SHA="$(build_subject "$TMP" 132)" || { rm -rf "$TMP"; return 1; }
  PROJROOT="$TMP/fake-cc-projects"
  build_real_dispatch_fixture "$PROJROOT" "$TMP" "session-132-fixture" "toolu_01JUDGE"
  land_judge_handoff "$TMP" 132 "$PROJROOT" fidelity-reviewer \
    "obeyed-check plan-advisor rec 1 — implemented: ${SHA} — the commit really lands what rec 1 asked for"
  OUT="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJROOT" "$VAJRA" next --check-obeyed 132 2>&1 )"; local code=$?
  echo "$OUT"; echo "exit=$code"
  [ "$code" -eq 0 ] || { echo "FAIL: expected exit 0 on a real judgment, got $code"; rc=1; }
  grep -q "verdict: READY" <<<"$OUT" || { echo "FAIL: expected READY"; rc=1; }
  grep -q "implemented (fidelity-reviewer)" <<<"$OUT" \
    || { echo "FAIL: does not name the judge that graded it"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "true-judgment-from-a-verified-judge-passes" exec true_judgment_passes

# --- 4. the three INADMISSIBLE judgments are each refused, each for its own reason ------------------
inadmissible_judgments_are_refused() {
  local TMP; TMP="$(real_tmpdir)"; local rc=0 OUT SHA PROJROOT
  SHA="$(build_subject "$TMP" 132)" || { rm -rf "$TMP"; return 1; }
  PROJROOT="$TMP/fake-cc-projects"

  # (a) SELF-GRADED — the advisor grades its own recommendation, from a REAL dispatch of itself.
  build_real_dispatch_fixture "$PROJROOT" "$TMP" "session-132-fixture" "toolu_01SELF" plan-advisor
  land_judge_handoff "$TMP" 132 "$PROJROOT" plan-advisor \
    "obeyed-check plan-advisor rec 1 — implemented: ${SHA} — I graded my own advice"
  OUT="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJROOT" "$VAJRA" next --check-obeyed 132 2>&1 )"
  echo "--- (a) self-graded"; echo "$OUT" | grep -E 'REFUSED|graded its OWN' | head -3
  grep -q "graded its OWN recommendation" <<<"$OUT" \
    || { echo "FAIL: an advisor grading its own recommendation was accepted"; rc=1; }

  # (b) STALE — a real judge, a real dispatch, but a sha that is not the one the disposition records.
  rm -f "$TMP/.ai/handoffs/session-132-plan-advisor-judge.md"
  cat > "$TMP/.ai/handoffs/session-132-plan-advisor.md" <<HAND
---
role: plan-advisor
session: 132
agent: claude-code-subagent (verified: toolu_ADVISOR)
source-sha: deadbeef
captured: 2026-08-24T00:00:00Z
cost_usd: null
---

# Plan-advisor handoff — session 132

rec 1 — record a covers: tag on every plan step

## Handoff Delta
- \`+\` new: fixture advisor brief
HAND
  build_real_dispatch_fixture "$PROJROOT" "$TMP" "session-132-fixture" "toolu_01JUDGE"
  land_judge_handoff "$TMP" 132 "$PROJROOT" fidelity-reviewer \
    "obeyed-check plan-advisor rec 1 — implemented: 0000000abc — I read a different commit"
  OUT="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJROOT" "$VAJRA" next --check-obeyed 132 2>&1 )"
  echo "--- (b) stale sha"; echo "$OUT" | grep -E 'REFUSED|stale' | head -3
  grep -q "is stale, not evidence" <<<"$OUT" \
    || { echo "FAIL: a judgment about a different commit was accepted"; rc=1; }

  # (c) HAND-TYPED — the same judgment text, written by a human into the handoff, no dispatch.
  perl -pi -e 's/^agent: .*/agent: claude-code-subagent (verified: toolu_TOTALLYMADEUP)/' \
    "$TMP/.ai/handoffs/session-132-fidelity-reviewer.md"
  perl -pi -e "s/0000000abc/${SHA}/" "$TMP/.ai/handoffs/session-132-fidelity-reviewer.md"
  OUT="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJROOT" "$VAJRA" next --check-obeyed 132 2>&1 )"
  echo "--- (c) hand-typed provenance"; echo "$OUT" | grep -E 'REFUSED|re-verified' | head -3
  grep -q "could not be independently re-verified" <<<"$OUT" \
    || { echo "FAIL: a hand-typed judgment with fabricated provenance was accepted"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "self-graded-stale-and-hand-typed-are-refused" exec inadmissible_judgments_are_refused

# --- 5. below the threshold a missing judgment WARNs, and the exemption is NAMED --------------------
pre_threshold_warns_and_names_the_exemption() {
  local TMP; TMP="$(real_tmpdir)"; local rc=0 OUT
  build_subject "$TMP" 131 >/dev/null || { rm -rf "$TMP"; return 1; }
  OUT="$( cd "$TMP" && "$VAJRA" next --check-obeyed 131 2>&1 )"; local code=$?
  echo "$OUT"; echo "exit=$code"
  [ "$code" -eq 0 ] || { echo "FAIL: a pre-threshold session must not block, got exit $code"; rc=1; }
  grep -q "pre-threshold: WARN" <<<"$OUT" || { echo "FAIL: no per-item warning"; rc=1; }
  grep -q "threshold: session 132" <<<"$OUT" \
    || { echo "FAIL: the exemption is not named in the output"; rc=1; }
  grep -q "not silently exempt" <<<"$OUT" \
    || { echo "FAIL: the exemption is not disclosed as one"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "pre-threshold-warns-and-names-the-exemption" exec pre_threshold_warns_and_names_the_exemption

# --- 6. the S127 HISTORICAL specimen, on the REAL record of this repo — no fixture ------------------
# Read-only against this very repo: the disposition (`prompts/127-…`), the recommendation
# (`.ai/handoffs/session-127-implementation-advisor.md`), the commit (`8cd3bea`) and the judgment
# are all real, landed artifacts.
#
# rec 1 (cold review): this check must NOT pre-specify the verdict the independent judge is
# supposed to reach — a check that only goes green when the reviewer agrees with the builder tests
# the reviewer's cooperation, not the mechanism. So the expected verdict is DERIVED from the landed
# judgment line, and what is asserted is the JOIN and the BLOCKING BEHAVIOUR: the gate reports the
# verdict that was actually recorded, and exits 1 if and only if that verdict is `mismatch`.
historical_specimen_127_is_joined_and_binds() {
  local rc=0 OUT LINE WORD JUDGE_HANDOFF
  JUDGE_HANDOFF=".ai/handoffs/session-132-fidelity-reviewer.md"
  [ -f "$JUDGE_HANDOFF" ] || { echo "FAIL: no landed fidelity-reviewer handoff to read a judgment from"; return 1; }
  # The probe asserts its own pattern matched (S127) before it asserts anything about the gate.
  LINE="$(grep -E '^obeyed-check session 127 implementation-advisor rec 9 —' "$JUDGE_HANDOFF" | tail -1)"
  [ -n "$LINE" ] || { echo "FAIL: the landed handoff records no judgment for the S127 specimen"; return 1; }
  echo "landed judgment: $LINE"
  WORD="$(sed -E 's/.* rec 9 — ([a-z]+):.*/\1/' <<<"$LINE")"
  case "$WORD" in
    implemented|mismatch) echo "recorded verdict: $WORD (derived from the handoff, not assumed)" ;;
    *) echo "FAIL: could not derive a verdict word from the landed judgment"; return 1 ;;
  esac

  OUT="$( "$VAJRA" next --check-obeyed 127 2>&1 )"; local code=$?
  echo "$OUT" | grep -E 'implementation-advisor rec 9|verdict:' | head -3
  echo "exit=$code"

  # (a) THE JOIN: the gate reports the verdict that was actually recorded, against the right label.
  case "$WORD" in
    mismatch)
      grep -q "implementation-advisor rec 9 — obeyed: 8cd3bea — MISMATCH" <<<"$OUT" \
        || { echo "FAIL: a recorded mismatch did not surface against rec 9"; rc=1; }
      # (b) THE BLOCKING BEHAVIOUR: a mismatch must refuse, at a session below the threshold too.
      [ "$code" -eq 1 ] || { echo "FAIL: a recorded mismatch did not BLOCK (exit $code)"; rc=1; }
      ;;
    implemented)
      grep -q "implementation-advisor rec 9 — obeyed: 8cd3bea — implemented" <<<"$OUT" \
        || { echo "FAIL: a recorded implemented verdict did not surface against rec 9"; rc=1; }
      [ "$code" -eq 0 ] || { echo "FAIL: an implemented verdict must not block (exit $code)"; rc=1; }
      ;;
  esac
  # (c) The judge's own words are carried through, whatever they are — never the script's.
  grep -qF "$(sed -E 's/.*: [0-9a-f]+ — //' <<<"$LINE" | cut -c1-40)" <<<"$OUT" \
    || { echo "FAIL: the gate does not carry the judge's own reason into its output"; rc=1; }
  # (d) The threshold still exempts SILENCE only: S127's other dispositions warn, they do not block.
  grep -q "pre-threshold: WARN" <<<"$OUT" \
    || { echo "FAIL: the rest of S127 is not warned as pre-threshold"; rc=1; }
  return $rc
}
run_check "s127-specimen-joins-and-drives-the-exit-code" exec historical_specimen_127_is_joined_and_binds

# --- 7. the gate really BINDS `--advance`, with every other stage neutralised -----------------------
advance_binds_the_close_path() {
  local TMP; TMP="$(real_tmpdir)"; local rc=0 OUT SHA
  ( cd "$TMP" && git init -q . && git config user.email t@t && git config user.name t \
      && "$VAJRA" init >/dev/null 2>&1 </dev/null ) || { echo "FAIL: init"; rm -rf "$TMP"; return 1; }
  echo "132" > "$TMP/.ai/SESSION"
  mkdir -p "$TMP/.ai/handoffs" "$TMP/prompts"
  ( cd "$TMP" && git add -A >/dev/null 2>&1 && git commit -q -m seed --no-verify \
      && git checkout -q -b session-132-x ) || { echo "FAIL: branch"; rm -rf "$TMP"; return 1; }
  SHA="$( cd "$TMP" && git rev-parse --short=7 HEAD )"
  printf '# S132\n\n## Plan\n1. x\n\n## Advice\n\n- plan-advisor rec 1 — obeyed: %s\n' "$SHA" \
    > "$TMP/prompts/132-task-x.md"
  cat > "$TMP/.ai/handoffs/session-132-plan-advisor.md" <<HAND
---
role: plan-advisor
session: 132
agent: claude-code-subagent (verified: toolu_ADVISOR)
source-sha: deadbeef
captured: 2026-08-24T00:00:00Z
cost_usd: null
---

# Plan-advisor handoff — session 132

rec 1 — record a covers: tag on every plan step

## Handoff Delta
- \`+\` new: fixture advisor brief
HAND

  local SKIPS="VAJRA_SKIP_ANALYST_GATE=1 VAJRA_SKIP_ARCHITECT_GATE=1 VAJRA_SKIP_PLANNER_GATE=1 \
VAJRA_SKIP_CODER_GATE=1 VAJRA_SKIP_QA_GATE=1 VAJRA_SKIP_DEMOER_GATE=1 VAJRA_SKIP_RELEASER_GATE=1 \
VAJRA_SKIP_ADVICE_GATE=1 VAJRA_SKIP_FIDELITY_GATE=1"

  OUT="$( cd "$TMP" && eval "$SKIPS" "$VAJRA" next --advance 2>&1 </dev/null )"; local code=$?
  echo "$OUT" | grep -iE 'obeyed|refusing' | head -5
  [ "$code" -ne 0 ] || { echo "FAIL: --advance succeeded with an unjudged obeyed:"; rc=1; }
  grep -q "\[vajra obeyed\]" <<<"$OUT" || { echo "FAIL: the refusal did not come from the Obeyed gate"; rc=1; }
  OUT="$( cd "$TMP" && eval "$SKIPS" VAJRA_SKIP_OBEYED_GATE=1 "$VAJRA" next --advance 2>&1 </dev/null )"; code=$?
  grep -q "VAJRA_SKIP_OBEYED_GATE set" <<<"$OUT" \
    || { echo "FAIL: the override does not announce itself"; echo "$OUT" | tail -5; rc=1; }
  [ "$code" -eq 0 ] || { echo "FAIL: the override did not advance (exit $code)"; echo "$OUT" | tail -5; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "advance-really-binds-on-an-unjudged-obeyed" exec advance_binds_the_close_path

# --- 8. the falsifiability fixture is real: RED on each bypass, GREEN on renaming -------------------
obeyed_green() { ( cd "$1" && cargo test -q --lib obeyed::tests:: 2>&1 | grep -q "test result: ok" ); }

# rec 3 (cold review): a bypass probe that silently no-ops reports false comfort, and a bypass that
# fails to COMPILE is not a falsification either. So each probe asserts (a) the exact source it
# means to patch was present and is gone afterwards, and (b) the red it produces is a TEST FAILURE,
# not a compile error.
apply_bypass() {   # file, fixed-string-to-replace, replacement
  local F="$1" FROM="$2" TO="$3"
  grep -qF "$FROM" "$F" || { echo "PROBE FAIL: the bypass target is not present: $FROM"; return 1; }
  FROM="$FROM" TO="$TO" perl -0pi -e 'BEGIN{$f=$ENV{FROM};$r=$ENV{TO}} s/\Q$f\E/$r/' "$F"
  grep -qF "$FROM" "$F" && { echo "PROBE FAIL: the substitution did not land"; return 1; }
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
  # Measured this session, not assumed: the SAME `cargo test` takes ~12s in a worktree under the
  # repo's gitignored `target/` and more than TEN MINUTES in one under $TMPDIR. Probe worktrees
  # live inside the repo for that reason alone.
  local WT="$ROOT/target/s132-fixture-wt"; local rc=0
  rm -rf "$WT"; git worktree prune
  git worktree add --detach -q "$WT" HEAD 2>/dev/null || { echo "FAIL: no clean-room worktree"; return 1; }
  local D="$WT/src/obeyed/mod.rs"
  # One PERSISTENT target dir (inside the gitignored `target/`) shared by the six probe compiles
  # below, so each is incremental and the dependency graph is built once ever, not once per run.
  # Measured, not assumed: with a fresh mktemp target dir this check alone pushed the suite past
  # the QA gate's 600s live-rerun budget (CONSTRAINTS.yaml#verify.timeout_secs), and a check that
  # gets killed is a BLOCK, never a silent pass (S73). Honest limit: the FIRST run on a cold
  # machine still pays the full dependency build.
  local PROBE_TARGET="$ROOT/target/s132-probes"
  mkdir -p "$PROBE_TARGET"
  export CARGO_TARGET_DIR="$PROBE_TARGET"

  obeyed_green "$WT" && echo "OK: shipped fixture GREEN" \
    || { echo "FAIL: the shipped fixture is not green"; rc=1; }

  # Bypass A — the no-self-certification rule: let an advisor grade its own recommendation.
  if apply_bypass "$D" "if j.judge_role.eq_ignore_ascii_case(&j.advisor_role) {" "if false {" \
     && expect_test_red "$WT" obeyed::tests::an_advisor_may_not_grade_its_own_recommendation; then
    echo "OK: bypassing no-self-certification -> RED (as a test failure)"
  else
    echo "FAIL: bypassing no-self-certification did not produce an honest red"; rc=1
  fi
  git -C "$WT" checkout -q -- src/obeyed/mod.rs

  # Bypass B — the sha bind: accept a judgment about any commit.
  if apply_bypass "$D" "if !same_commit(&j.sha, disposition_sha) {" "if false {" \
     && expect_test_red "$WT" obeyed::tests::a_judgment_about_a_different_commit_is_stale_not_evidence; then
    echo "OK: bypassing the sha bind -> RED (as a test failure)"
  else
    echo "FAIL: bypassing the sha bind did not produce an honest red"; rc=1
  fi
  git -C "$WT" checkout -q -- src/obeyed/mod.rs

  # Bypass C — the provenance re-verification: trust whatever the handoff claims.
  if apply_bypass "$D" "    verified(j)" "    let _ = &verified; Ok(())" \
     && expect_test_red "$WT" obeyed::tests::an_unverifiable_judge_is_refused; then
    echo "OK: bypassing provenance re-verification -> RED (as a test failure)"
  else
    echo "FAIL: bypassing provenance re-verification did not produce an honest red"; rc=1
  fi
  git -C "$WT" checkout -q -- src/obeyed/mod.rs

  # Bypass D — sticky mismatch (rec 5's fix): let a later `implemented:` clear a recorded
  # disagreement. Without this probe the fix would be untested in the falsifiable direction.
  if apply_bypass "$D" "let chosen = sticky_mismatch.or_else(|| admitted.last());" \
        "let chosen = admitted.last().or(sticky_mismatch);" \
     && expect_test_red "$WT" obeyed::tests::a_recorded_mismatch_is_sticky_whatever_the_order; then
    echo "OK: bypassing sticky-mismatch -> RED (as a test failure)"
  else
    echo "FAIL: bypassing sticky-mismatch did not produce an honest red"; rc=1
  fi
  git -C "$WT" checkout -q -- src/obeyed/mod.rs

  # The other direction (S122): renaming every message string must NOT turn it red — and rec 12:
  # the control itself must assert its substitutions landed, or a reworded message silently makes
  # it pass for the wrong reason (the very class the four bypasses above just fixed).
  local renamed=1
  apply_bypass "$D" "graded its OWN recommendation" "RENAMED: self-graded" || renamed=0
  apply_bypass "$D" "is stale, not evidence" "RENAMED: wrong commit" || renamed=0
  apply_bypass "$D" "the judgment records no usable note" "RENAMED: no note" || renamed=0
  [ "$renamed" -eq 1 ] || { echo "FAIL: the rename control did not actually rename anything"; rc=1; }
  if obeyed_green "$WT"; then
    echo "OK: renaming every gate message -> still GREEN (the fixture binds to behaviour)"
  else
    echo "FAIL: the fixture is bound to message strings, not behaviour"; rc=1
  fi

  unset CARGO_TARGET_DIR
  git worktree remove --force "$WT" >/dev/null 2>&1 || true
  return $rc
}
run_check "fixture-red-on-bypass-green-on-rename" exec fixture_fails_for_the_right_reason

# --- 9. nothing else moved: K of 8 at a non-degenerate baseline, not a 9th station ------------------
# Measured, not assumed (this session, live): `vajra next --stations` costs ~17s in this repo and
# more than TEN MINUTES inside a `git worktree` checkout — a pre-existing property of the stations
# derivation, not something this session changed. Running the before/after here instead keeps the
# whole suite inside the QA gate's 600s live-rerun budget. The cost of that choice, stated: this
# check writes ONE file into the live repo (`.ai/handoffs/session-126-fidelity-reviewer.md`, which
# does not otherwise exist) and removes it again, guarded so it is removed even on failure.
k_of_8_unchanged_and_not_a_ninth_station() {
  local rc=0 BEFORE AFTER
  local LANDED=".ai/handoffs/session-126-fidelity-reviewer.md"
  [ -e "$LANDED" ] && { echo "FAIL: $LANDED already exists — refusing to overwrite a real handoff"; return 1; }
  local BRIEF; BRIEF="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm -f '$LANDED' '$BRIEF'" RETURN

  BEFORE="$( "$VAJRA" next --stations 126 2>&1 | grep -oE '[0-9]+ of 8 stations passed' )"
  echo "baseline (session 126): $BEFORE"
  case "$BEFORE" in
    "0 of 8 stations passed"|"") echo "FAIL: DEGENERATE baseline — this check would prove nothing"; rc=1 ;;
  esac
  # Written directly, NOT through `vajra next --role --from`: that command always writes the
  # CURRENT session's handoff, which here would clobber this session's real cold review. The write
  # path is exercised by checks 2, 3 and 4; what this check needs is a landed handoff carrying the
  # new marker.
  cat > "$LANDED" <<HAND
---
role: fidelity-reviewer
session: 126
agent: claude-code-subagent (verified: toolu_KOF8FIXTURE)
source-sha: deadbeef
captured: 2026-08-24T00:00:00Z
cost_usd: null
---

# Fidelity-reviewer handoff — session 126

rec 1 — a fixture finding
obeyed-check plan-advisor rec 1 — implemented: deadbeef — must not move K

## Handoff Delta
- \`+\` new: K-of-8 fixture handoff
HAND
  [ -f "$LANDED" ] || { echo "FAIL: the handoff did not land, so the after-reading proves nothing"; return 1; }
  # One invocation, read twice — `--stations` costs ~30s here and the suite must stay inside the
  # QA gate's 600s live-rerun budget.
  local SOUT; SOUT="$( "$VAJRA" next --stations 126 2>&1 )"
  AFTER="$( grep -oE '[0-9]+ of 8 stations passed' <<<"$SOUT" )"
  echo "after a handoff carrying an obeyed-check lands: $AFTER"
  [ "$BEFORE" = "$AFTER" ] || { echo "FAIL: the judgment marker moved K"; rc=1; }
  if grep -ciE '(\[PASSED\]|\[ABSENT\]|\[LEGACY\]) *obeyed' <<<"$SOUT" | grep -qv '^0$'; then
    echo "FAIL: obeyed appears as a station row"; rc=1
  else
    echo "OK: obeyed is not a ninth station ($(grep -cE '\[(PASSED|ABSENT|LEGACY)\]' <<<"$SOUT") station rows read)"
  fi
  return $rc
}
run_check "k-of-8-unchanged-and-not-a-ninth-station" exec k_of_8_unchanged_and_not_a_ninth_station

# --- 10. the S127 Advice gate's own contract is UNCHANGED by this session ---------------------------
advice_gate_contract_unchanged() {
  local rc=0 OUT
  OUT="$( "$VAJRA" next --check-advice 127 2>&1 )"; local code=$?
  echo "$OUT" | tail -3; echo "exit=$code"
  [ "$code" -eq 0 ] || { echo "FAIL: --check-advice 127 changed verdict (exit $code)"; rc=1; }
  grep -q "verdict: READY" <<<"$OUT" \
    || { echo "FAIL: the Advice gate no longer reports S127 answered"; rc=1; }
  grep -q "implementation-advisor rec 9 — obeyed: 8cd3bea" <<<"$OUT" \
    || { echo "FAIL: the Advice gate stopped reading the specimen"; rc=1; }
  return $rc
}
run_check "advice-gate-contract-unchanged" exec advice_gate_contract_unchanged

# --- 10b. S131's Fidelity gate contract is UNCHANGED — traced, not asserted (cold review rec 4) ----
# AC 6 names S131's gate by hand, and the first draft of this suite never ran it once.
fidelity_gate_contract_unchanged() {
  local TMP; TMP="$(real_tmpdir)"; local rc=0 OUT PROJROOT
  build_subject "$TMP" 132 >/dev/null || { rm -rf "$TMP"; return 1; }
  # (a) absence still BLOCKS with S131's own message
  OUT="$( cd "$TMP" && "$VAJRA" next --check-fidelity-handoff 132 2>&1 )"; local code=$?
  echo "--- absent: exit=$code"; echo "$OUT" | grep -E 'no fidelity-reviewer handoff|verdict:' | head -2
  [ "$code" -eq 1 ] || { echo "FAIL: absence no longer blocks (exit $code)"; rc=1; }
  grep -q "no fidelity-reviewer handoff recorded for session 132" <<<"$OUT" \
    || { echo "FAIL: S131's absence message changed"; rc=1; }
  # (b) a real dispatch still PASSES — and a handoff carrying this session's new marker does not
  #     disturb that (the marker rides the findings body, which S131's gate never parsed).
  PROJROOT="$TMP/fake-cc-projects"
  build_real_dispatch_fixture "$PROJROOT" "$TMP" "session-132-fixture" "toolu_01FIDELITY"
  land_judge_handoff "$TMP" 132 "$PROJROOT" fidelity-reviewer \
    "obeyed-check plan-advisor rec 1 — implemented: deadbeef — a marker in the body"
  OUT="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJROOT" "$VAJRA" next --check-fidelity-handoff 132 2>&1 )"; code=$?
  echo "--- real dispatch: exit=$code"; echo "$OUT" | grep -E 'verdict:|agent:' | head -2
  [ "$code" -eq 0 ] || { echo "FAIL: a real dispatch no longer passes S131's gate (exit $code)"; rc=1; }
  grep -q "verdict: READY" <<<"$OUT" || { echo "FAIL: expected READY from the Fidelity gate"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "s131-fidelity-gate-contract-unchanged" exec fidelity_gate_contract_unchanged

# --- 11. the whole library is green, including the new module --------------------------------------
run_check "lib-tests-green" exec cargo test -q --lib

# --- 12. still seven top-level commands ------------------------------------------------------------
# BEHAVIORAL, and labelled so — the same hardcoded-banner grep named since S69.
help_lists_seven() {
  local help; help="$("$VAJRA" --help 2>&1)"; echo "$help"
  grep -q "vajra <init|claude|check|next|estimate|hook|meter>" <<<"$help"
}
run_check "no-eighth-command" behav help_lists_seven

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session 132 Verify Summary ==="
printf '%-52s %-7s %s\n' "STEP" "CLASS" "RESULT"
printf '%-52s %-7s %s\n' "----------------------------------------------------" "-------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo ""
print_tally "$EXEC_N" "$STRUCT_N" "$BEHAV_N" "$NESTED_N" "${NESTED_NAMES[@]:-}"
echo ""
echo "WHAT THIS SUITE NEVER EXERCISED — stated, not buried:"
echo "  * whether a judge's verdict is CORRECT. A judge that writes 'implemented:' without reading"
echo "    the diff passes every check here — the form floor, same class as S127's refusal reason."
echo "  * the regress: the judgment lives in a handoff whose own recommendations get dispositions"
echo "    that would themselves need judging. This session terminates it by hand, not by mechanism."
echo "  * refused: / deferred: dispositions — explicitly out of scope (S132 Non-goals)."
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
