#!/usr/bin/env bash
# verify-session-59.sh — S59 CODE: the attested-verdict delta ledger.
# Proves a DERIVED, hash-chained view over sessions/*-review.md + git: --ledger builds the
# real S54–S58 ledger (flags S54 REJECT + S58 attested ACCEPT), the chain is deterministic,
# --ledger-verify passes on a clean tree, and a hand-edit of a PAST verdict is DETECTED by
# the chain (real run, not a mock). No src/ change — the ledger rides verify-closeout.sh,
# which vajra init embeds byte-identically (S57 include_str!). No 8th command, no new store.
set -euo pipefail
cd "$(dirname "$0")/.."
REPO="$PWD"
GATE="scripts/verify-closeout.sh"

PASS=0; FAIL=0
ok(){ echo "  ok   $1"; PASS=$((PASS+1)); }
no(){ echo "  FAIL $1"; FAIL=$((FAIL+1)); }

echo "=== S59 verify — attested-verdict delta ledger ==="

# ---------------------------------------------------------------------------
# 0. Toolchain floor (discipline). S59 touches no src/, but keep the gate honest.
# ---------------------------------------------------------------------------
cargo test --lib >/tmp/s59-test.log 2>&1 && ok "cargo test --lib green" || no "cargo test --lib green"
cargo fmt -- --check >/dev/null 2>&1 && ok "cargo fmt clean" || no "cargo fmt clean"
cargo clippy --all-targets -- -D warnings >/tmp/s59-clippy.log 2>&1 && ok "cargo clippy -D warnings clean" || no "cargo clippy -D warnings clean"

# ---------------------------------------------------------------------------
# 1. --ledger builds the real derived view over committed history.
# ---------------------------------------------------------------------------
L="$(bash "$GATE" --ledger 2>/dev/null)"
echo "$L" | grep -qE '^S54 +REJECT +no ' && ok "ledger records S54 = REJECT (un-attested)" || no "ledger S54 REJECT row"
echo "$L" | grep -qE '^S58 +ACCEPT +yes ' && ok "ledger records S58 = ACCEPT + attested=yes" || no "ledger S58 attested ACCEPT row"
echo "$L" | grep -qE '^S55 +NONE ' && ok "ledger honestly records S55 = NONE (pre-canonical review)" || no "ledger S55 NONE row"
HEAD="$(echo "$L" | sed -n 's/^chain head : //p' | head -1)"
[[ "$HEAD" =~ ^[0-9a-f]{64}$ ]] && ok "chain head is a 64-hex sha256" || no "chain head is a 64-hex sha256"

# ---------------------------------------------------------------------------
# 2. The chain is deterministic (same repo → same head, every run).
# ---------------------------------------------------------------------------
H2="$(bash "$GATE" --ledger 2>/dev/null | sed -n 's/^chain head : //p' | head -1)"
{ [ -n "$HEAD" ] && [ "$HEAD" = "$H2" ]; } && ok "ledger head deterministic (run twice, equal)" || no "ledger head deterministic"

# ---------------------------------------------------------------------------
# 3. --ledger-verify PASSES on a clean tree (worktree == committed HEAD).
# ---------------------------------------------------------------------------
if bash "$GATE" --ledger-verify >/tmp/s59-lv-clean.log 2>&1; then ok "clean tree: --ledger-verify INTACT (exit 0)"; else no "clean tree: --ledger-verify should pass"; fi
grep -q 'LEDGER: INTACT' /tmp/s59-lv-clean.log && ok "clean tree reports INTACT" || no "clean tree INTACT message"

# ---------------------------------------------------------------------------
# 4. THE ACCEPTANCE — a hand-edit of a PAST verdict is DETECTED (real run).
#    Flip S54 REJECT→ACCEPT in the worktree; the chain head must move and the
#    verify must name S54 and exit 1. Restored no matter what (trap).
# ---------------------------------------------------------------------------
F="sessions/session-54-review.md"
restore(){ git checkout -q -- "$F" 2>/dev/null || true; rm -f "$F.bak"; }
trap restore EXIT
cp "$F" /tmp/s59-s54.orig
sed -i.bak 's/\*\*Verdict:\*\* REJECT/\*\*Verdict:\*\* ACCEPT/' "$F"
if bash "$GATE" --ledger-verify >/tmp/s59-lv-tamper.log 2>&1; then rc=0; else rc=1; fi
[ "$rc" -eq 1 ] && ok "tampered past verdict (S54): --ledger-verify FAILS (exit 1)" || no "tampered S54 should fail --ledger-verify"
grep -q 'TAMPER DETECTED' /tmp/s59-lv-tamper.log && ok "reports TAMPER DETECTED" || no "TAMPER DETECTED message"
grep -qE 'first divergent session: S54' /tmp/s59-lv-tamper.log && ok "names S54 as the first divergent session" || no "should name S54"
TH="$(sed -n 's/^worktree  head : //p' /tmp/s59-lv-tamper.log | head -1)"
{ [ -n "$TH" ] && [ "$TH" != "$HEAD" ]; } && ok "tamper of earliest verdict cascades → head moves (chain property)" || no "tampered head should differ from clean head"
restore
grep -qE '\*\*Verdict:\*\* REJECT' "$F" && ok "S54 review restored to REJECT after test" || no "S54 restore failed"

# ---------------------------------------------------------------------------
# 5. Propagation is FREE (S57 include_str!) — a real vajra init scaffolds the
#    ledger-bearing gate byte-identically. No src/ change, no 8th command, no store.
# ---------------------------------------------------------------------------
cargo build >/tmp/s59-build.log 2>&1 && ok "cargo build (binary for scaffold E2E)" || no "cargo build"
BIN="$REPO/target/debug/vajra"
S="$(mktemp -d)"; trap 'restore; rm -rf "$S"' EXIT
( cd "$S" && git init -q && printf 'DemoProj\nship it\nL2\n' | "$BIN" init >/dev/null 2>&1 )
SG="$S/scripts/verify-closeout.sh"
cmp -s "$SG" "$REPO/$GATE" && ok "scaffolded gate byte-identical to canonical (drift-free)" || no "scaffolded gate byte-identical"
grep -q 'build_ledger' "$SG" && ok "scaffolded gate carries the ledger builder" || no "scaffolded gate lacks build_ledger"
grep -q -- '--ledger-verify' "$SG" && ok "scaffolded gate exposes --ledger-verify" || no "scaffolded gate lacks --ledger-verify"

if git rev-parse --verify -q main >/dev/null 2>&1; then
  git diff --name-only main...HEAD 2>/dev/null | grep -qE '^src/' \
    && no "no src/ change this session (ledger rides the script, S57 include_str!)" \
    || ok "no src/ change this session (ledger rides the script, S57 include_str!)"
else
  ok "no src/ change (main ref absent — check skipped)"
fi
CMDS="$(grep -cE '^[[:space:]]*"[a-z-]+"[[:space:]]*=>[[:space:]]*Subcommand::[A-Z]' src/main.rs 2>/dev/null || echo 0)"
[ "${CMDS:-0}" -eq 7 ] && ok "dispatch still has exactly 7 command arms (no 8th command)" || no "command-arm count drifted: got ${CMDS}"
! ls "$S"/sessions/*LEDGER* >/dev/null 2>&1 && ok "no reflexive ledger store scaffolded (derived view only)" || no "a ledger store file was scaffolded"

echo "---"
echo "PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || { echo "RED"; exit 1; }
echo "ALL GREEN"
