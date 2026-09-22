---
role: qa-specialist
session: 174
agent: claude-code-subagent (verified: toolu_01UcBwxnefLtB3my8JtK8sio)
source-sha: 09ab75f3ca80c133d0737afb155e9f16d3c055bb49c5e98837527468de36c903
captured: 2026-09-22T17:11:39Z
cost_usd: null
---

# Qa-specialist handoff — session 174

I ran both scripts in `/Users/suman/playground/vajra` at `b46a413` on branch `session-174-keep-testing`. Both exited 0. I modified no files and committed nothing. My extra probes ran only in the scratchpad.

## Live results

**`bash scripts/verify-session-174.sh`: exit 0**
- The binary freshness check passed, so no rebuild was needed.
- The summary line was `=== session 174 verify: 19 pass, 0 fail ===`.
- Key lines:
  - `PASS: AC2 rudra main at 512c71a: 'session 05 is merged — session 06 starts here', branch first, no S05 ✗`
  - `PASS: AC3 real sync into rudra (3 hooks changed): boot names them Vajra's update, 'Never revert'`
  - `PASS: AC6 old vs new: 77 of 77 decisions identical (publish guard ×3 approvals, pre-commit)`

**`bash scripts/demo-session-174.sh </dev/null`: exit 0**
- The deck ran all 7 slides and printed `9 of 9 pass` and `✓ demo complete — all 9 live checks passed`.
- The scorecard shows 4 of 8 stations passed, independent review: none, and advice answered: 0 of 13.

## How each check works

In the verify script, 18 checks run the product, 1 is structural, and none is a hollow source grep.

| AC | Checks | Class | What it runs |
|---|---|---|---|
| AC1 | 6 | runs the product | Feeds commands to the real publish guard and checks the exit code and message (5 checks). Runs the real start-up hook and checks its note (1 check). |
| AC2 | 6 | runs the product | Runs `vajra next --steps` inside the rudra clone (1 check). Runs 5 unit tests by exact name, each required to report `1 passed`. |
| AC3 | 2 | runs the product | Runs the real `vajra init --sync-fleet` in the clone, then the start-up hook. Then makes a hand edit to one hook and checks it is reported as a hand edit. |
| AC4 | 1 | runs the product | Real pre-commit hook with 5 staged files. |
| AC5 | 2 | runs the product | Real pre-commit hook with SESSION 05 and BOOT 04, plus 1 unit test by name. |
| AC6 | 1 | runs the product | Runs the old and new hooks side by side and compares their exit codes. |
| AC7 | 1 | structural | Greps the prompt's findings table for F47, F56, F57 and F64. It checks paperwork, not behaviour, so it is not in the hollow count. |

Hollow checks: none. AC1 and AC3 do match message text, but they match the output of a live run. Since F58, F60, F61 and F63 are changes to what the agent is told, that output is the behaviour being tested.

The demo's 9 checks are all live runs too. One is weaker than the rest: "the old start-up said nothing about them" only confirms that a phrase is absent from the old hook's output. It would still pass if the old hook crashed and printed nothing.

## (a) AC6: old hooks against today's

- **It really runs both versions.** It extracts `scripts/hook-publish-guard.sh` and `.githooks/pre-commit` from `f170e1c` with `git show` (`f170e1c` is the S173 merge and an ancestor of HEAD). Each command then runs through the old and the new hook on the same scratch project, with the same input and approval. The 77 decisions are 23 commands × 3 approvals (05, none, 06) plus 8 pre-commit cases.
- **The code change can't loosen anything.** `git diff f170e1c HEAD` shows the only change in the publish guard is `APPROVED_HERE=1` plus a new message block. That block is reached only after the allow path has already refused and after the L1 exit, and it exits 2 just like the old fall-through. The allow-path code itself did not change.
- **The command list is not broad enough to be a lasting tripwire.** It includes `-R`, `HEAD:main`, `--force`, a merge chained after `&&`, and the heredoc. It is missing the spellings earlier cold reviews found holes in: `--head=`, `-H <branch>`, joined `-Hsession-05-y`, a repeated `--head`, the `cd <project> &&` prefix, `+branch`, `branch:main`, `--repo`, a backtick, and `| tail`. It also runs only at L3.
- **I tested those gaps myself.** I ran 18 more commands × 3 approvals through the old and new guard (54 decisions), plus L1 and L2 cases. There were 0 differences. So nothing got looser today, but the script does not guard those cases for the future.

## (b) AC2 and AC3: the rudra clone

- **Both run against a clone.** The script runs `git clone -q ~/playground/rudra $T/rudra`, then `checkout -B main 512c71a`, then points the clone's `origin/main` at `512c71a`. AC2 runs the binary and AC3 runs the sync only inside that clone (`$RC`). Everything is deleted on exit. If the clone fails, the check is recorded as FAIL, not skipped.
- **The real rudra was not touched.** Its HEAD was `512c71a33f…` before and after both runs. `git status` showed the same 3 modified files before and after: `.ai/hooks/hook-publish-guard.sh`, `hook-session-guard.sh` and `hook-session-start.sh`. That is rudra's own uncommitted synced update, which was already there; the demo's last slide mentions it. A clone copies only committed history, so AC3's "3 hooks changed" comes from the sync inside the clone.

## What the suite never exercised

- Whether a real agent, given the new messages, actually retries with `--body-file`, commits instead of reverting, or re-reads the list mid-session. That is the point of the session, and only rudra session 06 will show it.
- AC6 covers L3 only. It does not cover L1/L2, `VAJRA_ALLOW_PUBLISH=1`, or the guard switched off. My L1/L2 probe matched between old and new, but the script doesn't cover it.
- The start-up hook's changes (31 lines) are checked for message content only. There is no old-against-new comparison for it.
- The `src/cli/next.rs` change and the handover logic are checked only on rudra plus 5 unit-test fixtures.
- Close-time gates: the demo reports independent review none and advice 0 of 13 answered. Neither the verify script nor the demo checks the close.

## Recommendations

rec 1 — Add the allow-path edge spellings to AC6's command list: `--head=<b>`, `-H <b>`, joined `-H<other>`, a repeated `--head`, `cd <project> &&` / `cd <other> &&`, `<b>:main`, `+<b>`, `--repo`, a backtick, and `| tail`.
All 54 of these decisions match today. But these are exactly the cases where earlier reviews found holes, and a comparison that leaves them out won't notice when one of them loosens later.

rec 2 — Run AC6's comparison at L1 and L2, and with `VAJRA_ALLOW_PUBLISH=1` and the guard switched off, not only at L3.
The new message block sits right after the L1 exit. A later edit that moves either one would change decisions only at maturity levels AC6 never runs.

rec 3 — Make the demo's "the old start-up said nothing about them" check also require that the old hook exited 0 and printed something.
Right now a crashed or empty old hook would pass that check.

rec 4 — At the end of the verify script, check that the real rudra's HEAD and `git status --short` are the same as before the run.
Today "read-only" is true because of how the script is built (it clones). A before/after check would prove it on every run and catch a later edit that points `$RC` back at the real repo.

## Handoff Delta
- `+` new: first qa-specialist handoff for this session (6951 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
