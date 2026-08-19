#!/usr/bin/env bash
# The check-class tally — ONE SOURCE (S123 fix). `print_tally()` and `tally_discloses_nesting()`
# were byte-duplicated across verify-session-121.sh and verify-session-122.sh with nothing binding
# the copies: S122 fixed drift-by-copy for the execution policy (`execution_policy_one_source`)
# and created the identical hazard for the tally in the same diff. Sourced by both scripts now, so
# there is no second copy left to drift — a future change to either function changes both suites.
#
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

# The predicate: does a tally block disclose that it is not a complete count, and name what it
# leaves out? Exit 0 = honest. Same four conditions in both suites — no weaker in either.
tally_discloses_nesting() {
  local TEXT="$1"; local NAME="$2"
  grep -q "NOT a census of everything that ran" <<<"$TEXT" || return 1
  grep -q "nested suites (their own checks are NOT counted above)" <<<"$TEXT" || return 1
  grep -q -- "$NAME" <<<"$TEXT" || return 1
  grep -q "is a FLOOR" <<<"$TEXT" || return 1
  return 0
}
