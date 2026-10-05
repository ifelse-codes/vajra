#!/usr/bin/env bash
# Session 184 verify — F103 (init waits a bounded time on silent piped input), F107 (project-facing
# obeyed wording), F108 (no empty folder from --ledger / --ledger-verify).
# Every check RUNS the real thing — the real binary, the real close gates, a real `vajra init`
# project — and every fix is also run at the commit S184 started from, where it must go red for the
# reason it names (S122). Nothing greps source.
# OLD = the commit S184 started from (e1c348e, pinned — never `main`).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(mktemp -d)"; KILL=()
trap 'for p in ${KILL[@]+"${KILL[@]}"}; do kill "$p" 2>/dev/null; done; vajra_old_checkout_remove "${OLD_WT:-}"; rm -rf "$T"' EXIT
OLD_SHA=e1c348e
VAJRA="$ROOT/target/release/vajra"
cargo build --release -q || { echo "FAIL: cargo build --release"; exit 1; }
export PATH="$ROOT/target/release:$PATH"
# The OLD binary, built once into its own target dir (kept under target/ so a re-run is fast).
# S187 (S185 N7): the old checkout lives in the one known folder; a killed run's is cleared next run.
. "$ROOT/scripts/lib-old-checkout.sh"
OLD_WT=$(vajra_old_checkout "$OLD_SHA") || { echo "FAIL: worktree at $OLD_SHA"; exit 1; }
(cd "$OLD_WT" && CARGO_TARGET_DIR="$ROOT/target/s184-old" cargo build --release -q) || { echo "FAIL: build at $OLD_SHA"; exit 1; }
OLD_VAJRA="$ROOT/target/s184-old/release/vajra"
row() { grep -E "^$2[[:space:]]" "$1" | awk '{print $2}'; }
folders() { ls "$1/.ai/verify/closeout" 2>/dev/null | wc -l | tr -d ' '; }

# run_init BIN DIR — `vajra init` on a stdin that stays open and silent for 60 s. Prints the seconds
# it took, or "hung" when it was still waiting after 25 s (then it is killed).
run_init() {
  mkdir -p "$2" && (cd "$2" && git init -q) && mkfifo "$2.in"
  sleep 60 > "$2.in" & local sp=$!; KILL+=("$sp")
  (cd "$2" && "$1" init < "$2.in" > /dev/null 2> "$2.err") & local ip=$!; KILL+=("$ip")
  local s=$SECONDS
  while kill -0 "$ip" 2>/dev/null && [ $((SECONDS - s)) -lt 25 ]; do sleep 1; done
  if kill -0 "$ip" 2>/dev/null; then kill "$ip" 2>/dev/null; echo hung; else echo $((SECONDS - s)); fi
  kill "$sp" 2>/dev/null
}

# --- F103: an open, silent stdin no longer hangs `vajra init` -----------------------------------------
n=$(run_init "$VAJRA" "$T/silent-new"); o=$(run_init "$OLD_VAJRA" "$T/silent-old")
if [ "$n" != hung ] && [ "$n" -le 20 ] && [ "$o" = hung ] \
   && grep -q 'Project name: my-project  (default — no answer arrived on the piped input)' "$T/silent-new.err" \
   && grep -rq 'my-project' "$T/silent-new/.ai/AGENTS.md"; then
  ok "F103 a silent open pipe: init finishes in ${n}s with the default 'my-project', says so on stderr; at $OLD_SHA it was still waiting at 25s"
else bad "F103 silent pipe new='$n' old='$o'"; head -5 "$T/silent-new.err"; fi
grep -c '(default — ' "$T/silent-new.err" | grep -qx 3 \
  && ok "F103 after the first silence every later question gets its default too (3 defaults named, one wait)" \
  || bad "F103 defaults named: $(grep -c '(default — ' "$T/silent-new.err")"

# Piped answers still land — all three, including the last (maturity).
P="$T/piped"; mkdir -p "$P"; (cd "$P" && git init -q)
s=$SECONDS; (cd "$P" && printf 'acme-app\nlock the charts\nL3\n' | "$VAJRA" init >/dev/null 2>"$T/piped.err")
if grep -rq 'acme-app' "$P/.ai/AGENTS.md" && grep -q '^maturity: L3' "$P/.ai/CONSTRAINTS.yaml" \
   && ! grep -q '(default — ' "$T/piped.err" && [ $((SECONDS - s)) -lt 8 ]; then
  ok "F103 piped answers land: acme-app, goal, maturity L3 — no default used, no wait"
else bad "F103 piped answers"; head -5 "$T/piped.err"; fi
# End of input (the `</dev/null` every other script uses) is immediate, as before.
s=$SECONDS; (mkdir -p "$T/eof" && cd "$T/eof" && git init -q && "$VAJRA" init </dev/null >/dev/null 2>"$T/eof.err")
[ $((SECONDS - s)) -lt 8 ] && grep -q '(default — the piped input ended)' "$T/eof.err" \
  && ok "F103 empty input (</dev/null): defaults at once, named as 'the piped input ended'" || bad "F103 eof"
# A terminal is read exactly as before: no timer. A real pty via script(1); the answer comes 12 s
# late — past the piped wait — and still lands. (script sends ^D at end of input, so input is
# written after the program starts and held open 1 s after.)
mkdir -p "$T/tty" && (cd "$T/tty" && git init -q)
(cd "$T/tty" && (sleep 12; printf 'tty-app\n\n\n'; sleep 1) | script -q /dev/null "$VAJRA" init > "$T/tty.out" 2>&1)
grep -rq 'tty-app' "$T/tty/.ai" && ! grep -q '(default — ' "$T/tty.out" \
  && ok "F103 on a real terminal there is no timer: an answer typed after 12 s still lands (tty-app)" || bad "F103 terminal path"
cargo test -q --release --lib piped_ 2>&1 | grep -q 'test result: ok. 2 passed' \
  && ok "F103 unit: silence waits once then defaults (a late answer is not taken); answers land in order then end of input defaults" \
  || bad "F103 unit tests"

# --- F107: the obeyed warning a project sees names no Vajra session number ----------------------------
P="$T/proj"; mkdir -p "$P"; (cd "$P" && git init -q && "$VAJRA" init </dev/null >/dev/null 2>&1)
(cd "$P" && git add -A && git -c core.hooksPath=/nonexistent commit -qm scaffold && git checkout -q -b session-01-kickoff \
  && echo "# s01" > notes.md && git add notes.md && git -c core.hooksPath=/nonexistent commit -qm s01)
SHA=$(git -C "$P" rev-parse --short HEAD)
printf '\n## Advice\n- tech-lead rec 1 — obeyed: %s (done)\n' "$SHA" >> "$P/prompts/01-task-kickoff.md"
(cd "$P" && bash scripts/verify-closeout.sh > "$T/f107.out" 2>/dev/null)
LOG="$P/.ai/verify/closeout/latest/obeyed-judgments.log"
new=$(cd "$P" && "$VAJRA" next --check-obeyed 1 2>&1); old=$(cd "$P" && "$OLD_VAJRA" next --check-obeyed 1 2>&1)
if [ "$(row "$T/f107.out" obeyed-judgments)" = WARN ] && ! grep -qE '132|threshold' "$LOG" \
   && ! grep -qE '132|threshold' <<<"$new" && grep -q 'threshold: session 132' <<<"$old"; then
  ok "F107 project close: still a WARN row, and neither its log nor the gate says '132'/'threshold' (at $OLD_SHA it said 'threshold: session 132')"
else bad "F107 row='$(row "$T/f107.out" obeyed-judgments)'"; grep -E '132|threshold' "$LOG" <<<"$new" | head -3; fi
grep -q 'names them but does not block on them' <<<"$new" && grep -q 'warning, not blocking' <<<"$new" \
  && ok "F107 the gate still says plainly the claims are named, not blocked, and how to check one" || bad "F107 disclosure"
# Vajra's own gate keeps its threshold: session 132 and later still BLOCK an unchecked claim.
bash scripts/verify-session-132.sh > "$T/v132.out" 2>&1
grep -qE '^pre-threshold-warns-and-names-the-exemption +exec +PASS' "$T/v132.out" \
  && grep -qE '^s127-specimen-joins-and-drives-the-exit-code +exec +PASS' "$T/v132.out" \
  && grep -qE '^unjudged-obeyed-blocks-from-the-threshold +exec +PASS' "$T/v132.out" \
  && ok "F107 Vajra's S132 checks on the warning and on blocking still pass with the new words" \
  || { bad "F107 S132 checks"; grep -E 'exec +FAIL' "$T/v132.out"; }

# --- F108: --ledger / --ledger-verify leave no empty dated folder ------------------------------------
git show "$OLD_SHA:scripts/verify-closeout-scaffold.sh" > "$T/old-scaffold.sh"
# One committed review, so --ledger prints a real chain: in a project with NO review yet it exits 1
# silently at e1c348e and now alike (F114, S185) — comparing two such runs would prove nothing.
(cd "$P" && mkdir -p sessions && printf '**Verdict:** ACCEPT\n' > sessions/session-01-review.md && git add sessions \
  && git -c core.hooksPath=/nonexistent commit -qm review)
for mode in --ledger --ledger-verify; do
  a=$(folders "$P"); (cd "$P" && bash scripts/verify-closeout.sh $mode > "$T/l-new.out" 2>&1); rn=$?; b=$(folders "$P")
  sleep 1   # the dated folder is per second: two runs in one second share one name
  CLAUDE_PROJECT_DIR="$P" bash "$T/old-scaffold.sh" $mode > "$T/l-old.out" 2>&1; ro=$?; c=$(folders "$P")
  [ "$a" = "$b" ] && [ "$c" = $((b+1)) ] && [ "$rn" = 0 ] && [ "$ro" = 0 ] && [ -s "$T/l-new.out" ] && cmp -s "$T/l-new.out" "$T/l-old.out" \
    && ok "F108 project gate $mode: no folder now (the $OLD_SHA gate added 1); same exit ($rn) and same output" \
    || bad "F108 project $mode folders ${a}→${b} (old →${c}) exit new=$rn old=$ro"
done
for mode in --ledger --ledger-verify; do
  a=$(folders "$ROOT"); bash scripts/verify-closeout.sh $mode > "$T/v-new.out" 2>&1; rn=$?; b=$(folders "$ROOT")
  [ "$a" = "$b" ] && [ "$rn" = 0 ] && grep -q 'chain head\|intact\|INTACT' "$T/v-new.out" \
    && ok "F108 Vajra's gate $mode: exit 0, prints its result, adds no folder" || bad "F108 Vajra $mode folders ${a}→${b} exit $rn"
done
a=$(folders "$P"); (cd "$P" && bash scripts/verify-closeout.sh > /dev/null 2>&1); b=$(folders "$P")
[ "$b" = $((a+1)) ] && ok "F108 control: a full close run still writes its dated folder" || bad "F108 control ${a}→${b}"

echo; echo "=== Session 184 Verify Summary ==="
if [ "$FAIL" -eq 0 ]; then echo "GREEN ($PASS pass, 0 fail)"; exit 0; else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
