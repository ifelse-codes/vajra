# Session 118 — Dogfood: the overdue paid `vajra claude` run (target: chitra S11)

> **Status:** APPROVED — founder pick A at the S117 closeout, held pending chitra's working tree
> being clean. Founder gave the explicit go-ahead in chat on 2026-08-15; chitra is clean on `main`
> at `e4ec619` (S10 merged). Founder also chose the run mode (**Sonnet 5, headless `-p`, ~$5 cap**)
> and the payload scope (**catalog page + real in-browser re-run**).

## Type

**DOGFOOD (paid).** The deliverable is **evidence**, not Vajra `src/` changes — a run happened, it
cost real money, the receipt is authoritative, the gates behaved a documented way, and the payload
landed or honestly did not. `VAJRA_CLOSEOUT_WAIVER=dogfood-no-src-changes`. Max 2 assumptions ·
2 retries · ~2h founder attention · `VAJRA_ALLOW_COMMIT=118` for every commit.

## Goal

Run `vajra claude` headless against `/Users/suman/playground/chitra` on one real bounded task —
**chitra S11: the two-panel terminal catalog page** (full brief:
`sessions/session-118-artifacts/prompts/chitra-s11-brief.md`) — under a hard ~$5 budget, capture the
authoritative receipt plus the station / dogfood-age / obedience evidence, and report the result
honestly.

**Why now:** `vajra claude` has not run a real governed session since **S103 (2026-07-30)** — 14
sessions / 16 calendar days, 🔴 in three consecutive ground truths, deferred by explicit founder
choice at S115, S116 and S117. This is the single highest-leverage undone item on the board.

## Plan (ordered — cite the acceptance criteria each step covers, e.g. `covers: 1, 3`)

1. Record the pre-run baseline: chitra HEAD + `git status`, the on-disk JSONL listing, `vajra next
   --dogfood-age`, `vajra next --stations 118`, vajra binary sha256, `claude --version`. `covers: 3, 4`
2. Adapt the S103 harness into `sessions/session-118-artifacts/run-task.sh` — guards ON
   (`VAJRA_ENFORCE_COMMIT=1`, `VAJRA_ENFORCE_PUBLISH=1`), model `sonnet`, `--output-format json`,
   teeing stdout to `run-result.json` and stderr to `receipt.stderr.txt` (the S78 authoritative-cost
   path), plus a **cumulative-spend gate that refuses to launch another turn once the ~$5 cap is
   reached**. `covers: 1, 2, 6`
3. Launch the run against chitra with the S11 brief. If the payload is unfinished and cumulative
   spend is still under cap, continue with a bounded follow-up turn; stop at the cap regardless of
   completeness. `covers: 1, 6, 7`
4. Capture the evidence: `run-result.json`, `receipt.stderr.txt`, the run's on-disk `run.jsonl`,
   `total_cost_usd.txt`, `verdict.txt`, chitra's before/after HEAD + status, and the
   permission-denial list from the result stream. `covers: 2, 5`
5. Record the governance-obedience log: which Vajra gates fired, which were bypassed and why, and
   whether any unauthorized commit or push landed on chitra (`git log` on chitra `main` must be
   unchanged). `covers: 5`
6. Verify the payload with my own eyes, not the agent's claim: run the docs dev server and capture a
   real browser screenshot of the two-panel page, then map each chitra-S11 criterion to
   SHIPPED / PARTIAL / NOT-BUILT. `covers: 7`
7. Re-run `vajra next --stations 118` and `vajra next --dogfood-age` post-run and record both.
   `covers: 3, 4`
8. Write `sessions/session-118-ground-truth.md` (verdict rows) + `sessions/session-118-summary.md`
   (per-requirement fidelity map, what was not built, the fakest green), then dispatch an
   independent cold `fidelity-reviewer` fed only this prompt + the diff. `covers: 8`

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done:
- step 2 — done:
- step 3 — done:
- step 4 — done:
- step 5 — done:
- step 6 — done:
- step 7 — done:
- step 8 — done:

## Design

- design-significant: **no** — no new interface, no new module, no Vajra `src/` change. This session
  exercises the shipped launcher end-to-end and measures it. The run harness is a session artifact
  under `sessions/session-118-artifacts/`, adapted from the S103 harness of the same shape, not a
  product surface. If a run exposes a real launcher defect, it is **disclosed, not fixed here** —
  a fix is its own CODE session with its own record.

## Non-goals (not built this session)

- No Vajra `src/` changes, no new commands (7 stands), no crates.io action.
- Not fixing the known Planner-gate double-count bug (`task_2162b487`) — that is S119.
- Not pushing chitra or opening chitra's PR: the run stops with chitra's branch **local**, for the
  founder to review in a browser first.
- Not proving unattended `claude -p` fleet dispatch — still deferred (DECISION-007).

## Acceptance criteria

1. `vajra claude` ran at least one real paid turn against chitra, with a non-zero **authoritative**
   `total_cost_usd` in `run-result.json` (the S78 tee path) — not a token estimate.
2. `sessions/session-118-artifacts/` holds and commits: `run-result.json`, `receipt.stderr.txt`,
   the run's `run.jsonl`, `total_cost_usd.txt`, `verdict.txt`, and the before/after chitra git state.
3. `vajra next --stations 118` output recorded (pre-run baseline and post-run).
4. `vajra next --dogfood-age` recorded post-run and shows **S118** as the most recent dogfood.
5. Governance obedience documented: which gates fired, which were bypassed and why; chitra's `main`
   carries **zero** unauthorized commits and nothing was pushed.
6. The **budget cap was real**: the mechanism is in the committed harness, the threshold (~$5) is
   documented, and the actual cumulative spend is recorded — under cap, or over with the reason.
7. The chitra S11 payload outcome is reported honestly: every numbered criterion in the brief mapped
   SHIPPED / PARTIAL / NOT-BUILT, backed by **my own** verification (a real browser screenshot of the
   rendered page), never by the launched agent's self-report.
8. `sessions/session-118-ground-truth.md` + `sessions/session-118-summary.md` exist, the summary
   carries the per-requirement fidelity map and names the fakest green, and an independent cold
   `fidelity-reviewer` pass lands at `sessions/session-118-review.md`.

## Guardrails

- **Guards ON for every turn:** `VAJRA_ENFORCE_COMMIT=1 VAJRA_ENFORCE_PUBLISH=1`. Claude Code's own
  permission layer is bypassed for the unattended run **on purpose** — the interesting question is
  whether Vajra's gates hold when the host's do not (S103 shape). Record the answer either way.
- **Budget is a hard stop, not a hope.** Check cumulative `total_cost_usd` after every turn; do not
  launch another turn at or above ~$5. Report actual spend to the cent.
- **Never accept the launched agent's own grade.** Its summary is an input, not evidence.
- **No `--no-verify`, no force push, no chitra `main` commits.** Attest LAST: recompute
  `Review-Inputs-SHA` only after this prompt's Execution shas are committed, and confirm two
  consecutive `verify-closeout.sh --inputs-sha 118` runs agree.

## Delta (vs ROADMAP — OpenSpec markers)

- **ADDED:** the first paid governed dogfood since S103; the fleet-era launcher's first real run.
- **MODIFIED:** the 🔴 dogfood-staleness indicator — retired if this run lands.
- **UNCHANGED:** the 8 stations, the 7 commands, the 3 fleet roles, all product surfaces.
