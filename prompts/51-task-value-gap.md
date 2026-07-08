# Session 51 — Measure the value gap on a REAL repo (chitra), PAID · direction B, CODE/VERIFY

> **Founder pick at S50 GT close (A), sharpened at S50 close:** the standing #1 is **work-quality is
> UNMEASURED**. S48 obedience + S49 baseline measure only obedience to the RAILS (a floor). S51 takes the
> first real reading of what direction B actually promises — **does the AI do BETTER WORK through Vajra?** —
> **on a real, already-Vajra-wired project (`/Users/suman/playground/chitra`)**, so the test task is
> *genuinely useful* (chitra moves forward) instead of a throwaway. A paid run also **refreshes the aging
> `dogfood_check`** (last live fire = S46) in the same spend.

## Why this session
- S50 GT verdict: paper moat intact, **live moat aging** — no paid `vajra claude` run since S46 (S47/S48/S49
  all ~$0). `dogfood_check` = **🟡 measured-then-aging.**
- The work-quality thesis of direction B has **never been measured by a number.** Obedience is a floor, not
  proof the output was better. This is the harder, truer measurement (the S49-B carry).
- **Founder upgrade:** run it on **chitra** — a real user of Vajra — so (a) the test is a real dogfood on a
  real repo, and (b) whatever we build is *useful*, advancing chitra's own roadmap. Triple-duty: value-gap
  reading + live moat refresh + real chitra progress.

## The test bed — `/Users/suman/playground/chitra`
- Real pnpm monorepo, package `@chitra/core` — a zero-dep, AI-first **terminal chart library**
  ("the best terminal chart lib ever created"). **Vajra already installed** (`.ai/`, `.claude/`, hooks).
- **chitra runs its OWN Vajra workflow** — own `.ai/SESSION` (~S04), own `prompts/`/`sessions/`, own roadmap
  (milestone: *Docs & examples*; next real tasks incl. **S04 README / getting-started**). Do NOT confuse
  chitra's session numbering with Vajra's S51 — **S51 is the Vajra session that USES chitra as the subject.**

## The task (pick ONE small, real, fair chitra task — confirm scope at kickoff)
Lead candidate: **chitra's own next task** (e.g. S04 README/getting-started, or a small `@chitra/core` slice) —
something real on chitra's roadmap that fits the ~2h + 1-story cap. Declare the **rubric before running**:
1. **Correctness** — does the output actually work? (build / `gen:charts:check` / tests / manual render)
2. **Corrections** — how many founder interventions / re-work rounds to get it right?
3. **Cost** — $ per arm from the receipt/ledger.

## A/B design (same task, keeps the useful output)
- **Arm A — through Vajra:** run the real task via `vajra claude` on chitra's real branch. **This is what
  chitra KEEPS** → lands as chitra's own progress (chitra's normal commit/PR, its workflow).
- **Arm B — plain control:** the **same** task via plain `claude` (no Vajra context), in a **throwaway copy /
  git worktree of chitra** → measured, then **discarded**. (Its small effort is the price of a fair control.)
- Compare A vs B on the pre-declared rubric. Single sample — say so honestly.
- **Accepted alternative (founder may choose at kickoff):** two *different* comparable real chitra tasks, one
  per arm, both kept — more useful output, noisier comparison. Default is the same-task design above.

## What counts as done (success criteria)
- `sessions/session-51-summary.md` (in the **Vajra** repo) with: the rubric, both arms' raw results, and an
  **honest verdict** — did Vajra measurably improve correctness / reduce corrections, or not (caveat: n=1)?
- **`dogfood_check` refresh recorded:** cost-ledger line for the paid run + whether the moat fired live.
- **chitra advanced for real:** Arm A's output committed in chitra's own repo/workflow (not left dangling).
- Exactly 3 ranked next candidates for S52 (title · one-sentence goal · why-pick · key risk), from ROADMAP.

## Guardrails
- **PAID** — budget cap `$5.00` warn-mode; keep the task small; log real spend to the cost ledger.
- **Two repos, two workflows:** the S51 *Vajra* session (branch `session-51-<slug>` off Vajra's `main`,
  summary + closeout) is tracked in `/Users/suman/playground/vajra`; the *useful work* lands in chitra via
  chitra's own session/branch. Keep the two repos' commits separate; ≤3 files/commit in **both**.
- Max 2 assumptions · max 2 retries · ~2h cap · 1 story · **new chat** · approval token before any commit.
- Darshan for every human reply · Varta against the live `.ai/`.
- **Do NOT re-open the enforcement arc** — the moat is the floor; this session measures work-quality (the S46
  pivot: stop polishing the guard, prove the value).

## Honest-read reminder (carry from S48/S49)
- Obedience% + baseline = the **floor** (obedience to RAILS), not work-quality. This is the first attempt at
  the work-quality number itself. n=1 is a start, not a proof — frame it that way.

## Output
- `sessions/session-51-summary.md` (the value-gap baseline + verdict + 3 S52 candidates).
- Real chitra progress landed in the chitra repo (Arm A).
