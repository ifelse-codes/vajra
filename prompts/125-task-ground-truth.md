# Session 125 — NO-CODE GROUND TRUTH (audits S121–S124)

> **Status:** MANDATORY (`125 % 5 == 0`). Must run before any S126 CODE work.
> **Founder directive in force (S118):** `README.md` / `VISION.md` claims are the **target
> spec**, not a status report. Do NOT soften them. **No release** until reality meets them.

## Type

**NO-CODE. Max 2 assumptions · 2 retries · 1 story · ~2h · new chat.**
No `src/` changes. No commits allowed (the GT itself is the deliverable). Record findings in
`sessions/session-125-ground-truth.md` only.

## Why this session

S125 is mandatory (`125 % 5 == 0`). Four sessions since the last GT (S120):

- S121: QA Specialist role built + dispatched (found 4 real defects in its own suite)
- S122: the guardrails QA audited FIXED (three defects closed)
- S123: the QA role's `Write`/`Edit` grant FENCED — clean-room routing, narrowed grant, `tools:`
  enforcement MEASURED live
- S124: paid dogfood — the S121–S123 machinery's first real-use test

**The audit has two sharpened lenses this session, both surfaced live by S124, not assumed:**

1. **The fleet-never-engaged finding.** Three sessions built fleet + fence machinery; S124's real
   dogfood run never dispatched any of it (0 `Task` tool invocations, 0 `--clean-room-*` calls). Is
   this a scoping problem (the task never needed it), a discoverability problem (the agent didn't
   know it was there or when to reach for it), or something else? Do NOT rationalize it away.
2. **The self-report reliability question.** S124's launched agent produced a summary with a
   fabricated evidence citation (claimed a review file existed before it did). Independently
   verified and caught. Does this change how much weight any PAST session's self-graded SHIPPED
   verdicts deserve, retroactively? Spot-check at least 2 prior sessions' summaries against their
   actual diffs/artifacts, not just accept them.

## Goal

Run all required GT audits. Produce a PASS/PARTIAL/FAIL verdict with an honest account of what is
and is not true. Surface findings so S126 can act on the most load-bearing ones.

## Plan

1. **Vision audit:** re-read `VISION.md`. Does every claim have a corresponding implemented
   feature? Mark gaps `[GAP]` with estimates. `covers: 1`
2. **Roadmap drift audit:** re-read `ROADMAP.md`'s "Where We Are" table against actual code and
   session summaries. `covers: 2`
3. **State/Knowledge consistency:** spot-check 3 claims each in `STATE.md`/`KNOWLEDGE.md` against
   the code. `covers: 3`
4. **Constitution audit:** re-read `AGENTS.md`. Any stale or systematically-skipped rules? `covers: 4`
5. **Cost audit:** cumulative authoritative spend, cross-checked against session summaries
   (including S124's $3.2985, real). `covers: 5`
6. **Dogfood staleness:** run `vajra next --dogfood-age`. Confirm it now shows S124 (post S124's
   closeout commit). `covers: 6`
7. **Pipeline-advance counter:** run `vajra next --stations 125`. Report K-of-8. `covers: 7`
8. **The fleet-never-engaged lens:** read `sessions/session-124-summary.md` and
   `sessions/session-124-artifacts/p1/fleet-engagement.txt` in full. Form an independent judgment
   on why the machinery stayed silent, and whether that is a problem worth a session, or an
   honest, acceptable null result. `covers: 8`
9. **The self-report-reliability lens:** spot-check 2 prior CODE sessions' self-graded verdicts
   (pick from S119–S123) against their actual diffs/artifacts. Does the S124 fabricated-citation
   finding change confidence in any of them? `covers: 9`
10. **Summary + founder pick:** write `sessions/session-125-ground-truth.md` with all findings, a
    PASS/PARTIAL/FAIL verdict per lens, and three options A/B/C for S126 ranked by impact.
    `covers: 10`

## Acceptance criteria

1. Vision audit complete: every vision claim marked IMPLEMENTED / PARTIAL / GAP.
2. Roadmap drift audit complete: session table entries verified against code and summaries.
3. State/Knowledge spot-check: 3 claims each, marked CORRECT / STALE.
4. Constitution audit: stale or contradicted rules listed with evidence.
5. Cost audit: cumulative spend number computed and verified, including S124's real $3.2985.
6. Dogfood staleness: `vajra next --dogfood-age` run; confirmed showing S124 as most recent.
7. Pipeline-advance counter: `vajra next --stations 125` run and result reported.
8. The fleet-never-engaged finding independently assessed — not just repeated from S124.
9. At least 2 prior sessions' self-graded verdicts independently spot-checked against real
   artifacts.
10. `sessions/session-125-ground-truth.md` written, verdict PASS/PARTIAL/FAIL per lens, options
    A/B/C for S126.

## Execution (the Coder gate — NO-CODE so no commits; record only findings)

*No execution shas — this session produces no code.*

## Design

- design-significant: **no** — NO-CODE GT. No `src/` changes.

## Non-goals

- No code changes, no commits, no `src/` edits.
- No release, no crates.io action (founder directive).
- No `verify-session-125.sh` (GT sessions are exempt per `CONSTRAINTS.yaml`
  `ground_truth_commit_exempt_branch_suffixes`).
- Not fixing chitra's session 12 (dead sparkline, missing-then-produced review) — that is chitra's
  own next CODE session, not this audit's job.

## Guardrails

- **NO-CODE.** Any temptation to fix a finding in-session is a violation — record it, don't fix it.
- Run `vajra next --stations 125` as-is; do not modify the binary to game the output.
- **Attest LAST** (not applicable — NO-CODE, no review-inputs-sha required).
