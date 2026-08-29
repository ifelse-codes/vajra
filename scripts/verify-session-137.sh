#!/usr/bin/env bash
# Verify — Session 137: PAID DOGFOOD. Lock chitra's `scatter` chart to the reference panel
# language via a real `vajra claude` run, and prove what the governance did on live outside
# BUILD work (S134 was read-only; this is the first governed BUILD). What this suite proves
# beyond "the chart changed":
#   1. chitra's locked scatter really renders the panel language — dashed frame, eyebrow,
#      +/│ guide, and the `n · x-range · y-range · peak` footer (EXEC — renders the product);
#   2. the ONE accent hue is spent EXACTLY once on BOTH render paths, every other point on the
#      documented grey ramp, zero rainbow leak — the S134 RGB method (EXEC);
#   3. the footer reports NO Pearson r coefficient (a dishonest default was rejected) (EXEC);
#   4. the locked CONTRACT holds on cases the default render can't show — accent follows the
#      PRIMARY series' max-y (not the global max), `highlight` overrides it, and empty/single
#      data render honestly with no Infinity/NaN (EXEC — re-derives the test assertions);
#   4b. chitra's OWN committed 14 scatter tests RUN LIVE against the locked branch worktree — the
#      prompt's "asserted by chitra's OWN tests" is EXECUTED at close, not stood in for (S129
#      registered-not-run; added after the S137 fidelity-reviewer named the dropped check);
#   5. chitra's README carries a real `LOCKED: scatter chart — session 17` contract (STRUCT);
#   6. the previews are DERIVED and CURRENT — `gen:charts --check` is clean, so no hand-edit (EXEC);
#   7. the scatter branch carries exactly the three S17 commits, touching only scatter files (STRUCT);
#   8. chitra is UNDISTURBED where this session did not intend to touch it — session-16 HEAD and
#      working-tree content byte-identical to the recorded baseline, the older WIP stash intact,
#      main untouched, and only the intended session-17 branch added (BEHAV, against the baseline);
#   9. the receipt discipline holds — the RAW subagent token total is recorded (never a
#      new-tokens-only figure), and the authoritative-$ line is present (honest null allowed) (STRUCT).
#
# The LOCKED scatter lives on chitra's `session-17-scatter-lock` branch, but chitra rests on its
# in-flight `session-16` branch (undisturbed). So the EXEC checks render the locked code from a
# throwaway `git worktree` of the scatter branch — chitra's core is ZERO-DEPENDENCY, so main's
# `tsx` binary transpiles and runs it with no node_modules in the worktree, and session-16's
# working tree is never touched.
#
# S69: every machine-local check FAILS when its input is absent. It never skips. A check that cannot
# evaluate is indistinguishable from a deleted check, so absence is RED, never a quiet green.
#
# CHECK CLASSES — EXEC (runs the product, asserts on real output) · STRUCT grep (asserts an
# artifact's shape) · BEHAV (asserts a git/filesystem fact against a recorded baseline).
set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="137"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

CHITRA="${CHITRA_DIR:-/Users/suman/playground/chitra}"
BASELINE="$ROOT/sessions/session-137-chitra-baseline.txt"
SUMMARY="$ROOT/sessions/session-137-summary.md"
# shellcheck disable=SC1090
[ -f "$BASELINE" ] && . "$BASELINE"

# pnpm exposes tsx in each package's .bin, not the workspace root — pick the first that exists.
TSX=""
for c in "$CHITRA/artifacts/chitra-docs/node_modules/.bin/tsx" \
         "$CHITRA/packages/core/node_modules/.bin/tsx" \
         "$CHITRA/node_modules/.pnpm/node_modules/.bin/tsx"; do
  [ -x "$c" ] && { TSX="$c"; break; }
done
WT=""   # scatter-branch worktree, set up ONCE at top level below, removed at exit.
cleanup() { [ -n "$WT" ] && git -C "$CHITRA" worktree remove --force "$WT" >/dev/null 2>&1; git -C "$CHITRA" worktree prune 2>/dev/null || true; }
trap cleanup EXIT

# A branch can be checked out in only ONE worktree, so this MUST be a single top-level setup —
# creating it inside per-check subshells leaks a registration and every later add fails (the
# bug this comment guards against). Idempotent: prune + drop any stale checkout of the branch first.
setup_worktree_once() {
  [ -d "$CHITRA" ] && [ -n "$TSX" ] && [ -x "$TSX" ] || return 0
  git -C "$CHITRA" rev-parse --verify "$SCATTER_BRANCH" >/dev/null 2>&1 || return 0
  git -C "$CHITRA" worktree prune 2>/dev/null || true
  WT="$(mktemp -d)/s17"
  git -C "$CHITRA" worktree add -q "$WT" "$SCATTER_BRANCH" 2>/dev/null || { WT=""; return 0; }
  # Symlink the workspace node_modules so vitest resolves in the worktree (core is zero-dep for
  # rendering, but vitest itself is a devDep). Rendering via tsx needs neither.
  ln -s "$CHITRA/node_modules" "$WT/node_modules" 2>/dev/null || true
  ln -s "$CHITRA/packages/core/node_modules" "$WT/packages/core/node_modules" 2>/dev/null || true
}

# Run a TS snippet (on stdin) against the LOCKED scatter in the worktree. Emits its stdout.
run_locked() { # snippet on stdin
  [ -n "$WT" ] || { echo "FAIL: scatter-branch worktree unavailable (chitra/tsx/branch absent)"; return 1; }
  local f="$WT/packages/core/_v137.mts"; cat > "$f"; "$TSX" "$f" 2>/dev/null; local rc=$?; rm -f "$f"; return $rc
}

PASS=0; FAIL=0; RESULTS=()
EXEC_N=0; STRUCT_N=0; BEHAV_N=0
run_check() {
  local NAME="$1"; local CLASS="$2"; shift 2
  local LOG="$ARTIFACTS/${NAME}.log"
  case "$CLASS" in
    exec) EXEC_N=$((EXEC_N+1)) ;; struct) STRUCT_N=$((STRUCT_N+1)) ;; behav) BEHAV_N=$((BEHAV_N+1)) ;;
    *) echo "verify bug: unknown class '$CLASS' for $NAME"; exit 2 ;;
  esac
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-52s %-7s %s' "$NAME" "$CLASS" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-52s %-7s %s' "$NAME" "$CLASS" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# ── 1 · scatter renders the panel language ───────────────────────────────────────────────────
scatter_panel_language() {
  local out; out="$(cat <<'EOF' | run_locked
import { scatter } from "./src/index.ts";
const d=[{x:1,y:2},{x:2,y:4},{x:3,y:3},{x:4,y:7},{x:5,y:5},{x:6,y:9},{x:7,y:6},{x:10,y:12}];
process.stdout.write(scatter({data:d,title:"Scatter Plot",width:50,height:12}).toPlain());
EOF
)" || { echo "$out"; return 1; }
  echo "$out"
  echo "$out" | head -1 | grep -q '^┌╌'                                   || { echo "FAIL: no dashed frame top"; return 1; }
  echo "$out" | tail -1 | grep -q '^└╌'                                   || { echo "FAIL: no dashed frame bottom"; return 1; }
  echo "$out" | grep -q 'CORRELATION'                                     || { echo "FAIL: no eyebrow"; return 1; }
  echo "$out" | grep -qE 'n 8 · x 1\.\.10 · y 2\.\.12 · peak \(10, 12\)'  || { echo "FAIL: footer wrong"; return 1; }
  echo "$out" | grep -qE '[0-9]\+'                                        || { echo "FAIL: no + top y-guide"; return 1; }
  echo "PASS: panel language present"; return 0
}

# ── 2 · accent spent EXACTLY once, both paths, grey ramp elsewhere (S134 RGB method) ─────────
accent_spent_once() {
  cat <<'EOF' | run_locked
import { scatter } from "./src/index.ts";
import { resolveTheme, GREY_TONES } from "./src/themes/index.ts";
const d=[{x:1,y:2},{x:2,y:4},{x:3,y:3},{x:4,y:7},{x:5,y:5},{x:6,y:9},{x:7,y:6},{x:10,y:12}];
const acc=resolveTheme(undefined).accent!;
const GLYPH=/[⠁-⣿●○◆◇▲△]/;
let bad=false;
for(const rnd of ["braille","blocks"] as const){
  const out=scatter({data:d,title:"S",width:50,height:12,renderer:rnd}).toString();
  let a=0,g=0,o=0;
  for(const m of out.matchAll(/(\x1b\[[0-9;]*m)([^\x1b]+)(\x1b\[0m)/g))
    for(const ch of m[2]!){ if(!GLYPH.test(ch))continue;
      if(m[1]===acc)a++; else if(GREY_TONES.includes(m[1]!))g++; else o++; }
  console.log(`${rnd}: accent=${a} grey=${g} other=${o}`);
  if(a!==1||o!==0||g<1) bad=true;
}
if(bad){console.error("accent not spent exactly once / rainbow leak");process.exit(1);}
EOF
}

# ── 3 · footer reports NO Pearson r coefficient ──────────────────────────────────────────────
no_pearson_r() {
  local out; out="$(cat <<'EOF' | run_locked
import { scatter } from "./src/index.ts";
const d=[{x:1,y:2},{x:2,y:4},{x:3,y:3},{x:4,y:7},{x:5,y:5},{x:6,y:9},{x:7,y:6},{x:10,y:12}];
process.stdout.write(scatter({data:d,title:"S",width:50,height:12}).toPlain());
EOF
)" || return 1
  echo "$out" | tr 'A-Z' 'a-z' | grep -qE '\br *= *-?[0-9.]|pearson|coefficient' \
    && { echo "FAIL: a correlation coefficient leaked into the footer"; return 1; }
  echo "PASS: no Pearson r in the default footer"; return 0
}

# ── 4b · chitra's OWN committed scatter tests RUN LIVE against the locked branch (S129/S137
#         fidelity-reviewer: a gate that names 14 tests but never runs them is registered-not-run) ─
chitra_scatter_tests_live() {
  [ -n "$WT" ] || { echo "FAIL: scatter-branch worktree unavailable"; return 1; }
  local vitest=""
  for c in "$CHITRA/packages/core/node_modules/.bin/vitest" "$CHITRA/node_modules/.pnpm/node_modules/.bin/vitest"; do
    [ -x "$c" ] && { vitest="$c"; break; }
  done
  [ -n "$vitest" ] || { echo "FAIL: vitest binary not found"; return 1; }
  [ -f "$WT/packages/core/tests/scatter.test.ts" ] || { echo "FAIL: scatter.test.ts absent on the locked branch"; return 1; }
  ( cd "$WT/packages/core" && "$vitest" run tests/scatter.test.ts 2>&1 ) | grep -E 'Tests +[0-9]+ passed'
}

# ── 4 · the locked contract holds on cases the default render can't show ─────────────────────
contract_edge_cases() {
  cat <<'EOF' | run_locked
import { scatter } from "./src/index.ts";
const P=(o:any)=>scatter(o).toPlain();
let bad=false; const must=(c:boolean,m:string)=>{ if(!c){console.error("FAIL:",m);bad=true;} };
// accent follows PRIMARY series max-y (2,5), not the global max (9,20) in series 1
const multi=[[{x:1,y:1},{x:2,y:5}],[{x:9,y:20},{x:8,y:3}]];
must(/peak \(2, 5\)/.test(P({data:multi})),"accent must follow primary-series max-y, not global max");
// highlight override picks index 0 = (1,2)
const d=[{x:1,y:2},{x:2,y:4},{x:10,y:12}];
must(/peak \(1, 2\)/.test(P({data:d,highlight:0})),"highlight override ignored");
// empty renders n 0, no Infinity/NaN
const e=P({data:[]}); must(/n 0/.test(e)&&!/Infinity|NaN/.test(e),"empty data not safe");
// single point honest, no NaN
const s=P({data:[{x:3,y:5}]}); must(/n 1 · x 3\.\.3 · y 5\.\.5 · peak \(3, 5\)/.test(s)&&!/NaN/.test(s),"single point not honest");
if(bad)process.exit(1); else console.log("PASS: locked contract holds on all edge cases");
EOF
}

# ── 5 · README carries the LOCKED: scatter contract ──────────────────────────────────────────
readme_locked_block() {
  # The locked README lives on the scatter branch; chitra rests on session-16.
  local readme; readme="$(git -C "$CHITRA" show "$SCATTER_BRANCH:packages/core/README.md" 2>/dev/null)" \
    || { echo "FAIL: cannot read README on $SCATTER_BRANCH"; return 1; }
  echo "$readme" | grep -q 'LOCKED: scatter chart — session 17 design' \
    || { echo "FAIL: no LOCKED: scatter block"; return 1; }
  echo "$readme" | grep -q 'peak (<x>, <y>)' \
    || { echo "FAIL: LOCKED block missing the footer contract"; return 1; }
  echo "PASS: README LOCKED: scatter contract present"; return 0
}

# ── 6 · previews are DERIVED and CURRENT (no hand-edit), in the locked branch ────────────────
previews_current() {
  [ -n "$WT" ] || { echo "FAIL: scatter-branch worktree unavailable"; return 1; }
  ( cd "$WT/artifacts/chitra-docs" && "$TSX" scripts/generate-charts.ts --check 2>&1 ) | grep -E 'up to date' | head -1 \
    || { echo "FAIL: gen:charts --check not clean — a preview was hand-edited or stale"; return 1; }
}

# ── 7 · scatter branch = exactly the 3 S17 commits, scatter files only ───────────────────────
scatter_branch_commits() {
  local n; n=$(git -C "$CHITRA" log --oneline "$SCATTER_BRANCH" | grep -c ' S17:')
  [ "$n" -eq 3 ] || { echo "FAIL: expected 3 S17 commits, found $n"; return 1; }
  local files; files=$(git -C "$CHITRA" diff --name-only "${SESSION16_HEAD}..${SCATTER_BRANCH}")
  echo "$files"
  echo "$files" | grep -qvE 'scatter\.ts|scatter\.test\.ts|types\.ts|README\.md|ansi-charts\.json|charts\.ts' \
    && { echo "FAIL: a non-scatter file changed on the scatter branch"; return 1; }
  echo "PASS: 3 S17 commits, scatter files only"; return 0
}

# ── 8 · chitra UNDISTURBED (S134 four ways, against the recorded baseline) ────────────────────
chitra_undisturbed() {
  local rc=0
  local head; head=$(git -C "$CHITRA" rev-parse "$SESSION16_BRANCH" 2>/dev/null)
  [ "$head" = "$SESSION16_HEAD" ] || { echo "FAIL: session-16 HEAD moved ($head)"; rc=1; }
  # The "four ways" proof is only COMPLETE when session-16 is the resting branch with its work
  # restored — that is the intended end state. If chitra is elsewhere, the tree-content assertion
  # cannot fire and the proof would silently degrade to three ways (qa-specialist S137 rec 3), so
  # that is a FAIL here, not a quiet pass.
  local cur; cur=$(git -C "$CHITRA" branch --show-current)
  if [ "$cur" = "$SESSION16_BRANCH" ]; then
    local wsha; wsha=$(git -C "$CHITRA" diff | git hash-object --stdin)
    [ "$wsha" = "$SESSION16_TREE_SHA" ] || { echo "FAIL: session-16 tree changed ($wsha)"; rc=1; }
    echo "tree-content check FIRED (chitra on $SESSION16_BRANCH): $wsha"
  else
    echo "FAIL: chitra is on '$cur', not $SESSION16_BRANCH — the tree-content proof cannot fire"; rc=1
  fi
  git -C "$CHITRA" stash list | grep -qF "$OLDER_STASH_MARKER" || { echo "FAIL: the older WIP stash vanished"; rc=1; }
  [ "$(git -C "$CHITRA" rev-parse main)" = "$MAIN_HEAD" ] || { echo "FAIL: chitra main moved"; rc=1; }
  git -C "$CHITRA" rev-parse --verify "$SCATTER_BRANCH" >/dev/null 2>&1 || { echo "FAIL: scatter branch missing"; rc=1; }
  [ $rc -eq 0 ] && echo "PASS: chitra undisturbed (HEAD, tree, stash, main), only session-17 added"
  return $rc
}

# ── 9 · receipt discipline — RAW subagent tokens + authoritative-$ line recorded ─────────────
receipt_recorded() {
  [ -f "$SUMMARY" ] || { echo "FAIL: summary absent"; return 1; }
  grep -qiE 'RAW subagent' "$SUMMARY"             || { echo "FAIL: no RAW subagent token total"; return 1; }
  grep -qE '486,?695' "$SUMMARY"                  || { echo "FAIL: the recorded RAW total is missing/changed"; return 1; }
  grep -qiE 'authoritative .*(null|\$)' "$SUMMARY" || { echo "FAIL: no authoritative-\$ line"; return 1; }
  echo "PASS: receipt discipline recorded (RAW tokens + authoritative-\$)"; return 0
}

setup_worktree_once   # single top-level worktree of the locked scatter branch (see comment above)

run_check "scatter-renders-panel-language"        exec   scatter_panel_language
run_check "accent-spent-exactly-once-both-paths"  exec   accent_spent_once
run_check "footer-has-no-pearson-r"               exec   no_pearson_r
run_check "locked-contract-holds-edge-cases"      exec   contract_edge_cases
run_check "chitra-own-scatter-tests-run-live"     exec   chitra_scatter_tests_live
run_check "readme-locked-scatter-contract"        struct readme_locked_block
run_check "previews-derived-and-current"          exec   previews_current
run_check "scatter-branch-3-commits-scatter-only" struct scatter_branch_commits
run_check "chitra-undisturbed-four-ways"          behav  chitra_undisturbed
run_check "receipt-raw-tokens-and-authoritative"  struct receipt_recorded

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "════════════════════════════════════════════════════════════════════"
printf '%s\n' "${RESULTS[@]}"
echo "────────────────────────────────────────────────────────────────────"
echo "classes: EXEC=${EXEC_N} STRUCT=${STRUCT_N} BEHAV=${BEHAV_N}"
echo "────────────────────────────────────────────────────────────────────"
echo "session 137 verify: ${PASS} passed, ${FAIL} failed"
[ "$FAIL" -eq 0 ] && echo "RESULT: PASS" || echo "RESULT: FAIL"
[ "$FAIL" -eq 0 ]
