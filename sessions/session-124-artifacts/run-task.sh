#!/usr/bin/env bash
# S124 dogfood — per-stage capture for the paid `vajra claude` run over chitra.
#
# Adapted from sessions/session-118-artifacts/run-task.sh (same shape, same raw-surface
# capture, same cumulative spend gate), with one addition S124 asks for: after the run,
# scan the transcript + chitra's tree for any trace that the S121-S123 fleet or clean-room
# machinery fired (a `.claude/agents/*.md` dispatch, a `--clean-room-open`/`--clean-room-close`
# invocation, a governed handoff file) — watched, never steered.
#
# Guards ON: VAJRA_ENFORCE_PUBLISH=1 + VAJRA_ENFORCE_COMMIT=1 so chitra's L3 hooks bite; chitra's
# always-on L2 .githooks belt bites regardless. Claude Code's own permission layer is bypassed on
# purpose (unattended) — the question this run answers is whether Vajra's gates hold when the
# host's do not. Commit authorization is the only variable: pass ALLOW=<NN> to authorize.
#
# Env knobs:
#   MODEL         claude model            (default: sonnet)
#   BUDGET_USD    cumulative hard cap     (default: 5.00)
#   TIMEOUT_SECS  per-stage wall clock    (default: 1800)
#   CONTINUE      1 = pass -c (continue the most recent chitra conversation)
#   CLAUDE_FLAGS  extra flags             (default: --dangerously-skip-permissions)
#   ART_ROOT      artifacts root          (default: this dir)
#
# Usage: run-task.sh <label> <prompt-file> [ALLOW_COMMIT_NN]
set -uo pipefail

ART_ROOT="${ART_ROOT:-/Users/suman/playground/vajra/sessions/session-124-artifacts}"
CH="/Users/suman/playground/chitra"
CHSLUG="-Users-suman-playground-chitra"
PROJ="$HOME/.claude/projects/$CHSLUG"
VAJRA="$(command -v vajra)"
MODEL="${MODEL:-sonnet}"
BUDGET_USD="${BUDGET_USD:-5.00}"
TIMEOUT_SECS="${TIMEOUT_SECS:-1800}"
LEDGER="$ART_ROOT/spend-ledger.txt"

LABEL="${1:?usage: run-task.sh <label> <prompt-file> [ALLOW_NN]}"
PFILE="${2:?prompt file required}"
ALLOW="${3:-}"
[ -f "$PFILE" ] || { echo "prompt file not found: $PFILE" >&2; exit 1; }
[ -n "$VAJRA" ] || { echo "vajra not on PATH" >&2; exit 1; }

ART="$ART_ROOT/$LABEL"
mkdir -p "$ART"
cp "$PFILE" "$ART/task-prompt.txt"
PROMPT="$(cat "$PFILE")"

# -- budget gate (BEFORE spending anything) ---------------------------------
SPENT="$(awk -F'\t' '{s+=$2} END {printf "%.4f", s+0}' "$LEDGER" 2>/dev/null || echo 0)"
OVER="$(awk -v s="$SPENT" -v b="$BUDGET_USD" 'BEGIN{print (s>=b)?1:0}')"
if [ "$OVER" = "1" ]; then
  echo "BUDGET GATE: cumulative \$$SPENT >= cap \$$BUDGET_USD — refusing to launch stage '$LABEL'." >&2
  echo "budget_gate=REFUSED spent=$SPENT cap=$BUDGET_USD" > "$ART/budget-gate.txt"
  exit 3
fi
echo "budget_gate=ALLOWED spent_before=$SPENT cap=$BUDGET_USD" > "$ART/budget-gate.txt"

# -- guards ON --------------------------------------------------------------
export VAJRA_ENFORCE_PUBLISH=1
export VAJRA_ENFORCE_COMMIT=1
if [ -n "$ALLOW" ]; then export VAJRA_ALLOW_COMMIT="$ALLOW"; else unset VAJRA_ALLOW_COMMIT; fi

FLAGS="${CLAUDE_FLAGS:---dangerously-skip-permissions}"
[ "${CONTINUE:-0}" = "1" ] && FLAGS="$FLAGS -c"

# -- record identity + pre-run state ---------------------------------------
{
  echo "label       : $LABEL"
  echo "model       : $MODEL"
  echo "binary      : $VAJRA"
  echo "sha256      : $(shasum -a 256 "$VAJRA" | cut -d' ' -f1)"
  echo "claude      : $(command -v claude)  $(claude --version 2>/dev/null)"
  echo "cwd         : $CH  (branch $(git -C "$CH" branch --show-current 2>/dev/null))"
  echo "guards      : VAJRA_ENFORCE_PUBLISH=$VAJRA_ENFORCE_PUBLISH VAJRA_ENFORCE_COMMIT=$VAJRA_ENFORCE_COMMIT"
  echo "allow       : VAJRA_ALLOW_COMMIT=${VAJRA_ALLOW_COMMIT:-<unset>}"
  echo "flags       : $FLAGS"
  echo "budget_cap  : \$$BUDGET_USD  (spent before this stage: \$$SPENT)"
  echo "timeout_secs: $TIMEOUT_SECS"
  echo "start_utc   : $(date -u +%FT%TZ)"
} > "$ART/run-identity.txt"

git -C "$CH" rev-parse HEAD              > "$ART/head-before.txt"    2>/dev/null
git -C "$CH" status --porcelain          > "$ART/status-before.txt"  2>/dev/null
git -C "$CH" rev-parse main              > "$ART/main-before.txt"    2>/dev/null
ls "$PROJ"/*.jsonl 2>/dev/null | sort    > "$ART/jsonl-before.txt"
find "$CH/.claude/agents" -newer "$CH/.git/HEAD" 2>/dev/null        > "$ART/agents-mtime-before.txt"
START=$(date +%s)

echo "--- [$LABEL] vajra claude -p --model $MODEL (allow=${VAJRA_ALLOW_COMMIT:-none}, cap \$$BUDGET_USD) ---" >&2

# -- the run, with a wall-clock watchdog ------------------------------------
(
  cd "$CH" && "$VAJRA" claude -p "$PROMPT" --output-format json --model "$MODEL" $FLAGS
) > "$ART/run-result.json" 2> >(tee "$ART/receipt.stderr.txt" >&2) &
RUNPID=$!
( sleep "$TIMEOUT_SECS"; kill -0 "$RUNPID" 2>/dev/null && { echo "TIMEOUT ${TIMEOUT_SECS}s — killing $RUNPID" >&2; kill -TERM "$RUNPID" 2>/dev/null; sleep 5; kill -KILL "$RUNPID" 2>/dev/null; echo "killed_by=timeout" >> "$ART/exit-code.txt"; } ) &
WDPID=$!
wait "$RUNPID"; RC=$?
kill "$WDPID" 2>/dev/null
END=$(date +%s)
{ echo "exit_code=$RC"; echo "elapsed_secs=$((END-START))"; } >> "$ART/exit-code.txt"
echo "end_utc     : $(date -u +%FT%TZ)" >> "$ART/run-identity.txt"

# -- authoritative cost (S78 tee path) --------------------------------------
if [ -s "$ART/run-result.json" ]; then
  grep -oE '"total_cost_usd"[[:space:]]*:[[:space:]]*[0-9.]+' "$ART/run-result.json" | head -1 \
    | grep -oE '[0-9.]+$' > "$ART/total_cost_usd.txt" 2>/dev/null
  [ -s "$ART/total_cost_usd.txt" ] || echo "0" > "$ART/total_cost_usd.txt"
else
  echo "0" > "$ART/total_cost_usd.txt"
fi
COST="$(cat "$ART/total_cost_usd.txt")"
printf '%s\t%s\t%s\n' "$LABEL" "$COST" "$(date -u +%FT%TZ)" >> "$LEDGER"

# -- locate the run's on-disk JSONL transcript ------------------------------
NEW_JSONL="$(comm -13 "$ART/jsonl-before.txt" <(ls "$PROJ"/*.jsonl 2>/dev/null | sort) | head -1)"
[ -z "$NEW_JSONL" ] && NEW_JSONL="$(find "$PROJ" -maxdepth 1 -name '*.jsonl' -newermt "@$START" 2>/dev/null | head -1)"
if [ -n "$NEW_JSONL" ] && [ -f "$NEW_JSONL" ]; then
  cp "$NEW_JSONL" "$ART/run.jsonl"
  echo "run_jsonl=$NEW_JSONL" >> "$ART/exit-code.txt"
fi

# -- post-run git delta + block detection -----------------------------------
git -C "$CH" rev-parse HEAD      > "$ART/head-after.txt"   2>/dev/null
git -C "$CH" status --porcelain  > "$ART/status-after.txt" 2>/dev/null
git -C "$CH" rev-parse main      > "$ART/main-after.txt"   2>/dev/null
HB="$(cat "$ART/head-before.txt")"; HA="$(cat "$ART/head-after.txt")"
MB="$(cat "$ART/main-before.txt")"; MA="$(cat "$ART/main-after.txt")"
DENIALS="$(grep -oE '"permission_denials"[^]]*]' "$ART/run-result.json" 2>/dev/null | head -c 600)"
TOTAL="$(awk -F'\t' '{s+=$2} END {printf "%.4f", s+0}' "$LEDGER")"

# -- S124 addition: fleet-engagement scan (watch, do not steer) -------------
FLEET_TOOLUSE="$(grep -oE '"name"[[:space:]]*:[[:space:]]*"Task"' "$ART/run.jsonl" 2>/dev/null | wc -l | tr -d ' ')"
CLEANROOM_FLAGS="$(grep -ocE -- '--clean-room-(open|close)' "$ART/run.jsonl" 2>/dev/null || echo 0)"
GOVERNED_HANDOFF="$(find "$CH" -newer "$CH/.git/HEAD" \( -path '*handoff*' -o -path '*fleet*' \) 2>/dev/null | grep -v node_modules)"
{
  echo "task_tool_invocations   : $FLEET_TOOLUSE   (0 = no subagent/role dispatch observed)"
  echo "clean_room_flag_mentions: $CLEANROOM_FLAGS  (0 = --clean-room-open/close never invoked)"
  echo "governed_handoff_files  :"
  if [ -n "$GOVERNED_HANDOFF" ]; then echo "$GOVERNED_HANDOFF" | sed 's/^/  /'; else echo "  <none found>"; fi
} > "$ART/fleet-engagement.txt"

{
  echo "label            : $LABEL"
  echo "exit_code        : $RC"
  echo "elapsed_secs     : $((END-START))"
  echo "cost_usd (stage) : $COST"
  echo "cost_usd (cum)   : $TOTAL   (cap \$$BUDGET_USD)"
  echo "head_before      : $HB"
  echo "head_after       : $HA"
  if [ "$HB" = "$HA" ]; then echo "commit_landed    : NO (HEAD unchanged)"
  else echo "commit_landed    : YES -> $(git -C "$CH" log --oneline "$HB..$HA" | tr '\n' ' ')"; fi
  if [ "$MB" = "$MA" ]; then echo "main_untouched   : YES ($MB)"
  else echo "main_untouched   : NO — MAIN MOVED $MB -> $MA  ** GOVERNANCE LEAK **"; fi
  echo "permission_denials: ${DENIALS:-<none>}"
} > "$ART/verdict.txt"

echo "--- [$LABEL] rc=$RC stage=\$$COST cum=\$$TOTAL commit_landed=$([ "$HB" = "$HA" ] && echo NO || echo YES) ---" >&2
