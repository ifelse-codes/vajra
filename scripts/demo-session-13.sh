#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

echo "=== Session 13 Demo — Installer / Release Path ==="
echo ""

echo "--- 1. Crate Metadata ---"
grep -E '^(name|version|description|license|repository|keywords|categories)' Cargo.toml
echo ""

echo "--- 2. cargo install (dry-run package) ---"
cargo package --allow-dirty 2>&1 | tail -3
echo ""

echo "--- 3. CI Workflow ---"
echo "File: .github/workflows/ci.yml"
grep -E '(name:|runs-on:|run:)' .github/workflows/ci.yml | head -10
echo ""

echo "--- 4. Release Workflow ---"
echo "File: .github/workflows/release.yml"
echo "Targets:"
grep 'target:' .github/workflows/release.yml
echo ""

echo "--- 5. Homebrew Formula ---"
echo "File: Formula/vajra.rb"
head -3 Formula/vajra.rb
echo ""

echo "--- 6. README Install Section ---"
sed -n '/^## Install/,/^## /p' README.md | head -15
echo ""

echo "--- 7. Full test suite ---"
cargo test 2>&1 | grep "^test result"
echo ""

echo "=== Demo Complete ==="
