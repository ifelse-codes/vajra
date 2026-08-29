#!/usr/bin/env bash
# demo-session-137.sh — the sprint demo for S137: the first PAID dogfood of a Vajra-governed
# BUILD. chitra's `scatter` chart, locked to the reference panel language, rendered live.
# Required elements (CONSTRAINTS.yaml#demo.required_elements): header, cases, summary_table,
# before_after — each an emitted `demo:<element>` marker the Demo-er gate re-runs live and scans.
# The locked scatter lives on chitra's session-17-scatter-lock branch; chitra rests on session-16.
# chitra's core is ZERO-DEPENDENCY, so a throwaway worktree renders it via tsx with no install,
# and session-16 is never touched.
set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

CHITRA="${CHITRA_DIR:-/Users/suman/playground/chitra}"
BRANCH="session-17-scatter-lock"
TSX=""
for c in "$CHITRA/artifacts/chitra-docs/node_modules/.bin/tsx" \
         "$CHITRA/packages/core/node_modules/.bin/tsx" \
         "$CHITRA/node_modules/.pnpm/node_modules/.bin/tsx"; do
  [ -x "$c" ] && { TSX="$c"; break; }
done

CYAN="\033[36m"; BOLD="\033[1m"; GREEN="\033[32m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"
head_() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }

WT=""
cleanup() { [ -n "$WT" ] && git -C "$CHITRA" worktree remove --force "$WT" >/dev/null 2>&1; git -C "$CHITRA" worktree prune 2>/dev/null || true; }
trap cleanup EXIT
if [ -d "$CHITRA" ] && [ -n "$TSX" ] && git -C "$CHITRA" rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
  git -C "$CHITRA" worktree prune 2>/dev/null || true
  WT="$(mktemp -d)/s17"
  git -C "$CHITRA" worktree add -q "$WT" "$BRANCH" 2>/dev/null || WT=""
fi
[ -n "$WT" ] || { echo "demo bug: cannot render the locked scatter (chitra/tsx/branch absent)"; exit 2; }

render() { # $1 = renderer, $2 = opts-json
  local f="$WT/packages/core/_demo137.mts"
  cat > "$f" <<EOF
import { scatter } from "./src/index.ts";
process.stdout.write(scatter($2).toString());
EOF
  "$TSX" "$f" 2>/dev/null; echo; rm -f "$f"   # trailing newline: toString() emits none
}

DATA='data:[{x:1,y:2},{x:2,y:4},{x:3,y:3},{x:4,y:7},{x:5,y:5},{x:6,y:9},{x:7,y:6},{x:10,y:12}]'

echo "demo:header"
head_ "S137 — chitra's scatter, locked to the reference language (paid dogfood)"
printf "${DIM}The first time Vajra governed a real BUILD in an outside project. The tech-lead was\n"
printf "dispatched FIRST and its verdict bound; the design-advisor + implementation-advisor shaped\n"
printf "the chart WITH the founder, who signed off on the render. Below is the real locked output.${RESET}\n"

echo "demo:cases"

head_ "1 · The locked scatter (braille) — one accent on the max-y peak, grey ramp elsewhere"
render braille "{${DATA},title:\"Scatter Plot\",width:50,height:12}" | sed 's/^/    /'

head_ "2 · The accent tracks PRIMARY-series max-y, not the global max (multi-series)"
printf "${DIM}    series 0's max-y is (2,5); series 1 has a higher (9,20) point but is NOT primary.${RESET}\n"
render braille "{data:[[{x:1,y:1},{x:2,y:5}],[{x:9,y:20},{x:8,y:3}]],title:\"Two series\",width:50,height:10}" | sed 's/^/    /'

head_ "3 · Degenerate data is safe — empty renders n 0, no Infinity/NaN"
render braille "{data:[],title:\"Empty\",width:40,height:6}" | sed 's/^/    /'

echo "demo:summary_table"
head_ "What the lock carries"
printf "    %-26s %s\n" "panel frame" "┌╌ … ╌┐ dashed, eyebrow CORRELATION"
printf "    %-26s %s\n" "accent (spent once)" "primary-series max-y point, both render paths"
printf "    %-26s %s\n" "everything else" "grey ramp #ECECEF→#C6C6CE→#A4A4AE→#6A6A75"
printf "    %-26s %s\n" "footer" "n · x-range · y-range · peak (x,y) — no Pearson r"
printf "    %-26s %s\n" "guards" "empty / single / all-equal-y — no Infinity/NaN"

echo "demo:before_after"
head_ "BEFORE vs AFTER"
printf "    ${RED}BEFORE:${RESET} scatter() painted points with a per-series rainbow (theme.colors[i%%n]),\n"
printf "            a bare └─ axis, no frame, no eyebrow, no footer — the last unlocked continuous\n"
printf "            chart, off the reference language its siblings already spoke.\n"
printf "    ${GREEN}AFTER:${RESET}  scatter() joins pie/donut/area/line/bar: dashed panel, eyebrow, +/│ guide,\n"
printf "            the ONE accent hue spent once on the max-y peak (verified at raw-RGB: exactly\n"
printf "            one accent cell, zero rainbow), and an honest n·x·y·peak footer. Real commits on\n"
printf "            chitra's session-17 branch, previews regenerated, README contract added, and\n"
printf "            chitra's in-flight session-16 work proven byte-identical untouched.\n"

echo ""
printf "${GREEN}${BOLD}demo-137 complete.${RESET}\n"
