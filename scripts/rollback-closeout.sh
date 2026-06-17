#!/usr/bin/env bash
# Rollback closeout changes if verify-closeout.sh fails mid-process.
# Restores .ai/ files from git stash.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if git stash list | grep -q "factory-session-closeout"; then
  echo "Restoring .ai/ from stash..."
  git stash pop stash^{/factory-session-closeout} 2>/dev/null || {
    echo "ERROR: Could not restore stash. Manual intervention required." >&2
    exit 1
  }
  echo "Rollback complete. .ai/ files restored."
else
  echo "No closeout stash found. Nothing to rollback."
fi
