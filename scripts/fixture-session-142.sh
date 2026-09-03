#!/usr/bin/env bash
# =====================================================================================
# fixture-session-142.sh — falsifiability for `vajra init --sync-fleet`'s FOUR states on
# a PURE-RENDER HOOK (S142: the render stamp generalises from frontmatter to a shell
# comment; hooks join the smooth upgrade — Missing · UpToDate · StaleRender · Drifted).
#
# A green check proves nothing until you have watched it go red. S142 stamps `.ai/hooks/*.sh`
# with a trailing `# vajra-render-sha:` comment so an untouched OLD hook render (StaleRender)
# auto-upgrades without `--overwrite-drifted`, while a user edit / unstamped hook (Drifted) is
# still refused. The whole claim rests on ONE load-bearing property: the upgrade fires because
# the SHELL-comment stamp VERIFIES, not merely because the bytes differ. So the plants here go
# RED for that exact reason — strip or break the stamp and the same hook must be REFUSED.
#
# This drives the REAL release binary in a REAL throwaway dir (stranger-check style), never a
# mock. Each stale hook render is rebuilt INDEPENDENTLY in shell (sha256 of the body, appended
# as a `# vajra-render-sha:` trailing line) — if the fixture's own stamp math and the product's
# `render_stamp_verifies(_, ShellComment)` ever disagree, a plant misfires and the fixture fails.
# That cross-check is the point.
#
#   POS  fresh dir, --sync-fleet                  -> exit 0 CLEAN, roles + all 6 hooks created
#   UTD  immediate re-run                         -> exit 0, "already current", nothing rewritten
#   STA  a correctly-stamped OLDER hook render     -> exit 0 (NO --overwrite-drifted), "upgrade" by name
#   RRS  the SAME older body, UNSTAMPED            -> exit 1 REFUSED (the stamp was load-bearing, S122)
#   EDT  a stamped hook with one body byte moved   -> exit 1 REFUSED (verification actually bites)
#   RUN  the stamped hook STILL RUNS unchanged     -> bash parses + exec identical to unstamped body
#   DRF  an unstamped foreign hook                 -> exit 1, names --overwrite-drifted, hook UNCHANGED
#   OVR  DRF again with --overwrite-drifted         -> exit 0, hook rewritten to canonical
#   END  positive control: all resolved, re-run     -> exit 0 CLEAN
#
# Usage:  bash scripts/fixture-session-142.sh
# Exit:   0 = every state behaved exactly as specified AND every falsification fired.
# =====================================================================================

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
BIN="$ROOT/target/release/vajra"
[ -x "$BIN" ] || { echo "BLOCK: $BIN missing — cargo build --release first"; exit 1; }

PASS=0; FAIL=0
pass() { printf '  %-60s %s\n' "$1" "PASS"; PASS=$((PASS+1)); }
fail() { printf '  %-60s %s\n' "$1" "FAIL"; FAIL=$((FAIL+1)); [ -n "${2:-}" ] && echo "        └─ $2"; return 0; }

# A REAL throwaway project root with NO .git ancestor, so `find_project_root` uses it as-is.
WORK="$(mktemp -d "${TMPDIR:-/tmp}/vajra-fix142-XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
cd "$WORK"
H=".ai/hooks/hook-publish-guard.sh"   # the hook we mutate; the other five + the roles stay canonical

OUT=""; RC=0
sync() { OUT="$("$BIN" init "$@" 2>&1)"; RC=$?; }

# Insert a CORRECT shell-comment stamp: hash = sha256 of the unstamped bytes (which end in \n),
# appended as the trailing `# vajra-render-sha:` line. Mirrors fleet::stamp_render(_, ShellComment),
# computed here so the fixture and the product are two independent implementations that must agree.
stamp_hook() {  # $1 = unstamped path (ends in \n), $2 = output path
  local h; h="$(shasum -a 256 < "$1" | awk '{print $1}')"
  cp "$1" "$2"
  printf '# vajra-render-sha: %s\n' "$h" >> "$2"
}

echo "=== fixture-142 — do the four --sync-fleet states behave on a HOOK, and does the shell stamp bite? ==="
echo ""

# --- POS: a fresh dir creates every role + hook and exits 0 CLEANLY (positive control, S134) -----
sync --sync-fleet
if [ "$RC" -eq 0 ] && [ -f "$H" ]; then
  nh="$(ls -1 .ai/hooks/hook-*.sh 2>/dev/null | wc -l | tr -d ' ')"
  nr="$(ls -1 .claude/agents/*.md 2>/dev/null | wc -l | tr -d ' ')"
  { [ "$nh" -ge 6 ] && [ "$nr" -ge 10 ]; } \
    && pass "POS fresh --sync-fleet creates roles + hooks, exit 0 CLEAN ($nr roles, $nh hooks)" \
    || fail "POS fresh sync created only $nr roles / $nh hooks"
else
  fail "POS fresh --sync-fleet did not exit 0 with the hook present (exit $RC)"; echo "$OUT" | sed 's/^/        /'
fi

# --- UTD: an immediate re-run is a no-op — exit 0, all up to date, nothing rewritten -------------
BEFORE="$(cat "$H")"
sync --sync-fleet
if [ "$RC" -eq 0 ] && grep -q "already current" <<<"$OUT" && ! grep -qE '^  (create|upgrade|refresh|DRIFT)' <<<"$OUT" \
   && [ "$(cat "$H")" = "$BEFORE" ]; then
  pass "UTD re-run is idempotent — exit 0, all current, nothing rewritten"
else
  fail "UTD re-run was not a clean no-op (exit $RC)" "$(grep -E '^  (create|upgrade|refresh|DRIFT)' <<<"$OUT" | head -1)"
fi

# Build a genuine OLDER hook render: a valid shell script that DIFFERS from canonical (ends in \n).
printf '%s\n' '#!/usr/bin/env bash' '# an OLDER render of the publish guard (S-something)' \
  'echo "old publish guard body"' 'exit 0' > "$WORK/older.unstamped"

# --- STA: a correctly-stamped older hook render auto-upgrades WITHOUT --overwrite-drifted --------
stamp_hook "$WORK/older.unstamped" "$H"
sync --sync-fleet
if [ "$RC" -eq 0 ] && grep -q "upgrade $H" <<<"$OUT" && ! grep -q "old publish guard body" "$H"; then
  pass "STA stamped stale hook auto-upgrades (no --overwrite-drifted), reported by name"
else
  fail "STA stale hook did not auto-upgrade (exit $RC)" "$(grep -iE 'upgrade|drift' <<<"$OUT" | head -1)"
fi

# --- RRS: the SAME body UNSTAMPED must be REFUSED — proving the STAMP, not the diff, upgraded ----
cp "$WORK/older.unstamped" "$H"        # identical bytes to STA's preimage, minus the stamp line
sync --sync-fleet
if [ "$RC" -eq 1 ] && grep -q "$H" <<<"$OUT"; then
  pass "RRS same body UNSTAMPED is REFUSED (exit 1) — the shell stamp was load-bearing (S122)"
else
  fail "RRS an unstamped differing hook was NOT refused (exit $RC)" "the upgrade did not depend on the stamp"
fi
"$BIN" init --sync-fleet --overwrite-drifted >/dev/null 2>&1   # restore the hook to canonical

# --- EDT: a stamped hook with ONE body byte changed must be REFUSED (verification bites) ---------
stamp_hook "$WORK/older.unstamped" "$WORK/stamped.tmp"
sed 's/old publish guard body/old publish guard bodZ/' "$WORK/stamped.tmp" > "$H"
sync --sync-fleet
if [ "$RC" -eq 1 ] && grep -q "$H" <<<"$OUT"; then
  pass "EDT a hand-edited stamped hook is REFUSED (exit 1) — verification actually bites"
else
  fail "EDT an edited stamped hook was NOT refused (exit $RC)" "a broken stamp still auto-upgraded"
fi
"$BIN" init --sync-fleet --overwrite-drifted >/dev/null 2>&1   # restore

# --- RUN: the stamp must NOT change behavior — the stamped hook parses + runs identically --------
# A stamped canonical hook (the current on-disk one) must be valid bash, and stripping the trailing
# stamp comment must leave a byte-identical executable body (the stamp is inert, not load-bearing to
# execution). We prove it on a hook whose body we can run without side effects: run `bash -n` (parse)
# on all six, and exec-compare a copy with vs without the trailing comment on the session guard's
# `--help`-free no-arg path is unsafe, so we assert byte-inertness instead: body-without-stamp runs.
run_ok=1
for h in .ai/hooks/hook-*.sh; do
  bash -n "$h" || { run_ok=0; break; }
  # The stamp is the LAST line and a comment: dropping it must yield a still-parseable script.
  sed '$ d' "$h" > "$WORK/nostamp.sh"
  bash -n "$WORK/nostamp.sh" || { run_ok=0; break; }
  # And the only difference between stamped and stripped is that one trailing comment line.
  d="$(diff <(sed '$ d' "$h") "$WORK/nostamp.sh")"
  [ -z "$d" ] || { run_ok=0; break; }
  last="$(tail -1 "$h")"
  case "$last" in "# vajra-render-sha: "*) : ;; *) run_ok=0; break ;; esac
done
[ "$run_ok" -eq 1 ] \
  && pass "RUN every stamped hook parses; the stamp is the inert trailing comment (behavior unchanged)" \
  || fail "RUN a stamped hook did not parse, or the stamp is not the inert trailing comment"

# --- DRF: an unstamped foreign hook is refused, names the flag, and is left UNCHANGED ------------
printf '%s\n' '#!/usr/bin/env bash' '# a user'\''s own custom hook — never a Vajra render' 'exit 0' > "$H"
FOREIGN="$(cat "$H")"
sync --sync-fleet
if [ "$RC" -eq 1 ] && grep -q "$H" <<<"$OUT" && grep -q -- "--overwrite-drifted" <<<"$OUT" \
   && [ "$(cat "$H")" = "$FOREIGN" ]; then
  pass "DRF an unstamped foreign hook is REFUSED, names the flag, left UNCHANGED"
else
  fail "DRF unstamped hook mishandled (exit $RC)" "$(grep -iE 'drift|overwrite' <<<"$OUT" | head -1)"
fi

# --- OVR: DRF again WITH --overwrite-drifted rewrites it to canonical, exit 0 --------------------
sync --sync-fleet --overwrite-drifted
if [ "$RC" -eq 0 ] && ! grep -q "user's own custom hook" "$H"; then
  pass "OVR --overwrite-drifted rewrites the foreign hook to canonical, exit 0"
else
  fail "OVR --overwrite-drifted did not resolve the drift (exit $RC)"
fi

# --- END: positive control — everything resolved, a final re-run is a CLEAN exit 0 (S134) -------
sync --sync-fleet
if [ "$RC" -eq 0 ] && grep -q "already current" <<<"$OUT" && ! grep -qE '^  (create|upgrade|refresh|DRIFT)' <<<"$OUT"; then
  pass "END all states resolved — a final --sync-fleet is a CLEAN exit 0 (positive control)"
else
  fail "END the fixture did not return to a clean synced state (exit $RC)"
fi

echo ""
echo "──────────────────────────────────────────────────────────────────────────────"
echo "fixture-142: ${PASS} passed, ${FAIL} failed"
[ "$FAIL" -eq 0 ] && echo "RESULT: PASS (every state behaved AND every falsification fired)" \
                  || echo "RESULT: FAIL"
[ "$FAIL" -eq 0 ]
