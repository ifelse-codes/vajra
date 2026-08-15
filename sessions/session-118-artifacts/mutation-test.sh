#!/usr/bin/env bash
# S118 — reproducible falsifiability proof for chitra's new catalog check.
#
# The claim under test: `check-catalog-examples.ts` is a REAL check, not another grep —
# reintroducing the `applyOverrides` brace defect must make it FAIL, on exactly the
# charts that were broken when the governed run delivered the page.
#
# This script captures both runs to disk so the claim is not operator narration.
# Restores the file unconditionally (trap), and fails loudly if restoration drifts.
set -uo pipefail

CH="/Users/suman/playground/chitra/artifacts/chitra-docs"
SRC="$CH/src/components/CatalogPage.tsx"
OUT="${1:-/Users/suman/playground/vajra/sessions/session-118-artifacts/mutation-proof.txt}"
BAK="$(mktemp)"

cp "$SRC" "$BAK"
restore() { cp "$BAK" "$SRC"; rm -f "$BAK"; }
trap restore EXIT

{
  echo "=== S118 mutation test · $(date -u +%FT%TZ) ==="
  echo "file under test : $SRC"
  echo "sha256 (fixed)  : $(shasum -a 256 "$SRC" | cut -d' ' -f1)"
  echo
  echo "--- RUN 1: the shipped fix (expect all checks to pass, exit 0) ---"
} > "$OUT"

( cd "$CH" && pnpm exec tsx scripts/check-catalog-examples.ts ) >> "$OUT" 2>&1
echo "exit_code=$?" >> "$OUT"

# Reintroduce the exact defect the governed run shipped: re-emit the captured closing
# brace BEFORE the injected key, closing the options object early.
python3 - "$SRC" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
old = '      : `${body.replace(/\\s*,?\\s*$/, "")},\\n  ${key}: "${value}"\\n`;'
new = '      : `${body}}, ${key}: "${value}"`;'
assert old in s, "mutation target not found — the fix was refactored; update this script"
open(p, "w").write(s.replace(old, new))
PY

{
  echo
  echo "--- MUTATION APPLIED: applyOverrides closes the options object early ---"
  echo "sha256 (mutated): $(shasum -a 256 "$SRC" | cut -d' ' -f1)"
  echo
  echo "--- RUN 2: with the original defect reintroduced (expect FAILures, exit 1) ---"
} >> "$OUT"

( cd "$CH" && pnpm exec tsx scripts/check-catalog-examples.ts ) >> "$OUT" 2>&1
echo "exit_code=$?" >> "$OUT"

restore
trap - EXIT
{
  echo
  echo "--- RESTORED ---"
  echo "sha256 (restored): $(shasum -a 256 "$SRC" | cut -d' ' -f1)"
  echo "git status       : $(git -C /Users/suman/playground/chitra status --porcelain -- artifacts/chitra-docs/src/components/CatalogPage.tsx | wc -l | tr -d ' ') modified file(s) — 0 means the fix is intact"
} >> "$OUT"

cat "$OUT"
