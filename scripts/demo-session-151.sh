#!/usr/bin/env bash
# demo-session-151.sh — S151: show cargo fmt fix + guard
set -euo pipefail

echo "=== S151 Demo: cargo fmt fix + guard ==="
echo ""
echo "1. cargo fmt --check exits 0 (formatting clean):"
cargo fmt --check && echo "   OK"
echo ""
echo "2. verify-closeout.sh contains the cargo fmt guard:"
grep "cargo-fmt-clean\|cargo fmt --check" scripts/verify-closeout.sh | head -5
echo ""
echo "3. lib tests still pass:"
cargo test --lib 2>&1 | tail -3
