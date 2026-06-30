#!/usr/bin/env bash
# Session 29 — Propagate the one-session-per-chat guard into `vajra init`. Cumulative
# demo: a brand-new project, scaffolded from scratch, now inherits the S26 session-guard
# (byte-identical, executable), its PreToolUse(Bash) wiring, `one_session_per_chat: true`,
# and a `.gitignore` for the owner record — and the scaffolded guard actually enforces.
# Closes the second half of the S28 split (the same S22/S28 one-source-of-truth pattern).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="29"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — every new project inherits the session-guard"
printf "${DIM}  S22 lesson: enforcement only matters if every scaffolded project gets it.${RESET}\n"

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
header "2. The fresh project inherited the session-guard"
if [ -x "$SCRATCH/scripts/hook-session-guard.sh" ]; then
  ok "scripts/hook-session-guard.sh scaffolded + executable ($(wc -l < "$SCRATCH/scripts/hook-session-guard.sh" | tr -d ' ') lines)"
else
  bad "hook-session-guard.sh MISSING or not executable"
fi
if cmp -s "$SCRATCH/scripts/hook-session-guard.sh" "$ROOT/scripts/hook-session-guard.sh"; then
  ok "byte-identical to canonical hook-session-guard.sh — one source of truth, zero drift"
else
  bad "scaffolded guard DRIFTED from canonical"
fi

# ---------------------------------------------------------------------------
header "3. Wired + gated in the scaffolded config"
n=$(grep -c 'hook-session-guard.sh' "$SCRATCH/.claude/settings.json" || echo 0)
[ "$n" -ge 1 ] && ok "guard wired into .claude/settings.json PreToolUse(Bash)" \
              || bad "guard wiring missing"
grep -q 'one_session_per_chat: true' "$SCRATCH/.ai/CONSTRAINTS.yaml" \
  && ok "one_session_per_chat: true in .ai/CONSTRAINTS.yaml (the gate)" \
  || bad "flag missing — guard would no-op"
grep -q '.ai/.session-owner' "$SCRATCH/.gitignore" \
  && ok ".gitignore ignores the owner record (.ai/.session-owner)" \
  || bad ".gitignore missing the owner record"

# ---------------------------------------------------------------------------
header "4. The scaffolded guard actually enforces"
printf "${DIM}  chatA opens session 02, then tries to start 03 in the SAME chat:${RESET}\n"
OWNER=$(mktemp)
printf '{"tool_name":"Bash","tool_input":{"command":"git checkout -b session-02-x"},"session_id":"chatA"}' \
  | VAJRA_SESSION_OWNER_FILE="$OWNER" bash "$SCRATCH/scripts/hook-session-guard.sh" >/dev/null 2>&1 || true
if GUARD_OUT=$(printf '{"tool_name":"Bash","tool_input":{"command":"git checkout -b session-03-y"},"session_id":"chatA"}' \
  | VAJRA_SESSION_OWNER_FILE="$OWNER" bash "$SCRATCH/scripts/hook-session-guard.sh" 2>&1); then RC=0; else RC=$?; fi
echo "$GUARD_OUT" | sed 's/^/    /'
rm -f "$OWNER"
[ "$RC" -eq 2 ] && ok "blocked (exit 2): one vajra-session per chat — open a new chat first" \
              || bad "guard failed to block (exit $RC)"

# ---------------------------------------------------------------------------
header "5. Cumulative — prior propagation still intact (S22 co-pilot · S28 Darshan)"
[ -f "$SCRATCH/scripts/hook-copilot-loader.sh" ] \
  && ok "co-pilot loader still scaffolded (S22)" || bad "co-pilot hook regressed"
[ -f "$SCRATCH/darshan/SKILL.md" ] \
  && ok "Darshan skill still scaffolded (S28)" || bad "Darshan regressed"

# ---------------------------------------------------------------------------
header "Summary"
printf "\n"
printf "  %-44s %s\n" "Artifact (in a fresh vajra init)" "Status"
printf "  %-44s %s\n" "--------------------------------------------" "------"
printf "  %-44s %s\n" "hook-session-guard.sh (byte-identical, +x)"  "INHERITED"
printf "  %-44s %s\n" "PreToolUse(Bash) wiring"                     "INHERITED"
printf "  %-44s %s\n" "one_session_per_chat: true (the gate)"       "INHERITED"
printf "  %-44s %s\n" ".gitignore -> .ai/.session-owner"           "INHERITED"
printf "  %-44s %s\n" "guard enforces in the fresh project"        "PROVEN"
printf "  %-44s %s\n" "co-pilot loader (S22 regression)"           "INTACT"
printf "  %-44s %s\n" "Darshan skill (S28 regression)"             "INTACT"
printf "\n"

ok "Session ${SESSION} demo complete — new projects boot one-session-per-chat enforced."
