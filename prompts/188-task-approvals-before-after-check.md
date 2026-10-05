# Session 188 — the approvals folder: check what changed, not what the words say

> **Status:** DRAFT — written at the end of S187 from the founder's approved plan (2026-10-05).
> He approves it with `vajra approve 188` in his own terminal; the gate reads the approval record, not this line.

## Type
session_type: CODE
- **CODE.** Max 2 assumptions · 2 retries · ~2h · 1 story · new chat.
- The one story: **an AI that only reads the approvals folder is never blocked; an AI that writes to it is
  always caught.** Replace the word-guessing Bash guard with a before/after check.

## Goal
Today the approvals guard (`scripts/hook-approvals-guard.sh`, shipped to every project as
`.ai/hooks/hook-approvals-guard.sh`) reads the WORDS of every AI command and blocks when they name
`.ai/approvals` and look like writing — it false-blocked harmless reads 5 times in S187 alone (F110 class)
and can still be fooled by spelling. The founder's plan (2026-10-05): the AI is told never to write there;
Vajra looks at the folder **before and after** each AI command; if it changed, the AI did it — Vajra stops,
says so plainly, and that approval stops counting until the founder approves again. No sandbox, no chasing
tricks ("we say it not to write; once it uses the folder, even if it tricks us, we enforce it and ask again
not to").

## Deliverables
1. **N2 → backlog as a known issue** (founder, 2026-10-05): the ground-truth Write guard blocks writes
   outside the project; fixed some time in a future session. ROADMAP + STATE say so; S187's "N2 → S188"
   wording is replaced. (Design input kept: the S187 design-advisor's recs 12–20.)
2. **The before/after check (Bash).** Before each AI Bash command, Vajra records the folder's state (each
   file's name and content hash); after it, compares. Same → silent, exit 0. Changed → the AI is told, in
   plain words, that only the founder writes there and that the session's approval no longer counts until
   the founder runs `vajra approve NN` again — and the approval really stops counting (the gate, and
   `vajra next --steps`, read it as missing).
3. **The Bash word-guessing checks go.** The Write/Edit/MultiEdit/NotebookEdit block on a path inside the
   folder stays (it reads the real file path, not words). The AGENTS.md rule "the AI never writes to
   `.ai/approvals`" stays, and says what happens if it does.
4. **Projects get it.** `vajra init` scaffolds it and `vajra init --sync-fleet` ships it and wires the
   after-command hook into an existing project's `.claude/settings.json` (add-only, as S182). rudra gets it
   on its next sync.
5. **The founder is never flagged:** `vajra approve NN` typed in his own terminal changes the folder BETWEEN
   AI commands, so no before/after pair sees it.

## Acceptance
| AC | Check |
|---|---|
| AC1 | Every read the old guard false-blocked now passes (exit 0): S187's live case (`git checkout -b X main && cd … && ls .ai/approvals/`), `s187_split`, `f110_open` (heredoc / commit message naming the folder). Red at the start commit: they block. |
| AC2 | Every real write into the folder from the old guard's corpus (cp, mv, rm, `echo >`, tee, python, awk, `find -delete`, `git checkout --`, a path built at run time), run as an AI Bash command, is caught AFTER it runs: exit 2, the plain message, and the session's approval reads as missing in `vajra next --steps`. |
| AC3 | A change to the folder made between two AI commands (the founder's `vajra approve NN`) raises nothing, and the new record counts. |
| AC4 | A Write/Edit tool call aimed at a file in the folder is still blocked before it runs (unchanged). |
| AC5 | A fresh `vajra init` project and an existing one after `--sync-fleet` both run the check; `--sync-fleet` adds the hook once, never twice. |
| AC6 | Every fix has a real-run check in `scripts/verify-session-188.sh` (no source greps) that is red at the commit S188 starts from; the FULL `cargo test` passes locally before the PR is pushed (S187 lesson). |

## Design
design-significant: yes
- **Record:** docs/decisions/DECISION-011-controls-the-agent-cannot-type.md — this session writes its S188 addendum. No new DECISION file: same control (who may write an approval record), same bar-raising posture.
- **Deviates from that record, on purpose (founder, 2026-10-05):** §2 ("the agent's Bash hook refuses to write there"), the S182 addendum §2 (block a command by whether its text can write), the S186 addendum §1–2 (the S182 rule stands; a guard change only adds) and the S173 only-add rule. For Bash the guard stops reading the command and checks the result. The class-level argument S186 asked for: every write the shell can make — any spelling, a path built at run time, an interpreter — changes the folder, and the check reads the folder.
- **Shape.** One script, as today (scripts/hook-approvals-guard.sh, shipped as .ai/hooks/hook-approvals-guard.sh), branching on hook_event_name.
  - PreToolUse, every tool that reaches the guard: first save the folder's state — the folder's own type, then each entry's name, type and `git hash-object --no-filters` hash (a link's target), NUL-separated — under ${TMPDIR:-/tmp}/vajra-approvals-UID/, named by a checksum of the project root plus the tool_use_id (folder mode 700; records older than a day pruned here). Then the unchanged Write-tool path block. A state that cannot be saved exits 0 with no record, never 1 (hook-pre-bash.sh and hook-pre-write.sh skip their later checks on a non-zero exit).
  - PostToolUse and PostToolUseFailure, with exactly the Pre matcher of that settings file: save the state again and compare byte for byte. Same: silent, exit 0. Different, no before record, or no tool_use_id: write the void, plain message on stderr, exit 2 (on these events exit 2 cannot block; it is how the AI is told). The after hook never deletes the before record. L1: one report line, exit 0, no void.
- **The void (option B).** .ai/approvals/voided.json (gitignored) lists every record name present after the change. approved(n) returns None when the file it reads — session-NN.json, or allow-all.launch for the allow-all branch — is listed (names compared lower-cased); an unreadable marker makes every approval missing. `vajra approve NN` rewrites session-NN.json and un-lists it and every session-MM.json with MM below NN; the launch-time writers un-list what they write; an empty list removes the marker; an unreadable one is rebuilt from what is present, never deleted. The marker is inside the folder, so removing or editing it is itself a change the next pair catches and re-lists. Keyed on names, not times: a same-second approve cannot race it.
- **Order with the other hooks: none assumed.** Relied on only: Claude Code starts the tool after every PreToolUse hook returns and runs the after events once it ends. No other Vajra hook writes the folder. A double run of the after check (ADR-0003's injector copies project PostToolUse entries into vajra claude's --settings) gives the same answer twice, because neither run deletes the before record.
- **Rejected:** option A, one marker voiding everything until the next approve (a forged record for a LATER session counts again once the founder approves this one); a void kept outside the folder (one more unwatched command deletes it); the before record inside the folder or the tracked tree (changes what it checks; can be committed); keeping the Bash word checks too (F110's false blocks are why this session exists); pairing Bash only (a Write through a link into the folder lands between pairs); Claude Code's sandbox and Vajra's own OS box (founder, 2026-10-05); a hash crate (git is already required).
- **Accepted gaps (founder: no policing) — named, not closed:** a change undone within one command, including a forged record put in place, a gate run and the record removed in ONE command, which the gate reads as approved; the before record edited during the command; a write landing between pairs (a background job, run_in_background, an interrupted command, a hook killed by its timeout) looks like the founder; a write into ANOTHER project's folder is no longer blocked and never caught; tools outside the paired ones (MCP servers) are not watched; the founder's own `vajra approve` while an AI or background-subagent command runs is flagged (the message says to run it again); a git checkout, pull or stash that moves a committed record counts as a change.
- (Design text from the design-advisor's handoff, `.ai/handoffs/session-188-design-advisor.md`.)

## Carried in
- From S187 (`sessions/session-187-summary.md`): F110's false blocks are this session's reason; the S187
  corpus (`tests/approvals_guard.rs`) is the test list for AC1/AC2.
- **Rejected by the founder (2026-10-05):** Claude Code's sandbox (A1) and Vajra's own OS box (A2).
- **Backlog, S190 checklist (from S187):** the rest of N7; F97's opt-out key; `--advance` number-swaps
  SESSION-BOOT; the session guard reads a session number in edit text; verify-133 not safe to run twice at
  once; `tests/gt_cadence_shared.rs` reads the real repo's summary. **Parked:** F67, non-Claude tools, release.

## Guardrails
- ≤3 files per commit; every fix has a check red at the start commit for the named reason.
- This session REMOVES text checks on purpose (founder's call) — say plainly in the summary what the old
  guard blocked BEFORE a command that the new check only catches AFTER it.
- Run the full `cargo test` before pushing.

## Plan
1. The void: `approved()` reads a record listed in `.ai/approvals/voided.json` as missing (names
   lower-cased; unreadable marker → all missing); `vajra approve NN` and the launch-time writers un-list what
   they write (approve also every earlier session), rebuild an unreadable marker, remove an empty one; `--steps`
   and the Analyst gate say WHY it does not count (`src/approval/mod.rs`, `src/nextstep/mod.rs`,
   `src/analyst/mod.rs`). covers: 2, 3
2. The pair: the guard saves the folder's state first at every PreToolUse, and at PostToolUse /
   PostToolUseFailure compares, writes the void and tells the AI (exit 2); no before record or no
   `tool_use_id` counts as a change; L1 reports only; the after hook never deletes the before record. Vajra's
   own `.claude/settings.json` wires both after events with its Pre matchers. Word checks still in place
   (tech-lead rec 1). Tests: real commands run between a real Pre and Post call
   (`scripts/hook-approvals-guard.sh`, `tests/approvals_guard.rs`, `.claude/settings.json`). covers: 2, 3
3. Projects: the scaffold settings gain the two after groups (exactly the Pre matcher); the ignore block gains
   `voided.json`; the governed constitution says the AI never writes there and what happens if it does;
   `--sync-fleet` adds the groups once and leaves a project's own PostToolUse hooks byte-identical
   (`src/cli/init.rs`, `.ai/AGENTS.md` — its Hard Rules reach every scaffold through build.rs,
   `tests/approvals_scaffold.rs`). covers: 5
4. The Bash word checks go; the Write-tool path block stays. The old "blocked before" tests become "passes"
   (reads, F110, S187 split) and "caught after" (every runnable write the old guard blocked, plus
   `cp …; false` and a path built at run time) (`scripts/hook-approvals-guard.sh`, `tests/approvals_guard.rs`,
   `tests/approval_cli.rs`). covers: 1, 2, 4
5. The record: DECISION-011 S188 addendum; a KNOWLEDGE fact that supersedes lines 341–361; Vajra's own
   `.gitignore` line for the void. covers: 2
6. D1: the S187 summary's "N2 → S188" lines say → backlog (ROADMAP and STATE already do, PR #225).
7. `scripts/verify-session-188.sh` (real runs, each check red at 43305fd for its reason; the shipped copy is
   the same bytes) + `scripts/demo-session-188.sh`; the full `cargo test` before the push. covers: 1, 2, 3, 4, 5, 6
8. One live run through `vajra claude` on the cheapest model (design-advisor rec 11): a write in a failing
   command is caught once; a read brings nothing. Founder's yes first (it costs cents). covers: 2

## Execution
- step 1 — done: dfed53e
- step 2 — done: 441fd36
- step 3 — done: 80bdcb1
- step 4 — done: ee26d41
- step 5 — done: aff49f1
- step 6 — done: b870483
- step 7 — done: 281fa28
- step 8 — done: 92a07a6

## Advice
Roles dispatched: `tech-lead` (mandatory, first), `design-advisor` (required; design-significant: yes),
`fidelity-reviewer` (required; the one cold close review), `release-coordinator` (required; the one judge
of every `obeyed:` answer).
implementation-advisor: skipped — the tech-lead deferred it on budget (its crew line and rec 11): it would read the guard, its scaffold copy, init.rs and the tests, about 1.2M tokens, taking the crew to ~5.2M; the design-advisor's shape and the real-run checks (verify-188 AC2/AC5, the live run) stand in for it.

**tech-lead** (`.ai/handoffs/session-188-tech-lead.md`):
- tech-lead rec 1 — obeyed: dfed53e (the void) and 441fd36 (the before/after pair, the word checks still in place) landed before ee26d41 removed the word checks; no commit leaves the folder with neither guard
- tech-lead rec 2 — refused: in part — the before record lives outside the folder and the tracked tree, keyed by the project and the tool_use_id, as asked (441fd36); but the after hook does NOT delete it: the design-advisor (its rec 2) showed the after check can run twice for one call, and a deleted record would make the second run void a clean command. The Pre hook prunes records older than a day instead (`s188_a_second_after_run_gives_the_same_answer`).
- tech-lead rec 3 — obeyed: dfed53e (the void is `.ai/approvals/voided.json`, inside the folder; `allow-all.launch` is listed and read like any record) and 441fd36 (removing the void is itself caught and re-listed: `s188_removing_the_void_is_caught_and_relisted`)
- tech-lead rec 4 — obeyed: 441fd36 (the message says "if you ran `vajra approve` yourself while this command was running … just run it again"; `s188_an_approve_during_a_command_is_flagged_and_says_run_it_again` records what happens: flagged) and 281fa28 (verify-188's AC3 overlap check)
- tech-lead rec 5 — obeyed: aff49f1 (the DECISION-011 S188 addendum's Limit list: a background job, an interrupted command or a child it left, a hook killed by its timeout — "caught only if it lands inside a later pair; otherwise missed"; named, not closed) — the summary repeats it
- tech-lead rec 6 — obeyed: aff49f1 (the docs facts cited in the addendum) and 441fd36 (`s188_no_before_record_counts_as_a_change_and_l1_only_reports`: no before record voids at L2); 92a07a6 (live: `cp …; false` fired PostToolUseFailure once, with the Pre call's tool_use_id)
- tech-lead rec 7 — obeyed: ee26d41 (the S181–S187 corpus is kept and every command RUN for real between a real before and after call — `every_command_the_start_guard_blocked_is_caught_after_if_it_wrote`; the Write-tool path tests unchanged) and 441fd36 (`cp forged.json .ai/approvals/session-189.json; false` and the run-time path `d=.ai; a=appr; cp … $d/${a}ovals/…` are in `s188_writes`)
- tech-lead rec 8 — obeyed: 80bdcb1 (`sync_fleet_adds_the_after_check_once_and_keeps_a_projects_own_after_hooks`: the project's own PostToolUse group stays equal, one guard group added, a second run changes nothing) and 281fa28 (verify-188 AC5)
- tech-lead rec 9 — obeyed: 281fa28 (verify-188 AC6: the guard `vajra init` ships equals scripts/hook-approvals-guard.sh byte for byte, the stamp line aside; AC1–AC5 run through a `vajra init` project's own shipped copy and settings)
- tech-lead rec 10 — refused: in part — ROADMAP and STATE already said "N2 → backlog, a known issue" (PR #225), so no commit touched them; but deliverable 1 also says "S187's 'N2 → S188' wording is replaced", and the S187 summary still said "N2 → S188" in four places plus "F97 opt-out key → S188"; b870483 corrects those lines.
- tech-lead rec 11 — obeyed: ADVICE_SHA (the implementation-advisor skip line above, with the budget reason); one cold fidelity pass on the finished branch, then the release-coordinator once, after this section answers every rec

**design-advisor** (`.ai/handoffs/session-188-design-advisor.md`):
- design-advisor rec 1 — obeyed: 441fd36 (one script branching on `hook_event_name`, the before record in `${TMPDIR:-/tmp}/vajra-approvals-UID/`, mode 700, pruned after a day) and dfed53e (void option B: names listed, not one marker)
- design-advisor rec 2 — obeyed: 441fd36 (the after hook never deletes the before record; `s188_a_second_after_run_gives_the_same_answer`)
- design-advisor rec 3 — obeyed: 441fd36 (Vajra's own settings: the after groups use exactly its Pre matchers, `Bash` and `Edit|Write|MultiEdit`) and 80bdcb1 (the scaffold: `Bash|Edit|Write|MultiEdit|NotebookEdit` for all three events); `s188_a_write_tool_through_a_link_is_caught_after`
- design-advisor rec 4 — obeyed: 441fd36 (`save_before` runs first, before the Write-tool block, and returns 0 when it cannot save; `s188_an_unsavable_before_record_exits_0_at_pre_and_is_caught_after`, through hook-pre-bash.sh too)
- design-advisor rec 5 — obeyed: 441fd36 (`git hash-object --no-filters`, NUL-ended records, `cmp -s`, the folder's own type first, an unreadable entry recorded as a state, a failed save at Post counts as "could not compare")
- design-advisor rec 6 — obeyed: 441fd36 (`s188_no_before_record_counts_as_a_change_and_l1_only_reports`: no before record and no tool_use_id void at L2 with their own messages; L1 writes one report line, exit 0, no void)
- design-advisor rec 7 — obeyed: dfed53e (`read_void` lower-cases the names; `a_listed_record_does_not_count_and_says_why` lists `SESSION-188.JSON`)
- design-advisor rec 8 — obeyed: dfed53e (`an_unreadable_marker_voids_all_and_approve_rebuilds_it`: not JSON, and a directory in its place, both rebuilt from the records present, never deleted)
- design-advisor rec 9 — obeyed: 80bdcb1 (the scaffold's ignore block) and aff49f1 (Vajra's `.gitignore`); 441fd36 (`write_void` leaves the marker itself out of the list)
- design-advisor rec 10 — obeyed: dfed53e (`void_note`: `vajra next --steps` and the Analyst gate say "session NN's approval does not count — an AI command changed .ai/approvals …; the founder runs `vajra approve NN` again")
- design-advisor rec 11 — obeyed: 92a07a6 (the live run through `vajra claude -p --model haiku`, $0.03: the failing write fired PostToolUseFailure once and the agent got the message verbatim; the read fired PostToolUse once and raised nothing; cited in the addendum)
- design-advisor rec 12 — obeyed: ee26d41 (`tests/approval_cli.rs` converted to a real pair through hook-pre-bash.sh; the start guard read with `git show 43305fd:…` into a temp file) and 80bdcb1 (`tests/approvals_scaffold.rs` `assert_guarded` converted: blocked before OR caught after, plus the after wiring)
- design-advisor rec 13 — obeyed: aff49f1 (the addendum's first Limit bullet: a forged record put in place, a gate run and the record removed in ONE command is read as approved — the sharpest gap, named, not closed); the summary says it
- design-advisor rec 14 — obeyed: aff49f1 (the addendum: a write into another project's folder, once blocked by its text, is now neither blocked nor caught); the summary lists it as LOST, not moved
- design-advisor rec 15 — obeyed: 80bdcb1 (the rule is a Hard Rules row in `.ai/AGENTS.md`, which build.rs derives into the governed body `TPL_AGENTS_BODY` ships — a fresh `vajra init`'s `.ai/AGENTS.md` carries it) and aff49f1 (a new KNOWLEDGE fact that supersedes the S181–S183 guard facts, the old ones left as written)
- design-advisor rec 16 — obeyed: aff49f1 and ADVICE_SHA (the DECISION-011 S188 addendum's first lines say it deviates from §2's last sentence, reverses the S182 addendum §2 and the S186 addendum §1–2 and the S173 only-add rule; no new DECISION file)

## Delta
- `-` the approvals guard's Bash word checks (redirect, writer, interpreter and program lists)
- `+` a before/after check of `.ai/approvals` around every AI Bash command; a changed folder voids the approval
- `~` `vajra init` / `--sync-fleet` ship and wire the new hook
- `~` N2 → backlog as a known issue
