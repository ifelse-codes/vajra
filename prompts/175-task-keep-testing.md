# Session 175 — rudra session 06 with S174's fixes in

> **Status:** APPROVED — founder, 2026-09-22: "session 175 is the same rudra test, and keep going —
> no review-only session until 180."

## Type
- **CODE**, interactive. He runs rudra's session 06 for real under `vajra claude`; findings are
  COLLECTED during the run and fixed together after it closes (his rule since S173). Full close.
- **Not a ground-truth session.** The founder moved the next review-only session to **S180**.

## Before he starts
1. `cargo install --path /Users/suman/playground/vajra` (S174's fixes) — done 2026-09-22.
2. `cd ~/playground/rudra && vajra init --sync-fleet` — done; **4 Vajra files are waiting to be
   committed there. Never revert them**; S06's agent should commit them first.
3. `VAJRA_ALLOW_COMMIT=06 vajra claude`.

## Deliverable 0 — the cadence the founder just changed (do this first, before his run)
`N % 5 == 0` is hardcoded in `scripts/hook-session-start.sh` (the boot reminder) and
`scripts/verify-closeout.sh` (`is_code_session`, and the "no session scripts expected" branch), while
`.ai/CONSTRAINTS.yaml` already carries `ground_truth_every_n_sessions: 5` that nothing reads. So
today S175 announces itself as ground truth and its close QUIETLY SKIPS the CODE checks — weaker
exactly where we want them.
- Make both scripts read the next ground-truth session from `.ai/CONSTRAINTS.yaml`
  (e.g. `ground_truth_next_session: 180`), defaulting to today's every-5th rule when the key is
  absent, so other projects are unchanged.
- Record the founder's decision (DECISION-00N addendum): the every-5th cadence is a default, and he
  moved the next one to S180.
- A session that is NOT ground truth must get the full CODE close checks.

## What this run should exercise for the first time
- **F58:** when the agent's PR command is blocked once, does the new message get it through on the
  retry (`--body-file`), or does it still hand the PR back?
- **F59/F62:** does boot say "session 05 is merged — session 06 starts here"? How many times does the
  agent re-run `vajra next --steps` during the session (0 is the finding)?
- **F60:** does it commit the 4 waiting Vajra files first, and never suggest reverting them?
- **F61/F63:** do the two commit blocks now cost one try instead of three?
- **F48/F53/F54:** S07's prompt written before the merge; the review stamped ONCE; `## Advice` right
  the first time.
- **The `cwd` assumption** (still never tested live): `cd` into a worktree, try `git push` — it must
  go to the human.
- **F31 a sixth time** — tech-lead first.

## Carried in
1. **S174 review, deferred:** rec 2 — boot does not name synced role files (`.claude/agents/*.md`,
   stamp inside the header) as Vajra's update; rec 6 — build the verify's expected set from
   everything the sync changed; rec 7 — also name untracked files a sync adds.
2. **F64 (watch):** an advice answer switched from `deferred:` to `obeyed:` to pass the check —
   compare each `obeyed:` sha against what its rec actually asked.
3. **F47, F56, F57** (LOW, parked) · **F50** (not fixed in code, by the S173 decision).

## Findings (filled in live)
| # | Step | What happened | Severity |
|---|---|---|---|
| _ | _ | _ | _ |

## Goal
1. Deliverable 0 above.
2. _From the founder's run._

## Deliverables
1. The ground-truth cadence reads from config; next one is S180; a non-GT session gets the full CODE
   close checks.
2. _From the founder's run, plus the carried items._

## Acceptance
1. With `ground_truth_next_session: 180`, boot on a `session-175-*` branch does NOT announce ground
   truth, and `verify-closeout.sh` treats S175 as a CODE session (verify + demo scripts required).
2. With the key absent, every 5th session behaves exactly as it does today (a listed set of session
   numbers, old script vs new, same verdict).
3. _Each item something he can check himself._

## Design
- design-significant: <yes|no — decided from the findings>

## Plan
1. <filled in from the findings>

## Guardrails
- No new gate on Vajra's own paperwork. A gate on the HANDOVER to the human needs his explicit yes.
- Findings are collected during his run and fixed after it closes; small commits, each fix shown.
- Anything not fixed goes in the findings table with a severity, never dropped.
- Guard/check changes: compare old vs new on a listed set before claiming "no regression" (S173);
  changes may only ADD (S173 permanent lesson).

## Delta
- `+` the ground-truth cadence becomes config, next one S180 (founder, 2026-09-22)
- `+` whatever rudra session 06 surfaces
- `~` S174's six fixes meet a real run for the first time
- `~` F31 watched a sixth time; the `cwd` check finally exercised
- `-` nothing removed
