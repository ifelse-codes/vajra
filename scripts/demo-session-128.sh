#!/usr/bin/env bash
# Demo — Session 128: first contact works.
#
# Sprint-demo contract (CONSTRAINTS.yaml#demo.required_elements): header · cases · summary_table ·
# before_after. Cumulative: the prior sessions' capability that matters here is the SCAFFOLD
# itself (`vajra init`) and the L4 closeout gate it ships — this demo drives both, in the one
# place 125 sessions never looked: a real empty directory.
#
# Every case runs the REAL release binary in a REAL temp directory. Nothing is grepped out of
# source and called a demonstration.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="128"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}== %s ==${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}> %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}OK %s${RESET}\n" "$1"; }
no()     { printf "${RED}xx %s${RESET}\n" "$1"; }
dim()    { printf "${DIM}%s${RESET}\n" "$1"; }

VAJRA="$ROOT/target/release/vajra"
[ -x "$VAJRA" ] || cargo build -q --release || { echo "build failed"; exit 1; }

PASS=0; FAIL=0; EXEC_N=0; STRUCT_N=0; BEHAV_N=0; ROWS=()
score() {
  case "$2" in
    exec)   EXEC_N=$((EXEC_N+1)) ;;
    struct) STRUCT_N=$((STRUCT_N+1)) ;;
    behav)  BEHAV_N=$((BEHAV_N+1)) ;;
    *) echo "demo bug: unknown class '$2' for $3"; exit 2 ;;
  esac
  if [ "$1" -eq 0 ]; then ok "$3"; PASS=$((PASS+1)); ROWS+=("$(printf '%-62s %-7s %s' "$3" "$2" PASS)")
  else no "$3"; FAIL=$((FAIL+1)); ROWS+=("$(printf '%-62s %-7s %s' "$3" "$2" FAIL)"); fi
}

# ── The subject: a stranger's empty directory. Never this repo. ──────────────────────────────────
TMP="$(mktemp -d "${TMPDIR:-/tmp}/vajra-demo-128-XXXXXX")"; trap 'rm -rf "$TMP"' EXIT
case "$TMP" in "$ROOT"*) echo "demo bug: temp dir inside the repo"; exit 2;; esac
( cd "$TMP" && git init -q . ) || exit 1
( cd "$TMP" && "$VAJRA" init </dev/null ) >/dev/null 2>&1 || { echo "vajra init failed"; exit 1; }

# --- demo:header --------------------------------------------------------------------------------
header "Session ${SESSION} Demo — first contact works  [demo:header]"
dim "  57 days public · 0 stars · 0 forks · 0 issues · 19 downloads."
dim "  The last change a new user could reach was S108, 19 sessions ago."
dim "  Subject: $TMP — a real empty directory, scaffolded by the real \`vajra init\`."

# --- demo:before_after --------------------------------------------------------------------------
header "Before → after  [demo:before_after]"
printf '%-34s %-26s %s\n' "A STRANGER TYPES" "BEFORE S128" "AFTER S128"
printf '%-34s %-26s %s\n' "---------------------------------" "-------------------------" "-------------------------"
printf '%-34s %-26s %s\n' "vajra --version"          "help banner, exit 0"      "vajra $("$VAJRA" --version | awk '{print $2}'), exit 0"
printf '%-34s %-26s %s\n' "vajra chek && deploy"     "DEPLOY RUNS"              "blocked, exit 2"
printf '%-34s %-26s %s\n' "vajra check (fresh init)" "9/11, 2 FAILED"           "$( (cd "$TMP" && "$VAJRA" check 2>&1) | grep -o 'Score: [0-9]*/[0-9]* — [0-9]* FAILED' | sed 's/Score: //')"
printf '%-34s %-26s %s\n' "bash verify-closeout.sh"  "CRASH: unbound variable"  "runs, prints its summary"

# --- demo:cases ---------------------------------------------------------------------------------
header "Cases — the real binary, in a real empty directory  [demo:cases]"

label "case 1 — \`vajra --version\` exists, and reads the version from the crate"
EXPECTED="$(sed -n '/^\[package\]/,/^\[/p' Cargo.toml | sed -n 's/^version = "\(.*\)"/\1/p' | head -1)"
OUT="$( cd "$TMP" && "$VAJRA" --version 2>&1 )"; RC=$?
dim "    \$ vajra --version   ->  $OUT   (exit $RC)"
dim "    Cargo.toml [package] version = $EXPECTED — printed, not typed into a string"
[ "$RC" -eq 0 ] && [ "$OUT" = "vajra $EXPECTED" ]; score $? exec "case 1: --version prints the crate version, exit 0"

label "case 2 — the front door fails CLOSED. This is the one with teeth."
CHAIN="$( cd "$TMP" && "$VAJRA" chek 2>/dev/null && echo "DEPLOY RAN" )"
dim "    \$ vajra chek && echo 'DEPLOY RAN'"
dim "    -> $(printf '%s' "$CHAIN" | tail -1 | sed 's/^$/(nothing — the chain stopped)/')"
! printf '%s' "$CHAIN" | grep -q "DEPLOY RAN"; score $? exec "case 2: \`vajra <typo> && deploy\` no longer runs deploy"

ERRTXT="$( cd "$TMP" && "$VAJRA" chek 2>&1 >/dev/null )"; ERRRC=$?
dim "    stderr: $(printf '%s' "$ERRTXT" | head -1)   (exit $ERRRC)"
[ "$ERRRC" -ne 0 ] && printf '%s' "$ERRTXT" | grep -qF "chek"; score $? exec "case 3: exits non-zero and NAMES the unrecognised word"

label "case 4 — asking for help is still not an error"
HELP_OK=0
for INV in "" "help" "--help" "-h"; do
  # shellcheck disable=SC2086
  ( cd "$TMP" && "$VAJRA" $INV ) >/dev/null 2>&1 || HELP_OK=1
done
dim "    vajra · vajra help · vajra --help · vajra -h  ->  all exit 0"
[ "$HELP_OK" -eq 0 ]; score $? exec "case 4: help and bare \`vajra\` still exit 0"

label "case 5 — the L4 closeout gate RUNS on a fresh repo, on the macOS default shell"
dim "    shell: /bin/bash $(/bin/bash --version | head -1 | sed 's/.*version //;s/ .*//')"
CO="$( cd "$TMP" && /bin/bash scripts/verify-closeout.sh 2>&1 )"
dim "    $(printf '%s' "$CO" | tail -1)"
! printf '%s' "$CO" | grep -q "unbound variable"; score $? exec "case 5: no 'unbound variable' abort"
printf '%s' "$CO" | grep -q "Closeout Verify Summary"; score $? exec "case 6: the gate reaches its summary (RED is a verdict; a crash is not)"

label "case 7 — \`vajra check\` is honest on arrival"
CHK="$( cd "$TMP" && "$VAJRA" check 2>&1 )"
printf '%s\n' "$CHK" | grep -E "varta: matches render|^Score:" | sed 's/^/    /'
! printf '%s' "$CHK" | grep -q "vajra.varta missing"; score $? exec "case 7: no failure for a file \`init\` never creates"
UNEXPECTED="$(printf '%s\n' "$CHK" | grep -E '[[:space:]]FAIL[[:space:]]' | grep -v "branch: not main" || true)"
[ -z "$UNEXPECTED" ]; score $? exec "case 8: the only remaining FAIL is one a new user can act on"

label "case 9 — the drift guard kept its teeth (this is not a weakening)"
( cd "$TMP" && "$VAJRA" check --render ) >/dev/null 2>&1
printf 'hand-edited, not a render\n' >> "$TMP/vajra.varta"
STALE="$( cd "$TMP" && "$VAJRA" check 2>&1 )"
dim "    $(printf '%s\n' "$STALE" | grep 'varta: matches render')"
printf '%s' "$STALE" | grep -q "stale"; score $? exec "case 9: a hand-edited render still FAILS"
( cd "$TMP" && git add vajra.varta && rm vajra.varta )
TRACKED="$( cd "$TMP" && "$VAJRA" check 2>&1 )"
dim "    $(printf '%s\n' "$TRACKED" | grep 'varta: matches render')"
printf '%s' "$TRACKED" | grep -q "tracked in git but missing"; score $? exec "case 10: a committed render that vanished still FAILS"

label "case 11 — the audit that stops this class recurring"
grep -q "stranger_check" .ai/CONSTRAINTS.yaml && grep -q "stranger_questions" .ai/CONSTRAINTS.yaml
score $? struct "case 11: stranger_check is a REQUIRED ground-truth audit"

label "case 12 — nothing else moved"
ST="$( "$VAJRA" next --stations 127 2>&1 )"
dim "    $(printf '%s\n' "$ST" | grep 'stations passed')"
printf '%s' "$ST" | grep -q "8 of 8 stations passed (derived from each gate's evidence"
score $? exec "case 12: \`K of 8\` unmoved in derivation and shape"
VERSION_IS_A_FLAG="$( "$VAJRA" version 2>&1 >/dev/null )"
dim "    \$ vajra version  ->  $(printf '%s' "$VERSION_IS_A_FLAG" | head -1)"
printf '%s' "$VERSION_IS_A_FLAG" | grep -q "unrecognised command"
score $? exec "case 13: still 7 commands — \`--version\` is a FLAG, not an 8th"

# --- demo:summary_table -------------------------------------------------------------------------
header "Summary  [demo:summary_table]"
printf '%-62s %-7s %s\n' "CASE" "CLASS" "RESULT"
printf '%-62s %-7s %s\n' "--------------------------------------------------------------" "-------" "------"
for r in ${ROWS[@]+"${ROWS[@]}"}; do echo "$r"; done
echo ""
echo "  execute-based: $EXEC_N · structural: $STRUCT_N · behavioral source grep: $BEHAV_N"
echo "  (a class label here is self-assigned, exactly as in the verify suite — S122)"
echo ""
echo "WHAT THIS DEMO DOES NOT SHOW, in order:"
echo "  1. It does not show anyone USING Vajra. 0 stars and 19 downloads are unchanged by this"
echo "     session; a working front door is a precondition for adoption, never evidence of it."
echo "  2. The scaffolded constitution is STILL a hand-maintained fork — 66 lines against this"
echo "     repo's 183. S128 deliberately did not touch it. A stranger still gets a weaker"
echo "     rulebook than the one this repo runs on."
echo "  3. \`vajra init\` still blocks on stdin without EOF; every case above passes \`</dev/null\`."
echo "  4. Case 11 is a structural grep — it proves the audit is REGISTERED, not that any future"
echo "     ground-truth session will actually run it."
echo "  A green demo is not a passing delivery — the fidelity verdict lives in"
echo "  sessions/session-128-review.md."
echo ""
if [ "$FAIL" -eq 0 ]; then
  ok "DEMO GREEN ($PASS pass, $FAIL fail)"
  exit 0
else
  no "DEMO RED ($PASS pass, $FAIL fail)"
  exit 1
fi
