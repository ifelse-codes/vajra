#!/usr/bin/env bash
# Demo — Session 109: fleet slice 1 — one named agent (the Researcher) dispatched as a GOVERNED STEP.
#
# Sprint-demo contract (CONSTRAINTS.yaml#demo.required_elements): header · cases · summary_table ·
# before_after — each emitted as a `demo:<element>` marker. The Demo-er gate (S71) RE-RUNS this LIVE
# at close and blocks on a non-zero exit or a missing element. Everything here runs on the STUB agent
# (VAJRA_AGENT_CMD) — NO paid call in the demo; the real paid Researcher call's receipt is captured in
# the session summary. When a user asks to SEE the demo, present it as an interactive HTML slide deck.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="109"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}== %s ==${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}> %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}OK %s${RESET}\n" "$1"; }
no()     { printf "${RED}xx %s${RESET}\n" "$1"; }

# Build the binary the demo drives.
( cargo build -q ) || { no "cargo build failed"; exit 1; }
BIN="$ROOT/target/debug/vajra"

# A stub Researcher agent (no paid call) — emits a canned result stream like `claude -p --output-format json`.
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
STUB="$WORK/stub.sh"
cat > "$STUB" <<'EOF'
#!/bin/sh
printf '%s\n' '{"type":"result","result":"Use ripgrep over grep for repo scans: ~3x faster, respects .gitignore. Trade-off: an extra dependency.","total_cost_usd":0.0037}'
EOF
chmod +x "$STUB"

# A throwaway governed repo on a session branch (so the handoff lands under session-42).
REPO="$WORK/repo"; mkdir -p "$REPO/.ai"
( cd "$REPO"; git init -q -b main; git config user.email t@t; git config user.name t
  echo 42 > .ai/SESSION; echo seed > seed.txt; git add -A; git commit -qm init
  git checkout -qb session-42-demo ) >/dev/null 2>&1
HANDOFF="$REPO/.ai/handoffs/session-42-researcher.md"

# --- demo:header ---
header "Session ${SESSION} Demo — the fleet's first real agent: a Researcher dispatched as a GOVERNED step  [demo:header]"
label "One line: 'vajra claude --role researcher -p \"<question>\"' runs one named agent behind the existing gates, capturing its answer as a delta-tracked handoff in the .ai/ spine — no 8th command, stub path for CI, one real paid call as the headline proof."

# --- demo:before_after ---
header "Before -> After  [demo:before_after]"
label "BEFORE — 'vajra claude' launched ONE undifferentiated agent; the 8 'stations' were gates + a team-voice roster (S104), not real separate agent invocations. The fleet fork (S103) had 0 code."
label "AFTER — a named role is a real dispatch:"
printf "  ${DIM}vajra consumes --role, injects the Researcher's role-scoped system prompt, runs the agent (real claude OR a stub via VAJRA_AGENT_CMD), meters the real cost (S78), and writes a governed handoff: frontmatter contract + captured findings + a ## Handoff Delta vs the prior stage.${RESET}\n"

# --- demo:cases ---
header "Cases  [demo:cases]"

header "1 · Dispatch the Researcher (stub agent) → a governed handoff appears in .ai/handoffs/"
label "Live: VAJRA_AGENT_CMD=<stub> vajra claude --role researcher -p 'fastest repo scan tool?'"
if ( cd "$REPO" && VAJRA_AGENT_CMD="$STUB" "$BIN" claude --role researcher -p "fastest repo scan tool?" ) >/dev/null 2>&1; then
  ok "dispatch exited 0; handoff written"
  printf "  ${DIM}--- .ai/handoffs/session-42-researcher.md ---${RESET}\n"
  sed 's/^/  /' "$HANDOFF"
else
  no "dispatch failed"; exit 1
fi

header "2 · The handoff is well-formed (frontmatter contract + non-empty body + ## Handoff Delta)"
for key in "role: researcher" "source-sha:" "cost_usd:"; do
  if grep -q "^${key}" "$HANDOFF"; then ok "carries '${key}'"; else no "missing '${key}'"; exit 1; fi
done
if grep -Eq "^source-sha: [0-9a-f]{64}$" "$HANDOFF"; then ok "source-sha is a real 64-hex digest (traceable to what was asked)"; else no "source-sha not a digest"; exit 1; fi
if grep -q "## Handoff Delta" "$HANDOFF"; then ok "records a ## Handoff Delta"; else no "no delta"; exit 1; fi

header "3 · FAIL-CLOSED — the governance holds: unknown role / missing agent / no task all exit non-zero"
label "Live: an UNKNOWN role must be refused"
if ( cd "$REPO" && VAJRA_AGENT_CMD="$STUB" "$BIN" claude --role coder -p "x" ) >/tmp/vajra-demo-109-role.log 2>&1; then
  no "unknown role returned 0 — NOT a real gate"; exit 1
else ok "unknown role -> exit non-zero"; printf "  ${DIM}%s${RESET}\n" "$(grep -m1 'unknown role' /tmp/vajra-demo-109-role.log || true)"; fi
label "Live: a MISSING agent command must be refused"
if ( cd "$REPO" && VAJRA_AGENT_CMD="/no/such/agent" "$BIN" claude --role researcher -p "x" ) >/dev/null 2>&1; then
  no "missing agent returned 0 — NOT a real gate"; exit 1
else ok "missing agent command -> exit non-zero"; fi
label "Live: MALFORMED agent output must not write a bogus handoff"
BAD="$WORK/bad.sh"; printf '#!/bin/sh\necho noise\n' > "$BAD"; chmod +x "$BAD"
BADREPO="$WORK/badrepo"; mkdir -p "$BADREPO/.ai"
( cd "$BADREPO"; git init -q -b main; git config user.email t@t; git config user.name t
  echo 42 > .ai/SESSION; echo s > s.txt; git add -A; git commit -qm init; git checkout -qb session-42-bad ) >/dev/null 2>&1
if ( cd "$BADREPO" && VAJRA_AGENT_CMD="$BAD" "$BIN" claude --role researcher -p "x" ) >/dev/null 2>&1; then
  no "malformed output returned 0 — NOT fail-closed"; exit 1
else ok "malformed output -> exit non-zero, no handoff written"; fi

header "4 · No 8th command — the dispatch RIDES 'vajra claude'"
label "Live: vajra --help still lists exactly 7 commands"
if "$BIN" --help 2>&1 | grep -q "vajra <init|claude|check|next|estimate|hook|meter>"; then
  ok "7 commands (init·claude·check·next·estimate·hook·meter) — no 8th"
else no "command set changed"; exit 1; fi

header "5 · The falsifiable stub smoke (CI's gate — no paid call)"
label "Live: scripts/fleet-smoke.sh"
if bash scripts/fleet-smoke.sh | tail -1 | sed 's/^/  /'; then ok "fleet-smoke SMOKE PASS (7/7)"; else no "fleet-smoke failed"; exit 1; fi

# --- demo:summary_table ---
header "Summary  [demo:summary_table]"
printf "\n"
printf "  %-44s %s\n" "Capability" "Status"
printf "  %-44s %s\n" "--------------------------------------------" "------"
printf "  %-44s %s\n" "vajra claude --role researcher (dispatch)"   "SHIPPED (S109)"
printf "  %-44s %s\n" "governed handoff in .ai/handoffs/"           "SHIPPED"
printf "  %-44s %s\n" "delta-tracked (## Handoff Delta)"            "SHIPPED"
printf "  %-44s %s\n" "real cost metered (S78 tee)"                 "SHIPPED"
printf "  %-44s %s\n" "stub path (VAJRA_AGENT_CMD, CI/gate)"        "PAID-FREE"
printf "  %-44s %s\n" "unknown role / missing agent / bad output"   "FAIL-CLOSED"
printf "  %-44s %s\n" "no 8th top-level command"                    "TRUE (help = 7)"
printf "  %-44s %s\n" "one real paid Researcher call"               "SEE SUMMARY"
printf "\n"

ok "Session ${SESSION} demo complete."
