# Session 188 — Summary (CODE: the approvals folder — check what changed, not what the words say)

Brief: `prompts/188-task-approvals-before-after-check.md` — the founder's approved plan (2026-10-05), approved
with `vajra approve 188`. The brief's one story: an AI that only reads the approvals folder is never blocked; an
AI that writes to it is always caught. (Delivered for writes made by the guarded tools inside a command; the gaps
that are NOT caught are named below.)

## Goal achieved?
Yes, with the named gaps below. The Bash word guard is gone. Vajra saves `.ai/approvals`' state before every call
of a guarded tool (Bash, Edit, Write, MultiEdit, NotebookEdit — not MCP tools) and compares after it (Claude Code's PostToolUse and PostToolUseFailure); a change lists the records present in
`.ai/approvals/voided.json`, they stop counting, and the AI is told in plain words. The founder's `vajra approve NN`
lands between calls and makes his record count again. Projects get it through `vajra init` / `--sync-fleet`.
Proven in real Claude Code once (Haiku, $0.03). Verify: `scripts/verify-session-188.sh` 11/11 (each fix row also
run at 43305fd, red for its reason; the last row runs the new S188 tests at HEAD only, and the shipped-copy row is
a proof that is green at 43305fd too). Demo: `scripts/demo-session-188.sh` (8 live checks). Full `cargo test`: 687
passed, 0 failed (after the review's fixes, before the push). One cold review: ACCEPT, its 5 recs fixed in-session.

## Fidelity map (prompt `prompts/188-task-approvals-before-after-check.md`)
| # | Requirement | Status | Evidence |
|---|---|---|---|
| D1 | N2 → backlog as a known issue; ROADMAP + STATE say so; S187's "N2 → S188" wording replaced | SHIPPED | ROADMAP S188 row and STATE already said it (PR #225, no commit needed); b870483 replaced the S187 summary's five "→ S188" lines (N2 ×4, F97's opt-out key ×1) |
| D2 | Before/after check of the folder around each AI Bash command; a change voids the approval (gate and `--steps` read it as missing) | SHIPPED | 441fd36 (the pair), dfed53e (the void; `void_note` says why in `--steps` and the Analyst gate); live run 92a07a6 |
| D3 | The Bash word checks go; the Write-tool path block stays; the AGENTS.md rule says what happens | SHIPPED | ee26d41 (word checks removed; `write_tools_block_on_the_path` unchanged); 80bdcb1 — the rule did not exist yet, so it was ADDED as a Hard Rules row (reaches every scaffold through build.rs) |
| D4 | Projects get it: `vajra init` scaffolds, `--sync-fleet` ships and wires the after hook, add-only; rudra on its next sync | SHIPPED (rudra: on its next `--sync-fleet`, not run here) | 80bdcb1; `sync_fleet_adds_the_after_check_once_and_keeps_a_projects_own_after_hooks`; verify-188 AC5 |
| D5 | The founder is never flagged: `vajra approve NN` between AI commands | PARTIAL (the review's grade) — between commands it holds; during a running command he IS flagged (a false void, named; the message tells him to run it again) | `s188_the_founders_approve_between_calls_raises_nothing`, `s188_an_approve_during_a_command_is_flagged_and_says_run_it_again`; verify-188 AC3 ×2 |
| AC1 | Every read the old guard false-blocked passes (S187 live case, `s187_split`, `f110_open`); red at start | SHIPPED | verify-188 rows 1–2 (43305fd: all five blocked before they ran) |
| AC2 | Every real write (cp, mv, rm, `echo >`, tee, python, awk, `find -delete`, `git checkout --`, a run-time path) caught after it runs: exit 2, the message, ✗ in `--steps` | SHIPPED | verify-188 rows 3–4 (12/12 incl. the review's two fail-open attacks, + `git checkout --`; 43305fd: 0 caught after, `git checkout --` blocked before); the whole old corpus run for real in `every_command_the_start_guard_blocked_is_caught_after_if_it_wrote` |
| AC3 | A change between two AI commands raises nothing; the new record counts | SHIPPED | verify-188 row 5; row 6 records the overlap case (tech-lead rec 4) |
| AC4 | A Write/Edit into the folder is still blocked before it runs | SHIPPED (unchanged by design — green at 43305fd too) | verify-188 row 7 |
| AC5 | A fresh project and an old one after `--sync-fleet` both run the check; added once | SHIPPED | verify-188 rows 8–9 (43305fd: before only) |
| AC6 | Real-run checks red at the start commit; full `cargo test` before the PR | PARTIAL (the review's grade) → rec 4 fixed in-session: the `git checkout --` row now runs at 43305fd too | verify-188 rows 1–9 run at 43305fd too; row 10 (the shipped copy = the tested bytes) is a proof, green at 43305fd too; row 11 runs the new S188 tests at HEAD only (said in the row); `cargo test` 687/0 |

## What the old guard blocked BEFORE that the new check only catches AFTER — counted, not stated
`every_command_the_start_guard_blocked_is_caught_after_if_it_wrote` runs the whole S181–S187 corpus for real between
a real before call and a real after call. The guard S188 started from (43305fd) blocked **76** of those commands
before they ran:
- **45 really write the folder → now caught AFTER they run.** cp, mv, rm, redirects (`>`, `>>`, `2>`, `&>`, `>|`,
  a backslash-newline), tee, touch, ln, truncate, python, awk (with and without a path), `cd` into the folder,
  `find -delete`, a link made then written through, 20–120 KB commands. The difference that matters: **the write
  happens.** The record may be changed or gone; Vajra undoes nothing; the approval stops counting until the
  founder runs `vajra approve NN` again.
- **31 wrote nothing in the folder → now pass.** The F110 false blocks (a heredoc or commit message naming the
  folder, a read joined to another command) and commands that fail or write elsewhere (`sh x.sh .ai/approvals`
  with no `x.sh`, `echo x > .ai/approvals/\`date\`` — an ambiguous redirect).
- **LOST — blocked before, now neither blocked nor caught** (design-advisor recs 13–14):
  - a write into ANOTHER project's `.ai/approvals` (`cd ~/playground/rudra && cp x .ai/approvals/y`) — only this
    project's folder is watched;
  - a change undone inside ONE command — including the sharpest case: put a forged record in place, run a gate
    that reads it, remove the record, all in one command. The gate inside that command reads it as approved.
    The old guard blocked the plain spelling. Named, not closed.

## The cold review (one pass, ACCEPT 10/12 · 2 PARTIAL) and what it changed
`sessions/session-188-review.md`. Its five recs, all fixed in-session:
- **rec 1 — the void failed OPEN (serious, found by reading, confirmed by running):** a forge plus `touch --
  .ai/approvals/--x` (jq read the name as an option) or `chmod a-w .ai/approvals` left no void while the message
  said the approvals "no longer count". Run against the pre-fix guard: no void, message "no longer count". Fixed
  (26c593c): names reach jq on stdin, the folder is made writable first, and a void that still cannot be written
  says "NOT voided — these approvals STILL count". Both attacks are now in the tests and verify-188.
- **rec 2 — the restart window:** after `--sync-fleet` the new script is live at once but the after hooks load
  only at Claude Code's next start; in between, a Bash write is neither blocked nor caught. `--sync-fleet` now says
  "restart Claude Code in this project now" (20dcaa3). **This applies to rudra's next sync, and to any Vajra chat
  left open across this merge.**
- **rec 3 — wording** (a4b1a1c): the false "chmod can only take an approval away" removed; the sharpest gap widened
  (a gate in the SAME command as a forge reads it as approved, removed or not); the void is this machine's only (a
  caught forged record that gets committed counts in any other checkout); "guarded tools", not "any AI tool call".
- **rec 4** — verify-188's `git checkout --` row runs at 43305fd too; the typed "they do not exist" removed.
- **rec 5** — the folder is hashed by one git process, not one per record (26c593c).

## What was NOT built / limits (named, not closed)
- **A gate run in the SAME command as a forge** reads the forged record as approved (removed afterwards or not); the
  void lands only after the command ends. The old guard blocked the plain spelling.
- **The void is this machine's only:** a caught forged record that gets committed counts in CI, a fresh clone, a
  worktree. Vajra undoes nothing.
- **The restart window** after `--sync-fleet` (said by the command now).
- **Writes between pairs look like the founder:** a background job (`(sleep 5; cp …) &`, `run_in_background`), what
  an interrupted command or a child it left behind writes after the call returns, a hook killed by its timeout.
  Caught only if it lands inside a later pair.
- **The before record can be edited** during the command (it is in the user's temp folder), and the hook scripts
  that run outside any pair can be edited. Accepted by the founder.
- **The founder is flagged** when his `vajra approve` lands while an AI command (or a background subagent's) runs,
  and a `git checkout` / `pull` / `stash` that moves a committed record counts as a change (one combined
  `git checkout main && git pull --ff-only` does not). The message tells him to run it again.
- **An existing project's `.gitignore`** gets no line for `voided.json` (its Vajra block is appended once, S171): it
  shows as an untracked file there.
- **MCP tools** that write files are not watched.
- **Older verify scripts:** verify-182 (1 check), verify-186 (23 checks) and verify-187 (1 check) assert that a Bash write into the folder is BLOCKED before it runs — run against today's code they FAIL, by design (2026-10-05 runs). Two more now PASS HOLLOW: verify-186's AC3 and verify-187's AC1 corpus check run `cargo test` filtered to test names S188 merged into `every_command_the_start_guard_blocked_is_caught_after_if_it_wrote`, so cargo runs 0 tests and exits 0. Left as history, like verify-175; not re-pointed this session → backlog, S190 checklist.

## Fakest green
`verify-188` and the tests prove the hooks behave when they are CALLED the way Claude Code calls them. That Claude
Code really calls them that way rests on ONE live run (Haiku, two commands, `vajra claude -p`): the failing command
fired PostToolUseFailure once with the same `tool_use_id`, the agent got the message, the read raised nothing. An
interactive session, a subagent's commands, and `run_in_background` were not run live. The other soft spot:
"caught" means the approval stops counting — the write itself already happened, and a gate in the same command has
already acted. Until the review, "caught" also printed "no longer count" when no void was written; now it says
"STILL count" when that happens.

## Process
- Crew: tech-lead (first), design-advisor (16 recs, all obeyed), one cold fidelity review (ACCEPT; 5 recs, all
  fixed), one release-coordinator judge. implementation-advisor skipped on budget (tech-lead).
- The old word guard false-blocked THIS session twice before step 4 removed it (a heredoc naming the folder, a
  python edit script) — F110 one last time.
- `vajra next --advance` number-swapped SESSION-BOOT again (S187's line rewritten as "188"); fixed by hand (backlog).
- Cost: $0.03 (the live run, Haiku). No other paid run.

## Next — 3 ranked candidates
1. **(Recommended) F67 — the receipt reads the tool's own cost for interactive runs.** The one wrong number every user sees (~5× high on Opus 5.5); today's live run showed the `-p` path already reads the real cost. Why: every rudra session's receipt is wrong, and the founder parked it three times asking for the permanent fix, not new price rows. Risk: Claude Code may not write a cost into an interactive run's transcript — then the fix is "say no cost is known", not a number.
2. **The non-Claude tools brainstorm (F91, F94, F95).** Promised since S179: OpenCode's agent and the founder look the same to the git guards. Why: the next user may not use Claude Code. Risk: a design session — nothing a user runs comes out of it.
3. **rudra S18 under the new approvals check.** The first real use of S188 in the founder's project, after `--sync-fleet`. Why: S188 was proven once on Haiku; rudra is where a false void or a missed write would show. Risk: waits for rudra's data API (founder, 2026-10-04).
(S190 is the next review-only session. N2 stays in the backlog.)
