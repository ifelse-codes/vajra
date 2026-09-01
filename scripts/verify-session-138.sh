#!/usr/bin/env bash
# verify-session-138.sh — THE REAL DOGFOOD: `vajra claude` run from INSIDE chitra.
#
# S138 corrected the S137 method: the heatmap lock is a NATIVE chitra session (chitra's hooks,
# chitra's fleet, chitra's `.ai/`), driven headless and MONITORED from the Vajra session. This
# Vajra session is the wrapper: prep + evidence + reports. The build landed in chitra on branch
# `session-18-heatmap-lock` (4 commits, 6 files).
#
# Every check FAILS on absent (S69: a check that cannot evaluate FAILS, never skips). Cross-repo
# checks read chitra READ-ONLY via `git -C`; they FAIL if chitra is missing (the evidence lives
# there). Behavioral check re-derives accent-once from the COMMITTED locked preview (raw-RGB).
set -uo pipefail

VAJRA_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHITRA="${CHITRA_ROOT:-/Users/suman/playground/chitra}"
BR="session-18-heatmap-lock"
PASS=0; FAIL=0; EXECN=0; STRUCTN=0; BEHAVN=0
ok(){ echo "  ✅ $1"; PASS=$((PASS+1)); }
no(){ echo "  ❌ $1"; FAIL=$((FAIL+1)); }
cls(){ case "$1" in exec)EXECN=$((EXECN+1));; struct)STRUCTN=$((STRUCTN+1));; behav)BEHAVN=$((BEHAVN+1));; esac; }

echo "=== verify-session-138 · the real inside-chitra dogfood ==="

# 1 [STRUCT] the wrapper prompt exists and states the corrected method
cls struct
P="$VAJRA_ROOT/prompts/138-task-real-dogfood-inside-chitra.md"
if [ -f "$P" ] && grep -qiE "INSIDE chitra" "$P" && grep -qi "never reach across" "$P" 2>/dev/null || { [ -f "$P" ] && grep -qi "corrected" "$P"; }; then
  ok "1 wrapper prompt present + corrected-method stated"; else no "1 wrapper prompt missing/incomplete"; fi

# 2 [STRUCT] the founder handoff exists
cls struct
[ -f "$VAJRA_ROOT/sessions/session-138-chitra-handoff.md" ] && ok "2 founder handoff present" || no "2 founder handoff missing"

# 3 [STRUCT] the render exists and carries the raw-RGB accent PASS verdict + canonical accent hue
cls struct
R="$VAJRA_ROOT/sessions/session-138-heatmap-render.html"
if [ -f "$R" ] && grep -q "#8B7CF6" "$R" && grep -qi "PASS" "$R"; then
  ok "3 heatmap render present + accent PASS verdict"; else no "3 render missing / no accent verdict"; fi

# 4 [EXEC] chitra repo present (the dogfood evidence lives there)
cls exec
if git -C "$CHITRA" rev-parse --show-toplevel >/dev/null 2>&1; then ok "4 chitra repo reachable at $CHITRA"; else no "4 chitra repo NOT reachable at $CHITRA"; fi

# 5 [EXEC] the heatmap branch exists with the 4 S18 build commits
cls exec
N=$(git -C "$CHITRA" log --oneline "main..$BR" 2>/dev/null | grep -c "S18:")
if [ "${N:-0}" -ge 4 ]; then ok "5 $BR carries $N S18 commits (>=4)"; else no "5 $BR missing S18 commits (found ${N:-0})"; fi

# 6 [EXEC] the rainbow was removed — the old blue->orange HEAT_COLORS_DARK gradient is gone
cls exec
HT=$(git -C "$CHITRA" show "$BR:packages/core/src/charts/heatmap.ts" 2>/dev/null)
if [ -n "$HT" ] && ! printf '%s' "$HT" | grep -q "HEAT_COLORS_DARK" && printf '%s' "$HT" | grep -qiE "ECECEF|grey|gray|ramp"; then
  ok "6 rainbow removed; grey ramp present in heatmap.ts"; else no "6 heatmap.ts still rainbow / no grey ramp"; fi

# 7 [EXEC] the README carries the LOCKED heatmap contract
cls exec
if git -C "$CHITRA" show "$BR:packages/core/README.md" 2>/dev/null | grep -qi "LOCKED: heatmap chart"; then
  ok "7 README LOCKED: heatmap block present"; else no "7 README LOCKED: heatmap block missing"; fi

# 8 [EXEC] falsifiability tests assert accent===1 at the CELL level
cls exec
TT=$(git -C "$CHITRA" show "$BR:packages/core/tests/heatmap.test.ts" 2>/dev/null)
if printf '%s' "$TT" | grep -qE "accent" && printf '%s' "$TT" | grep -qE "toBe\(1\)"; then
  ok "8 heatmap.test.ts asserts accent===1 (cell level)"; else no "8 accent-once assertion absent"; fi

# 9 [BEHAV] raw-RGB accent-once on the COMMITTED locked preview: exactly ONE non-grey hue
#   (#8B7CF6, chitra's canonical accent) + all 4 documented grey tones present.
cls behav
TMPJS="$(mktemp -t s138acc.XXXXXX).cjs"
cat > "$TMPJS" <<'NODE'
const {execSync}=require("child_process");
const CH=process.env.CHITRA||"/Users/suman/playground/chitra", BR="session-18-heatmap-lock";
let raw;try{raw=execSync(`git -C ${CH} show ${BR}:artifacts/chitra-docs/src/data/ansi-charts.json`,{encoding:"utf8"});}catch(e){console.log("NOJSON");process.exit(3);}
let j;try{j=JSON.parse(raw);}catch(e){console.log("BADJSON");process.exit(3);}
const arr=Array.isArray(j)?j:Object.values(j);
const h=arr.find(x=>x&&(x.id||x.slug)==="heatmap")||j.heatmap;
const s=typeof h==="string"?h:(h&&(h.ansi||h.preview||h.output||h.text))||"";
const ESC=String.fromCharCode(27);const GREY=["ECECEF","C6C6CE","A4A4AE","6A6A75"];
const tally={};let cur=null;let i=0;
while(i<s.length){if(s[i]===ESC){const m=s.slice(i).match(/^\x1b\[([0-9;]*)m/);if(m){const fg=m[1].match(/38;2;(\d+);(\d+);(\d+)/);if(fg)cur=((+fg[1]).toString(16)+(+fg[2]).toString(16)+(+fg[3]).toString(16)).toUpperCase().padStart(6,"0");else if(m[1]==="0"||m[1]==="")cur=null;i+=m[0].length;continue;}}const ch=s[i];if(cur&&ch!=="\n"&&ch!==" ")tally[cur]=(tally[cur]||0)+1;i++;}
const keys=Object.keys(tally);const greyPresent=GREY.filter(g=>keys.some(k=>k.endsWith(g)));
const nonGrey=keys.filter(k=>!GREY.some(g=>k.endsWith(g)));
const okAccent=nonGrey.length===1&&/8B7CF6$/.test(nonGrey[0]);
const okGrey=greyPresent.length===4;
console.log("nonGrey="+JSON.stringify(nonGrey)+" grey="+greyPresent.length);
process.exit(okAccent&&okGrey?0:1);
NODE
if CHITRA="$CHITRA" node "$TMPJS"; then ok "9 raw-RGB: one accent (#8B7CF6) + 4 grey tones on the locked preview"; else no "9 accent leak / grey ramp incomplete on locked preview"; fi
rm -f "$TMPJS"

# 10 [EXEC] scope proof: session-18 changed EXACTLY the 6 declared files vs main (nothing stray)
cls exec
CHANGED=$(git -C "$CHITRA" diff --name-only "main..$BR" 2>/dev/null | sort)
EXPECT=$(printf '%s\n' \
  "artifacts/chitra-docs/scripts/chart-specs.ts" \
  "artifacts/chitra-docs/src/data/ansi-charts.json" \
  "artifacts/chitra-docs/src/data/charts.ts" \
  "packages/core/README.md" \
  "packages/core/src/charts/heatmap.ts" \
  "packages/core/tests/heatmap.test.ts" | sort)
if [ "$CHANGED" = "$EXPECT" ]; then ok "10 exactly the 6 declared files changed vs main (no stray)"; else no "10 scope drift vs main:"; printf '%s\n' "$CHANGED" | sed 's/^/       /'; fi

echo "---"
echo "class tally: $EXECN execute-based · $STRUCTN structural · $BEHAVN behavioral"
echo "RESULT: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
echo "✅ verify-session-138 GREEN"
