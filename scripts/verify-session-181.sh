#!/usr/bin/env bash
# Session 181 verify — close the loopholes, five parts. Every check RUNS the real thing: the compiled
# binary, the real hook and gate scripts, and the Rust test binaries that drive them. Nothing here
# greps source for a claim. OLD = the commit S181 started from (e003dd1, pinned — never `main`).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
OLD_SHA=e003dd1

cargo build --release -q 2>/dev/null || { bad "release build failed"; exit 1; }
NEW="$ROOT/target/release/vajra"

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

# --- Part 1 -------------------------------------------------------------------------------------------
t "P1 --help probes + dry-run test that can fail (AC1)" cli_front_door
"$NEW" --help 2>&1 | grep -q "not \`claude\`" && ok "P1 top-level --help names the claude exception" || bad "P1 --help wording"

# --- Part 2: ONE cadence answer, real sites, old vs new -------------------------------------------------
t "P2 shared helper; 5 real sites; S181 not GT, S185 GT with key 180; passed override rolls + says so (AC2)" gt_cadence_shared
t "P2 scaffold gate reads the same helper" scaffold_gt_cadence
# old vs new on the real Stop hook: key 180 + its report present, on branch session-185-x
r="$T/r"; mkdir -p "$r/.ai" "$r/sessions"; ( cd "$r" && git init -q && git checkout -q -b session-185-x )
printf 'maturity: L2\nsession:\n  ground_truth_next_session: 180\n' > "$r/.ai/CONSTRAINTS.yaml"
echo x > "$r/sessions/session-180-ground-truth.md"
git show "$OLD_SHA:scripts/hook-stop.sh" > "$T/old-stop.sh"
o="$(CLAUDE_PROJECT_DIR="$r" bash "$T/old-stop.sh" 2>&1)"
n="$(CLAUDE_PROJECT_DIR="$r" bash scripts/hook-stop.sh 2>&1)"
if ! grep -q "Ground Truth Session 185" <<<"$o" && grep -q "Ground Truth Session 185" <<<"$n"; then
  ok "P2 old vs new: with the key still 180, OLD never sees S185 as ground truth (the loophole), NEW does"
else
  bad "P2 old vs new cadence: old=[$o] new=[$n]"
fi

# --- Part 3 ----------------------------------------------------------------------------------------------
t "P3 session_type: strict enum, fails closed, loud legacy fallback, both gates; missing lib fails; project boundary (AC3)" session_type_gate

# --- Part 4 ----------------------------------------------------------------------------------------------
t "P4 approve refused marked / without a terminal, works from a terminal; agent can't use the launch yes; hooks (AC4)" approval_cli
d="$T/a"; mkdir -p "$d"
( cd "$d" && "$NEW" approve 181 </dev/null >/dev/null 2>"$T/err"; echo "rc=$?" >"$T/rc" )
if grep -q "rc=1" "$T/rc" && grep -q "not a terminal" "$T/err" && [ ! -e "$d/.ai" ]; then
  ok "P4 the release binary refuses \`vajra approve 181\` with no terminal and writes nothing"
else
  bad "P4 approve without terminal"
fi
if cargo test -q --lib analyst 2>&1 | grep -qE "test result: ok\. [0-9]+ passed; 0 failed"; then
  ok "P4 gate ignores a typed APPROVED after 180, reads the record (analyst unit tests)"
else
  bad "P4 analyst gate tests"
fi

# --- Part 5 ----------------------------------------------------------------------------------------------
t "P5 named waivers: one name waives one check; no reason refused; launch-time vs later; legacy warns (AC5)" named_waivers
t "P5 stamp bound to text at the fidelity + mandate gates, real capture (AC5)" stamp_gate
if cargo test -q --lib dispatch 2>&1 | grep -qE "test result: ok\. [0-9]+ passed; 0 failed"; then
  ok "P5 stamp unit tests (edit kills it; legacy fallback dated + loud)"
else
  bad "P5 dispatch tests"
fi

# --- whole suite ---------------------------------------------------------------------------------------------
# S182 Part 1: a POSITIVE check. The old one passed when no `test result` line printed at all, so a suite
# that failed to compile was green. Now: cargo exits 0, at least one `test result: ok`, and no FAILED.
# The S182 verify script runs this function against a stub `cargo` that fails to compile (must go red).
whole_suite_check() {
  local out rc=0
  out=$(cargo test -q 2>&1) || rc=$?
  if [ "$rc" -ne 0 ]; then echo "cargo test exited $rc"; return 1; fi
  if ! printf '%s\n' "$out" | grep -qE 'test result: ok\. [0-9]+ passed'; then echo "no 'test result: ok' line"; return 1; fi
  if printf '%s\n' "$out" | grep -qE 'FAILED|test result: FAILED'; then echo "a FAILED line"; return 1; fi
  return 0
}
if why=$(whole_suite_check); then
  ok "full cargo test: exit 0, suites ran, none FAILED"
else
  bad "full cargo test: $why"
fi

echo; echo "=== Session 181 Verify Summary ==="
if [ "$FAIL" -eq 0 ]; then echo "GREEN ($PASS pass, 0 fail)"; exit 0; else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
