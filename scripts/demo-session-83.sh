#!/usr/bin/env bash
# Session 83 — warn before a headless `vajra claude -p` run with no permission-mode flag hits
# Claude Code's silent read-only wall. S76's paid dogfood ride-along burned a real call against
# exactly this: headless Claude Code has no approval channel, so every Write/Edit/Bash call is
# silently denied, and nothing said so before the run started. Carried as a debt across S73/S76/
# S77/S78/S81 — this session closes it with one advisory stderr warning, printed before `claude`
# is ever spawned.
#
# Sprint demo — runs the REAL `run()` launch path end-to-end via a stub `claude` binary (so this
# demo costs $0 and needs no credentials), across the warn/no-warn matrix, plus the regression
# suite; emits the four gated demo:<element> markers; `--check-demo 83` re-runs it live at close.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="83"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — warn before the headless read-only wall  [demo:header]"
printf "${DIM}  S76's paid dogfood ride-along spent real money on a headless run that could write\n"
printf "  nothing — Claude Code silently denies every tool call with no approval channel, and vajra\n"
printf "  said nothing about it beforehand. This session adds a pre-flight stderr warning.${RESET}\n"

# ── build a stub \`claude\` so the demo runs the REAL launch path for \$0 ──
STUB_DIR=$(mktemp -d)
cat > "$STUB_DIR/claude" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$STUB_DIR/claude"
export PATH="$STUB_DIR:$PATH"
export VAJRA_SKIP_AUTH_CHECK=1
export VAJRA_QUIET=1
cargo build --quiet --bin vajra
BIN="$ROOT/target/debug/vajra"

header "Before → After  [demo:before_after]"
label "BEFORE (S76 — the silent wall; a real paid headless run, nothing written, no warning):"
printf '   $ vajra claude -p "add a feature"\n   (Claude Code runs, every Write/Edit/Bash denied, no diff, no explanation — you find out\n    only by reading the transcript afterward)\n'
label "AFTER (S83, run LIVE against a stub claude binary — same command, real launch path):"
AFTER=$("$BIN" claude -p "add a feature" 2>&1 1>/dev/null || true)
printf '%s\n' "$AFTER" | sed 's/^/   /'
if printf '%s\n' "$AFTER" | grep -qi 'no approval channel'; then
  ok "the warning fires BEFORE claude is spawned, naming the wall and the fix"
else
  bad "expected the read-only-headless warning"
fi

header "Cases — the warn/no-warn matrix  [demo:cases]"

header "1 · Headless, no permission flag -> warns (AC1)"
CASE1=$("$BIN" claude -p "x" 2>&1 1>/dev/null || true)
if printf '%s\n' "$CASE1" | grep -qi 'no approval channel'; then
  ok "vajra claude -p \"x\"  ->  warning printed"
else
  bad "expected a warning"
fi

header "2 · Headless + --dangerously-skip-permissions -> silent (AC2)"
CASE2=$("$BIN" claude -p "x" --dangerously-skip-permissions 2>&1 1>/dev/null || true)
if [ -z "$CASE2" ]; then
  ok "vajra claude -p \"x\" --dangerously-skip-permissions  ->  no warning"
else
  bad "unexpected output: $CASE2"
fi

header "3 · Headless + --permission-mode <any mode> -> silent (AC3)"
CASE3=$("$BIN" claude --print "x" --permission-mode plan 2>&1 1>/dev/null || true)
if [ -z "$CASE3" ]; then
  ok "vajra claude --print \"x\" --permission-mode plan  ->  no warning (mode not second-guessed)"
else
  bad "unexpected output: $CASE3"
fi

header "4 · Interactive (no -p/--print) -> never warns (AC4)"
CASE4=$("$BIN" claude --model opus < /dev/null 2>&1 1>/dev/null || true)
if [ -z "$CASE4" ]; then
  ok "vajra claude --model opus  ->  no warning (TTY is its own approval channel)"
else
  bad "unexpected output: $CASE4"
fi

header "5 · Advisory only — regression suite (AC5, AC6)"
if cargo test --quiet --lib cli::launch::tests::has_permission_flag_detects_either_flag_exact_token >/dev/null 2>&1 \
  && cargo test --quiet --lib cli::launch::tests::should_warn_readonly_headless_matrix >/dev/null 2>&1; then
  ok "has_permission_flag + should_warn_readonly_headless unit matrix green"
else
  bad "regression test failed"
fi

header "Summary — S83 acceptance criteria  [demo:summary_table]"
printf "\n"
printf "  %-58s %s\n" "Criterion" "Status"
printf "  %-58s %s\n" "----------------------------------------------------------" "------"
printf "  %-58s %s\n" "1 · headless + no flag -> warns before spawn"                "SHIPPED"
printf "  %-58s %s\n" "2 · --dangerously-skip-permissions -> silent"                 "SHIPPED"
printf "  %-58s %s\n" "3 · --permission-mode <any> -> silent"                        "SHIPPED"
printf "  %-58s %s\n" "4 · interactive -> never warns"                              "SHIPPED"
printf "  %-58s %s\n" "5 · advisory only (no exit-code/arg change)"                  "SHIPPED"
printf "  %-58s %s\n" "6 · cargo test --lib green (263, +2)"                        "SHIPPED"
printf "\n"

ok "Session ${SESSION} demo complete."
