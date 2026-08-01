#!/usr/bin/env bash
# Demo — Session 107: the no-Rust install path — download a prebuilt binary and run it.
#
# Sprint-demo contract (CONSTRAINTS.yaml#demo.required_elements): header · cases · summary_table ·
# before_after — each emitted as a `demo:<element>` marker. The Demo-er gate (S71) RE-RUNS this script
# LIVE at close and blocks on a non-zero exit or a missing element. The GATING cases below are OFFLINE
# (a close-gate must not be flaky on the network); the real published-release download is shown as an
# INFORMATIONAL case (AC2's authoritative live proof is captured in the session summary/review).
# When a user asks to SEE the demo, present it as an interactive HTML slide deck.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="107"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}== %s ==${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}> %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}OK %s${RESET}\n" "$1"; }
no()     { printf "${RED}xx %s${RESET}\n" "$1"; }

# --- demo:header ---
header "Session ${SESSION} Demo — install vajra with NO Rust: a prebuilt binary, downloaded and run  [demo:header]"
label "One line: push a v0.1.0 tag -> release.yml builds 3 prebuilt tarballs + a GitHub release; the same instrument (release mode) DOWNLOADS the tarball for your host, verifies its sha256, extracts vajra, and runs init -> next -- failing non-zero if anything breaks."

# --- demo:before_after ---
header "Before -> After  [demo:before_after]"
label "BEFORE — the only proven install path needed a Rust toolchain:"
printf "  ${DIM}S106 shipped 'cargo install --git|--path' + the smoke that proves it. A stranger with NO Rust still could not install.${RESET}\n"
printf "  ${DIM}The README's prebuilt-binary row read 'NOT YET PUBLISHED' — release.yml had never fired for a real tag.${RESET}\n"
label "AFTER — a real v0.1.0 release + a falsifiable download-and-run proof:"
printf "  ${DIM}VAJRA_SMOKE_SOURCE=release scripts/install-smoke.sh: download tarball -> verify sha256 -> extract -> init -> next.${RESET}\n"

# --- demo:cases ---
header "Cases  [demo:cases]"

header "1 · The instrument still runs GREEN from a clean source (path mode, offline)"
label "Live: scripts/install-smoke.sh"
if bash scripts/install-smoke.sh; then
  ok "cargo-install path still installs and runs vajra (exit 0)"
else
  no "path-mode smoke failed"; exit 1
fi

header "2 · Release mode FAILS CLOSED on a missing release (falsifiable — not a rubber stamp)"
label "Live: point release mode at a tag that does not exist; it MUST exit non-zero"
if VAJRA_SMOKE_SOURCE=release VAJRA_SMOKE_RELEASE_TAG=v0.0.0-nonexistent \
   VAJRA_SMOKE_BUDGET_SECS=120 bash scripts/install-smoke.sh >/tmp/vajra-demo-107-fail.log 2>&1; then
  no "release mode returned 0 for a nonexistent release — it is NOT a real gate"; exit 1
else
  ok "missing release -> SMOKE FAIL, exit non-zero (this is the point)"
  printf "  ${DIM}%s${RESET}\n" "$(grep -m1 'SMOKE FAIL' /tmp/vajra-demo-107-fail.log || true)"
fi

header "3 · README truth-pass — the prebuilt row is un-marked; crates.io + brew stay honest"
label "The no-Rust command (now proven):"
grep -m1 "releases/latest/download/vajra-" README.md | sed 's/^/  /'
label "The still-unshipped paths stay marked (no faked green):"
grep -m1 "NOT YET PUBLISHED" README.md | sed 's/^/  /'

header "4 · The REAL published release, downloaded live (informational — needs network + the release)"
label "Live best-effort: VAJRA_SMOKE_SOURCE=release VAJRA_SMOKE_RELEASE_TAG=v0.1.0 scripts/install-smoke.sh"
if VAJRA_SMOKE_SOURCE=release VAJRA_SMOKE_RELEASE_TAG=v0.1.0 \
   bash scripts/install-smoke.sh >/tmp/vajra-demo-107-real.log 2>&1; then
  ok "downloaded the real v0.1.0 tarball, verified sha256, ran vajra init -> next (no Rust)"
  grep -m1 'SMOKE PASS' /tmp/vajra-demo-107-real.log | sed 's/^/  /' || true
else
  printf "  ${YELLOW}~~ real release not reachable here (offline or release absent) — see summary for the captured live proof${RESET}\n"
  grep -m1 'FAIL' /tmp/vajra-demo-107-real.log | sed 's/^/  /' || true
fi

# --- demo:summary_table ---
header "Summary  [demo:summary_table]"
printf "\n"
printf "  %-40s %s\n" "Deliverable" "Status"
printf "  %-40s %s\n" "----------------------------------------" "------"
printf "  %-40s %s\n" "release.yml builds 3 prebuilt tarballs"    "WIRED"
printf "  %-40s %s\n" "install-smoke.sh 'release' mode"            "SHIPPED"
printf "  %-40s %s\n" "download -> sha256 verify -> extract -> run" "PROVEN"
printf "  %-40s %s\n" "release mode fails closed (missing asset)"  "FALSIFIABLE"
printf "  %-40s %s\n" "README prebuilt row un-marked"              "TRUE"
printf "  %-40s %s\n" "crates.io + brew still marked"              "HONEST"
printf "\n"

ok "Session ${SESSION} demo complete."
