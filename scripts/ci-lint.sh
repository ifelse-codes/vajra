#!/usr/bin/env bash
# The ONE lint command (S183, F101). CI (.github/workflows/ci.yml) and the close gate's
# `cargo-clippy-clean` check (scripts/verify-closeout.sh) both run this script, so the command
# cannot drift between them. Run it from the crate's root.
#
# It FAILS when the rustc actually running is not the version pinned in rust-toolchain.toml:
# a cargo outside rustup, or a RUSTUP_TOOLCHAIN override, silently ignores that file — and a
# different clippy is exactly how S182 closed green and then failed CI. A check that cannot
# evaluate (no file, no exact version, no rustc) FAILS too.
set -euo pipefail

want="$(grep -E '^[[:space:]]*channel[[:space:]]*=' rust-toolchain.toml 2>/dev/null | head -1 \
  | sed -E 's/^[^=]*=[[:space:]]*"?([^"[:space:]]*)"?.*$/\1/' || true)"
if [ -z "$want" ]; then
  echo "FAIL: rust-toolchain.toml missing, or it has no \`channel = \"X.Y.Z\"\` line — nothing pins the toolchain." >&2
  exit 1
fi
if ! [[ "$want" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "FAIL: rust-toolchain.toml channel is \"$want\" — pin an exact version (X.Y.Z); a moving channel lets CI's clippy differ from yours." >&2
  exit 1
fi

rustc_v="$(rustc -V 2>/dev/null || true)"
clippy_v="$(cargo clippy -V 2>/dev/null || true)"
echo "toolchain: ${rustc_v:-<no rustc>} · ${clippy_v:-<no clippy>} (pinned: $want)"
have="$(printf '%s' "$rustc_v" | awk '{print $2}')"
if [ "$have" != "$want" ]; then
  echo "FAIL: running rustc ${have:-<none>} but rust-toolchain.toml pins $want — this clippy is not CI's. Unset RUSTUP_TOOLCHAIN, or run \`rustup toolchain install\` here." >&2
  exit 1
fi

echo "+ cargo clippy --all-targets -- -D warnings"
exec cargo clippy --all-targets -- -D warnings
