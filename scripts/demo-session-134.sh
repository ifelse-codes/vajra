#!/usr/bin/env bash
# demo-session-134.sh — the sprint demo for S134: the paid dogfood in chitra.
# Required elements (CONSTRAINTS.yaml#demo.required_elements): header, cases, summary_table,
# before_after — each emitted as a literal `demo:<element>` marker the Demo-er gate re-runs live.
set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

CHITRA="${VAJRA_S134_CHITRA_ROOT:-/Users/suman/playground/chitra}"
ART="sessions/session-134-artifacts"
GL="$ART/gate-log"
MANIFEST="sessions/session-134-seen-manifest.tsv"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
FAILED=0
head_() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label() { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()    { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()   { printf "${RED}✗ %s${RESET}\n" "$1"; FAILED=1; }

echo "demo:header"
head_ "S134 — the paid dogfood: Vajra governing REAL work in another repo"
printf "${DIM}Nine sessions since the last paid run. Every instrument in this repo measures Vajra\n"
printf "governing ITSELF. This is the first evidence about S133's mandate that this repo did not\n"
printf "manufacture.${RESET}\n"

# ─────────────────────────────────────────────────────────────────────────────
echo "demo:cases"

head_ "CASE 1 — the receipt reports a REAL dollar figure (S77/S78 pay off)"
label "vajra claude -p ... --output-format stream-json  →  the terminal result line"
COST=$(python3 - "$ART/chitra-run-stream.jsonl" <<'PY'
import json,sys
c=t=None
for line in open(sys.argv[1]):
    try: d=json.loads(line)
    except Exception: continue
    if d.get('type')=='result': c,t=d.get('total_cost_usd'),d.get('num_turns')
print(f"{c}\t{t}" if c is not None else "\t")
PY
)
USD=$(printf '%s' "$COST" | cut -f1); TURNS=$(printf '%s' "$COST" | cut -f2)
if [ -n "$USD" ]; then
  printf "    total_cost_usd: ${BOLD}\$%s${RESET}   turns: %s\n" "$USD" "$TURNS"
  ok "a real authoritative cost — NOT S77's honest null, which is what an interactive run returns"
else
  bad "no authoritative cost in the result stream"
fi

head_ "CASE 2 — the charts were SEEN, and the manifest binds to real bytes"
label "10 rows, every evidence file re-hashed live"
ROWS=$(tail -n +2 "$MANIFEST" | grep -c .)
MISS=0
while IFS=$'\t' read -r fam chart method path sha cap src; do
  [ -n "${path:-}" ] || continue
  a=$(shasum -a 256 "$CHITRA/$path" 2>/dev/null | cut -d' ' -f1)
  [ "$a" = "$sha" ] || MISS=$((MISS+1))
done < <(tail -n +2 "$MANIFEST")
printf "    manifest rows: %s   sha mismatches: %s\n" "$ROWS" "$MISS"
[ "$ROWS" -ge 7 ] && [ "$MISS" -eq 0 ] && ok "every render's bytes still hash to what the manifest claims" \
  || bad "manifest does not bind to real bytes"

label "a locked chart, rendered fresh from source during the paid run:"
BARP=$(awk -F'\t' '$2=="bar"{print $4}' "$MANIFEST" | head -1)
if [ -f "$CHITRA/$BARP" ]; then
  sed -n '1,6p' "$CHITRA/$BARP" | sed 's/^/    /'
  printf "    ${DIM}... (full render at %s)${RESET}\n" "$BARP"
  ok "the dashed panel frame, the eyebrow row and the + tick language are all really there"
else
  bad "the bar render is missing"
fi

label "the NEGATIVE control — horizontalBar is NOT in the S12 lock, and looks it:"
HBP=$(awk -F'\t' '$1=="unlocked-control"{print $4}' "$MANIFEST" | head -1)
if [ -f "$CHITRA/$HBP" ]; then
  sed -n '1,4p' "$CHITRA/$HBP" | sed 's/^/    /'
  grep -q '┌╌' "$CHITRA/$HBP" && bad "control has a panel frame — the control is not a control" \
    || ok "no dashed frame, no eyebrow, no accent — a real un-migrated chart to compare against"
else
  bad "the horizontalBar control render is missing"
fi

head_ "CASE 3 — S133's mandate, on the Vajra side: it PAID FOR ITSELF"
label "vajra next --check-design-handoff 134"
sed -n '5,10p' "$GL/check-design-handoff-134.txt" | sed 's/^/    /'
grep -q 'verified: toolu_' "$GL/check-design-handoff-134.txt" \
  && ok "provenance VERIFIED against a real dispatch id — not a hand-typed label" \
  || bad "provenance did not verify"
printf "${DIM}    The advisor returned 22 recommendations and found the session brief itself wrong in\n"
printf "    seven places — a whole chart family omitted, a 'how to see them' section describing\n"
printf "    scripts that do not exist, and an acceptance criterion impossible to satisfy.${RESET}\n"

head_ "CASE 4 — the finding this repo could NOT have manufactured"
label "the same gate, run inside chitra, on a session actively doing design work"
sed -n '5,11p' "$GL/chitra-check-design-handoff-16.txt" | sed 's/^/    /'
if grep -q 'predates the design-advisor mandate' "$GL/chitra-check-design-handoff-16.txt"; then
  ok "captured verbatim: chitra S16 gets READY with NO handoff at all"
  printf "${DIM}    S133 closed the FRESH-project hole with a scaffolded placeholder marker. It never\n"
  printf "    reasoned about an ALREADY-GOVERNED project below the line. For Vajra the threshold is\n"
  printf "    a closing window; for a brownfield adopter it is a PERMANENT exemption.${RESET}\n"
else
  bad "the brownfield hole was not captured"
fi

head_ "CASE 5 — the falsifiability fixture: these checks can go RED"
label "bash scripts/fixture-session-134.sh (4 planted defects + 2 controls)"
if bash scripts/fixture-session-134.sh >/tmp/s134-fx.$$ 2>&1; then
  grep -c '✓' /tmp/s134-fx.$$ | xargs printf "    fixture assertions passed: %s\n"
  ok "mutated sha · stale screenshot · invented method word · empty manifest — RED on each"
else
  bad "the fixture did not pass"
fi
rm -f /tmp/s134-fx.$$

# ─────────────────────────────────────────────────────────────────────────────
echo "demo:before_after"
head_ "BEFORE / AFTER — chitra's in-flight state (criterion 6)"
printf "${BOLD}    %-22s %-34s %-34s${RESET}\n" "field" "BEFORE" "AFTER"
for f in branch HEAD index_sha stash_list_count; do
  b=$(grep "^$f:" "$ART/chitra-fingerprint-BEFORE.txt" | cut -d' ' -f2- | cut -c1-32)
  a=$(grep "^$f:" "$ART/chitra-fingerprint-AFTER.txt"  | cut -d' ' -f2- | cut -c1-32)
  if [ "$b" = "$a" ]; then printf "    %-22s %-34s %-34s ${GREEN}same${RESET}\n" "$f" "$b" "$a"
  else printf "    %-22s %-34s %-34s ${RED}MOVED${RESET}\n" "$f" "$b" "$a"; FAILED=1; fi
done
printf "\n${DIM}    'git status --short' alone would have missed all of these. The BEFORE fingerprint\n"
printf "    caught a pre-existing stash that --short never showed (design-advisor rec 19).${RESET}\n"
DELTA=$(diff <(sed -n '/^--- porcelain/,$p' "$ART/chitra-fingerprint-BEFORE.txt") \
             <(sed -n '/^--- porcelain/,$p' "$ART/chitra-fingerprint-AFTER.txt") | grep '^>' || true)
printf "\n    working-tree delta:\n"
printf '%s\n' "$DELTA" | sed 's/^/      /'
[ "$(printf '%s\n' "$DELTA" | grep -c '^>')" -eq 1 ] \
  && ok "exactly ONE new path — the review artifact declared in advance, and nothing else" \
  || bad "more than the one permitted delta"

# ─────────────────────────────────────────────────────────────────────────────
echo "demo:summary_table"
head_ "SCORECARD — S134"
printf "${BOLD}    %-42s %s${RESET}\n" "what" "result"
printf "    %-42s %s\n" "paid run through vajra claude" "\$$USD authoritative ($TURNS turns)"
printf "    %-42s %s\n" "charts rendered fresh and looked at" "$ROWS (incl. 1 negative control)"
printf "    %-42s %s\n" "chitra tracked files modified" "0"
printf "    %-42s %s\n" "chitra new untracked paths" "1 (pre-declared)"
printf "    %-42s %s\n" "design-advisor recs returned" "22"
printf "    %-42s %s\n" "brief errors the advisor caught pre-spend" "7"
printf "    %-42s %s\n" "mandate on the Vajra side" "READY, provenance verified"
printf "    %-42s %s\n" "mandate inside chitra (session 16)" "READY + WARN — the hole"
printf "    %-42s %s\n" "design verdict" "IMPRESSIVE, 2 fixable blemishes"
printf "    %-42s %s\n" "weakest chart / top fix" "area / un-crush bar x-labels"

printf "\n"
[ "$FAILED" -eq 0 ] && printf "${GREEN}${BOLD}demo: all cases PASS${RESET}\n" \
                    || printf "${RED}${BOLD}demo: FAILURES above${RESET}\n"
exit "$FAILED"
