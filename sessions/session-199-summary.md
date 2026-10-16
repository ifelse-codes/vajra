# Session 199 — every pending known bug

**Branch:** `session-199-all-pending-bugs` · **Type:** CODE · **Start commit:** `027e70f` · **Prompt:** `prompts/199-task-all-pending-bugs.md`

## Goal achieved?

Yes. All nine items on the prompt's list are fixed, in its order, with nothing moved out under the split rule
(~1h20 of work). Each fix has a verify row that runs the real thing and, where a binary is involved, runs it again
with the binary from `027e70f`, where it goes red. ROADMAP's known-bug list now holds only the named guard limits
(F123/F127 routes, kept by the founder's 2026-09-15 rule) and one new LOW finding, N22.

## What shipped

| Fix | What a user sees now | Commits |
|---|---|---|
| **F126** | A real run first (a throwaway checkout: stamp, edit, commit, stamp again): a new next-session prompt, a summary edit and `.ai/` TASK/STATE/ROADMAP edits **leave the review's stamp alone**; this session's own prompt, a new handoff and any code **move it**. So the rudra S21 agent's "changing it now would undo today's sign-off" was wrong, and no new rule is needed. The step list now says it: the push step tells the agent a late change from the human goes into git, never only into its own memory — the next prompt, the summary's pick line, `.ai/TASK.md` — which do not move the stamp, then one more close run; the stamp step names exactly what moves it. | `b63e349` |
| **Sign-off step** | On a review-only session `vajra next --steps` has "the founder has signed off this review-only session's report" — ✗ until `.ai/approvals/session-NN-close.json` counts, ✓ after; while that record is not in the last commit the step names it ("… is not in git yet; commit it with this session's work"). "Review-only" is the shared helper's answer (`vajra_is_ground_truth`), the same one the guard acts on. | `b63e349` |
| **N19** | `vajra next --advance` keeps each line's own ending in SESSION-BOOT and TASK.md: a CRLF file stays CRLF on the F118 move, the number swap and the prompt-pointer rewrite (new lines take the `## Current Session` line's ending). | `df7bc11` |
| **N20** | The prompt-pointer rewrite stops at the first `## Prior Session` heading, so an old entry's "Read prompt `…`" is never rewritten. A file with no such heading (TASK.md) is read whole, as before. | `df7bc11` |
| **N21** | With two `prompts/NN-task-*.md` for one session, `vajra next --advance` refuses before writing anything: "session 07 has 2 prompt files (…, …) — which one is the session's is not something to guess. Keep one and remove the others"; `vajra next --steps` (and so the boot) leads with "✗ this session has ONE prompt — it has 2: …", live and at a merged session's hand-over. The shared lookup (`analyst::find_prompt_for`) now reads the first by name, never `read_dir` order. | `e572057` |
| **N14** | A new ground-truth question, owned by the existing `constraint_violation_review` audit: "for each session since the last ground truth, read its newest `.ai/verify/closeout/<stamp>/result` … and what the summary and the agent told the human at close. Did they match?" A new block, so a fresh `vajra init` has it and `vajra init --sync-fleet` adds it to an existing project. A question, not a gate. | `c2a11bd` |
| **`latest`** | The founder saw the folder (732 broken self-links + 12 logs from 2026-08-03, 52 KB, untracked) and said yes (2026-10-16). It is now a link to the newest run (`20261015T100751Z`); the next close repoints it. Local only — nothing in git. F121 reads the stamp folders, not `latest`. | (local; proven by verify row 7, `c3cad24`) |
| **gt_cadence_shared** | `announces_gt()` counts only the hooks' own announcement line for that session. A new test puts "ground truth" in a non-ground-truth session's boot output — the words are there, the old whole-output match would read them as an announcement, the new one does not. | `c19800d` |
| **N7 (rest)** | verify-176/178/179 and demo-176/178/179/184/186 take their old-version checkout from `scripts/lib-old-checkout.sh`; none makes its own. All eight were run after the change; no checkout was left. | `93b706b` · `c38ea5b` · `8216bf5` |

**Evidence:** `scripts/verify-session-199.sh` 9/9 (`c3cad24`). Row 1: the real stamp in a throwaway checkout (5
late edits "same", own prompt "moved") + the step-list test (absent at `027e70f`). Row 2: a `vajra init` project at
review-only session 10 — ✗, then ✓ naming the close record, then ✓ after the commit; no such step from `027e70f`'s
binary. Rows 3–4: a CRLF Vajra-shaped SESSION-BOOT + TASK.md and a CRLF `vajra init` SESSION-BOOT, advanced — every
line still CRLF, the Prior line byte-identical, the pointers moved; `027e70f`'s binary made them LF and rewrote the
Prior line. Row 5: two session-07 prompts — exit 1 naming both, `.ai/SESSION` unchanged, the ✗ step; `027e70f`
advanced. Row 6: fresh init has the question; removed + `--sync-fleet` adds it; `scaffold-drift.sh` exit 0 (20/0 when run by hand; the row prints only a tail line);
absent from `027e70f`'s init. Row 7: `latest` is a link to a run folder. Row 8: the new test (absent at `027e70f`)
and the file's 6 tests. Row 9: the eight scripts source the helper and none runs `git worktree add`; verify-176
rebuilt its old binary through it (a private checkout folder), exit 0, 0 left.
`scripts/demo-session-199.sh` 5/5 live checks. Full `cargo test` 743 passed / 0 failed (summed from `^test result` lines only); `scripts/ci-lint.sh` exit 0.

## Fidelity map

| Prompt item | Grade | Evidence |
|---|---|---|
| D1 / AC1 F126 | SHIPPED | the real stamp run (verify row 1, and the first run recorded in this session's chat); step-list words in `b63e349`; no rule changed, so no founder quote needed and design stays `no` |
| D2 / AC2 sign-off | SHIPPED | verify row 2; unit test `a_review_only_session_has_the_founders_sign_off_step` checks the `vajra approve 10 --close` wording (`--steps` prints a step's "how" only for the first open step) |
| D3 / AC3 N19 | SHIPPED | verify row 3; unit test `update_session_boot_keeps_crlf_on_both_shapes` |
| D4 / AC4 N20 | SHIPPED | verify row 4; unit test `update_prompt_pointer_leaves_prior_entries_alone` |
| D5 / AC5 N21 | SHIPPED | verify row 5; unit test `two_prompts_for_one_session_are_named_not_picked` (live list and hand-over) |
| D6 / AC6 N14 | SHIPPED | verify row 6 |
| D7 / AC7 `latest` | PARTIAL until this session's close runs | verify row 7 (a link, to S198's run `20261015T100751Z`); the founder's yes in this chat before the change. "The close check still writes" is NOT yet shown — no close has run since the fix; this session's own close run must repoint it (review rec 1, checked after the close) |
| D8 / AC8 gt_cadence_shared | SHIPPED | verify row 8 |
| D9 / AC9 N7 | SHIPPED | verify row 9; all eight run (below) |
| AC10 real-run checks, red at start; cargo test; push via the belt | PARTIAL — the push happens after the close (review rec 2; S198 graded the same case PARTIAL) | verify 9/9; cargo test above; the push is recorded at S200's start, as S198's was here |
| Carried: S198's push recorded | SHIPPED | `6fc23c3` (PR #236 head `a3068d2` = the GREEN, `clean: yes` close result) |

**The eight N7 scripts, run after the change:** verify-176 exit 0 · demo-176 ✓ · demo-179 ✓ · demo-184 7/7 ·
**verify-178** 9 FAIL rows and **demo-178** 1 FAIL — main's own copies (`git show 027e70f:…`) fail the same rows:
old-vs-new text comparisons that later wording broke → **N22**, filed · **demo-186** 2 FAIL — the same on main's own
copy: a Bash write "blocked before it runs", which S188 removed on purpose (the matching verify-186 checks were
retired at S190) · **verify-179** 1 FAIL — "rudra's ground-truth section differs from the new scaffold's": N14's new
block, which rudra gets on its next `vajra init --sync-fleet` (the founder's call; not run here).

**Not built:** nothing in the prompt. **Not offered:** the README "tested with" line — it needs the founder's own
words; it is on the S200 checklist.

**Fakest green:** step 7's `done:` sha is the verify commit, because the `latest` fix is a local, untracked change —
nothing in git shows it, and verify row 7 reads only this machine. Next: F126's fix is words; the real stamp run
proves the words are true, but nothing makes an agent follow them (rudra S21's agent had the facts and chose wrong).

## New findings (filed, not fixed)

- **N22** (LOW) — `scripts/verify-session-178.sh` (9 rows) and `scripts/demo-session-178.sh` (1 check) are red on main:
  their old-vs-new comparisons meet wording later sessions added. ROADMAP known bugs, S200 checklist.

## Process

- **Found by the review (rec 6), fixed:** verify row 2's PASS message had `vajra approve 10 --close` in backticks inside
  double quotes, so bash RAN it. In this agent shell it was refused (the agent mark); from the founder's own
  terminal it would have written a stray `.ai/approvals/session-10-close.json` into Vajra's repo. None was written
  (`ls .ai/approvals`); the message now names no command.

- Crew: tech-lead (first), fidelity-reviewer (one cold pass), release-coordinator (the one judge of `obeyed:`);
  design-advisor a recorded skip (no new rule); the other six deferred on budget by the tech-lead.
- The founder approved the plan and item 7 in this chat (2026-10-16) before the advance.
- One trap: the session guard read a later session's number in a Python heredoc; the ROADMAP edit moved into a file.

## Next — 3 ranked candidates

1. **(Recommended) S200 — the review-only session (NO-CODE, due by the every-5th rule).** Review S196–S199; first use
   of N14's close-truth question on S196–S199; the S200 checklist (N22, verify-179's rudra row, F123/F127's routes,
   F97's opt-out key, S188's gaps, the `/clear` receipt gap). Why: it is the rule, and the known-bug list is now
   clean to judge. Risk: none — it changes no code. Prompt drafted: `prompts/200-task-ground-truth.md`.
2. **After S200: rudra S22, synced.** `vajra init --sync-fleet` in rudra (N14's question, the sign-off step, the
   push belt, the review-only guard), then a real session to close. Why: every fix since S196 has run only in temp
   projects. Risk: S22 is a real build — long and paid.
3. **After S200: the README "tested with" line (Haiku answer c), then the boot diet (F4).** Why: tells a user which
   models Vajra was tried on, then makes every session cheaper. Risk: the line must be in the founder's own words;
   the boot diet touches what every agent reads first.

**Founder pick (2026-10-16): option 1** — the review-only session; prompt written: `prompts/200-task-ground-truth.md`.
