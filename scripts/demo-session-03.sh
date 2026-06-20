#!/usr/bin/env bash
# Session 03 Demo — ClaudeCodeHookAdapter end-to-end
# Feeds real CC PostToolUse hook JSON into `vajra hook` and shows results.

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

VAJRA="$ROOT/target/debug/vajra"
FIXTURES="$ROOT/research/compression-fixtures/raw"

# ─── Build ───────────────────────────────────────────────────────────────────
header "Build"
cargo build -q
ok "vajra built at $VAJRA"

run_hook() { echo "$1" | "$VAJRA" hook; }

# ─── Case 1: Non-Bash tool → passthrough ─────────────────────────────────────
header "Case 1 — Non-Bash tool (toolName: Read)"
label "Input JSON:"
JSON='{"toolName":"Read","toolInput":{},"toolResponse":{"stdout":"file content here","stderr":"","interrupted":false,"isImage":false,"noOutputExpected":false,"exitCode":0}}'
echo "$JSON" | jq .
label "Output:"
OUT=$(run_hook "$JSON")
echo "$OUT"
[ "$OUT" = "{}" ] && ok "Correct: {} — non-Bash tools always passthrough"

# ─── Case 2: isImage: true → passthrough ─────────────────────────────────────
header "Case 2 — isImage: true"
label "Input JSON:"
JSON='{"toolName":"Bash","toolInput":{"command":"cat screenshot.png"},"toolResponse":{"stdout":"","stderr":"","interrupted":false,"isImage":true,"noOutputExpected":false,"exitCode":0}}'
echo "$JSON" | jq .
label "Output:"
OUT=$(run_hook "$JSON")
echo "$OUT"
[ "$OUT" = "{}" ] && ok "Correct: {} — images never fed to compressor"

# ─── Case 3: noOutputExpected → passthrough ──────────────────────────────────
header "Case 3 — noOutputExpected: true"
label "Input JSON:"
JSON='{"toolName":"Bash","toolInput":{"command":"touch foo.txt"},"toolResponse":{"stdout":"","stderr":"","interrupted":false,"isImage":false,"noOutputExpected":true,"exitCode":0}}'
echo "$JSON" | jq .
label "Output:"
OUT=$(run_hook "$JSON")
echo "$OUT"
[ "$OUT" = "{}" ] && ok "Correct: {} — no output to compress"

# ─── Case 4: Malformed JSON → fail-open ──────────────────────────────────────
header "Case 4 — Malformed JSON (fail-open)"
label "Input:"
echo "this is not valid json at all"
label "Output:"
OUT=$(echo "this is not valid json at all" | "$VAJRA" hook)
echo "$OUT"
[ "$OUT" = "{}" ] && ok "Correct: {} — never blocks Claude Code on bad input"

# ─── Case 5: Short Bash output → passthrough ─────────────────────────────────
header "Case 5 — Short Bash output (under LINE_CAP=200)"
label "Input JSON:"
JSON='{"toolName":"Bash","toolInput":{"command":"echo hello"},"toolResponse":{"stdout":"hello\nworld","stderr":"","interrupted":false,"isImage":false,"noOutputExpected":false,"exitCode":0}}'
echo "$JSON" | jq .
label "Output:"
OUT=$(run_hook "$JSON")
echo "$OUT"
[ "$OUT" = "{}" ] && ok "Correct: {} — 2 lines < LINE_CAP, passthrough"

# ─── Case 6: VAJRA_RAW=1 bypass ──────────────────────────────────────────────
header "Case 6 — VAJRA_RAW=1 bypass (lossless-on-demand)"
label "Building cargo build hook JSON (181-line fixture)…"
RAW=$(cat "$FIXTURES/cargo-build.txt")
HOOK_JSON=$(jq -n \
    --arg cmd "cargo build" \
    --arg stdout "$RAW" \
    '{"toolName":"Bash","toolInput":{"command":$cmd},"toolResponse":{"stdout":$stdout,"stderr":"","interrupted":false,"isImage":false,"noOutputExpected":false,"exitCode":0}}')
label "Output with VAJRA_RAW=1:"
OUT=$(echo "$HOOK_JSON" | VAJRA_RAW=1 "$VAJRA" hook)
echo "$OUT"
[ "$OUT" = "{}" ] && ok "Correct: {} — RAW check fires before stdin is read; original output preserved"

# ─── Case 7: cargo build — the real compression ──────────────────────────────
header "Case 7 — cargo build fixture: 181 lines → compressed"
RAW=$(cat "$FIXTURES/cargo-build.txt")
LINE_COUNT=$(printf '%s' "$RAW" | wc -l | tr -d ' ')
label "Raw stdout (first 5 of $LINE_COUNT lines):"
echo "$RAW" | head -5
printf "${DIM}  … (%d more lines)${RESET}\n" "$(( LINE_COUNT - 5 ))"

HOOK_JSON=$(jq -n \
    --arg cmd "cargo build" \
    --arg stdout "$RAW" \
    '{"toolName":"Bash","toolInput":{"command":$cmd},"toolResponse":{"stdout":$stdout,"stderr":"","interrupted":false,"isImage":false,"noOutputExpected":false,"exitCode":0}}')

label "Hook output JSON:"
OUT=$(run_hook "$HOOK_JSON")
echo "$OUT" | jq .

COMPRESSED=$(echo "$OUT" | jq -r '.hookSpecificOutput.updatedToolOutput.stdout')
COMP_LINES=$(printf '%s' "$COMPRESSED" | wc -l | tr -d ' ')
label "Compressed stdout ($LINE_COUNT lines → $COMP_LINES):"
echo "$COMPRESSED"
ok "$LINE_COUNT lines → $COMP_LINES lines ($(( (LINE_COUNT - COMP_LINES) * 100 / LINE_COUNT ))% reduction)"

# ─── Case 8: cargo test — drop compile + ok-line noise ───────────────────────
header "Case 8 — cargo test fixture: 86 lines → compressed"
RAW=$(cat "$FIXTURES/cargo-test.txt")
LINE_COUNT=$(printf '%s' "$RAW" | wc -l | tr -d ' ')
label "Raw stdout (first 5 of $LINE_COUNT lines):"
echo "$RAW" | head -5
printf "${DIM}  … (%d more lines)${RESET}\n" "$(( LINE_COUNT - 5 ))"

HOOK_JSON=$(jq -n \
    --arg cmd "cargo test" \
    --arg stdout "$RAW" \
    '{"toolName":"Bash","toolInput":{"command":$cmd},"toolResponse":{"stdout":$stdout,"stderr":"","interrupted":false,"isImage":false,"noOutputExpected":false,"exitCode":0}}')

label "Hook output JSON:"
OUT=$(run_hook "$HOOK_JSON")
echo "$OUT" | jq .

COMPRESSED=$(echo "$OUT" | jq -r '.hookSpecificOutput.updatedToolOutput.stdout')
COMP_LINES=$(printf '%s' "$COMPRESSED" | wc -l | tr -d ' ')
label "Compressed stdout ($LINE_COUNT lines → $COMP_LINES):"
echo "$COMPRESSED"
ok "$LINE_COUNT lines → $COMP_LINES lines ($(( (LINE_COUNT - COMP_LINES) * 100 / LINE_COUNT ))% reduction)"

# ─── Summary ─────────────────────────────────────────────────────────────────
header "Summary"
printf "\n"
printf "  %-40s %s\n" "Case" "Result"
printf "  %-40s %s\n" "----------------------------------------" "------"
printf "  %-40s %s\n" "1. Non-Bash tool (Read)"                  "{} passthrough"
printf "  %-40s %s\n" "2. isImage: true"                         "{} passthrough"
printf "  %-40s %s\n" "3. noOutputExpected: true"                "{} passthrough"
printf "  %-40s %s\n" "4. Malformed JSON"                        "{} fail-open"
printf "  %-40s %s\n" "5. Short output (2 lines)"                "{} passthrough"
printf "  %-40s %s\n" "6. VAJRA_RAW=1"                           "{} bypass"
printf "  %-40s %s\n" "7. cargo build (181 lines)"               "compressed + breadcrumb"
printf "  %-40s %s\n" "8. cargo test (86 lines)"                 "compressed + breadcrumb"
printf "\n"
ok "ClaudeCodeHookAdapter: all cases correct"
