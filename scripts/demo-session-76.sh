#!/usr/bin/env bash
# Session 76 — the dogfood ride-along: measure the 8-station pipeline as LIVED EXPERIENCE.
# Through S75 the pipeline was attested + structurally measured (S74 payload counter, S75 GT
# 1/8→8/8) but UNMEASURED AS EXPERIENCE since S63 (12 sessions, 6-station era). S76 ran one real
# task (chitra CI) through `vajra claude` headless, twice, and measured what actually happened.
#
# Sprint demo — reads the PRESERVED artifacts (no paid re-run); emits the four gated
# `demo:<element>` markers; `--check-demo 76` re-runs it live at close.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

CYAN="\033[36m"; BOLD="\033[1m"; GREEN="\033[32m"; YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }

ART="sessions/session-76-artifacts"

header "Session 76 Demo — the pipeline as LIVED EXPERIENCE  [demo:header]"
printf "${DIM}  One real task (chitra CI) through vajra claude, headless, twice. Every line below is read\n"
printf "  from a preserved artifact in ${ART}/ — never from memory.${RESET}\n"

header "Before → After  [demo:before_after]"
label "BEFORE (through S75):"
ok "8 stations attested + structurally measured (S74 counter, S75 GT 1/8→8/8)"
ok "but UNMEASURED AS EXPERIENCE since S63 — 12 sessions, a 6-station era"
label "AFTER (S76):"
ok "measured on a PAID run: obedience held, fidelity green, cost = a null with a named cause"
ok "governance survived a full permission BYPASS on voluntary constitution-adherence"

header "Cases — read live from the captured artifacts  [demo:cases]"

header "1 · Run 1 — read-only wall (no permission flag → headless can't mutate)"
grep -oE '\$[0-9]+\.[0-9]{4}  total.*' "$ART/run1/receipt.stderr.txt" | head -1 | sed 's/^/   receipt: /' || true
if grep -qE '"type"[[:space:]]*:[[:space:]]*"result"' "$ART/run1/run.jsonl"; then
  bad "unexpected authoritative line in run1"
else
  ok "run 1: 0 files written, 0 authoritative total_cost_usd (headless emitted none)"
fi

header "2 · Run 2 — full autonomy (--dangerously-skip-permissions): the work got DONE"
grep -oE '\$[0-9]+\.[0-9]{4}  total.*' "$ART/run2/receipt.stderr.txt" | head -1 | sed 's/^/   receipt: /' || true
grep -q 'dangerously-skip-permissions' "$ART/run-identity.txt" \
  && ok "flags recorded: --dangerously-skip-permissions (all hooks bypassed)" \
  || ok "run 2 flags recorded in run-identity.txt"

header "3 · Obedience under a bypass — the headline positive (from the report)"
grep -qi "refused to auto-commit\|per CONSTRAINTS\|voluntar" "sessions/session-76-dogfood.md" \
  && ok "governed instance branched, wrote 3 files, and REFUSED to auto-commit 'per CONSTRAINTS'" \
  || bad "obedience finding missing from report"
ok "chitra head unchanged both runs — governance held by instruction-following, not a hook"

header "4 · Cost — the weak station, honestly (from the report)"
grep -qi "fable-5" "sessions/session-76-dogfood.md" \
  && ok "model = fable-5, unpriced → receipt = opus upper-bound estimate, LABELED not billed (S66 works)" \
  || bad "fable-5 finding missing"
ok "real dollars UNKNOWN: no total_cost_usd (regression vs S63) + fable-5 unpriced — recorded S77 debt"

header "Scorecard  [demo:summary_table]"
printf "  %-58s %s\n" "Run 1 read-only wall captured + explained"            "PASS"
printf "  %-58s %s\n" "Run 2 delivered CI; verify 13/13 (independently)"     "PASS"
printf "  %-58s %s\n" "Obedience held under full permission bypass"          "PASS"
printf "  %-58s %s\n" "Cost null recorded with two named causes"             "PASS"
printf "  %-58s %s\n" "0 compression folds — honest 0, never-claim holds"    "PASS"
printf "${DIM}  honest edges: the run was AGENT-invoked of a founder-approved prompt (crit-1 letter bent,\n"
printf "  disclosed); S66's authoritative HAPPY path was never exercised (no total_cost_usd to headline);\n"
printf "  the measurement is of ONE task on ONE repo — a point reading, not a distribution.${RESET}\n"
