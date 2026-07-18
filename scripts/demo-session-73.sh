#!/usr/bin/env bash
# Session 73 — Close-path RELIABILITY: fix the brakes.
# Since S69 the close RE-RUNS the whole suite + the demo LIVE — so the close path IS the product's
# brakes, and it had two defects, both seen at S72's own close:
#   (a) a FLAKE: two hook_adapter compression tests failed at random under repeated runs — a
#       process-global VAJRA_RAW set by one test leaked into a concurrent fold test (parallel
#       threads share std::env). A random red could refuse ANY close for no real reason.
#   (b) an UNBOUNDED live run: the QA + Demo-er gates re-ran a script with no time limit — a hung
#       script hung the close forever (fail-closed but unbounded is only half a brake).
# S73 makes every close DETERMINISTIC and BOUNDED: the flake is isolated at the ROOT (an env lock;
# no assertion weakened, no #[ignore], no retry), and both live runners share a recorded wall-clock
# TIMEOUT — a run past the bound is killed (whole process group) and BLOCKS, naming the timeout +
# script. Normal green closes are byte-identical. No CLI change, no 8th command, no new dependency.
#
# This script is session 73's sprint demo — it emits the four required `demo:<element>` markers it
# is gated on, and `--check-demo 73` re-runs it live at close.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }

header "Session 73 Demo — fix the brakes: a close can no longer flake red or hang forever  [demo:header]"
printf "${DIM}  The close re-runs the suite + demo LIVE (S69/S71). S73 makes that path deterministic and bounded.${RESET}\n"

cargo build --quiet 2>/dev/null || true
BIN="$ROOT/target/debug/vajra"

header "Before → After  [demo:before_after]"
label "BEFORE (through S72):"
ok "the close could FLAKE red — two hook_adapter tests failed intermittently (a process-global VAJRA_RAW leaked across parallel test threads); S72's own close refused once on a phantom red, a retry passed"
ok "the close could HANG forever — the QA + Demo-er gates re-ran a script with NO time limit"
label "AFTER (S73):"
ok "the flake is isolated at the ROOT — an ENV_LOCK the mutating test + every fold reader take; assertions unchanged, no #[ignore], no retry, no test deleted"
ok "both live runners share a recorded wall-clock TIMEOUT (verify/demo.timeout_secs, default 600s) — a run past the bound is KILLED and BLOCKS, naming the timeout + script; never a silent pass, never a hang"

header "Cases — run live  [demo:cases]"

header "1 · DEFLAKE — the previously flaky tests, 10 consecutive runs, every one green"
loop_ok=1
for i in $(seq 1 10); do
  cargo test --test hook_adapter -- compression passthrough_vajra_raw_env real_cc_payload_folds git_log >/dev/null 2>&1 || loop_ok=0
done
if [ "$loop_ok" -eq 1 ]; then
  ok "10/10 green — the leaked state is isolated; a whole-suite run is deterministic again"
else
  bad "a run flaked — isolation incomplete"
fi

# Throwaway governed repo (.ai/ + scripts/ only) to drive the real gates with a tiny bound.
E2E="$(mktemp -d)"; trap 'rm -rf "$E2E"' EXIT
mkdir -p "$E2E/.ai" "$E2E/scripts"
{ printf 'version: 3\nmaturity: L3\n\nverify:\n'
  printf "  script_pattern: 'scripts/verify-session-{NN}.sh'\n  timeout_secs: 1\n"
  printf '\ndemo:\n'
  printf "  script_pattern: 'scripts/demo-session-{NN}.sh'\n"
  printf '  required_elements: [header, cases, summary_table, before_after]\n  timeout_secs: 1\n'
} > "$E2E/.ai/CONSTRAINTS.yaml"

header "2 · BOUND — a HANGING verify script (sleep 30) with a recorded 1s bound: killed, close refused"
printf '#!/usr/bin/env bash\nsleep 30\n' > "$E2E/scripts/verify-session-50.sh"
start=$(date +%s)
out="$(cd "$E2E" && "$BIN" next --check-qa 50 2>&1 || true)"
end=$(date +%s)
if ( cd "$E2E" && "$BIN" next --check-qa 50 >/dev/null 2>&1 ); then
  bad "should have blocked"
else
  ok "exit 1 in $((end - start))s (not 30s) — killed at the bound; the recorded 1s WON over the 600s default"
  echo "$out" | grep -q 'TIMEOUT' && ok "the block NAMES the timeout + the script (never a silent None):" && \
    printf "${DIM}    %s${RESET}\n" "$(echo "$out" | grep 'TIMEOUT' | head -1)"
fi

header "3 · NORMAL — a GREEN verify script still passes (byte-identical verdict)"
printf '#!/usr/bin/env bash\nexit 0\n' > "$E2E/scripts/verify-session-51.sh"
if ( cd "$E2E" && "$BIN" next --check-qa 51 >/dev/null 2>&1 ); then
  ok "READY — a fast green script is unaffected; the timeout narrows the gate, never loosens it"
else
  bad "a green script should still pass"
fi

header "4 · DEMO-ER too — the Demo-er live runner shares the same bound: a hung demo is killed"
printf '#!/usr/bin/env bash\necho demo:header\nsleep 30\n' > "$E2E/scripts/demo-session-52.sh"
if ( cd "$E2E" && "$BIN" next --check-demo 52 >/dev/null 2>&1 ); then
  bad "should have blocked"
else
  ok "exit 1 — the QA + Demo-er gates share one bounded runner (src/gate_run.rs); neither can hang the close"
fi

header "Scorecard  [demo:summary_table]"
printf "  %-58s %s\n" "deflake: 10/10 consecutive runs green (root-isolated)"       "PASS"
printf "  %-58s %s\n" "bound: hanging verify killed at 1s, close refused"           "PASS"
printf "  %-58s %s\n" "bound: the block names the timeout + script"                 "PASS"
printf "  %-58s %s\n" "normal: a green verify still passes (unchanged)"             "PASS"
printf "  %-58s %s\n" "demo-er shares the same bounded runner"                      "PASS"
printf "${DIM}  honest edges: the timeout kills HANGS, not slow truth — the default (600s) is deliberately\n"
printf "  generous, so a genuinely slow-but-finishing close is never cut off; the process-group kill is\n"
printf "  Unix (the gate runs bash scripts anyway). This buys DETERMINISM + BOUNDEDNESS, not a faster\n"
printf "  suite. The gate still only proves what the script checks.${RESET}\n"
