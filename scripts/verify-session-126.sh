#!/usr/bin/env bash
# Verify — Session 126: the last five fleet roles; the roster closed at nine.
#
# What this suite must actually prove, beyond "the roles exist":
#   1. the real binary scaffolds NINE roles and the repo's copies are exactly its render;
#   2. each of the five NEW roles governs a real handoff through the unchanged S109 path;
#   3. NOTHING else moved — `K of 8` is untouched, no 8th command, and the execution allowlist is
#      still exactly one role (five roles added, zero new grants of Bash);
#   4. each of the five was really DISPATCHED BY NAME — checked against the committed evidence
#      RECORD (the raw runtime files are untracked by founder call; see
#      `sessions/session-126-dispatch-evidence.md`), with the check shown going RED on six kinds of
#      planted drift, so it is not a check that cannot fail;
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
DISPATCH="sessions/session-126-artifacts/dispatch"   # LOCAL ONLY — untracked by policy
EVIDENCE="sessions/session-126-dispatch-evidence.md"

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

# --- 4. the five dispatches, checked against the COMMITTED evidence RECORD ----------------------
# The raw runtime evidence (five transcripts + five headless run results, ~810KB of JSONL) was
# committed at first and then REMOVED FROM GIT at the founder's call — session artifacts do not
# belong in the repo. What git carries is `sessions/session-126-dispatch-evidence.md`: every field
# this check reads, plus a sha256 of each raw file, so a LOCAL copy can still be matched against
# what was recorded. See that file's own opening note for what the removal costs.
#
# CLASS, honestly: `struct` when it checks the record alone (a claim about a written record, with no
# runtime output to exercise) — and the record is checked HARD: every id must agree in both
# directions, every parent session must be distinct, every field must be present. When the raw
# evidence IS present in the checkout (the machine that ran the dispatches), the same function
# re-derives from those files and requires the record to MATCH — a drifted or hand-edited record
# fails there. Neither mode proves provenance; the cold review already named that (a copy checking
# itself proves consistency, not origin), and binding evidence to the runtime is S127's candidate B.
#
# $1 = the evidence record to check; $2 = the raw dispatch dir to cross-derive from when present.
# Both parameterised so the fixture below can drive THIS function over planted drift.
check_evidence_record() {
  python3 - "$1" "$2" "$NEW_ROLES" <<'PYEOF'
import json, os, re, sys
rec_path, raw_dir, roles = sys.argv[1], sys.argv[2], sys.argv[3].split()
bad = 0
try:
    text = open(rec_path).read()
    block = re.search(r"```json\n(.*?)\n```", text, re.S).group(1)
    rec = json.loads(block)
except Exception as e:
    print(f"FAIL: the evidence record is unreadable or carries no json block ({e}) "
          f"— cannot evaluate, so it fails")
    sys.exit(1)

by_role = {d.get("role"): d for d in rec.get("dispatches", [])}
if sorted(by_role) != sorted(roles):
    print(f"FAIL: the record covers {sorted(by_role)}, not the five new roles"); sys.exit(1)

seen_ids, seen_sessions = set(), set()
for r in roles:
    d = by_role[r]
    for field in ("subagent_type_requested", "agent_type_resolved", "tool_use_id",
                  "meta_tool_use_id", "parent_session_id", "parent_timestamp",
                  "transcript_sha256", "transcript_lines", "run_cost_usd", "handoff"):
        if not d.get(field):
            print(f"FAIL {r}: the record has no {field}"); bad = 1
    if d.get("subagent_type_requested") != r or d.get("agent_type_resolved") != r:
        print(f"FAIL {r}: requested {d.get('subagent_type_requested')!r} / resolved "
              f"{d.get('agent_type_resolved')!r} — not this role"); bad = 1
    tid = d.get("tool_use_id")
    if not tid or tid != d.get("meta_tool_use_id"):
        print(f"FAIL {r}: parent id {tid!r} != subagent toolUseId {d.get('meta_tool_use_id')!r}"); bad = 1
    if tid in seen_ids:
        print(f"FAIL {r}: tool-call id {tid} is reused — five dispatches cannot share one id"); bad = 1
    seen_ids.add(tid)
    sid = d.get("parent_session_id")
    if sid in seen_sessions:
        print(f"FAIL {r}: parent session {sid} is reused — each dispatch ran in its OWN fresh session"); bad = 1
    seen_sessions.add(sid)
    if not re.fullmatch(r"[0-9a-f]{64}", str(d.get("transcript_sha256", ""))):
        print(f"FAIL {r}: transcript_sha256 is not a sha256"); bad = 1
    # The record must point at something that EXISTS in the repo — the governed handoff the brief
    # was landed as. This is the one field a purely invented record cannot satisfy silently.
    if not os.path.exists(d.get("handoff", "")):
        print(f"FAIL {r}: the record names handoff {d.get('handoff')!r}, which does not exist"); bad = 1
    else:
        h = open(d["handoff"]).read()
        if f"role: {r}" not in h:
            print(f"FAIL {r}: {d['handoff']} is not a governed handoff for this role"); bad = 1
    print(f"OK {r}: requested == resolved == {r}, both on tool-call {tid}, own session {sid}")

# STRONG PATH, when the raw evidence is present in this checkout: re-derive and require a match.
import hashlib
if os.path.isdir(raw_dir):
    print("raw evidence PRESENT — re-deriving from the runtime's own files")
    for r in roles:
        d = by_role[r]
        try:
            tu = json.load(open(os.path.join(raw_dir, f"{r}-parent-tooluse.json")))[0]
            meta = json.load(open(os.path.join(raw_dir, f"{r}-subagent-meta.json")))
            raw = open(os.path.join(raw_dir, f"{r}-subagent-transcript.jsonl"), "rb").read()
        except Exception as e:
            print(f"FAIL {r}: raw evidence present but unreadable ({e})"); bad = 1; continue
        if tu.get("id") != d["tool_use_id"] or meta.get("toolUseId") != d["meta_tool_use_id"]:
            print(f"FAIL {r}: the record's ids do not match the raw files"); bad = 1
        if tu.get("input", {}).get("subagent_type") != r or meta.get("agentType") != r:
            print(f"FAIL {r}: the raw files do not name this role"); bad = 1
        if hashlib.sha256(raw).hexdigest() != d["transcript_sha256"]:
            print(f"FAIL {r}: the recorded transcript sha256 does not match the raw transcript"); bad = 1
        if not any(json.loads(l).get("type") == "assistant"
                   and (json.loads(l).get("message") or {}).get("usage")
                   for l in raw.decode().splitlines() if l.strip()):
            print(f"FAIL {r}: the raw transcript carries no real assistant usage line"); bad = 1
    if not bad:
        print("OK: the record matches the raw runtime files it was derived from")
else:
    print(f"raw evidence NOT in this checkout ({raw_dir} absent) — untracked by founder policy.")
    print("The record was checked; provenance was NOT, and this check never claimed to prove it.")
sys.exit(bad)
PYEOF
}
run_check "dispatch-evidence-record" struct check_evidence_record "$EVIDENCE" "$DISPATCH"

# THE FALSIFIABILITY FIXTURE: the SAME function, over copies of the record carrying planted drift.
# Each forgery must turn it RED, and the untouched copy must stay GREEN — otherwise "checked" is a
# claim, not a test. Driven with the raw dir deliberately absent, so the record alone is on trial.
evidence_record_has_teeth() {
  local TMP; TMP="$(mktemp -d)"; local rc=0
  local NOPE="$TMP/no-raw-evidence-here"
  cp "$EVIDENCE" "$TMP/record.md"

  echo "--- control: the committed record, unmodified (must be GREEN) ---"
  if check_evidence_record "$TMP/record.md" "$NOPE" >/dev/null 2>&1; then echo "OK: green on the real record"
  else echo "FAIL: red on the unmodified record — the fixture proves nothing"; rc=1; fi

  local case_name; local mutation
  for case_name in mismatched-id wrong-agent-type reused-session missing-handoff dropped-role; do
    cp "$EVIDENCE" "$TMP/record.md"
    python3 - "$TMP/record.md" "$case_name" <<'PYEOF'
import json, re, sys
p, case = sys.argv[1], sys.argv[2]
text = open(p).read()
block = re.search(r"```json\n(.*?)\n```", text, re.S)
rec = json.loads(block.group(1))
d = rec["dispatches"]
if case == "mismatched-id":       d[0]["meta_tool_use_id"] = "toolu_" + "0" * 22
elif case == "wrong-agent-type":  d[1]["agent_type_resolved"] = "general-purpose"
elif case == "reused-session":    d[2]["parent_session_id"] = d[3]["parent_session_id"]
elif case == "missing-handoff":   d[3]["handoff"] = ".ai/handoffs/session-126-no-such-role.md"
elif case == "dropped-role":      rec["dispatches"] = d[:4]
open(p, "w").write(text[:block.start(1)] + json.dumps(rec, indent=2) + text[block.end(1):])
PYEOF
    if check_evidence_record "$TMP/record.md" "$NOPE" >/dev/null 2>&1; then
      echo "FAIL: the check accepted a record with planted drift: $case_name"; rc=1
    else
      echo "OK: $case_name REJECTED"
    fi
  done

  echo "--- fail-closed: a record with no json block at all ---"
  echo "not a record" > "$TMP/record.md"
  if check_evidence_record "$TMP/record.md" "$NOPE" >/dev/null 2>&1; then
    echo "FAIL: an unparseable record passed — the check is not fail-closed"; rc=1
  else
    echo "OK: an unparseable record fails closed"
  fi

  echo "--- the STRONG path, when raw evidence is present: a record that drifts from it must fail ---"
  if [ -d "$DISPATCH" ]; then
    cp "$EVIDENCE" "$TMP/record.md"
    python3 - "$TMP/record.md" <<'PYEOF'
import json, re, sys
p = sys.argv[1]
text = open(p).read()
block = re.search(r"```json\n(.*?)\n```", text, re.S)
rec = json.loads(block.group(1))
rec["dispatches"][0]["transcript_sha256"] = "0" * 64
open(p, "w").write(text[:block.start(1)] + json.dumps(rec, indent=2) + text[block.end(1):])
PYEOF
    if check_evidence_record "$TMP/record.md" "$DISPATCH" >/dev/null 2>&1; then
      echo "FAIL: a recorded sha that does not match the raw transcript was accepted"; rc=1
    else
      echo "OK: a record drifting from the raw evidence is REJECTED"
    fi
  else
    echo "raw evidence absent in this checkout — the strong path could not be exercised here,"
    echo "and this fixture says so rather than scoring a case it did not run."
  fi
  rm -rf "$TMP"; return $rc
}
run_check "evidence-record-has-teeth" exec evidence_record_has_teeth

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
