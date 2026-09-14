#!/usr/bin/env bash
# demo-session-168.sh — S168: a demo that cannot be faked (DECISION-010).
# Built on scripts/demo-kit.sh from the seven-section template; demo-producer recs 1–14 applied.
#   in a terminal       → a paged deck (← → or space · a autoplay · q quit)
#   piped / CI / gate   → every slide in order, with the markers the gate scans:
#                         demo:header · demo:before_after · demo:cases · demo:summary_table ·
#                         demo:complete (dk_finish) · demo:fact (dk_vajra_tiles / dk_vajra_scorecard)
# Every panel is a live run: the before runs the S167 kit straight out of git.
set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="168"
# ========================
BIN="${VAJRA_BIN:-$ROOT/target/release/vajra}"
export VAJRA_BIN="$BIN"   # the kit reads Vajra's facts from this binary (the gate sets it to itself)
S167=40fe6f7              # the S167 merge — the kit and template before this session

# Recorded at close — measured outside this deck, never re-run here (labelled "recorded").
REC_TESTS_N=506
REC_TESTS="cargo test --lib: $REC_TESTS_N pass, 0 fail"
REC_LINT="cargo clippy --all-targets -D warnings: clean · cargo fmt --check: clean"
REC_CHITRA="--dry-run: template 'would upgrade', kit 'would create' (chitra never synced S167); HEAD, status and stash identical before and after"

# ---- helpers --------------------------------------------------------------------------------
fresh_project() {  # DIR — a real empty project: git init + the real `vajra init`
  mkdir -p "$1" && ( cd "$1" && git init -q . && "$BIN" init >/dev/null 2>&1 </dev/null )
}
in_dir() { local d="$1"; shift; ( cd "$d" && "$@" ); }
# outline_demo FILE HEADLINE CASES FINISH — a full seven-section demo on the kit, as a stranger writes it
outline_demo() {
  cat > "$1" <<EOF
. "\$(cd "\$(dirname "\$0")" && pwd)/demo-kit.sh"
s1() { dk_section headline; $2; }
s2() { dk_section story; dk_p "a story"; }
s3() { dk_section before_after; dk_p "before and after"; }
s4() { dk_section rule; dk_p "the rule"; }
s5() { dk_section cases; $3; }
s6() { dk_section scorecard; dk_scorecard LIVE; }
s7() { dk_section next; dk_p "next"; }
dk_deck s1 s2 s3 s4 s5 s6 s7
$4
EOF
}
HONEST_CHECK='dk_check "the project has a constitution" test -f .ai/AGENTS.md'
TYPED_CHECK='dk_check "the project has a constitution" PASS'
first_reason() {  # the gate's own first ✗ (or ⚠) line, trimmed — the Why column is never typed
  printf '%s\n' "$1" | grep -m1 -E "^  [✗⚠] " | sed -E 's/^  [✗⚠] //; s/scripts\/demo-session-99\.sh //' | cut -c1-70
}

slide_headline() {
  dk_section headline "session $SESSION · a demo that cannot be faked · 2026-09-14"   # prints demo:header
  dk_h1 "A demo can no longer " "fake its checks or its numbers" "."
  dk_p "S167 made every Vajra demo a slide deck in the terminal. Its own review found the hole: a check could be the word PASS, and a number tile could say anything. Now checks run real commands, Vajra fills in the numbers it knows, and the close gate compares them."
  dk_vajra_tiles "$SESSION" "LIB TESTS|$REC_TESTS_N|recorded"
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Old (recorded — the S167 gate is not re-run here): dk_check \"anything\" PASS counted as a passing live check, and STATIONS|8|of 8 was free text; the gate checked exit 0 and four markers." \
    "New (live below): a bare PASS is refused by name; the tiles above come from vajra next --demo-facts; the gate re-derives every fact at close and blocks a typed number or a demo that never finished."
  dk_caption "live = ran just now · recorded = measured at close, not re-run here · filled in by Vajra = derived, never typed"
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "Checks run commands.|dk_check \"label\" <command> runs it and its real exit code decides. The words PASS, FAIL, a bare number or no command at all are refused by name, and the demo fails." \
    "Vajra fills in the numbers.|vajra next --demo-facts NN prints the stations passed, the review verdict, the advice answered and the crew — read-only. dk_vajra_tiles and dk_vajra_scorecard draw them." \
    "The gate proves it.|For a demo built on the kit, vajra next --check-demo now needs demo:complete and compares every demo:fact line with what it derives itself (DECISION-010)." \
    "Old demos keep working.|A demo not built on the kit keeps the old four-marker rule, with a warning that names the downgrade. The S167 demo was migrated — its gate runs live in the cases." \
    "Light terminals.|DEMO_THEME=light, or a light COLORFGBG, switches to deeper colors that read on a white background."
  dk_caption "\"Fact\" = a number Vajra works out from the project itself. \"Kit-built\" = a demo that sources scripts/demo-kit.sh or prints its markers."
}

slide_before_after() {
  dk_section before_after "the change · two real runs · same faked demo"   # prints demo:before_after
  dk_h2 "Before → After"
  dk_p "The input: a full seven-section demo whose only check is the word PASS (and whose tile types STATIONS 8 of 8). The same script runs on the S167 kit, read out of git, and on today's kit. The kit catches the typed PASS here; the typed tile is caught by the gate — see the next slide."
  local old="$DK_TMP/ba-old" new="$DK_TMP/ba-new" before brc after arc
  mkdir -p "$old/scripts" "$new/scripts"
  dk_check "the S167 kit is in git at $S167" git cat-file -e "$S167:scripts/demo-kit.sh"
  git show "$S167:scripts/demo-kit.sh" > "$old/scripts/demo-kit.sh"
  cp scripts/demo-kit.sh "$new/scripts/demo-kit.sh"
  outline_demo "$old/scripts/demo-session-99.sh" 'dk_metrics "STATIONS|8|of 8"' "$TYPED_CHECK" dk_finish
  cp "$old/scripts/demo-session-99.sh" "$new/scripts/demo-session-99.sh"
  # keep the marker lines, the check lines and the typed tile's value; drop the nested box chrome
  dk_run_v env -u CLAUDE_PROJECT_DIR DEMO_MODE=stream NO_COLOR=1 bash "$old/scripts/demo-session-99.sh"
  brc=$_DK_RC
  before="$(printf '%s\n' "$_DK_OUT" | grep -E '^(demo:|  [✓✗])|8 of 8' | sed 's/[│ ]\{2,\}/ /g; s/^ *//')"
  dk_run_v env -u CLAUDE_PROJECT_DIR DEMO_MODE=stream NO_COLOR=1 bash "$new/scripts/demo-session-99.sh"
  arc=$_DK_RC
  after="$(printf '%s\n' "$_DK_OUT" | grep -E '^(demo:|  [✓✗])|8 of 8' | sed 's/[│ ]\{2,\}/ /g; s/^ *//')"
  dk_compare "BEFORE|S167 kit ($S167) · exit $brc" "$before" "AFTER|today's kit · exit $arc" "$after"
  dk_caption "Both panels are live runs of the same script, just now."
  echo
  dk_check "the typed-PASS demo passed on the S167 kit (exit $brc) and today's kit refuses it by name (exit $arc)" \
    bash -c '[ "$1" = 0 ] && [ "$2" = 1 ] && printf "%s" "$3" | grep -q "refused"' _ "$brc" "$arc" "$after"
}

slide_rule() {
  dk_section rule "the rule, in plain words · every verdict below is the real gate on a fresh project"
  dk_h2 "When vajra next --check-demo lets a demo close"
  local base="$DK_TMP/rule-base" n=0 row label kind want pat d got badge facts sp why; local -a rows
  fresh_project "$base"
  sp="$(in_dir "$base" "$BIN" next --demo-facts 99 | sed -n 's/^stations_passed=//p')"
  facts="$(in_dir "$base" "$BIN" next --demo-facts 99 | sed "s/^stations_passed=.*/stations_passed=$((sp + 1))/; s/^/demo:fact /")"
  for row in \
    "an honest demo: real commands, Vajra's tiles|honest|READY|verdict: READY" \
    "a check that is just the word PASS|typed|NOT READY|exited 1" \
    "a typed tile, no facts printed at all|tile|NOT READY|prints no demo:fact" \
    "a hand-typed fact: stations $((sp + 1)) (truth: $sp)|forged|NOT READY|Vajra derives stations_passed=$sp" \
    "the demo never reaches dk_finish|unfinished|NOT READY|shows no complete" \
    "fakest green: dk_check \"x\" true|alwaystrue|READY|verdict: READY" \
    "an old demo, not on the kit, old project|legacy-old|READY|not built on" \
    "the same old demo in a new project|legacy-new|NOT READY|shows no complete"; do
    n=$((n+1)); label="${row%%|*}"; row="${row#*|}"; kind="${row%%|*}"; row="${row#*|}"
    want="${row%%|*}"; pat="${row#*|}"
    d="$DK_TMP/rule-$n"; rm -rf "$d"; cp -R "$base" "$d"
    case "$kind" in
      honest)     outline_demo "$d/scripts/demo-session-99.sh" 'dk_vajra_tiles 99' "$HONEST_CHECK" dk_finish ;;
      typed)      outline_demo "$d/scripts/demo-session-99.sh" 'dk_vajra_tiles 99' "$TYPED_CHECK" dk_finish ;;
      tile)       outline_demo "$d/scripts/demo-session-99.sh" 'dk_metrics "STATIONS|8|of 8"' "$HONEST_CHECK" dk_finish ;;
      forged)     printf '%s\n' "$facts" > "$d/forged.txt"
                  outline_demo "$d/scripts/demo-session-99.sh" "dk_metrics \"STATIONS|$((sp + 1))|of 8\"; cat forged.txt" "$HONEST_CHECK" dk_finish ;;
      unfinished) outline_demo "$d/scripts/demo-session-99.sh" 'dk_vajra_tiles 99' "$HONEST_CHECK" "" ;;
      alwaystrue) outline_demo "$d/scripts/demo-session-99.sh" 'dk_vajra_tiles 99' 'dk_check "x" true' dk_finish ;;
      legacy-*)   printf "printf 'demo:header\\\\ndemo:cases\\\\ndemo:summary_table\\\\ndemo:before_after\\\\n'\n" > "$d/scripts/demo-session-99.sh"
                  [ "$kind" = legacy-old ] && sed -i.bak 's/required_elements: \[header, cases, summary_table, before_after, complete\]/required_elements: [header, cases, summary_table, before_after]/' "$d/.ai/CONSTRAINTS.yaml" ;;
    esac
    dk_run_v in_dir "$d" "$BIN" next --check-demo 99
    if [ "$_DK_RC" = 0 ]; then got=READY; else got="NOT READY"; fi
    if [ "$got" = READY ]; then badge="${C_YES}✓ READY${C_0}"; else badge="${C_NO}✗ NOT READY${C_0}"; fi
    why="$(first_reason "$_DK_OUT")"; [ -n "$why" ] || why="$(printf '%s\n' "$_DK_OUT" | grep -m1 '^verdict:')"
    rows+=("$label|$badge|$why")
    dk_check -q "rule · $label → $want for the right reason (got $got)" \
      bash -c '[ "$1" = "$2" ] && printf "%s" "$3" | grep -q -- "$4"' _ "$got" "$want" "$_DK_OUT" "$pat"
  done
  dk_table "The demo…|Gate|The gate's own words" "${rows[@]}"
  dk_caption "Each row is a fresh folder with a real vajra init, a demo written the way a stranger would, and the real gate (vajra next --check-demo 99). The right column is the gate's first ✗ or ⚠ line, cut to fit."
}

slide_cases() {
  dk_section cases "the cases · live"   # prints demo:cases
  dk_h2 "Six things to see for yourself"
  local c1 c2 c3 c4 c5 c6 pw keys rc2 rec="$DK_TMP/recursion" up="$DK_TMP/upgrade" tiny="$DK_TMP/tiny.sh"
  local nl nd nf nn h0 h1 r tok ref="$DK_TMP/refuse" rc167
  dk_run_v "$BIN" next --demo-facts "$SESSION"
  c1="$_DK_OUT"
  keys="$(printf '%s\n' "$c1" | cut -d= -f1 | tr '\n' ' ')"

  rm -rf "$rec"; fresh_project "$rec"
  printf 'touch ran-verify\n' > "$rec/scripts/verify-session-42.sh"
  printf 'touch ran-demo\n' > "$rec/scripts/demo-session-42.sh"
  dk_run_v in_dir "$rec" "$BIN" next --demo-facts 42
  rc2=$_DK_RC
  c2="exit $rc2 · $(printf '%s\n' "$_DK_OUT" | head -1)
$(in_dir "$rec" ls ran-verify ran-demo 2>&1 | sed 's/^ls: //')"

  printf '. "%s"\ns() { dk_section headline; dk_check "ok" true; }\ndk_deck s\n' "$KIT" > "$tiny"
  nl="$(DEMO_COLOR=1 DEMO_THEME=light COLORTERM= DEMO_MODE=stream bash "$tiny" 2>/dev/null | LC_ALL=C grep -c $'\033\[38;5;56m')"
  nd="$(DEMO_COLOR=1 DEMO_THEME=dark COLORTERM= DEMO_MODE=stream bash "$tiny" 2>/dev/null | LC_ALL=C grep -c $'\033\[38;5;99m')"
  nf="$(DEMO_COLOR=1 COLORFGBG='0;15' COLORTERM= DEMO_MODE=stream bash "$tiny" 2>/dev/null | LC_ALL=C grep -c $'\033\[38;5;56m')"
  nn="$(NO_COLOR=1 DEMO_COLOR=1 DEMO_THEME=light DEMO_MODE=stream bash "$tiny" 2>/dev/null | LC_ALL=C grep -c $'\033')"
  c3="DEMO_THEME=light     → $nl line(s) in deep violet 38;5;56
DEMO_THEME=dark      → $nd line(s) in soft violet 38;5;99
COLORFGBG=0;15       → $nf line(s) in deep violet 38;5;56
NO_COLOR + light     → $nn line(s) with any escape byte"

  rm -rf "$up"; fresh_project "$up"
  git show "$S167:scripts/demo-kit.sh" > "$up/scripts/demo-kit.sh"
  printf '# vajra-render-sha: %s\n' "$(shasum -a 256 "$up/scripts/demo-kit.sh" | cut -d' ' -f1)" >> "$up/scripts/demo-kit.sh"
  h0="$(shasum -a 256 "$up/scripts/demo-kit.sh" | cut -c1-12)"
  dk_run_v in_dir "$up" "$BIN" init --sync-fleet --dry-run
  h1="$(shasum -a 256 "$up/scripts/demo-kit.sh" | cut -c1-12)"
  c4="$(printf '%s\n' "$_DK_OUT" | grep -E 'demo-kit\.sh|DRIFT')
kit sha before dry-run $h0 · after $h1"

  c5=""; mkdir -p "$ref"
  for tok in '0' '' 'FAIL'; do
    printf '. "%s"\ns() { dk_section headline; dk_check "x" %s; }\ndk_deck s\ndk_finish\n' "$KIT" "$tok" > "$ref/d.sh"
    r="$(DEMO_MODE=stream NO_COLOR=1 bash "$ref/d.sh" 2>&1)"
    c5="${c5}dk_check \"x\" ${tok:-(nothing)} → exit $? · $(printf '%s\n' "$r" | grep -c 'refused') refusal line(s)
"
  done

  dk_run_v "$BIN" next --check-demo 167
  rc167=$_DK_RC
  c6="$(printf '%s\n' "$_DK_OUT" | grep -E '^(script|verdict|  [✗⚠])' | cut -c1-80)"

  if [ "$DK_W" -ge 96 ]; then pw=$(( (DK_W - 2) / 2 ))
    dk_side "$(dk_term "1 · vajra next --demo-facts $SESSION" "$c1" "$pw")" \
            "$(dk_term "2 · facts never run a script" "$c2" "$pw")"
    dk_side "$(dk_term "3 · the light theme" "$c3" "$pw")" \
            "$(dk_term "4 · an S167-stamped kit on --sync-fleet" "$c4" "$pw")"
    dk_side "$(dk_term "5 · what the kit refuses" "$c5" "$pw")" \
            "$(dk_term "6 · the migrated S167 demo, gated live" "$c6" "$pw")"
  else
    dk_term "1 · vajra next --demo-facts $SESSION" "$c1"; dk_term "2 · facts never run a script" "$c2"
    dk_term "3 · the light theme" "$c3"; dk_term "4 · an S167-stamped kit on --sync-fleet" "$c4"
    dk_term "5 · what the kit refuses" "$c5"; dk_term "6 · the migrated S167 demo, gated live" "$c6"
  fi
  dk_check "the facts are the 9 documented keys, in order" \
    test "$keys" = "session stations_passed stations_total stations_names review recs_answered recs_total crew_handoffs crew_roles "
  dk_check "--demo-facts 42 answered (exit 0, session=42) and ran neither the verify nor the demo script" \
    bash -c '[ "$1" = 0 ] && printf "%s" "$2" | grep -q "session=42" && [ ! -e "$3/ran-verify" ] && [ ! -e "$3/ran-demo" ]' _ "$rc2" "$c2" "$rec"
  dk_check "light palette from DEMO_THEME and COLORFGBG, dark by default, no escapes under NO_COLOR" \
    test "$nl" -gt 0 -a "$nd" -gt 0 -a "$nf" -gt 0 -a "$nn" -eq 0
  dk_check "an S167-stamped kit would upgrade (no drift) and the dry-run changed nothing" \
    bash -c 'printf "%s" "$1" | grep -qE "would +upgrade scripts/demo-kit.sh" && ! printf "%s" "$1" | grep -q DRIFT && [ "$2" = "$3" ]' _ "$c4" "$h0" "$h1"
  dk_check "dk_check with 0, nothing, or FAIL: each exits 1 and names the refusal" \
    test "$(printf '%s' "$c5" | grep -c '→ exit 1 · [1-9] refusal')" = 3
  dk_check "vajra next --check-demo 167 is READY under the new gate" \
    bash -c '[ "$1" = 0 ] && printf "%s" "$2" | grep -q "verdict: READY"' _ "$rc167" "$c6"
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"   # prints demo:summary_table
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  echo
  dk_table "Recorded at close — not re-run here|Result" \
    "Rust tests|$REC_TESTS" \
    "lint|$REC_LINT" \
    "chitra (a real project on Vajra)|$REC_CHITRA"
  dk_verdict "HONEST NOTES" \
    "Fakest green: a check can run a command that is always true (dk_check \"x\" true passes — the rule slide shows it live), and a demo can draw its own tiles beside Vajra's. The gate proves the facts, not every number on screen." \
    "A hand-typed demo:fact line with the RIGHT value passes: the gate proves the value is true, not that Vajra drew it. A hand-typed echo demo:complete satisfies that element, but it also marks the demo kit-built, so every fact must then be printed and true." \
    "The facts drawn here come from this run; the gate derives them again at close, so they can differ if work lands in between. The S167 gate binary is never re-run; the rule rows use session 99 in throwaway folders." \
    "Existing projects get the fact check once they upgrade vajra and run --sync-fleet; a demo that drops every kit sign keeps the old rule until they add complete to CONSTRAINTS.yaml." \
    "Not shown: Windows, and the 0.2.0 release (after the merge, on the founder's go). A green demo is not a passing delivery — verify and the cold review are separate."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next"
  dk_table " |Session|What and why" \
    "A|S169 · tighten the close gate|The S166 review found a commit-id check that a word like 'defaced' can pass, and a close with no tech-lead." \
    "B|S170 · Ground Truth|The mandatory no-code audit (170 % 5 == 0)." \
    "C|prove it works, then cut cost|Founder priority 2: a paid end-to-end run on a real project, then make it cheaper."
  dk_h2 "Small words helper"
  dk_table "word|meaning" \
    "kit|scripts/demo-kit.sh — the drawing helpers a demo script calls." \
    "gate|A check Vajra runs before a session may close; vajra next --check-demo is the demo's gate." \
    "fact|A number Vajra works out itself: stations passed, review verdict, advice answered, crew." \
    "demo:fact|A line the demo prints for each fact; the gate compares it with its own." \
    "demo:complete|Printed only when the whole outline passed; the gate requires it." \
    "kit-built|A demo that sources the kit or prints any of its markers." \
    "fresh project|An empty folder where the real vajra init just ran — what a stranger starts with." \
    "out of git|An older version of a file read from a past commit (git show <commit>:<file>)." \
    "stream mode|The demo printed straight through, as the gate and CI see it (DEMO_MODE=stream)." \
    "dry-run / --sync-fleet|vajra init --sync-fleet updates Vajra's files in a project; --dry-run only says what it would do." \
    "fakest green|The thing that looks proven but is weakest — named so nobody oversells it." \
    "legacy / downgrade|An old demo not on the kit: it keeps the old, weaker rule, and the gate says so."
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish   # prints demo:complete only when the whole outline passed
