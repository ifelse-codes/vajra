#!/usr/bin/env bash
# demo-session-166.sh — S166: fix Analyst + Coder station gaps
# Required markers: demo:header · demo:cases · demo:summary_table · demo:before_after
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BIN="target/release/vajra"

# demo:header
echo "demo:header"
echo "======================================================="
echo " Session 166 — Fix Analyst + Coder Station Gaps"
echo " Three 🔴 findings from the S165 Ground Truth, closed."
echo "======================================================="
echo ""

# demo:cases
echo "demo:cases"
echo "--- Case 1: Analyst station PASSED for session 166 ---"
echo ""
echo "  BEFORE S166: ## Delta used prose — no +/~/- markers"
echo "               vajra next --stations 166 → [ABSENT] Analyst"
echo ""
echo "  AFTER  S166: ## Delta has real OpenSpec markers"
echo "  Command: $BIN next --stations 166"
echo ""
if [ -x "$BIN" ]; then
  "$BIN" next --stations 166 2>&1 | grep -E "Analyst|K/8|stations"
else
  echo "  (binary not built — run cargo build --release)"
fi
echo ""

echo "--- Case 2: prose done: is now BLOCKED ---"
echo ""
echo "  BEFORE S166: done: (verify + scripts: see next commit) → PASSED"
echo "  AFTER  S166: same entry → BAD-SHA / EXEC-SHAS: FAIL"
echo ""
echo "  Command: bash scripts/verify-closeout.sh --check-exec-shas 164"
echo ""
_s164="$(bash scripts/verify-closeout.sh --check-exec-shas 164 2>&1)" && true || true
echo "$_s164" | grep -E "BAD-SHA|EXEC-SHAS|prompt:"
echo ""

echo "--- Case 3: real SHA still passes ---"
echo ""
echo "  Command: bash scripts/verify-closeout.sh --check-exec-shas 163"
echo ""
_s163="$(bash scripts/verify-closeout.sh --check-exec-shas 163 2>&1)" && true || true
echo "$_s163" | grep -E "EXEC-SHAS|OK:"
echo ""

echo "--- Case 4: session-164-summary.md closes S164's incomplete closeout ---"
echo ""
echo "  S164 closeout was missing its summary file (SUMMARY step skipped)."
echo "  File now exists: sessions/session-164-summary.md"
ls -la sessions/session-164-summary.md
echo ""

# demo:summary_table
echo "demo:summary_table"
echo ""
printf "%-6s %-52s %-8s\n" "AC" "Criterion" "Result"
printf "%-6s %-52s %-8s\n" "---" "----------------------------------------------------" "-------"
if [ -x "$BIN" ]; then
  ac1_out="$("$BIN" next --stations 166 2>&1)"
  if echo "$ac1_out" | grep -q "\[PASSED\] Analyst"; then ac1="PASS"; else ac1="FAIL"; fi
else
  ac1="SKIP (no binary)"
fi
printf "%-6s %-52s %-8s\n" "AC1" "Analyst PASSED (vajra next --stations 166)" "$ac1"

_d164="$(bash scripts/verify-closeout.sh --check-exec-shas 164 2>&1)" && true || true
if echo "$_d164" | grep -q "EXEC-SHAS: FAIL"; then ac2="PASS"; else ac2="FAIL"; fi
printf "%-6s %-52s %-8s\n" "AC2" "prose done: → EXEC-SHAS: FAIL" "$ac2"

_d163="$(bash scripts/verify-closeout.sh --check-exec-shas 163 2>&1)" && true || true
if echo "$_d163" | grep -q "EXEC-SHAS: PASS"; then ac3="PASS"; else ac3="FAIL"; fi
printf "%-6s %-52s %-8s\n" "AC3" "real 7-char SHA → EXEC-SHAS: PASS" "$ac3"

if [ -f "sessions/session-164-summary.md" ]; then ac4="PASS"; else ac4="FAIL"; fi
printf "%-6s %-52s %-8s\n" "AC4" "sessions/session-164-summary.md exists" "$ac4"

verify_out="$(bash scripts/verify-session-166.sh 2>&1)" && verify_code=0 || verify_code=$?
if [ "$verify_code" -eq 0 ]; then ac5="PASS"; else ac5="FAIL"; fi
printf "%-6s %-52s %-8s\n" "AC5" "verify-session-166.sh exits 0 (all behavioral)" "$ac5"
echo ""

# demo:before_after
echo "demo:before_after"
echo ""
echo "BEFORE (S165 GT findings):"
echo "  check_execution_shas:"
echo "    if echo \"\$line\" | grep -qE 'done:[[:space:]]*<'; then"
echo "    # Only blocks angle-bracket form: done: <sha>"
echo "    # MISSED: done: (verify + scripts: see next commit)"
echo ""
echo "  Analyst station:"
echo "    All prompts S161-S164 used prose ## Delta"
echo "    vajra next --stations → [ABSENT] Analyst (4/4 consecutive)"
echo ""
echo "  S164 closeout:"
echo "    sessions/session-164-summary.md: MISSING"
echo ""
echo "AFTER (S166 ships):"
echo "  check_execution_shas:"
echo "    if echo \"\$line\" | grep -qE 'done:' && \\"
echo "       ! echo \"\$line\" | grep -qE 'done:[[:space:]]+[0-9a-f]{7}'; then"
echo "    # Blocks any done: not followed by a 7-char hex SHA"
echo "    # CATCHES: prose, parenthetical, angle-bracket, bare text"
echo ""
echo "  Analyst station:"
echo "    prompts/166-task-analyst-coder-gaps.md ## Delta:"
echo "      - \`+\` check_execution_shas blocks prose/parenthetical done: entries"
echo "      - \`+\` sessions/session-164-summary.md — completes S164's closeout"
echo "      - \`~\` prompts/166-task-analyst-coder-gaps.md (this file)"
if [ -x "$BIN" ]; then
  echo ""
  "$BIN" next --stations 166 2>&1 | grep -E "Analyst|K/8"
fi
echo ""
echo "  S164 closeout:"
echo "    sessions/session-164-summary.md: EXISTS"
echo "    3 ranked A/B/C candidates for S166 confirmed."
echo ""
echo "======================================================="
echo " Demo complete — all 4 required markers emitted."
echo "======================================================="
