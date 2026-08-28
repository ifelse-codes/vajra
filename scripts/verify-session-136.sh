#!/usr/bin/env bash
# Verify — Session 136: `vajra init --sync-fleet`, the UPGRADE path a brownfield adopter needs, and
# the fleet made REAL in chitra. What this suite must prove beyond "ten files exist":
#   1. an empty repo syncs to the FULL canonical roster — every role, byte-for-byte from
#      `fleet::render_subagent_definition`, never a hand-typed subset;
#   2. it is IDEMPOTENT — a second run writes nothing and reports every role current;
#   3. a DRIFTED file is REPORTED and REFUSED by default, left byte-identical, and the message
#      names the flag that resolves it — the guardrail that a clobbering command is worse than none;
#   4. `--overwrite-drifted` really refreshes it (the escape exists and works);
#   5. `--dry-run` is a TRUE preview: identical plan, zero writes, and the exit code the real run
#      would return — a preview that exits 0 where the real run exits 1 previews a different command;
#   6. it touches ONLY `.claude/agents/` — a project at session 16 must not receive a kickoff prompt;
#   7. chitra really carries all ten role files, byte-identical to THIS repo's canonical render;
#   8. the crew gate really BINDS inside chitra at session 16 — exit 1, naming the tech-lead, from a
#      session number far below the 133 threshold (the S135 no-threshold rule, in a real brownfield
#      project, not a fixture);
#   9. chitra is UNDISTURBED the four ways outside the pre-declared paths, against the baseline
#      recorded BEFORE any write;
#  10. nothing else moved — still 7 top-level commands, the fleet is 10 roles, K of 8 unchanged.
#
# S69: every machine-local check FAILS when its input is absent. It never skips. A check that cannot
# evaluate is indistinguishable from a deleted check, so absence is RED here, never a quiet green.
#
# CHECK CLASSES — EXECUTE-BASED (runs the product, asserts on real output) · STRUCTURAL grep
# (asserts architecture — no runtime output to exercise).
set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

# shellcheck source=scripts/lib-tally.sh
source "$ROOT/scripts/lib-tally.sh"

SESSION="136"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

VAJRA="$ROOT/target/release/vajra"
[ -x "$VAJRA" ] || cargo build -q --release || { echo "release build failed"; exit 2; }

# The one project outside this repo. Machine-local (S91 shape) — but NOT skippable (S69): the whole
# point of this session is that the fleet is real THERE, so an absent chitra is a RED result here.
CHITRA="${VAJRA_CHITRA_ROOT:-/Users/suman/playground/chitra}"
# TRACKED (`.ai/verify/` is gitignored — S126: raw run captures stay local, git keeps the
# small derived evidence record). A fresh checkout can therefore re-run check 9.
BASELINE="$ROOT/sessions/session-136-chitra-baseline.txt"

PASS=0; FAIL=0; RESULTS=()
EXEC_N=0; STRUCT_N=0; BEHAV_N=0; NESTED_N=0; NESTED_NAMES=()
run_check() {
  local NAME="$1"; local CLASS="$2"; shift 2
  local LOG="$ARTIFACTS/${NAME}.log"
  case "$CLASS" in
    exec)   EXEC_N=$((EXEC_N+1)) ;;
    struct) STRUCT_N=$((STRUCT_N+1)) ;;
    behav)  BEHAV_N=$((BEHAV_N+1)) ;;
    nested) NESTED_N=$((NESTED_N+1)); NESTED_NAMES+=("$NAME") ;;
    *) echo "verify bug: unknown class '$CLASS' for $NAME"; exit 2 ;;
  esac
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-56s %-7s %s' "$NAME" "$CLASS" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-56s %-7s %s' "$NAME" "$CLASS" FAIL)"); FAIL=$((FAIL+1))
  fi
}

real_tmpdir() { ( cd "$(mktemp -d)" && pwd -P ); }

# The ten names acceptance criterion 1 ITSELF spells out. Hand-typed ON PURPOSE, and the cold
# fidelity review is why: deriving the roster only from the binary's own output makes the roster's
# IDENTITY untestable — a typo'd, duplicated or swapped role name would be faithfully re-derived and
# re-checked against itself, and every roster check would stay green. The count alone does not catch
# that. So this list is the independent side of the comparison; `canonical_roles` is the product's
# side; check 11 asserts they are equal. If the roster legitimately changes, this line changes with
# it — deliberately, as a decision, which is the opposite of drift.
CRITERION_ROLES="demo-producer design-advisor fidelity-reviewer implementation-advisor plan-advisor qa-specialist release-coordinator requirements-analyst researcher tech-lead"

# The roster as the BINARY reports it.
canonical_roles() {
  ( cd "$(real_tmpdir)" && "$VAJRA" init --sync-fleet --dry-run 2>&1 ) \
    | sed -n 's#.*\.claude/agents/\(.*\)\.md.*#\1#p' | sort
}

# ── 1 · an empty repo syncs to the full canonical roster, byte-for-byte ────────────────────────
sync_creates_full_canonical_roster() {
  local rc=0 SB; SB="$(real_tmpdir)"
  ( cd "$SB" && "$VAJRA" init --sync-fleet ) || { echo "FAIL: sync exited non-zero on an empty repo"; return 1; }
  local N; N="$(ls "$SB/.claude/agents" 2>/dev/null | wc -l | tr -d ' ')"
  echo "roles written: $N"
  [ "$N" -ge 10 ] || { echo "FAIL: expected the full roster (>=10), got $N"; rc=1; }
  # Byte-for-byte against THIS repo's own agents, which are themselves rendered from the one source.
  local role
  for role in $(canonical_roles); do
    cmp -s "$ROOT/.claude/agents/$role.md" "$SB/.claude/agents/$role.md" \
      || { echo "FAIL: $role.md is not byte-identical to the canonical render"; rc=1; }
  done
  echo "byte-for-byte against $ROOT/.claude/agents: checked $(canonical_roles | wc -l | tr -d ' ') roles"
  return $rc
}
run_check "empty-repo-syncs-to-canonical-roster-byte-for-byte" exec sync_creates_full_canonical_roster

# ── 2 · idempotence: the second run writes nothing ─────────────────────────────────────────────
sync_is_idempotent() {
  local rc=0 SB; SB="$(real_tmpdir)"
  ( cd "$SB" && "$VAJRA" init --sync-fleet >/dev/null 2>&1 ) || { echo "FAIL: first run"; return 1; }
  local ROLE; ROLE="$(canonical_roles | head -1)"
  local BEFORE; BEFORE="$(shasum -a 256 "$SB/.claude/agents/$ROLE.md" | cut -d' ' -f1)"
  local OUT; OUT="$( cd "$SB" && "$VAJRA" init --sync-fleet 2>&1 )" || { echo "FAIL: second run exited non-zero"; rc=1; }
  echo "$OUT"
  echo "$OUT" | grep -q "already current" || { echo "FAIL: second run did not report the roster current"; rc=1; }
  echo "$OUT" | grep -qE "^\s*(create|refresh)" && { echo "FAIL: second run wrote something"; rc=1; }
  local AFTER; AFTER="$(shasum -a 256 "$SB/.claude/agents/$ROLE.md" | cut -d' ' -f1)"
  [ "$BEFORE" = "$AFTER" ] || { echo "FAIL: an up-to-date file was rewritten"; rc=1; }
  return $rc
}
run_check "second-run-is-a-no-op" exec sync_is_idempotent

# ── 3 · drift is reported and REFUSED, and the file is left untouched ──────────────────────────
drift_is_refused_not_clobbered() {
  local rc=0 SB; SB="$(real_tmpdir)"
  local ROLE; ROLE="$(canonical_roles | head -1)"
  mkdir -p "$SB/.claude/agents"
  printf 'an older render\n' > "$SB/.claude/agents/$ROLE.md"
  local OUT EC
  OUT="$( cd "$SB" && "$VAJRA" init --sync-fleet 2>&1 )"; EC=$?
  echo "$OUT"; echo "exit: $EC"
  [ "$EC" -ne 0 ] || { echo "FAIL: unresolved drift exited 0 — a stale roster would look synced"; rc=1; }
  echo "$OUT" | grep -q "DRIFT" || { echo "FAIL: the drift was not reported"; rc=1; }
  echo "$OUT" | grep -q -- "--overwrite-drifted" || { echo "FAIL: the message does not name the resolving flag"; rc=1; }
  [ "$(cat "$SB/.claude/agents/$ROLE.md")" = "an older render" ] \
    || { echo "FAIL: the drifted file was rewritten — refusing must mean refusing"; rc=1; }
  # A refusal on one file must not abort the rest: every other role is still created.
  local other; other="$(canonical_roles | sed -n '2p')"
  [ -f "$SB/.claude/agents/$other.md" ] || { echo "FAIL: a refusal on one file aborted the others"; rc=1; }
  return $rc
}
run_check "drift-refused-file-untouched-flag-named" exec drift_is_refused_not_clobbered

# ── 4 · the explicit escape really works ───────────────────────────────────────────────────────
overwrite_drifted_refreshes() {
  local rc=0 SB; SB="$(real_tmpdir)"
  local ROLE; ROLE="$(canonical_roles | head -1)"
  mkdir -p "$SB/.claude/agents"
  printf 'an older render\n' > "$SB/.claude/agents/$ROLE.md"
  ( cd "$SB" && "$VAJRA" init --sync-fleet --overwrite-drifted ) \
    || { echo "FAIL: --overwrite-drifted exited non-zero"; return 1; }
  cmp -s "$ROOT/.claude/agents/$ROLE.md" "$SB/.claude/agents/$ROLE.md" \
    || { echo "FAIL: the drifted file was not refreshed to canonical"; rc=1; }
  return $rc
}
run_check "overwrite-drifted-restores-canonical" exec overwrite_drifted_refreshes

# ── 5 · the dry run is a TRUE preview ──────────────────────────────────────────────────────────
dry_run_is_a_true_preview() {
  local rc=0 SB; SB="$(real_tmpdir)"
  local OUT; OUT="$( cd "$SB" && "$VAJRA" init --sync-fleet --dry-run 2>&1 )" \
    || { echo "FAIL: dry run over a clean empty repo exited non-zero"; rc=1; }
  echo "$OUT"
  [ -d "$SB/.claude/agents" ] && { echo "FAIL: the dry run created files"; rc=1; }
  echo "$OUT" | grep -q "DRY RUN" || { echo "FAIL: the dry run does not announce itself"; rc=1; }
  echo "$OUT" | grep -q "to create" || { echo "FAIL: a dry run must not claim work it did not do"; rc=1; }
  # The verdict half: drift + dry-run must return what the real run would, not a kinder answer.
  local ROLE; ROLE="$(canonical_roles | head -1)"
  mkdir -p "$SB/.claude/agents"; printf 'an older render\n' > "$SB/.claude/agents/$ROLE.md"
  ( cd "$SB" && "$VAJRA" init --sync-fleet --dry-run >/dev/null 2>&1 ) \
    && { echo "FAIL: a dry run over drift exited 0 where the real run exits 1"; rc=1; }
  return $rc
}
run_check "dry-run-previews-plan-and-verdict-writes-nothing" exec dry_run_is_a_true_preview

# ── 6 · scoped to the fleet: no other scaffold entry rides along ────────────────────────────────
sync_touches_only_the_agents_dir() {
  local rc=0 SB; SB="$(real_tmpdir)"
  ( cd "$SB" && "$VAJRA" init --sync-fleet >/dev/null 2>&1 ) || { echo "FAIL: sync"; return 1; }
  local TOP; TOP="$(ls -A "$SB")"
  echo "top level after sync: $TOP"
  [ "$TOP" = ".claude" ] || { echo "FAIL: sync-fleet wrote outside .claude/"; rc=1; }
  local unwanted
  for unwanted in .ai scripts prompts sessions .githooks; do
    [ -e "$SB/$unwanted" ] && { echo "FAIL: $unwanted/ was scaffolded by --sync-fleet"; rc=1; }
  done
  return $rc
}
run_check "sync-fleet-does-not-run-the-full-init-scaffold" exec sync_touches_only_the_agents_dir

# ── 7 · chitra really carries the canonical roster ──────────────────────────────────────────────
chitra_carries_the_canonical_roster() {
  local rc=0
  [ -d "$CHITRA/.claude/agents" ] \
    || { echo "FAIL: chitra not found at $CHITRA — this check FAILS on absence, it never skips (S69)"; return 1; }
  # The cold review's rec 4: comparing chitra to THIS repo's `.claude/agents/*.md` is one hop from
  # the acceptance criterion, which names `render_subagent_definition`. The hop is only sound while
  # this repo's own files ARE the current render — an assumption nothing checked. So check it: a
  # sync over this repo reporting every role already current is exactly that proof, from the product.
  local SELF; SELF="$( cd "$ROOT" && "$VAJRA" init --sync-fleet --dry-run 2>&1 )"
  echo "$SELF" | grep -q "0 to create, 0 to refresh" \
    || { echo "FAIL: this repo's own .claude/agents are NOT the current render — the comparison basis is unsound"; rc=1; }
  echo "$SELF" | grep -q "0 drifted" \
    || { echo "FAIL: this repo's own .claude/agents are drifted — cannot serve as the canonical basis"; rc=1; }
  local role N=0
  for role in $(canonical_roles); do
    if cmp -s "$ROOT/.claude/agents/$role.md" "$CHITRA/.claude/agents/$role.md"; then
      N=$((N+1))
    else
      echo "FAIL: chitra's $role.md is absent or not byte-identical to the canonical render"; rc=1
    fi
  done
  echo "chitra roles byte-identical to canonical: $N"
  [ "$N" -ge 10 ] || { echo "FAIL: expected the full ten-role roster in chitra, matched $N"; rc=1; }
  return $rc
}
run_check "chitra-carries-all-ten-roles-byte-for-byte" exec chitra_carries_the_canonical_roster

# ── 8 · the crew gate BINDS inside chitra, at a session far below the 133 threshold ─────────────
crew_gate_binds_inside_chitra() {
  local rc=0
  [ -d "$CHITRA/.ai" ] || { echo "FAIL: chitra not found at $CHITRA (S69: absence is RED)"; return 1; }
  local OUT EC
  OUT="$( cd "$CHITRA" && "$VAJRA" next --check-crew 16 2>&1 )"; EC=$?
  echo "$OUT"; echo "exit: $EC"
  # An unrecognised flag falls through to the dump and exits 0 (S132) — require the gate's OWN header.
  echo "$OUT" | grep -q "=== crew: tech-lead for session 16 ===" \
    || { echo "FAIL: this is not the crew gate's output"; rc=1; }
  [ "$EC" -eq 1 ] || { echo "FAIL: the crew gate did not BLOCK in chitra (exit $EC)"; rc=1; }
  echo "$OUT" | grep -q "NOT READY" || { echo "FAIL: no NOT READY verdict"; rc=1; }
  echo "$OUT" | grep -q "FIRST and MANDATORY dispatch" \
    || { echo "FAIL: the block does not name the tech-lead as first-and-mandatory"; rc=1; }
  # The no-threshold rule, proven in a real brownfield project: 16 is far below 133.
  echo "$OUT" | grep -q "session-16-tech-lead.md" \
    || { echo "FAIL: the gate did not resolve chitra's own session-16 handoff path"; rc=1; }
  return $rc
}
run_check "crew-gate-binds-in-chitra-at-session-16" exec crew_gate_binds_inside_chitra

# ── 9 · chitra undisturbed the four ways, against the pre-write baseline ────────────────────────
chitra_undisturbed_four_ways() {
  local rc=0
  [ -f "$BASELINE" ] || { echo "FAIL: baseline record missing at $BASELINE (S69: absence is RED)"; return 1; }
  [ -d "$CHITRA/.git" ] || { echo "FAIL: chitra not found at $CHITRA (S69: absence is RED)"; return 1; }
  local B_HEAD B_BRANCH B_INDEX B_STASH B_STATUS
  B_HEAD="$(sed -n 's/^HEAD=//p' "$BASELINE")"
  B_BRANCH="$(sed -n 's/^BRANCH=//p' "$BASELINE")"
  B_INDEX="$(sed -n 's/^INDEX=//p' "$BASELINE")"
  B_STASH="$(sed -n 's/^STASH_COUNT=//p' "$BASELINE")"
  B_STATUS="$(sed -n 's/^STATUS_MINUS_DECLARED_SHA=//p' "$BASELINE")"
  local N_HEAD N_BRANCH N_INDEX N_STASH N_STATUS
  N_HEAD="$(   git -C "$CHITRA" rev-parse HEAD )"
  N_BRANCH="$( git -C "$CHITRA" branch --show-current )"
  N_INDEX="$(  git -C "$CHITRA" write-tree )"
  N_STASH="$(  git -C "$CHITRA" stash list | wc -l | tr -d ' ' )"
  N_STATUS="$( git -C "$CHITRA" status --porcelain | grep -v '\.claude/agents/' | shasum -a 256 | cut -d' ' -f1 )"
  printf '  %-14s %s\n' "HEAD"   "$N_HEAD"
  printf '  %-14s %s\n' "BRANCH" "$N_BRANCH"
  printf '  %-14s %s\n' "INDEX"  "$N_INDEX"
  printf '  %-14s %s\n' "STASH"  "$N_STASH"
  printf '  %-14s %s\n' "STATUS" "$N_STATUS"
  [ "$N_HEAD"   = "$B_HEAD"   ] || { echo "FAIL: chitra HEAD moved"; rc=1; }
  [ "$N_BRANCH" = "$B_BRANCH" ] || { echo "FAIL: chitra branch changed"; rc=1; }
  [ "$N_INDEX"  = "$B_INDEX"  ] || { echo "FAIL: chitra index tree changed"; rc=1; }
  [ "$N_STASH"  = "$B_STASH"  ] || { echo "FAIL: chitra stash list changed"; rc=1; }
  # The exact criterion-4 proof: everything outside the pre-declared paths hashes the same.
  [ "$N_STATUS" = "$B_STATUS" ] \
    || { echo "FAIL: something outside the declared .claude/agents/ paths changed in chitra"; rc=1; }
  # And every path that DID change must be one that was declared by name before any write.
  local changed
  changed="$( git -C "$CHITRA" status --porcelain | awk '{print $NF}' | grep '^\.claude/agents/' || true )"
  local p
  for p in $changed; do
    grep -q "^DECLARE $p " "$BASELINE" || { echo "FAIL: $p changed but was never declared"; rc=1; }
  done
  echo "declared paths changed: $(echo "$changed" | grep -c . || true)"
  # CONTENT level. The path-level status hash above cannot see an append to a file chitra had
  # already modified — falsifiability probe C proved exactly that hole, so it is closed here.
  local B_DIFF B_UNTRACKED N_DIFF N_UNTRACKED
  B_DIFF="$(      sed -n 's/^TRACKED_DIFF_SHA=//p' "$BASELINE" )"
  B_UNTRACKED="$( sed -n 's/^UNTRACKED_SHA=//p'    "$BASELINE" )"
  N_DIFF="$( git -C "$CHITRA" diff HEAD -- . ':(exclude).claude/agents' | shasum -a 256 | cut -d' ' -f1 )"
  N_UNTRACKED="$( git -C "$CHITRA" ls-files --others --exclude-standard \
    | grep -v '^\.claude/agents/' | sort | shasum -a 256 | cut -d' ' -f1 )"
  printf '  %-14s %s\n' "DIFF"      "$N_DIFF"
  printf '  %-14s %s\n' "UNTRACKED" "$N_UNTRACKED"
  [ -n "$B_DIFF" ] || { echo "FAIL: no TRACKED_DIFF_SHA in the baseline record"; rc=1; }
  [ "$N_DIFF"      = "$B_DIFF"      ] || { echo "FAIL: tracked content outside the declared paths changed"; rc=1; }
  [ "$N_UNTRACKED" = "$B_UNTRACKED" ] || { echo "FAIL: the untracked file set outside the declared paths changed"; rc=1; }
  return $rc
}
run_check "chitra-undisturbed-outside-pre-declared-paths" exec chitra_undisturbed_four_ways

# ── 10 · the unit suite behind the classification ───────────────────────────────────────────────
run_check "sync-fleet-unit-suite" exec cargo test --release --lib cli::init::tests

# ── 11 · nothing else moved ─────────────────────────────────────────────────────────────────────
nothing_else_moved() {
  local rc=0
  # Still SEVEN top-level commands. STRUCTURAL, not an allow-list: the cold review found that
  # grepping for the seven KNOWN names counts 7 even when an eighth command exists under a new name.
  # Read the front door's own usage line, which enumerates the commands it dispatches.
  local USAGE; USAGE="$("$VAJRA" --help 2>&1 | grep -oE 'vajra <[a-z|]+>' | head -1)"
  echo "front-door usage: $USAGE"
  [ -n "$USAGE" ] || { echo "FAIL: could not read the front door's usage line"; rc=1; }
  local CMDS; CMDS="$(echo "$USAGE" | sed 's/vajra <//; s/>//' | tr '|' '\n' | grep -c .)"
  echo "top-level commands enumerated: $CMDS"
  [ "$CMDS" -eq 7 ] || { echo "FAIL: the seven-command ceiling moved (got $CMDS)"; rc=1; }
  # The roster is still ten roles AND still the ten roles the acceptance criterion NAMES. The count
  # alone cannot catch a typo'd or swapped name — the cold review's rec 2.
  local N; N="$(canonical_roles | wc -l | tr -d ' ')"
  echo "canonical roles: $N"
  [ "$N" -eq 10 ] || { echo "FAIL: the fleet is no longer ten roles (got $N)"; rc=1; }
  local DERIVED EXPECTED
  DERIVED="$(canonical_roles | tr '\n' ' ' | sed 's/ *$//')"
  EXPECTED="$(echo "$CRITERION_ROLES" | tr ' ' '\n' | sort | tr '\n' ' ' | sed 's/ *$//')"
  echo "derived : $DERIVED"
  echo "criterion: $EXPECTED"
  [ "$DERIVED" = "$EXPECTED" ] \
    || { echo "FAIL: the roster's NAMES differ from the ten the acceptance criterion spells out"; rc=1; }
  # K of 8 is unchanged — sync-fleet is a scaffold action, not a ninth station.
  "$VAJRA" next --stations 136 2>&1 | grep -q "of 8" || { echo "FAIL: K of 8 shape changed"; rc=1; }
  return $rc
}
run_check "nothing-else-moved-7-commands-10-roles-k-of-8" exec nothing_else_moved

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

# ── tally ───────────────────────────────────────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════════════"
printf '%s\n' "${RESULTS[@]}"
echo "────────────────────────────────────────────────────────────────────"
print_tally "$EXEC_N" "$STRUCT_N" "$BEHAV_N" "$NESTED_N" ${NESTED_NAMES[@]+"${NESTED_NAMES[@]}"}
echo "────────────────────────────────────────────────────────────────────"
echo "session 136 verify: ${PASS} passed, ${FAIL} failed"
[ "$FAIL" -eq 0 ] && echo "RESULT: PASS" || echo "RESULT: FAIL"
[ "$FAIL" -eq 0 ]
