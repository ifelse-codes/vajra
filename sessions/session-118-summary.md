# Session 118 Summary — Dogfood: the overdue paid `vajra claude` run (chitra S11)

**Branch:** `session-118-dogfood-chitra-catalog` · **Type:** DOGFOOD (paid) · **Date:** 2026-08-15
**Spend:** **$4.0911771** authoritative, cumulative $4.0912 against a $5 cap · **Run time:** 1331s

## Goal achieved?

**Yes — and it found something.** `vajra claude` ran a real governed session on chitra for
the first time since S103 (14 sessions / 16 days). The payload — chitra S11, the two-panel
terminal catalog page — was delivered by the run, graded green by the run, and was **broken
on 19 of its 20 pages.** The operator found this by clicking every chart in a browser, then
repaired it and closed the hollow check that let it pass.

## Fidelity map — every numbered criterion in `prompts/118-task-dogfood-paid-run.md`

| # | Criterion | Status | Evidence |
|---|---|---|---|
| 1 | ≥1 real paid turn, non-zero authoritative `total_cost_usd` | **SHIPPED** | `p1/run-result.json` → `$4.0911771`; `p1/total_cost_usd.txt` |
| 2 | artifacts committed (result, receipt, jsonl, cost, verdict, git state) | **SHIPPED** | `sessions/session-118-artifacts/p1/` — 17 files, six atomic commits |
| 3 | `vajra next --stations 118` recorded pre- and post-run | **SHIPPED** | `pre-run-baseline.txt` (3 of 8) · `post-run-evidence.txt` (2 of 8) |
| 4 | `vajra next --dogfood-age` post-run shows S118 | **PARTIAL** | recorded, but still reports S103 until `.ai/SESSION` is bumped at closeout; the post-closeout re-read is the real proof |
| 5 | obedience documented; zero unauthorized commits; nothing pushed | **SHIPPED** | `obedience-log.md`; chitra `main` = `e4ec619` before and after; branch unpushed |
| 6 | budget cap real, threshold documented, actual spend recorded | **PARTIAL** | mechanism committed and threshold documented, but **never triggered** — the refusal path is untested code |
| 7 | payload outcome verified by my own eyes, not the agent's report | **SHIPPED** | `browser-verification.md` — 20 pages clicked, 1 Ready / 19 Error, then 20/20 after repair |
| 8 | ground-truth + summary + independent cold fidelity review | **SHIPPED** | `session-118-ground-truth.md`, this file, `session-118-review.md` |

## What I did NOT build

- **The budget gate's refusal path was never exercised.** The run finished at $4.09, under
  the $5 cap, so the branch that refuses to launch a stage has never executed. It is code
  I wrote and did not test.
- **No second stage.** The plan allowed a bounded follow-up turn; the payload came back
  "complete" (falsely), so no second stage ran. The repair was done by hand instead.
- **No Vajra `src/` fix for the finding.** The QA station still accepts a grep-only verify
  suite. Named in the ground truth as the S119 candidate; deliberately not fixed here.
- **The chitra branch is unpushed and has no PR**, by instruction.

## The fakest green

**Criterion 7 — "verified with my own eyes" — is the only reason this session is not a
green report over a broken payload**, and it is fakest in a specific way: it depended on me
choosing to click all 20 charts rather than the 1 that the agent's own screenshot would
have shown. Nothing in the criterion said *all 20*. Had I clicked "Line Chart", seen it
render, and moved on, every artifact in this session would look identical and be wrong.

Second: **stations went 3 of 8 → 2 of 8** across the session. I recorded it honestly, but
the counter measured nothing about whether the session was going well — Releaser flipped
ABSENT simply because a session branch now exists. The payload counter does not count
payload quality.

## The finding

Six governance gates fired during this run — against an agent whose host permission layer
was switched off, and against me. `main` was never touched. Nothing was pushed. Every
commit carried its authorization marker.

**And none of that noticed that the delivered page did not work.** chitra's verify script
was 14/14 ALL GREEN because all 11 of its catalog checks were greps for source strings.
The run's own cold fidelity review passed it. This is [[vajra-fidelity-over-discipline]]
reproduced on a paid run, one pipeline generation later.

## Repair (operator work, not the run's)

`6fa1d67` fixed three real defects — a brace misplaced in the option injector
(`missing ) after argument list` on 19 charts), a `return ( … )` wrapper that could not
hold multi-statement examples (`Unexpected token ';'` on sparkline), and a chained-regex
highlighter that printed its own markup as buffer text. `fd8a5fd` added
`check-catalog-examples.ts`, which **executes** all 20 examples, all 3 renderers, and a
deliberately broken buffer. Reintroducing the brace defect drops it from 24/24 to **5/24**,
so the check is falsifiable. chitra's verify is now 15/15 with one check that is not a grep.

## Next options (A/B/C)

**A — Teach the QA station to smell a grep-only verify suite.**
Goal: `vajra next --check-qa NN` flags a verify script whose checks are all `grep`/`test -f`
over source, so a suite that cannot fail on a broken build is visible at close.
Why: this session's exact failure, and it generalizes to every repo Vajra governs.
Risk: heuristic; a legitimate structural check could be flagged, and the flag is advisory.

**B — Give the fidelity reviewer the running artifact.**
Goal: extend the reviewer handoff so a UI/CLI deliverable ships with captured *output*
(screenshots, rendered text) alongside the diff, and the reviewer must cite it.
Why: prompt + diff could never have caught a page that does not render.
Risk: capture is repo-specific; risks becoming a manual step nobody performs.

**C — S119 as already planned (Planner-gate bug + opt-in blocking fleet gate).**
Goal: fix `is_acceptance_heading` double-counting (`task_2162b487`) and wire fleet handoffs
into a gate that can block.
Why: both are queued, small, and contained.
Risk: neither touches the finding this paid run just produced.

**My call: A.** This run cost $4.09 to discover that a green verify suite proved nothing,
and A is the smallest change that makes that condition visible at close in any repo.
