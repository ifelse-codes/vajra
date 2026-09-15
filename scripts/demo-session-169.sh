#!/usr/bin/env bash
# Session 169 demo — the close gate refuses made-up evidence.
# Built on scripts/demo-kit.sh (DECISION-009/010). Every verdict below is a live run of a REAL close
# gate against a REAL git fixture; the "before" is the gate read out of git at 8bdd69a (S168 merged).
set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="169"
# ========================
OLD_SHA="8bdd69a"                                   # main before S169: the gate as S168 left it
BIN="${VAJRA_BIN:-$ROOT/target/release/vajra}"
NEW_GATE="$ROOT/scripts/verify-closeout.sh"
OLD_GATE="$DK_TMP/old-gate.sh"
FX="$DK_TMP/fx"

# --- a real git fixture with one real commit ---------------------------------------------------
mkdir -p "$FX/prompts" "$FX/sessions" "$FX/.ai/handoffs"
git -C "$FX" init -q && git -C "$FX" -c user.email=d@d -c user.name=d commit -q --allow-empty -m seed
SHORT="$(git -C "$FX" rev-parse --short=7 HEAD)"
GHOST="0123456789abcdef0123456789abcdef01234567"
git show "$OLD_SHA:scripts/verify-closeout.sh" > "$OLD_GATE" 2>/dev/null
prompt() {  # N TYPE EXEC-LINE... — one real plan step per ## Execution line
  local n="$1" type="$2" i=1 l; shift 2
  { printf '# Session %s\n## Type\n- %s\n## Plan\n' "$n" "$type"
    for l in "$@"; do printf '%s. build part %s\n' "$i" "$i"; i=$((i+1)); done
    printf '## Execution\n'; for l in "$@"; do printf -- '- %s\n' "$l"; done
  } > "$FX/prompts/$n-task-fx.md"
}
gate() { env -u VAJRA_CLOSEOUT_WAIVER CLAUDE_PROJECT_DIR="$FX" bash "$@"; }
gate_waived() { local w="$1"; shift; env CLAUDE_PROJECT_DIR="$FX" VAJRA_CLOSEOUT_WAIVER="$w" bash "$@"; }
prompt 41 '**CODE**' "step 1 — done: defacedprose"
prompt 42 '**CODE**' "step 1 — done: ${SHORT:0:6}"
prompt 45 '**CODE**' "step 1 — done: $GHOST"
prompt 46 '**CODE**' "step 1 — done: $SHORT"
prompt 48 '**CODE**' "step 1 — done: $SHORT" "step 2 — pending: the release waits for the merge"
prompt 51 '**CODE**' "step 1 — done: $SHORT"
printf '**Verdict:** ACCEPT (fidelity-reviewer, all SHIPPED)\n' > "$FX/sessions/session-51-summary.md"
prompt 54 '**CODE**' "step 1 — done: $SHORT"
prompt 55 '**NO-CODE** ground truth' "step 1 — done: $SHORT"
prompt 71 '**CODE**' "step 1 — done: defaced prose" "step 2 — pending: the release waits for the merge"

slide_headline() {
  dk_section headline "session $SESSION · the close gate refuses made-up evidence · 2026-09-15"
  dk_h1 "A session can no longer " "close on made-up evidence" "."
  dk_p "S166 closed with a summary that claimed a review nobody ran, no tech-lead, and a founder waiver that let every close check pass. Now the close gate checks that every recorded commit is real, that every plan step has one, and a waiver cannot back a claim."
  dk_vajra_tiles "$SESSION"
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Old (live on the next slide, the gate read out of git at $OLD_SHA): 'done: defaced prose' passed, a 'pending:' plan step passed, and VAJRA_CLOSEOUT_WAIVER passed a claimed review with no review file." \
    "New: a done: must name a whole 7–40 hex sha that git finds, every plan step needs one, and the claimed-evidence check has no waiver path — in Vajra's gate and in the one vajra init hands a stranger."
  dk_caption "live = ran just now · recorded = measured at close, not re-run here · filled in by Vajra = derived, never typed"
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "Real commits only.|A done: line must name a whole 7–40 character hex sha, and git must find that commit. 'done: defaced prose' used to pass because 'defaced' is seven hex letters." \
    "Every plan step lands.|A plan step with no done: sha — like S168's 'pending:' release — now blocks at close, not only when the next session starts." \
    "Post-merge work gets its own row.|A release can only happen after the merge, so it goes in its own ROADMAP row, never a plan step. Nobody needs VAJRA_SKIP_CODER_GATE for it again (DECISION-007, S169 addendum)." \
    "A waiver cannot back a claim.|If the summary claims a verdict, the review file and the fidelity-reviewer handoff must exist; a CODE session needs its tech-lead file. The founder waiver does not skip this check." \
    "Strangers get it too.|The close gate vajra init scaffolds carries the same checks; verify-session-169.sh runs every case on both gates."
  dk_caption "sha = the short id git gives a commit. waiver = VAJRA_CLOSEOUT_WAIVER=N, a founder-set switch that used to pass every close check."
}

slide_before_after() {
  dk_section before_after "the change · two real runs · same made-up record"
  dk_h2 "Before → After"
  dk_p "The input: a CODE prompt whose ## Execution says 'step 1 — done: defaced prose' and 'step 2 — pending: the release waits for the merge'. The same prompt goes through the gate at $OLD_SHA and the gate today."
  local before brc after arc
  dk_check "the old gate is in git at $OLD_SHA" git cat-file -e "$OLD_SHA:scripts/verify-closeout.sh"
  dk_run_v gate "$OLD_GATE" --check-exec-shas 71
  brc=$_DK_RC; before="$(printf '%s\n' "$_DK_OUT" | grep -E '^(EXEC-SHAS|BAD-SHA|OK:|BLOCK)' | cut -c1-90)"
  dk_run_v gate "$NEW_GATE" --check-exec-shas 71
  arc=$_DK_RC; after="$(printf '%s\n' "$_DK_OUT" | grep -E '^(EXEC-SHAS|BAD-SHA|OK:|BLOCK)' | cut -c1-90)"
  dk_compare "BEFORE|gate at $OLD_SHA · exit $brc" "$before" "AFTER|gate today · exit $arc" "$after"
  dk_caption "Both panels are live runs of the same prompt, just now."
  echo
  dk_check "old gate passed (exit $brc); new gate blocks (exit $arc), naming the made-up sha AND the pending step" \
    bash -c '[ "$1" = 0 ] && [ "$2" = 1 ] && printf "%s" "$3" | grep -q "NO-SUCH-COMMIT defaced" && printf "%s" "$3" | grep -q "NO-DONE step 2"' _ "$brc" "$arc" "$after"
}

slide_rule() {
  dk_section rule "the rule, in plain words · every verdict below is the real gate on the fixture"
  dk_h2 "When the close gate lets a record through"
  local row label n kind want pat got badge why; local -a rows
  for row in \
    "done: a real 7-char commit sha|46|exec|PASS|EXEC-SHAS: PASS" \
    "done: defacedprose (hex glued to prose)|41|exec|BLOCK|BAD-SHA" \
    "done: a 6-char sha|42|exec|BLOCK|BAD-SHA" \
    "done: a well-formed sha with no commit|45|exec|BLOCK|NO-SUCH-COMMIT" \
    "step 2 — pending: the release|48|exec|BLOCK|NO-DONE step 2" \
    "summary claims ACCEPT, no review · waiver set|51|waived|BLOCK|NOT WAIVABLE" \
    "CODE session, no tech-lead file · waiver set|54|waived|BLOCK|session-54-tech-lead.md" \
    "ground-truth session, no tech-lead file|55|claimed|PASS|N/A: session 55"; do
    label="${row%%|*}"; row="${row#*|}"; n="${row%%|*}"; row="${row#*|}"
    kind="${row%%|*}"; row="${row#*|}"; want="${row%%|*}"; pat="${row#*|}"
    case "$kind" in
      exec)    dk_run_v gate "$NEW_GATE" --check-exec-shas "$n" ;;
      waived)  dk_run_v gate_waived "$n" "$NEW_GATE" --check-claimed "$n" ;;
      claimed) dk_run_v gate "$NEW_GATE" --check-claimed "$n" ;;
    esac
    if [ "$_DK_RC" = 0 ]; then got=PASS; badge="${C_YES}✓ PASS${C_0}"; else got=BLOCK; badge="${C_NO}✗ BLOCK${C_0}"; fi
    # the line that decided it: a block reason first, then N/A, then OK
    why="$(printf '%s\n' "$_DK_OUT" | grep -m1 -E '^(BAD-SHA|NOT WAIVABLE|BLOCK)' | sed -E 's/^BAD-SHA: +//')"
    [ -n "$why" ] || why="$(printf '%s\n' "$_DK_OUT" | grep -m1 -E '^N/A')"
    [ -n "$why" ] || why="$(printf '%s\n' "$_DK_OUT" | grep -m1 -E '^OK')"
    why="$(printf '%s' "$why" | cut -c1-64)"
    rows+=("$label|$badge|$why")
    dk_check -q "rule · $label → $want for the right reason (got $got)" \
      bash -c '[ "$1" = "$2" ] && printf "%s" "$3" | grep -qF -- "$4"' _ "$got" "$want" "$_DK_OUT" "$pat"
  done
  dk_table "The record…|Gate|The gate's own words" "${rows[@]}"
  dk_caption "Each row runs scripts/verify-closeout.sh against the fixture. The right column is the gate's own first line, cut to fit."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "Three things to see for yourself"
  local init="$DK_TMP/init" full old_rows
  # 1 — a stranger's gate, from a real vajra init.
  mkdir -p "$init"; git -C "$init" init -q
  dk_run_v bash -c 'cd "$1" && "$2" init </dev/null >/dev/null 2>&1 && test -f scripts/verify-closeout.sh' _ "$init" "$BIN"
  dk_run_v gate_waived 51 "$init/scripts/verify-closeout.sh" --check-claimed 51
  dk_term "1 · the gate a fresh vajra init scaffolds · summary claims ACCEPT, no review, waiver set" \
    "$(printf '%s\n' "$_DK_OUT" | grep -E '^(BLOCK|NOT WAIVABLE|CLAIMED)' | cut -c1-110)"
  dk_check "the scaffolded gate refuses the waiver too (exit $_DK_RC)" \
    bash -c '[ "$1" = 1 ] && printf "%s" "$2" | grep -q "NOT WAIVABLE"' _ "$_DK_RC" "$_DK_OUT"
  # 2 — the full close under the waiver: the old gate has no such check; the new one refuses.
  echo 51 > "$FX/.ai/SESSION"
  dk_run_v gate_waived 51 "$OLD_GATE"; old_rows="$(printf '%s\n' "$_DK_OUT" | grep -cE '^claimed-evidence-real')"
  dk_run_v gate_waived 51 "$NEW_GATE"; full="$_DK_OUT"
  rm -f "$FX/.ai/SESSION"
  dk_term "2 · the full close under VAJRA_CLOSEOUT_WAIVER=51 (new gate; old gate rows for this check: $old_rows)" \
    "$(printf '%s\n' "$full" | grep -E '^(fidelity-review-accept|claimed-evidence-real|RED|ALL GREEN)')"
  dk_check "the waiver still passes the review check, but claimed-evidence-real FAILs; the old gate had no such row" \
    bash -c '[ "$1" = 0 ] && printf "%s" "$2" | grep -qE "^fidelity-review-accept +PASS" && printf "%s" "$2" | grep -qE "^claimed-evidence-real +FAIL"' _ "$old_rows" "$full"
  # 3 — this session's own record.
  dk_run_v bash "$NEW_GATE" --check-claimed "$SESSION"
  dk_term "3 · session $SESSION's own record" "$(printf '%s\n' "$_DK_OUT" | grep -E '^(OK|N/A|BLOCK|CLAIMED)')"
  dk_check "session $SESSION has its tech-lead file (exit $_DK_RC)" \
    bash -c '[ "$1" = 0 ] && printf "%s" "$2" | grep -q "session-169-tech-lead.md"' _ "$_DK_RC" "$_DK_OUT"
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_table "Recorded at close — not re-run here|Result" \
    "scripts/verify-session-169.sh|31 pass, 0 fail — every case on Vajra's gate and the scaffolded one" \
    "cargo test --release --lib|509 passed" \
    "old gate ($OLD_SHA), same fixtures|passed prose + pending; no claimed-evidence check"
  dk_verdict "HONEST NOTES" \
    "Fakest green: the claimed-evidence check proves the files EXIST, not that they are real — that is the fidelity and attestation checks' job. And a made-up done: sha is still waivable: only the claimed-evidence check refuses the waiver (the design-advisor's scope)." \
    "Not shown: the Rust Coder gate is unchanged (design-advisor rec 4); the closed S167 and S168 prompts now fail --check-exec-shas (old sessions are never re-graded); nothing proves a post-merge ROADMAP row is ever carried out."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next"
  dk_table " |Option|Why pick it · the risk" \
    "S170|Ground truth (no code) — mandatory|every 5th session · risk: none, it is the rule" \
    "A|Publish vajractl 0.2.0 (crates.io + brew)|the tag is out, crates.io still has 0.1.0 · risk: founder-typed, irreversible" \
    "B|S168 review recs 1–3|DECISION-010 wording + a disclosed-floor row · risk: small" \
    "C|Make a made-up done: sha unwaivable too|closes this demo's fakest green · risk: a NO-CODE close that needs it"
  dk_table "word|meaning" \
    "close gate|scripts/verify-closeout.sh — a session is not done until it exits 0" \
    "waiver|VAJRA_CLOSEOUT_WAIVER=N, set by the founder to excuse missing evidence" \
    "claim|a line in the record saying something happened (a verdict, a commit)" \
    "scaffold|the files vajra init writes into a new project"
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
