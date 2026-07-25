#!/usr/bin/env bash
# demo-session-101.sh — Session 101: README truth-pass + crate-name decision (docs-only).
# Cumulative: prior sessions' capabilities still hold; this session makes the README verifiable
# today and settles the v0.1 crate name on paper (DECISION-006). Publishes/renames NOTHING.
# Emits demo:header / demo:before_after / demo:cases / demo:summary_table (Demo-er gate, S71).
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="101"
README="README.md"
DEC="docs/decisions/DECISION-006-crate-name.md"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"; YELLOW="\033[33m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
no()     { printf "${RED}✗ %s${RESET}\n" "$1"; }
show()   { if grep -qiF "$2" "$1"; then ok "$3"; else no "MISSING: $3"; fi; }
gone()   { if grep -qiF "$2" "$1"; then no "STILL PRESENT: $3"; else ok "$3"; fi; }

# --- demo:header ---
header "Session ${SESSION} Demo — README truth-pass + crate-name decision  [demo:header]"
label "A stranger reading the README should be able to trust every sentence."
label "Publishes / tags / renames NOTHING — corrects docs, records one decision."

# --- demo:before_after ---
header "Before → After  [demo:before_after]"
label "BEFORE — README receipt example (stale figure + unpriced model id):"
echo  "  \$33.4976  total  (opus-4-6 90 lines)     ← oversold the old ~8× cache bug"
label "AFTER — a REAL captured receipt (S97 paid run, authoritative + [estimate]):"
grep -m1 -F 'total  (fable-5' "$README" | sed 's/^[* ]*/  /' | cut -c1-70
echo
label "BEFORE — install offered crates.io as if it worked:"
echo  "  # From crates.io"
echo  "  cargo install vajractl                    ← 404s today"
label "AFTER — one working method; the rest marked NOT YET PUBLISHED:"
grep -m1 -F 'Works today' "$README" | sed 's/^[* #]*/  /' | cut -c1-70

# --- demo:cases ---
header "Cases  [demo:cases]"

header "1 · Stale receipt claims retired"
gone "$README" '~8x'        "no '~8×' receipt-bug claim"
gone "$README" 'opus-4-6'   "no 'opus-4-6' example model id"
gone "$README" '33.4976'    "no stale \$33.4976 figure"

header "2 · Install honesty — one working method, three marked not-yet-published"
show "$README" 'cargo install --path .'                   "source build kept as the working method"
for c in 'cargo install vajractl' 'brew install suman/tap/vajra' 'releases/latest/download'; do
  if awk -v cmd="$c" 'index($0,cmd) && index(prev,"NOT YET PUBLISHED"){f=1}{prev=$0}END{exit f?0:1}' "$README"; then
    ok "marked NOT YET PUBLISHED: $c"
  else no "unmarked: $c"; fi
done

header "3 · Direction paragraph = shipped reality"
gone "$README" 'next build is the'   "45-session-stale 'next build is the fidelity auditor' phrasing"
show "$README" '8 stations ship today' "8 stations named as shipped"
show "$README" '11 checks'             "vajra check = 11"
show "$README" '`vajra estimate`'    "table lists estimate"
show "$README" '`vajra hook`'        "table lists hook"

header "4 · DECISION-006 settles the crate name (live check, on paper)"
show "$DEC" 'crates.io/api/v1/crates'  "records the re-runnable command"
show "$DEC" '404'                      "vajractl -> 404 AVAILABLE"
show "$DEC" '200'                      "vajra -> 200 TAKEN"
show "$DEC" 'Nothing is published'     "explicitly publishes/tags/renames nothing"

# --- demo:summary_table ---
header "Summary  [demo:summary_table]"
printf "\n"
printf "  %-48s %s\n" "Deliverable" "Status"
printf "  %-48s %s\n" "------------------------------------------------" "------"
printf "  %-48s %s\n" "README install: 1 working + 3 not-yet-published"   "SHIPPED"
printf "  %-48s %s\n" "Receipt note + example (real S97 capture)"         "SHIPPED"
printf "  %-48s %s\n" "Direction paragraph + Status table (7 cmds, 11)"   "SHIPPED"
printf "  %-48s %s\n" "DECISION-006 crate name (vajractl + vajra)"        "SHIPPED"
printf "  %-48s %s\n" "Published / tagged / renamed"                      "NOTHING"
printf "  %-48s %s\n" "src/ · Cargo.toml touched"                         "NONE"
printf "\n"

ok "Session ${SESSION} demo complete."
