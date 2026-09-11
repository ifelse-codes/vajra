# Session 162 — Test the waiver path + fix false "ready" on fresh init

> **Status:** APPROVED — founder pick (2026-09-11, post S161 closeout)

## Type
- **CODE** (~2h cap)

## Goal

Two pre-ship audit findings (Sept 9 audit) that have never been closed:

**Finding 07 — Emergency override never tested:** `VAJRA_CLOSEOUT_WAIVER` is the "break glass" mechanism that lets a founder bypass a blocking closeout check with an unforgeable env var. It has been *used* (S161 applied it twice) but never formally proven to work correctly end-to-end: does it pass when it should? Does a stale/wrong session number get rejected? Is the waiver reason written to artifacts? None of this is tested.

**Finding 14 — New projects get a false "ready" signal:** When a stranger runs `vajra init` on a brand-new empty repo and then runs `vajra check` or `vajra next --stations`, the system may report a healthy or ready state before a single session has ever closed. That is a misleading signal at exactly the worst moment.

## Acceptance criteria

| AC | Criterion |
|----|-----------|
| AC1 | A behavioral test confirms that `VAJRA_CLOSEOUT_WAIVER=N` on a blocking check causes it to pass for session N — tested live against a synthetic fixture that forces a known block (e.g. missing review file), not just documented in prose |
| AC2 | A behavioral test confirms that `VAJRA_CLOSEOUT_WAIVER=M` where M≠N does NOT bypass a block for session N — the session-scoped guard is proven, not assumed |
| AC3 | The waiver reason (`VAJRA_CLOSEOUT_WAIVER_REASON`) is confirmed to be recorded in the closeout artifacts when a waiver is applied |
| AC4 | Investigate: run `vajra init` on a fresh empty dir, then run `vajra check`, `vajra next`, `vajra next --stations`, and `scripts/verify-closeout.sh` with no session run yet — document exactly what output each produces |
| AC5 | Fix any output from AC4 that gives a false "ready" or misleadingly green signal before session 0 has closed — the correct signal is an honest "no session closed yet" or equivalent |
| AC6 | `scripts/verify-session-162.sh` exits 0 |

## Guardrails

- **AC1–AC3 must use live behavioral tests** — a verify script that greps source code for "waiver" does not prove the waiver path works. The test must actually run `verify-closeout.sh` with and without `VAJRA_CLOSEOUT_WAIVER` and check exit codes.
- **AC4 investigation first, fix second.** Do not guess what signal the fresh init gives — run it and see. The fix scope depends on what you find; do not over-engineer before knowing the problem.
- **AC5 scope:** fix only what is actively misleading (false green / false ready). If the fresh init gives no signal at all, that may be correct — document it and close the finding. Do not add new features.
- Max 3 files per atomic commit.

## Plan

1. Write `scripts/demo-session-162.sh` with 3 cases: (a) waiver-present → PASS, (b) wrong-session-N waiver → BLOCK, (c) waiver-reason recorded in artifacts. covers: 1, 2, 3
2. Run `vajra init` on a fresh tmpdir, run each vajra command, capture and document output. covers: 4
3. Fix the false-ready signal (if found): change the binary or scaffold output to return honest state. covers: 5
4. Write `scripts/verify-session-162.sh`. covers: 6

## Design

design-significant: no — no new interface contract or architectural decision. Waiver behavior is already defined (S56/S93); this session proves it works and fixes an existing output. No ADR needed.
design-advisor: skipped — design-significant: no; no ADR or interface decision in scope.

## Crew

tech-lead to dispatch first (mandatory). fidelity-reviewer required (two deliverables: behavioral tests + fresh-init fix). design-advisor: skipped — design-significant: no.

## Execution

step 1 — done: b35f243 (demo-session-162.sh + tech-lead handoff; waiver Cases A/B/C)
step 2 — done: b35f243 (AC4 investigation: fresh-init signals documented in demo + verify)
step 3 — done: b35f243 (AC5: no fix needed — finding 14 closed as honest; documented)
step 4 — done: 48e89f1 (verify-session-162.sh — 13/13 pass)

## Delta

Pre-ship audit (Sept 9, finding 07): VAJRA_CLOSEOUT_WAIVER used in production (S161 ×2) but never tested — could be broken and we'd only discover it in a crisis. Pre-ship audit finding 14: a stranger running `vajra init` for the first time may see a false green before they have done anything. Both are trust/honesty gaps, not feature gaps. This session closes them before Sept 15.
