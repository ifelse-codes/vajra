#!/usr/bin/env bash
# Demo — Session 119: the clean-room runner (cumulative).
set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

VAJRA="$ROOT/target/debug/vajra"

echo "demo:header"
echo "============================================================"
echo " S119: the clean-room runner — QA and Demo-er now re-run"
echo " their scripts in an environment the agent did not prepare."
echo "============================================================"
echo ""
echo "BEFORE (S118 finding):"
echo "  - Governed run: 14/14 ALL GREEN in verify suite made of grep checks"
echo "  - Reality: 19/20 chart pages showed an error"
echo "  - Cause: stale build artifact (dist/) left in agent's working tree"
echo "  - Ten cold reviews missed it; CI caught it in 37s"
echo ""
echo "AFTER (S119):"
echo "  - QA and Demo-er route through 'git worktree add --detach HEAD'"
echo "  - Clean room: no uncommitted files, no gitignored artifacts"
echo "  - Bootstrap command optional (e.g. pnpm install --frozen-lockfile)"
echo "  - Default OFF — existing repos unaffected; opt-in per repo"
echo "  - VAJRA_SKIP_CLEAN_ROOM=1 escapes to working tree (disclosed)"
echo ""

echo "demo:cases"
echo "--- Falsifiability fixture (the key test) ---"
echo ""
echo "Shell-level fixture: verify script that PASSES in working tree, FAILS in clean room"
REPO="$(mktemp -d)"
cleanup() { rm -rf "$REPO"; }
trap cleanup EXIT

git -C "$REPO" init -q
git -C "$REPO" config user.email "t@t.com"
git -C "$REPO" config user.name "T"
printf 'dist/\n' > "$REPO/.gitignore"
mkdir -p "$REPO/scripts"
printf '#!/usr/bin/env bash\n[ -f dist/output.txt ] || { echo "FAIL: artifact absent"; exit 1; }\necho "PASS: artifact present"\n' \
  > "$REPO/scripts/verify.sh"
git -C "$REPO" add . && git -C "$REPO" commit -qm "initial"
mkdir -p "$REPO/dist" && printf 'stale build\n' > "$REPO/dist/output.txt"

printf '  %-40s ' "working-tree run (artifact present):"
if (cd "$REPO" && bash scripts/verify.sh) 2>/dev/null; then echo "[PASS]"; else echo "[FAIL]"; fi

CR="$(mktemp -d)"; rmdir "$CR"
git -C "$REPO" worktree add --detach "$CR" HEAD -q
printf '  %-40s ' "clean-room run (artifact absent):"
if (cd "$CR" && bash scripts/verify.sh) 2>/dev/null; then echo "[FAIL — clean room let artifact through]"
else echo "[PASS — clean room correctly fails]"; fi
git -C "$REPO" worktree remove --force "$CR" 2>/dev/null || true

echo ""
echo "--- Configuration (opt-in, default off) ---"
echo ""
if grep -q "clean_room:" "$ROOT/.ai/CONSTRAINTS.yaml" 2>/dev/null; then
  echo "  verify.clean_room in .ai/CONSTRAINTS.yaml:"
  grep -A3 "clean_room:" "$ROOT/.ai/CONSTRAINTS.yaml" | head -4 | sed 's/^/    /'
else
  echo "  (clean_room section not found — should be present)"
fi
echo ""
echo "  vajra init scaffold also carries clean_room keys (default off)"
grep -c "clean_room:" "$ROOT/src/cli/init.rs" 2>/dev/null \
  && echo "  ✓ clean_room: found in TPL_CONSTRAINTS" || echo "  ✗ missing from TPL_CONSTRAINTS"

echo ""
echo "--- Gate behaviour ---"
echo "  VAJRA_SKIP_CLEAN_ROOM=1  → run in working tree (disclosed in output)"
echo "  Bootstrap failure/timeout → CannotEvaluate → BLOCK (never degrades to pass)"
echo "  Clean room creation failure → CannotEvaluate → BLOCK"
echo "  enabled: false (default) → byte-identical to pre-S119 for all existing repos"

echo ""
echo "demo:summary_table"
echo ""
printf '%-35s %-15s\n' "CHECK" "RESULT"
printf '%-35s %-15s\n' "---------------------------------" "-------"

check_result() {
  local name="$1"; local cmd="$2"
  if eval "$cmd" > /dev/null 2>&1; then
    printf '%-35s %-15s\n' "$name" "PASS"
  else
    printf '%-35s %-15s\n' "$name" "FAIL"
  fi
}

check_result "falsifiability-fixture (lib test)" \
  "cargo test --lib gate_run::tests::clean_room_falsifiability_fixture"
check_result "clean_room_config defaults off" \
  "cargo test --lib gate_run::tests::clean_room_config_defaults_when_key_absent"
check_result "CONSTRAINTS.yaml has clean_room" \
  "grep -q 'clean_room:' .ai/CONSTRAINTS.yaml"
check_result "init scaffold has clean_room" \
  "grep -q 'clean_room:' src/cli/init.rs"
check_result "VAJRA_SKIP_CLEAN_ROOM in both gates" \
  "grep -q 'VAJRA_SKIP_CLEAN_ROOM' src/qa/mod.rs && grep -q 'VAJRA_SKIP_CLEAN_ROOM' src/demoer/mod.rs"

echo ""
echo "demo:before_after"
echo ""
echo "BEFORE (S118): verify suite returned 14/14 ALL GREEN while 19/20 charts errored."
echo "AFTER  (S119): a verify script that depends on a stale artifact FAILS in the clean"
echo "               room — the exact defect CI caught at S118 that ten reviews missed."
echo ""
echo "Honest limit: this proves the product RUNS FROM A CLEAN CHECKOUT."
echo "It does NOT prove the product is correct. It would NOT have caught the 19/20"
echo "broken charts — that code compiled fine. The grep-only-verify detector stays queued."
