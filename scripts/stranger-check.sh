#!/usr/bin/env bash
# =====================================================================================
# stranger-check.sh — S128. The only instrument in this repo that measures the PRODUCT
# instead of measuring Vajra governing itself.
#
# Every other check here runs inside the repo that builds Vajra, where 125 sessions of
# .ai/ state already exists. That is why four defects survived 125 sessions and 57 public
# days: `vajra --version` did not exist, an unknown subcommand exited 0, `vajra check`
# failed on a file `init` never creates, and the L4 closeout gate crashed on bash 3.2.
# None of them were visible from inside this repo. All four were visible in ten seconds
# from an empty directory.
#
# So: a REAL empty directory, a REAL `git init`, the REAL release binary, and the first
# six things a stranger does — the sixth (S129) being the GOVERNANCE they are handed. Every assertion asserts its own pattern matched (S127) —
# a probe that silently no-ops reports false comfort.
#
# Usage:  bash scripts/stranger-check.sh [--bin /path/to/vajra]
# Exit:   0 = a stranger's first ten minutes work.  1 = they do not.
# =====================================================================================

set -uo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

VAJRA_BIN="${VAJRA_BIN:-}"
if [ "${1:-}" = "--bin" ]; then VAJRA_BIN="${2:-}"; fi

PASS=0; FAIL=0
pass() { printf '  %-52s %s\n' "$1" "PASS"; PASS=$((PASS+1)); }
fail() { printf '  %-52s %s\n' "$1" "FAIL"; FAIL=$((FAIL+1)); [ -n "${2:-}" ] && echo "        └─ $2"; return 0; }

echo "=== stranger-check — first contact, in a real empty directory ==="
echo ""

# ---- the binary a stranger would run --------------------------------------------------
if [ -z "$VAJRA_BIN" ]; then
  echo "  building the release binary…"
  cargo build --release >/dev/null 2>&1 || { echo "BLOCK: cargo build --release failed"; exit 1; }
  VAJRA_BIN="$ROOT/target/release/vajra"
fi
[ -x "$VAJRA_BIN" ] || { echo "BLOCK: no executable vajra at $VAJRA_BIN"; exit 1; }
echo "  binary: $VAJRA_BIN"

# ---- can this host even evaluate criterion 4? (S69: a check that cannot evaluate FAILS)
# bash 3.2 aborts on EXPANDING an empty array under `set -u`. Newer bash does not, so a
# green here on bash 5 would prove nothing about the shell a mac user actually has.
SHELL_UNDER_TEST="/bin/bash"
if "$SHELL_UNDER_TEST" -c 'set -u; a=(); for x in "${a[@]}"; do :; done' >/dev/null 2>&1; then
  BASH32_SEMANTICS=0
else
  BASH32_SEMANTICS=1
fi
echo "  shell under test: $SHELL_UNDER_TEST ($("$SHELL_UNDER_TEST" --version | head -1 | sed 's/GNU bash, //'))"
echo "  bash-3.2 empty-array semantics present: $([ "$BASH32_SEMANTICS" = 1 ] && echo yes || echo NO)"
echo ""

# ---- a real empty directory -----------------------------------------------------------
WORK="$(mktemp -d "${TMPDIR:-/tmp}/vajra-stranger-XXXXXX")"
cleanup() { [ -n "${WORK:-}" ] && rm -rf "$WORK"; }
trap cleanup EXIT
case "$WORK" in
  "$ROOT"*) echo "BLOCK: temp dir is inside the repo — that defeats the whole check"; exit 1;;
esac

( cd "$WORK" && git init -q . ) || { echo "BLOCK: git init failed"; exit 1; }

# `vajra init` scaffolds into its CWD, so it MUST only ever run inside $WORK. Running it
# from the repo root scaffolds over this repo — it happened once while writing this file.
# `</dev/null` is required: init blocks on stdin without EOF.
INIT_OUT="$(cd "$WORK" && [ "$PWD" != "$ROOT" ] && "$VAJRA_BIN" init </dev/null 2>&1)"; INIT_RC=$?
echo "--- scaffold ---"
if [ "$INIT_RC" -eq 0 ] && [ -f "$WORK/.ai/SESSION" ]; then
  pass "vajra init scaffolds an empty directory"
else
  fail "vajra init scaffolds an empty directory" "exit $INIT_RC"
  echo "$INIT_OUT" | tail -5
  echo "RED — nothing else can be measured."; exit 1
fi
echo ""

# =====================================================================================
# Criterion 1 — `vajra --version` prints the crate version and exits 0.
# =====================================================================================
echo "--- criterion 1: vajra --version ---"
EXPECTED_VERSION="$(sed -n '/^\[package\]/,/^\[/p' "$ROOT/Cargo.toml" | sed -n 's/^version = "\(.*\)"/\1/p' | head -1)"
if [ -z "$EXPECTED_VERSION" ]; then
  fail "read [package] version out of Cargo.toml" "the probe itself matched nothing"
else
  pass "read [package] version out of Cargo.toml ($EXPECTED_VERSION)"
  for FLAG in --version -V; do
    OUT="$(cd "$WORK" && "$VAJRA_BIN" "$FLAG" 2>/dev/null)"; RC=$?
    if [ "$RC" -ne 0 ]; then
      fail "vajra $FLAG exits 0" "exit $RC"
    elif ! printf '%s' "$OUT" | grep -qF "$EXPECTED_VERSION"; then
      fail "vajra $FLAG prints $EXPECTED_VERSION" "printed: $(printf '%s' "$OUT" | head -1)"
    elif printf '%s' "$OUT" | grep -q "Scaffold .ai/ workflow"; then
      fail "vajra $FLAG prints a version, not the help banner"
    else
      pass "vajra $FLAG prints $EXPECTED_VERSION and exits 0"
    fi
  done
fi
echo ""

# =====================================================================================
# Criterion 2 — the front door fails CLOSED. The assertion that matters is the shell's:
# `vajra <typo> && anything` must not run `anything`.
# =====================================================================================
echo "--- criterion 2: the front door fails closed ---"
CHAIN="$(cd "$WORK" && "$VAJRA_BIN" chek 2>/dev/null && echo RAN)"
if printf '%s' "$CHAIN" | grep -q RAN; then
  fail "vajra chek && echo RAN does NOT print RAN" "the && chain was not short-circuited — the front door fails OPEN"
else
  pass "vajra chek && echo RAN does NOT print RAN"
fi

ERR="$(cd "$WORK" && "$VAJRA_BIN" chek 2>&1 >/dev/null)"; RC=$?
if [ "$RC" -eq 0 ]; then
  fail "vajra chek exits non-zero" "exit 0"
else
  pass "vajra chek exits non-zero (exit $RC)"
fi
if printf '%s' "$ERR" | grep -qF "chek"; then
  pass "the message names the unrecognised word"
else
  fail "the message names the unrecognised word" "stderr: $(printf '%s' "$ERR" | head -1)"
fi
echo ""

# =====================================================================================
# Criterion 3 — asking for help is not an error. Criterion 2 must not have broken this.
# =====================================================================================
echo "--- criterion 3: help still exits 0 ---"
for INVOCATION in "" "help" "--help" "-h"; do
  # shellcheck disable=SC2086
  ( cd "$WORK" && "$VAJRA_BIN" $INVOCATION ) >/dev/null 2>&1; RC=$?
  LABEL="vajra ${INVOCATION:-<no args>} exits 0"
  if [ "$RC" -eq 0 ]; then pass "$LABEL"; else fail "$LABEL" "exit $RC"; fi
done
echo ""

# =====================================================================================
# Criterion 4 — the L4 closeout gate RUNS on a fresh repo under the macOS default shell.
# RED is a verdict and is allowed. A crash is not.
# =====================================================================================
echo "--- criterion 4: verify-closeout.sh does not crash ---"
if [ ! -f "$WORK/scripts/verify-closeout.sh" ]; then
  fail "vajra init scaffolds scripts/verify-closeout.sh"
elif [ "$BASH32_SEMANTICS" != 1 ]; then
  fail "criterion 4 evaluated under bash-3.2 semantics" \
       "this host's $SHELL_UNDER_TEST does not abort on an empty array under set -u, so a green here would prove nothing. A check that cannot evaluate FAILS (S69). Run on macOS /bin/bash, or install bash 3.2."
else
  CO_OUT="$(cd "$WORK" && "$SHELL_UNDER_TEST" scripts/verify-closeout.sh 2>&1)"
  if printf '%s' "$CO_OUT" | grep -q "unbound variable"; then
    fail "no 'unbound variable' abort" "$(printf '%s' "$CO_OUT" | grep -m1 'unbound variable')"
  else
    pass "no 'unbound variable' abort"
  fi
  if printf '%s' "$CO_OUT" | grep -q "Closeout Verify Summary"; then
    pass "the gate runs to completion and prints its summary"
  else
    fail "the gate runs to completion and prints its summary" \
         "last line: $(printf '%s' "$CO_OUT" | tail -1)"
  fi
fi
echo ""

# =====================================================================================
# Criterion 5 — `vajra check` on a fresh repo reports only TRUE, ACTIONABLE failures.
# =====================================================================================
echo "--- criterion 5: vajra check is honest on arrival ---"
CHECK_OUT="$(cd "$WORK" && "$VAJRA_BIN" check 2>&1)"
if printf '%s' "$CHECK_OUT" | grep -q "varta: matches render"; then
  pass "the varta check ran (probe matched)"
  if printf '%s' "$CHECK_OUT" | grep -q "vajra.varta missing"; then
    fail "vajra.varta missing is NOT reported on a fresh init" \
         "init never creates vajra.varta — the product fails its own health check on arrival"
  else
    pass "vajra.varta missing is NOT reported on a fresh init"
  fi
else
  fail "the varta check ran (probe matched)" "no 'varta: matches render' line — this probe is measuring nothing"
fi

# Every remaining FAIL must be one a new user can act on. The only sanctioned one is
# 'branch: not main', which is true (they are on main) and actionable (branch first).
# Match the STATUS COLUMN, not the word: `Score: 10/11 - 1 FAILED` is a tally line, not a
# check row, and excluding it by name would be an exclusion list — the hole, not the fix (S122).
UNEXPECTED="$(printf '%s\n' "$CHECK_OUT" | grep -E '[[:space:]]FAIL[[:space:]]' | grep -v "branch: not main" || true)"
if [ -z "$UNEXPECTED" ]; then
  pass "every reported FAIL is true and actionable"
else
  fail "every reported FAIL is true and actionable" "unexpected: $(printf '%s' "$UNEXPECTED" | tr '\n' ';')"
fi
echo ""

# =====================================================================================
# Criterion 6 — the GOVERNANCE a stranger is handed (S129).
#
# S128's cold reviewer found the second half of the fork: "a stranger's ground truth will
# never run the audit invented to protect strangers." Every audit in a scaffolded project's
# CONSTRAINTS.yaml must be one a stranger can actually produce evidence for — and the list
# must not have silently shrunk back to a hand-typed subset. The DEEP comparison against the
# live .ai/ is scaffold-drift.sh's job; this is the stranger-facing half of it, asserted from
# inside the scaffold alone.
# =====================================================================================
echo "--- criterion 6: the governance a stranger is handed ---"
# NO MAGIC NUMBERS. The first cut asserted ">= 13 rules" and ">= 10 audits" and carried a typed
# list of audits a stranger cannot run — a hand-typed twin of a live count, introduced by the
# session whose whole purpose was to kill hand-typed twins. S129's cold reviewer called it: it
# would go stale by construction, not by neglect. Every assertion below is RELATIVE — the file
# is checked against its OWN derivation notes and its OWN contents.
SC_AGENTS="$WORK/.ai/AGENTS.md"
SC_CONSTRAINTS="$WORK/.ai/CONSTRAINTS.yaml"

# 6a. The constitution's derivation note claims N rules; the table must have exactly N rows.
# A hand-typed regression loses the note (fails) or keeps a count that no longer matches (fails).
SC_CLAIMED="$(grep -o 'These [0-9]* rules are generated at build time' "$SC_AGENTS" | grep -o '[0-9]*')"
SC_ACTUAL="$(awk '/^## Hard Rules/{f=1;next} f&&/^## /{exit} f&&/^\|/{print}' "$SC_AGENTS" \
  | grep -v '^| *Rule *|' | grep -v '^|[ -]*---' | wc -l | tr -d ' ')"
if [ -z "$SC_CLAIMED" ]; then
  fail "the constitution states how many rules it derived" \
       "no derivation note — this file was hand-typed, which is the S129 regression"
elif [ "$SC_CLAIMED" = "$SC_ACTUAL" ]; then
  pass "the constitution derives $SC_ACTUAL rules and carries $SC_CLAIMED"
else
  fail "the constitution's rule count matches its own derivation note" \
       "note says $SC_CLAIMED, table has $SC_ACTUAL"
fi

# 6b. Same for the audit list: its note says "N of M audits", and M - N omissions must be declared.
SC_NOTE="$(grep -o '— [0-9]* of [0-9]* audits' "$SC_CONSTRAINTS" | head -1)"
SC_AUDIT_N="$(grep -m1 '^ *required_audits:' "$SC_CONSTRAINTS" | sed 's/.*\[//; s/\].*//' \
  | tr ',' '\n' | sed 's/^ *//; s/ *$//' | grep -c '[a-z]')"
if [ -z "$SC_NOTE" ]; then
  fail "the ground truth states how many audits it derived" "no derivation note on required_audits"
else
  SC_CARRIED="$(printf '%s' "$SC_NOTE" | awk '{print $2}')"
  SC_TOTAL="$(printf '%s' "$SC_NOTE" | awk '{print $4}')"
  SC_DECL="$(grep -c 'scaffold-omits-audit: .* — .' "$SC_CONSTRAINTS" | tr -d ' ')"
  if [ "$SC_CARRIED" = "$SC_AUDIT_N" ] && [ "$((SC_TOTAL - SC_CARRIED))" -eq "$SC_DECL" ]; then
    pass "$SC_AUDIT_N audits required, $SC_DECL withheld, and the arithmetic closes"
  else
    fail "the audit list, its note and its declarations agree" \
         "note '$SC_NOTE', list has $SC_AUDIT_N, $SC_DECL declared omission(s)"
  fi
fi

# 6c. THE POINT, derived rather than listed: no audit may demand evidence from a script this
# scaffold does not ship. That is exactly why S128 refused to register `stranger_check` here —
# and it now holds for any FUTURE audit too, without anyone maintaining an exclusion list.
#
# Read from the QUESTION ITEMS only (`^    - `), which is where an audit names the evidence it
# demands. The `scaffold-omits-audit:` comments also name scripts — that is the whole point of
# those comments, and counting them would make the check fire on its own explanation.
UNRUNNABLE=""; SCRIPTS_SEEN=0
while IFS= read -r ref; do
  [ -z "$ref" ] && continue
  SCRIPTS_SEEN=$((SCRIPTS_SEEN+1))
  [ -f "$WORK/$ref" ] || UNRUNNABLE="$UNRUNNABLE $ref"
done <<EOF
$(grep '^    - ' "$SC_CONSTRAINTS" | grep -o 'scripts/[a-zA-Z0-9_.-]*\.sh' | sort -u)
EOF
if [ "$SCRIPTS_SEEN" -eq 0 ]; then
  pass "no audit demands a script at all (nothing to be unable to run)"
elif [ -z "$UNRUNNABLE" ]; then
  pass "all $SCRIPTS_SEEN script(s) their ground truth names are shipped"
else
  fail "every script their ground truth names is shipped" \
       "missing:$UNRUNNABLE — their ground truth would fail a check they cannot run"
fi

# 6d. A withholding must be VISIBLE to them, with a reason — and must not contradict the list.
WITHHELD="$(grep 'scaffold-omits-audit:' "$SC_CONSTRAINTS" 2>/dev/null | sed 's/.*scaffold-omits-audit: *//; s/ *—.*//')"
CONTRADICTION=""
for w in $WITHHELD; do
  grep -m1 '^ *required_audits:' "$SC_CONSTRAINTS" | grep -q "\b$w\b" && CONTRADICTION="$CONTRADICTION $w"
  grep -q "scaffold-omits-audit: $w — ." "$SC_CONSTRAINTS" || CONTRADICTION="$CONTRADICTION $w(no reason)"
done
if [ -z "$WITHHELD" ]; then
  pass "nothing was withheld from this stranger"
elif [ -z "$CONTRADICTION" ]; then
  pass "every withheld audit is named to them with a reason, and none is also required"
else
  fail "withheld audits are named with a reason and not also required" "contradiction:$CONTRADICTION"
fi

# 6e. Reworded rules are declared to them too — the detail-rewrite channel, made visible.
RETEXT_N="$(grep -c 'scaffold-retexts-rule: .* — .' "$SC_AGENTS" | tr -d ' ')"
RETEXT_CLAIM="$(grep -c 'Reworded details' "$SC_AGENTS" | tr -d ' ')"
if [ "$RETEXT_CLAIM" -ge 1 ]; then
  pass "the constitution states its reworded details ($RETEXT_N declared)"
else
  fail "the constitution states its reworded details" \
       "no 'Reworded details' line — a rewritten rule would be invisible to them"
fi
echo ""

# =====================================================================================
echo "=== stranger-check summary ==="
printf '  %-52s %s\n' "checks passed" "$PASS"
printf '  %-52s %s\n' "checks failed" "$FAIL"
echo "  every check above executes the real binary in a real empty directory."
if [ "$FAIL" -eq 0 ]; then
  echo "  GREEN — a stranger's first ten minutes work."
  exit 0
else
  echo "  RED — a stranger hits $FAIL broken thing(s) on arrival."
  exit 1
fi
