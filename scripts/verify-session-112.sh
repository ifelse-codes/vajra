#!/usr/bin/env bash
# Verify — Session 112: downstream handoff-consumption (founder pick at S112 kickoff).
#
# S109 wrote governed handoffs, S111 proved they come from a real by-name dispatch — and nothing
# read one back. This session made three Analyst surfaces consume them. So the checks here are
# behavioural, not structural: the SAME command in the SAME repo must produce DIFFERENT output
# solely because a governed handoff exists, and IDENTICAL output when one does not.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="112"
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

# --- toolchain: unchanged discipline ----------------------------------------------------------
run_check "cargo-build"   cargo build --all-targets
run_check "cargo-test"    cargo test --lib
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings

# --- the S109 fail-closed writer smoke must still hold (this session only ADDS a reader) --------
run_check "fleet-smoke"   bash scripts/fleet-smoke.sh

VAJRA="$ROOT/target/debug/vajra"

# --- the reader's own unit contract (path-is-SoT, malformed != absent, inline findings) ---------
# (`cargo test` takes ONE filter, so one check per contract — each names what it locks down.)
run_check "test-read-absent-vs-malformed" \
  cargo test --lib fleet::tests::read_handoff_absent_found_and_malformed
run_check "test-path-is-session-sot" \
  cargo test --lib fleet::tests::parse_handoff_trusts_the_path_not_a_self_declared_session
run_check "test-findings-inlined" \
  cargo test --lib fleet::tests::format_handoff_brief_inlines_findings_and_is_empty_when_absent
run_check "test-intake-consumes" \
  cargo test --lib analyst::tests::intake_consumes_a_governed_researcher_handoff
run_check "test-intake-names-broken" \
  cargo test --lib analyst::tests::intake_surfaces_a_malformed_handoff_instead_of_swallowing_it

# --- END-TO-END, in a throwaway repo: govern a handoff, watch the output CHANGE -----------------
# The honest shape of the proof: capture the consuming station's output BEFORE any handoff exists,
# govern one through the real `vajra next --role` writer, capture the output AFTER, and require a
# difference that carries the actual findings. No fixture is hand-placed on disk.
e2e_consumption() { local TMP; TMP="$(mktemp -d)"; _e2e_consumption "$TMP"; local rc=$?; rm -rf "$TMP"; return $rc; }
_e2e_consumption() {
  local TMP="$1"
  ( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null ) || { echo "vajra init failed"; return 1; }
  echo "112" > "$TMP/.ai/SESSION"

  local BEFORE AFTER
  BEFORE="$(cd "$TMP" && "$VAJRA" next --intake 2>&1)" || { echo "intake failed (before)"; return 1; }
  echo "--- BEFORE ---"; echo "$BEFORE"

  # A silent, harmless absence: not one word about handoffs when there are none.
  if echo "$BEFORE" | grep -qi "handoff"; then
    echo "FAIL: intake mentions handoffs when none exist (absence must be silent)"; return 1
  fi

  printf 'ANSWER: ANTHROPIC_API_KEY is the only auth that survives a fresh no-TTY shell.\nclaude setup-token is the subscription alternative.\n' > "$TMP/findings.md"
  ( cd "$TMP" && "$VAJRA" next --role researcher --from findings.md ) >/dev/null \
    || { echo "governing the handoff failed"; return 1; }

  AFTER="$(cd "$TMP" && "$VAJRA" next --intake 2>&1)" || { echo "intake failed (after)"; return 1; }
  echo "--- AFTER ---"; echo "$AFTER"

  [ "$BEFORE" != "$AFTER" ] || { echo "FAIL: intake output did not change"; return 1; }
  echo "$AFTER" | grep -q "fleet handoffs" \
    || { echo "FAIL: no fleet handoffs block"; return 1; }
  echo "$AFTER" | grep -q ".ai/handoffs/session-112-researcher.md" \
    || { echo "FAIL: handoff path not surfaced"; return 1; }
  # INLINE findings, not merely a pointer — the whole point of consumption.
  echo "$AFTER" | grep -q "ANTHROPIC_API_KEY is the only auth" \
    || { echo "FAIL: findings not inlined"; return 1; }

  # The packet an agent boots on carries it too. (Captured to a variable, never piped straight
  # into `grep -q`: under `pipefail` an early-closing reader would fail the pipeline on SIGPIPE.)
  local PACKET; PACKET="$(cd "$TMP" && "$VAJRA" next 2>&1)"
  echo "$PACKET" | grep -q "fleet handoffs (session 112)" \
    || { echo "FAIL: packet does not carry the handoff"; return 1; }

  # A DIFFERENT session is untouched by session 112's handoff.
  echo "113" > "$TMP/.ai/SESSION"
  local OTHER; OTHER="$(cd "$TMP" && "$VAJRA" next --intake 2>&1)"
  if echo "$OTHER" | grep -qi "fleet handoffs"; then
    echo "FAIL: session 113 shows session 112's handoff"; return 1
  fi

  # Malformed must be NAMED, never swallowed as absent (no false green).
  echo "112" > "$TMP/.ai/SESSION"
  echo "just some notes, no frontmatter" > "$TMP/.ai/handoffs/session-112-researcher.md"
  local BROKEN; BROKEN="$(cd "$TMP" && "$VAJRA" next --intake 2>&1)"
  echo "$BROKEN" | grep -q "not used" \
    || { echo "FAIL: malformed handoff swallowed"; return 1; }

  echo "E2E OK: absent silent · governed handoff consumed inline · other sessions unaffected · malformed named"
  return 0
}
run_check "e2e-consumption" e2e_consumption

# --- REAL DATA, this repo: session 111's genuine subagent-derived handoff is now surfaced -------
# Stronger than the tempdir fixture: this handoff was produced by an actual by-name subagent
# dispatch (S111's evidence trail), and the Analyst gate now shows it without being told to look.
real_handoff_surfaced() {
  local OUT_111 OUT_110
  OUT_111="$("$VAJRA" next --validate 111 2>&1)"
  OUT_110="$("$VAJRA" next --validate 110 2>&1)"
  echo "--- validate 111 ---"; echo "$OUT_111"
  echo "--- validate 110 ---"; echo "$OUT_110"
  echo "$OUT_111" | grep -q ".ai/handoffs/session-111-researcher.md" \
    || { echo "FAIL: real S111 handoff not surfaced at the Analyst gate"; return 1; }
  echo "$OUT_111" | grep -q "researcher (agent:" \
    || { echo "FAIL: provenance line missing"; return 1; }
  # S110 has no handoff — its gate output must not mention one.
  if echo "$OUT_110" | grep -qi "handoffs/session-110"; then
    echo "FAIL: session 110 output mentions a handoff it does not have"; return 1
  fi
  return 0
}
run_check "real-handoff-surfaced" real_handoff_surfaced

# --- no 8th command: consumption rides `next`, exactly like the writer did ----------------------
help_lists_seven() {
  local help; help="$("$VAJRA" --help 2>&1)"
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
