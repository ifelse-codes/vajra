#!/usr/bin/env bash
# Session 186 verify — the fixes the S185 ground truth picked: F113 (obeyed_blocks_from:), F115
# (verify-132's --advance fixture), F110 (b) + S182 recs 1/2/5 (the approvals guard and the settings
# merge), F114 (a fresh project's ledger), N1 (hook block reasons on stderr).
# Every check RUNS the real thing — the real binary, the real hooks, a real `vajra init` project — and
# each fix is also run at the commit S186 started from, where it must go red for the reason it names
# (S122). Nothing greps source.
# OLD = the commit S186 started from (b10a1a6, pinned — never `main`).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(cd "$(mktemp -d)" && pwd -P)"
trap 'git worktree remove --force "$T/old" >/dev/null 2>&1; git worktree prune >/dev/null 2>&1; rm -rf "$T"' EXIT
OLD_SHA=b10a1a6
VAJRA="$ROOT/target/release/vajra"
cargo build --release -q || { echo "FAIL: cargo build --release"; exit 1; }
git worktree add --detach "$T/old" "$OLD_SHA" >/dev/null 2>&1 || { echo "FAIL: worktree at $OLD_SHA"; exit 1; }
(cd "$T/old" && CARGO_TARGET_DIR="$ROOT/target/s186-old" cargo build --release -q) || { echo "FAIL: build at $OLD_SHA"; exit 1; }
OLD_VAJRA="$ROOT/target/s186-old/release/vajra"

# --- F113 (AC1): a project's session 132 is not Vajra's ----------------------------------------------
# A fresh `vajra init` project at session 132 whose `## Advice` records an unjudged `obeyed:`.
obeyed_project() {
  local P="$1"; mkdir -p "$P" && (cd "$P" && git init -q && "$VAJRA" init >/dev/null 2>&1 </dev/null) || return 1
  echo 132 > "$P/.ai/SESSION"; mkdir -p "$P/prompts" "$P/.ai/handoffs"
  (cd "$P" && git add -A >/dev/null 2>&1 && git -c core.hooksPath=/nonexistent commit -qm seed)
  printf '# S132\n\n## Advice\n\n- plan-advisor rec 1 — obeyed: %s\n' "$(cd "$P" && git rev-parse --short=7 HEAD)" \
    > "$P/prompts/132-task-x.md"
}
P="$T/obeyed"; obeyed_project "$P" || bad "F113 fixture"
out=$(cd "$P" && "$VAJRA" next --check-obeyed 132 2>&1); rn=$?
outo=$(cd "$P" && "$OLD_VAJRA" next --check-obeyed 132 2>&1); ro=$?
if [ "$rn" = 0 ] && grep -q 'does not block on unchecked `obeyed:` claims (no `obeyed_blocks_from:` in .ai/CONSTRAINTS.yaml)' <<<"$out" \
   && [ "$ro" = 1 ] && grep -q 'carries no independent judgment' <<<"$outo"; then
  ok "F113 no key: a fresh project's session 132 warns and says why (exit 0); at $OLD_SHA it BLOCKED (exit 1)"
else bad "F113 no key: new exit $rn, old exit $ro"; fi
printf '  obeyed_blocks_from: 132\n' >> "$P/.ai/CONSTRAINTS.yaml"
out=$(cd "$P" && "$VAJRA" next --check-obeyed 132 2>&1); rn=$?
[ "$rn" = 1 ] && grep -q 'carries no independent judgment' <<<"$out" \
  && ok "F113 obeyed_blocks_from: 132 declared: the same claim blocks (exit 1)" || bad "F113 declared: exit $rn"
sed -i.bak 's/^  obeyed_blocks_from: 132$/  obeyed_blocks_from: x/' "$P/.ai/CONSTRAINTS.yaml"
line=$(grep -n 'obeyed_blocks_from: x' "$P/.ai/CONSTRAINTS.yaml" | cut -d: -f1)
out=$(cd "$P" && "$VAJRA" next --check-obeyed 132 2>&1); rn=$?
[ "$rn" = 1 ] && grep -q "CONSTRAINTS.yaml line $line" <<<"$out" && ! grep -q 'no `obeyed_blocks_from:`' <<<"$out" \
  && ok "F113 obeyed_blocks_from: x blocks, names line $line, and never claims 'no key'" || bad "F113 malformed: exit $rn"
cp "$ROOT/.ai/CONSTRAINTS.yaml" "$P/.ai/CONSTRAINTS.yaml"
out=$(cd "$P" && "$VAJRA" next --check-obeyed 132 2>&1); rn=$?
[ "$rn" = 1 ] && ok "F113 Vajra's own CONSTRAINTS.yaml (its real key) still blocks an unjudged claim at 132" \
  || bad "F113 Vajra's own config: exit $rn"

# --- F115 (AC7): verify-132 is fully green, including the --advance binding red since S135 -------------
if bash scripts/verify-session-132.sh > "$T/v132.out" 2>&1 \
   && grep -qE '^advance-really-binds-on-an-unjudged-obeyed[[:space:]]+exec[[:space:]]+PASS' "$T/v132.out"; then
  ok "F115 scripts/verify-session-132.sh exits 0; advance-really-binds-on-an-unjudged-obeyed PASS"
else bad "F115 verify-132"; grep -E 'FAIL' "$T/v132.out" | head -5; fi

# --- F110 (b) SPLIT OUT by the founder (2026-10-04); recs 1/5 (AC4): the guard, live, new vs old ---------
GP="$T/guardproj"; mkdir -p "$GP/.ai"; echo 'maturity: L2' > "$GP/.ai/CONSTRAINTS.yaml"
git show "$OLD_SHA:scripts/hook-approvals-guard.sh" > "$T/old-guard.sh"
guard() {  # SCRIPT CMD -> exit code
  jq -n --arg c "$2" --arg d "$GP" '{tool_name:"Bash", cwd:$d, tool_input:{command:$c}}' \
    | CLAUDE_PROJECT_DIR="$GP" bash "$1" >/dev/null 2>&1; echo $?
}
D=.ai/approvals
HEREDOC="cat > notes.md <<'EOF'
The folder $D holds the founder's approvals.
EOF"
COMMIT="git commit -m \"S186: fix the $D guard

Co-Authored-By: Claude <noreply@anthropic.com>\""
QUOTE="cat <<'EOF' > notes.md
> a quote that names $D
EOF"
# F110 is still open: these still block, and the block now names the way past.
for c in "$HEREDOC" "$COMMIT" "$QUOTE"; do
  msg=$(jq -n --arg c "$c" --arg d "$GP" '{tool_name:"Bash", cwd:$d, tool_input:{command:$c}}' \
    | CLAUDE_PROJECT_DIR="$GP" bash scripts/hook-approvals-guard.sh 2>&1 >/dev/null); n=$?
  [ "$n" = 2 ] && grep -q 'git commit -F' <<<"$msg" \
    && ok "F110 open (split): still blocks, names 'git commit -F': $(head -1 <<<"$c" | cut -c1-50)" \
    || bad "F110 open: exit $n or no way-past message: $(head -1 <<<"$c")"
done
for c in "echo x > $D/y" "echo x >> .AI//Approvals/../approvals/y" "cd .ai && echo x > approvals/y" \
         "D=$D; echo x > \$D/y" "env -C $D sh -c 'echo > x'" "sh -c \"echo >\"' $D/x'" \
         "echo x > .ai/hooks/../approvals/x" "find $D -delete" "git checkout -- $D" "sh x.sh $D" \
         "echo x > \\
$D/y" "awk -v f=$D/x 'BEGIN{print 1 > f }'" "\${x}cd $D && echo x > y" "echo x >>! $D/y" \
         "/usr/bin/awk -v f=$D/x 'BEGIN{print 1}'" "builtin c\${x}d $D && echo x > y"; do
  n=$(guard scripts/hook-approvals-guard.sh "$c")
  [ "$n" = 2 ] && ok "F110/AC4 still blocks: $c" || bad "F110/AC4 not blocked (exit $n): $c"
done
jq -n --arg d "$GP" '{tool_name:"Write", cwd:$d, tool_input:{file_path:($d + "/.ai/hooks/../approvals/x")}}' \
  | CLAUDE_PROJECT_DIR="$GP" bash scripts/hook-approvals-guard.sh >/dev/null 2>&1; n=$?
jq -n --arg d "$GP" '{tool_name:"Write", cwd:$d, tool_input:{file_path:($d + "/.ai/hooks/../approvals/x")}}' \
  | CLAUDE_PROJECT_DIR="$GP" bash "$T/old-guard.sh" >/dev/null 2>&1; o=$?
[ "$n" = 2 ] && [ "$o" = 0 ] && ok "rec 1 (AC4): the Write tool into .ai/hooks/../approvals/x blocks (passed at $OLD_SHA)" \
  || bad "rec 1 Write tool: new=$n old=$o"

# --- AC3: the corpus — every command the S182 guard blocked still blocks, except listed non-writes ------
if cargo test -q --test approvals_guard > "$T/guard-tests.out" 2>&1 && grep -q 'test result: ok. 11 passed' "$T/guard-tests.out"; then
  ok "AC3 tests/approvals_guard.rs: 11 pass, incl. every_listed_command_the_s182_guard_blocked_still_blocks (only adds; F110 cases still block)"
else bad "AC3 guard tests"; tail -5 "$T/guard-tests.out"; fi

# --- S182 rec 2 (AC5): the new merge test is red on the old merge, green now ---------------------------
TESTFN="$(awk '/fn merge_adds_no_hook_wired_under_a_covering_matcher/{p=1; print "    #[test]"} p{print} p&&/^    }$/{exit}' src/cli/init.rs)"
[ -n "$TESTFN" ] || bad "AC5 could not lift the test"
TESTFN="$TESTFN" perl -0pi -e 's/(    #\[test\]\n    fn merge_is_idempotent)/$ENV{TESTFN}\n\n$1/' "$T/old/src/cli/init.rs"
(cd "$T/old" && CARGO_TARGET_DIR="$ROOT/target/s186-old" cargo test -q --lib merge_adds_no_hook_wired_under_a_covering_matcher) > "$T/ac5-old.out" 2>&1; ro=$?
cargo test -q --lib merge_adds_no_hook_wired_under_a_covering_matcher > "$T/ac5-new.out" 2>&1; rn=$?
if [ "$rn" = 0 ] && [ "$ro" != 0 ] && grep -q 'adding it again runs it twice' "$T/ac5-old.out" \
   && ! grep -qE 'error\[E[0-9]+\]' "$T/ac5-old.out"; then
  ok "AC5 a hook wired under a covering matcher is not added again; at $OLD_SHA the same test fails: 'runs it twice'"
else bad "AC5 new=$rn old=$ro"; grep -E 'panicked|error' "$T/ac5-old.out" | head -3; fi
git -C "$T/old" checkout -q -- src/cli/init.rs

# --- F114 (AC6): a fresh project's ledger ---------------------------------------------------------------
F="$T/fresh"; mkdir -p "$F" && (cd "$F" && git init -q && "$VAJRA" init >/dev/null 2>&1 </dev/null)
(cd "$F" && bash scripts/verify-closeout.sh --ledger > "$T/l.out" 2>&1); rn=$?
(cd "$F" && bash scripts/verify-closeout.sh --ledger-verify > "$T/lv.out" 2>&1); rv=$?
git show "$OLD_SHA:scripts/verify-closeout-scaffold.sh" > "$F/scripts/old-closeout.sh"
(cd "$F" && bash scripts/old-closeout.sh --ledger > "$T/lo.out" 2>&1); ro=$?
if [ "$rn" = 0 ] && grep -q 'ledger: no reviewed sessions yet' "$T/l.out" && [ "$rv" = 0 ] && [ "$ro" != 0 ] && [ ! -s "$T/lo.out" ]; then
  ok "F114 fresh project: --ledger prints 'no reviewed sessions yet' (exit 0), --ledger-verify exit 0; at $OLD_SHA silent exit $ro"
else bad "F114 new=$rn verify=$rv old=$ro"; fi
bash scripts/verify-closeout.sh --ledger > "$T/lv-own.out" 2>&1 && grep -q 'chain head' "$T/lv-own.out" \
  && ok "F114 control: Vajra's own ledger still prints its chain" || bad "F114 control: Vajra's ledger"

# --- N1 (AC8): a ground-truth block reaches the agent on stderr -----------------------------------------
G="$T/gt"; mkdir -p "$G" && (cd "$G" && git init -q && git checkout -q -b session-190-x)
mkdir -p "$T/oldhooks"; for f in hook-pre-bash.sh hook-pre-write.sh hook-approvals-guard.sh lib-ground-truth.sh; do
  git show "$OLD_SHA:scripts/$f" > "$T/oldhooks/$f"; done
gt() {  # HOOK PAYLOAD -> "exit stdout-has stderr-has"
  local so se; so="$T/so"; se="$T/se"
  printf '%s' "$2" | CLAUDE_PROJECT_DIR="$G" bash "$1" >"$so" 2>"$se"; local rc=$?
  echo "$rc $(grep -c '\[HOOK BLOCK\] Ground Truth' "$so") $(grep -c '\[HOOK BLOCK\] Ground Truth' "$se")"
}
PB=$(jq -n --arg d "$G" '{tool_name:"Bash", cwd:$d, tool_input:{command:"git commit -m x"}}')
PW=$(jq -n --arg d "$G" '{tool_name:"Write", cwd:$d, tool_input:{file_path:($d + "/src/main.rs")}}')
for pair in "hook-pre-bash.sh|$PB" "hook-pre-write.sh|$PW"; do
  h="${pair%%|*}"; p="${pair#*|}"
  n=$(gt "scripts/$h" "$p"); o=$(gt "$T/oldhooks/$h" "$p")
  [ "$n" = "2 0 1" ] && [ "$o" = "2 1 0" ] \
    && ok "N1 $h: the ground-truth block reason is on stderr (at $OLD_SHA it was on stdout — 'No stderr output')" \
    || bad "N1 $h new='$n' old='$o' (exit stdout stderr)"
done

echo; echo "=== Session 186 Verify Summary ==="
if [ "$FAIL" -eq 0 ]; then echo "GREEN ($PASS pass, 0 fail)"; exit 0; else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
