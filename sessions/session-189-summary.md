# Session 189 — Summary (CODE: F67 for good — the receipt reads Claude Code's own cost)

**Branch:** `session-189-receipt-tool-cost` · **Prompt:** `prompts/189-task-receipt-tool-cost.md` (founder-approved,
`vajra approve 189`) · **Record:** ADR-0004 S189 addendum · **Verify:** `scripts/verify-session-189.sh` (13/13) ·
**Demo:** `scripts/demo-session-189.sh` (7/7 live checks) · full `cargo test` 695 passed / 0 failed · cost $0 (no paid run).

## Goal achieved?

Yes, on recorded lines. An interactive `vajra claude` receipt's top line is now Claude Code's own figure for
this run, or says "no cost from Claude Code for this run" with no dollar sign. The price-list number is only
ever the labelled `[estimate]` line beneath it. No price rows were added.

- **Where the figure lives (researcher):** Claude Code 2.1.275 and later appends a `{"type":"cost-state"}`
  line with its own running `totalCostUSD` to the main transcript at each normal exit. S77 found no cost in
  the transcript because this line did not exist yet. On rudra's last run (2026-10-03) it reads $29.89, the
  same number `~/.claude.json` keeps.
- **This run's share:** a resumed chat keeps a running total (4.65 → 13.94 → 17.51 → 25.60 in one real
  transcript). The receipt shows the last total minus the last total written before the first line stamped
  at or after the launch. On any doubt (a crash, no readable timestamp, a negative share, a fork or a resume
  missing its earlier total) it shows no figure.
- **Same run, both binaries (verify AC1):** at 8e52d29 the top line read `~$23.91 estimated`. Today it reads
  `$4.65 what this run cost — Claude Code's own figure`: the old guess was ~5× too high, which is F67.

## Fidelity map

| # | Requirement | Status | Evidence |
|---|---|---|---|
| D1 | Find the tool's own figure (researcher first), recorded in the design | SHIPPED | `.ai/handoffs/session-189-researcher.md`; the prompt's `## Design`; ADR-0004 S189 addendum (2d6ab54). Status line rejected (it is the user's); `~/.claude.json` kept as a cross-check only; hooks carry no cost |
| D2 | The receipt uses it; none → "no cost from Claude Code for this run" + labelled `[estimate]` | SHIPPED | 164e516 (meter: `cost_state_record`, `headline_dollars`, receipt wording), 49ef0da (launch time passed in); verify AC1/AC2 |
| D3 | No new price rows | SHIPPED | verify row "deliverable 3": `MODEL_PRICING` has the same 7 rows and rates as 8e52d29 |
| D4 | Projects get it with no action | PARTIAL | No setting or file is needed in a project — the change is in the `vajra` binary. But rudra sees it only after the founder installs the new `vajra` (`cargo install --path .`); nothing here installs it, and no real rudra run has used it yet |
| AC1 | Recorded interactive-run fixture with a known figure → headline equals it; red at start | SHIPPED | verify AC1 fresh ($4.65) + resumed ($9.30 share), both red at 8e52d29 (`~$23.91 estimated`, `~$47.82 estimated`); unit tests on `tests/fixtures/meter/cost-state-2.1.280.jsonl` |
| AC2 | No figure → headline says so; estimate labelled, not the headline | SHIPPED | verify AC2 (crash: no cost-state written) — no `$` on the top line, `~$… [estimate…]` beneath; red at 8e52d29 |
| AC3 | Unknown model (`claude-opus-9`) never makes the headline a guess | SHIPPED | verify AC3; the upper-bound tag rides the estimate line only; red at 8e52d29 |
| AC4 | `-p` runs unchanged | SHIPPED | verify AC4: the same top line at 8e52d29 and today (`$0.42` from the stream, not the log's `$4.65`); unit test `s189_the_p_stream_still_wins_over_the_transcript_record` |
| AC5 | Real-run checks, red at start; full `cargo test` before the PR | SHIPPED | verify-189 runs the real binaries against a stand-in `claude`; 695/0 |

## What was NOT built / limits (named, not closed)

- **No live interactive run.** Every proof uses a stand-in `claude` that writes real 2.1.280 cost-state lines.
  Whether a real interactive session behaves the same through `/clear` and `--continue` is unproven (researcher
  rec 5: a few cents, the founder's yes first).
- **`/clear`** makes two transcripts newer than the launch, and the meter still skips the whole receipt
  ("multiple sessions detected"), as before. The same goes for two sessions running at once in one folder.
- **On a resumed chat the `[estimate]` line still counts the whole file's tokens** (older behaviour). It now
  sits beside a top line that covers only this run.
- **The transcript folder name:** `find_session_jsonl` replaces only `/`, while Claude Code replaces every
  character that is not a letter or digit. A project path with `.`, `_` or a space finds no transcript and
  gets no receipt. `CLAUDE_CONFIG_DIR` is ignored. Researcher rec 6, deferred → backlog, S190 GT checklist.
- **No session-id match by SessionStart hook** (researcher rec 2): the run's transcript is still "the one file
  changed since launch". Deferred → backlog, S190 GT checklist (it needs an ADR-0003 addendum).
- The budget check still uses the estimate when Claude Code gives no figure (as before). Claude Code's figure
  is its own list-price total, not an invoice. The per-model split is not shown.

## Fakest green

The resume share is proven on a stand-in that APPENDS to a copied log. Claude Code's real resume behaviour is
taken from one transcript: it keeps the same file, restores the total and writes a new cost-state line at exit.
Nobody has watched a real `--continue` through `vajra claude`. If Claude Code ever copies the earlier total into
a new file instead, the receipt shows "no cost … includes spend before this run" (fail closed), not a wrong
number, but the share would not be shown.

## Process

- Crew per the tech-lead: researcher → design-advisor → build → one fidelity-reviewer → one release-coordinator.
  Plan, implementation, QA and demo roles were deferred on budget (skip lines in `## Advice`).
- `vajra next --advance` number-swapped SESSION-BOOT again (S188's line became "189"); fixed by hand in bcc0ada.

## Next — 3 ranked candidates

1. **(Recommended) S190 — the ground truth (review-only, due by the rule).** Review S186–S189 against the
   vision and roadmap, and the S190 checklist (N2, N7's rest, F97's opt-out key, the `--advance` number swap,
   S188's named gaps, S189's two deferred researcher recs). Why: every 5th session is review-only, and four
   CODE sessions ran since S185. Risk: none — it is the rule; it changes no code.
2. **After S190: the non-Claude tools brainstorm (F91, F94, F95).** Promised since S179: OpenCode's agent and the
   founder look the same to the git guards. Why: the next user may not use Claude Code. Risk: a design session,
   and nothing a user runs comes out of it.
3. **After S190: rudra S18 — the new receipt and the approvals check in real use.** Install the new `vajra`,
   `--sync-fleet` rudra, and run a real session. Why: S188 and S189 are proven only on stand-ins and one Haiku
   run. Risk: waits for rudra's data API (founder, 2026-10-04).
