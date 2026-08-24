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
# are all real, landed artifacts. This is the check that proves the mechanism WOULD have caught the
# S127 defect, rather than asserting it in prose.
historical_specimen_127_is_caught() {
  local rc=0 OUT
  OUT="$( "$VAJRA" next --check-obeyed 127 2>&1 )"; local code=$?
  echo "$OUT" | grep -E 'implementation-advisor rec 9|verdict:' | head -5
  echo "exit=$code"
  [ "$code" -eq 1 ] || { echo "FAIL: the specimen does not BLOCK (exit $code)"; rc=1; }
  grep -q "implementation-advisor rec 9 — obeyed: 8cd3bea — MISMATCH" <<<"$OUT" \
    || { echo "FAIL: rec 9 is not reported a MISMATCH on the real record"; rc=1; }
  grep -q "_uses" <<<"$OUT" \
    || { echo "FAIL: the judgment does not name what the commit failed to do"; rc=1; }
  # And the pre-threshold exemption still applies to the OTHER 47 dispositions of that session —
  # the threshold governs silence, never a judgment that exists.
  grep -q "pre-threshold: WARN" <<<"$OUT" \
    || { echo "FAIL: the rest of S127 is not warned as pre-threshold"; rc=1; }
  return $rc
}
run_check "s127-historical-specimen-is-a-mismatch" exec historical_specimen_127_is_caught

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

  OUT="$( cd "$TMP" && eval "$SKIPS" "$VAJRA" next --advance 2>&1 )"; local code=$?
  echo "$OUT" | grep -iE 'obeyed|refusing' | head -5
  [ "$code" -ne 0 ] || { echo "FAIL: --advance succeeded with an unjudged obeyed:"; rc=1; }
  grep -q "\[vajra obeyed\]" <<<"$OUT" || { echo "FAIL: the refusal did not come from the Obeyed gate"; rc=1; }
  OUT="$( cd "$TMP" && eval "$SKIPS" VAJRA_SKIP_OBEYED_GATE=1 "$VAJRA" next --advance 2>&1 )"; code=$?
  grep -q "VAJRA_SKIP_OBEYED_GATE set" <<<"$OUT" \
    || { echo "FAIL: the override does not announce itself"; echo "$OUT" | tail -5; rc=1; }
  [ "$code" -eq 0 ] || { echo "FAIL: the override did not advance (exit $code)"; echo "$OUT" | tail -5; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "advance-really-binds-on-an-unjudged-obeyed" exec advance_binds_the_close_path

# --- 8. the falsifiability fixture is real: RED on each bypass, GREEN on renaming -------------------
obeyed_green() { ( cd "$1" && cargo test -q --lib obeyed::tests:: 2>&1 | grep -q "test result: ok" ); }
fixture_fails_for_the_right_reason() {
  local WT; WT="$(mktemp -d)"; local rc=0
  git worktree add --detach -q "$WT" HEAD 2>/dev/null || { echo "FAIL: no clean-room worktree"; return 1; }
  local D="$WT/src/obeyed/mod.rs"

  obeyed_green "$WT" && echo "OK: shipped fixture GREEN" \
    || { echo "FAIL: the shipped fixture is not green"; rc=1; }

  # Bypass A — the no-self-certification rule: let an advisor grade its own recommendation.
  perl -0pi -e 's/if j\.judge_role\.eq_ignore_ascii_case\(&j\.advisor_role\) \{/if false {/' "$D"
  if ( cd "$WT" && cargo test -q --lib obeyed::tests::an_advisor_may_not_grade_its_own_recommendation 2>&1 | grep -q "test result: ok" ); then
    echo "FAIL: bypassing no-self-certification left its own test GREEN"; rc=1
  else
    echo "OK: bypassing no-self-certification -> RED"
  fi
  git -C "$WT" checkout -q -- src/obeyed/mod.rs

  # Bypass B — the sha bind: accept a judgment about any commit.
  perl -0pi -e 's/if !same_commit\(&j\.sha, disposition_sha\) \{/if false {/' "$D"
  if ( cd "$WT" && cargo test -q --lib obeyed::tests::a_judgment_about_a_different_commit_is_stale_not_evidence 2>&1 | grep -q "test result: ok" ); then
    echo "FAIL: bypassing the sha bind left its own test GREEN"; rc=1
  else
    echo "OK: bypassing the sha bind -> RED"
  fi
  git -C "$WT" checkout -q -- src/obeyed/mod.rs

  # Bypass C — the provenance re-verification: trust whatever the handoff claims.
  perl -0pi -e 's/    verified\(j\)\n\}/    let _ = verified; Ok(())\n}/' "$D"
  if ( cd "$WT" && cargo test -q --lib obeyed::tests::an_unverifiable_judge_is_refused 2>&1 | grep -q "test result: ok" ); then
    echo "FAIL: bypassing provenance re-verification left its own test GREEN"; rc=1
  else
    echo "OK: bypassing provenance re-verification -> RED"
  fi
  git -C "$WT" checkout -q -- src/obeyed/mod.rs

  # The other direction (S122): renaming every message string must NOT turn it red.
  perl -pi -e 's/graded its OWN recommendation/RENAMED: self-graded/; s/is stale, not evidence/RENAMED: wrong commit/; s/the judgment records no usable note/RENAMED: no note/' "$D"
  if obeyed_green "$WT"; then
    echo "OK: renaming every gate message -> still GREEN (the fixture binds to behaviour)"
  else
    echo "FAIL: the fixture is bound to message strings, not behaviour"; rc=1
  fi

  git worktree remove --force "$WT" >/dev/null 2>&1 || true
  return $rc
}
run_check "fixture-red-on-bypass-green-on-rename" exec fixture_fails_for_the_right_reason

# --- 9. nothing else moved: K of 8 at a non-degenerate baseline, not a 9th station ------------------
k_of_8_unchanged_and_not_a_ninth_station() {
  local WT; WT="$(mktemp -d)"; local rc=0 BEFORE AFTER
  git worktree add --detach -q "$WT" HEAD 2>/dev/null || { echo "FAIL: no worktree"; return 1; }
  BEFORE="$( cd "$WT" && "$VAJRA" next --stations 126 2>&1 | grep -oE '[0-9]+ of 8 stations passed' )"
  echo "baseline (session 126): $BEFORE"
  case "$BEFORE" in
    "0 of 8 stations passed"|"") echo "FAIL: DEGENERATE baseline — this check would prove nothing"; rc=1 ;;
  esac
  printf 'rec 1 — a fixture finding\nobeyed-check plan-advisor rec 1 — implemented: deadbeef — must not move K\n' > "$WT/b.md"
  ( cd "$WT" && "$VAJRA" next --role fidelity-reviewer --from b.md >/dev/null 2>&1 ) || rc=1
  AFTER="$( cd "$WT" && "$VAJRA" next --stations 126 2>&1 | grep -oE '[0-9]+ of 8 stations passed' )"
  echo "after a handoff carrying an obeyed-check lands: $AFTER"
  [ "$BEFORE" = "$AFTER" ] || { echo "FAIL: the judgment marker moved K"; rc=1; }
  local SOUT; SOUT="$( cd "$WT" && "$VAJRA" next --stations 126 2>&1 )"
  if grep -ciE '(\[PASSED\]|\[ABSENT\]|\[LEGACY\]) *obeyed' <<<"$SOUT" | grep -qv '^0$'; then
    echo "FAIL: obeyed appears as a station row"; rc=1
  else
    echo "OK: obeyed is not a ninth station ($(grep -cE '\[(PASSED|ABSENT|LEGACY)\]' <<<"$SOUT") station rows read)"
  fi
  git worktree remove --force "$WT" >/dev/null 2>&1 || true
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
