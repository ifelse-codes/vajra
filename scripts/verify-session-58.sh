#!/usr/bin/env bash
# verify-session-58.sh — S58 CODE: structural verdict-authorship independence.
# Proves the input-attestation teeth: an ACCEPT verdict must carry a **Review-Inputs-SHA:**
# that matches the canonical hash of the cold inputs (contract prompt + delivery diff),
# recomputed from the repo by the gate. A missing / forged / stale ACCEPT now FAILS; the
# founder waiver still clears; every S56 --fidelity-only behavior still holds; and the
# scaffolded verify-closeout.sh inherits it byte-identically (S57 include_str!, no src change).
set -euo pipefail
cd "$(dirname "$0")/.."
REPO="$PWD"

PASS=0; FAIL=0
ok(){ echo "  ok   $1"; PASS=$((PASS+1)); }
no(){ echo "  FAIL $1"; FAIL=$((FAIL+1)); }

echo "=== S58 verify — verdict-authorship attestation ==="

# ---------------------------------------------------------------------------
# 0. Toolchain floor (discipline). S58 touches no src/, but keep the gate honest.
# ---------------------------------------------------------------------------
cargo test --lib >/tmp/s58-test.log 2>&1 && ok "cargo test --lib green" || no "cargo test --lib green"
cargo fmt -- --check >/dev/null 2>&1 && ok "cargo fmt clean" || no "cargo fmt clean"
cargo clippy --all-targets -- -D warnings >/tmp/s58-clippy.log 2>&1 && ok "cargo clippy -D warnings clean" || no "cargo clippy -D warnings clean"

# ---------------------------------------------------------------------------
# 1. --inputs-sha on the real repo: deterministic + a 64-hex sha256.
# ---------------------------------------------------------------------------
A="$(bash scripts/verify-closeout.sh --inputs-sha 58 2>/dev/null)"
B="$(bash scripts/verify-closeout.sh --inputs-sha 58 2>/dev/null)"
{ [ -n "$A" ] && [ "$A" = "$B" ]; } && ok "--inputs-sha deterministic (run twice, equal)" || no "--inputs-sha deterministic"
[[ "$A" =~ ^[0-9a-f]{64}$ ]] && ok "--inputs-sha prints a 64-hex sha256" || no "--inputs-sha prints a 64-hex sha256"

# ---------------------------------------------------------------------------
# 2. THE ACCEPTANCE — a purpose-built temp git repo mirroring the real flow:
#    the contract prompt lives on main (prior closeout); the delivery is on the branch.
# ---------------------------------------------------------------------------
GATE_SRC="$REPO/scripts/verify-closeout.sh"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
(
  cd "$T"
  git init -q; git config user.email t@t.dev; git config user.name tester
  git checkout -q -b main
  mkdir -p prompts scripts sessions .ai
  printf '# S58 contract\nGoal: attest the cold inputs.\n' > prompts/58-task-x.md
  cp "$GATE_SRC" scripts/verify-closeout.sh; chmod +x scripts/verify-closeout.sh
  git add -A; git commit -qm "main: contract + gate"
  git checkout -q -b session-58-x
  printf 'echo the real delivery\n' > scripts/thing.sh          # the session's delivery
  git add -A; git commit -qm "S58 delivery"
)
GATE="$T/scripts/verify-closeout.sh"

# Helpers: run the gate against the temp repo (ROOT via CLAUDE_PROJECT_DIR).
sha_now(){ CLAUDE_PROJECT_DIR="$T" bash "$GATE" --inputs-sha 58 2>/dev/null; }
attest(){ CLAUDE_PROJECT_DIR="$T" env "$@" bash "$GATE" --attest-only 58 >/dev/null 2>&1; }
fidelity(){ CLAUDE_PROJECT_DIR="$T" env "$@" bash "$GATE" --fidelity-only 58 >/dev/null 2>&1; }
write_review(){ # $1 verdict ; $2 sha-line-value ('' = omit) ; $3 forged-in-file-waiver?
  { echo "# S58 review (fixture)"; echo
    echo "| # | Requirement | Verdict | Evidence |"; echo "|---|---|---|---|"
    echo "| 1 | a | SHIPPED | x |"; echo "| 2 | b | PARTIAL | y |"; echo "| 3 | c | NOT-BUILT | z |"; echo
    [ -n "${2:-}" ] && echo "**Review-Inputs-SHA:** $2"
    [ "${3:-}" = "forged" ] && { echo "VAJRA_CLOSEOUT_WAIVER=58"; echo "Status: WAIVED"; }
    echo "**Verdict:** $1"
  } > "$T/sessions/session-58-review.md"
}

GOOD="$(sha_now)"
[[ "$GOOD" =~ ^[0-9a-f]{64}$ ]] && ok "canonical hash computable in temp repo" || no "canonical hash computable in temp repo"

# 2a. ACCEPT + correct attestation → PASS.
write_review ACCEPT "$GOOD"
attest && ok "ACCEPT with matching attestation PASSES" || no "ACCEPT with matching attestation PASSES"

# 2b. ACCEPT + forged attestation → FAIL.
write_review ACCEPT "0000000000000000000000000000000000000000000000000000000000000000"
attest && no "ACCEPT with forged attestation must FAIL" || ok "ACCEPT with forged attestation FAILS"

# 2c. ACCEPT with NO attestation line → FAIL.
write_review ACCEPT ""
attest && no "ACCEPT with no attestation must FAIL" || ok "ACCEPT with no attestation FAILS"

# 2d. Founder env waiver clears a forged ACCEPT.
write_review ACCEPT "deadbeef"
attest VAJRA_CLOSEOUT_WAIVER=58 && ok "founder env waiver clears the attestation gate" || no "founder env waiver clears the attestation gate"

# 2e. Orthogonality: a REJECT review is N/A for attestation (owned by the fidelity check).
write_review REJECT ""
attest && ok "REJECT review is N/A for attestation (no double-jeopardy)" || no "REJECT review N/A for attestation"

# 2f. FRESHNESS: a correct ACCEPT that predates a later delivery change no longer matches.
write_review ACCEPT "$GOOD"
attest && ok "ACCEPT matches before delivery changes" || no "ACCEPT matches before delivery changes"
( cd "$T" && printf 'echo CHANGED after review\n' >> scripts/thing.sh && git add -A && git commit -qm "post-review change" )
attest && no "stale ACCEPT after a delivery change must FAIL" || ok "stale ACCEPT after delivery change FAILS (freshness)"

# ---------------------------------------------------------------------------
# 2g. S56's whole --fidelity-only matrix STILL holds (unchanged behavior).
# ---------------------------------------------------------------------------
rm -f "$T/sessions/session-58-review.md"
fidelity && no "S56: missing review still blocks --fidelity-only" || ok "S56: missing review still blocks --fidelity-only"
write_review REJECT ""
fidelity && no "S56: REJECT still blocks --fidelity-only" || ok "S56: REJECT still blocks --fidelity-only"
write_review ACCEPT ""     # ACCEPT with NO sha: --fidelity-only must still PASS (shape-only, S56 semantics)
fidelity && ok "S56: --fidelity-only unchanged — ACCEPT (no sha) still passes shape check" || no "S56: --fidelity-only regressed"

# ---------------------------------------------------------------------------
# 3. Propagation is FREE (S57 include_str!): a real `vajra init` scaffolds the
#    attestation-bearing gate byte-identically. No src/ change this session.
# ---------------------------------------------------------------------------
cargo build >/tmp/s58-build.log 2>&1 && ok "cargo build (binary for E2E)" || no "cargo build (binary for E2E)"
BIN="$REPO/target/debug/vajra"
S="$(mktemp -d)"; trap 'rm -rf "$T" "$S"' EXIT
( cd "$S" && git init -q && printf 'DemoProj\nship it\nL2\n' | "$BIN" init >/dev/null 2>&1 )
SG="$S/scripts/verify-closeout.sh"
cmp -s "$SG" "$REPO/scripts/verify-closeout.sh" && ok "scaffolded gate byte-identical to canonical (drift-free)" || no "scaffolded gate byte-identical"
grep -q 'check_review_attestation' "$SG" && ok "scaffolded gate carries check_review_attestation" || no "scaffolded gate carries check_review_attestation"
grep -q 'Review-Inputs-SHA' "$SG" && ok "scaffolded gate references Review-Inputs-SHA" || no "scaffolded gate references Review-Inputs-SHA"
grep -q -- '--inputs-sha' "$SG" && ok "scaffolded gate exposes --inputs-sha" || no "scaffolded gate exposes --inputs-sha"

# ---------------------------------------------------------------------------
# 4. Spine intact — no src/ change, no 8th command, no second store.
# ---------------------------------------------------------------------------
if git rev-parse --verify -q main >/dev/null 2>&1; then
  git diff --name-only main...HEAD 2>/dev/null | grep -qE '^src/' \
    && no "no src/ change this session (attestation rides the script, S57 include_str!)" \
    || ok "no src/ change this session (attestation rides the script, S57 include_str!)"
else
  ok "no src/ change (main ref absent — check skipped)"
fi
CMDS="$(grep -cE '^[[:space:]]*"[a-z-]+"[[:space:]]*=>[[:space:]]*Subcommand::[A-Z]' src/main.rs 2>/dev/null || echo 0)"
[ "${CMDS:-0}" -eq 7 ] && ok "dispatch still has exactly 7 command arms (spine intact)" || no "command-arm count drifted: got ${CMDS}"
! grep -RqiE 'spec\.md|specs/' "$S/.ai" 2>/dev/null && ok "no second store scaffolded (spec.md/specs/)" || no "no second store scaffolded"

echo "---"
echo "PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || { echo "RED"; exit 1; }
echo "ALL GREEN"
