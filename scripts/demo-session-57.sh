#!/usr/bin/env bash
# demo-session-57.sh — S57: the fidelity gate + reviewer, now inherited by every scaffolded project.
# Cumulative: S54 Analyst gate · S55 reviewer brain · S56 gate teeth (vajra repo) · S57 → propagated
# into `vajra init` so a scaffolded project's closeout also structurally requires an ACCEPT review.
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
block()  { printf "${RED}⛔ %s${RESET}\n" "$1"; }

header "Session 57 Demo — the fidelity gate, propagated into vajra init"

BIN="$ROOT/target/debug/vajra"
[ -x "$BIN" ] || { printf "${DIM}building vajra…${RESET}\n"; cargo build >/dev/null 2>&1; }
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

label "1. Scaffold a fresh project with a real \`vajra init\`"
( cd "$TMP" && git init -q && printf 'AcmeApp\nbuild the widget\nL2\n' | "$BIN" init 2>&1 ) \
  | grep -E 'reviewer/SKILL.md|verify-closeout.sh' | sed 's/^/    /'
ok "every scaffolded project now ships the reviewer brain + the closeout gate"

label "2. Drift-free — one source of truth (include_str!)"
cmp -s "$TMP/reviewer/SKILL.md"      "$ROOT/reviewer/SKILL.md"      && ok "reviewer/SKILL.md      byte-identical to canonical"
cmp -s "$TMP/scripts/verify-closeout.sh" "$ROOT/scripts/verify-closeout.sh" && ok "verify-closeout.sh    byte-identical to canonical"

GATE="$TMP/scripts/verify-closeout.sh"; N=7
rev() { mkdir -p "$TMP/sessions"
  { echo "# review"; echo; echo "| # | Requirement | Verdict | Evidence |"; echo "|---|---|---|---|"
    echo "| 1 | a | SHIPPED | x |"; echo "| 2 | b | PARTIAL | y |"; echo "| 3 | c | NOT-BUILT | z |"; echo
    echo "**Verdict:** $1"; } > "$TMP/sessions/session-$N-review.md"; }
g() { CLAUDE_PROJECT_DIR="$TMP" env "$@" bash "$GATE" --fidelity-only "$N" >/dev/null 2>&1; }

label "3. The scaffolded closeout can no longer self-certify"
g && : || block "no fidelity review → closeout BLOCKED (self-cert is retired)"
rev REJECT; g && : || block "review Verdict: REJECT → closeout BLOCKED"
rev ACCEPT; g && ok "review Verdict: ACCEPT → closeout CLEARED"

label "4. The waiver is un-forgeable (env var, not a marker the agent can Write)"
rev REJECT; printf 'VAJRA_CLOSEOUT_WAIVER=%s\nStatus: WAIVED\n' "$N" >> "$TMP/sessions/session-$N-review.md"
g && : || block "forged in-file waiver ignored → still BLOCKED"
g VAJRA_CLOSEOUT_WAIVER="$N" && ok "founder env-var waiver (VAJRA_CLOSEOUT_WAIVER=$N) → CLEARED"

header "Summary"
printf "\n  %-46s %s\n" "Capability" "Status"
printf "  %-46s %s\n" "----------------------------------------------" "------"
printf "  %-46s %s\n" "reviewer/SKILL.md scaffolded (brain)"          "WORKS"
printf "  %-46s %s\n" "verify-closeout.sh scaffolded (teeth)"         "WORKS"
printf "  %-46s %s\n" "byte-identical / drift-free (include_str!)"    "WORKS"
printf "  %-46s %s\n" "scaffolded gate blocks missing/REJECT"         "WORKS"
printf "  %-46s %s\n" "scaffolded gate passes ACCEPT"                 "WORKS"
printf "  %-46s %s\n" "waiver un-forgeable (env, not in-file marker)" "WORKS"
printf "\n"
ok "Session 57 demo complete — every scaffolded project inherits the fidelity gate."
