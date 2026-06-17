#!/usr/bin/env bash
# Auto-generate verify-session-NN.sh from template.
# Usage: scripts/init-session.sh <NN>

set -euo pipefail

NN="${1:-}"
if [ -z "$NN" ]; then
  echo "Usage: $0 <session-number>" >&2
  exit 1
fi

if ! [[ "$NN" =~ ^[0-9]+$ ]]; then
  echo "ERROR: session number must be an integer" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE="$ROOT/scripts/verify-session-template.sh"
TARGET="$ROOT/scripts/verify-session-${NN}.sh"

if [ ! -f "$TEMPLATE" ]; then
  echo "ERROR: template not found at $TEMPLATE" >&2
  exit 1
fi

if [ -f "$TARGET" ]; then
  echo "WARNING: $TARGET already exists. Overwrite? [y/N]"
  read -r reply
  case "$reply" in
    y|Y) : ;;
    *) echo "Aborted."; exit 0 ;;
  esac
fi

sed "s/SESSION=\"NN\"/SESSION=\"${NN}\"/" "$TEMPLATE" > "$TARGET"
chmod +x "$TARGET"
mkdir -p "$ROOT/.ai/verify/session-${NN}"

echo "Created: $TARGET"
echo "Artifact dir: $ROOT/.ai/verify/session-${NN}/"
