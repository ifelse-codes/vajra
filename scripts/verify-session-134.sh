#!/usr/bin/env bash
# verify-session-134.sh — S134: the paid dogfood in chitra (the mudra chart review).
#
# What this script can and cannot prove, said once, up front:
#   - The chart RENDERS and the chitra fingerprints live in gitignored artifact dirs (the founder's
#     S126 rule: raw captures stay local, git gets the summary + a small derived evidence record).
#     Every check that binds to them is therefore MACHINE-LOCAL — the same disclosed class as
#     `--dogfood-age` (S91), check-subagent-cost-fields.sh (S111) and the S131 dispatch gate.
#   - Machine-local + FAIL-on-absent is honest. Machine-local + skip-on-absent is a fake green.
#     A check that cannot evaluate FAILS (S69). Nothing here skips.
set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

CHITRA="${VAJRA_S134_CHITRA_ROOT:-/Users/suman/playground/chitra}"
ART="sessions/session-134-artifacts"
# The fixture points this at a sandbox copy so it NEVER mutates the tracked manifest in place
# (cold review rec 11: demo-session-134.sh invokes the fixture, so an interrupted demo used to be
# able to leave damaged tracked evidence behind).
MANIFEST="${VAJRA_S134_MANIFEST:-sessions/session-134-seen-manifest.tsv}"
GL="$ART/gate-log"

GREEN="\033[32m"; RED="\033[31m"; DIM="\033[2m"; BOLD="\033[1m"; RESET="\033[0m"
PASS=0; FAIL=0
declare -a CLASS_EXEC=(); declare -a CLASS_BYTES=(); declare -a CLASS_GREP=()

ok()   { printf "${GREEN}✓${RESET} %s\n" "$1"; PASS=$((PASS+1)); }
bad()  { printf "${RED}✗${RESET} %s\n" "$1"; FAIL=$((FAIL+1)); }
head_() { printf "\n${BOLD}══ %s ══${RESET}\n" "$1"; }

# check <class> <label> ; body returns 0/1 on stdin-less eval
chk() { local cls="$1" label="$2"; shift 2; if "$@"; then ok "$label"; else bad "$label"; fi
        case "$cls" in exec) CLASS_EXEC+=("$label");; bytes) CLASS_BYTES+=("$label");; grep) CLASS_GREP+=("$label");; esac; }

head_ "S134 verify — the paid dogfood in chitra"
printf "${DIM}chitra root: %s${RESET}\n" "$CHITRA"

# ─────────────────────────────────────────────────────────────────────────────
head_ "criterion 1 — a real run through vajra claude, binary recorded"

c_stream_exists() { [ -s "$ART/chitra-run-stream.jsonl" ]; }
chk bytes "the paid run's stream-json transcript exists and is non-empty" c_stream_exists

# The authoritative cost rides the terminal type:"result" line (S78). Absent => FAIL, never skip.
c_cost_real() {
  local v
  v=$(python3 - "$ART/chitra-run-stream.jsonl" <<'PY'
import json,sys
c=None
for line in open(sys.argv[1]):
    try: d=json.loads(line)
    except Exception: continue
    if d.get('type')=='result': c=d.get('total_cost_usd')
print(c if c is not None else '')
PY
) || return 1
  [ -n "$v" ] || return 1
  python3 -c "import sys; sys.exit(0 if float(sys.argv[1])>0 else 1)" "$v"
}
chk exec "the receipt carries a REAL authoritative total_cost_usd > 0 (not S77's honest null)" c_cost_real

# The cold fidelity reviewer named the previous version of this check as S134's FAKEST GREEN, and
# it was right: it grepped a hardcoded literal in a file the agent had typed by hand (the file even
# carried an unexpanded `$(which vajra)`). Delete the whole paid run, type one file, green. This
# version RECOMPUTES the hash of the binary on PATH right now and compares it to the recorded value
# — no literal appears in this script at all.
c_binary_recorded() {
  local f="$ART/binary-provenance.txt" rec_i rec_r live
  [ -s "$f" ] || return 1
  grep -q '\$(' "$f" && { echo "    unexpanded shell substitution in $f — hand-typed, not captured" >&2; return 1; }
  rec_i=$(awk -F': ' '/^sha256_installed:/{print $2}' "$f")
  rec_r=$(awk -F': ' '/^sha256_repo_build:/{print $2}' "$f")
  [ -n "$rec_i" ] && [ "$rec_i" = "$rec_r" ] || return 1
  live=$(shasum -a 256 "$(command -v vajra)" 2>/dev/null | cut -d' ' -f1)
  [ -n "$live" ] && [ "$live" = "$rec_i" ]
}
chk exec "the vajra binary on PATH re-hashes to the recorded sha (recomputed live, no literal)" c_binary_recorded

# ─────────────────────────────────────────────────────────────────────────────
head_ "criterion 6 — chitra's in-flight state was NOT disturbed"

c_fingerprints_exist() { [ -s "$ART/chitra-fingerprint-BEFORE.txt" ] && [ -s "$ART/chitra-fingerprint-AFTER.txt" ]; }
chk bytes "both four-way chitra fingerprints were captured" c_fingerprints_exist

# HEAD, index hash and stash count must be IDENTICAL. `git status --short` alone would miss all
# three (rec 19) — the BEFORE fingerprint caught a pre-existing stash that --short never showed.
c_fp_field_same() {
  local f="$1" b a
  b=$(grep "^$f:" "$ART/chitra-fingerprint-BEFORE.txt" 2>/dev/null) || return 1
  a=$(grep "^$f:" "$ART/chitra-fingerprint-AFTER.txt" 2>/dev/null) || return 1
  [ -n "$b" ] && [ "$b" = "$a" ]
}
chk exec "chitra HEAD unchanged"              c_fp_field_same HEAD
chk exec "chitra index hash unchanged (no staged/unstaged shuffle)" c_fp_field_same index_sha
chk exec "chitra stash list unchanged"        c_fp_field_same stash_list_count
chk exec "chitra branch unchanged"            c_fp_field_same branch

# The ONE permitted delta, declared in the prompt BEFORE the run: the review artifact, nothing else.
c_one_declared_delta() {
  local d
  d=$(diff <(sed -n '/^--- porcelain/,$p' "$ART/chitra-fingerprint-BEFORE.txt") \
           <(sed -n '/^--- porcelain/,$p' "$ART/chitra-fingerprint-AFTER.txt") | grep '^[<>]' || true)
  # exactly one added line, and it is the declared path
  [ "$(printf '%s\n' "$d" | grep -c '^>' )" -eq 1 ] || return 1
  [ "$(printf '%s\n' "$d" | grep -c '^<' )" -eq 0 ] || return 1
  printf '%s\n' "$d" | grep -q 'sessions/mudra-chart-review-2026-08-26.md'
}
chk exec "exactly ONE new path in chitra, and it is the pre-declared review artifact" c_one_declared_delta

# ─────────────────────────────────────────────────────────────────────────────
head_ "criteria 3 + 14 — every chart was SEEN, and the manifest binds to real bytes"

c_manifest_exists() { [ -s "$MANIFEST" ]; }
chk bytes "seen-manifest.tsv exists and is non-empty" c_manifest_exists

# Non-vacuity floor (the S126 lesson): a manifest that is merely well-formed but empty must not pass.
c_manifest_floor() { [ "$(tail -n +2 "$MANIFEST" | grep -c .)" -ge 7 ]; }
chk exec "manifest carries at least 7 rows (5 merged locked charts + 2 in flight)" c_manifest_floor

# Criterion 14 asks for EQUALITY against the live re-derived list, not merely a floor (cold review
# rec 3). Re-derive the locked family count from chitra's README right now and bind to it.
c_manifest_matches_rederived() {
  local readme="$CHITRA/packages/core/README.md" derived rows
  [ -f "$readme" ] || return 1
  derived=$(grep -c '^### LOCKED:' "$readme")
  [ "$derived" -gt 0 ] || return 1
  rows=$(awk -F'\t' 'NR>1 && $1!="in-flight" && $1!="unlocked-control" && NF>0 {print $1}' "$MANIFEST" | sort -u | grep -c .)
  printf "    ${DIM}(README declares %d LOCKED families; manifest covers %d)${RESET}\n" "$derived" "$rows"
  [ "$rows" -eq "$derived" ]
}
chk exec "manifest's locked-family count EQUALS the count re-derived live from chitra's README" c_manifest_matches_rederived

# `method` comes from a CLOSED vocabulary. Any other word FAILS — it does not warn.
c_method_vocab() {
  local bad_rows
  bad_rows=$(tail -n +2 "$MANIFEST" | awk -F'\t' 'NF>0 && $3!="fresh-render-terminal" && $3!="fresh-render-browser" && $3!="screenshot-existing" && $3!="code-only"' | grep -c . )
  [ "$bad_rows" -eq 0 ]
}
chk exec "every manifest row's method is in the closed vocabulary" c_method_vocab

# Every evidence_path must EXIST and its sha256 must RECOMPUTE EQUAL. Absent => FAIL (S69).
c_evidence_bytes() {
  local rc=0 n=0
  while IFS=$'\t' read -r fam chart method path sha cap src; do
    [ -n "${path:-}" ] || continue
    n=$((n+1))
    local f="$CHITRA/$path"
    if [ ! -f "$f" ]; then echo "    missing evidence: $f" >&2; rc=1; continue; fi
    local actual; actual=$(shasum -a 256 "$f" | cut -d' ' -f1)
    if [ "$actual" != "$sha" ]; then echo "    sha mismatch for $chart: $actual != $sha" >&2; rc=1; fi
  done < <(tail -n +2 "$MANIFEST")
  [ "$n" -gt 0 ] || return 1
  return $rc
}
chk bytes "every evidence file exists and its sha256 recomputes equal" c_evidence_bytes

# The stale-screenshot tooth (rec 15): evidence must not PREDATE the code it claims to show.
# DORMANT-TOOTH DISCLOSURE (cold review rec 2): on THIS session's manifest every row is
# `fresh-render-terminal`, so the stale-screenshot branch evaluates ZERO rows and would be green
# even if deleted. That is stated here rather than hidden, and the check reports how many rows it
# actually examined so a reader can see the difference between "no violations" and "nothing tested".
# The fixture's synthetic row is what genuinely exercises it.
c_no_stale_evidence() {
  local rc=0 seen=0
  while IFS=$'\t' read -r fam chart method path sha cap src; do
    [ -n "${cap:-}" ] || continue
    [ "$method" = "screenshot-existing" ] || continue
    seen=$((seen+1))
    if [[ "$cap" < "$src" ]]; then
      echo "    STALE: $chart captured $cap but source changed $src" >&2; rc=1
    fi
  done < <(tail -n +2 "$MANIFEST")
  printf "    ${DIM}(stale-screenshot rows evaluated: %d — every render this session is fresh, so the\n" "$seen"
  printf "     tooth is DORMANT here and is exercised only by fixture-session-134.sh defect 2)${RESET}\n"
  return $rc
}
chk exec "no screenshot-existing row is older than the source it claims to show" c_no_stale_evidence

# A render is only evidence if it actually contains a chart. Bind to the locked panel language.
c_renders_show_panel() {
  local rc=0 n=0
  while IFS=$'\t' read -r fam chart method path sha cap src; do
    [ -n "${path:-}" ] || continue
    [ "$fam" = "unlocked-control" ] && continue
    n=$((n+1))
    grep -q '┌╌' "$CHITRA/$path" || { echo "    no dashed panel frame in $chart" >&2; rc=1; }
  done < <(tail -n +2 "$MANIFEST")
  [ "$n" -ge 7 ] || return 1
  return $rc
}
chk bytes "every LOCKED chart's render really contains the dashed panel frame" c_renders_show_panel

# The negative control: horizontalBar is NOT in the S12 lock, and its render must prove it.
c_control_is_unlocked() {
  local p; p=$(awk -F'\t' '$1=="unlocked-control"{print $4}' "$MANIFEST" | head -1)
  [ -n "$p" ] || return 1
  ! grep -q '┌╌' "$CHITRA/$p"
}
chk bytes "negative control: horizontalBar's render has NO panel frame (it is pre-mudra)" c_control_is_unlocked

# ─────────────────────────────────────────────────────────────────────────────
head_ "criteria 8 + 9 — the gates that fired, and the mandate's outcome"

c_gatelog_populated() { [ "$(ls "$GL"/*.txt 2>/dev/null | wc -l | tr -d ' ')" -ge 4 ]; }
chk bytes "the gate-log holds at least 4 captured gate invocations" c_gatelog_populated

c_gatelog_has_exit_codes() {
  local rc=0 n=0
  for f in "$GL"/*.txt; do [ -f "$f" ] || continue; n=$((n+1))
    head -1 "$f" | grep -q '^exit_code:' || { echo "    no exit_code first line: $f" >&2; rc=1; }
  done
  [ "$n" -gt 0 ] || return 1
  return $rc
}
chk bytes "every gate-log file records its exit code on line 1" c_gatelog_has_exit_codes

# The Vajra-side mandate was satisfied by a REAL dispatch with verified provenance.
c_mandate_vajra_real() {
  grep -q '^verdict: READY' "$GL/check-design-handoff-134.txt" &&
  grep -q 'verified: toolu_' "$GL/check-design-handoff-134.txt"
}
chk bytes "S134's own mandate: READY via a dispatch whose provenance VERIFIED" c_mandate_vajra_real

# The finding itself: chitra's session 16 is exempt, and the capture proves it.
c_brownfield_hole_captured() {
  grep -q 'predates the design-advisor mandate' "$GL/chitra-check-design-handoff-16.txt" &&
  grep -q '^verdict: READY'                     "$GL/chitra-check-design-handoff-16.txt" &&
  grep -q 'handoff: (none)'                     "$GL/chitra-check-design-handoff-16.txt"
}
chk bytes "the brownfield hole is captured VERBATIM: chitra S16 gets READY with no handoff" c_brownfield_hole_captured

# The record owed by rec 12 exists and is an addendum, not a new DECISION.
c_addendum_written() {
  grep -q '## S134 addendum — the BROWNFIELD threshold hole' docs/decisions/DECISION-007-agent-fleet.md &&
  [ ! -f docs/decisions/DECISION-008*.md ] 2>/dev/null
}
chk grep "DECISION-007 carries the S134 brownfield addendum (and no premature DECISION-008)" c_addendum_written

# rec 13a — the F2f hand-check: the advice PRECEDED the work.
c_f2f_hand_check() {
  [ -s "$ART/f2f-hand-check.txt" ] && grep -q 'handoff captured:' "$ART/f2f-hand-check.txt"
}
chk bytes "the F2f timestamp comparison was done by hand and recorded" c_f2f_hand_check

# ─────────────────────────────────────────────────────────────────────────────
head_ "criteria 4 + 5 + 13 — the verdict, the separation, the design questions"

c_review_landed() { [ -s "$CHITRA/sessions/mudra-chart-review-2026-08-26.md" ]; }
chk bytes "the founder-facing review landed in chitra at the declared path" c_review_landed

c_verdict_takes_position() {
  local f="$CHITRA/sessions/mudra-chart-review-2026-08-26.md"
  grep -qi 'IMPRESSIVE' "$f" && grep -qi 'weakest' "$f"
}
chk bytes "the review takes a POSITION and names a weakest chart" c_verdict_takes_position

c_merged_vs_inflight_separated() {
  local f="$CHITRA/sessions/mudra-chart-review-2026-08-26.md"
  grep -q 'MERGED' "$f" && grep -qi 'in.flight' "$f" && grep -qi 'not merged\|NOT merged' "$f"
}
chk bytes "merged work and chitra's in-flight session-16 work are reported SEPARATELY" c_merged_vs_inflight_separated

c_design_questions_decided() {
  local p=prompts/134-task-dogfood-chitra-mudra-review.md
  grep -q 'Q1 — RESOLVED' "$p" && grep -q 'Q2 — RESOLVED' "$p" &&
  grep -q 'The loser, and its reason' "$p" && grep -q 'Rejected:' "$p"
}
chk grep "both open design questions are DECIDED with the loser's reason recorded" c_design_questions_decided

# ─────────────────────────────────────────────────────────────────────────────
head_ "the honest disclosures (these are checks too)"

c_unmetered_disclosed() {
  grep -q 'unmetered' sessions/session-134-summary.md 2>/dev/null
}
chk grep "the summary reports unmetered subagent tokens beside the dollar figure" c_unmetered_disclosed

c_losses_reported() {
  grep -qi 'cost more than it gave\|got in the way\|changed nothing' sessions/session-134-summary.md 2>/dev/null
}
chk grep "the summary names where governance cost more than it gave" c_losses_reported

# ─────────────────────────────────────────────────────────────────────────────
head_ "check-class tally"
printf "  execute-based (runs code / recomputes state) : %d\n" "${#CLASS_EXEC[@]}"
printf "  byte-bound    (binds to real captured bytes) : %d\n" "${#CLASS_BYTES[@]}"
printf "  source-grep   (weakest class — text presence): %d\n" "${#CLASS_GREP[@]}"
printf "\n  ${DIM}Machine-local by disclosure: every check reading %s.\n" "$CHITRA"
printf "  Absent evidence FAILS here; nothing skips (S69).${RESET}\n"

printf "\n${BOLD}%d passed, %d failed${RESET}\n" "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
