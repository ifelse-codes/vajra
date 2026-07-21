# Session 87 — Fill S76's unfilled Execution `<sha>` placeholders (CODE, docs-only)

> **Status:** APPROVED (founder pick at S86 close, from 3 ranked candidates).
> **Type:** CODE per the session-numbering convention, but the change itself is docs-only — one
> file (`prompts/76-task-dogfood-ride-along.md`), no `src/` edit, no new command, no new
> CONSTRAINTS.yaml key.

## Goal

`prompts/76-task-dogfood-ride-along.md`'s `## Execution` section still reads:

```
- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
- step 4 — done: <sha>
```

S76 predates S81's closeout-gate hardening (`check_execution_shas` / `coder::exec_gate`, which now
BLOCKS an unfilled `<sha>` placeholder) — S76 itself shipped and merged before that gate existed,
so it was never caught. First flagged as a true positive at S81 (`sessions/session-81-review.md`),
carried disclosed-not-fixed since, now **9 sessions overdue** (S81→S86). Ranked 🥈 at both the S85
GT and this S86 close; picked now because it's the oldest standing debt and a pure record-keeping
fix (no live exploit surface — contrast S86, which WAS a live exploit surface and was rightly
picked ahead of this for 5 sessions running).

## Why this session

Oldest disclosed debt in the repo. Low risk, low effort, closes a `verify-closeout.sh` gap: running
`check_execution_shas` against session 76 today would BLOCK on these exact placeholders if S76's PR
were still open — it isn't (merged long ago), so this is pure retroactive record hygiene, not an
active gate failure. Fixing it removes the last standing `<sha>` placeholder in the repo's history.

## Investigation starting point (not a conclusion — verify before filling anything in)

S76's merge commit (`a4d6968`, "Merge pull request #74 from ifelse-codes/session-76-dogfood-ride-along")
has two parents: `0f928d0` (pre-merge `main`) and `275662b` (the branch tip). `git log --oneline
0f928d0..275662b` shows 6 commits on that branch, in landing order:

```
76190f1  S76 (1/4): dogfood verify+demo scripts + curate-artifacts gitignore
9f0cab0  S76 (2/4): dogfood report + summary (fidelity map) + attested cold review
16d30aa  S76 (3/4): dogfood harness + task + pre-run measurement checklist
08e4718  S76 (4/4): the two run receipts (curated evidence; raw transcripts local)
c802d3e  S76 closeout (1/2): .ai sync — SESSION 76, STATE snapshot, SESSION-BOOT
275662b  S76 closeout (2/2): TASK pointer + ROADMAP entry + S77 prompt (receipt truth)
```

**Do NOT assume the "(N/4)" commit-message numbering matches the Plan's step-N in the same order**
— read S76's `## Plan` section (4 steps: prepare the ride-along + measurement checklist; the
founder drives the paid run while the agent captures artifacts live; derive the numbers from
captured artifacts; write the dogfood report + verify/demo scripts + summary + cold review +
attestation) and match each step's actual SUBSTANCE against what each commit's diff really
contains — e.g. Plan step 1 ("prepare... measurement checklist") reads like it matches commit
`16d30aa` ("(3/4): dogfood harness + task + pre-run measurement checklist"), not `76190f1`, despite
the "(1/4)" label. Confirm by reading each commit's actual diff, not by pattern-matching numbers.

## Acceptance (testable — every criterion is cited by a `## Plan` step below)

1. **WHEN** each of S76's 4 Plan steps is matched against the commit that actually delivers its
   substance **THEN** `prompts/76-task-dogfood-ride-along.md`'s `## Execution` section names that
   commit's real sha (no `<sha>` placeholder remains anywhere in the file).
2. **WHEN** `vajra next --check-exec 76` runs **THEN** it reports READY (every named sha resolves
   via `git cat-file -e <sha>^{commit}`) — prove this live, don't just assert it.
3. **WHEN** `vajra next --stations 76` runs **THEN** the Coder dimension reads PASSED where it
   previously read ABSENT for lack of a resolved Execution trace — confirm the before/after
   difference live (run `--stations 76` before AND after the fix).
4. If a Plan step's evidence genuinely spans more than one commit (S84's own review established
   this is acceptable and should be disclosed plainly, not hidden), record the sha of the commit
   that most completes that step's evidence, and say so in the summary — do not force an artificial
   1:1 mapping where the history doesn't support one.
5. No other file changes. This is a single-file, docs-only fix — do not touch `ROADMAP.md`'s stale
   table or anything in `src/` (both explicitly out of scope, ranked lower at S86's close).

## Design (the Architect gate — recorded rationale)

design-significant: **no** — filling in a historical record with real, already-existing commit
shas. No new mechanism, no new gate, no new store.

## Plan (ordered steps — cite the acceptance criteria each step covers)

1. Read S76's `## Plan` section and all 6 candidate commits' actual diffs (not just their
   messages); match each Plan step to the commit whose content genuinely delivers it. `covers: 1, 4`
2. Edit `prompts/76-task-dogfood-ride-along.md`'s `## Execution` section with the real shas.
   `covers: 1, 5`
3. Run `vajra next --check-exec 76` and `vajra next --stations 76` (before/after) live; confirm the
   Coder dimension flips from ABSENT to PASSED and record the actual output in the summary.
   `covers: 2, 3`

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>

## Guardrails

- **One story:** the S76 Execution sha fix only. Do NOT touch `ROADMAP.md`'s stale table (ranked
  🥉, not picked) or start any dogfood/measurement work (ranked 🥇 by this session's own
  recommendation, not picked by the founder this round).
- **No new command, no new CONSTRAINTS.yaml key.** This is a single historical-record edit.
- **This session is NOT itself design-significant** — do not add an ADR or DECISION record for it.
- **S90 is the next mandatory NO-CODE ground truth** (`90 % 5 == 0`) — S87, S88, S89 are normal.

## Delta (the Analyst gate — what this session ADDS to the governed pipeline)

- `+` closes the last standing `<sha>` placeholder debt in the repo's history (S76,
  disclosed-not-fixed since S81, 9 sessions overdue at pick time) — a pure record-hygiene fix, not
  a new capability.
