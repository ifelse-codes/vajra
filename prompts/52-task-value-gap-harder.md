# Session 52 — Value gap on a HARDER task (n=2, PAID) · direction B, CODE/VERIFY

> **Founder pick at S51 close (A):** S51's first work-quality reading was an honest **n=1 null** — no
> measurable Vajra win on a README one-shot, cost ~19% more. The likely reason: **the task was too easy to
> separate the arms** (a strong base model gets a simple, well-specified job right with or without Vajra's
> context). S52 gives the thesis a **fair test on a task where Vajra SHOULD help** — multi-step,
> convention-heavy, drift-prone — and takes the **second** reading (n=1 → n=2).

## Why this session
- S51 verdict: on a simple one-shot, Vajra's context layer added cost without measurably better output. The
  value (if any) lives in **harder, convention-heavy, multi-turn work** where captured `.ai/` context prevents
  drift + re-work. A README cannot show that; a real multi-step task can.
- Same triple-duty as S51: value-gap reading **+** live `dogfood_check` refresh **+** real chitra progress.

## The test bed — `/Users/suman/playground/chitra` (unchanged from S51)
- chitra runs its own Vajra workflow (own `.ai/SESSION`, now ~S04 with README merged). S52 is the **Vajra**
  session that USES chitra as the subject — do not confuse chitra's numbering with Vajra's S52.
- **Precondition:** confirm chitra's tree is clean before starting (S51 left `session-04-readme-getting-started`
  committed; land/close it in chitra's own workflow first if still dangling).

## The task — pick ONE real, harder chitra task (confirm scope at kickoff)
Lead candidates from **chitra's own backlog** (both genuinely multi-step + convention-heavy):
1. **Real publishable `dist/` build for `@chitra/core`** (today `build` is `tsc --noEmit`) — touches
   `package.json` exports/`files`, a real `tsc` emit config, and must not break the zero-dep / public-API
   guarantees. Convention-heavy → Vajra's captured constraints (zero-dep, `toPlain()/toJSON()` stability, 116
   tests green) are exactly the kind of context that could prevent drift.
2. **CI workflows** the README references but that don't exist (`.github/workflows/*`) — must match the repo's
   real verify/demo scripts + pnpm workspace layout.

Prefer #1 (richer correctness surface). Declare the **rubric before running** — and make it able to
**distinguish** the arms (S51's rubric was passable by both):
1. **Correctness** — does it build/emit/test-green for real? (`pnpm build`/`tsc`/`vitest`/manual import of `dist`)
2. **Corrections** — founder interventions / re-work rounds to shippable.
3. **Constraint-adherence** — did the arm honor chitra's captured guardrails (zero runtime deps, public-API
   stability, keep agent-output helpers)? **This is the axis a README couldn't test** and where Vajra's `.ai/`
   context should bite.
4. **Cost** — $ per arm (authoritative `total_cost_usd`, not the vajra receipt — see S51 finding).

## A/B design (same as S51, proven)
- **Arm A — through Vajra:** `vajra claude` on chitra's real branch (full `.ai/` governance). **Kept** → lands
  as chitra's real progress.
- **Arm B — plain control:** same task via plain `claude` in a **throwaway worktree with the Vajra layer
  stripped** (`.ai/`, `.claude/`, `CLAUDE.md`, `varta/`, `darshan/`, `.githooks/` removed). **Discarded.**
- Same prompt, same tool whitelist, same cost capture. n=2 across S51+S52 — still small; say so.

## What counts as done
- `sessions/session-52-summary.md` (Vajra repo): rubric, both arms raw, **honest verdict vs the S51 null**
  (did a harder task separate them?), dogfood refresh line, chitra advanced (Arm A committed), 3 ranked S53
  candidates.
- **chitra advanced for real:** Arm A's output committed in chitra's own repo/workflow.

## Guardrails
- **PAID** — budget cap `$5.00` warn; keep the task bounded; log authoritative spend (Arm A + Arm B + probes).
- **Use `total_cost_usd`, NOT the vajra receipt** — S51 found the receipt overstates ~9× (cache miscalibration).
- Two repos, two workflows; ≤3 files/commit in **both**; max 2 assumptions · 2 retries · ~2h · 1 story · new
  chat · approval token before any commit.
- Darshan every human reply · Varta against the live `.ai/`.
- **Do NOT re-open the enforcement arc.** The moat is the floor; S52 measures work-quality on a harder task.

## Honest-read reminder
- S51 = n=1 null. S52 = n=2 and a fairer task. Still not a proof. If a harder task ALSO shows no Vajra win,
  that is a **major, honest signal** about direction B — record it plainly, do not rescue the thesis.

## Output
- `sessions/session-52-summary.md` (harder-task value gap + verdict + 3 S53 candidates).
- Real chitra progress landed in the chitra repo (Arm A).
