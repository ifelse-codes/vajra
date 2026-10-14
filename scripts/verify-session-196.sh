#!/usr/bin/env bash
# Session 196 verify — rudra S21 on Opus (the founder's run), and the one fix he said yes to:
#   F127: a RED close stopped nothing — rudra S20's RED branch was pushed, a PR opened and merged. Founder
#         (2026-10-14): "no pr creation till it is not green". `.githooks/pre-push` now stops an AGENT's push of a
#         session branch unless the close check said GREEN for that exact commit; the close result is format 2
#         (head + clean) and the exit box reads it (DECISION-007 + ADR-0004 S196 addenda). A person gets a note.
# Every check RUNS the real thing: the real `vajra init` in a temp project, the project's own scaffolded close
# script, a real `git push` to a real bare remote, a real `vajra claude` exit box. Each row runs again with the
# binary and scaffold from the commit S196 started at (59719f8), where it must go red for its own reason (S122).
# Nothing greps Vajra's source; rudra is never touched.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(cd "$(mktemp -d)" && pwd -P)"
trap 'vajra_old_checkout_remove "${OLD_WT:-}"; rm -rf "$T"' EXIT
OLD_SHA=59719f8
VAJRA="$ROOT/target/release/vajra"
cargo build --release -q || { echo "FAIL: cargo build --release"; exit 1; }
. "$ROOT/scripts/lib-old-checkout.sh"
OLD_WT=$(vajra_old_checkout "$OLD_SHA") || { echo "FAIL: worktree at $OLD_SHA"; exit 1; }
(cd "$OLD_WT" && CARGO_TARGET_DIR="$ROOT/target/s196-old" cargo build --release -q) || { echo "FAIL: build at $OLD_SHA"; exit 1; }
OLD_VAJRA="$ROOT/target/s196-old/release/vajra"

# The script may run inside Claude Code; setup is the human's, so every agent marker is dropped.
human() { env -u CLAUDECODE -u CLAUDE_CODE_ENTRYPOINT -u CURSOR_TRACE_ID -u VAJRA_AGENT -u VAJRA_ALLOW_COMMIT \
            -u CLAUDE_PROJECT_DIR GIT_CONFIG_GLOBAL=/dev/null "$@"; }
agent() { human CLAUDECODE=1 "$@"; }
has() { printf '%s\n' "$1" | grep -qF -- "$2"; }

# project BIN NAME → a `vajra init` project (that binary's scaffold, hooks wired by init) on session-01-x with
# one commit, and a bare remote at NAME.git.
project() {
  local p="$T/$2"; rm -rf "$p" "$p.git"; mkdir -p "$p"
  (cd "$p" && human git init -q -b main && human "$1" init </dev/null >/dev/null 2>&1 \
     && echo 1 > .ai/SESSION && human git checkout -qb session-01-x && human git add -A \
     && human git -c user.email=t@t -c user.name=t commit -qm init \
     && human git init -q --bare "$p.git" && human git remote add origin "$p.git")
  printf '%s' "$p"
}
arrived() { human git --git-dir "$1.git" rev-parse -q --verify "refs/heads/$2" >/dev/null 2>&1; }
# green P [SHA] → a format-2 GREEN result for SHA (default HEAD), as the close scripts write it.
green() {
  local sha="${2:-$(cd "$1" && human git rev-parse HEAD)}" d="$1/.ai/verify/closeout/20990101T000000Z"
  mkdir -p "$d"
  printf 'vajra-closeout-result: 2\nsession: 1\nhead: %s\nclean: yes\nverdict: GREEN\npass: 20\nfail: 0\nwarn: 1\nfailed: \n' "$sha" > "$d/result"
}
close() { (cd "$1" && human PATH="$(dirname "$2"):$PATH" bash scripts/verify-closeout.sh 1 >/dev/null 2>&1); }

# --- 1 (F127): rudra S20's shape — the project's own close check goes RED, the agent pushes ---
P=$(project "$VAJRA" red); close "$P" "$VAJRA"
OUT=$(cd "$P" && agent git push -q origin session-01-x 2>&1); RC=$?
R=$(ls -d "$P"/.ai/verify/closeout/2*/ 2>/dev/null | tail -1)
if [ "$RC" != 0 ] && ! arrived "$P" session-01-x && has "$OUT" 'the close check is RED' && has "$OUT" 'until it says GREEN' \
   && sed -n 3p "$R/result" | grep -qx "head: $(cd "$P" && human git rev-parse HEAD)"; then
  ok "F127 the agent's push of a RED session branch is refused; the branch never reaches the remote (result $(basename "$R"), head = HEAD)"
else bad "F127 RED push now (rc $RC):"$'\n'"$OUT"$'\n'"$(cat "$R/result" 2>&1)"; fi
P=$(project "$OLD_VAJRA" red-old); close "$P" "$OLD_VAJRA"
OUT=$(cd "$P" && agent git push -q origin session-01-x 2>&1); RC=$?
if [ "$RC" = 0 ] && arrived "$P" session-01-x; then
  ok "F127 red at $OLD_SHA: the same RED branch reached the remote — a PR could open from it"
else bad "F127 at $OLD_SHA (rc $RC):"$'\n'"$OUT"; fi

# --- 2 (F127): GREEN for this exact commit lets it through; a commit after the GREEN does not ---
P=$(project "$VAJRA" green); green "$P"
OUT=$(cd "$P" && agent git push -q origin session-01-x 2>&1); RC=$?
if [ "$RC" = 0 ] && arrived "$P" session-01-x && has "$OUT" 'GREEN with 1 WARN'; then
  ok "F127 a GREEN (with a WARN) for the pushed commit lets the agent's branch through, and says so"
else bad "F127 GREEN push (rc $RC):"$'\n'"$OUT"; fi
P=$(project "$VAJRA" stale); green "$P"
(cd "$P" && echo x > later.txt && human git add later.txt && human git -c user.email=t@t -c user.name=t commit -qm later)
OUT=$(cd "$P" && agent git push -q origin session-01-x 2>&1); RC=$?
if [ "$RC" != 0 ] && ! arrived "$P" session-01-x && has "$OUT" 'a commit landed after it'; then
  ok "F127 a GREEN from before the last commit does not count — 'run it again'"
else bad "F127 stale GREEN (rc $RC):"$'\n'"$OUT"; fi
P=$(project "$OLD_VAJRA" stale-old)
(cd "$P" && echo x > later.txt && human git add later.txt && human git -c user.email=t@t -c user.name=t commit -qm later)
OUT=$(cd "$P" && agent git push -q origin session-01-x 2>&1); RC=$?
if [ "$RC" = 0 ] && arrived "$P" session-01-x; then
  ok "F127 red at $OLD_SHA: a branch with no close check at all reached the remote"
else bad "F127 stale at $OLD_SHA (rc $RC):"$'\n'"$OUT"; fi

# --- 3 (F127, founder's call): his own push of a RED branch is noted and goes on; a non-session branch is free ---
P=$(project "$VAJRA" human); close "$P" "$VAJRA"
OUT=$(cd "$P" && human git push -q origin session-01-x 2>&1); RC=$?
if [ "$RC" = 0 ] && arrived "$P" session-01-x && has "$OUT" 'Note:' && has "$OUT" 'RED' && has "$OUT" 'Pushing anyway'; then
  ok "F127 the founder pushing a RED session branch gets a note naming the RED, and the push goes on"
else bad "F127 human push (rc $RC):"$'\n'"$OUT"; fi
P=$(project "$OLD_VAJRA" human-old); close "$P" "$OLD_VAJRA"
OUT=$(cd "$P" && human git push -q origin session-01-x 2>&1)
if ! has "$OUT" 'RED'; then
  ok "F127 red at $OLD_SHA: the founder's RED push said nothing about the close"
else bad "F127 human at $OLD_SHA:"$'\n'"$OUT"; fi
P=$(project "$VAJRA" free)
OUT=$(cd "$P" && human git checkout -qb quick-fix && agent git push -q origin quick-fix 2>&1); RC=$?
if [ "$RC" = 0 ] && arrived "$P" quick-fix && [ -z "$OUT" ]; then
  ok "F127 a branch not named session-NN-… is not checked (founder, 2026-09-21)"
else bad "F127 non-session branch (rc $RC):"$'\n'"$OUT"; fi

# --- 4 (F127/F121): the exit box reads the new format; the binary from 59719f8 cannot ---
mkdir -p "$T/bin"
printf '#!/usr/bin/env bash\nbash scripts/verify-closeout.sh >/dev/null 2>&1\nexit 0\n' > "$T/bin/claude"; chmod +x "$T/bin/claude"
launch() {
  (cd "$2" && human HOME="$T/home-$(basename "$2")" PATH="$T/bin:$(dirname "$1"):$PATH" VAJRA_SKIP_AUTH_CHECK=1 \
     "$1" claude 2>&1 >/dev/null </dev/null)
}
P=$(project "$VAJRA" box); BOX=$(launch "$VAJRA" "$P")
if printf '%s\n' "$BOX" | grep -qE '^ close check: RED — [0-9]+ of [0-9]+ failed \(.*\) · \.ai/verify/closeout/[0-9]{8}T[0-9]{6}Z$'; then
  ok "F127 the exit box reads a format-2 result: '$(printf '%s\n' "$BOX" | grep '^ close check' | cut -c2-60)…'"
else bad "F127 exit box now:"$'\n'"$BOX"; fi
P=$(project "$VAJRA" box-old); BOX=$(launch "$OLD_VAJRA" "$P")
if has "$BOX" 'result unreadable'; then
  ok "F127 red at $OLD_SHA: that binary called a format-2 result unreadable"
else bad "F127 exit box at $OLD_SHA:"$'\n'"$BOX"; fi

# --- RECORDs from rudra S21 (founder's run, read 2026-10-14; the logs stay on his machine, S126) — not checks ---
echo "RECORD: F121 rudra S21 close 20261013T021539Z = GREEN 21 pass · 0 fail · 2 WARN (format 1); exit-box line not pasted by the founder; the box can only have shown after PR #25's merge (~03:17Z; chat ended after 03:24:56Z)"
echo "RECORD: F123 not exercised — rudra main moved only by fast-forward (main@{0}: merge origin/main: Fast-forward)"
echo "RECORD: AC3 Opus S21: 4 Agent calls (tech-lead, design-advisor, qa-specialist, fidelity-reviewer), 18 'vajra next' calls, all 4 handoffs 'verified: toolu_…', close GREEN, last claim 'fully closed' (true) · Haiku S20: 0 / 0 / self-written review / RED / 'FULLY CLOSED' (false)"
echo "RECORD: receipt — cost-state totalCostUSD 19.2086772 = ~/.claude.json lastCost 19.2086772 (fresh launch); vajra's top line not pasted"
echo "KNOWN GAP (named, not closed): the agent can write a GREEN result or type 'git push --no-verify'; untracked files are not counted in clean:; a non-session branch name skips the check (N17 → S197)."

echo "----"
echo "verify-session-196: $PASS passed, $FAIL failed (plus 4 RECORD lines, not checks)"
[ "$FAIL" = 0 ]
