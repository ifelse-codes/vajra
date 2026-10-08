#!/usr/bin/env bash
# Session 191 verify — four small fixes from the S190 ground truth, each RUN for real and each run again
# at the commit S191 started from (f37b0fe, pinned), where it must go red for the reason it names (S122).
#   AC1 (N2)  the ground-truth Write guard passes a write it can prove is OUTSIDE the project — 20 cases
#             through the real hook-pre-write.sh, old and new.
#   AC2       `vajra next --advance` moves only the number after `**Number:**` — the real S188 line as the
#             fixture, the new unit test run against the old function too.
#   AC3       verify-session-133.sh twice at once, old and new.
#   AC4       the session guard drops ONE heredoc shape's body from what it reads — an old-vs-new corpus
#             (S173's list + the S191 design-advisor's rec 10) under macOS /bin/bash 3.2: nothing the old
#             guard blocked gets through, except the declared shape.
# Nothing here greps source. `cargo test` in full is run separately (founder rule, 2026-10-04).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(cd "$(mktemp -d)" && pwd -P)"
trap 'vajra_old_checkout_remove "${OLD_WT:-}"; rm -rf "$T" "${O:-}" "${PD:-}" "${TD:-}"' EXIT
OLD_SHA=f37b0fe
BASH32=/bin/bash
. "$ROOT/scripts/lib-old-checkout.sh"
OLD_WT=$(vajra_old_checkout "$OLD_SHA") || { echo "FAIL: worktree at $OLD_SHA"; exit 1; }
OLDH="$T/oldhooks"; mkdir -p "$OLDH"
git show "$OLD_SHA:scripts/hook-pre-write.sh" > "$OLDH/hook-pre-write.sh"
git show "$OLD_SHA:scripts/hook-session-guard.sh" > "$OLDH/hook-session-guard.sh"
cp scripts/lib-ground-truth.sh scripts/hook-approvals-guard.sh "$OLDH/"   # unchanged since f37b0fe
for f in lib-ground-truth.sh hook-approvals-guard.sh; do
  git diff --quiet "$OLD_SHA" -- "scripts/$f" || bad "scripts/$f changed since $OLD_SHA — the old-hook copy is not the old hook"
done

# ==============================================================================================
# AC1 — N2: outside passes, every inside spelling still blocks (exit exactly 2), `..` now blocks.
# ==============================================================================================
PD=$(mktemp -d); P="$PD/proj"; mkdir -p "$P/src" "$P/.ai" "$P/sessions" "${P}2"   # under /var (a link to /private/var)
printf 'maturity: L2\nsession:\n  ground_truth_every_n_sessions: 5\n' > "$P/.ai/CONSTRAINTS.yaml"
echo x > "$P/src/x.rs"
( cd "$P" && git init -q && git checkout -q -b session-185-x )
PP=$(cd -P "$P" && pwd -P)
O=$(mktemp -d /tmp/s191-out.XXXXXX)     # /tmp is a link to /private/tmp
ln -s "$P/src/x.rs" "$O/leaflink.rs"; ln "$P/src/x.rs" "$O/hard.rs"; ln -s "$P" "$O/projlink"; mkfifo "$O/fifo"
UP=$(printf '%s' "$P" | tr '[:lower:]' '[:upper:]')
pw() { # pw <hookdir> <path> [root] → exit code
  printf '{"tool_input":{"file_path":"%s"}}' "$2" \
    | CLAUDE_PROJECT_DIR="${3:-$P}" "$BASH32" "$1/hook-pre-write.sh" >/dev/null 2>"$T/pw.err"; echo $?
}
n2() { # n2 <label> <want-new> <want-old> <path> [root]
  local n o; n=$(pw scripts "$4" "${5:-}"); o=$(pw "$OLDH" "$4" "${5:-}")
  if [ "$n" = "$2" ] && [ "$o" = "$3" ]; then ok "AC1 $1: new $n, at $OLD_SHA $o"
  else bad "AC1 $1: new $n (want $2), at $OLD_SHA $o (want $3)"; fi
}
n2 "outside, in /tmp"                    0 2 "/tmp/${O##*/}/n.md"
n2 "outside, in /private/tmp"            0 2 "$O/n.md"
TD=$(mktemp -d)                          # $TMPDIR spelling: /var/folders/…
n2 "outside, under \$TMPDIR"              0 2 "$TD/n.md"
n2 "sibling folder proj2"                0 2 "${P}2/n.md"
n2 "'..' back into src (the old hole)"   2 0 "$P/.ai/../src/x.rs"
n2 "inside, logical /var path"           2 2 "$P/src/x.rs"
n2 "inside, physical /private/var path"  2 2 "$PP/src/x.rs"
n2 "inside, root given physically"       2 2 "$P/src/y.rs" "$PP"
n2 "inside, a new file"                  2 2 "$P/src/new.rs"
n2 "inside, case changed"                2 2 "$UP/src/x.rs"
n2 "a linked ancestor into the project"  2 2 "$O/projlink/src/x.rs"
n2 "leaf is a link into the project"     2 2 "$O/leaflink.rs"
n2 "leaf is a hard link"                 2 2 "$O/hard.rs"
n2 "leaf is a FIFO"                      2 2 "$O/fifo"
n2 "relative path"                       2 2 "src/x.rs"
n2 "non-ASCII path"                      2 2 "$O/é.md"
n2 "a folder that does not exist yet"    2 2 "$O/nope/n.md"
n2 "allowlisted .ai/ still passes"       0 0 "$P/.ai/notes.md"
n2 "the ground-truth report still passes" 0 0 "$P/sessions/session-185-ground-truth.md"
# Cold review rec 1: `cd -P` resolves symlinks, not macOS firmlinks — at 64248b9 (S191's first N2 commit)
# an inside file spelled /System/Volumes/Data/… passed. Now the folder walk compares by inode (`-ef`).
MIDH="$T/midhooks"; mkdir -p "$MIDH"; cp "$OLDH"/lib-ground-truth.sh "$OLDH"/hook-approvals-guard.sh "$MIDH/"
git show 64248b9:scripts/hook-pre-write.sh > "$MIDH/hook-pre-write.sh"
# The project sits under /private/tmp: there `cd -P` keeps the /System/Volumes/Data spelling (under
# /private/var it happens to resolve it, so a /var project cannot show the hole).
FP="$O/fproj"; mkdir -p "$FP/src" "$FP/.ai"; echo x > "$FP/src/x.rs"; cp "$P/.ai/CONSTRAINTS.yaml" "$FP/.ai/"
( cd "$FP" && git init -q && git checkout -q -b session-185-x )
FPP=$(cd -P "$FP" && pwd -P)
if [ -d "/System/Volumes/Data$FPP" ]; then
  n=$(pw scripts "/System/Volumes/Data$FPP/src/x.rs" "$FP"); m=$(pw "$MIDH" "/System/Volumes/Data$FPP/src/x.rs" "$FP")
  [ "$n" = 2 ] && [ "$m" = 0 ] && ok "AC1 inside, through the /System/Volumes/Data firmlink: new 2, at 64248b9 0 (review rec 1)" \
    || bad "AC1 firmlink spelling: new $n (want 2), at 64248b9 $m (want 0)"
else
  echo "SKIP: no /System/Volumes/Data$FPP on this machine (not macOS APFS) — the firmlink row cannot run"
fi
pw scripts "$O/nope/n.md" >/dev/null
grep -q "mkdir -p '$O/nope'" "$T/pw.err" && ok "AC1 the missing-folder block names the way past (mkdir -p, then write)" \
  || bad "AC1 the missing-folder block does not name mkdir -p: $(cat "$T/pw.err")"
( cd "$P" && git checkout -q -b session-186-x )
[ "$(pw scripts "$P/src/x.rs")" = 0 ] && ok "AC1 not a ground truth (S186): an inside edit passes, as before" \
  || bad "AC1 not a ground truth (S186): an inside edit is blocked"

# ==============================================================================================
# AC2 — the real S188 line. The new unit test runs at the tip (green) and at f37b0fe (red: the old
# `line.replace` rewrites session-188-summary.md and the rest).
# ==============================================================================================
cargo test -q --lib -- update_session_boot swap_boot_number >"$T/ac2.log" 2>&1 \
  && grep -q "3 passed" "$T/ac2.log" && ok "AC2 the three SESSION-BOOT tests pass at the tip" \
  || bad "AC2 the SESSION-BOOT tests at the tip — $(tail -3 "$T/ac2.log")"
REAL188=$(git show 976ba05:.ai/SESSION-BOOT.md | grep -F '**Number:** 188 — COMPLETE (merged #226)')
grep -qF "$REAL188" src/cli/next.rs && ok "AC2 the test's fixture is the real S188 line (.ai/SESSION-BOOT.md at 976ba05)" \
  || bad "AC2 the test's fixture is not the real S188 line"
perl -0777 -ne 'print $1 if /(    \/\/\/ S191 AC2:.*?\n    }\n)/s' src/cli/next.rs > "$T/ac2.rs"
perl -0777 -i -pe 'BEGIN { local $/; open F, "<", "'"$T/ac2.rs"'"; $t = <F> } s/\}\s*\z/$t}\n/' "$OLD_WT/src/cli/next.rs"
(cd "$OLD_WT" && CARGO_TARGET_DIR="$ROOT/target/s191-old" cargo test -q --lib -- update_session_boot_leaves_prose_numbers_alone) >"$T/ac2-old.log" 2>&1
if grep -q "panicked" "$T/ac2-old.log" && grep -q "session-189-summary" "$T/ac2-old.log"; then
  ok "AC2 at $OLD_SHA the same test is RED: the old swap wrote session-189-summary.md into the S188 line"
else
  bad "AC2 at $OLD_SHA the test did not go red for the named reason — $(grep -E 'error|panicked|result' "$T/ac2-old.log" | head -3)"
fi

# ==============================================================================================
# AC4 — the session guard. The fixture owns session 4 in chat SID; anything that starts session 5
# from SID blocks (exit 2). Old = the hook at f37b0fe; new = today's. Run under /bin/bash 3.2.
# ==============================================================================================
G="$T/sg"; mkdir -p "$G/.ai"
printf 'maturity: L2\nsession:\n  one_session_per_chat: true\n' > "$G/.ai/CONSTRAINTS.yaml"; echo 04 > "$G/.ai/SESSION"
sg() { # sg <hook> <command> → exit code
  printf '4\tSID\n' > "$G/.ai/.session-owner"
  jq -n --arg c "$2" '{session_id:"SID",tool_input:{command:$c}}' \
    | CLAUDE_PROJECT_DIR="$G" "$BASH32" "$1" >/dev/null 2>&1; echo $?
}
NEWH=scripts/hook-session-guard.sh; OLDS="$OLDH/hook-session-guard.sh"
q="'"
body() { printf 'notes\ngit checkout -b session-05-x\nvajra next --advance\nmore\n'; }
# The declared shape — each must pass now and block at f37b0fe (the bug).
SHAPE=(
  "cat > notes.md <<${q}EOF${q}"$'\n'"$(body)"$'\n'"EOF"
  "cat >> notes.md <<\"EOF\""$'\n'"$(body)"$'\n'"EOF"
  "cat <<${q}EOF${q} > notes.md"$'\n'"$(body)"$'\n'"EOF"
  "tee -a notes.md > /dev/null <<${q}EOF${q}"$'\n'"$(body)"$'\n'"EOF"
  "tee notes.md <<${q}NOTE${q} > /dev/null"$'\n'"$(body)"$'\n'"NOTE"
  "cat > notes.md <<${q}EOF${q}"$'\n'"$(body)"$'\n'"EOF "$'\n'"still body"$'\n'"EOF"
  "cat > notes.md <<${q}EOF${q}"$'\n'"[vajra session-guard] BLOCKED: this chat already owns session 4."$'\n'"    open a fresh chat, then run: git checkout -b session-5-<slug>"$'\n'"EOF"
)
for c in "${SHAPE[@]}"; do
  n=$(sg "$NEWH" "$c"); o=$(sg "$OLDS" "$c")
  if [ "$n" = 0 ] && [ "$o" = 2 ]; then ok "AC4 passes now, blocked at $OLD_SHA: $(head -1 <<<"$c")"
  else bad "AC4 $(head -1 <<<"$c" | tr '\n' ' '): new $n (want 0), at $OLD_SHA $o (want 2)"; fi
done
# Must still block, new AND old (design-advisor rec 10 (g), each aimed at one clause of the shape).
STILL=(
  "git checkout -b session-05-x"
  "vajra next --advance"
  "cat <<${q}EOF${q} | bash"$'\n'"$(body)"$'\n'"EOF"
  "bash <<${q}EOF${q}"$'\n'"$(body)"$'\n'"EOF"
  "sh -s <<${q}EOF${q}"$'\n'"$(body)"$'\n'"EOF"
  "source /dev/stdin <<${q}EOF${q}"$'\n'"$(body)"$'\n'"EOF"
  "ssh h <<${q}EOF${q}"$'\n'"$(body)"$'\n'"EOF"
  "xargs <<${q}EOF${q}"$'\n'"$(body)"$'\n'"EOF"
  "cat > f <<${q}EOF${q}; git checkout -b session-05-x"$'\n'"x"$'\n'"EOF"
  "cat > run.sh <<${q}EOF${q}"$'\n'"$(body)"$'\n'"EOF"$'\n'"bash run.sh"
  "cat > n.md <<EOF"$'\n'"$(body)"$'\n'"EOF"
  "cat > n.md <<EOF"$'\n'"\$(git checkout -b session-05-x)"$'\n'"EOF"
  "cat > n.md <<EOF"$'\n'"\$(echo \")\"; git checkout -b session-05-x)"$'\n'"EOF"
  "cat > n.md <<-${q}EOF${q}"$'\n'"$(body)"$'\n'"EOF"
  "cat > a <<${q}A${q} > b <<${q}B${q}"$'\n'"$(body)"$'\n'"A"$'\n'"B"
  "cat > n.md <<${q}EOF${q}"$'\n'"$(body)"$'\r\n'"EOF"$'\r'
  "cat > =git <<${q}EOF${q}"$'\n'"$(body)"$'\n'"EOF"
  "cat > \$(git checkout -b session-05-x) <<${q}EOF${q}"$'\n'"x"$'\n'"EOF"
  "cat > n.md <<${q}EOF${q}"$'\n'"$(body)"
  "git commit -m \"\$(cat <<${q}EOF${q}"$'\n'"$(body)"$'\n'"EOF"$'\n'")\""
  "git commit -m \"\$(cat <<${q}D${q}"$'\n'")\""$'\n'"git checkout -b session-05-x"$'\n'"D"$'\n'")\""
  "cat > n.md <<${q}EOF${q}"$'\n'"x"$'\n'"EOF"$'\n'"git checkout -b session-05-x"
  "echo \`git checkout -b session-05-x\`"
  "eval \"git checkout -b session-05-x\""
  "sh -c 'git checkout -b session-05-x'"
)
for c in "${STILL[@]}"; do
  n=$(sg "$NEWH" "$c"); o=$(sg "$OLDS" "$c")
  if [ "$n" = 2 ] && [ "$o" = 2 ]; then ok "AC4 still blocks (and did): $(head -1 <<<"$c" | tr -d '\r')"
  else bad "AC4 $(printf '%s' "$c" | tr '\n\r' '⏎ '): new $n, at $OLD_SHA $o (want 2 and 2)"; fi
done
# S173's whole list × both triggers, old vs new: nothing blocked before passes now.
forms() { # S173's forms (scripts/verify-session-173.sh), each RUNS <trigger>
  local t="$1"
  printf '%s\0' \
    "$t" "echo x; $t" "echo \`$t\`" "echo \"\$($t)\"" \
    "$(printf 'cat <<EOF > n.md\n$(%s)\nEOF' "$t")" \
    "$(printf 'cat <<EOF | bash\n%s\nEOF' "$t")" \
    "$(printf 'bash -s <<EOF\n%s\nEOF' "$t")" \
    "$(printf 'cat <<EOF\nEOF\n%s\nEOF' "$t")" \
    "$(printf "echo '<<EOF'\n%s\nEOF" "$t")" \
    "$(printf "# don't push yet\n%s\necho 'done'" "$t")" \
    "$(printf 'cat <<EOF >/dev/null; %s\nx\nEOF' "$t")" \
    "$(printf 'bash -c "\n%s\n"' "$t")" \
    "eval \"$t\"" \
    "$(printf 'git commit -m "$(cat <<'"'"'EOF'"'"'\nmsg\nEOF\n)" && %s' "$t")" \
    "$(printf "echo 'x \"\$(cat <<'EOF'\n'; %s; echo '\nEOF\n)\"'" "$t")" \
    "$(printf 'git commit -m "$(cat <<'"'"'EOF'"'"'\nmsg\nEOF\n%s\nEOF\n)"' "$t")" \
    "$(printf 'git commit -m "$(cat <<-'"'"'EOF'"'"'\nmsg\n\tEOF\n%s\nEOF\n)"' "$t")" \
    "$(printf 'git commit -m "$(cat <<'"'"'EOF'"'"'\nmsg\n  EOF\n%s\nEOF\n)"' "$t")" \
    "$(printf 'echo "it'"'"'s" && git commit -m "$(cat <<'"'"'EOF'"'"'\n'"'"'; %s; echo '"'"'\nEOF\n)"' "$t")" \
    "$(printf 'echo \\'"'"' ; git commit -m "$(cat <<'"'"'EOF'"'"'\n'"'"'; %s; echo '"'"'\nEOF\n)"' "$t")" \
    "$(printf "echo 'abc\ngit commit -m \"\$(cat <<'EOF'\n'; %s; echo '\nEOF\n)\"'" "$t")" \
    "$(printf 'cat <<EOF\nit'"'"'s\nEOF\ngit commit -m "$(cat <<'"'"'EOF'"'"'\n'"'"'; %s; echo '"'"'\nEOF\n)"' "$t")" \
    "$(printf 'echo "it'"'"'s" '"'"'x git commit -m "$(cat <<'"'"'EOF'"'"'\n'"'"'; %s; echo '"'"'\nEOF\n)"' "$t")" \
    "$(printf 'echo a \\\n; %s' "$t")" \
    "$(printf 'echo a\r\n%s\r' "$t")" \
    "$(printf 'cat <<<"x"; %s' "$t")" \
    "$(printf '(( 1 )) && %s' "$t")" \
    "$(printf 'git commit -m "$(cat <<'"'"'D'"'"'\n)"\n%s\nD\n)"' "$t")" \
    "$t && echo \"\$(echo checkout -b session-01-a)\"" \
    "echo \"\$(echo checkout -b session-01-a)\" && $t" \
    "$(printf "cat > n.md <<'EOF'\nx\nEOF\n%s" "$t")" \
    "$(printf "cat > n.md <<'EOF' && %s\nx\nEOF" "$t")" \
    "$(printf "cat > n.md <<'EOF'\n%s\nEOF\nbash n.md" "$t")"
}
CN=0; CBAD=0; CDIFF=0
for t in 'vajra next --advance' 'git checkout -b session-05-x'; do
  while IFS= read -r -d '' c; do
    CN=$((CN+1)); o=$(sg "$OLDS" "$c"); n=$(sg "$NEWH" "$c")
    [ "$o" = 2 ] && [ "$n" != 2 ] && { CBAD=$((CBAD+1)); echo "  regressed: $(printf '%s' "$c" | tr '\n' '⏎')"; }
    [ "$o" != "$n" ] && CDIFF=$((CDIFF+1))
  done < <(forms "$t")
done
[ "$CBAD" = 0 ] && [ "$CDIFF" = 0 ] && ok "AC4 old-vs-new on S173's list + 3 heredoc-then-run shapes: $CN commands, 0 went from blocked to allowed, 0 changed at all" \
  || bad "AC4 old-vs-new: $CBAD of $CN went from blocked to allowed, $CDIFF changed"
# No perl → nothing removed: the declared shape blocks as before.
NOPERL="$T/noperl"; mkdir -p "$NOPERL"
for b in jq sed grep tr head cat awk git printf; do p=$(command -v "$b") && ln -sf "$p" "$NOPERL/$b"; done
printf '4\tSID\n' > "$G/.ai/.session-owner"
np=$(jq -n --arg c "${SHAPE[0]}" '{session_id:"SID",tool_input:{command:$c}}' \
  | PATH="$NOPERL" CLAUDE_PROJECT_DIR="$G" "$BASH32" "$NEWH" >/dev/null 2>&1; echo $?)
[ "$np" = 2 ] && ok "AC4 with perl gone from PATH the declared shape still blocks (nothing removed)" \
  || bad "AC4 with no perl the declared shape exits $np (want 2)"
# The shape never claims a session: a plain-file note leaves the owner record alone.
printf '4\tSID\n' > "$G/.ai/.session-owner"
jq -n --arg c "${SHAPE[0]}" '{session_id:"OTHER",tool_input:{command:$c}}' \
  | CLAUDE_PROJECT_DIR="$G" "$BASH32" "$NEWH" >/dev/null 2>&1
[ "$(cut -f1 "$G/.ai/.session-owner")" = 4 ] && ok "AC4 a note written from another chat records no owner" \
  || bad "AC4 a note recorded owner $(cut -f1 "$G/.ai/.session-owner")"
# S173 pass 7, at L1: only the old rule's number is ever recorded — a checkout inside `$( )` (EXTRA
# only) or inside the declared shape's body, run from another chat, leaves the owner record alone.
for c in "echo \"\$(git checkout -b session-05-x)\"" "${SHAPE[0]}"; do
  printf '4\tSID\n' > "$G/.ai/.session-owner"
  jq -n --arg c "$c" '{session_id:"OTHER",tool_input:{command:$c}}' \
    | VAJRA_GUARD_MATURITY=L1 CLAUDE_PROJECT_DIR="$G" "$BASH32" "$NEWH" >/dev/null 2>&1
  [ "$(cut -f1 "$G/.ai/.session-owner")" = 4 ] && ok "AC4 L1 (S173 pass 7): no owner recorded for: $(head -1 <<<"$c")" \
    || bad "AC4 L1: owner $(cut -f1 "$G/.ai/.session-owner") recorded for: $(head -1 <<<"$c")"
done

# ==============================================================================================
# AC3 — verify-session-133.sh twice at once. At f37b0fe both runs share one fixture checkout and go
# red on it; now each run has its own and both pass. (~80 s for the old pair, ~3 min for the new one —
# each new run clones and rebuilds its own build folder; the old pair runs first.)
# ==============================================================================================
git show "$OLD_SHA:scripts/verify-session-133.sh" > "$T/v133-old.sh"
pair() { # pair <script> <tag> → "rcA rcB"
  ( CLAUDE_PROJECT_DIR="$ROOT" bash "$1" >"$T/$2-a.log" 2>&1; echo $? >"$T/$2-a.rc" ) &
  ( CLAUDE_PROJECT_DIR="$ROOT" bash "$1" >"$T/$2-b.log" 2>&1; echo $? >"$T/$2-b.rc" ) &
  wait; echo "$(cat "$T/$2-a.rc") $(cat "$T/$2-b.rc")"
}
r=$(pair "$T/v133-old.sh" old)
if [ "$r" != "0 0" ] && grep -h "fixture-red-on-bypass" "$T"/old-?.log | grep -q FAIL; then
  ok "AC3 at $OLD_SHA two runs at once collide (exits: $r) — on the shared fixture checkout"
else
  bad "AC3 at $OLD_SHA two runs at once did not collide on the fixture (exits: $r)"
fi
r=$(pair scripts/verify-session-133.sh new)
[ "$r" = "0 0" ] && ok "AC3 two runs at once both pass (exits: $r)" || bad "AC3 two runs at once: exits $r (want 0 0)"
left=$(ls -d "$ROOT"/target/s133-fixture-wt-* "$ROOT"/target/s133-probes-* 2>/dev/null | wc -l | tr -d ' ')
[ "$left" = 0 ] && ok "AC3 no per-run checkout or build folder left behind" || bad "AC3 $left per-run checkout(s)/build folder(s) left behind"

echo ""
echo "WHAT THIS NEVER EXERCISED — stated, not buried:"
echo "  * a real Claude Code Write call during a real ground truth (the hook is driven with its JSON input)"
echo "  * zsh, or a user's shell function/alias named cat or tee (the guard trusts they are the real programs)"
echo "  * a parallel call swapping a checked folder for a link between the check and the write (named limit)"
echo "  * more than one concurrent round of verify-133 here (one more round was run by hand on the same version, green)
  * a case-SENSITIVE disk (the inode walk uses the as-resolved root; only macOS APFS, case-insensitive, was run)"
echo ""
if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, $FAIL fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
