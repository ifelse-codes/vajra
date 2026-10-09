#!/usr/bin/env bash
# Session 192 demo — the receipt, proven live; and found wherever Claude Code keeps its log.
# A terminal deck (DECISION-009): run it bare in a terminal; piped it prints every slide + the markers.
# Every check runs the REAL `vajra claude` (today's, and the one built at the commit S192 started from,
# 0a58fb5) against a stand-in `claude` that files its log the way Claude Code 2.1.280 does, or the real
# unit tests. The founder's live runs (rudra; /clear, --continue, a fork) are recorded, not re-run.
set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="192"
OLD_SHA=0a58fb5    # the commit S192 started from — pinned, never `main`
# ========================

NEW="$ROOT/target/release/vajra"; OLD="$ROOT/target/s192-old/release/vajra"
cargo build --release -q || { echo "demo: cargo build failed" >&2; exit 1; }
if [ ! -x "$OLD" ]; then
  . "$ROOT/scripts/lib-old-checkout.sh"
  WT=$(vajra_old_checkout "$OLD_SHA") || exit 1
  (cd "$WT" && CARGO_TARGET_DIR="$ROOT/target/s192-old" cargo build --release -q) || exit 1
  vajra_old_checkout_remove "$WT"
fi

# A plain work folder (macOS's own temp folder has an `_` in it, which would hide the point).
W="$ROOT/target/s192-demo-$$"; rm -rf "$W"; mkdir -p "$W/bin"; trap 'rm -rf "$W"' EXIT
cat > "$W/bin/claude" <<'EOF'
#!/usr/bin/env bash
now_ms() { perl -MTime::HiRes=time -e 'printf "%d\n", time()*1000'; }
start=$(now_ms); sleep 0.05
ts=$(perl -MPOSIX=strftime -e 'my $m=shift; printf "%s.%03dZ", strftime("%Y-%m-%dT%H:%M:%S", gmtime(int($m/1000))), $m%1000' "$(now_ms)")
dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects/$(printf '%s' "$(pwd -P)" | perl -pe 's/[^A-Za-z0-9]/-/g')"; mkdir -p "$dir"
{ printf '{"type":"assistant","timestamp":"%s","version":"2.1.280","requestId":"r%s","message":{"id":"m%s","model":"claude-haiku-4-5-20251001","usage":{"input_tokens":10,"output_tokens":50}}}\n' "$ts" "$$" "$$"
  printf '{"type":"cost-state","totalCostUSD":0.0159651,"startTime":%s,"hasUnknownModelCost":false}\n' "$start"; } >> "$dir/s192.jsonl"
EOF
chmod +x "$W/bin/claude"
receipt() { # receipt <bin> <folder name> [ENV=..]… → the receipt's first two lines, or what was printed
  local bin="$1" f="$2"; shift 2; local p="$W/$RANDOM"; mkdir -p "$p/home" "$p/$f"
  local o; o=$(cd "$p/$f" && env HOME="$p/home" PATH="$W/bin:$PATH" VAJRA_SKIP_AUTH_CHECK=1 "$@" "$bin" claude 2>&1 >/dev/null </dev/null)
  if printf '%s\n' "$o" | grep -q '^─── vajra · '; then printf '%s\n' "$o" | awk '/^─── vajra · /{print; getline; print; exit}'
  else printf '(no receipt — nothing printed)\n'; fi
}
has_receipt() { printf '%s' "$1" | grep -q 'Claude Code.s own figure'; }

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION" "LIVE RUNS|5|rudra ×2, fresh, --continue, a fork — each equal to Claude Code's own figure"
  dk_h1 "The receipt is right on real runs, " "and it now finds the run log" " in any folder."
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Your two rudra runs: the receipt said \$6.90 and \$22.96 — exactly what Claude Code itself recorded." \
    "A project in a folder with a dot, an underscore or a space (or with CLAUDE_CONFIG_DIR set) used to get no receipt at all. Now it does."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "Checked the receipt on real money.|Your rudra runs (\$6.90, \$22.96) and three tiny Haiku runs: every figure matched Claude Code's own log to the cent." \
    "Settled S189's open question.|A fork keeps the parent's start time — so the receipt rightly says 'includes earlier spend' instead of guessing." \
    "Learned what /clear does.|It starts a new log and Claude Code's count restarts at \$0. The receipt skips — honest, not helpful yet." \
    "Fixed the folder name.|Copied Claude Code's own rule from its code: every character that is not a letter or digit becomes '-'. Matches 12 of 12 real folders on your Mac; the old rule matched 9." \
    "Same fix in the helper-handoff check.|A project at ~/my_app would have had every helper's handoff marked unverifiable."
  dk_caption "run log = the file Claude Code writes for each chat under ~/.claude/projects/<folder name>/."
}

slide_before_after() {
  dk_section before_after "the change · the same run, before and after"
  dk_h2 "Before → After"
  dk_p "One vajra claude run in a folder named 'my proj_v2.0'. Left: vajra built at $OLD_SHA. Right: today's."
  local b a
  b=$(receipt "$OLD" "my proj_v2.0"); a=$(receipt "$NEW" "my proj_v2.0")
  dk_compare "BEFORE|vajra at $OLD_SHA" "$b" "AFTER|vajra today · live" "$a"
  echo
  dk_check "before: no receipt" bash -c '! printf "%s" "$1" | grep -q "own figure"' _ "$b"
  dk_check "after: Claude Code's own \$0.02" bash -c 'printf "%s" "$1" | grep -q "\$0.02  what this run cost — Claude Code.s own figure"' _ "$a"
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "What the receipt says now"
  dk_table "The run|The receipt's top line|Live result" \
    "a fresh run|Claude Code's own figure|\$0.02 = \$0.0160 ✓" \
    "--continue|only what THIS run added|\$0.01 = \$0.0245 − \$0.0160 ✓" \
    "a fork|'no cost for this run' + the whole conversation, labelled|\$0.03 whole ✓ (fork keeps the parent's start)" \
    "/clear in the run|skipped: 'multiple sessions detected'|no receipt (named, not fixed)" \
    "a folder with . _ or a space|Claude Code's own figure|was: no receipt at all"
  dk_caption "When Vajra cannot be sure a number is this run's, it says so — it never shows a wrong one."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  local b a
  b=$(receipt "$OLD" proj); a=$(receipt "$NEW" proj)
  dk_term "1 · a plain folder name: both versions give a receipt" "$(printf 'before: %s\nafter:  %s' "$(printf '%s' "$b" | tail -1)" "$(printf '%s' "$a" | tail -1)")"
  dk_check "so a missing receipt below is the folder name, nothing else" bash -c 'printf "%s" "$1$2" | grep -c "own figure" | grep -q 2' _ "$b" "$a"
  b=$(receipt "$OLD" proj CLAUDE_CONFIG_DIR="$W/conf-old"); a=$(receipt "$NEW" proj CLAUDE_CONFIG_DIR="$W/conf-new")
  dk_term "2 · CLAUDE_CONFIG_DIR moves Claude Code's logs" "$(printf 'before: %s\nafter:  %s' "$(printf '%s' "$b" | tail -1)" "$(printf '%s' "$a" | tail -1)")"
  dk_check "before none, after the receipt" bash -c '! printf "%s" "$1" | grep -q "own figure" && printf "%s" "$2" | grep -q "own figure"' _ "$b" "$a"
  dk_run_v cargo test -q --lib s192_
  dk_term "3 · the naming rule vs Claude Code's own output, and the live resume / fork shapes" "$(printf '%s' "$_DK_OUT" | grep -E 'test result')"
  dk_check "7 tests ran and passed" bash -c 'printf "%s" "$1" | grep -q "ok. 7 passed"' _ "$_DK_OUT"
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_table "Recorded at close — not re-run here|Result" \
    "rudra runs c778503 / d8cc560: receipt vs Claude Code's cost-state|\$6.90 = 6.8959 · \$22.96 = 22.9620" \
    "fresh / --continue / fork (Haiku, ~\$0.03)|\$0.02 ✓ · \$0.01 ✓ · whole \$0.03 labelled ✓" \
    "the naming rule vs every real folder on this Mac|12 of 12 (old rule: 9)" \
    "scripts/verify-session-192.sh · the full cargo test|see the summary"
  dk_verdict "HONEST NOTES" \
    "/clear still gets no receipt, and a fork's own share is not shown. Both need Vajra to know the run's session id (a start-of-session hook) — a design for a later session, your call." \
    "Claude Code puts /x/my.app and /x/my_app in ONE folder. If one of them wrote no log while the other did, the receipt could read the other's. Another Claude Code version could name folders differently: then no receipt, never a wrong one."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next"
  dk_table " |Option|Why pick it · the risk" \
    "1|rudra's next session|real work finds what fixtures cannot; the receipt is now trusted · risk: waits on rudra's own work" \
    "2|the session-id hook (receipt for /clear + a fork's share)|the last two receipt gaps · risk: touches every project's settings; a design first" \
    "3|the non-Claude tools brainstorm (F91/F94/F95)|promised since S179 · risk: a design session, nothing a user runs"
  dk_table "word|meaning" \
    "receipt|the cost box vajra prints when a Claude run ends" \
    "run log|Claude Code's file for one chat, under ~/.claude/projects" \
    "fork|a new chat that starts as a copy of an old one (--fork-session)"
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
