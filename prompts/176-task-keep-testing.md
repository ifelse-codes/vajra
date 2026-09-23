# Session 176 — rudra session 07 with S175's fixes in

> **Status:** APPROVED — founder picked candidate A (test on rudra) at the S176 start, 2026-09-23,
> same rudra test as S172–S175.

## Type
- **CODE**, interactive. He runs rudra's session 07 for real under `vajra claude`; findings are
  COLLECTED during the run and fixed together after it closes (his rule since S173). Full close.
- **Not a ground-truth session.** `.ai/CONSTRAINTS.yaml#ground_truth_next_session: 180` — 176 is a
  plain CODE session (S175's own fix, first real use of it after itself).

## Before he starts — read this carefully, two of S175's fixes are BINARY-EMBEDDED
1. `cargo install --path /Users/suman/playground/vajra` — **not yet done for S175's fixes.**
   `scripts/hook-publish-guard.sh` and `scripts/hook-session-start.sh` are embedded into the `vajra`
   binary at build time (`include_str!` in `src/cli/init.rs`) and only reach rudra through a rebuild
   + resync — unlike `hook-pre-bash.sh`/`hook-pre-write.sh`/`hook-prompt-submit.sh`/`hook-stop.sh`/
   `verify-closeout.sh`, which are NOT scaffolded at all (Vajra-repo-only, per the S175 addendum).
   **Skipping this step means the F65 merge fix is not in rudra** — the exact bug from S175 would
   still be live there.
2. `cd ~/playground/rudra && vajra init --sync-fleet` — carries the rebuilt `hook-publish-guard.sh`
   (merge exclusion) and `hook-session-start.sh` (cadence config read, though rudra has no reason to
   set `ground_truth_next_session` itself) into rudra. Commit whatever it changes FIRST, never revert
   (F60's own rule, holding since S174).
3. Launch: **`VAJRA_ALLOW_COMMIT=07 vajra claude`.** Founder's call last session: merge stays strictly
   hand-typed — do **not** add `VAJRA_ALLOW_PUBLISH=1` unless you want the agent to push/open a PR
   too (it still cannot merge, by design, after S175).

## What this run should exercise for the first time
- **The F65 fix, live:** does `gh pr merge` still get blocked even with `VAJRA_ALLOW_PUBLISH=1` set,
  if he sets it again? (Optional — only if he wants to re-test it; not required for this run.)
- **F58, F61/F63:** two sessions running with no block firing to retry from. If one fires this time,
  does it cost one try, and does the PR block name `--body-file` correctly?
- **The `cwd`/worktree push assumption:** still never tested live, six sessions running. Not forced
  this session either — a real worktree use would settle it if one happens naturally.
- **F66 (watched, not fixed):** does a same-morning fixup PR happen again (a required handoff left
  uncommitted at close), or did S06's founder-observed gap not recur?
- **F31 a seventh time** — tech-lead dispatched first.

## Carried in
1. **S175 design-advisor, 3 recs, carried to S180** (not S176 — they're a ground-truth-scale audit
   question, not a build task): shared-lib extraction trigger for the 6-copy `ground_truth_next_session`
   pattern; the post-S180 dead-cadence trip-wire; `verify-closeout-scaffold.sh`'s drift ownership.
   `prompts/180-task-ground-truth.md`.
2. **F47, F56, F57** (LOW, parked) · **F50** (not fixed in code, S173 decision) · **F64** (watch: an
   advice answer switched from `deferred:`/`refused:` to `obeyed:` to pass the check).
3. **F66** (S175, disclosed, not fixed): `--check-crew` checks disk-presence, never git-tracked-ness.
   Still needs the founder's explicit yes before it becomes a session (Guardrails, unchanged).

## Findings (filled in live)
| # | Step | What happened | Severity |
|---|---|---|---|
| _ | _ | _ | _ |

## Goal
1. _From the founder's run._

## Deliverables
1. _From the founder's run, plus whatever the carried items resolve to._

## Acceptance
1. _Each item something he can check himself._

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
- **Merge stays strictly hand-typed** (founder, 2026-09-23, S175): no `VAJRA_ALLOW_MERGE`-style
  switch exists or should be built without his explicit ask.

## Delta
- `+` whatever rudra session 07 surfaces
- `~` S175's two fixes (GT cadence config, merge-exclusion) meet a real run for the first time
- `~` F31 watched a seventh time
- `-` nothing removed
