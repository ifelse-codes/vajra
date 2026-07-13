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

  # (2) Real, not present: per-requirement verdict TABLE + a canonical overall verdict.
  # Count verdict tokens only inside table rows (lines containing '|') so three verdict
  # WORDS scattered in prose don't fake a table — the gate must not ship the soft-proxy
  # disease it exists to kill (S56 self-review finding).
  local tokens overall complete=1
  tokens=$(grep -E '\|' "$F" | grep -oiE 'SHIPPED|PARTIAL|NOT-BUILT' | wc -l | tr -d ' ') || true
  overall=$(grep -iE '^[*_[:space:]]*(overall[[:space:]]+|final[[:space:]]+)?verdict[*_[:space:]]*:' "$F" \
            | grep -ioE 'ACCEPT|REJECT' | head -1 | tr '[:lower:]' '[:upper:]') || true
  echo "per-requirement verdict rows (in-table): ${tokens:-0}" >> "$LOG"
  echo "canonical overall verdict: ${overall:-<none>}" >> "$LOG"

  if [ "${tokens:-0}" -lt 3 ]; then
    echo "INCOMPLETE: fewer than 3 in-table per-requirement verdicts — not a real acceptance table." >> "$LOG"; complete=0
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

# --- Verdict-authorship attestation (S58 — DECISION-003) --------------------
# check_fidelity_review proves the review's SHAPE + the WAIVER's authorship, but not
# the VERDICT's authorship: a builder can hand-write its own `**Verdict:** ACCEPT`.
# The attestation binds an ACCEPT to a hash of the exact COLD INPUTS the reviewer is
# fed — the contract prompt + the delivery diff — recomputed here from the repo. A
# stale / recycled / delivery-decoupled ACCEPT no longer matches and FAILS.
#
# HONEST LIMIT (do NOT overclaim): the same agent can run `--inputs-sha` and paste the
# hash, so this is BAR-RAISING, not tamper-proof. It kills a review recycled from
# another session, one written against an earlier diff (freshness), and one decoupled
# from what actually shipped — it does NOT prove a different mind authored the verdict.

# Portable SHA-256 (Linux `sha256sum` / macOS `shasum -a 256`). Empty => uncomputable.
_sha256() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum | awk '{print $1}'
  elif command -v shasum   >/dev/null 2>&1; then shasum -a 256 | awk '{print $1}'
  else return 1; fi
}

# The canonical cold inputs, hashed by ONE function used by BOTH the emit side
# (`--inputs-sha`, what the reviewer embeds) and the verify side (check_review_
# attestation) — so normalization can never drift between them.
#   inputs = <prompt file bytes> \0 <delivery diff bytes>
# Delivery diff = committed changes vs the branch point (merge-base with main),
# EXCLUDING everything authored/synced at or after the review (so the hash is stable
# from emit-time to closeout-time): sessions/, the closeout-synced .ai/* files, and
# the gate's own timestamped verify artifacts. Prints the hash, or nothing if it
# cannot be computed (no prompt / no git / no sha tool) — the caller fails closed.
canonical_inputs_sha() {
  [ -n "$N" ] || return 1
  local padded; padded="$(printf '%02d' "$N")"
  shopt -s nullglob
  local prompts=(prompts/${padded}-task-*.md)
  (( ${#prompts[@]} == 1 )) || return 1          # 0 or >1 contract => uncomputable
  local base
  base="$(git merge-base main HEAD 2>/dev/null)" || return 1
  [ -n "$base" ] || return 1
  local diff
  diff="$(git diff --no-color --no-ext-diff "$base" HEAD -- \
            ':(exclude)sessions' ':(exclude)prompts' \
            ':(exclude).ai/STATE.md' ':(exclude).ai/SESSION-BOOT.md' \
            ':(exclude).ai/SESSION' ':(exclude).ai/TASK.md' \
            ':(exclude).ai/ROADMAP.md' ':(exclude).ai/KNOWLEDGE.md' \
            ':(exclude).ai/verify' ':(exclude).ai/.session-owner' 2>/dev/null)" || return 1
  { cat "${prompts[0]}"; printf '\0'; printf '%s' "$diff"; } | _sha256
}

# Require + verify the input-attestation on an ACCEPT review. Orthogonal to
# check_fidelity_review: a missing / non-ACCEPT review is N/A here (that outcome is
# owned by the fidelity check — no double-jeopardy). An ACCEPT with a missing, forged,
# or uncomputable-and-mismatched attestation FAILS, behind the same founder waiver.
check_review_attestation() {
  local NAME="review-inputs-attested"; local LOG="$ARTIFACTS/${NAME}.log"
  if [ -z "$N" ]; then echo "BLOCK: N unresolved" > "$LOG"; bad "$NAME"; return; fi
  local F="sessions/session-${N}-review.md"
  : > "$LOG"

  if [ ! -f "$F" ] || [ ! -s "$F" ]; then
    echo "N/A: no review file — outcome owned by fidelity-review-accept." >> "$LOG"; ok "$NAME"; return
  fi
  local overall
  overall=$(grep -iE '^[*_[:space:]]*(overall[[:space:]]+|final[[:space:]]+)?verdict[*_[:space:]]*:' "$F" \
            | grep -ioE 'ACCEPT|REJECT' | head -1 | tr '[:lower:]' '[:upper:]') || true
  if [ "$overall" != "ACCEPT" ]; then
    echo "N/A: verdict is ${overall:-<none>} (attestation only gates an ACCEPT)." >> "$LOG"; ok "$NAME"; return
  fi

  local claimed expected
  claimed=$(grep -m1 -iE '^[*_[:space:]]*Review-Inputs-SHA[*_[:space:]]*:' "$F" \
            | grep -oiE '[0-9a-f]{64}' | head -1 | tr '[:upper:]' '[:lower:]') || true
  expected=$(canonical_inputs_sha 2>/dev/null) || true
  echo "claimed:  ${claimed:-<none>}" >> "$LOG"
  echo "expected: ${expected:-<uncomputable>}" >> "$LOG"

  if [ -n "$claimed" ] && [ -n "$expected" ] && [ "$claimed" = "$expected" ]; then
    echo "OK: ACCEPT attestation matches the canonical cold-input hash." >> "$LOG"; ok "$NAME"; return
  fi
  [ -z "$claimed" ]   && echo "BLOCK: ACCEPT with no **Review-Inputs-SHA:** attestation." >> "$LOG"
  [ -z "$expected" ]  && echo "BLOCK: canonical input hash uncomputable (a check that cannot evaluate FAILS)." >> "$LOG"
  { [ -n "$claimed" ] && [ -n "$expected" ] && [ "$claimed" != "$expected" ]; } \
    && echo "BLOCK: attestation MISMATCH — the ACCEPT is stale/recycled/decoupled from the delivered diff." >> "$LOG"
  if waiver_ok; then
    echo "WAIVED: VAJRA_CLOSEOUT_WAIVER=$N — ${VAJRA_CLOSEOUT_WAIVER_REASON:-<no reason recorded>}" >> "$LOG"; ok "$NAME"
  else
    echo "FAIL: re-run the cold review and embed a matching **Review-Inputs-SHA:** (\`verify-closeout.sh --inputs-sha $N\`), or record a founder waiver." >> "$LOG"; bad "$NAME"
  fi
}

# Print the canonical cold-input hash the reviewer must embed. `--inputs-sha [N]`.
if [ "${1:-}" = "--inputs-sha" ]; then
  if [ -n "${2:-}" ]; then N="$((10#$2))"; else check_session_file >/dev/null 2>&1; fi
  if H=$(canonical_inputs_sha); then echo "$H"; exit 0; else
    echo "ERROR: canonical input hash uncomputable (need a single prompts/NN-task-*.md, git, and a sha tool)." >&2; exit 1
  fi
fi

# Focused entry point: run ONLY the fidelity gate against an explicit or resolved N.
# Used by verify-session-56.sh and the S54 dogfood (`--fidelity-only 54`).
# S58: --fidelity-only keeps its S56 meaning (shape/verdict/waiver only) so prior
# harnesses stay green; the attestation has its own focused entry (`--attest-only`).
if [ "${1:-}" = "--fidelity-only" ]; then
  if [ -n "${2:-}" ]; then N="$((10#$2))"; else check_session_file; fi
  check_fidelity_review
  echo ""
  echo "=== Fidelity gate (N=${N:-?}) ==="
  for r in "${RESULTS[@]}"; do echo "$r"; done
  cat "$ARTIFACTS/fidelity-review-accept.log" 2>/dev/null || true
  if [ "$FAIL" -eq 0 ]; then echo "FIDELITY: PASS"; exit 0; else echo "FIDELITY: FAIL"; exit 1; fi
fi

# Focused entry point: run ONLY the verdict-attestation check (S58). `--attest-only [N]`.
if [ "${1:-}" = "--attest-only" ]; then
  if [ -n "${2:-}" ]; then N="$((10#$2))"; else check_session_file; fi
  check_review_attestation
  echo ""
  echo "=== Attestation gate (N=${N:-?}) ==="
  for r in "${RESULTS[@]}"; do echo "$r"; done
  cat "$ARTIFACTS/review-inputs-attested.log" 2>/dev/null || true
  if [ "$FAIL" -eq 0 ]; then echo "ATTEST: PASS"; exit 0; else echo "ATTEST: FAIL"; exit 1; fi
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
check_review_attestation

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
