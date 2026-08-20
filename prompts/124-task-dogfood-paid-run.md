# Session 124 — Dogfood: does any of the last three sessions' machinery hold under real use?

> **Status:** APPROVED — founder pick, in chat, at the S123 close, SUPERSEDING the originally
> written S124 prompt (`clean-room-dispatch-evidence`). The founder's own words: this project has
> now built the same "ship it trusting → discover a hole → spend a session fencing it" arc FIVE
> times (`covers:`, `design-significant:`, the tally ×3), and S124's original plan would have been
> a sixth, self-aware repeat of exactly that pattern — *knowingly* building a guard around a fake
> instead of building the real thing. Dogfood staleness is 🟡 (5 sessions / 4 calendar days since
> S118) and every one of the last three sessions' claims (the fence, the measurement, the receipt
> plan that was never built) has been tested only against synthetic fixtures the SAME agent that
> built them also wrote. This session tests them against real use instead.

## Type

**DOGFOOD (paid).** The deliverable is **evidence**, not Vajra `src/` changes — a run happened, it
cost real money, the receipt is authoritative, the gates behaved a documented way, and the payload
landed or honestly did not. `VAJRA_CLOSEOUT_WAIVER=dogfood-no-src-changes`. Max 2 assumptions ·
2 retries · ~2h founder attention · `VAJRA_ALLOW_COMMIT=124` for every commit.

## Goal

Run `vajra claude` against `/Users/suman/playground/chitra` on one real bounded task, under a hard
~$5 budget, and specifically watch whether the S121–S123 fleet + fence machinery does anything real
— or whether it never even engages, which would itself be the honest finding.

**Why now:** `vajra claude` has not run a real governed session since **S103** and chitra since
**S118** (2026-08-15) — 5 sessions / 4 calendar days, 🟡 and climbing. Three sessions
(S121–S123) built the QA role, found real bugs with it, then fenced its write access — all of it
proven only inside throwaway repos the same agent constructed. This is the first chance to see any
of it operate on a real task chitra's own roadmap actually needs.

## Plan (ordered — cite the acceptance criteria each step covers, e.g. `covers: 1, 3`)

1. **Re-init chitra's scaffold with the current `vajra` binary first.** chitra's `.claude/agents/`
   does not exist yet (its scaffold predates the fleet, S109+) — without this, none of S121–S123's
   work is even reachable in that repo. `vajra init` is skip-if-present, so this only adds the
   missing fleet files + the `clean_room` CONSTRAINTS key; it must not touch chitra's existing
   `.ai/` state. Record the diff. `covers: 1`
2. **Record the pre-run baseline:** chitra HEAD + `git status`, `vajra next --dogfood-age`,
   `vajra next --stations 124` (run from vajra's own repo, chitra is a separate project — record
   what fleet-evidence surfaces, if any, are even reachable cross-repo), vajra binary sha256,
   `claude --version`. `covers: 2, 3`
3. Adapt the S118/S103 harness into `sessions/session-124-artifacts/run-task.sh` — guards ON
   (`VAJRA_ENFORCE_COMMIT=1`, `VAJRA_ENFORCE_PUBLISH=1`), teeing stdout/stderr for the S78
   authoritative-cost path, a **cumulative-spend gate that refuses another turn past ~$5**.
   `covers: 4, 8`
4. **The real payload:** chitra's own next roadmap item — extend the S10 reference-locked line
   language to the `bar` chart family (`packages/core/README.md`'s "LOCKED: line chart" contract is
   the reference; bar charts currently do not carry it). Bounded, single-family scope — do not also
   attempt sparkline/histogram in this run. `covers: 5, 7`
5. Launch the run. If a fleet role gets a real reason to fire (a QA pass on the resulting code is
   the obvious one), **do not steer it either way** — let the agent decide whether to use the fleet
   machinery unprompted, and record what actually happened, including "it never touched it."
   `covers: 6`
6. Capture the evidence: `run-result.json`, `receipt.stderr.txt`, the run's on-disk `run.jsonl`,
   `total_cost_usd.txt`, chitra's before/after HEAD + status, the permission-denial list, and —
   the specific new thing this session is watching for — **any `.claude/agents/*.md` dispatch,
   any `--clean-room-open`/`--clean-room-close` invocation, and any governed handoff written**
   inside chitra during the run. `covers: 6, 8`
7. Record governance obedience: which gates fired, which were bypassed and why, whether any
   unauthorized commit or push landed on chitra (`git log` on chitra `main` must be unchanged
   unless an authorized commit landed). `covers: 4`
8. Verify the payload with your own eyes, not the agent's claim: run chitra's dev server, capture a
   real screenshot of the bar chart output, and map the criterion (bar chart carries the locked
   line-chart look) to SHIPPED / PARTIAL / NOT-BUILT. `covers: 7`
9. Re-run `vajra next --dogfood-age` post-run and confirm it now shows S124. Write
   `sessions/session-124-ground-truth.md` (verdict rows) + `sessions/session-124-summary.md`
   (per-requirement fidelity map, what was not built, the fakest green — including an honest verdict
   on whether S121–S123's machinery did anything at all in a real run), then dispatch an
   independent cold `fidelity-reviewer` fed only this prompt + the diff. `covers: 2, 9`

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: 033e5e2
- step 2 — done: 70bb872
- step 3 — done: da79cdd
- step 4 — done: a601cb9
- step 5 — done: b38d292
- step 6 — done: 77f07f8
- step 7 — done: 0d61702
- step 8 — done: 77f07f8
- step 9 — done: 3d60e85

**Record a real commit sha for every step.** Prose in place of a sha breaks `git cat-file` and goes
Coder-dark (the S119 defect, hit again at S122 until corrected).

## Design

- design-significant: **no** — no new interface, no new module, no Vajra `src/` change. This
  session exercises the shipped launcher + fleet end-to-end and measures it. If the run exposes a
  real defect (in Vajra, or in the S121–S123 fence specifically), it is **disclosed, not fixed
  here** — a fix is its own CODE session with its own record.

## Non-goals (not built this session)

- No Vajra `src/` changes, no new commands (7 stands), no crates.io action.
- **Not the clean-room dispatch-evidence gap** (the original S124 plan, superseded). It stays a
  real, named backlog item — but it is not this session's job.
- **Not making the check-class label EARNED** (S124 option A from the S123 close). Standing
  backlog, still not picked.
- Not steering the agent toward or away from using the fleet — the whole point is an honest
  observation of whether it reaches for that machinery unprompted.
- Not pushing chitra or opening chitra's PR: the run stops with chitra's branch **local**, for the
  founder to review in a browser first (same as S118).

## Acceptance criteria

1. chitra's scaffold carries the fleet (`.claude/agents/*.md`, the `clean_room` CONSTRAINTS key)
   before the run launches, added non-destructively (skip-if-present, chitra's own `.ai/` state
   unchanged except for the new files).
2. `vajra next --dogfood-age` recorded pre- and post-run; post-run shows **S124** as most recent.
3. Pre-run baseline recorded: chitra HEAD/status, vajra binary sha256, `claude --version`.
4. Guards were ON for the run (`VAJRA_ENFORCE_COMMIT=1 VAJRA_ENFORCE_PUBLISH=1`); the budget cap is
   real (mechanism in the committed harness, actual cumulative spend recorded to the cent, capped
   at ~$5); chitra's `main` carries zero unauthorized commits.
5. The bar-chart payload attempt is real work against chitra's own actual next roadmap item, not a
   synthetic or trivial task chosen to make the fence machinery look busy.
6. **Reported honestly, either way:** did the agent dispatch any fleet role during the run? Did it
   use `--clean-room-open`/`--clean-room-close`? Did a governed handoff get written? If none of
   this happened, that is a valid and important finding, not a session failure — say so plainly.
7. The bar-chart payload outcome mapped SHIPPED / PARTIAL / NOT-BUILT, backed by a real screenshot,
   never by the launched agent's self-report.
8. `sessions/session-124-artifacts/` holds and commits: `run-result.json`, `receipt.stderr.txt`,
   the run's `run.jsonl`, `total_cost_usd.txt`, chitra's before/after git state, and (if any
   occurred) the fleet-dispatch/clean-room evidence named in step 6.
9. `sessions/session-124-ground-truth.md` + `sessions/session-124-summary.md` exist, the summary
   carries the per-requirement fidelity map and names the fakest green, and an independent cold
   `fidelity-reviewer` pass lands at `sessions/session-124-review.md`.

## Guardrails

- **Guards ON for every turn:** `VAJRA_ENFORCE_COMMIT=1 VAJRA_ENFORCE_PUBLISH=1`.
- **Budget is a hard stop, not a hope.** Check cumulative `total_cost_usd` after every turn; do not
  launch another turn at or above ~$5. Report actual spend to the cent.
- **Never accept the launched agent's own grade, and never accept a fleet role's own report as
  proof it ran the way S123 designed it to** — that is exactly the class of claim this project has
  gotten burned on repeatedly. If a governed handoff exists, check it against real evidence.
- **No `--no-verify`, no force push, no chitra `main` commits without the authorized marker.**
  Attest LAST: recompute `Review-Inputs-SHA` only after this prompt's Execution shas are committed,
  and confirm two consecutive `verify-closeout.sh --inputs-sha 124` runs agree.

## Delta (vs ROADMAP — OpenSpec markers)

- **ADDED:** the first real-use test of the S121–S123 fleet + fence machinery; chitra's scaffold
  catches up to the current fleet.
- **MODIFIED:** the 🟡 dogfood-staleness indicator — retired if this run lands.
- **UNCHANGED:** the 8 stations, the 7 commands, all Vajra product surfaces.
