#!/usr/bin/env bash
# Shared "is session N a ground-truth (review-only) session?" — S181 Part 2.
# One answer for every hook and both close gates; before this, six scripts each carried their own copy.
#
# Rule (the founder's, S180): the default is every 5th session. `.ai/CONSTRAINTS.yaml`
# `ground_truth_next_session: KEY` is a ONE-TIME override, and it only counts until session KEY has
# happened (sessions/session-KEY-ground-truth.md exists) or been passed. After that the next
# multiple of 5 applies on its own — no edit needed, no number to remember.
#
#   no key                  -> N % 5 == 0
#   N <  KEY                -> not ground truth (the override says the next one is KEY)
#   N == KEY                -> ground truth
#   N >  KEY, KEY reported  -> N % 5 == 0
#   N >  KEY, no report     -> the override was PASSED without a report: sessions below the next
#                              multiple of 5 above KEY are not ground truth; from there N % 5 == 0.
#                              VAJRA_GT_NOTE says so, so the founder is told, not left to find out.
#
# Usage:  vajra_is_ground_truth N [ROOT]     -> exit 0 = ground truth, 1 = not
# Sets VAJRA_GT_NOTE (empty unless a passed override was rolled forward). Never exits the caller.

vajra_gt_key() {
  grep -E '^[[:space:]]*ground_truth_next_session:' "$1/.ai/CONSTRAINTS.yaml" 2>/dev/null \
    | grep -oE '[0-9]+' | head -1 || true
}

vajra_is_ground_truth() {
  local n root key next5
  VAJRA_GT_NOTE=""
  n="$1"; root="${2:-.}"
  [[ "$n" =~ ^[0-9]+$ ]] || return 1
  n=$((10#$n))
  [ "$n" -gt 0 ] || return 1
  key="$(vajra_gt_key "$root")"
  if [ -z "$key" ]; then
    [ $((n % 5)) -eq 0 ]; return
  fi
  key=$((10#$key))
  if [ "$n" -lt "$key" ]; then return 1; fi
  if [ "$n" -eq "$key" ]; then return 0; fi
  if [ -f "$root/sessions/session-${key}-ground-truth.md" ] \
     || [ -f "$root/sessions/session-$(printf '%02d' "$key")-ground-truth.md" ]; then
    [ $((n % 5)) -eq 0 ]; return
  fi
  next5=$(( (key / 5 + 1) * 5 ))
  VAJRA_GT_NOTE="ground_truth_next_session: $key was passed with no sessions/session-${key}-ground-truth.md — rolled forward: the next ground-truth session is $next5. Founder: write that report, or clear/move the key."
  if [ "$n" -lt "$next5" ]; then return 1; fi
  [ $((n % 5)) -eq 0 ]
}

# --- session type (S181 Part 3) --------------------------------------------------------------
# A brief declares its type in ONE strict field, a line that STARTS with the key:
#     session_type: CODE | DOCUMENT | GROUND_TRUTH | INTERACTIVE
# Nothing is guessed from the brief's prose (no searching for **CODE**): the field is there and is
# one of the four, or the close gate says so and fails. Usage: vajra_session_type N [ROOT]
# Sets VAJRA_TYPE (the enum value, or "") and VAJRA_TYPE_STATE:
#   declared  one valid value            missing   a brief exists, no field
#   unknown   a value not in the enum    conflict  two different values
#   noprompt  no prompts/NN-task-*.md
vajra_session_type() {
  local n root padded f vals first v count
  VAJRA_TYPE=""; VAJRA_TYPE_STATE=""
  n="$1"; root="${2:-.}"
  padded="$(printf '%02d' "$((10#$n))")"
  f="$(ls "$root"/prompts/"${padded}"-task-*.md 2>/dev/null | head -1 || true)"
  if [ -z "$f" ]; then VAJRA_TYPE_STATE="noprompt"; return 0; fi
  vals="$(grep -E '^session_type:' "$f" | sed -E 's/^session_type:[[:space:]]*//; s/[[:space:]]+$//' || true)"
  if [ -z "$vals" ]; then VAJRA_TYPE_STATE="missing"; return 0; fi
  first="$(printf '%s\n' "$vals" | head -1)"
  count="$(printf '%s\n' "$vals" | sort -u | wc -l | tr -d ' ')"
  if [ "$count" -gt 1 ]; then VAJRA_TYPE="$first"; VAJRA_TYPE_STATE="conflict"; return 0; fi
  v="$first"
  case "$v" in
    CODE|DOCUMENT|GROUND_TRUTH|INTERACTIVE) VAJRA_TYPE="$v"; VAJRA_TYPE_STATE="declared" ;;
    *) VAJRA_TYPE="$v"; VAJRA_TYPE_STATE="unknown" ;;
  esac
}

# --- named waivers (S181 Part 5) -----------------------------------------------------------------
# `VAJRA_WAIVE=check-a,check-b` waives ONLY the checks it names (the log names of the close gate,
# e.g. fidelity-review-accept), and needs a reason in `VAJRA_WAIVE_REASON` — empty is refused, not
# waived. The note says whether the waiver was set at LAUNCH (`vajra claude` copies VAJRA_WAIVE into
# VAJRA_LAUNCH_WAIVE from the founder's own terminal) or set LATER, in the running session.
# The old `VAJRA_CLOSEOUT_WAIVER=N` (waives every check) still works, loudly, until the founder says
# remove it.
#
# vajra_waiver_ok CHECK SESSION [LOGFILE]  -> 0 = waived, 1 = not. Sets WAIVER_NOTE.
# LIMIT: bar-raising, not tamper-proof — an agent could set both variables in its own shell.
vajra_waiver_ok() {
  local check="$1" n="$2" log="${3:-}" item when listed=0 items
  WAIVER_NOTE=""
  if [ -n "${VAJRA_WAIVE:-}" ] && [ -n "$check" ]; then
    IFS=',' read -ra items <<<"$VAJRA_WAIVE"
    for item in "${items[@]}"; do
      item="${item//[[:space:]]/}"
      [ "$item" = "$check" ] && listed=1
    done
    if [ "$listed" -eq 1 ]; then
      if [ -z "${VAJRA_WAIVE_REASON//[[:space:]]/}" ]; then
        WAIVER_NOTE="REFUSED: VAJRA_WAIVE names '$check' but VAJRA_WAIVE_REASON is empty — a waiver needs a reason."
        [ -n "$log" ] && echo "$WAIVER_NOTE" >> "$log"
        return 1
      fi
      when="set later, in the running session"
      if [ -n "${VAJRA_LAUNCH_WAIVE:-}" ] && [ "$VAJRA_LAUNCH_WAIVE" = "$VAJRA_WAIVE" ]; then
        when="launch-time — human chose at start"
      fi
      WAIVER_NOTE="WAIVED ($when): $check — $VAJRA_WAIVE_REASON"
      return 0
    fi
  fi
  if [ -n "${VAJRA_CLOSEOUT_WAIVER:-}" ] && [ "${VAJRA_CLOSEOUT_WAIVER}" = "$n" ]; then
    WAIVER_NOTE="WAIVED (LEGACY VAJRA_CLOSEOUT_WAIVER=$n — waives EVERY check; deprecated, use VAJRA_WAIVE=<check>,... with VAJRA_WAIVE_REASON) — ${VAJRA_CLOSEOUT_WAIVER_REASON:-<no reason recorded>}"
    if [ -z "${_VAJRA_LEGACY_WAIVER_WARNED:-}" ]; then
      _VAJRA_LEGACY_WAIVER_WARNED=1
      echo "[vajra] WARNING: VAJRA_CLOSEOUT_WAIVER=$n waives every close check. Name what you waive: VAJRA_WAIVE=<check>,<check> VAJRA_WAIVE_REASON='<why>'." >&2
    fi
    return 0
  fi
  return 1
}

# --- where the new rules start (S181, cold review defect A) ------------------------------------------
# Sessions BELOW `.ai/CONSTRAINTS.yaml` `session_rules_from: N` keep the old readings (session type from
# prose, approval from the brief's words, stamps without a text hash) through the named, dated
# fallbacks; N and above must follow the new rules. Absent -> 181, Vajra's own boundary. A project
# that adopted Vajra earlier (rudra was at S15) never reaches 181, so it stays on the old readings
# until it sets the key — the gates SAY so, every time, and name the line to add. New scaffolds ship
# `session_rules_from: 1` (every session follows the rules).
vajra_rules_from() {
  local v
  v="$(grep -E '^[[:space:]]*session_rules_from:' "${1:-.}/.ai/CONSTRAINTS.yaml" 2>/dev/null | grep -oE '[0-9]+' | head -1 || true)"
  echo "${v:-181}"
}
vajra_rules_from_declared() {
  grep -qE '^[[:space:]]*session_rules_from:[[:space:]]*[0-9]+' "${1:-.}/.ai/CONSTRAINTS.yaml" 2>/dev/null
}
