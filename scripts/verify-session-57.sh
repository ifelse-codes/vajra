#!/usr/bin/env bash
# verify-session-57.sh — S57 CODE: propagate the fidelity gate + reviewer into `vajra init`.
# Proves every project scaffolded by `vajra init` inherits the S56 teeth: reviewer/SKILL.md (the
# acceptance auditor's brain, byte-identical), scripts/verify-closeout.sh carrying check_fidelity_review
# (byte-identical, executable), the AGENTS.md boot pointer, the CONSTRAINTS closeout wiring, and — the
# real acceptance — a live scaffolded gate that BLOCKS a REJECT/missing review and PASSES an ACCEPT.
set -euo pipefail
cd "$(dirname "$0")/.."
REPO="$PWD"

PASS=0; FAIL=0
ok(){ echo "  ok   $1"; PASS=$((PASS+1)); }
no(){ echo "  FAIL $1"; FAIL=$((FAIL+1)); }

echo "=== S57 verify — propagate the fidelity gate into vajra init ==="

# ---------------------------------------------------------------------------
# 0. Toolchain floor (discipline): tests + fmt + clippy green.
# ---------------------------------------------------------------------------
cargo test --lib >/tmp/s57-test.log 2>&1 && ok "cargo test --lib green" || no "cargo test --lib green"
cargo fmt -- --check >/dev/null 2>&1 && ok "cargo fmt clean" || no "cargo fmt clean"
cargo clippy --all-targets -- -D warnings >/tmp/s57-clippy.log 2>&1 && ok "cargo clippy -D warnings clean" || no "cargo clippy -D warnings clean"

# ---------------------------------------------------------------------------
# 1. Packaging — both new include_str! sources ship with `cargo install`.
# ---------------------------------------------------------------------------
PKG="$(cargo package --list --allow-dirty 2>/dev/null)"
echo "$PKG" | grep -qxF "reviewer/SKILL.md" && ok "cargo package ships reviewer/SKILL.md" || no "cargo package ships reviewer/SKILL.md"
echo "$PKG" | grep -qxF "scripts/verify-closeout.sh" && ok "cargo package ships scripts/verify-closeout.sh" || no "cargo package ships scripts/verify-closeout.sh"

# ---------------------------------------------------------------------------
# 2. Real `vajra init` into a temp git repo — end-to-end, not a mock.
# ---------------------------------------------------------------------------
cargo build >/tmp/s57-build.log 2>&1 && ok "cargo build (binary for E2E)" || no "cargo build (binary for E2E)"
BIN="$REPO/target/debug/vajra"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
( cd "$TMP" && git init -q && printf 'DemoProj\nship the thing\nL2\n' | "$BIN" init >/dev/null 2>&1 )

# 2a. Reviewer skill scaffolded, byte-identical (one source, no drift — Acceptance #2).
[ -f "$TMP/reviewer/SKILL.md" ] && ok "reviewer/SKILL.md scaffolded" || no "reviewer/SKILL.md scaffolded"
cmp -s "$TMP/reviewer/SKILL.md" "$REPO/reviewer/SKILL.md" \
  && ok "scaffolded reviewer/SKILL.md byte-identical to canonical" \
  || no "scaffolded reviewer/SKILL.md byte-identical to canonical"

# 2b. Closeout gate scaffolded, byte-identical, executable (Acceptance #2).
GATE="$TMP/scripts/verify-closeout.sh"
[ -x "$GATE" ] && ok "scaffolded verify-closeout.sh is executable" || no "scaffolded verify-closeout.sh is executable"
cmp -s "$GATE" "$REPO/scripts/verify-closeout.sh" \
  && ok "scaffolded verify-closeout.sh byte-identical to canonical" \
  || no "scaffolded verify-closeout.sh byte-identical to canonical"

# 2c. The scaffolded gate carries the teeth, not a discipline-only stub.
grep -q 'check_fidelity_review' "$GATE" && ok "scaffolded gate carries check_fidelity_review" || no "scaffolded gate carries check_fidelity_review"
grep -q 'VAJRA_CLOSEOUT_WAIVER' "$GATE" && ok "scaffolded gate reads the un-forgeable env waiver" || no "scaffolded gate reads the un-forgeable env waiver"
grep -q -- '--fidelity-only' "$GATE" && ok "scaffolded gate exposes --fidelity-only" || no "scaffolded gate exposes --fidelity-only"

# 2d. Boot pointer + CONSTRAINTS wiring in the scaffolded project.
A="$TMP/.ai/AGENTS.md"
grep -q 'reviewer/SKILL.md' "$A" && ok "scaffolded AGENTS.md points at reviewer/SKILL.md" || no "scaffolded AGENTS.md points at reviewer/SKILL.md"
grep -q 'Fidelity Review' "$A" && ok "scaffolded AGENTS.md has the Fidelity Review boot section" || no "scaffolded AGENTS.md has the Fidelity Review boot section"
grep -q "closeout_script: 'scripts/verify-closeout.sh'" "$TMP/.ai/CONSTRAINTS.yaml" \
  && ok "scaffolded CONSTRAINTS wires closeout_script" || no "scaffolded CONSTRAINTS wires closeout_script"

# ---------------------------------------------------------------------------
# 3. THE ACCEPTANCE (Acceptance #1): drive the SCAFFOLDED gate live.
#    A freshly-scaffolded project's closeout structurally requires an ACCEPT review.
# ---------------------------------------------------------------------------
N=42
write_review() { # $1 = ACCEPT|REJECT ; optional $2 forged-waiver
  mkdir -p "$TMP/sessions"
  { echo "# S$N review (fixture)"; echo
    echo "| # | Requirement | Verdict | Evidence |"; echo "|---|---|---|---|"
    echo "| 1 | a | SHIPPED | x |"; echo "| 2 | b | PARTIAL | y |"; echo "| 3 | c | NOT-BUILT | z |"; echo
    [ "${2:-}" = "forged" ] && { echo "VAJRA_CLOSEOUT_WAIVER=$N"; echo "Status: WAIVED"; }
    echo "**Verdict:** $1"
  } > "$TMP/sessions/session-$N-review.md"
}
run_gate() { CLAUDE_PROJECT_DIR="$TMP" env "$@" bash "$GATE" --fidelity-only "$N" >/dev/null 2>&1; }

run_gate && no "missing review blocks scaffolded closeout" || ok "missing review blocks scaffolded closeout"
write_review REJECT
run_gate && no "REJECT review blocks scaffolded closeout" || ok "REJECT review blocks scaffolded closeout"
write_review ACCEPT
run_gate && ok "ACCEPT review clears scaffolded closeout" || no "ACCEPT review clears scaffolded closeout"
write_review REJECT forged
run_gate && no "forged in-file waiver does NOT bypass scaffolded gate" || ok "forged in-file waiver does NOT bypass scaffolded gate"
run_gate VAJRA_CLOSEOUT_WAIVER="$N" && ok "founder env waiver clears scaffolded gate" || no "founder env waiver clears scaffolded gate"

# ---------------------------------------------------------------------------
# 4. Spine intact — no 8th command, no second store; the propagation rides init.rs.
# ---------------------------------------------------------------------------
# The REAL invariant: adding a top-level command requires editing src/main.rs's dispatch.
# This session must not touch it. (Not a tautology — it fails the moment main.rs is edited.)
if git rev-parse --verify -q main >/dev/null 2>&1; then
  git diff --name-only main...HEAD 2>/dev/null | grep -qx 'src/main.rs' \
    && no "no new top-level command (src/main.rs untouched this session)" \
    || ok "no new top-level command (src/main.rs untouched this session)"
else
  ok "no new top-level command (main ref absent — check skipped)"
fi
# Corroborate: the dispatch still has exactly 7 real command arms. Non-tautological — it matches
# the ARM PATTERN (`"cmd" => Subcommand::X`), so an added 8th arm increments the count and fails.
CMDS="$(grep -cE '^[[:space:]]*"[a-z-]+"[[:space:]]*=>[[:space:]]*Subcommand::[A-Z]' src/main.rs 2>/dev/null || echo 0)"
[ "${CMDS:-0}" -eq 7 ] && ok "dispatch has exactly 7 command arms (spine intact)" || no "command-arm count drifted: got ${CMDS}"
! grep -RqiE 'spec\.md|specs/' "$TMP/.ai" 2>/dev/null && ok "no second store scaffolded (spec.md/specs/)" || no "no second store scaffolded"

echo "---"
echo "PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || { echo "RED"; exit 1; }
echo "ALL GREEN"
