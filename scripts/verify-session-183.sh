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
[ -x "$VAJRA" ] || cargo build --release -q

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

echo; echo "=== Session 183 Verify Summary ==="
if [ "$FAIL" -eq 0 ]; then echo "GREEN ($PASS pass, 0 fail)"; exit 0; else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
