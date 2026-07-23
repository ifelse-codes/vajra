#!/usr/bin/env bash
# S97 e2e-pipeline dogfood — capture harness (adapted from S92/S76).
#
# Instruments ONE headless `vajra claude -p` run over the chitra subject repo and
# preserves every raw surface. No Vajra src changes; no fixing bugs mid-run.
#
# Headless `-p` + `--output-format json` is required: only the headless result
# stream carries the authoritative `total_cost_usd` (S77/S78). With `json`, the
# entire stdout IS one result object -> saved verbatim as run-result.json.
#
# Usage:
#   sessions/session-97-artifacts/capture.sh -f path/to/prompt.txt
#   sessions/session-97-artifacts/capture.sh "the one real task prompt"
set -uo pipefail

ART="/Users/suman/playground/vajra/sessions/session-97-artifacts"
CH="/Users/suman/playground/chitra"
CHSLUG="-Users-suman-playground-chitra"
PROJ="$HOME/.claude/projects/$CHSLUG"
# Pin the CURRENT release binary (installed ~/.cargo/bin/vajra was rebuilt this session).
VAJRA="/Users/suman/playground/vajra/target/release/vajra"

# -- prompt --------------------------------------------------------------
if [ "${1:-}" = "-f" ]; then
  [ -f "${2:-}" ] || { echo "prompt file not found: ${2:-}" >&2; exit 1; }
  PROMPT="$(cat "$2")"
else
  PROMPT="${1:-}"
fi
[ -n "$PROMPT" ] || { echo "usage: capture.sh \"<task>\"  |  capture.sh -f <file>" >&2; exit 1; }

mkdir -p "$ART"
printf '%s\n' "$PROMPT" > "$ART/task-prompt.txt"

# -- record identity + pre-run state -------------------------------------
{
  echo "binary   : $VAJRA"
  echo "sha256   : $(shasum -a 256 "$VAJRA" | cut -d' ' -f1)"
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

echo "--- running headless: $VAJRA claude -p --output-format json (cwd=$CH) ---" >&2

# -- the run (governance + compression fire in chitra) --
# CLAUDE_FLAGS passes extra args through vajra -> claude. `--output-format json`
# makes stdout a single result object; we save it verbatim as run-result.json.
( cd "$CH" && "$VAJRA" claude -p "$PROMPT" --output-format json ${CLAUDE_FLAGS:-} ) \
    > >(tee "$ART/run-result.json") \
    2> >(tee "$ART/receipt.stderr.txt" >&2)
RC=$?
echo "exit_code=$RC" > "$ART/exit-code.txt"
echo "end : $(date -u +%FT%TZ)" >> "$ART/run-identity.txt"

# -- pull the authoritative cost out of run-result.json --
if [ -s "$ART/run-result.json" ]; then
  grep -oE '"total_cost_usd"[[:space:]]*:[[:space:]]*[0-9.]+' "$ART/run-result.json" | head -1 \
    > "$ART/total_cost_usd.txt" 2>/dev/null
  if [ -s "$ART/total_cost_usd.txt" ]; then
    echo "AUTHORITATIVE cost captured: $(cat "$ART/total_cost_usd.txt")" >&2
  else
    echo "(no total_cost_usd in run-result.json -- RECORD as finding)" > "$ART/total_cost_usd.txt"
    echo "NO total_cost_usd -- record as finding." >&2
  fi
else
  echo "(run-result.json empty -- run failed?)" > "$ART/total_cost_usd.txt"
fi

# -- locate the run's on-disk JSONL transcript too (for completeness) --
NEW_JSONL="$(find "$PROJ" -maxdepth 1 -name '*.jsonl' -newermt "@$START" 2>/dev/null | head -1)"
[ -z "$NEW_JSONL" ] && NEW_JSONL="$(comm -13 "$ART/jsonl-before.txt" <(ls "$PROJ"/*.jsonl 2>/dev/null | sort) | head -1)"
if [ -n "$NEW_JSONL" ] && [ -f "$NEW_JSONL" ]; then
  cp "$NEW_JSONL" "$ART/run.jsonl"
  echo "run_jsonl=$NEW_JSONL" >> "$ART/exit-code.txt"
fi

# -- post-run git delta in chitra (did any commit/branch gate bind?) --
git -C "$CH" rev-parse HEAD > "$ART/chitra-head-after.txt" 2>/dev/null
git -C "$CH" status --porcelain > "$ART/chitra-status-after.txt" 2>/dev/null
git -C "$CH" branch --show-current > "$ART/chitra-branch-after.txt" 2>/dev/null

echo "--- capture complete. artifacts in $ART ---" >&2
ls -la "$ART" >&2
