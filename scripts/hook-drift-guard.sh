#!/usr/bin/env bash
# Drift guard: asserts .ai/ agrees on the current session.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

QUIET=0
[ "${1:-}" = "--quiet" ] && QUIET=1

banner() {
  echo ""
  echo "⚠ .ai/ DRIFT — STOP, fix before any work"
  echo "  $1"
  echo "  (.ai/SESSION is the single source of truth.)"
  echo ""
}

if [ ! -f .ai/SESSION ]; then banner ".ai/SESSION missing"; exit 1; fi
N="$(tr -d ' \t\n\r' < .ai/SESSION)"
if ! [[ "$N" =~ ^[0-9]+$ ]]; then banner ".ai/SESSION not an integer: '$N'"; exit 1; fi
Ni="$((10#$N))"

drift=0; detail=""

if [ -f .ai/SESSION-BOOT.md ]; then
  boot="$(grep -m1 -E '\*\*Number:\*\*' .ai/SESSION-BOOT.md | grep -oE '[0-9]+' | head -1)"
  if [ -z "$boot" ]; then
    drift=1; detail="SESSION-BOOT.md has no **Number:** integer"
  elif [ "$((10#$boot))" -ne "$Ni" ]; then
    drift=1; detail="SESSION-BOOT Number=$boot != .ai/SESSION=$Ni"
  fi
else
  drift=1; detail=".ai/SESSION-BOOT.md missing"
fi

if [ "$drift" -eq 0 ] && [ -f .ai/TASK.md ]; then
  pad="$(printf '%02d' "$Ni")"
  if ! grep -qiE "Session 0*${Ni}\b" .ai/TASK.md \
     && ! grep -qiE "Session ${pad}\b" .ai/TASK.md \
     && ! grep -qiE "between sessions" .ai/TASK.md; then
    drift=1; detail="TASK.md references neither Session $Ni nor 'between sessions'"
  fi
fi

if [ "$drift" -ne 0 ]; then banner "$detail"; exit 1; fi

[ "$QUIET" -eq 0 ] && echo "[drift-guard] OK — .ai/ consistent at session $Ni"
exit 0
