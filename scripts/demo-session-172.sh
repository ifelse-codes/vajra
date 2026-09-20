#!/usr/bin/env bash
# Session 172 demo — the founder's own rudra run, and the nine things it broke.
# Built on scripts/demo-kit.sh (DECISION-009/010). Every panel below is a live run against a real
# git fixture; the "before" is this repo read out of git at 1d30a97 — main as S171 left it, BEFORE
# this session (never `main`, which is now the after-state: that is F40, fixed here).
set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="172"
OLD_SHA="1d30a97"          # main before S172: the merge of S171
# ========================
export VAJRA_BIN="${VAJRA_BIN:-$ROOT/target/release/vajra}"
BIN="$VAJRA_BIN"
OLD_BIN="$DK_TMP/vajra-old"          # built only if it is cheap to; otherwise the old side is shown from source
FX="$DK_TMP/fx"

# --- a real repo, mid-session: session 02 closed and MERGED, session 03 about to start ----------
mk_repo() { # mk_repo <dir> <summary-on-main: yes|no>
  local d="$1" on_main="$2"
  mkdir -p "$d/.ai" "$d/prompts" "$d/sessions"
  printf 'maturity: L2\n' > "$d/.ai/CONSTRAINTS.yaml"
  printf '02\n' > "$d/.ai/SESSION"
  printf '# S02\n\n## Next session candidates\n1. a\n2. b\n3. c\n' > "$d/sessions/session-02-summary.md"
  printf '# Session 03\n\n> **Status:** APPROVED\n\n## Type\n- **CODE**\n\n## Goal\n- ship x\n\n## Deliverables\n1. x\n\n## Acceptance\n1. x works\n\n## Design\n- design-significant: no — pure fix\n\n## Plan\n- step 1 — do x. covers: 1\n\n## Guardrails\n- none\n\n## Delta\n- `+` x\n' \
    > "$d/prompts/03-task-fx.md"
  git -C "$d" init -q -b main
  if [ "$on_main" = yes ]; then git -C "$d" add -A; else git -C "$d" add .ai prompts; fi
  git -C "$d" -c user.email=d@d -c user.name=d commit -qm seed
  git -C "$d" checkout -qb session-03-x
}
adv() { ( cd "$1" && echo n | "$BIN" next --advance 2>&1 ); }

# --- rudra's ADR layout: ten records in docs/ADR/ADR-NNN-title.md ------------------------------
ADR="$DK_TMP/adr"; mkdir -p "$ADR/docs/ADR" "$ADR/prompts" "$ADR/.ai"
printf 'maturity: L2\n' > "$ADR/.ai/CONSTRAINTS.yaml"
printf '# ADR-010: Foundation v0.1 scope\n' > "$ADR/docs/ADR/ADR-010-foundation.md"
adr_prompt() { printf '# S05\n\n## Type\n- **CODE**\n\n## Design\n- design-significant: yes\n- %s\n' "$1" > "$ADR/prompts/05-task-fx.md"; }

slide_headline() {
  dk_section headline "session $SESSION · the founder used Vajra on his own project · 2026-09-20"
  dk_h1 "A session you already merged is " "never graded again" "."
  dk_p "The founder ran his own project's session 03 under Vajra and pasted what he hit. Nine problems came out. The worst: starting a new session made him redo the PREVIOUS session's paperwork — work he had already merged days before. The checks moved to where they still make sense: before the merge."
  dk_vajra_tiles "$SESSION"
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Old: 'vajra next --advance' re-graded the session it was closing — but that session had already merged, sometimes under older rules. It blocked the new session until the old paperwork was rewritten." \
    "New: if your summary is on main, those checks REPORT. They BLOCK earlier instead, in the close check you run before merging — which gained the three they were missing."
  dk_caption "live = ran just now · recorded = measured at close, not re-run here · filled in by Vajra = derived, never typed"
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What this session did"
  dk_bullets \
    "The founder tested it himself.|He ran rudra session 03 end to end. Nine findings, F35 to F43, each written down with how bad it was before anything was fixed." \
    "Merged work is left alone.|Vajra asks git one question: is this session's summary on main? If yes, the human shipped it, and the checks report instead of blocking." \
    "The teeth moved earlier, not away.|The close check you run before merging gained the three checks that only existed at the next session's start: advice answered, tests live, demo live." \
    "Vajra can see real design records.|rudra keeps ten records in docs/ADR/. Vajra looked only for docs/adr/ and found none, so it silently skipped the check — a made-up record would have passed." \
    "The riskiest untested change now has a test.|Last session split the commit rules so they stop the agent and let you through. Six tests now run the real hooks; the qa-specialist settled the eleven cases first."
  dk_caption "advice answered = every recommendation a specialist gave has a recorded answer. In rudra, five were unanswered and the close still said 'all green'."
}

slide_before_after() {
  dk_section before_after "the change · two real runs · the same repo"
  dk_h2 "Before → After"
  dk_p "The input: a repo whose session 02 is closed and merged, standing on the session 03 branch, running 'vajra next --advance'. The old binary is built from git at $OLD_SHA; the new one is today's."
  local before brc after arc repo_old repo_new
  dk_check "the old Vajra is in git at $OLD_SHA" git cat-file -e "$OLD_SHA:src/cli/next.rs"
  repo_old="$DK_TMP/r-old"; mk_repo "$repo_old" yes
  repo_new="$DK_TMP/r-new"; mk_repo "$repo_new" yes
  if [ -x "$OLD_BIN" ]; then
    dk_run_v env -C "$repo_old" sh -c "echo n | '$OLD_BIN' next --advance 2>&1"
  else
    # No old binary built: show the old wiring from git — the gate list with no merged-session branch.
    dk_run_v bash -c "git show $OLD_SHA:src/cli/next.rs | grep -c 'cannot close'"
    _DK_OUT="the old --advance had $(git show "$OLD_SHA:src/cli/next.rs" | grep -c 'cannot close') closing gates
and NO branch for a merged session:
  \$ git show $OLD_SHA:src/cli/next.rs | grep -c shipped_close
  $(git show "$OLD_SHA:src/cli/next.rs" | grep -c shipped_close)
so every one of them BLOCKED work the human had merged."
    _DK_RC=0
  fi
  brc=$_DK_RC; before="$_DK_OUT"
  dk_run_v bash -c "cd '$repo_new' && echo n | '$BIN' next --advance 2>&1 | grep -E 'already merged|not re-running' | sed -E 's/ ?\(sessions[^)]*\)//; s/^ +//'"
  arc=$_DK_RC; after="$_DK_OUT"
  dk_compare "BEFORE|Vajra at $OLD_SHA" "$before" "AFTER|Vajra today · live" "$after"
  dk_caption "The right panel is a live run, just now, against a real git repo made for this demo."
  echo
  dk_check "today's advance reports on the merged session instead of blocking it" \
    bash -c 'printf "%s" "$1" | grep -q "already merged by you"' _ "$after"
  dk_check "and skips the slow re-runs of its tests and demo" \
    bash -c 'printf "%s" "$1" | grep -q "not re-running"' _ "$after"
  dk_check "the old code had no such branch (shipped_close appears $(git show "$OLD_SHA:src/cli/next.rs" | grep -c shipped_close) times at $OLD_SHA)" \
    bash -c '[ "$(git show "$1:src/cli/next.rs" | grep -c shipped_close)" = 0 ]' _ "$OLD_SHA"
}

slide_rule() {
  dk_section rule "the rule, in plain words · every verdict below is live"
  dk_h2 "When a check blocks you, and when it just tells you"
  local -a rows; local out
  # 1 — merged session: reports.
  local m="$DK_TMP/rule-merged"; mk_repo "$m" yes
  out="$(adv "$m")"
  dk_check -q "rule · summary on main → reports" bash -c 'printf "%s" "$1" | grep -q "already merged by you"' _ "$out"
  rows+=("your summary is on main (you merged it)|${C_YES}✓ REPORTS${C_0}|already merged by you — reporting, not blocking")
  # 2 — unmerged session: blocks.
  local u="$DK_TMP/rule-unmerged"; mk_repo "$u" no
  out="$(adv "$u")"
  dk_check -q "rule · summary not on main → still blocks" bash -c 'printf "%s" "$1" | grep -q "cannot close"' _ "$out"
  rows+=("your summary is NOT on main (still open)|${C_NO}✗ BLOCKS${C_0}|$(printf '%s' "$out" | grep -m1 'cannot close' | cut -c1-58)")
  # 3/4 — the close check, before the merge: a failing gate blocks, an old binary cannot evaluate.
  live_gate() { # live_gate <fake vajra body> -> RESULT=
    local d="$DK_TMP/lg.$RANDOM"; mkdir -p "$d/bin"
    cp "$ROOT/scripts/verify-closeout-scaffold.sh" "$d/gate.sh"
    printf '#!/bin/sh\n%s\n' "$1" > "$d/bin/vajra"; chmod +x "$d/bin/vajra"
    ( cd "$d" && PATH="$d/bin:/usr/bin:/bin" bash -c '
        source /dev/stdin <<<"$(sed -n "/^check_live_gate()/,/^}/p" gate.sh)"
        N=72; ARTIFACTS=.; ok(){ echo RESULT=PASS; }; bad(){ echo RESULT=FAIL; }; waiver_ok(){ false; }
        check_live_gate advice-answered --check-advice "=== advice: dispositions for session" "answer them"' )
  }
  out="$(live_gate 'echo "=== advice: dispositions for session 72 ==="; exit 1')"
  dk_check -q "rule · close check, advice unanswered → blocks" bash -c 'printf "%s" "$1" | grep -q RESULT=FAIL' _ "$out"
  rows+=("close check (before merge), advice unanswered|${C_NO}✗ BLOCKS${C_0}|the check that used to live only at the next start")
  out="$(live_gate 'echo "=== vajra: handoff packet ==="; exit 0')"
  dk_check -q "rule · close check, vajra too old to judge → blocks" bash -c 'printf "%s" "$1" | grep -q RESULT=FAIL' _ "$out"
  rows+=("close check, vajra too old to run it|${C_NO}✗ BLOCKS${C_0}|a check that cannot evaluate fails, never greens")
  # 5/6 — the design record citation, rudra's layout.
  adr_prompt "the slice rests on ADR-010's locked scope, extending it at the adapter boundary."
  ( cd "$ADR" && "$BIN" next --check-design 05 >/dev/null 2>&1 ) && out=PASS || out=BLOCK
  dk_check -q "rule · real record in docs/ADR/ → passes" bash -c '[ "$1" = PASS ]' _ "$out"
  rows+=("cites ADR-010, a real file in docs/ADR/|${C_YES}✓ PASSES${C_0}|found: ADR-0010 — Foundation v0.1 scope")
  adr_prompt "the slice rests on ADR-077's locked scope, extending it at the adapter boundary."
  ( cd "$ADR" && "$BIN" next --check-design 05 >/dev/null 2>&1 ) && out=PASS || out=BLOCK
  dk_check -q "rule · made-up record → blocks" bash -c '[ "$1" = BLOCK ]' _ "$out"
  rows+=("cites ADR-077, which does not exist|${C_NO}✗ BLOCKS${C_0}|before today this WAIVED itself and passed")
  dk_table "The situation…|Vajra|Why" "${rows[@]}"
  dk_caption "Each row ran just now. 'Reports' means it prints the problem and lets you carry on; 'blocks' means it stops and says what to fix."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "Four things to see for yourself"
  # 1 — the commit/push belt test.
  dk_run_v cargo test -q --test commit_belt
  dk_term "1 · the commit and push rules, tested against the real hook files" \
    "$(printf '%s\n' "$_DK_OUT" | grep -E 'running|test result' | cut -c1-96)"
  dk_check "six belt tests pass (agent stopped · human through · main closed to both)" \
    bash -c '[ "$1" = 0 ] && printf "%s" "$2" | grep -q "6 passed"' _ "$_DK_RC" "$_DK_OUT"
  # 2 — the reading pause only names what you have not read.
  local L="$DK_TMP/loader"; mkdir -p "$L/.ai"
  printf 'maturity: L2\ncopilot:\n  on:\n    - "prompts/* => .ai/TASK.md, .ai/ROADMAP.md | re-read the contract"\n' > "$L/.ai/CONSTRAINTS.yaml"
  loader() { printf '%s\n' "$1" > "$L/t.jsonl"
    echo "{\"session_id\":\"$2\",\"transcript_path\":\"$L/t.jsonl\",\"tool_input\":{\"file_path\":\"$L/prompts/03-x.md\"}}" \
      | CLAUDE_PROJECT_DIR="$L" VAJRA_COPILOT_STATE_DIR="$L/st-$2" bash "$ROOT/scripts/hook-copilot-loader.sh" 2>&1; }
  local none one
  none="$(loader '{}' a)"; one="$(loader '{"x":"----- .ai/TASK.md -----"}' b)"
  dk_term "2 · the pause when nothing was read → both files · when TASK.md was read at boot → only the other" \
    "$(printf '%s\n%s\n' "$none" "$one" | grep -E 'paused|- \.ai' | cut -c1-96)"
  dk_check "the pause names only the file that was not read yet" \
    bash -c 'printf "%s" "$1" | grep -q ROADMAP && ! printf "%s" "$1" | grep -q TASK' _ "$one"
  # 3 — boot warns about a handover pointing at a file that does not exist (rudra's own case).
  local H="$DK_TMP/boot"; mkdir -p "$H/.ai" "$H/prompts"
  printf '# Task\n\nRead prompt: author `prompts/03-execution-oms-ems.md` first.\n' > "$H/.ai/TASK.md"
  : > "$H/prompts/03-task-execution-oms-ems.md"
  dk_run_v env CLAUDE_PROJECT_DIR="$H" bash "$ROOT/scripts/hook-session-start.sh"
  dk_term "3 · rudra's real session-02 handover, at boot" \
    "$(printf '%s\n' "$_DK_OUT" | grep 'hook warn' | cut -c1-110)"
  dk_check "boot names the missing file and suggests the real one" \
    bash -c 'printf "%s" "$1" | grep -q "Did it mean prompts/03-task-execution-oms-ems.md"' _ "$_DK_OUT"
  # 4 — the fixes reach a project that already exists.
  local sync_target="${VAJRA_SYNC_TARGET:-$HOME/playground/rudra}"
  if [ -d "$sync_target/.git" ]; then
    local C="$DK_TMP/rc"; git clone -q "$sync_target" "$C" 2>/dev/null
    dk_run_v bash -c "cd '$C' && '$BIN' init --sync-fleet 2>&1 | tail -12"
    dk_term "4 · vajra init --sync-fleet on a copy of the founder's own project" \
      "$(printf '%s\n' "$_DK_OUT" | grep -E 'upgrade|created,' | cut -c1-96)"
    dk_check "the changed files upgrade cleanly, nothing counted as hand-edited" \
      bash -c 'printf "%s" "$1" | grep -qE "^0 created, [0-9]+ upgraded, .*0 drifted"' _ "$_DK_OUT"
  else
    dk_term "4 · vajra init --sync-fleet on an existing project" "no project at $sync_target — set VAJRA_SYNC_TARGET to see this one"
    dk_check "a real project to sync into is present" test -d "$sync_target/.git"
  fi
}

slide_scorecard() {
  dk_section scorecard "the scorecard"
  dk_h2 "Every check on this deck, and the session's own numbers"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "every check on this deck · live"
  dk_caption "Top box: filled in by Vajra from this session's own records. Bottom box: every check on this deck, each one a live run."
}

slide_next() {
  dk_section next "what is next"
  dk_h2 "Where this leaves us"
  dk_bullets \
    "The close check is now the only enforcement.|Before today, skipping it was caught when the next session started. It is not caught anywhere now — run scripts/verify-closeout.sh on the branch before merging. Written down in DECISION-007, S172 addendum." \
    "One question is still yours.|An agent can commit without approval on a branch not named session-NN-. Close that, or record it as deliberate?" \
    "The next test is rudra session 04.|Sync the fixes in, start it, and see whether the nine fixes hold against a real run."
  dk_caption "Every limit above is written in the session summary too, not only said here."
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
