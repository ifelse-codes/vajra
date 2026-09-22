# Session 173 — keep using Vajra in rudra, fix what it finds

**Type:** CODE, interactive (the founder's own run; findings collected during it, fixed after it closed).
**Branch:** `session-173-keep-testing`. **Brief:** `prompts/173-task-keep-testing.md`.
**Verify:** `scripts/verify-session-173.sh` — 84 pass, 0 fail. **Demo:** `scripts/demo-session-173.sh`
— 18 live checks, all green. **Decision:** DECISION-007, S173 addendum.

## What happened

The founder ran rudra's session 04 end to end under Vajra: it went from choosing the session through
plan, build, independent review (ACCEPT 12/12) and merge (rudra PR #5) in about two hours, 75 minutes
of it active work. His new rule for this session: collect every finding while rudra runs, and fix
them only after it closes. Eleven came out (F45–F55), plus two this session hit on itself (F56, F57).
Nine are fixed in code, F48 by the new step order; F47, F56 and F57 are parked LOW; F50 is not
fixed in code (see below).

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
| F50 | The session guard read a heredoc commit message as a command (F44, live) | 🟡 MED | **not fixed in code** — four fixes each failed review; the block now says `git commit -F <file>` |
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
| 4 | Guards not loosened; F50 handled by the block message (F50/F44) | PARTIAL (by decision) | rudra's commit still blocks, as before S173; the block names `git commit -F`; old-vs-new: 0 of 120 listed commands newly allowed. Passes 1–6 each broke a fix — see below |
| 5 | The close in order up front (F53, F54) | SHIPPED | verify AC6: advice step, then stamp LAST, then merge; formats named (unit test) |
| 6 | The agent ships its own branch (F55) | SHIPPED | verify AC7: the allowed shapes pass; merge, main, force, delete, tags, other branches, joined/repeated `--head`, and every form both reviewers named go back to the human |
| 7 | Sync says whose files it wrote (F49) | SHIPPED | verify AC8 on a rudra clone |
| 8 | F48 checked, not built | SHIPPED (as a check) | rudra S04 wrote `prompts/05-…` before its merge (`1bad1cb` in rudra) |
| — | Carried: F44 | NOT FIXED IN CODE | = F50; handled by the block message |
| — | Carried: unexplained file changes in S172 | NOT SEEN | did not recur this session; nothing to trace |
| — | Carried: watch F31 | CLEAN | rudra S04 transcript: tech-lead dispatched 14:36, before design and plan |

## What the cold review changed

**Pass 1: REJECT** (13 SHIPPED · 4 PARTIAL). My F50 fix taught both guards to ignore message text,
but it ignored too much: with no approval at all, `cat <<EOF >/dev/null; git push -f --no-verify
origin HEAD:main` got through — blocked before this session. One of my own verify checks
("backticked-mention-passes") recorded that hole as a PASS.

**Pass 2: REJECT** (14 SHIPPED · 3 PARTIAL). I had patched pass 1's examples with a cleverer,
bash-like scanner; a fresh reviewer found new spellings of the same hole (an unquoted heredoc whose
body runs `$( )`, `cat <<EOF | bash`, an empty heredoc, an apostrophe in a comment) and a merge that
rode the new push permission inside a PR body's `$( )`. Its point was the real one: fixing the named
examples, pass after pass, is the loop.

**What changed after pass 2 — the approach, not the examples.** The guards read commands the way
they did BEFORE this session (so nothing can newly slip through), plus one narrow exception — the
`"$(cat <<'EOF' … EOF)"` message shape, in which bash runs nothing — plus an addition that only
ever blocks more (they also read `$( )`, backticks and `eval`/`sh -c` strings, closing holes that
predate S173). The push permission reads the raw command: any `$`, backtick, backslash or line
break sends it to the human. And the verify script now tests the PROPERTY: 15 shapes × 4 triggers
through the old hooks and today's — 0 of 60 went from blocked to allowed, 0 of 60 merge/main forms
rode the approval. rudra S04's four real push/PR commands pass with the approval.

**Pass 3: REJECT** (12 SHIPPED · 5 PARTIAL). This time the approach held and the flaw was inside the
one exception: its body pattern could run past an early `EOF` line and hide the commands bash runs
after it — with no approval, and inside an approved `gh pr create` body. Fixed the rule (no line
inside the hidden span may look like the delimiter, so it ends where bash ends it or earlier), and
added the shape to the before/after check first: it went red on 12 commands with the old exception,
green after.

**Pass 4: REJECT** (13 SHIPPED · 4 PARTIAL). Two gaps: the exception's "everything before it is
properly quoted" test only COUNTED quote marks, so a prefix with an even count while bash was still
inside a quote let the span hide a line bash runs; and the new allow path refused `-R other/repo`
but not the glued `-Rother/repo`. Fixed: the exception now needs a plain `git commit`/`gh pr create`
opening its line with nothing quoted before it at all; `-R` in any spelling is refused. Both
reviewer cases went red on the pass-4 code (exit 0) and green now. Also: the boot check now proves
the to-do list printed, the check is labelled "old vs new on a listed set" rather than a property,
and a piped `n` stops an advance again.

**Pass 5: REJECT** (15 SHIPPED · 2 PARTIAL). Two things: the push permission read the project
folder's branch, not the branch of the folder the command runs in (an agent in a worktree could push
another session's branch); and on macOS `/bin/bash` 3.2 the message exception still hid a push —
confirmed on this machine. I had said a fifth hole in the exception would end it, so **the exception
is gone**: the guards read commands exactly as before S173, plus the extra reads. F50 is therefore
not fixed in code — rudra's commit would still block — but the block now says the way out
(`git commit -F <file>`). The push permission now checks the command's own directory.

**Pass 6: REJECT** (15 SHIPPED · 2 PARTIAL). R1 confirmed fixed. Two new small holes in the "extra
reads only add" rule: a decoy `$(echo checkout -b session-01-a)` could displace the real session
number and let an advance through; and with no `perl` installed both guards exited 127 — which
Claude Code does not treat as a block. Fixed: the extra reads are kept apart and only ever add a
reason to block; no perl means the pre-S173 rule alone. Both went red on the pass-5 code and green
now. 30 shapes × 4 triggers = 120 commands; 84 checks in all.

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

**The before/after check is 120 named commands, not bash's grammar.** It is far stronger than the
example lists passes 1 and 2 caught — it compares the whole old rule to the new one on every shape
at once — but its 30 shapes are the ones six reviewers found, and passes 3–6 each found one the
earlier list missed. A 31st spelling no one has tried is not covered.

Also: **verify AC7's allow cases are the ones I thought of plus the ones two reviewers named.** They
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
