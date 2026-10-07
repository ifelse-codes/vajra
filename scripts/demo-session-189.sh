#!/usr/bin/env bash
# Session 189 demo — F67 for good: the receipt reads Claude Code's own cost.
# A terminal deck (DECISION-009): run it bare in a terminal; piped it prints every slide + the markers.
# Every receipt below is a REAL `vajra claude` run — today's binary and the one at the commit S189
# started from (8e52d29) — launched against a stand-in `claude` that writes a run log in the shape Claude
# Code 2.1.280 writes (a cut-down cost-state line around one real transcript's totals), for $0.
set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="189"
OLD_SHA=8e52d29    # the commit S189 started from — pinned, never `main`
# ========================

cargo build --release -q 2>/dev/null
VAJRA="$ROOT/target/release/vajra"
. "$ROOT/scripts/lib-old-checkout.sh"
OLD_WT=$(vajra_old_checkout "$OLD_SHA")
trap 'vajra_old_checkout_remove "${OLD_WT:-}"' EXIT
(cd "$OLD_WT" && CARGO_TARGET_DIR="$ROOT/target/s189-old" cargo build --release -q) 2>/dev/null
OLD_VAJRA="$ROOT/target/s189-old/release/vajra"
FIX="$ROOT/tests/fixtures/meter/cost-state-2.1.280.jsonl"
head -n 6 "$FIX" > "$DK_TMP/run1.jsonl"

mkdir -p "$DK_TMP/bin"
cat > "$DK_TMP/bin/claude" <<'EOF'
#!/usr/bin/env bash
now_ms() { perl -MTime::HiRes=time -e 'printf "%d\n", time()*1000'; }
stamp() { perl -MPOSIX=strftime -e 'my $m=shift; printf "%s.%03dZ\n", strftime("%Y-%m-%dT%H:%M:%S", gmtime(int($m/1000))), $m%1000' "$1"; }
start=$(now_ms); sleep 0.05
dir="$HOME/.claude/projects/$(pwd -P | tr / -)"; mkdir -p "$dir"
log="$dir/69ecb30e-f3ea-4691-84aa-4fe8e8630ef8.jsonl"
[ -n "${STUB_SEED:-}" ] && cp "$STUB_SEED" "$log"
[ -n "${STUB_SEED_START:-}" ] && start="$STUB_SEED_START"
ts=$(stamp "$(now_ms)")
model="${STUB_MODEL:-claude-opus-5-5}"
{
  printf '{"type":"queue-operation","operation":"enqueue","timestamp":"%s","sessionId":"69ecb30e-f3ea-4691-84aa-4fe8e8630ef8"}\n' "$ts"
  printf '{"type":"assistant","uuid":"s189-%s","timestamp":"%s","version":"2.1.280","requestId":"req_s189_%s","message":{"id":"msg_s189_%s","model":"%s","role":"assistant","content":[{"type":"text","text":"ok"}],"usage":{"input_tokens":622,"cache_creation_input_tokens":251857,"cache_read_input_tokens":8306752,"output_tokens":51811,"cache_creation":{"ephemeral_1h_input_tokens":251857,"ephemeral_5m_input_tokens":0}}}}\n' "$$" "$ts" "$$" "$$" "$model"
  printf '{"type":"last-prompt","lastPrompt":"ok","sessionId":"69ecb30e-f3ea-4691-84aa-4fe8e8630ef8"}\n'
  [ -z "${STUB_CRASH:-}" ] && printf '{"type":"cost-state","sessionId":"69ecb30e-f3ea-4691-84aa-4fe8e8630ef8","totalCostUSD":%s,"startTime":%s,"modelUsage":{"%s":{"costUSD":%s}},"hasUnknownModelCost":%s}\n' "$STUB_TOTAL" "$start" "$model" "$STUB_TOTAL" "${STUB_UNPRICED:-false}"
} >> "$log"
for a in "$@"; do [ "$a" = -p ] && printf '{"type":"result","subtype":"success","total_cost_usd":%s}\n' "$STUB_P_TOTAL"; done
exit 0
EOF
chmod +x "$DK_TMP/bin/claude"

N=0
# receipt BIN [ENV=..]... -- [claude args] → the receipt one `vajra claude` run prints, in a fresh folder
receipt() {
  local bin="$1"; shift; local envs=(); while [ "$1" != -- ]; do envs+=("$1"); shift; done; shift
  local p; p=$(mktemp -d "$DK_TMP/run.XXXXXX"); mkdir -p "$p/home" "$p/proj"
  (cd "$p/proj" && env HOME="$p/home" PATH="$DK_TMP/bin:$PATH" VAJRA_SKIP_AUTH_CHECK=1 STUB_TOTAL=4.648155399999999 \
     STUB_P_TOTAL=0.4211 ${envs[@]+"${envs[@]}"} "$bin" claude "$@" 2>&1 >/dev/null </dev/null) \
    | sed -n '/^─── vajra/,/^─────/p' | sed '1d;$d' | sed 's/^ *//' | fold -s -w 74
}
head1() { printf '%s\n' "$1" | head -1; }

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION" "CHANGE|1|the receipt's cost line is Claude Code's own figure"
  dk_h1 "The receipt now shows " "what Claude Code says it cost" " — or says it does not know."
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Old: an interactive run's receipt guessed the cost from Vajra's own price list. A model missing from the list (Opus 5.5) was priced at a ceiling — rudra's receipts read about 5× too high." \
    "New: Claude Code writes its own total into the run log when it exits. Vajra reads it and shows this run's share. No figure → the receipt says so, and the guess sits underneath, labelled [estimate]."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "Your ask (parked 3 times).|Fix it for good — read the tool's own cost, don't keep adding price rows." \
    "The find.|Claude Code 2.1.275+ adds a 'cost-state' line to the run log at every normal exit: its own total, per model. S77 found nothing because the line did not exist yet." \
    "This run only.|A resumed chat keeps a running total (4.65 → 13.94 → …). Vajra subtracts what was already there when it started." \
    "Fails safe.|Crash, old Claude Code, an odd timestamp, a resume missing its earlier total → 'no cost from Claude Code for this run'. A crash on a new Claude Code is also named in a warning." \
    "Nothing to set up.|No new setting, no status line change, no price rows. rudra gets it the next time it runs vajra claude (after the new vajra is installed)."
  dk_caption "run log = the transcript file Claude Code keeps for each chat, under ~/.claude/projects/."
}

slide_before_after() {
  dk_section before_after "the change · the same run, before and after"
  dk_h2 "Before → After"
  dk_p "The input: one interactive run on Opus 5.5 that Claude Code says cost \$4.65. Left: vajra at $OLD_SHA. Right: today's."
  local b a
  dk_run_v receipt "$OLD_VAJRA" --; b="$_DK_OUT"
  dk_run_v receipt "$VAJRA" --; a="$_DK_OUT"
  dk_compare "BEFORE|vajra at $OLD_SHA" "$b" "AFTER|vajra today · live" "$a"
  echo
  dk_check "before: the headline was the price-list guess (~\$23.91)" bash -c 'printf "%s" "$1" | head -1 | grep -q "^~\$23.91  estimated"' _ "$b"
  dk_check "after: the headline is Claude Code's \$4.65" bash -c 'printf "%s" "$1" | head -1 | grep -q "^\$4.65  what this run cost — Claude Code"' _ "$a"
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "Which number goes on top"
  dk_table "The run|The receipt's top line|Why" \
    "vajra claude -p (headless)|the cost Claude Code printed at the end|unchanged since S78" \
    "an interactive run that ended normally|this run's share of Claude Code's own total|new — the run log's cost-state line" \
    "a crash, or Claude Code before 2.1.275|no cost from Claude Code for this run|nothing to read, so nothing claimed" \
    "a fork, or a resume missing its earlier total|no cost for this run + the whole chat's total, labelled|can't tell this run's share" \
    "vajra meter FILE (after the fact)|the whole chat's total, labelled as that|no start time to cut at"
  dk_caption "Vajra's own token guess is always the line underneath, marked [estimate]. No price rows were added."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  dk_run_v receipt "$VAJRA" STUB_SEED="$DK_TMP/run1.jsonl" STUB_SEED_START=1790227599460 STUB_TOTAL=13.94323919999999 -- --continue
  dk_term "1 · a resumed chat: Claude Code's total is 13.94; 4.65 was already in the log" "$_DK_OUT"
  dk_check "this run's share: \$9.30" bash -c 'printf "%s" "$1" | head -1 | grep -q "^\$9.30  what this run cost"' _ "$_DK_OUT"
  dk_run_v receipt "$VAJRA" STUB_CRASH=1 --
  dk_term "2 · the run crashed — Claude Code wrote no total" "$_DK_OUT"
  dk_check "says no cost; no dollar sign on top" bash -c 'h=$(printf "%s" "$1" | head -1); printf "%s" "$h" | grep -q "^no cost from Claude Code for this run" && ! printf "%s" "$h" | grep -q "\\$"' _ "$_DK_OUT"
  dk_run_v receipt "$VAJRA" STUB_CRASH=1 STUB_MODEL=claude-opus-9 --
  dk_term "3 · a made-up model (claude-opus-9), no total from Claude Code" "$_DK_OUT"
  dk_check "the ceiling guess is only on the [estimate] line" bash -c '! printf "%s" "$1" | head -1 | grep -q "\\$" && printf "%s" "$1" | sed -n 2p | grep -q "unknown-model upper bound"' _ "$_DK_OUT"
  dk_run_v receipt "$VAJRA" -- -p hi --output-format stream-json
  dk_term "4 · a -p run: Claude Code printed \$0.42; the log also says \$4.65" "$_DK_OUT"
  dk_check "the printed \$0.42 still wins" bash -c 'printf "%s" "$1" | head -1 | grep -q "^\$0.42  what this run cost  ("' _ "$_DK_OUT"
  dk_run_v bash -c "'$VAJRA' meter '$FIX' 2>&1 >/dev/null | sed -n '2p' | sed 's/^ *//'"
  dk_term "5 · vajra meter on a saved log (two runs, the last total written twice)" "$_DK_OUT"
  dk_check "the whole chat's \$13.94, labelled; never added twice" bash -c 'printf "%s" "$1" | grep -q "^\$13.94  Claude Code.s own total for this whole conversation"' _ "$_DK_OUT"
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_table "Recorded at close — not re-run here|Result" \
    "scripts/verify-session-189.sh — real vajra runs; each fix run at $OLD_SHA too|see the summary" \
    "rudra's last run log (2026-10-03): Claude Code's own total|\$29.89 (recorded; old receipts read ~5× that kind of run)" \
    "the full cargo test, before the push|see the summary"
  dk_verdict "HONEST NOTES" \
    "Proven on a stand-in claude that writes 2.1.280-shaped lines around real totals — not yet on a live interactive run. A fork is assumed to keep Claude Code's start time (unverified). /clear still skips the receipt (two logs), and the [estimate] line on a resumed chat still counts the whole log." \
    "Claude Code's figure is its own list-price total, not your invoice; on a subscription it is notional. Its line format is internal and may change — then the receipt says 'no cost', never a wrong number."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next"
  dk_table " |Option|Why pick it · the risk" \
    "1|S190 ground truth (review-only, due)|every 5th session; S186–S189 since the last · risk: none, it is the rule" \
    "2|after S190: the non-Claude tools brainstorm|promised since S179 · risk: a design session" \
    "3|after S190: rudra S18 with the new receipt + approvals check|first real use of S188 + S189 · risk: waits for rudra's data API"
  dk_table "word|meaning" \
    "receipt|the cost summary Vajra prints when a Claude Code run ends" \
    "cost-state|the line Claude Code writes into its run log when it exits, with its own total" \
    "[estimate]|Vajra's own guess from token counts × its price list — never the top line"
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
