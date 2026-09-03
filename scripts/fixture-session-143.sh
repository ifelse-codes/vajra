#!/usr/bin/env bash
# =====================================================================================
# fixture-session-143.sh — falsifiability for `vajra init --sync-fleet`'s FIVE states on
# the CONSTITUTION (`.ai/AGENTS.md`), a BOUNDARY target (S143: the render stamp splits a
# per-install FILLED header from a byte-identical GOVERNED body; --sync-fleet upgrades only
# the body, preserving the header verbatim). States: Missing · UpToDate · StaleRender ·
# Drifted · NeedsBoundary.
#
# A green check proves nothing until you have watched it go red. The whole claim rests on TWO
# load-bearing properties, and the plants here go RED for exactly those reasons:
#   (a) the upgrade fires because the MARKDOWN-comment stamp on the BODY VERIFIES, not merely
#       because bytes differ — strip or break the stamp and the same body is REFUSED (S122);
#   (b) an upgrade preserves the user-owned HEADER above the sentinel BYTE-FOR-BYTE — the whole
#       reason the fill/body split exists. A boundaryless constitution (NeedsBoundary) is
#       refused EVEN with --overwrite-drifted, because there is no safe place to split.
#
# This drives the REAL release binary in a REAL throwaway dir, never a mock. Each stale body is
# rebuilt INDEPENDENTLY in shell (sha256 of the preimage, wrapped as an HTML comment) — if the
# fixture's own stamp math and the product's render_stamp_verifies(_, MarkdownComment) ever
# disagree, a plant misfires and the fixture fails. That cross-check is the point.
#
#   POS  fresh `vajra init`                         -> constitution scaffolded, header+sentinel+stamp
#   UTD  immediate --sync-fleet                      -> exit 0, "up to date", nothing rewritten
#   STA  a correctly-stamped OLDER body, CUSTOM hdr  -> exit 0 (NO --overwrite-drifted), "upgrade" by name
#   HDR  after STA: the custom header is UNCHANGED   -> byte-for-byte identical above the sentinel
#   RRS  the SAME older body, UNSTAMPED              -> exit 1 REFUSED (the body stamp was load-bearing)
#   EDT  a stamped body with one byte moved          -> exit 1 REFUSED (verification actually bites)
#   NB   a boundaryless constitution                 -> NeedsBoundary; REFUSED even with --overwrite-drifted,
#                                                       prints the sentinel, header bytes UNCHANGED
#   MIG  paste the sentinel, then --overwrite-drifted -> exit 0, body canonical, header preserved
#   END  positive control: all resolved, re-run       -> exit 0 CLEAN
#
# Usage:  bash scripts/fixture-session-143.sh
# Exit:   0 = every state behaved exactly as specified AND every falsification fired.
# =====================================================================================

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
BIN="$ROOT/target/release/vajra"
[ -x "$BIN" ] || { echo "BLOCK: $BIN missing — cargo build --release first"; exit 1; }

PASS=0; FAIL=0
pass() { printf '  %-62s %s\n' "$1" "PASS"; PASS=$((PASS+1)); }
fail() { printf '  %-62s %s\n' "$1" "FAIL"; FAIL=$((FAIL+1)); [ -n "${2:-}" ] && echo "        └─ $2"; return 0; }

SENTINEL='<!-- vajra:governed-body - do not edit below this line - vajra owns and upgrades these bytes -->'
A=".ai/AGENTS.md"

# A REAL throwaway project root with NO .git ancestor, so `find_project_root` uses it as-is.
WORK="$(mktemp -d "${TMPDIR:-/tmp}/vajra-fix143-XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
cd "$WORK"

OUT=""; RC=0
sync() { OUT="$("$BIN" init "$@" 2>&1)"; RC=$?; }

# Build a stamped MARKDOWN body the way fleet::stamp_render(_, MarkdownComment) does: the preimage
# ends in \n, the stamp is the trailing `<!-- vajra-render-sha: <hex> -->` line. Two independent
# implementations of the same math that must agree, or a plant misfires.
stamp_md() {  # $1 = preimage path (ends in \n), $2 = output path
  local h; h="$(shasum -a 256 < "$1" | awk '{print $1}')"
  cp "$1" "$2"
  printf '<!-- vajra-render-sha: %s -->\n' "$h" >> "$2"
}

# Byte-exact header extraction: the header is the file's bytes BEFORE the first sentinel occurrence —
# exactly what write_target preserves. Done in python so trailing newlines are never stripped (a shell
# $(...) would eat them and make a correct upgrade look like it altered the header).
header_bytes() {  # $1 = file  -> header bytes on stdout
  python3 - "$1" "$SENTINEL" <<'PY'
import sys
d = open(sys.argv[1], "rb").read()
i = d.find(sys.argv[2].encode())
sys.stdout.buffer.write(d[:i] if i >= 0 else d)
PY
}

# A custom, hand-edited USER HEADER (never a Vajra render) — the bytes that must survive an upgrade.
CUSTOM_HEADER=$'# ACME Corp \xe2\x80\x94 Our Own Constitution\n\n> a hand-written preamble we care about\n\n'
printf '%s' "$CUSTOM_HEADER" > "$WORK/custom_header"
# An OLDER governed body preimage: the sentinel + some older governed content.
printf '%s\n\n## Mandatory Load Order\n\nAN OLDER GOVERNED BODY FROM A PRIOR VAJRA\n' "$SENTINEL" > "$WORK/older.preimage"

echo "=== fixture-143 — do the five --sync-fleet states behave on the CONSTITUTION, and is the header safe? ==="
echo ""

# --- POS: a fresh `vajra init` scaffolds the constitution with header + sentinel + stamp ----------
printf 'acme-app\nlock the charts\nL2\n' | "$BIN" init >/dev/null 2>&1
if [ -f "$A" ] && grep -qF "$SENTINEL" "$A" && tail -1 "$A" | grep -q '^<!-- vajra-render-sha:'; then
  pass "POS fresh init scaffolds the constitution: header + sentinel + trailing markdown stamp"
else
  fail "POS fresh init did not scaffold a stamped, bounded constitution"; sed -n '1,3p;$p' "$A" 2>/dev/null | sed 's/^/        /'
fi

# --- UTD: an immediate --sync-fleet is a no-op on the constitution — exit 0, nothing rewritten ----
BEFORE="$(cat "$A")"
sync --sync-fleet
if [ "$RC" -eq 0 ] && grep -q "$A (up to date)" <<<"$OUT" && [ "$(cat "$A")" = "$BEFORE" ]; then
  pass "UTD immediate re-run: constitution up to date, nothing rewritten (no churn)"
else
  fail "UTD constitution was not a clean no-op (exit $RC)" "$(grep -E "AGENTS" <<<"$OUT" | head -1)"
fi

# --- STA: a stamped OLDER body under a CUSTOM header auto-upgrades WITHOUT --overwrite-drifted -----
stamp_md "$WORK/older.preimage" "$WORK/older.body"
printf '%s' "$CUSTOM_HEADER" > "$A"; cat "$WORK/older.body" >> "$A"
sync --sync-fleet
if [ "$RC" -eq 0 ] && grep -q "upgrade $A" <<<"$OUT" && ! grep -q "AN OLDER GOVERNED BODY" "$A"; then
  pass "STA a stamped stale body auto-upgrades (no --overwrite-drifted), reported by name"
else
  fail "STA stale body did not auto-upgrade (exit $RC)" "$(grep -iE 'upgrade|drift' <<<"$OUT" | head -1)"
fi

# --- HDR: the session's core property — the custom header survived the upgrade BYTE-FOR-BYTE -------
header_bytes "$A" > "$WORK/hdr.after"
if cmp -s "$WORK/hdr.after" "$WORK/custom_header"; then
  pass "HDR the user-owned header survived the STA upgrade BYTE-FOR-BYTE"
else
  fail "HDR the upgrade altered the user's header" "the fill/body split leaked into the header"
fi

# --- RRS: the SAME older body UNSTAMPED must be REFUSED — proving the STAMP, not the diff, upgraded -
printf '%s' "$CUSTOM_HEADER" > "$A"; cat "$WORK/older.preimage" >> "$A"   # same body, minus the stamp line
sync --sync-fleet
if [ "$RC" -eq 1 ] && grep -q "$A" <<<"$OUT"; then
  pass "RRS same body UNSTAMPED is REFUSED (exit 1) — the body stamp was load-bearing (S122)"
else
  fail "RRS an unstamped differing body was NOT refused (exit $RC)" "the upgrade did not depend on the stamp"
fi
# restore to canonical for the next plant
printf '%s' "$CUSTOM_HEADER" > "$A"; cat "$WORK/older.body" >> "$A"; "$BIN" init --sync-fleet >/dev/null 2>&1

# --- EDT: a stamped body with ONE byte changed must be REFUSED (verification bites) ---------------
stamp_md "$WORK/older.preimage" "$WORK/stamped.tmp"
printf '%s' "$CUSTOM_HEADER" > "$A"
sed 's/AN OLDER GOVERNED BODY/AN OLDER GOVERNED BODZ/' "$WORK/stamped.tmp" >> "$A"
sync --sync-fleet
if [ "$RC" -eq 1 ] && grep -q "$A" <<<"$OUT"; then
  pass "EDT a hand-edited stamped body is REFUSED (exit 1) — verification actually bites"
else
  fail "EDT an edited stamped body was NOT refused (exit $RC)" "a broken stamp still auto-upgraded"
fi

# --- NB: a boundaryless constitution is NeedsBoundary — refused EVEN with --overwrite-drifted -----
LEGACY=$'# acme-app \xe2\x80\x94 AI Agent Constitution\n\n## Mandatory Load Order\n\nour real hand-written content, no sentinel\n'
printf '%s' "$LEGACY" > "$WORK/legacy"; printf '%s' "$LEGACY" > "$A"
sync --sync-fleet --overwrite-drifted
if [ "$RC" -eq 1 ] && grep -q "needs-boundary" <<<"$OUT" && grep -qF "$SENTINEL" <<<"$OUT" \
   && cmp -s "$A" "$WORK/legacy"; then
  pass "NB boundaryless constitution REFUSED even with --overwrite-drifted; prints the sentinel; header UNTOUCHED"
else
  fail "NB a boundaryless constitution was mishandled (exit $RC)" "--overwrite-drifted must NEVER rewrite it"
fi

# --- MIG: paste the sentinel, then --overwrite-drifted upgrades the body + preserves the header ----
# Insert the sentinel immediately above the load-order heading (the one-time migration).
awk -v s="$SENTINEL" '/^## Mandatory Load Order/ && !done {print s "\n"; done=1} {print}' "$A" > "$WORK/migrated"
mv "$WORK/migrated" "$A"
# After the paste, the header (bytes before the sentinel) is the legacy title + blank line.
printf '%s' $'# acme-app \xe2\x80\x94 AI Agent Constitution\n\n' > "$WORK/mig_header"
sync --sync-fleet --overwrite-drifted
if [ "$RC" -eq 0 ] && ! grep -q "our real hand-written content" "$A"; then
  header_bytes "$A" > "$WORK/mig.after"
  if cmp -s "$WORK/mig.after" "$WORK/mig_header"; then
    pass "MIG paste-sentinel + --overwrite-drifted: body upgraded, migrated header preserved verbatim"
  else
    fail "MIG the migration altered the header bytes"
  fi
else
  fail "MIG the migration did not upgrade the body (exit $RC)"
fi

# --- END: positive control — everything resolved, a final re-run is a CLEAN exit 0 (S134) ---------
sync --sync-fleet
if [ "$RC" -eq 0 ] && grep -q "already current" <<<"$OUT" && grep -q "$A (up to date)" <<<"$OUT" \
   && ! grep -qE '^  (create|upgrade|refresh|DRIFT|BODY)' <<<"$OUT"; then
  pass "END all states resolved — a final --sync-fleet is a CLEAN exit 0 (positive control)"
else
  fail "END the fixture did not return to a clean synced state (exit $RC)"
fi

echo ""
echo "──────────────────────────────────────────────────────────────────────────────"
echo "fixture-143: ${PASS} passed, ${FAIL} failed"
[ "$FAIL" -eq 0 ] && echo "RESULT: PASS (every state behaved AND every falsification fired)" \
                  || echo "RESULT: FAIL"
[ "$FAIL" -eq 0 ]
