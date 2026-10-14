---
role: design-advisor
session: 196
agent: claude-code-subagent (verified: toolu_01G36dJwcxEE6aXkMTSFMRUt; text-sha: aa48ae32590e041857e1b80e9189017d16849dfbd68e1a5afe092934cd6d6420)
source-sha: cb8417be2d739325f2abd2f84a1e9c00b08f4d12b555994d1a93aa352e7be22b
captured: 2026-10-14T11:42:53Z
cost_usd: null
---

# Design-advisor handoff — session 196

# Design brief: S196, F127 (a RED close check stops no push)

## The decision in one line
Use shape **(A), the read**. `verify-closeout.sh` adds two lines to its result file: `head:` and `clean:`, which makes it format v2. `.githooks/pre-push` then refuses to push a `session-NN-…` branch unless the newest close result for **the exact sha being pushed** is `verdict: GREEN`, `clean: yes` and `session: NN`. This applies to the agent and the human alike. Git's own `--no-verify` is the only way around it, and the block message shows it only in a human shell.

## What I checked in the repo
- `.githooks/pre-push` is ONE file. Vajra's own repo uses it as is, and `src/cli/init.rs:2312` embeds it with `include_str!` as `TPL_GITHOOK_PRE_PUSH`. It is on `SYNC_HOOKS` (`src/cli/init.rs:52`), so `--sync-fleet` delivers it to rudra. Today it only reads `refs/heads/main|master`. Its agent check uses environment variables (`CLAUDECODE` and the others), not command text.
- The result file is written in two places with the same lines: `scripts/verify-closeout.sh:1393-1401` and `scripts/verify-closeout-scaffold.sh:1238-1246`. It sits under `.ai/verify/`, which is gitignored (`.gitignore:10`, and the scaffold's `.gitignore` too). So writing it never moves HEAD. Option A depends on that.
- **A hidden coupling.** `parse_close_result` in `src/cli/launch.rs:465-500` refuses any version other than `1` and refuses any extra line (`if lines.next().is_some() { return None }`). There is also a test near `launch.rs:788` that requires version 2 to be unreadable. If `head:` is added without changing the parser, every exit box shows "result unreadable". The format has to move to v2, and the binary has to accept both 1 and 2.
- **A conflict with a locked founder decision.** DECISION-007, S172 addendum, "Founder decision, 2026-09-21": *a branch not named `session-NN-…` is ungoverned work, on purpose*. It is locked by `tests/commit_belt.rs::an_agent_on_a_non_session_branch_commits_without_approval_by_design`. Your sketch ("any branch other than main/master") would reverse it. I recommend session branches only (rec 4). Rudra's S20 branch, and every `session-NN-closeout` branch, match `^session-[0-9]+-`, so F127 is still fully covered. If the founder wants every branch covered, that is his reversal to record. The agent cannot decide it.
- **Chicken-and-egg: none found.** I checked these:
  - `review-inputs-attested` uses `git merge-base main HEAD`, which is local main. No push is needed.
  - `check_release_coordinator` exists only in Vajra's own gate; the scaffold does not run it. It grades the PRIOR session's ship hygiene against `origin/main` as of the last fetch. It never needs the current branch on a remote.
  - No close check reads a PR number or calls `gh`: I grepped `src/` and both close scripts.
  - The S83 rule ("run the full close on the branch BEFORE merging") is now enforced by construction: a push comes before any PR or merge.
  - **One real friction:** anything committed after the GREEN run (a PR number in the summary, a "GREEN" line in STATE) moves HEAD, and the next push asks for one more run. That is correct behaviour; rec 6 covers the message and rec 9 the close-step wording.
- **Records that exist:**
  - `docs/decisions/DECISION-007-agent-fleet.md` (the git belt: the S171 and S194 addenda, and the 2026-09-21 decision)
  - `docs/adr/0004-meter-receipt-design.md` (the result file: the S194 addendum, line 572)
  - `docs/decisions/DECISION-011-controls-the-agent-cannot-type.md` (no environment variable the agent can type, and `vajra approve` records)

  No new record is needed: this extends the git belt and the result format, and both already have records.

## Proposed `## Design` text, for the author to record (not recorded by me)
```
## Design
design-significant: yes
- F127 (founder, 2026-10-14: "no pr creation till it is not green"). A PR needs a pushed branch, so the push is the
  one door every PR route passes (gh pr create, the web UI, a GUI client). `.githooks/pre-push` refuses to push
  `refs/heads/session-NN-*` unless the newest `.ai/verify/closeout/<stamp>/result` whose `head:` equals the pushed sha
  says `verdict: GREEN`, `clean: yes`, `session: NN`. GREEN with WARN passes (WARN is not a fail; the count is
  printed). Deletes, tags, non-session branches (founder 2026-09-21: ungoverned on purpose) and the existing
  main/master rule are unchanged — the guard only adds.
- Result format v2 (ADR-0004): `head:` = `git rev-parse HEAD`, `clean: yes|no` = no staged or unstaged change to a
  tracked file at the start AND the end of the run, and HEAD unchanged between them. The binary reads v1 and v2;
  the hook reads only v2 (v1 → "run vajra init --sync-fleet, then the close again").
- Session number = the `session-NN-` in the branch name, compared with the result's `session:`. Not `.ai/SESSION`
  (between sessions it holds the previous number) and not a guess.
- Override: none new. The human has git's own `git push --no-verify` (named only when no agent marker is set); a
  stuck check is waived inside the close, as today. No env var, no new approval record (DECISION-011).
- Cites DECISION-007 (S196 addendum: the push belt) and ADR-0004 (S196 addendum: result v2). DEVIATES from ADR-0004's
  S194 addendum in two stated ways: the binary is no longer the file's only reader, and `session:` is now compared.
  DEVIATES from DECISION-007's S171 "a person gets a note, not a wall" for session branches only: a human pushing a
  RED session branch is refused (with --no-verify named), because the founder's rule is about the PR existing, not
  who pushes it.
- Rejected: (B) re-running the close inside pre-push — minutes (live verify, live demo, clippy in Vajra) inside a
  push the agent's Bash call may time out on; it needs the working tree to equal the pushed commit anyway (another
  branch cannot be checked); the extra "unforgeable" is small, because the same agent can still run --no-verify where
  the publish guard is off. Guarding `gh pr create` in the publish guard (command-text classifying, S177/S188; agent
  only; misses the web UI). GitHub branch protection or required CI (rudra has no CI; Vajra is local-first). All
  branches (reverses the 2026-09-21 founder decision). Accepting a GREEN on an ancestor when only sessions/ or .ai/
  changed since (an exclusion list is the hole, S122). Blocking on WARN. Parsing through the `vajra` binary (version
  skew → the S132 hollow-pass trap; PATH inside a git subprocess).
- Named, not closed: the agent can write a GREEN result file (bar-raising, not tamper-proof, as DECISION-011);
  `--no-verify` skips the hook, and the agent can type it wherever the publish guard is off (Vajra's own repo,
  `publish_guard: off`) or VAJRA_ALLOW_PUBLISH=1 (VAJRA_ALLOW_COMMIT's allow-list does not include it); untracked files
  are not counted, so a close that read an uncommitted review or handoff can still push; a waiver typed inline is a
  GREEN; the hook runs only where core.hooksPath is .githooks; a non-session branch name skips it (the founder's door,
  N17 stays with S197).
```

## Recommendations

rec 1 — Switch `prompts/196-task-rudra-s21.md` to `design-significant: yes` and record a real `## Design` (draft above) before the fix lands.
Why: F127 changes a shared interface (result format v1 to v2, read by the binary and now by the hook) and a shipped guard. It also deviates in a stated way from ADR-0004's S194 addendum ("the binary reads only this file"; an extra line is unreadable; `session:` is not compared) and from DECISION-007's S171 "note, not wall". The prompt's own `## Design` says to switch on exactly this kind of change. The Architect gate reads the marker and never guesses.

rec 2 — Choose shape (A), the read of the result file. Reject (B), the re-run in pre-push.
Why: (B) runs the whole close inside `git push`: the live QA verify, the live demo, and clippy in Vajra's own repo. That takes minutes, and the agent's Bash tool call may time out (2-minute default). It also needs the working tree to equal the pushed commit, so `git push origin <other-branch>` cannot be checked at all. Its "unforgeable" advantage is mostly illusory: the same agent can type `git push --no-verify` wherever the publish guard is off, including Vajra's own repo. (A) costs nothing at push time, and the forgery hole is the one ADR-0004 S194 already names. Disclose it again; don't pretend it is closed.

rec 3 — Make the result file v2 in BOTH `scripts/verify-closeout.sh` and `scripts/verify-closeout-scaffold.sh`. Keep the field order fixed, with `head: <40-hex>` and `clean: yes|no` after `session:`. Record HEAD and tracked-cleanliness (`git status --porcelain --untracked-files=no` empty) at the START of the run. Check them again at the END. `clean: yes` only if both checks are clean and HEAD did not change. Update `parse_close_result` in `src/cli/launch.rs` to accept versions 1 and 2. Rewrite the `launch.rs` test that requires v2 to be unreadable so it uses v3.
Why: the exit-box parser refuses extra lines and any version other than 1. Without this, every project's F121 line turns into "result unreadable" the day the scripts sync. Checking at both start and end catches a check that edits a tracked file mid-run. A test that fails without it: the existing `s194_*` GREEN fixture rewritten as v2 must parse as GREEN. And a real scaffold run in a temp `vajra init` project must write a result that the hook accepts (rec 8, row 9).

rec 4 — In `.githooks/pre-push`, for each pushed ref line, apply the rule only when `remoteref` matches `refs/heads/session-[0-9]+-*`:
- Skip an all-zero `localsha` (a delete or prune) and skip `refs/tags/*`. Leave the main/master branch of the hook byte-for-byte as it is.
- Among `$(git rev-parse --show-toplevel)/.ai/verify/closeout/*/result`, take the newest stamp whose `head:` equals `localsha`.
- Refuse when there is no such result, or it is not GREEN, or `clean:` is not `yes`, or `session:` is not the branch's NN (compared as base 10, so `session-07-` equals 7).
- GREEN with WARN passes, and the WARN count is printed.
- The rule applies whether or not an agent shell is detected.
Why:
- Session branches only, because of the founder's 2026-09-21 decision, which is locked by a test. The NN comes from the branch name, not `.ai/SESSION` (which holds the previous number between sessions) and not a guess. That is the same `^session-([0-9]+)-` the publish guard and the commit belt already use.
- "Newest result for this exact sha": a later GREEN after a RED on the same commit passes, a later RED blocks, and a GREEN from before the last commit never counts.
- Human and agent alike: the founder's rule is about the PR existing, not about who opens it. S20's merge happened on GitHub.
- "Only adds": main/master is unchanged, and non-session branches get nothing new.

rec 5 — Parse the result inside the hook, in plain bash 3.2: strict fixed format, v2 only, fail closed. Add one cross-reader test that feeds the same fixture strings to `parse_close_result` and to the hook, and requires both to agree on GREEN, RED and unreadable: the v1 file, an extra line, GREEN with `fail: 1`, RED whose name count is wrong.
Why: calling `vajra` from the hook ties the push to the binary on PATH inside a git subprocess (GUI clients often lack it). When the hook is newer than the binary, an unknown flag falls through to `run_dump` and exits 0: the S132 hollow-binary pass. The hook and the script that writes the file are synced together by `--sync-fleet`, so they cannot drift apart; the cross-reader test keeps the second reader from drifting away from the Rust one.

rec 6 — Each refusal names its reason and the way through (S173):
- no result for this commit: "the last close check ran on <short-sha>, before your newest commit — run `bash scripts/verify-closeout.sh` again, then push";
- RED: "RED — N failed (names) · <folder> — fix them, commit, run the close until it says GREEN, push again";
- `clean: no`: "the close ran with uncommitted changes to tracked files — commit them, run it again";
- session mismatch: "the close checked session X; this branch is session NN's";
- v1 or unreadable: "run `vajra init --sync-fleet`, then the close again".

Every message also says "A pull request opens only after the close is GREEN (founder, 2026-10-14)". With no agent marker set, add: "Pushing anyway is your call: `git push --no-verify` skips every git hook." With an agent marker set, add instead: "If you think the check is wrong, stop and tell the founder — do not push around it."
Why: a guard has to name the way through. The `--no-verify` line is for the human, and hiding it from the agent only changes the text, not anyone's permission. An agent that runs `env -u CLAUDECODE` sees the human's text, which is harmless, and that should be disclosed.

rec 7 — Add no new override. No environment variable, no `vajra approve NN --push` record. The human's way past is git's own `--no-verify`. A stuck check is waived inside the close exactly as today (`VAJRA_WAIVE` + reason), and that waived run is a GREEN.
Why: the founder's rulings are DECISION-011 (no environment-variable escapes the agent can type, approvals are records), "no more policing" and "prefer removing ceremony". A push-approval record would police the founder's own push. `--no-verify` cannot be removed anyway, so a second escape adds ceremony and no safety. Disclose that an inline waiver, which the agent can type, produces a GREEN.

rec 8 — Prove it with `tests/push_belt.rs` (or new `s196_*` tests in `tests/commit_belt.rs`) plus rows in `scripts/verify-session-196.sh`. Each test uses a real `vajra init` in a temp folder, a bare `origin.git`, `core.hooksPath .githooks` as init sets it, and a real `git push`. Clear `CLAUDECODE`, `CLAUDE_CODE_ENTRYPOINT`, `CURSOR_TRACE_ID` and `VAJRA_AGENT`, and set them per row. All rows must be red at the S196 start commit:
1. RED result for HEAD → push exits non-zero, and the remote has no `refs/heads/session-01-x`.
2. GREEN for HEAD → push succeeds.
3. GREEN for HEAD~1, then a new commit → refused, naming "run it again".
4. GREEN with `clean: no` → refused.
5. GREEN with `session: 2` on `session-01-x` → refused.
6. `quick-fix` branch with no result → pushes (the 2026-09-21 decision).
7. `git push origin :session-01-x` → passes.
8. v1 result → refused, naming `--sync-fleet`.
9. The scaffold's REAL `scripts/verify-closeout.sh` runs on the fresh project. Its own RED result, not a hand-written fixture, blocks the push, and its `head:` equals `git rev-parse HEAD`.
10. GREEN with WARN → pushes, and the WARN count is printed.
11. Human shell vs agent shell: the `--no-verify` line appears only in the human shell.
Why: AC4 forbids source greps, and the existing `commit_belt.rs` pre-push tests feed the hook a ref line by hand. Only a real push to a real remote proves "no PR can exist". Row 9 is the one that proves the writer and the reader agree.

rec 9 — Change the Releaser step text in `src/nextstep/mod.rs:221-226`. It currently says "run scripts/verify-closeout.sh ON THE BRANCH first". Make it: "run it LAST, with everything committed, until it says GREEN — the push is refused otherwise; anything committed after it (a PR number, a 'GREEN' line) needs one more run". Update the `pre-push` row in `.githooks/README.md` the same way.
Why: this is the one real friction found in the chicken-and-egg check. If the instruction keeps its current wording, the first close under the new hook hits a refusal that the instructions never warned about. These two changes are text only: no gate changes.

rec 10 — Record a DECISION-007 "S196 addendum — the push belt stops a RED session branch (F127)" as the primary record, and a short ADR-0004 "S196 addendum — result v2: head and clean, a second reader". Each must state its deviations plainly:
- ADR-0004: the file now has a second reader, `session:` is now compared, and the exit box accepts v1 and v2.
- DECISION-007: on a session branch the human now gets a wall, not the S171 note.

Cite DECISION-011 for the decision to add no environment variable. Carry the named-not-closed list from the draft `## Design` into the addendum word for word.
Why: DECISION-007 owns the git belt (the S171 and S194 addenda) and ADR-0004 owns the result file (S194, line 572). Both exist on disk. The Architect gate checks only that a citation has the right form, so writing the deviation down is the only thing that marks it. These changes also touch more than 3 files: the hook, two scripts, `launch.rs`, tests, the verify script, two records, the README and `nextstep`. Split them into ≤3-file commits along those lines.

## Files
- /Users/suman/playground/vajra/.githooks/pre-push
- /Users/suman/playground/vajra/.githooks/README.md
- /Users/suman/playground/vajra/scripts/verify-closeout.sh (result write at 1393-1401; release-coordinator at 1025; merge-base at 1107)
- /Users/suman/playground/vajra/scripts/verify-closeout-scaffold.sh (result write at 1238-1246)
- /Users/suman/playground/vajra/src/cli/launch.rs (`parse_close_result` at 465; the v2-unreadable test near 788)
- /Users/suman/playground/vajra/src/cli/init.rs (`SYNC_HOOKS` at 21-55; `TPL_GITHOOK_PRE_PUSH` at 2312)
- /Users/suman/playground/vajra/src/nextstep/mod.rs (Releaser step text at 221-226)
- /Users/suman/playground/vajra/scripts/hook-publish-guard.sh (the `VAJRA_ALLOW_COMMIT` allow-list does not include `--no-verify`; `publish_guard: off` in Vajra's own repo)
- /Users/suman/playground/vajra/tests/commit_belt.rs
- /Users/suman/playground/vajra/docs/decisions/DECISION-007-agent-fleet.md (the 2026-09-21 founder decision at 1440; S194 addendum at 1748)
- /Users/suman/playground/vajra/docs/adr/0004-meter-receipt-design.md (S194 addendum at 572)
- /Users/suman/playground/vajra/docs/decisions/DECISION-011-controls-the-agent-cannot-type.md
- /Users/suman/playground/vajra/prompts/196-task-rudra-s21.md (`## Design` currently says `design-significant: no`)

## Handoff Delta
- `+` new: first design-advisor handoff for this session (18064 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
