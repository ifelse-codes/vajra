#!/usr/bin/env bash
# Verify — Session 121: the fleet's FOURTH role, the QA Specialist (founder pick at the S120 GT).
#
# Same shape as verify-session-116.sh (the third role), with one difference this session must not
# duck. S120's GT named the disease these checks can carry: a BEHAVIORAL SOURCE GREP — greping src/
# for a message string and calling that proof a feature works — passes even if the feature is
# deleted and only the string survives. The role built here exists to catch exactly that, so this
# script classifies its OWN checks, in the same two classes the role's contract uses:
#
#   EXECUTE-BASED   — runs the product (the binary, cargo test, a script) and asserts on real output.
#   STRUCTURAL grep — asserts ARCHITECTURE (one source of truth, no second copy, no key collision,
#                     a file's absence). Legitimate: there is no output to run for "this text exists
#                     in exactly one place".
#   BEHAVIORAL grep — the hollow class. Any that survive are named in the summary and in the
#                     session's fakest-green disclosure. ONE survives here: `no-eighth-command`
#                     (see below). It is labelled honestly rather than aspirationally, because a
#                     tally of zero that was reached by relabelling is the exact disease.
#
# The tally itself is a SELF-ASSIGNED LABEL, not a measurement — nothing here proves a check marked
# `exec` executes anything. Named as this session's fakest green (cold review, S121) rather than
# quoted as a number that was verified.
#
# The tally is printed at the end so it cannot be quietly claimed in prose only.
#
# ── S122 AMENDMENT ──────────────────────────────────────────────────────────────────────────────
# The `qa-specialist` role this suite verifies was then pointed AT this suite (the S121 post-close
# live run) and found four real defects in these guardrails. S122 closes them, in place, each with
# a falsifiability fixture — because a check that has never been seen RED is not evidence:
#   1. the read-only guard was a PREFIX grep and passed a `Write` leak → now token-exact
#      (`read_only_outside_allowlist`), fixture `read-only-guard-has-teeth`
#   2. `one_source_of_role_text` did not exclude `.ai/handoffs/` — a QA report quoting its own probe
#      sentence turned the suite RED with an unexplaining message → excluded + the message now names
#      every carrier, fixture `one-source-guard-has-teeth`
#   3. the render test asserted `def.contains(role.system_prompt)` — the render against the field it
#      renders from, satisfied by an empty prompt → now asserts substantive per-role CONTENT
#      (`src/fleet/mod.rs`), fixture `render_test_cannot_pass_on_an_empty_system_prompt`
#   4. the tally folded a 14-check nested suite into one `exec` slot → nested suites are their own
#      class, named and explicitly uncounted, fixture `tally-disclosure-has-teeth`
# NOT fixed, still true: the class labels are still typed by the author, and `no-eighth-command`
# (here and in S113's suite) is still a hardcoded-banner grep.
#
# KNOWN, DISCLOSED: verify-session-116.sh's `init-scaffolds-three-roles` and `test-roles-read-only`
# go RED by construction against this branch — the fleet grew to four, and the every-role-is-
# read-only invariant was DELIBERATELY changed at S121 (DECISION-007 S121 addendum), which is why
# that test was renamed rather than quietly loosened. Same reasoning S116 recorded for S114's
# `scaffolds_two_roles`: those scripts are historical snapshots of their session's world, not living
# regression suites. The role-COUNT-AGNOSTIC ones (S113's counter suite, fleet-smoke.sh) ARE re-run
# below, unchanged, and must stay green.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="121"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
EXEC_N=0; STRUCT_N=0; BEHAV_N=0; NESTED_N=0; NESTED_NAMES=()
# S122 fix 4 — the fourth class, `nested`. THE DEFECT (qa-specialist live run, S121): the tally
# said `13 execute-based · 3 structural · 1 behavioral`, and ONE of those 17 slots
# (`s113-counter-still-green`) was an entire other suite of 14 checks — which carries its OWN
# hollow banner grep. The true count of hollow checks that run was 2, not 1, and no reader of the
# printed line could have known. A nested suite is now its own class: it is NAMED, it is NOT folded
# into the three per-check counts, and the summary says out loud that the tally is a count of THIS
# suite's own checks only.
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
    RESULTS+=("$(printf '%-34s %-7s %s' "$NAME" "$CLASS" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-34s %-7s %s' "$NAME" "$CLASS" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- toolchain: unchanged discipline ----------------------------------------------------------
run_check "cargo-build"   exec cargo build --all-targets
run_check "cargo-test"    exec cargo test --lib
run_check "cargo-fmt"     exec cargo fmt -- --check
run_check "cargo-clippy"  exec cargo clippy --all-targets -- -D warnings

# The role-count-agnostic regressions: a fourth role does not get to move what the fleet already
# guarantees. (S113 tests the counter MECHANISM and never asserts "exactly N roles"; fleet-smoke
# exercises the researcher path only.)
run_check "fleet-smoke"              exec bash scripts/fleet-smoke.sh
# NESTED, not exec (S122 fix 4): this ONE slot runs verify-session-113.sh, which is 14 checks of
# its own — including its own `no-eighth-command` hardcoded-banner grep, i.e. a SECOND behavioral
# source grep that the S121 tally never showed. Counting it as a single `exec` check made the
# printed tally read as a complete census of what ran. It is not one, and now says so.
run_check "s113-counter-still-green" nested bash scripts/verify-session-113.sh

VAJRA="$ROOT/target/debug/vajra"

# `cargo test --lib <filter>` EXITS 0 WHEN THE FILTER MATCHES NOTHING (S112 pass 2) — a bare
# filtered run names a lock it does not hold. Reused verbatim, as required.
named_test_passed() {
  local out; out="$(cargo test --lib "$1" 2>&1)"
  echo "$out"
  grep -qE 'test result: ok\. [1-9][0-9]* passed' <<<"$out" \
    || { echo "FAIL: filter '$1' matched no test that ran and passed"; return 1; }
}
run_check "test-role-registered" exec \
  named_test_passed fleet::tests::qa_specialist_is_registered_with_a_non_colliding_key_and_the_execution_grant
run_check "test-execution-allowlist" exec \
  named_test_passed fleet::tests::tool_grants_are_per_role_and_execution_is_the_qa_specialists_alone
run_check "test-delta-names-role" exec \
  named_test_passed fleet::tests::compute_delta_names_the_producing_role_not_a_hardcoded_one
run_check "test-render-every-role" exec \
  named_test_passed fleet::tests::render_subagent_definition_is_correct_for_every_registered_role
# The guard on the guard: a filter matching nothing must FAIL, or every check above is theatre.
filter_guard_has_teeth() {
  if named_test_passed fleet::tests::this_test_does_not_exist_on_purpose >/dev/null 2>&1; then
    echo "FAIL: named_test_passed is green on a filter that matches no test"; return 1
  fi
  echo "OK: a filter matching zero tests fails, as it must"
}
run_check "test-filter-guard-has-teeth" exec filter_guard_has_teeth

# --- the tally, as a FUNCTION so it can be falsified (S122 fix 4) --------------------------------
# The tally used to be four inline `echo`s at the bottom of the file — unreachable by any check, so
# "the tally is honest now" would have been a claim with no test behind it. It is a function; the
# real summary calls it, and so does the fixture below, against both the fixed shape and the S121
# shape it replaced.
# $1=exec $2=struct $3=behav $4=nested, rest = nested suite names.
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
    echo "  DISCLOSED: verify-session-113.sh carries its own \`no-eighth-command\` hardcoded-banner"
    echo "  grep, so the true number of behavioral source greps this run executed is ${B} + at least 1."
  fi
  if [ "$B" -ne 0 ]; then
    echo "NOTE: ${B} behavioral source grep(s) in THIS suite — each must be named in the session's fakest-green disclosure."
  fi
  echo "STILL A SELF-ASSIGNED LABEL: nothing here proves a check marked \`exec\` executes anything."
  echo "S122 made this tally honest about NESTING. It did not make the labels EARNED."
}

# The S121 tally, kept verbatim as the negative control for the fixture. This is the line the QA
# role read as a complete count of 17 checks while one slot hid 14 more.
print_tally_s121_shape() {
  echo "CHECK CLASSES — execute-based: $1 · structural grep: $2 · behavioral source grep: $3"
}

# The predicate: does a tally block disclose that it is not a complete count, and name what it
# leaves out? Exit 0 = honest.
tally_discloses_nesting() {
  local TEXT="$1"; local NESTED_NAME="$2"
  grep -q "NOT a census of everything that ran" <<<"$TEXT" || return 1
  grep -q "nested suites (their own checks are NOT counted above)" <<<"$TEXT" || return 1
  grep -q -- "$NESTED_NAME" <<<"$TEXT" || return 1
  grep -q "at least 1" <<<"$TEXT" || return 1
  return 0
}

# THE FALSIFIABILITY FIXTURE for fix 4.
tally_disclosure_has_teeth() {
  local rc=0 OLD NEW
  OLD="$(print_tally_s121_shape 13 3 1)"
  NEW="$(print_tally 13 3 1 1 "s113-counter-still-green")"
  echo "--- the S121 tally (must be judged DISHONEST about nesting) ---"; echo "$OLD"
  if tally_discloses_nesting "$OLD" "s113-counter-still-green"; then
    echo "FAIL: the predicate passes the very line the QA run called misleading — it has no teeth"; rc=1
  else
    echo "OK: the S121 one-liner is rejected — it implied a complete count of 17"
  fi
  echo "--- the S122 tally (must be judged HONEST) ---"; echo "$NEW"
  if tally_discloses_nesting "$NEW" "s113-counter-still-green"; then
    echo "OK: the fixed tally discloses the nesting and names the nested suite"
  else
    echo "FAIL: the fixed tally does not disclose its own nesting"; rc=1
  fi
  # It must also stop naming a nested suite it did not run — no boilerplate disclosure.
  if tally_discloses_nesting "$(print_tally 13 3 1 0)" "s113-counter-still-green"; then
    echo "FAIL: the tally claims a nested suite it never ran"; rc=1
  else
    echo "OK: with no nested suite, the tally makes no nesting disclosure"
  fi
  # And the self-assigned-label caveat is never dropped, at any shape.
  grep -q "STILL A SELF-ASSIGNED LABEL" <<<"$NEW" \
    || { echo "FAIL: the S121 fakest-green disclosure was quietly dropped"; rc=1; }
  return $rc
}
run_check "tally-disclosure-has-teeth" exec tally_disclosure_has_teeth

strip_fleet() { grep -vE '^[[:space:]]*(⚠ )?fleet:'; }

# --- the ANCHORED read-only guard (S122 fix 1) ---------------------------------------------------
# THE DEFECT (found by the qa-specialist live run at the S121 close): the S121 assertion was
# `grep -q "^tools: Read, Grep, Glob" <agent file>`. `grep` matches a SUBSTRING of the line, so a
# role whose grant had leaked to `tools: Read, Grep, Glob, Write` matched it and PASSED. The check
# that looked like the thing stopping a write-tool leak did not stop one; only the Rust unit test
# did.
#
# The fix: read the grant, split it into TOKENS, and reject any write/exec token on a role outside
# the named allowlist. Tokenising is the load-bearing half — a substring test cannot tell `Edit`
# from `NotebookEdit`, and cannot tell a trailing `, Write` from the end of the line.
#
# $1 = a directory of `.claude/agents/*.md`. Exit 0 = every non-allowlisted role is read-only.
EXECUTION_ALLOWLIST="qa-specialist"
FORBIDDEN_TOOLS="Bash Write Edit NotebookEdit Task"
read_only_outside_allowlist() {
  local DIR="$1"; local BAD=0; local N=0
  local f NAME TOOLS TOK t
  for f in "$DIR"/*.md; do
    [ -f "$f" ] || continue
    N=$((N+1))
    NAME="$(sed -n 's/^name: \(.*\)$/\1/p' "$f" | head -1)"
    TOOLS="$(sed -n 's/^tools: \(.*\)$/\1/p' "$f" | head -1)"
    [ -n "$NAME" ]  || { echo "FAIL: $(basename "$f") has no 'name:' line — cannot evaluate, so it fails"; BAD=1; continue; }
    [ -n "$TOOLS" ] || { echo "FAIL: $NAME has no 'tools:' line — cannot evaluate, so it fails"; BAD=1; continue; }
    if grep -qw -- "$NAME" <<<"$EXECUTION_ALLOWLIST"; then
      echo "  $NAME: [$TOOLS] (allowlisted to execute)"
      continue
    fi
    echo "  $NAME: [$TOOLS]"
    # Tokenise on commas, trim each token, compare WHOLE tokens.
    while IFS= read -r TOK; do
      [ -n "$TOK" ] || continue
      for t in $FORBIDDEN_TOOLS; do
        if [ "$TOK" = "$t" ]; then
          echo "FAIL: $NAME grants the write/exec tool '$t' — only [$EXECUTION_ALLOWLIST] may execute"
          BAD=1
        fi
      done
    done < <(tr ',' '\n' <<<"$TOOLS" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
  done
  [ "$N" -gt 0 ] || { echo "FAIL: no agent files in $DIR — the guard would be vacuous"; return 1; }
  [ "$BAD" -eq 0 ] || return 1
  echo "OK: $N role(s) checked; every role outside [$EXECUTION_ALLOWLIST] is read-only (token-exact)"
  return 0
}

# THE FALSIFIABILITY FIXTURE for fix 1. A check never seen RED is not evidence — so plant the exact
# leak the old prefix grep let through and require the guard to reject it, then plant the clean
# equivalent and require it to pass. If either half misbehaves, this check fails.
read_only_guard_has_teeth() {
  local TMP; TMP="$(mktemp -d)"; local rc=0
  mkdir -p "$TMP/leak" "$TMP/clean"

  # The leak the S121 assertion PASSED: the read-only prefix is intact, `Write` is appended.
  printf -- '---\nname: researcher\ndescription: d\ntools: Read, Grep, Glob, Write\n---\nbody\n' > "$TMP/leak/researcher.md"
  printf -- '---\nname: qa-specialist\ndescription: d\ntools: Bash, Read, Write, Edit, Grep, Glob\n---\nbody\n' > "$TMP/leak/qa-specialist.md"
  # Control: the same fleet without the leak.
  printf -- '---\nname: researcher\ndescription: d\ntools: Read, Grep, Glob\n---\nbody\n' > "$TMP/clean/researcher.md"
  cp "$TMP/leak/qa-specialist.md" "$TMP/clean/qa-specialist.md"

  echo "--- the OLD S121 assertion against the leaking file (shown failing to catch it) ---"
  if grep -q "^tools: Read, Grep, Glob" "$TMP/leak/researcher.md"; then
    echo "confirmed: the old prefix grep is GREEN on 'tools: Read, Grep, Glob, Write' — that was the hole"
  else
    echo "FAIL: the fixture no longer reproduces the S121 defect — it proves nothing"; rc=1
  fi

  echo "--- the NEW guard against the leaking file (must go RED) ---"
  if read_only_outside_allowlist "$TMP/leak"; then
    echo "FAIL: the anchored guard accepted a Write leak on a non-allowlisted role"; rc=1
  else
    echo "OK: the anchored guard REJECTED the leak the old prefix grep accepted"
  fi

  echo "--- the NEW guard against the clean fleet (must stay GREEN) ---"
  if read_only_outside_allowlist "$TMP/clean"; then
    echo "OK: the anchored guard passes a genuinely read-only fleet (not a check that always fails)"
  else
    echo "FAIL: the anchored guard rejects a clean fleet — it is not a usable guard"; rc=1
  fi

  # Fail-closed: a grant it cannot read is a FAIL, never a silent pass (L-layer rule).
  printf -- '---\nname: mystery\ndescription: d\n---\nbody\n' > "$TMP/leak/mystery.md"
  if read_only_outside_allowlist "$TMP/leak" >/dev/null 2>&1; then
    echo "FAIL: an agent file with no tools: line passed — the guard is not fail-closed"; rc=1
  else
    echo "OK: an unreadable grant fails closed"
  fi

  rm -rf "$TMP"
  return $rc
}
run_check "read-only-guard-has-teeth" exec read_only_guard_has_teeth

# --- criteria 1 + 2: a fresh `vajra init` scaffolds FOUR agent files, one of which EXECUTES -------
# Proven by RUNNING init and asserting on what it produced — never by reading src/cli/init.rs.
scaffolds_four_roles() { local TMP; TMP="$(mktemp -d)"; _scaffolds_four_roles "$TMP"; local rc=$?; rm -rf "$TMP"; return $rc; }
_scaffolds_four_roles() {
  local TMP="$1"
  ( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null </dev/null ) || { echo "vajra init failed"; return 1; }
  echo "--- scaffolded agents ---"; ls -1 "$TMP/.claude/agents/"

  local N; N="$(find "$TMP/.claude/agents" -maxdepth 1 -name '*.md' | wc -l | tr -d ' ')"
  [ "$N" = "4" ] || { echo "FAIL: expected 4 scaffolded agent files, got $N"; return 1; }
  for f in researcher fidelity-reviewer plan-advisor qa-specialist; do
    [ -f "$TMP/.claude/agents/$f.md" ] || { echo "FAIL: $f not scaffolded"; return 1; }
  done

  # The scaffolded qa-specialist carries the CONTRACT, not a stub: run it, classify every check,
  # name the hollow ones, never repair what you tested, never silently skip.
  local F="$TMP/.claude/agents/qa-specialist.md"
  grep -q "^name: qa-specialist$" "$F" || { echo "FAIL: wrong subagent name"; return 1; }
  grep -q 'scripts/verify-session-NN.sh' "$F" || { echo "FAIL: it is not told to run the verify script"; return 1; }
  grep -q 'BEHAVIORAL SOURCE GREP' "$F" || { echo "FAIL: no hollow-check classification contract"; return 1; }
  grep -q 'EXECUTE-BASED' "$F" || { echo "FAIL: no execute-based classification contract"; return 1; }
  grep -q 'do NOT repair the checks you criticise' "$F" || { echo "FAIL: the independence rule is missing"; return 1; }
  grep -q 'a check that cannot evaluate fails' "$F" || { echo "FAIL: the fail-closed rule is missing"; return 1; }
  grep -q "vajra next --role qa-specialist --from" "$F" || { echo "FAIL: wrong handoff command"; return 1; }

  # CRITERION 2, the load-bearing half: this role EXECUTES, and it is the ONLY one that does.
  grep -q "^tools: Bash, Read, Write, Edit, Grep, Glob$" "$F" \
    || { echo "FAIL: the qa-specialist tool grant is not the recorded execution grant"; return 1; }
  local NEXEC; NEXEC="$(grep -lE '^tools:.*Bash' "$TMP/.claude/agents/"*.md | wc -l | tr -d ' ')"
  echo "scaffolded roles granted Bash: $NEXEC"
  [ "$NEXEC" = "1" ] || { echo "FAIL: $NEXEC roles were granted Bash; the allowlist is exactly one"; return 1; }
  # S122 fix 1: the read-only guard is now ANCHORED and TOKENISED. It used to be
  # `grep -q "^tools: Read, Grep, Glob"` — a PREFIX match, so `tools: Read, Grep, Glob, Write`
  # sailed through it and only the unit test caught the leak. It now parses the grant into tokens
  # and rejects ANY write/exec tool on a role outside the named allowlist.
  read_only_outside_allowlist "$TMP/.claude/agents" || return 1

  # This repo's committed copies must be exactly what init renders — a rendering, not a duplicate.
  for f in researcher.md fidelity-reviewer.md plan-advisor.md qa-specialist.md; do
    diff -u "$TMP/.claude/agents/$f" "$ROOT/.claude/agents/$f" \
      || { echo "FAIL: the repo's $f has drifted from the render"; return 1; }
  done

  # EXACTLY the rendered set — a hand-written extra file would be a real, boot-loadable, second
  # source of role text sitting in the one place nothing looks (S114 cold-review finding).
  local REPO_AGENTS RENDERED
  REPO_AGENTS="$(cd "$ROOT/.claude/agents" && ls -1 | sort)"
  RENDERED="$(cd "$TMP/.claude/agents" && ls -1 | sort)"
  echo "--- repo .claude/agents/ ---"; echo "$REPO_AGENTS"
  if [ "$REPO_AGENTS" != "$RENDERED" ]; then
    echo "FAIL: .claude/agents/ holds files vajra init does not render — a hand-maintained agent definition is a second source"
    diff <(echo "$RENDERED") <(echo "$REPO_AGENTS"); return 1
  fi
  echo "OK: four roles scaffolded byte-identical to this repo's copies; exactly one grants Bash"
  return 0
}
run_check "init-scaffolds-four-roles" exec scaffolds_four_roles

# --- the no-second-source guard (with its positive control) -------------------------------------
# STRUCTURAL by nature: the claim is "this text exists in exactly one hand-maintained file", which
# has no runtime behaviour to exercise. The probe sentence sits UNBROKEN on one Rust source line —
# a phrase split across a `\`-continuation is invisible to grep (the S114 trap).
#
# S122 fix 2 — THE BOOBY-TRAP, found by the qa-specialist live run. The exclusion list omitted
# `.ai/handoffs/`, which is EXACTLY where this role's governed handoff lands. So the moment a QA
# report quoted the role's own probe sentence and was landed through `vajra next --role
# qa-specialist --from`, this check flipped the whole suite RED — for a reason its message
# ("role text lives in 2 places, not 1") could not explain to the person reading it. The role the
# session shipped was, by using itself as designed, a live trap for the session's own suite.
#
# Two changes: (a) GENERATED and HANDOFF locations are excluded — `.ai/handoffs/` is Vajra-written
# output, never a hand-maintained source of role text; (b) the failure message NAMES every carrier
# it found, so a future trip is self-explaining instead of a riddle.
#
# $1 = the root to scan (defaults to this repo). Parameterised so the fixture below can prove the
# check goes RED on a real second source and stays GREEN on a governed handoff.
ROLE_TEXT_PROBE="Fixing what you just tested destroys the independence"
role_text_carriers() {
  local ROOT_DIR="${1:-.}"
  ( cd "$ROOT_DIR" && grep -rl "$ROLE_TEXT_PROBE" . 2>/dev/null ) \
    | grep -v '^\./target/' | grep -v '^\./\.git/' \
    | grep -v '^\./\.ai/verify/' \
    | grep -v '^\./\.ai/handoffs/' \
    | grep -v '^\./\.claude/agents/' | grep -v '^\./docs/decisions/' \
    | grep -v '^\./sessions/' \
    | grep -vE '^\./scripts/verify-session-[0-9]+\.sh$' \
    | sort
}
# The exclusions above, stated once in prose so the list is not a wall of unexplained greps:
#   target/ .git/                 — build output and history, not source
#   .ai/verify/  .ai/handoffs/    — VAJRA-GENERATED: verify logs and the governed handoff (fix 2)
#   .claude/agents/               — the RENDER of the canonical source, byte-checked separately
#   docs/decisions/  sessions/    — the written record quoting the decision, not a second source
#   scripts/verify-session-NN.sh  — the checks themselves have to name the probe to test for it
one_source_of_role_text() { _one_source_of_role_text "$ROOT"; }
_one_source_of_role_text() {
  local ROOT_DIR="$1"
  local HITS; HITS="$(role_text_carriers "$ROOT_DIR")"
  echo "carriers of the qa-specialist prompt text (excluding generated + handoff locations):"
  echo "$HITS"
  grep -q '^\./src/fleet/mod\.rs$' <<<"$HITS" \
    || { echo "FAIL: the pattern does not even match the canonical source — it proves nothing"; return 1; }
  local N; N="$(grep -c . <<<"$HITS")"
  if [ "$N" != "1" ]; then
    # The message NAMES the carriers (S122 fix 2). The S121 version printed only a count, so a trip
    # told you the suite was red without telling you which file to look at.
    echo "FAIL: the qa-specialist role text lives in $N hand-maintained files, not 1."
    echo "      The canonical source is ./src/fleet/mod.rs. These other carriers must go, or be"
    echo "      excluded above if they are generated output rather than a second source:"
    grep -v '^\./src/fleet/mod\.rs$' <<<"$HITS" | sed 's/^/        - /'
    return 1
  fi
  echo "OK: the qa-specialist's prompt text exists in exactly one hand-maintained file"
  return 0
}
run_check "one-source-of-role-text" struct one_source_of_role_text

# THE FALSIFIABILITY FIXTURE for fix 2. Builds a miniature repo and drives the check through three
# states: canonical only (GREEN) · canonical + a governed handoff quoting the probe (GREEN — this is
# the exact trip that made the S121 suite red) · canonical + a real second hand-maintained carrier
# (RED, and the message must name that carrier by path).
one_source_guard_has_teeth() {
  local TMP; TMP="$(mktemp -d)"; local rc=0; local OUT
  mkdir -p "$TMP/src/fleet" "$TMP/.ai/handoffs" "$TMP/docs"
  printf 'canonical: %s\n' "$ROLE_TEXT_PROBE" > "$TMP/src/fleet/mod.rs"

  echo "--- state 1: canonical source only (must be GREEN) ---"
  if _one_source_of_role_text "$TMP"; then echo "OK: green on the canonical source alone"
  else echo "FAIL: red with only the canonical carrier present"; rc=1; fi

  echo "--- state 2: a governed handoff quotes the probe (must STAY GREEN — the S121 trap) ---"
  printf 'role: qa-specialist\n\nThe report quotes the rule it was given: %s\n' "$ROLE_TEXT_PROBE" \
    > "$TMP/.ai/handoffs/session-122-qa-specialist.md"
  echo "--- the OLD S121 exclusion list against that handoff (shown tripping) ---"
  if ( cd "$TMP" && grep -rl "$ROLE_TEXT_PROBE" . 2>/dev/null \
        | grep -v '^\./target/' | grep -v '^\./\.git/' | grep -v '^\./\.ai/verify/' \
        | grep -v '^\./\.claude/agents/' | grep -v '^\./docs/decisions/' \
        | grep -v '^\./sessions/' | grep -c . ) | grep -qv '^1$'; then
    echo "confirmed: the S121 exclusion list counts the handoff as a second source — that was the trap"
  else
    echo "FAIL: the fixture no longer reproduces the S121 booby-trap — it proves nothing"; rc=1
  fi
  if _one_source_of_role_text "$TMP"; then
    echo "OK: the fixed check ignores the governed handoff — the trap is defused"
  else
    echo "FAIL: a governed handoff quoting the probe still trips the check"; rc=1
  fi

  echo "--- state 3: a REAL second hand-maintained carrier (must go RED and NAME it) ---"
  printf 'a second copy of the role text: %s\n' "$ROLE_TEXT_PROBE" > "$TMP/docs/rival.md"
  OUT="$(_one_source_of_role_text "$TMP" 2>&1)"; local RC3=$?
  echo "$OUT"
  if [ "$RC3" -eq 0 ]; then
    echo "FAIL: a genuine second source passed — the check has no teeth left"; rc=1
  else
    echo "OK: a genuine second source is still rejected"
    grep -q -- '- \./docs/rival\.md' <<<"$OUT" \
      || { echo "FAIL: the failure message does not name the offending carrier"; rc=1; }
  fi

  rm -rf "$TMP"
  return $rc
}
run_check "one-source-guard-has-teeth" exec one_source_guard_has_teeth

# --- criterion 3, END-TO-END in a throwaway repo -------------------------------------------------
# Fail-closed for the new role, the key collision, then FOUR governed handoffs in one session.
e2e_four_handoffs() { local TMP; TMP="$(mktemp -d)"; _e2e_four_handoffs "$TMP"; local rc=$?; rm -rf "$TMP"; return $rc; }
_e2e_four_handoffs() {
  local TMP="$1"
  ( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null </dev/null ) || { echo "vajra init failed"; return 1; }
  echo "121" > "$TMP/.ai/SESSION"

  mkdir -p "$TMP/prompts"
  cat > "$TMP/prompts/121-task-fixture.md" <<'FIXTURE'
# Session 121 — fixture

## Acceptance
1. **WHEN** four roles have governed handoffs **THEN** the counter names all four
2. **WHEN** the qa-specialist role is unknown **THEN** the writer fails closed

## Design
- design-significant: no

## Plan
1. register the fourth role. covers: 1
2. govern its handoff. covers: 2

## Delta
- `+` the fleet's fourth named role, the first that executes
FIXTURE

  local BEFORE; BEFORE="$(cd "$TMP" && "$VAJRA" next --stations 121 2>&1)" || { echo "--stations failed"; return 1; }
  echo "--- BEFORE (no fleet work) ---"; echo "$BEFORE"
  grep -qi "fleet" <<<"$BEFORE" && { echo "FAIL: fleet mentioned with no handoff"; return 1; }
  grep -qE "^  [1-9] of 8 stations passed" <<<"$BEFORE" \
    || { echo "FAIL: fixture has 0 passing stations — the byte-identity check would be vacuous"; return 1; }

  # --- fail-closed: the collision word + the standard three ---
  printf 'QA: ran verify-session-121.sh, exit 0. 18 checks: 15 execute-based, 3 structural.\n' > "$TMP/qa.md"
  : > "$TMP/empty.md"
  ( cd "$TMP" && "$VAJRA" next --role qa --from qa.md ) >/dev/null 2>&1 \
    && { echo "FAIL: the bare key 'qa' was accepted — the collision was not resolved"; return 1; }
  ( cd "$TMP" && "$VAJRA" next --role qa-specialist ) >/dev/null 2>&1 \
    && { echo "FAIL: --role without --from was accepted"; return 1; }
  ( cd "$TMP" && "$VAJRA" next --role qa-specialist --from empty.md ) >/dev/null 2>&1 \
    && { echo "FAIL: empty findings were accepted"; return 1; }
  ( cd "$TMP" && "$VAJRA" next --role qa-specialist --from nope.md ) >/dev/null 2>&1 \
    && { echo "FAIL: a missing findings file was accepted"; return 1; }
  echo "OK: unknown role (the collision word) · missing --from · empty findings · missing file all fail closed"

  # --- the real writer, all four roles ---
  printf 'ANSWER: ANTHROPIC_API_KEY is the only auth that survives a fresh no-TTY shell.\n' > "$TMP/findings.md"
  printf 'VERDICT: ACCEPT. 6 of 6 requirements SHIPPED.\nFakest green: the counter counts files, not agents.\n' > "$TMP/review.md"
  printf 'PLAN: 1. do the thing — covers: 1\n2. do the other thing — covers: 2\n' > "$TMP/plan.md"
  ( cd "$TMP" && "$VAJRA" next --role researcher --from findings.md ) >/dev/null \
    || { echo "researcher handoff failed"; return 1; }
  ( cd "$TMP" && "$VAJRA" next --role fidelity-reviewer --from review.md ) >/dev/null \
    || { echo "reviewer handoff failed"; return 1; }
  ( cd "$TMP" && "$VAJRA" next --role plan-advisor --from plan.md ) >/dev/null \
    || { echo "plan-advisor handoff failed"; return 1; }
  ( cd "$TMP" && "$VAJRA" next --role qa-specialist --from qa.md ) >/dev/null \
    || { echo "qa-specialist handoff failed"; return 1; }

  local H="$TMP/.ai/handoffs/session-121-qa-specialist.md"
  [ -f "$H" ] || { echo "FAIL: the qa-specialist handoff is not at the contract path"; return 1; }
  echo "--- qa-specialist handoff ---"; cat "$H"
  grep -q "^role: qa-specialist$" "$H" || { echo "FAIL: handoff role frontmatter wrong"; return 1; }
  grep -qE "^source-sha: [0-9a-f]{64}$" "$H" || { echo "FAIL: handoff carries no real source hash"; return 1; }
  # The recorded hash is the REAL hash of the findings, not a placeholder. Vajra hashes the
  # TRIMMED body (src/cli/next.rs: `let body = findings.trim()`), so the comparison must trim too —
  # the standing carry-forward that has bitten every session that compared raw file bytes.
  local WANT GOT
  WANT="$(printf '%s' "$(cat "$TMP/qa.md")" | shasum -a 256 | cut -d' ' -f1)"
  GOT="$(grep '^source-sha: ' "$H" | cut -d' ' -f2)"
  [ "$WANT" = "$GOT" ] || { echo "FAIL: source-sha $GOT does not hash the trimmed findings ($WANT)"; return 1; }
  echo "trimmed-body sha matches the recorded source-sha: $GOT"
  grep -q "first qa-specialist handoff" "$H" \
    || { echo "FAIL: the handoff delta does not name the producing role"; return 1; }
  if grep -q "researcher handoff" "$H"; then
    echo "FAIL: the qa-specialist's own delta is labelled with the Researcher's name"; return 1
  fi

  # --- FOUR governed handoffs, all named, K byte-identical ---
  local AFTER; AFTER="$(cd "$TMP" && "$VAJRA" next --stations 121 2>&1)"
  echo "--- AFTER (four handoffs) ---"; echo "$AFTER"
  grep -q "fleet: 4 governed handoff(s)" <<<"$AFTER" \
    || { echo "FAIL: the counter does not report four governed handoffs"; return 1; }
  for role in researcher fidelity-reviewer plan-advisor qa-specialist; do
    grep -q "$role" <<<"$(grep 'fleet:' <<<"$AFTER")" \
      || { echo "FAIL: the fleet line does not name $role"; return 1; }
  done
  grep -q "NOT counted in it" <<<"$AFTER" \
    || { echo "FAIL: the fleet line stopped disclosing that it sits outside K"; return 1; }

  local STRIPPED; STRIPPED="$(strip_fleet <<<"$AFTER")"
  if [ "$STRIPPED" != "$BEFORE" ]; then
    echo "FAIL: the report changed by more than the fleet line at FOUR handoffs"
    diff <(echo "$BEFORE") <(echo "$STRIPPED"); return 1
  fi
  echo "OK: four handoffs named beside K; the rest of the report is byte-identical to no-fleet"

  # A malformed FOURTH handoff is still named and still counts as nothing — the S113/S114 rule at a
  # count it was never exercised at (three good + one broken must read as THREE governed).
  echo "notes with no frontmatter" > "$H"
  local MIXED; MIXED="$(cd "$TMP" && "$VAJRA" next --stations 121 2>&1)"
  echo "--- MIXED (three valid, one malformed) ---"; echo "$MIXED"
  grep -q "fleet: 3 governed handoff(s)" <<<"$MIXED" \
    || { echo "FAIL: the surviving valid handoffs are miscounted"; return 1; }
  grep -q "not counted" <<<"$MIXED" || { echo "FAIL: the malformed handoff was swallowed"; return 1; }
  echo "E2E OK: fail-closed (incl. the collision word) · four governed handoffs beside an unchanged K · malformed still named"
  return 0
}
run_check "e2e-four-governed-handoffs" exec e2e_four_handoffs

# --- criterion 4: the decision is IN WRITING, and the code matches it ----------------------------
decision_recorded_and_honoured() {
  local D="docs/decisions/DECISION-007-agent-fleet.md"
  grep -q "S121 addendum" "$D" || { echo "FAIL: no S121 addendum"; return 1; }
  grep -qi 'the role key: \*\*`qa-specialist`\*\*' "$D" \
    || { echo "FAIL: the key decision is not recorded"; return 1; }
  grep -qi 'the tool grant: \*\*`Bash, Read, Write, Edit, Grep, Glob`\*\*' "$D" \
    || { echo "FAIL: the tool grant is not recorded as a decision"; return 1; }

  local ADDENDUM; ADDENDUM="$(sed -n '/^## S121 addendum/,$p' "$D")"
  [ -n "$ADDENDUM" ] || { echo "FAIL: the S121 addendum section is empty"; return 1; }
  local NREJ; NREJ="$(grep -c '^- \*\*Rejected' <<<"$ADDENDUM")"
  echo "rejected-alternative bullets inside the S121 addendum: $NREJ"
  [ "$NREJ" -ge 2 ] \
    || { echo "FAIL: the S121 addendum records $NREJ rejected alternatives; the decision needs at least 2"; return 1; }
  grep -qi 'read-only QA agent' <<<"$ADDENDUM" \
    || { echo "FAIL: the rejected read-only alternative — the one the prompt names — is not recorded"; return 1; }
  # The residual risk of the grant is disclosed, not hidden behind "the role is told not to".
  grep -qi 'residual risk' <<<"$ADDENDUM" \
    || { echo "FAIL: the Write/Edit residual risk is not disclosed"; return 1; }

  # The code matches: the key is distinct AND the bare station word resolves to nothing.
  grep -qE '^[[:space:]]*name: "qa-specialist"' src/fleet/mod.rs \
    || { echo "FAIL: the role key in code is not qa-specialist"; return 1; }
  if grep -rqE '^[[:space:]]*name: "qa"' src/; then
    echo "FAIL: a role keyed 'qa' exists — the collision was not resolved"; return 1
  fi
  echo "OK: the decision is recorded with rejected alternatives + residual risk; code matches it"
  return 0
}
run_check "decision-recorded-honoured" struct decision_recorded_and_honoured

# --- the STATION stays separate from the ROLE (structural: an absence has no output to run) ------
no_station_collision() {
  if grep -rq "qa-specialist" src/qa/ 2>/dev/null; then
    echo "FAIL: the QA STATION now knows about the role — the two were meant to stay separate"; return 1
  fi
  # Positive control: the pattern DOES match where it should, so the absence above means something.
  grep -rq "qa-specialist" src/fleet/ \
    || { echo "FAIL: the pattern matches nothing anywhere — the absence check proves nothing"; return 1; }
  # And the station module really is there to be collided with (not renamed out from under us).
  [ -f src/qa/mod.rs ] || { echo "FAIL: src/qa/mod.rs is gone — this check is vacuous"; return 1; }
  echo "OK: the QA station is untouched by the role key; the probe is non-vacuous"
  return 0
}
run_check "no-station-collision" struct no_station_collision

# --- no 8th command: the fourth role rides `init` + `next`, like the first three -----------------
# BEHAVIORAL, and labelled so (cold review, S121). It runs the real binary, but what it asserts on
# is a hardcoded usage BANNER STRING: an 8th command could be wired into the dispatcher without
# touching that line and this check would stay green. Running the product is not enough to earn the
# `exec` label — the assertion has to bind to the behaviour. The house-wide weak check named since
# S69; reclassified here rather than left flattering itself.
help_lists_seven() {
  local help; help="$("$VAJRA" --help 2>&1)"
  echo "$help"
  grep -q "vajra <init|claude|check|next|estimate|hook|meter>" <<<"$help"
}
run_check "no-eighth-command" behav help_lists_seven

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-34s %-7s %s\n' "STEP" "CLASS" "RESULT"
printf '%-34s %-7s %s\n' "----------------------------------" "-------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo ""
print_tally "$EXEC_N" "$STRUCT_N" "$BEHAV_N" "$NESTED_N" "${NESTED_NAMES[@]:-}"

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
