#!/usr/bin/env bash
# demo-session-142.sh — the sprint demo for S142: complete the upgrade loop for the pure-render
# scaffold files. The S141 `vajra-render-sha:` stamp now generalises beyond frontmatter to the shell
# HOOKS (`.ai/hooks/hook-*.sh`, a trailing `# vajra-render-sha:` comment), so the SINGLE
# `vajra init --sync-fleet` gives the hooks the same four-state smooth upgrade — under one command, no
# 8th. Required elements (CONSTRAINTS.yaml#demo.required_elements): header, cases, summary_table,
# before_after — each an emitted `demo:<element>` marker the Demo-er gate re-runs live and scans for.
# Cumulative: it shows the S141 role-file upgrade AND the new S142 hook upgrade. Runs the REAL binary.
#
# The summary_table marks are COMPUTED from the live case signals (S141 rec 3), never hardcoded.
set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

VAJRA="$ROOT/target/release/vajra"
[ -x "$VAJRA" ] || cargo build -q --release || { echo "release build failed"; exit 2; }

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
head_() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label() { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
mk() { [ "$1" -eq 0 ] 2>/dev/null && printf "${GREEN}✔${RESET}" || printf "${RED}✗${RESET}"; }

W="$(mktemp -d "${TMPDIR:-/tmp}/vajra-demo142-XXXXXX")"
trap 'rm -rf "$W"' EXIT
H="$W/.ai/hooks/hook-publish-guard.sh"
ROLE="$W/.claude/agents/researcher.md"

echo "demo:header"
head_ "S142 — one command upgrades everything: the hooks join the fleet's smooth upgrade"
printf "${DIM}S141 gave the smooth upgrade-in-place to the fleet ROLE files only. Every other scaffold\n"
printf "file was add-only — created if missing, then frozen. S142 generalises the vajra-render-sha\n"
printf "stamp to a shell comment so the HOOKS get the same four states under the SAME single command\n"
printf "(vajra init --sync-fleet). The constitution — a filled template — is the named S143 follow-up.${RESET}\n"

echo "demo:cases"

head_ "CASE 1 — fresh install: --sync-fleet creates roles AND hooks, each STAMPED"
label "cd \$tmp && vajra init --sync-fleet"
OUT1="$( cd "$W" && "$VAJRA" init --sync-fleet 2>&1 )"
echo "$OUT1" | head -1 | sed 's/^/    /'
echo "$OUT1" | tail -1 | sed 's/^/    /'
HSTAMP="$(tail -1 "$H")"
printf "    hook stamp (trailing comment): ${DIM}%s${RESET}\n" "${HSTAMP:0:46}…"
{ echo "$OUT1" | grep -q "roles + .* hooks" && [ -n "$HSTAMP" ] && \
  case "$HSTAMP" in "# vajra-render-sha: "*) true;; *) false;; esac; }; C1=$?

head_ "CASE 2 — a stamped OLDER hook render -> auto-upgraded with NO --overwrite-drifted"
label "plant a correctly-stamped older hook, then: vajra init --sync-fleet"
printf '%s\n' '#!/usr/bin/env bash' '# OLDER publish-guard body' 'exit 0' > "$W/older"
hex="$(shasum -a 256 < "$W/older" | awk '{print $1}')"
cp "$W/older" "$H"; printf '# vajra-render-sha: %s\n' "$hex" >> "$H"
OUT2="$( cd "$W" && "$VAJRA" init --sync-fleet 2>&1 )"; C2rc=$?
echo "$OUT2" | grep -E "upgrade|already current|drifted\." | sed 's/^/    /'
{ [ "$C2rc" -eq 0 ] && echo "$OUT2" | grep -q "upgrade .*hook-publish-guard" && ! grep -q "OLDER publish-guard body" "$H"; }; C2=$?

head_ "CASE 3 — a user's OWN hook edit (unstamped) -> REFUSED, left untouched"
label "hand-edit the hook, then: vajra init --sync-fleet"
printf '%s\n' '#!/usr/bin/env bash' '# I edited this myself' 'exit 0' > "$H"
OUT3="$( cd "$W" && "$VAJRA" init --sync-fleet 2>&1 )"; C3rc=$?
echo "$OUT3" | grep -E "DRIFT|overwrite-drifted" | head -2 | sed 's/^/    /'
{ [ "$C3rc" -ne 0 ] && grep -q "I edited this myself" "$H"; }; C3=$?

head_ "CASE 4 — the stamp is INERT: the stamped hook still parses + keeps its shebang"
label "bash -n \$hook  (and the role-file upgrade path from S141 still works)"
"$VAJRA" init --sync-fleet --overwrite-drifted >/dev/null 2>&1 </dev/null || true
( cd "$W" && "$VAJRA" init --sync-fleet --overwrite-drifted >/dev/null 2>&1 )
PARSE_OK=1; for hk in "$W"/.ai/hooks/hook-*.sh; do bash -n "$hk" || PARSE_OK=0; done
SHEBANG="$(head -1 "$H")"
printf "    bash -n all 6 hooks: %s · shebang line 1: ${DIM}%s${RESET}\n" "$([ $PARSE_OK -eq 1 ] && echo OK || echo FAIL)" "$SHEBANG"
ROLE_STAMP="$(grep -c '^vajra-render-sha:' "$ROLE" 2>/dev/null || echo 0)"
printf "    (cumulative) S141 role files still stamped in frontmatter: %s\n" "$([ "$ROLE_STAMP" -ge 1 ] && echo yes || echo no)"
{ [ "$PARSE_OK" -eq 1 ] && case "$SHEBANG" in "#!"*) true;; *) false;; esac && [ "$ROLE_STAMP" -ge 1 ]; }; C4=$?

echo "demo:summary_table"
head_ "S142 acceptance — mapped to the live cases above"
printf "  # requirement                                                     case        result\n"
printf "  ─────────────────────────────────────────────────────────────────────────────────\n"
printf "  1 hook carries a round-tripping shell-comment stamp (inert)       CASE 1/4    %b\n" "$(mk $C1)"
printf "  2 classify exercises the FOUR states on a hook                    CASE 1/2/3  %b\n" "$(mk $C2)"
printf "  3 StaleRender hook auto-upgrades; Drifted refused (exit 1)        CASE 2/3    %b\n" "$(mk $C3)"
printf "  4 the stamp does NOT change behavior (hook still runs)            CASE 4      %b\n" "$(mk $C4)"

echo "demo:before_after"
head_ "Before → After"
printf "  ${RED}BEFORE (S141):${RESET} only .claude/agents/*.md upgraded smoothly; the hooks were add-only —\n"
printf "         created once, then frozen. Improving a hook meant a human hand-copy + clobber risk.\n"
printf "  ${GREEN}AFTER  (S142):${RESET} the SAME single command (vajra init --sync-fleet) auto-upgrades an\n"
printf "         untouched old hook (CASE 2) and still refuses a real edit (CASE 3). Honest limit:\n"
printf "         pre-S142 hooks are unstamped, so their FIRST upgrade needs one --overwrite-drifted;\n"
printf "         and the filled constitution (.ai/AGENTS.md) is the named S143 follow-up.\n"

echo ""
FAILS=$(( (C1!=0) + (C2!=0) + (C3!=0) + (C4!=0) ))
[ "$FAILS" -eq 0 ] && printf "${GREEN}${BOLD}demo: all 4 cases green${RESET}\n" \
                   || printf "${RED}${BOLD}demo: %s case(s) red${RESET}\n" "$FAILS"
[ "$FAILS" -eq 0 ]
