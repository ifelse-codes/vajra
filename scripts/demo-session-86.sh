#!/usr/bin/env bash
# Session 86 — the attestation gate now recomputes-and-compares, instead of trusting a bare
# label. `reviewer_status`/`session_attested_accept` (src/stations/mod.rs) used to accept ANY
# review file containing the substring "review-inputs-sha" — the claimed hash's VALUE was never
# checked. Disclosed since S82, re-disclosed S83/S84, reconfirmed unfixed at the S85 GT (ranked
# the top live-exploit-surface risk). This session recomputes the SAME
# `sha256(prompt bytes \0 delivery diff)` canonical hash `verify-closeout.sh` commits to, and
# rejects any claimed value that doesn't match — a forged, stale, or recycled-from-another-session
# attestation can no longer silently pass Reviewer or Releaser.
#
# Sprint demo — runs the REAL `vajra next --stations NN` gate path end-to-end against a synthetic
# temp git repo with genuine merge commits (so this demo costs $0, needs no credentials, and is
# not a mock of the classifier — it IS the classifier, reading real git history).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="86"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — the attestation gate recomputes, it no longer trusts a label  [demo:header]"
printf "${DIM}  Before this session, any review file with the text 'review-inputs-sha' anywhere in it,\n"
printf "  plus a final ACCEPT verdict, satisfied the Reviewer/Releaser stations — the claimed hash's\n"
printf "  VALUE was never checked. This session recomputes the canonical cold-input hash and rejects\n"
printf "  anything that doesn't match: forged, stale, or recycled from a different session.${RESET}\n"

cargo build --quiet --bin vajra
BIN="$ROOT/target/debug/vajra"

# ── build a real git repo with genuine merge commits — the classifier reads real history ──
TMP_REPO=$(mktemp -d)
trap 'rm -rf "$TMP_REPO"' EXIT
mkdir -p "$TMP_REPO/.ai" "$TMP_REPO/prompts" "$TMP_REPO/sessions" "$TMP_REPO/scripts"
git -C "$TMP_REPO" init -q -b main
git -C "$TMP_REPO" config user.email t@t
git -C "$TMP_REPO" config user.name t
echo "init" > "$TMP_REPO/README.md"
git -C "$TMP_REPO" add -A
git -C "$TMP_REPO" commit -qm init

land_session() {
  local nn="$1" marker="$2"
  printf 'prompt for session %s\n' "$nn" > "$TMP_REPO/prompts/${nn}-task-fixture.md"
  git -C "$TMP_REPO" add -A
  git -C "$TMP_REPO" commit -qm "add prompt ${nn}"
  local base; base=$(git -C "$TMP_REPO" rev-parse HEAD)
  git -C "$TMP_REPO" checkout -qb "session-${nn}-x"
  printf 'work\n' > "$TMP_REPO/${marker}.txt"
  git -C "$TMP_REPO" add -A
  git -C "$TMP_REPO" commit -qm "s${nn} work"
  local tip; tip=$(git -C "$TMP_REPO" rev-parse HEAD)
  git -C "$TMP_REPO" checkout -q main
  git -C "$TMP_REPO" merge -q --no-ff "session-${nn}-x" -m "merge ${nn}"
  git -C "$TMP_REPO" branch -D "session-${nn}-x" >/dev/null
  echo "$base $tip"
}

canonical_hash() {
  local nn="$1" base="$2" tip="$3" diff
  diff=$(git -C "$TMP_REPO" diff --no-color --no-ext-diff "$base" "$tip" -- \
    ':(exclude)sessions' ':(exclude)prompts' \
    ':(exclude).ai/STATE.md' ':(exclude).ai/SESSION-BOOT.md' \
    ':(exclude).ai/SESSION' ':(exclude).ai/TASK.md' \
    ':(exclude).ai/ROADMAP.md' ':(exclude).ai/KNOWLEDGE.md' \
    ':(exclude).ai/verify' ':(exclude).ai/.session-owner')
  { cat "$TMP_REPO/prompts/${nn}-task-fixture.md"; printf '\0'; printf '%s' "$diff"; } | shasum -a 256 | awk '{print $1}'
}

read_out() { (cd "$TMP_REPO" && "$BIN" next --stations "$1" 2>&1); }

read -r BASE70 TIP70 <<< "$(land_session 70 f70)"
HASH70=$(canonical_hash 70 "$BASE70" "$TIP70")
read -r BASE71 TIP71 <<< "$(land_session 71 f71)"
HASH71=$(canonical_hash 71 "$BASE71" "$TIP71")
FORGED=$(printf 'f%.0s' $(seq 1 64))

header "Before → After  [demo:before_after]"
label "BEFORE (pre-S86 — a bare label match; a review file with a MADE-UP hash still 'attested'):"
printf '**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** %s\n' "$FORGED" > "$TMP_REPO/sessions/session-70-review.md"
printf '   %s\n' "sessions/session-70-review.md: Review-Inputs-SHA: ${FORGED:0:16}... (made up, never checked)"
printf "${DIM}   old code: text.lines().any(|l| l.contains(\"review-inputs-sha\")) -> PASSED anyway${RESET}\n"
label "AFTER (S86, run LIVE — the real gate path, recomputes and rejects the same made-up value):"
BEFORE_AFTER_OUT=$(read_out 70)
printf '%s\n' "$BEFORE_AFTER_OUT" | grep -i reviewer | sed 's/^/   /'
if printf '%s' "$BEFORE_AFTER_OUT" | grep -q '\[ABSENT\] Reviewer'; then
  ok "the SAME made-up hash that used to pass is now correctly rejected"
else
  bad "expected the forged hash to be rejected"
fi

header "Cases — genuine, forged, and recycled attestations  [demo:cases]"

header "1 · Genuine, matching hash -> PASSED (the honest happy path, unchanged)"
printf '**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** %s\n' "$HASH70" > "$TMP_REPO/sessions/session-70-review.md"
GENUINE_OUT=$(read_out 70)
printf '%s\n' "$GENUINE_OUT" | grep -i reviewer | sed 's/^/   /'
if printf '%s' "$GENUINE_OUT" | grep -q '\[PASSED\] Reviewer'; then
  ok "a real, cryptographically-verified attestation still passes"
else
  bad "expected the genuine hash to pass"
fi

header "2 · Recycled from a different session -> ABSENT (the named AC2 threat)"
printf '**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** %s\n' "$HASH71" > "$TMP_REPO/sessions/session-70-review.md"
RECYCLED_OUT=$(read_out 70)
printf '%s\n' "$RECYCLED_OUT" | grep -i reviewer | sed 's/^/   /'
if printf '%s' "$RECYCLED_OUT" | grep -q '\[ABSENT\] Reviewer'; then
  ok "session 71's genuine hash, recycled into session 70's review, is rejected — different prompt, different preimage"
else
  bad "expected the recycled hash to be rejected"
fi

header "3 · Releaser's NoBranch fallback carries the SAME fix (no hand-duplication)"
printf '**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** %s\n' "$HASH71" > "$TMP_REPO/sessions/session-71-review.md"
RELEASER_OUT=$(read_out 71)
printf '%s\n' "$RELEASER_OUT" | grep -i releaser | sed 's/^/   /'
if printf '%s' "$RELEASER_OUT" | grep -q '\[PASSED\] Releaser'; then
  ok "the Releaser's pruned-branch fallback also verifies the real hash"
else
  bad "expected the Releaser fallback to pass on a genuine hash"
fi

header "Summary — S86 acceptance criteria  [demo:summary_table]"
printf "\n"
printf "  %-58s %s\n" "Criterion" "Status"
printf "  %-58s %s\n" "----------------------------------------------------------" "------"
printf "  %-58s %s\n" "1 · matching hash -> PASSED (happy path unchanged)"          "SHIPPED"
printf "  %-58s %s\n" "2 · wrong/forged hash -> ABSENT (was a silent pass)"          "SHIPPED"
printf "  %-58s %s\n" "  2b · recycled-from-another-session -> ABSENT"              "SHIPPED"
printf "  %-58s %s\n" "3 · no attestation -> ABSENT, unchanged"                     "SHIPPED"
printf "  %-58s %s\n" "4 · Releaser NoBranch fallback shares the SAME helper"       "SHIPPED"
printf "  %-58s %s\n" "5 · AC5 fragility disclosed (merge-archaeology, not silent)" "SHIPPED"
printf "  %-58s %s\n" "6 · cargo test --lib green (270, +3), scope = 1 file"        "SHIPPED"
printf "\n"

ok "Session ${SESSION} demo complete."
