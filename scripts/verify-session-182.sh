#!/usr/bin/env bash
# Session 182 verify — ship S181's controls into existing projects. Every check RUNS the real thing:
# the real hook scripts with the JSON Claude Code sends, the Rust test binaries, a stub `cargo`, and
# the guard rudra's own settings register. Nothing here greps source for a claim.
# OLD = the commit S182 started from (e5db703, pinned — never `main`).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
OLD_SHA=e5db703
APPR=".ai/approvals"

# t NAME TESTFILE — run one integration-test binary; PASS only if cargo says every test in it passed
t() {
  local n="$1" f="$2" out
  out="$(cargo test -q --test "$f" 2>&1)"
  if grep -qE "test result: ok\. [1-9][0-9]* passed; 0 failed" <<<"$out"; then
    ok "$n ($(grep -oE '[0-9]+ passed' <<<"$out" | head -1))"
  else
    bad "$n"; echo "$out" | tail -15
  fi
}
# hook SCRIPT PROJECT TOOL-JSON-INPUT → the hook's exit code for that tool call
hook() { printf '{"tool_name":"%s","tool_input":%s}' "$3" "$4" | CLAUDE_PROJECT_DIR="$2" bash "$1" >/dev/null 2>&1; echo $?; }
P="$T/p"; mkdir -p "$P/.ai"; echo "maturity: L2" > "$P/.ai/CONSTRAINTS.yaml"

# --- Part 6 (AC7): the guard blocks writes, not reads — old vs new on the real hook -----------------
t "P6 every write blocks, reads pass, every command the S181 guard blocked still blocks, no-jq L1 advises (AC7)" approvals_guard
git show "$OLD_SHA:scripts/hook-pre-bash.sh" > "$T/old-pre-bash.sh"
READ="{\"command\":\"cat $APPR/x 2>&1\"}"
o=$(hook "$T/old-pre-bash.sh" "$P" Bash "$READ"); n=$(hook scripts/hook-pre-bash.sh "$P" Bash "$READ")
[ "$o" = 2 ] && [ "$n" = 0 ] && ok "P6 a read with 2>&1: blocked at $OLD_SHA, passes now (AC7)" || bad "P6 read old=$o new=$n"
W="{\"command\":\"echo x 2>&1 > $APPR/x\"}"
n=$(hook scripts/hook-pre-bash.sh "$P" Bash "$W")
[ "$n" = 2 ] && ok "P6 a redirect into the folder after a 2>&1 still blocks (AC7)" || bad "P6 write exit $n"

# --- Part 1 (AC1): the whole-suite check goes red on a suite that cannot compile ---------------------
fn=$(sed -n '/^whole_suite_check()/,/^}/p' scripts/verify-session-181.sh)
mkdir -p "$T/bin"
stub() { printf '#!/bin/sh\n%s\n' "$1" > "$T/bin/cargo"; chmod +x "$T/bin/cargo"; PATH="$T/bin:$PATH" bash -c "$fn; whole_suite_check" >/dev/null; echo $?; }
r=$(stub 'echo "error: could not compile vajractl"; exit 101')
[ "$r" = 1 ] && ok "P1 stub cargo that cannot compile → whole-suite check RED (AC1)" || bad "P1 compile-fail stub returned $r"
r=$(stub 'echo "test x ... FAILED"; echo "test result: ok. 1 passed; 0 failed"; exit 0')
[ "$r" = 1 ] && ok "P1 a cargo FAILED test line → RED" || bad "P1 FAILED-line stub returned $r"
r=$(stub 'echo "  1 of 1 live checks FAILED"; echo "test result: ok. 3 passed; 0 failed"; exit 0')
[ "$r" = 0 ] && ok "P1 a test that prints the word FAILED as its own output → still GREEN" || bad "P1 word-FAILED stub returned $r"
old=$(git show "$OLD_SHA:scripts/verify-session-181.sh" | sed -n '/whole suite/,/^fi/p' | tail -n +2)
printf '#!/bin/sh\necho "error: could not compile vajractl"\nexit 101\n' > "$T/bin/cargo"
r=$(PATH="$T/bin:$PATH" bash -c "ok(){ echo GREEN; }; bad(){ echo RED; }; $old")
[ "$r" = GREEN ] && ok "P1 the same stub at $OLD_SHA was GREEN (the hollow check, shown)" || bad "P1 old check said $r"
if why=$(bash -c "$fn; whole_suite_check"); then ok "P1 the real whole suite: exit 0, suites ran, none FAILED"; else bad "P1 real suite: $why"; fi

# --- Part 2 (AC2) -------------------------------------------------------------------------------------
t "P2 edit a judge's obeyed-check findings → --check-obeyed blocks, end to end (AC2)" stamp_gate

# --- Parts 3–4 (AC3, AC4) -----------------------------------------------------------------------------
t "P3/P4 new project guarded via settings; --sync-fleet wires an old one; reports, never writes, session_rules_from (AC3, AC4)" approvals_scaffold

# --- Part 5 (AC5) -------------------------------------------------------------------------------------
t "P5 a bare --allow-all is refused before launch; an agent cannot use it (AC5)" approval_cli
if cargo test -q --lib approval::tests::allow_all_approves_only_the_session_it_names 2>&1 | grep -qE "test result: ok\. 1 passed"; then
  ok "P5 an --allow-all=A record does not approve session B (AC5)"
else
  bad "P5 allow-all session binding"
fi

# --- Part 7 (AC8): rudra, live — SKIPPED (never PASS) when rudra is absent ----------------------------
R=/Users/suman/playground/rudra
if [ -d "$R/.ai" ]; then
  c=$(jq -r '[.hooks.PreToolUse[].hooks[].command | select(contains("hook-approvals-guard"))] | length' "$R/.claude/settings.json" 2>/dev/null)
  [ "$c" = 1 ] && ok "P7 rudra's settings register the approvals guard exactly once (AC8)" || bad "P7 rudra registrations: $c"
  cmd=$(jq -r '[.hooks.PreToolUse[].hooks[].command | select(contains("hook-approvals-guard"))][0]' "$R/.claude/settings.json" 2>/dev/null)
  e=$(printf '{"tool_name":"Bash","tool_input":{"command":"echo x > %s/session-16.json"}}' "$APPR" | (cd "$R" && CLAUDE_PROJECT_DIR="$R" bash -c "$cmd" >/dev/null 2>&1); echo $?)
  [ "$e" = 2 ] && ok "P7 rudra's registered guard blocks an agent write (exit 2) (AC8)" || bad "P7 rudra guard exit $e"
  grep -qE '^[[:space:]]*session_rules_from:[[:space:]]*[0-9]+' "$R/.ai/CONSTRAINTS.yaml" \
    && ok "P7 rudra's .ai/CONSTRAINTS.yaml names session_rules_from (AC8)" || bad "P7 rudra has no session_rules_from"
else
  echo "SKIPPED: P7 rudra is not on this machine — the live evidence is in sessions/session-182-summary.md"
fi

echo; echo "=== Session 182 Verify Summary ==="
if [ "$FAIL" -eq 0 ]; then echo "GREEN ($PASS pass, 0 fail)"; exit 0; else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
