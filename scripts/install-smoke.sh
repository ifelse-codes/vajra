#!/usr/bin/env bash
# scripts/install-smoke.sh — the installability instrument (S106).
#
# The falsifiable answer to "can a stranger install and run vajra?" — the exact S105 meta-check
# blind spot: `vajra next --stations` read 7/8 on S101 while every install path was broken, because
# NO instrument measured installability. This script does. It installs `vajra` from a CLEAN source
# checkout into a throwaway root, then in a SEPARATE fresh directory (no prior .ai/) runs the exact
# first two commands a stranger runs — `vajra init` then `vajra next` — asserting each exits 0 inside
# a time budget. ANY failed step exits non-zero. No claim survives that a stranger could not re-derive.
#
# Default proof (`path`): `cargo install --path <checkout>` — hermetic, offline, tests THIS tree (the
# code under review), which is byte-identical to what a `git clone` hands a stranger. The README
# documents the no-clone one-liner `cargo install --git <repo>` (same crate `vajractl`, binary `vajra`);
# set VAJRA_SMOKE_SOURCE=git to exercise that public remote path instead.
#
# The no-Rust proof (`release`, S107): a stranger with NO Rust toolchain downloads the published
# prebuilt tarball for THIS host from the GitHub release, verifies its sha256, extracts `vajra`, and
# runs the same stranger flow — NOT a claim, the exact download command the README prints, re-derived
# live. A missing asset, a sha mismatch, or a non-zero `vajra` step is a FAIL, never a skipped green.
#
# Usage:
#   scripts/install-smoke.sh                              # install from this checkout (default)
#   VAJRA_SMOKE_SOURCE=git scripts/install-smoke.sh       # install from the public git remote
#   VAJRA_SMOKE_SOURCE=release scripts/install-smoke.sh   # download+run the published prebuilt binary
#   VAJRA_SMOKE_RELEASE_TAG=v0.1.0 VAJRA_SMOKE_SOURCE=release scripts/install-smoke.sh  # pin a tag
#   VAJRA_SMOKE_BUDGET_SECS=300 scripts/install-smoke.sh
set -euo pipefail

REPO_ROOT="${VAJRA_SMOKE_PATH:-${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}}"
SOURCE="${VAJRA_SMOKE_SOURCE:-path}"                        # path | git | release
GIT_URL="${VAJRA_SMOKE_GIT_URL:-https://github.com/ifelse-codes/vajra}"
WEB_URL="${VAJRA_SMOKE_WEB_URL:-https://github.com/ifelse-codes/vajra}"
RELEASE_TAG="${VAJRA_SMOKE_RELEASE_TAG:-latest}"           # latest | v0.1.0 | ... (release mode)
BUDGET="${VAJRA_SMOKE_BUDGET_SECS:-420}"                    # bounds hangs, not slow truth (cf. gate 600s)
START=$SECONDS

INSTALL_ROOT="$(mktemp -d)"
PROJECT_DIR="$(mktemp -d)"
DL_DIR="$(mktemp -d)"
STEP_LOG="$(mktemp)"
cleanup() { rm -rf "$INSTALL_ROOT" "$PROJECT_DIR" "$DL_DIR" "$STEP_LOG"; }
trap cleanup EXIT

# host_target — the release target triple for THIS host, ONLY if release.yml builds it; else non-zero.
host_target() {
  local os arch
  case "$(uname -s)" in
    Darwin) os="apple-darwin" ;;
    Linux)  os="unknown-linux-gnu" ;;
    *) return 1 ;;
  esac
  case "$(uname -m)" in
    arm64|aarch64) arch="aarch64" ;;
    x86_64|amd64)  arch="x86_64" ;;
    *) return 1 ;;
  esac
  case "${arch}-${os}" in
    aarch64-apple-darwin|x86_64-apple-darwin|x86_64-unknown-linux-gnu) echo "${arch}-${os}" ;;
    *) return 1 ;;  # e.g. aarch64-unknown-linux-gnu is not a built target
  esac
}
dl_asset() { curl -fsSL -o "$3/$2" "$1/$2"; }             # base-url, name, dest-dir
sha_verify() {                                            # dir, asset — check against its .sha256
  ( cd "$1"
    if command -v shasum >/dev/null 2>&1; then shasum -a 256 -c "${2}.sha256"
    else sha256sum -c "${2}.sha256"; fi )
}

pass=0; fail=0
# step "<name>" cmd... — runs cmd, records PASS/FAIL, emits a `smoke:<name>` marker, never aborts the
# run (the `if` guard keeps `set -e` from short-circuiting so every step reports).
step() {
  local name="$1"; shift
  printf '  %-22s ' "$name"
  if "$@" >"$STEP_LOG" 2>&1; then
    echo "PASS  [smoke:${name}]"; pass=$((pass + 1))
  else
    echo "FAIL  [smoke:${name}]"; fail=$((fail + 1))
    echo "    --- last output (tail) ---"
    sed 's/^/    /' "$STEP_LOG" | tail -20
  fi
}

echo "== vajra install smoke =="
echo "  source:       $SOURCE"
echo "  install root: $INSTALL_ROOT"
echo "  fresh dir:    $PROJECT_DIR"
echo "  budget:       ${BUDGET}s"
echo ""

# 1) INSTALL — get a runnable `vajra` the way a stranger would, per SOURCE.
if [ "$SOURCE" = "release" ]; then
  # The no-Rust path: download the published prebuilt tarball for THIS host, verify its sha, extract.
  TARGET="$(host_target || true)"
  ASSET="vajra-${TARGET}.tar.gz"
  if [ "$RELEASE_TAG" = "latest" ]; then BASE="$WEB_URL/releases/latest/download"
  else BASE="$WEB_URL/releases/download/$RELEASE_TAG"; fi
  echo "  target:       ${TARGET:-<unsupported host — no built tarball>}"
  echo "  release tag:  $RELEASE_TAG"
  echo "  asset:        ${BASE}/${ASSET}"
  echo ""
  step "detect-host-target" test -n "$TARGET"
  step "download-tarball"   dl_asset "$BASE" "$ASSET" "$DL_DIR"
  step "download-sha256"    dl_asset "$BASE" "$ASSET.sha256" "$DL_DIR"
  step "verify-sha256"      sha_verify "$DL_DIR" "$ASSET"
  mkdir -p "$INSTALL_ROOT/bin"
  step "extract-binary"     tar xzf "$DL_DIR/$ASSET" -C "$INSTALL_ROOT/bin"
elif [ "$SOURCE" = "git" ]; then
  step "install-from-git"  cargo install --git "$GIT_URL" --root "$INSTALL_ROOT" --force --quiet
else
  step "install-from-path" cargo install --path "$REPO_ROOT" --root "$INSTALL_ROOT" --force --quiet
fi
VJ="$INSTALL_ROOT/bin/vajra"

# 2) The install produced a runnable binary named `vajra`.
step "binary-installed" test -x "$VJ"

# 3) STRANGER FLOW — a brand-new project dir, no prior .ai/: the first two commands from the README.
run_init() { ( cd "$PROJECT_DIR" && "$VJ" init ); }
run_next() { ( cd "$PROJECT_DIR" && "$VJ" next ); }
step "git-init-project" git -C "$PROJECT_DIR" init -q
step "vajra-init"       run_init
step "scaffold-created" test -f "$PROJECT_DIR/.ai/SESSION"
step "vajra-next"       run_next

# 4) The whole path finished inside the time budget (a hang is a failure, not a slow pass).
ELAPSED=$((SECONDS - START))
step "within-budget" test "$ELAPSED" -le "$BUDGET"

echo ""
echo "  elapsed: ${ELAPSED}s / ${BUDGET}s"
case "$SOURCE" in
  release) WHENCE="a downloaded prebuilt binary (no Rust toolchain)" ;;
  git)     WHENCE="'cargo install --git' from the public remote" ;;
  *)       WHENCE="'cargo install' from a clean checkout" ;;
esac
if [ "$fail" -eq 0 ]; then
  echo "SMOKE PASS ($pass checks, 0 fail) — a stranger can install and run vajra via $WHENCE."
  exit 0
else
  echo "SMOKE FAIL ($pass pass, $fail fail) — the install path is BROKEN; do not claim installable."
  exit 1
fi
