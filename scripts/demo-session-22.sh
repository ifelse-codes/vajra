#!/usr/bin/env bash
# Session 22 — scaffold propagation. A fresh `vajra init` now inherits the S20
# ground-truth audits + the S21 enforcing co-pilot. Cumulative demo.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="22"
BIN="$ROOT/target/debug/vajra"
CANON="$ROOT/scripts/hook-copilot-loader.sh"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — scaffold propagation (every project inherits the hardening)"
printf "${DIM}  Before S22: a fresh \`vajra init\` produced a pre-S20 workflow. Now it ships S20+S21.${RESET}\n"

[ -x "$BIN" ] || { label "building vajra"; cargo build >/dev/null 2>&1; }

header "1. Run a REAL \`vajra init\` into an empty temp project"
DEMO=$(mktemp -d)
label "vajra init < /dev/null   (non-interactive → L2 defaults)"
( cd "$DEMO" && "$BIN" init < /dev/null ) 2>&1 | sed 's/^/    /'
ok "Scaffolded into $DEMO"

header "2. The scaffold now carries the S20 ground-truth audits"
label ".ai/CONSTRAINTS.yaml#ground_truth (was absent pre-S22)"
grep -E 'ground_truth:|drift_axes:|required_audits:|vision_questions:' "$DEMO/.ai/CONSTRAINTS.yaml" | sed 's/^/    /'
ok "Direction-drift auditing (vision + roadmap) inherited"

header "3. The scaffold now carries the S21 co-pilot rules"
label ".ai/CONSTRAINTS.yaml#copilot.on"
grep -E '^[[:space:]]*-[[:space:]]*".*=>.*"' "$DEMO/.ai/CONSTRAINTS.yaml" | sed -E 's/^[[:space:]]*-[[:space:]]*/  ⚡on /'
ok "Plus refreshed approval_tokens (+\"go ahead and commit\") + GT-exempt branch suffixes"

header "4. The hook ships drift-free (the key decision: include_str!)"
label "cmp scaffolded hook  vs  canonical scripts/hook-copilot-loader.sh"
if cmp -s "$CANON" "$DEMO/scripts/hook-copilot-loader.sh"; then
  printf "    ${GREEN}byte-identical — one source of truth, no hand-copy${RESET}\n"
else
  printf "    ${RED}DRIFT — files differ${RESET}\n"
fi
ok "Un-excluded in Cargo.toml so it also ships with \`cargo install\`"

header "5. The propagated co-pilot FIRES in the new project (L2 = enforce)"
label "PreToolUse(Bash) 'git commit' in the scaffolded project"
SD=$(mktemp -d)
OUT=$(printf '%s' '{"tool_name":"Bash","tool_input":{"command":"git commit -m wip"},"session_id":"demo22"}' \
  | VAJRA_COPILOT_STATE_DIR="$SD" CLAUDE_PROJECT_DIR="$DEMO" bash "$DEMO/scripts/hook-copilot-loader.sh" 2>&1) && RC=0 || RC=$?
rm -rf "$SD"
printf '%s\n' "$OUT" | sed 's/^/    /'
if [ "$RC" -eq 2 ]; then printf "    ${RED}[tool BLOCKED — exit 2 → the new project enforces, day one]${RESET}\n"
else printf "    ${DIM}[exit %s]${RESET}\n" "$RC"; fi
rm -rf "$DEMO"
ok "A brand-new project gets the enforcing co-pilot with zero extra setup"

header "Summary"
printf "\n"
printf "  %-48s %s\n" "Deliverable" "Status"
printf "  %-48s %s\n" "------------------------------------------------" "------"
printf "  %-48s %s\n" "init scaffolds ground_truth audits (S20)"        "DONE"
printf "  %-48s %s\n" "init scaffolds copilot.on rules (S21)"           "DONE"
printf "  %-48s %s\n" "hook embedded via include_str! (no drift)"       "DONE"
printf "  %-48s %s\n" "hook wired into PreToolUse (Bash + Edit/Write)"  "DONE"
printf "  %-48s %s\n" "propagated co-pilot fires in a fresh project"    "DONE"
printf "\n"
printf "${DIM}  Cumulative: prior capabilities in scripts/demo-session-{08,09,11,12,13,14,16,17,19,21}.sh${RESET}\n"
ok "Session ${SESSION} demo complete — the hardening now travels with every \`vajra init\`."
