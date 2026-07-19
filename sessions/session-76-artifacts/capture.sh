#!/usr/bin/env bash
# S76 dogfood ride-along — capture harness.
#
# FOUNDER runs this (founder-led is load-bearing). It only instruments a headless
# `vajra claude -p` run in chitra and preserves every raw surface; the agent derives
# the numbers afterward. No src changes, no fixing bugs mid-run (S63 stance).
#
# Usage:
#   sessions/session-76-artifacts/capture.sh "the one real task prompt"
#   sessions/session-76-artifacts/capture.sh -f path/to/prompt.txt
#
# Headless (`-p`) is required: only headless CC emits the `type:"result"` line that
# carries the authoritative total_cost_usd (verified: 89 interactive JSONLs here = 0).
set -uo pipefail

ART="/Users/suman/playground/vajra/sessions/session-76-artifacts"
CH="/Users/suman/playground/chitra"
CHSLUG="-Users-suman-playground-chitra"
PROJ="$HOME/.claude/projects/$CHSLUG"
# Pin the CURRENT binary — the installed ~/.cargo/bin/vajra is stale (Jul 2, pre-5-stations).
VAJRA="/Users/suman/playground/vajra/target/release/vajra"

# ── prompt ────────────────────────────────────────────────────────────
if [ "${1:-}" = "-f" ]; then
  [ -f "${2:-}" ] || { echo "prompt file not found: ${2:-}" >&2; exit 1; }
  PROMPT="$(cat "$2")"
else
  PROMPT="${1:-}"
fi
[ -n "$PROMPT" ] || { echo "usage: capture.sh \"<task>\"  |  capture.sh -f <file>" >&2; exit 1; }

mkdir -p "$ART"
printf '%s\n' "$PROMPT" > "$ART/task-prompt.txt"

# ── record identity + pre-run state ───────────────────────────────────
{
  echo "binary   : $VAJRA"
  echo "sha256   : $(shasum -a 256 "$VAJRA" | cut -d' ' -f1)"
  echo "version  : $("$VAJRA" --version 2>/dev/null)"
  echo "claude   : $(command -v claude)  $(claude --version 2>/dev/null)"
  echo "cwd      : $CH  (branch $(git -C "$CH" branch --show-current 2>/dev/null))"
  echo "maturity : $(grep -E '^maturity:' "$CH/.ai/CONSTRAINTS.yaml" 2>/dev/null)"
  echo "flags    : ${CLAUDE_FLAGS:-<none>}"
  echo "start    : $(date -u +%FT%TZ)"
} > "$ART/run-identity.txt"
ls "$PROJ"/*.jsonl 2>/dev/null | sort > "$ART/jsonl-before.txt"
git -C "$CH" rev-parse HEAD > "$ART/chitra-head-before.txt" 2>/dev/null
git -C "$CH" status --porcelain > "$ART/chitra-status-before.txt" 2>/dev/null
START=$(date +%s)

echo "─── running headless: $VAJRA claude -p (cwd=$CH) ─────────────────" >&2

# ── the run (founder-issued prompt; governance + compression fire in chitra) ──
# CLAUDE_FLAGS passes extra args through vajra → claude (e.g. --permission-mode,
# --dangerously-skip-permissions). Recorded in run-identity.txt for the report.
( cd "$CH" && "$VAJRA" claude -p "$PROMPT" ${CLAUDE_FLAGS:-} ) \
    > >(tee "$ART/run.stdout.txt") \
    2> >(tee "$ART/receipt.stderr.txt" >&2)
RC=$?
echo "exit_code=$RC" > "$ART/exit-code.txt"
echo "end : $(date -u +%FT%TZ)" >> "$ART/run-identity.txt"

# ── locate the run's JSONL (created/modified after START, not in before-set) ──
NEW_JSONL="$(find "$PROJ" -maxdepth 1 -name '*.jsonl' -newermt "@$START" 2>/dev/null | head -1)"
if [ -z "$NEW_JSONL" ]; then
  # fallback: newest jsonl not present before the run
  NEW_JSONL="$(comm -13 "$ART/jsonl-before.txt" <(ls "$PROJ"/*.jsonl 2>/dev/null | sort) | head -1)"
fi

if [ -n "$NEW_JSONL" ] && [ -f "$NEW_JSONL" ]; then
  cp "$NEW_JSONL" "$ART/run.jsonl"
  echo "run_jsonl=$NEW_JSONL" >> "$ART/exit-code.txt"
  # authoritative cost line (headless only). Absence is itself a recorded finding.
  grep -E '"type"[[:space:]]*:[[:space:]]*"result"' "$ART/run.jsonl" > "$ART/total_cost_usd.txt" 2>/dev/null
  if [ -s "$ART/total_cost_usd.txt" ]; then
    echo "AUTHORITATIVE total_cost_usd line captured:" >&2
    grep -oE '"total_cost_usd"[[:space:]]*:[[:space:]]*[0-9.]+' "$ART/total_cost_usd.txt" | head -1 >&2
  else
    echo "NO type:result line — receipt will be a labeled [estimate]; RECORD as finding." >&2
    echo "(no type:result / total_cost_usd line in this run's JSONL)" > "$ART/total_cost_usd.txt"
  fi
else
  echo "WARNING: could not locate the run's JSONL under $PROJ" >&2
  echo "(run JSONL not located)" > "$ART/total_cost_usd.txt"
fi

# ── post-run git delta in chitra (did any commit/branch gate bind?) ──
git -C "$CH" rev-parse HEAD > "$ART/chitra-head-after.txt" 2>/dev/null
git -C "$CH" status --porcelain > "$ART/chitra-status-after.txt" 2>/dev/null

echo "─── capture complete. artifacts in $ART ───────────────────────────" >&2
ls -la "$ART" >&2
