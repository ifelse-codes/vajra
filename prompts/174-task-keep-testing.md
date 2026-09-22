# Session 174 — rudra session 05 with S173's fixes in

> **Status:** DRAFT — drafted at the S173 close from the summary's recommended candidate 1. The founder has not picked yet; if he picks 2 (the 0.2.0 release) or 3 (cut the close's paperwork), this file is rewritten from that pick. The findings fill in the Goal and Acceptance from his run, as in S171–S173.

## Type
- **CODE**, interactive. He runs rudra's session 05 (async directive/generation monitors) for real
  under `vajra claude`; findings are COLLECTED during the run and fixed together after it closes
  (his S173 rule). Full close at the end.

## Before he starts
1. `cargo install --path /Users/suman/playground/vajra` — the installed `vajra` predates S173.
2. `cd ~/playground/rudra && vajra init --sync-fleet` — carries S173's three hook fixes in; the sync
   now says the files are Vajra's, to commit with session 05's first commit (F49).
3. Launch with the approval so the agent can ship its own branch (F55):
   `VAJRA_ALLOW_COMMIT=05 vajra claude`.

## What this run should exercise for the first time
- **F55 for real:** does the agent push `session-05-…` and open its PR itself, with the PR body
  from `--body-file`? Does anything it tries fall back to him that should not, or get through that
  should not?
- **F53/F54:** does the close answer every advisor rec in the right format the first time, and
  stamp the review LAST — once?
- **F50 (not fixed in code):** when a commit message mentions a Vajra command, does the block's
  `git commit -F <file>` hint get the agent through in one try?
- **The `cwd` assumption (S173 pass 6 rec 5):** the push permission reads the hook input's `cwd`.
  Check live that it follows the agent's `cd` — `cd` into a worktree, try `git push`, it must go to
  the human.
- **F51/F52:** the advance after merged S04 — one counted line per check, no fake question.
- **F48:** is S06's plan written before S05 merges, in the same chat?

## Carried in
1. **F47 (LOW, parked):** options copied from a summary keep their jargon.
2. **F56 (LOW, parked):** the session guard cannot tell a command runs in another project.
3. **F57 (LOW, parked):** the Coder check reads only `1. …` plan steps; this repo writes
   `- step N — …`, so the check passes with nothing to check. A loophole in Vajra's own paperwork —
   parked under the founder's "no more policing" rule unless he says otherwise.
4. **Watch F31 a fifth time** — tech-lead first.

## Findings (filled in live)
| # | Step | What happened | Severity |
|---|---|---|---|
| _ | _ | _ | _ |

## Goal
1. _From the founder's run._

## Deliverables
1. _From the founder's run, plus the carried items above._

## Acceptance
1. _Each item something he can check himself._

## Design
- design-significant: <yes|no — decided from the findings>

## Plan
1. <filled in from the findings>

## Guardrails
- No new gate on Vajra's own paperwork. A gate on the HANDOVER to the human needs his explicit yes.
- Findings are collected during his run and fixed after it closes; show each fix, small commits.
- Anything not fixed goes in the findings table with a severity, never dropped.
- A branch NOT named `session-NN-…` is ungoverned ad-hoc work by design (DECISION-007) — do not
  "fix" it.
- Guard changes: compare the old rule with the new on a listed set before claiming "no
  regression" (S173 took five review passes to learn this).

## Delta
- `+` whatever the founder's rudra session 05 surfaces
- `~` F55 (the agent ships its own branch) meets a real run for the first time
- `~` F31 watched a fifth time
- `-` nothing removed
