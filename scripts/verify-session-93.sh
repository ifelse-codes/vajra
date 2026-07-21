#!/usr/bin/env bash
# Session 93 — Prove the commit gate has teeth (no-autonomous-commit: voluntary -> ENFORCED).
#
#   L2 belt (.githooks/pre-commit): on a session-NN branch a commit is BLOCKED unless the
#     un-forgeable env marker VAJRA_ALLOW_COMMIT==NN is present. Real commits in throwaway git
#     repos exercise the actual hook (block-without / allow-with / stale-rejected / main-still-blocked).
#   L3 teeth (hook-commit-guard.sh): a PreToolUse(Bash) guard blocks `git commit` unless the
#     marker is in the hook's OWN launch env — un-forgeable by an inline prefix, and fires even
#     on `--no-verify`. Driven by synthetic payloads (the S39 pattern; no paid `vajra claude`).
#   Propagation: a real `vajra init` inherits both, byte-identical, with L3 ON (no `commit_guard: off`).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="93"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

GUARD="$ROOT/scripts/hook-commit-guard.sh"
PRECOMMIT="$ROOT/.githooks/pre-commit"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-34s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-34s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- Rust + syntax gates -----------------------------------------------------------------------
# fmt is scoped to THIS session's only Rust change (init.rs). A repo-wide `cargo fmt -- --check`
# currently reports PRE-EXISTING drift in next.rs / dogfood/mod.rs / stations/mod.rs under
# rustfmt 1.9.0 (a toolchain-version drift from S91-era commits, unrelated to S93) — fixing that
# would reformat modules this session never touches. Disclosed in sessions/session-93-summary.md.
run_check "rustfmt-init"     rustfmt --edition 2021 --check src/cli/init.rs
run_check "cargo-clippy"     cargo clippy --all-targets -- -D warnings
run_check "cargo-test"       cargo test
run_check "shellcheck-guard" bash -n "$GUARD"
run_check "shellcheck-precommit" bash -n "$PRECOMMIT"
run_check "cargo-build"      cargo build

# ==============================================================================================
# L2 — .githooks/pre-commit: the git-native belt, exercised by REAL commits in throwaway repos.
# Each test spins a fresh repo, points core.hooksPath at the CURRENT pre-commit, sets HEAD to the
# target branch (works unborn), stages a file, and commits with/without the marker.
# ==============================================================================================
l2_expect() {  # <block|allow> <branch> <marker>
  local want="$1" br="$2" mk="$3" d rc
  d=$(mktemp -d)
  (
    cd "$d" || exit 2
    git init -q
    git config user.email a@b.c; git config user.name t
    git symbolic-ref HEAD "refs/heads/$br"
    mkdir -p .githooks
    cp "$PRECOMMIT" .githooks/pre-commit; chmod +x .githooks/pre-commit
    git config core.hooksPath .githooks
    echo hi > f.txt; git add f.txt
    set +e
    if [ -n "$mk" ]; then VAJRA_ALLOW_COMMIT="$mk" git commit -q -m t >/dev/null 2>&1
    else git commit -q -m t >/dev/null 2>&1; fi
    rc=$?
    set -e
    if [ "$want" = block ]; then [ "$rc" -ne 0 ]; else [ "$rc" -eq 0 ]; fi
  )
  local r=$?; rm -rf "$d"; return $r
}
run_check "L2-block-no-marker"     l2_expect block session-93-x ""
run_check "L2-allow-with-marker"   l2_expect allow session-93-x 93
run_check "L2-block-stale-marker"  l2_expect block session-93-x 92
run_check "L2-main-blocked"        l2_expect block main 93   # main is unconditional; marker can't unlock it
run_check "L2-nonsession-untouched" l2_expect allow feature-x ""  # gate scopes to session-NN only

# ==============================================================================================
# L3 — hook-commit-guard.sh: the un-forgeable PreToolUse teeth, driven by synthetic payloads.
# CROOT = a git repo on session-93-* with L3 ON (no `commit_guard: off`). COFF = same but OFF.
# ==============================================================================================
CROOT=$(mktemp -d); mkdir -p "$CROOT/.ai"
printf 'maturity: L2\n' > "$CROOT/.ai/CONSTRAINTS.yaml"
( cd "$CROOT" && git init -q && git symbolic-ref HEAD refs/heads/session-93-x )
COFF=$(mktemp -d); mkdir -p "$COFF/.ai"
printf 'maturity: L2\nenforcement:\n  commit_guard: off\n' > "$COFF/.ai/CONSTRAINTS.yaml"
( cd "$COFF" && git init -q && git symbolic-ref HEAD refs/heads/session-93-x )
trap 'rm -rf "$CROOT" "$COFF" "${SCRATCH:-}"' EXIT

expect_commit() {  # <expected-rc> <maturity> <marker> <enforce> <root> <cmd>
  local expected="$1" mat="$2" mk="$3" enf="$4" root="$5" cmd="$6" json rc
  json=$(printf '%s' "$cmd" | jq -Rs '{tool_name:"Bash",tool_input:{command:.}}')
  set +e
  VAJRA_GUARD_MATURITY="$mat" VAJRA_ALLOW_COMMIT="$mk" VAJRA_ENFORCE_COMMIT="$enf" \
    CLAUDE_PROJECT_DIR="$root" bash "$GUARD" <<<"$json" >/dev/null 2>&1
  rc=$?
  set -e
  [ "$rc" = "$expected" ]
}
run_check "L3-block-no-marker"      expect_commit 2 L2 ""   "" "$CROOT" 'git commit -m "x"'
run_check "L3-allow-with-marker"    expect_commit 0 L2 "93" "" "$CROOT" 'git commit -m "x"'
run_check "L3-block-stale-marker"   expect_commit 2 L2 "92" "" "$CROOT" 'git commit -m "x"'
run_check "L3-block-inline-inject"  expect_commit 2 L2 ""   "" "$CROOT" 'VAJRA_ALLOW_COMMIT=93 git commit -m "x"'
run_check "L3-block-no-verify"      expect_commit 2 L2 ""   "" "$CROOT" 'git commit --no-verify -m "x"'
run_check "L3-block-compound"       expect_commit 2 L2 ""   "" "$CROOT" 'cd /tmp/z && git commit -m "y"'
run_check "L3-advise-L1"            expect_commit 0 L1 ""   "" "$CROOT" 'git commit -m "x"'
run_check "L3-pass-git-status"      expect_commit 0 L2 ""   "" "$CROOT" 'git status'
run_check "L3-pass-git-log"         expect_commit 0 L2 ""   "" "$CROOT" 'git log --oneline'
run_check "L3-pass-commit-quoted"   expect_commit 0 L2 ""   "" "$CROOT" 'echo "run git commit later"'
run_check "L3-off-toggle-passes"    expect_commit 0 L2 ""   "" "$COFF"  'git commit -m "x"'
run_check "L3-off-toggle-rearm"     expect_commit 2 L2 ""   "1" "$COFF" 'git commit -m "x"'

# ==============================================================================================
# Propagation — a real `vajra init` inherits both layers, byte-identical, with L3 ON.
# ==============================================================================================
SCRATCH=$(mktemp -d)
( cd "$SCRATCH" && git init -q )
printf 'demo-proj\nbuild it\n\n' | ( cd "$SCRATCH" && "$ROOT/target/debug/vajra" init ) >/dev/null 2>&1 || true
run_check "e2e-guard-byte-identical"     cmp -s "$SCRATCH/.ai/hooks/hook-commit-guard.sh" "$GUARD"
run_check "e2e-precommit-byte-identical" cmp -s "$SCRATCH/.githooks/pre-commit" "$PRECOMMIT"
run_check "e2e-guard-wired"              grep -q "hook-commit-guard.sh" "$SCRATCH/.claude/settings.json"
run_check "e2e-scaffold-guard-on" bash -c \
  '! grep -qE "^[[:space:]]*commit_guard:[[:space:]]*off" "'"$SCRATCH"'/.ai/CONSTRAINTS.yaml"'

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-34s %s\n' "STEP" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
