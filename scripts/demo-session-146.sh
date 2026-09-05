#!/usr/bin/env bash
# demo-session-146.sh — live demo of S146 deliverables.
# Shows: (1) --sync-fleet propagates verify-closeout.sh; (2) PATH-first resolver in scaffold.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

BIN="$ROOT/target/release/vajra"
[ -x "$BIN" ] || { echo "BLOCK: build the binary first (cargo build --release)"; exit 1; }

echo "=== S146 Demo: close-gate propagation + PATH-first resolver ==="
echo ""

DIR=$(mktemp -d)
trap "rm -rf $DIR" EXIT

# DEMO 1: fresh init scaffolds the close-gate stamped + PATH-first
echo "--- D1: scaffold creates a stamped, PATH-first close-gate ---"
(cd "$DIR" && printf "demo-project\nfirst session\n2\n" | "$BIN" init 2>/dev/null)
GATE="$DIR/scripts/verify-closeout.sh"
echo "  gate exists:  $([ -f "$GATE" ] && echo YES || echo NO)"
echo "  stamp line:   $(grep 'vajra-render-sha' "$GATE" | head -1)"
echo "  resolver:     $(grep 'command -v vajra' "$GATE" | head -1 | xargs)"
echo ""

# DEMO 2: fresh init + --sync-fleet = UpToDate
echo "--- D2: --sync-fleet reports UpToDate right after init ---"
(cd "$DIR" && "$BIN" init --sync-fleet 2>&1) | grep -E "verify-closeout|already current"
echo ""

# DEMO 3: remove gate, --sync-fleet re-creates it
echo "--- D3: remove gate, --sync-fleet re-creates it ---"
rm "$GATE"
(cd "$DIR" && "$BIN" init --sync-fleet 2>&1) | grep -E "create.*verify-closeout|created"
echo "  gate exists after re-create: $([ -f "$GATE" ] && echo YES || echo NO)"
echo ""

# DEMO 4: edit gate, --sync-fleet detects Drifted
echo "--- D4: user-edited gate → Drifted (not silently overwritten) ---"
echo "# user edit" >> "$GATE"
(cd "$DIR" && "$BIN" init --sync-fleet 2>&1 || true) | grep -E "verify-closeout|drifted" | head -3
echo ""

echo "=== Demo complete ==="
