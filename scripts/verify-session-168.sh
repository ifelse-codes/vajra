#!/usr/bin/env bash
# verify-session-168.sh — S168: a demo that cannot be faked (DECISION-010).
# Behavioral: every check runs the real release binary, the real kit or a real script, and each
# block names the failure it catches. No check greps Rust source.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
check() { local name="$1"; shift; if "$@"; then ok "$name"; else bad "$name"; fi; }
has() { printf '%s' "$1" | grep -q -- "$2"; }   # has TEXT PATTERN

BIN="$ROOT/target/release/vajra"
CHITRA="${VAJRA_CHITRA:-/Users/suman/playground/chitra}"
S167=40fe6f7   # the S167 merge — the kit before this session
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
[ -x "$BIN" ] || { echo "FAIL: release binary missing — run cargo build --release"; exit 1; }

fresh() { mkdir -p "$1" && ( cd "$1" && git init -q . && "$BIN" init >/dev/null 2>&1 </dev/null ); }
FRESH="$T/fresh"; fresh "$FRESH"

# deck FILE HEADLINE CASES FINISH — a full seven-section demo on the kit (in a fresh project)
deck() {
  cat > "$1" <<EOF
. "\$(cd "\$(dirname "\$0")" && pwd)/demo-kit.sh"
s1() { dk_section headline; $2; }
s2() { dk_section story; }
s3() { dk_section before_after; }
s4() { dk_section rule; }
s5() { dk_section cases; $3; }
s6() { dk_section scorecard; dk_vajra_scorecard 99; dk_scorecard LIVE; }
s7() { dk_section next; }
dk_deck s1 s2 s3 s4 s5 s6 s7
$4
EOF
}
run_deck() { ( cd "$FRESH" && env -u CLAUDE_PROJECT_DIR VAJRA_BIN="$BIN" DEMO_MODE=stream "$@" bash scripts/d.sh 2>&1 </dev/null ); }
REAL='dk_check "a constitution exists" test -f .ai/AGENTS.md'

# ---------------------------------------------------------------------------
# AC1: dk_check runs a command; bare tokens are refused by name; -q still counts.
# FALSIFIABILITY: the S167 kit (case AC1f) passes the typed PASS — the same deck that must fail here.
# ---------------------------------------------------------------------------
for tok in PASS FAIL 0 ''; do
  deck "$FRESH/scripts/d.sh" 'dk_vajra_tiles 99' "dk_check \"x\" $tok" dk_finish
  out="$(run_deck)"; rc=$?
  check "AC1a: dk_check \"x\" ${tok:-(no command)} exits non-zero (got $rc)" test "$rc" -ne 0
  check "AC1a: ...and names the refusal" has "$out" "refused"
  check "AC1a: ...and never prints demo:complete" bash -c "! printf '%s' \"\$1\" | grep -q '^demo:complete'" _ "$out"
done
deck "$FRESH/scripts/d.sh" 'dk_vajra_tiles 99' 'dk_check "fails" false' dk_finish
out="$(run_deck)"; rc=$?
check "AC1b: a failing command is a FAIL and the demo exits non-zero (got $rc)" bash -c "[ $rc -ne 0 ] && printf '%s' \"\$1\" | grep -q '✗ fails (exit 1)'" _ "$out"
deck "$FRESH/scripts/d.sh" 'dk_vajra_tiles 99' "$REAL; dk_check -q \"hidden\" false" dk_finish
out="$(run_deck)"; rc=$?
check "AC1c: -q hides the line but the failure still counts (exit $rc)" \
  bash -c "[ $rc -ne 0 ] && printf '%s' \"\$1\" | grep -q '1 of 2 live checks FAILED' && ! printf '%s' \"\$1\" | grep -q '✗ hidden (exit'" _ "$out"
deck "$FRESH/scripts/d.sh" 'dk_vajra_tiles 99' "$REAL; dk_check -q \"quiet ok\" true" dk_finish
HONEST="$(run_deck)"; rc=$?
check "AC1d: real passing commands → exit 0 with demo:complete (got $rc)" bash -c "[ $rc -eq 0 ] && printf '%s' \"\$1\" | grep -q '^demo:complete$'" _ "$HONEST"
mkdir -p "$T/s167kit/scripts"; git show "$S167:scripts/demo-kit.sh" > "$T/s167kit/scripts/demo-kit.sh"
deck "$T/s167kit/scripts/d.sh" ':' 'dk_check "x" PASS' dk_finish   # the S167 kit has no dk_vajra_* —
sed -i.bak 's/dk_vajra_scorecard 99; //' "$T/s167kit/scripts/d.sh"  # same typed-PASS deck otherwise
( cd "$T/s167kit" && DEMO_MODE=stream bash scripts/d.sh >/dev/null 2>&1 </dev/null ); rc=$?
check "AC1f: the SAME typed-PASS deck passed on the S167 kit (exit $rc) — AC1a can fail" test "$rc" -eq 0

# ---------------------------------------------------------------------------
# AC2: vajra next --demo-facts — 9 keys in order, read-only, exit 0 even when nothing is known.
# FALSIFIABILITY: a missing/reordered key, a non-zero exit, or a sentinel file created by a script.
# ---------------------------------------------------------------------------
facts="$("$BIN" next --demo-facts 168 2>&1)"; rc=$?
check "AC2a: --demo-facts 168 exits 0" test "$rc" -eq 0
check "AC2a: 9 keys in the documented order" test "$(printf '%s\n' "$facts" | cut -d= -f1 | tr '\n' ' ')" = "session stations_passed stations_total stations_names review recs_answered recs_total crew_handoffs crew_roles "
REC="$T/rec"; fresh "$REC"
printf 'touch "%s/ran-verify"\n' "$REC" > "$REC/scripts/verify-session-42.sh"
printf 'touch "%s/ran-demo"\n' "$REC" > "$REC/scripts/demo-session-42.sh"
f42="$(cd "$REC" && "$BIN" next --demo-facts 42 2>&1)"; rc=$?
check "AC2b: an empty project answers with exit 0 (got $rc)" test "$rc" -eq 0
check "AC2b: ...absent facts print none / 0" bash -c "printf '%s' \"\$1\" | grep -qx 'review=none' && printf '%s' \"\$1\" | grep -qx 'recs_total=0'" _ "$f42"
check "AC2c: deriving the facts ran neither the verify nor the demo script (no recursion)" test ! -e "$REC/ran-verify" -a ! -e "$REC/ran-demo"

# ---------------------------------------------------------------------------
# AC3: Vajra-filled tiles + scorecard show exactly the --demo-facts values, labelled, one demo:fact each.
# FALSIFIABILITY: a typed or missing fact line differs from the binary's own output.
# ---------------------------------------------------------------------------
f99="$(cd "$FRESH" && "$BIN" next --demo-facts 99)"
first_block="$(printf '%s\n' "$HONEST" | grep '^demo:fact ' | head -9 | sed 's/^demo:fact //')"
check "AC3a: the demo:fact lines equal vajra next --demo-facts 99, line for line" test "$first_block" = "$f99"
check "AC3b: one demo:fact per fact from the tiles AND from the scorecard (18 lines)" test "$(printf '%s\n' "$HONEST" | grep -c '^demo:fact ')" -eq 18
check "AC3c: the tiles are labelled filled in by Vajra" has "$HONEST" "filled in by Vajra"
check "AC3c: the scorecard is labelled filled in by Vajra" has "$HONEST" "Filled in by Vajra · session 99"

# ---------------------------------------------------------------------------
# AC4 + AC6: the NEW gate on a stranger project (real vajra init, real demo, real gate).
# FALSIFIABILITY: each fake must block FOR ITS OWN REASON (the pattern), and the honest one must pass.
# ---------------------------------------------------------------------------
sp="$(printf '%s\n' "$f99" | sed -n 's/^stations_passed=//p')"
gate_row() {  # NAME WANT_RC PATTERN HEADLINE CASES FINISH [legacy-old|legacy-new]
  local d="$T/g-$1" out rc
  rm -rf "$d"; cp -R "$FRESH" "$d"
  case "${7:-}" in
    legacy-*) printf "printf 'demo:header\\\\ndemo:cases\\\\ndemo:summary_table\\\\ndemo:before_after\\\\n'\n" > "$d/scripts/demo-session-99.sh"
              [ "$7" = legacy-old ] && sed -i.bak 's/, complete\]/]/' "$d/.ai/CONSTRAINTS.yaml" ;;
    *) deck "$d/scripts/demo-session-99.sh" "$4" "$5" "$6" ;;
  esac
  printf '%s\n' "$f99" | sed "s/^stations_passed=.*/stations_passed=$((sp + 1))/; s/^/demo:fact /" > "$d/forged.txt"
  out="$(cd "$d" && "$BIN" next --check-demo 99 2>&1)"; rc=$?
  if [ "$2" = 0 ]; then check "AC4/AC6 $1: gate exits 0 (got $rc)" test "$rc" -eq 0
  else check "AC4/AC6 $1: gate blocks (got $rc)" test "$rc" -ne 0; fi
  check "AC4/AC6 $1: ...for the right reason ('$3')" has "$out" "$3"
}
gate_row honest       0 "verdict: READY"                     'dk_vajra_tiles 99' "$REAL" dk_finish
gate_row typed-pass   1 "exited 1"                           'dk_vajra_tiles 99' 'dk_check "x" PASS' dk_finish
gate_row forged-fact  1 "Vajra derives stations_passed=$sp"  'cat forged.txt' "$REAL" dk_finish
gate_row typed-tile   1 "prints no demo:fact"                'dk_metrics "STATIONS|8|of 8"' "$REAL" 'dk_finish'
gate_row no-finish    1 "shows no complete"                  'dk_vajra_tiles 99' "$REAL" ''
gate_row legacy-old   0 "not built on"                       '' '' '' legacy-old
gate_row legacy-new   1 "shows no complete"                  '' '' '' legacy-new
check "AC6: the scaffold's CONSTRAINTS.yaml requires complete" grep -q 'required_elements: \[header, cases, summary_table, before_after, complete\]' "$FRESH/.ai/CONSTRAINTS.yaml"

# Rust fixtures for the gate (typed PASS · forged fact · no dk_finish · honest · echoed signs).
cargo test --quiet --lib demoer:: > "$T/demoer-tests.txt" 2>&1; rc=$?
check "AC4: the Demo-er gate's Rust fixtures pass (exit $rc)" test "$rc" -eq 0
for t in kit_demo_honest_passes_with_no_downgrade_warning kit_demo_with_a_typed_pass_blocks \
         kit_demo_with_a_forged_fact_blocks_naming_it kit_demo_that_never_reaches_dk_finish_blocks \
         hand_echoed_kit_signs_make_the_demo_kit_built demo_facts_never_runs_a_script; do
  cargo test --quiet --lib "$t" -- --exact --list 2>/dev/null | grep -q "$t: test" \
    && ok "AC4: fixture exists: $t" || bad "AC4: fixture missing: $t"
done

# ---------------------------------------------------------------------------
# AC5: the design decision is on the record.
# FALSIFIABILITY: a missing record, pointer, or decision on the open question.
# ---------------------------------------------------------------------------
D=docs/decisions/DECISION-010-unfakeable-demo.md
check "AC5a: DECISION-010 exists" test -f "$D"
check "AC5b: it answers how the gate knows a demo is kit-built" grep -q "kit-built" "$D"
check "AC5c: it says what existing projects get, and when" grep -q "What existing projects get, and when" "$D"
check "AC5d: DECISION-009 points at DECISION-010" grep -q "overturned by DECISION-010" docs/decisions/DECISION-009-terminal-demo.md
check "AC5e: this repo's CONSTRAINTS.yaml requires complete" grep -q 'before_after, complete\]' .ai/CONSTRAINTS.yaml
check "AC5f: the prompt's Design cites DECISION-010 and the Architect gate reads it" bash -c "'$BIN' next --check-design 168 2>&1 | grep -q 'verdict: READY'"

# ---------------------------------------------------------------------------
# AC7: S167 renders upgrade as StaleRender; chitra dry-run is read-only.
# FALSIFIABILITY: a Drifted state (needing the risky flag) or any change in chitra.
# ---------------------------------------------------------------------------
UP="$T/up"; fresh "$UP"
for f in scripts/demo-kit.sh scripts/demo-session-template.sh; do
  git show "$S167:$f" > "$UP/$f"
  printf '# vajra-render-sha: %s\n' "$(shasum -a 256 "$UP/$f" | cut -d' ' -f1)" >> "$UP/$f"
done
up_out="$(cd "$UP" && "$BIN" init --sync-fleet --dry-run 2>&1)"
check "AC7a: S167-stamped kit → would upgrade" has "$up_out" "would   upgrade scripts/demo-kit.sh"
check "AC7a: S167-stamped template → would upgrade" has "$up_out" "would   upgrade scripts/demo-session-template.sh"
( cd "$UP" && "$BIN" init --sync-fleet >/dev/null 2>&1 ); rc=$?
check "AC7b: the real sync upgrades both without --overwrite-drifted (exit $rc)" bash -c "[ $rc -eq 0 ] && cmp -s '$UP/scripts/demo-kit.sh' '$FRESH/scripts/demo-kit.sh' && cmp -s '$UP/scripts/demo-session-template.sh' '$FRESH/scripts/demo-session-template.sh'"
cargo test --quiet --lib s167_stamped_kit_and_template_upgrade_as_stale_renders > /dev/null 2>&1; rc=$?
check "AC7c: the Rust StaleRender test passes (exit $rc)" test "$rc" -eq 0
if [ -d "$CHITRA/.git" ]; then
  st() { git -C "$CHITRA" rev-parse HEAD; git -C "$CHITRA" status --porcelain; git -C "$CHITRA" stash list; }
  s0="$(st)"; c_out="$(cd "$CHITRA" && "$BIN" init --sync-fleet --dry-run 2>&1)"; s1="$(st)"
  check "AC7d: chitra dry-run lists the template as an upgrade" has "$c_out" "would   upgrade scripts/demo-session-template.sh"
  check "AC7d: chitra dry-run lists the kit (create — chitra never synced S167)" has "$c_out" "scripts/demo-kit.sh"
  check "AC7e: chitra HEAD, status and stash identical before and after" test "$s0" = "$s1"
else
  bad "AC7: chitra not found at $CHITRA — cannot evaluate (set VAJRA_CHITRA)"
fi

# ---------------------------------------------------------------------------
# AC8: light theme by DEMO_THEME / COLORFGBG; NO_COLOR clean; boxes straight at 100 and 72.
# FALSIFIABILITY: the dark code under a light setting, any escape under NO_COLOR, a crooked box.
# ---------------------------------------------------------------------------
LIGHT=$'\033[38;5;56m'; DARK=$'\033[38;5;99m'
o="$(run_deck DEMO_COLOR=1 COLORTERM= DEMO_THEME=light)"
check "AC8a: DEMO_THEME=light prints the light accent, not the dark one" bash -c "printf '%s' \"\$1\" | LC_ALL=C grep -qF \"\$2\" && ! printf '%s' \"\$1\" | LC_ALL=C grep -qF \"\$3\"" _ "$o" "$LIGHT" "$DARK"
o="$(run_deck DEMO_COLOR=1 COLORTERM= COLORFGBG='0;15')"
check "AC8b: COLORFGBG=0;15 (light background) picks the light accent" bash -c "printf '%s' \"\$1\" | LC_ALL=C grep -qF \"\$2\"" _ "$o" "$LIGHT"
o="$(run_deck DEMO_COLOR=1 COLORTERM= COLORFGBG='15;0')"
check "AC8c: a dark background keeps the dark accent" bash -c "printf '%s' \"\$1\" | LC_ALL=C grep -qF \"\$2\"" _ "$o" "$DARK"
o="$(run_deck NO_COLOR=1 DEMO_COLOR=1 DEMO_THEME=light)"
check "AC8d: NO_COLOR prints zero escape bytes" bash -c "! printf '%s' \"\$1\" | LC_ALL=C grep -q $'\033'" _ "$o"
boxes_straight() {  # FILE MAXWIDTH
  python3 - "$1" "$2" <<'PY'
import re, sys
text = re.sub(r'\x1b\[[0-9;?]*[A-Za-z]', '', open(sys.argv[1], encoding='utf-8').read())
rows = [list(l) for l in text.split('\n')]; bad = boxes = 0
for i, row in enumerate(rows):
    for c, ch in enumerate(row):
        if ch not in '┌┏': continue
        tr, bl, br, v = ('┓', '┗', '┛', '┃') if ch == '┏' else ('┐', '└', '┘', '│')
        try: r = row.index(tr, c + 1)
        except ValueError: bad += 1; continue
        boxes += 1; closed = False
        for below in rows[i + 1:]:
            lc = below[c] if c < len(below) else ''; rc = below[r] if r < len(below) else ''
            if lc == bl: bad += rc != br; closed = True; break
            if lc != v or rc != v: bad += 1; closed = True; break
        bad += not closed
widest = max(len(r) for r in rows)
sys.exit(0 if boxes > 0 and bad == 0 and widest <= int(sys.argv[2]) else 1)
PY
}
for w in 100 72; do
  run_deck DEMO_WIDTH=$w > "$T/w$w.txt"
  check "AC8e: Vajra tiles + scorecard boxes straight within $w columns" boxes_straight "$T/w$w.txt" "$w"
done

# ---------------------------------------------------------------------------
# AC9: S167's demo + verify migrated and green.
# FALSIFIABILITY: either script red, or the S167 demo failing the new gate.
# ---------------------------------------------------------------------------
( DEMO_MODE=stream bash scripts/demo-session-167.sh >/dev/null 2>&1 </dev/null ); rc=$?
check "AC9a: demo-session-167.sh exits 0 (got $rc)" test "$rc" -eq 0
bash scripts/verify-session-167.sh > "$T/v167.txt" 2>&1; rc=$?
check "AC9b: verify-session-167.sh exits 0 (got $rc; $(grep -c '^PASS:' "$T/v167.txt") checks)" test "$rc" -eq 0

# ---------------------------------------------------------------------------
# AC10: demo-producer dispatched for real, answered, brief updated.
# FALSIFIABILITY: a hand-written handoff (no verified provenance), an unanswered rec, a brief with no facts rule.
# ---------------------------------------------------------------------------
H=.ai/handoffs/session-168-demo-producer.md
check "AC10a: the demo-producer handoff exists with verified dispatch provenance" grep -q '^agent: claude-code-subagent (verified: toolu_' "$H"
check "AC10b: the Advice gate finds every recommendation answered" bash -c "'$BIN' next --check-advice 168 >/dev/null 2>&1"
DP="$FRESH/.claude/agents/demo-producer.md"
for w in dk_vajra_tiles dk_vajra_scorecard 'dk_check \\"label\\" <command' demo:header demo:cases demo:summary_table demo:before_after demo:complete; do
  check "AC10c: the scaffolded demo-producer names '$w'" grep -q "$w" "$DP"
done
check "AC10d: it keeps tools: Read, Grep, Glob" grep -qx "tools: Read, Grep, Glob" "$DP"
check "AC10e: this repo's demo-producer.md matches the fresh render (stamp aside)" \
  bash -c "diff <(grep -v '^vajra-render-sha: ' '$DP') '$ROOT/.claude/agents/demo-producer.md' >/dev/null"

# ---------------------------------------------------------------------------
# AC11: the S168 demo — stream run, the new gate, and the deck in a pseudo-terminal.
# FALSIFIABILITY: a red demo, a before that does not pass on the S167 kit, a gate block, keys ignored.
# ---------------------------------------------------------------------------
DEMO_MODE=stream bash scripts/demo-session-168.sh > "$T/d168.txt" 2>&1 </dev/null; rc=$?
check "AC11a: demo-session-168.sh exits 0 in stream mode (got $rc)" test "$rc" -eq 0
check "AC11a: its before runs the S167 kit out of git and passed there (exit 0)" grep -q "S167 kit ($S167) · exit 0" "$T/d168.txt"
check "AC11a: its after refuses the same demo on today's kit (exit 1)" grep -q "today's kit · exit 1" "$T/d168.txt"
check "AC11b: it prints Vajra's facts for session 168" grep -q '^demo:fact session=168$' "$T/d168.txt"
check "AC11c: vajra next --check-demo 168 exits 0 under the new gate" bash -c "'$BIN' next --check-demo 168 >/dev/null 2>&1"
pty_run() {  # KEYS OUTFILE
  python3 - "$ROOT/scripts/demo-session-168.sh" "$1" "$2" <<'PY'
import os, pty, select, sys, time
script, keys, outfile = sys.argv[1:4]
pid, fd = pty.fork()
if pid == 0:
    os.environ.pop('DEMO_MODE', None)
    os.execvp('bash', ['bash', script])
buf = b''
def pump(secs):
    global buf
    end = time.time() + secs
    while time.time() < end:
        r, _, _ = select.select([fd], [], [], 0.1)
        if r:
            try: d = os.read(fd, 65536)
            except OSError: return
            if not d: return
            buf += d
pump(8)
for k in keys:
    os.write(fd, k.encode()); pump(8)
pump(6)
_, st = os.waitpid(pid, 0)
open(outfile, 'wb').write(buf)
sys.exit(os.WEXITSTATUS(st) if os.WIFEXITED(st) else 99)
PY
}
pty_run "nnnnnnn" "$T/pty.txt"; rc=$?
check "AC11d: in a terminal it plays as a deck (alternate screen)" bash -c "LC_ALL=C grep -q $'\033\\[?1049h' '$T/pty.txt'"
check "AC11d: seven key presses reach 'demo complete' (exit $rc)" bash -c "[ $rc -eq 0 ] && grep -q 'demo complete' '$T/pty.txt'"

# ---------------------------------------------------------------------------
# AC12: non-regression.
# FALSIFIABILITY: any failing test/lint, a red stranger/drift check, the kit missing from the crate.
# ---------------------------------------------------------------------------
check "AC12a: cargo test --lib passes" bash -c "cargo test --quiet --lib 2>&1 | grep -q 'test result: ok'"
check "AC12b: cargo clippy -D warnings is clean" bash -c "cargo clippy --quiet --all-targets -- -D warnings >/dev/null 2>&1"
check "AC12c: cargo fmt --check is clean" cargo fmt --check
check "AC12d: scripts/stranger-check.sh is green" bash -c "bash scripts/stranger-check.sh >/dev/null 2>&1"
check "AC12e: scripts/scaffold-drift.sh is green" bash -c "bash scripts/scaffold-drift.sh >/dev/null 2>&1"
check "AC12f: cargo package --list includes scripts/demo-kit.sh" \
  bash -c "cargo package --list --allow-dirty 2>/dev/null | grep -qx 'scripts/demo-kit.sh'"

echo ""
echo "=== verify-session-168.sh ==="
echo "PASS: $PASS  FAIL: $FAIL"
[ "$FAIL" -eq 0 ] && echo "ALL PASS — exit 0" && exit 0
echo "FAILURES — exit 1" && exit 1
