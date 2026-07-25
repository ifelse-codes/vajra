#!/usr/bin/env bash
# verify-session-101.sh — Session 101: README truth-pass + crate-name decision (docs-only)
# Asserts the S101 acceptance criteria hold in the committed docs (grep, robust after merge),
# plus scope (no src/, no Cargo.toml change) and cargo test --lib green.
set -euo pipefail

README="README.md"
DEC="docs/decisions/DECISION-006-crate-name.md"
REVIEW="sessions/session-101-review.md"
PASS=0
FAIL=0

check() {
  local desc="$1" result="$2"
  if [ "$result" = "ok" ]; then echo "  PASS  $desc"; PASS=$((PASS + 1))
  else echo "  FAIL  $desc"; FAIL=$((FAIL + 1)); fi
}
has()    { grep -qiF "$2" "$1" && echo ok || echo fail; }   # case-insensitive fixed
hasF()   { grep -qF  "$2" "$1" && echo ok || echo fail; }   # case-sensitive fixed
hasnotF(){ grep -qF  "$2" "$1" && echo fail || echo ok; }   # absence (case-sensitive)
hasnotI(){ grep -qiF "$2" "$1" && echo fail || echo ok; }   # absence (case-insensitive)
# marker_before: the line immediately preceding the first line matching CMD contains MARK
marker_before() { # file cmd mark
  awk -v cmd="$2" -v mark="$3" 'index($0,cmd) && index(prev,mark){f=1} {prev=$0} END{exit f?0:1}' "$1" \
    && echo ok || echo fail
}

echo "=== verify-session-101: README truth-pass + crate-name decision ==="
echo

# --- AC1: no stale strings survive in README ---
echo "[AC1] stale receipt strings retired from README"
check "no '~8x' receipt-bug claim (x)"          "$(hasnotI "$README" '~8x')"
check "no '~8×' receipt-bug claim (unicode)"    "$(hasnotF "$README" '~8×')"
check "no 'opus-4-6' example model id"          "$(hasnotI "$README" 'opus-4-6')"
check "no stale '\$33.4976' figure"             "$(hasnotF "$README" '33.4976')"
echo

# --- AC2: Install — one working method; each broken method marked NOT YET PUBLISHED ---
echo "[AC2] Install section honesty"
check "working method labelled (build from source)"  "$(has "$README" 'Works today')"
check "the one working command present"              "$(hasF "$README" 'cargo install --path .')"
check "crates.io line carries the marker"            "$(marker_before "$README" 'cargo install vajractl' 'NOT YET PUBLISHED')"
check "Homebrew line carries the marker"             "$(marker_before "$README" 'brew install suman/tap/vajra' 'NOT YET PUBLISHED')"
check "prebuilt-binary line carries the marker"      "$(marker_before "$README" 'releases/latest/download' 'NOT YET PUBLISHED')"
echo

# --- AC3: Direction paragraph + Status table match shipped reality ---
echo "[AC3] Direction + Status table = shipped reality"
check "stale 'next build is the fidelity auditor' phrasing GONE" "$(hasnotI "$README" 'next build is the')"
check "stale 'in build, not shipped' phrasing GONE"              "$(hasnotI "$README" 'in build, not shipped')"
check "8 stations named as shipped"                              "$(has "$README" '8 stations ship today')"
check "vajra check = 11 checks"                                  "$(has "$README" '11 checks')"
check "table lists 'vajra estimate'"                             "$(hasF "$README" '`vajra estimate`')"
check "table lists 'vajra hook'"                                 "$(hasF "$README" '`vajra hook`')"
echo

# --- AC4: DECISION-006 records the live check + chosen name + reason ---
echo "[AC4] DECISION-006 crate-name decision"
check "DECISION-006 file exists"                     "$([ -f "$DEC" ] && echo ok || echo fail)"
check "records the command used (curl + crates.io)"  "$(has "$DEC" 'crates.io/api/v1/crates')"
check "records vajractl -> 404 AVAILABLE"            "$(has "$DEC" '404')"
check "records vajra -> 200 TAKEN"                   "$(has "$DEC" '200')"
check "states chosen crate: vajractl"               "$(has "$DEC" 'vajractl')"
check "states chosen binary: vajra + reason"        "$(has "$DEC" 'not globally namespaced')"
echo

# --- AC5: scope — nothing published/renamed; no src/, no Cargo.toml edit ---
echo "[AC5] scope: docs + one decision only"
BASE=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD origin/main 2>/dev/null || true)
if [ -n "$BASE" ]; then
  SRC_DIFF=$(git diff --name-only "$BASE"..HEAD -- src/ Cargo.toml Cargo.lock 2>/dev/null || true)
  check "branch touches no src/ · Cargo.toml · Cargo.lock" "$([ -z "$SRC_DIFF" ] && echo ok || echo fail)"
else
  check "branch touches no src/ · Cargo.toml (no base to diff)" "ok"
fi
check "DECISION-006 states nothing is published"    "$(has "$DEC" 'Nothing is published')"
echo

# --- cargo test --lib stays green (docs-only — must not regress) ---
echo "[scope] cargo test --lib (docs-only — must stay green)"
if cargo test --lib 2>&1 | grep -q 'test result: ok'; then
  check "cargo test --lib green" "ok"
else
  check "cargo test --lib green" "fail"
fi
echo

TOTAL=$((PASS + FAIL))
echo "=== Result: ${PASS}/${TOTAL} checks passed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
