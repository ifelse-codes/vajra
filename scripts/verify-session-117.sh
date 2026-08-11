#!/usr/bin/env bash
# Verify — Session 117: prove the Plan Advisor (the fleet's third role) dispatches BY NAME.
#
# S116 shipped `plan-advisor` as a scaffolded file the S111 mid-creating-session limit made
# undispatchable within its own session. This is the first fresh session after that commit landed
# on main — the earliest point the wire could be tested, mirroring S111 (role 1) and S115 (role 2).
# These checks are aimed at the two ways "it dispatched by name" could be faked: (a) a hand-typed
# copy of a JSON blob instead of two independently-written Claude Code files agreeing on a random
# tool-call ID, and (b) a governed handoff existing without any dispatch evidence behind it at all.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="117"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-34s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-34s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- toolchain: unchanged discipline ----------------------------------------------------------
run_check "cargo-build"   cargo build --all-targets
run_check "cargo-test"    cargo test --lib
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings

# Count-agnostic regressions must still hold — this session proves dispatch, it does not get to
# move what the fleet already guarantees. Reusing S113 (role-count-agnostic), same reasoning S116
# recorded: a fixed-count script like S114's goes stale by construction as the fleet grows.
run_check "fleet-smoke"              bash scripts/fleet-smoke.sh
run_check "s113-counter-still-green" bash scripts/verify-session-113.sh

VAJRA="$ROOT/target/debug/vajra"

# --- design-significant: no, honoured — no src/ changed this session ---------------------------
no_src_changes() {
  local D; D="$(git diff --stat main -- src/ 2>/dev/null)"
  if [ -n "$D" ]; then
    echo "src/ diff vs main:"; echo "$D"
    echo "FAIL: this session's prompt declares design-significant: no — no src/ change expected"
    return 1
  fi
  echo "OK: no src/ changes — this session supplies evidence, not new code paths"
}
run_check "no-src-changes" no_src_changes

# --- criterion 1: dispatch resolved by name, on the first try ----------------------------------
ARTDIR="sessions/session-117-artifacts"
dispatch_resolved_by_name() {
  for f in plan-advisor-parent-tooluse.json plan-advisor-subagent-meta.json \
           plan-advisor-subagent-transcript.jsonl plan-advisor-brief.md plan-advisor-run-note.md; do
    [ -f "$ARTDIR/$f" ] || { echo "FAIL: missing $ARTDIR/$f"; return 1; }
  done
  grep -q '"subagent_type": "plan-advisor"' "$ARTDIR/plan-advisor-parent-tooluse.json" \
    || { echo "FAIL: parent tool-use record does not request subagent_type: plan-advisor"; return 1; }
  grep -q "resolved by name on the first try\|worked immediately\|no \`general-purpose\` fallback" \
    "$ARTDIR/plan-advisor-run-note.md" \
    || { echo "FAIL: run note does not record whether the dispatch worked on the first try"; return 1; }
  echo "OK: dispatch requested subagent_type: plan-advisor; run note records the first-try result"
}
run_check "criterion1-dispatch-by-name" dispatch_resolved_by_name

# "First try, no workaround" is a real, load-bearing claim — checking it by grepping the run note's
# own prose for a magic phrase is hollow (the same author who wrote the claim wrote the check for
# it, per the S117 cold review). Independent evidence: the LIVE parent session transcript itself,
# outside anything this session hand-authored — count how many times subagent_type:"plan-advisor"
# was actually requested. A retry-after-failure would show up as MORE than one, or as an earlier
# attempt at a different (fallback) subagent_type for the same task. This is local-machine-only,
# same limitation class as check-subagent-cost-fields.sh.
first_try_independently_confirmed() {
  local PARENT_SESSION_ID; PARENT_SESSION_ID="$(python3 -c "
import json
print(json.load(open('$ARTDIR/plan-advisor-parent-tooluse.json'))[0]['parent_session_id'])
")"
  local JSONL; JSONL="$(find "$HOME/.claude/projects" -maxdepth 2 -name "${PARENT_SESSION_ID}.jsonl" 2>/dev/null | head -1)"
  if [ -z "$JSONL" ]; then
    echo "SKIP: parent session transcript not found on this machine (local-only evidence, same class as --dogfood-age)"
    return 0
  fi
  local N; N="$(grep -o '"subagent_type":[[:space:]]*"plan-advisor"' "$JSONL" | wc -l | tr -d ' ')"
  echo "occurrences of subagent_type: plan-advisor in the real parent transcript: $N"
  [ "$N" = "1" ] || { echo "FAIL: expected exactly 1 dispatch attempt, found $N — first-try claim not independently confirmed"; return 1; }
  echo "OK: exactly one dispatch attempt in the real transcript — first-try, independently confirmed, not self-typed prose"
}
run_check "criterion1-first-try-independently-confirmed" first_try_independently_confirmed

# --- criterion 2: independent, non-copyable, cross-referencing evidence ------------------------
cross_referencing_evidence() {
  local PARENT_ID SUBAGENT_TOOLUSE_ID SUBAGENT_AGENT_TYPE
  PARENT_ID="$(grep -o '"id": "toolu_[a-zA-Z0-9]*"' "$ARTDIR/plan-advisor-parent-tooluse.json" | head -1 | grep -o 'toolu_[a-zA-Z0-9]*')"
  SUBAGENT_TOOLUSE_ID="$(grep -o '"toolUseId":"toolu_[a-zA-Z0-9]*"' "$ARTDIR/plan-advisor-subagent-meta.json" | grep -o 'toolu_[a-zA-Z0-9]*')"
  SUBAGENT_AGENT_TYPE="$(grep -o '"agentType":"[a-z-]*"' "$ARTDIR/plan-advisor-subagent-meta.json" | grep -o '"[a-z-]*"$' | tr -d '"')"

  echo "parent tool_use.id         : $PARENT_ID"
  echo "subagent meta toolUseId    : $SUBAGENT_TOOLUSE_ID"
  echo "subagent meta agentType    : $SUBAGENT_AGENT_TYPE"

  [ -n "$PARENT_ID" ] || { echo "FAIL: could not extract parent tool_use id"; return 1; }
  [ "$PARENT_ID" = "$SUBAGENT_TOOLUSE_ID" ] \
    || { echo "FAIL: parent tool-call id and subagent toolUseId do not match — not the same dispatch"; return 1; }
  [ "$SUBAGENT_AGENT_TYPE" = "plan-advisor" ] \
    || { echo "FAIL: subagent meta agentType is not plan-advisor"; return 1; }

  # The transcript file must be the real thing, not a hand-typed stand-in: non-trivial JSONL with a
  # matching sha256 recorded in the run note (so the recorded hash cannot silently drift from the file).
  local LINES SHA RECORDED_SHA
  LINES="$(wc -l < "$ARTDIR/plan-advisor-subagent-transcript.jsonl" | tr -d ' ')"
  [ "${LINES:-0}" -gt 1 ] || { echo "FAIL: subagent transcript has $LINES lines — too small to be real"; return 1; }
  SHA="$(shasum -a 256 "$ARTDIR/plan-advisor-subagent-transcript.jsonl" | awk '{print $1}')"
  RECORDED_SHA="$(grep -o '[0-9a-f]\{64\}' "$ARTDIR/plan-advisor-run-note.md" | head -1)"
  echo "transcript sha256 (live)   : $SHA"
  echo "transcript sha256 (recorded): $RECORDED_SHA"
  [ "$SHA" = "$RECORDED_SHA" ] || { echo "FAIL: transcript sha256 does not match what the run note recorded"; return 1; }

  echo "OK: two independently-written Claude Code files agree on tool-call $PARENT_ID; transcript hash verified"
}
run_check "criterion2-cross-referencing-evidence" cross_referencing_evidence

# --- criterion 3: governed handoff + --stations reports it beside K, K unchanged ---------------
handoff_governed_and_counted() {
  local H=".ai/handoffs/session-117-plan-advisor.md"
  [ -f "$H" ] || { echo "FAIL: no governed handoff at $H"; return 1; }
  grep -q "^role: plan-advisor$" "$H" || { echo "FAIL: handoff role frontmatter wrong"; return 1; }
  grep -qE "^source-sha: [0-9a-f]{64}$" "$H" || { echo "FAIL: handoff carries no real source hash"; return 1; }

  # source-sha hashes the TRIMMED body (`findings.trim()` in src/cli/next.rs), not raw file bytes.
  local EXPECTED_SHA RECORDED_SHA
  EXPECTED_SHA="$(python3 -c "import hashlib,sys; sys.stdout.write(hashlib.sha256(open('$ARTDIR/plan-advisor-brief.md').read().strip().encode()).hexdigest())")"
  RECORDED_SHA="$(grep -oE '^source-sha: [0-9a-f]{64}$' "$H" | awk '{print $2}')"
  echo "brief sha256 (live)      : $EXPECTED_SHA"
  echo "handoff source-sha       : $RECORDED_SHA"
  [ "$EXPECTED_SHA" = "$RECORDED_SHA" ] \
    || { echo "FAIL: handoff source-sha does not match the brief file it claims to be sourced from"; return 1; }

  local STATIONS; STATIONS="$("$VAJRA" next --stations 117 2>&1)"
  echo "--- vajra next --stations 117 ---"; echo "$STATIONS"
  grep -q "fleet: 1 governed handoff(s) — plan-advisor" <<<"$STATIONS" \
    || { echo "FAIL: --stations does not report exactly one plan-advisor handoff"; return 1; }
  grep -q "NOT counted in it" <<<"$STATIONS" \
    || { echo "FAIL: the fleet line stopped disclosing it sits outside K"; return 1; }
  grep -qE "^  [0-9] of 8 stations passed" <<<"$STATIONS" \
    || { echo "FAIL: no K-of-8 line found — cannot confirm K is a plain station count, unaffected by fleet"; return 1; }
  echo "OK: handoff source-sha matches the real brief; --stations names it beside K, outside K"
}
run_check "criterion3-handoff-governed-and-counted" handoff_governed_and_counted

# --- criterion 4 (2nd half): demo-session-117.sh itself exits 0 -- run it, not just assert it -----
run_check "demo-session-117-exits-zero" bash scripts/demo-session-117.sh

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-34s %s\n' "STEP" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
