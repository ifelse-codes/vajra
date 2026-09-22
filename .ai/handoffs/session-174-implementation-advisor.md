---
role: implementation-advisor
session: 174
agent: claude-code-subagent (verified: toolu_017bzqhB2of11EnwHp9mrchU)
source-sha: 3e4f56dd56311f0bfbd4fecf426e5152fe06bffdff418380547bb9fc615d907a
captured: 2026-09-22T17:01:17Z
cost_usd: null
---

# Implementation-advisor handoff — session 174

I've read the `--steps` path end to end. Nothing is written or run. The prompt's `## Plan` still has placeholder text (`1. <filled in from the findings>`), so I can't name a real step number. Treat all of the below as one plan step (call it "step K — F59/F62") and give it a number when the plan is written. The whole change fits in one commit touching 2 files: `src/nextstep/mod.rs` and `src/cli/next.rs`.

## What the code does today

- `run_steps` in `/Users/suman/playground/vajra/src/cli/next.rs` (lines 442–463) picks N from the `session-NN-` branch name, then from `.ai/SESSION`. It then prints `format_steps(&steps(&root, session), session)` and `format_options(&root, session)`.
- Nothing asks whether N has already been merged. So on `main` after S04 merged, N is 4 and you get S04's list, all ✓, ending "nothing left — close the session" (F59). After S05 merged, N is 5 and its old checks are graded again with ✗ lines (F62).
- A git-based "has this close been merged?" check already exists and is already used in this file: `releaser::shipped_close(root, nn)` in `/Users/suman/playground/vajra/src/releaser/mod.rs:190`. It is used for `stamped` at `nextstep/mod.rs:63-64`. It returns `Some` when `sessions/session-NN-summary.md` is committed on `origin/<main>`, or on local main if there is no origin ref. The summary is written at the session's own close, so this means "closed and merged", read from git rather than from `.ai/SESSION`.

## Recommendations

rec 1 — Decide "merged" with the existing `releaser::shipped_close` in a new `nextstep::session_to_show(root, session) -> (u32, Option<u32>)` that steps forward past every session whose close is already on main. Add no new git check and do not trust `.ai/SESSION`.

Shape: `let mut n = session; while releaser::shipped_close(root, n).is_some() { n += 1 }`, returning `(n, (n != session).then(|| n - 1))`. The loop handles `.ai/SESSION` lagging by two, which is the rudra S01→S02 case. It stops on its own, because it ends at the first session with no summary on main. This covers the tech-lead's advice to read merged-ness from git: the check is `git cat-file -e origin/main:sessions/...`, not the counter.

rec 2 — Move `run_steps`' printing into a new `nextstep::render(root, session, branch: &str) -> String`. `cli/next.rs` keeps picking N exactly as it does now and just does `print!("{}", nextstep::render(&root, session, &current_branch(&root)))`.

This lets a unit test run the same path the boot hook runs (`scripts/hook-session-start.sh:113`, `vajra next --steps`). Passing the branch in keeps `nextstep` free of its own branch lookup. Use the public `releaser::session_number_of(branch)` for the branch-number check; `session_of_branch` in `next.rs` is private.

rec 3 — When `session_to_show` rolls past a merged N, `render` prints a header `session N is merged — session N+1 starts here`. Then come two new steps, then the existing `steps(root, N+1)` unchanged, then the line `re-run \`vajra next --steps\` after each step — this list is the session`. It must never call `steps(root, N)`.

The two new steps, in `start_steps(root, next, branch) -> Vec<Step>`:
- **Branch step.**
  - Done when `releaser::session_number_of(branch) == Some(next)`.
  - What: "you are on this session's own branch".
  - How: `git checkout -b session-{next:02}-<slug> main`, where `<slug>` comes from `prompts/{next:02}-task-<slug>.md` if it exists (next to `prompt_exists`), otherwise the literal `<slug>`.
- **Prompt step.**
  - Done when `prompt_exists(root, next)`.
  - What: "this session's prompt exists".
  - How: write it from the human's pick of session N's three options, which are printed below.

Rendering the rest with the existing `format_steps(&steps, next)` gives "YOUR NEXT STEP" for the first unfinished step. The tech-lead is the first of the existing steps. I checked that an unstarted N+1 does not tick falsely: the Releaser reads `NoBranch` with no attested review as ABSENT (`stations/mod.rs:331-335`), `counter_moved` is false while `.ai/SESSION` is N, and `stamped` is false.

rec 4 — Don't add a separate "bump `.ai/SESSION`" step before the tech-lead. Instead, change the existing counter step's `how` (`nextstep/mod.rs:104-108`) to say that `vajra next --advance` moves `.ai/SESSION` and SESSION-BOOT's Number together, and never to edit them by hand.

You asked for the bump near the start. But `run_advance` refuses to run on main (`next.rs:1440-1442`) and blocks at L2/L3 until N+1's prompt is approved (`next.rs:1463-1483`). Putting it before the tech-lead would name a step that fails. `--advance` already writes both files (`next.rs:1903-1917`), so saying so in the `how` text is the whole F63 fix available on this path. If you want the bump moved earlier anyway, that means changing `--advance`, which is outside this path's scope.

rec 5 — When rolling over, call `format_options(root, N)` for the merged session N rather than for N+1. That way, if N+1's prompt was never written (F48 missed it in rudra), the three candidates it should come from are on screen. `format_options` already adds "already written — say which of these it came from" when the prompt exists.

rec 6 — Add these unit tests to `src/nextstep/mod.rs`, reusing the git-init closure pattern from `a_merged_session_with_an_accept_on_file_is_not_sent_back_for_review`. The first two fail today:
- `a_merged_session_hands_over_to_the_next_ones_start` (F59/F62, fails without the change):
  - Setup: `git init -b main`, commit `sessions/session-05-summary.md`.
  - Expect `render(root, 5, "main")`:
    - contains `session 05 is merged — session 06 starts here`, `YOUR NEXT STEP: you are on this session's own branch`, `session-06-` and `re-run \`vajra next --steps\``;
    - does not contain `what is left in session 05` or `nothing left — close the session`.
  - Add `prompts/06-task-foo.md` and the `how` names `session-06-foo`, with the prompt step ✓.
- `a_lagging_counter_rolls_past_every_merged_session`: commit summaries for 04 and 05, then `render(root, 4, "main")` names `session 06 starts here`.
- `a_green_but_unmerged_close_keeps_its_own_list` (unchanged behaviour): commit the 05 summary on `session-05-x` only, then return to main. Output contains `what is left in session 05` and not `is merged`.
- `the_new_sessions_branch_gets_the_normal_list`: with the 05 summary on main, `render(root, 6, "session-06-x")` has no merged header, and the tech-lead is the next step.
- `no_git_means_no_rollover`: the existing non-git `repo()` output from `render(root, 1, "?")` equals today's `format_steps(&steps(root,1),1)` plus `format_options`. The existing tests already cover this indirectly.
- Leave the live proof (boot on rudra-shaped main after a merge) to the QA specialist's `verify-session-174.sh`. The tech-lead handoff lists `--steps` after merge as one of its checks.

rec 7 — Land this as one commit touching only `src/nextstep/mod.rs` and `src/cli/next.rs`. Write the plan step first, and record `step K — done: <sha>` only after the commit exists. Put the three limits below in the prompt's findings or summary rather than fixing them.

## Edge cases

| Case | What happens |
|---|---|
| Branch not created yet (on main, `.ai/SESSION`=N, N merged) | Rollover. The first unfinished step is the branch step. |
| `.ai/SESSION` already bumped on the new branch | N comes from the branch name (N+1). `shipped_close(N+1)` is `None`, so the list is unchanged and has no header. |
| Counter bumped on main with no branch (hand edit) | N = N+1, not merged, so unchanged. That list has no branch step. This is outside this path; note it, don't fix it. |
| Close green but not merged | The summary is only on the branch, so `shipped_close` is `None` and nothing changes. This is already tested by `shipped_close_needs_the_summary_on_main_not_just_on_a_branch`. |
| Merged locally while `origin/main` exists | Doesn't count, because `shipped_close` checks origin first (`shipped_close_prefers_origin_so_a_local_merge_does_not_count`). |
| No git remote | Falls back to local main. An agent's own local merge would trigger the rollover. This limit is already disclosed on `shipped_close` (S172 rec 1). It's acceptable here because `--steps` only gives advice and blocks nothing. |
| Merged on GitHub but not yet fetched | `origin/main` is out of date, so you still see N's list until the post-merge sync pulls. Vajra never fetches. Disclose this. |
| Not a git repo, or no main/master | `main_branch` is `None`, so nothing changes. |
| Explicit `--steps NN` for a merged NN | Also rolls over. That matches "never show ✗ for a merged session" and "reported on, never re-graded". |

## Files
- `/Users/suman/playground/vajra/src/nextstep/mod.rs`: add `session_to_show`, `start_steps` and `render`, reword the counter step's `how`, add the tests.
- `/Users/suman/playground/vajra/src/cli/next.rs`: `run_steps` (lines 442–463) calls `nextstep::render`.
- Read only, not changed: `/Users/suman/playground/vajra/src/releaser/mod.rs` (`shipped_close`, `session_number_of`), `/Users/suman/playground/vajra/scripts/hook-session-start.sh`.

## Handoff Delta
- `+` new: first implementation-advisor handoff for this session (9144 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
