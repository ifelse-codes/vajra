# Session 184 — Independent Fidelity Review

**Method controls:** I did not build this work and wrote no code. My inputs were the contract `prompts/184-task-rudra-s17-new-rules.md`, the branch diff `.ai/verify/session-184/branch.diff` (e1c348e...HEAD) and `verify.out`. I read `sessions/session-184-summary.md` only because the dispatch named it as the findings-table input. Every claim it makes was checked against the diff or the code. I also opened `src/cli/init.rs`, `src/obeyed/mod.rs` (lines 441–538), `scripts/verify-closeout.sh` (lines 42–50 and 1241–1395) and `scripts/verify-closeout-scaffold.sh` (lines 623–692 and 953–1085), plus the in-repo scripts that pipe answers into `vajra init`. I went in assuming the builder had re-scoped to whatever goes green.

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| D1 | F103, F107, F108 fixed; a findings list from rudra S17 (F109…), each with evidence and the founder's call | SHIPPED | **F103:** `src/cli/init.rs` adds `PIPED_ANSWER_WAIT` (10 s, ~l.1228) and `struct Answers` (l.1235–1313). The terminal path is still a plain blocking `read_line` (l.1284–1291). Any other stdin gets one reader thread and an `mpsc` channel, with `recv_timeout`. The first `Timeout` or `Disconnected` sets `gave_up`, and every later question then short-circuits to its default (l.1294). Each default is named on stderr. A late line stays in the channel and is never read. A read error still surfaces as "failed to read input", exactly as before. **F107:** `src/obeyed/mod.rs` l.509 and l.520–528 rewritten with no session number and no "threshold". **F108:** `case --inputs-sha\|--ledger\|--ledger-verify` → `mktemp -d` plus an EXIT trap, in both close scripts (l.46–50). **Findings:** F109–F113 are in the summary table, each with evidence and a founder call. |
| D2 | Fixes for every finding the founder says yes to, each with a test that fails without it | SHIPPED | F103, F107 and F108 each have a check that is run against the e1c348e binary or scaffold and goes red there for the named reason (see AC2). F110 and F113 got a founder "fix", but he scheduled both after the S185 review session, which forbids code. They are on S185's list in `prompts/185-task-ground-truth.md`. Named, not closed. Graded against the scope the founder kept for this session. |
| AC1 | Every finding has evidence and a founder call recorded in the summary | PARTIAL | F103/F107/F108 and F109–F113 all have evidence and a call. Two defects seen in this session have no number and no founder call. (a) `verify-session-132.sh` check `advance-really-binds-on-an-unjudged-obeyed` is red at e1c348e and at HEAD. It is only disclosed in the summary's "fakest green" section and the S185 prompt, l.40 ("not yet explained"). That check is about whether the obeyed gate really stops `--advance`. (b) The scaffold's `--ledger` exits 1 in a project with no review files, and nobody noticed. Under `set -euo pipefail`, `list="$(_ledger_worktree_sessions)"` (scaffold l.1075) runs `ls sessions/session-*-review.md`, which fails, so the script aborts before printing anything. verify-184's own PASS line reports "same exit (1)" without comment. |
| AC2 | Every fix has a real-run check in verify-184 (no source greps) that fails without it | SHIPPED | No source greps anywhere in `scripts/verify-session-184.sh`. **F103** (l.39–44): a FIFO held open 60 s. The new binary finishes in ≤20 s with `my-project` and the exact stderr line; the e1c348e build (a real worktree at l.20–22) is still waiting at 25 s. **F107** (l.72–85): a real `vajra init` project with one unchecked claim and a full close run. The new log and gate output have no `132`/`threshold`; the old binary prints `threshold: session 132`. **F108** (l.95–103): folder counts, where the old scaffold (pulled with `git show e1c348e:`) adds 1 folder per mode and the new one adds 0. The controls (piped answers, the `script(1)` terminal check with a 12 s answer past the 10 s wait, a full close still writing its folder) catch regressions. Caveats: the "same output" half of the project `--ledger` check compares two runs that both abort silently (see Fakest green). `verify-session-143`, which the prompt's F103 test line names, is never re-run anywhere in the diff. The piped-answer check (l.50–55) uses the same input, so the path is covered, but the named script is not. |
| AC3 | No Vajra commit touches rudra; rudra's commits are the founder's | SHIPPED | Every path in the diff is a Vajra path (KNOWLEDGE, ROADMAP, the .ai files, the approval, 3 handoffs, prompts 184/185, the scripts, the summary, `src/cli/init.rs`, `src/obeyed/mod.rs`). The scratch projects live in `mktemp` folders only. The half about rudra's commits cannot be checked from these inputs: it rests on the summary's statement (rudra HEAD b626e79 is the founder's merge of #20; the S17 commits were made under his `VAJRA_ALLOW_COMMIT=17`). |
| AC4 | `verify-closeout.sh` exits 0 on the branch before merge; one fresh cold review | PARTIAL | This file is the one fresh cold review. The gate run, and its `scripts/ci-lint.sh` row, are not in my inputs. That part can only be graded at close, when `verify-closeout.sh` runs on the branch after `--inputs-sha 184` is stamped. The summary's claims of "565 lib tests" and "ci-lint clean" have no evidence in the diff. |

**4 of 6 SHIPPED** · 2 PARTIAL · 0 NOT-BUILT.

**Probes, answered:**
- **F103 thread design is correct.**
  - A late line is dropped: once `gave_up` is set, `rx` is never read again. The unit test `piped_silence_waits_once_then_defaults_every_later_answer` would go red if that short-circuit were removed.
  - An error behaves as before: `Err` is sent and comes back through `?` with the same context.
  - End of input gives `Disconnected` and a named default.
  - The terminal path is unchanged; `is_terminal()` decides which path runs.
  - The reader thread keeps the stdin lock for the life of the process. Nothing later in `init` reads stdin: the only child that inherits stdin is `git config` via `.status()`, and it does not read it. So it is harmless.
  - Visible change: every `</dev/null` and short-pipe user now sees `(default — the piped input ended)` on stderr. No in-repo script matches that stderr text exactly.
- **F108 changes no output or exit code.** Neither ledger mode reads `$ARTIFACTS`. Both exit before the `latest` symlink (l.1386) and the `Artifacts:` line.
- **F107's new wording is true wherever it is printed.** `warnings` is filled only on the pre-threshold `Unjudged` branch (l.498–512), which never blocks, so "does not block on them in this session" holds in Vajra's repo and in a project. But it is true because it now says less. The old text "(threshold: session 132)" was literally accurate for a project, because the gate counts the project's own sessions (F113). Now a project at its own session 131 gets no warning that session 132 will block. Two other things went stale with the reword:
  - The comment at `obeyed/mod.rs:517` still says the exemption is "stated ONCE and out loud rather than buried in a constant", but the number is no longer printed.
  - `verify-session-132.sh`'s check `pre-threshold-warns-and-names-the-exemption` was re-pointed at the new words and no longer checks that the exemption is named.
- **Claims not backed by the diff:**
  - Plan step 5 and the demo scorecard say verify-184 has "14 real-run checks, each red at e1c348e". At least checks 3 (piped answers), 5 (terminal), 12–13 (Vajra's own gate, never run against the old script) and 14 (control) would pass at e1c348e or never ran there. Each *fix* has a differential check; each *check* does not.
  - `demo-session-184.sh` l.79 says "Four findings, all rudra's own (F109–F112)". F110 is Vajra's own guard, and F113 is left out. The demo's own closing note (l.140) contradicts it.
  - The demo table (l.105) says `--ledger` "print[s] their result". In a fresh project it prints nothing and exits 1.

## Fakest green

The F108 project-gate check, `PASS: F108 project gate --ledger: no folder now (the e1c348e gate added 1); same exit (1) and same output` (verify-184 l.95–103).

The folder half is real. The "same exit, same output" half is supposed to prove F108 changed nothing else, but it compares two runs that both died. In a project with no review files, the scaffold's `--ledger` hits `set -e` on `list="$(_ledger_worktree_sessions)"`: the `ls` of a glob with no match fails under pipefail (scaffold l.973–975, l.1075). So the script exits 1 before printing the ledger, at e1c348e and at HEAD alike. `cmp -s` of two crashed runs passes. It would pass even if `--ledger` were deleted outright, and it printed a read-only display command's exit 1 as normal, so a real project-facing defect slid by inside a PASS line.

Runner-up: verify-184 check 9 ("Vajra's S132 checks … still pass") greps three chosen rows from `verify-session-132.sh` rather than that script's exit code. That is how a verify script with a known red check (`advance-really-binds-on-an-unjudged-obeyed`) reads as green here.

## Recommendations

rec 1 — Record the fresh-project `--ledger` silent exit 1 as a numbered finding with evidence and get the founder's call.
In a `vajra init` project with no `sessions/*-review.md`, `bash scripts/verify-closeout.sh --ledger` exits 1 and prints nothing (scaffold l.1075, `set -euo pipefail` plus an `ls` that matches nothing). verify-184's own PASS line shows "same exit (1)". It is likely a one-line fix (`|| true`, as `_ledger_read` already does), but per AC1 it needs a number and a call first. Putting it on the S185 list is enough.

rec 2 — Give the red `verify-session-132.sh` check `advance-really-binds-on-an-unjudged-obeyed` a finding number and a founder call, not just a disclosure line.
It is red at e1c348e and at HEAD, and it is the check that shows the obeyed gate really stops `vajra next --advance`. Today it lives only in the summary's "fakest green" paragraph and an unnumbered line in the S185 prompt. Verify-184 also reads that script by cherry-picking three rows. Name it so S185 has to answer it.

rec 3 — Correct three prose overclaims, or carry them to S185 if a change now would mean re-stamping.
These are: Plan step 5 and the demo scorecard ("14 real-run checks, each red at e1c348e"; true per fix, not per check), demo l.79 ("Four findings, all rudra's own (F109–F112)"; F110 is Vajra's guard and F113 is missing), and demo l.105 ("--ledger … print their result"; false in a fresh project, see rec 1). Editing the prompt or a script changes the attested inputs, so do it before `--inputs-sha 184` or list it for S185.

rec 4 — When F113 is fixed, also restore the honest disclosure F107 removed: the comment and the S132 check name that now overclaim.
The comment at `obeyed/mod.rs:517` still says the exemption is "stated out loud", and `pre-threshold-warns-and-names-the-exemption` no longer checks that the exemption is named. A project at its own session 131 now gets no hint that session 132 will block (F113). This should be part of F113's fix in S185, not a separate session.

rec 5 — Run `scripts/verify-session-143.sh` once and record the result, or say plainly it was not run.
The prompt's own F103 test line ends "verify-session-143 still green", and nothing in the diff shows it ran. The piped-answer check in verify-184 covers the same input, so this is most likely green, but the named script should be shown.

Is the real scope one narrow slice presented as the whole? No. All three pre-approved fixes are really built and each is checked against the old build. The rudra S17 findings are recorded with the founder's calls. The gaps are naming gaps (two defects without a number or call) and prose overclaims, not hollow deliveries.

## What the builder did with the recommendations (added after the review; answers also in the prompt's `## Advice`)
- rec 1 — F114 numbered, reproduced by hand (rc=1, no output; rc=0 once a review exists); founder 2026-10-04: **fix later** → S185 list. verify-184's F108 check now commits one review first and requires exit 0 and non-empty output from both runs.
- rec 2 — F115 numbered → S185 list ("stale check or real regression?").
- rec 3 — the three overclaims corrected before the stamp: plan step 5 and the demo scorecard ("each fix has one that is red"), demo story (five findings: three rudra's, two Vajra's), demo rule row (names F114).
- rec 4 — added to F113's item in `prompts/185-task-ground-truth.md`.
- rec 5 — `scripts/verify-session-143.sh` run at close: 13 passed, 0 failed, RESULT: PASS.

## Obeyed claims — two independent judges (added at close)
- **Recorded judge:** the release-coordinator (`.ai/handoffs/session-184-release-coordinator.md`) judged all 16 `obeyed:` answers: 16 of 16 `implemented` after two answers were re-cited (design-advisor rec 2: a0c1417 → 302f923, the commit that wrote the `## Design` deviation; plan-advisor rec 3: 302f923 → d396daf, which pastes the real `git diff --name-only` output in place of a hand-typed list that missed KNOWLEDGE.md). `vajra next --check-obeyed 184`: READY, unjudged 0.
- **Second judge, not recorded as a handoff** (a fresh fidelity-reviewer dispatch; recording it would have replaced the review's own handoff above): 8 of 11 advisor answers `implemented`. Its three mismatches: design-advisor rec 2 and plan-advisor rec 3 — both fixed by the re-cites above; and **tech-lead rec 1 (b6c15c8)** — the commit has the fix but not the folder-count test the rec also asked for (that test is in 3170809, strengthened in f6ea7d6). The recorded judge graded the same answer `implemented` and named the same split. Left as is: the fix and its test both landed; the answer cites the fix.

**Verdict:** ACCEPT

**Review-Inputs-SHA:** 2fa75470f4603632944b4ef3154c69e22719f91d7d6634795628e1c9119d55b3
