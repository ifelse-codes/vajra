#!/usr/bin/env bash
# verify-session-144.sh — S144: the chitra FULL-LOOP dogfood.
# Proves, with the REAL installed binary against the REAL brownfield repo chitra:
#   (1) first-contact classification  (2) constitution header preserved byte-for-byte
#   (3) smooth going-forward sync      (4) a governed build to a GREEN close + bound crew
#   (5) chitra undisturbed four ways   (6) the two structural findings recorded
# Runs from the Vajra repo. Checks chitra via git; temporarily checks out its dogfood branch
# for the live sub-runs, then ALWAYS restores chitra's original branch (trap).
set -uo pipefail

CHITRA="/Users/suman/playground/chitra"
BR="session-19-horizontalbar-lock"
# Recorded baseline captured at S144 start (chitra on main, clean):
BASE_HEAD="8945ce4ad7f43c5b6e15498017fd926dc97c2e01"
BASE_TREE="fa094276eb538893b3323db3dec425e9d4f3745a"
SENTINEL="<!-- vajra:governed-body - do not edit below this line - vajra owns and upgrades these bytes -->"

PASS=0; FAIL=0
ok()  { printf '  %-40s PASS\n' "$1"; PASS=$((PASS+1)); }
bad() { printf '  %-40s FAIL  (%s)\n' "$1" "${2:-}"; FAIL=$((FAIL+1)); }

echo "=== S144 verify — chitra full-loop dogfood ==="

# --- durable checks (no checkout needed) ---------------------------------------------------
# C1: the first-contact PRECONDITION is durably true (not prose). chitra main's constitution is the
# boundaryless pre-S143 state — no sentinel, no render stamp, but a real load-order heading. The live
# classification (16 drifted + 1 needs-boundary) is recorded verbatim in the summary; this asserts the
# on-disk state that classification described, read straight from git. (qa rec 1.)
SUM="sessions/session-144-summary.md"
MAIN_AGENTS="$(git -C "$CHITRA" show main:.ai/AGENTS.md 2>/dev/null)"
if [ -n "$MAIN_AGENTS" ] && ! grep -qF "$SENTINEL" <<<"$MAIN_AGENTS" \
   && ! grep -q "vajra-render-sha:" <<<"$MAIN_AGENTS" && grep -q "## Mandatory Load Order" <<<"$MAIN_AGENTS"; then
  ok "C1 first-contact-precondition"
else bad "C1 first-contact-precondition" "main constitution is not the boundaryless pre-S143 state"; fi

# C5: chitra undisturbed ALL FOUR WAYS (qa rec 3) — HEAD + tree + stash list + no-S19-on-main.
NOW_HEAD="$(git -C "$CHITRA" rev-parse main 2>/dev/null)"
NOW_TREE="$(git -C "$CHITRA" rev-parse main^{tree} 2>/dev/null)"
STASHES="$(git -C "$CHITRA" stash list 2>/dev/null | wc -l | tr -d ' ')"
MAIN_TOP="$(git -C "$CHITRA" log --oneline -1 main 2>/dev/null)"
if [ "$NOW_HEAD" = "$BASE_HEAD" ] && [ "$NOW_TREE" = "$BASE_TREE" ] \
   && [ "${STASHES:-0}" -ge 2 ] && ! grep -qiE "S19|horizontalbar" <<<"$MAIN_TOP"; then
  ok "C5 chitra-undisturbed-four-ways"
else bad "C5 chitra-undisturbed-four-ways" "HEAD/tree/stash($STASHES)/main-top drifted from baseline"; fi

# C2: constitution header preserved byte-for-byte. Header = bytes ABOVE the load-order heading on
# main (boundaryless) vs bytes ABOVE the sentinel on the dogfood branch. Must be identical.
HDR_MAIN="$(git -C "$CHITRA" show main:.ai/AGENTS.md 2>/dev/null | awk '/^## Mandatory Load Order/{exit} {print}')"
HDR_S19="$(git -C "$CHITRA" show "$BR:.ai/AGENTS.md" 2>/dev/null | awk -v s="$SENTINEL" 'index($0,s){exit} {print}')"
if [ -n "$HDR_MAIN" ] && [ "$HDR_MAIN" = "$HDR_S19" ]; then
  ok "C2 constitution-header-byte-identical"
else bad "C2 constitution-header-byte-identical" "header above sentinel != original header"; fi

# C4a: the dogfood branch carries the governed body (sentinel + a render stamp).
if git -C "$CHITRA" show "$BR:.ai/AGENTS.md" 2>/dev/null | grep -qF "$SENTINEL" \
   && git -C "$CHITRA" show "$BR:.ai/AGENTS.md" 2>/dev/null | grep -q "vajra-render-sha:"; then
  ok "C4 constitution-body-upgraded"
else bad "C4 constitution-body-upgraded" "sentinel or render-stamp missing on branch"; fi

# C6: the two structural findings are TRUE in the real Vajra source, not merely asserted in prose
# (qa rec 2 + fidelity rec 1 — was a self-grep of the summary; now falsifiable against the code).
# Finding 1 — sync_targets() never lists verify-closeout.sh (the close-gate is not propagated).
# Finding 2 — the canonical close-gate still hardcodes BIN="target/release/vajra" (Vajra's own build).
F1=0; F2=0
awk '/fn sync_targets\(\)/,/^}/' src/cli/init.rs | grep -q "verify-closeout" || F1=1
grep -q 'BIN="target/release/vajra"' scripts/verify-closeout.sh && F2=1
if [ "$F1" = 1 ] && [ "$F2" = 1 ] && [ -f "$SUM" ]; then ok "C6 findings-true-in-source"
else bad "C6 findings-true-in-source" "F1(sync_targets-excludes-closeout)=$F1 F2(gate-hardcodes-BIN)=$F2"; fi

# --- live checks (need chitra on the dogfood branch) ---------------------------------------
ORIG_BR="$(git -C "$CHITRA" symbolic-ref --quiet --short HEAD 2>/dev/null || echo main)"
DIRTY="$(git -C "$CHITRA" status --porcelain --untracked-files=no)"  # tracked changes only; untracked can't block checkout
restore() { git -C "$CHITRA" checkout --quiet "$ORIG_BR" 2>/dev/null; }
trap restore EXIT

if [ -n "$DIRTY" ]; then
  bad "C3 second-sync-smooth"      "chitra tree dirty — cannot run live checks safely"
  bad "C4 chitra-closeout-green"   "chitra tree dirty"
  bad "C4 required-crew-bound"     "chitra tree dirty"
  bad "C4 build-verified"          "chitra tree dirty"
else
  git -C "$CHITRA" checkout --quiet "$BR" 2>/dev/null

  # C3: a repeat --sync-fleet is smooth (0 churn) for all three classes.
  SYNC="$(cd "$CHITRA" && vajra init --sync-fleet 2>&1)"
  if grep -q "0 created, 0 upgraded, 0 refreshed, 17 already current, 0 drifted, 0 needs-boundary" <<<"$SYNC"; then
    ok "C3 second-sync-smooth"
  else bad "C3 second-sync-smooth" "non-zero churn on repeat sync"; fi

  # C4b: chitra's own closeout gate is green (incl. the restored required-crew gate).
  CO="$(cd "$CHITRA" && bash scripts/verify-closeout.sh 19 2>&1)"
  if grep -q "ALL GREEN" <<<"$CO" && grep -qE "required-crew +PASS" <<<"$CO"; then
    ok "C4 chitra-closeout-green"
  else bad "C4 chitra-closeout-green" "verify-closeout not ALL GREEN or crew gate not PASS"; fi

  # C4c: the required crew actually bound — tech-lead + every required role has a real handoff.
  CREW="$(cd "$CHITRA" && vajra next --check-crew 19 2>&1)"
  if grep -q "verdict: READY" <<<"$CREW" && grep -q "every required role has a real handoff" <<<"$CREW"; then
    ok "C4 required-crew-bound"
  else bad "C4 required-crew-bound" "crew verdict not READY / a required handoff missing"; fi

  # C4d: the build is correct — verify-session-19 green (accent-once + no phantom fill live).
  BV="$(cd "$CHITRA" && bash scripts/verify-session-19.sh 2>&1)"
  if grep -q "ALL GREEN" <<<"$BV" && grep -qE "raw-rgb-accent-count-1 +PASS" <<<"$BV" \
     && grep -qE "no-phantom-fill-glyph +PASS" <<<"$BV"; then
    ok "C4 build-verified"
  else bad "C4 build-verified" "verify-session-19 not green / accent or fill assertion missing"; fi

  restore
fi
trap - EXIT

echo ""
echo "=== S144 Verify Summary ==="
if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
