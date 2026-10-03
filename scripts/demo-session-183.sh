#!/usr/bin/env bash
# Session 183 demo — a close that is green means CI is green too (F101: one pinned toolchain, one lint
# script, both close gates run it), plus four fixes from the founder's rudra session 16 (F102 main's red
# CI, F104 unchecked "obeyed" claims shown as WARN, F105 the session-type step at the start, F106 no
# empty close folders). Drawn with scripts/demo-kit.sh (DECISION-009/010): every claim runs live; the
# "before" is the commit S183 started from. Try it: DEMO_MODE=stream bash scripts/demo-session-183.sh
# (gate view) · bare in a terminal (deck).

set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="183"
OLD_SHA=9558801    # the commit S183 started from — pinned, never `main`
# ========================

export RUSTUP_AUTO_INSTALL=0
cargo build --release -q 2>/dev/null
export PATH="$ROOT/target/release:$PATH"

# a tiny crate pinned like Vajra, with the one lint that broke S182's CI
LINT="$DK_TMP/lintcrate"; mkdir -p "$LINT/src" "$LINT/scripts"
cp rust-toolchain.toml "$LINT/"; cp scripts/ci-lint.sh "$LINT/scripts/"
printf '[package]\nname = "lintfix"\nversion = "0.1.0"\nedition = "2021"\n' > "$LINT/Cargo.toml"
printf 'fn main() {\n    let s = format!("hello");\n    println!("{s}");\n}\n' > "$LINT/src/main.rs"
(cd "$LINT" && git init -q)
git show "$OLD_SHA:scripts/verify-closeout.sh" > "$DK_TMP/old-gate.sh" 2>/dev/null
cp scripts/lib-ground-truth.sh "$DK_TMP/" 2>/dev/null

# a fresh `vajra init` project with one session commit
P="$DK_TMP/proj"; mkdir -p "$P"
(cd "$P" && git init -q && vajra init </dev/null >/dev/null 2>&1 && git add -A \
  && git -c core.hooksPath=/nonexistent commit -qm scaffold && git checkout -q -b session-01-kickoff \
  && echo "# s01" > notes.md && git add notes.md && git -c core.hooksPath=/nonexistent commit -qm s01)
git show "$OLD_SHA:scripts/verify-closeout-scaffold.sh" > "$DK_TMP/old-scaffold.sh" 2>/dev/null

# gate_row SCRIPT ROW → that close gate's result for ROW on the lint crate
gate_row() {
  CLAUDE_PROJECT_DIR="$LINT" bash "$1" 2>/dev/null | grep -E "^$2[[:space:]]" | awk '{print $1"  "$2}'
  echo "(no other row matters here — the crate is not a Vajra session)"
}
# obeyed_row SCRIPT → the project's obeyed-judgments row with two unchecked `obeyed:` claims
obeyed_row() {
  local sha; sha=$(git -C "$P" rev-parse --short HEAD)
  grep -q '^## Advice' "$P/prompts/01-task-kickoff.md" || printf '\n## Advice\n- tech-lead rec 1 — obeyed: %s (done)\n- tech-lead rec 2 — obeyed: %s (done)\n' "$sha" "$sha" >> "$P/prompts/01-task-kickoff.md"
  CLAUDE_PROJECT_DIR="$P" bash "$1" 2>/dev/null | grep -E '^obeyed-judgments'
  grep -h '^WARN:' "$P/.ai/verify/closeout/latest/obeyed-judgments.log" 2>/dev/null | cut -c1-110
}
# type_step VALUE → what `vajra next --steps` says about the session type for that prompt line
type_step() {
  local f="$P/prompts/01-task-kickoff.md"
  sed -i.bak '/^session_type:/d' "$f"; [ -n "$1" ] && sed -i.bak "s/^## Type\$/## Type\nsession_type: $1/" "$f"
  echo "prompt line: ${1:+session_type: $1}${1:-<none>}"
  (cd "$P" && vajra next --steps 2>&1) | grep -E '^  [✓✗] the prompt says its session type'
}
# folders_after SCRIPT → empty dated folders one --inputs-sha call leaves behind
folders_after() {
  local a b; a=$(ls "$P/.ai/verify/closeout" 2>/dev/null | wc -l | tr -d ' ')
  CLAUDE_PROJECT_DIR="$P" bash "$1" --inputs-sha 1 >/dev/null 2>&1
  b=$(ls "$P/.ai/verify/closeout" 2>/dev/null | wc -l | tr -d ' ')
  echo "close-log folders: $a → $b"
}

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION" "FIXES|5|F101 F102 F104 F105 F106"
  dk_h1 "A green close now means " "a green CI" " — one Rust version, one lint, everywhere."
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Old: S182 closed green, then GitHub failed its lint — your machine had an older clippy, and the close check never ran clippy at all. In rudra, 34 'I obeyed the advice' claims passed unchecked under a PASS." \
    "New: one file pins Rust for your machine and CI; the close check runs CI's own lint script and names the version. Unchecked claims show as WARN with the count. The session-type rule shows at the start."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "F101.|rust-toolchain.toml pins 1.99.0; scripts/ci-lint.sh is the one lint command CI and the close check both run. Projects name theirs in one line (lint_command:)." \
    "F102.|main had been red on GitHub since S182 merged — one test only worked on a Mac. Fixed; PR #220's CI is green on Ubuntu and macOS." \
    "F104.|rudra S16 closed 34 'obeyed' claims nobody checked, under PASS. Now: WARN, with the number." \
    "F105.|rudra S16 met the session-type rule only at close, then re-stamped its review. The step list now says it at the start." \
    "F106.|Each review-stamp calculation left an empty folder in the close logs. Not any more." \
    "Your call.|F103 (init waits on silent input), F107 (a message quoting Vajra's session number to rudra), F108 (two more modes leave empty folders)."
}

slide_before_after() {
  dk_section before_after "the change · the same crate, before and after"
  dk_h2 "Before → After"
  dk_p "The input: a crate whose only fault is the lint that broke S182 on GitHub. Left: the close check at $OLD_SHA. Right: today's."
  local before after
  dk_run_v gate_row "$DK_TMP/old-gate.sh" cargo-clippy-clean; before="$_DK_OUT"
  dk_run_v gate_row "$ROOT/scripts/verify-closeout.sh" cargo-clippy-clean; after="$_DK_OUT"
  dk_compare "BEFORE|close check at $OLD_SHA" "${before:-(no clippy row at all)}" "AFTER|close check today · live" "$after"
  echo
  dk_check "before: the close check had no lint row at all" \
    bash -c '! printf "%s" "$1" | grep -q "cargo-clippy-clean"' _ "$before"
  dk_check "after: cargo-clippy-clean FAILS on the lint" \
    bash -c 'printf "%s" "$1" | grep -q "cargo-clippy-clean  FAIL"' _ "$after"
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "What Vajra does now"
  dk_table "Thing|Vajra now" \
    "which Rust version|the one in rust-toolchain.toml — your machine and GitHub both read it" \
    "the lint|scripts/ci-lint.sh: says the version, fails if it is not the pinned one, then runs CI's clippy" \
    "a project's lint|lint_command: in .ai/CONSTRAINTS.yaml — runs it; 'none' = N/A; missing = a WARN row" \
    "unchecked 'obeyed' claims|a WARN row with the count, never PASS" \
    "the session type|named in the step list at the start, read the same way the close check reads it"
  dk_caption "Honest limits: an agent can type 'lint_command: true'; 'matches CI' means 'matches the pinned version'; #[allow] still silences a lint."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  dk_run_v obeyed_row "$ROOT/scripts/verify-closeout-scaffold.sh"
  dk_term "1 · F104: a project with two 'obeyed' claims nobody checked" "$_DK_OUT"
  dk_check "the row is WARN and names 2, not PASS" \
    bash -c 'printf "%s" "$1" | grep -q "WARN" && printf "%s" "$1" | grep -q "WARN: 2"' _ "$_DK_OUT"
  dk_run_v type_step ""
  dk_term "2 · F105: a prompt with no session_type line, at the START of the session" "$_DK_OUT"
  dk_check "the step list says it is missing (✗)" bash -c 'printf "%s" "$1" | grep -q "✗ the prompt says its session type"' _ "$_DK_OUT"
  dk_run_v type_step CODE
  dk_term "3 · F105: the same prompt with session_type: CODE" "$_DK_OUT"
  dk_check "the step is done (✓)" bash -c 'printf "%s" "$1" | grep -q "✓ the prompt says its session type"' _ "$_DK_OUT"
  dk_run_v folders_after "$ROOT/scripts/verify-closeout-scaffold.sh"
  dk_term "4 · F106: one review-stamp calculation (--inputs-sha)" "$_DK_OUT"
  dk_check "no new folder in the close logs" bash -c 'printf "%s" "$1" | grep -qE "folders: ([0-9]+) → \1$"' _ "$_DK_OUT"
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_table "Recorded at close — not re-run here|Result" \
    "scripts/verify-session-183.sh — real-run checks|23 / 23" \
    "PR #220 CI (Ubuntu + macOS) on the pinned toolchain|green"
  dk_verdict "HONEST NOTES" \
    "Release builds use the pinned toolchain too, but that workflow only runs on a version tag — not tried yet. The Linux case of F102 is proven by GitHub's CI, not on this Mac." \
    "Not fixed, your call: F103, F107, F108."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next"
  dk_table " |Option|Why pick it · the risk" \
    "A|rudra session 17 under the new rules (interactive)|S183's WARN row and type step get real use · risk: more findings than fixes" \
    "B|F67: the receipt reads the tool's own cost for interactive runs|rudra S16 read ~\$83.54, ~5× real · risk: Claude Code may not expose it" \
    "C|the non-Claude tools brainstorm (F91, F94, F95)|parked since S179 · risk: a design session, nothing a user runs yet"
  dk_table "word|meaning" \
    "rust-toolchain.toml|the one file that says which Rust version builds Vajra" \
    "lint|an automatic code-tidiness check (clippy, for Rust)" \
    "obeyed claim|the agent saying 'I did what the advisor recommended', with a commit"
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
