#!/usr/bin/env bash
# Session 66 — Make the receipt AUTHORITATIVE (retire the ~4.71x overstatement).
# Demo: side-by-side, the SAME fable-5 run before/after. The bug (S63): the receipt recomputed
# from tokens and priced `claude-fable-5` as opus -> $5.9665 for a run that actually cost $1.2662
# (4.71x). The fix: prefer the JSONL's own `total_cost_usd` as the headline, demote the token
# recompute to a labeled `[estimate]`, and flag the unknown model instead of silently billing opus.
# Cumulative: one CLI, no 8th command; the receipt is `vajra meter` / the `vajra claude` tail.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}== %s ==${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}> %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}+ %s${RESET}\n" "$1"; }

header "Session 66 Demo — the receipt tells the truth: authoritative first, estimate labeled"
printf "${DIM}  A governance tool whose own receipt lies 4.71x is not 'provable'. This retires that.${RESET}\n"

cargo build --quiet 2>/dev/null || true
BIN="$ROOT/target/debug/vajra"

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# --- The S63 reproduction: a fable-5 run. The result line carries the real bill ($1.2662); the
#     assistant token counts recompute to ~$5.97 at the opus fallback rate. ---
FA="$TMP/fable-run.jsonl"
cat > "$FA" <<'EOF'
{"type":"assistant","message":{"model":"claude-fable-5","usage":{"input_tokens":32687,"output_tokens":18781,"cache_read_input_tokens":593200,"cache_creation":{"ephemeral_5m_input_tokens":0,"ephemeral_1h_input_tokens":105923},"server_tool_use":{"web_search_requests":0,"web_fetch_requests":0}}}}
{"type":"result","subtype":"success","total_cost_usd":1.2662,"num_turns":17}
EOF

header "1. The S63 fable-5 run — receipt now leads with the authoritative charge"
label "vajra meter <fable-run.jsonl>"
"$BIN" meter "$FA" 2>&1 | sed 's/^/    /'
ok "Headline \$1.2662 = the JSONL's total_cost_usd (the real bill)"
ok "Token recompute \$5.9664 is shown but labeled [estimate] — the retired 4.71x, disclosed not billed"
ok "'claude-fable-5 not in pricing table' — the unknown model is flagged, not silently priced as opus"

# --- The fallback: an interactive/legacy transcript with a known model and NO total_cost_usd. ---
FB="$TMP/interactive-run.jsonl"
cat > "$FB" <<'EOF'
{"type":"assistant","message":{"model":"claude-opus-4-8","usage":{"input_tokens":500,"output_tokens":1000,"cache_read_input_tokens":11000,"cache_creation":{"ephemeral_5m_input_tokens":0,"ephemeral_1h_input_tokens":5000}}}}
EOF

header "2. No total_cost_usd (interactive/legacy) — the estimate stays, honestly labeled"
label "vajra meter <interactive-run.jsonl>"
"$BIN" meter "$FB" 2>&1 | sed 's/^/    /'
ok "Headline is the token estimate, tagged [estimate] — never presented as the authoritative charge"
ok "'no total_cost_usd in JSONL' — the reader knows this is an estimate, not the bill"

header "Summary"
printf "  ${GREEN}%s${RESET}\n" "Prefer total_cost_usd  ->  demote the token estimate to a labeled fallback  ->  flag unknown models."
printf "  ${DIM}%s${RESET}\n" "The estimate is not deleted (offline/legacy logs need it); it is disclosed, not billed."
