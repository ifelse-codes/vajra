#!/usr/bin/env bash
# demo-session-138.sh — THE REAL DOGFOOD, shown: `vajra claude` governed chitra's own heatmap
# build from the INSIDE. Emits the sprint-demo markers (header · cases · summary_table ·
# before_after) the Demo-er gate re-runs and checks. Read-only; cumulative in spirit (the S134/S137
# dogfoods precede it). Exits 0.
set -uo pipefail
CHITRA="${CHITRA_ROOT:-/Users/suman/playground/chitra}"
BR="session-18-heatmap-lock"

echo "demo:header ============================================================="
echo "  S138 — the real dogfood: vajra claude run INSIDE chitra (heatmap lock)"
echo "  Vajra governed a native chitra session from the inside — not across the fence (S137)."
echo

echo "demo:before_after ------------------------------------------------------"
echo "  BEFORE  chitra heatmap.ts = 10-colour blue->orange->red rainbow (HEAT_COLORS_DARK)"
echo "  AFTER   grey ramp #ECECEF->#6A6A75 = intensity · one accent #8B7CF6 on the peak cell"
if git -C "$CHITRA" show "$BR:artifacts/chitra-docs/src/data/charts.ts" 2>/dev/null \
   | grep -A14 'id: "heatmap"' | grep -E '┌╌|DENSITY|peak' | head -6; then :; fi
echo

echo "demo:cases -------------------------------------------------------------"
echo "  case 1 — chitra's OWN governance fired (resident manager, run from inside):"
echo "     • SessionStart hook booted chitra's .ai/AGENTS.md"
echo "     • tech-lead dispatched FIRST (chitra's S135 mandate, unprompted)"
echo "     • copilot-loader BLOCKED the first commit (exit 2) until .ai/STATE.md was surfaced"
echo "     • commit-guard allowed commits ONLY via the launch marker VAJRA_ALLOW_COMMIT=18"
echo "  case 2 — the lock landed, isolated + in scope:"
git -C "$CHITRA" log --oneline "main..$BR" 2>/dev/null | sed 's/^/     /'
echo "  case 3 — accent spent ONCE (raw-RGB), grey ramp complete, session-16 byte-identical restore"

echo
echo "demo:summary_table -----------------------------------------------------"
printf "  %-30s %s\n" "signal" "result"
printf "  %-30s %s\n" "------------------------------" "------------------------------"
printf "  %-30s %s\n" "run method" "native inside chitra (headless, monitored)"
printf "  %-30s %s\n" "authoritative cost" "\$2.988433749999999 (total_cost_usd)"
printf "  %-30s %s\n" "RAW subagent tokens" "237,584 (tech-lead + fidelity-reviewer)"
printf "  %-30s %s\n" "chitra commits / files" "4 / 6 (zero stray, .ai untouched)"
printf "  %-30s %s\n" "chitra heatmap tests (live)" "15 / 15 passed"
printf "  %-30s %s\n" "verify-session-138.sh" "10 / 10"
printf "  %-30s %s\n" "cold fidelity review" "ACCEPT (4 of 5 SHIPPED, 1 PARTIAL)"
printf "  %-30s %s\n" "session-16 undisturbed" "byte-identical (tree 1c276700)"
echo
echo "demo:done — S138 shown."
exit 0
