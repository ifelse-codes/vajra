#!/usr/bin/env bash
# Session 197 verify — the known-bug session (founder pick, 2026-10-14):
#   F125 + N17  the review-only guard ships to every project; no branch name opens it, only the founder's
#               `vajra approve NN --close` record (DECISION-011 S197 addendum). Founder call in-session: user
#               projects never had the guard at all, so it ships; F118 moved out.
#   F116        `vajra next --steps` names an approval record that is not in the last commit.
#   F119        `--steps` ticks design on a `design-significant: no` prompt, as `--check-design` does.
#   N10         scaffold-drift check 6 takes a `# source-claim: <why>` opt-out on the line itself.
# Every check RUNS the real thing: a real `vajra init` project, its own scaffolded hook fed the JSON Claude Code
# sends, the real `vajra approve` in a pseudo-terminal, real `vajra next`, the real scaffold-drift script. Each
# row runs again with the binary, hooks and scaffold from the commit S197 started at (eceb6d5), where it must go
# red for its own reason (S122). Nothing greps Vajra's source; rudra is never touched.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(cd "$(mktemp -d)" && pwd -P)"
trap 'vajra_old_checkout_remove "${OLD_WT:-}"; [ -n "${WT:-}" ] && git worktree remove --force "$WT" >/dev/null 2>&1; rm -rf "$T"' EXIT
OLD_SHA=eceb6d5
VAJRA="$ROOT/target/release/vajra"
cargo build --release -q || { echo "FAIL: cargo build --release"; exit 1; }
. "$ROOT/scripts/lib-old-checkout.sh"
OLD_WT=$(vajra_old_checkout "$OLD_SHA") || { echo "FAIL: worktree at $OLD_SHA"; exit 1; }
(cd "$OLD_WT" && CARGO_TARGET_DIR="$ROOT/target/s197-old" cargo build --release -q) || { echo "FAIL: build at $OLD_SHA"; exit 1; }
OLD_VAJRA="$ROOT/target/s197-old/release/vajra"
mkdir -p "$T/new-bin" "$T/old-bin" "$T/tmp"
ln -s "$VAJRA" "$T/new-bin/vajra"; ln -s "$OLD_VAJRA" "$T/old-bin/vajra"

# Setup is the human's: every agent marker dropped; the founder's terminal is a pseudo-terminal (`script`).
human() { env -u CLAUDECODE -u CLAUDE_CODE_ENTRYPOINT -u CURSOR_TRACE_ID -u VAJRA_AGENT -u VAJRA_ALLOW_COMMIT \
            -u VAJRA_AGENT_MARK -u CLAUDE_PROJECT_DIR -u VAJRA_GT_WAIVER GIT_CONFIG_GLOBAL=/dev/null "$@"; }
has() { printf '%s\n' "$1" | grep -qF -- "$2"; }
gitc() { human git -c user.email=t@t -c user.name=t "$@"; }
founder() { (cd "$1" && shift && human script -q /dev/null "$@" </dev/null >/dev/null 2>&1); }

# project BIN NAME [SESSION] → a `vajra init` project (that binary's scaffold) whose committed .ai/SESSION is 4
# (so session 5, a ground truth by the every-5th rule, is next), on branch session-05-closeout.
project() {
  local p="$T/$2"; rm -rf "$p"; mkdir -p "$p"
  # The project's own belt refuses a commit on main, so the branch comes first.
  (cd "$p" && human git init -q -b main && human "$1" init </dev/null >/dev/null 2>&1 && echo "${3:-4}" > .ai/SESSION \
     && perl -pi -e 's/\*\*Number:\*\* \d+/**Number:** '"${3:-4}"'/' .ai/SESSION-BOOT.md && human git checkout -qb session-05-closeout && human git add -A && gitc commit -qm init)
  printf '%s' "$p"
}
# hook P SCRIPT BINDIR TOOL KEY VALUE → run SCRIPT as Claude Code's PreToolUse would, with BINDIR's vajra on PATH.
# Prints "rc|stderr".
hook() {
  local p="$1" s="$2" bin="$3" tool="$4" key="$5" val="$6" j err rc
  j=$(jq -cn --arg t "$tool" --arg k "$key" --arg v "$val" \
        '{hook_event_name:"PreToolUse", tool_name:$t, tool_use_id:"toolu_s197", tool_input:{($k):$v}}')
  err=$(cd "$p" && printf '%s' "$j" | human CLAUDE_PROJECT_DIR="$p" PATH="$bin:$PATH" TMPDIR="$T/tmp" bash "$s" 2>&1 >/dev/null); rc=$?
  printf '%s|%s' "$rc" "$err"
}
gg() { hook "$1" "$1/.ai/hooks/hook-ground-truth-guard.sh" "${3:-$T/new-bin}" Bash command "$2"; }

# --- 1 (F125, AC1): a ground-truth session's commit / push / PR on a -closeout branch is blocked in a project ---
P=$(project "$VAJRA" gt)
R1=$(gg "$P" "git commit -m report"); R2=$(gg "$P" "git push -u origin session-05-closeout"); R3=$(gg "$P" "gh pr create --fill")
if [ "${R1%%|*}" = 2 ] && [ "${R2%%|*}" = 2 ] && [ "${R3%%|*}" = 2 ] && has "$R1" 'Ground Truth Session 5' \
   && has "$R1" 'vajra approve 5 --close' \
   && jq -e '[.hooks.PreToolUse[].hooks[].command] | any(test("hook-ground-truth-guard"))' "$P/.claude/settings.json" >/dev/null; then
  ok "F125 a fresh project ships + wires the guard; on session-05-closeout, commit / push / PR are blocked and told 'vajra approve 5 --close'"
else bad "F125 project block: commit=${R1%%|*} push=${R2%%|*} pr=${R3%%|*}"$'\n'"$R1"; fi
PO=$(project "$OLD_VAJRA" gt-old)
if [ ! -e "$PO/.ai/hooks/hook-ground-truth-guard.sh" ] \
   && ! grep -rqE 'vajra_is_ground_truth|Ground Truth Session' "$PO/.ai/hooks/hook-session-guard.sh" "$PO/.ai/hooks/hook-commit-guard.sh" "$PO/.ai/hooks/hook-publish-guard.sh" "$PO/.ai/hooks/hook-approvals-guard.sh" \
   && ! jq -e '[.hooks.PreToolUse[].hooks[].command] | any(test("ground-truth|pre-bash|pre-write"))' "$PO/.claude/settings.json" >/dev/null; then
  ok "F125 red at $OLD_SHA: a fresh project had NO review-only guard — no file, no wiring, no ground-truth block in any PreToolUse hook"
else bad "F125 at $OLD_SHA: the old scaffold had a ground-truth guard after all"; fi

# --- 2 (F125): Vajra's own hook — the -closeout branch no longer switches it off ---
N=$(hook "$P" "$ROOT/scripts/hook-pre-bash.sh" "$T/new-bin" Bash command "git commit -m report")
O=$(hook "$P" "$OLD_WT/scripts/hook-pre-bash.sh" "$T/new-bin" Bash command "git commit -m report")
NW=$(hook "$P" "$ROOT/scripts/hook-pre-write.sh" "$T/new-bin" Write file_path "$P/src/main.rs")
OW=$(hook "$P" "$OLD_WT/scripts/hook-pre-write.sh" "$T/new-bin" Write file_path "$P/src/main.rs")
# Positive control (review rec 5): the SAME old hooks in the SAME project do block on a plain session-05 branch,
# so their pass on -closeout comes from the exemption, not from a hook that cannot run here.
(cd "$P" && human git checkout -qb session-05-x)
OC=$(hook "$P" "$OLD_WT/scripts/hook-pre-bash.sh" "$T/new-bin" Bash command "git commit -m report")
OCW=$(hook "$P" "$OLD_WT/scripts/hook-pre-write.sh" "$T/new-bin" Write file_path "$P/src/main.rs")
(cd "$P" && human git checkout -q session-05-closeout)
if [ "${N%%|*}" = 2 ] && has "$N" 'Ground Truth Session 5' && [ "${NW%%|*}" = 2 ] && [ "${O%%|*}" = 0 ] && [ "${OW%%|*}" = 0 ] \
   && [ "${OC%%|*}" = 2 ] && [ "${OCW%%|*}" = 2 ]; then
  ok "F125 Vajra's own hook-pre-bash.sh and hook-pre-write.sh block a commit and a src/ write on session-05-closeout; at $OLD_SHA both passed there, and blocked on session-05-x (the '*-closeout' exemption)"
else bad "F125 own hooks: bash new=${N%%|*} old=${O%%|*} ctl=${OC%%|*} · write new=${NW%%|*} old=${OW%%|*} ctl=${OCW%%|*}"$'\n'"$N"; fi

# --- 3 (F125): writes — the report and .ai/ notes pass, code is blocked, before the record ---
W1=$(hook "$P" "$P/.ai/hooks/hook-ground-truth-guard.sh" "$T/new-bin" Write file_path "$P/src/main.rs")
W2=$(hook "$P" "$P/.ai/hooks/hook-ground-truth-guard.sh" "$T/new-bin" Write file_path "$P/sessions/session-05-ground-truth.md")
W3=$(hook "$P" "$P/.ai/hooks/hook-ground-truth-guard.sh" "$T/new-bin" Edit file_path "$P/.ai/STATE.md")
if [ "${W1%%|*}" = 2 ] && [ "${W2%%|*}" = 0 ] && [ "${W3%%|*}" = 0 ]; then
  ok "F125 before the sign-off: a write to src/ is blocked; the report and .ai/ notes are written"
else bad "F125 writes: src=${W1%%|*} report=${W2%%|*} ai=${W3%%|*}"$'\n'"$W1"; fi

# --- 4 (F125): the founder's record opens it; an older vajra that ignores the flag does not ---
founder "$P" "$VAJRA" approve 5 --close
R1=$(gg "$P" "git commit -m report"); R2=$(gg "$P" "gh pr create --fill")
RO=$(gg "$P" "git commit -m report" "$T/old-bin")
if [ -f "$P/.ai/approvals/session-05-close.json" ] && [ "${R1%%|*}" = 0 ] && [ "${R2%%|*}" = 0 ] && [ "${RO%%|*}" = 2 ]; then
  ok "F125 after 'vajra approve 5 --close' (the founder's terminal) commit and PR pass; with a vajra that predates the flag on PATH it stays closed"
else bad "F125 opening: record=$(ls "$P/.ai/approvals" 2>&1) commit=${R1%%|*} pr=${R2%%|*} old-vajra=${RO%%|*}"$'\n'"$R1"$'\n'"$RO"; fi

# --- 5 (F125): a record the agent forges through Bash is voided by the S188 check, and the guard stays closed ---
P=$(project "$VAJRA" forge)
FORGE="mkdir -p .ai/approvals && printf '{\"session\":5,\"method\":\"close-command\",\"at_unix\":1}' > .ai/approvals/session-05-close.json"
J=$(jq -cn --arg c "$FORGE" '{hook_event_name:"PreToolUse", tool_name:"Bash", tool_use_id:"toolu_forge", tool_input:{command:$c}}')
(cd "$P" && printf '%s' "$J" | human CLAUDE_PROJECT_DIR="$P" TMPDIR="$T/tmp" bash .ai/hooks/hook-approvals-guard.sh >/dev/null 2>&1
 bash -c "$FORGE"
 printf '%s' "${J/PreToolUse/PostToolUse}" | human CLAUDE_PROJECT_DIR="$P" TMPDIR="$T/tmp" bash .ai/hooks/hook-approvals-guard.sh >/dev/null 2>&1)
R=$(gg "$P" "git commit -m report")
if [ -f "$P/.ai/approvals/session-05-close.json" ] && [ "${R%%|*}" = 2 ] && has "$R" 'does not count'; then
  ok "F125 a close record forged through Bash is voided by the before/after check; the commit stays blocked ('does not count')"
else bad "F125 forged record: rc=${R%%|*}"$'\n'"$R"$'\n'"$(cat "$P/.ai/approvals/voided.json" 2>&1)"; fi

# --- 6 (N17): a branch with no session number uses HEAD's committed .ai/SESSION + 1 ---
P=$(project "$VAJRA" n17); (cd "$P" && human git checkout -qb notes && echo 9 > .ai/SESSION)
R=$(gg "$P" "git commit -am notes")
PO=$(project "$VAJRA" n17-old)
(cd "$PO" && human git checkout -qb session-05-x)
OC=$(hook "$PO" "$OLD_WT/scripts/hook-pre-bash.sh" "$T/new-bin" Bash command "git commit -am notes")   # positive control
(cd "$PO" && human git checkout -qb notes)
O=$(hook "$PO" "$OLD_WT/scripts/hook-pre-bash.sh" "$T/new-bin" Bash command "git commit -am notes")
if [ "${R%%|*}" = 2 ] && has "$R" 'Ground Truth Session 5' && [ "${O%%|*}" = 0 ] && [ "${OC%%|*}" = 2 ]; then
  ok "N17 on a branch named 'notes' (HEAD's .ai/SESSION = 4; the working-tree file edited to 9) the commit is blocked as session 5; at $OLD_SHA it passed"
else bad "N17: new=${R%%|*} old=${O%%|*}"$'\n'"$R"; fi

# --- 7 (F125): --sync-fleet adds and wires the guard in a project made by the old binary ---
P=$(project "$OLD_VAJRA" sync)
(cd "$P" && human "$VAJRA" init --sync-fleet </dev/null >/dev/null 2>&1)
R=$(gg "$P" "git commit -m report")
if [ -f "$P/.ai/hooks/hook-ground-truth-guard.sh" ] && [ "${R%%|*}" = 2 ] \
   && jq -e '[.hooks.PreToolUse[] | select(.matcher|test("NotebookEdit")) | .hooks[].command] | any(test("hook-ground-truth-guard"))' "$P/.claude/settings.json" >/dev/null; then
  ok "F125 '--sync-fleet' on a project scaffolded at $OLD_SHA ships the guard, wires it in the Bash|Edit|Write group, and it blocks"
else bad "F125 sync: rc=${R%%|*} $(jq -c '.hooks.PreToolUse' "$P/.claude/settings.json" 2>&1)"; fi

# --- 7b (F125, review rec 1 — founder: fix it now): a branch with ANOTHER session's number is refused ---
P=$(project "$VAJRA" wrongnum)
B1=$(gg "$P" "git checkout -b session-06-x"); B2=$(gg "$P" "git switch -c session-201-report")
B3=$(gg "$P" "git branch session-06-x && git checkout session-06-x"); B4=$(gg "$P" "git checkout -b session-05-report")
O=$(hook "$P" "$OLD_WT/scripts/hook-pre-bash.sh" "$T/new-bin" Bash command "git checkout -b session-06-x")
if [ "${B1%%|*}" = 2 ] && [ "${B2%%|*}" = 2 ] && [ "${B3%%|*}" = 2 ] && [ "${B4%%|*}" = 0 ] && has "$B1" "another session's branch" \
   && [ "${O%%|*}" = 0 ]; then
  ok "F125 during ground truth 5: making or moving to session-06 / session-201 branches is refused, session-05-report is not; at $OLD_SHA nothing refused it"
else bad "F125 wrong number: b1=${B1%%|*} b2=${B2%%|*} b3=${B3%%|*} own=${B4%%|*} old=${O%%|*}"$'\n'"$B1"; fi

# --- 7c (review recs 2 + 4): a project's own scripts/ code is not writable; an unknown tool name is judged by shape ---
S1=$(hook "$P" "$P/.ai/hooks/hook-ground-truth-guard.sh" "$T/new-bin" Write file_path "$P/scripts/build.sh")
S2=$(hook "$P" "$P/.ai/hooks/hook-ground-truth-guard.sh" "$T/new-bin" Write file_path "$P/scripts/verify-session-05.sh")
U1=$(hook "$P" "$P/.ai/hooks/hook-ground-truth-guard.sh" "$T/new-bin" SomeNewShell command "git commit -m x")
(cd "$P" && human git checkout -qb session-05-y)
OS=$(hook "$P" "$OLD_WT/scripts/hook-pre-write.sh" "$T/new-bin" Write file_path "$P/scripts/build.sh")
if [ "${S1%%|*}" = 2 ] && [ "${S2%%|*}" = 0 ] && [ "${U1%%|*}" = 2 ] && [ "${OS%%|*}" = 0 ]; then
  ok "F125 scripts/build.sh is blocked, the session's verify script is not; an unknown tool carrying a command is judged as Bash; at $OLD_SHA scripts/ was open even on a plain session-05 branch"
else bad "F125 allowlist/tool: build=${S1%%|*} verify=${S2%%|*} unknown=${U1%%|*} old-plain=${OS%%|*}"$'\n'"$S1"$'\n'"$U1"; fi

# --- 8 (F116, AC2): an approval record that is not in git is named until it is committed ---
P=$(project "$VAJRA" f116 6); founder "$P" "$VAJRA" approve 7
S1=$(cd "$P" && human "$VAJRA" next --steps 7 2>&1 | grep 'founder has approved')
(cd "$P" && human git add .ai/approvals/session-07.json && gitc commit -qm approval)
S2=$(cd "$P" && human "$VAJRA" next --steps 7 2>&1 | grep 'founder has approved')
P=$(project "$VAJRA" f116-old 6); founder "$P" "$VAJRA" approve 7
SO=$(cd "$P" && human "$OLD_VAJRA" next --steps 7 2>&1 | grep 'founder has approved')
if has "$S1" '✓' && has "$S1" '.ai/approvals/session-07.json is not in git yet' && has "$S2" '✓' && ! has "$S2" 'not in git' \
   && has "$SO" '✓' && ! has "$SO" 'not in git'; then
  ok "F116 '--steps' names .ai/approvals/session-07.json while it is not committed, and stops once it is; at $OLD_SHA it said nothing"
else bad "F116:"$'\n'"before: $S1"$'\n'"after: $S2"$'\n'"old: $SO"; fi

# --- 9 (F119, AC4): design-significant: no → ✓ at --steps, READY at --check-design ---
P=$(project "$VAJRA" f119 6)
printf '# Session 7\n## Type\nsession_type: CODE\n## Goal\nfix one thing\n## Design\ndesign-significant: no\n' > "$P/prompts/07-task-fix.md"
D1=$(cd "$P" && human "$VAJRA" next --steps 7 2>&1 | grep 'the design is recorded')
C1=$(cd "$P" && human "$VAJRA" next --check-design 7 2>&1 | grep '^verdict:')
DO=$(cd "$P" && human "$OLD_VAJRA" next --steps 7 2>&1 | grep 'the design is recorded')
if has "$D1" '✓' && [ "$C1" = "verdict: READY" ] && has "$DO" '✗'; then
  ok "F119 a 'design-significant: no' prompt: '--steps' ✓ design, '--check-design' READY; at $OLD_SHA '--steps' said ✗"
else bad "F119: steps='$D1' check='$C1' old='$DO'"; fi

# --- 10 (N10, AC5): scaffold-drift exits 0 on Vajra; an unmarked or reason-less hollow grep still fails check 6 ---
OUT=$(bash scripts/scaffold-drift.sh --bin "$VAJRA" 2>&1); RC=$?
WT="$T/wt"; git worktree add -q --detach "$WT" HEAD >/dev/null 2>&1
printf '#!/usr/bin/env bash\ngrep -q fn src/main.rs && echo ok\n' > "$WT/scripts/verify-session-9001.sh"  # source-claim: writes a fixture file, runs nothing
printf '#!/usr/bin/env bash\ngrep -q fn src/main.rs && echo ok  # source-claim:\n' > "$WT/scripts/verify-session-9002.sh"  # source-claim: writes a fixture file, runs nothing
NEG=$(CLAUDE_PROJECT_DIR="$WT" bash "$WT/scripts/scaffold-drift.sh" --bin "$VAJRA" 2>&1)
# The old check-6 rule, run over this repo's verify scripts. (Not over $OLD_WT: check 6 sorts on the 3rd
# dash-separated field of the FULL path, and the old checkouts' folder name has dashes — filed as N18.)
OLD=$(CLAUDE_PROJECT_DIR="$ROOT" bash "$OLD_WT/scripts/scaffold-drift.sh" --bin "$OLD_VAJRA" 2>&1); ORC=$?
C6='no hollow src/*.rs grep'  # source-claim: check 6's own message text, matched in its output below
if [ "$RC" = 0 ] && has "$OUT" "${C6}s in last 10 verify scripts" \
   && has "$NEG" "$C6 in verify-session-9001.sh" && has "$NEG" "$C6 in verify-session-9002.sh" \
   && [ "$ORC" != 0 ] && has "$OLD" "$C6 in verify-session-189.sh"; then
  ok "N10 scaffold-drift exits 0 here; an unmarked grep and a marker with no why still fail check 6; at $OLD_SHA it failed on verify-189's display count"
else bad "N10: rc=$RC old-rc=$ORC"$'\n'"$(printf '%s\n' "$OUT" | grep -A2 -- '--- 6')"$'\n'"$(printf '%s\n' "$NEG" | grep -A4 -- '--- 6')"; fi

echo ""
echo "=== verify-session-197: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
