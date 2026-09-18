---
role: qa-specialist
session: 172
agent: claude-code-subagent (verified: toolu_01Caj5hi2ymNRENowt2RbXcd)
source-sha: de8fcd2aa298d01302fcb6fec18b2357013d3bec17851c8c0bfebc6e169931e8
captured: 2026-09-18T08:34:33Z
cost_usd: null
---

# Qa-specialist handoff — session 172

I've settled the list: **11 cases, 8 for pre-commit and 3 for pre-push**. The brief's "six" leaves out the stale-marker case, the upper edge of the 3-file limit, and the other ways the hooks detect an agent. The tech-lead's "eight" matches the pre-commit count but has no pre-push cases.

I ran every case below against the real hooks in throwaway repos in the scratchpad. I edited nothing in the repo. I did not run `scripts/verify-session-172.sh`, because this task was to design the test cases, not to run the suite.

## How the hooks branch
- **pre-commit** checks things in this order:
  1. **B1:** on `main` or `master`, it blocks everyone.
  2. **B2:** it treats the shell as an agent if any of `CLAUDECODE`, `CLAUDE_CODE_ENTRYPOINT`, `CURSOR_TRACE_ID` or `VAJRA_AGENT` is set to anything other than an empty string.
  3. **B3:** for an agent on a branch matching `^session-([0-9]+)-`, `VAJRA_ALLOW_COMMIT` must be exactly that number, compared as text.
  4. **B4:** an agent may stage at most 3 files.
  5. **B5:** it blocks if `.ai/SESSION` and the Number in `SESSION-BOOT.md` disagree.
  6. **B6:** it runs `scripts/hook-drift-guard.sh`.
- **pre-push:**
  - **P1:** an agent pushing to `refs/heads/main` or `refs/heads/master` is blocked (exit 1).
  - **P2:** a person doing the same gets a note and exit 0.
  - **P3:** any other branch passes silently.
  - **P4:** a line with no remote ref is skipped.

## Case table (all observed)
| # | Hook | Branch | Agent variable | `VAJRA_ALLOW_COMMIT` | Files staged | Exit | Key output line |
|---|---|---|---|---|---|---|---|
| 1 | pre-commit | main | none | none | 1 | 1 | `Vajra stopped this commit: you are on 'main'.` |
| 2 | pre-commit | main | `CLAUDECODE=1` | 1 | 1 | 1 | same line (the approval never gets you onto main) |
| 3 | pre-commit | session-7-x | none | none | 5 | 0 | no output (a person needs no approval and has no 3-file limit) |
| 4 | pre-commit | session-7-x | `CLAUDECODE=1` | none | 1 | 1 | `...the agent has no approval to commit for session 7.` |
| 5 | pre-commit | session-7-x | `CLAUDECODE=1` | 6 (a different session) | 1 | 1 | same line as case 4 |
| 6 | pre-commit | session-7-x | `CLAUDECODE=1` | 7 | 3 | 0 | no output |
| 7 | pre-commit | session-7-x | `CLAUDECODE=1` | 7 | 4 | 1 | `Vajra stopped this commit: 4 files at once; an agent commits at most 3.` |
| 8 | pre-commit | session-7-x | one of `CLAUDE_CODE_ENTRYPOINT=x`, `CURSOR_TRACE_ID=x`, `VAJRA_AGENT=1` (one at a time) | none | 1 | 1 | same line as case 4, for each variable |
| 9 | pre-push | pushing to `refs/heads/main` | `CLAUDECODE=1` | – | – | 1 | `Vajra stopped this push: the agent may not push 'refs/heads/main' straight up.` |
| 10 | pre-push | pushing to `refs/heads/main` | none | – | – | 0 | `Note: pushing 'refs/heads/main' directly...` |
| 11 | pre-push | pushing to `refs/heads/session-7-x` | `CLAUDECODE=1` | – | – | 0 | no output |

Case 8 should be one test that loops over the three variables.

Pre-push needs no remote. Pipe `refs/heads/x <sha> refs/heads/main <sha>\n` into `bash pre-push` and it runs.

## Behaviour no case covers (all observed)
- **B5, the `.ai/` mismatch check:** it blocks a person too (`[pre-commit BLOCK] .ai/ drift: .ai/SESSION=7 but SESSION-BOOT Number=6`, exit 1). No case sets it up, because a temp repo has no `.ai/`.
- **B6, the drift-guard:** it only runs if `scripts/hook-drift-guard.sh` exists and is executable in the temp repo, so it is always skipped there.
- **An agent on a branch that isn't named `session-NN-`:**
  - An agent committing 1 file on `feature-x` with no approval gets exit 0.
  - So does an agent on `session-7`, with no dash after the number, because the pattern needs a trailing `-`.
  - The 3-file limit still applies on those branches. This is the biggest gap in the approval check that nothing pins down.
- **How approval and agent detection match:**
  - Approval is compared as text, so `VAJRA_ALLOW_COMMIT=07` does not approve session 7 (exit 1).
  - `VAJRA_AGENT=0` still counts as an agent.
  - `CLAUDECODE=` (set but empty) counts as a person.
- **Rarer paths:**
  - A commit on `master` (blocked the same way as main).
  - A detached HEAD: it becomes `DETACHED`, is not a session branch, and only the file limit applies.
  - A pre-push line with no remote ref, and an agent push that mixes a session branch and main (observed exit 1).

## What would make a temp-repo test flaky
1. **The environment it inherits.** This shell has `CLAUDECODE=1` and `CLAUDE_CODE_ENTRYPOINT=claude-desktop`, so a test run from inside Claude Code will see an agent. The "person" cases would then fail in an agent shell and pass in CI or a terminal. Every `Command` needs `.env_remove` for all five variables: `CLAUDECODE`, `CLAUDE_CODE_ENTRYPOINT`, `CURSOR_TRACE_ID`, `VAJRA_AGENT` and `VAJRA_ALLOW_COMMIT`.
   - This has already happened. With the agent variables removed, `scripts/verify-session-93.sh` shows `L2-block-no-marker FAIL`. With them present it shows PASS. That check has only been passing because it runs inside an agent shell.
2. **Staging the copied hook.** If the hook is copied into the work tree and the test runs `git add .`, the hook counts as a staged file. My first probe of case 6 (3 files) saw 4 and was blocked. Point `core.hooksPath` at a folder outside the work tree, or `git add` the named files only.
3. **The hook changes into the repo root** (`git rev-parse --show-toplevel`) and reads `.ai/` and `scripts/` there. Leave both out of the temp repo unless a case means to test them.
4. **Your personal git settings.** Set `user.name` and `user.email` in each repo. Also set `commit.gpgsign=false`, or better, `GIT_CONFIG_GLOBAL=/dev/null`, so a global signing setting or global `core.hooksPath` can't interfere.
5. **Branch setup.** `git symbolic-ref HEAD refs/heads/<br>` on a brand-new repo is enough and needs no first commit.

`src/cli/init.rs` builds both hooks into the binary from `.githooks/` (`include_str!`). That means testing `.githooks/` also tests the copy every project gets at `vajra init`.

rec 1 — The new test must remove all five variables (CLAUDECODE, CLAUDE_CODE_ENTRYPOINT, CURSOR_TRACE_ID, VAJRA_AGENT, VAJRA_ALLOW_COMMIT) on every Command and set only the ones a case needs.
Without this, the result depends on whether Claude Code launched the test. `verify-session-93.sh` already shows that failure.

rec 2 — Keep the hook outside the temp work tree (core.hooksPath set to its own temp folder) and stage files by name.
This stops the hook from counting toward the 3-file limit, as it did in my first case 6 probe.

rec 3 — Fix `L2-block-no-marker` in scripts/verify-session-93.sh so it sets CLAUDECODE=1 itself instead of taking it from the calling shell.
In a person's terminal or in CI it now FAILs, because since S171 a person may commit without approval.

rec 4 — Decide in writing whether an agent may commit without approval on a branch not named session-NN- (e.g. `feature-x`, `session-7`), and add one case that locks in that decision.
Today both give exit 0 with no approval, and no case covers it.

## Handoff Delta
- `+` new: first qa-specialist handoff for this session (7097 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
