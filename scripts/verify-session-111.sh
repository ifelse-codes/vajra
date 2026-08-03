#!/usr/bin/env bash
# Verify — Session 111: close the fleet's def-vs-dispatch wire (founder pick A at S110 GT).
# Exit 0 = done. This session's headline deliverable is EVIDENCE (an on-disk proof that Claude
# Code's own Task tool resolves a scaffolded `.claude/agents/<name>.md` by name), not new runtime
# code — so this verify checks that the evidence trail is real and complete, alongside the usual
# toolchain + fail-closed fleet-smoke gates.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="111"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-32s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-32s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- toolchain: unchanged discipline — build/test/fmt/clippy all green -------------------------------
run_check "cargo-build"   cargo build --all-targets
run_check "cargo-test"    cargo test --lib
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings

# --- the fail-closed smoke from S109 must still hold (this session touches no dispatch code) --------
run_check "fleet-smoke"   bash scripts/fleet-smoke.sh

# --- the dispatch-wire evidence trail exists AND cross-references, not a self-referential grep -------
# A single copied .meta.json is trivially hand-typed. The real check: the parent session's own
# tool-call record and the subagent's own meta.json are TWO SEPARATE Claude-Code-written files that
# must agree on the same random tool-call ID — that's much harder to fake than one JSON blob.
check_dispatch_evidence() {
  local RUN_NOTE="sessions/session-111-artifacts/researcher-run-note.md"
  local META="sessions/session-111-artifacts/researcher-subagent-meta.json"
  local PARENT="sessions/session-111-artifacts/researcher-parent-tooluse.json"
  local TRANSCRIPT="sessions/session-111-artifacts/researcher-subagent-transcript.jsonl"
  local BRIEF="sessions/session-111-artifacts/researcher-subagent-brief.md"
  local HANDOFF=".ai/handoffs/session-111-researcher.md"

  for f in "$RUN_NOTE" "$META" "$PARENT" "$TRANSCRIPT" "$BRIEF" "$HANDOFF"; do
    [ -f "$f" ] || { echo "missing $f"; return 1; }
  done

  command -v python3 >/dev/null 2>&1 || { echo "python3 required for cross-reference check"; return 1; }

  python3 - "$META" "$PARENT" "$TRANSCRIPT" <<'PYEOF' || return 1
import json, sys
meta_path, parent_path, transcript_path = sys.argv[1], sys.argv[2], sys.argv[3]

meta = json.load(open(meta_path))
if meta.get("agentType") != "researcher":
    print(f"meta.json agentType is {meta.get('agentType')!r}, not 'researcher'"); sys.exit(1)
tool_use_id = meta.get("toolUseId")
if not tool_use_id:
    print("meta.json has no toolUseId to cross-reference"); sys.exit(1)

parent = json.load(open(parent_path))
if not isinstance(parent, list) or not parent:
    print("parent tool-use record is empty or malformed"); sys.exit(1)
entry = parent[0]
tool_use = entry.get("tool_use", {})
if tool_use.get("id") != tool_use_id:
    print(f"parent tool_use id {tool_use.get('id')!r} != subagent meta toolUseId {tool_use_id!r}"); sys.exit(1)
if tool_use.get("input", {}).get("subagent_type") != "researcher":
    print("parent tool_use input.subagent_type is not 'researcher'"); sys.exit(1)

# The raw transcript must be real Claude Code JSONL (an assistant line with a model + usage), not a stub.
found_usage = False
for line in open(transcript_path):
    line = line.strip()
    if not line:
        continue
    v = json.loads(line)
    if v.get("type") == "assistant" and v.get("message", {}).get("usage"):
        found_usage = True
if not found_usage:
    print("subagent transcript has no assistant line with real usage data"); sys.exit(1)

print("cross-reference OK: parent tool_use.id == subagent meta.toolUseId == " + tool_use_id)
PYEOF

  # The run note must disclose BOTH halves honestly: the same-session negative result AND the
  # fresh-session positive result — a one-sided write-up would be the new fakest-green.
  grep -q "Agent type 'researcher' not found" "$RUN_NOTE" \
    || { echo "run note omits the same-session negative result"; return 1; }
  grep -qi "toolUseId" "$RUN_NOTE" \
    || { echo "run note omits the cross-reference proof"; return 1; }

  # The handoff is a real, validated fleet handoff (same contract as S109), governed from the
  # ACTUAL captured brief — not a stub.
  grep -q "^role: researcher" "$HANDOFF" || { echo "handoff missing role"; return 1; }
  grep -q "^session: 111" "$HANDOFF" || { echo "handoff missing session"; return 1; }
  grep -Eq "^source-sha: [0-9a-f]{64}$" "$HANDOFF" || { echo "handoff source-sha not 64-hex"; return 1; }

  return 0
}
run_check "dispatch-wire-evidence" check_dispatch_evidence

# --- cost: a REAL, re-runnable scan (not a doc-comment string match) — asserts null stays honest ------
run_check "subagent-cost-check" bash scripts/check-subagent-cost-fields.sh --assert-null

# --- DECISION-007 carries the S111 addendum (design record, not just session prose) ------------------
run_check "decision-007-addendum" grep -q "S111 addendum" docs/decisions/DECISION-007-agent-fleet.md

# --- max-7-commands guard: still no 8th — this session rides init + next, same as S109 ---------------
help_lists_seven() {
  local help; help="$(./target/debug/vajra --help 2>&1)"
  echo "$help"
  echo "$help" | grep -q "vajra <init|claude|check|next|estimate|hook|meter>"
}
run_check "no-eighth-command" help_lists_seven

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-32s %s\n' "STEP" "RESULT"
printf '%-32s %s\n' "--------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
