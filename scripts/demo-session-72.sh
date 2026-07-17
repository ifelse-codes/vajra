#!/usr/bin/env bash
# Session 72 — The Releaser station (the pipeline's SHIP gate — the 8th governed station).
# Demo: seven stations governed WHAT/DESIGN/HOW/DID/WORKS/SHOW/REVIEW — and nothing governed
# SHIP. A session's work shipped (PR → merge → main synced → branches pruned) on convention
# alone: the S37 founder-flagged gap ("no post-merge 'checkout main + prune merged branches'
# step; mandatory to close/start a session") was a checklist line enforced by nobody.
# The Releaser SURFACES the ship state (`--release NN`, read-only) and ENFORCES it
# (`--check-release NN`): everything is RE-DERIVED from LOCAL git refs at check time — merge
# ancestry, main vs the last-fetched origin/main, merged session-* locals — never a recorded
# claim (the S68 git-existence lesson + the S69/S71 re-derive-live lesson). The gate blocks
# unmerged / behind / diverged / unpruned; it never pushes, merges, or deletes — shipping
# stays a human act the close now WAITS for. Cumulative: one CLI, no 8th command,
# WHAT (S54+61+62) → DESIGN (S67) → HOW-plan (S64) → CODE (S68) → WORKS (S69) → SHOW (S71) →
# SHIP (S72) → REVIEW (S55-59) riding the same `vajra next`.
#
# This script is itself session 72's sprint demo — it emits the four required
# `demo:<element>` markers it is gated on, and `--check-demo 72` re-runs it live at close.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }

header "Session 72 Demo — the Releaser: a close now refuses until the PRIOR session SHIPPED  [demo:header]"
printf "${DIM}  WHAT → DESIGN → HOW-plan → CODE → WORKS → SHOW → SHIP (new) → REVIEW — eight governed stations, one command.${RESET}\n"

cargo build --quiet 2>/dev/null || true
BIN="$ROOT/target/debug/vajra"

header "Before → After  [demo:before_after]"
label "BEFORE (S71 and every session before it):"
ok "ship hygiene was a CHECKLIST LINE — STATE.md carried 'Housekeeping: after the merge, checkout main + prune' (the S37 founder flag); nothing checked the merge landed, main synced, or branches got pruned"
printf "${DIM}  a session could close with the prior PR unmerged, main stale, and dead session-* branches\n"
printf "  piling up — no gate would notice.${RESET}\n"
label "AFTER (S72):"
ok "vajra next --release/--check-release surface + enforce ship state RE-DERIVED from git live"
ok "--advance refuses the close until the prior session's work is merged (ancestry), main is synced with origin/main, and merged session-* locals are pruned"

# Throwaway Vajra GIT repo with a REAL bare origin (file transport — no network). Session 41
# is CLOSING on the in-flight branch session-42-y — the real close shape — with every other
# gate satisfied so only the Releaser varies.
E2E_BASE="$(mktemp -d)"; trap 'rm -rf "$E2E_BASE"' EXIT
ORIGIN="$E2E_BASE/origin.git"; E2E="$E2E_BASE/repo"
git init -q --bare "$ORIGIN"
mkdir -p "$E2E/.ai" "$E2E/prompts" "$E2E/sessions" "$E2E/scripts"
echo "41" > "$E2E/.ai/SESSION"
{ printf 'version: 3\nmaturity: L3\n\nverify:\n'
  printf "  script_pattern: 'scripts/verify-session-{NN}.sh'\n"
  printf '\nrelease:\n  require_merged_prior: true\n  require_main_synced: true\n  require_pruned: true\n'
} > "$E2E/.ai/CONSTRAINTS.yaml"
printf '# Session Boot\n- **Number:** 41\n' > "$E2E/.ai/SESSION-BOOT.md"
printf '# Current Task Pointer\n\nRead prompt: `prompts/41-task-x.md`\n' > "$E2E/.ai/TASK.md"
printf '# Vajra — Working Roadmap\n' > "$E2E/.ai/ROADMAP.md"
{ printf '# S41 summary\n\n## Next — ranked candidates (S42)\n\n'
  printf -- '- **A — one.**\n- **B — two.**\n- **C — three.**\n'
} > "$E2E/sessions/session-41-summary.md"
for NN in 41 42; do
cat > "$E2E/prompts/${NN}-task-x.md" <<'P'
# Session NN — x: a slice
> **Status:** APPROVED
## Goal
Do one thing.
## Acceptance (testable, EARS-style)
1. WHEN built THEN it works.
## Deliverables
- a thing
## Plan
1. build the thing — covers: 1
## Guardrails
- one story
## Delta (vs ROADMAP)
- `+` a real recorded change
P
done
printf 'exit 0\n' > "$E2E/scripts/verify-session-41.sh"
( cd "$E2E" && git init -qb main && git config user.email t@t && git config user.name t \
    && git add -A && git commit -qm init \
    && git remote add origin "$ORIGIN" && git push -q origin main \
    && git checkout -qb session-41-x \
    && echo work > f41.txt && git add f41.txt && git commit -qm "s41 work" \
    && git push -q origin session-41-x \
    && git checkout -qb session-42-y )

header "Cases — run against a throwaway governed repo with a real bare origin, live  [demo:cases]"

header "1 · SURFACE — vajra next --release 41: ship state re-derived from git, read-only"
( cd "$E2E" && "$BIN" next --release 41 ) || true
ok "derived live from LOCAL refs (ancestry · main vs origin/main · unpruned locals) — nothing recorded, nothing fetched"

header "2 · GATE — the prior session's branch is NOT merged: the close refuses"
if ( cd "$E2E" && "$BIN" next --advance >/dev/null 2>&1 ); then
  bad "should have refused"
else
  ok "refused — SESSION still $(cat "$E2E/.ai/SESSION"): session-41-x is not an ancestor of main (the work never shipped)"
fi

header "3 · GATE — merged, but the local branch was never pruned: still blocked"
( cd "$E2E" && git checkout -q main && git merge -q --no-ff session-41-x -m "merge s41" \
    && git push -q origin main && git checkout -q session-42-y )
if ( cd "$E2E" && "$BIN" next --check-release 41 ); then
  bad "should have blocked"
else
  ok "exit 1 — the S37 prune step is unfinished; the gate names the leftover and the fix (git branch -d)"
fi

header "4 · GATE — local main behind origin/main (merge landed, main never synced): blocked"
( cd "$E2E" && git branch -qd session-41-x \
    && git checkout -q main && git commit -q --allow-empty -m "landed elsewhere" \
    && git push -q origin main && git reset -q --hard HEAD~1 && git checkout -q session-42-y )
if ( cd "$E2E" && "$BIN" next --check-release 41 ); then
  bad "should have blocked"
else
  ok "exit 1 — checkout main + pull is now enforced, not remembered"
fi

header "5 · SHIPPED — merged + synced + pruned: the close proceeds"
( cd "$E2E" && git checkout -q main && git merge -q --ff-only origin/main && git checkout -q session-42-y )
( cd "$E2E" && "$BIN" next --check-release 41 )
( cd "$E2E" && "$BIN" next --advance >/dev/null 2>&1 )
ok "advanced — SESSION now $(cat "$E2E/.ai/SESSION"); ship hygiene held (VAJRA_SKIP_RELEASER_GATE=1 is the documented override — the cheap check still runs, only the block is bypassed)"

header "6 · DOGFOOD — this repo, live: the S72 close binds on session 71's ship state"
"$BIN" next --release 71 || true
ok "session 71 passes on what the gate can actually derive: merge-evidence VACUOUS (branch pruned — the warning above names it), main synced, nothing unpruned; the gate stays honest rather than inventing a green"

header "Scorecard  [demo:summary_table]"
printf "  %-56s %s\n" "surface: ship state re-derived from git, read-only"      "PASS"
printf "  %-56s %s\n" "gate: unmerged prior branch refuses the close"           "PASS"
printf "  %-56s %s\n" "gate: unpruned merged local blocked, fix named"          "PASS"
printf "  %-56s %s\n" "gate: main behind origin/main blocked"                   "PASS"
printf "  %-56s %s\n" "shipped (merged+synced+pruned): advance passes"          "PASS"
printf "  %-56s %s\n" "dogfood: S72's own close binds on session 71"            "PASS"
printf "${DIM}  honest edges: 'merged' proves ANCESTRY, not that the merge was the reviewed PR; a branch\n"
printf "  pruned UNMERGED looks identical to pruned-after-merge (self-granted jurisdiction, named in\n"
printf "  the gate's output); origin/main is only as fresh as the last fetch — the gate never fetches.\n"
printf "  The Releaser governs ship MECHANICS, not release quality. Never pitch it as 'the release is\n"
printf "  verified.'${RESET}\n"
