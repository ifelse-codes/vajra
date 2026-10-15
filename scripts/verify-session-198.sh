#!/usr/bin/env bash
# Session 198 verify — the known-bug leftovers (founder pick 2, 2026-10-14):
#   F118  `vajra next --advance` moves the old `## Current Session` entry to the first `## Prior Session` on
#         Vajra's shape; any other shape keeps the number swap and says why on stderr.
#   N18   scaffold-drift check 6 picks the last 10 verify scripts by the number in the file name, so a folder
#         with dashes in its path scans the same 10 as one without.
# Every row RUNS the real thing: the built `vajra next --advance` on a temp `vajra init` project, and the real
# scaffold-drift script from two checkouts. Each row runs again with the binary and script from the commit S198
# started at (2830bb2), where it must go red for its own reason (S122). Nothing greps Vajra's source.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(cd "$(mktemp -d)" && pwd -P)"
# A folder with NO dash anywhere in its path, for N18's comparison (mktemp's X's are letters and digits).
ND="$(cd "$(mktemp -d /tmp/v198XXXXXX)" && pwd -P)"
trap 'vajra_old_checkout_remove "${OLD_WT:-}"; for w in "${WD:-}" "${WN:-}"; do [ -n "$w" ] && git worktree remove --force "$w" >/dev/null 2>&1; done; rm -rf "$T" "$ND"' EXIT
OLD_SHA=2830bb2
VAJRA="$ROOT/target/release/vajra"
cargo build --release -q || { echo "FAIL: cargo build --release"; exit 1; }
. "$ROOT/scripts/lib-old-checkout.sh"
OLD_WT=$(vajra_old_checkout "$OLD_SHA") || { echo "FAIL: worktree at $OLD_SHA"; exit 1; }
(cd "$OLD_WT" && CARGO_TARGET_DIR="$ROOT/target/s198-old" cargo build --release -q) || { echo "FAIL: build at $OLD_SHA"; exit 1; }
OLD_VAJRA="$ROOT/target/s198-old/release/vajra"

human() { env -u CLAUDECODE -u CLAUDE_CODE_ENTRYPOINT -u CURSOR_TRACE_ID -u VAJRA_AGENT -u VAJRA_ALLOW_COMMIT \
            -u VAJRA_AGENT_MARK -u CLAUDE_PROJECT_DIR GIT_CONFIG_GLOBAL=/dev/null "$@"; }
has() { printf '%s\n' "$1" | grep -qF -- "$2"; }

# project BIN NAME → a `vajra init` project at L1 (gates advise, so the advance runs), on session 06's branch
# for session 07, with a session-07 prompt. Its SESSION-BOOT is whatever `vajra init` wrote, number set to 06.
project() {
  local p="$T/$2"; rm -rf "$p"; mkdir -p "$p"
  (cd "$p" && human git init -q -b main && human "$1" init </dev/null >/dev/null 2>&1 \
     && perl -pi -e 's/^maturity: L2/maturity: L1/' .ai/CONSTRAINTS.yaml && echo 06 > .ai/SESSION \
     && perl -pi -e 's/\*\*Number:\*\* \d+/**Number:** 06/' .ai/SESSION-BOOT.md \
     && cp prompts/01-task-kickoff.md prompts/07-task-next.md && human git checkout -qb session-07-next)
  printf '%s' "$p"
}
advance() { (cd "$1" && human "$2" next --advance </dev/null 2>&1); }

# Vajra's shape: one entry (with a continuation line, and prose naming both numbers) under Current, then Prior.
ENTRY='- **Number:** 06 — COMPLETE on `session-06-x`. Names 06 and 07 in prose.
  Verify: `scripts/verify-session-06.sh` (3/3).'
vajra_boot() { printf '# Session Boot\n\n## Next Session\n- **S07** next.\n\n## Current Session\n%s\n\n## Prior Session\n- **Number:** 05 — CLOSED.\n\n**New chat.**\n' "$1"; }

# --- 1 (F118, AC1): on Vajra's shape the old entry is the first Prior Session block, byte-for-byte ---
WANT="$T/want-boot"
printf '# Session Boot\n\n## Next Session\n- **S07** next.\n\n## Current Session\n- **Number:** 07 — IN PROGRESS\n\n## Prior Session\n%s\n\n## Prior Session\n- **Number:** 05 — CLOSED.\n\n**New chat.**\n' "$ENTRY" > "$WANT"
P=$(project "$VAJRA" ac1); vajra_boot "$ENTRY" > "$P/.ai/SESSION-BOOT.md"; A1=$(advance "$P" "$VAJRA")
PO=$(project "$OLD_VAJRA" ac1-old); vajra_boot "$ENTRY" > "$PO/.ai/SESSION-BOOT.md"; advance "$PO" "$OLD_VAJRA" >/dev/null
CUR_OLD=$(awk '/^## Current Session/{f=1;next} /^## /{f=0} f' "$PO/.ai/SESSION-BOOT.md")
if [ "$(cat "$P/.ai/SESSION")" = 07 ] && cmp -s "$WANT" "$P/.ai/SESSION-BOOT.md" \
   && has "$A1" "session 06's entry is now the first \`## Prior Session\`" \
   && has "$CUR_OLD" '**Number:** 07 — COMPLETE on `session-06-x`' && ! has "$CUR_OLD" 'IN PROGRESS'; then
  ok "F118 Vajra's shape: Current names only 07 (IN PROGRESS); session 06's entry, continuation line included, is the first Prior Session block byte-for-byte; at $OLD_SHA session 06's story sat under 07"
else bad "F118 AC1:"$'\n'"$(diff "$WANT" "$P/.ai/SESSION-BOOT.md")"$'\n'"$A1"$'\n'"old current: $CUR_OLD"; fi

# --- 2 (F118, AC2): any other shape keeps the number swap and says why the entry did not move ---
# (a) the SESSION-BOOT `vajra init` writes; (b) Vajra's shape with a second entry under Current.
P=$(project "$VAJRA" ac2a); B2A=$(cat "$P/.ai/SESSION-BOOT.md"); A2A=$(advance "$P" "$VAJRA")
# The advance also re-points the `Read prompt` line to session 07's prompt (unchanged behaviour).
W2A=$(printf '%s\n' "$B2A" | perl -pe 's/\*\*Number:\*\* 06/**Number:** 07/; s#prompts/01-task-kickoff\.md#prompts/07-task-next.md#')
P2=$(project "$VAJRA" ac2b); vajra_boot "$ENTRY"$'\n''- **Number:** 04 — a second entry.' > "$P2/.ai/SESSION-BOOT.md"
B2B=$(cat "$P2/.ai/SESSION-BOOT.md"); A2B=$(advance "$P2" "$VAJRA")
W2B=$(printf '%s\n' "$B2B" | perl -pe 's/\*\*Number:\*\* 06/**Number:** 07/')
PO=$(project "$OLD_VAJRA" ac2-old); AO=$(advance "$PO" "$OLD_VAJRA")
NOTE='only the session number moved; the old entry was NOT moved'
if [ "$(cat "$P/.ai/SESSION-BOOT.md")" = "$W2A" ] && [ "$(cat "$P2/.ai/SESSION-BOOT.md")" = "$W2B" ] \
   && has "$A2A" "$NOTE" && has "$A2A" 'is `## Repo State Snapshot`, not `## Prior Session`' \
   && has "$A2B" "$NOTE" && has "$A2B" 'holds more than one entry' \
   && has "$AO" '.ai/SESSION-BOOT.md updated' && ! has "$AO" 'NOT moved'; then
  ok "F118 other shapes (the 'vajra init' one; two entries under Current): number swapped as before, nothing else changed, stderr says why the entry stayed; at $OLD_SHA it said only 'updated'"
else bad "F118 AC2:"$'\n'"$A2A"$'\n'"$A2B"$'\n'"old: $AO"; fi

# --- 3 (N18, AC3): check 6 scans the same 10 scripts from a dashed path as from a path with no dash ---
# Two checkouts of HEAD — one under `n-1-8/` (dashes), one under $ND (none) — each with a planted hollow
# verify-session-199.sh: the highest number, but far from the top by text order. Same files; only the path differs.
case "$ND" in *-*) bad "N18: the no-dash folder $ND has a dash — cannot evaluate";; esac
mkdir -p "$T/n-1-8"; WD="$T/n-1-8/vajra"; WN="$ND/vajra"
git worktree add -q --detach "$WD" HEAD >/dev/null 2>&1; git worktree add -q --detach "$WN" HEAD >/dev/null 2>&1
for w in "$WD" "$WN"; do
  printf '#!/usr/bin/env bash\ngrep -q fn src/main.rs && echo ok\n' > "$w/scripts/verify-session-199.sh"  # source-claim: writes a fixture file, runs nothing
done
EXPECT=$(ls "$WN/scripts" | sed -n 's/^verify-session-\([0-9][0-9]*\)\.sh$/\1/p' | sort -n | tail -10 \
           | sed 's/.*/verify-session-&.sh/' | tr '\n' ' ')
drift() { CLAUDE_PROJECT_DIR="$1" bash "$2" --bin "$3" 2>&1; }
SD=$(drift "$WD" "$WD/scripts/scaffold-drift.sh" "$VAJRA"); SN=$(drift "$WN" "$WN/scripts/scaffold-drift.sh" "$VAJRA")
OD=$(drift "$WD" "$OLD_WT/scripts/scaffold-drift.sh" "$OLD_VAJRA"); ON=$(drift "$WN" "$OLD_WT/scripts/scaffold-drift.sh" "$OLD_VAJRA")
scanned() { printf '%s\n' "$1" | sed -n 's/^  scanned: //p'; }
C6='no hollow src/*.rs grep in verify-session-199.sh'  # source-claim: check 6's own message text, matched in its output below
if [ "$(scanned "$SD")" = "$EXPECT" ] && [ "$(scanned "$SN")" = "$EXPECT" ] && has "$SD" "$C6" && has "$SN" "$C6" \
   && has "$ON" "$C6" && ! has "$OD" "$C6"; then
  ok "N18 check 6 from '…/n-1-8/vajra' and from '$WN' scans the same 10 (${EXPECT% }) and both catch the planted 199; at $OLD_SHA the dashed path missed it"
else bad "N18 AC3: expect=[$EXPECT]"$'\n'"dashed=[$(scanned "$SD")]"$'\n'"plain=[$(scanned "$SN")]"$'\n'"old dashed:"$'\n'"$(printf '%s\n' "$OD" | grep -A3 -- '--- 6')"; fi

# --- 4 (AC4): the SESSION-BOOT unit tests (both shapes, the S191 prose-number case) pass ---
if cargo test -q --lib -- session_boot >"$T/ut.log" 2>&1 && grep -q '5 passed' "$T/ut.log"; then
  ok "the five SESSION-BOOT unit tests pass (Vajra's shape, other shapes, S191's prose numbers, exact swap)"
else bad "SESSION-BOOT unit tests — $(tail -3 "$T/ut.log")"; fi

echo ""
echo "=== verify-session-198: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
