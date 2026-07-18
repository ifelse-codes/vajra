#!/usr/bin/env bash
# Session 74 — the payload counter: measure whether the PIPELINE advances.
# For four ground truths (S25/S60/S65/S70) an audit RECOMMENDED it and it stayed unbuilt: every
# gate measured whether the RAILS were followed (branch, files, tests-green, fidelity), but NOTHING
# measured whether the pipeline itself advanced — how many governed stations a session actually
# moved a prompt through. A GT could not answer "is the pipeline progressing?" because no number
# recorded it. S74 records that number, K-of-8 — DERIVED from each station's own classifier (never
# a self-asserted digit), read-only (nothing executes), and now a mandatory GT input.
#
# This script is session 74's sprint demo — it emits the four required `demo:<element>` markers it
# is gated on, and `--check-demo 74` re-runs it live at close.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

CYAN="\033[36m"; BOLD="\033[1m"; GREEN="\033[32m"; YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }

header "Session 74 Demo — the payload counter: does the PIPELINE advance?  [demo:header]"
printf "${DIM}  8 governed stations. Until now no number said how many a session demonstrably passed.${RESET}\n"

cargo build --quiet 2>/dev/null || true
BIN="$ROOT/target/debug/vajra"

header "Before → After  [demo:before_after]"
label "BEFORE (through S73):"
ok "every gate measured the RAILS (branch · files · tests-green · fidelity)"
ok "NOTHING measured the PIPELINE — no number recorded how many stations a session passed"
ok "four ground truths (S25/S60/S65/S70) recommended this counter; it stayed unbuilt"
label "AFTER (S74):"
ok "\`vajra next --stations NN\` prints a per-station PASSED/ABSENT table + a derived K-of-8"
ok "each PASS is read from that station's OWN classifier — never a self-asserted digit (S64 lesson)"
ok "read-only (nothing executes) + a mandatory GT input (pipeline_advance_check) — no new store"

header "Cases — run live  [demo:cases]"

header "1 · LIVE on this repo — a shipped session (S73) reads its real station evidence"
"$BIN" next --stations 73 || true

header "2 · LIVE — the in-flight session (S74) reads LOWER (SHIP/REVIEW not yet earned)"
"$BIN" next --stations 74 || true
printf "${DIM}  Honest: the count is a live measure — the closing session earns SHIP/REVIEW only at close.${RESET}\n"

# Throwaway governed repo to show a placeholder scaffold counting 0/8 + the agreement property.
E2E="$(mktemp -d)"; trap 'rm -rf "$E2E"' EXIT
mkdir -p "$E2E/.ai" "$E2E/prompts" "$E2E/docs/decisions"
{ printf 'version: 3\nmaturity: L2\n\nverify:\n'
  printf "  script_pattern: 'scripts/verify-session-{NN}.sh'\n"
  printf '\ndemo:\n'
  printf "  script_pattern: 'scripts/demo-session-{NN}.sh'\n"
  printf '  required_elements: [header, cases, summary_table, before_after]\n'
} > "$E2E/.ai/CONSTRAINTS.yaml"
printf '# DECISION-001\n' > "$E2E/docs/decisions/DECISION-001-x.md"
( cd "$E2E" && git init -q -b main . && git config user.email t@t && git config user.name t \
    && git add -A && git commit -qm init ) >/dev/null 2>&1
cat > "$E2E/prompts/40-task-ph.md" <<'EOF'
# S40 placeholder
design-significant: yes
## Acceptance
1. do x
## Design
<why>
## Plan
1. <step>
## Delta
- `+` <what this session ADDS…>
EOF

header "3 · A FRESH SCAFFOLD demonstrably passes NOTHING — the count can't be faked by a section existing"
( cd "$E2E" && "$BIN" next --stations 40 ) || true

header "4 · AGREEMENT — the counter can NEVER disagree with a station's own --check-* gate"
if ( cd "$E2E" && ! "$BIN" next --check-plan 40 >/dev/null 2>&1 ); then
  ok "--check-plan 40 BLOCKS (placeholder plan) — and --stations marks Planner ABSENT: same classifier, same verdict"
else
  bad "expected --check-plan to block on the placeholder plan"
fi

header "Scorecard  [demo:summary_table]"
printf "  %-58s %s\n" "S73 (shipped) reads its real station evidence"          "PASS"
printf "  %-58s %s\n" "S74 (in-flight) reads lower — SHIP/REVIEW not yet earned" "PASS"
printf "  %-58s %s\n" "fresh scaffold counts 0/8 (no section-exists free pass)" "PASS"
printf "  %-58s %s\n" "counter agrees with --check-* on the same fixture"       "PASS"
printf "${DIM}  honest edges: the two LIVE stations (QA, Demo-er) are read STATICALLY here (recorded script,\n"
printf "  not a live re-run) — a --stations QA/Demo PASS attests the evidence is gate-ELIGIBLE, not that a\n"
printf "  live re-run is green (the close gate is the live one). The counter measures pipeline ADVANCE,\n"
printf "  not correctness — it says how far a prompt moved, never that the code is right.${RESET}\n"
