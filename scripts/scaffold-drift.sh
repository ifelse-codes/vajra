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
# Three questions, both directions, for rules and for audits:
#   1. Is every LIVE element either carried into the scaffold, or DECLARED out with a reason?
#   2. Did the scaffold INVENT an element this repo does not have?
#   3. Is every DECLARATION still true — the element still live, and still actually absent?
#      (S128's fakest green was a hand-typed list that measured the boundary its own author
#      drew. A declaration that can go stale unnoticed is the same bug.)
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
rule_names() {  # $1 = an AGENTS.md
  awk '/^## Hard Rules/{f=1;next} f&&/^## /{exit} f&&/^\|/{print}' "$1" \
    | grep -v '^| *Rule *|' | grep -v '^|[ -]*---' \
    | sed 's/^| *//; s/ *|.*$//'
}
audit_names() { # $1 = a CONSTRAINTS.yaml
  grep -m1 '^ *required_audits:' "$1" \
    | sed 's/.*\[//; s/\].*//' | tr ',' '\n' | sed 's/^ *//; s/ *$//' | grep -v '^$'
}
declared() {    # $1 = file, $2 = marker word (scaffold-omits-rule | scaffold-omits-audit)
  grep "$2:" "$1" 2>/dev/null | sed "s/.*$2: *//; s/ *—.*$//" | sed 's/ *$//' | grep -v '^$'
}

rule_names   "$ROOT/.ai/AGENTS.md"          > "$LIST/live_rules"
rule_names   "$WORK/.ai/AGENTS.md"          > "$LIST/scaf_rules"
audit_names  "$ROOT/.ai/CONSTRAINTS.yaml"   > "$LIST/live_audits"
audit_names  "$WORK/.ai/CONSTRAINTS.yaml"   > "$LIST/scaf_audits"
declared "$WORK/.ai/AGENTS.md"        scaffold-omits-rule  > "$LIST/decl_rules"
declared "$WORK/.ai/CONSTRAINTS.yaml" scaffold-omits-audit > "$LIST/decl_audits"

# S127/S128: a probe that silently no-ops reports false comfort. If either side extracted
# nothing, this script cannot evaluate — and a check that cannot evaluate FAILS (S69).
for f in live_rules scaf_rules live_audits scaf_audits; do
  if [ ! -s "$LIST/$f" ]; then
    echo "BLOCK: extracted ZERO elements for '$f'. The parser and the file disagree —"
    echo "       a green verdict here would be meaningless. Fix the extractor, not the list."
    exit 1
  fi
done

n() { wc -l < "$1" | tr -d ' '; }
echo "--- what is being compared ---"
echo "  live rules   : $(n "$LIST/live_rules")   scaffold rules   : $(n "$LIST/scaf_rules")   declared omissions: $(n "$LIST/decl_rules")"
echo "  live audits  : $(n "$LIST/live_audits")   scaffold audits  : $(n "$LIST/scaf_audits")   declared omissions: $(n "$LIST/decl_audits")"
echo ""
echo "  live rules, by name:"
sed 's/^/    · /' "$LIST/live_rules"
echo "  live audits, by name:"
sed 's/^/    · /' "$LIST/live_audits"
echo ""

has() { grep -Fxq "$1" "$2"; }

# ---- 1. every LIVE element is carried, or DECLARED out --------------------------------
echo "--- 1. every live element reaches a stranger, or is declared out with a reason ---"
for kind in rules audits; do
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
for kind in rules audits; do
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
for kind in rules audits; do
  if [ ! -s "$LIST/decl_$kind" ]; then
    pass "no stale $kind declaration (none declared)"
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
  echo "GREEN — a stranger is governed by $(n "$LIST/scaf_rules") of this repo's $(n "$LIST/live_rules") binding rules"
  echo "        and $(n "$LIST/scaf_audits") of its $(n "$LIST/live_audits") ground-truth audits, every difference declared with a reason."
  exit 0
fi
echo "RED — the scaffold and the live .ai/ have drifted. Fix the SOURCE, never the copy:"
echo "      rules + audits are derived in build.rs; withholding one needs a declared reason."
exit 1
