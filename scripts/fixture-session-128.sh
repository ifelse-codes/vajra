#!/usr/bin/env bash
# =====================================================================================
# fixture-session-128.sh — falsifiability, the S122 way.
#
# The question a fixture must answer is not "does the suite go red?" — it is "does it go
# red for the RIGHT REASON?" So this plants each S128 fix's ORIGINAL DEFECT back into the
# source, one at a time, rebuilds the real binary, and demands that
# `scripts/stranger-check.sh` fails AND that the specific check which should notice is the
# one that reports it.
#
# It also runs the opposite control: RENAMING a message must leave the suite GREEN. A
# fixture that goes red when you reword an error string is measuring spelling, not
# behaviour (S122), and every probe here asserts its own edit actually landed before
# trusting the result (S127: two probes silently no-opped and printed GREEN).
#
# Usage: bash scripts/fixture-session-128.sh
# Exit:  0 = the stranger-check is falsifiable and precise. 1 = it is decorative.
# =====================================================================================

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

MAIN="src/main.rs"
CHECK="src/cli/check.rs"
CLOSEOUT="scripts/verify-closeout.sh"
BACKUP="$(mktemp -d "${TMPDIR:-/tmp}/vajra-fixture-XXXXXX")"

# Back up by CONTENT, not by `git checkout` — restoring from git would silently destroy any
# uncommitted work in these files.
mkdir -p "$BACKUP/src/cli" "$BACKUP/scripts"
cp "$MAIN" "$BACKUP/$MAIN"; cp "$CHECK" "$BACKUP/$CHECK"; cp "$CLOSEOUT" "$BACKUP/$CLOSEOUT"
restore() {
  cp "$BACKUP/$MAIN" "$MAIN"; cp "$BACKUP/$CHECK" "$CHECK"; cp "$BACKUP/$CLOSEOUT" "$CLOSEOUT"
}
cleanup() { restore; cargo build -q --release >/dev/null 2>&1; rm -rf "$BACKUP"; }
trap cleanup EXIT

PASS=0; FAIL=0
report() { printf '  %-56s %s\n' "$1" "$2"; if [ "$2" = PASS ]; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); fi; }

# plant <file> <from> <to>  — asserts the edit ACTUALLY landed (S127). Returns 1 if it no-oped.
plant() {
  local f="$1" from="$2" to="$3"
  python3 - "$f" "$from" "$to" <<'PY'
import sys
f, a, b = sys.argv[1], sys.argv[2], sys.argv[3]
s = open(f).read()
if a not in s:
    sys.exit(3)          # the probe matched NOTHING — false comfort, refuse to continue
open(f, 'w').write(s.replace(a, b, 1))
PY
}

# run_planted <label> <expected-failing-check-substring> ; call AFTER plant() + rebuild
run_planted() {
  local label="$1" expected="$2"
  local out; out="$(/bin/bash scripts/stranger-check.sh --bin "$ROOT/target/release/vajra" 2>&1)"
  local rc=$?
  echo "$out" > "$BACKUP/last-run.log"
  if [ "$rc" -eq 0 ]; then
    report "$label — suite goes RED" FAIL
    echo "        └─ the stranger-check stayed GREEN with the defect planted back"
    return
  fi
  report "$label — suite goes RED" PASS
  if grep -F "$expected" <<<"$out" | grep -q FAIL; then
    report "$label — RED for the RIGHT reason ($expected)" PASS
  else
    report "$label — RED for the RIGHT reason ($expected)" FAIL
    echo "        └─ expected a FAIL on a line containing: $expected"
    grep FAIL <<<"$out" | sed 's/^/           /'
  fi
}

rebuild() { cargo build -q --release >/dev/null 2>&1 || { echo "BLOCK: rebuild failed"; exit 1; }; }

echo "=== fixture-session-128 — planting each S128 defect back, one at a time ==="
echo ""

# ---- control: unplanted, the suite is GREEN ------------------------------------------
rebuild
if /bin/bash scripts/stranger-check.sh --bin "$ROOT/target/release/vajra" >/dev/null 2>&1; then
  report "control — unplanted suite is GREEN" PASS
else
  report "control — unplanted suite is GREEN" FAIL
  echo "        └─ the suite is red before anything was planted; nothing below means much"
fi

# ---- R1: --version routed back to the help banner (the original defect) ---------------
restore
plant "$MAIN" '"--version" | "-V" => Subcommand::Version,' '"--version" | "-V" => Subcommand::Help,' \
  || { report "R1 plant landed" FAIL; echo "        └─ the plant matched nothing"; }
rebuild
run_planted "R1 --version prints the help banner again" "vajra --version prints"

# ---- R2: the front door falls back to Help again (fails OPEN) -------------------------
restore
plant "$MAIN" 'other => Subcommand::Unknown(other.to_string()),' '_ => Subcommand::Help,' \
  || { report "R2 plant landed" FAIL; echo "        └─ the plant matched nothing"; }
rebuild
run_planted "R2 unknown subcommand exits 0 again" "does NOT print RAN"

# ---- R3: asking for help becomes an error (criterion 3 regressed) ---------------------
restore
plant "$MAIN" '        Subcommand::Help => {
            print_usage();
            0
        }' '        Subcommand::Help => {
            print_usage();
            1
        }' || { report "R3 plant landed" FAIL; echo "        └─ the plant matched nothing"; }
rebuild
run_planted "R3 vajra --help exits non-zero" "exits 0"

# ---- R4: the bash 3.2 empty-array expansion, unguarded again -------------------------
restore
plant "$CLOSEOUT" 'for s in ${summaries[@]+"${summaries[@]}"}; do' 'for s in "${summaries[@]}"; do' \
  || { report "R4 plant landed" FAIL; echo "        └─ the plant matched nothing"; }
rebuild
run_planted "R4 verify-closeout.sh crashes on bash 3.2 again" "unbound variable"

# ---- R5: an absent vajra.varta is a failure again ------------------------------------
restore
plant "$CHECK" '        Err(_) => (
            true,
            format!("{RENDER_PATH} not rendered (optional)' '        Err(_) => (
            false,
            format!("{RENDER_PATH} missing — run `vajra check --render`"),
        ),
        #[allow(unreachable_patterns)]
        Err(_) => (
            true,
            format!("{RENDER_PATH} not rendered (optional)' \
  || { report "R5 plant landed" FAIL; echo "        └─ the plant matched nothing"; }
rebuild
run_planted "R5 fresh init fails on vajra.varta again" "vajra.varta missing is NOT reported"

# ---- control: RENAMING a message must leave the suite GREEN (S122) -------------------
restore
plant "$MAIN" "vajra: unrecognised command '{word}'" "vajra: no idea what '{word}' means" \
  || { report "rename control plant landed" FAIL; echo "        └─ the plant matched nothing"; }
rebuild
if /bin/bash scripts/stranger-check.sh --bin "$ROOT/target/release/vajra" >/dev/null 2>&1; then
  report "control — renaming the message leaves it GREEN" PASS
else
  report "control — renaming the message leaves it GREEN" FAIL
  echo "        └─ the stranger-check is spelling-bound, not behaviour-bound (S122)"
fi

restore
rebuild
echo ""
echo "=== fixture summary ==="
printf '  %-56s %s\n' "probes passed" "$PASS"
printf '  %-56s %s\n' "probes failed" "$FAIL"
echo ""
echo "  DISCLOSED, not buried: two of the stranger-check's assertions are bound to STRINGS the"
echo "  product prints — 'Closeout Verify Summary' (used as the gate's completion signal) and"
echo "  'varta: matches render' (used to prove that probe ran at all). Renaming EITHER would"
echo "  turn this suite red for the wrong reason. The rename control above covers the front"
echo "  door's message only; it does not cover those two."
if [ "$FAIL" -eq 0 ]; then
  echo "  GREEN — every S128 fix is falsifiable, and each fails through the check that owns it."
  exit 0
else
  echo "  RED — $FAIL probe(s) failed."
  exit 1
fi
