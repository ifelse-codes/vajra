#!/usr/bin/env bash
# fixture-session-134.sh — falsifiability for S134's seen-manifest checks.
#
# A green verify script proves nothing unless it can go RED. This plants four defects, one at a
# time, into a THROWAWAY copy of the manifest + evidence tree and asserts verify-session-134.sh
# fails on each. Two rules this repo learned the hard way:
#   - S122: a fixture must fail for the RIGHT reason, not because something else broke.
#   - S127/S132: every substitution must ASSERT IT LANDED, including the positive control.
set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

GREEN="\033[32m"; RED="\033[31m"; DIM="\033[2m"; BOLD="\033[1m"; RESET="\033[0m"
PASS=0; FAIL=0
ok()  { printf "${GREEN}✓${RESET} %s\n" "$1"; PASS=$((PASS+1)); }
bad() { printf "${RED}✗${RESET} %s\n" "$1"; FAIL=$((FAIL+1)); }
head_(){ printf "\n${BOLD}══ %s ══${RESET}\n" "$1"; }

REAL_CHITRA="${VAJRA_S134_CHITRA_ROOT:-/Users/suman/playground/chitra}"
REAL_MANIFEST="sessions/session-134-seen-manifest.tsv"
# Every mutation below happens to a SANDBOX COPY. The tracked manifest is opened read-only, once.
MANIFEST=""  # set to the sandbox copy after $WORK exists

WORK=$(mktemp -d "${TMPDIR:-/tmp}/vajra-s134-fixture-XXXXXX")
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

[ -s "$REAL_MANIFEST" ] || { echo "no manifest to falsify — cannot evaluate, FAIL (S69)"; exit 1; }
REAL_SHA=$(shasum -a 256 "$REAL_MANIFEST" | cut -d' ' -f1)
cp "$REAL_MANIFEST" "$WORK/manifest.orig"
MANIFEST="$WORK/manifest.live"
cp "$WORK/manifest.orig" "$MANIFEST"

# A sandbox chitra: real evidence files copied out, so a mutation cannot touch the real repo.
SANDBOX="$WORK/chitra"
while IFS=$'\t' read -r fam chart method path sha cap src; do
  [ -n "${path:-}" ] || continue
  mkdir -p "$SANDBOX/$(dirname "$path")"
  cp "$REAL_CHITRA/$path" "$SANDBOX/$path" 2>/dev/null || true
done < <(tail -n +2 "$REAL_MANIFEST")
# The fingerprints/gate-log live in the repo and are untouched by these fixtures; only the
# chitra-side evidence is sandboxed, so a RED here can only come from the manifest checks.
mkdir -p "$SANDBOX/sessions"
cp "$REAL_CHITRA/sessions/mudra-chart-review-2026-08-26.md" "$SANDBOX/sessions/" 2>/dev/null || true

# ANSI must be stripped before grepping: the label is preceded by a colour reset, so a pattern
# like `✗ the check` never matches the raw bytes. (Found by this fixture's own positive control —
# it reported a broken harness rather than a silent all-green, which is the point of having one.)
run_verify() {
  VAJRA_S134_CHITRA_ROOT="$SANDBOX" VAJRA_S134_MANIFEST="$MANIFEST" bash scripts/verify-session-134.sh 2>&1 \
    | sed 's/\x1b\[[0-9;]*m//g' >"$WORK/out.txt"
  local ec=${PIPESTATUS[0]}
  echo "$ec"
}

# ── positive control ─────────────────────────────────────────────────────────
head_ "positive control — the UNMODIFIED manifest must reach the manifest checks GREEN"
cp "$WORK/manifest.orig" "$MANIFEST"
run_verify >/dev/null
if grep -q '✓ every evidence file exists and its sha256 recomputes equal' "$WORK/out.txt"; then
  ok "control: the sha256 check passes on the untouched manifest (so a later RED means the defect)"
else
  bad "control FAILED — the harness is broken, every RED below is meaningless"
  printf "${DIM}%s${RESET}\n" "$(grep '✗' "$WORK/out.txt" | head -5)"
fi

# ── defect 1: a mutated sha ──────────────────────────────────────────────────
head_ "defect 1 — a manifest row's sha256 no longer matches its bytes"
python3 - "$MANIFEST" <<'PY'
import sys
p=sys.argv[1]; L=open(p).read().split('\n')
for i,l in enumerate(L):
    f=l.split('\t')
    if len(f)==7 and f[0]!='family':
        f[4]='0'*64; L[i]='\t'.join(f); break
open(p,'w').write('\n'.join(L))
PY
if grep -q '0000000000000000000000000000000000000000000000000000000000000000' "$MANIFEST"; then
  ok "substitution LANDED (a row now claims an all-zero sha)"
  ec=$(run_verify)
  if [ "$ec" -ne 0 ] && grep -q '✗ every evidence file exists and its sha256 recomputes equal' "$WORK/out.txt"; then
    ok "verify went RED, and on the RIGHT check (sha mismatch)"
  else
    bad "verify did NOT go red on the sha check (exit $ec)"
  fi
else
  bad "substitution did not land — fixture is vacuous"
fi
cp "$WORK/manifest.orig" "$MANIFEST"

# ── defect 2: a stale screenshot ─────────────────────────────────────────────
head_ "defect 2 — evidence that PREDATES the code it claims to show"
python3 - "$MANIFEST" <<'PY'
import sys
p=sys.argv[1]; L=open(p).read().split('\n')
for i,l in enumerate(L):
    f=l.split('\t')
    if len(f)==7 and f[0]!='family':
        f[2]='screenshot-existing'
        f[5]='2020-01-01T00:00:00Z'      # captured long before
        f[6]='2026-08-24T12:19:58Z'      # source changed after
        L[i]='\t'.join(f); break
open(p,'w').write('\n'.join(L))
PY
if grep -q 'screenshot-existing' "$MANIFEST" && grep -q '2020-01-01T00:00:00Z' "$MANIFEST"; then
  ok "substitution LANDED (a screenshot row now predates its source)"
  ec=$(run_verify)
  if [ "$ec" -ne 0 ] && grep -q '✗ no screenshot-existing row is older than the source' "$WORK/out.txt"; then
    ok "verify went RED on the stale-screenshot tooth — the exact defect rec 15 named"
  else
    bad "the stale-screenshot tooth did NOT bite (exit $ec)"
  fi
else
  bad "substitution did not land — fixture is vacuous"
fi
cp "$WORK/manifest.orig" "$MANIFEST"

# ── defect 3: a method word outside the closed vocabulary ────────────────────
head_ "defect 3 — a method word outside the closed vocabulary"
python3 - "$MANIFEST" <<'PY'
import sys
p=sys.argv[1]; L=open(p).read().split('\n')
for i,l in enumerate(L):
    f=l.split('\t')
    if len(f)==7 and f[0]!='family':
        f[2]='looked-at-it-basically'; L[i]='\t'.join(f); break
open(p,'w').write('\n'.join(L))
PY
if grep -q 'looked-at-it-basically' "$MANIFEST"; then
  ok "substitution LANDED (a row claims an invented method)"
  ec=$(run_verify)
  if [ "$ec" -ne 0 ] && grep -q "✗ every manifest row's method is in the closed vocabulary" "$WORK/out.txt"; then
    ok "verify went RED on the vocabulary check — an invented word does not warn, it FAILS"
  else
    bad "the vocabulary check did NOT bite (exit $ec)"
  fi
else
  bad "substitution did not land — fixture is vacuous"
fi
cp "$WORK/manifest.orig" "$MANIFEST"

# ── defect 4: an empty manifest (the vacuity trap) ───────────────────────────
head_ "defect 4 — a well-formed but EMPTY manifest (the S126 vacuity trap)"
head -1 "$WORK/manifest.orig" > "$MANIFEST"
if [ "$(tail -n +2 "$MANIFEST" | grep -c .)" -eq 0 ]; then
  ok "substitution LANDED (header only, zero rows)"
  ec=$(run_verify)
  if [ "$ec" -ne 0 ] && grep -q '✗ manifest carries at least 7 rows' "$WORK/out.txt"; then
    ok "verify went RED on the non-vacuity floor — zero rows is not a green"
  else
    bad "the vacuity floor did NOT bite (exit $ec)"
  fi
else
  bad "substitution did not land — fixture is vacuous"
fi
cp "$WORK/manifest.orig" "$MANIFEST"

# ── restoration control ──────────────────────────────────────────────────────
head_ "untouched control — the TRACKED manifest was never written at all"
if [ "$(shasum -a 256 "$REAL_MANIFEST" | cut -d' ' -f1)" = "$REAL_SHA" ]; then
  ok "the tracked manifest still hashes to its pre-fixture value (never mutated, not merely restored)"
else
  bad "the TRACKED manifest changed — this fixture damaged real evidence"
fi

printf "\n${BOLD}%d passed, %d failed${RESET}\n" "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
