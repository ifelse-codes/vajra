---
role: qa-specialist
session: 172
agent: claude-code-subagent (verified: toolu_01U9qNvk1iSixisEKhi5WKyo)
source-sha: 4e68cbb275921d046c3194f1b07d5ed3c8aac1039e0ae5e3409dcdba51e528dd
captured: 2026-09-20T18:16:13Z
cost_usd: null
---

# Qa-specialist handoff — session 172

# qa-specialist — session 172

Two dispatches, one handoff: the case list this role settled BEFORE the belt test was written,
and its later independent judgments on the dispositions other roles' advice produced.
(Its own recs 1 and 3 are judged elsewhere — a role may not grade its own advice.)

---

# Part 1 — the case list (advice, recs 1-4)

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

---

# Part 2 — independent judgments

# qa-specialist — independent judgment on session 172's recorded dispositions

Two batches. Batch 1 judged the cold review's own ten recommendations; batch 2 judged the
tech-lead's, qa-specialist's and design-advisor's. One MISMATCH, named in batch 2.

## Batch 2 — tech-lead, qa-specialist, design-advisor

obeyed-check tech-lead rec 1 — implemented: ff8145a — commits the tech-lead handoff carrying the crew roster with exactly `qa-specialist` and `fidelity-reviewer` marked `required` and the other seven `deferred-budget` each with a cost reason, plus the qa-specialist dispatch itself.

obeyed-check tech-lead rec 2 — implemented: bf3b515 — lands `tests/commit_belt.rs` built to the qa-specialist's settled case list (handoff `captured: 2026-09-18T08:34:33Z`, ~32 minutes before this commit's 09:06Z author time), driving the real `.githooks` files, so the count was settled at 11 before the test was written rather than after.

obeyed-check tech-lead rec 3 — implemented: da508e1 — adds the single `.ai/handoffs/session-172-fidelity-reviewer.md` plus `sessions/session-172-review.md` (ACCEPT, 13 requirement rows, 9 recommendations) and the summary's "What the cold review changed"; only one reviewer handoff and one review file exist for S172, so there was no re-review loop.

obeyed-check tech-lead rec 4 — implemented: 4f1ce0f — lands the session's `## Design` and `## Plan` after the tech-lead dispatch of ff8145a and builds no F31 gate anywhere in its diff; the "Did not recur" findings-table row it cites was already written in b9db6bb, so this commit carries the disposition rather than the record.

obeyed-check tech-lead rec 5 — mismatch: 4f1ce0f dispatches the design-advisor and records its handoff, but the rec asked to MOVE the role from `deferred-budget` to `required` with the founder's yes — the crew row in `.ai/handoffs/session-172-tech-lead.md:24` still reads `crew design-advisor — deferred-budget`, no founder approval is recorded anywhere in the prompt, summary or handoffs, and the prompt's own Advice preamble says "dispatched anyway", so the Crew gate never required the role and the dispatch stayed voluntary.

obeyed-check qa-specialist rec 1 — implemented: bf3b515 — defines `BELT_VARS` with all five variables (`CLAUDECODE`, `CLAUDE_CODE_ENTRYPOINT`, `CURSOR_TRACE_ID`, `VAJRA_AGENT`, `VAJRA_ALLOW_COMMIT`) and `env_remove`s every one of them on all three `Command` builders (`git`, `commit`, `push`), each case then adding only the variable it tests.

obeyed-check qa-specialist rec 3 — implemented: bf3b515 — `l2_expect` in `scripts/verify-session-93.sh` now builds `as_agent=(env -u CLAUDE_CODE_ENTRYPOINT -u CURSOR_TRACE_ID -u VAJRA_AGENT -u VAJRA_ALLOW_COMMIT CLAUDECODE=1)` instead of inheriting the caller's shell; run with every agent variable stripped, `L2-block-no-marker` now reports PASS.

obeyed-check design-advisor rec 1 — implemented: 4f1ce0f — records `- design-significant: yes` and gives the reason as the moved clause ("this session MOVES the moment DECISION-007's two wiring clauses lock"), not "we changed code"; the reason sits in the DEVIATION paragraph, not on the marker line, and the literal phrase "a locked clause moves" appears only in the disposition.

obeyed-check design-advisor rec 2 — implemented: 4f1ce0f — the `## Design` body is the advisor's rec-2 text, trimmed, keeping all four paragraphs including the deviation one; the one clause dropped in the trim, "(or any route that puts it there)", is exactly what the cold review's rec 1 later caught and 2261cae restored.

obeyed-check design-advisor rec 3 — implemented: 53601d2 — appends exactly one `## S172 addendum` to `docs/decisions/DECISION-007-agent-fleet.md` (and no DECISION-011 exists) that quotes the S127 "wired into `--advance` on the CLOSING session" and S131 "binds on the session being CLOSED" sentences, states the new rule under an explicit "The new rule, in one line:", and cross-references DECISION-010's "old demos are never re-graded at close".

obeyed-check design-advisor rec 4 — implemented: 4f1ce0f — the `## Design` prose itself carries "**DEVIATION**, stated plainly because the Architect gate checks the form of a citation and never whether the design obeys it", unsoftened, rather than leaving the deviation only in the addendum.

obeyed-check design-advisor rec 5 — implemented: 53601d2 — the addendum's "What this does NOT claim" section opens with item 1, "The backstop is gone… It is not caught anywhere now", naming the S83 pre-merge text rule and this repo's own S171 finding that text rules get skipped while gates do not; no owner is named for the residual, which the rec's headline also asked for.

obeyed-check design-advisor rec 6 — implemented: 53601d2 — the addendum's "record discovery widens (F35)" paragraph writes out the accepted set (`docs/adr/` and `docs/ADR/` in any case, `0010-title.md` and `ADR-010-title.md`, decisions unchanged) and restates the S126 sentence, while fb8b043 changes `src/fleet/mod.rs:271-272` to "`docs/adr/` or `docs/decisions/`, in any case (`docs/ADR/ADR-010-title.md` counts)"; DECISION-007 line 565 is restated in the addendum rather than edited in place, which is what rec 3 asked for.

obeyed-check design-advisor rec 7 — implemented: 53601d2 — builds the falsifiability case as `run_live_gate` in `scripts/verify-session-172.sh`, sourcing the real `check_live_gate` out of the close scripts and asserting it goes red on a failing gate and on a build that cannot evaluate, and the partial claim is honest about the big gap (no end-to-end `verify-closeout.sh` red); two caveats on the claim as worded — at 53601d2 only the scaffold copy genuinely went red, the "own" copy greened on the missing-binary branch until ccd1b21 fixed it, and the rec's fallback ("record that in the findings table with a severity") was not done, the shortfall being disclosed in the summary's open list and S173 candidate 3 instead.

Out-of-scope flag from something I ran: `scripts/verify-session-93.sh` exits RED (25 pass, 2 fail) at `HEAD=4c1e269` — `e2e-guard-byte-identical` and `e2e-precommit-byte-identical`. Neither is caused by the commits above. `vajra init`'s scaffolded `/Users/suman/playground/vajra/.githooks/pre-commit` now differs from the repo's by one appended line, `# vajra-render-sha: e8d825c6…`, and `$GUARD` points at `.ai/hooks/hook-commit-guard.sh`, which does not exist in this repo at all — so both checks look stale rather than broken, but they are red.

## Batch 1 — the cold review's ten recommendations

obeyed-check fidelity-reviewer rec 1 — implemented: 2261cae — `shipped_close()` now asks `refs/remotes/origin/<main>` first and only falls back to local main when no such ref exists (saying "no origin/main ref to check against" when it does), and the un-forgeability sentence in `docs/decisions/DECISION-007-agent-fleet.md` is replaced by an explicit "Corrected by this session's cold review (rec 1)" paragraph that names the `git checkout main && git merge` route.

obeyed-check fidelity-reviewer rec 2 — implemented: ccd1b21 — adds `check_live_gate fidelity-handoff --check-fidelity-handoff "=== fidelity: fidelity-reviewer handoff for session"` to the main check sequence of both `scripts/verify-closeout.sh` (line 1284) and `scripts/verify-closeout-scaffold.sh` (line 1086), so an absent handoff now blocks pre-merge.

obeyed-check fidelity-reviewer rec 3 — implemented: 36c5725 — rewrites the prose `obeyed:` dispositions in `prompts/172-task-keep-testing.md` to name resolvable shas (`ff8145a`, `4f1ce0f`, `53601d2`) and gives `design-advisor rec 7` the parseable word `obeyed:` in place of `obeyed in part:`.

obeyed-check fidelity-reviewer rec 4 — implemented: ccd1b21 — `check_live_gate` in `verify-closeout.sh` now resolves `BIN` PATH-first so the harness's fake `vajra` is reachable, the harness `cat`s the gate log, and the `AC2 same-check-in-vajras-own-gate` assertion additionally requires `binary: .*/bin/vajra`, distinguishing a real block from the missing-binary branch.

obeyed-check fidelity-reviewer rec 5 — implemented: ccd1b21 — replaces the `grep -c '#[test]' … = 6` count check with a live negative control that seds `agent_shell=1` → `agent_shell=0` in a copy of the real `.githooks/pre-commit` and asserts an unapproved agent commit then succeeds.

obeyed-check fidelity-reviewer rec 6 — implemented: 2261cae — the Releaser step in `src/nextstep/mod.rs` now reads "run scripts/verify-closeout.sh ON THE BRANCH first — since S172 nothing re-checks it after the merge — then open the pull request, merge it, prune the branch", reversing the previous merge-then-verify order.

obeyed-check fidelity-reviewer rec 7 — implemented: ccd1b21 — the missing-`$RUDRA` branch of `verify-session-172.sh` swaps `echo "N/A…"; ok …` for `bad "AC7 sync-fleet-upgrades-a-real-project-cleanly — no project at $RUDRA to sync into; set VAJRA_SYNC_TARGET"`.

obeyed-check fidelity-reviewer rec 8 — implemented: ccd1b21 — both scripts' `check_live_gate` now use the identical `BIN="$(command -v vajra 2>/dev/null || echo "target/release/vajra")"` resolution, retry with the locally built binary when the resolved one does not emit the gate header, log `binary: $BIN`, and the FAIL text names the remedy (`cargo install --path . / brew upgrade`); the four other binary-resolving checks in `verify-closeout.sh` were aligned to the same line.

obeyed-check fidelity-reviewer rec 9 — implemented: ccd1b21 — `scripts/verify-session-172.sh:5` no longer claims "No check greens by grepping source" and instead discloses that source-reading checks exist and are named `*-wires-*`.

obeyed-check fidelity-reviewer rec 10 — implemented: 2261cae — adds residual-risk item 3 to the DECISION-007 S172 addendum: "The demo template WARNS against comparing with `main`; nothing enforces it. Older demo scripts in this repo still read `git show main:` (cold review rec 10)."

---

## What I ran, and what it printed

All of the below ran from `/Users/suman/playground/vajra` at `HEAD=b517ec1`. I wrote nothing to the repo; `git status --short` is unchanged (only the four pre-existing untracked files). Probe scripts and a separate `CARGO_TARGET_DIR` build live in the scratchpad.

- `bash /Users/suman/playground/vajra/scripts/verify-session-172.sh` → `=== Session 172 verify: 30 pass, 0 fail ===`, including `AC2 same-check-in-vajras-own-gate`, all seven `*-wires-*` checks, `AC4 the-tests-would-go-red-if-agent-detection-were-removed`, `AC7 cargo-test-green (528 passed)`, `AC7 cargo-fmt-clean`, `AC7 sync-fleet-upgrades-a-real-project-cleanly (6 files)`.
- `cargo test -q --lib releaser` → `21 passed; 0 failed`, including the new `shipped_close_prefers_origin_so_a_local_merge_does_not_count`.
- **rec 1, live** — on a fixture with an `origin/main` whose close is committed on local `main` only: the gate still blocks (`[vajra fidelity] session 02 cannot close`); after `git push origin main` it flips to `already merged by you — sessions/session-02-summary.md is on origin/main; reporting, not blocking.` On a remote-less fixture the message is `sessions/session-02-summary.md is on main — no origin/main ref to check against`. The DECISION-007 text and the code agree.
- **rec 2, live** — `vajra next --check-fidelity-handoff 172` in this repo exits 0 (`verdict: READY`); in a fixture with no handoff it exits 1 with `verdict: NOT READY` and names the missing `.ai/handoffs/session-172-fidelity-reviewer.md`. `check_live_gate`'s non-zero path calls `bad`.
- **rec 4, mutation probe** — I ran the AC2 `own` harness against a copy of `verify-closeout.sh` with the final `else echo "FAIL: $FIX"; bad "$NAME"` branch replaced by `ok "$NAME"`. Unmutated: `AC2 -> PASS`. Mutant: `AC2 -> FAIL (no block at all)`. I also ran the harness against `ccd1b21^`'s script and reproduced the review's diagnosis exactly — `RESULT=FAIL` came from `BLOCK: target/release/vajra not found`, i.e. the old check greened without ever running the binary.
- **rec 5, two-sided check** — same fixture, real `.githooks/pre-commit`: `commit BLOCKED` (so AC4 would report FAIL); mutated copy with `agent_shell=0`: `commit SUCCEEDED` (AC4 reports PASS). The control genuinely goes the other way.
- **rec 7, live** — `VAJRA_SYNC_TARGET=/nonexistent/no-such-project bash scripts/verify-session-172.sh` → `FAIL: AC7 sync-fleet-upgrades-a-real-project-cleanly — no project at /nonexistent/no-such-project to sync into` and `29 pass, 1 fail`.
- **rec 3, live** — `vajra next --check-advice 172` exits 0 with `verdict: READY`; every disposition resolves.

Four things I observed that sit beside the judgments rather than changing them:

1. `/Users/suman/playground/vajra/target/release/vajra` is dated Sep 18 and **predates all three of these commits** — it still prints the old `is already on main` message. `scripts/verify-session-172.sh` uses that binary by default, so the binary-driven checks in the 30/30 run above exercised a pre-fix build. I rebuilt into the scratchpad and re-ran the rec 1 probes against the fresh binary; the origin-preference behaviour is only present in the fresh build. (`verify-closeout.sh` now resolves `command -v vajra` = `/Users/suman/.cargo/bin/vajra`, which may be staler still — the rec 8 retry covers it only when `target/release/vajra` is itself current.)
2. rec 3's fix at `36c5725` left `tech-lead rec 3 — obeyed: PENDING_REVIEW`, which `advice::check_evidence` scores as no sha; that last line was filled with `da508e1` in `b517ec1`. Ten of the eleven prose dispositions were resolvable at the named commit, eleven at the tip.
3. rec 9's replacement header says "**Three** checks DO read source" — the live run emits **seven** `*-wires-*` checks (three `own-gate-wires`, four `project-gate-wires`). The false blanket claim is gone and the checks are named, but the count that replaced it is wrong.
4. rec 5's other half — "replace the count check with a check that binds the eleven cases" — was not built: the count check was deleted, and the mutation control never reads `tests/commit_belt.rs`, so emptying all six test bodies would still leave `AC4 the-tests-would-go-red-if-agent-detection-were-removed` green. Its name claims more than it tests. Relatedly, rec 10's literal target — Deliverable 3 in `/Users/suman/playground/vajra/prompts/172-task-keep-testing.md:68` — still reads "**The demo cannot rot at merge (F40)**"; the downgrade landed in the DECISION addendum (`2261cae`) and in `/Users/suman/playground/vajra/sessions/session-172-summary.md:117` (`da508e1`), which are the two places rec 10 named.

## Handoff Delta
- `~` re-run: qa-specialist handoff replaced (22187 bytes now vs 14437 bytes prior)
- prior stage: this session's earlier qa-specialist handoff
