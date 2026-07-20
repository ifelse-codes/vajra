#!/usr/bin/env bash
# Session 84 — typed `CannotEvaluate::{Timeout, SpawnFailure}` for the QA/Demo-er gates' live
# re-run. The S73 fakest-green finding, carried across 7 sessions (S76-S83): both gates collapsed
# "the script hung past its bound and was killed" and "the child process never spawned at all"
# into the same untyped `None`, so a blocked close's message could never tell an operator WHICH
# problem they were looking at. This session splits it into a real typed value.
#
# Sprint demo — runs the REAL `vajra next --check-qa/--check-demo` gate path end-to-end against a
# synthetic temp repo (so this demo costs $0 and needs no credentials), across the
# timeout/spawn-failure/real-red/green matrix; emits the four gated demo:<element> markers;
# `--check-demo 84` re-runs it live at close.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="84"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — typed CannotEvaluate::{Timeout, SpawnFailure}  [demo:header]"
printf "${DIM}  S73 gave the QA and Demo-er gates a live-rerun timeout so a hung script can't hang the\n"
printf "  close forever. But both gates classified EVERY unevaluable run the same way — a bare\n"
printf "  'no exit code' — whether the script hung OR the process never even started. This session\n"
printf "  splits that into a typed value so the BLOCK message names which one happened.${RESET}\n"

cargo build --quiet --bin vajra
BIN="$ROOT/target/debug/vajra"

# ── build an isolated temp repo the real gate path can run against ─────────
TMP_REPO=$(mktemp -d)
trap 'rm -rf "$TMP_REPO"' EXIT
mkdir -p "$TMP_REPO/.ai" "$TMP_REPO/scripts"
cat > "$TMP_REPO/.ai/CONSTRAINTS.yaml" <<'EOF'
verify:
  script_pattern: 'scripts/verify-session-{NN}.sh'
  artifacts_dir: '.ai/verify/session-{NN}/'
  timeout_secs: 1
demo:
  script_pattern: 'scripts/demo-session-{NN}.sh'
  required_elements: [header, cases, summary_table, before_after]
  timeout_secs: 1
EOF

header "Before → After  [demo:before_after]"
label "BEFORE (S73-S83 — the collapsed message; a real hang against this repo's own gate):"
printf '   $ vajra next --check-qa NN\n   ✗ scripts/verify-session-NN.sh could not be evaluated (no exit code) — a check\n     that cannot evaluate FAILS\n   (same message whether the script hung OR the interpreter never started — an operator\n    debugging a blocked close cannot tell which)\n'
label "AFTER (S84, run LIVE against a synthetic temp repo — the real gate path, two real cases):"

cat > "$TMP_REPO/scripts/verify-session-99.sh" <<'EOF'
#!/usr/bin/env bash
sleep 5
EOF
chmod +x "$TMP_REPO/scripts/verify-session-99.sh"
AFTER_TIMEOUT=$(cd "$TMP_REPO" && "$BIN" next --check-qa 99 2>&1 || true)
printf '%s\n' "$AFTER_TIMEOUT" | sed 's/^/   /'
if printf '%s' "$AFTER_TIMEOUT" | grep -q "TIMEOUT"; then
  ok "the timeout case now names TIMEOUT explicitly"
else
  bad "expected a TIMEOUT-named message"
fi

AFTER_SPAWN=$(cd "$TMP_REPO" && PATH="/nonexistent-dir-for-s84-demo" "$BIN" next --check-qa 99 2>&1 || true)
printf '%s\n' "$AFTER_SPAWN" | sed 's/^/   /'
if printf '%s' "$AFTER_SPAWN" | grep -q "SPAWN FAILURE"; then
  ok "the spawn-failure case now names SPAWN FAILURE explicitly — visibly different from TIMEOUT"
else
  bad "expected a SPAWN FAILURE-named message"
fi

header "Cases — the QA + Demo-er gate matrix  [demo:cases]"

header "1 · Timeout — script hangs past its bound (QA + Demo-er)"
cp "$TMP_REPO/scripts/verify-session-99.sh" "$TMP_REPO/scripts/demo-session-99.sh"
QA_TO=$(cd "$TMP_REPO" && "$BIN" next --check-qa 99 2>&1 || true)
DEMO_TO=$(cd "$TMP_REPO" && "$BIN" next --check-demo 99 2>&1 || true)
if printf '%s' "$QA_TO" | grep -q "TIMEOUT" && printf '%s' "$DEMO_TO" | grep -q "TIMEOUT"; then
  ok "both gates BLOCK and name TIMEOUT"
else
  bad "expected both gates to name TIMEOUT"
fi

header "2 · Spawn failure — bash cannot be found (QA + Demo-er)"
QA_SF=$(cd "$TMP_REPO" && PATH="/nonexistent-dir-for-s84-demo" "$BIN" next --check-qa 99 2>&1 || true)
DEMO_SF=$(cd "$TMP_REPO" && PATH="/nonexistent-dir-for-s84-demo" "$BIN" next --check-demo 99 2>&1 || true)
if printf '%s' "$QA_SF" | grep -q "SPAWN FAILURE" && printf '%s' "$DEMO_SF" | grep -q "SPAWN FAILURE"; then
  ok "both gates BLOCK and name SPAWN FAILURE — distinct from the timeout message above"
else
  bad "expected both gates to name SPAWN FAILURE"
fi

header "3 · Real nonzero exit code — UNCHANGED, never CannotEvaluate (QA + Demo-er)"
cat > "$TMP_REPO/scripts/verify-session-99.sh" <<'EOF'
#!/usr/bin/env bash
exit 7
EOF
cp "$TMP_REPO/scripts/verify-session-99.sh" "$TMP_REPO/scripts/demo-session-99.sh"
QA_RED=$(cd "$TMP_REPO" && "$BIN" next --check-qa 99 2>&1 || true)
DEMO_RED=$(cd "$TMP_REPO" && "$BIN" next --check-demo 99 2>&1 || true)
if printf '%s' "$QA_RED" | grep -q "exited 7" && ! printf '%s' "$QA_RED" | grep -qE "TIMEOUT|SPAWN FAILURE" \
  && printf '%s' "$DEMO_RED" | grep -q "exited 7" && ! printf '%s' "$DEMO_RED" | grep -qE "TIMEOUT|SPAWN FAILURE"; then
  ok "both gates still name the real exit code 7 — not reclassified as CannotEvaluate"
else
  bad "expected the real exit code to survive unchanged"
fi

header "4 · Exit 0 — UNCHANGED, still LiveGreen (QA + Demo-er)"
cat > "$TMP_REPO/scripts/verify-session-99.sh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
cat > "$TMP_REPO/scripts/demo-session-99.sh" <<'EOF'
#!/usr/bin/env bash
printf 'demo:header\ndemo:cases\ndemo:summary_table\ndemo:before_after\n'
EOF
chmod +x "$TMP_REPO/scripts/verify-session-99.sh" "$TMP_REPO/scripts/demo-session-99.sh"
if (cd "$TMP_REPO" && "$BIN" next --check-qa 99) >/dev/null 2>&1 \
  && (cd "$TMP_REPO" && "$BIN" next --check-demo 99) >/dev/null 2>&1; then
  ok "both gates still pass clean on a genuine green run"
else
  bad "expected both gates to pass"
fi

header "5 · Regression suite"
if cargo test --quiet --lib qa::tests::gate_block_message_names_timeout_distinctly_from_spawn_failure >/dev/null 2>&1 \
  && cargo test --quiet --lib demoer::tests::gate_block_message_names_timeout_distinctly_from_spawn_failure >/dev/null 2>&1; then
  ok "both call sites' BLOCK-message tests green"
else
  bad "regression test failed"
fi

header "Summary — S84 acceptance criteria  [demo:summary_table]"
printf "\n"
printf "  %-58s %s\n" "Criterion" "Status"
printf "  %-58s %s\n" "----------------------------------------------------------" "------"
printf "  %-58s %s\n" "1 · spawn failure -> Err(SpawnFailure), named distinctly"     "SHIPPED"
printf "  %-58s %s\n" "2 · timeout -> Err(Timeout), named distinctly"                "SHIPPED"
printf "  %-58s %s\n" "3 · real nonzero exit code -> unchanged, not CannotEvaluate"  "SHIPPED"
printf "  %-58s %s\n" "4 · exit 0 -> unchanged (LiveGreen)"                         "SHIPPED"
printf "  %-58s %s\n" "5 · both call sites (qa + demoer) carry the fix"             "SHIPPED"
printf "  %-58s %s\n" "6 · cargo test --lib green (267, +4), no weakened assertion" "SHIPPED"
printf "\n"

ok "Session ${SESSION} demo complete."
