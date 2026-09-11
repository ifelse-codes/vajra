#!/usr/bin/env bash
# Verify: session 162 — waiver path behavioral tests + fresh-init signal investigation
# All waiver checks invoke verify-closeout.sh LIVE; no source-proximity greps.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

PASS=0; FAIL=0
ok()   { printf 'PASS  %s\n' "$1"; PASS=$((PASS+1)); }
fail() { printf 'FAIL  %s\n' "$1"; FAIL=$((FAIL+1)); }

# ── Fixture setup ─────────────────────────────────────────────────────────────
# A synthetic repo that forces a known block (fidelity-review-accept) so waiver tests
# have a real gate to bypass. SESSION=162, no review file → guaranteed fidelity FAIL.
FIXTURE=$(mktemp -d)
cleanup() { rm -rf "$FIXTURE"; }
trap cleanup EXIT

mkdir -p "$FIXTURE/.ai/verify/closeout" "$FIXTURE/scripts" "$FIXTURE/sessions" "$FIXTURE/prompts" \
         "$FIXTURE/.ai/handoffs" "$FIXTURE/src"

cp scripts/verify-closeout.sh "$FIXTURE/scripts/"

printf '%s\n' "162"                         > "$FIXTURE/.ai/SESSION"
printf '# Test AGENTS\n'                    > "$FIXTURE/.ai/AGENTS.md"
printf '# Session Boot\n## Current Session\n- **Number:** 162\n' > "$FIXTURE/.ai/SESSION-BOOT.md"
printf '## Session 162\nbetween sessions\n' > "$FIXTURE/.ai/TASK.md"
printf '# State\n## Active Branch\nNone\n## What Currently Works\ntest\n## What Is Broken\nnone\n## What Is In Progress\nnone\n## Cost Tracking\n$0\n' > "$FIXTURE/.ai/STATE.md"
printf 'version: 3\nmaturity: L2\n'        > "$FIXTURE/.ai/CONSTRAINTS.yaml"
printf '# Knowledge\n'                     > "$FIXTURE/.ai/KNOWLEDGE.md"
printf '## Session 162\n'                  > "$FIXTURE/.ai/ROADMAP.md"
printf 'Brief: test handoff\n'             > "$FIXTURE/.ai/handoffs/session-162-tech-lead.md"

# 3 session summary/prompt pairs so session-prompt-summary-pair passes
for nn in 160 161 162; do
  printf '## Session %s — done\n' "$nn" > "$FIXTURE/sessions/session-${nn}-summary.md"
  printf '# Session %s prompt\n'    "$nn" > "$FIXTURE/prompts/${nn}-task-test.md"
done

# Verify + demo scripts present and with markers (CODE session gate)
printf '#!/usr/bin/env bash\nexit 0\n' > "$FIXTURE/scripts/verify-session-162.sh"
printf '#!/usr/bin/env bash\necho "demo:header"; echo "demo:cases"; echo "demo:summary_table"; echo "demo:before_after"\n' \
  > "$FIXTURE/scripts/demo-session-162.sh"
chmod +x "$FIXTURE/scripts/verify-session-162.sh" "$FIXTURE/scripts/demo-session-162.sh"

# Minimal Cargo project so cargo-fmt-clean exits 0 (no files to reformat)
printf '[package]\nname = "fixture"\nversion = "0.1.0"\nedition = "2021"\n' > "$FIXTURE/Cargo.toml"
printf 'fn main() {}\n' > "$FIXTURE/src/main.rs"

# Binary copy if available (obeyed + design-advisor gates need it)
if [ -f "target/release/vajra" ]; then
  mkdir -p "$FIXTURE/target/release"
  cp "target/release/vajra" "$FIXTURE/target/release/"
fi

run_vc() {
  # $1 = env prefix string (eval-safe); $2 = output file
  local out="$2"
  eval "CLAUDE_PROJECT_DIR=\"\$FIXTURE\" $1 bash \"\$FIXTURE/scripts/verify-closeout.sh\"" \
    > "$out" 2>&1 || true
}

# ── AC1: correct waiver (N=N) passes verify-closeout ─────────────────────────
# Verify-closeout must exit 0 when VAJRA_CLOSEOUT_WAIVER equals .ai/SESSION (162).
run_vc 'VAJRA_CLOSEOUT_WAIVER=162 VAJRA_CLOSEOUT_WAIVER_REASON="verify: AC1 waiver test"' \
       /tmp/v162-ac1.txt
exit_ac1=0
grep -q "^ALL GREEN" /tmp/v162-ac1.txt || exit_ac1=1
if [ "$exit_ac1" -eq 0 ]; then
  ok "AC1: VAJRA_CLOSEOUT_WAIVER=162 → verify-closeout ALL GREEN (exit 0)"
else
  fail "AC1: VAJRA_CLOSEOUT_WAIVER=162 → expected ALL GREEN, got:"
  tail -5 /tmp/v162-ac1.txt | sed 's/^/      /'
fi

# ── AC2: wrong session waiver (M≠N) stays blocked ────────────────────────────
# VAJRA_CLOSEOUT_WAIVER=999 must NOT bypass the block for session 162.
run_vc 'VAJRA_CLOSEOUT_WAIVER=999 VAJRA_CLOSEOUT_WAIVER_REASON="wrong session"' \
       /tmp/v162-ac2.txt
if grep -q "^RED" /tmp/v162-ac2.txt; then
  ok "AC2: VAJRA_CLOSEOUT_WAIVER=999 (≠162) → verify-closeout still RED (block holds)"
else
  fail "AC2: wrong-session waiver was accepted — waiver_ok() session-scope broken"
  tail -5 /tmp/v162-ac2.txt | sed 's/^/      /'
fi

# Confirm fidelity-review-accept specifically FAIL in the wrong-waiver run
if grep -E "fidelity-review-accept[[:space:]]+FAIL" /tmp/v162-ac2.txt > /dev/null 2>&1; then
  ok "AC2b: fidelity-review-accept FAIL with wrong waiver (M≠N doesn't bypass fidelity gate)"
else
  fail "AC2b: fidelity-review-accept line not FAIL in wrong-waiver output"
fi

# ── AC3: waiver reason recorded in artifact log ───────────────────────────────
# After the AC1 waiver run, the artifact log must contain VAJRA_CLOSEOUT_WAIVER_REASON.
WAIVER_ARTIFACTS=$(grep "^Artifacts:" /tmp/v162-ac1.txt | awk '{print $2}' || true)
LOG_FILE=""
if [ -n "${WAIVER_ARTIFACTS:-}" ]; then
  LOG_FILE="$FIXTURE/${WAIVER_ARTIFACTS}/fidelity-review-accept.log"
fi

if [ -n "$LOG_FILE" ] && [ -f "$LOG_FILE" ] && \
   grep -qF "verify: AC1 waiver test" "$LOG_FILE"; then
  ok "AC3: VAJRA_CLOSEOUT_WAIVER_REASON found in artifact log ($(basename "$WAIVER_ARTIFACTS")/fidelity-review-accept.log)"
else
  fail "AC3: waiver reason NOT in artifact log"
  if [ -n "$LOG_FILE" ] && [ -f "$LOG_FILE" ]; then
    cat "$LOG_FILE" | sed 's/^/      /'
  else
    printf '      LOG_FILE=%s\n' "${LOG_FILE:-unset}"
  fi
fi

# ── AC4: fresh-init signals are honest ────────────────────────────────────────
# Run vajra check + vajra next + verify-closeout on a fresh init; confirm none says "ready."
FRESH=$(mktemp -d)
cleanup_fresh() { rm -rf "$FRESH"; }
trap "cleanup_fresh; cleanup" EXIT
(cd "$FRESH" && git init -q && vajra init 2>/dev/null) || \
  (fail "AC4: vajra init failed on fresh dir"; FRESH="")

if [ -n "$FRESH" ]; then
  # verify-closeout must exit non-zero (incomplete session)
  vc_exit=0
  CLAUDE_PROJECT_DIR="$FRESH" bash "$FRESH/scripts/verify-closeout.sh" > /tmp/v162-ac4-vc.txt 2>&1 || vc_exit=$?
  if [ "$vc_exit" -ne 0 ]; then
    ok "AC4a: fresh-init verify-closeout exits non-zero ($vc_exit) — not false green"
  else
    fail "AC4a: fresh-init verify-closeout exited 0 — FALSE READY signal"
    tail -5 /tmp/v162-ac4-vc.txt | sed 's/^/      /'
  fi

  # vajra next --stations must not report "8 of 8" (false-ready), and must show
  # at least one ABSENT station — both confirm an honest "no work done" signal.
  stations_out=$(CLAUDE_PROJECT_DIR="$FRESH" vajra next --stations 1 2>&1 || true)
  no_false_ready=0; has_absent=0
  echo "$stations_out" | grep -qE "^[[:space:]]*8 of 8.*passed" || no_false_ready=1
  echo "$stations_out" | grep -qE "\[ABSENT\]|hasn't framed|no design|no plan|no code|no review" && has_absent=1 || true
  if [ "$no_false_ready" -eq 1 ] && [ "$has_absent" -eq 1 ]; then
    ok "AC4b: vajra next --stations on fresh init shows honest absent stations (no false-ready '8 of 8')"
  else
    fail "AC4b: vajra next --stations on fresh init may give false-ready signal (no_false_ready=$no_false_ready, has_absent=$has_absent)"
    printf '      %s\n' "$stations_out" | tail -5
  fi
fi

# ── AC5: no fix needed (finding 14 is honest) ────────────────────────────────
# AC4 found no false-ready signal; this check confirms the investigation conclusion.
if [ -n "$FRESH" ] && [ "$vc_exit" -ne 0 ]; then
  ok "AC5: no false-ready fix needed — fresh-init signals are honest (AC4 confirmed)"
else
  fail "AC5: AC4 outcome inconclusive — re-investigate fresh-init signals"
fi

# ── AC6: demo script exists, is non-empty, and contains all 4 markers ─────────
if [ -f scripts/demo-session-162.sh ] && [ -s scripts/demo-session-162.sh ]; then
  ok "AC6a: scripts/demo-session-162.sh exists and non-empty"
else
  fail "AC6a: scripts/demo-session-162.sh missing or empty"
fi

demo_out=$(bash scripts/demo-session-162.sh 2>&1) && demo_exit=0 || demo_exit=$?
for marker in header cases summary_table before_after; do
  if echo "$demo_out" | grep -q "demo:${marker}"; then
    ok "AC6b: demo:${marker} marker present in live demo output"
  else
    fail "AC6b: demo:${marker} marker MISSING from live demo output"
  fi
done

if [ "$demo_exit" -eq 0 ]; then
  ok "AC6c: demo-session-162.sh exits 0"
else
  fail "AC6c: demo-session-162.sh exits $demo_exit"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
printf '\n'
printf '=== verify-session-162.sh: %d pass, %d fail ===\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
