# Session 120 — NO-CODE GROUND TRUTH (audits S116–S119)

> **Status:** APPROVED — mandatory (`120 % 5 == 0`). Must run before any S121 CODE work.
> **Founder directive in force (S118):** `README.md` / `VISION.md` claims are the **target
> spec**, not a status report. Do NOT soften them. **No release** until reality meets them.

## Type

**NO-CODE. Max 2 assumptions · 2 retries · 1 story · ~2h · new chat.**
No `src/` changes. No commits allowed (the GT itself is the deliverable). Record findings in
`sessions/session-120-ground-truth.md` only.

## Why this session

S120 is mandatory (`120 % 5 == 0`). Three prior sessions since the last GT (S115):
- S116: Plan Advisor role built (no-code-change path)
- S117: Plan Advisor dispatch proven by name (no `src/` change)
- S118: Paid dogfood on chitra — root cause = grep-only verify suites + no clean-room execution
- S119: Clean-room runner — QA + Demo-er route through `git worktree add --detach`

**The audit has two sharpened lenses this session:**

1. **Grep-only-verify sweep.** S118 and S119 both named the same class of hollow verify: a check
   that greps source strings instead of exercising the product. S118 found it in `verify-session-11.sh`
   (11 checks, ALL GREEN over a broken build). S119 repeated it in `verify-session-119.sh` (the
   `run-location-printed-in-output` check). **Sweep all historical `verify-session-NN.sh` scripts
   and catalogue every grep-over-source check.** Report a count and a ranked list (most hollow first).

2. **Pipeline-advance counter.** Does the clean-room runner (S119) change the `vajra next --stations`
   output? Does the pipeline-advance picture match ROADMAP/VISION claims?

## Goal

Run all required GT audits. Produce a PARTIAL/PASS verdict with an honest account of what is and
is not true. Surface findings so S121 can act on the most load-bearing ones.

## Plan

1. **Vision audit:** re-read `VISION.md`. Does every claim in the vision have a corresponding
   implemented feature? Mark gaps with `[GAP]` and estimates. `covers: 1`
2. **Roadmap drift audit:** re-read `ROADMAP.md` "Where We Are" table. Are the session verdicts,
   dates, and capability claims consistent with the actual code and session summaries? `covers: 2`
3. **State/Knowledge consistency:** are `STATE.md` and `KNOWLEDGE.md` internally consistent? Do
   they agree with the code (spot-check 3 claims each)? `covers: 3`
4. **Constitution audit:** re-read `AGENTS.md`. Are any rules stale or contradicted by actual
   practice (e.g. session close steps that are systematically skipped)? `covers: 4`
5. **Cost audit:** report cumulative authoritative spend. Is the cost tracking in `STATE.md`
   accurate? Cross-check against session summaries. `covers: 5`
6. **Dogfood staleness:** run `vajra next --dogfood-age`. Report the result. Is the staleness
   acceptable given S118? `covers: 6`
7. **Pipeline-advance counter:** run `vajra next --stations 119`. Report K-of-8. Does S119's
   clean-room runner appear in the evidence? Does the counter match ROADMAP/VISION claims? `covers: 7`
8. **Grep-only-verify sweep:** read every `scripts/verify-session-NN.sh` in this repo. For each:
   count lines that grep source strings vs. lines that execute the product. Produce a ranked table
   (most hollow first). `covers: 8`
9. **Summary + finder pick:** write `sessions/session-120-ground-truth.md` with all findings,
   a PASS/PARTIAL/FAIL verdict per lens, and three options A/B/C for S121 ranked by impact. `covers: 9`

## Acceptance criteria

1. Vision audit complete: every vision claim marked IMPLEMENTED / PARTIAL / GAP.
2. Roadmap drift audit complete: session table entries verified against code and summaries.
3. State/Knowledge spot-check: 3 claims each, marked CORRECT / STALE.
4. Constitution audit: stale or contradicted rules listed with evidence.
5. Cost audit: cumulative spend number computed and verified.
6. Dogfood staleness: `vajra next --dogfood-age` run and result reported.
7. Pipeline-advance counter: `vajra next --stations 119` run and result reported.
8. Grep-only-verify sweep: all historical verify scripts catalogued; hollow checks ranked.
9. `sessions/session-120-ground-truth.md` written, verdict PASS/PARTIAL/FAIL per lens, options
   A/B/C for S121.

## Execution (the Coder gate — NO-CODE so no commits; record only findings)

*No execution shas — this session produces no code.*

## Design

- design-significant: **no** — NO-CODE GT. No `src/` changes.

## Non-goals

- No code changes, no commits, no `src/` edits.
- No release, no crates.io action (founder directive).
- No `verify-session-120.sh` (GT sessions are exempt per `CONSTRAINTS.yaml`
  `ground_truth_commit_exempt_branch_suffixes`).

## Guardrails

- **NO-CODE.** Any temptation to fix a finding in-session is a violation — record it, don't fix it.
- Run `vajra next --stations 119` as-is; do not modify the binary to game the output.
- The grep-only-verify sweep must count each check individually — do not declare a script "clean"
  because it has some execute-based checks while also having grep-over-source checks.
- **Attest LAST** (not applicable — NO-CODE, no review-inputs-sha required).
