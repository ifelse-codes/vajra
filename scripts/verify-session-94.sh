#!/usr/bin/env bash
# Session 94 — Close the nested-repo guard blindspot (S52, now load-bearing after S93).
#
# The guards resolve their governed project from CLAUDE_PROJECT_DIR (the scaffolded project root),
# falling back to the hook's own scaffold location. The blindspot: two guards derived git facts via
# `git -C "$ROOT"` / `cd "$ROOT" && git …`, which walk UP to the nearest .git — so a ROOT nested
# inside a DIFFERENT git repo (a subject tree checked out under Vajra during a dogfood) governed the
# WRONG repo (mis-derived session number / murmured the enclosing repo's changes). The fix pins git
# facts to the project's OWN git top-level and SURFACES the governed project on every advise/block.
#
# This session touches only shell (the three guards) + these verify/demo scripts. `cargo test`
# proves the Rust scaffold-drift tests (byte-identical `include_str!` propagation) stay green.
#
# Fixtures (all in throwaway dirs; no paid `vajra claude`, the S39 synthetic-payload pattern):
#   OUTER  = a git repo on session-94-outer, with a NESTED subject dir (plain dir, no own .git).
#   SUBJ   = OUTER/subject — the dogfood blindspot shape: governed by CLAUDE_PROJECT_DIR, but
#            `git -C SUBJ` walks up to OUTER (session-94).
#   STAND  = a STANDALONE subject: its OWN git repo on session-07 (the normal, non-nested shape) —
#            drives the zero-regression assertions.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="94"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

G_COMMIT="$ROOT/scripts/hook-commit-guard.sh"
G_MURMUR="$ROOT/scripts/hook-copilot-murmur.sh"
G_SESSION="$ROOT/scripts/hook-session-guard.sh"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-38s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-38s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- Rust + syntax gates -----------------------------------------------------------------------
# No Rust source changed this session; `cargo test` still runs to prove the byte-identical scaffold
# drift tests (init.rs) pass — i.e. `vajra init` inherits the hardened guards verbatim (AC5).
run_check "bash-n-commit-guard"  bash -n "$G_COMMIT"
run_check "bash-n-copilot-murmur" bash -n "$G_MURMUR"
run_check "bash-n-session-guard" bash -n "$G_SESSION"
run_check "cargo-test"           cargo test
run_check "cargo-build"          cargo build

# --- Build fixtures ----------------------------------------------------------------------------
FX=$(mktemp -d)
trap 'rm -rf "$FX"' EXIT
CONSTRAINTS_BODY='version: 3
maturity: L2
session:
  one_session_per_chat: true
copilot:
  on:
    - "src/* => docs/x.md | heuristics context"
'
mk_project() {  # <dir> <branch>   scaffold a guard-carrying project + init a git repo on <branch>
  local d="$1" br="$2"
  mkdir -p "$d/scripts" "$d/.ai"
  cp "$G_COMMIT" "$G_MURMUR" "$G_SESSION" "$d/scripts/"
  printf '%s' "$CONSTRAINTS_BODY" > "$d/.ai/CONSTRAINTS.yaml"
  printf '7\n' > "$d/.ai/SESSION"
  ( cd "$d" && git init -q && git symbolic-ref HEAD "refs/heads/$br" )
}

# OUTER (session-94) with a NESTED subject (no own .git). A change in the ENCLOSING repo's src/.
OUTER="$FX/outer"
( mkdir -p "$OUTER" && cd "$OUTER" && git init -q && git symbolic-ref HEAD refs/heads/session-94-outer )
mkdir -p "$OUTER/src"; echo enclosing > "$OUTER/src/enclosing.rs"
SUBJ="$OUTER/subject"
mkdir -p "$SUBJ/scripts" "$SUBJ/.ai"
cp "$G_COMMIT" "$G_MURMUR" "$G_SESSION" "$SUBJ/scripts/"
printf '%s' "$CONSTRAINTS_BODY" > "$SUBJ/.ai/CONSTRAINTS.yaml"
printf '7\n' > "$SUBJ/.ai/SESSION"

# STANDALONE subject: its OWN git repo on session-07, with a change in its OWN src/.
STAND="$FX/standalone"
mk_project "$STAND" "session-07-standalone"
mkdir -p "$STAND/src"; echo own > "$STAND/src/own.rs"

# Canonical (physical) paths — the guards surface `pwd -P` / git's top-level, which on macOS
# resolves the /var -> /private/var symlink; match the guard output against the same form.
SUBJ_REAL=$(cd "$SUBJ" && pwd -P)
OUTER_REAL=$(cd "$OUTER" && pwd -P)
STAND_REAL=$(cd "$STAND" && pwd -P)

# --- helpers (drive the guards with synthetic payloads; capture rc + combined output) ----------
cg() {  # <marker> <enforce> <root>   → sets CG_RC, CG_OUT
  set +e
  CG_OUT=$(echo '{"tool_input":{"command":"git commit -m x"}}' \
    | VAJRA_ALLOW_COMMIT="$1" VAJRA_ENFORCE_COMMIT="$2" CLAUDE_PROJECT_DIR="$3" \
        bash "$3/scripts/hook-commit-guard.sh" 2>&1)
  CG_RC=$?; set -e
}
sg() {  # <root> <sid> <cmd>   → sets SG_RC, SG_OUT
  set +e
  SG_OUT=$(printf '{"session_id":"%s","tool_input":{"command":"%s"}}' "$2" "$3" \
    | CLAUDE_PROJECT_DIR="$1" bash "$1/scripts/hook-session-guard.sh" 2>&1)
  SG_RC=$?; set -e
}
mur() {  # <root> <statedir>   → sets MUR_OUT
  set +e
  MUR_OUT=$(echo '{"session_id":"vs94"}' \
    | CLAUDE_PROJECT_DIR="$1" VAJRA_COPILOT_STATE_DIR="$2" \
        bash "$1/scripts/hook-copilot-murmur.sh" 2>&1)
  set -e
}

# ==============================================================================================
# AC1 — commit-guard governs the intended project when NESTED (no enclosing-session bleed).
# ==============================================================================================
chk_cg_nested_blocks() {                     # nested, no marker → still fail-closed (rc 2)
  cg "" 1 "$SUBJ"; echo "rc=$CG_RC"; echo "$CG_OUT"
  [ "$CG_RC" -eq 2 ]
}
chk_cg_nested_no_enclosing_leak() {          # the fix: block message must NOT adopt session 94
  cg "" 1 "$SUBJ"; echo "rc=$CG_RC"; echo "$CG_OUT"
  grep -q "VAJRA_ALLOW_COMMIT=NN" <<<"$CG_OUT" || return 1
  grep -q "VAJRA_ALLOW_COMMIT=94" <<<"$CG_OUT" && return 1   # enclosing session must not leak
  return 0
}
chk_cg_nested_names_project() {              # AC2: surfaces the governed subject + flags nesting
  cg "" 1 "$SUBJ"; echo "$CG_OUT"
  grep -q "Governing project $SUBJ_REAL" <<<"$CG_OUT" || return 1
  grep -q "nested inside git repo $OUTER_REAL" <<<"$CG_OUT" || return 1
  return 0
}
run_check "cg-nested-blocks-no-marker"    chk_cg_nested_blocks
run_check "cg-nested-no-enclosing-leak"   chk_cg_nested_no_enclosing_leak
run_check "cg-nested-names-project"       chk_cg_nested_names_project

# ==============================================================================================
# AC4 — non-nested (own git) behavior UNCHANGED + the governed project surfaced (AC2).
# ==============================================================================================
chk_cg_standalone_allow() {                  # correct marker → allow, names project
  cg "07" "" "$STAND"; echo "rc=$CG_RC"; echo "$CG_OUT"
  [ "$CG_RC" -eq 0 ] || return 1
  grep -q "Governing project $STAND_REAL" <<<"$CG_OUT" || return 1
  return 0
}
chk_cg_standalone_block_wrong() {            # wrong marker → block, binds to THIS repo's session 07
  cg "99" "" "$STAND"; echo "rc=$CG_RC"; echo "$CG_OUT"
  [ "$CG_RC" -eq 2 ] || return 1
  grep -q "VAJRA_ALLOW_COMMIT=07" <<<"$CG_OUT" || return 1
  return 0
}
chk_cg_standalone_inline_blocked() {         # S69 regression: inline self-grant still blocked
  set +e
  local out rc
  out=$(echo '{"tool_input":{"command":"VAJRA_ALLOW_COMMIT=07 git commit -m x"}}' \
    | CLAUDE_PROJECT_DIR="$STAND" bash "$STAND/scripts/hook-commit-guard.sh" 2>&1); rc=$?
  set -e
  echo "rc=$rc"; echo "$out"
  [ "$rc" -eq 2 ] && grep -q "INLINE" <<<"$out"
}
chk_cg_standalone_status_passes() {          # non-commit git verb still passes untouched
  set +e
  local rc
  echo '{"tool_input":{"command":"git status"}}' \
    | CLAUDE_PROJECT_DIR="$STAND" bash "$STAND/scripts/hook-commit-guard.sh" >/dev/null 2>&1; rc=$?
  set -e
  [ "$rc" -eq 0 ]
}
run_check "cg-standalone-allow-correct"   chk_cg_standalone_allow
run_check "cg-standalone-block-wrong"     chk_cg_standalone_block_wrong
run_check "cg-standalone-inline-blocked"  chk_cg_standalone_inline_blocked
run_check "cg-standalone-status-passes"   chk_cg_standalone_status_passes

# ==============================================================================================
# AC3 — session-guard owner record + session-number pinned to the governed project (no bleed).
# ==============================================================================================
chk_sg_nested_block_names_project() {        # chat owns S6 in the SUBJECT; checkout S7 → block + name
  printf '6\tvs94\n' > "$SUBJ/.ai/.session-owner"
  rm -rf "$OUTER/.ai" 2>/dev/null || true
  sg "$SUBJ" "vs94" "git checkout -b session-7-x"; echo "rc=$SG_RC"; echo "$SG_OUT"
  [ "$SG_RC" -eq 2 ] || return 1
  grep -q "Governing project $SUBJ_REAL" <<<"$SG_OUT" || return 1
  grep -q "nested inside git repo $OUTER_REAL" <<<"$SG_OUT" || return 1
  return 0
}
chk_sg_owner_pinned_to_subject() {           # fresh chat claims ownership INTO the subject only
  rm -f "$SUBJ/.ai/.session-owner"
  rm -rf "$OUTER/.ai" 2>/dev/null || true
  sg "$SUBJ" "freshchat" "git checkout -b session-7-x"; echo "rc=$SG_RC"; echo "$SG_OUT"
  [ "$SG_RC" -eq 0 ] || return 1
  [ -f "$SUBJ/.ai/.session-owner" ] || return 1
  grep -qE '^7[[:space:]]' "$SUBJ/.ai/.session-owner" || return 1
  [ ! -e "$OUTER/.ai/.session-owner" ] || return 1     # never written into the enclosing repo
  return 0
}
chk_sg_standalone_still_blocks() {           # zero-regression: non-nested boundary still enforced
  printf '6\tc1\n' > "$STAND/.ai/.session-owner"
  sg "$STAND" "c1" "git checkout -b session-7-x"; echo "rc=$SG_RC"; echo "$SG_OUT"
  [ "$SG_RC" -eq 2 ] && grep -q "Governing project $STAND_REAL" <<<"$SG_OUT"
}
run_check "sg-nested-block-names-project"  chk_sg_nested_block_names_project
run_check "sg-owner-pinned-to-subject"     chk_sg_owner_pinned_to_subject
run_check "sg-standalone-still-blocks"     chk_sg_standalone_still_blocks

# ==============================================================================================
# AC1/AC2 — copilot-murmur reads THIS project's working tree only (quiet when nested, no own git).
# ==============================================================================================
chk_murmur_nested_quiet() {                  # nested → no own git → must NOT murmur enclosing src/
  mur "$SUBJ" "$FX/ms-nested"; echo "[out:$MUR_OUT]"
  [ -z "$MUR_OUT" ]
}
chk_murmur_standalone_murmurs() {            # own repo change still murmurs (zero-regression)
  mur "$STAND" "$FX/ms-stand"; echo "$MUR_OUT"
  grep -q "murmur" <<<"$MUR_OUT" && grep -q "src/" <<<"$MUR_OUT"
}
run_check "murmur-nested-stays-quiet"     chk_murmur_nested_quiet
run_check "murmur-standalone-murmurs"     chk_murmur_standalone_murmurs

# ==============================================================================================
# AC5 — `vajra init` inherits the hardened guards byte-identical (the include_str! one-source).
# ==============================================================================================
SCRATCH="$FX/scaffold"
( mkdir -p "$SCRATCH" && cd "$SCRATCH" && git init -q )
printf 'demo-proj\nbuild it\n\n' | ( cd "$SCRATCH" && "$ROOT/target/debug/vajra" init ) >/dev/null 2>&1 || true
run_check "e2e-commit-guard-byte-identical"  cmp -s "$SCRATCH/.ai/hooks/hook-commit-guard.sh" "$G_COMMIT"
run_check "e2e-murmur-byte-identical"        cmp -s "$SCRATCH/.ai/hooks/hook-copilot-murmur.sh" "$G_MURMUR"
run_check "e2e-session-guard-byte-identical" cmp -s "$SCRATCH/.ai/hooks/hook-session-guard.sh" "$G_SESSION"
run_check "e2e-guards-wired" bash -c \
  'grep -q "hook-commit-guard.sh" "'"$SCRATCH"'/.claude/settings.json" && grep -q "hook-session-guard.sh" "'"$SCRATCH"'/.claude/settings.json"'

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-38s %s\n' "STEP" "RESULT"
printf '%-38s %s\n' "--------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
