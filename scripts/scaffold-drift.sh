#!/usr/bin/env bash
# =====================================================================================
# scaffold-drift.sh — S129. Does what `vajra init` hands a stranger still match what this
# repo runs on?
#
# For 128 sessions nothing asked. The answer had drifted to 8 binding rules against 13 and
# 7 ground-truth audits against 11, with no reason on record for a single omission
# (`sessions/session-129-fork-measurement.md`). The binding sets are now DERIVED at build
# time by `build.rs`, so this script is the INDEPENDENT second opinion: it never reads the
# template constants or the generated fragments, only the files a REAL `vajra init` writes
# into a REAL empty directory using the REAL release binary.
#
# Four questions, both directions, over three inventories — binding RULES, ground-truth
# AUDITS, and drift AXES (the axes are here because S129's own cold review found them forked
# 6-against-7, three lines above the fix, invisible to every instrument the session built):
#   1. Is every LIVE element either carried into the scaffold, or DECLARED out with a reason?
#   2. Did the scaffold INVENT an element this repo does not have?
#   3. Is every DECLARATION still true — the element still live, and still actually absent?
#      (S128's fakest green was a hand-typed list that measured the boundary its own author
#      drew. A declaration that can go stale unnoticed is the same bug.)
#   3b. Is every rewritten rule DETAIL declared with a reason, and is every rewrite claim real?
#      Names are the identity, so a detail rewrite would otherwise be a silent channel to
#      invert a rule's meaning while the file still read "Declared omissions: none".
#      HONEST ABOUT WHICH HALF IS PROVEN: the STALE-CLAIM direction is falsified by fixture P7.
#      The UNDECLARED-REWRITE direction is a RENDERER-REGRESSION GUARD, not a live check — every
#      `RETEXT_RULES` entry auto-emits its own marker, so reaching that branch means the renderer
#      broke. And a standing limit neither half covers: once a rule is declared retexted, its
#      stranger-facing wording is unconstrained. The guard proves a declaration and a reason
#      exist; it never proves the rewrite preserves the rule.
#
# It NAMES what it compared. A bare OK would be indistinguishable from a check that ran
# over an empty list, which is exactly how a probe reports false comfort (S127).
#
# Usage:  bash scripts/scaffold-drift.sh [--bin /path/to/vajra]
# Exit:   0 = the scaffold and the live .ai/ agree.  1 = they have drifted.
# =====================================================================================

set -uo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

VAJRA_BIN="${VAJRA_BIN:-}"
if [ "${1:-}" = "--bin" ]; then VAJRA_BIN="${2:-}"; fi

PASS=0; FAIL=0
pass() { printf '  %-58s %s\n' "$1" "PASS"; PASS=$((PASS+1)); }
fail() { printf '  %-58s %s\n' "$1" "FAIL"; FAIL=$((FAIL+1)); [ -n "${2:-}" ] && echo "        └─ $2"; return 0; }

echo "=== scaffold-drift — is a stranger governed by what we are governed by? ==="
echo ""

# ---- the binary a stranger would run --------------------------------------------------
if [ -z "$VAJRA_BIN" ]; then
  echo "  building the release binary…"
  cargo build --release >/dev/null 2>&1 || { echo "BLOCK: cargo build --release failed"; exit 1; }
  VAJRA_BIN="$ROOT/target/release/vajra"
fi
[ -x "$VAJRA_BIN" ] || { echo "BLOCK: no executable vajra at $VAJRA_BIN"; exit 1; }
echo "  binary:      $VAJRA_BIN"
echo "  live source: .ai/AGENTS.md · .ai/CONSTRAINTS.yaml"
echo ""

# ---- a real empty directory (never this repo — `vajra init` scaffolds into its CWD) ----
WORK="$(mktemp -d "${TMPDIR:-/tmp}/vajra-drift-XXXXXX")"
LIST="$(mktemp -d "${TMPDIR:-/tmp}/vajra-drift-lists-XXXXXX")"
cleanup() { rm -rf "${WORK:-}" "${LIST:-}"; }
trap cleanup EXIT
case "$WORK" in
  "$ROOT"*) echo "BLOCK: temp dir is inside the repo — that defeats the whole check"; exit 1;;
esac

( cd "$WORK" && git init -q . ) || { echo "BLOCK: git init failed"; exit 1; }
# `</dev/null` is required: init blocks on stdin without EOF (S125).
( cd "$WORK" && [ "$PWD" != "$ROOT" ] && "$VAJRA_BIN" init </dev/null ) >/dev/null 2>&1
[ -f "$WORK/.ai/AGENTS.md" ] && [ -f "$WORK/.ai/CONSTRAINTS.yaml" ] || {
  echo "BLOCK: vajra init did not scaffold .ai/ — nothing can be compared"; exit 1; }

# ---- extraction (IDENTICAL code on both sides, so the comparison is symmetric) ---------
rule_rows() {   # $1 = an AGENTS.md -> `name<TAB>detail`
  awk '/^## Hard Rules/{f=1;next} f&&/^## /{exit} f&&/^\|/{print}' "$1" \
    | grep -v '^| *Rule *|' | grep -v '^|[ -]*---' \
    | sed 's/^| *//; s/ *|$//' | awk -F' *\\| *' '{print $1 "\t" $2}'
}
rule_names() {  # $1 = an AGENTS.md
  rule_rows "$1" | cut -f1
}
inline_list() { # $1 = a CONSTRAINTS.yaml, $2 = the key
  grep -m1 "^ *$2:" "$1" \
    | sed 's/.*\[//; s/\].*//' | tr ',' '\n' | sed 's/^ *//; s/ *$//' | grep -v '^$'
}
declared() {    # $1 = file, $2 = marker word (scaffold-omits-rule|-audit|-axis, scaffold-retexts-rule)
  grep "$2:" "$1" 2>/dev/null | sed "s/.*$2: *//; s/ *—.*$//" | sed 's/ *$//' | grep -v '^$'
}
reason_for() {  # $1 = file, $2 = marker word, $3 = element -> the text after the em dash
  grep -F "$2: $3 — " "$1" 2>/dev/null | head -1 | sed 's/.*— *//'
}

rule_rows    "$ROOT/.ai/AGENTS.md"                        > "$LIST/live_rows"
rule_rows    "$WORK/.ai/AGENTS.md"                        > "$LIST/scaf_rows"
cut -f1 "$LIST/live_rows"                                 > "$LIST/live_rules"
cut -f1 "$LIST/scaf_rows"                                 > "$LIST/scaf_rules"
inline_list "$ROOT/.ai/CONSTRAINTS.yaml" required_audits  > "$LIST/live_audits"
inline_list "$WORK/.ai/CONSTRAINTS.yaml" required_audits  > "$LIST/scaf_audits"
inline_list "$ROOT/.ai/CONSTRAINTS.yaml" drift_axes       > "$LIST/live_axes"
inline_list "$WORK/.ai/CONSTRAINTS.yaml" drift_axes       > "$LIST/scaf_axes"
declared "$WORK/.ai/AGENTS.md"        scaffold-omits-rule   > "$LIST/decl_rules"
declared "$WORK/.ai/CONSTRAINTS.yaml" scaffold-omits-audit  > "$LIST/decl_audits"
declared "$WORK/.ai/CONSTRAINTS.yaml" scaffold-omits-axis   > "$LIST/decl_axes"
declared "$WORK/.ai/AGENTS.md"        scaffold-retexts-rule > "$LIST/retext_rules"

# S127/S128: a probe that silently no-ops reports false comfort. If either side extracted
# nothing, this script cannot evaluate — and a check that cannot evaluate FAILS (S69).
for f in live_rules scaf_rules live_audits scaf_audits live_axes scaf_axes; do
  if [ ! -s "$LIST/$f" ]; then
    echo "BLOCK: extracted ZERO elements for '$f'. The parser and the file disagree —"
    echo "       a green verdict here would be meaningless. Fix the extractor, not the list."
    exit 1
  fi
done

n() { wc -l < "$1" | tr -d ' '; }
echo "--- what is being compared ---"
echo "  live rules   : $(n "$LIST/live_rules")   scaffold rules   : $(n "$LIST/scaf_rules")   declared omissions: $(n "$LIST/decl_rules")   reworded: $(n "$LIST/retext_rules")"
echo "  live audits  : $(n "$LIST/live_audits")   scaffold audits  : $(n "$LIST/scaf_audits")   declared omissions: $(n "$LIST/decl_audits")"
echo "  live axes    : $(n "$LIST/live_axes")   scaffold axes    : $(n "$LIST/scaf_axes")   declared omissions: $(n "$LIST/decl_axes")"
echo ""
echo "  live rules, by name:"
sed 's/^/    · /' "$LIST/live_rules"
echo "  live audits, by name:"
sed 's/^/    · /' "$LIST/live_audits"
echo ""

has() { grep -Fxq "$1" "$2"; }

# ---- 1. every LIVE element is carried, or DECLARED out --------------------------------
echo "--- 1. every live element reaches a stranger, or is declared out with a reason ---"
for kind in rules audits axes; do
  MISSING=""
  while IFS= read -r el; do
    [ -z "$el" ] && continue
    if has "$el" "$LIST/scaf_$kind"; then continue; fi
    if has "$el" "$LIST/decl_$kind"; then continue; fi
    MISSING="$MISSING
    · $el"
  done < "$LIST/live_$kind"
  if [ -z "$MISSING" ]; then
    pass "every live $kind entry carried or declared ($(n "$LIST/live_$kind") checked)"
  else
    fail "every live $kind entry carried or declared" "undeclared and NOT in the scaffold:$MISSING"
  fi
done
echo ""

# ---- 2. the scaffold invented nothing --------------------------------------------------
echo "--- 2. the scaffold invented nothing this repo is not governed by ---"
for kind in rules audits axes; do
  EXTRA=""
  while IFS= read -r el; do
    [ -z "$el" ] && continue
    has "$el" "$LIST/live_$kind" || EXTRA="$EXTRA
    · $el"
  done < "$LIST/scaf_$kind"
  if [ -z "$EXTRA" ]; then
    pass "no invented $kind entry ($(n "$LIST/scaf_$kind") checked)"
  else
    fail "no invented $kind entry" "in the scaffold, absent from the live .ai/:$EXTRA"
  fi
done
echo ""

# ---- 3. no stale declaration -----------------------------------------------------------
echo "--- 3. every declared omission is still true (live, and still absent) ---"
for kind in rules audits axes; do
  if [ ! -s "$LIST/decl_$kind" ]; then
    # Say so. A pass over an empty list is a STRUCTURAL NO-OP, and this repo's own rule (S129
    # KNOWLEDGE) is: plant a fixture that exercises the branch, or label it in the tally.
    # Fixture P6 plants a real OMIT_RULES entry and drives this branch to `(1 checked)`.
    pass "STRUCTURAL NO-OP today: no $kind declared, so nothing to go stale"
    continue
  fi
  STALE=""
  while IFS= read -r el; do
    [ -z "$el" ] && continue
    has "$el" "$LIST/live_$kind" || STALE="$STALE
    · $el — declared out, but no longer in the live .ai/ at all"
    has "$el" "$LIST/scaf_$kind" && STALE="$STALE
    · $el — declared out, but the scaffold carries it anyway"
  done < "$LIST/decl_$kind"
  if [ -z "$STALE" ]; then
    pass "no stale $kind declaration ($(n "$LIST/decl_$kind") checked)"
  else
    fail "no stale $kind declaration" "$STALE"
  fi
done
echo ""

# ---- 3b. a rewritten rule DETAIL is declared, with a reason -----------------------------
# The rule NAME is the identity, so the checks above are name-based on purpose. That leaves a
# channel S129's cold reviewer named: an author could rewrite a rule's DETAIL — inverting its
# meaning — while the file still said "Declared omissions: none". So compare the details too,
# and require every difference to carry its own marker AND a reason.
echo "--- 3b. every reworded rule detail is declared, with a reason ---"
UNDECLARED_RETEXT=""; CHECKED_DETAIL=0
while IFS="$(printf '\t')" read -r name detail; do
  [ -z "$name" ] && continue
  has "$name" "$LIST/scaf_rules" || continue          # omitted rules are section 1's business
  CHECKED_DETAIL=$((CHECKED_DETAIL+1))
  SCAF_DETAIL="$(grep -F "$name$(printf '\t')" "$LIST/scaf_rows" | head -1 | cut -f2-)"
  [ "$SCAF_DETAIL" = "$detail" ] && continue
  if has "$name" "$LIST/retext_rules" \
     && [ -n "$(reason_for "$WORK/.ai/AGENTS.md" scaffold-retexts-rule "$name")" ]; then
    continue
  fi
  UNDECLARED_RETEXT="$UNDECLARED_RETEXT
    · $name — the stranger's wording differs from ours and nothing declares it"
done < "$LIST/live_rows"
if [ "$CHECKED_DETAIL" -eq 0 ]; then
  fail "every reworded rule detail is declared" "compared ZERO details — the probe matched nothing"
elif [ -z "$UNDECLARED_RETEXT" ]; then
  pass "every reworded rule detail is declared ($CHECKED_DETAIL detail(s) compared)"
else
  fail "every reworded rule detail is declared" "$UNDECLARED_RETEXT"
fi
# ...and the reverse: a rewrite marker for a rule that is not actually reworded is a stale claim.
STALE_RETEXT=""
while IFS= read -r name; do
  [ -z "$name" ] && continue
  LIVE_DETAIL="$(grep -F "$name$(printf '\t')" "$LIST/live_rows" | head -1 | cut -f2-)"
  SCAF_DETAIL="$(grep -F "$name$(printf '\t')" "$LIST/scaf_rows" | head -1 | cut -f2-)"
  if [ -z "$LIVE_DETAIL" ]; then
    STALE_RETEXT="$STALE_RETEXT
    · $name — declared reworded, but it is not a live rule at all"
  elif [ "$LIVE_DETAIL" = "$SCAF_DETAIL" ]; then
    STALE_RETEXT="$STALE_RETEXT
    · $name — declared reworded, but the wording is identical"
  fi
done < "$LIST/retext_rules"
if [ -z "$STALE_RETEXT" ]; then
  pass "no stale rewrite declaration ($(n "$LIST/retext_rules") checked)"
else
  fail "no stale rewrite declaration" "$STALE_RETEXT"
fi
echo ""

# ---- 4. the provenance a stranger can read ---------------------------------------------
echo "--- 4. the scaffold says it is derived, and says what was withheld ---"
if grep -q 'Derived, not typed' "$WORK/.ai/AGENTS.md"; then
  pass "scaffold constitution carries its derivation provenance"
else
  fail "scaffold constitution carries its derivation provenance" \
       "no 'Derived, not typed' note — a hand-typed regression would be invisible"
fi
if grep -q 'DERIVED at build time' "$WORK/.ai/CONSTRAINTS.yaml"; then
  pass "scaffold constraints carry their derivation provenance"
else
  fail "scaffold constraints carry their derivation provenance" "no 'DERIVED at build time' note"
fi
if [ -s "$LIST/decl_audits" ]; then
  while IFS= read -r el; do
    [ -z "$el" ] && continue
    if grep -q "scaffold-omits-audit: $el — ." "$WORK/.ai/CONSTRAINTS.yaml"; then
      pass "withheld audit '$el' ships its reason to the stranger"
    else
      fail "withheld audit '$el' ships its reason to the stranger" "declared, but with no reason after the dash"
    fi
  done < "$LIST/decl_audits"
fi
echo ""

# ---- 5. the published crate can still build --------------------------------------------
# The derivation reads .ai/AGENTS.md and .ai/CONSTRAINTS.yaml at BUILD time. Cargo.toml
# excludes .ai/ wholesale; those two are un-excluded by name. If that ever regresses,
# `cargo install vajractl` breaks for every stranger and nothing in this repo would notice.
echo "--- 5. the two derivation sources still ship inside the published crate ---"
PKG="$(cargo package --list --allow-dirty 2>/dev/null)"
if [ -z "$PKG" ]; then
  fail "cargo package --list is readable" "cargo package produced nothing — cannot evaluate"
else
  for src in .ai/AGENTS.md .ai/CONSTRAINTS.yaml; do
    if printf '%s\n' "$PKG" | grep -Fxq "$src"; then
      pass "$src is inside the packaged crate"
    else
      fail "$src is inside the packaged crate" "excluded — a cargo-installed vajra could not build"
    fi
  done
fi
echo ""

# ---- verdict ---------------------------------------------------------------------------
echo "=== scaffold-drift: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -eq 0 ]; then
  echo "GREEN — across the THREE LISTS THIS CHECK COVERS, a stranger is governed by"
  echo "        $(n "$LIST/scaf_rules") of this repo's $(n "$LIST/live_rules") binding rules, $(n "$LIST/scaf_audits") of its $(n "$LIST/live_audits") ground-truth audits and"
  echo "        $(n "$LIST/scaf_axes") of its $(n "$LIST/live_axes") drift axes, every difference declared with a reason."
  echo ""
  echo "        READ THAT SCOPE LITERALLY. The derivation decides what this check compares, so"
  echo "        this GREEN can never go red on anything outside those three lists — and there IS"
  echo "        more outside them. \`src/cli/init.rs\` still hand-types \`communication.forbid\`,"
  echo "        \`load_order\`, \`demo.required_elements\` and others against live twins in"
  echo "        \`.ai/CONSTRAINTS.yaml\`; the scaffolded constitution's load order and session loop"
  echo "        are hand-written against sections the live file labels Mandatory. Named by S129's"
  echo "        pass-2 cold review, refused in-session with a reason, and top of the next pick."
  exit 0
fi
echo "RED — the scaffold and the live .ai/ have drifted. Fix the SOURCE, never the copy:"
echo "      rules + audits are derived in build.rs; withholding one needs a declared reason."
exit 1
