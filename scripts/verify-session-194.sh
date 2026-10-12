#!/usr/bin/env bash
# Session 194 verify — three fixes from rudra S20 (run on Haiku 4.5, the founder's deliberate cheap-model test).
#   F121: rudra's close check went RED (17 pass, 5 fail) and only the agent saw it; it told the founder "fully
#         closed". The close script now writes one fixed-format `result` file and `vajra claude`'s exit box
#         shows it (ADR-0004 S194 addendum).
#   F123: `git merge --no-ff` on main went through — a merge commit runs pre-merge-commit, never pre-commit.
#         Vajra now ships `.githooks/pre-merge-commit` (DECISION-007 S194 addendum).
#   F120: `vajra next --role --from` wrote a helper's raw transcript (the user's email, its system prompt)
#         into the handoff. It now refuses one (DECISION-007 S194 addendum).
# Every check RUNS the real thing: the real `vajra init` / `vajra claude` / `vajra next` binary in a temp
# project, a stand-in `claude` that runs the project's own scaffolded close check, real `git merge`. Each fix
# runs again at the commit S194 started from (7e8210e), where it must go red for its own reason (S122).
# Nothing greps Vajra's source; rudra is never touched.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(cd "$(mktemp -d)" && pwd -P)"
trap 'vajra_old_checkout_remove "${OLD_WT:-}"; rm -rf "$T"' EXIT
OLD_SHA=7e8210e
VAJRA="$ROOT/target/release/vajra"
cargo build --release -q || { echo "FAIL: cargo build --release"; exit 1; }
. "$ROOT/scripts/lib-old-checkout.sh"
OLD_WT=$(vajra_old_checkout "$OLD_SHA") || { echo "FAIL: worktree at $OLD_SHA"; exit 1; }
(cd "$OLD_WT" && CARGO_TARGET_DIR="$ROOT/target/s194-old" cargo build --release -q) || { echo "FAIL: build at $OLD_SHA"; exit 1; }
OLD_VAJRA="$ROOT/target/s194-old/release/vajra"

# The test itself may run inside Claude Code; setup commits are the human's, so every agent marker is dropped.
human() { env -u CLAUDECODE -u CLAUDE_CODE_ENTRYPOINT -u CURSOR_TRACE_ID -u VAJRA_AGENT -u VAJRA_ALLOW_COMMIT \
            GIT_CONFIG_GLOBAL=/dev/null "$@"; }
# project BIN NAME → a fresh git project on main (one empty commit) scaffolded by that binary's `vajra init`.
project() {
  local p="$T/$2"; rm -rf "$p"; mkdir -p "$p"
  (cd "$p" && human git init -q -b main && human git -c user.email=t@t -c user.name=t commit -q --allow-empty -m init \
     && human "$1" init >/dev/null 2>&1)
  printf '%s' "$p"
}

# The stand-in `claude`: writes no Claude Code log (so the receipt has no cost — the close line must not
# depend on it) and, with STUB_CLOSE=1, runs the project's own scaffolded close check the way an agent does.
mkdir -p "$T/bin"
cat > "$T/bin/claude" <<'STUB'
#!/usr/bin/env bash
[ -n "${STUB_CLOSE:-}" ] && bash scripts/verify-closeout.sh >/dev/null 2>&1
exit 0
STUB
chmod +x "$T/bin/claude"
# launch BIN DIR [ENV=..]... → the exit box (stderr) of one `vajra claude` run in DIR.
launch() {
  local bin="$1" dir="$2"; shift 2
  (cd "$dir" && env HOME="$T/home-$(basename "$dir")" PATH="$T/bin:$(dirname "$bin"):$PATH" VAJRA_SKIP_AUTH_CHECK=1 \
     "$@" "$bin" claude 2>&1 >/dev/null </dev/null)
}
has() { printf '%s\n' "$1" | grep -qF -- "$2"; }

# --- 1 (F121): rudra S20's shape — the agent runs the close check, it goes RED, the run ends ---
P=$(project "$VAJRA" f121); NEW=$(launch "$VAJRA" "$P" STUB_CLOSE=1)
R=$(ls -d "$P"/.ai/verify/closeout/2*/ 2>/dev/null | tail -1)
LINE=$(printf '%s\n' "$NEW" | grep '^ close check: ')
if printf '%s\n' "$LINE" | grep -qE '^ close check: RED — [0-9]+ of [0-9]+ failed \(.*required-crew.*\) · \.ai/verify/closeout/[0-9]{8}T[0-9]{6}Z$' \
   && has "$NEW" 'no receipt'; then
  ok "F121 exit box: '$(printf '%s' "$LINE" | sed 's/^ //' | cut -c1-70)…' — shown with no cost log at all"
else bad "F121 exit box now:"$'\n'"$NEW"; fi
if [ -n "$R" ] && sed -n 1p "$R/result" | grep -qx 'vajra-closeout-result: 1' && grep -qx 'verdict: RED' "$R/result" \
   && grep -q '^failed: .*required-crew' "$R/result" \
   && [ "$(sed -n 's/^fail: //p' "$R/result")" = "$(sed -n 's/^failed: //p' "$R/result" | wc -w | tr -d ' ')" ]; then
  ok "F121 the project's scaffolded close check wrote $(basename "$R")/result: verdict RED, fail = the number of names on 'failed:'"
else bad "F121 result file: $(cat "$R/result" 2>&1)"; fi
P=$(project "$OLD_VAJRA" f121-old); OLD=$(launch "$OLD_VAJRA" "$P" STUB_CLOSE=1)
R=$(ls -d "$P"/.ai/verify/closeout/2*/ 2>/dev/null | tail -1)
if [ -n "$R" ] && [ ! -e "$R/result" ] && ! has "$OLD" 'close check'; then
  ok "F121 red at $OLD_SHA: the close check ran ($(basename "$R")) but wrote no result, and the exit box said nothing of it"
else bad "F121 at $OLD_SHA:"$'\n'"$OLD"; fi

# --- 2 (F121 control): no close check during the run → it says so, never GREEN ---
P=$(project "$VAJRA" f121-none); NEW=$(launch "$VAJRA" "$P")
if has "$NEW" ' close check: not run during this run' && ! has "$NEW" 'GREEN'; then
  ok "F121 control: a run with no close check says 'close check: not run during this run'"
else bad "F121 control:"$'\n'"$NEW"; fi

# --- 3 (F123): a merge commit on main — the agent's `git merge --no-ff` in rudra S20 ---
merge_on_main() {   # merge_on_main DIR → the merge's output; prints MOVED if main moved
  (cd "$1" && human git checkout -qb session-01-x && echo x > work.txt && human git add -A \
     && human git -c user.email=t@t -c user.name=t commit -q --no-verify -m work && human git checkout -q main \
     && before=$(git rev-parse HEAD) \
     && CLAUDECODE=1 VAJRA_ALLOW_COMMIT=01 GIT_CONFIG_GLOBAL=/dev/null git -c user.email=t@t -c user.name=t \
          merge --no-ff -m merge session-01-x 2>&1; [ "$(git rev-parse HEAD)" != "$before" ] && echo MOVED)
}
P=$(project "$VAJRA" f123); NEW=$(merge_on_main "$P")
if [ -x "$P/.githooks/pre-merge-commit" ] && [ "$(cd "$P" && git config core.hooksPath)" = .githooks ] \
   && has "$NEW" "Vajra stopped this merge: you are on 'main'" && ! has "$NEW" MOVED; then
  ok "F123 a fresh project: 'git merge --no-ff' on main (agent, approved for session 01) is stopped; main did not move"
else bad "F123 now:"$'\n'"$NEW"; fi
P=$(project "$OLD_VAJRA" f123-old); OLD=$(merge_on_main "$P")
if [ ! -e "$P/.githooks/pre-merge-commit" ] && has "$OLD" MOVED; then
  ok "F123 red at $OLD_SHA: no pre-merge-commit was scaffolded and the merge commit landed on main"
else bad "F123 at $OLD_SHA:"$'\n'"$OLD"; fi

# --- 4 (F123): an existing project gets the hook from `vajra init --sync-fleet` (how rudra will) ---
P=$(project "$OLD_VAJRA" f123-sync); SYNC=$(cd "$P" && human "$VAJRA" init --sync-fleet 2>&1)
if [ -x "$P/.githooks/pre-merge-commit" ] && has "$(merge_on_main "$P")" "Vajra stopped this merge"; then
  ok "F123 sync: a project scaffolded at $OLD_SHA gets an executable pre-merge-commit from --sync-fleet, and it stops the merge"
else bad "F123 sync:"$'\n'"$SYNC"; fi

# --- 5 (F123): the hook ships in the package (include_str! would break `cargo install` without it) ---
if cargo package --list --allow-dirty 2>/dev/null | grep -qx '.githooks/pre-merge-commit' \
   && ! git -C "$OLD_WT" ls-files --error-unmatch .githooks/pre-merge-commit >/dev/null 2>&1; then
  ok "F123 package: '.githooks/pre-merge-commit' is in cargo package --list (not in the tree at $OLD_SHA)"
else bad "F123 package list"; fi

# --- 6 (F120): a helper's raw transcript given to `vajra next --role --from` ---
role() {   # role BIN NAME → output; prints WRITTEN if a handoff file appeared
  local p="$T/$2"; rm -rf "$p"; mkdir -p "$p/.ai" "$p/projects"; echo 194 > "$p/.ai/SESSION"
  (cd "$p" && human git init -q -b session-194-x \
     && printf '%s\n' '{"parentUuid":null,"sessionId":"s1","type":"user","message":{"role":"user","content":"brief"}}' \
          '{"parentUuid":"a","sessionId":"s1","type":"attachment","attachment":{"context":{"userEmail":"someone@example.com"}}}' > agent.output \
     && VAJRA_CLAUDE_PROJECTS_DIR="$p/projects" "$1" next --role tech-lead --from agent.output 2>&1; \
     [ -e .ai/handoffs/session-194-tech-lead.md ] && echo WRITTEN)
}
NEW=$(role "$VAJRA" f120); OLD=$(role "$OLD_VAJRA" f120-old)
if has "$NEW" 'is a transcript, not a findings brief' && ! has "$NEW" WRITTEN; then
  ok "F120 a transcript is refused and no handoff is written"
else bad "F120 now:"$'\n'"$NEW"; fi
if has "$OLD" WRITTEN && grep -qF 'someone@example.com' "$T/f120-old/.ai/handoffs/session-194-tech-lead.md"; then
  ok "F120 red at $OLD_SHA: the transcript was written into the handoff, the email with it"
else bad "F120 at $OLD_SHA:"$'\n'"$OLD"; fi

# --- AC3: rudra S20's receipt against Claude Code's own total — a RECORD, not a check (S193 review rec 3) ---
# Read on 2026-10-12 from the founder's run log, which stays on his machine (S126). Nothing here can re-read
# it, so this line cannot fail and is not counted as a pass.
echo "RECORD: AC3 rudra S20 (fresh run, Haiku 4.5): receipt '\$1.49 … Claude Code's own figure' and nothing else in the box · cost-state totalCostUSD 1.4903203999999999 · ~/.claude.json lastCost 1.4903203999999999"
echo "KNOWN GAP (named, not closed): a fast-forward, reset --hard, branch -f, update-ref or 'git merge --no-verify' moves main with no hook; pre-push still stops the push."

echo "----"
echo "verify-session-194: $PASS passed, $FAIL failed (plus 1 RECORD line, not a check)"
[ "$FAIL" = 0 ]
