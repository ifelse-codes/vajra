# Session 172 — keep testing rudra, fix what it finds

**Type:** CODE, interactive (the founder's own run, findings fixed in a short loop).
**Branch:** `session-172-keep-testing`. **Brief:** `prompts/172-task-keep-testing.md`.
**Verify:** `scripts/verify-session-172.sh` — 28 pass, 0 fail. **Demo:** `scripts/demo-session-172.sh`
— 14 live checks, all green. **Decision:** DECISION-007, S172 addendum.

## What happened

The founder ran his own project (`rudra`) session 03 end to end under Vajra and pasted the whole run
— including the parts where Vajra got in the way. Nine problems came out of it (F35–F43). All nine
are fixed. The carried item from S171 — an executable test for the commit/push split — is built.

**The one that mattered most (F39).** Starting a new session made him redo the *previous* session's
paperwork. `vajra next --advance` re-graded the session it was closing, but advance runs after that
session merged — sometimes under rules that arrived later. In rudra, session 03 could not begin
until session 02's advice answers and demo had been rewritten, days after session 02 shipped.

Now Vajra asks git one question: is this session's summary on main? If it is, the human shipped it,
and every closing check reports instead of blocking; the slow live re-runs of its tests and demo are
skipped entirely. The teeth moved earlier rather than away: the close check you run *before* merging
gained the three checks that only existed at the next session's start — advice answered, tests live,
and (in the copy every project gets) demo live. This session proved it on Vajra itself: S171 closed
light, with no reviewer handoff, and the counter moved with a report instead of a wall.

That rudra needed this was not theoretical: rudra's session 03 closed "ALL GREEN 17/17" while five
of its tech-lead's recommendations had no answer at all. The new pre-merge check catches exactly
that.

## Everything fixed

| # | What the founder hit | What changed |
|---|---|---|
| F39 🔴 | A merged session's paperwork blocked the next session | `releaser::shipped_close()`; closing gates report once the summary is on main; the close check gained advice + live verify (+ live demo for projects) |
| F35 🔴 | rudra's ten ADRs were invisible, so the citation check silently waived itself | `src/architect` reads `docs/ADR/` and `ADR-010-title.md`; a made-up id blocks; the role text agrees |
| F40 🟡 | Demos compared against `main` and inverted after the merge | the template WARNS against it (prose, unenforced — cold review rec 10) and pins "before" to the session's start commit; no demo re-run for a merged session |
| F41 🟡 | Closing took ~52 minutes of trial and error | the advance question when there is no keyboard, the `crew <role> — …` line format (a table reads as zero), and when to compute `Review-Inputs-SHA` |
| F36 🟡 | The agent was paused to re-read files it had already read | the loader reads the transcript and names only what is unread |
| F42 🟡 | The founder had to ask for plain English, three sessions running | the boot banner and `darshan/SKILL.md` demand plain words, results first |
| F37 ⚪ | Nothing said when to move the session number | the checklist names it, with the command |
| F38 ⚪ | The handover named a prompt file that does not exist | boot warns and suggests the real file (caught rudra's exact case) |
| F43 ⚪ | The agent guessed wrong about why main was unpushed | the ship check lists the unpushed commits by name |

**Carried item (S171 pass-3 rec 7): built.** `tests/commit_belt.rs` — 6 tests over the 11 cases the
qa-specialist settled, driving the real `.githooks` files in a temp repo. Disabling the hook's agent
detection turns 3 of them red. The same role found that `verify-session-93.sh` was passing only
because it ran inside an agent shell; it now says "agent" itself.

**F31 did not recur.** rudra's session 03 dispatched the tech-lead before any planning — the first
clean run after two failures. No gate was built, as the brief required.

**The fleet changed the work, for once.** rudra's plan-advisor caught a 22-vs-23 event-count error
in a locked spec (the founder ruled 23); its design-advisor corrected the tech-lead twice. Here, the
design-advisor's 7 recommendations rewrote this session's design record, and the qa-specialist's
case list corrected the brief's own "six cases" to eleven.

## What this does NOT claim

1. **The backstop is gone.** A skipped closeout used to be caught at the next session's start. It is
   not caught anywhere now. `scripts/verify-closeout.sh` must run on the branch before the merge — and
   this repo's own S171 finding is that text rules get skipped while gates do not. Named, not
   fenced (DECISION-007, S172 addendum).
2. **`shipped_close()` keys on one file, and on a ref.** It asks `origin/<main>` when that ref
   exists (the agent cannot push there) and falls back to local main when it does not — and a
   local merge runs no hook. Landing that summary early still downgrades the gates while a session
   is live. Self-granted jurisdiction, disclosed.
3. **Wider ADR discovery proves a record exists, never that the citation is apt.** The form floor
   from S67 is unchanged.
4. **One question is still open and was put to the founder twice:** an agent can commit without
   approval on a branch not named `session-NN-…`. Nothing was locked in either direction.
5. **`darshan/SKILL.md` reaches new installs only** — `--sync-fleet` does not carry it. Existing
   projects get the plain-words rule through the boot banner, which is the surface the agent
   actually reads.
6. **F44, found at this very close and NOT fixed:** the session guard reads a command's prose. A closeout note quoting the advance command in backticks armed the session boundary and blocked the write. Quoted strings are stripped before that scan; backticked ones are not. Worked around, recorded, left open.
7. **Three unexplained file changes** appeared in this repo mid-session (`.claude/settings.json`,
   `.gitignore`, a stray `.ai/hooks/`), consistent with a `vajra init` run inside Vajra itself. Not
   reproduced by the test suite or the S93 script. Kept in `git stash` and the scratch dir, not
   deleted, and flagged to the founder.

## The fakest green here

Named by the cold review, not by me: `AC2 same-check-in-vajras-own-gate` claimed to prove Vajra's
own close script blocks on a failing advice gate, and it was passing on the "binary not found"
branch instead — the fake `vajra` it set up was never consulted. It would have stayed green if the
blocking code were deleted. Fixed in this session: the check now requires the log line naming which
binary answered.

The runner-up is more consequential. The first draft of this session wrote into a LOCKED record that
an agent "cannot set" the shipped state. It can: with no `origin/<main>`, `git checkout main &&
git merge <branch>` fires no hook and no guard. The code now asks `origin/<main>` first, where
pushing is guarded, and the claim is corrected in the record. A locked record that overstates a
security property is worse than an unfenced risk, because the next session builds on it.

And the structural one stands: nothing checks that the close which produced a summary was ever
verified. A session merged without running `verify-closeout.sh` sails through every closing check
afterwards with a cheerful "reporting, not blocking".

## What the cold review changed

The review said ACCEPT and then handed over nine recommendations, two of them serious. Fixed before
the merge, not deferred:

- **rec 1** — the un-forgeability claim was false and sat in a locked record. `shipped_close()` now
  prefers `origin/<main>`; the claim is corrected in the record, the code comment and here.
- **rec 2** — the fidelity-handoff gate had the merged-session bypass and NO pre-merge mirror, so it
  was enforced nowhere. Wired into both close scripts.
- **rec 4** — the fakest green above.
- **rec 5** — the negative control the acceptance promised: a mutated copy of the real hook with
  agent detection disabled must let an unapproved agent commit, proving the cases bind on that code.
- **rec 6** — the checklist's last step told the agent to merge and THEN run the close check. Since
  this session that order is load-bearing; it now says branch first.
- **rec 7** — the sync check self-passed when no project existed to sync into. It fails now.
- **rec 8** — one binary resolution in both close scripts, with a fallback to the local build when
  the installed `vajra` is too old, and a FAIL message that says how to update.
- **rec 9** — the verify header claimed no check greens by grepping source; three do, and they now
  say so in their names.
- **rec 10** — "the demo cannot rot at merge" downgraded to what shipped: it is warned against.
- **rec 3** — was already fixed before the review landed (the close check caught it first).

## What the independent judge changed

Every `obeyed:` answer in this session was checked against its commit by a role that neither gave
the advice nor built the fix. Four things came back that I had got wrong:

1. **One MISMATCH.** I recorded the tech-lead's rec 5 as obeyed because the design-advisor was
   dispatched. The rec asked for the role to be MOVED to `required` with the founder's yes — the
   crew row still says `deferred-budget` and no approval was sought. Corrected to a `refused:` that
   says exactly that.
2. **The verify script was driving a stale binary** — `target/release/vajra` predated the fixes it
   was checking, and still printed 30/30. It now refuses to run against a binary older than `src/`.
3. **The header's new count was wrong** (three source-reading checks, actually seven), and nothing
   bound the eleven belt cases to the test file once the old count check was deleted. Both fixed.
4. **A wording downgrade was half-applied** — the deliverable still said the demo "cannot" rot.

A second judge (implementation-advisor) had to be brought in for the qa-specialist's own two
recommendations, because the Obeyed gate correctly refuses a role grading its own advice. That role
has no shell, so its two judgments are from reading the files, not from running them — it said so
itself, and this session did not re-run those cases under a third pair of eyes.

Left open, flagged by the judge and not fixed here: `scripts/verify-session-93.sh` is RED on two
`e2e-*-byte-identical` checks. They compare a fresh scaffold against this repo's files and are
stale, not broken — the scaffolded hook now carries a render stamp the repo copy does not, and the
guard path they check (`.ai/hooks/hook-commit-guard.sh`) does not exist here at all. Pre-existing,
unrelated to this session's commits, and an instance of the "old records under new rules" class
already on the board.

## Cost

Three specialist dispatches (tech-lead, qa-specialist, design-advisor) plus one cold review at
close. No paid rudra run was made by this session — the founder's own run supplied the findings.

## 3 ranked next candidates

1. **(Recommended) Session 173 — rudra session 04 with the fixes in.** Sync the nine fixes into
   rudra, run its next session end to end, and see whether the close now catches what it missed and
   the start no longer punishes the last one. This is the only way to find out if F39's fix helps or
   just moves the pain. Risk: it will surface more findings than one session can fix, as this one
   did.
2. **Session 173 — finish the 0.2.0 release.** crates.io is still 0.1.0. Nothing from S166–S172
   exists for anyone who is not on this machine, and the founder's own installed `vajra` is older
   than the binary this session built — which is why the counter refused to advance until the local
   build was used. Risk: release work shows the user nothing new.
3. **Session 173 — close the approval gap, and re-look at the one that opened.** Decide the branch
   question (an agent committing without approval on a non-`session-NN-` branch), and add the
   end-to-end falsifiability case the design-advisor asked for: a whole `verify-closeout.sh` run
   that goes red when advice is unanswered. Risk: this is work on Vajra's own rules, which the
   founder has said to stop doing unless a user is on the other end.
