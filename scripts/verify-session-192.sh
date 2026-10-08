#!/usr/bin/env bash
# Session 192 verify — the receipt finds Claude Code's run log wherever Claude Code puts it.
# Claude Code (2.1.280, read from its own code) names a project's log folder by replacing EVERY
# character that is not a letter or digit with `-`, and keeps it under $CLAUDE_CONFIG_DIR/projects when
# that is set. Before S192 Vajra replaced only `/` and always looked under ~/.claude — so a project in
# `my proj_v2.0` (or with CLAUDE_CONFIG_DIR set) got no receipt at all.
# Every receipt check RUNS the real `vajra claude` binary against a stand-in `claude` that files its
# run log the way Claude Code does, for $0. Each fix is run again at the commit S192 started from
# (0a58fb5, pinned), where it must go red for the reason it names (S122): a plain-path control run
# proves the old binary still gives a receipt when the folder name is not the problem.
# The live evidence (the founder's rudra runs: $6.90 and $22.96, each equal to Claude Code's own
# cost-state total) is recorded in sessions/session-192-summary.md — no transcript is committed.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
# Not mktemp: macOS's temp folder (/var/folders/0s/snr36g_x5…) itself has an `_`, so no path under it
# is plain enough for the control below. target/ is git-ignored; letters, digits, `/` and `-` only.
T="$ROOT/target/s192-verify-$$"; rm -rf "$T"; mkdir -p "$T"
case "$T" in *[!A-Za-z0-9/-]*) echo "FAIL: the work folder $T is not plain"; exit 1 ;; esac
trap 'vajra_old_checkout_remove "${OLD_WT:-}"; rm -rf "$T"' EXIT
OLD_SHA=0a58fb5
VAJRA="$ROOT/target/release/vajra"
cargo build --release -q || { echo "FAIL: cargo build --release"; exit 1; }
. "$ROOT/scripts/lib-old-checkout.sh"
OLD_WT=$(vajra_old_checkout "$OLD_SHA") || { echo "FAIL: worktree at $OLD_SHA"; exit 1; }
(cd "$OLD_WT" && CARGO_TARGET_DIR="$ROOT/target/s192-old" cargo build --release -q) || { echo "FAIL: build at $OLD_SHA"; exit 1; }
OLD_VAJRA="$ROOT/target/s192-old/release/vajra"

# The stand-in `claude`: files its run log where Claude Code 2.1.280 does — under
# ${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects, in a folder named by replacing every non-alphanumeric
# character of the real working folder with `-` — then writes the cost-state record at exit.
mkdir -p "$T/bin"
cat > "$T/bin/claude" <<'EOF'
#!/usr/bin/env bash
now_ms() { perl -MTime::HiRes=time -e 'printf "%d\n", time()*1000'; }
stamp() { perl -MPOSIX=strftime -e 'my $m=shift; printf "%s.%03dZ\n", strftime("%Y-%m-%dT%H:%M:%S", gmtime(int($m/1000))), $m%1000' "$1"; }
start=$(now_ms); sleep 0.05
root="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects"
dir="$root/$(printf "%s" "$(pwd -P)" | perl -pe 's/[^A-Za-z0-9]/-/g')"; mkdir -p "$dir"
log="$dir/192ecb30-f3ea-4691-84aa-4fe8e8630ef8.jsonl"
ts=$(stamp "$(now_ms)")
{
  printf '{"type":"assistant","uuid":"s192-%s","timestamp":"%s","version":"2.1.280","requestId":"req_s192_%s","message":{"id":"msg_s192_%s","model":"claude-opus-5-5","role":"assistant","content":[{"type":"text","text":"ok"}],"usage":{"input_tokens":10,"cache_creation_input_tokens":100,"cache_read_input_tokens":1000,"output_tokens":50}}}\n' "$$" "$ts" "$$" "$$"
  printf '{"type":"cost-state","totalCostUSD":6.8958896,"startTime":%s,"modelUsage":{},"hasUnknownModelCost":false}\n' "$start"
} >> "$log"
echo "$log" > "$STUB_LOG_PATH"
exit 0
EOF
chmod +x "$T/bin/claude"

# launch BIN CASE FOLDER [ENV=..]... → the receipt (stderr) of one `vajra claude` run in FOLDER with
# its own HOME. The stand-in writes the path of the log it filed to $T/<case>-<bin>.log.
launch() {
  local bin="$1" case="$2" folder="$3"; shift 3
  local tag; tag=$(basename "$(dirname "$(dirname "$bin")")")
  local p="$T/$case-$tag"; rm -rf "$p"; mkdir -p "$p/home" "$p/$folder"
  (cd "$p/$folder" && env HOME="$p/home" PATH="$T/bin:$PATH" VAJRA_SKIP_AUTH_CHECK=1 \
     STUB_LOG_PATH="$T/$case-$tag.log" "$@" "$bin" claude 2>&1 >/dev/null </dev/null)
}
headline() { awk '/^─── vajra · /{getline; print; exit}' ; }
WANT='^ \$6\.90  what this run cost — Claude Code.s own figure'

# --- 0 (control): a plain folder name — the OLD binary finds the log too, so a red below is the folder ---
NEW=$(launch "$VAJRA" plain proj); OLD=$(launch "$OLD_VAJRA" plain proj)
if printf '%s\n' "$NEW" | headline | grep -q "$WANT" && printf '%s\n' "$OLD" | headline | grep -q "$WANT"; then
  ok "control: folder 'proj' — both binaries show Claude Code's own \$6.90"
else bad "control: new '$(printf '%s\n' "$NEW" | headline)' / old '$(printf '%s\n' "$OLD" | headline)'"; fi

# --- 1 (AC3): a folder with `.`, `_` and a space ---
NEW=$(launch "$VAJRA" odd "my proj_v2.0"); OLD=$(launch "$OLD_VAJRA" odd "my proj_v2.0")
LOG=$(cat "$T/odd-target.log" 2>/dev/null)
case "$LOG" in */projects/-*-my-proj-v2-0/*.jsonl) filed=1 ;; *) filed=0 ;; esac
if [ "$filed" = 1 ] && printf '%s\n' "$NEW" | headline | grep -q "$WANT"; then
  ok "AC3 'my proj_v2.0': the log is filed as …/$(basename "$(dirname "$LOG")") and the receipt shows \$6.90"
else bad "AC3 odd folder: log '$LOG' / headline '$(printf '%s\n' "$NEW" | headline)'"; fi
if ! printf '%s\n' "$OLD" | grep -q '^─── vajra · '; then
  ok "AC3 red at $OLD_SHA for the named reason: no receipt (it looked in …/$(printf '%s' "$T/odd-target/my proj_v2.0" | tr / - | sed 's/.*-odd-target-/…-/'), which Claude Code never makes)"
else bad "AC3 at $OLD_SHA still found the log: $(printf '%s\n' "$OLD" | headline)"; fi

# --- 2 (AC3): CLAUDE_CONFIG_DIR moves the logs; the receipt follows ---
NEW=$(launch "$VAJRA" cfg proj CLAUDE_CONFIG_DIR="$T/cfg-target/conf"); OLD=$(launch "$OLD_VAJRA" cfg proj CLAUDE_CONFIG_DIR="$T/cfg-s192-old/conf")
LOG=$(cat "$T/cfg-target.log" 2>/dev/null)
if [ "${LOG#"$T/cfg-target/conf/projects/"}" != "$LOG" ] && printf '%s\n' "$NEW" | headline | grep -q "$WANT"; then
  ok "AC3 CLAUDE_CONFIG_DIR: the log is under \$CLAUDE_CONFIG_DIR/projects and the receipt shows \$6.90"
else bad "AC3 CLAUDE_CONFIG_DIR: log '$LOG' / headline '$(printf '%s\n' "$NEW" | headline)'"; fi
if ! printf '%s\n' "$OLD" | grep -q '^─── vajra · '; then
  ok "AC3 CLAUDE_CONFIG_DIR red at $OLD_SHA for the named reason: no receipt (it looked only under ~/.claude)"
else bad "AC3 CLAUDE_CONFIG_DIR at $OLD_SHA still found the log: $(printf '%s\n' "$OLD" | headline)"; fi

# --- 3 (AC3/AC4): the naming rule against Claude Code's own output, and the live resume shape ---
# The expected names in these tests were produced by Claude Code 2.1.280's own `kT` under node; the
# resume test copies the shape the founder's `claude --resume` left in rudra's log (no transcript).
OUT=$(cargo test -q --lib s192_ 2>&1)
if printf '%s\n' "$OUT" | grep -q 'test result: ok. 6 passed'; then
  ok "unit: 6 s192 tests ran and passed (names incl. a >200 hashed one, CLAUDE_CONFIG_DIR, the name override, the resume shape)"
else bad "unit s192: $(printf '%s\n' "$OUT" | grep 'test result' | head -1)"; fi

echo "verify-session-192: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
