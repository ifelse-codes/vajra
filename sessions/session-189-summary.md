# Session 189 — Summary (CODE: F67 for good — the receipt reads Claude Code's own cost)

**Branch:** `session-189-receipt-tool-cost` · **Prompt:** `prompts/189-task-receipt-tool-cost.md` (founder-approved,
`vajra approve 189`) · **Record:** ADR-0004 S189 addendum · **Verify:** `scripts/verify-session-189.sh` (20/20) ·
**Demo:** `scripts/demo-session-189.sh` (7/7 live checks) · full `cargo test` 697 passed / 0 failed (after the
review fixes: see Process) · **Review:** `sessions/session-189-review.md` (one cold pass, ACCEPT) · cost $0 (no paid run).

## Goal achieved?

Yes, on recorded lines and a stand-in — not yet on a live interactive run. An interactive `vajra claude`
receipt's top line is now Claude Code's own figure for this run, or says "no cost from Claude Code for this
run" with no dollar sign. The price-list number appears only on the labelled `[estimate]` lines beneath it.
No price rows were added.

- **Where the figure lives (researcher):** Claude Code 2.1.275 and later appends a `{"type":"cost-state"}`
  line with its own running `totalCostUSD` to the main transcript at each normal exit. S77 found no cost in
  the transcript because this line did not exist yet. On rudra's last run (2026-10-03) it reads $29.89, the
  same number `~/.claude.json` keeps.
- **This run's share:** a resumed chat keeps a running total (4.65 → 13.94 → 17.51 → 25.60 in one real
  transcript). The receipt shows the last total minus the last total written before the first line stamped
  at or after the launch. With no readable cut, no record from this run, or a negative share, it shows no
  figure. The same happens when the log holds no earlier total and Claude Code's start time is before the
  launch (a resume missing its earlier total; a fork, IF a fork keeps the parent's start time — unverified).
- **Same run, both binaries (verify AC1):** at 8e52d29 the top line read `~$23.91 estimated`. Today it reads
  `$4.65 what this run cost — Claude Code's own figure`: the old guess was ~5× too high, which is F67.
- **A silent "no cost" is named:** when a run on Claude Code 2.1.275+ leaves no record, or a record has no
  readable total, the receipt says so in a `[vajra warn]` line. If Claude Code changes the format, that warning
  is what shows it.

## Fidelity map

| # | Requirement | Status | Evidence |
|---|---|---|---|
| D1 | Find the tool's own figure (researcher first), recorded in the design | SHIPPED | `.ai/handoffs/session-189-researcher.md`; the prompt's `## Design`; ADR-0004 S189 addendum (2d6ab54, 3c973c1). Status line rejected (it is the user's); `~/.claude.json` kept as a cross-check only; hooks carry no cost |
| D2 | The receipt uses it; none → "no cost from Claude Code for this run" + labelled `[estimate]` | SHIPPED | 164e516 (meter), 49ef0da (launch time passed in), 2146e27 (the split line labelled, the missing-record warning), 4947a15 (the budget line calls an estimate an estimate); verify AC1/AC2 |
| D3 | No new price rows | SHIPPED | verify row "deliverable 3": `MODEL_PRICING` has the same 7 rows and rates as 8e52d29 |
| D4 | Projects get it with no action | PARTIAL | No setting or file is needed in a project — the change is in the `vajra` binary. But rudra sees it only after the founder installs the new `vajra` (`cargo install --path .`); nothing here installs it, and no real rudra run has used it yet |
| AC1 | Recorded interactive-run fixture with a known figure → headline equals it; red at start | SHIPPED | verify AC1 fresh ($4.65) + resumed ($9.30 share), both red at 8e52d29 (`~$23.91 estimated`, `~$47.82 estimated`); unit tests on `tests/fixtures/meter/cost-state-2.1.280.jsonl` (two real cost-state lines; its duplicate line and token counts are made up) |
| AC2 | No figure → headline says so; estimate labelled, not the headline | SHIPPED | verify AC2 (crash: no cost-state written) — no `$` on the top line, `~$… [estimate…]` beneath; red at 8e52d29 |
| AC3 | Unknown model (`claude-opus-9`) never makes the headline a guess | SHIPPED | verify AC3; the upper-bound tag rides the estimate line only; red at 8e52d29 |
| AC4 | `-p` runs unchanged | SHIPPED (stream/json `-p`) | verify AC4: the same top line at 8e52d29 and today (`$0.42` from the stream, not the log's `$4.65`). Not unchanged: a text-mode `-p` (no `--output-format`) has no stream, so it now shows the log's figure where it showed the estimate — untested |
| AC5 | Real-run checks, red at start; full `cargo test` before the PR | SHIPPED | verify-189: 20 real runs of the real binaries against a stand-in `claude`, the fork branch, the unpriced record, the missing-record warning and the budget line included (42842ea); the test-name count row removed; full `cargo test` 697/0 |

## The cold review (one pass, ACCEPT 10/14 · 3 PARTIAL · 1 NOT-BUILT) and what it changed

All 7 recs were answered in this session (details in the prompt's `## Advice`):
- **rec 1 (fakest green: "the tripwire"):** a pinned fixture cannot notice Claude Code changing its format. The
  receipt now names a missing or unreadable record on 2.1.275+ in a `[vajra warn]` line (2146e27). The ADR and
  the Design no longer call the fixture a tripwire (3c973c1).
- **rec 2:** the price-list split line (`new text $… · replies $…`) is labelled `[estimate] split:` (2146e27).
- **rec 3:** over the budget cap with no figure, the line says "Vajra's own token estimate ~$X … (no cost from
  Claude Code for this run)", never "session cost" (4947a15).
- **rec 4:** the fork start-time assumption is named in the ADR's limits, and the founder's live check should
  include a fork (3c973c1).
- **rec 5:** this summary's five overclaims are corrected: the fork, text-mode `-p`, `## Advice` written,
  backlog entries made, and "2.1.280-shaped" lines rather than "real" ones.
- **rec 6:** real-run verify rows added for the fork branch and the unpriced record, the count row removed (42842ea).
- **rec 7:** STATE records F67 as fixed on recorded lines only, still waiting for one real interactive receipt.
- The NOT-BUILT row (Delta: F67 off STATE) is the closeout's STATE edit, worded per rec 7.

## What was NOT built / limits (named, not closed)

- **No live interactive run.** Every proof uses a stand-in `claude` that writes 2.1.280-shaped cost-state lines
  around one real transcript's totals. `/clear`, `--continue` and a fork through `vajra claude` are unproven
  (researcher rec 5, review rec 4: a few cents, the founder's yes first).
- **A fork is assumed to keep Claude Code's start time.** If it resets it while carrying the parent's total, the
  receipt would show the parent's spend as this run's cost. This is the one way left for a wrong number with a
  "this run" label.
- **`/clear`** makes two transcripts newer than the launch, and the meter still skips the whole receipt
  ("multiple sessions detected"), as before. The same goes for two sessions running at once in one folder.
- **On a resumed chat the `[estimate]` lines still count the whole file's tokens** (older behaviour). They now
  sit beside a top line that covers only this run.
- **The transcript folder name:** `find_session_jsonl` replaces only `/`, while Claude Code replaces every
  character that is not a letter or digit. A project path with `.`, `_` or a space finds no transcript and
  gets no receipt; `CLAUDE_CONFIG_DIR` is ignored. Researcher rec 6 → backlog (ROADMAP, S190 checklist).
- **No session-id match by SessionStart hook** (researcher rec 2): the run's transcript is still "the one file
  changed since launch" → backlog (ROADMAP, S190 checklist; it needs an ADR-0003 addendum).
- Claude Code's figure is its own list-price total, not an invoice. The per-model split is not shown.

## Fakest green

The resume share and the fork guard rest on what ONE real transcript shows: same file, the total carried over,
the start time kept, a new cost-state line at exit. The stand-in is built on that same assumption, so it cannot
check it. If a real resume behaves that way, the share is right. If Claude Code copies the earlier total into a
new file, the receipt says "no cost … includes spend before this run" (fail closed). If a fork resets the start
time, the receipt is wrong. Only a live run settles it.

## Process

- Crew per the tech-lead: researcher → design-advisor → build → one fidelity-reviewer (ACCEPT) → one
  release-coordinator. Plan, implementation, QA and demo roles were deferred on budget (skip lines in `## Advice`).
- `vajra next --advance` number-swapped SESSION-BOOT again (S188's line became "189"); fixed by hand in bcc0ada.
- The full `cargo test` first went red (1 failure): `tests/gt_cadence_shared.rs` reads this repo's real summary,
  and this summary's first option said the words that test looks for. The option was reworded; the test bug is
  already on the S190 checklist (S188 backlog).

## Next — 3 ranked candidates

1. **(Recommended) S190 — the review-only session (NO-CODE, due by the every-5th rule).** Review S186–S189 against
   the vision and roadmap, and the S190 checklist (N2, N7's rest, F97's opt-out key, the `--advance` number swap,
   S188's named gaps, S189's two deferred researcher recs, `gt_cadence_shared` reading the real summary). Why:
   every 5th session is review-only, and four CODE sessions ran since S185. Risk: none — it is the rule; it
   changes no code.
2. **After S190: the non-Claude tools brainstorm (F91, F94, F95).** Promised since S179: OpenCode's agent and the
   founder look the same to the git guards. Why: the next user may not use Claude Code. Risk: a design session,
   and nothing a user runs comes out of it.
3. **After S190: rudra S18 — the new receipt and the approvals check in real use.** Install the new `vajra`,
   `--sync-fleet` rudra, and run a real session (with a `--continue` and a fork for S189). Why: S188 and S189 are
   proven only on stand-ins and one Haiku run. Risk: waits for rudra's data API (founder, 2026-10-04).
