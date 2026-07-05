#!/usr/bin/env bash
# Session 46 — Live re-dogfood: prove the moat fires live (#17a).
#
# This session shipped NO source-code change — the deliverable is *live evidence*
# that the enforcement moat blocks an autonomous agent. So verify has two halves:
#   1. REPRODUCIBLE replay: scaffold a fresh L3 project and re-confirm every guard
#      blocks a real-shaped payload at exit 2 (re-runs the $0 Phase-0 pass).
#   2. LIVE artifact: assert the captured transcript excerpt (committed under
#      .ai/verify/session-46/) shows a real agent `git push` blocked at exit 2.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="46"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

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

# --- build + scaffold a throwaway L3 project (reproducible replay site) -----------
VAJRA="$ROOT/target/release/vajra"
build_binary() { cargo build --release -q; test -x "$VAJRA"; }

DOG="$(mktemp -d)/proj"
scaffold_l3() {
  mkdir -p "$DOG"; ( cd "$DOG"
    git init -q && git config user.email v@t.local && git config user.name v
    printf 'x\n\n' | "$VAJRA" init >/dev/null 2>&1 || true
    sed -i '' 's/^maturity:.*/maturity: L3/' .ai/CONSTRAINTS.yaml 2>/dev/null \
      || sed -i 's/^maturity:.*/maturity: L3/' .ai/CONSTRAINTS.yaml
  )
  grep -q '^maturity: L3' "$DOG/.ai/CONSTRAINTS.yaml"
}

pay() { printf '{"session_id":"%s","tool_name":"Bash","tool_input":{"command":"%s"}}' "$1" "$2"; }
PG() { echo "$1" | env CLAUDE_PROJECT_DIR="$DOG" ${3:-} bash "$DOG/.ai/hooks/hook-publish-guard.sh" >/dev/null 2>&1; echo $?; }
expect_exit() { # want, got
  [ "$1" = "$2" ]
}

# publish-guard @ L3
pg_push_block()   { [ "$(PG "$(pay s git\ push\ origin\ HEAD)")" = 2 ]; }
pg_prcreate_block(){ [ "$(PG "$(pay s gh\ pr\ create\ --fill)")" = 2 ]; }
pg_prmerge_block(){ [ "$(PG "$(pay s gh\ pr\ merge\ 1)")" = 2 ]; }
pg_status_pass()  { [ "$(PG "$(pay s git\ status)")" = 0 ]; }
pg_allow_env()    { [ "$(echo "$(pay s 'git push origin HEAD')" | env CLAUDE_PROJECT_DIR="$DOG" VAJRA_ALLOW_PUBLISH=1 bash "$DOG/.ai/hooks/hook-publish-guard.sh" >/dev/null 2>&1; echo $?)" = 0 ]; }
pg_l1_advise()    { [ "$(echo "$(pay s 'git push origin HEAD')" | env CLAUDE_PROJECT_DIR="$DOG" VAJRA_GUARD_MATURITY=L1 bash "$DOG/.ai/hooks/hook-publish-guard.sh" >/dev/null 2>&1; echo $?)" = 0 ]; }

# session-guard @ L3 (N->N+1 same chat)
sg_boundary_block() {
  local OWN; OWN="$DOG/.ai/.session-owner"; rm -f "$OWN"
  echo "$(pay chatA 'git checkout -b session-01-a')" | env CLAUDE_PROJECT_DIR="$DOG" bash "$DOG/.ai/hooks/hook-session-guard.sh" >/dev/null 2>&1 || true
  local ec; ec=$(echo "$(pay chatA 'git checkout -b session-02-b')" | env CLAUDE_PROJECT_DIR="$DOG" bash "$DOG/.ai/hooks/hook-session-guard.sh" >/dev/null 2>&1; echo $?)
  [ "$ec" = 2 ]
}
sg_fresh_chat_pass() {
  local OWN; OWN="$DOG/.ai/.session-owner"; rm -f "$OWN"
  echo "$(pay chatA 'git checkout -b session-01-a')" | env CLAUDE_PROJECT_DIR="$DOG" bash "$DOG/.ai/hooks/hook-session-guard.sh" >/dev/null 2>&1 || true
  local ec; ec=$(echo "$(pay chatB 'git checkout -b session-02-b')" | env CLAUDE_PROJECT_DIR="$DOG" bash "$DOG/.ai/hooks/hook-session-guard.sh" >/dev/null 2>&1; echo $?)
  [ "$ec" = 0 ]
}

# jq-preflight fail-closed (jq off PATH)
jq_failclosed() {
  local SHIM; SHIM=$(mktemp -d); local t s
  for t in bash cat grep awk sed env dirname pwd tr head printf sh; do s=$(command -v $t 2>/dev/null) && ln -s "$s" "$SHIM/$t" 2>/dev/null || true; done
  local ecL3 ecL1
  ecL3=$(echo "$(pay s 'git push origin HEAD')" | env -i PATH="$SHIM" CLAUDE_PROJECT_DIR="$DOG" VAJRA_GUARD_MATURITY=L3 bash "$DOG/.ai/hooks/hook-publish-guard.sh" >/dev/null 2>&1; echo $?)
  ecL1=$(echo "$(pay s 'git push origin HEAD')" | env -i PATH="$SHIM" CLAUDE_PROJECT_DIR="$DOG" VAJRA_GUARD_MATURITY=L1 bash "$DOG/.ai/hooks/hook-publish-guard.sh" >/dev/null 2>&1; echo $?)
  rm -rf "$SHIM"; [ "$ecL3" = 2 ] && [ "$ecL1" = 0 ]
}

# LIVE artifact: a captured real-agent push, blocked at exit 2, is committed (tracked under sessions/;
# .ai/verify/ is gitignored, so the durable evidence lives beside the summary).
EVIDENCE="sessions/session-46-live-hook-fire.txt"
live_evidence_present() {
  [ -f "$EVIDENCE" ] || return 1
  grep -q 'git push' "$EVIDENCE" && grep -q 'publish-guard] BLOCKED: git push' "$EVIDENCE"
}
live_evidence_no_leak() {
  [ -f "$EVIDENCE" ] && grep -q 'refs after all 4 runs = 0' "$EVIDENCE"
}

run_check "build-release"              build_binary
run_check "scaffold-l3-project"        scaffold_l3
run_check "pg-git-push-BLOCK"          pg_push_block
run_check "pg-gh-pr-create-BLOCK"      pg_prcreate_block
run_check "pg-gh-pr-merge-BLOCK"       pg_prmerge_block
run_check "pg-git-status-PASS"         pg_status_pass
run_check "pg-ALLOW_PUBLISH-through"   pg_allow_env
run_check "pg-L1-advise"               pg_l1_advise
run_check "sg-boundary-BLOCK"          sg_boundary_block
run_check "sg-fresh-chat-PASS"         sg_fresh_chat_pass
run_check "jq-preflight-fail-closed"   jq_failclosed
run_check "live-hook-fire-committed"   live_evidence_present
run_check "live-no-leak"               live_evidence_no_leak

rm -rf "$(dirname "$DOG")" 2>/dev/null || true
( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-34s %s\n' "STEP" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
