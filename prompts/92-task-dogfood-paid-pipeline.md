# Session 92 — Dogfood: full paid 8-station pipeline ride-along

> **Status:** APPROVED (founder pick A, S91 close).

## Goal

Run `vajra claude` end-to-end on a real bounded task. Measure the full 8-station governed pipeline
as a lived experience. Record the receipt, station check, and `--dogfood-age` output. The dogfood
gap has been 🔴 for 14 sessions (since S76 = 2026-07-18) — this session closes it.

This is a **DOGFOOD** session, not a CODE session. The deliverable is evidence, not src/ changes.
The allowed artefacts are:

- `sessions/session-92-artifacts/` — receipt, run-result.json, any demo output
- `sessions/session-92-ground-truth.md` — the measured report (same format as a GT report, but
  scoped to dogfood evidence, not a full audit)
- `.ai/STATE.md`, `ROADMAP.md`, `SESSION-BOOT.md`, `TASK.md`, `SESSION` — closeout sync only

No `## Execution` shas required (DOGFOOD session — no src/ deliverables). No fidelity review
required. `VAJRA_CLOSEOUT_WAIVER=dogfood-no-src-changes` is the correct waiver for this session.

## Why this session

Three consecutive GTs (S80, S85, S90) flagged the dogfood gap as 🔴. S91 added `--dogfood-age`
to make it measurable live. The 8-station pipeline is now complete (S72) and counter-verified
(S74/S75), but has never been run as a governing layer over a real paid `vajra claude` session
post-spine-completion. S76 (pre-spine-complete) is the last real paid run. The evidence is 14
sessions stale.

## Scope

**The task to dogfood:** Pick a bounded, well-scoped improvement from the S92 backlog that is
small enough to complete in one session and concrete enough to produce a real diff. Good candidates
(choose one at session start, record the choice):

- Fix S89 Demo-er ABSENT (`demo-session-89.sh` markers) — option B from S91 close
- Add `--ledger-verify` to mandatory closeout run — option C from S91 close
- Any other backlog item that fits in ~1h of real `vajra claude` time

**What to measure:**
1. `vajra next --stations NN` (where NN = 92) — record K-of-8 at session close
2. `vajra next --dogfood-age` — record the live output (should show S92 after this run)
3. Receipt: `sessions/session-92-artifacts/receipt.stderr.txt` (or `vajra-receipt.txt`)
4. `run-result.json` with `total_cost_usd` (S78 tee path — this is how we capture the real cost)
5. Obedience: did the agent follow all governance gates or bypass any? Document explicitly.

## Acceptance Criteria

1. `vajra claude` ran at least one real paid turn (non-zero `total_cost_usd` in `run-result.json`
   or the receipt shows a non-zero model call). `covers: 1`
2. `sessions/session-92-artifacts/receipt.stderr.txt` (or `vajra-receipt.txt`) exists and is
   committed to the branch. `covers: 1`
3. `vajra next --stations 92` output is recorded in the ground-truth report. `covers: 3`
4. `vajra next --dogfood-age` output is recorded (session 92 should now be the most recent). `covers: 4`
5. Governance obedience documented: which gates fired, which (if any) were bypassed and why. `covers: 5`
6. `sessions/session-92-ground-truth.md` exists with verdict rows for: cost, stations, obedience,
   dogfood_staleness (post-run `--dogfood-age` output). `covers: all`

## Design

design-significant: **no** — no src/ changes from the governing layer (Vajra itself). The session
produces evidence artefacts, not code. Any src/ changes from the dogfooded task are the
subject-repo changes, not Vajra governance changes.

## Plan

1. Pick the task to dogfood (one of the backlog candidates above or another bounded item). Record
   the choice in the session ground-truth report. `covers: 6`
2. Run `vajra claude` with the task prompt. Let the governed agent complete the work. `covers: 1`
3. Capture the receipt: `sessions/session-92-artifacts/` with `receipt.stderr.txt` and
   `run-result.json`. Verify `total_cost_usd` is present (S78 tee path). `covers: 1, 2`
4. At session close, run `vajra next --stations 92` and `vajra next --dogfood-age`. Record both
   outputs verbatim. `covers: 3, 4`
5. Document governance obedience: did the agent follow the session guard, commit gate, closeout
   gate? Any bypasses? `covers: 5`
6. Write `sessions/session-92-ground-truth.md` with all measured data. `covers: 6`

## Guardrails

- Max 2 assumptions · max 2 retries · max 1 story.
- DOGFOOD session: `VAJRA_CLOSEOUT_WAIVER=dogfood-no-src-changes` — no `## Execution` shas required.
- No fidelity review required for DOGFOOD sessions (no src/ deliverable to review).
- Branch: `session-92-dogfood-paid-pipeline`. New chat.
- If the dogfooded task produces src/ changes, those changes must pass their OWN closeout (i.e.
  the nested session has its own verify script, review, etc.) — do NOT merge src/ changes into
  the S92 dogfood branch without proper closeout.

## Delta (Analyst gate)

- `+` `sessions/session-92-artifacts/` — receipt + run-result.json (evidence)
- `+` `sessions/session-92-ground-truth.md` — measured dogfood report
- `~` `.ai/STATE.md`, `ROADMAP.md`, `SESSION-BOOT.md`, `TASK.md`, `SESSION` — closeout sync only
