#!/usr/bin/env bash
# Session 183 verify — F101: the close gate runs the lint CI runs, on the toolchain CI uses.
# Every check RUNS the real thing: scripts/ci-lint.sh on tiny crates, Vajra's real close gate aimed at
# a crate with a lint error, and a real `vajra init` project's close gate. Nothing greps source.
# Fixtures run with RUSTUP_AUTO_INSTALL=0 so a missing toolchain or the network can never make one go
# red for the wrong reason (S122); each red case names the reason it must be red for.
# OLD = the commit S183 started from (9558801, pinned — never `main`).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
OLD_SHA=9558801
export RUSTUP_AUTO_INSTALL=0
VAJRA="$ROOT/target/release/vajra"
# Always the CURRENT build, first on PATH: the scaffold gates find `vajra` on PATH, and an installed
# older copy (or a stale target/) would make a check pass or fail for the wrong reason (S122).
cargo build --release -q || { echo "FAIL: cargo build --release"; exit 1; }
export PATH="$ROOT/target/release:$PATH"

# crate DIR LINT? — a tiny crate pinned like Vajra; LINT=1 adds one `useless_format` (the S182 lint)
crate() {
  mkdir -p "$1/src"; cp rust-toolchain.toml "$1/"
  printf '[package]\nname = "lintfix"\nversion = "0.1.0"\nedition = "2021"\n' > "$1/Cargo.toml"
  if [ "$2" = 1 ]; then printf 'fn main() {\n    let s = format!("hello");\n    println!("{s}");\n}\n' > "$1/src/main.rs"
  else printf 'fn main() {\n    println!("hello");\n}\n' > "$1/src/main.rs"; fi
}
lint() { (cd "$1" && bash "$ROOT/scripts/ci-lint.sh") > "$1.log" 2>&1; echo $?; }

# --- F101 (a): the one lint script — red on a lint, for that lint; green without it ------------------
crate "$T/bad" 1; crate "$T/good" 0
r=$(lint "$T/bad")
if [ "$r" != 0 ] && grep -q 'useless_format\|useless use of `format!`' "$T/bad.log" && (cd "$T/bad" && cargo build -q 2>/dev/null); then
  ok "F101 ci-lint.sh FAILS a crate whose only fault is useless_format — and that crate builds fine"
else bad "F101 bad crate: exit $r"; tail -5 "$T/bad.log"; fi
r=$(lint "$T/good")
[ "$r" = 0 ] && ok "F101 control: the same crate without the lint passes" || { bad "F101 good crate exit $r"; tail -5 "$T/good.log"; }
grep -qE '^toolchain: rustc [0-9.]+ .* clippy [0-9.]+ .*\(pinned: [0-9.]+\)' "$T/good.log" \
  && ok "F101 it names the toolchain it ran: $(head -1 "$T/good.log")" || bad "F101 no toolchain line"

# --- F101 (b): a clippy that is not the pinned one FAILS (the S182 gap) ------------------------------
crate "$T/old" 0; sed -i.bak 's/^channel = .*/channel = "1.98.0"/' "$T/old/rust-toolchain.toml"
r=$( (cd "$T/old" && RUSTUP_TOOLCHAIN="$(sed -nE 's/^channel = "(.*)"/\1/p' "$ROOT/rust-toolchain.toml")" bash "$ROOT/scripts/ci-lint.sh") > "$T/old.log" 2>&1; echo $?)
[ "$r" != 0 ] && grep -q 'pins 1.98.0' "$T/old.log" && ! grep -q '^+ cargo clippy' "$T/old.log" \
  && ok "F101 running clippy that is not the pinned version FAILS before linting: $(grep FAIL "$T/old.log")" \
  || { bad "F101 version mismatch exit $r"; cat "$T/old.log"; }
crate "$T/moving" 0; sed -i.bak 's/^channel = .*/channel = "stable"/' "$T/moving/rust-toolchain.toml"
r=$(lint "$T/moving")
[ "$r" != 0 ] && grep -q 'pin an exact version' "$T/moving.log" && ok "F101 a moving channel (\"stable\") FAILS — it is the S182 gap" || bad "F101 stable channel exit $r"
mkdir -p "$T/none"; r=$(lint "$T/none")
[ "$r" != 0 ] && grep -q 'nothing pins the toolchain' "$T/none.log" && ok "F101 no rust-toolchain.toml FAILS (cannot evaluate is not a pass)" || bad "F101 no-toml exit $r"

# --- F101 (c): Vajra's real close gate, old vs new, aimed at the lint crate --------------------------
row() { grep -E "^$2[[:space:]]" "$1" | awk '{print $2}'; }
mkdir -p "$T/bad/scripts"; cp scripts/ci-lint.sh "$T/bad/scripts/"; (cd "$T/bad" && git init -q)
CLAUDE_PROJECT_DIR="$T/bad" bash scripts/verify-closeout.sh > "$T/gate-new.out" 2>/dev/null
git show "$OLD_SHA:scripts/verify-closeout.sh" > "$T/old-gate.sh"; cp scripts/lib-ground-truth.sh "$T/"
CLAUDE_PROJECT_DIR="$T/bad" bash "$T/old-gate.sh" > "$T/gate-old.out" 2>/dev/null
n=$(row "$T/gate-new.out" cargo-clippy-clean); o=$(row "$T/gate-old.out" cargo-clippy-clean)
# the old gate must have RUN (its fmt row is there) — an empty row from a crash is not "no check"
[ "$n" = FAIL ] && [ -z "$o" ] && [ -n "$(row "$T/gate-old.out" cargo-fmt-clean)" ] && ok "F101 Vajra's close gate: no clippy row at $OLD_SHA; cargo-clippy-clean FAIL now, on the lint crate" \
  || bad "F101 gate rows old='$o' new='$n'"
mkdir -p "$T/good/scripts"; cp scripts/ci-lint.sh "$T/good/scripts/"; (cd "$T/good" && git init -q)
CLAUDE_PROJECT_DIR="$T/good" bash scripts/verify-closeout.sh > "$T/gate-good.out" 2>/dev/null
[ "$(row "$T/gate-good.out" cargo-clippy-clean)" = PASS ] && ok "F101 control: the gate's cargo-clippy-clean PASSES the clean crate" || bad "F101 gate on good crate"
if bash scripts/ci-lint.sh > "$T/self.log" 2>&1; then ok "F101 Vajra itself is clean under the shared lint ($(head -1 "$T/self.log"))"; else bad "F101 Vajra lint"; tail -8 "$T/self.log"; fi

# --- F101 (d): a project's close gate runs the lint it declares ---------------------------------------
P="$T/proj"; mkdir -p "$P"; (cd "$P" && git init -q && "$VAJRA" init </dev/null >/dev/null 2>&1)
pgate() {
  local f="$P/.ai/CONSTRAINTS.yaml"; sed -i.bak '/^[[:space:]]*lint_command:/d' "$f"
  [ -n "$1" ] && printf '  lint_command: %s\n' "$1" >> "$f"
  (cd "$P" && bash scripts/verify-closeout.sh > "$T/pgate.out" 2>/dev/null); row "$T/pgate.out" project-lint-clean
}
[ -f "$P/scripts/verify-closeout.sh" ] || bad "F101 vajra init made no scripts/verify-closeout.sh"
grep -q '^  # lint_command:' "$P/.ai/CONSTRAINTS.yaml" && ok "F101 a new project's CONSTRAINTS.yaml shows the lint_command line (commented)" || bad "F101 no lint_command hint in the scaffold"
r=$(pgate "");      [ "$r" = WARN ] && grep -q 'WARN row' "$T/pgate.out" && ok "F101 project with no lint_command → WARN row in the table (not PASS)" || bad "F101 missing → '$r'"
r=$(pgate "false"); [ "$r" = FAIL ] && ok "F101 project lint_command that fails → FAIL" || bad "F101 false → '$r'"
r=$(pgate "true");  [ "$r" = PASS ] && ok "F101 project lint_command that passes → PASS" || bad "F101 true → '$r'"
r=$(pgate "none");  [ "$r" = N/A ]  && ok "F101 lint_command: none → N/A (a recorded 'no linter')" || bad "F101 none → '$r'"
r=$(pgate "\"cd $T/bad && bash $ROOT/scripts/ci-lint.sh\"")
[ "$r" = FAIL ] && grep -q 'useless' "$P/.ai/verify/closeout/latest/project-lint-clean.log" \
  && ok "F101 a project whose lint_command is a real clippy run FAILS on the lint crate, and its log names the lint" || bad "F101 real lint → '$r'"

# --- F102: the no-jq test runs with jq really absent, on any OS ---------------------------------------
# (Linux's /bin = /usr/bin cannot be rebuilt here without a container: the red evidence is CI — main
# red from #219's merge, green on this branch — named in the summary.)
if command -v jq >/dev/null 2>&1 && cargo test -q --test approvals_guard no_jq_advises_at_l1_and_blocks_at_l2 2>&1 | grep -q 'test result: ok. 1 passed'; then
  ok "F102 the no-jq test passes on a host that HAS jq (it removes jq itself, then proves it is gone)"
else bad "F102 no-jq test (or no jq on this host — then this check proves nothing)"; fi

# --- F106: --inputs-sha leaves no empty folder; same hash as before -------------------------------
folders() { ls "$1/.ai/verify/closeout" 2>/dev/null | wc -l | tr -d ' '; }
(cd "$P" && git add -A && git -c core.hooksPath=/nonexistent commit -qm scaffold && git checkout -q -b session-01-kickoff \
  && echo "# s01" > notes.md && git add notes.md && git -c core.hooksPath=/nonexistent commit -qm s01)
git show "$OLD_SHA:scripts/verify-closeout-scaffold.sh" > "$T/old-scaffold.sh"
a=$(folders "$P"); hn=$(cd "$P" && bash scripts/verify-closeout.sh --inputs-sha 1 2>&1); b=$(folders "$P")
ho=$(CLAUDE_PROJECT_DIR="$P" bash "$T/old-scaffold.sh" --inputs-sha 1 2>&1); c=$(folders "$P")
[ "$a" = "$b" ] && [ "$c" = $((b+1)) ] && [ "$hn" = "$ho" ] && [[ "$hn" =~ ^[0-9a-f]{64}$ ]] \
  && ok "F106 project gate: --inputs-sha adds no folder now (the $OLD_SHA gate added 1); same hash, old and new" \
  || bad "F106 project folders ${a}→${b} (old →${c}), hash new='$hn' old='$ho'"
a=$(folders "$ROOT"); h=$(bash scripts/verify-closeout.sh --inputs-sha 2>&1); b=$(folders "$ROOT")
[ "$a" = "$b" ] && [[ "$h" =~ ^[0-9a-f]{64}$ ]] && ok "F106 Vajra's gate: --inputs-sha with no number still prints a hash and adds no folder" \
  || bad "F106 Vajra folders ${a}→${b}, out='$h'"

# --- F104: unchecked `obeyed:` claims are a WARN row with the count, never PASS ----------------------
SHA=$(git -C "$P" rev-parse --short HEAD)
printf '\n## Advice\n- tech-lead rec 1 — obeyed: %s (done)\n- tech-lead rec 2 — obeyed: %s (done)\n' "$SHA" "$SHA" >> "$P/prompts/01-task-kickoff.md"
(cd "$P" && bash scripts/verify-closeout.sh > "$T/f104.out" 2>/dev/null)
cp "$P/.ai/verify/closeout/latest/obeyed-judgments.log" "$T/f104.log" 2>/dev/null
CLAUDE_PROJECT_DIR="$P" bash "$T/old-scaffold.sh" > "$T/f104-old.out" 2>/dev/null
n=$(row "$T/f104.out" obeyed-judgments); o=$(row "$T/f104-old.out" obeyed-judgments)
[ "$n" = WARN ] && [ "$o" = PASS ] && grep -q 'WARN: 2 `obeyed:` claim' "$T/f104.log" \
  && ok "F104 2 unchecked obeyed claims: WARN row naming 2 now; PASS at $OLD_SHA" || bad "F104 rows new='$n' old='$o'"
sed -i.bak '/^## Advice$/,$d' "$P/prompts/01-task-kickoff.md"
(cd "$P" && bash scripts/verify-closeout.sh > "$T/f104c.out" 2>/dev/null)
[ "$(row "$T/f104c.out" obeyed-judgments)" = PASS ] && ok "F104 control: no obeyed claims → PASS" || bad "F104 control row '$(row "$T/f104c.out" obeyed-judgments)'"

# --- F105: the step list says the session type at the START, read through the one shared helper ----
stp() { (cd "$P" && vajra next --steps 2>&1) | grep -E '^  [✓✗] the prompt says its session type' | grep -oE '[✓✗]'; }
F="$P/prompts/01-task-kickoff.md"; LIB="$P/.ai/hooks/lib-ground-truth.sh"
sed -i.bak '/^session_type:/d' "$F";                   r1=$(stp)
sed -i.bak 's/^## Type$/## Type\nsession_type: code/' "$F"; r2=$(stp)
sed -i.bak 's/^session_type: code$/session_type: CODE/' "$F"; r3=$(stp)
cp "$LIB" "$T/lib.keep"; sed -i.bak 's/CODE|DOCUMENT|GROUND_TRUTH|INTERACTIVE)/DOCUMENT|GROUND_TRUTH|INTERACTIVE)/' "$LIB"; r4=$(stp)
rm -f "$LIB"; r5=$(stp); cp "$T/lib.keep" "$LIB"
[ "$r1" = "✗" ] && [ "$r2" = "✗" ] && [ "$r3" = "✓" ] && ok "F105 type missing ✗ · 'code' ✗ · 'CODE' ✓ in vajra next --steps" || bad "F105 missing='$r1' code='$r2' CODE='$r3'"
[ "$r4" = "✗" ] && [ "$r5" = "✗" ] && ok "F105 the step reads the project's shared helper: edit it to drop CODE → ✗; delete it → ✗" || bad "F105 helper-edited='$r4' no-helper='$r5'"
pos=$( (cd "$P" && vajra next --steps 2>&1) | grep -nE '^  [✓✗] ' | grep -E 'session type|independent review' | cut -d: -f1 | tr '\n' ' ')
set -- $pos; [ "${1:-0}" -lt "${2:-0}" ] && ok "F105 the type step comes before the review step (lines $pos)" || bad "F105 order '$pos'"

echo; echo "=== Session 183 Verify Summary ==="
if [ "$FAIL" -eq 0 ]; then echo "GREEN ($PASS pass, 0 fail)"; exit 0; else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
