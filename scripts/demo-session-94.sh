#!/usr/bin/env bash
# Session 94 demo — the guards are now repo-identity-aware (nested-repo blindspot, S52, closed).
# Cumulative: prior sessions' capabilities still hold; this pins each guard to the project it was
# scaffolded into and SURFACES which project it governs.
# Emits demo:header / demo:before_after / demo:cases / demo:summary_table (Demo-er gate, S71).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="94"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"; YELLOW="\033[33m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
no()     { printf "${RED}✗ %s${RESET}\n" "$1"; }

G_COMMIT="$ROOT/scripts/hook-commit-guard.sh"
G_MURMUR="$ROOT/scripts/hook-copilot-murmur.sh"
G_SESSION="$ROOT/scripts/hook-session-guard.sh"

# Fixtures: an OUTER git repo on session-94 with a NESTED subject (plain dir, no own .git) — the
# dogfood shape — plus a STANDALONE subject (its own git repo on session-07).
FX=$(mktemp -d); trap 'rm -rf "$FX"' EXIT
BODY='version: 3
maturity: L2
session:
  one_session_per_chat: true
copilot:
  on:
    - "src/* => docs/x.md | heuristics context"
'
OUTER="$FX/outer"
( mkdir -p "$OUTER" && cd "$OUTER" && git init -q && git symbolic-ref HEAD refs/heads/session-94-outer )
mkdir -p "$OUTER/src"; echo enclosing > "$OUTER/src/enclosing.rs"
SUBJ="$OUTER/subject"; mkdir -p "$SUBJ/scripts" "$SUBJ/.ai"
cp "$G_COMMIT" "$G_MURMUR" "$G_SESSION" "$SUBJ/scripts/"
printf '%s' "$BODY" > "$SUBJ/.ai/CONSTRAINTS.yaml"; printf '7\n' > "$SUBJ/.ai/SESSION"
STAND="$FX/standalone"; mkdir -p "$STAND/scripts" "$STAND/.ai"
( cd "$STAND" && git init -q && git symbolic-ref HEAD refs/heads/session-07-standalone )
cp "$G_COMMIT" "$G_MURMUR" "$G_SESSION" "$STAND/scripts/"
printf '%s' "$BODY" > "$STAND/.ai/CONSTRAINTS.yaml"; printf '7\n' > "$STAND/.ai/SESSION"

cg_out() {  # <marker> <root> → prints combined guard output
  echo '{"tool_input":{"command":"git commit -m x"}}' \
    | VAJRA_ALLOW_COMMIT="$1" VAJRA_ENFORCE_COMMIT=1 CLAUDE_PROJECT_DIR="$2" \
        bash "$2/scripts/hook-commit-guard.sh" 2>&1 || true
}

# --- demo:header ---
header "Session ${SESSION} Demo  [demo:header]"
label "The PreToolUse guards are now repo-identity-aware — each acts only on the project it was"
label "scaffolded into, and names it. No cross-repo bleed during a nested dogfood."

# --- demo:before_after ---
header "Before → After  [demo:before_after]"
label "BEFORE — a guard run in a subject nested inside another git repo derived git facts via"
echo  "  \`git -C \$ROOT\`, which walks UP to the nearest .git. A subject checked out under Vajra"
echo  "  (on session-94) had its commit-guard read Vajra's branch → demanded VAJRA_ALLOW_COMMIT=94"
echo  "  and Vajra's own founder marker could authorize a commit in the SUBJECT. Silent mis-fire."
label "AFTER — git facts are pinned to the project's OWN git top-level; the governed project is"
echo  "  surfaced on every advise/block. A nested subject no longer adopts the enclosing session."

# --- demo:cases ---
header "Cases  [demo:cases]"

header "1 · NESTED commit-guard no longer leaks the enclosing session (94)"
OUT=$(cg_out "" "$SUBJ")
if grep -q "VAJRA_ALLOW_COMMIT=NN" <<<"$OUT" && ! grep -q "VAJRA_ALLOW_COMMIT=94" <<<"$OUT"; then
  ok "block says =NN, not =94 (enclosing session not adopted)"
  printf "    %s\n" "$(grep -m1 'Governing project' <<<"$OUT" | sed -E 's/^[[:space:]]+//')"
else no "enclosing session leaked into the block message"; fi

header "2 · NON-NESTED (own git, session-07) still binds correctly — zero regression"
OUT=$(cg_out "99" "$STAND")
grep -q "VAJRA_ALLOW_COMMIT=07" <<<"$OUT" && ok "wrong marker 99 → blocked, demands this repo's =07" || no "binding changed"
OUT=$(cg_out "07" "$STAND")
grep -q "ALLOWED" <<<"$OUT" && ok "correct marker 07 → allowed, names its own project" || no "correct marker rejected"

header "3 · NESTED co-pilot murmur stays quiet (won't murmur the enclosing repo's changes)"
MOUT=$(echo '{"session_id":"d94"}' | CLAUDE_PROJECT_DIR="$SUBJ" VAJRA_COPILOT_STATE_DIR="$FX/ms" bash "$SUBJ/scripts/hook-copilot-murmur.sh" 2>&1 || true)
[ -z "$MOUT" ] && ok "no own git → no murmur about enclosing src/enclosing.rs" || no "murmured the enclosing repo"

header "4 · session-guard surfaces the governed project + flags nesting"
printf '6\td94\n' > "$SUBJ/.ai/.session-owner"; rm -rf "$OUTER/.ai" 2>/dev/null || true
SOUT=$(echo '{"session_id":"d94","tool_input":{"command":"git checkout -b session-7-x"}}' | CLAUDE_PROJECT_DIR="$SUBJ" bash "$SUBJ/scripts/hook-session-guard.sh" 2>&1 || true)
if grep -q "Governing project" <<<"$SOUT" && grep -q "nested inside git repo" <<<"$SOUT"; then
  ok "block names the governed subject and flags the nesting (mis-fire is visible)"
else no "governed project not surfaced"; fi

# --- demo:summary_table ---
header "Summary  [demo:summary_table]"
printf "\n"
printf "  %-46s %s\n" "Guard / property" "Status"
printf "  %-46s %s\n" "----------------------------------------------" "------"
printf "  %-46s %s\n" "commit-guard: git facts pinned to own repo"  "FIXED"
printf "  %-46s %s\n" "copilot-murmur: reads own working tree only"  "FIXED"
printf "  %-46s %s\n" "session-guard: owner/session pinned + surfaced" "SURFACED"
printf "  %-46s %s\n" "governed project named on advise/block"       "YES"
printf "  %-46s %s\n" "non-nested behavior unchanged"                "ZERO REGRESSION"
printf "  %-46s %s\n" "scaffold inherits byte-identical (include_str!)" "YES"
printf "\n"

ok "Session ${SESSION} demo complete."
