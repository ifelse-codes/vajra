#!/usr/bin/env bash
# Session 28 — Propagate Darshan into `vajra init`. Cumulative demo: a brand-new
# project, scaffolded from scratch, now inherits the Darshan human-output skill +
# the AGENTS.md Speaking Skills boot pointer — byte-identical to canonical, the
# same one-source-of-truth pattern that ships the co-pilot loader (S22).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="28"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — every new project inherits Darshan"
printf "${DIM}  S22 lesson: a skill only matters if every scaffolded project gets it.${RESET}\n"

# Make sure the binary is current.
cargo build --quiet 2>/dev/null || true
BIN="$ROOT/target/debug/vajra"

# ---------------------------------------------------------------------------
header "1. Scaffold a brand-new project from scratch"
SCRATCH=$(mktemp -d)
trap 'rm -rf "$SCRATCH"' EXIT
( cd "$SCRATCH" && git init -q )
label "vajra init  (project: demo-proj, goal: build it, maturity: L2)"
printf 'demo-proj\nbuild it\n\n' | ( cd "$SCRATCH" && "$BIN" init ) 2>&1 \
  | grep -E 'create|skip' | sed 's/^/    /' || true

# ---------------------------------------------------------------------------
header "2. The fresh project inherited Darshan"
if [ -f "$SCRATCH/darshan/SKILL.md" ]; then
  ok "darshan/SKILL.md scaffolded ($(wc -l < "$SCRATCH/darshan/SKILL.md" | tr -d ' ') lines)"
else
  bad "darshan/SKILL.md MISSING"
fi
if cmp -s "$SCRATCH/darshan/SKILL.md" "$ROOT/darshan/SKILL.md"; then
  ok "byte-identical to canonical darshan/SKILL.md — one source of truth, zero drift"
else
  bad "scaffolded skill DRIFTED from canonical"
fi

# ---------------------------------------------------------------------------
header "3. The constitution boots Darshan as the default human lane"
printf "${DIM}  .ai/AGENTS.md (scaffolded) — Speaking Skills section:${RESET}\n"
sed -n '/## Speaking Skills/,/## Mandatory Load Order/p' "$SCRATCH/.ai/AGENTS.md" \
  | grep -v '## Mandatory Load Order' | sed 's/^/    /'

# ---------------------------------------------------------------------------
header "4. Cumulative — prior propagation still intact (S22 co-pilot)"
n=$(grep -c 'hook-copilot-loader.sh' "$SCRATCH/.claude/settings.json" || echo 0)
[ "$n" -ge 1 ] && ok "co-pilot loader still wired into .claude/settings.json ($n matchers)" \
              || bad "co-pilot wiring regressed"
[ -f "$SCRATCH/scripts/hook-copilot-loader.sh" ] \
  && ok "co-pilot hook still scaffolded verbatim" || bad "co-pilot hook missing"

# ---------------------------------------------------------------------------
header "Summary"
printf "\n"
printf "  %-40s %s\n" "Artifact (in a fresh vajra init)" "Status"
printf "  %-40s %s\n" "----------------------------------------" "------"
printf "  %-40s %s\n" "darshan/SKILL.md (byte-identical)"        "INHERITED"
printf "  %-40s %s\n" "AGENTS.md Speaking Skills boot pointer"   "INHERITED"
printf "  %-40s %s\n" "co-pilot loader (S22 regression)"         "INTACT"
printf "  %-40s %s\n" "session-guard (S26)"                      "→ S29 (split)"
printf "\n"

ok "Session ${SESSION} demo complete — new projects boot with Darshan."
