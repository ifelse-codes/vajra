#!/usr/bin/env bash
# verify-session-56.sh — S56 CODE: the fidelity GATE (teeth).
# Proves scripts/verify-closeout.sh now STRUCTURALLY REQUIRES an independent fidelity review and FAILS
# closeout on a missing / incomplete / REJECT review, absent an UN-FORGEABLE founder waiver (env var, not a
# text marker the agent can Write). Also: the S54 dogfood (the gate blocks S54's real REJECT), the bundled
# GT write-guard whitelist fix, spine/no-8th-command, and NO src/ change (bash-only session).
set -euo pipefail
cd "$(dirname "$0")/.."
REPO="$PWD"

PASS=0; FAIL=0
ok(){ echo "  ok   $1"; PASS=$((PASS+1)); }
no(){ echo "  FAIL $1"; FAIL=$((FAIL+1)); }

CLO="scripts/verify-closeout.sh"

# Run the focused fidelity gate against a fixture root; echo exit code.
# args: ROOT  N  [extra env assignments...]
gate() {
  local root="$1" n="$2"; shift 2
  env "$@" CLAUDE_PROJECT_DIR="$root" bash "$REPO/$CLO" --fidelity-only "$n" >/dev/null 2>&1
}

# Write a review fixture. args: root N verdict(ACCEPT|REJECT|NONE) tokens(full|thin) [extra lines...]
write_review() {
  local root="$1" n="$2" verdict="$3" tokens="$4"; shift 4
  mkdir -p "$root/sessions"
  local f="$root/sessions/session-${n}-review.md"
  {
    echo "# Session ${n} — Fidelity Review (fixture)"
    echo
    echo "| # | Requirement | Verdict | Evidence |"
    echo "|---|---|---|---|"
    if [ "$tokens" = "full" ]; then
      echo "| 1 | thing one | SHIPPED | evidence |"
      echo "| 2 | thing two | PARTIAL | evidence |"
      echo "| 3 | thing three | NOT-BUILT | evidence |"
    else
      echo "| 1 | thing one | SHIPPED | evidence |"   # only 1 verdict token → incomplete
    fi
    echo
    for extra in "$@"; do echo "$extra"; done
    case "$verdict" in
      ACCEPT) echo "**Verdict:** ACCEPT" ;;
      REJECT) echo "**Verdict:** REJECT" ;;
      NONE)   echo "## Overall verdict"; echo "we would reject this delivery" ;;  # heading-only, no canonical line
    esac
  } > "$f"
}

echo "=== S56 verify — the fidelity gate (teeth) ==="

# ---------------------------------------------------------------------------
# 1. Behaviour matrix (isolated fixtures via --fidelity-only)
# ---------------------------------------------------------------------------
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
NF=77

# (a) missing review → FAIL
gate "$TMP" "$NF" && no "missing review blocks closeout" || ok "missing review blocks closeout"

# (b) REJECT review → FAIL
write_review "$TMP" "$NF" REJECT full
gate "$TMP" "$NF" && no "REJECT review blocks closeout" || ok "REJECT review blocks closeout"

# (c) incomplete: real table but NO canonical Verdict line → FAIL (not present-only pass)
write_review "$TMP" "$NF" NONE full
gate "$TMP" "$NF" && no "review without canonical Verdict line blocks" || ok "review without canonical Verdict line blocks"

# (d) incomplete: canonical ACCEPT but <3 per-requirement verdicts → FAIL
write_review "$TMP" "$NF" ACCEPT thin
gate "$TMP" "$NF" && no "ACCEPT with too-thin table blocks (not a real acceptance table)" \
                  || ok "ACCEPT with too-thin table blocks (not a real acceptance table)"

# (e) ACCEPT + full table → PASS
write_review "$TMP" "$NF" ACCEPT full
gate "$TMP" "$NF" && ok "complete ACCEPT review passes closeout" || no "complete ACCEPT review passes closeout"

# ---------------------------------------------------------------------------
# 2. UN-FORGEABILITY — a text marker in the review must NOT waive; only the env var does
# ---------------------------------------------------------------------------
# REJECT review that also contains a forged in-file waiver marker (the agent CAN Write this).
write_review "$TMP" "$NF" REJECT full \
  "**Human-Waiver:** APPROVED by founder" \
  "Waiver: yes" "VAJRA_CLOSEOUT_WAIVER=$NF" "Status: WAIVED"
gate "$TMP" "$NF" && no "forged in-file waiver marker does NOT bypass the gate" \
                  || ok "forged in-file waiver marker does NOT bypass the gate"

# The founder-controlled env var (which the agent cannot set in the launch env) DOES waive.
gate "$TMP" "$NF" VAJRA_CLOSEOUT_WAIVER="$NF" \
  && ok "founder env-var waiver (VAJRA_CLOSEOUT_WAIVER=N) passes" \
  || no "founder env-var waiver (VAJRA_CLOSEOUT_WAIVER=N) passes"

# A waiver naming a DIFFERENT session must not apply (session-scoped, not blanket).
gate "$TMP" "$NF" VAJRA_CLOSEOUT_WAIVER="99" \
  && no "waiver for a different session does NOT apply" \
  || ok "waiver for a different session does NOT apply"

# ---------------------------------------------------------------------------
# 3. DOGFOOD — the gate blocks S54's real REJECT (S56 prompt Q3), and a founder waiver clears it
# ---------------------------------------------------------------------------
[ -f sessions/session-54-review.md ] && ok "S54 canonical review artifact exists" || no "S54 canonical review artifact exists"
grep -qiE '^\*\*Verdict:\*\* *REJECT' sessions/session-54-review.md \
  && ok "S54 review carries canonical Verdict: REJECT" || no "S54 review carries canonical Verdict: REJECT"
bash "$CLO" --fidelity-only 54 >/dev/null 2>&1 && no "gate BLOCKS S54's REJECT live" || ok "gate BLOCKS S54's REJECT live"
VAJRA_CLOSEOUT_WAIVER=54 bash "$CLO" --fidelity-only 54 >/dev/null 2>&1 \
  && ok "recorded founder waiver clears S54" || no "recorded founder waiver clears S54"

# ---------------------------------------------------------------------------
# 4. Integration — the gate is wired into the MAIN closeout sequence, not just the isolated mode
# ---------------------------------------------------------------------------
grep -qE '^check_fidelity_review$' "$CLO" && ok "check_fidelity_review wired into main closeout flow" \
  || no "check_fidelity_review wired into main closeout flow"
grep -qE 'waiver_ok\(\)' "$CLO" && ok "un-forgeable waiver helper present" || no "un-forgeable waiver helper present"
grep -qE 'VAJRA_CLOSEOUT_WAIVER' "$CLO" && ok "gate reads the founder env-var waiver" || no "gate reads the founder env-var waiver"

# ---------------------------------------------------------------------------
# 5. Bundled fix — GT write-guard whitelist now allows review + reviewer deliverables
# ---------------------------------------------------------------------------
grep -qE 'sessions/session-\*-review\.md' scripts/hook-pre-write.sh \
  && ok "GT whitelist allows sessions/*-review.md" || no "GT whitelist allows sessions/*-review.md"
grep -qE '\*/reviewer/\*' scripts/hook-pre-write.sh \
  && ok "GT whitelist allows reviewer/*" || no "GT whitelist allows reviewer/*"

# ---------------------------------------------------------------------------
# 6. Spine + honesty guardrails
# ---------------------------------------------------------------------------
# No 8th top-level command: the gate rides verify-closeout.sh, not a new `vajra` subcommand.
if [ -d src ]; then
  git diff --name-only main...HEAD 2>/dev/null | grep -qE '^src/' && no "NO src/ change (bash-only session)" \
    || ok "NO src/ change (bash-only session)"
else
  ok "NO src/ change (bash-only session)"
fi
grep -qiE 'Verdict.*ACCEPT.*REJECT|canonical machine-readable verdict' reviewer/SKILL.md \
  && ok "reviewer/SKILL.md documents the canonical Verdict line" \
  || no "reviewer/SKILL.md documents the canonical Verdict line"
grep -qiE 'teeth|verify-closeout\.sh .*(FAILS|requires)' reviewer/SKILL.md \
  && ok "reviewer/SKILL.md marks the teeth as built" || no "reviewer/SKILL.md marks the teeth as built"

echo "---"
echo "PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || { echo "RED"; exit 1; }
echo "ALL GREEN"
