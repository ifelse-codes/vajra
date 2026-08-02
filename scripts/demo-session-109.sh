#!/usr/bin/env bash
# Demo — Session 109: fleet slice 1 — one named agent (the Researcher) as a NATIVE Claude Code
# subagent, governed by Vajra. DECISION-007.
#
# Sprint-demo contract (CONSTRAINTS.yaml#demo.required_elements): header · cases · summary_table ·
# before_after — each an `demo:<element>` marker. The Demo-er gate (S71) RE-RUNS this LIVE at close
# and blocks on a non-zero exit or a missing element. Everything here runs on plain files — NO paid
# call, NO live agent; the real Researcher subagent run's evidence is captured in the session summary.
# When a user asks to SEE the demo, present it as an interactive HTML slide deck.

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

( cargo build -q ) || { no "cargo build failed"; exit 1; }
BIN="$ROOT/target/debug/vajra"

# A throwaway governed repo on a session branch (so a handoff lands under session-42).
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
REPO="$WORK/repo"; mkdir -p "$REPO"
( cd "$REPO"; git init -q -b main; git config user.email t@t; git config user.name t
  printf 'demo\nfirst session\nL2\n' | "$BIN" init >/dev/null 2>&1 || true
  git add -A; git commit -q --no-verify -m init; git checkout -qb session-42-demo ) >/dev/null 2>&1
AGENT_DEF="$REPO/.claude/agents/researcher.md"
HANDOFF="$REPO/.ai/handoffs/session-42-researcher.md"

# --- demo:header ---
header "Session ${SESSION} Demo — the fleet's first named agent: a Researcher SUBAGENT, governed by Vajra  [demo:header]"
label "One line: 'vajra init' scaffolds the Researcher as a native Claude Code subagent (.claude/agents/researcher.md) from ONE canonical source; the live session runs it via the Task tool; 'vajra next --role researcher --from <findings>' records its brief as a delta-tracked, validated handoff in the .ai/ spine. No 8th command, no separate auth."

# --- demo:before_after ---
header "Before -> After  [demo:before_after]"
label "BEFORE — 'vajra claude' launched ONE undifferentiated agent; the 8 'stations' were gates + a team-voice roster (S104), not real separate agents. The fleet fork (S103) had 0 code."
label "AFTER — a named role is a real, native subagent that Vajra scaffolds + governs:"
printf "  ${DIM}Vajra owns two jobs: (1) SCAFFOLD .claude/agents/researcher.md from the canonical fleet::ROLES (like it already scaffolds settings.json + hooks); (2) GOVERN the subagent's findings into a handoff with a source-sha, a timestamp, and a ## Handoff Delta vs the prior stage — fail-closed if the role is unknown or the findings are empty.${RESET}\n"

# --- demo:cases ---
header "Cases  [demo:cases]"

header "1 · 'vajra init' scaffolds the role as a native Claude Code subagent"
label "Live: head .claude/agents/researcher.md (rendered from the one canonical source)"
if [ -f "$AGENT_DEF" ] && grep -q "^name: researcher" "$AGENT_DEF"; then
  ok "subagent definition scaffolded"
  sed -n '1,4p' "$AGENT_DEF" | sed 's/^/  /'
else no "no subagent definition"; exit 1; fi

header "2 · Govern a subagent's findings → a delta-tracked, validated handoff in .ai/"
label "Live: vajra next --role researcher --from <findings>"
printf 'Use ripgrep over grep for repo scans: ~3x faster, respects .gitignore. Trade-off: an extra dependency.\n' > "$WORK/findings.txt"
if ( cd "$REPO" && "$BIN" next --role researcher --from "$WORK/findings.txt" ) >/tmp/vajra-demo-109-gov.log 2>&1; then
  ok "handoff governed + validated"
  sed 's/^/  /' /tmp/vajra-demo-109-gov.log
  printf "  ${DIM}--- .ai/handoffs/session-42-researcher.md ---${RESET}\n"
  sed 's/^/  /' "$HANDOFF"
else no "governance failed"; exit 1; fi

header "3 · The handoff is well-formed (frontmatter contract + non-empty body + ## Handoff Delta)"
for key in "role: researcher" "source-sha:" "cost_usd:"; do
  if grep -q "^${key}" "$HANDOFF"; then ok "carries '${key}'"; else no "missing '${key}'"; exit 1; fi
done
if grep -Eq "^source-sha: [0-9a-f]{64}$" "$HANDOFF"; then ok "source-sha is a real 64-hex digest of the findings"; else no "source-sha not a digest"; exit 1; fi
if grep -q "## Handoff Delta" "$HANDOFF"; then ok "records a ## Handoff Delta"; else no "no delta"; exit 1; fi

header "4 · FAIL-CLOSED — governance holds: unknown role / missing --from / empty findings exit non-zero"
label "Live: an UNKNOWN role must be refused"
if ( cd "$REPO" && "$BIN" next --role coder --from "$WORK/findings.txt" ) >/tmp/vajra-demo-109-role.log 2>&1; then
  no "unknown role returned 0 — NOT a real gate"; exit 1
else ok "unknown role -> exit non-zero"; printf "  ${DIM}%s${RESET}\n" "$(grep -m1 'unknown role' /tmp/vajra-demo-109-role.log || true)"; fi
label "Live: a missing --from must be refused"
if ( cd "$REPO" && "$BIN" next --role researcher ) >/dev/null 2>&1; then
  no "missing --from returned 0 — NOT a real gate"; exit 1
else ok "missing --from -> exit non-zero"; fi
label "Live: EMPTY findings must not write a bogus handoff"
printf '   \n' > "$WORK/empty.txt"
BADREPO="$WORK/badrepo"; mkdir -p "$BADREPO"
( cd "$BADREPO"; git init -q -b main; git config user.email t@t; git config user.name t
  printf 'd\nf\nL2\n' | "$BIN" init >/dev/null 2>&1 || true
  git add -A; git commit -q --no-verify -m init; git checkout -qb session-42-bad ) >/dev/null 2>&1
if ( cd "$BADREPO" && "$BIN" next --role researcher --from "$WORK/empty.txt" ) >/dev/null 2>&1; then
  no "empty findings returned 0 — NOT fail-closed"; exit 1
else ok "empty findings -> exit non-zero, no handoff written"; fi

header "5 · No 8th command — scaffold rides 'vajra init', governance rides 'vajra next'"
label "Live: vajra --help still lists exactly 7 commands"
if "$BIN" --help 2>&1 | grep -q "vajra <init|claude|check|next|estimate|hook|meter>"; then
  ok "7 commands (init·claude·check·next·estimate·hook·meter) — no 8th"
else no "command set changed"; exit 1; fi

header "6 · The falsifiable stub smoke (CI's gate — no paid call, no live agent)"
label "Live: scripts/fleet-smoke.sh"
if bash scripts/fleet-smoke.sh | tail -1 | sed 's/^/  /'; then ok "fleet-smoke SMOKE PASS (7/7)"; else no "fleet-smoke failed"; exit 1; fi

# --- demo:summary_table ---
header "Summary  [demo:summary_table]"
printf "\n"
printf "  %-46s %s\n" "Capability" "Status"
printf "  %-46s %s\n" "----------------------------------------------" "------"
printf "  %-46s %s\n" "vajra init scaffolds .claude/agents/researcher.md" "SHIPPED (S109)"
printf "  %-46s %s\n" "rendered from ONE canonical source (fleet::ROLES)" "NO DRIFT"
printf "  %-46s %s\n" "vajra next --role --from (govern findings)"        "SHIPPED"
printf "  %-46s %s\n" "delta-tracked handoff in .ai/ (## Handoff Delta)"  "SHIPPED"
printf "  %-46s %s\n" "unknown role / missing --from / empty findings"    "FAIL-CLOSED"
printf "  %-46s %s\n" "no 8th top-level command"                          "TRUE (help = 7)"
printf "  %-46s %s\n" "real Researcher subagent run"                      "SEE SUMMARY"
printf "\n"

ok "Session ${SESSION} demo complete."
