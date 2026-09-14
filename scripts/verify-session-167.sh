#!/usr/bin/env bash
# verify-session-167.sh — S167: every Vajra demo plays as a rich story in the terminal.
# Every check runs the real binary, the real scaffolded kit/template, or the real toolchain.
# FALSIFIABILITY: each check names the specific failure it would catch.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
check() { local name="$1"; shift; if "$@"; then ok "$name"; else bad "$name"; fi; }

BIN="$ROOT/target/release/vajra"
CHITRA="${VAJRA_CHITRA:-/Users/suman/playground/chitra}"
PRE=fab1b79   # main just before S167
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
[ -x "$BIN" ] || { echo "FAIL: release binary missing — run cargo build --release"; exit 1; }

# A fresh `vajra init` in an empty directory — the stranger's view.
FRESH="$T/fresh"; mkdir -p "$FRESH"
( cd "$FRESH" && git init -q . && "$BIN" init >/dev/null 2>&1 </dev/null )

# Box straightness: every ┌/┏ has its partner corner on the line and straight edges down to the
# bottom corners; color escapes are stripped first. Prints nothing; exit 0 = straight + within width.
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

# ---------------------------------------------------------------------------
# AC1: init scaffolds the kit; a deck sourced from it runs under /bin/bash with no terminal.
# FALSIFIABILITY: a missing kit, a byte-counted (crooked) box, a line past the width, or color
# leaking under NO_COLOR each fail one check below.
# ---------------------------------------------------------------------------
check "AC1a: vajra init scaffolds scripts/demo-kit.sh" test -f "$FRESH/scripts/demo-kit.sh"
cat > "$FRESH/scripts/demo-sample.sh" <<'DECK'
set -uo pipefail
. "$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
s1() { dk_section headline "sample"; dk_h1 "A " "sample" " deck."; dk_metrics "A|1|of 1" "B|2|live" "C|3" "D|4|recorded" "E|5"; dk_verdict "ONE BREATH" "Old: nothing." "New: something ✓ with a long line that must wrap across the heavy box because it keeps going past the width."; }
s2() { dk_section story; dk_bullets "Lead.|a bullet long enough to wrap around the column edge at seventy-two columns for sure."; }
s3() { dk_section before_after; dk_run_v printf 'old\nline two\n'; local b="$_DK_OUT"; dk_run_v printf 'new ✓\n'; dk_compare "BEFORE|old" "$b" "AFTER|new" "$_DK_OUT"; dk_check "differs" PASS; }
s4() { dk_section rule; dk_table "In|Out|Why" "done: abc1234|✓ pass|a real id" "done: (prose that is long and clips past forty two columns)|✗ block|words words words words words words words words words words words"; }
s5() { dk_section cases; dk_term "1 · a case" "$(printf '\033[1mbold output from a command\033[0m that is long enough to wrap inside the terminal panel for sure yes')"; dk_check "case" 0; }
s6() { dk_section scorecard; dk_scorecard "LIVE"; }
s7() { dk_section next; dk_caption "the end"; }
dk_deck s1 s2 s3 s4 s5 s6 s7
dk_finish
DECK
for w in 100 72; do
  out="$T/sample-$w.txt"
  ( cd "$FRESH" && env -u DEMO_MODE -u NO_COLOR DEMO_WIDTH=$w /bin/bash scripts/demo-sample.sh > "$out" 2>&1 </dev/null ); rc=$?
  check "AC1b: sample deck exits 0 at width $w (got $rc)" test "$rc" -eq 0
  check "AC1c: every box straight and within $w columns" boxes_straight "$out" "$w"
done
( cd "$FRESH" && NO_COLOR=1 DEMO_COLOR=1 /bin/bash scripts/demo-sample.sh > "$T/nocolor.txt" 2>&1 </dev/null )
check "AC1d: NO_COLOR prints zero escape bytes (even a command's own color)" bash -c "! LC_ALL=C grep -q $'\033' '$T/nocolor.txt'"
( cd "$FRESH" && DEMO_COLOR=1 /bin/bash scripts/demo-sample.sh > "$T/color.txt" 2>&1 </dev/null )
check "AC1e: DEMO_COLOR=1 does print escapes (AC1d can fail)" bash -c "LC_ALL=C grep -q $'\033' '$T/color.txt'"
( cd "$FRESH" && env -i PATH="$PATH" LC_ALL=C LANG=C DEMO_KIT_LOCALE=keep DEMO_WIDTH=72 /bin/bash scripts/demo-sample.sh > "$T/bytes.txt" 2>&1 </dev/null )
check "AC1f: boxes stay straight with no UTF-8 locale at all" boxes_straight "$T/bytes.txt" 72

# ---------------------------------------------------------------------------
# AC2: an unedited template copy fails naming every section; a filled one passes with 4 markers.
# FALSIFIABILITY: the pre-S167 template passed unedited (exit 0) — that is exactly what AC2a catches.
# ---------------------------------------------------------------------------
cp "$FRESH/scripts/demo-session-template.sh" "$FRESH/scripts/demo-session-99.sh"
( cd "$FRESH" && DEMO_MODE=stream bash scripts/demo-session-99.sh > "$T/empty.txt" 2>&1 </dev/null ); rc=$?
check "AC2a: unedited template copy exits non-zero (got $rc)" test "$rc" -ne 0
flat="$(tr -s ' \n' '  ' < "$T/empty.txt")"
check "AC2b: the failure names all seven unfilled sections" \
  bash -c "printf '%s' \"\$1\" | grep -q 'unfilled section(s): headline, story, before_after, rule, cases, scorecard, next'" _ "$flat"
sed 's/^\([[:space:]]*\)dk_todo .*/\1dk_check "this section ran a live check" PASS/' \
  "$FRESH/scripts/demo-session-template.sh" > "$FRESH/scripts/demo-session-98.sh"
( cd "$FRESH" && DEMO_MODE=stream bash scripts/demo-session-98.sh > "$T/filled.txt" 2>&1 </dev/null ); rc=$?
check "AC2c: the filled outline exits 0 (got $rc)" test "$rc" -eq 0
for m in header before_after cases summary_table; do
  check "AC2d: filled outline prints demo:$m" grep -q "^demo:$m\$" "$T/filled.txt"
done

# ---------------------------------------------------------------------------
# AC3: the HTML-deck rule is gone from the scaffold and this repo; the terminal demo is the human demo;
# the scaffolded demo-producer proposes the whole outline, names the 4 elements, stays read-only.
# FALSIFIABILITY: any surviving "interactive_html" / "interactive HTML slide deck" fails AC3a.
# ---------------------------------------------------------------------------
for f in "$FRESH/scripts/demo-session-template.sh" "$FRESH/.ai/AGENTS.md" "$FRESH/.ai/CONSTRAINTS.yaml" \
         "$ROOT/.ai/AGENTS.md" "$ROOT/.ai/CONSTRAINTS.yaml"; do
  check "AC3a: no HTML-deck rule in ${f#"$T/"}" bash -c "! grep -q 'interactive_html\|interactive HTML slide deck' '$f'"
done
check "AC3b: scaffolded constitution says the terminal demo IS the human demo" grep -q "The terminal demo IS the human demo" "$FRESH/.ai/AGENTS.md"
check "AC3c: scaffolded template says the terminal demo IS the human demo" grep -q "THE TERMINAL DEMO IS THE HUMAN DEMO" "$FRESH/scripts/demo-session-template.sh"
DP="$FRESH/.claude/agents/demo-producer.md"
for w in headline story before_after rule cases scorecard next demo:header demo:cases demo:summary_table demo:before_after; do
  check "AC3d: scaffolded demo-producer names '$w'" grep -q "$w" "$DP"
done
check "AC3e: scaffolded demo-producer keeps tools: Read, Grep, Glob" grep -qx "tools: Read, Grep, Glob" "$DP"
check "AC3f: this repo's demo-producer.md matches the fresh render (stamp aside)" \
  bash -c "diff <(grep -v '^vajra-render-sha: ' '$DP') '$ROOT/.claude/agents/demo-producer.md' >/dev/null"

# ---------------------------------------------------------------------------
# AC4: --sync-fleet through the states, with the real binary.
# FALSIFIABILITY: a sync that overwrote a hand edit, skipped a missing kit, demanded the risky flag
# for an untouched shipped template, or wrote during --dry-run fails one check.
# ---------------------------------------------------------------------------
sync_out="$(cd "$FRESH" && "$BIN" init --sync-fleet --dry-run 2>&1)"
check "AC4a: fresh scaffold reports the template up to date" bash -c "printf '%s' \"\$1\" | grep -q 'demo-session-template.sh (up to date)'" _ "$sync_out"
check "AC4a: fresh scaffold reports the kit up to date" bash -c "printf '%s' \"\$1\" | grep -q 'demo-kit.sh (up to date)'" _ "$sync_out"
P="$T/proj"; cp -R "$FRESH" "$P"; rm "$P/scripts/demo-kit.sh"
( cd "$P" && "$BIN" init --sync-fleet --dry-run >/dev/null 2>&1 )
check "AC4e: --dry-run writes nothing (the missing kit is still missing)" test ! -e "$P/scripts/demo-kit.sh"
( cd "$P" && "$BIN" init --sync-fleet >/dev/null 2>&1 )
check "AC4b: a missing kit is created, byte-identical to a fresh scaffold" cmp -s "$P/scripts/demo-kit.sh" "$FRESH/scripts/demo-kit.sh"
git show "$PRE:scripts/demo-session-template.sh" > "$P/scripts/demo-session-template.sh"
up_out="$(cd "$P" && "$BIN" init --sync-fleet 2>&1)"; rc=$?
check "AC4c: an untouched shipped template upgrades without --overwrite-drifted (exit $rc)" test "$rc" -eq 0
check "AC4c: ...and is now the current render" cmp -s "$P/scripts/demo-session-template.sh" "$FRESH/scripts/demo-session-template.sh"
check "AC4c: a stamped OLDER render upgrades too (Rust test)" \
  bash -c "cargo test --quiet --lib sync_fleet_carries_the_demo_template_and_kit_through_every_state 2>&1 | grep -q 'test result: ok. 1 passed'"
printf '# my own tweak\n' >> "$P/scripts/demo-kit.sh"; before="$(shasum "$P/scripts/demo-kit.sh")"
drift_out="$(cd "$P" && "$BIN" init --sync-fleet 2>&1)"; rc=$?
check "AC4d: a hand-edited kit is refused (non-zero exit, got $rc)" test "$rc" -ne 0
check "AC4d: the refusal names --overwrite-drifted" bash -c "printf '%s' \"\$1\" | grep -q -- '--overwrite-drifted'" _ "$drift_out"
check "AC4d: the hand-edited kit is untouched" test "$before" = "$(shasum "$P/scripts/demo-kit.sh")"

# ---------------------------------------------------------------------------
# AC5: --dry-run inside chitra lists both files with real states; chitra provably untouched.
# FALSIFIABILITY: any write to chitra changes HEAD, status or stash; a missing file line fails AC5a.
# ---------------------------------------------------------------------------
if [ -d "$CHITRA/.git" ]; then
  snap() { ( cd "$CHITRA" && git rev-parse HEAD && git status --porcelain && git stash list ) | shasum -a 256; }
  s0="$(snap)"; chitra_out="$(cd "$CHITRA" && "$BIN" init --sync-fleet --dry-run 2>&1)"; s1="$(snap)"
  check "AC5a: chitra dry-run lists the template" bash -c "printf '%s' \"\$1\" | grep -q 'scripts/demo-session-template.sh'" _ "$chitra_out"
  check "AC5a: chitra dry-run lists the kit" bash -c "printf '%s' \"\$1\" | grep -q 'scripts/demo-kit.sh'" _ "$chitra_out"
  check "AC5b: chitra HEAD, status and stash identical before and after" test "$s0" = "$s1"
else
  bad "AC5: chitra not found at $CHITRA — cannot evaluate (set VAJRA_CHITRA)"
fi

# ---------------------------------------------------------------------------
# AC6: the S167 demo — stream run, the gate, and the deck in a pseudo-terminal with scripted keys.
# FALSIFIABILITY: a hollow demo fails the gate; a deck that ignores keys never reaches "complete";
# an early quit that claims "complete" fails AC6e; any Demo-er logic change fails AC6f.
# ---------------------------------------------------------------------------
DEMO_MODE=stream bash scripts/demo-session-167.sh > "$T/d167.txt" 2>&1 </dev/null; rc=$?
check "AC6a: demo-session-167.sh exits 0 in stream mode (got $rc)" test "$rc" -eq 0
check "AC6a: its before runs the pre-session template out of git ($PRE, exit 0)" grep -q "template at $PRE · exit 0" "$T/d167.txt"
check "AC6a: every box in the S167 demo is straight" boxes_straight "$T/d167.txt" 100
check "AC6b: vajra next --check-demo 167 exits 0" bash -c "'$BIN' next --check-demo 167 >/dev/null 2>&1"
pty_run() {  # KEYS OUTFILE — run the demo in a pseudo-terminal, typing KEYS one by one
  python3 - "$ROOT/scripts/demo-session-167.sh" "$1" "$2" <<'PY'
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
pump(4)
for k in keys:
    os.write(fd, k.encode()); pump(3)
pump(4)
_, st = os.waitpid(pid, 0)
open(outfile, 'wb').write(buf)
sys.exit(os.WEXITSTATUS(st) if os.WIFEXITED(st) else 99)
PY
}
pty_run "nnnnnnn" "$T/pty-full.txt"; rc=$?
check "AC6c: in a terminal the demo runs as a deck (alternate screen used)" bash -c "LC_ALL=C grep -q $'\033\\[?1049h' '$T/pty-full.txt'"
check "AC6d: seven key presses page through all 7 slides to 'demo complete' (exit $rc)" \
  bash -c "[ $rc -eq 0 ] && grep -q 'demo complete' '$T/pty-full.txt'"
pty_run "q" "$T/pty-quit.txt"; rc=$?
check "AC6e: q on slide 1 says 'stopped at slide 1 of 7', never 'complete'" \
  bash -c "grep -q 'stopped at slide 1 of 7' '$T/pty-quit.txt' && ! grep -q 'demo complete' '$T/pty-quit.txt'"
demoer_changes="$(git diff "$PRE" -- src/demoer/mod.rs | grep -E '^[+-][^+-]' | grep -vE '^[+-]//!|^[+-]  presentation: (interactive_html|terminal_deck)$' || true)"
check "AC6f: Demo-er gate logic unchanged since $PRE (header comment + test fixture only)" test -z "$demoer_changes"

# ---------------------------------------------------------------------------
# AC7: the decision record exists and carries its required parts.
# FALSIFIABILITY: a missing record or a record without rejected alternatives / S168 fails.
# ---------------------------------------------------------------------------
D=docs/decisions/DECISION-009-terminal-demo.md
check "AC7a: DECISION-009 exists" test -f "$D"
check "AC7b: it says the terminal demo is the human demo" grep -q "The Terminal Demo Is the Human Demo" "$D"
check "AC7c: it says the kit is not a Darshan renderer" grep -q "not a Darshan renderer" "$D"
for alt in "Keep agent-made HTML" "A renderer inside the binary" "Vajra-built slides now"; do
  check "AC7d: rejected alternative with a reason: $alt" grep -q "^| $alt | .\{20,\}" "$D"
done
check "AC7e: it names S168" grep -q "S168" "$D"

# ---------------------------------------------------------------------------
# AC8: non-regression — tests, lint, stranger + scaffold-drift, and the kit ships in the crate.
# FALSIFIABILITY: any failing test/lint, a red stranger/drift check, or a kit missing from
# `cargo package --list` (a published crate could not build) fails.
# ---------------------------------------------------------------------------
check "AC8a: cargo test --lib passes" bash -c "cargo test --quiet --lib 2>&1 | grep -q 'test result: ok'"
check "AC8b: cargo clippy -D warnings is clean" bash -c "cargo clippy --quiet --all-targets -- -D warnings >/dev/null 2>&1"
check "AC8c: cargo fmt --check is clean" cargo fmt --check
check "AC8d: scripts/stranger-check.sh is green" bash -c "bash scripts/stranger-check.sh >/dev/null 2>&1"
check "AC8e: scripts/scaffold-drift.sh is green" bash -c "bash scripts/scaffold-drift.sh >/dev/null 2>&1"
check "AC8f: cargo package --list includes scripts/demo-kit.sh" \
  bash -c "cargo package --list --allow-dirty 2>/dev/null | grep -qx 'scripts/demo-kit.sh'"

echo ""
echo "=== verify-session-167.sh ==="
echo "PASS: $PASS  FAIL: $FAIL"
[ "$FAIL" -eq 0 ] && echo "ALL PASS — exit 0" && exit 0
echo "FAILURES — exit 1" && exit 1
