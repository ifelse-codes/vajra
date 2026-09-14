#!/usr/bin/env bash
# demo-kit.sh — the terminal deck drawing kit (S167, DECISION-009).
# `vajra init` scaffolds this file and `vajra init --sync-fleet` upgrades it. Build demos ON it;
# do not edit it by hand (a hand-edited copy is refused by the next sync, never overwritten).
#
# THE TERMINAL DEMO IS THE HUMAN DEMO. Source the kit from a session demo:
#   . "$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
# and the demo tells the whole story in the terminal. The Demo-er gate re-runs that same script.
#
# One script, three looks (the Darshan rule — the richest the surface can take, never drop meaning):
#   deck   — stdin AND stdout are a terminal: one slide per screen · ← → / space · a autoplay · q quit
#   stream — CI, pipes, the Demo-er gate: every slide in order, plus the demo:<element> markers
#   plain  — NO_COLOR set, or stdout not a terminal: the same boxes, no color (✓ ✗ and words carry it)
# Knobs: DEMO_MODE=stream|deck · DEMO_WIDTH=60..104 · DEMO_COLOR=1 (color into a pipe) ·
#        DEMO_THEME=light|dark (else read from COLORFGBG) · DEMO_AUTOPLAY=seconds per slide ·
#        NO_COLOR=1 · VAJRA_BIN=path to vajra (the Demo-er gate sets it to itself).
#
# The outline (see scripts/demo-session-template.sh), one `dk_section` per slide:
#   headline · story · before_after · rule · cases · scorecard · next
# dk_finish FAILS the demo when a section never rendered, a dk_todo placeholder is still in it,
# no live check ran, a live check failed, or a check was refused. It prints demo:complete only
# when the whole outline passed.
#
# A demo that cannot be faked (S168, DECISION-010):
#   dk_check [-q] "label" command [args…]   runs the command; ITS exit code is the result
#                                           (a bare PASS / FAIL / digit is refused by name)
#   dk_vajra_tiles NN [tile…]               number tiles filled in by Vajra (vajra next --demo-facts)
#   dk_vajra_scorecard NN                   the same facts as a table, with names
# Both print one demo:fact key=value line per fact; the Demo-er gate re-derives every fact at close
# and blocks a demo whose facts differ, or one built on this kit that shows no facts at all.
#
# The kit owns the EXIT trap. Put throwaway files under "$DK_TMP" (removed on exit).
# bash 3.2 safe (the macOS default). No dependencies beyond a POSIX userland.

# ---- locale: bash counts BYTES unless the locale is UTF-8, and every box would come out crooked
case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in
  *[Uu][Tt][Ff]-8*|*[Uu][Tt][Ff]8*) ;;
  *) if [ "${DEMO_KIT_LOCALE:-}" != keep ]; then
       _dk_loc="$(locale -a 2>/dev/null | grep -i -E '^(en_US|C)\.utf-?8$' | head -1)"
       [ -n "$_dk_loc" ] && export LC_ALL="$_dk_loc"
     fi ;;
esac
_dk_probe='✓'
# No UTF-8 locale at all (a bare container): measure by dropping UTF-8 continuation bytes.
if [ "${#_dk_probe}" = 1 ]; then DK_BYTES=0; else DK_BYTES=1; fi
_DK_CONT="[$(printf '\200')-$(printf '\277')]"

_E=$'\033'
DK_MODE="${DEMO_MODE:-}"
if [ -z "$DK_MODE" ]; then
  if [ -t 0 ] && [ -t 1 ]; then DK_MODE=deck; else DK_MODE=stream; fi
fi
[ "$DK_MODE" = deck ] || DK_MODE=stream
if [ -n "${NO_COLOR:-}" ] || { [ ! -t 1 ] && [ "${DEMO_COLOR:-}" != 1 ]; }; then DK_COLOR=0; else DK_COLOR=1; fi
if [ "$DK_MODE" = deck ]; then
  _dk_cols="${COLUMNS:-$(tput cols 2>/dev/null)}"
  case "$_dk_cols" in ''|*[!0-9]*) _dk_cols=102 ;; esac
  DK_W="${DEMO_WIDTH:-$(( _dk_cols - 2 ))}"
else
  DK_W="${DEMO_WIDTH:-100}"
fi
case "$DK_W" in ''|*[!0-9]*) DK_W=100 ;; esac
[ "$DK_W" -gt 104 ] && DK_W=104
[ "$DK_W" -lt 60 ] && DK_W=60

DK_THEME="${DEMO_THEME:-}"   # light | dark; unset → COLORFGBG ("fg;bg": bg 7 or 15 is a light background)
if [ "$DK_THEME" != light ] && [ "$DK_THEME" != dark ]; then
  case "${COLORFGBG:-}" in *\;7|*\;15) DK_THEME=light ;; *) DK_THEME=dark ;; esac
fi
if [ "$DK_COLOR" = 1 ]; then
  if [ "$DK_THEME" = light ]; then   # deeper tones that stay readable on a white background
    case "${COLORTERM:-}" in
      truecolor|24bit) C_ACC="${_E}[38;2;91;63;217m" C_YES="${_E}[38;2;22;120;52m" C_NO="${_E}[38;2;178;34;34m" ;;
      *)               C_ACC="${_E}[38;5;56m" C_YES="${_E}[38;5;28m" C_NO="${_E}[38;5;124m" ;;
    esac
    C_D="${_E}[38;5;243m"
  else   # one accent (violet), green/red only for pass/fail, dim for chrome
    case "${COLORTERM:-}" in
      truecolor|24bit) C_ACC="${_E}[38;2;139;124;246m" C_YES="${_E}[38;2;126;207;138m" C_NO="${_E}[38;2;224;133;133m" ;;
      *)               C_ACC="${_E}[38;5;99m" C_YES="${_E}[38;5;71m" C_NO="${_E}[38;5;167m" ;;
    esac
    C_D="${_E}[2m"
  fi
  C_B="${_E}[1m" C_0="${_E}[0m"
else
  C_ACC= C_YES= C_NO= C_B= C_D= C_0=
fi

DK_TMP="$(mktemp -d "${TMPDIR:-/tmp}/demo-kit.XXXXXX")"
DK_SCORES=() DK_FAILS=0 _DK_ALT=0 DK_SLIDES_TOTAL=0 DK_SLIDES_SEEN=0
DK_SECTIONS="" DK_TODOS="" _DK_UNKNOWN="" DK_REFUSED="" _DK_FACTS=""
_DK_OUTLINE="headline story before_after rule cases scorecard next"
_dk_cleanup() { [ "$_DK_ALT" = 1 ] && printf '%s' "${_E}[?25h${_E}[?1049l"; rm -rf "$DK_TMP"; }
trap _dk_cleanup EXIT
trap 'exit 130' INT TERM

# ---- measuring (results in globals instead of $(...) so nothing forks per line) ---------------
dk_strip_v() { local t="$1" out=""
  while :; do case "$t" in
    *"${_E}["*) out="$out${t%%"${_E}["*}"; t="${t#*"${_E}["}"; t="${t#*m}" ;;
    *) break ;; esac; done
  _DK_S="$out$t"; }
dk_len_v() { dk_strip_v "$1"
  if [ "$DK_BYTES" = 1 ]; then local c="${_DK_S//$_DK_CONT/}"; _DK_N=${#c}; else _DK_N=${#_DK_S}; fi; }
dk_rep_v() { local r="" n="$2"; while [ "$n" -gt 0 ]; do r="$r$1"; n=$((n-1)); done; _DK_R="$r"; }
dk_fit_v() { dk_len_v "$1"   # exactly $2 columns: pad, or clip with …
  if [ "$_DK_N" -le "$2" ]; then dk_rep_v ' ' $(( $2 - _DK_N )); _DK_F="$1$C_0$_DK_R"
  else _DK_F="${_DK_S:0:$(( $2 - 1 ))}…"; fi; }
dk_run_v() { _DK_OUT="$("$@" 2>&1)" && _DK_RC=0 || _DK_RC=$?   # live run: output + real exit code
  while [ "${_DK_OUT:0:1}" = $'\n' ]; do _DK_OUT="${_DK_OUT:1}"; done; }

dk_wrap() { local w="$1"; shift; local line="" word n   # word wrap to $w columns
  set -f
  for word in $*; do
    dk_len_v "$word"; n=$_DK_N
    while [ "$n" -gt "$w" ]; do
      [ -n "$line" ] && { printf '%s\n' "$line"; line=""; }
      printf '%s\n' "${_DK_S:0:$w}"; word="${_DK_S:$w}"; dk_len_v "$word"; n=$_DK_N
    done
    dk_len_v "$line"
    if [ -z "$line" ]; then line="$word"
    elif [ $(( _DK_N + 1 + n )) -le "$w" ]; then line="$line $word"
    else printf '%s\n' "$line"; line="$word"; fi
  done
  set +f
  [ -n "$line" ] && printf '%s\n' "$line"; return 0; }
dk_wrap_log() { local w="$1" l seg first   # keep each output line; wrap long ones with ↳
  while IFS= read -r l || [ -n "$l" ]; do
    dk_len_v "$l"
    if [ "$_DK_N" -le "$w" ]; then printf '%s\n' "$l"; continue; fi
    first=1
    while IFS= read -r seg; do
      if [ $first = 1 ]; then printf '%s\n' "$seg"; first=0; else printf '%s\n' "${C_D}↳${C_0} $seg"; fi
    done < <(dk_wrap $(( w - 2 )) "$l")
  done; }

# ---- building blocks -----------------------------------------------------------------------
dk_box() { local w="$1" title="$2" tl tr bl br h v fc l   # dk_box WIDTH "TITLE" [heavy] < lines
  if [ "${3:-}" = heavy ]; then tl='┏' tr='┓' bl='┗' br='┛' h='━' v='┃' fc="$C_ACC"
  else tl='┌' tr='┐' bl='└' br='┘' h='╌' v='│' fc="$C_D"; fi
  if [ -n "$title" ]; then
    dk_len_v "$title"; [ "$_DK_N" -gt $(( w - 6 )) ] && { dk_fit_v "$title" $(( w - 6 )); title="$_DK_F"; dk_len_v "$title"; }
    dk_rep_v "$h" $(( w - 5 - _DK_N ))
    printf '%s\n' "$fc$tl$h$C_0 $title$C_0 $fc$_DK_R$tr$C_0"
  else dk_rep_v "$h" $(( w - 2 )); printf '%s\n' "$fc$tl$_DK_R$tr$C_0"; fi
  while IFS= read -r l || [ -n "$l" ]; do
    dk_fit_v "$l" $(( w - 4 )); printf '%s\n' "$fc$v$C_0 $_DK_F $fc$v$C_0"
  done
  dk_rep_v "$h" $(( w - 2 )); printf '%s\n' "$fc$bl$_DK_R$br$C_0"; }
dk_side() { local -a la lb; local l i n wa   # two rendered blocks, side by side
  while IFS= read -r l; do la+=("$l"); done <<< "$1"
  while IFS= read -r l; do lb+=("$l"); done <<< "$2"
  dk_len_v "${la[0]}"; wa=$_DK_N; n=${#la[@]}; [ ${#lb[@]} -gt "$n" ] && n=${#lb[@]}
  for (( i=0; i<n; i++ )); do
    if [ "$i" -lt ${#la[@]} ]; then l="${la[$i]}"; else dk_rep_v ' ' "$wa"; l="$_DK_R"; fi
    printf '%s  %s\n' "$l" "${lb[$i]:-}"
  done; }
dk_marker()  { [ "$DK_MODE" = deck ] || printf '%s\n' "${C_D}demo:$1${C_0}"; }
dk_eyebrow() { local u; u="$(printf '%s' "$*" | tr '[:lower:]' '[:upper:]')"; dk_len_v "$u"
  if [ "$_DK_N" -gt $(( DK_W - 4 )) ]; then dk_fit_v "$u" $(( DK_W - 4 )); u="$_DK_F"; fi
  printf '\n  %s\n' "${C_ACC}●${C_0} ${C_D}$u${C_0}"; }
dk_h1() { local l; echo; while IFS= read -r l; do printf '  %s\n' "$l"; done < <(dk_wrap $(( DK_W - 2 )) "${C_B}$1${C_ACC}${2:-}${C_0}${C_B}${3:-}${C_0}"); echo; }
dk_h2() { printf '\n  %s\n\n' "${C_B}$(printf '%s' "$*" | tr '[:lower:]' '[:upper:]')${C_0}"; }
dk_p() { local l; while IFS= read -r l; do printf '  %s\n' "$l"; done < <(dk_wrap $(( DK_W - 2 )) "$*"); echo; }
dk_caption() { local l; while IFS= read -r l; do printf '  %s\n' "${C_D}$l${C_0}"; done < <(dk_wrap $(( DK_W - 2 )) "$*"); }
dk_term() { local w="${3:-$DK_W}" body="$2"   # dk_term "TITLE" "captured output" [WIDTH]
  # No color means no escape bytes at all — including the ones a captured command printed itself.
  if [ "$DK_COLOR" = 0 ]; then dk_strip_v "$body"; body="$_DK_S"; fi
  printf '%s\n' "$body" | dk_wrap_log $(( w - 4 )) | dk_box "$w" "$1"; }

dk_metrics() { local n=$# tw per out="" blk t lab val sm count=0   # "LABEL|VALUE|small" tiles
  tw=$(( (DK_W - 2 * (n - 1)) / n )); [ "$tw" -gt 24 ] && tw=24; [ "$tw" -lt 16 ] && tw=16
  per=$(( (DK_W + 2) / (tw + 2) ))
  for t in "$@"; do
    lab="${t%%|*}"; t="${t#*|}"; val="${t%%|*}"; sm=""; [ "$t" != "$val" ] && sm="${t#*|}"
    blk="$(printf '%s\n%s\n' "${C_ACC}●${C_0} ${C_D}$lab${C_0}" "${C_B}$val${C_0} ${C_D}$sm${C_0}" | dk_box "$tw" "")"
    if [ -z "$out" ]; then out="$blk"; else out="$(dk_side "$out" "$blk")"; fi
    count=$((count+1)); if [ "$count" -eq "$per" ]; then printf '%s\n' "$out"; out=""; count=0; fi
  done
  [ -n "$out" ] && printf '%s\n' "$out"; echo; }
dk_verdict() { local lab="$1" l; shift   # dk_verdict "LABEL" "line" "line"… — a heavy callout box
  { for l in "$@"; do dk_wrap $(( DK_W - 4 )) "$l"; done; } | dk_box "$DK_W" "${C_ACC}● $lab${C_0}" heavy; }
dk_bullets() { local b lead rest first l   # "Lead words.|the rest of the bullet"…
  for b in "$@"; do lead="${b%%|*}"; rest="${b#*|}"; first=1
    while IFS= read -r l; do
      if [ $first = 1 ]; then printf '  %s\n' "${C_ACC}▸${C_0} $l"; first=0; else printf '    %s\n' "$l"; fi
    done < <(dk_wrap $(( DK_W - 4 )) "${C_B}$lead${C_0} $rest")
  done; echo; }
dk_compare() { local pw a b   # "BEFORE|title" "output" "AFTER|title" "output"
  local bh="${C_NO}✗ ${1%%|*}${C_0} ${C_D}·${C_0} ${1#*|}" ah="${C_YES}✓ ${3%%|*}${C_0} ${C_D}·${C_0} ${3#*|}"
  if [ "$DK_W" -ge 96 ]; then pw=$(( (DK_W - 2) / 2 ))
    a="$(dk_term "$bh" "$2" "$pw")"; b="$(dk_term "$ah" "$4" "$pw")"; dk_side "$a" "$b"
  else dk_term "$bh" "$2"; dk_term "$ah" "$4"; fi; }
_dk_row() { local rest="$1" color="$2" i c out="" cont="" first=1 l   # one dk_table row (reads cw/ncol/lw)
  for (( i=0; i<ncol-1; i++ )); do c="${rest%%|*}"; rest="${rest#*|}"
    dk_fit_v "$c" "${cw[$i]}"; out="$out$color$_DK_F$C_0 ${C_D}│${C_0} "
    dk_rep_v ' ' "${cw[$i]}"; cont="$cont$_DK_R ${C_D}│${C_0} "; done
  while IFS= read -r l; do
    if [ $first = 1 ]; then printf '  %s\n' "$out$color$l$C_0"; first=0; else printf '  %s\n' "$cont$color$l$C_0"; fi
  done < <(dk_wrap "$lw" "$rest")
  [ $first = 1 ] && printf '  %s\n' "$out"; return 0; }
dk_table() { local hdr="$1"; shift   # "H1|H2|H3" rows… — the last column word-wraps; others clip at 42
  local -a cw; local r c i rest lw ncol
  ncol=$(( $(printf '%s' "$hdr" | tr -cd '|' | wc -c) + 1 ))
  for r in "$hdr" "$@"; do rest="$r"
    for (( i=0; i<ncol-1; i++ )); do c="${rest%%|*}"; rest="${rest#*|}"
      dk_len_v "$c"; [ "$_DK_N" -gt 42 ] && _DK_N=42; [ "${cw[$i]:-0}" -lt "$_DK_N" ] && cw[$i]=$_DK_N
    done; done
  lw=$(( DK_W - 2 )); for (( i=0; i<ncol-1; i++ )); do lw=$(( lw - cw[i] - 3 )); done
  [ "$lw" -lt 12 ] && lw=12
  _dk_row "$hdr" "$C_ACC$C_B"; dk_rep_v '╌' $(( DK_W - 2 )); printf '  %s\n' "$C_D$_DK_R$C_0"
  for r in "$@"; do _dk_row "$r" ""; done; echo; }

# ---- the outline ---------------------------------------------------------------------------
# dk_section NAME "eyebrow words" — starts one outline section. It emits the Demo-er marker where
# that section really renders (headline→header, before_after, cases, scorecard→summary_table).
dk_section() { local name="$1"; shift
  case " $_DK_OUTLINE " in
    *" $name "*) ;;
    *) _DK_UNKNOWN="$_DK_UNKNOWN $name" ;;
  esac
  case "$name" in
    headline) dk_marker header ;;
    before_after) dk_marker before_after ;;
    cases) dk_marker cases ;;
    scorecard) dk_marker summary_table ;;
  esac
  case " $DK_SECTIONS " in *" $name "*) ;; *) DK_SECTIONS="$DK_SECTIONS $name" ;; esac
  dk_eyebrow "${*:-$name}"; }
# dk_todo SECTION "what goes here" — a visible placeholder. The demo FAILS by name until it is
# replaced with the real thing. Deleting it without filling the section in defeats only yourself.
dk_todo() {
  case " $DK_TODOS " in *" $1 "*) ;; *) DK_TODOS="$DK_TODOS $1" ;; esac
  dk_marker "check-failed $1 — unfilled"   # the gate blocks on this even if dk_finish is skipped
  dk_wrap $(( DK_W - 4 )) "${2:-fill in this section}" | dk_box "$DK_W" "${C_NO}✗ TO FILL IN · $1${C_0}"; }

# ---- live checks + scorecard (the demo exits non-zero if any live check fails) --------------
# dk_check [-q] "label" command [args…] — RUNS the command (stdin closed); its real exit code is the
# result, and _DK_OUT / _DK_RC keep what it printed for a panel. -q keeps the line off-screen, still
# counted. A bare PASS / FAIL / digit is not a check: it is refused by name and fails the demo.
dk_check() { local quiet=0 label res l
  [ "${1:-}" = -q ] && { quiet=1; shift; }
  label="${1:-}"; [ $# -gt 0 ] && shift
  local tok="${1:-}" bare=0
  case "$tok" in ''|PASS|FAIL|pass|fail) bare=1 ;; *[!0-9]*) ;; *) bare=1 ;; esac   # empty · word · all digits
  if [ "$bare" = 1 ]; then
    DK_REFUSED="$DK_REFUSED|$label"; DK_SCORES+=("FAIL|$label — refused"); DK_FAILS=$((DK_FAILS+1))
    dk_marker "check-failed $label — refused"   # the gate blocks on this line, dk_finish or not
    _dk_fail_line "✗ dk_check \"$label\" ${tok:-(no command)} — refused: a bare ${tok:-missing command} is not a check. Write dk_check \"$label\" <command…> so its real exit code decides."
    return 0
  fi
  dk_run_v "$@" </dev/null
  if [ "$_DK_RC" = 0 ]; then res=PASS; dk_marker "check-passed $label"; else res=FAIL; DK_FAILS=$((DK_FAILS+1)); dk_marker "check-failed $label — exit $_DK_RC"; fi
  DK_SCORES+=("$res|$label")
  [ "$quiet" = 1 ] && return 0
  if [ "$res" = PASS ]; then printf '  %s\n' "${C_YES}✓${C_0} $label"
  else printf '  %s\n' "${C_NO}✗ $label${C_0} ${C_D}(exit $_DK_RC)${C_0}"
    printf '%s\n' "$_DK_OUT" | tail -n 3 | while IFS= read -r l; do dk_fit_v "$l" $(( DK_W - 6 )); printf '    %s\n' "${C_D}$_DK_F${C_0}"; done
  fi; return 0; }

# ---- the facts Vajra fills in (vajra next --demo-facts NN) — never typed by hand ---------------
_dk_facts() { local n="${1:-}" line k   # loads DKF_<key> + _DK_FACTS; a failure is a failed check
  [ -n "$_DK_FACTS" ] && [ "${DKF_session:-}" = "$n" ] && return 0   # read once per session per run
  _DK_FACTS=""
  dk_run_v "${VAJRA_BIN:-vajra}" next --demo-facts "$n" </dev/null
  case "$_DK_OUT" in "session=$n"*) ;; *) [ "$_DK_RC" = 0 ] && _DK_RC=1 ;; esac   # an old vajra prints no facts
  if [ "$_DK_RC" != 0 ]; then
    DK_SCORES+=("FAIL|Vajra filled in the facts for session $n"); DK_FAILS=$((DK_FAILS+1))
    dk_marker "check-failed Vajra facts for session $n — ${VAJRA_BIN:-vajra} exited $_DK_RC"
    _dk_fail_line "✗ could not read Vajra's facts: ${VAJRA_BIN:-vajra} next --demo-facts $n exited $_DK_RC — install vajra 0.2.0+ or set VAJRA_BIN"
    return 1; fi
  _DK_FACTS="$_DK_OUT"
  while IFS= read -r line; do k="${line%%=*}"
    case "$k" in ''|*[!a-z_]*) continue ;; esac
    printf -v "DKF_$k" '%s' "${line#*=}"
  done <<< "$_DK_FACTS"; }
_dk_fact_markers() { local line; while IFS= read -r line; do [ -n "$line" ] && dk_marker "fact $line"; done <<< "$_DK_FACTS"; }
# dk_vajra_tiles NN [LABEL|VALUE|small …] — four tiles from Vajra's facts (your extra tiles after them)
dk_vajra_tiles() { local n="${1:-}"; [ $# -gt 0 ] && shift; _dk_facts "$n" || return 0
  dk_metrics "STATIONS|$DKF_stations_passed|of $DKF_stations_total" "REVIEW|$DKF_review" \
    "ADVICE|$DKF_recs_answered|of $DKF_recs_total" "CREW|$DKF_crew_handoffs|handoffs" "$@"
  dk_caption "▲ STATIONS · REVIEW · ADVICE · CREW: filled in by Vajra (vajra next --demo-facts $n), never typed — the Demo-er gate re-derives them at close."
  _dk_fact_markers; }
# dk_vajra_scorecard NN — the same facts as a table, with the station and role names
dk_vajra_scorecard() { local n="${1:-}"; _dk_facts "$n" || return 0
  dk_table "Filled in by Vajra · session $n|Value" \
    "stations passed|$DKF_stations_passed of $DKF_stations_total — ${DKF_stations_names//,/, }" \
    "independent review|$DKF_review" \
    "advice answered|$DKF_recs_answered of $DKF_recs_total" \
    "crew handoffs|$DKF_crew_handoffs — ${DKF_crew_roles//,/, }"
  dk_caption "From vajra next --demo-facts $n. The Demo-er gate re-derives every fact at close and blocks on any mismatch."
  _dk_fact_markers; }
dk_scorecard() { local s pass=0 n=${#DK_SCORES[@]} bar   # every dk_check so far, in one box
  { for s in ${DK_SCORES[@]+"${DK_SCORES[@]}"}; do dk_fit_v "${s#*|}" $(( DK_W - 16 ))
      if [ "${s%%|*}" = PASS ]; then pass=$((pass+1)); printf '%s\n' "${C_YES}✓${C_0} $_DK_F ${C_YES}PASS${C_0}"
      else printf '%s\n' "${C_NO}✗${C_0} $_DK_F ${C_NO}FAIL${C_0}"; fi; done
    dk_rep_v '█' "$pass"; bar="${C_YES}$_DK_R${C_0}"; dk_rep_v '░' $(( n - pass ))
    printf '\n%s\n' "${C_B}$pass of $n pass${C_0}  ▕$bar${C_D}$_DK_R${C_0}▏"
  } | dk_box "$DK_W" "$1"; }

# ---- the deck --------------------------------------------------------------------------------
dk_deck() { local n=$# i=0 key auto=0 prog pre; local -a sl; sl=("$@")   # dk_deck slide_fn…
  DK_SLIDES_TOTAL=$n
  if [ "$DK_MODE" != deck ]; then
    for (( i=0; i<n; i++ )); do pre="══ slide $((i+1)) / $n "; dk_len_v "$pre"; dk_rep_v '═' $(( DK_W - _DK_N ))
      printf '\n%s\n' "${C_D}$pre$_DK_R${C_0}"; "${sl[$i]}"; DK_SLIDES_SEEN=$((i+1)); done
    return 0; fi
  _DK_ALT=1; printf '%s' "${_E}[?1049h${_E}[?25l"
  while :; do
    if [ ! -f "$DK_TMP/slide-$i" ]; then   # each slide runs live ONCE; going back shows that run
      printf '%s\n\n  %s' "${_E}[2J${_E}[H" "${C_D}running slide $((i+1)) live…${C_0}"
      "${sl[$i]}" > "$DK_TMP/slide-$i" 2>&1
      [ $((i+1)) -gt "$DK_SLIDES_SEEN" ] && DK_SLIDES_SEEN=$((i+1))
    fi
    printf '%s' "${_E}[2J${_E}[H"; cat "$DK_TMP/slide-$i"
    dk_rep_v '▰' $((i+1)); prog="${C_ACC}$_DK_R${C_0}"; dk_rep_v '▱' $(( n - i - 1 ))
    printf '\n  %s   %s' "$prog${C_D}$_DK_R${C_0} $((i+1)) / $n" \
      "${C_D}← back · → or space next · a autoplay$([ $auto = 1 ] && printf ' (on)') · q quit${C_0}"
    key=""
    if [ $auto = 1 ]; then IFS= read -rsn1 -t "${DEMO_AUTOPLAY:-8}" key || key=n
    else IFS= read -rsn1 key || key=q; fi
    if [ "$key" = "$_E" ]; then IFS= read -rsn2 key || key=""; fi
    case "$key" in
      n|l|j|' '|''|'[C') if [ "$i" -lt $(( n - 1 )) ]; then i=$((i+1)); else break; fi ;;
      p|h|k|b|'[D') if [ "$i" -gt 0 ]; then i=$((i-1)); fi ;;
      a) auto=$(( 1 - auto )) ;;
      q) break ;;
    esac
  done
  printf '%s' "${_E}[?25h${_E}[?1049l"; _DK_ALT=0
  cat "$DK_TMP/slide-$i"; }   # the last slide seen stays on the normal screen
_dk_fail_line() { local l; while IFS= read -r l; do printf '  %s\n' "${C_NO}$l${C_0}"; done < <(dk_wrap $(( DK_W - 2 )) "$1"); }
dk_finish() { local ran=${#DK_SCORES[@]} missing="" s bad=0; printf '\n'
  if [ "$DK_SLIDES_SEEN" -lt "$DK_SLIDES_TOTAL" ]; then   # never say "complete" for a deck left early
    printf '  %s\n\n' "${C_D}■ demo stopped at slide $DK_SLIDES_SEEN of $DK_SLIDES_TOTAL — $ran live check(s) ran, $DK_FAILS failed${C_0}"
    [ "$DK_FAILS" -eq 0 ] && exit 0 || exit 1; fi
  for s in $_DK_OUTLINE; do case " $DK_SECTIONS " in *" $s "*) ;; *) missing="$missing $s" ;; esac; done
  if [ -n "$DK_TODOS" ]; then s="${DK_TODOS# }"
    _dk_fail_line "✗ demo not filled in — unfilled section(s): ${s// /, }"; bad=1; fi
  if [ -n "$missing" ]; then s="${missing# }"
    _dk_fail_line "✗ outline incomplete — section(s) never shown: ${s// /, }"; bad=1; fi
  if [ -n "$_DK_UNKNOWN" ]; then s="${_DK_UNKNOWN# }"
    _dk_fail_line "✗ unknown section name(s): ${s// /, } (outline: $_DK_OUTLINE)"; bad=1; fi
  if [ -n "$DK_REFUSED" ]; then s="${DK_REFUSED#|}"
    _dk_fail_line "✗ check(s) refused — a bare PASS / FAIL / digit is not a check: ${s//|/, }"; bad=1; fi
  if [ "$ran" -eq 0 ]; then
    _dk_fail_line "✗ no live check ran — a demo that checks nothing shows nothing"; bad=1; fi
  if [ "$DK_FAILS" -gt 0 ]; then
    _dk_fail_line "✗ $DK_FAILS of $ran live checks FAILED"; bad=1; fi
  if [ "$bad" = 1 ]; then printf '\n'; exit 1; fi
  dk_marker complete
  printf '  %s\n\n' "${C_YES}✓ demo complete — all $ran live checks passed${C_0}"; exit 0; }
dk_marker kit   # this demo is built on the kit (the Demo-er gate also reads the script text)
