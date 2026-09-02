#!/usr/bin/env bash
# =====================================================================================
# fixture-session-141.sh — falsifiability for `vajra init --sync-fleet`'s FOUR states
# (S141: Missing · UpToDate · StaleRender · Drifted).
#
# A green check proves nothing until you have watched it go red. S141 adds a recorded
# `vajra-render-sha:` stamp so an untouched OLD render (StaleRender) can be auto-upgraded
# without `--overwrite-drifted`, while a user edit / unstamped file (Drifted) is still
# refused. The whole claim rests on ONE load-bearing property: the upgrade fires because the
# stamp VERIFIES, not merely because the bytes differ. So the plants here go RED for that
# exact reason — strip or break the stamp and the same file must be REFUSED.
#
# This is a shell fixture driving the REAL release binary in a REAL throwaway dir (stranger-
# check style), never a mock. Each stale render is rebuilt INDEPENDENTLY in shell (sha256 of
# the body-minus-stamp, inserted before the closing frontmatter fence) — if the fixture's own
# stamp math and the product's `render_stamp_verifies` ever disagree, a plant misfires and the
# fixture fails. That cross-check is the point.
#
#   POS  fresh dir, --sync-fleet                 -> exit 0 CLEAN, all 10 role files created
#   UTD  immediate re-run                        -> exit 0, "already current", nothing rewritten
#   STA  a correctly-stamped OLDER render         -> exit 0 (NO --overwrite-drifted), "upgrade" by name
#   RRS  the SAME older body, UNSTAMPED           -> exit 1 REFUSED (the stamp was load-bearing, S122)
#   EDT  a stamped render with one body byte moved -> exit 1 REFUSED (verification actually bites)
#   DRF  an unstamped foreign file                -> exit 1, names --overwrite-drifted, file UNCHANGED
#   OVR  DRF again with --overwrite-drifted        -> exit 0, file rewritten to canonical
#   END  positive control: all resolved, re-run    -> exit 0 CLEAN
#
# Usage:  bash scripts/fixture-session-141.sh
# Exit:   0 = every state behaved exactly as specified AND every falsification fired.
# =====================================================================================

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
BIN="$ROOT/target/release/vajra"
[ -x "$BIN" ] || { echo "BLOCK: $BIN missing — cargo build --release first"; exit 1; }

PASS=0; FAIL=0
pass() { printf '  %-58s %s\n' "$1" "PASS"; PASS=$((PASS+1)); }
fail() { printf '  %-58s %s\n' "$1" "FAIL"; FAIL=$((FAIL+1)); [ -n "${2:-}" ] && echo "        └─ $2"; return 0; }

# A REAL throwaway project root with NO .git ancestor, so `find_project_root` uses it as-is.
WORK="$(mktemp -d "${TMPDIR:-/tmp}/vajra-fix141-XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
cd "$WORK"
R=".claude/agents/researcher.md"   # the role we mutate; the other nine stay canonical throughout

# Run the real binary; capture output + exit code into globals (never a pipe under pipefail).
OUT=""; RC=0
sync() { OUT="$("$BIN" init "$@" 2>&1)"; RC=$?; }

# Insert a CORRECT vajra-render-sha stamp: hash = sha256 of the unstamped file bytes, inserted as
# the last frontmatter line (before the 2nd `---`). Mirrors fleet::stamp_render, computed here so
# the fixture and the product are two independent implementations that must agree.
stamp_file() {  # $1 = unstamped path, $2 = output path
  local h; h="$(shasum -a 256 < "$1" | awk '{print $1}')"
  awk -v h="$h" '/^---$/{c++; if(c==2) print "vajra-render-sha: " h} {print}' "$1" > "$2"
}

echo "=== fixture-141 — do the four --sync-fleet states behave, and does the stamp bite? ==="
echo ""

# --- POS: a fresh dir creates every role file and exits 0 CLEANLY (positive control, S134) -------
sync --sync-fleet
if [ "$RC" -eq 0 ] && [ -f "$R" ]; then
  n="$(ls -1 .claude/agents/*.md 2>/dev/null | wc -l | tr -d ' ')"
  [ "$n" -ge 10 ] && pass "POS fresh --sync-fleet creates all role files, exit 0 CLEAN ($n files)" \
                   || fail "POS fresh sync created only $n role files"
else
  fail "POS fresh --sync-fleet did not exit 0 with role files (exit $RC)"; echo "$OUT" | sed 's/^/        /'
fi

# --- UTD: an immediate re-run is a no-op — exit 0, all up to date, nothing rewritten -------------
BEFORE="$(cat "$R")"
sync --sync-fleet
# A no-op prints only per-file "ok" lines + the all-zero summary. Match per-file ACTION lines (two
# leading spaces + verb), never the summary counts ("0 created, ...") which always name the verbs.
if [ "$RC" -eq 0 ] && grep -q "already current" <<<"$OUT" && ! grep -qE '^  (create|upgrade|refresh|DRIFT)' <<<"$OUT" \
   && [ "$(cat "$R")" = "$BEFORE" ]; then
  pass "UTD re-run is idempotent — exit 0, all current, nothing rewritten"
else
  fail "UTD re-run was not a clean no-op (exit $RC)" "$(grep -E '^  (create|upgrade|refresh|DRIFT)' <<<"$OUT" | head -1)"
fi

# Build a genuine OLDER render for researcher: a valid frontmatter+body that DIFFERS from canonical.
printf '%s\n' '---' 'name: researcher' 'description: an older render of this role' \
  'tools: Read, Grep, Glob' '---' '' 'OLD BODY of an older Vajra render' > "$WORK/older.unstamped"

# --- STA: a correctly-stamped older render auto-upgrades WITHOUT --overwrite-drifted -------------
stamp_file "$WORK/older.unstamped" "$R"
sync --sync-fleet
if [ "$RC" -eq 0 ] && grep -q "upgrade $R" <<<"$OUT" && ! grep -q "OLD BODY" "$R"; then
  pass "STA stamped stale render auto-upgrades (no --overwrite-drifted), reported by name"
else
  fail "STA stale render did not auto-upgrade (exit $RC)" "$(grep -iE 'upgrade|drift' <<<"$OUT" | head -1)"
fi

# --- RRS: the SAME body UNSTAMPED must be REFUSED — proving the STAMP, not the diff, upgraded ----
cp "$WORK/older.unstamped" "$R"        # identical bytes to STA's preimage, minus the stamp line
sync --sync-fleet
if [ "$RC" -eq 1 ] && grep -q "$R" <<<"$OUT"; then
  pass "RRS same body UNSTAMPED is REFUSED (exit 1) — the stamp was load-bearing (S122 right reason)"
else
  fail "RRS an unstamped differing file was NOT refused (exit $RC)" "the upgrade did not depend on the stamp"
fi
"$BIN" init --sync-fleet --overwrite-drifted >/dev/null 2>&1   # restore researcher to canonical

# --- EDT: a stamped render with ONE body byte changed must be REFUSED (verification bites) -------
stamp_file "$WORK/older.unstamped" "$WORK/stamped.tmp"
# Flip one body character AFTER stamping, so the embedded stamp no longer matches the body.
sed 's/OLD BODY/OLD BODZ/' "$WORK/stamped.tmp" > "$R"
sync --sync-fleet
if [ "$RC" -eq 1 ] && grep -q "$R" <<<"$OUT"; then
  pass "EDT a hand-edited stamped render is REFUSED (exit 1) — verification actually bites"
else
  fail "EDT an edited stamped render was NOT refused (exit $RC)" "a broken stamp still auto-upgraded"
fi
"$BIN" init --sync-fleet --overwrite-drifted >/dev/null 2>&1   # restore

# --- DRF: an unstamped foreign file is refused, names the flag, and is left UNCHANGED ------------
printf '%s\n' 'a user'\''s own custom agent — never a Vajra render' > "$R"
FOREIGN="$(cat "$R")"
sync --sync-fleet
if [ "$RC" -eq 1 ] && grep -q -- "--overwrite-drifted" <<<"$OUT" && [ "$(cat "$R")" = "$FOREIGN" ]; then
  pass "DRF foreign file refused (exit 1), names --overwrite-drifted, left UNCHANGED"
else
  fail "DRF a foreign file was not safely refused (exit $RC)" "a user edit may have been clobbered"
fi

# --- OVR: the human's explicit override rewrites the foreign file to canonical, exit 0 ----------
sync --sync-fleet --overwrite-drifted
if [ "$RC" -eq 0 ] && [ "$(cat "$R")" != "$FOREIGN" ] && grep -q "refresh $R" <<<"$OUT"; then
  pass "OVR --overwrite-drifted rewrites the foreign file to canonical, exit 0"
else
  fail "OVR --overwrite-drifted did not rewrite the foreign file (exit $RC)"
fi

# --- END: everything resolved — a final sync is a clean no-op (exit 0) ---------------------------
sync --sync-fleet
if [ "$RC" -eq 0 ] && grep -q "already current" <<<"$OUT" && ! grep -qE '^  (create|upgrade|refresh|DRIFT)' <<<"$OUT"; then
  pass "END positive control: all states resolved, re-run exits 0 CLEAN"
else
  fail "END final sync was not a clean no-op (exit $RC)"
fi

echo ""
echo "fixture-141: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
