#!/usr/bin/env bash
# Session 189 verify — F67 for good: the receipt reads Claude Code's own cost for interactive runs.
# Claude Code (2.1.275+) writes its own running total into the run log (`{"type":"cost-state"}`) when it
# exits. The receipt's headline is now that figure — this run's share of it — or says plainly that
# Claude Code gave none; the price-list number only ever rides a labelled `[estimate]` line.
# Every check RUNS the real thing: the real `vajra claude` (and `vajra meter`) binary, launched against
# a stand-in `claude` that writes a run log in the shape Claude Code 2.1.280 writes — a cut-down
# cost-state line (the fields Vajra reads) around the real totals of one real transcript — for $0. The
# unit-test fixture (tests/fixtures/meter/cost-state-2.1.280.jsonl) carries two real cost-state lines;
# its second 13.94 line (one exit writing twice) and its token counts are made up. Each fix is run again at the commit S189
# started from (8e52d29, pinned), where it must go red for the reason it names (S122). Nothing greps
# source; the price list is compared with the start commit's, entry by entry.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(cd "$(mktemp -d)" && pwd -P)"
trap 'vajra_old_checkout_remove "${OLD_WT:-}"; rm -rf "$T"' EXIT
OLD_SHA=8e52d29
VAJRA="$ROOT/target/release/vajra"
FIX="$ROOT/tests/fixtures/meter/cost-state-2.1.280.jsonl"
cargo build --release -q || { echo "FAIL: cargo build --release"; exit 1; }
. "$ROOT/scripts/lib-old-checkout.sh"
OLD_WT=$(vajra_old_checkout "$OLD_SHA") || { echo "FAIL: worktree at $OLD_SHA"; exit 1; }
(cd "$OLD_WT" && CARGO_TARGET_DIR="$ROOT/target/s189-old" cargo build --release -q) || { echo "FAIL: build at $OLD_SHA"; exit 1; }
OLD_VAJRA="$ROOT/target/s189-old/release/vajra"

# The stand-in `claude`: it writes a run log the way Claude Code does — every line stamped after the
# launch, then (unless STUB_CRASH) the cost-state record at exit. STUB_TOTAL is the running total it
# records; STUB_SEED is an earlier run log to resume (copied in first, so this run appends to it);
# STUB_MODEL is the model it answers as; STUB_UNPRICED=true marks the record as not fully priced by
# Claude Code; STUB_SEED_START moves Claude Code's own start time; a `-p` launch also prints the result
# stream. Each line names Claude Code 2.1.280, as a real one does.
mkdir -p "$T/bin"
cat > "$T/bin/claude" <<'EOF'
#!/usr/bin/env bash
now_ms() { perl -MTime::HiRes=time -e 'printf "%d\n", time()*1000'; }
stamp() { perl -MPOSIX=strftime -e 'my $m=shift; printf "%s.%03dZ\n", strftime("%Y-%m-%dT%H:%M:%S", gmtime(int($m/1000))), $m%1000' "$1"; }
start=$(now_ms); sleep 0.05
# S192: Claude Code names the folder by replacing every non-alphanumeric character; the binary at the
# start commit replaced only `/`. The folder gets the new name, linked under the old one, so each finds it.
here="$(pwd -P)"; dir="$HOME/.claude/projects/$(printf '%s' "$here" | perl -pe 's/[^A-Za-z0-9]/-/g')"; mkdir -p "$dir"
olddir="$HOME/.claude/projects/$(printf '%s' "$here" | tr / -)"; [ -e "$olddir" ] || ln -s "$dir" "$olddir"
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
chmod +x "$T/bin/claude"

# launch BIN NAME [ENV=..]... -- [claude args] → the receipt (stderr) of one `vajra claude` run in a
# fresh project folder with its own HOME; the headline is the line after the receipt's top rule.
launch() {
  local bin="$1" name="$2"; shift 2
  local envs=(); while [ "$1" != -- ]; do envs+=("$1"); shift; done; shift
  local p="$T/$name-$(basename "$(dirname "$(dirname "$bin")")")"; rm -rf "$p"; mkdir -p "$p/home" "$p/proj/.ai"
  local e; for e in ${envs[@]+"${envs[@]}"}; do case "$e" in CAP=*)
    printf 'budget:\n  cap_usd: %s\n  mode: warn\n' "${e#CAP=}" > "$p/proj/.ai/CONSTRAINTS.yaml" ;; esac; done
  (cd "$p/proj" && env HOME="$p/home" PATH="$T/bin:$PATH" VAJRA_SKIP_AUTH_CHECK=1 STUB_TOTAL=4.648155399999999 \
     STUB_P_TOTAL=0.4211 ${envs[@]+"${envs[@]}"} "$bin" claude "$@" 2>&1 >/dev/null </dev/null)
}
headline() { awk '/^─── vajra · /{getline; print; exit}' ; }
after_headline() { awk '/^─── vajra · /{getline; getline; print; exit}' ; }

# --- 1 (AC1): a fresh interactive run — the headline IS Claude Code's own figure ---
NEW=$(launch "$VAJRA" fresh --) ; OLD=$(launch "$OLD_VAJRA" fresh --)
if printf '%s\n' "$NEW" | headline | grep -q '^ \$4\.65  what this run cost — Claude Code.s own figure'; then
  ok "AC1 fresh run: headline = Claude Code's own \$4.65 ($(printf '%s\n' "$NEW" | after_headline | sed 's/^ *//' | cut -c1-40)… on the line beneath)"
else bad "AC1 fresh run headline: $(printf '%s\n' "$NEW" | headline)"; fi
if printf '%s\n' "$OLD" | headline | grep -q '^ ~\$23\.91  estimated'; then
  ok "AC1 red at $OLD_SHA for the named reason: the headline was the price-list guess ($(printf '%s\n' "$OLD" | headline | sed 's/^ *//' | cut -c1-20)), ~5× Claude Code's own"
else bad "AC1 at $OLD_SHA: $(printf '%s\n' "$OLD" | headline)"; fi

# --- 2 (AC1): a resumed conversation — the headline is THIS run's share, not the whole total ---
head -n 6 "$FIX" > "$T/run1.jsonl"
NEW=$(launch "$VAJRA" resume STUB_SEED="$T/run1.jsonl" STUB_SEED_START=1790227599460 STUB_TOTAL=13.94323919999999 -- --continue)
OLD=$(launch "$OLD_VAJRA" resume STUB_SEED="$T/run1.jsonl" STUB_SEED_START=1790227599460 STUB_TOTAL=13.94323919999999 -- --continue)
if printf '%s\n' "$NEW" | headline | grep -q '^ \$9\.30  what this run cost — Claude Code.s own figure'; then
  ok "AC1 resumed run: headline = this run's share \$9.30 (Claude Code's 13.94 total minus the 4.65 already in the log)"
else bad "AC1 resumed run headline: $(printf '%s\n' "$NEW" | headline)"; fi
if printf '%s\n' "$OLD" | headline | grep -q 'estimated'; then
  ok "AC1 resumed run red at $OLD_SHA: $(printf '%s\n' "$OLD" | headline | sed 's/^ *//' | cut -c1-30)"
else bad "AC1 resumed at $OLD_SHA: $(printf '%s\n' "$OLD" | headline)"; fi

# --- 3 (AC2): Claude Code wrote no figure (a crash) — the headline says so; the estimate is labelled beneath ---
NEW=$(launch "$VAJRA" crash STUB_CRASH=1 --) ; OLD=$(launch "$OLD_VAJRA" crash STUB_CRASH=1 --)
H=$(printf '%s\n' "$NEW" | headline); B=$(printf '%s\n' "$NEW" | after_headline)
if [ "$(printf '%s' "$H" | sed 's/  (.*//')" = " no cost from Claude Code for this run" ] && ! printf '%s' "$H" | grep -q '\$' \
   && printf '%s' "$B" | grep -q '^ *~\$[0-9.]*  \[estimate'; then
  ok "AC2 no figure: headline '$(printf '%s' "$H" | sed 's/^ //; s/  (.*//')', no dollar sign; the estimate is the labelled line beneath"
else bad "AC2: headline '$H' / beneath '$B'"; fi
if printf '%s\n' "$OLD" | headline | grep -q '^ ~\$[0-9.]*  estimated'; then
  ok "AC2 red at $OLD_SHA: the headline was a dollar estimate ($(printf '%s\n' "$OLD" | headline | sed 's/^ *//' | cut -c1-20))"
else bad "AC2 at $OLD_SHA: $(printf '%s\n' "$OLD" | headline)"; fi

# --- 4 (AC3): a made-up model with no price row and no record — never a guess on the headline ---
NEW=$(launch "$VAJRA" opus9 STUB_CRASH=1 STUB_MODEL=claude-opus-9 --) ; OLD=$(launch "$OLD_VAJRA" opus9 STUB_CRASH=1 STUB_MODEL=claude-opus-9 --)
H=$(printf '%s\n' "$NEW" | headline); B=$(printf '%s\n' "$NEW" | after_headline)
if printf '%s' "$H" | grep -q '^ no cost from Claude Code for this run  (opus-9' && ! printf '%s' "$H" | grep -q '\$' \
   && printf '%s' "$B" | grep -q 'opus-9 priced at the unknown-model upper bound'; then
  ok "AC3 claude-opus-9: headline has no figure; the upper-bound guess is tagged on the estimate line only"
else bad "AC3: headline '$H' / beneath '$B'"; fi
if printf '%s\n' "$OLD" | headline | grep -q '^ ~\$[0-9.]*  estimated  (opus-9'; then
  ok "AC3 red at $OLD_SHA: the headline was the upper-bound guess ($(printf '%s\n' "$OLD" | headline | sed 's/^ *//' | cut -c1-20))"
else bad "AC3 at $OLD_SHA: $(printf '%s\n' "$OLD" | headline)"; fi

# --- 5 (deliverable 3): no new price rows — the price list equals the start commit's, entry by entry ---
rows() { awk '/^const MODEL_PRICING/,/^\];/' | grep -E 'prefix:|_per_mtok:' | tr -d ' ' ; }
if diff <(git show "$OLD_SHA:src/meter/mod.rs" | rows) <(rows < src/meter/mod.rs) >/dev/null; then
  ok "deliverable 3: the price list has the same $(rows < src/meter/mod.rs | grep -c prefix:) rows as $OLD_SHA, the same rates — none added for Opus 5.5 or any model"
else bad "deliverable 3: the price list changed since $OLD_SHA"; fi

# --- 6 (AC4): a -p run — the result stream still wins, unchanged from the start commit ---
NEW=$(launch "$VAJRA" p -- -p hi --output-format stream-json) ; OLD=$(launch "$OLD_VAJRA" p -- -p hi --output-format stream-json)
NH=$(printf '%s\n' "$NEW" | headline); OH=$(printf '%s\n' "$OLD" | headline)
if [ "$NH" = "$OH" ] && printf '%s' "$NH" | grep -q '^ \$0\.42  what this run cost  ('; then
  ok "AC4 -p run: headline '$(printf '%s' "$NH" | sed 's/^ //')' — the stream's \$0.42, not the log's \$4.65, same as at $OLD_SHA"
else bad "AC4: now '$NH' / at $OLD_SHA '$OH'"; fi

# --- 7 (design): \`vajra meter FILE\` has no launch time — the whole conversation's total, labelled so ---
NEW=$("$VAJRA" meter "$FIX" 2>&1 >/dev/null); OLD=$("$OLD_VAJRA" meter "$FIX" 2>&1 >/dev/null)
if printf '%s\n' "$NEW" | headline | grep -q "^ \$13\.94  Claude Code's own total for this whole conversation (every run in this file)"; then
  ok "vajra meter FILE: \$13.94 labelled as the whole conversation (the two duplicate lines not added up)"
else bad "vajra meter FILE: $(printf '%s\n' "$NEW" | headline)"; fi
if printf '%s\n' "$OLD" | headline | grep -q 'estimated'; then
  ok "vajra meter FILE red at $OLD_SHA: $(printf '%s\n' "$OLD" | headline | sed 's/^ *//' | cut -c1-20)"
else bad "vajra meter at $OLD_SHA: $(printf '%s\n' "$OLD" | headline)"; fi

# --- 8 (review rec 6): a fork, or a resume missing its earlier total — Claude Code's own start time is
# before the launch and nothing in the log to subtract: never headlined as this run's cost ---
NEW=$(launch "$VAJRA" fork STUB_SEED_START=1790227599460 STUB_TOTAL=13.94323919999999 --)
OLD=$(launch "$OLD_VAJRA" fork STUB_SEED_START=1790227599460 STUB_TOTAL=13.94323919999999 --)
H=$(printf '%s\n' "$NEW" | headline); B=$(printf '%s\n' "$NEW" | after_headline)
if printf '%s' "$H" | grep -q '^ no cost from Claude Code for this run' && ! printf '%s' "$H" | grep -q '\$' \
   && printf '%s' "$B" | grep -q "\$13\.94  Claude Code's total for this whole conversation — includes spend before this run"; then
  ok "fork / unseen resume: no figure on top; the whole conversation's \$13.94 on its own labelled line"
else bad "fork: headline '$H' / beneath '$B'"; fi
if printf '%s\n' "$OLD" | headline | grep -q '^ ~\$[0-9.]*  estimated'; then
  ok "fork red at $OLD_SHA: the headline was a dollar estimate ($(printf '%s\n' "$OLD" | headline | sed 's/^ *//' | cut -c1-20))"
else bad "fork at $OLD_SHA: $(printf '%s\n' "$OLD" | headline)"; fi

# --- 9 (review rec 6): Claude Code's record says it could not price every model — still its figure, and said ---
NEW=$(launch "$VAJRA" unpriced STUB_UNPRICED=true STUB_MODEL=claude-opus-9 --)
OLD=$(launch "$OLD_VAJRA" unpriced STUB_UNPRICED=true STUB_MODEL=claude-opus-9 --)
if printf '%s\n' "$NEW" | headline | grep -q '^ \$4\.65  what this run cost — Claude Code.s own figure' \
   && printf '%s\n' "$NEW" | grep -q '^ *Claude Code could not price every model in this run'; then
  ok "hasUnknownModelCost: headline is Claude Code's \$4.65 and says it could not price every model"
else bad "unpriced: $(printf '%s\n' "$NEW" | headline)"; fi
if printf '%s\n' "$OLD" | headline | grep -q '^ ~\$[0-9.]*  estimated  (opus-9'; then
  ok "hasUnknownModelCost red at $OLD_SHA: $(printf '%s\n' "$OLD" | headline | sed 's/^ *//' | cut -c1-20)"
else bad "unpriced at $OLD_SHA: $(printf '%s\n' "$OLD" | headline)"; fi

# --- 10 (review rec 1): Claude Code 2.1.280 wrote no record for this run — named, not a silent "no cost" ---
NEW=$(launch "$VAJRA" drift STUB_CRASH=1 --) ; OLD=$(launch "$OLD_VAJRA" drift STUB_CRASH=1 --)
if printf '%s\n' "$NEW" | grep -q '^\[vajra warn\] Claude Code 2\.1\.280 records its own cost when it exits, but this run log has none'; then
  ok "a missing record is named: '$(printf '%s\n' "$NEW" | grep -m1 'Claude Code 2.1.280 records' | cut -c14-80)…'"
else bad "drift warning missing"; fi
if ! printf '%s\n' "$OLD" | grep -q 'records its own cost'; then
  ok "missing-record warning red at $OLD_SHA: nothing said"
else bad "drift at $OLD_SHA"; fi

# --- 11 (review rec 3): over the budget cap with no figure — the number is called an estimate, not the cost ---
NEW=$(launch "$VAJRA" cap CAP=5.00 STUB_CRASH=1 --) ; OLD=$(launch "$OLD_VAJRA" cap CAP=5.00 STUB_CRASH=1 --)
if printf '%s\n' "$NEW" | grep -q "^\[vajra budget\] WARNING: Vajra's own token estimate ~\$23\.91 exceeds cap \$5\.00 (no cost from Claude Code" \
   && ! printf '%s\n' "$NEW" | grep -q 'session cost'; then
  ok "budget: '$(printf '%s\n' "$NEW" | grep -m1 'vajra budget' | cut -c1-72)…'"
else bad "budget now: $(printf '%s\n' "$NEW" | grep 'vajra budget')"; fi
if printf '%s\n' "$OLD" | grep -q '^\[vajra budget\] WARNING: session cost \$23\.91[0-9]* exceeds cap'; then
  ok "budget red at $OLD_SHA: the estimate was called the session cost"
else bad "budget at $OLD_SHA: $(printf '%s\n' "$OLD" | grep 'vajra budget')"; fi

echo "----"
echo "verify-session-189: $PASS passed, $FAIL failed"
[ "$FAIL" = 0 ]
