#!/usr/bin/env bash
# =====================================================================================
# fixture-session-129.sh — falsifiability for the one-source scaffold.
#
# A green check proves nothing until you have watched it go red. S122: a fixture that goes
# red for the WRONG reason is glued on, so every plant here must turn the suite red
# **through the check that owns it** — never merely "somewhere". And S127/S128: every
# plant asserts its own edit LANDED before its result is trusted; a plant that silently
# no-ops reports false comfort.
#
# Seven plants and one control:
#   P1  a binding rule added to the live constitution, never shipped   -> drift RED (rules)
#   P2  an audit added to the live constraints, never shipped          -> drift RED (audits)
#   P3  a declaration that has gone stale                              -> the BUILD fails
#   P4  a derivation source excluded from the published crate          -> drift RED (package)
#   P5  the stranger_check omission declaration removed                -> stranger-check RED
#   P6  a rule genuinely withheld, with a declared reason              -> drift GREEN, round-trip
#   P7  a rewrite claimed for wording that did not change              -> drift RED (stale rewrite)
#   C   a rule's DETAIL reworded, its NAME untouched                   -> both stay GREEN
#
# The control is the point: identity is the rule NAME. A check that went red on P1..P7 and
# also on C would be diffing bytes, not governing a contract. P6 is the other half of that
# point — the only plant that must stay GREEN, because a DECLARED withholding is a pass by
# design, and it exists because a branch that never runs is not a check (S129 cold review).
#
# Usage:  bash scripts/fixture-session-129.sh
# Exit:   0 = every plant fired through its own check, and the control stayed green.
# =====================================================================================

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

PASS=0; FAIL=0
pass() { printf '  %-56s %s\n' "$1" "PASS"; PASS=$((PASS+1)); }
fail() { printf '  %-56s %s\n' "$1" "FAIL"; FAIL=$((FAIL+1)); [ -n "${2:-}" ] && echo "        └─ $2"; return 0; }

SRC_AGENTS=".ai/AGENTS.md"
SRC_CONSTRAINTS=".ai/CONSTRAINTS.yaml"
SRC_BUILD="build.rs"
SRC_CARGO="Cargo.toml"

# The tree must be clean for these files, or "restore" would silently discard real work.
DIRTY="$(git status --porcelain -- "$SRC_AGENTS" "$SRC_CONSTRAINTS" "$SRC_BUILD" "$SRC_CARGO" 2>/dev/null)"
if [ -n "$DIRTY" ]; then
  echo "BLOCK: uncommitted changes in a file this fixture edits and restores:"
  printf '%s\n' "$DIRTY"
  echo "       Commit or stash first — this fixture restores from disk copies, not from git."
  exit 1
fi

BACKUP="$(mktemp -d "${TMPDIR:-/tmp}/vajra-fix129-XXXXXX")"
cp "$SRC_AGENTS" "$BACKUP/AGENTS.md"
cp "$SRC_CONSTRAINTS" "$BACKUP/CONSTRAINTS.yaml"
cp "$SRC_BUILD" "$BACKUP/build.rs"
cp "$SRC_CARGO" "$BACKUP/Cargo.toml"

REBUILT=0
restore() {
  cp "$BACKUP/AGENTS.md" "$SRC_AGENTS"
  cp "$BACKUP/CONSTRAINTS.yaml" "$SRC_CONSTRAINTS"
  cp "$BACKUP/build.rs" "$SRC_BUILD"
  cp "$BACKUP/Cargo.toml" "$SRC_CARGO"
  # Only pay for the rebuild if a plant actually invalidated the binary.
  [ "$REBUILT" -eq 1 ] && cargo build --release >/dev/null 2>&1
  rm -rf "$BACKUP" "${STALE_BIN:-}"
}
trap restore EXIT

echo "=== fixture-129 — does the one-source guard actually bite? ==="
echo ""

cargo build --release >/dev/null 2>&1 || { echo "BLOCK: baseline release build failed"; exit 1; }
STALE_BIN="$(mktemp "${TMPDIR:-/tmp}/vajra-shipped-XXXXXX")"
cp target/release/vajra "$STALE_BIN"
chmod +x "$STALE_BIN"

# The shipped binary is the scaffold as a stranger would receive it. Plants P1/P2/P4 edit the
# LIVE source and deliberately do NOT rebuild — which is the real-world failure: someone edits
# the constitution and never ships it. That is exactly the state that went unnoticed for 128
# sessions.
drift() { /bin/bash scripts/scaffold-drift.sh --bin "$STALE_BIN" 2>&1; }

# The baseline must be green, or every "it went red" below proves nothing.
BASE="$(drift)"
if printf '%s' "$BASE" | grep -q '^GREEN'; then
  pass "baseline: the shipped scaffold matches the live .ai/"
else
  fail "baseline: the shipped scaffold matches the live .ai/" "already RED — no plant below can be attributed"
  echo "$BASE" | tail -20
  exit 1
fi
echo ""

# ---- P1: a binding rule added live, never shipped --------------------------------------
echo "--- P1: a binding rule added to the live constitution, never shipped ---"
python3 - "$SRC_AGENTS" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
anchor = "| ~2h per session cap | Marathon = drift |\n"
assert anchor in s, "fixture P1: anchor row not found — the plant would have no-opped"
open(p, "w").write(s.replace(anchor, anchor + "| FIXTURE-129 planted rule | proves the drift check bites |\n", 1))
PY
if grep -q 'FIXTURE-129 planted rule' "$SRC_AGENTS"; then
  pass "P1 plant landed in $SRC_AGENTS"
  OUT="$(drift)"
  if printf '%s' "$OUT" | grep -q '^RED'; then
    if printf '%s' "$OUT" | grep -q 'every live rules entry carried or declared *FAIL' \
       && printf '%s' "$OUT" | grep -q 'FIXTURE-129 planted rule'; then
      pass "P1 turns it RED through the RULES check, naming the rule"
    else
      fail "P1 turns it RED through the RULES check, naming the rule" "red, but not through the owning check"
    fi
  else
    fail "P1 turns it RED" "the check stayed green with an unshipped binding rule"
  fi
else
  fail "P1 plant landed in $SRC_AGENTS" "the edit no-opped — this plant measured nothing"
fi
cp "$BACKUP/AGENTS.md" "$SRC_AGENTS"
echo ""

# ---- P2: an audit added live, never shipped ---------------------------------------------
echo "--- P2: a ground-truth audit added to the live constraints, never shipped ---"
python3 - "$SRC_CONSTRAINTS" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
import re
m = re.search(r"^(  required_audits: \[)(.*)(\])$", s, re.M)
assert m, "fixture P2: required_audits line not found — the plant would have no-opped"
s = s[:m.start()] + m.group(1) + m.group(2) + ", fixture_129_audit" + m.group(3) + s[m.end():]
open(p, "w").write(s)
PY
if grep -q 'fixture_129_audit' "$SRC_CONSTRAINTS"; then
  pass "P2 plant landed in $SRC_CONSTRAINTS"
  OUT="$(drift)"
  if printf '%s' "$OUT" | grep -q '^RED'; then
    if printf '%s' "$OUT" | grep -q 'every live audits entry carried or declared *FAIL' \
       && printf '%s' "$OUT" | grep -q 'fixture_129_audit'; then
      pass "P2 turns it RED through the AUDITS check, naming the audit"
    else
      fail "P2 turns it RED through the AUDITS check, naming the audit" "red, but not through the owning check"
    fi
  else
    fail "P2 turns it RED" "the check stayed green with an unshipped required audit"
  fi
else
  fail "P2 plant landed in $SRC_CONSTRAINTS" "the edit no-opped — this plant measured nothing"
fi
cp "$BACKUP/CONSTRAINTS.yaml" "$SRC_CONSTRAINTS"
echo ""

# ---- P3: a stale declaration fails the BUILD --------------------------------------------
# This is the half no shell check can cover: the declaration lives in build.rs, and a
# declaration that can quietly go stale is S128's fakest green wearing a new hat.
echo "--- P3: a declaration that has gone stale ---"
python3 - "$SRC_BUILD" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
anchor = 'const OMIT_AUDITS: &[(&str, &str)] = &[\n'
assert anchor in s, "fixture P3: OMIT_AUDITS not found — the plant would have no-opped"
plant = anchor + '    ("audit_that_no_longer_exists", "a stale declaration planted by fixture-129"),\n'
open(p, "w").write(s.replace(anchor, plant, 1))
PY
if grep -q 'audit_that_no_longer_exists' "$SRC_BUILD"; then
  pass "P3 plant landed in $SRC_BUILD"
  REBUILT=1
  BUILD_OUT="$(cargo build --release 2>&1)"; BUILD_RC=$?
  if [ "$BUILD_RC" -ne 0 ]; then
    if printf '%s' "$BUILD_OUT" | grep -q 'STALE DECLARATION' \
       && printf '%s' "$BUILD_OUT" | grep -q 'audit_that_no_longer_exists'; then
      pass "P3 fails the BUILD, naming the stale declaration"
    else
      fail "P3 fails the BUILD, naming the stale declaration" "build failed for some other reason"
      printf '%s\n' "$BUILD_OUT" | tail -8
    fi
  else
    fail "P3 fails the BUILD" "the build succeeded with a declaration pointing at nothing"
  fi
else
  fail "P3 plant landed in $SRC_BUILD" "the edit no-opped — this plant measured nothing"
fi
cp "$BACKUP/build.rs" "$SRC_BUILD"
echo ""

# ---- P4: a derivation source dropped from the published crate ---------------------------
echo "--- P4: a derivation source excluded from the published crate ---"
python3 - "$SRC_CARGO" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
anchor = '  "!.ai/AGENTS.md",\n'
assert anchor in s, "fixture P4: the un-exclude line is not there — the plant would have no-opped"
open(p, "w").write(s.replace(anchor, "", 1))
PY
if ! grep -q '"!.ai/AGENTS.md"' "$SRC_CARGO"; then
  pass "P4 plant landed in $SRC_CARGO"
  OUT="$(drift)"
  if printf '%s' "$OUT" | grep -q '^RED' \
     && printf '%s' "$OUT" | grep -q '.ai/AGENTS.md is inside the packaged crate *FAIL'; then
    pass "P4 turns it RED through the PACKAGE check"
  else
    fail "P4 turns it RED through the PACKAGE check" \
         "a cargo-installed vajra could not build, and nothing noticed"
  fi
else
  fail "P4 plant landed in $SRC_CARGO" "the edit no-opped — this plant measured nothing"
fi
cp "$BACKUP/Cargo.toml" "$SRC_CARGO"
echo ""

# ---- P5: the stranger_check omission removed ---------------------------------------------
# Deleting the declaration does not delete the audit: the DEFAULT is carried, so the scaffold
# starts demanding an audit whose evidence script it does not ship — the exact thing S128
# refused to do. This is what makes stranger-check's criterion 6 falsifiable rather than green.
echo "--- P5: the stranger_check omission declaration removed ---"
python3 - "$SRC_BUILD" <<'PY'
import sys, re
p = sys.argv[1]
s = open(p).read()
m = re.search(r'\n    \(\n        "stranger_check",\n.*?\n    \),', s, re.S)
assert m, "fixture P5: the stranger_check declaration was not found — the plant would have no-opped"
open(p, "w").write(s[:m.start()] + s[m.end():])
PY
if ! grep -q '"stranger_check"' "$SRC_BUILD"; then
  pass "P5 plant landed in $SRC_BUILD"
  REBUILT=1
  if cargo build --release >/dev/null 2>&1; then
    OUT="$(/bin/bash scripts/stranger-check.sh --bin "$ROOT/target/release/vajra" 2>&1)"
    if printf '%s' "$OUT" | grep -q 'every script their ground truth names is shipped *FAIL' \
       && printf '%s' "$OUT" | grep -q 'scripts/stranger-check.sh'; then
      pass "P5 turns stranger-check RED through the runnable-evidence check, naming the script"
    else
      fail "P5 turns stranger-check RED through the runnable-evidence check, naming the script" \
           "a stranger's ground truth now demands an audit they cannot run, and nothing noticed"
    fi
  else
    fail "P5 rebuild succeeds so the check can be evaluated" "build failed — cannot evaluate"
  fi
else
  fail "P5 plant landed in $SRC_BUILD" "the edit no-opped — this plant measured nothing"
fi
cp "$BACKUP/build.rs" "$SRC_BUILD"
cargo build --release >/dev/null 2>&1
echo ""

# ---- P6: the OMIT_RULES path, exercised end to end ---------------------------------------
# S129's cold reviewer: `OMIT_RULES` is empty, so its `scaffold-omits-rule:` markers are never
# produced and the drift check's rule-omission branch is a pass over an empty list. Declare one
# for real, and prove the whole round trip: the rule LEAVES the scaffold, its marker and reason
# ARRIVE in the stranger's file, and the drift check stays GREEN because it is declared.
echo "--- P6: a rule genuinely withheld, with a declared reason ---"
python3 - "$SRC_BUILD" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
anchor = "const OMIT_RULES: &[(&str, &str)] = &[];"
assert anchor in s, "fixture P6: OMIT_RULES not found — the plant would have no-opped"
plant = ('const OMIT_RULES: &[(&str, &str)] = &[\n'
         '    ("~2h per session cap", "a reason planted by fixture-129 to exercise this path"),\n'
         '];')
open(p, "w").write(s.replace(anchor, plant, 1))
PY
if grep -q 'a reason planted by fixture-129' "$SRC_BUILD"; then
  pass "P6 plant landed in $SRC_BUILD"
  REBUILT=1
  if cargo build --release >/dev/null 2>&1; then
    P6WORK="$(mktemp -d "${TMPDIR:-/tmp}/vajra-p6-XXXXXX")"
    ( cd "$P6WORK" && git init -q . && "$ROOT/target/release/vajra" init </dev/null ) >/dev/null 2>&1
    GONE=0; MARKED=0
    grep -q '^| ~2h per session cap |' "$P6WORK/.ai/AGENTS.md" || GONE=1
    grep -q 'scaffold-omits-rule: ~2h per session cap — a reason planted by fixture-129' \
      "$P6WORK/.ai/AGENTS.md" && MARKED=1
    if [ "$GONE" -eq 1 ] && [ "$MARKED" -eq 1 ]; then
      pass "P6: the rule leaves the scaffold and its reason arrives in the stranger's file"
    else
      fail "P6: the rule leaves the scaffold and its reason arrives in the stranger's file" \
           "rule-removed=$GONE marker-present=$MARKED"
    fi
    OUT="$(/bin/bash scripts/scaffold-drift.sh --bin "$ROOT/target/release/vajra" 2>&1)"
    if printf '%s' "$OUT" | grep -q '^GREEN' \
       && printf '%s' "$OUT" | grep -q 'no stale rules declaration (1 checked)'; then
      pass "P6: a DECLARED omission stays GREEN, and the declaration is checked (1, not 0)"
    else
      fail "P6: a DECLARED omission stays GREEN, and the declaration is checked" \
           "a declared withholding should pass — and the count should stop being zero"
    fi
    rm -rf "$P6WORK"
  else
    fail "P6 rebuild succeeds so the check can be evaluated" "build failed — cannot evaluate"
  fi
else
  fail "P6 plant landed in $SRC_BUILD" "the edit no-opped — this plant measured nothing"
fi
cp "$BACKUP/build.rs" "$SRC_BUILD"
echo ""

# ---- P7: a rewrite claim that is not a rewrite -------------------------------------------
# The detail-rewrite channel, in the direction build.rs cannot see: the rule NAME is still live,
# so no STALE DECLARATION fires, but the "rewritten" wording is identical to ours. The claim is
# false, and the drift check must say so.
echo "--- P7: a rewrite declared for wording that did not change ---"
python3 - "$SRC_BUILD" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
old = 'A green verify script proves discipline, never fidelity.",'
assert old in s, "fixture P7: the retext detail was not found — the plant would have no-opped"
new = 'A green verify script proves discipline, never fidelity. (DECISION-002)",'
open(p, "w").write(s.replace(old, new, 1))
PY
if grep -q 'never fidelity. (DECISION-002)"' "$SRC_BUILD"; then
  pass "P7 plant landed in $SRC_BUILD"
  REBUILT=1
  if cargo build --release >/dev/null 2>&1; then
    OUT="$(/bin/bash scripts/scaffold-drift.sh --bin "$ROOT/target/release/vajra" 2>&1)"
    if printf '%s' "$OUT" | grep -q '^RED' \
       && printf '%s' "$OUT" | grep -q 'no stale rewrite declaration *FAIL' \
       && printf '%s' "$OUT" | grep -q 'declared reworded, but the wording is identical'; then
      pass "P7 turns it RED through the STALE-REWRITE check"
    else
      fail "P7 turns it RED through the STALE-REWRITE check" \
           "a false rewrite claim passed — the declaration channel is decoration"
    fi
  else
    fail "P7 rebuild succeeds so the check can be evaluated" "build failed — cannot evaluate"
  fi
else
  fail "P7 plant landed in $SRC_BUILD" "the edit no-opped — this plant measured nothing"
fi
cp "$BACKUP/build.rs" "$SRC_BUILD"
cargo build --release >/dev/null 2>&1
echo ""

# ---- CONTROL: reword a rule's DETAIL, leave its NAME alone -------------------------------
echo "--- CONTROL: a rule's detail reworded, its name untouched ---"
python3 - "$SRC_AGENTS" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
anchor = "| ~2h per session cap | Marathon = drift |"
assert anchor in s, "fixture control: anchor row not found — the control would have no-opped"
open(p, "w").write(s.replace(anchor, "| ~2h per session cap | FIXTURE-129 reworded detail |", 1))
PY
if grep -q 'FIXTURE-129 reworded detail' "$SRC_AGENTS"; then
  pass "control edit landed in $SRC_AGENTS"
  REBUILT=1
  if cargo build --release >/dev/null 2>&1; then
    OUT="$(/bin/bash scripts/scaffold-drift.sh --bin "$ROOT/target/release/vajra" 2>&1)"
    if printf '%s' "$OUT" | grep -q '^GREEN'; then
      pass "CONTROL stays GREEN — the contract is the rule NAME, not the bytes"
    else
      fail "CONTROL stays GREEN" "rewording a detail turned it red — this check diffs bytes, not governance"
    fi
  else
    fail "control rebuild succeeds so the check can be evaluated" "build failed — cannot evaluate"
  fi
else
  fail "control edit landed in $SRC_AGENTS" "the edit no-opped — the control measured nothing"
fi
echo ""

echo "=== fixture-129: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -eq 0 ]; then
  echo "GREEN — seven plants, each landing through the check that owns it; the control stayed green."
  exit 0
fi
echo "RED — the one-source guard does not bite the way it claims."
exit 1
