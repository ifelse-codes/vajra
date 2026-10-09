#!/usr/bin/env bash
# Session 193 demo — rudra S19 under the trusted receipt; F117: a real figure stands alone.
# A terminal deck (DECISION-009): run it bare in a terminal; piped it prints every slide + the markers.
# Every check runs the REAL `vajra claude` (today's, and the one built at the commit S193 started from,
# d2ec218) against a stand-in `claude` that writes a run log the way Claude Code 2.1.280 does. The
# founder's rudra S19 run is recorded, not re-run (its log stays on his machine, S126).
set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="193"
OLD_SHA=d2ec218    # the commit S193 started from — pinned, never `main`
# ========================

NEW="$ROOT/target/release/vajra"; OLD="$ROOT/target/s193-old/release/vajra"
cargo build --release -q || { echo "demo: cargo build failed" >&2; exit 1; }
if [ ! -x "$OLD" ]; then
  . "$ROOT/scripts/lib-old-checkout.sh"
  WT=$(vajra_old_checkout "$OLD_SHA") || exit 1
  (cd "$WT" && CARGO_TARGET_DIR="$ROOT/target/s193-old" cargo build --release -q) || exit 1
  vajra_old_checkout_remove "$WT"
fi

W="$ROOT/target/s193-demo-$$"; rm -rf "$W"; mkdir -p "$W/bin"; trap 'rm -rf "$W"' EXIT
# The stand-in: one opus-5-5 reply, one folded tool call (as rudra S19 had), and — unless STUB_CRASH —
# Claude Code's own cost record at exit: $37.27, rudra S19's figure.
cat > "$W/bin/claude" <<'STUB'
#!/usr/bin/env bash
now_ms() { perl -MTime::HiRes=time -e 'printf "%d\n", time()*1000'; }
start=$(now_ms); sleep 0.05
ts=$(perl -MPOSIX=strftime -e 'my $m=shift; printf "%s.%03dZ", strftime("%Y-%m-%dT%H:%M:%S", gmtime(int($m/1000))), $m%1000' "$(now_ms)")
dir="$HOME/.claude/projects/$(printf '%s' "$(pwd -P)" | perl -pe 's/[^A-Za-z0-9]/-/g')"; mkdir -p "$dir"
printf '{"lines_in":18,"lines_out":1,"command":"cargo"}\n' >> "$VAJRA_SESSION_STATS"
{ printf '{"type":"assistant","timestamp":"%s","version":"2.1.280","requestId":"r%s","message":{"id":"m%s","model":"claude-opus-5-5","usage":{"input_tokens":622,"output_tokens":51811,"cache_read_input_tokens":8306752,"cache_creation":{"ephemeral_1h_input_tokens":251857,"ephemeral_5m_input_tokens":0}}}}\n' "$ts" "$$" "$$"
  [ -z "${STUB_CRASH:-}" ] && printf '{"type":"cost-state","totalCostUSD":37.2723498,"startTime":%s,"hasUnknownModelCost":false}\n' "$start"; } >> "$dir/s193.jsonl"
STUB
chmod +x "$W/bin/claude"
receipt() { # receipt <bin> [ENV=..]… → the whole receipt (stderr), or what was printed
  local bin="$1"; shift; local p="$W/$RANDOM"; mkdir -p "$p/home" "$p/proj"
  (cd "$p/proj" && env HOME="$p/home" PATH="$W/bin:$PATH" VAJRA_SKIP_AUTH_CHECK=1 "$@" "$bin" claude 2>&1 >/dev/null </dev/null)
}

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION" "RUDRA S19|\$37.27|the receipt = Claude Code's own figure, to the cent"
  dk_h1 "When Claude Code says what a run cost, " "the receipt now says only that" "."
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "rudra S19's receipt showed the real \$37.27 — and right under it a ~\$167 'estimate', 4.5 times too high." \
    "Now a real figure stands alone. The estimate only appears when Claude Code gave no figure at all."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "You ran rudra S19 for real.|About 1h45m of work: a new trading idea tested, reviewed (ACCEPT 17/20), merged. The close log: green, 2 expected warnings." \
    "We checked the receipt against Claude Code.|\$37.27 on screen = 37.2723 in Claude Code's own log = its own lastCost. Trusted." \
    "We found four things (F116–F119).|You said: fix F117 (the misleading estimate), park the other three as known bugs, written down so they are not lost." \
    "We fixed F117.|One rule decides 'Claude Code gave a figure'. With one, no estimate, no split, no pricing warning."
  dk_caption "receipt = the cost box vajra prints when a Claude run ends."
}

slide_before_after() {
  dk_section before_after "the change · the same run, before and after"
  dk_h2 "Before → After"
  dk_p "One vajra claude run shaped like rudra S19 (opus-5-5, \$37.27). Left: vajra built at $OLD_SHA. Right: today's."
  local b a
  b=$(receipt "$OLD" | sed -n '/^─── vajra/,$p'); a=$(receipt "$NEW" | sed -n '/^─── vajra/,$p')
  dk_compare "BEFORE|vajra at $OLD_SHA" "$b" "AFTER|vajra today · live" "$a"
  echo
  dk_check "before: a ~\$23.91 estimate beside the real \$37.27" bash -c 'printf "%s" "$1" | grep -q "\[estimate · opus-5-5 priced at the unknown-model upper bound"' _ "$b"
  dk_check "after: the \$37.27, no estimate line" bash -c 'printf "%s" "$1" | grep -q "\$37.27  what this run cost — Claude Code.s own figure" && ! printf "%s" "$1" | grep -q "\[estimate"' _ "$a"
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "When the estimate shows"
  dk_table "The run|Claude Code gave a figure?|What the receipt shows" \
    "a normal run (rudra S19)|yes|the figure only" \
    "vajra claude -p|yes (its result line)|the figure only" \
    "vajra meter FILE|yes (the whole file's total)|the whole-file figure only" \
    "a crash (no record written)|no|'no cost from Claude Code' + the estimate, labelled" \
    "a fork|not for this run|'no cost for this run' + the whole total + the estimate"
  dk_caption "The estimate is Vajra's own guess from token counts. It is only worth showing when there is nothing better."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  local a
  a=$(receipt "$NEW" STUB_CRASH=1 | sed -n '/^─── vajra/,$p')
  dk_term "1 · a crash: Claude Code wrote no figure — the estimate is still shown, labelled" "$a"
  dk_check "no figure → estimate and split stay" bash -c 'printf "%s" "$1" | grep -q "Vajra.s own estimate from the tokens" && printf "%s" "$1" | grep -q "\[estimate\] split"' _ "$a"
  a=$("$NEW" meter "$ROOT/tests/fixtures/meter/cost-state-2.1.280.jsonl" 2>&1 >/dev/null | sed -n '/^─── vajra/,$p')
  dk_term "2 · vajra meter on a saved run log: the whole file's figure, nothing beside it" "$a"
  dk_check "whole-file \$13.94, no estimate" bash -c 'printf "%s" "$1" | grep -q "\$13.94  Claude Code.s own total" && ! printf "%s" "$1" | grep -q "\[estimate"' _ "$a"
  dk_run_v cargo test -q --lib s193_
  dk_term "3 · the unit test: whole file, fork, no record, and a late -p figure" "$(printf '%s' "$_DK_OUT" | grep -E 'test result')"
  dk_check "1 test ran and passed" bash -c 'printf "%s" "$1" | grep -q "ok. 1 passed"' _ "$_DK_OUT"
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_table "Recorded at close — not re-run here|Result" \
    "rudra S19 receipt vs Claude Code's cost-state vs ~/.claude.json lastCost|\$37.27 = 37.2723 = 37.2723" \
    "rudra S19 close log: WAIVED / N/A / WARN first|0 waived · 2 WARN, both expected (unchecked claims, no lint_command)" \
    "scripts/verify-session-193.sh · the full cargo test|see the summary"
  dk_verdict "HONEST NOTES" \
    "Parked as known bugs (ROADMAP backlog, on the S195 checklist): F116 your approval record is left out of git at close · F118 --advance keeps the old session's text · F119 the to-do list shows ✗ for design when none is needed." \
    "The '~\$ saved' compression line is still priced from Vajra's own price list (a guess). /clear still gets no receipt."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next — no pick yet (founder, 2026-10-09)"
  dk_table " |Option|Why pick it · the risk" \
    "1|rudra's next session (its S20 is a review session)|real work finds what fixtures cannot · risk: a review-only run may find little in Vajra" \
    "2|fix the three known bugs (F116, F118, F119)|small, each one a user meets · risk: little new learning" \
    "3|cut the cost: the boot diet (F4) + a KNOWLEDGE.md trim|your next build · risk: early by your own rule"
  dk_table "word|meaning" \
    "receipt|the cost box vajra prints when a Claude run ends" \
    "estimate|Vajra's own guess from token counts × its price list" \
    "fork|a new chat that starts as a copy of an old one"
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
