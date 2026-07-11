#!/usr/bin/env bash
# Fail-closed closeout gate. Exit 0 = closeout done.
# Single source of truth: .ai/SESSION (one integer).

set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/closeout/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
ok()  { RESULTS+=("$(printf '%-34s %s' "$1" PASS)"); PASS=$((PASS+1)); }
bad() { RESULTS+=("$(printf '%-34s %s' "$1" FAIL)"); FAIL=$((FAIL+1)); }

N=""
check_session_file() {
  local NAME="session-file-valid"; local LOG="$ARTIFACTS/${NAME}.log"
  if [ ! -f .ai/SESSION ]; then echo "BLOCK: .ai/SESSION missing" > "$LOG"; bad "$NAME"; return; fi
  local raw; raw="$(tr -d ' \t\n\r' < .ai/SESSION)"
  if [[ "$raw" =~ ^[0-9]+$ ]]; then
    N="$((10#$raw))"; echo "OK: $raw (N=$N)" > "$LOG"; ok "$NAME"
  else
    echo "BLOCK: not an integer: '$raw'" > "$LOG"; bad "$NAME"
  fi
}

check_required_files() {
  local NAME="required-files-exist"; local LOG="$ARTIFACTS/${NAME}.log"
  : > "$LOG"
  local missing=0
  for f in .ai/AGENTS.md .ai/SESSION .ai/SESSION-BOOT.md .ai/TASK.md \
           .ai/STATE.md .ai/CONSTRAINTS.yaml .ai/KNOWLEDGE.md .ai/ROADMAP.md; do
    if [ -f "$f" ] && [ -s "$f" ]; then echo "OK: $f" >> "$LOG"
    else echo "MISSING/empty: $f" >> "$LOG"; missing=$((missing+1)); fi
  done
  if [ "$missing" -eq 0 ]; then ok "$NAME"; else bad "$NAME"; fi
}

check_session_boot() {
  local NAME="session-boot-current"; local LOG="$ARTIFACTS/${NAME}.log"
  if [ -z "$N" ]; then echo "BLOCK: N unresolved" > "$LOG"; bad "$NAME"; return; fi
  local F=".ai/SESSION-BOOT.md"
  if [ ! -f "$F" ]; then echo "BLOCK: $F missing" > "$LOG"; bad "$NAME"; return; fi
  local num; num="$(grep -m1 -E '\*\*Number:\*\*' "$F" | grep -oE '[0-9]+' | head -1)"
  if [ -z "$num" ]; then echo "BLOCK: no **Number:** integer in $F" > "$LOG"; bad "$NAME"; return; fi
  if [ "$((10#$num))" -eq "$N" ]; then
    echo "OK: SESSION-BOOT Number=$num == N=$N" > "$LOG"; ok "$NAME"
  else
    echo "DRIFT: SESSION-BOOT Number=$num != .ai/SESSION N=$N" > "$LOG"; bad "$NAME"
  fi
}

check_task_ref() {
  local NAME="task-ref-current"; local LOG="$ARTIFACTS/${NAME}.log"
  if [ -z "$N" ]; then echo "BLOCK: N unresolved" > "$LOG"; bad "$NAME"; return; fi
  local F=".ai/TASK.md"
  if [ ! -f "$F" ]; then echo "BLOCK: $F missing" > "$LOG"; bad "$NAME"; return; fi
  local padded; padded="$(printf '%02d' "$N")"
  if grep -qiE "Session 0*${N}\b" "$F" || grep -qiE "Session ${padded}\b" "$F" \
     || grep -qiE "between sessions" "$F"; then
    echo "OK: TASK.md references Session $N (or 'between sessions')" > "$LOG"; ok "$NAME"
  else
    echo "DRIFT: TASK.md does not reference Session $N nor 'between sessions'" > "$LOG"; bad "$NAME"
  fi
}

check_state_sections() {
  local NAME="state-required-sections"; local LOG="$ARTIFACTS/${NAME}.log"
  local F=".ai/STATE.md"
  if [ ! -f "$F" ]; then echo "BLOCK: $F missing" > "$LOG"; bad "$NAME"; return; fi
  : > "$LOG"
  local missing=0
  for h in "What Currently Works" "What Is Broken" "What Is In Progress"; do
    if grep -q "$h" "$F"; then echo "OK: $h" >> "$LOG"
    else echo "MISSING section: $h" >> "$LOG"; missing=$((missing+1)); fi
  done
  if [ "$missing" -eq 0 ]; then ok "$NAME"; else bad "$NAME"; fi
}

check_session_pair() {
  local NAME="session-prompt-summary-pair"; local LOG="$ARTIFACTS/${NAME}.log"
  shopt -s nullglob
  local summaries=(sessions/session-*-summary.md)
  local prompts=(prompts/[0-9]*-task-*.md)
  : > "$LOG"
  local missing=0
  if (( ${#summaries[@]} == 0 )); then echo "MISSING: no session summaries" >> "$LOG"; missing=$((missing+1)); fi
  if (( ${#prompts[@]} == 0 )); then echo "MISSING: no session prompts" >> "$LOG"; missing=$((missing+1)); fi
  for s in "${summaries[@]}"; do
    local base; base=$(basename "$s" -summary.md); local nn="${base#session-}"
    local matches=(prompts/${nn}-task-*.md)
    if (( ${#matches[@]} == 0 )); then
      echo "MISSING prompt for $s (expected prompts/${nn}-task-*.md)" >> "$LOG"
      missing=$((missing+1))
    else
      echo "OK: $s ↔ ${matches[0]}" >> "$LOG"
    fi
  done
  if [ "$missing" -eq 0 ]; then ok "$NAME"; else bad "$NAME"; fi
}

check_roadmap_current() {
  local NAME="roadmap-references-N"; local LOG="$ARTIFACTS/${NAME}.log"
  if [ -z "$N" ]; then echo "BLOCK: N unresolved" > "$LOG"; bad "$NAME"; return; fi
  local F=".ai/ROADMAP.md"
  if [ ! -f "$F" ]; then echo "BLOCK: $F missing" > "$LOG"; bad "$NAME"; return; fi
  local padded; padded="$(printf '%02d' "$N")"
  if grep -qiE "Session 0*${N}\b" "$F" || grep -qiE "Session ${padded}\b" "$F"; then
    echo "OK: ROADMAP.md references Session $N" > "$LOG"; ok "$NAME"
  else
    echo "DRIFT: ROADMAP.md does not reference Session $N" > "$LOG"; bad "$NAME"
  fi
}

check_cost_tracking() {
  local NAME="cost-tracking-present"; local LOG="$ARTIFACTS/${NAME}.log"
  local F=".ai/STATE.md"
  if [ ! -f "$F" ]; then echo "BLOCK: $F missing" > "$LOG"; bad "$NAME"; return; fi
  if grep -q "Cost Tracking" "$F"; then
    echo "OK: STATE.md has Cost Tracking section" > "$LOG"; ok "$NAME"
  else
    echo "MISSING: STATE.md lacks Cost Tracking section" > "$LOG"; bad "$NAME"
  fi
}

# --- Fidelity gate (S56 — DECISION-002 teeth) -------------------------------
# Un-forgeable waiver: a founder-controlled env var, NOT a text marker the agent
# can Write into a tracked file. Mirrors VAJRA_ALLOW_PUBLISH (S37). Session-scoped:
# VAJRA_CLOSEOUT_WAIVER must equal N (a stale waiver for another session does not apply).
waiver_ok() { [ -n "${VAJRA_CLOSEOUT_WAIVER:-}" ] && [ "${VAJRA_CLOSEOUT_WAIVER}" = "$N" ]; }

# Closeout structurally requires an INDEPENDENT fidelity review (reviewer/SKILL.md).
# It must (1) exist, (2) be real — a per-requirement verdict table (SHIPPED/PARTIAL/
# NOT-BUILT) + a canonical "**Verdict:** ACCEPT|REJECT" line — not merely present, and
# (3) resolve to ACCEPT. Missing / incomplete / REJECT FAILS closeout unless waived.
check_fidelity_review() {
  local NAME="fidelity-review-accept"; local LOG="$ARTIFACTS/${NAME}.log"
  if [ -z "$N" ]; then echo "BLOCK: N unresolved" > "$LOG"; bad "$NAME"; return; fi
  local F="sessions/session-${N}-review.md"
  : > "$LOG"

  # (1) Require the artifact.
  if [ ! -f "$F" ] || [ ! -s "$F" ]; then
    echo "MISSING: $F — an independent fidelity review is required (DECISION-002)." >> "$LOG"
    if waiver_ok; then
      echo "WAIVED: VAJRA_CLOSEOUT_WAIVER=$N — ${VAJRA_CLOSEOUT_WAIVER_REASON:-<no reason recorded>}" >> "$LOG"; ok "$NAME"
    else
      echo "FAIL: supply sessions/session-${N}-review.md (cold pass) or a founder waiver (VAJRA_CLOSEOUT_WAIVER=$N)." >> "$LOG"; bad "$NAME"
    fi
    return
  fi

  # (2) Real, not present: per-requirement verdict table + a canonical overall verdict.
  local tokens overall complete=1
  tokens=$(grep -oiE 'SHIPPED|PARTIAL|NOT-BUILT' "$F" | wc -l | tr -d ' ') || true
  overall=$(grep -iE '^[*_[:space:]]*(overall[[:space:]]+|final[[:space:]]+)?verdict[*_[:space:]]*:' "$F" \
            | grep -ioE 'ACCEPT|REJECT' | head -1 | tr '[:lower:]' '[:upper:]') || true
  echo "per-requirement verdict tokens: ${tokens:-0}" >> "$LOG"
  echo "canonical overall verdict: ${overall:-<none>}" >> "$LOG"

  if [ "${tokens:-0}" -lt 3 ]; then
    echo "INCOMPLETE: fewer than 3 per-requirement verdicts — not a real acceptance table." >> "$LOG"; complete=0
  fi
  if [ -z "$overall" ]; then
    echo "INCOMPLETE: no canonical '**Verdict:** ACCEPT|REJECT' line (heading-grep is not a verdict)." >> "$LOG"; complete=0
  fi

  # (3) ACCEPT passes; missing verdict, incomplete table, or REJECT fails unless waived.
  if [ "$complete" -eq 1 ] && [ "$overall" = "ACCEPT" ]; then
    echo "OK: independent review present, complete (${tokens} verdicts), Verdict=ACCEPT." >> "$LOG"; ok "$NAME"; return
  fi
  [ "$complete" -eq 0 ] && echo "BLOCK: review is present but incomplete (not real, only present)." >> "$LOG"
  [ "$overall" = "REJECT" ] && echo "BLOCK: review Verdict=REJECT — delivery does not match the prompt." >> "$LOG"
  if waiver_ok; then
    echo "WAIVED: VAJRA_CLOSEOUT_WAIVER=$N — ${VAJRA_CLOSEOUT_WAIVER_REASON:-<no reason recorded>}" >> "$LOG"; ok "$NAME"
  else
    echo "FAIL: closeout blocked — ship an ACCEPT review (fix the gaps) or record a founder waiver (VAJRA_CLOSEOUT_WAIVER=$N)." >> "$LOG"; bad "$NAME"
  fi
}

# Focused entry point: run ONLY the fidelity gate against an explicit or resolved N.
# Used by verify-session-56.sh and the S54 dogfood (`--fidelity-only 54`).
if [ "${1:-}" = "--fidelity-only" ]; then
  if [ -n "${2:-}" ]; then N="$((10#$2))"; else check_session_file; fi
  check_fidelity_review
  echo ""
  echo "=== Fidelity gate (N=${N:-?}) ==="
  for r in "${RESULTS[@]}"; do echo "$r"; done
  cat "$ARTIFACTS/fidelity-review-accept.log" 2>/dev/null || true
  if [ "$FAIL" -eq 0 ]; then echo "FIDELITY: PASS"; exit 0; else echo "FIDELITY: FAIL"; exit 1; fi
fi

check_session_file
check_required_files
check_session_boot
check_task_ref
check_state_sections
check_session_pair
check_roadmap_current
check_cost_tracking
check_fidelity_review

( cd ".ai/verify/closeout" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Closeout Verify Summary (N=${N:-?}) ==="
printf '%-34s %s\n' "STEP" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo ""
echo "Artifacts: $ARTIFACTS"

if [ "$FAIL" -eq 0 ]; then
  echo "ALL GREEN ($PASS pass, 0 fail) — closeout is done."; exit 0
else
  echo "RED ($PASS pass, $FAIL fail) — closeout NOT done."; exit 1
fi
