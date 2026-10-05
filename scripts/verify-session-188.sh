#!/usr/bin/env bash
# Session 188 verify — the approvals folder: check what changed, not what the words say.
# The AI's Bash commands are no longer judged by their words: Vajra saves the folder's state before each
# AI call and compares after it; a change voids those approvals until the founder approves again.
# Every check RUNS the real thing — the real binary, the real guard, a real `vajra init` project wired
# through its own .claude/settings.json, real commands between the real before and after hooks — and
# each fix is run again at the commit S188 started from (43305fd, pinned), where it must go red for the
# reason it names (S122). Nothing greps source.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(cd "$(mktemp -d)" && pwd -P)"
trap 'vajra_old_checkout_remove "${OLD_WT:-}"; chmod -R u+rwx "$T" 2>/dev/null; rm -rf "$T"' EXIT
OLD_SHA=43305fd
VAJRA="$ROOT/target/release/vajra"
cargo build --release -q || { echo "FAIL: cargo build --release"; exit 1; }
. "$ROOT/scripts/lib-old-checkout.sh"
OLD_WT=$(vajra_old_checkout "$OLD_SHA") || { echo "FAIL: worktree at $OLD_SHA"; exit 1; }
(cd "$OLD_WT" && CARGO_TARGET_DIR="$ROOT/target/s188-old" cargo build --release -q) || { echo "FAIL: build at $OLD_SHA"; exit 1; }
OLD_VAJRA="$ROOT/target/s188-old/release/vajra"
git show "$OLD_SHA:scripts/hook-approvals-guard.sh" > "$T/old-guard.sh"
D=.ai/approvals
mkdir -p "$T/home"

# project BIN DIR — a fresh `vajra init` project by BIN, at session 2, approved by a founder record, committed.
project() {
  mkdir -p "$2" && (cd "$2" && git init -q && "$1" init >/dev/null 2>&1 </dev/null) || return 1
  (cd "$2" && echo 2 > .ai/SESSION && mkdir -p $D \
    && printf '{"session": 2, "method": "approve-command", "at_unix": 1}\n' > $D/session-02.json \
    && printf '{"session": 3, "method": "approve-command"}\n' > forged.json \
    && git add -A && git -c user.name=v -c user.email=v@v commit -qm start --no-verify) >/dev/null 2>&1
}
# the guard command the project's settings run for TOOL on EVENT (empty: none registered)
registered() {
  jq -r --arg ev "$2" --arg t "$3" '[.hooks[$ev][]? | select((.matcher // "") | split("|") | index($t))
    | .hooks[].command | select(contains("hook-approvals-guard"))] | .[]' "$1/.claude/settings.json" 2>/dev/null
}
# hook DIR EVENT TOOL ID INPUT TMP → exit code of the registered guard, or "none"; stderr to $T/hook.err
hook() {
  local cmd; cmd=$(registered "$1" "$2" "$3" | head -1)
  [ -n "$cmd" ] || { echo none; return; }
  jq -n --arg ev "$2" --arg t "$3" --arg id "$4" --argjson in "$5" --arg d "$1" \
    '{hook_event_name:$ev, tool_name:$t, tool_use_id:$id, tool_input:$in, cwd:$d}' \
    | CLAUDE_PROJECT_DIR="$1" TMPDIR="$6" bash -c "$cmd" >"$T/hook.out" 2>"$T/hook.err"; echo "$?"
}
# pair DIR CMD → "before/after": one AI Bash call — the before hook, the real command, the after hook
# its exit picks. A blocked before means the command never ran: "2/-".
N_ID=0
pair() {
  N_ID=$((N_ID+1)); local id="toolu_v188_$N_ID" tmp; tmp=$(mktemp -d "$T/tmp.XXXXXX")
  local in; in=$(jq -n --arg c "$2" '{command:$c}')
  local pre; pre=$(hook "$1" PreToolUse Bash "$id" "$in" "$tmp")
  [ "$pre" = 2 ] && { echo "2/-"; return; }
  local ev=PostToolUse
  (cd "$1" && HOME="$T/home" bash -c "$2") >/dev/null 2>&1 </dev/null || ev=PostToolUseFailure
  echo "$pre/$(hook "$1" "$ev" Bash "$id" "$in" "$tmp")"
}
# approved BIN DIR → ✓ or ✗ from `vajra next --steps` (the founder-approval line)
approved() { (cd "$2" && "$1" next --steps 2>&1) | grep 'founder has approved this session' | grep -oE '^ *[✓✗]' | tr -d ' '; }
# the founder's own terminal (python's pty), outside any agent
approve_tty() {
  (cd "$2" && env -u VAJRA_AGENT_MARK python3 -c \
    "import pty,sys; sys.exit(0 if pty.spawn(['$1','approve','2'])==0 else 1)" </dev/null >/dev/null 2>&1)
}

NEW_P="$T/new"; project "$VAJRA" "$NEW_P" || bad "fixture: new project"
OLD_P="$T/old"; project "$OLD_VAJRA" "$OLD_P" || bad "fixture: old project"
fresh() { rm -rf "$2"; cp -R "$1" "$2"; }

# --- 1 (AC1, the before side): every read the old guard false-blocked passes ---------------------------
READS=(
  "git checkout -q -b X main && cd ~/playground/rudra && ls $D/"
  "cat > notes.md <<'EOF'
The folder $D holds the founder's approvals.
EOF"
  "git commit -m \"fix the $D guard

Co-Authored-By: Claude <noreply@anthropic.com>\""
  "ls $D; rm -f notes.txt"
  "cat $D/session-02.json && python3 -c 'print(1)'"
)
before_side() { # GUARD → the exit codes of the before side for every read, space-separated
  local GP="$T/gp"; mkdir -p "$GP/.ai"; echo "maturity: L2" > "$GP/.ai/CONSTRAINTS.yaml"; local c out=""
  for c in "${READS[@]}"; do
    jq -n --arg c "$c" --arg d "$GP" '{hook_event_name:"PreToolUse",tool_name:"Bash",tool_use_id:"toolu_b",tool_input:{command:$c},cwd:$d}' \
      | CLAUDE_PROJECT_DIR="$GP" TMPDIR="$T" bash "$1" >/dev/null 2>&1; out="$out$? "
  done; echo "$out"
}
bn=$(before_side scripts/hook-approvals-guard.sh); bo=$(before_side "$T/old-guard.sh")
if [ "$bn" = "0 0 0 0 0 " ] && [ "$bo" = "2 2 2 2 2 " ]; then
  ok "AC1 the S187 live read, two F110 heredoc/commit-message cases and two joined reads pass the before side (exit 0); at $OLD_SHA all five blocked"
else bad "AC1 before side: now [$bn] at $OLD_SHA [$bo]"; fi

# --- 2 (AC1, real runs): the same reads, run through a project's own settings, raise nothing after -----
rn=""; ro=""
for c in "${READS[@]}"; do
  fresh "$NEW_P" "$T/r"; rn="$rn$(pair "$T/r" "$c") "
  fresh "$OLD_P" "$T/r"; ro="$ro$(pair "$T/r" "$c") "
done
if [ "$rn" = "0/0 0/0 0/0 0/0 0/0 " ] && grep -q '2/-' <<<"$ro"; then
  ok "AC1 run for real in a fresh project: before 0, after 0 for all five; at $OLD_SHA the before side blocked them [$ro]"
else bad "AC1 real runs: now [$rn] at $OLD_SHA [$ro]"; fi

# --- 3 (AC2): every real write is caught AFTER it runs, and the approval reads as missing ---------------
WRITES=(
  "echo x > $D/x"
  "cp forged.json $D/session-03.json"
  "mv $D/session-02.json notes.md"
  "rm $D/session-02.json"
  "echo x | tee $D/x >/dev/null"
  "python3 -c 'open(\"$D/x\",\"w\").write(\"1\")'"
  "awk 'BEGIN{print 1 > \"$D/x\"}'"
  "find $D -name '*.json' -delete"
  "cp forged.json $D/session-03.json; false"
  "d=.ai; a=appr; cp forged.json \$d/\${a}ovals/session-03.json"
)
wn=0; wo=0; wmsg=0; wsteps=0
for c in "${WRITES[@]}"; do
  fresh "$NEW_P" "$T/w"; r=$(pair "$T/w" "$c")
  [ "$r" = "0/2" ] && wn=$((wn+1))
  grep -q '\[vajra\] CAUGHT' "$T/hook.err" && grep -q 'tell the founder' "$T/hook.err" && wmsg=$((wmsg+1))
  [ "$(approved "$VAJRA" "$T/w")" = "✗" ] && wsteps=$((wsteps+1))
  fresh "$OLD_P" "$T/w"; r=$(pair "$T/w" "$c")
  case "$r" in */2) wo=$((wo+1)) ;; esac
done
if [ "$wn" = "${#WRITES[@]}" ] && [ "$wmsg" = "${#WRITES[@]}" ] && [ "$wsteps" = "${#WRITES[@]}" ] && [ "$wo" = 0 ]; then
  ok "AC2 ${#WRITES[@]}/${#WRITES[@]} writes (cp, mv, rm, >, tee, python, awk, find -delete, a write in a FAILING command, a path built at run time) ran, were caught after (exit 2, the plain message) and \`vajra next --steps\` shows ✗ approval; at $OLD_SHA nothing ran after a call (0 caught)"
else bad "AC2 caught $wn, message $wmsg, steps ✗ $wsteps of ${#WRITES[@]}; at $OLD_SHA caught $wo"; fi
fresh "$NEW_P" "$T/g"
printf '{"session": 2, "method": "approve-command", "at_unix": 2}\n' > "$T/g/$D/session-02.json"   # the founder's newer record
r=$(pair "$T/g" "git checkout -- $D")
if [ "$r" = "0/2" ] && grep -q 'changed: session-02.json' "$T/hook.err"; then
  ok "AC2 \`git checkout -- $D\` (restores a committed record over the founder's newer one) is caught after"
else bad "AC2 git checkout: $r"; fi

# --- 4 (AC3): the founder's approve BETWEEN two AI calls raises nothing; his new record counts ---------
s3() { # BIN DIR → "after-write steps · approve · after-approve steps · the next read"
  local a b r; r=$(pair "$2" "cp forged.json $D/x"); a=$(approved "$1" "$2")
  approve_tty "$1" "$2" || { echo "approve-failed"; return; }; b=$(approved "$1" "$2")
  echo "$r $a $b $(pair "$2" "ls $D") $(approved "$1" "$2")"
}
fresh "$NEW_P" "$T/a"; an=$(s3 "$VAJRA" "$T/a"); fresh "$OLD_P" "$T/a"; ao=$(s3 "$OLD_VAJRA" "$T/a")
if [ "$an" = "0/2 ✗ ✓ 0/0 ✓" ] && [ "$ao" != "$an" ]; then
  ok "AC3 caught write → ✗; the founder's \`vajra approve 2\` from his own terminal → ✓; the next AI read raises nothing (0/0), still ✓ [at $OLD_SHA: $ao — the write was blocked before, nothing to catch or clear]"
else bad "AC3 now [$an] at $OLD_SHA [$ao]"; fi
# tech-lead rec 4: his approve DURING a long AI command — what really happens
overlap() { # BIN DIR → "after-exit message?"
  local tmp; tmp=$(mktemp -d "$T/tmp.XXXXXX"); local in='{"command":"sleep 0"}'
  hook "$2" PreToolUse Bash toolu_ov "$in" "$tmp" >/dev/null
  approve_tty "$1" "$2"
  local post; post=$(hook "$2" PostToolUse Bash toolu_ov "$in" "$tmp")
  grep -q 'while this command was running' "$T/hook.err" && echo "$post told" || echo "$post silent"
}
fresh "$NEW_P" "$T/o"; on=$(overlap "$VAJRA" "$T/o"); fresh "$OLD_P" "$T/o"; oo=$(overlap "$OLD_VAJRA" "$T/o")
if [ "$on" = "2 told" ] && [ "$oo" != "$on" ]; then
  ok "AC3 (rec 4) an approve that lands WHILE an AI command runs is flagged, and the message tells the founder to run it again [at $OLD_SHA: $oo]"
else bad "AC3 overlap now [$on] at $OLD_SHA [$oo]"; fi

# --- 5 (AC4, unchanged by design): a Write/Edit aimed at the folder is still blocked BEFORE it runs ----
w4() { # DIR → exits of Write and Edit into the folder
  local tmp; tmp=$(mktemp -d "$T/tmp.XXXXXX")
  local in; in=$(jq -n --arg f "$1/$D/session-03.json" '{file_path:$f, content:"x"}')
  echo "$(hook "$1" PreToolUse Write toolu_w "$in" "$tmp") $(hook "$1" PreToolUse Edit toolu_e "$in" "$tmp")"
}
fresh "$NEW_P" "$T/e"; en=$(w4 "$T/e"); fresh "$OLD_P" "$T/e"; eo=$(w4 "$T/e")
if [ "$en" = "2 2" ] && [ "$eo" = "2 2" ]; then
  ok "AC4 Write and Edit into $D are blocked before they run (exit 2) — unchanged, the same at $OLD_SHA"
else bad "AC4 now [$en] at $OLD_SHA [$eo]"; fi

# --- 6 (AC5): a fresh project and an old one after --sync-fleet both run the check; added once ---------
wired() { # DIR → how many times each event × tool runs the guard (all must be 1)
  local ev t out=""
  for ev in PreToolUse PostToolUse PostToolUseFailure; do for t in Bash Edit Write MultiEdit NotebookEdit; do
    out="$out$(registered "$1" "$ev" "$t" | grep -c .)"; done; done; echo "$out"
}
ALL1=111111111111111
fn=$(wired "$NEW_P"); fo=$(wired "$OLD_P")
if [ "$fn" = "$ALL1" ] && [ "$fo" != "$ALL1" ]; then
  ok "AC5 a fresh \`vajra init\` runs the guard before AND after every call, once per tool; at $OLD_SHA: before only [$fo]"
else bad "AC5 fresh wiring now [$fn] at $OLD_SHA [$fo]"; fi
sync_case() { # BIN → "wiring · own hook kept · second run unchanged · a write caught"
  local P="$T/s"; fresh "$OLD_P" "$P"
  jq '.hooks.PostToolUse = [{"matcher":"Bash","hooks":[{"type":"command","command":"bash my-own-after.sh"}]}]' \
    "$P/.claude/settings.json" > "$T/s.json" && cp "$T/s.json" "$P/.claude/settings.json"
  (cd "$P" && "$1" init --sync-fleet >/dev/null 2>&1)
  local own; own=$(jq -c '.hooks.PostToolUse[0]' "$P/.claude/settings.json")
  local once; once=$(cat "$P/.claude/settings.json")
  (cd "$P" && "$1" init --sync-fleet >/dev/null 2>&1)
  local same=changed; [ "$once" = "$(cat "$P/.claude/settings.json")" ] && same=same
  local kept=lost; [ "$own" = '{"matcher":"Bash","hooks":[{"type":"command","command":"bash my-own-after.sh"}]}' ] && kept=kept
  echo "$(wired "$P") $kept $same $(pair "$P" "cp forged.json $D/x")"
}
sn=$(sync_case "$VAJRA"); so=$(sync_case "$OLD_VAJRA")
if [ "$sn" = "$ALL1 kept same 0/2" ] && [ "$so" != "$sn" ]; then
  ok "AC5 an old project with its own after hook: --sync-fleet wires the guard after every call once, keeps the project's hook, a second run changes nothing, a write is caught [at $OLD_SHA: $so]"
else bad "AC5 sync now [$sn] at $OLD_SHA [$so]"; fi

# --- 7 (AC6, tech-lead rec 9): projects run the bytes Vajra tests ------------------------------------
if diff <(grep -v 'vajra-render-sha' "$NEW_P/.ai/hooks/hook-approvals-guard.sh") \
        <(grep -v 'vajra-render-sha' scripts/hook-approvals-guard.sh) >/dev/null; then
  ok "AC6 the guard \`vajra init\` ships is scripts/hook-approvals-guard.sh, byte for byte (the stamp line aside) — the checks above ran the shipped copy"
else bad "AC6 the shipped guard differs from scripts/hook-approvals-guard.sh"; fi

# --- 8 (AC6): the S188 tests run and pass (no before record, L1, double after-run, links, the void) ---
if cargo test -q --test approvals_guard --test approvals_scaffold --test approval_cli > "$T/t.out" 2>&1 \
   && cargo test -q --lib approval:: >> "$T/t.out" 2>&1; then
  n=$(grep -E '^test result: ok' "$T/t.out" | awk '{s+=$4} END {print s+0}')
  ok "AC6 the guard, scaffold, approve-CLI and void tests pass ($n tests; they do not exist at $OLD_SHA)"
else bad "AC6 cargo tests"; tail -15 "$T/t.out"; fi

echo "----"
echo "verify-session-188: $PASS passed, $FAIL failed"
[ "$FAIL" = 0 ]
