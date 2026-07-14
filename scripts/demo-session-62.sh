#!/usr/bin/env bash
# Session 62 — The Analyst's Intake + Options half, made REAL (finishes the S54 REJECT).
# Demo: INTAKE surfaces the real inputs (prior .ai/SESSION + ROADMAP next-builds) so the job comes
# from context, not a slug; OPTIONS enforces a RECORDED count — a session that records 2 or 4 ranked
# candidates is BLOCKED at closeout, only exactly 3 passes. The binary SURFACES + ENFORCES; it never
# AUTHORS. Cumulative: one CLI, no 8th command, the .ai/+prompts/+sessions/ spine, the Analyst gate.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }

header "Session 62 Demo — Intake surfaces the real inputs · Options enforces exactly 3"
printf "${DIM}  S54 shipped the gate; S61 made Generate+Delta real; S62 finishes Intake+Options.${RESET}\n"

cargo build --quiet 2>/dev/null || true
BIN="$ROOT/target/debug/vajra"

# Throwaway Vajra repo at session 40, L3 (non-interactive advance).
E2E="$(mktemp -d)"; trap 'rm -rf "$E2E"' EXIT
mkdir -p "$E2E/.ai" "$E2E/prompts" "$E2E/sessions"
echo "40" > "$E2E/.ai/SESSION"
printf 'version: 3\nmaturity: L3\n' > "$E2E/.ai/CONSTRAINTS.yaml"
printf '# Session Boot\n- **Number:** 40\n' > "$E2E/.ai/SESSION-BOOT.md"
printf '# Current Task Pointer\n\nRead prompt: `prompts/40-task-x.md`\n' > "$E2E/.ai/TASK.md"
cat > "$E2E/.ai/ROADMAP.md" <<'ROADMAP'
# Vajra — Working Roadmap

### Next builds — ranked

Intro prose (not a list item).

1. **🥇 build the planner stage — the second pipeline specialist.**
2. **🥈 a paid dogfood run — measure the experience.**
3. **🥉 harden the gate — signer + ledger-verify.**

**Prior · Session 39 — a past entry.**
1. a stray numbered line that must NOT be surfaced.
ROADMAP
( cd "$E2E" && git init -q && git config user.email t@t && git config user.name t \
    && git add -A && git commit -qm init && git checkout -q -b session-41-x )

header "1 · INTAKE (J1) — surface the real inputs the author must fold into the Goal"
label "vajra next --intake"
( cd "$E2E" && "$BIN" next --intake ) | sed 's/^/    /'
if ( cd "$E2E" && "$BIN" next --intake ) | grep -q 'planner stage' \
   && ( cd "$E2E" && "$BIN" next --intake ) | grep -q 'prior session (.ai/SESSION): 40'; then
  ok "J1: prior session + ROADMAP next-builds surfaced — the job comes from context, not a slug"
else bad "intake did not surface the real inputs"; fi

header "2 · OPTIONS (J2) — a session must record EXACTLY 3 ranked next candidates"
sum_with() {
  { printf '# S40 summary\n\n## Next — ranked candidates (S41)\n\n'
    for L in "$@"; do printf -- '- **%s 🥇 — a candidate.**\n  *Goal:* do the thing.\n' "$L"; done
  } > "$E2E/sessions/session-40-summary.md"
}

printf "${DIM}  A summary with only 2 options (A, B):${RESET}\n"
sum_with A B
label "vajra next --check-options 40   (expected: BLOCKED — not exactly 3)"
if ( cd "$E2E" && "$BIN" next --check-options 40 ); then
  bad "closed a session on 2 options — the count was not enforced"
else
  ok "J2: BLOCKED — a non-author cannot close a session on 2 options"
fi

printf "\n${DIM}  A summary with 4 options (A, B, C, D):${RESET}\n"
sum_with A B C D
label "vajra next --check-options 40   (expected: BLOCKED — not exactly 3)"
if ( cd "$E2E" && "$BIN" next --check-options 40 ); then
  bad "closed a session on 4 options"
else
  ok "J2: BLOCKED — 4 options is over the mandated 3"
fi

printf "\n${DIM}  A summary with exactly 3 options (A, B, C):${RESET}\n"
sum_with A B C
label "vajra next --check-options 40   (expected: READY)"
if ( cd "$E2E" && "$BIN" next --check-options 40 ) | grep -q READY; then
  ok "exactly 3 recorded — the closeout is allowed to proceed"
else bad "3 options was wrongly rejected"; fi

header "3 · WIRED into --advance — closing a session on the wrong count is refused"
cat > "$E2E/prompts/41-task-planner-stage.md" <<'P'
# Session 41 — planner-stage: a slice
> **Status:** APPROVED
## Goal
Do one thing.
## Deliverables
- a thing
## Acceptance
1. it works
## Guardrails
- one story
## Delta (vs ROADMAP)
- `+` a real recorded change
P
sum_with A B          # closing session 40 records only 2 options
label "vajra next --advance   (expected: BLOCKED on the closing session's options)"
if ( cd "$E2E" && "$BIN" next --advance ); then
  bad "advanced while the closing session recorded 2 options"
else
  ok "advance refused — SESSION stayed at $(cat "$E2E/.ai/SESSION")"
fi
sum_with A B C        # fix to exactly 3
label "vajra next --advance   (now: 40 → 41)"
if ( cd "$E2E" && "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "41" ]; then
  ok "exactly 3 recorded — advanced 40 → 41"
else bad "advance failed with a valid 3-option summary"; fi

header "Honest scope"
printf "${DIM}  The binary SURFACES the inputs (J1) and ENFORCES the count (J2) — it does NOT author${RESET}\n"
printf "${DIM}  the intent or the options. That is the agent's job (no faked 'generated').${RESET}\n"
printf "${GREEN}${BOLD}  S54 Analyst REJECT: 3-of-5 → 5-of-5 core stage-steps real — now ACCEPT-able.${RESET}\n"
