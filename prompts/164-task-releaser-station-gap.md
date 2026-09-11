# Session 164 — Close the Releaser station gap

> **Status:** APPROVED — founder pick B (2026-09-11, post S163 closeout)

## Type
- **CODE** (~2h cap)

## Goal

The Releaser station in `verify-closeout.sh` has never passed in any session. The root cause is structural: the station requires that all session branches be pruned from the remote, but `session-156-admin-close` is still present on origin and cannot be pruned without special auth. The station therefore always blocks at closeout.

Two valid fixes — pick the narrowest one that makes the station honest:

**Option A (preferred):** Teach the Releaser station to accept a declared exception for branches that cannot be pruned because they require elevated auth to delete from the remote — a `releaser: exception — <reason>` marker in the prompt or a matching entry in AGENTS.md. The station passes when the exception is declared; blocks when it is absent with no exception.

**Option B (alternative):** Prune `session-156-admin-close` from origin and update the Releaser station to pass cleanly with no exception machinery.

Option B requires verifying that pruning this branch is safe (it is a merged admin-only session from S156; the PR was merged). If both are equivalent in risk, prefer whichever produces fewer ongoing workarounds.

## Acceptance criteria

| AC | Criterion |
|----|-----------|
| AC1 | Releaser station passes at closeout for S164 (`release-coordinator` PASS in verify-closeout.sh summary) |
| AC2 | If Option A: a `releaser: exception — <reason>` marker mechanism is added; the station blocks when the marker is absent; the station passes when the marker is present and names a real reason |
| AC3 | If Option B: `session-156-admin-close` is confirmed pruned from origin; station passes cleanly with no exception marker needed |
| AC4 | All previously-passing verify-closeout.sh checks still pass (non-regression) |
| AC5 | `scripts/verify-session-164.sh` exits 0; every check is behavioral |

## Guardrails

- **Do not touch the Releaser station logic beyond what is needed to make it honest.** Do not refactor the broader station, add new checks, or change the error format.
- **Exception mechanism (Option A) must block by default.** An absent exception must cause FAIL, not SKIP. The station must be harder to pass than before, not easier.
- **Max 3 files per atomic commit.**
- **design-significant: no** — no new interface or ADR needed for a single-station fix.

## Plan

1. Investigate the Releaser station: read its logic, reproduce the failure, confirm the root cause. covers: 1
2. Implement the chosen fix (Option A or B). covers: 2, 3
3. Run full verify-closeout.sh — confirm Releaser PASS + no regression in other checks. covers: 1, 4
4. Write `scripts/demo-session-164.sh` and `scripts/verify-session-164.sh` (behavioral). covers: 5

## Design

design-significant: no — no new interface contract or ADR. This session fixes an existing station's blocking condition; it does not add a new pipeline station or change the handoff protocol.
design-advisor: skipped — design-significant: no.

## Crew

tech-lead to dispatch first (mandatory). fidelity-reviewer required (DECISION-002; no self-cert). release-coordinator required — the session's own goal is to make the release-coordinator station pass; an independent release-coordinator handoff must confirm the fix is real, not self-asserted.

## Delta

The Releaser station was last touched at S71–S72 (Demo-er → Releaser sprint). S160 GT flagged it as structurally absent (merged branch `session-156-admin-close` not pruned; station NEVER passes). S163 GT carry-forward listed it as backlog. S164 closes it: the 8-station spine is complete only when all 8 stations actually pass, not just pass on the right kind of sessions.
