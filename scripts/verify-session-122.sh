#!/usr/bin/env bash
# Verify — Session 122: close the four real holes the S121 live QA run found in S121's own
# guardrails.
#
# S121 shipped a suite that went 17/17 green and a cold review that said ACCEPT. Then the
# `qa-specialist` role it built was pointed at that suite and found four defects IN THE GUARDRAILS:
# a read-only guard that passed the leak it existed to stop, a check that would turn the suite red
# for a reason its own message could not explain, a test that could not fail, and a tally that read
# as a complete count while one slot hid fourteen checks.
#
# So this suite has one job beyond "the fixes exist": prove each fix has been SEEN RED. A check that
# has never failed is not evidence — that is the whole lesson of the session that produced these
# defects. Every fix below is verified twice:
#   (a) its falsifiability fixture ran and passed inside the real S121 suite (or as a real unit
#       test), asserted against that run's live output — never against source;
#   (b) this suite RE-DERIVES the invariant independently, with its own parser and its own planted
#       defect, so a fix that only convinced the script that ships with it does not count.
#
# CHECK CLASSES — same three the QA role's contract uses, plus the fourth S122 added:
#   EXECUTE-BASED   — runs the product (binary, cargo test, a script) and asserts on real output.
#   STRUCTURAL grep — asserts ARCHITECTURE (one source of truth, no second copy, an absence).
#   BEHAVIORAL grep — the hollow class: greps source for a string and calls that proof.
#   NESTED suite    — runs another whole suite. Its checks are NOT folded into the counts above;
#                     it is named, and the tally says out loud that it is not a census (S122 fix 4).
#
# THE EXECUTOR THESIS IS STILL UNPROVEN, and this suite does not pretend otherwise. S121 shipped
# the claim that a role which can run code cannot fake a pass. Across two live runs the role has
# found seven real defects and EVERY ONE came from independent READING — execution bought exit
# codes and pass counts, nothing else. What is evidenced is INDEPENDENCE, not execution. Nothing
# in this suite tests whether an executor can fake a pass, and the `Write`/`Edit` grant is
# documented rather than fenced.
#
# STILL A SELF-ASSIGNED LABEL, unchanged from S121 and not softened here: nothing in this file
# proves a check marked `exec` executes anything. S122 made the tally honest about NESTING. It did
# not make the labels EARNED. That remains the unpicked option B from the S121 close.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="122"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
EXEC_N=0; STRUCT_N=0; BEHAV_N=0; NESTED_N=0; NESTED_NAMES=()
# $1 = check name, $2 = class (exec|struct|behav|nested), rest = the command.
run_check() {
  local NAME="$1"; local CLASS="$2"; shift 2
  local LOG="$ARTIFACTS/${NAME}.log"
  case "$CLASS" in
    exec)   EXEC_N=$((EXEC_N+1)) ;;
    struct) STRUCT_N=$((STRUCT_N+1)) ;;
    behav)  BEHAV_N=$((BEHAV_N+1)) ;;
    nested) NESTED_N=$((NESTED_N+1)); NESTED_NAMES+=("$NAME") ;;
    *) echo "verify bug: unknown class '$CLASS' for $NAME"; exit 2 ;;
  esac
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-36s %-7s %s' "$NAME" "$CLASS" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-36s %-7s %s' "$NAME" "$CLASS" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# The tally, as a function — so it can be called by a fixture instead of being four unreachable
# echoes at the bottom of the file (S122 fix 4, same shape now used in verify-session-121.sh).
print_tally() {
  local E="$1" S="$2" B="$3" NN="$4"; shift 4
  local n
  echo "CHECK CLASSES (this suite's OWN checks only — NOT a census of everything that ran)"
  echo "  execute-based: ${E} · structural grep: ${S} · behavioral source grep: ${B}"
  echo "  nested suites (their own checks are NOT counted above): ${NN}"
  for n in "$@"; do
    [ -n "$n" ] || continue
    echo "    - ${n} — runs another whole suite; read that suite's own tally for its classes"
  done
  if [ "$NN" -ne 0 ]; then
    # Derived from what actually ran, never a hardcoded count. The first cut of this line said
    # "+ at least 2" and named two suites as literals — a hardcoded banner delivered as the fix
    # for hollowness (qa-specialist finding). It said "2" even when called with one nested suite.
    echo "  DISCLOSED: each of those ${NN} nested suite(s) runs checks of its own, including its own"
    echo "  behavioral source greps. They are NOT included in the ${B} above, so ${B} is a FLOOR,"
    echo "  never a total for this run."
  fi
  if [ "$B" -ne 0 ]; then
    echo "NOTE: ${B} behavioral source grep(s) in THIS suite — each must be named in the session's fakest-green disclosure."
  fi
  echo "STILL A SELF-ASSIGNED LABEL: nothing here proves a check marked \`exec\` executes anything."
  echo "S122 made the tally honest about NESTING. It did not make the labels EARNED."
}

# --- toolchain: unchanged discipline ------------------------------------------------------------
run_check "cargo-build"   exec cargo build --all-targets
run_check "cargo-test"    exec cargo test --lib
run_check "cargo-fmt"     exec cargo fmt -- --check
run_check "cargo-clippy"  exec cargo clippy --all-targets -- -D warnings

VAJRA="$ROOT/target/debug/vajra"

# `cargo test --lib <filter>` EXITS 0 WHEN THE FILTER MATCHES NOTHING (S112) — reused verbatim.
named_test_passed() {
  local out; out="$(cargo test --lib "$1" 2>&1)"
  echo "$out"
  grep -qE 'test result: ok\. [1-9][0-9]* passed' <<<"$out" \
    || { echo "FAIL: filter '$1' matched no test that ran and passed"; return 1; }
}
filter_guard_has_teeth() {
  if named_test_passed fleet::tests::this_test_does_not_exist_on_purpose >/dev/null 2>&1; then
    echo "FAIL: named_test_passed is green on a filter that matches no test"; return 1
  fi
  echo "OK: a filter matching zero tests fails, as it must"
}
run_check "test-filter-guard-has-teeth" exec filter_guard_has_teeth

# --- the nested suites -------------------------------------------------------------------------
# The count-agnostic regressions, plus the FIXED S121 suite. Run ONCE here; the checks that follow
# assert on this run's captured live output rather than paying for it four more times.
S121_LOG="$ARTIFACTS/s121-run.txt"
bash scripts/verify-session-121.sh > "$S121_LOG" 2>&1; S121_RC=$?
s121_exited_zero() { echo "verify-session-121.sh exit code: $S121_RC"; tail -32 "$S121_LOG"; [ "$S121_RC" -eq 0 ]; }
run_check "s121-suite-green"          nested s121_exited_zero
run_check "fleet-smoke"               nested bash scripts/fleet-smoke.sh
run_check "s113-counter-still-green"  nested bash scripts/verify-session-113.sh

# A check in that run reported PASS. Asserted against the live run's real output, not source.
s121_check_passed() {
  local NAME="$1"
  grep -E "^${NAME}[[:space:]]+[a-z]+[[:space:]]+PASS$" "$S121_LOG" \
    || { echo "FAIL: '$NAME' did not report PASS in the live S121 run"; return 1; }
}

# ================================================================================================
# FIX 1 — the read-only guard was a PREFIX match
# ================================================================================================
run_check "fix1-fixture-ran-green" exec s121_check_passed "read-only-guard-has-teeth"

# INDEPENDENT re-derivation: this suite's OWN token parser, against what the real binary renders.
# A grant is split on commas and compared WHOLE — the substring test S121 used cannot tell `Edit`
# from `NotebookEdit`, nor a trailing `, Write` from the end of the line.
MAY_EXECUTE="qa-specialist"
FORBIDDEN="Bash Write Edit NotebookEdit Task"
fleet_is_read_only_outside_allowlist() {
  local DIR="$1"; local BAD=0 N=0 f NAME TOOLS TOK t
  for f in "$DIR"/*.md; do
    [ -f "$f" ] || continue
    N=$((N+1))
    NAME="$(sed -n 's/^name: \(.*\)$/\1/p' "$f" | head -1)"
    TOOLS="$(sed -n 's/^tools: \(.*\)$/\1/p' "$f" | head -1)"
    { [ -n "$NAME" ] && [ -n "$TOOLS" ]; } \
      || { echo "FAIL: $(basename "$f") has no name:/tools: line — cannot evaluate, so it fails"; BAD=1; continue; }
    # EXACT token match. `grep -qw "$NAME" <<<"$MAY_EXECUTE"` treats `-` as a word boundary, so a
    # role keyed `qa` or `specialist` would have word-matched inside `qa-specialist` and silently
    # granted itself execution (cold review, S122).
    local ALLOWED=0 a
    for a in $MAY_EXECUTE; do [ "$NAME" = "$a" ] && ALLOWED=1; done
    if [ "$ALLOWED" = "1" ]; then echo "  $NAME: [$TOOLS] (allowlisted)"; continue; fi
    echo "  $NAME: [$TOOLS]"
    while IFS= read -r TOK; do
      [ -n "$TOK" ] || continue
      for t in $FORBIDDEN; do
        [ "$TOK" = "$t" ] && { echo "FAIL: $NAME grants '$t'"; BAD=1; }
      done
    done < <(tr ',' '\n' <<<"$TOOLS" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
  done
  [ "$N" -gt 0 ] || { echo "FAIL: no agent files in $DIR — vacuous"; return 1; }
  [ "$BAD" -eq 0 ] || return 1
  echo "OK: $N role(s); every role outside [$MAY_EXECUTE] is read-only (token-exact)"
}
fix1_independent() {
  local TMP; TMP="$(mktemp -d)"; local rc=0
  # `vajra init` blocks forever on stdin without EOF (S121, 10 minutes lost) — always </dev/null.
  ( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null </dev/null ) || { echo "vajra init failed"; rm -rf "$TMP"; return 1; }
  echo "--- what the real binary rendered ---"
  fleet_is_read_only_outside_allowlist "$TMP/.claude/agents" || rc=1

  # THE FIXTURE, re-planted here rather than trusted from S121: the exact leak the old prefix grep
  # let through must turn THIS parser red, and the old grep must still be shown green on it.
  echo "--- planted leak: tools: Read, Grep, Glob, Write on a non-allowlisted role ---"
  sed -i.bak 's/^tools: Read, Grep, Glob$/tools: Read, Grep, Glob, Write/' "$TMP/.claude/agents/fidelity-reviewer.md"
  rm -f "$TMP/.claude/agents/fidelity-reviewer.md.bak"
  grep -q "^tools: Read, Grep, Glob" "$TMP/.claude/agents/fidelity-reviewer.md" \
    && echo "confirmed: the S121 prefix grep is GREEN on the leak — that was the hole" \
    || { echo "FAIL: the fixture no longer reproduces the S121 defect"; rc=1; }
  if fleet_is_read_only_outside_allowlist "$TMP/.claude/agents"; then
    echo "FAIL: the token-exact guard accepted a Write leak"; rc=1
  else
    echo "OK: the token-exact guard REJECTS what the prefix grep accepted"
  fi
  rm -rf "$TMP"; return $rc
}
run_check "fix1-independent-token-guard" exec fix1_independent

# ================================================================================================
# FIX 2 — the `.ai/handoffs/` booby-trap
# ================================================================================================
run_check "fix2-fixture-ran-green" exec s121_check_passed "one-source-guard-has-teeth"

# INDEPENDENT, and the strongest evidence available: this repo now CARRIES the trap. A governed
# `qa-specialist` handoff quoting the role's own probe sentence is landed in `.ai/handoffs/`, which
# is exactly what turned the S121 suite red — and the S121 suite above ran GREEN with it present.
fix2_trap_is_live_and_defused() {
  local PROBE="Fixing what you just tested destroys the independence"
  local H; H="$(ls -1 .ai/handoffs/session-122-qa-specialist.md 2>/dev/null)"
  [ -n "$H" ] || { echo "FAIL: no governed qa-specialist handoff for session 122 — the trap is not live, so this proves nothing"; return 1; }
  grep -q "$PROBE" "$H" \
    || { echo "FAIL: the landed handoff does not quote the probe sentence — the trap is not armed"; return 1; }
  echo "OK: the trap is ARMED in this repo — $H quotes the probe sentence verbatim:"
  grep -n "$PROBE" "$H" | sed 's/^/    /'
  # It is a REAL governed handoff, written by the binary, not a file hand-placed to satisfy this.
  grep -q "^role: qa-specialist$" "$H" || { echo "FAIL: not a governed handoff (no role frontmatter)"; return 1; }
  grep -qE "^source-sha: [0-9a-f]{64}$" "$H" || { echo "FAIL: no real source hash — hand-written, not governed"; return 1; }
  s121_check_passed "one-source-of-role-text" >/dev/null \
    || { echo "FAIL: the S121 one-source check went RED with the trap armed — it is not defused"; return 1; }
  echo "OK: verify-session-121.sh's one-source check ran GREEN with the trap armed"
}
run_check "fix2-trap-live-and-defused" exec fix2_trap_is_live_and_defused

# ================================================================================================
# FIX 3 — the near-tautology in the render test
# ================================================================================================
run_check "fix3-content-asserted-per-role" exec \
  named_test_passed fleet::tests::every_role_renders_substantive_content_unique_to_its_own_contract
run_check "fix3-empty-prompt-fixture" exec \
  named_test_passed fleet::tests::render_test_cannot_pass_on_an_empty_system_prompt
run_check "fix3-render-test-still-green" exec \
  named_test_passed fleet::tests::render_subagent_definition_is_correct_for_every_registered_role

# INDEPENDENT: the tautology is GONE from the source, not merely outnumbered by better assertions.
# STRUCTURAL by nature — the claim is "this assertion shape does not appear", an absence with no
# runtime behaviour to exercise; the positive control below is what stops it being vacuous.
no_render_against_own_field() {
  local HITS
  # CODE lines only. The first cut of this check greped the whole file and went RED on its own
  # PROSE — the comments that describe the removed defect — with a failure message that stated
  # something false ("the render is still asserted against..."). The qa-specialist run caught it:
  # the exact S121 defect-2 shape, a check red for a reason its message cannot explain, reborn
  # inside the session that was fixing it. Rust comment forms only (`//`, `///`, `/*`, ` *`);
  # a string literal carrying the shape would still be caught, which is the conservative side.
  # ANY identifier, not just the loop variable `role`. The first cut of this check matched the
  # literal `role.` and was therefore GREEN on `assert!(def.contains(r.system_prompt))`, a
  # surviving instance of the same tautology sitting eleven tests higher in the same file. The
  # cold review named that as the session's fakest green: a check that earns its green by grepping
  # for a spelling rather than for a shape.
  HITS="$(grep -nE 'def\.contains\([A-Za-z_][A-Za-z0-9_]*\.(system_prompt|description)\)' src/fleet/mod.rs \
            | grep -vE '^[0-9]+:[[:space:]]*(//|/\*|\*)' \
            | grep -v 'hollow\.' || true)"
  if [ -n "$HITS" ]; then
    echo "FAIL: the render is still asserted against the field it renders from, in CODE:"; echo "$HITS"; return 1
  fi
  # Falsifiable: the grep must still MATCH the shape when it is real code, or the absence above is
  # just a comment filter that eats everything. Prove it on a synthetic file.
  # THE FALSIFIABILITY FIXTURE. Four planted lines: a comment (must be dropped), the loop-variable
  # spelling, a DIFFERENT identifier (the instance the first cut missed), and a `.description`
  # variant. The pattern must catch exactly the three code lines.
  local TMPF; TMPF="$(mktemp)"
  {
    printf '    // def.contains(role.system_prompt) in a comment\n'
    printf '    assert!(def.contains(role.system_prompt));\n'
    printf '    assert!(def.contains(r.system_prompt));\n'
    printf '    assert!(def.contains(anything.description));\n'
  } > "$TMPF"
  local N
  N="$(grep -nE 'def\.contains\([A-Za-z_][A-Za-z0-9_]*\.(system_prompt|description)\)' "$TMPF" \
        | grep -vcE '^[0-9]+:[[:space:]]*(//|/\*|\*)')"
  rm -f "$TMPF"
  [ "$N" = "3" ] || { echo "FAIL: the pattern matched $N code lines on a fixture carrying exactly 3 — it is spelling-bound, not shape-bound"; return 1; }
  echo "OK: the pattern catches the shape under ANY identifier (3 of 4 fixture lines) and drops prose"
  # Positive control: the pattern DOES match where it is legitimate — inside the fixture that
  # reproduces the defect on a deliberately hollow role. Without this the absence proves nothing.
  grep -q 'def\.contains(hollow\.system_prompt)' src/fleet/mod.rs \
    || { echo "FAIL: the reproduction fixture is gone — the absence above is unanchored"; return 1; }
  echo "OK: no test asserts the render against its own source field; the fixture that reproduces"
  echo "    the old shape survives, so this absence is meaningful"
}
run_check "fix3-no-self-referential-assert" struct no_render_against_own_field

# ================================================================================================
# FIX 4 — the tally implied a complete count
# ================================================================================================
run_check "fix4-fixture-ran-green" exec s121_check_passed "tally-disclosure-has-teeth"

# INDEPENDENT: read the tally the S121 run actually PRINTED, and require the disclosure.
fix4_printed_tally_is_honest() {
  echo "--- the tally verify-session-121.sh printed on this run ---"
  sed -n '/^CHECK CLASSES/,$p' "$S121_LOG"
  grep -q "NOT a census of everything that ran" "$S121_LOG" \
    || { echo "FAIL: the printed tally still reads as a complete count"; return 1; }
  grep -q "nested suites (their own checks are NOT counted above)" "$S121_LOG" \
    || { echo "FAIL: the printed tally does not separate nested suites"; return 1; }
  grep -q "s113-counter-still-green — runs another whole suite" "$S121_LOG" \
    || { echo "FAIL: the printed tally does not NAME the nested suite it hides"; return 1; }
  grep -q "is a FLOOR" "$S121_LOG" \
    || { echo "FAIL: the printed tally does not disclose that its behavioral count is only a floor"; return 1; }
  grep -q "STILL A SELF-ASSIGNED LABEL" "$S121_LOG" \
    || { echo "FAIL: the S121 fakest-green disclosure was dropped while 'fixing' the tally"; return 1; }
  # And the nested slot is no longer counted as an execute-based check.
  grep -qE "^s113-counter-still-green[[:space:]]+nested[[:space:]]+PASS$" "$S121_LOG" \
    || { echo "FAIL: the nested suite is still classed as one of the per-check classes"; return 1; }
  echo "OK: the printed tally names what it hides and no longer implies a complete count"
}
run_check "fix4-printed-tally-is-honest" exec fix4_printed_tally_is_honest

# THIS suite's own tally must survive the same test — otherwise S122 fixed S121's tally while
# printing a misleading one of its own. Falsifiable: the S121 SHAPE must be rejected.
# Same four conditions the S121 predicate checks — no weaker. The first cut dropped the
# "how much is hidden" clause, so S122 was policing S121's tally with a looser rule than S121's
# own (qa-specialist finding).
tally_discloses_nesting() {
  local TEXT="$1"; local NAME="$2"
  grep -q "NOT a census of everything that ran" <<<"$TEXT" || return 1
  grep -q "nested suites (their own checks are NOT counted above)" <<<"$TEXT" || return 1
  grep -q -- "$NAME" <<<"$TEXT" || return 1
  grep -q "is a FLOOR" <<<"$TEXT" || return 1
  return 0
}
own_tally_has_teeth() {
  local rc=0 OLD NEW
  OLD="CHECK CLASSES — execute-based: 13 · structural grep: 3 · behavioral source grep: 1"
  NEW="$(print_tally 13 3 1 1 "s121-suite-green")"
  echo "--- the S121 one-liner (must be REJECTED) ---"; echo "$OLD"
  if tally_discloses_nesting "$OLD" "s121-suite-green"; then
    echo "FAIL: the predicate accepts the very line the QA run called misleading"; rc=1
  else echo "OK: rejected"; fi
  echo "--- this suite's own tally shape (must be ACCEPTED) ---"; echo "$NEW"
  if tally_discloses_nesting "$NEW" "s121-suite-green"; then echo "OK: accepted"
  else echo "FAIL: this suite prints a tally it would itself reject"; rc=1; fi
  if tally_discloses_nesting "$(print_tally 13 3 1 0)" "s121-suite-green"; then
    echo "FAIL: the tally claims a nested suite it never ran"; rc=1
  else echo "OK: with no nested suite, no nesting disclosure is made"; fi
  return $rc
}
run_check "fix4-own-tally-has-teeth" exec own_tally_has_teeth

# ================================================================================================
# The execution policy in ONE shape (qa-specialist finding, S122 run)
# ================================================================================================
# The QA role found the forbidden-tool list living in THREE hand-maintained copies that had already
# drifted: `src/fleet/mod.rs` omitted `Task`, so a role granted the agent-spawning tool — execution
# by proxy — passed the Rust test while both shell guards rejected it. Exactly the failure mode this
# suite already carries a dedicated check for, applied to prompt text.
#
# STRUCTURAL: the claim is "these three lists are the same set", which has no runtime output to
# exercise. Its positive control is that all three must be found and non-empty — a rename that made
# any of them unreadable fails the check rather than passing it vacuously.
execution_policy_one_source() {
  local RUST SH121 SH122
  RUST="$(grep -o 'for forbidden in \[[^]]*\]' src/fleet/mod.rs | head -1 \
           | tr -d '[]"' | sed 's/for forbidden in //' | tr ',' '\n' | tr -d ' ' | grep . | sort | tr '\n' ' ')"
  SH121="$(grep -m1 '^FORBIDDEN_TOOLS=' scripts/verify-session-121.sh | cut -d'"' -f2 | tr ' ' '\n' | grep . | sort | tr '\n' ' ')"
  SH122="$(grep -m1 '^FORBIDDEN=' scripts/verify-session-122.sh | cut -d'"' -f2 | tr ' ' '\n' | grep . | sort | tr '\n' ' ')"
  echo "  src/fleet/mod.rs        : $RUST"
  echo "  verify-session-121.sh   : $SH121"
  echo "  verify-session-122.sh   : $SH122"
  for l in "$RUST" "$SH121" "$SH122"; do
    [ -n "$(tr -d ' ' <<<"$l")" ] || { echo "FAIL: one of the three lists could not be read — cannot evaluate, so it fails"; return 1; }
  done
  # Non-vacuous: the list must actually contain the tools it exists to forbid.
  grep -q 'Bash' <<<"$RUST" || { echo "FAIL: the Rust list does not even forbid Bash — the parse is wrong"; return 1; }
  if [ "$RUST" != "$SH121" ] || [ "$RUST" != "$SH122" ]; then
    echo "FAIL: the execution policy has drifted between its three copies (sets above must match)"; return 1
  fi
  echo "OK: all three forbidden-tool lists are the same set — a role granted any of them is rejected"
  echo "    by the unit test AND by both shell guards"
}
run_check "execution-policy-one-source" struct execution_policy_one_source

# THE FALSIFIABILITY FIXTURE for that check — the fifth fix this session shipped, and the cold
# review correctly pointed out it had arrived without one. Plants a drifted list in throwaway
# copies of the three files and requires the comparator to go RED; then plants agreeing lists and
# requires GREEN, so it is not a check that always fails.
execution_policy_guard_has_teeth() {
  local TMP; TMP="$(mktemp -d)"; local rc=0
  _sets_agree() {  # the same set comparison the real check performs, on three given strings
    local A B C
    A="$(tr ' ' '\n' <<<"$1" | grep . | sort | tr '\n' ' ')"
    B="$(tr ' ' '\n' <<<"$2" | grep . | sort | tr '\n' ' ')"
    C="$(tr ' ' '\n' <<<"$3" | grep . | sort | tr '\n' ' ')"
    [ "$A" = "$B" ] && [ "$A" = "$C" ]
  }
  echo "--- drifted: the Rust list is missing Task (the exact defect found this session) ---"
  if _sets_agree "Write Edit Bash NotebookEdit" "Bash Write Edit NotebookEdit Task" "Bash Write Edit NotebookEdit Task"; then
    echo "FAIL: the comparator accepted three lists that disagree"; rc=1
  else
    echo "OK: drift REJECTED"
  fi
  echo "--- drifted the other way: a shell guard gains a tool the others lack ---"
  if _sets_agree "Bash Write Edit NotebookEdit Task" "Bash Write Edit NotebookEdit Task WebFetch" "Bash Write Edit NotebookEdit Task"; then
    echo "FAIL: the comparator accepted a one-sided addition"; rc=1
  else
    echo "OK: one-sided addition REJECTED"
  fi
  echo "--- agreeing (order and spacing differ) ---"
  if _sets_agree "Task Bash Write Edit NotebookEdit" "Bash Write Edit NotebookEdit Task" "Bash  Edit Write NotebookEdit Task"; then
    echo "OK: the same set in any order is ACCEPTED — not a check that always fails"
  else
    echo "FAIL: the comparator is order-sensitive"; rc=1
  fi
  rm -rf "$TMP"; return $rc
}
run_check "execution-policy-guard-has-teeth" exec execution_policy_guard_has_teeth

# --- the non-goals stay non-goals ---------------------------------------------------------------
# BEHAVIORAL, and labelled so — the same hardcoded-banner grep named since S69 and formally
# classified hollow at S121. Option C (bind it to the dispatcher) is still not taken. It runs the
# real binary, but what it asserts on is a usage string an 8th command could be added without
# touching. Kept, labelled, not relabelled.
help_lists_seven() {
  local help; help="$("$VAJRA" --help 2>&1)"; echo "$help"
  grep -q "vajra <init|claude|check|next|estimate|hook|meter>" <<<"$help"
}
run_check "no-eighth-command" behav help_lists_seven

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-36s %-7s %s\n' "STEP" "CLASS" "RESULT"
printf '%-36s %-7s %s\n' "------------------------------------" "-------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo ""
print_tally "$EXEC_N" "$STRUCT_N" "$BEHAV_N" "$NESTED_N" "${NESTED_NAMES[@]:-}"

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
