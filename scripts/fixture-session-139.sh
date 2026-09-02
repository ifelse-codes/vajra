#!/usr/bin/env bash
# =====================================================================================
# fixture-session-139.sh — falsifiability for check_required_crew (verify-closeout.sh).
#
# A green check proves nothing until you have watched it go red. This gate binds the
# tech-lead's `required` verdict at CLOSE: a session cannot close green when the tech-lead
# handoff is missing, or a role it marked `required` produced no governed handoff. So every
# plant here hides one required handoff and asserts the close-gate goes RED **for that exact
# role** (S122: red for the RIGHT reason, named — not "somewhere"), then GREEN once restored.
# The positive control asserts a CLEAN exit 0 on the pristine, fully-crewed state (S134: not
# just one green line). The IGNORE control proves the gate does not over-fire on a change it
# must not care about — a stray handoff for a role the tech-lead DEFERRED.
#
# This is a shell-gate fixture (not a `cargo test` one like fixture-135): the plants move
# real files under .ai/handoffs/ and the assertion runs the REAL close-gate
# `bash scripts/verify-closeout.sh --crew-only 139`. Every plant asserts its edit LANDED
# (the file is really gone) before its RED is trusted (S127/S128) and restores in place.
#
# PRECONDITION: run this AFTER session 139's tech-lead + three required handoffs
# (design-advisor, implementation-advisor, fidelity-reviewer) are on disk — the baseline
# must be GREEN, or a later RED cannot be attributed to a plant.
#
#   P1  hide the tech-lead handoff             -> RED, reason names the missing tech-lead
#   P2  hide the design-advisor handoff        -> RED, reason names `design-advisor`
#   P3  hide the implementation-advisor handoff-> RED, reason names `implementation-advisor`
#   P4  a gate-less binary (run_dump exit 0)   -> RED (the header guard bites, not just abs.)
#   HDR the real binary emits the exact header -> present (a CLI wording drift is caught)
#   IGN a stray handoff for a DEFERRED role    -> stays GREEN (the gate ignores it)
#   POS pristine, fully-crewed state           -> CLEAN exit 0
#
# Usage:  bash scripts/fixture-session-139.sh
# Exit:   0 = every plant fired naming its own role, the ignore-control stayed green, and
#             the positive control exited 0 cleanly.
# =====================================================================================

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

N=139
GATE=(bash scripts/verify-closeout.sh --crew-only "$N")

PASS=0; FAIL=0
pass() { printf '  %-58s %s\n' "$1" "PASS"; PASS=$((PASS+1)); }
fail() { printf '  %-58s %s\n' "$1" "FAIL"; FAIL=$((FAIL+1)); [ -n "${2:-}" ] && echo "        └─ $2"; return 0; }

HDIR=".ai/handoffs"
TL="$HDIR/session-${N}-tech-lead.md"
DA="$HDIR/session-${N}-design-advisor.md"
IA="$HDIR/session-${N}-implementation-advisor.md"
STRAY="$HDIR/session-${N}-researcher.md"   # a DEFERRED role — no handoff should exist for it

# Run the close-gate; echo "GREEN"/"RED" and capture its output for reason-matching.
GATE_OUT=""
run_gate() {
  GATE_OUT="$("${GATE[@]}" 2>&1)"; local code=$?
  [ "$code" -eq 0 ] && echo GREEN || echo RED
}

# A required handoff must be present to begin. Backup dir + trap restore in place.
for f in "$TL" "$DA" "$IA"; do
  if [ ! -f "$f" ]; then
    echo "BLOCK: precondition — $f is absent. Record session $N's tech-lead + three required"
    echo "       handoffs before running this fixture (the baseline must be GREEN)."
    exit 1
  fi
done
if [ -e "$STRAY" ]; then
  echo "BLOCK: $STRAY already exists — the IGNORE control needs to create and remove it."
  exit 1
fi

BACKUP="$(mktemp -d "${TMPDIR:-/tmp}/vajra-fix139-XXXXXX")"
cp "$TL" "$BACKUP/tl.md"; cp "$DA" "$BACKUP/da.md"; cp "$IA" "$BACKUP/ia.md"
restore() { cp "$BACKUP/tl.md" "$TL"; cp "$BACKUP/da.md" "$DA"; cp "$BACKUP/ia.md" "$IA"; rm -f "$STRAY"; rm -rf "$BACKUP"; }
trap restore EXIT

echo "=== fixture-139 — does check_required_crew actually bite? ==="
echo ""

# Baseline: fully crewed => GREEN (so a later RED is the plant, not a pre-existing gap).
if [ "$(run_gate)" = GREEN ]; then
  pass "baseline: fully-crewed session $N passes the close-gate (GREEN)"
else
  fail "baseline: session $N is NOT green before any plant" "record the tech-lead + 3 required handoffs first"
  echo "$GATE_OUT" | sed 's/^/        /'
  echo ""; echo "fixture-139: $PASS passed, $FAIL failed"; exit 1
fi

# Hide one handoff, assert it LANDED (file gone), assert RED, assert the reason NAMES `needle`.
plant_hides_role() {
  local NAME="$1" FILE="$2" NEEDLE="$3"
  mv "$FILE" "$FILE.hidden"
  if [ -e "$FILE" ]; then
    fail "$NAME" "plant did not land — $FILE still present (a silent no-op)"
    mv "$FILE.hidden" "$FILE"; return 0
  fi
  local verdict; verdict="$(run_gate)"
  if [ "$verdict" != RED ]; then
    fail "$NAME" "close-gate stayed $verdict with $FILE hidden — the gate does not bite"
  elif ! grep -qF "$NEEDLE" <<<"$GATE_OUT"; then
    fail "$NAME" "went RED but for the WRONG reason — output does not name '$NEEDLE' (S122)"
  else
    pass "$NAME"
  fi
  mv "$FILE.hidden" "$FILE"
}

# --- P1: the tech-lead itself is missing -------------------------------------------------------
plant_hides_role "P1 tech-lead handoff hidden -> RED naming the tech-lead" "$TL" "no real tech-lead handoff"

# --- P2: a required specialist is missing (named, not a canned string) --------------------------
plant_hides_role "P2 design-advisor handoff hidden -> RED naming design-advisor" "$DA" "design-advisor"

# --- P3: a DIFFERENT required specialist -> the gate names THAT role, proving it is value-bound --
plant_hides_role "P3 implementation-advisor hidden -> RED naming implementation-advisor" "$IA" "implementation-advisor"

# --- P4: a gate-less binary must NOT green the check — the run_dump exit-0 header guard ----------
# An unknown `vajra next` flag falls through to run_dump() and exits 0 (S132). A build WITHOUT this
# gate would exit 0 and print no crew header; check_required_crew must BLOCK on the absent header,
# never trust the zero exit. Simulate with a stub binary that exits 0 and prints a dump missing the
# header. Back up + restore the real release binary so nothing is left broken.
BIN="target/release/vajra"
if [ -x "$BIN" ]; then
  cp "$BIN" "$BACKUP/vajra.real"
  printf '#!/usr/bin/env bash\necho "vajra next: unknown flag — dumping packet"\nexit 0\n' > "$BIN"
  chmod +x "$BIN"
  verdict="$(run_gate)"
  if [ "$verdict" != RED ]; then
    fail "P4 gate-less binary (no header) -> RED" "gate greened on a run_dump exit-0 with no crew header"
  elif ! grep -qF "does not carry the gate" <<<"$GATE_OUT"; then
    fail "P4 gate-less binary (no header) -> RED" "went RED but not via the header guard (S122 wrong reason)"
  else
    pass "P4 gate-less binary (run_dump exit 0) -> RED via the header guard"
  fi
  cp "$BACKUP/vajra.real" "$BIN"; chmod +x "$BIN"
else
  fail "P4 gate-less binary control" "no $BIN to swap — cannot exercise the header guard"
fi

# --- HDR: the real binary emits the EXACT header the guard greps (a CLI wording drift is caught) --
if "$BIN" next --check-crew "$N" 2>&1 | grep -qF "=== crew: tech-lead for session"; then
  pass "HDR real binary emits the exact header the guard requires"
else
  fail "HDR real binary header drift" "the CLI no longer prints '=== crew: tech-lead for session' — the guard would false-block"
fi

# --- IGN: the ignore control — a stray handoff for a DEFERRED role must NOT turn it red ----------
# The tech-lead deferred `researcher`; a handoff appearing for it changes no `required` obligation.
cp "$BACKUP/da.md" "$STRAY"
if [ ! -f "$STRAY" ]; then
  fail "IGN control plant landed" "could not create $STRAY — the control proves nothing"
else
  if [ "$(run_gate)" = GREEN ]; then
    pass "IGN control: a stray DEFERRED-role handoff keeps the gate GREEN (no over-fire)"
  else
    fail "IGN control: a deferred-role handoff turned the gate RED" "the gate binds more than the required set"
    echo "$GATE_OUT" | sed 's/^/        /'
  fi
  rm -f "$STRAY"
fi

# --- POS: the positive control — pristine, fully-crewed state exits 0 CLEANLY (S134) ------------
"${GATE[@]}" >/dev/null 2>&1 && CODE=0 || CODE=$?
if [ "${CODE:-1}" -eq 0 ]; then
  pass "POS positive control: pristine fully-crewed close-gate exits 0 CLEANLY (S134)"
else
  fail "POS positive control: pristine close-gate did not exit 0 (exit ${CODE})" "the plants did not fully restore"
fi

echo ""
echo "fixture-139: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
