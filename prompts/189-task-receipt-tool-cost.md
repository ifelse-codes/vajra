# Session 189 — F67 for good: the receipt reads Claude Code's own cost for interactive runs

> **Status:** DRAFT — written at the end of S188 from the founder's pick (2026-10-05: "F67 receipt cost").
> He approves it with `vajra approve 189` in his own terminal; the gate reads the approval record, not this line.

## Type
session_type: CODE
- **CODE.** Max 2 assumptions · 2 retries · ~2h · 1 story · new chat.
- The one story: **the cost line on every `vajra claude` receipt is Claude Code's own figure, or says plainly
  that none is known — never a guess from a price list.**

## Goal
F67 (S176, parked three times by the founder, who asked for the permanent fix, not new price rows): an
interactive `vajra claude` run has no result stream, so the receipt estimates the cost from Vajra's hand-kept
price list — and every new model breaks it (Opus 5.5 reads ~5× too high: rudra S07/S08/S09 receipts said
~$48.68 / ~$62.71 / ~$118.69). A headless `vajra claude -p` run already reads the tool's own
`total_cost_usd` (S77/S78; S188's live run showed "$0.03 what this run cost"). This session finds where Claude
Code exposes its own cost for an INTERACTIVE session (candidates: the status-line JSON's `cost.total_cost_usd`,
a hook's input, the transcript) and makes the receipt use it; where the tool gives none, the receipt says so.

## Deliverables
1. **Find the tool's own figure (researcher first).** Which surface of Claude Code 2.1.x carries an interactive
   session's cost, when it is written, and whether Vajra can read it without the user's own settings changing
   (the status line is the user's; `vajra claude` injects `--settings` today — ADR-0003). Recorded in the design.
2. **The receipt uses it.** An interactive `vajra claude` run's headline cost is the tool's own figure, labelled
   as such. When the tool gives none, the headline says "no cost from Claude Code for this run" and the token
   estimate stays a labelled `[estimate]` — never the headline.
3. **No new price rows.** The price list is not extended for Opus 5.5 or any other model (founder, S176/S177).
4. **Projects get it** with no action: `vajra claude` in rudra shows the real figure on its next run.

## Acceptance
| AC | Check |
|---|---|
| AC1 | A recorded interactive-run fixture (or a live interactive run, founder's yes first) whose tool figure is known: the receipt's headline equals that figure. Red at the start commit: it prints the price-list estimate. |
| AC2 | A run where the tool gives no figure: the headline says no cost is known; the estimate is labelled `[estimate]` and is not the headline. |
| AC3 | An unknown model (e.g. a made-up `claude-opus-9`) never makes the headline a guess. |
| AC4 | `-p` runs are unchanged (the S77/S78 result-stream figure still wins). |
| AC5 | Every fix has a real-run check in `scripts/verify-session-189.sh` (no source greps), red at the commit S189 starts from; the full `cargo test` passes before the PR. |

## Design
design-significant: yes
- Changes the receipt's interface: `meter_session` takes the launch time, `SessionCost` gains Claude Code's own session record as a separate source, and the headline rule changes. Recorded as an S189 addendum to ADR-0004 (meter and receipt), which also writes down the S66/S77/S78 rule that until now lived only in code comments: the tool's own figure wins, and a guess is never the headline. This DEVIATES from ADR-0004 §2.8, whose headline was the token-formula total; the addendum replaces that rule. ADR-0003 is unchanged: no hook, no status line, no change to `--settings`.
- Source (researcher, S189): Claude Code (2.1.275 and later) appends a `cost-state` line with the running `totalCostUSD` to the main transcript at each normal exit. The headline is picked by one resolver, in this order: the transcript's `type:"result"` `total_cost_usd`, then the captured `-p` result stream (S78, unchanged), then this run's share of the cost-state total, then none. The cost-state figure is kept in its own field, so it can never block the `-p` stream.
- This run's share is the last cost-state total minus the last total written before the first line timestamped at or after launch (0 if there is none). There is no figure if the last cost-state line comes before that line (crash or kill), if no line from this run has a readable timestamp, if the share is negative, or if the total is not a finite number. Totals are never added up. If there is no baseline and the record's `startTime` is before launch (a fork, or a resume Vajra did not see), the headline says no cost for this run and a labelled line shows the whole conversation's total. `vajra meter FILE` shows that labelled conversation total and subtracts nothing.
- Nothing new is stored: the launch time already in memory is the only input, and the transcript is only read, after exit.
- No figure: the headline reads "no cost from Claude Code for this run" and the token number is a labelled `[estimate]` line beneath it. An unknown model only ever tags the estimate line. If `hasUnknownModelCost` is true, the headline is still Claude Code's figure and says Claude Code could not price every model. No price rows are added.
- Rejected: the status line (it would replace the user's own statusLine setting; ADR-0003 and the add-only rule); `~/.claude.json` lastCost (undocumented, one value per folder, a shared global file); a SessionStart hook writing to a file beside the transcript, now (correct but larger, needs an ADR-0003 change; deferred); recording transcript byte lengths before launch (same answer, needs a scan before Claude Code starts); adding up cost-state lines (one exit can write the line twice); headlining the conversation total on a resume (overcounts); new price rows (founder, S176/S177).
- Named limits: crash or kill gives no figure; `/clear` still skips the meter; concurrent sessions in one folder; on a resume the estimate still counts the whole file's tokens; the `-p --resume` stream total may include earlier spend (unverified, unchanged by AC4); the transcript folder name only replaces `/` (deferred); Claude Code older than 2.1.275 gives no figure; Claude Code calls the line format internal — the pinned 2.1.280 fixture checks only Vajra's own reading of it, and a record that is missing or unreadable on 2.1.275+ is named in a `[vajra warn]` line (review rec 1); a fork is assumed to keep Claude Code's `startTime` (unverified, review rec 4).

## Carried in
- F67 (S176 summary row; STATE 🔴). Memory: read the tool's own cost, don't grow a price list (S77–S79).
- From S188: the approvals before/after check shipped (DECISION-011 S188 addendum); rudra gets it on its next
  `--sync-fleet`. **Backlog, S190 checklist:** N2; the rest of N7; F97's opt-out key; `--advance` number-swaps
  SESSION-BOOT (hit again in S188); the session guard reads a session number in edit text; verify-133 not safe to
  run twice at once; `tests/gt_cadence_shared.rs` reads the real repo's summary; S188's named gaps (a change undone
  in one command, writes between pairs, another project's folder). **Parked:** non-Claude tools, release.

## Guardrails
- ≤3 files per commit; every fix has a check red at the start commit for the named reason.
- A paid live run needs the founder's yes first, cheapest model, throwaway folder.
- Never print a guessed dollar figure as the headline.
- Run the full `cargo test` before pushing.

## Plan
1. The meter reads Claude Code's own record: `cost-state` lines parsed from the main transcript into their own
   field (never `authoritative_dollars`); this run's share by the timestamp cut, baseline, `startTime` and
   fail-closed rules; one resolver (result line → `-p` stream → cost-state → none); the no-figure headline and
   the `[estimate]` line; `hasUnknownModelCost` said on the headline; `meter_session` = the whole conversation
   (no launch time), `meter_run` = this run. Unit tests on a fixture pinned from a real 2.1.280 transcript
   (fresh, resume, crash, fork, unknown model, `-p` still wins) (`src/meter/mod.rs`,
   `tests/fixtures/meter/cost-state-2.1.280.jsonl`). covers: 1, 2, 3, 4
2. The launcher hands the launch time to the meter, so an interactive `vajra claude` receipt shows this run's
   share (`src/cli/launch.rs`). covers: 1
3. The record: the S189 addendum to ADR-0004 (the source order, the share rules, the deviation from §2.8, the
   named limits) (`docs/adr/0004-meter-receipt-design.md`). covers: 1, 2, 3
4. `scripts/verify-session-189.sh` — real runs of the real binary with a stub `claude` that writes a recorded
   transcript, each check red at 8e52d29 for its reason, the price list diffed against 8e52d29 — and
   `scripts/demo-session-189.sh`; the full `cargo test` before the push. covers: 1, 2, 3, 4, 5

## Execution
- step 1 — done: 164e516
- step 2 — done: 49ef0da
- step 3 — done: 2d6ab54
- step 4 — done: 52c88df

## Advice
Roles dispatched: `tech-lead` (mandatory, first), `researcher` (required; deliverable 1 was an open fact),
`design-advisor` (required; design-significant: yes), `fidelity-reviewer` (required; the one cold close review),
`release-coordinator` (required; the one judge of every `obeyed:` answer).
requirements-analyst: skipped — the tech-lead deferred it on budget: the 4 deliverables and 5 ACs restate the founder's own F67 ask (S176/S177), so a ~0.4M pass would only restate them and push the ~4.0M crew to ~4.4M.
plan-advisor: skipped — the tech-lead deferred it on budget: one story, the Planner gate already checks `covers: N`, and its rec 1 gave the one order that mattered (~0.4M more).
implementation-advisor: skipped — the tech-lead deferred it on budget: reading meter, launch, the receipt tests and the injector is ~1.0M (crew to ~5.0M); the design-advisor's shape and the real-run AC1–AC4 checks stand in for it.
qa-specialist: skipped — the tech-lead deferred it on budget: AC5 already requires real-run checks red at the start commit; the author wrote verify-189 and the fidelity-reviewer read it (~0.8M saved).
demo-producer: skipped — the tech-lead deferred it on budget: the only user-facing change is the receipt's top line, which the fidelity-reviewer read (~0.5M saved).

## Delta
- `~` an interactive `vajra claude` receipt's headline cost: the tool's own figure, or "no cost known"
- `~` the price-list estimate: labelled `[estimate]`, never the headline
- `-` F67 from STATE's broken list (if AC1–AC3 pass)
