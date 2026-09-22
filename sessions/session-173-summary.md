# Session 173 — keep using Vajra in rudra, fix what it finds

**Type:** CODE, interactive (the founder's own run; findings collected during it, fixed after it closed).
**Branch:** `session-173-keep-testing`. **Brief:** `prompts/173-task-keep-testing.md`.
**Verify:** `scripts/verify-session-173.sh` — 63 pass, 0 fail. **Demo:** `scripts/demo-session-173.sh`
— 17 live checks, all green. **Decision:** DECISION-007, S173 addendum.

## What happened

The founder ran rudra's session 04 end to end under Vajra: it went from choosing the session through
plan, build, independent review (ACCEPT 12/12) and merge (rudra PR #5) in about two hours, 75 minutes
of it active work. His new rule for this session: collect every finding while rudra runs, and fix
them only after it closes. Eleven came out (F45–F55), plus one this session hit on itself (F56).
Ten are fixed; F47 and F56 are parked as LOW.

**What worked, first.** The tech-lead was called first, before any planning — F31 is now clean four
runs in a row. The agent waited for his OK on the plan before writing code. Session 03 was reported
on, not re-graded (S172's F39 fix, holding). And the agent wrote session 05's plan *before* the
merge, because the to-do list now puts that step there — so F48's "whole extra chat just to write
the next plan" did not recur.

**What did not.** Vajra's own start-up crashed halfway on rudra (F45 — last session's fix). A guard
blocked a commit because its *message* quoted a Vajra command (F50 — carried F44, hit live). Vajra
asked "Advance? y/N" and the agent answered it itself (F52). The close redid its paperwork: the
review stamp four times (F53), 38 advisor answers in three rounds (F54). And at the end the founder
typed `git push` and a long `gh pr create` by hand (F55).

## Everything found

| # | What happened | Severity | Now |
|---|---|---|---|
| F45 | Start-up died when the handover names no plan file — branch, commit rule and to-do list never printed | 🔴 HIGH | fixed `42e608c` |
| F46 | The to-do list sent the agent back to redo session 03's ACCEPTed review | 🟡 MED | fixed `c28b4f1` |
| F47 | Options copied from a summary keep its jargon; the plain-words rule reaches only the agent's own sentences | ⚪ LOW | **parked** |
| F48 | The next plan was written on `main` after the merge, costing a chat and a hand-typed commit | 🟡 MED | resolved by the new step order — seen working in rudra S04 |
| F49 | A sync left a file uncommitted on main through a whole session, called "your change" | ⚪ LOW | fixed `8b43a27` |
| F50 | The session guard read a heredoc commit message as a command (F44, live) | 🟡 MED | fixed `5e30be9` |
| F51 | A merged session's leftovers printed as ~70 lines under "cannot close" | 🟡 MED | fixed `c28b4f1` — one counted line per check |
| F52 | A `y/N` only the agent saw; the to-do list told it to pipe `y` | 🟡 MED | fixed `c28b4f1`, `0593349` |
| F53 | The review stamp redone four times — nothing said "last" | 🟡 MED | fixed `5e2c2b7` — its own step, LAST |
| F54 | 38 advisor answers met only at the close check, failed twice on format | 🟡 MED | fixed `5e2c2b7` — a step with the exact format |
| F55 | He hand-typed push and PR every session | 🟡 MED | fixed `00fdca9`, `c222516` — his pick B |
| F56 | Vajra's own session guard, in THIS repo, blocked a command that ran an advance inside a *copy of rudra*: it cannot tell a command runs in another project | ⚪ LOW | **parked** (found at close) |

**F55, the one that changed a rule.** Given three options, he picked B: the launch approval
`VAJRA_ALLOW_COMMIT=NN`, which already lets the agent commit on `session-NN-*`, now also lets it push
that branch and open its PR. Merging stays his. The first version listed *forbidden* pushes; the
design-advisor broke it a dozen ways (another session's branch via `HEAD:session-05-y`, a force in
`-uf`, a force in quotes, a GitLab push option that merges). It is now an *allow-list* of exact
shapes — anything else goes back to the human — and every form the advisor named is a failing case
in the verify script.

## Fidelity — every deliverable

| # | Deliverable | Status | Evidence |
|---|---|---|---|
| 1 | Boot survives a handover naming no prompt (F45) | SHIPPED | verify AC1; demo before/after runs the old hook from `f02d8e1` (exit 1) against today's (exit 0) |
| 2 | Merged session not sent back, walled or re-graded (F46, F51) | SHIPPED | verify AC2 (unit test + rudra clone), AC3 (rudra at `3c401ec`: counts, no per-item `✗`; S05's design reason still in full) |
| 3 | No fake question (F52) | SHIPPED | verify AC4 (advance on rudra with no terminal says it did not ask; unit test: no step says `echo y`) |
| 4 | Guards read commands, not prose (F50/F44) | SHIPPED (pass 2) | verify AC5: rudra's exact heredoc commit and a quoted mention pass; real, piped, backticked, `$( )`-in-quotes, heredoc-opening-line, `bash -c` and heredoc-fed-to-bash advances blocked. Pass 1 was PARTIAL — see below |
| 5 | The close in order up front (F53, F54) | SHIPPED | verify AC6: advice step, then stamp LAST, then merge; formats named (unit test) |
| 6 | The agent ships its own branch (F55) | SHIPPED | verify AC7: the allowed shapes pass; merge, main, force, delete, tags, other branches, joined/repeated `--head`, and every form both reviewers named go back to the human |
| 7 | Sync says whose files it wrote (F49) | SHIPPED | verify AC8 on a rudra clone |
| 8 | F48 checked, not built | SHIPPED (as a check) | rudra S04 wrote `prompts/05-…` before its merge (`1bad1cb` in rudra) |
| — | Carried: F44 | SHIPPED | = F50 |
| — | Carried: unexplained file changes in S172 | NOT SEEN | did not recur this session; nothing to trace |
| — | Carried: watch F31 | CLEAN | rudra S04 transcript: tech-lead dispatched 14:36, before design and plan |

## What the cold review changed

**Pass 1: REJECT** (13 SHIPPED · 4 PARTIAL · 0 NOT-BUILT). The finding that mattered: my F50 fix
taught both guards to ignore message text, but it ignored too much. It hid backticks, `$( … )`, the
rest of a heredoc's first line and multi-line `bash -c` strings — all things bash RUNS. With no
approval at all, `cat <<EOF >/dev/null; git push -f --no-verify origin HEAD:main` now got through,
and it had been blocked before this session. And one of my own verify checks
("backticked-mention-passes") recorded exactly that hole as a PASS — its fakest green.

What changed: both guards now read a command left to right the way bash does (single quotes and a
heredoc's body are prose; everything bash would execute stays visible); `bash -c` and `eval`
strings are read whole; the `gh pr create --head` rule takes exactly one plainly spelled head; the
fakest-green check now expects a block. The review's forms are 15 new verify cases — 63 in all.
Fixing it tripped Vajra's own guard in this repo twice (a heredoc mentioning `bash -c`), which is
the new rule over-blocking on the safe side; the second time led to one more refinement (a
heredoc's body is hidden BEFORE the `-c` rule looks, unless the heredoc is fed to a shell).

## What this does NOT claim

1. **The push permission is a text match.** It closes the forms the design-advisor listed, not every
   way to reach a remote. Forms the guard never recognises as a push at all (`git -c k=v push`, a
   git alias, a variable like `$G push`) were open before this session and still are — they get neither the new permission
   nor a block. An upstream pointed at main earlier makes a plain `git push` land on main; the
   pre-push hook blocks an agent pushing main as a second lock, except under `--no-verify` (which the
   allow-list refuses, but an unrecognised form could carry). All in DECISION-007's S173 addendum.
2. **It was never exercised by a real rudra run.** F55 was built after rudra S04 closed. The verify
   script drives the real hook with every listed command; the next rudra session is the first real use.
3. **With no terminal, `--advance` now proceeds for CI and scripts too**, not only agents. In a chat
   the session guard is the control; nothing checks that the human OK'd a plan.
4. **The 38 answers are still 38.** F54 made them easier to get right, not fewer. Cutting how many
   advisor recommendations need an answer is a rule change and is the founder's call — not taken.
5. **F53's fix is an instruction, not a mechanism.** The to-do list says "stamp LAST"; the hash still
   moves on every later edit. Changing what the hash covers was rejected: it would break
   verification of every past review.

## The fakest green here

**Verify AC7's cases are the ones I thought of plus the ones two reviewers named.** They
prove the allow-list does what it says for those strings; they do not prove there is no other
string that reaches a remote. The honest claim is "the forms we know about go back to the human",
not "the agent can only push its own branch".

## Cost

Two specialist dispatches (tech-lead, design-advisor) plus one cold review at close; seven roles
deferred by the tech-lead with reasons. No paid rudra run by this session — the founder's own run
supplied the findings, read from its transcript on disk rather than pasted.

## 3 ranked next candidates

1. **(Recommended) Session 174 — rudra session 05 with these fixes in.** Sync into rudra, launch with
   `VAJRA_ALLOW_COMMIT=05 vajra claude`, and run its session 05 (async directive monitors) end to
   end. First real test of the agent shipping its own PR, the stamp-LAST order and the shorter close.
   Collect findings during the run, fix after, as this session did. Risk: more findings than one
   session can fix.
2. **Session 174 — finish the 0.2.0 release.** crates.io is still 0.1.0; nothing from S166–S173
   exists for anyone not on this machine. Risk: release work shows the founder nothing new.
3. **Session 174 — cut the close's paperwork.** 38 advisor answers per session is the biggest
   remaining ceremony: answer only the final review's recommendations and the tech-lead's, and let
   the others stand as advice. Risk: it loosens the S127 "no silent drop" rule, which needs the
   founder's yes.
