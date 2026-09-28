#!/usr/bin/env bash
# Session 179 verify — F89 (`vajra <cmd> --help` ran the command; `init --help` wrote a scaffold),
# F90 (`init` ignored words it did not know), F93 (a project's ground truth asked about the tool,
# not the project). Every check RUNS the real binary in a fresh temp repo: OLD (built from the
# pinned commit this session started from — 224b349, never `main`: after the merge main IS new)
# vs NEW (this checkout). Nothing here greps source for a claim.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0; SKIP=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(mktemp -d)"; trap 'rm -rf "$T"; git worktree remove --force "$T.old" >/dev/null 2>&1' EXIT
PRE_FIX=224b349
RUDRA="${RUDRA:-/Users/suman/playground/rudra}"

# --- binaries -----------------------------------------------------------------------------------
cargo build --release -q 2>/dev/null || { bad "new build failed"; exit 1; }
NEW="$ROOT/target/release/vajra"
OLD="${OLD_VAJRA:-}"
if [ -z "$OLD" ]; then
  git worktree add -q --detach "$T.old" "$PRE_FIX" 2>/dev/null || { bad "cannot check out $PRE_FIX"; exit 1; }
  ( cd "$T.old" && CARGO_TARGET_DIR="$ROOT/target/s179-old" cargo build --release -q 2>/dev/null ) \
    || { bad "old build ($PRE_FIX) failed"; exit 1; }
  OLD="$ROOT/target/s179-old/release/vajra"
fi

# repo → a fresh empty git repo with one commit; changes DIR → what a command wrote there
repo() { local d; d="$(mktemp -d "$T/r.XXXX")"; ( cd "$d" && git init -q && git -c user.name=t -c user.email=t@t commit -q --allow-empty -m x ); echo "$d"; }
changes() { ( cd "$1" && git status --porcelain | wc -l | tr -d ' ' ); }
# run BIN DIR ARGS... → stderr+stdout in $OUT, exit in $RC (stdin closed: init's prompts get EOF)
run() { local b="$1" d="$2"; shift 2; OUT="$(cd "$d" && "$b" "$@" </dev/null 2>&1)"; RC=$?; }

# --- AC1 (F89): every Vajra subcommand's --help / -h prints its help and writes nothing -----------
for cmd in init check next estimate hook meter; do
  for flag in --help -h; do
    d="$(repo)"; run "$NEW" "$d" "$cmd" "$flag"; n_rc=$RC; n_out="$OUT"; n_ch="$(changes "$d")"
    d2="$(repo)"; run "$OLD" "$d2" "$cmd" "$flag"; o_rc=$RC; o_ch="$(changes "$d2")"
    if [ "$n_rc" = 0 ] && [ "$n_ch" = 0 ] && grep -q "^vajra $cmd — " <<<"$n_out" && grep -q "usage:" <<<"$n_out"; then
      ok "AC1 vajra $cmd $flag: exit 0, own help, 0 files written (old: exit $o_rc, $o_ch files)"
    else
      bad "AC1 vajra $cmd $flag: exit=$n_rc files=$n_ch; first line: $(head -1 <<<"$n_out")"
    fi
  done
done
# the case that hurt: OLD init --help wrote a scaffold — proves the probe can see a write at all
d="$(repo)"; run "$OLD" "$d" init --help; o_ch="$(changes "$d")"
[ "$o_ch" -gt 0 ] && ok "AC1 anchor: OLD \`init --help\` wrote $o_ch files (the probe sees writes)" \
  || bad "AC1 anchor: OLD \`init --help\` wrote nothing — the probe cannot see writes, AC1 proves nothing"
# inside an already-set-up project too (where Vajra's own repo got its duplicate hooks)
d="$(repo)"; run "$NEW" "$d" init; ( cd "$d" && git add -A && git -c user.name=t -c user.email=t@t commit -q -m s --no-verify )
run "$NEW" "$d" init --help; [ "$RC" = 0 ] && [ "$(changes "$d")" = 0 ] \
  && ok "AC1 \`init --help\` in a set-up project: exit 0, nothing changed" \
  || bad "AC1 \`init --help\` in a set-up project: exit=$RC, changed=$(changes "$d")"
# claude stays a pass-through: its --help reaches Claude Code, old and new behave the same
d="$(repo)"; run "$NEW" "$d" claude --help; n="$RC:$(head -1 <<<"$OUT")"; run "$OLD" "$d" claude --help; o="$RC:$(head -1 <<<"$OUT")"
[ "$n" = "$o" ] && ok "AC1 \`claude --help\` unchanged, old = new ($n)" || bad "AC1 \`claude --help\` changed: old=$o new=$n"
# a bare `vajra --help` still lists the commands, and names the new per-command help
run "$NEW" "$T" --help; [ "$RC" = 0 ] && grep -q "<command> --help" <<<"$OUT" \
  && ok "AC1 \`vajra --help\` exit 0 and names \`<command> --help\`" || bad "AC1 \`vajra --help\` rc=$RC"

# --- AC1b (F90): init refuses a word it does not know, writes nothing ---------------------------------
for w in --dry-run --overwrite-drifted --bogus myproject; do
  d="$(repo)"; run "$NEW" "$d" init "$w"; n_rc=$RC; n_out="$OUT"; n_ch="$(changes "$d")"
  d2="$(repo)"; run "$OLD" "$d2" init "$w"; o_rc=$RC; o_ch="$(changes "$d2")"
  if [ "$n_rc" != 0 ] && [ "$n_ch" = 0 ] && grep -q -- "$w" <<<"$n_out" && grep -q "nothing was written" <<<"$n_out"; then
    ok "AC1b vajra init $w: refused (exit $n_rc), names the word, 0 files (old: exit $o_rc, $o_ch files)"
  else
    bad "AC1b vajra init $w: exit=$n_rc files=$n_ch out=$(head -1 <<<"$n_out")"
  fi
done
d="$(repo)"; run "$NEW" "$d" init --dry-run; grep -q "vajra init --sync-fleet --dry-run" <<<"$OUT" \
  && ok "AC1b \`init --dry-run\` names the right command (\`vajra init --sync-fleet --dry-run\`)" \
  || bad "AC1b \`init --dry-run\` does not name the right command"
# the words init does know still work
d="$(repo)"; run "$NEW" "$d" init; [ "$RC" = 0 ] && [ -f "$d/.ai/SESSION" ] \
  && ok "AC1b plain \`vajra init\` still scaffolds" || bad "AC1b plain \`vajra init\` broke (rc=$RC)"
( cd "$d" && git add -A && git -c user.name=t -c user.email=t@t commit -q -m s --no-verify )
for args in "--sync-fleet --dry-run" "--sync-fleet"; do
  # shellcheck disable=SC2086
  run "$NEW" "$d" init $args; [ "$RC" = 0 ] && ok "AC1b \`vajra init $args\` still runs (exit 0)" || bad "AC1b \`vajra init $args\` rc=$RC: $(tail -1 <<<"$OUT")"
done

# --- AC2 (F93): a project's ground truth asks about the project first ------------------------------
audits() { sed -n 's/^  required_audits: \[\(.*\)\]$/\1/p' "$1"; }
d="$(repo)"; run "$NEW" "$d" init; NC="$d/.ai/CONSTRAINTS.yaml"
d2="$(repo)"; run "$OLD" "$d2" init; OC="$d2/.ai/CONSTRAINTS.yaml"
na="$(audits "$NC")"; oa="$(audits "$OC")"
case "$na" in
  "vision_alignment, roadmap_alignment, delivery_progress,"*) ok "AC2 new scaffold's audits start vision, roadmap, delivery_progress (old: $(cut -d, -f1-3 <<<"$oa"))";;
  *) bad "AC2 new scaffold's audits do not lead with the project: $na";;
esac
for w in dogfood_check dogfood_staleness; do
  if ! grep -q "$w" <<<"$na" && grep -q "scaffold-omits-audit: $w — " "$NC" && grep -q "$w" <<<"$oa"; then
    ok "AC2 $w withheld from a project, with its reason declared (old scaffold carried it)"
  else
    bad "AC2 $w: still required, or withheld without a declared reason"
  fi
done
grep -q "^  dogfood_questions:" "$NC" && bad "AC2 the Vajra-only dogfood questions still ship" \
  || ok "AC2 the Vajra-only dogfood questions no longer ship to a project"
pos() { grep -n "^  $1_questions:" "$NC" | cut -d: -f1; }
if [ -n "$(pos vision)" ] && [ "$(pos vision)" -lt "$(pos roadmap)" ] && [ "$(pos roadmap)" -lt "$(pos delivery_progress)" ] \
   && [ "$(pos delivery_progress)" -lt "$(pos pipeline_advance)" ] && [ "$(pos delivery_progress)" -lt "$(pos constitution)" ]; then
  ok "AC2 question order: vision → roadmap → delivery_progress, then the workflow ones"
else
  bad "AC2 question order wrong (vision=$(pos vision) roadmap=$(pos roadmap) delivery=$(pos delivery_progress) pipeline=$(pos pipeline_advance))"
fi
grep -q "What did this project actually deliver since the last ground truth" "$NC" \
  && ok "AC2 the delivery question ships (\"what did this project actually deliver…\")" || bad "AC2 the delivery question is missing"
bash scripts/scaffold-drift.sh >"$T/drift.out" 2>&1; rc=$?
[ "$rc" = 0 ] && ok "AC2 scripts/scaffold-drift.sh exit 0 ($(grep -m1 'live audits' "$T/drift.out" | tr -s ' '))" \
  || bad "AC2 scripts/scaffold-drift.sh exit $rc"
if [ -f "$RUDRA/.ai/CONSTRAINTS.yaml" ]; then
  blk() { sed -n '/^ground_truth:/,/^load_order:/p' "$1"; }
  if [ "$(blk "$RUDRA/.ai/CONSTRAINTS.yaml")" = "$(blk "$NC")" ]; then
    ok "AC2 rudra's ground-truth section equals the new scaffold's, byte for byte"
  else
    bad "AC2 rudra's ground-truth section differs from the new scaffold's"
  fi
else
  echo "SKIP: rudra not found at $RUDRA"; SKIP=$((SKIP+1))
fi

# --- the binary tests, and S178's corrected record -------------------------------------------------
cargo test -q --test cli_front_door >"$T/t.out" 2>&1 && ok "cargo test --test cli_front_door: $(grep -m1 'test result' "$T/t.out")" \
  || { bad "cargo test --test cli_front_door failed"; tail -5 "$T/t.out"; }
cargo test -q --lib scaffold_ground_truth_puts_the_project_first >"$T/t2.out" 2>&1 \
  && grep -q "1 passed" "$T/t2.out" && ok "lib test scaffold_ground_truth_puts_the_project_first passes" \
  || bad "lib test scaffold_ground_truth_puts_the_project_first did not pass"
grep -q "Corrected in S179" sessions/session-178-summary.md \
  && ok "S178 summary carries the correction (its own \`init --help\` wrote the files)" || bad "S178 correction missing"

echo
echo "result: $([ "$FAIL" = 0 ] && echo "ALL GREEN" || echo RED) ($PASS pass, $FAIL fail, $SKIP skip)"
[ "$FAIL" = 0 ]
