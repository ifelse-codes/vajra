#!/usr/bin/env bash
# demo-session-167.sh — S167: every Vajra demo plays as a rich story in the terminal.
# The first real demo built on scripts/demo-kit.sh from the new seven-section template.
#   in a terminal       → a paged deck (← → or space · a autoplay · q quit)
#   piped / CI / gate   → every slide in order, with the demo:<element> markers the gate scans
# Every panel is a live run: the before runs the pre-S167 template straight out of git.
set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="167"
# ========================
BIN="${VAJRA_BIN:-$ROOT/target/release/vajra}"
PRE=fab1b79   # main just before S167 — the last commit carrying the old template
ALL="headline story before_after rule cases scorecard next"

# Recorded at close — measured outside this deck, never re-run here (labelled "recorded").
REC_TESTS="cargo test --lib: 493 pass, 0 fail"
REC_LINT="cargo clippy --all-targets: no warnings · cargo fmt --check: clean"
REC_CHITRA="--dry-run: template 'would upgrade' (an untouched pre-S71 copy), kit 'would create'; HEAD, status and stash identical before and after"
REC_REVIEW="cold fidelity-reviewer pass: see sessions/session-167-review.md"

# One fresh `vajra init` in an empty folder, made once and reused by the slides.
FRESH="$DK_TMP/fresh"
fresh_init() {
  [ -d "$FRESH/scripts" ] && return 0
  mkdir -p "$FRESH" && ( cd "$FRESH" && git init -q . && "$BIN" init >/dev/null 2>&1 </dev/null )
}
in_dir() { local d="$1"; shift; ( cd "$d" && "$@" ); }   # run a command inside a folder

slide_headline() {
  dk_section headline "session $SESSION · the rich terminal demo · 2026-09-14"   # prints demo:header
  dk_h1 "Every Vajra demo now plays as a " "slide deck in the terminal" "."
  dk_p "One story: agents asked for a demo kept making HTML pages, because Vajra's own rules said the demo script was for machines and the human demo was a separate page. Now the demo script IS the human demo — in this repo and in every project that runs vajra init."
  fresh_init
  local have=0 f up html
  for f in scripts/demo-kit.sh scripts/demo-session-template.sh; do [ -f "$FRESH/$f" ] && have=$((have+1)); done
  dk_run_v in_dir "$FRESH" "$BIN" init --sync-fleet --dry-run
  up="$(printf '%s\n' "$_DK_OUT" | grep -cE 'demo-(kit|session-template)\.sh \(up to date\)')"
  html="$(cat "$FRESH/scripts/demo-session-template.sh" "$FRESH/.ai/AGENTS.md" "$FRESH/.ai/CONSTRAINTS.yaml" \
          .ai/AGENTS.md .ai/CONSTRAINTS.yaml | grep -c 'interactive_html\|interactive HTML slide deck')"
  dk_metrics "OUTLINE|7|sections" "SCAFFOLDED|$have|of 2 files · live" "SYNC|$up|of 2 up to date · live" \
    "HTML RULES|$html|left · live" "LIB TESTS|493|recorded"
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Old: copy the demo template, run it without filling anything in, and it PASSED — exit 0, all four markers, nothing shown." \
    "New: the same empty copy FAILS and names all seven empty sections. Filled in, it plays as this deck — and vajra init --sync-fleet brings the kit to projects that already use Vajra."
  dk_caption "live = ran just now, while you watched · recorded = measured at close, not re-run here"
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "Found the root cause.|The template, the constitution and CONSTRAINTS.yaml all said: the script is for CI, show humans an HTML deck. So agents in chitra drew HTML pages by hand." \
    "Built the kit.|scripts/demo-kit.sh draws headlines, number tiles, verdict boxes, before/after panels, tables, a scorecard and a pager — in plain bash 3.2, boxes straight at any width." \
    "Rewrote the template as a seven-section outline.|Each section starts as a red TO FILL IN box that fails the demo by name, so an empty demo can no longer pass." \
    "Retired the HTML rule everywhere.|The template, .ai/AGENTS.md step 5, CONSTRAINTS.yaml, the scaffolded constitution and the demo-producer brief now say the terminal demo is the human demo (DECISION-009)." \
    "Put both files on the upgrade path.|vajra init --sync-fleet creates, upgrades or refuses them, like the hooks — and an untouched old template upgrades without the risky flag."
  dk_caption "\"Scaffold\" = the files vajra init writes into a new project. \"Sync\" = vajra init --sync-fleet, which updates those files later."
}

slide_before_after() {
  dk_section before_after "the change · two real runs · same input"   # prints demo:before_after
  dk_h2 "Before → After"
  dk_p "The input: copy the demo template to a new session demo and run it without filling anything in — the laziest demo possible."
  local old="$DK_TMP/before" new="$DK_TMP/after" before brc after arc
  mkdir -p "$old/scripts" "$new/scripts"
  git show "$PRE:scripts/demo-session-template.sh" > "$old/scripts/demo-session-99.sh" 2>/dev/null
  cp scripts/demo-kit.sh "$new/scripts/" && cp scripts/demo-session-template.sh "$new/scripts/demo-session-99.sh"
  dk_run_v env -u CLAUDE_PROJECT_DIR DEMO_MODE=stream NO_COLOR=1 bash "$old/scripts/demo-session-99.sh"
  before="$_DK_OUT" brc=$_DK_RC
  dk_run_v env -u CLAUDE_PROJECT_DIR DEMO_MODE=stream NO_COLOR=1 bash "$new/scripts/demo-session-99.sh"
  arc=$_DK_RC
  after="$(printf '%s\n' "$_DK_OUT" | grep '^demo:')
$(printf '%s\n' "$_DK_OUT" | grep -c 'TO FILL IN') red TO FILL IN boxes, then:
$(printf '%s\n' "$_DK_OUT" | sed -n '/demo not filled in/,$p')"
  dk_compare "BEFORE|template at $PRE · exit $brc" "$before" "AFTER|template today · exit $arc" "$after"
  dk_caption "Both panels are live runs. The before ran the old template straight out of git (commit $PRE). The after is an unedited copy of today's template."
  echo
  if [ "$brc" = 0 ] && [ "$arc" != 0 ]; then dk_check "an empty demo used to pass · now it fails by name" PASS
  else dk_check "an empty demo used to pass · now it fails by name (before exit $brc, after exit $arc)" FAIL; fi
}

# rule_deck FILE "SECTIONS" "COMMANDS" — a tiny deck: one slide per section, then the commands.
rule_deck() {
  local s fns=""
  { printf '. "%s"\n' "$KIT"
    for s in $2; do printf 's_%s() { dk_section %s; }\n' "$s" "$s"; fns="$fns s_$s"; done
    printf 'x() { %s; }\ndk_deck%s x\ndk_finish\n' "$3" "$fns"
  } > "$1"
}

slide_rule() {
  dk_section rule "the rule, in plain words · every verdict below is a live run"
  dk_h2 "When a demo passes now"
  local d="$DK_TMP/rule" n=0 row label secs cmds want why got badge; local -a rows
  mkdir -p "$d"
  for row in \
    "every section shown, a live check passed|$ALL|dk_check ok PASS quiet|PASS|the only way to pass" \
    "a section still holds its TO FILL IN box|$ALL|dk_check ok PASS quiet; dk_todo story x|BLOCK|an outline left empty" \
    "a section was never shown|headline story before_after rule cases scorecard|dk_check ok PASS quiet|BLOCK|the story has a hole" \
    "no live check ran at all|$ALL|:|BLOCK|a demo that checks nothing shows nothing" \
    "a live check failed|$ALL|dk_check ok FAIL quiet|BLOCK|the failure is shown, and the exit is non-zero"; do
    n=$((n+1)); label="${row%%|*}"; row="${row#*|}"; secs="${row%%|*}"; row="${row#*|}"
    cmds="${row%%|*}"; row="${row#*|}"; want="${row%%|*}"; why="${row#*|}"
    rule_deck "$d/deck-$n.sh" "$secs" "$cmds"
    if DEMO_MODE=stream bash "$d/deck-$n.sh" >/dev/null 2>&1; then got=PASS; else got=BLOCK; fi
    if [ "$got" = PASS ]; then badge="${C_YES}✓ passes${C_0}"; else badge="${C_NO}✗ fails${C_0}"; fi
    rows+=("$label|$badge|$why")
    if [ "$got" = "$want" ]; then dk_check "rule · $label → $want" PASS quiet
    else dk_check "rule · $label should be $want, got $got" FAIL quiet; fi
  done
  dk_table "The demo…|Result|Why" "${rows[@]}"
  dk_caption "Each row wrote a tiny throwaway deck on the real kit and ran it the way the gate does (not in a terminal)."
}

slide_cases() {
  dk_section cases "the cases · live"   # prints demo:cases
  dk_h2 "Four things to see for yourself"
  fresh_init
  local c1 c2 c3 c4 oldp="$DK_TMP/oldproj" edp="$DK_TMP/edited" pw
  dk_run_v in_dir "$FRESH" bash -c 'ls -1 scripts/demo-kit.sh scripts/demo-session-template.sh; tail -n 1 scripts/demo-kit.sh | cut -c1-44'
  c1="$_DK_OUT"
  dk_run_v in_dir "$FRESH" "$BIN" init --sync-fleet --dry-run
  c2="$(printf '%s\n' "$_DK_OUT" | grep -E 'demo-(kit|session-template)\.sh')"
  rm -rf "$oldp" "$edp"; cp -R "$FRESH" "$oldp"; cp -R "$FRESH" "$edp"
  git show "$PRE:scripts/demo-session-template.sh" > "$oldp/scripts/demo-session-template.sh" 2>/dev/null
  dk_run_v in_dir "$oldp" "$BIN" init --sync-fleet --dry-run
  c3="$(printf '%s\n' "$_DK_OUT" | grep -E 'demo-session-template\.sh')"
  printf '# my own tweak\n' >> "$edp/scripts/demo-kit.sh"
  dk_run_v in_dir "$edp" "$BIN" init --sync-fleet --dry-run
  c4="$(printf '%s\n' "$_DK_OUT" | grep -E 'demo-kit\.sh|--overwrite-drifted$' | head -3)"
  if [ "$DK_W" -ge 96 ]; then pw=$(( (DK_W - 2) / 2 ))
    dk_side "$(dk_term "1 · vajra init in an empty folder" "$c1" "$pw")" \
            "$(dk_term "2 · --sync-fleet right after init" "$c2" "$pw")"
    dk_side "$(dk_term "3 · an untouched OLD template" "$c3" "$pw")" \
            "$(dk_term "4 · a hand-edited kit" "$c4" "$pw")"
  else
    dk_term "1 · vajra init in an empty folder" "$c1"; dk_term "2 · --sync-fleet right after init" "$c2"
    dk_term "3 · an untouched OLD template" "$c3"; dk_term "4 · a hand-edited kit" "$c4"
  fi
  if grep -q '^# vajra-render-sha: ' "$FRESH/scripts/demo-kit.sh" 2>/dev/null; then dk_check "init scaffolds the kit, stamped" PASS
  else dk_check "init scaffolds the kit, stamped" FAIL; fi
  if [ "$(printf '%s\n' "$c2" | grep -c 'up to date')" = 2 ]; then dk_check "both demo files are up to date right after init" PASS
  else dk_check "both demo files are up to date right after init" FAIL; fi
  if printf '%s' "$c3" | grep -q 'upgrade'; then dk_check "an untouched old template upgrades without --overwrite-drifted" PASS
  else dk_check "an untouched old template upgrades without --overwrite-drifted" FAIL; fi
  if printf '%s' "$c4" | grep -q 'DRIFT'; then dk_check "a hand-edited kit is refused, never overwritten" PASS
  else dk_check "a hand-edited kit is refused, never overwritten" FAIL; fi
}

slide_scorecard() {
  dk_section scorecard "proof · what ran live in this deck · what was recorded at close"   # prints demo:summary_table
  dk_h2 "The scorecard"
  dk_scorecard "LIVE — ran while you watched"
  echo
  dk_table "Recorded at close — not re-run here|Result" \
    "Rust tests|$REC_TESTS" \
    "lint|$REC_LINT" \
    "chitra (a real project on Vajra)|$REC_CHITRA" \
    "independent review|$REC_REVIEW"
  dk_verdict "HONEST NOTES" \
    "Fakest green: a lazy agent can still replace every TO FILL IN box with thin text and one easy check, and pass. The kit proves the outline was filled, not that it shows anything — that is S168." \
    "What this demo does not show: the deck keys in a real terminal (the verify script drives them in a pseudo-terminal), Linux (the Rust tests run the kit there in CI), light-background terminals, Windows, and the release to crates.io and Homebrew."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next"
  dk_table " |Session|What and why" \
    "A|S168 · Vajra fills in the numbers|Tiles and scorecard come from checks Vajra already runs, so they cannot be skipped or faked (founder-named)." \
    "B|S169 · tighten the close gate|The S166 cold review found a commit-id check a word like 'defaced' can pass." \
    "C|S170 · Ground Truth|The mandatory no-code audit (170 % 5 == 0)."
  dk_h2 "Small words helper"
  dk_table "word|meaning" \
    "kit|scripts/demo-kit.sh — the drawing helpers a demo script calls." \
    "outline|The seven sections every demo fills: headline, story, before/after, rule, cases, scorecard, next." \
    "marker|A demo:<name> line the Demo-er gate looks for when it re-runs the demo." \
    "stamp|A last-line fingerprint that proves a file is an untouched Vajra render." \
    "drifted|A file Vajra cannot prove untouched — it refuses to overwrite it."
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
