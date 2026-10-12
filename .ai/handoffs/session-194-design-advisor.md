---
role: design-advisor
session: 194
agent: claude-code-subagent (verified: toolu_01LVsF4QpKK1BYDzSLFYo4aY; text-sha: 913092973339fbf90f0711c2522bb79570cd0ae481c0be1180534a2dcafc4c71)
source-sha: f2d76a61890a2a65f6554d30c005ba9af59e09c00307674154ce4a8fbe3ea84c
captured: 2026-10-12T04:18:08Z
cost_usd: null
---

# Design-advisor handoff — session 194

# Design brief: session 194 (F121, F123, F120)

## Marker: change it to `design-significant: yes`

The prompt currently says `design-significant: no`, and its own text says to flip it once a shared rule changes. All three fixes change one:
- **F121** adds a new contract between `scripts/verify-closeout.sh` and the `vajra` binary. That script ships to every project. It also adds a new line to the exit box.
- **F123** adds a new file that `vajra init` and `--sync-fleet` write into every project (`.githooks/pre-merge-commit`).
- **F120** adds a new refusal to `vajra next --role --from`, the command that records helper handoffs.

None of these is a pure fix.

## What I found in the repo (this decides the design)

1. **The close check writes no result file.** `verify-closeout.sh` and `verify-closeout-scaffold.sh` print the summary table and the `RED (17 pass, 5 fail) — closeout NOT done.` line to stdout only. They write no file with the result.
   - There is no `closeout.log`. rudra's `.ai/verify/closeout/20261012T035332Z/` holds 23 per-check `*.log` files, each in its own free-text shape. For example, `session-file-valid.log` is just `OK: 20 (N=20)`.
   - The `latest` link is set only at the end of the run (line 1389 / 1234).
   - So today the binary could only learn the result by guessing from text. That breaks the founder's "no text guessing" rule. The script must write a fixed-format result file itself.
2. **The record that governs F123 already names this hole.** The S43 git belt has no record of its own. But DECISION-007's **S172 addendum** (lines 1397–1400) describes this exact hole: `git checkout main && git merge <branch>` runs no pre-commit hook ("git would run `pre-merge-commit`, which Vajra does not ship"). It ends: "Disclosed, not fenced."
   - The **2026-09-21 founder decision** in the same record (line 1450) says "nobody commits on `main`/`master` (human or agent)".
   - The **S171 note in `src/cli/init.rs`** (lines 47–52) puts the git belt on `SYNC_HOOKS`.
3. **The handoff contract.** DECISION-007 §2 "Govern the handoff — rides `vajra next`, fail-closed" (lines 59–74) lists the cases that must exit non-zero: unknown role, missing or empty findings, a handoff that would not validate. F120 adds a fourth case.
4. **The receipt format.** ADR-0004 §2.8 already lets lines sit below the box's bottom border (`[vajra warn]` lines). The S193 addendum is the latest receipt addendum.

## Proposed `## Design` text (to paste, edit freely)

```
## Design
design-significant: yes

Cites ADR-0004 (§2.8 receipt format; S193 addendum) for F121, and DECISION-007 (§2 the handoff
contract; the S172 addendum and the 2026-09-21 founder decision on the git belt) for F120 and F123.
Recorded as an S194 addendum in each, as S193 did. No new record: each fix extends a rule those
records already lock.

F121 — the exit box shows the latest close check. verify-closeout.sh (Vajra's own and the scaffold
copy) prints its result only to the screen today; its per-check logs have no common shape. So the
script now also writes one fixed-format file, `.ai/verify/closeout/<stamp>/result`, as its last
step: a version line, `verdict: GREEN|RED`, `pass:`, `fail:`, `warn:`, and `failed:` (the names
of the failed checks). On exit, `vajra claude` reads only that file — never the screen text,
never the logs, never the transcript. "This run" means the newest run folder whose stamp is at
or after the second `vajra claude` started. The line prints below the receipt box (the §2.8 spot
for extra lines), from the launcher (src/cli/launch.rs), not the meter. It also prints when the
cost cannot be read. Four outcomes:
  close check: RED — 5 of 22 failed (fidelity-review-accept, …) · .ai/verify/closeout/<stamp>
  close check: GREEN — 22 passed · <folder>
  close check: started <time> but wrote no result (it stopped early, or the script is older — run
    `vajra init --sync-fleet`) · <folder>
  close check: not run during this run
A file that does not parse exactly is reported as unreadable, never as GREEN. VAJRA_QUIET=1
hides it with the receipt.

F123 — a merge commit on main is stopped. New `.githooks/pre-merge-commit`, a standalone hook
that only checks main|master. It blocks everyone, human or agent, the same as pre-commit's
first check and the 2026-09-21 rule. It does not call pre-commit. It ships the same way as
pre-commit and pre-push: include_str!, `fxs` in init, a SYNC_HOOKS entry, executable, and a
`!.githooks/pre-merge-commit` line in Cargo.toml. This closes the S172 addendum's "Vajra does
not ship pre-merge-commit"; that sentence gets struck through in the addendum, not left stale.

F120 — `--role --from` refuses a transcript. If the first non-blank line of the findings parses
as a JSON object (checked with serde_json, not a `{` check), Vajra writes nothing. It exits
non-zero and says: this is a transcript, not a findings brief — pass the helper's final handback
text (save it to a file, or `--from -`). The check runs before anything is written, so an
existing handoff stays as it was. This is a fourth fail-closed case on DECISION-007 §2's list.

Deviation, stated plainly: the receipt box (ADR-0004) was a cost receipt only. It now carries
one line that is not about cost. The meter API and format_receipt do not change.

Rejected:
- F121: the box reads stdout or the transcript for "RED (" (text guessing); the box reads the
  per-check logs (no common shape, so still guessing); trust the `latest` link (it may point to
  a run from before this launch, and it is set only at the very end); re-run the close at exit
  (minutes of live checks, writes a new artifact folder); a Stop hook that blocks the agent
  claiming "closed" (judges AI-written words).
- F123: call pre-commit from the new hook, like git's own sample does (pre-commit's 3-file cap
  and approval check would also block an agent merging main INTO its session branch — new
  policing, not this finding); add `git merge` to the L3 guard's text match (another command-
  text classifier; S173 needed seven REJECTs on exactly that; the git hook covers every route,
  `git pull` included); git's reference-transaction hook (fires on every ref change, including
  the human's fast-forward `git pull` on main and fetches — far too broad); block only agents
  (goes against the 2026-09-21 rule, and the agent check rests on environment variables).
- F120: pull the handback out of the transcript (ties Vajra to Claude Code's internal transcript
  format, and makes Vajra choose which message is "the brief" — a guess, and against DECISION-
  007's "Vajra governs, never authors" stance); detect by Claude Code's key names `parentUuid`/
  `sessionId` (breaks when Claude Code renames them, misses other tools' JSON-lines transcripts);
  require every line to be JSON (one cut-off last line defeats it); a size cap (a long brief is
  real, and size is not structure); warn and write anyway (the harm — the user's email and the
  full system prompt in a committed file — happens at the write).

Named, not closed:
- F121 shows the truth; it does not stop an agent saying "fully closed". The box appears only
  when `vajra claude` exits, so a founder who merges on GitHub before exiting still will not see
  it. The agent can write a fake result file (bar-raising, not tamper-proof, as in DECISION-011).
  A WAIVED check counts as a pass in the totals (read the logs for WAIVED, per S178). After a
  resume, only runs since this launch count.
- F123: any move of main without a new commit fires no hook — a fast-forward merge, `git reset
  --hard`, `git branch -f main`, `git update-ref`. `git merge --no-verify` skips the hook, and
  the L3 guard does not read `git merge`. pre-push still stops the push to main. The hook only
  works where `core.hooksPath` is `.githooks`.
- F120: a findings file that starts with prose and has a transcript pasted further down is not
  caught.
```

## Recommendations

rec 1 — Change the marker to `design-significant: yes` and record each fix as an S194 addendum in ADR-0004 (F121) and DECISION-007 (F120, F123), saying plainly that the exit box now carries a line that is not about cost.
- No new record is needed. Every citation above points to a file that exists: `docs/adr/0004-meter-receipt-design.md` and `docs/decisions/DECISION-007-agent-fleet.md`.
- **Test that would fail without it:** `vajra next --check-design 194` reports the citations correctly only once the marker and the citations are in the prompt.

rec 2 — F121: make both `scripts/verify-closeout.sh` and `scripts/verify-closeout-scaffold.sh` write a fixed-format `result` file into their run folder as their last step; the binary reads only that file.
- Write it next to the existing `ln -sfn … latest` line, before the final echo.
- `--inputs-sha`, `--ledger` and `--ledger-verify` already use a temporary folder, so they never produce one.
- **Test:** in `scripts/verify-session-194.sh`, run the real scaffold script in a temporary project set up to fail. Assert that `<stamp>/result` exists and contains `verdict: RED` and a `failed:` line naming the failed checks. At the start commit no such file exists, so the check is red.

rec 3 — F121: the newest run folder stamped at or after the launch second is "this run"; print exactly one of four lines (RED with names / GREEN / started-but-no-result / not run); anything that does not parse exactly is never shown as GREEN.
- Compare the folder stamp `%Y%m%dT%H%M%SZ` as a fixed-width string against the launch time in the same format. Do not use file modified times.
- **Tests:** unit tests on the pure reader, with fixture folders:
  - (a) a RED folder after launch gives the RED line with the failed names;
  - (b) a GREEN folder from before launch only gives "not run during this run";
  - (c) a folder after launch with no `result` gives "wrote no result", not GREEN;
  - (d) `verdict: PASSED`, a missing `fail:` line, or a non-number gives "unreadable", not GREEN;
  - (e) an older RED folder plus a newer GREEN one gives GREEN — the newest wins.

rec 4 — F121: put the reader and the printing in `src/cli/launch.rs` after `print_receipt`, and print the line even when the transcript cannot be found or the meter errors; leave `meter::format_receipt` unchanged.
- **Test:** a real-run check in `verify-session-194.sh`. A stand-in `claude` writes a RED result folder; assert that `vajra claude`'s stderr contains `close check: RED`. At the start commit's binary this is red. Also run it once with no transcript, so the line is shown not to depend on the cost.

rec 5 — F121: put the "named, not closed" list into the ADR-0004 addendum as written above.
- The list covers: the box only appears at exit, after any GitHub merge; the agent can write the file; WAIVED rows count as passes; a resume counts only since its own launch.
- Say "named, not closed" for these, per the founder's "a label is not a fix".
- **Test:** none, because this is wording. The fidelity-reviewer checks that the addendum and the summary claim no more than this.

rec 6 — F123: ship `.githooks/pre-merge-commit` as a standalone check of the current branch name against main|master that blocks everyone, and do not call pre-commit from it.
- Message: merges into main go through a pull request. Do not print `--no-verify` in the message — do not teach the agent the way around.
- **Tests:** add three to `tests/commit_belt.rs`, each in a temporary repo with `core.hooksPath=.githooks`:
  - on `main`, `git merge --no-ff session-01-x` exits non-zero and main's commit is unchanged — once with `CLAUDECODE=1` set and once without;
  - on a session branch, merging a 5-file branch with `--no-ff` succeeds. This proves the new hook does not bring in the 3-file cap.

rec 7 — F123: wire the new hook in the same places as pre-commit and pre-push.
- The places: a `TPL_GITHOOK_PRE_MERGE_COMMIT` include_str!, `fxs(".githooks/pre-merge-commit", …)` in `files()`, an entry in `SYNC_HOOKS`, executable mode, and `"!.githooks/pre-merge-commit"` in Cargo.toml's `exclude`.
- Without that Cargo.toml line the file is left out of the published package, and the include_str! breaks `cargo install`.
- Expect tests that count `SYNC_HOOKS.len()` to shift; they already compute the number, so check they still pass.
- **Tests:** an init test asserts the file exists with mode 0o755. A `--sync-fleet` test on a project that does not have the file asserts it is reported Missing and then written. `cargo package --list --allow-dirty` must list `.githooks/pre-merge-commit`; that is a check in verify-194 that is red at the start commit.

rec 8 — F123: in the DECISION-007 S194 addendum, strike through the S172 sentence "which Vajra does not ship" and name the remaining routes.
- The remaining routes: fast-forward, `reset --hard`, `branch -f`, `update-ref`, `git merge --no-verify`, and a repo without `core.hooksPath`.
- Do not add `git merge` to the L3 guard in this session.
- **Test:** none. This is a scope limit; the verify script prints it as a named known gap.

rec 9 — F120: `run_role_handoff` refuses findings whose first non-blank line parses as a JSON object, before `repo_root()` and before any write.
- The message says what it found ("a transcript, not a findings brief") and what to pass instead (the helper's handback text, in a file or through `--from -`).
- **Tests:** an integration test running the real binary:
  - a 3-line JSON-lines file shaped like a Claude Code transcript (`parentUuid`, `sessionId`, `type`) exits non-zero and creates no handoff file;
  - with an existing handoff, that file is byte-for-byte unchanged afterwards;
  - the same holds through `--from -` (stdin);
  - a counter-test: a markdown brief that contains a fenced ```json block is still recorded.
- All of these, except the counter-test, are red at the start commit.

## Notes for the author
- **Commit sizes under the 3-file cap:**
  - F121 = the two close scripts and `launch.rs`, with the tests in a separate commit.
  - F123 = the hook, `init.rs` and `Cargo.toml`, then `tests/commit_belt.rs`.
  - F120 = `next.rs` and its test.
- **Projects need a sync.** rudra and other existing projects get the result file and the new hook only after `vajra init --sync-fleet`. Until then, rec 3's "wrote no result" line tells them to run it.
- **F122 has no work of its own.** It becomes visible through the `failed:` names in F121 (`required-crew`, `fidelity-handoff`).

Relevant files:
- /Users/suman/playground/vajra/prompts/194-task-rudra-s20.md
- /Users/suman/playground/vajra/sessions/session-194-summary.md
- /Users/suman/playground/vajra/docs/adr/0004-meter-receipt-design.md
- /Users/suman/playground/vajra/docs/decisions/DECISION-007-agent-fleet.md
- /Users/suman/playground/vajra/scripts/verify-closeout.sh
- /Users/suman/playground/vajra/scripts/verify-closeout-scaffold.sh
- /Users/suman/playground/vajra/src/cli/launch.rs
- /Users/suman/playground/vajra/src/cli/init.rs
- /Users/suman/playground/vajra/src/cli/next.rs
- /Users/suman/playground/vajra/.githooks/pre-commit
- /Users/suman/playground/vajra/Cargo.toml
- /Users/suman/playground/vajra/tests/commit_belt.rs

## Handoff Delta
- `+` new: first design-advisor handoff for this session (15189 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
