#!/usr/bin/env bash
# Session 43 — Gap 2: scaffold the git-level belt into `vajra init` (ROADMAP #17b).
#
# The gap (S40 finding #2): the vajra repo runs a tracked git belt — .githooks/pre-commit
# (blocks main-commits / >3 staged / .ai/ drift) + .githooks/pre-push (blocks push to
# main|master), activated by `git config core.hooksPath .githooks`. Scaffolded projects got
# only the L3 .claude/ hooks, so a raw `echo N > .ai/SESSION` write or a direct commit/push
# bypassed the Bash guards entirely.
#
# The fix: `vajra init` now emits .githooks/pre-commit + pre-push (byte-identical to the
# canonical .githooks/*, via include_str! — one source, no drift) and sets core.hooksPath
# to .githooks in a git repo (idempotent: an existing hooksPath is left as-is; a non-git dir
# degrades to a documented no-op). This is an independent L2 layer beneath the L3 hooks.
#
# Proof strategy: a real `vajra init` into a temp GIT repo → assert both hooks byte-identical
# + executable + core.hooksPath=.githooks; then drive the scaffolded pre-commit to actually
# BLOCK a main-commit / >3-staged / .ai/-drift and the scaffolded pre-push to BLOCK a push to
# main, and confirm the clean cases PASS. A real `vajra init` into a temp NON-git dir → assert
# it degrades gracefully (files emitted, exit 0, no config). Plus the Rust + packaging gates.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="43"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

CANON_PRECOMMIT="$ROOT/.githooks/pre-commit"
CANON_PREPUSH="$ROOT/.githooks/pre-push"
VAJRA="$ROOT/target/debug/vajra"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-44s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-44s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- Rust gates (init.rs scaffold-drift unit tests assert both scaffolded git hooks stay
#     byte-identical to the canonical .githooks/* + core.hooksPath is set / respected) ---
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings
run_check "cargo-test"    cargo test
run_check "cargo-build"   cargo build
run_check "shellcheck-pre-commit"  bash -n "$CANON_PRECOMMIT"
run_check "shellcheck-pre-push"    bash -n "$CANON_PREPUSH"

# --- Packaging: both git hooks must ship in the crate (include_str! from an excluded dir;
#     un-excluded per-file in Cargo.toml) or `cargo install` can't compile. ---
pkg_has_githooks() {
  local list; list=$(cargo package --list --allow-dirty 2>/dev/null)
  grep -qx '.githooks/pre-commit' <<<"$list" && grep -qx '.githooks/pre-push' <<<"$list"
}
run_check "package-ships-both-githooks"  pkg_has_githooks

# =====================================================================================
# E2E: a real `vajra init` into a temp GIT repo scaffolds the belt + activates it.
# =====================================================================================
GREPO=$(mktemp -d)
NONGIT=$(mktemp -d)
trap 'rm -rf "$GREPO" "$NONGIT"' EXIT

( cd "$GREPO" && git init -q && git symbolic-ref HEAD refs/heads/main )
printf 'demo-proj\nbuild it\n\n' | ( cd "$GREPO" && "$VAJRA" init ) >/dev/null 2>&1 || true

run_check "e2e-pre-commit-byte-identical"  cmp -s "$GREPO/.githooks/pre-commit" "$CANON_PRECOMMIT"
run_check "e2e-pre-push-byte-identical"    cmp -s "$GREPO/.githooks/pre-push"   "$CANON_PREPUSH"
run_check "e2e-pre-commit-executable"      test -x "$GREPO/.githooks/pre-commit"
run_check "e2e-pre-push-executable"        test -x "$GREPO/.githooks/pre-push"

hookspath_is_githooks() { [ "$(git -C "$GREPO" config --local --get core.hooksPath)" = ".githooks" ]; }
run_check "e2e-core-hookspath-set"  hookspath_is_githooks

# --- Drive the SCAFFOLDED pre-commit to actually BLOCK, invoked in-repo as git would.
#     expect_precommit <expected-rc>: run the hook against the repo's current git state. ---
expect_precommit() {
  local expected="$1" rc
  set +e
  ( cd "$GREPO" && bash .githooks/pre-commit ) >/dev/null 2>&1
  rc=$?
  set -e
  [ "$rc" = "$expected" ]
}

# 1) On main → BLOCK (exit 1), regardless of staging.
run_check "block-precommit-on-main"  expect_precommit 1

# Move off main to an unborn session branch (no commit needed) for the remaining checks.
( cd "$GREPO" && git symbolic-ref HEAD refs/heads/session-01-demo )

# 2) >3 files staged → BLOCK (exit 1). Stage 4 files; .ai/ state still consistent.
( cd "$GREPO" && git add .githooks/pre-commit .githooks/pre-push .ai/SESSION .ai/STATE.md )
run_check "block-precommit-over-3-staged"  expect_precommit 1

# 3) .ai/ drift → BLOCK (exit 1). One file staged, but SESSION(07) != SESSION-BOOT Number(01).
( cd "$GREPO" && git reset -q && printf '07\n' > .ai/SESSION && git add .ai/SESSION )
run_check "block-precommit-ai-drift"  expect_precommit 1

# 4) Clean case → PASS (exit 0). Off main, <=3 staged, .ai/ state consistent again.
( cd "$GREPO" && git reset -q && printf '01\n' > .ai/SESSION && git add .ai/KNOWLEDGE.md )
run_check "pass-precommit-clean"  expect_precommit 0

# --- Drive the SCAFFOLDED pre-push (reads git's stdin: <lref> <lsha> <rref> <rsha>). ---
expect_prepush() {
  local expected="$1" refline="$2" rc
  set +e
  printf '%s\n' "$refline" | ( cd "$GREPO" && bash .githooks/pre-push ) >/dev/null 2>&1
  rc=$?
  set -e
  [ "$rc" = "$expected" ]
}
run_check "block-prepush-to-main"   expect_prepush 1 "refs/heads/main a refs/heads/main b"
run_check "pass-prepush-feature"    expect_prepush 0 "refs/heads/session-01 a refs/heads/session-01 b"

# =====================================================================================
# E2E: a real `vajra init` into a temp NON-git dir degrades gracefully (no crash).
# =====================================================================================
INIT_RC=0
printf 'demo-proj\nbuild it\n\n' | ( cd "$NONGIT" && "$VAJRA" init ) >/dev/null 2>&1 || INIT_RC=$?
run_check "nongit-init-exits-zero"        test "$INIT_RC" = "0"
run_check "nongit-emits-pre-commit"       test -f "$NONGIT/.githooks/pre-commit"
run_check "nongit-emits-pre-push"         test -f "$NONGIT/.githooks/pre-push"
run_check "nongit-no-git-created"         test ! -d "$NONGIT/.git"

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-44s %s\n' "STEP" "RESULT"
printf '%-44s %s\n' "--------------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
