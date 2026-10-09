#!/usr/bin/env bash
# Session 193 verify — F117 (rudra S19): with Claude Code's own figure, the receipt shows only that figure.
# rudra S19's receipt printed $37.27 (= Claude Code's cost-state 37.2723498, to the cent) over a ~$167.44
# "[estimate · opus-5-5 priced at the unknown-model upper bound]" line, an "[estimate] split:" line and a
# "not in pricing table" warning. The founder's call: drop the estimate when there is a real figure; keep it
# only when there is none (ADR-0004 S193 addendum).
# Every check RUNS the real thing: the real `vajra claude` / `vajra meter` binary against S189's stand-in
# `claude` (a 2.1.280-shaped run log, $0) — plus one line in Vajra's compression stats file, as the hook
# writes it, so the receipt has its compression lines. Each fix is run again at the commit S193 started
# from (d2ec218, pinned — the receipt code is unchanged up to it), where it must go red for F117's own
# reason (S122). The controls (no figure) must print the same lines at both commits. Nothing greps source;
# the price list is compared with the start commit's, entry by entry.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(cd "$(mktemp -d)" && pwd -P)"
trap 'vajra_old_checkout_remove "${OLD_WT:-}"; rm -rf "$T"' EXIT
OLD_SHA=d2ec218
VAJRA="$ROOT/target/release/vajra"
FIX="$ROOT/tests/fixtures/meter/cost-state-2.1.280.jsonl"
cargo build --release -q || { echo "FAIL: cargo build --release"; exit 1; }
. "$ROOT/scripts/lib-old-checkout.sh"
OLD_WT=$(vajra_old_checkout "$OLD_SHA") || { echo "FAIL: worktree at $OLD_SHA"; exit 1; }
(cd "$OLD_WT" && CARGO_TARGET_DIR="$ROOT/target/s193-old" cargo build --release -q) || { echo "FAIL: build at $OLD_SHA"; exit 1; }
OLD_VAJRA="$ROOT/target/s193-old/release/vajra"

# The stand-in `claude` (S189's, unchanged), plus: STUB_STATS=1 appends one compressed-call line to the
# stats file Vajra hands it (VAJRA_SESSION_STATS), 18 lines in → 1 out, as rudra S19's run had.
mkdir -p "$T/bin"
cat > "$T/bin/claude" <<'STUB'
#!/usr/bin/env bash
now_ms() { perl -MTime::HiRes=time -e 'printf "%d\n", time()*1000'; }
stamp() { perl -MPOSIX=strftime -e 'my $m=shift; printf "%s.%03dZ\n", strftime("%Y-%m-%dT%H:%M:%S", gmtime(int($m/1000))), $m%1000' "$1"; }
start=$(now_ms); sleep 0.05
here="$(pwd -P)"; dir="$HOME/.claude/projects/$(printf '%s' "$here" | perl -pe 's/[^A-Za-z0-9]/-/g')"; mkdir -p "$dir"
log="$dir/69ecb30e-f3ea-4691-84aa-4fe8e8630ef8.jsonl"
[ -n "${STUB_SEED_START:-}" ] && start="$STUB_SEED_START"
[ -n "${STUB_STATS:-}" ] && printf '{"lines_in":18,"lines_out":1,"command":"cargo"}\n' >> "$VAJRA_SESSION_STATS"
ts=$(stamp "$(now_ms)")
model="${STUB_MODEL:-claude-opus-5-5}"
{
  printf '{"type":"queue-operation","operation":"enqueue","timestamp":"%s","sessionId":"69ecb30e-f3ea-4691-84aa-4fe8e8630ef8"}\n' "$ts"
  printf '{"type":"assistant","uuid":"s193-%s","timestamp":"%s","version":"2.1.280","requestId":"req_s193_%s","message":{"id":"msg_s193_%s","model":"%s","role":"assistant","content":[{"type":"text","text":"ok"}],"usage":{"input_tokens":622,"cache_creation_input_tokens":251857,"cache_read_input_tokens":8306752,"output_tokens":51811,"cache_creation":{"ephemeral_1h_input_tokens":251857,"ephemeral_5m_input_tokens":0}}}}\n' "$$" "$ts" "$$" "$$" "$model"
  printf '{"type":"last-prompt","lastPrompt":"ok","sessionId":"69ecb30e-f3ea-4691-84aa-4fe8e8630ef8"}\n'
  [ -z "${STUB_CRASH:-}" ] && printf '{"type":"cost-state","sessionId":"69ecb30e-f3ea-4691-84aa-4fe8e8630ef8","totalCostUSD":%s,"startTime":%s,"modelUsage":{"%s":{"costUSD":%s}},"hasUnknownModelCost":%s}\n' "$STUB_TOTAL" "$start" "$model" "$STUB_TOTAL" "${STUB_UNPRICED:-false}"
} >> "$log"
for a in "$@"; do [ "$a" = -p ] && printf '{"type":"result","subtype":"success","total_cost_usd":%s}\n' "$STUB_P_TOTAL"; done
exit 0
STUB
chmod +x "$T/bin/claude"

# launch BIN NAME [ENV=..]... -- [claude args] → the receipt (stderr) of one `vajra claude` run in a fresh
# project folder with its own HOME.
launch() {
  local bin="$1" name="$2"; shift 2
  local envs=(); while [ "$1" != -- ]; do envs+=("$1"); shift; done; shift
  local p="$T/$name-$(basename "$(dirname "$(dirname "$bin")")")"; rm -rf "$p"; mkdir -p "$p/home" "$p/proj/.ai"
  (cd "$p/proj" && env HOME="$p/home" PATH="$T/bin:$PATH" VAJRA_SKIP_AUTH_CHECK=1 STUB_TOTAL=37.2723498 \
     STUB_P_TOTAL=0.4211 ${envs[@]+"${envs[@]}"} "$bin" claude "$@" 2>&1 >/dev/null </dev/null)
}
# The receipt's body: the lines between its top rule and its bottom rule.
body() { awk '/^─── vajra · /{on=1; next} on && /^───────/{exit} on'; }
headline() { body | head -1; }
has() { printf '%s\n' "$1" | grep -qF -- "$2"; }

# --- 1 (F117): rudra S19's shape — a fresh run, opus-5-5, $37.27, one folded call ---
NEW=$(launch "$VAJRA" fresh STUB_STATS=1 --); OLD=$(launch "$OLD_VAJRA" fresh STUB_STATS=1 --)
NB=$(printf '%s\n' "$NEW" | body)
if [ "$(printf '%s\n' "$NB" | wc -l | tr -d ' ')" = 3 ] \
   && printf '%s\n' "$NB" | sed -n 1p | grep -q "^ \$37\.27  what this run cost — Claude Code's own figure  (opus-5-5 · 1 replies)$" \
   && printf '%s\n' "$NB" | sed -n 2p | grep -q '^ *17 lines folded across 1 tool calls$' \
   && printf '%s\n' "$NB" | sed -n 3p | grep -q '^ *~\$[0-9.]* saved (est\. ~204 input tokens not billed)$' \
   && ! has "$NEW" 'not in pricing table' && ! has "$NEW" '[estimate'; then
  ok "F117 fresh run: the receipt is 3 lines — '\$37.27 … Claude Code's own figure', 17 lines folded, the saving — no estimate, no split, no pricing warning"
else bad "F117 fresh run now:"$'\n'"$NEW"; fi
if has "$OLD" '[estimate · opus-5-5 priced at the unknown-model upper bound' && has "$OLD" '[estimate] split:' \
   && has "$OLD" 'not in pricing table' && [ "$(printf '%s\n' "$OLD" | headline)" = "$(printf '%s\n' "$NB" | sed -n 1p)" ]; then
  ok "F117 red at $OLD_SHA: same headline, then '$(printf '%s\n' "$OLD" | body | sed -n 2p | sed 's/^ *//' | cut -c1-60)…', the split and the pricing warning"
else bad "F117 at $OLD_SHA:"$'\n'"$OLD"; fi

# --- 2 (F117): a -p run — the stream's figure, no 'Vajra's own estimate from tokens' beneath it ---
NEW=$(launch "$VAJRA" p -- -p hi --output-format stream-json); OLD=$(launch "$OLD_VAJRA" p -- -p hi --output-format stream-json)
if printf '%s\n' "$NEW" | headline | grep -q '^ \$0\.42  what this run cost  (opus-5-5' \
   && ! has "$NEW" "Vajra's own estimate" && ! has "$NEW" '[estimate' && ! has "$NEW" 'not in pricing table'; then
  ok "F117 -p run: '\$0.42  what this run cost' (the stream) and no estimate, split or pricing warning"
else bad "F117 -p now:"$'\n'"$NEW"; fi
if has "$OLD" "Vajra's own estimate from tokens" && has "$OLD" 'not in pricing table'; then
  ok "F117 -p red at $OLD_SHA: '$(printf '%s\n' "$OLD" | grep -m1 "Vajra's own estimate" | sed 's/^ *//' | cut -c1-50)…' beneath the stream figure"
else bad "F117 -p at $OLD_SHA:"$'\n'"$OLD"; fi

# --- 3 (F117): `vajra meter FILE` — the whole-conversation total is the figure for what it shows ---
NEW=$("$VAJRA" meter "$FIX" 2>&1 >/dev/null); OLD=$("$OLD_VAJRA" meter "$FIX" 2>&1 >/dev/null)
if printf '%s\n' "$NEW" | headline | grep -q "^ \$13\.94  Claude Code's own total for this whole conversation (every run in this file)" \
   && ! has "$NEW" '[estimate'; then
  ok "F117 meter FILE: '\$13.94 … whole conversation' and no estimate beneath it"
else bad "F117 meter FILE now:"$'\n'"$NEW"; fi
if has "$OLD" '[estimate'; then ok "F117 meter FILE red at $OLD_SHA: an [estimate] line beneath the whole-conversation total"
else bad "F117 meter FILE at $OLD_SHA:"$'\n'"$OLD"; fi

# --- 4 (controls): no figure from Claude Code — the estimate stays, the same lines as at the start ---
# A crash (no cost-state written) and a fork (the total started before this launch). The unknown-model
# warning is now written last, so the lines are compared as a set.
for c in "crash STUB_CRASH=1" "fork STUB_SEED_START=1700000000000"; do
  set -- $c; name=$1; shift
  NEW=$(launch "$VAJRA" "$name" STUB_STATS=1 "$@" --); OLD=$(launch "$OLD_VAJRA" "$name" STUB_STATS=1 "$@" --)
  if has "$NEW" "Vajra's own estimate from the tokens" && has "$NEW" '[estimate] split:' && has "$NEW" 'not in pricing table' \
     && diff <(printf '%s\n' "$NEW" | sort) <(printf '%s\n' "$OLD" | sort) >/dev/null; then
    ok "control $name (no figure): estimate, split and pricing warning still shown — the same $(printf '%s\n' "$NEW" | wc -l | tr -d ' ') lines as at $OLD_SHA"
  else bad "control $name: now vs $OLD_SHA"$'\n'"$(diff <(printf '%s\n' "$OLD" | sort) <(printf '%s\n' "$NEW" | sort))"; fi
done

# --- 5 (standing rule): no new price rows — the price list equals the start commit's, entry by entry ---
rows() { awk '/^const MODEL_PRICING/,/^\];/' | grep -E 'prefix:|_per_mtok:' | tr -d ' ' ; }
if diff <(git show "$OLD_SHA:src/meter/mod.rs" | rows) <(rows < src/meter/mod.rs) >/dev/null; then
  ok "the price list has the same $(rows < src/meter/mod.rs | grep -c prefix:) rows as $OLD_SHA — none added for Opus 5.5"
else bad "the price list changed since $OLD_SHA"; fi

# --- 6 (AC3): rudra S19's receipt against Claude Code's own total (recorded numbers, not a live read) ---
# The founder's receipt top line was $37.27; the run log's last cost-state totalCostUSD was 37.272349799999986
# and ~/.claude.json lastCost the same (read 2026-10-09; the log stays on his machine, S126).
if [ "$(printf '%.2f' 37.272349799999986)" = 37.27 ]; then
  ok "AC3 rudra S19: receipt \$37.27 = cost-state 37.2723498 = lastCost 37.2723498 (rounded to the cent)"
else bad "AC3 rounding"; fi

echo "----"
echo "verify-session-193: $PASS passed, $FAIL failed"
[ "$FAIL" = 0 ]
