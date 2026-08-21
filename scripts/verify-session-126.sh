#!/usr/bin/env bash
# Verify — Session 126: the last five fleet roles; the roster closed at nine.
#
# What this suite must actually prove, beyond "the roles exist":
#   1. the real binary scaffolds NINE roles and the repo's copies are exactly its render;
#   2. each of the five NEW roles governs a real handoff through the unchanged S109 path;
#   3. NOTHING else moved — `K of 8` is untouched, no 8th command, and the execution allowlist is
#      still exactly one role (five roles added, zero new grants of Bash);
#   4. each of the five was really DISPATCHED BY NAME, cross-checked the S111 way against two
#      files Claude Code itself wrote — and that cross-check is shown going RED on a forged id, so
#      it is not a check that cannot fail;
#   5. the residual is on the record: the roster is complete and nothing depends on it.
#
# CHECK CLASSES — the S121/S122/S123 contract: EXECUTE-BASED (runs the product, asserts on real
# output) · STRUCTURAL grep (asserts architecture: one source, no collision, set equality — no
# runtime output exists to exercise) · BEHAVIORAL grep (greps source for a string and treats it as
# proof the feature works — HOLLOW, named in the disclosure) · NESTED (runs another whole suite).
#
# S126 CARRIES ONE BEHAVIORAL CHECK, the same hardcoded-banner grep named since S69. It is
# labelled, not relabelled.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

# shellcheck source=scripts/lib-tally.sh
source "$ROOT/scripts/lib-tally.sh"

SESSION="126"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

VAJRA="$ROOT/target/release/vajra"
[ -x "$VAJRA" ] || cargo build -q --release || { echo "release build failed"; exit 2; }

NEW_ROLES="requirements-analyst design-advisor implementation-advisor demo-producer release-coordinator"
ALL_ROLES="researcher fidelity-reviewer plan-advisor qa-specialist $NEW_ROLES"
DISPATCH="sessions/session-126-artifacts/dispatch"

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
    RESULTS+=("$(printf '%-40s %-7s %s' "$NAME" "$CLASS" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-40s %-7s %s' "$NAME" "$CLASS" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- toolchain: unchanged discipline ------------------------------------------------------------
run_check "cargo-build"   exec cargo build --all-targets
run_check "cargo-test"    exec cargo test --lib
run_check "cargo-fmt"     exec cargo fmt -- --check
run_check "cargo-clippy"  exec cargo clippy --all-targets -- -D warnings

# --- 1. the real binary scaffolds NINE roles, and the repo's copies ARE that render --------------
# `vajra init` blocks forever on stdin without EOF (S121) — always </dev/null.
scaffolds_nine_roles() {
  local TMP; TMP="$(mktemp -d)"; local rc=0
  ( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null </dev/null ) \
    || { echo "FAIL: vajra init failed"; rm -rf "$TMP"; return 1; }
  local N; N="$(ls -1 "$TMP/.claude/agents" | wc -l | tr -d ' ')"
  echo "--- what the real binary rendered ---"; ls -1 "$TMP/.claude/agents"
  [ "$N" = "9" ] || { echo "FAIL: expected 9 scaffolded agent files, got $N"; rc=1; }
  # Byte-identity, per role — the repo's committed copy is a RENDER, never a hand-written twin.
  local r
  for r in $ALL_ROLES; do
    diff -u "$TMP/.claude/agents/$r.md" "$ROOT/.claude/agents/$r.md" \
      || { echo "FAIL: the repo's $r.md has drifted from the render"; rc=1; }
  done
  # EXACTLY the rendered set — an extra hand-written file would be a real second source of role
  # text sitting in the one place nothing looks (S114 cold-review finding).
  if ! diff <(cd "$TMP/.claude/agents" && ls -1 | sort) <(cd "$ROOT/.claude/agents" && ls -1 | sort); then
    echo "FAIL: .claude/agents/ holds files vajra init does not render"; rc=1
  fi
  rm -rf "$TMP"
  [ "$rc" -eq 0 ] && echo "OK: $N roles scaffolded byte-identical to this repo's copies"
  return $rc
}
run_check "init-scaffolds-nine-roles" exec scaffolds_nine_roles

# --- 2. each NEW role governs a real handoff through the unchanged S109 path ---------------------
new_roles_govern_handoffs() {
  local TMP; TMP="$(mktemp -d)"; local rc=0
  ( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null </dev/null ) \
    || { echo "FAIL: vajra init failed"; rm -rf "$TMP"; return 1; }
  echo "126" > "$TMP/.ai/SESSION"
  local r OUT
  for r in $NEW_ROLES; do
    printf 'Findings for %s.\nThe marker this station parses is named in the role prompt.\n' "$r" \
      > "$TMP/brief-$r.md"
    OUT="$( cd "$TMP" && "$VAJRA" next --role "$r" --from "brief-$r.md" 2>&1 )" || {
      echo "FAIL: vajra next --role $r exited non-zero"; echo "$OUT"; rc=1; continue; }
    local H="$TMP/.ai/handoffs/session-126-$r.md"
    [ -f "$H" ] || { echo "FAIL: no governed handoff written for $r"; rc=1; continue; }
    grep -q "^role: $r$"    "$H" || { echo "FAIL: $r handoff has no role frontmatter"; rc=1; }
    grep -q "^session: 126$" "$H" || { echo "FAIL: $r handoff is filed under the wrong session"; rc=1; }
    grep -q "^source-sha: [0-9a-f]\{64\}$" "$H" || { echo "FAIL: $r handoff has no real source-sha"; rc=1; }
    grep -q "## Handoff Delta" "$H" || { echo "FAIL: $r handoff has no tracked delta"; rc=1; }
    grep -q "first $r handoff" "$H" || { echo "FAIL: $r handoff's delta does not name its own role"; rc=1; }
    echo "  $r → $(sed -n 's/^source-sha: //p' "$H" | cut -c1-12)… governed + validated"
  done
  # FAIL-CLOSED, exercised: an unknown role must be refused, or "governs a handoff" means nothing.
  if ( cd "$TMP" && "$VAJRA" next --role no-such-role --from "brief-demo-producer.md" >/dev/null 2>&1 ); then
    echo "FAIL: an unknown role was governed instead of refused"; rc=1
  else
    echo "OK: an unknown role is refused (fail-closed)"
  fi
  rm -rf "$TMP"; return $rc
}
run_check "new-roles-govern-handoffs" exec new_roles_govern_handoffs

# --- 3a. no station-name collision: the station words do NOT resolve as roles --------------------
# EXECUTE-BASED: it runs the real binary and asserts on its exit code and message, not on source.
no_station_collision() {
  local TMP; TMP="$(mktemp -d)"; local rc=0
  ( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null </dev/null ) || { rm -rf "$TMP"; return 1; }
  echo "126" > "$TMP/.ai/SESSION"; echo "x" > "$TMP/b.md"
  local w OUT
  for w in analyst architect coder demoer releaser planner reviewer qa; do
    if ( cd "$TMP" && "$VAJRA" next --role "$w" --from b.md >/dev/null 2>&1 ); then
      echo "FAIL: the station word '$w' resolves as a role key — a role shadows a station"; rc=1
    else
      echo "  '$w' → refused (station word, not a role key)"
    fi
  done
  # Positive control: the real keys DO resolve, so this is not a check that refuses everything.
  for w in $NEW_ROLES; do
    ( cd "$TMP" && "$VAJRA" next --role "$w" --from b.md >/dev/null 2>&1 ) \
      || { echo "FAIL: the registered role '$w' does not resolve"; rc=1; }
  done
  OUT="$( cd "$TMP" && "$VAJRA" next --role analyst --from b.md 2>&1 )"
  grep -q "requirements-analyst" <<<"$OUT" \
    || { echo "FAIL: the fail-closed message does not even list the known roles"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "no-station-collision" exec no_station_collision

# --- 3b. K of 8 is untouched by the roster, with all five handoffs present -----------------------
k_of_8_unchanged() {
  local TMP; TMP="$(mktemp -d)"; local rc=0
  ( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null </dev/null ) || { rm -rf "$TMP"; return 1; }
  echo "126" > "$TMP/.ai/SESSION"
  local BEFORE AFTER r
  BEFORE="$( cd "$TMP" && "$VAJRA" next --stations 126 2>&1 | grep -oE '[0-9]+ of 8 stations passed' )"
  for r in $NEW_ROLES; do
    printf 'Findings for %s.\n' "$r" > "$TMP/b-$r.md"
    ( cd "$TMP" && "$VAJRA" next --role "$r" --from "b-$r.md" >/dev/null 2>&1 ) || { rc=1; }
  done
  local OUT; OUT="$( cd "$TMP" && "$VAJRA" next --stations 126 2>&1 )"
  AFTER="$( grep -oE '[0-9]+ of 8 stations passed' <<<"$OUT" )"
  echo "before five handoffs: $BEFORE"
  echo "after  five handoffs: $AFTER"
  [ -n "$BEFORE" ] && [ "$BEFORE" = "$AFTER" ] \
    || { echo "FAIL: the roster moved K — K must be derived from station gates alone"; rc=1; }
  # ...and the fleet evidence IS reported beside K, so "unchanged" is not "invisible".
  grep -q "5 governed handoff(s)" <<<"$OUT" \
    || { echo "FAIL: five governed handoffs are on disk but the counter does not report them"; rc=1; }
  grep -q "NOT counted in it" <<<"$OUT" \
    || { echo "FAIL: the counter does not disclose that fleet evidence is not counted in K"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "k-of-8-unchanged-by-the-roster" exec k_of_8_unchanged

# --- 3c. five roles added, ZERO new grants of Bash (token-exact, on the real render) -------------
# The S122 parser: split on commas and compare WHOLE tokens — a substring test cannot tell `Edit`
# from `NotebookEdit`, and `grep -qw` treats `-` as a word boundary (so `qa` would match inside
# `qa-specialist`).
MAY_EXECUTE="qa-specialist"
FORBIDDEN="Bash Write Edit NotebookEdit Task"
execution_allowlist_did_not_grow() {
  local TMP; TMP="$(mktemp -d)"; local rc=0 BASH_N=0 N=0
  ( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null </dev/null ) || { rm -rf "$TMP"; return 1; }
  local f NAME TOOLS TOK t ALLOWED a
  for f in "$TMP"/.claude/agents/*.md; do
    N=$((N+1))
    NAME="$(sed -n 's/^name: \(.*\)$/\1/p' "$f" | head -1)"
    TOOLS="$(sed -n 's/^tools: \(.*\)$/\1/p' "$f" | head -1)"
    { [ -n "$NAME" ] && [ -n "$TOOLS" ]; } \
      || { echo "FAIL: $(basename "$f") has no name:/tools: line — cannot evaluate, so it fails"; rc=1; continue; }
    grep -q "Bash" <<<"$TOOLS" && BASH_N=$((BASH_N+1))
    ALLOWED=0; for a in $MAY_EXECUTE; do [ "$NAME" = "$a" ] && ALLOWED=1; done
    if [ "$ALLOWED" = "1" ]; then echo "  $NAME: [$TOOLS] (allowlisted)"; continue; fi
    echo "  $NAME: [$TOOLS]"
    while IFS= read -r TOK; do
      [ -n "$TOK" ] || continue
      for t in $FORBIDDEN; do
        [ "$TOK" = "$t" ] && { echo "FAIL: $NAME grants '$t'"; rc=1; }
      done
    done < <(tr ',' '\n' <<<"$TOOLS" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
  done
  [ "$N" = "9" ] || { echo "FAIL: expected 9 roles to police, saw $N"; rc=1; }
  [ "$BASH_N" = "1" ] || { echo "FAIL: $BASH_N roles grant Bash — the allowlist grew"; rc=1; }
  rm -rf "$TMP"
  [ "$rc" -eq 0 ] && echo "OK: 9 roles, exactly 1 may execute; the other 8 are token-exact read-only"
  return $rc
}
run_check "execution-allowlist-did-not-grow" exec execution_allowlist_did_not_grow

# --- 4. the five dispatches, cross-checked against the COMMITTED evidence ------------------------
# The S111 shape: two files Claude Code itself wrote, in two different places, agreeing on a random
# tool-call id neither Vajra nor this suite chose. $1 = the directory of evidence to check, so the
# fixture below can drive this same function against a forged copy.
cross_check_dir() {
  python3 - "$1" "$NEW_ROLES" <<'PYEOF'
import glob, json, os, sys
d, roles = sys.argv[1], sys.argv[2].split()
bad = 0
for r in roles:
    try:
        tu = json.load(open(os.path.join(d, f"{r}-parent-tooluse.json")))[0]
        meta = json.load(open(os.path.join(d, f"{r}-subagent-meta.json")))
    except Exception as e:
        print(f"FAIL {r}: evidence unreadable ({e}) — cannot evaluate, so it fails"); bad = 1; continue
    if tu.get("input", {}).get("subagent_type") != r:
        print(f"FAIL {r}: parent tool_use requested {tu.get('input',{}).get('subagent_type')!r}"); bad = 1
    if meta.get("agentType") != r:
        print(f"FAIL {r}: subagent meta resolved {meta.get('agentType')!r}"); bad = 1
    if not tu.get("id") or tu["id"] != meta.get("toolUseId"):
        print(f"FAIL {r}: parent id {tu.get('id')!r} != subagent toolUseId {meta.get('toolUseId')!r}"); bad = 1
        continue
    t = os.path.join(d, f"{r}-subagent-transcript.jsonl")
    usage = False
    for line in open(t):
        line = line.strip()
        if not line:
            continue
        v = json.loads(line)
        if v.get("type") == "assistant" and (v.get("message") or {}).get("usage"):
            usage = True
    if not usage:
        print(f"FAIL {r}: subagent transcript carries no real assistant usage line"); bad = 1; continue
    print(f"OK {r}: subagent_type == agentType == {r}, both on tool-call {tu['id']}")
sys.exit(bad)
PYEOF
}
run_check "five-dispatches-cross-check" exec cross_check_dir "$DISPATCH"

# THE FALSIFIABILITY FIXTURE: the same function, driven over a copy with ONE forged id. It must go
# RED there and stay GREEN on the untouched copy — otherwise "cross-checked" is a claim, not a test.
cross_check_has_teeth() {
  local TMP; TMP="$(mktemp -d)"; local rc=0
  cp "$DISPATCH"/*.json "$DISPATCH"/*.jsonl "$TMP/" 2>/dev/null
  echo "--- control: the committed evidence, unmodified (must be GREEN) ---"
  if cross_check_dir "$TMP" >/dev/null 2>&1; then echo "OK: green on unmodified copies"
  else echo "FAIL: red on unmodified copies — the fixture proves nothing"; rc=1; fi

  echo "--- planted forgery: one subagent meta claims a different tool-call id ---"
  python3 - "$TMP" <<'PYEOF'
import json, os, sys
p = os.path.join(sys.argv[1], "demo-producer-subagent-meta.json")
m = json.load(open(p)); m["toolUseId"] = "toolu_" + "0" * 22
json.dump(m, open(p, "w"))
PYEOF
  if cross_check_dir "$TMP" >/dev/null 2>&1; then
    echo "FAIL: the cross-check accepted a forged tool-call id"; rc=1
  else
    echo "OK: a forged id is REJECTED"
  fi

  echo "--- planted forgery 2: the parent asked for a different subagent_type ---"
  cp "$DISPATCH/demo-producer-subagent-meta.json" "$TMP/"
  python3 - "$TMP" <<'PYEOF'
import json, os, sys
p = os.path.join(sys.argv[1], "demo-producer-parent-tooluse.json")
tu = json.load(open(p)); tu[0]["input"]["subagent_type"] = "general-purpose"
json.dump(tu, open(p, "w"))
PYEOF
  if cross_check_dir "$TMP" >/dev/null 2>&1; then
    echo "FAIL: the cross-check accepted a dispatch of a different agent type"; rc=1
  else
    echo "OK: a different subagent_type is REJECTED"
  fi
  rm -rf "$TMP"; return $rc
}
run_check "cross-check-has-teeth" exec cross_check_has_teeth

# --- 5. the role text still lives in exactly ONE hand-maintained file ----------------------------
# STRUCTURAL: the claim is "this text exists in exactly one hand-maintained file", which has no
# runtime output to exercise. The probe is a fragment of a NEW role's prompt, sitting UNBROKEN on
# one source line (a phrase split across a `\`-continuation is invisible to grep — the S114 trap).
S126_PROBE="A demo that prints claims is theatre"
one_source_of_new_role_text() {
  local HITS
  HITS="$( grep -rl "$S126_PROBE" . 2>/dev/null \
    | grep -v '^\./target/' | grep -v '^\./\.git/' \
    | grep -v '^\./\.ai/verify/' | grep -v '^\./\.ai/handoffs/' \
    | grep -v '^\./\.claude/agents/' | grep -v '^\./docs/decisions/' \
    | grep -v '^\./sessions/' \
    | grep -v '^\./scripts/verify-session-126\.sh$' \
    | sort )"
  # Exclusions, in prose so the list is not a wall of greps: target/ .git/ = build output and
  # history; .ai/verify/ + .ai/handoffs/ = VAJRA-GENERATED (the S122 booby-trap); .claude/agents/ =
  # the RENDER, byte-checked above; docs/decisions/ + sessions/ = the written record quoting the
  # decision; and THIS script only — the check has to name the probe to test for it. Deliberately
  # NOT a wildcard over verify-session-NN.sh (S122 pass 2: that licenses every future suite to
  # carry role text). Any other script mentioning it uses a fragment of a fragment.
  echo "carriers of the new-role prompt text:"; echo "$HITS"
  grep -q '^\./src/fleet/mod\.rs$' <<<"$HITS" \
    || { echo "FAIL: the probe does not even match the canonical source — it proves nothing"; return 1; }
  local N; N="$(grep -c . <<<"$HITS")"
  [ "$N" = "1" ] || { echo "FAIL: the new role text lives in $N hand-maintained files, not 1:"; \
    grep -v '^\./src/fleet/mod\.rs$' <<<"$HITS" | sed 's/^/    - /'; return 1; }
  echo "OK: the new roles' prompt text exists in exactly one hand-maintained file"
}
run_check "one-source-of-new-role-text" struct one_source_of_new_role_text

# --- 6. the residual is ON THE RECORD, in the decision that shipped the roles --------------------
# STRUCTURAL: the claim is about the written record, and it is asserted as such — this proves a
# disclosure exists, never that the fleet works.
residual_is_recorded() {
  local D="docs/decisions/DECISION-007-agent-fleet.md"
  grep -q "## S126 addendum" "$D" || { echo "FAIL: no S126 addendum in DECISION-007"; return 1; }
  local S; S="$(sed -n '/## S126 addendum/,$p' "$D")"
  local phrase
  for phrase in "Nothing depends on it" "no gate anywhere consumes a handoff" \
                "requirements-analyst" "design-advisor" "implementation-advisor" \
                "demo-producer" "release-coordinator" "rejected alternative"; do
    grep -qi -- "$phrase" <<<"$S" || { echo "FAIL: the addendum does not record: $phrase"; return 1; }
  done
  echo "OK: the addendum records all five keys, their rejected alternatives, and the residual"
}
run_check "residual-is-recorded" struct residual_is_recorded

# --- 7. the chain that this session's change could have broken, re-run LIVE ----------------------
# NESTED, and load-bearing: verify-session-122.sh re-runs the S121 suite inside itself, so this one
# call re-proves both. S126's only edit outside the fleet was to a roster-SIZE pin in the S121
# suite; running the chain is how that edit is proven harmless rather than asserted harmless.
run_check "s121-s122-chain-still-green" nested bash scripts/verify-session-122.sh

# --- 8. the non-goals stay non-goals ------------------------------------------------------------
# BEHAVIORAL, and labelled so — the same hardcoded-banner grep named since S69: it runs the real
# binary, but what it asserts on is a usage string an 8th command could be added without touching.
help_lists_seven() {
  local help; help="$("$VAJRA" --help 2>&1)"; echo "$help"
  grep -q "vajra <init|claude|check|next|estimate|hook|meter>" <<<"$help"
}
run_check "no-eighth-command" behav help_lists_seven

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session 126 Verify Summary ==="
printf '%-40s %-7s %s\n' "STEP" "CLASS" "RESULT"
printf '%-40s %-7s %s\n' "----------------------------------------" "-------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo ""
print_tally "$EXEC_N" "$STRUCT_N" "$BEHAV_N" "$NESTED_N" "${NESTED_NAMES[@]:-}"
echo ""
echo "WHAT THIS SUITE NEVER EXERCISED: whether any gate, script, or session REACHES FOR a role."
echo "Nine roles are registered, scaffolded, dispatchable and governed — and nothing depends on"
echo "any of them. 'Done' is tested here. 'Working' is not, and is not claimed."
echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "ALL GREEN ($PASS pass, $FAIL fail)"
  exit 0
else
  echo "RED ($PASS pass, $FAIL fail)"
  exit 1
fi
