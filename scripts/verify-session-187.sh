#!/usr/bin/env bash
# Session 187 verify — the guard says how to get past a joined read (fix C), and the S190 leftovers:
# N4 (the step list names a missing approval), F97 (sync adds missing ground-truth audits/questions),
# verify-133 re-pointed, N6 (no hand-typed ROADMAP header), N7 (old checkouts in one folder) and N5
# (`--dogfood-age` says it sees this repo only — named, not closed). N2 moved to S188 (founder).
# Every check RUNS the real thing — the real binary, the real guard, a real `vajra init` project — and
# each one also runs at the commit S187 started from (0071dca, pinned), where it must go red for the
# reason it names (S122). Nothing greps source.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(cd "$(mktemp -d)" && pwd -P)"
trap 'vajra_old_checkout_remove "${OLD_WT:-}"; rm -rf "$T"' EXIT
OLD_SHA=0071dca
VAJRA="$ROOT/target/release/vajra"
cargo build --release -q || { echo "FAIL: cargo build --release"; exit 1; }
. "$ROOT/scripts/lib-old-checkout.sh"
OLD_WT=$(vajra_old_checkout "$OLD_SHA") || { echo "FAIL: worktree at $OLD_SHA"; exit 1; }
(cd "$OLD_WT" && CARGO_TARGET_DIR="$ROOT/target/s187-old" cargo build --release -q) || { echo "FAIL: build at $OLD_SHA"; exit 1; }
OLD_VAJRA="$ROOT/target/s187-old/release/vajra"

# A fresh `vajra init` project (session_rules_from: 1 is scaffolded).
project() {
  mkdir -p "$1" && (cd "$1" && git init -q && "$VAJRA" init >/dev/null 2>&1 </dev/null)
}

# --- 1 (AC1): the 2026-10-04 live false block still blocks, and now says how to get past it ----------
git show "$OLD_SHA:scripts/hook-approvals-guard.sh" > "$T/old-guard.sh"
live() { # guard → "exit|stderr"
  local GP="$T/gp"; mkdir -p "$GP/.ai"; echo "maturity: L2" > "$GP/.ai/CONSTRAINTS.yaml"
  local cmd='git checkout -b X main && cd ~/playground/rudra && ls .ai/approvals/'
  jq -n --arg c "$cmd" --arg d "$GP" '{tool_name:"Bash",tool_input:{command:$c},cwd:$d}' \
    | CLAUDE_PROJECT_DIR="$GP" bash "$1" 2>"$T/live.err" >/dev/null; echo "$?"
}
rn=$(live scripts/hook-approvals-guard.sh); en=$(cat "$T/live.err")
ro=$(live "$T/old-guard.sh"); eo=$(cat "$T/live.err")
if [ "$rn" = 2 ] && grep -q 'as its own command' <<<"$en" && grep -q 'git commit -F' <<<"$en" \
   && [ "$ro" = 2 ] && ! grep -q 'as its own command' <<<"$eo"; then
  ok "AC1 the live joined read still blocks (exit 2) and says 'run the read as its own command'; at $OLD_SHA it blocked without saying how"
else bad "AC1 live case: new exit $rn, old exit $ro"; fi
if cargo test -q --test approvals_guard s187_blocks_exactly_what_0071dca_blocked > "$T/ac1.out" 2>&1; then
  ok "AC1 every guard-corpus command exits the same at $OLD_SHA and now (only the reason changed)"
else bad "AC1 corpus old-vs-new"; tail -5 "$T/ac1.out"; fi

# --- 2 (AC3, N4): the step list names a missing approval record --------------------------------------
P="$T/steps"; project "$P" || bad "AC3 fixture"
echo 2 > "$P/.ai/SESSION"
sn=$(cd "$P" && "$VAJRA" next --steps 2>&1); so=$(cd "$P" && "$OLD_VAJRA" next --steps 2>&1)
# The list prints a step's "how" only for the NEXT step; `vajra approve NN` in the how is the unit
# test's (`the_list_names_a_missing_approval_record`), run in the lib suite below.
if grep -q '✗ the founder has approved this session' <<<"$sn" \
   && ! grep -q 'founder has approved this session' <<<"$so"; then
  ok "AC3 no approval record: '✗ the founder has approved this session'; at $OLD_SHA no such line"
else bad "AC3 missing record line"; grep -n 'approv' <<<"$sn" | head -3; fi
N=$(grep -oE 'what is left in session [0-9]+' <<<"$sn" | head -1 | grep -oE '[0-9]+$'); N=$((10#${N:-0}))
mkdir -p "$P/.ai/approvals"
printf '{"session": %s, "method": "approve-command", "at_unix": 1}\n' "$N" > "$P/.ai/approvals/session-$(printf '%02d' "$N").json"
sn=$(cd "$P" && "$VAJRA" next --steps 2>&1)
grep -q '✓ the founder has approved this session' <<<"$sn" \
  && ok "AC3 with the record for session $N the step reads ✓" || bad "AC3 record present, step not ✓"

# --- 3 (AC4, F97): sync adds a project's missing ground-truth audits and questions, nothing else -------
P="$T/f97"; project "$P" || bad "AC4 fixture"
C="$P/.ai/CONSTRAINTS.yaml"
python3 - "$C" <<'PY'
import re, sys
p = sys.argv[1]; s = open(p).read()
s = s.replace('delivery_progress, ', '', 1)
s = re.sub(r'  delivery_progress_questions:\n(    .*\n)+', '', s)
open(p, 'w').write(s)
PY
cp "$C" "$T/before.yaml"
(cd "$P" && "$OLD_VAJRA" init --sync-fleet >/dev/null 2>&1)
if cmp -s "$C" "$T/before.yaml"; then oldsame=1; else oldsame=0; cp "$T/before.yaml" "$C"; fi
dry=$(cd "$P" && "$VAJRA" init --sync-fleet --dry-run 2>&1)
cmp -s "$C" "$T/before.yaml" && grep -q 'would   add ground-truth audits to .ai/CONSTRAINTS.yaml: delivery_progress' <<<"$dry" \
  && ok "AC4 --dry-run names delivery_progress and writes nothing" || bad "AC4 dry run"
out=$(cd "$P" && "$VAJRA" init --sync-fleet 2>&1)
undo=$(python3 - "$C" <<'PY'
import re, sys
s = open(sys.argv[1]).read()
s = re.sub(r'  delivery_progress_questions:\n(    .*\n)+', '', s)
s = s.replace(', delivery_progress', '', 1)
sys.stdout.write(s)
PY
)
if grep -q 'add     ground-truth audits to .ai/CONSTRAINTS.yaml: delivery_progress' <<<"$out" \
   && grep -q 'add     ground-truth question blocks to .ai/CONSTRAINTS.yaml: delivery_progress_questions' <<<"$out" \
   && grep -q 'required_audits: \[vision_alignment, roadmap_alignment, delivery_progress, state_drift' "$C" \
   && [ "$undo" = "$(cat "$T/before.yaml")" ] && [ "$oldsame" = 1 ]; then
  ok "AC4 sync adds delivery_progress after roadmap_alignment + its question block, says so; removing them gives the original byte for byte; at $OLD_SHA sync left the file as it was"
else bad "AC4 add (old left it unchanged: $oldsame)"; fi
cp "$C" "$T/after.yaml"
out=$(cd "$P" && "$VAJRA" init --sync-fleet 2>&1)
cmp -s "$C" "$T/after.yaml" && grep -q 'every ground-truth audit and question block present' <<<"$out" \
  && ok "AC4 a second run adds nothing" || bad "AC4 second run"

# --- 4 (AC5): verify-133 green, same 15 checks; the 0071dca script is red against today's code --------
bash scripts/verify-session-133.sh > "$T/v133.out" 2>&1; rn=$?
git show "$OLD_SHA:scripts/verify-session-133.sh" > "$T/v133-old.sh"
CLAUDE_PROJECT_DIR="$ROOT" bash "$T/v133-old.sh" > "$T/v133-old.out" 2>&1; ro=$?
cn=$(grep -cE '^[a-z0-9-]+ +(exec|behav|struct) +(PASS|FAIL)' "$T/v133.out")
co=$(grep -cE '^[a-z0-9-]+ +(exec|behav|struct) +(PASS|FAIL)' "$T/v133-old.out")
if [ "$rn" = 0 ] && [ "$cn" = 15 ] && [ "$co" = 15 ] && [ "$ro" != 0 ] \
   && grep -qE '^k-of-8-unchanged-and-not-a-ninth-station +exec +FAIL' "$T/v133-old.out"; then
  ok "AC5 verify-133 exits 0 with 15 checks; its 0071dca text (15 checks) fails today's code, incl. k-of-8"
else bad "AC5 verify-133: new exit $rn ($cn checks), old exit $ro ($co checks)"; fi

# --- 5 (AC6, N6): no hand-typed session number in ROADMAP's header ------------------------------------
header() { awk '/^## /{exit} {print}'; }
hn=$(header < .ai/ROADMAP.md); ho=$(git show "$OLD_SHA:.ai/ROADMAP.md" | header)
if ! grep -qE 'Session [0-9]+' <<<"$hn" && grep -q 'vajra next --steps' <<<"$hn" && grep -q 'Session 166' <<<"$ho"; then
  ok "AC6 ROADMAP's header (before its first section) names no session and points at \`vajra next --steps\`; at $OLD_SHA it said 'Session 166'"
else bad "AC6 ROADMAP header"; fi

# --- 6 (AC7, N7 + N5) ---------------------------------------------------------------------------------
# N7: a run that is killed leaves its checkout in the one known folder; the next run clears it.
export VAJRA_OLD_CHECKOUTS="$T/oc"
bash -c '. scripts/lib-old-checkout.sh; vajra_old_checkout '"$OLD_SHA"' >/dev/null; kill -9 $$' >/dev/null 2>&1
left=$(ls "$VAJRA_OLD_CHECKOUTS" 2>/dev/null | wc -l | tr -d ' ')
bash -c '. scripts/lib-old-checkout.sh; p=$(vajra_old_checkout '"$OLD_SHA"'); vajra_old_checkout_remove "$p"' 2>"$T/sweep.err"
after=$(ls "$VAJRA_OLD_CHECKOUTS" 2>/dev/null | wc -l | tr -d ' ')
reg=$(git worktree list | grep -c "$VAJRA_OLD_CHECKOUTS" || true)
unset VAJRA_OLD_CHECKOUTS
if [ "$left" = 1 ] && [ "$after" = 0 ] && [ "$reg" = 0 ] && grep -q 'cleared a leftover' "$T/sweep.err" \
   && ! git cat-file -e "$OLD_SHA:scripts/lib-old-checkout.sh" 2>/dev/null; then
  ok "AC7 N7 a killed run's checkout is left in the one folder, and the next run clears it (and its worktree entry); at $OLD_SHA no shared folder existed"
else bad "AC7 N7: left $left, after $after, registered $reg"; fi
dn=$("$VAJRA" next --dogfood-age 2>&1); do_=$("$OLD_VAJRA" next --dogfood-age 2>&1)
grep -q 'THIS repo only' <<<"$dn" && ! grep -q 'THIS repo only' <<<"$do_" \
  && ok "AC7 N5 --dogfood-age says it counts THIS repo only (named, not closed); at $OLD_SHA it did not say" \
  || bad "AC7 N5 dogfood-age scope"

# --- 7: the whole lib suite and the guard suite are green ---------------------------------------------
cargo test -q --lib > "$T/lib.out" 2>&1 && ok "cargo test --lib green" || { bad "cargo test --lib"; tail -5 "$T/lib.out"; }
cargo test -q --test approvals_guard > "$T/g.out" 2>&1 && ok "cargo test --test approvals_guard green" || bad "approvals_guard tests"

echo; echo "=== S187 verify: $PASS passed, $FAIL failed ==="
[ "$FAIL" = 0 ]
