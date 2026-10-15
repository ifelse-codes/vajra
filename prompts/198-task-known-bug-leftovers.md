# Session 198 — CODE: the known-bug leftovers — F118 and N18

> **Status:** DRAFT — written by the S197 agent from the founder's pick (2026-10-14: option 2 of
> `sessions/session-197-summary.md`, "the known-bug leftovers: F118 + N18"). The founder reads it and runs
> `vajra approve 198` in his own terminal; the gate reads the record, not this line.

## Type
session_type: CODE
- **CODE.** Max 2 assumptions · 2 retries · ~2h · 1 story (the two leftovers) · new chat.

## Goal
Fix the two small bugs left on ROADMAP's "🐞 KNOWN BUGS — TO FIX" list after S197 — each one a thing a user meets:
`vajra next --advance` leaving the old session's text under the new number (F118), and the drift check choosing the
wrong verify scripts when the folder path has dashes (N18).

## Deliverables
1. **F118 — `vajra next --advance` moves the old `## Current Session` entry to `## Prior Session`.** Today
   `update_session_boot` (`src/cli/next.rs`) swaps only the `**Number:**` token, so the old session's whole story sits
   under the new number and drops out of `## Prior Session` (S193, S194 and S197's own advance `aad6381`, each fixed by
   hand). On a SESSION-BOOT shaped like Vajra's (a `## Current Session` with one `- **Number:** NN — …` entry, then
   `## Prior Session` blocks), the advance writes a fresh `- **Number:** NN+1 — IN PROGRESS` entry under
   `## Current Session` and puts the old entry, unchanged, as the first `## Prior Session` block. Any other shape (a
   project's own SESSION-BOOT, e.g. rudra's) keeps today's number swap and is told so on stderr — never rewritten
   by guess.
2. **N18 — `scripts/scaffold-drift.sh` check 6 picks the last 10 verify scripts by session number, not by a field
   of the full path.** Today `sort -t- -k3 -n` splits the WHOLE path on `-`, so a folder with dashes in its path
   (the old-version checkouts `…/vajra-old-checkouts/<pid>-<sha>/`) sorts the wrong field (found S197).

## Acceptance
| AC | Check |
|---|---|
| AC1 | F118: `vajra next --advance` on a temp repo whose SESSION-BOOT has Vajra's shape leaves `## Current Session` naming only the new number, and the old entry is the first `## Prior Session` block, byte-for-byte. |
| AC2 | F118: on a SESSION-BOOT without that shape, the advance still swaps the number (as today) and prints why it did not move the entry. |
| AC3 | N18: check 6 run from a folder whose path has dashes scans the same 10 scripts as from a path without dashes. |
| AC4 | Every fix has a real-run check in `scripts/verify-session-198.sh` (no source greps), red at the start commit. Full `cargo test` passes before push; the push goes through the S196 push belt (close GREEN on the pushed commit). |

## Design
design-significant: no
- F118 follows the S191 `--advance` addendum (DECISION-011 S191) and DECISION-007's step list; N18 is a one-line
  sort fix in a check script. The design-advisor is still mandatory (S133): one narrow dispatch, or a recorded
  reasoned skip.
- design-advisor: skipped — both fixes follow existing records (DECISION-011 S191 `--advance` addendum, DECISION-007's
  step list) and change no shared rule; the tech-lead's rec 1 (`.ai/handoffs/session-198-tech-lead.md`) says to skip.
- F118's shape test is strict and fails closed (tech-lead rec 2): exactly one `## Current Session` heading; under it
  exactly one `- **Number:** <current>` line, its indented continuation lines, then only blank lines; the next heading
  is `## Prior Session`. The `vajra init` SESSION-BOOT (several `- **…:**` lines, no `## Prior Session`) is "another
  shape": number swap + a stderr note — no heading is invented.

## Carried in
- **From S197 (founder calls, 2026-10-14):** F125 + N17 fixed — the review-only guard ships to every project and only
  `vajra approve NN --close` opens it (DECISION-011 S197 addendum); F116, F119, N10 fixed. F118 was moved out of
  S197 to make room. rudra needs `vajra init --sync-fleet` and a Claude Code restart to get the guard.
- **Carried from S197 (its release-coordinator rec 1):** record whether S197's GREEN push went through the S196
  push belt — S197's tech-lead rec 6 and fidelity-reviewer rec 7 asked for it, and no S197 commit can show a push
  that happens after its own close. Write it into S197's summary (sessions/) at this session's start, from the
  founder's S197 pull-request page or `git log origin/session-197-known-bugs`. S197's full `cargo test` (735/0) is in its
  summary already (7443202).
- **Kept in backlog (ROADMAP known bugs):** S197 design-advisor rec 10 (a `--steps` line for the close record) ·
  F126 · the rest of N7 · F97's opt-out key · `tests/gt_cadence_shared.rs`'s loose assertion · S188's named gaps ·
  F123/F127's named routes. **Parked:** non-Claude tools (F91/F94/F95); release.
- **Founder rulings:** read the tool's own cost, never grow the price list; one release-coordinator judges all
  `obeyed:` answers; the close does not run `cargo test` (run it in full before pushing); no new policing of Vajra's
  own paperwork; release not yet.
- **Next ground truth: the next multiple of 5** (derived, `scripts/lib-ground-truth.sh`) — the review-only guard now
  blocks its commits until the founder's `vajra approve NN --close`.

## Guardrails
- No paid run by the agent without the founder's yes. No transcript or run capture committed (S126).
- Fixes only what is listed; a new bug found on the way is filed, not fixed.

## Plan
1. F118: `update_session_boot` (`src/cli/next.rs`) moves the old entry to the first `## Prior Session` block on
   Vajra's shape and writes `- **Number:** NN+1 — IN PROGRESS`; any other shape keeps the number swap and `--advance`
   prints why the entry did not move; unit tests for both shapes and the `vajra init` shape.
   covers: 1, 2
2. N18: check 6 in `scripts/scaffold-drift.sh` picks the last 10 verify scripts by the number in the file name.
   covers: 3
3. `scripts/verify-session-198.sh` — each row a real run (the built `vajra` on a temp repo; `scaffold-drift.sh` from a
   dashed folder), red at the start commit `2830bb2` — and the demo; full `cargo test` before the push.
   covers: 4

## Execution
- step 1 — done: e26d59a
- step 2 — done: bbc2948, 0087c2a
- step 3 — done: 31e92e7, c2b936c

## Delta
- `~` F118: `--advance` moves the old Current Session entry down instead of leaving it under the new number
- `~` N18: check 6 sorts by session number, not by a field of the full path

## Advice
Roles dispatched: `tech-lead` (mandatory, first). Required at close: `fidelity-reviewer` (the one cold review),
`release-coordinator` (the one judge of every `obeyed:` answer). `design-advisor`: the recorded skip in `## Design`.

researcher: skipped — the tech-lead deferred it on budget: both bugs' evidence was already in the prompt and ROADMAP's known-bug list (~0.15M; crew ~1.4M → ~1.55M).
requirements-analyst: skipped — the tech-lead deferred it on budget: the founder picked these two items and AC1–AC4 give each a real-run check (~0.1M would restate them).
plan-advisor: skipped — the tech-lead deferred it on budget: a two-step plan whose order does not matter (~0.1M).
implementation-advisor: skipped — the tech-lead deferred it on budget: its recs 2–4 name the traps (strict shape, sort by file name, real-run rows) (~0.25M).
qa-specialist: skipped — the tech-lead deferred it on budget: AC4 makes every verify row a real run, red at 2830bb2, and the fidelity-reviewer runs them (~0.3M).
demo-producer: skipped — the tech-lead deferred it on budget: two bug fixes shown in verify output and the summary; the demo is the template's seven sections with live runs (~0.15M).

**tech-lead** (`.ai/handoffs/session-198-tech-lead.md`):
- tech-lead rec 1 — obeyed: 1f77083 (`design-advisor: skipped — <reason>` recorded in `## Design`; no dispatch, since the shape test needed no new rule)
- tech-lead rec 2 — obeyed: e26d59a (`move_current_entry` checks the shape strictly and returns why it differs; any other shape gets the swap + the stderr note; the `vajra init` shape is "other shape", written in `## Design` at 1f77083 and tested as verify row 2)
- tech-lead rec 3 — obeyed: bbc2948 (check 6 takes the NN from the file name before sorting) and 31e92e7 (row 3 runs check 6 from a checkout under `…/n-1-8/` and one under a dash-free folder and compares the 10 names)
- tech-lead rec 4 — obeyed: 31e92e7 (rows 1–3 run the built `vajra` and the real script, each also at 2830bb2 where it goes red for its own reason; row 4 keeps S191's prose-number unit test)
- tech-lead rec 5 — deferred: prompts/199-task-design-vajra-runs-the-reviewer.md (the push half — stamp → close → push through the S196 belt, then recorded — happens after this session's last commit, so no commit here can show it; carried in that prompt. The cargo-test half is done: 737/0 before any push, in the summary, 07e73cf)
- tech-lead rec 6 — obeyed: 07e73cf (build, then one fidelity-reviewer, then one release-coordinator; the tech-lead recorded from its handback text, c2b936c; a skip line for each deferred role above; `## Delta` above `## Advice`; no new bug fixed on the way)

**fidelity-reviewer** (`.ai/handoffs/session-198-fidelity-reviewer.md`, ACCEPT 5/6):
- fidelity-reviewer rec 1 — obeyed: 29520f8 (verify row 4 now needs `test result: ok. 5 passed;`, so 15/25 no longer match; re-run 4/4)
- fidelity-reviewer rec 2 — obeyed: 8199d0a (the summary's fidelity map grades AC4 PARTIAL — the push half deferred to the next session's prompt)
- fidelity-reviewer rec 3 — obeyed: 8199d0a (filed as N19 in ROADMAP's known bugs with a fix idea and the S200 checklist destination; not fixed, per the guardrails)
- fidelity-reviewer rec 4 — obeyed: 8199d0a (filed as N20 in ROADMAP's known bugs with a fix idea and the S200 checklist destination; not fixed)
- fidelity-reviewer rec 5 — obeyed: 8199d0a (the builder re-ran `scripts/verify-session-198.sh` at the tip — 4/4, rows 1–3 also red at 2830bb2 inside the run — and the full `cargo test`: exit 0, 737 passed / 0 failed; that re-run found the earlier "739" was a miscount, corrected in the summary, ROADMAP and this section)
