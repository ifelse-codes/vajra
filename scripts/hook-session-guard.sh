#!/usr/bin/env bash
# PreToolUse(Bash): enforces one-vajra-session-per-chat (AGENTS.md step 10).
#
# The Hard Rule: a new vajra-session starts in a NEW chat. The chat that closed
# session N must NOT begin session N+1's BRANCH/PLAN in the same chat. Until now
# this was convention only (CONSTRAINTS.yaml#session.one_session_per_chat: true);
# this hook makes it real.
#
# Signal: the Claude `session_id` (the chat). We record which chat "owns" each
# vajra-session number the first time it creates that session's branch. When a
# `git checkout -b session-NN-*` crosses the N->N+1 boundary FROM THE SAME CHAT
# that owned N, we block: open a new chat first.
#
# Maturity-gated (same gate as every Vajra hook, S21):
#   L1    -> ADVISE  : warn on stdout, exit 0 (agent may proceed).
#   L2/L3 -> ENFORCE : warn on stderr, exit 2 (branch creation blocked).
# Only active when CONSTRAINTS.yaml#session.one_session_per_chat: true.
#
# Test/override knobs (used by verify-session-26.sh to drive the boundary without
# real chats): VAJRA_SESSION_OWNER_FILE overrides the owner record path;
# VAJRA_GUARD_MATURITY overrides the maturity level read from CONSTRAINTS.yaml.

set -euo pipefail

# jq preflight — fail-closed (AGENTS.md L147: a check that cannot evaluate FAILS).
if ! command -v jq >/dev/null 2>&1; then
  _VROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
  _VMAT="${VAJRA_GUARD_MATURITY:-$(grep -m1 '^maturity:' "$_VROOT/.ai/CONSTRAINTS.yaml" 2>/dev/null | awk '{print $2}' || echo L2)}"
  [ "$_VMAT" = "L1" ] && { echo "[vajra] jq not on PATH — enforcement degraded to advise (L1)."; exit 0; }
  echo "[vajra] BLOCKED: jq required for Vajra enforcement, not on PATH (fail-closed)." 1>&2
  exit 2
fi

INPUT=$(cat 2>/dev/null || echo "{}")
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
CONSTRAINTS="$ROOT/.ai/CONSTRAINTS.yaml"
[ -f "$CONSTRAINTS" ] || exit 0

# ── Repo-identity: govern only the project this hook belongs to (S94, closes the S52 blindspot) ─
# This guard's session number ($ROOT/.ai/SESSION) and owner record ($ROOT/.ai/.session-owner) are
# ALREADY pinned to ROOT (never git), so no enclosing repo can bleed in. But during a dogfood ROOT
# can sit nested inside another git repo — surface the governed project (and flag the nesting) so a
# CLAUDE_PROJECT_DIR mis-fire is visible, not silent.
ROOT_REAL=$(cd "$ROOT" 2>/dev/null && pwd -P || printf '%s' "$ROOT")
GIT_TOP=$(git -C "$ROOT" rev-parse --show-toplevel 2>/dev/null || echo "")
if [ -n "$GIT_TOP" ] && [ "$GIT_TOP" != "$ROOT_REAL" ]; then
  GOVERNS="project $ROOT_REAL (nested inside git repo $GIT_TOP)"
else
  GOVERNS="project $ROOT_REAL"
fi

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")
SID=$(echo "$INPUT" | jq -r '.session_id // "nosession"' 2>/dev/null || echo "nosession")

# Scan a QUOTED-SPAN-STRIPPED copy so a trigger phrase inside a message/arg (e.g.
# git commit -m "…checkout -b session-40…") can't false-arm the boundary — same fix as the
# S39 publish-guard. Real checkout/advance commands are unquoted, so nothing real is hidden.
#
# S173 F50/F44: `sed` stripped quotes LINE BY LINE, so a multi-line commit message — a heredoc
# (`-m "$(cat <<'EOF' … EOF)"`) — kept its body, and rudra's "S04 setup: … vajra next --advance"
# message blocked its own commit.
# S173 (F50/F44, cold review recs 1-3): what a guard READS. Prose — quoted text, a heredoc body —
# is hidden; anything bash would RUN stays visible: backticks and $( ) (even inside double quotes),
# the rest of the line a heredoc opens on, and the whole of a `bash -c` / `eval` string. The first
# S173 cut hid all of those and let `cat <<EOF >x; git push -f origin HEAD:main` through unapproved.
# vajra_scan [1] — with 1, each quoted span becomes the placeholder Q instead of vanishing.
vajra_scan() { VQ="${1:-0}" perl -0777 -pe '
# VAJRA_SCAN (S173): what a guard reads. Prose is hidden; anything bash would RUN stays visible.
my $q = ($ENV{VQ} // "") eq "1";   # 1 = each quoted span becomes the placeholder Q
my $s = $_;
# The BODY of a heredoc is text — unless it is fed to a shell (bash <<EOF runs it). The rest of
# the line the heredoc opens on is still command, and stays.
$s =~ s{(^|\n)([^\n]*?)<<-?[ \t]*([\x27"]?)(\w+)\3([^\n]*)\n.*?\n[ \t]*\4[ \t]*(?=\n|$)}{
  my ($p, $pre, $rest, $all) = ($1, $2, $5, $&);
  $pre =~ /(^|[^\w])((?:ba|z|da|k)?sh|eval|source)\s*$/ ? $all : "$p$pre H $rest" }gse;
$s =~ s/\$\(\s*cat\s+H\s*\)/ /g;   # "$(cat <<EOF … EOF)" — a heredoc fed to cat is text
# A `-c` / eval string IS a command: past this point hide nothing (over-block is the safe side).
unless ($s =~ /(^|[^\w])(eval|(?:ba|z|da|k)?sh\s+(?:-\w+\s+)*-c)(\s|$)/) {
  # Left to right, as bash reads it: single-quoted text is literal; "…" is text except $( … ) and `…` inside,
  # which bash runs and so stay visible; outside quotes everything stays.
  my ($o, $i, $n) = ("", 0, length $s);
  while ($i < $n) {
    my $c = substr($s, $i, 1);
    if ($c eq "\\") { $o .= substr($s, $i, 2); $i += 2; next; }
    if ($c eq "\x27") { my $j = index($s, "\x27", $i + 1); $j = $n if $j < 0;
                        $o .= $q ? "Q" : ""; $i = $j + 1; next; }
    if ($c eq "\"") {
      my @keep; $i++;
      while ($i < $n && substr($s, $i, 1) ne "\"") {
        my $d = substr($s, $i, 1);
        if ($d eq "\\") { $i += 2; next; }
        if ($d eq "`") { my $j = index($s, "`", $i + 1); $j = $n if $j < 0;
                         push @keep, substr($s, $i + 1, $j - $i - 1); $i = $j + 1; next; }
        if (substr($s, $i, 2) eq "\$(") { my ($j, $depth) = ($i + 2, 1);
          while ($j < $n && $depth) { my $e = substr($s, $j, 1); $depth++ if $e eq "("; $depth-- if $e eq ")"; $j++; }
          push @keep, substr($s, $i + 2, $j - $i - 3); $i = $j; next; }
        $i++;
      }
      $i++;
      $o .= @keep ? " " . join(" ; ", @keep) . " " : ($q ? "Q" : "");
      next;
    }
    $o .= $c; $i++;
  }
  $s = $o;
}
$_ = $s;
'; }
SCAN=$(vajra_scan 0 <<<"$CMD")

# Fire on a session ADVANCE — two shapes, one meaning ("this chat crosses N -> N+1"):
#   1. checkout of the next branch: git checkout -b session-NN-<slug>   (NN = the new session).
#   2. `vajra next --advance` (S39, story A — the S36 root cause). The S36 brownfield agent
#      advanced 00->01 WITHOUT ever `checkout -b`, so the branch tripwire never armed and it
#      ran two vajra-sessions in one chat, unstopped. `--advance` is Vajra's ONE sanctioned
#      advance command; it bumps .ai/SESSION via Rust `fs::write` (invisible to a Bash hook as
#      a file write), so the invocation itself is the observable common-denominator signal.
#      For an advance the target session is (current .ai/SESSION) + 1. (A raw manual
#      `echo N > .ai/SESSION` is out of scope here — tracked for git-level pre-commit
#      scaffolding; enforcement stays fail-safe: unrecognised advances simply don't arm.)
NN=$(printf '%s' "$SCAN" | grep -oE 'checkout +-b +session-[0-9]+-' | grep -oE 'session-[0-9]+' | grep -oE '[0-9]+' | head -1 || true)
if [ -z "$NN" ] && grep -qE '(^|[^[:alnum:]_])next[[:space:]]+--advance([^[:alnum:]]|$)' <<<"$SCAN"; then
  CUR=$(tr -dc '0-9' < "$ROOT/.ai/SESSION" 2>/dev/null || true)
  [ -n "$CUR" ] && NN=$((10#$CUR + 1))
fi
[ -n "$NN" ] || exit 0
NN=$((10#$NN))

# Gate: rule must be enabled.
ENABLED=$(grep -E '^[[:space:]]*one_session_per_chat:' "$CONSTRAINTS" 2>/dev/null | grep -oE 'true|false' | head -1 || echo "false")
[ "$ENABLED" = "true" ] || exit 0

MATURITY="${VAJRA_GUARD_MATURITY:-$(grep -m1 '^maturity:' "$CONSTRAINTS" 2>/dev/null | awk '{print $2}' || echo "L2")}"
OWNER_FILE="${VAJRA_SESSION_OWNER_FILE:-$ROOT/.ai/.session-owner}"

# Read the prior owner record, if any:  <NN>\t<session_id>
OWNER_NN=""; OWNER_SID=""
if [ -f "$OWNER_FILE" ]; then
  OWNER_NN=$(awk 'NR==1{print $1}' "$OWNER_FILE" 2>/dev/null || echo "")
  OWNER_SID=$(awk 'NR==1{print $2}' "$OWNER_FILE" 2>/dev/null || echo "")
  [ -n "$OWNER_NN" ] && OWNER_NN=$((10#$OWNER_NN))
fi

record() { printf '%s\t%s\n' "$NN" "$SID" > "$OWNER_FILE"; }

# Block only the N->N+1 boundary FROM THE SAME CHAT that owned N.
if [ -n "$OWNER_NN" ] && [ "$NN" -eq "$((OWNER_NN + 1))" ] && [ "$SID" = "$OWNER_SID" ]; then
  if [ "$MATURITY" = "L1" ]; then
    echo "[vajra session-guard] one-session-per-chat: this chat owns session $OWNER_NN. Governing $GOVERNS."
    echo "  Starting session $NN here breaks the rule — open a NEW chat. (L1 advise, not blocking.)"
    record
    exit 0
  fi
  {
    echo "[vajra session-guard] BLOCKED: this chat already owns session $OWNER_NN."
    echo "  Governing $GOVERNS."
    echo "  One vajra-session per chat (AGENTS.md step 10). Start session $NN in a NEW chat:"
    echo "    open a fresh chat, then run: git checkout -b session-$NN-<slug>"
    echo "  (Set one_session_per_chat: false or maturity: L1 in CONSTRAINTS.yaml to override.)"
  } 1>&2
  exit 2
fi

# Same session re-checkout (same NN, same chat) or a fresh chat: allow + claim ownership.
record
exit 0
