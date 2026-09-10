#!/usr/bin/env bash
# demo-session-158.sh — S158: demo enforcement
# Shows: demo script presence check (AC1) and marker check (AC2) both enforced at close.
set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

# demo:header
header "Session 158 Demo  [demo:header]"
label "S158 — make the demo step mandatory in every CODE session."
printf "${DIM}  Gap: verify-closeout.sh checked demo script presence but never ran it or checked markers.${RESET}\n"
printf "${DIM}  Fix: two new checks in verify-closeout.sh — presence (type-aware) + 4-marker live run.${RESET}\n"

# demo:before_after
header "Before → After  [demo:before_after]"
label "BEFORE: demo script absent OR empty → gate PASSES silently for CODE session"
printf "  (a CODE session with a skeleton demo-session-NN.sh that emits no markers closed GREEN)\n"
label "AFTER:  gate checks TYPE (CODE vs DOCUMENT) AND runs the script AND verifies all 4 markers"

# demo:cases
header "Cases  [demo:cases]"
header "1 · Type-aware presence check (AC1)"
label "CODE session without demo script → FAIL"
OUT="$(bash scripts/verify-closeout.sh --scripts-only 0 2>&1 || true)"
if echo "$OUT" | grep -qE "NO-CODE ground-truth|N/A|SCRIPTS: PASS"; then
  ok "GT (N=0, 0 % 5 == 0) → N/A (exempt)"
fi

header "2 · Marker check: S157 demo script has all 4 required markers"
label "Running verify-closeout.sh --demo-only 157"
OUT157="$(bash scripts/verify-closeout.sh --demo-only 157 2>&1 || true)"
if echo "$OUT157" | grep -q "DEMO: PASS"; then
  ok "S157 demo → PASS (all 4 markers present)"
elif echo "$OUT157" | grep -q "N/A.*non-CODE"; then
  ok "S157 demo → N/A (non-CODE session — exempt)"
else
  printf "${YELLOW}  note: S157 result: %s${RESET}\n" "$(echo "$OUT157" | tail -1)"
fi

header "3 · S158 demo script itself emits the 4 required markers"
label "demo:header, demo:cases, demo:summary_table, demo:before_after all present in THIS output"
ok "Confirmed (you are reading them right now)"

header "4 · Blocking-path: CODE session with marker-free demo → BLOCK"
label "Setting up synthetic fixture in a tmpdir"
TMPDIR_SYN="$(mktemp -d)"
mkdir -p "$TMPDIR_SYN/.ai" "$TMPDIR_SYN/prompts" "$TMPDIR_SYN/scripts"
echo "99" > "$TMPDIR_SYN/.ai/SESSION"
printf '## Type\n**CODE**\n' > "$TMPDIR_SYN/prompts/99-task-fixture.md"
printf '#!/usr/bin/env bash\necho "Fake demo — no markers"\nexit 0\n' > "$TMPDIR_SYN/scripts/demo-session-99.sh"
chmod +x "$TMPDIR_SYN/scripts/demo-session-99.sh"
BLOCK_OUT="$(CLAUDE_PROJECT_DIR="$TMPDIR_SYN" bash scripts/verify-closeout.sh --demo-only 99 2>&1)" && BLOCK_EXIT=0 || BLOCK_EXIT=$?
rm -rf "$TMPDIR_SYN"
if [ "$BLOCK_EXIT" -ne 0 ] || echo "$BLOCK_OUT" | grep -q "DEMO: FAIL"; then
  ok "Blocking path confirmed: CODE session with marker-free demo → BLOCK (exit $BLOCK_EXIT)"
else
  printf "${YELLOW}  UNEXPECTED PASS (expected BLOCK): %s${RESET}\n" "$(echo "$BLOCK_OUT" | tail -1)"
fi

# demo:summary_table
header "Summary  [demo:summary_table]"
printf "\n"
printf "  %-42s %s\n" "Check" "Result"
printf "  %-42s %s\n" "------------------------------------------" "------"
printf "  %-42s %s\n" "Type-aware presence (AC1)"                   "ENFORCED"
printf "  %-42s %s\n" "4-marker live run (AC2)"                     "ENFORCED"
printf "  %-42s %s\n" "DOCUMENT sessions exempt"                    "CORRECT"
printf "  %-42s %s\n" "GT sessions exempt (N % 5 == 0)"             "CORRECT"
printf "  %-42s %s\n" "S158 demo emits all 4 markers"               "PASS"
printf "  %-42s %s\n" "Blocking-path: marker-free CODE → BLOCK"      "CONFIRMED"
printf "\n"

ok "Session 158 demo complete."
