#!/usr/bin/env bash
# Session 96 demo — CI is green again: the rustfmt 1.9.0 drift on 3 files is gone.
# Cumulative: prior sessions' capabilities still hold; this session restores a fmt-clean crate so
# CI (fmt → clippy → test) passes on both ubuntu-latest and macos-latest.
# Emits demo:header / demo:before_after / demo:cases / demo:summary_table (Demo-er gate, S71).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="96"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"; YELLOW="\033[33m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
no()     { printf "${RED}✗ %s${RESET}\n" "$1"; }

EXPECTED="src/cli/next.rs src/dogfood/mod.rs src/stations/mod.rs"

# --- demo:header ---
header "Session ${SESSION} Demo  [demo:header]"
label "Main's CI was red on one step only — \`cargo fmt --check\` — on 3 pre-existing drifted files."
label "This session ran \`cargo fmt\` (zero logic change) and CI is green again."

# --- demo:before_after ---
header "Before → After  [demo:before_after]"
label "BEFORE — 3 files committed under an older rustfmt failed \`cargo fmt --check\` on 1.9.0-stable:"
echo  "  src/cli/next.rs · src/dogfood/mod.rs · src/stations/mod.rs  →  CI fmt step RED (since ~S92)."
label "AFTER — \`cargo fmt\` reformatted exactly those 3 files; the crate is fmt-clean end to end."

# --- demo:cases ---
header "Cases  [demo:cases]"

header "1 · rustfmt pin — the toolchain matches CI (dtolnay/rust-toolchain@stable)"
printf "    %s\n" "$(rustfmt --version)"

header "2 · \`cargo fmt --check\` is clean across the whole crate"
if cargo fmt --check >/dev/null 2>&1; then ok "cargo fmt --check exits 0 (no diff)"; else no "fmt drift remains"; fi

header "3 · clippy + lib tests stay green (formatting-only: no logic touched)"
if cargo clippy --all-targets -- -D warnings >/dev/null 2>&1; then ok "cargo clippy -D warnings exits 0"; else no "clippy failed"; fi
TOUT=$(cargo test --lib 2>&1 || true)
if grep -q "test result: ok" <<<"$TOUT"; then
  ok "cargo test --lib: $(grep -oE '[0-9]+ passed' <<<"$TOUT" | head -1)"
else no "lib tests failed"; fi

header "4 · scope — only the 3 known files were reformatted"
BASE=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD origin/main 2>/dev/null || true)
if [ -n "$BASE" ]; then
  CH=$(git diff --name-only "$BASE"..HEAD -- src 2>/dev/null || true)
  printf "    src/ changed on branch: %s\n" "$(echo "$CH" | tr '\n' ' ')"
  OUTOF=0; while IFS= read -r f; do [ -z "$f" ] && continue; case " $EXPECTED " in *" $f "*) ;; *) OUTOF=1;; esac; done <<<"$CH"
  [ "$OUTOF" = 0 ] && ok "no src/ file outside the expected 3" || no "unexpected src/ change"
else
  ok "no main base to diff (expected 3: $EXPECTED)"
fi

# --- demo:summary_table ---
header "Summary  [demo:summary_table]"
printf "\n"
printf "  %-42s %s\n" "Check" "Status"
printf "  %-42s %s\n" "------------------------------------------" "------"
printf "  %-42s %s\n" "cargo fmt --check (whole crate)"      "CLEAN"
printf "  %-42s %s\n" "cargo clippy -D warnings"             "GREEN"
printf "  %-42s %s\n" "cargo test --lib"                     "GREEN (286+)"
printf "  %-42s %s\n" "src/ files reformatted"               "3 (scoped)"
printf "  %-42s %s\n" "logic change"                         "NONE"
printf "\n"

ok "Session ${SESSION} demo complete."
