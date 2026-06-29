#!/usr/bin/env bash
# Session 27 — Darshan: Vajra's default, surface-adaptive, glanceable human-output
# skill (skill, not renderer; pairs with Varta — agent talks in Varta, user sees
# Darshan). This demo shows the SAME status as a wall of text, then in Darshan's
# terminal tier and plain fallback — same truth, far less to read, nothing dropped.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="27"
SKILL="$ROOT/darshan/SKILL.md"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — Darshan: show the human, don't dump on them"
printf "${DIM}  One rule: render the richest visual this surface can handle;${RESET}\n"
printf "${DIM}  always glanceable; never drop meaning. Pairs with Varta.${RESET}\n"

# ---------------------------------------------------------------------------
header "1. The wall of text (what AI does today)"
printf "${DIM}"
cat <<'WALL'
    I finished the session 27 work. The verify script passed all of its
    checks — there were 9 of them and they all passed, including cargo fmt,
    clippy, and the full test suite, plus the Darshan-specific assertions for
    the three surface tiers, the never-drop-meaning rule, the terminal
    fallback, and the boot wiring. The demo also runs and shows the wall of
    text versus the glanceable form. The PR is open but not yet merged.
WALL
printf "${RESET}"
printf "    ${RED}↑ 6 lines to read word-by-word for 3 facts.${RESET}\n"

# ---------------------------------------------------------------------------
header "2. Same truth — Darshan, terminal tier (this surface)"
printf "${GREEN}${BOLD}"
cat <<'BOX'
    ┌─ Session 27 · Darshan ──────────────── ✓ DONE ─┐
    │  verify   9/9 pass   ▕████████▏                 │
    │  demo     wall → glance · chat + terminal       │
    │  PR       ⚠ open (merge after closeout)         │
    └─────────────────────────────────────────────────┘
BOX
printf "${RESET}"
printf "    ${DIM}Same 3 facts, one glance. Nothing dropped — the ⚠ caveat survives.${RESET}\n"

# ---------------------------------------------------------------------------
header "3. Same truth — plain / no-color fallback (pipes, logs)"
cat <<'PLAIN'
    SESSION 27 · DARSHAN — DONE
    - verify: 9/9 pass
    - demo:   wall -> glance (chat + terminal)
    - PR:     open (merge after closeout)
PLAIN
printf "    ${DIM}Degrades cleanly everywhere; still leads with the verdict.${RESET}\n"

# ---------------------------------------------------------------------------
header "4. The richest tier — rich chat (HTML/SVG)"
printf "    ${DIM}On Claude desktop/web/Cursor the agent emits an HTML card —\n"
printf "    a colored banner + table. The skill ships a worked example:${RESET}\n"
grep -nF '<div style="background:#0a7' "$SKILL" >/dev/null 2>&1 \
  && ok "darshan/SKILL.md carries a before/after for BOTH chat + terminal"

# ---------------------------------------------------------------------------
header "5. Wired as the default — and skill-not-renderer"
grep -qi "Darshan" "$ROOT/.ai/AGENTS.md" \
  && ok ".ai/AGENTS.md teaches Darshan at boot as the default human-output skill"
grep -qiE "skill,? not a renderer|there is no renderer" "$SKILL" \
  && ok "nothing in Vajra renders — the agent draws (like Varta speaks)"
! grep -rqi "Darshan" "$ROOT/src" 2>/dev/null \
  && ok "no 8th command — Darshan rides the boot/skill surface"

header "6. Why this matters (cumulative)"
printf "    ${DIM}• Varta = the agent talks to itself · Darshan = the user sees.${RESET}\n"
printf "    ${DIM}• Plain-talk fixes the words; Darshan also fixes the LOAD.${RESET}\n"
printf "    ${DIM}• Surface-adaptive: rich chat → terminal → plain, never dropping meaning.${RESET}\n"
printf "    ${DIM}• Scaffold propagation to \`vajra init\` deferred to S28 (kept to 1 story).${RESET}\n"

header "Done"
ok "The human gets a glance, not a wall — every reply, any agent."
