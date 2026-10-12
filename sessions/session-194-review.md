# Session 194 — Independent Fidelity Review

One cold pass by a fresh fidelity-reviewer dispatch, not the builder. Its report follows verbatim; the builder's answers to its recs are in the prompt's `## Advice`.



verdict: ACCEPT

**Verdict:** ACCEPT

**4 of 6 SHIPPED** (2 PARTIAL, 0 NOT-BUILT)

The three approved fixes (F120, F121, F123) are real code, ship to projects, and have real-run checks that test the right thing. Nothing here is a narrow slice passed off as the whole job. The two PARTIALs are small. One finding has no founder call in the form the prompt asked for. And the "cargo test passes in full" half of AC4 rests only on the builder's word. There is also one real hole in F121 that nobody named, and it is the fakest green below.

**How I reviewed.** I followed `reviewer/SKILL.md`. I graded from the prompt and the code. I opened the summary only to check its claims. I read every file in the brief, `.git/logs/HEAD` for commit order, and both handoffs. I had no shell, so I ran nothing.

### Grade table (the numbered requirements)

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| D1 | Findings list F120…, each with evidence and the founder's call | SHIPPED | Summary findings table F120–F125, plus the F118/F119 sightings, each with a log time, file or commit. It was committed in `ca6eedc` before any code: in HEAD's log, ca6eedc comes before 052d338, 301f875 and 9d6892e. F125 was added in `f5801dd` with "founder: park". AC1 covers the founder-call part. |
| D2 | A fix for every finding the founder said yes to, each with a test that fails without it | SHIPPED | **F120:** `starts_with_json_object` (serde_json parse, not a `{` check) runs in `run_role_handoff` (`src/cli/next.rs:351`) before `repo_root()` and any write. `tests/role_refuses_transcript.rs` has 4 tests on the real binary. **F123:** standalone `.githooks/pre-merge-commit`, which checks the branch only. It is wired through `TPL_GITHOOK_PRE_MERGE_COMMIT`, `fxs`, `SYNC_HOOKS` (executable: true) and Cargo.toml `!.githooks/pre-merge-commit`. Tested in `tests/commit_belt.rs` `s194_*`. **F121:** both close scripts write `<stamp>/result` last, through a temp file and `mv`. `read_close_check` / `parse_close_result` in `src/cli/launch.rs` print the line after `print_receipt`, even with no cost. Unit tests `s194_*`. One unnamed hole, see the fakest green. |
| AC1 | Every finding has evidence and a founder call in the summary | PARTIAL | F120, F121, F123 (fix), F124 (not a problem) and F125 (park) each have a call. **F122's** "Founder call" cell says "Made visible by F121's fix (same class as S138)". That is not fix / park / not-a-problem, and nothing says it is the founder's words. The demo's "You made the calls" slide leaves F122 out. F122 is arguably rudra S20's biggest finding: zero helper roles ran, and the agent wrote its own "INDEPENDENT" review. |
| AC2 | Every fix has a real-run check in verify-194, no source greps, red at the start commit | SHIPPED | `scripts/verify-session-194.sh` has 10 rows (3+1+2+1+1+2), which matches the claimed 10. Each one runs the real binary in a temp project: `vajra init`, `vajra claude` with a stand-in `claude`, real `git merge --no-ff`, `--sync-fleet`, `cargo package --list`, `vajra next --role`. Each fix also runs against the binary built at 7e8210e, and goes red there for its own reason (S122): **F121** the close ran but wrote no `result` and the box had no "close check" line; **F123** no `pre-merge-commit` was scaffolded and main MOVED; **F120** the handoff was WRITTEN with the email inside. No row greps Vajra's source. Gap: the GREEN / WARN / unreadable paths are proven only by unit tests, never by a real run. |
| AC3 | rudra S20's receipt recorded against Claude Code's own total, and whether it shows the estimate lines | SHIPPED | Summary AC3 table: $1.49 top line, cost-state 1.4903203999999999, `~/.claude.json` lastCost 1.4903203999999999. It says "no `[estimate` line, no split, no pricing warning" and that it was a fresh run. verify-194 prints this as a `RECORD:` line and does not count it. This is a hand-read record of a log I cannot see (S126), and it is labelled honestly as one. |
| AC4 | No Vajra commit touches rudra; full `cargo test` passes | PARTIAL | First half: all 16 S194 commits in `.git/logs/HEAD` are in this repo, and verify-194 and the demo work only in temp folders. Second half: "719 passed / 0 failed" is only the builder's claim. Nothing in the diff or the close re-runs it (by founder ruling), and I could not run it. It becomes SHIPPED when CI on the PR is green. |

### The design as written (a supplementary check against the prompt's `## Design`)

| Design item | Verdict | Evidence |
|---|---|---|
| F121: fixed-format result file; the binary reads only it; newest folder at or after the launch second; a file that does not parse exactly is never GREEN; `VAJRA_QUIET=1` hides the line | SHIPPED | `parse_close_result` reads fields strictly in order and rejects any extra line. GREEN needs `fail == 0` and an empty `failed:`. RED needs the number of names to equal `fail:`. Version must be `1`. `is_run_stamp` ignores `latest`. The QUIET branch is at `launch.rs:266`. I found no way for a file the script did not write to read as GREEN. The two exceptions are both named: an agent writing a fake file, and WAIVED counting as a pass. |
| F123: standalone hook on main/master only, blocks everyone, does not call pre-commit, does not police merging into a session branch | SHIPPED | The hook is a `case` on `symbolic-ref` with no cap and no approval check. `s194_merging_into_a_session_branch_is_not_policed` merges a 5-file branch into a session branch with `CLAUDECODE=1` and it passes. |
| F120: first non-blank line is a JSON object → refuse, write nothing, exit non-zero | SHIPPED | `next.rs:344-357`. `read_findings` only reads. An existing handoff stays byte-for-byte (test). A brief containing a fenced json block still records (test). |

### The fakest green

**F121's exit line "shows the latest close check", but what it really shows is the newest dated folder.**

In both scripts, every focused mode creates a dated run folder (line 49, `mkdir -p "$ARTIFACTS"`) and then exits before the new `result` block runs: `--fidelity-only`, `--attest-only`, `--crew-only`, `--scripts-only` and `--check-exec-shas` (scaffold lines 1021–1073). Only `--inputs-sha` and the two ledger modes use a temp folder.

So this sequence is possible in a single `vajra claude` run:
1. The agent runs the full close and it goes RED.
2. The agent then runs a focused mode. `reviewer/SKILL.md` itself tells agents to use `--fidelity-only <N>`.
3. At exit, the newest folder has no `result`. The box says: `close check: started HH:MM:SSZ but wrote no result (it stopped early, or the project's script is older — run vajra init --sync-fleet)`.

The RED is gone from the box, and the reason it gives is wrong. This is not a false GREEN, so the "never GREEN" promise holds. But the headline promise, that the founder hears RED from Vajra and not from the agent, fails in a sequence an agent can easily reach.

Nothing covers this case:
- verify-194 row 1 and every unit test use a single full run, or several full runs.
- It is missing from the ADR-0004 S194 addendum's "Named, not closed" list and from the summary's limits.
- The design-advisor's rec 2 named only `--inputs-sha` and the ledger modes as using a temp folder, and the build inherited that gap.

The runner-up is the summary's own pick: AC3 is a hand-typed record. It is labelled honestly and not counted as a pass.

### Questions the caller asked

- **Does each verify row go red at 7e8210e for its own reason?** Yes, for F121, F123 and F120 (details in the AC2 row). Row 4 (`--sync-fleet`) and row 2 (the control) have no separate run at the old commit. Row 3b already shows the old binary has no hook, and row 2 is a control, not a fix.
- **Can the F121 reader report GREEN for a bad file?** Only for a file written exactly right, either by the script or by an agent forging it (named). Any reordering, extra line, wrong version, GREEN with failures, or RED whose count does not match the names reads as Unreadable. Note that the `session:` field is parsed but never checked against the current session.
- **Does pre-merge-commit police merging into a session branch?** No. It checks the branch only, and a test proves a 5-file agent merge into a session branch passes. Side effect, not named: a human's non-fast-forward `git pull` on local main is now refused as well. That matches the 2026-09-21 "nobody commits on main" rule.
- **Is the F120 check before any write?** Yes. It runs before `repo_root()`, `create_dir_all` and the handoff read.
- **Do the summary and addenda claim more than was built?** Mostly no. Every limit is labelled "named, not closed". The overclaim is in the summary's state list, which offers "started but wrote no result — run `vajra init --sync-fleet`" as if old scripts and early stops were the only causes. A later focused run is a third cause. One smaller wording issue: DECISION-007 says the hook "covers every route, `git pull` included". That is true only for routes that make a merge commit, which the same addendum then admits.
- **Is F125 recorded with evidence and the founder's call?** Yes. It is in the ROADMAP known bugs (lines 788–793) and the summary, with the branch name, the time 03:17:43Z, `hook-pre-bash.sh`'s `*-closeout) GT=0` (which I confirmed in `scripts/hook-pre-bash.sh:54`), and "founder, 2026-10-12: park".
- **Founder rulings.** No text guessing: the F120 test parses with serde_json, and F121 reads one fixed-format file. Guard changes only add: the hook only adds a block. No new policing of Vajra's own paperwork: F123 polices a product action, and F120 was the founder's own "Fix".

### Other things I noticed

- `.ai/approvals/session-194.json` is untracked at close (git status `??`). That is F116 happening again in Vajra's own S194, and the summary does not record it.
- The demo's "next" slide does not match the summary's three ranked options. The demo's option 3 is "cut the cost"; the summary's option 3 is the known-bug session.

### What I could not do

- I ran nothing: not verify-194, not demo-194, not `cargo test --release`. So the 10/0, 5/5 and 719/0 counts are all the builder's claims.
- I could not watch the old binary at 7e8210e actually fail. I checked only that each row's assertion against the old binary tests the right failure.
- I could not read rudra, its close logs or the S20 transcript. The F121, F122 and F125 evidence and the AC3 numbers rest on the builder's reading.
- I did not judge any `obeyed:` disposition. That is the release-coordinator's job. One thing for them: design-advisor rec 7 asked for an init test of mode 0o755 and a `--sync-fleet` Missing→written test. The Advice answer points to verify-194's `-x` check and its row 4 instead.

### Recommendations

rec 1 — Stop a focused close-check mode from hiding a RED: make `--fidelity-only/--attest-only/--crew-only/--scripts-only/--check-exec-shas` log to a temp folder (as S183 did for `--inputs-sha`), or have the reader report the newest run that wrote a result and say a later partial run wrote none; add a verify-194 row (full RED run, then `--attest-only`, the box must still say RED, red today).
A RED that disappears is the exact failure F121 was approved to fix. The current reader turns it into a message that blames an old script.

rec 2 — Until rec 1 lands, name this hole in the ADR-0004 S194 addendum's "Named, not closed" list and in the summary's limits, and stop presenting "wrote no result — run vajra init --sync-fleet" as if those were the only two causes.
A label is not a fix (founder rule), but an unnamed hole is worse than a named one.

rec 3 — Record F122's founder call in the asked form (fix / park / not a problem), in the founder's words, in the summary's findings table.
"Made visible by F121's fix" is how the builder framed it, not a call. F122 (zero helper roles on Haiku, a self-written "INDEPENDENT" review) is the finding the S195 review-only session most needs to see stated plainly.

rec 4 — Record the F116 sighting in S194 itself: `.ai/approvals/session-194.json` is untracked at close; either commit it with the session or add the sighting to the F116 entry.

rec 5 — Do not merge the PR until CI's full test run is green; that, not the summary's "719 passed", is AC4's evidence.

rec 6 — Make the demo's "next" slide list the same three ranked options as the summary.

rec 7 — In the DECISION-007 S194 addendum, change "the git hook covers every route, `git pull` included" to "every route that makes a merge commit", and name that a human's non-fast-forward `git pull` on local main is now refused too.

### Files referenced
- /Users/suman/playground/vajra/prompts/194-task-rudra-s20.md
- /Users/suman/playground/vajra/sessions/session-194-summary.md
- /Users/suman/playground/vajra/src/cli/launch.rs (lines 266–461, tests 683–783)
- /Users/suman/playground/vajra/src/cli/next.rs (lines 311–357, 437–448)
- /Users/suman/playground/vajra/.githooks/pre-merge-commit
- /Users/suman/playground/vajra/src/cli/init.rs (lines 21–55, 361–370, 1818, 2314)
- /Users/suman/playground/vajra/Cargo.toml (line 24)
- /Users/suman/playground/vajra/scripts/verify-closeout.sh (lines 41–50, 1389–1402)
- /Users/suman/playground/vajra/scripts/verify-closeout-scaffold.sh (lines 1021–1073, 1234–1247)
- /Users/suman/playground/vajra/scripts/verify-session-194.sh
- /Users/suman/playground/vajra/scripts/demo-session-194.sh
- /Users/suman/playground/vajra/tests/role_refuses_transcript.rs
- /Users/suman/playground/vajra/tests/commit_belt.rs (lines 239–315)
- /Users/suman/playground/vajra/docs/adr/0004-meter-receipt-design.md (lines 572–611)
- /Users/suman/playground/vajra/docs/decisions/DECISION-007-agent-fleet.md (lines 1398–1399, 1748–1784)
- /Users/suman/playground/vajra/.ai/ROADMAP.md (lines 786–797)
- /Users/suman/playground/vajra/.ai/handoffs/session-194-tech-lead.md
- /Users/suman/playground/vajra/.ai/handoffs/session-194-design-advisor.md
- /Users/suman/playground/vajra/reviewer/SKILL.md

**Review-Inputs-SHA:** 6568d7ea0e58bca6efa708fa698248fb20200a2e8fb39f186a0ff100d4bb3761
