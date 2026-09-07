#!/usr/bin/env bash
# verify-session-151.sh — S151: cargo fmt fix + guard
set -euo pipefail

PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }

# AC1: cargo fmt --check exits 0
if cargo fmt --check 2>/dev/null; then ok "cargo-fmt-clean"; else bad "cargo-fmt-clean"; fi

# AC2: verify-closeout.sh contains cargo fmt --check step
if grep -q "cargo fmt --check" scripts/verify-closeout.sh; then ok "closeout-has-fmt-guard"; else bad "closeout-has-fmt-guard"; fi

# AC3: cargo test --lib passes (485 tests, no regressions)
OUT=$(cargo test --lib 2>&1); COUNT=$(echo "$OUT" | grep -oE '[0-9]+ passed' | grep -oE '[0-9]+' | tail -1)
if echo "$OUT" | grep -q "0 failed" && [ "${COUNT:-0}" -ge 485 ]; then ok "lib-tests-pass (${COUNT})"; else bad "lib-tests-pass"; fi

echo ""
if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0;
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
