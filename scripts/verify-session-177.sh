#!/usr/bin/env bash
# Session 177 verify — F74 + F76: the close gate every project gets (scripts/verify-closeout-scaffold.sh)
# skipped a CODE session's CODE checks when (F74) the founder moved the next ground truth, or (F76)
# the brief wrote `**CODE.**`. Every check RUNS the real gate functions: the NEW scaffold (this
# checkout) and the OLD one from the pinned commit this session started from (8061a52 — pinned,
# never `main`: after the merge main IS new).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0; SKIP=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
PRE_FIX=8061a52
RUDRA="${RUDRA:-/Users/suman/playground/rudra}"

git show "$PRE_FIX:scripts/verify-closeout-scaffold.sh" > "$T/old.sh" || { bad "old scaffold missing"; exit 1; }
cp scripts/verify-closeout-scaffold.sh "$T/new.sh"

# fx N KEY TYPELINE → a fixture project (CONSTRAINTS with/without the key, one prompt, no scripts)
fx() {
  local P="$T/p$RANDOM$RANDOM"; mkdir -p "$P/prompts" "$P/.ai"
  { echo "session:"; echo "  ground_truth_every_n_sessions: 5"
    [ "$2" = - ] || echo "  ground_truth_next_session: $2"; } > "$P/.ai/CONSTRAINTS.yaml"
  printf '# S\n\n## Type\n%s\n' "$3" > "$P/prompts/$(printf '%02d' "$1")-task-x.md"
  printf '%s' "$P"
}
# cls GATE DIR N → "code=<yes|no> scripts=<PASS|FAIL>" from the gate's own functions, run in DIR
cls() {
  ( cd "$2" && bash -c '
    for f in is_ground_truth_session is_code_session check_verify_demo_scripts spath; do
      source /dev/stdin <<<"$(sed -n "/^$f()/,/^}/p" "$1")"
    done
    waiver_ok() { false; }; ok() { R=PASS; }; bad() { R=FAIL; }
    N=$2; ARTIFACTS=$(mktemp -d); R=; check_verify_demo_scripts
    if is_code_session; then c=yes; else c=no; fi
    echo "code=$c scripts=$R"' _ "$1" "$3" )
}

# --- AC1: the moved ground truth (key 15) ------------------------------------------------------
O=$(cls "$T/old.sh" "$(fx 10 15 '- **CODE**, one story.')" 10)
N=$(cls "$T/new.sh" "$(fx 10 15 '- **CODE**, one story.')" 10)
[ "$O" = "code=no scripts=PASS" ] && [ "$N" = "code=yes scripts=FAIL" ] \
  && ok "AC1 key=15, S10 without scripts: OLD [$O] → NEW [$N] (CODE, blocks)" \
  || bad "AC1 S10: old [$O] new [$N]"
N=$(cls "$T/new.sh" "$(fx 15 15 '- **NO-CODE** ground truth.')" 15)
[ "$N" = "code=no scripts=PASS" ] && ok "AC1 key=15, S15 is the ground truth: [$N] (N/A)" || bad "AC1 S15: [$N]"
N=$(cls "$T/new.sh" "$(fx 11 15 '- **CODE**, one story.')" 11)
[ "$N" = "code=yes scripts=FAIL" ] && ok "AC1 key=15, S11 is CODE: [$N]" || bad "AC1 S11: [$N]"

# --- AC2: no key → old rule, byte-for-byte, across a listed spread ------------------------------
diffs=""
for n in 1 4 5 6 9 10 11 14 15 20 25 99 100 175 180 181; do
  P=$(fx "$n" - '- **CODE**, one story.')
  [ "$(cls "$T/old.sh" "$P" "$n")" = "$(cls "$T/new.sh" "$P" "$n")" ] || diffs="$diffs $n"
done
[ -z "$diffs" ] && ok "AC2 no key: old = new at 16 session numbers (1 4 5 6 9 10 11 14 15 20 25 99 100 175 180 181)" \
  || bad "AC2 no key: old ≠ new at$diffs"

# --- AC3: Type spellings, then old vs new over every real prompt --------------------------------
t_ok=1
for l in '- **CODE.** Max 2 assumptions' '- **CODE**, interactive.' '- **CODE** — fixes' '- **CODE:** one story'; do
  [ "$(cls "$T/new.sh" "$(fx 9 - "$l")" 9)" = "code=yes scripts=FAIL" ] || { t_ok=0; echo "  not CODE: $l"; }
done
for l in '- **NO-CODE.** Max 2' '- **NO-CODE** ground truth' '- **DOCUMENT.** No source'; do
  [ "$(cls "$T/new.sh" "$(fx 9 - "$l")" 9 | cut -d' ' -f1)" = "code=no" ] || { t_ok=0; echo "  read as CODE: $l"; }
done
[ "$t_ok" = 1 ] && ok "AC3 **CODE.** **CODE**, **CODE** — **CODE:** read CODE; **NO-CODE.** **NO-CODE** **DOCUMENT.** do not" \
  || bad "AC3 Type spellings"

# Every prompt, both repos, cadence held neutral (no key; multiples of 5 skipped — AC1/AC2 cover those)
up=0; down=0; same=0; list=""
for repo in "$ROOT" "$RUDRA"; do
  [ -d "$repo/prompts" ] || continue
  for f in "$repo"/prompts/[0-9]*-task-*.md; do
    n=$(basename "$f" | grep -oE '^[0-9]+'); n=$((10#$n)); [ $((n % 5)) -eq 0 ] && continue
    P="$T/s$RANDOM$RANDOM"; mkdir -p "$P/prompts" "$P/.ai"; : > "$P/.ai/CONSTRAINTS.yaml"
    cp "$f" "$P/prompts/$(printf '%02d' "$n")-task-x.md"
    o=$(cls "$T/old.sh" "$P" "$n" | cut -d' ' -f1); w=$(cls "$T/new.sh" "$P" "$n" | cut -d' ' -f1); rm -rf "$P"
    if [ "$o" = "$w" ]; then same=$((same+1))
    elif [ "$w" = code=yes ]; then up=$((up+1)); list="$list $(basename "$repo")/$n"
    else down=$((down+1)); echo "  LOOSENED: $f"; fi
  done
done
echo "$list" | tr ' ' '\n' | sed '/^$/d' > "$T/flips.txt"
[ "$down" -eq 0 ] && [ "$up" -gt 0 ] \
  && ok "AC3 old vs new over every prompt: $same same · $up non-CODE → CODE ($(tr '\n' ' ' < "$T/flips.txt")) · 0 CODE → non-CODE" \
  || bad "AC3 sweep: same=$same up=$up down=$down"

# --- AC4: rudra's OWN gate, after the sync, in rudra's own tree ---------------------------------
if [ -f "$RUDRA/scripts/verify-closeout.sh" ]; then
  R10=$(cls "$RUDRA/scripts/verify-closeout.sh" "$RUDRA" 10 | cut -d' ' -f1)
  R9=$(cls "$RUDRA/scripts/verify-closeout.sh" "$RUDRA" 9 | cut -d' ' -f1)
  grep -q '^is_ground_truth_session()' "$RUDRA/scripts/verify-closeout.sh" && [ "$R10" = code=yes ] && [ "$R9" = code=yes ] \
    && ok "AC4 rudra's own gate (synced) in rudra's tree: S10 $R10 · S09 $R9 (its **CODE.** brief)" \
    || bad "AC4 rudra gate: S10 $R10 · S09 $R9 (synced? $(grep -c '^is_ground_truth_session()' "$RUDRA/scripts/verify-closeout.sh"))"
else echo "SKIP: AC4 — no rudra checkout at $RUDRA"; SKIP=$((SKIP+1)); fi

# --- the Rust tests run the same functions ------------------------------------------------------
cargo test -q --test scaffold_gt_cadence >"$T/ct.txt" 2>&1 && ok "cargo test --test scaffold_gt_cadence ($(grep -oE '[0-9]+ passed' "$T/ct.txt" | head -1))" \
  || { bad "scaffold_gt_cadence tests"; tail -20 "$T/ct.txt"; }
bash -n scripts/verify-closeout-scaffold.sh && ok "scaffold parses (bash -n)" || bad "scaffold syntax"

echo "=== S177: $PASS pass · $FAIL fail · $SKIP skip ==="
[ "$FAIL" -eq 0 ]
