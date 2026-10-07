# Session 189 — Independent Fidelity Review

One cold pass by a fresh fidelity-reviewer dispatch, not the builder. Recorded verbatim through `vajra next --role fidelity-reviewer` (`.ai/handoffs/session-189-fidelity-reviewer.md`). Its recs are answered in the prompt's `## Advice`; all seven were fixed in-session (2146e27, 4947a15, 42842ea, 3c973c1, the summary, and STATE at closeout).

## Fidelity review: Session 189 (cold, adversarial)

**Verdict:** ACCEPT
**Count:** 10 of 14 SHIPPED (3 PARTIAL, 1 NOT-BUILT)

**Scope:** The whole contract was built, not one narrow slice passed off as the whole. But every proof runs on a stand-in `claude` and a hand-built fixture. No real interactive run has been watched. Several claims in the ADR, the demo and the summary go further than the code proves (listed below).

**How I reviewed it:** One cold pass. I read the prompt first, then the branch diff (8e52d29..ebeaa04) and the per-commit file list. Then I read the HEAD versions of `src/meter/mod.rs`, `src/cli/launch.rs` and `src/cli/meter.rs`, plus the `budget` formatter. I checked the fixture against the real transcript it claims to come from. I read the builder's captured verify and demo output as claims, not proof. I ran no code. The summary is inside the diff, so I saw it while reading. I formed every grade from the code before I compared it with the summary.

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| D1 | Find the tool's own figure (researcher first); record it in the design | SHIPPED | The researcher handoff (c936a1c) found the `cost-state` line and rejected the status line, `~/.claude.json` and hooks, with reasons. This is recorded in the prompt's `## Design` (bcc0ada) and the ADR-0004 S189 addendum (2d6ab54). Vajra only reads the transcript after exit. `--settings` and the user's statusLine are untouched (no diff in the injector). |
| D2 | The interactive headline is the tool's own figure, labelled; with none it says "no cost from Claude Code for this run" and the estimate is a labelled `[estimate]` | SHIPPED | `format_receipt` now matches on `(authoritative_dollars, tool_record)`. `ThisRun` prints `$X  what this run cost — Claude Code's own figure`. `None` and `IncludesEarlierSpend` print the no-cost headline with no `$`. `estimate_line` carries `[estimate]`. `launch.rs` now calls `meter_run(..., Some(session_start))`. Gap: the breakdown line `new text $… · replies $… · re-reading context $… · saving context $…` is still priced from the price list (the ceiling rate for unknown models) and has no label (see rec 2). |
| D3 | No new price rows | SHIPPED | No hunk in `src/meter/mod.rs` touches `MODEL_PRICING` or `pricing_for` (the hunk at line 69 only rewrites `NO_REPORTED_COST_WARNING`). Verify row 5 compares the table with 8e52d29 entry by entry. That check is weak (a pricing special case outside the const would slip past it), but the diff itself shows no change. |
| D4 | Projects get it with no action (rudra's next run shows the real figure) | PARTIAL | The change is binary-only and needs no project file. rudra's path has no `.`, `_` or space, so the slug is fine. But nothing in the diff shows a rudra run, and the binary has to be installed first. The builder grades this PARTIAL too. |
| AC1 | A recorded interactive fixture: headline equals the tool figure; red at start because it prints the price-list estimate | SHIPPED | Verify rows 1–4 run the real binary at HEAD and at 8e52d29: fresh run `$4.65` vs old `~$23.91  estimated`; resumed run `$9.30` vs old `~$47.82  estimated`. Each is red for the reason it names. The fixture is a hybrid: the 4.648… and 13.943… totals and the `startTime` match the real `69ecb30e…jsonl` (lines 400 and 849). The duplicate 13.94 line (totalDuration 39912083) does not exist in that file. The run-2 assistant usage is invented. |
| AC2 | No figure: the headline says so; the estimate is labelled and is not the headline | SHIPPED | Verify row 3 (`STUB_CRASH`): headline equals " no cost from Claude Code for this run", no `$`, `~$… [estimate` beneath. Red at 8e52d29. Unit test `s189_no_record_from_this_run_means_no_figure` also covers no cut, a negative total and a non-numeric total. |
| AC3 | An unknown model never makes the headline a guess | SHIPPED | Verify row 4 (`claude-opus-9`, no record): no `$` on the headline, and the upper-bound tag appears only on the estimate line. Red at 8e52d29 (`~$23.91  estimated  (opus-9`). The headline itself never uses the price list. |
| AC4 | `-p` runs unchanged (the result stream still wins) | SHIPPED | `tool_record` is its own field, so `apply_captured_cost` still fills an empty `authoritative_dollars`. `headline_dollars` checks `authoritative_dollars` first. Verify row 6 requires the same headline string from both binaries (`$0.42`, not the log's `$4.65`), and that check could actually fail. One caveat: text-mode `-p` (no `--output-format`) has no stream, so it now shows the cost-state figure where it used to show `~$X estimated`. That is better, but it is not literally "unchanged", and nothing tests it. |
| AC5 | Every fix has a real-run check in verify-189 (no source greps), red at 8e52d29; full `cargo test` before the PR | PARTIAL | Rows 1–4, 6 and 7 are real runs, red at start. Not covered by any real run: the `IncludesEarlierSpend` branch (the fork / startTime guard) and the `hasUnknownModelCost` headline note. Both have unit tests only. Row 8 counts test names (`[ "$s" -ge 8 ]`), so it would pass with eight empty `s189_*` tests, and it is not red at start for any named reason. The full `cargo test` result (695/0) is the builder's claim; I have no captured output for it. |
| G1 | ≤3 files per commit; every fix red at start for the named reason | SHIPPED | From s189-log.txt: bcc0ada 3 files, c936a1c 3, 164e516 2, 49ef0da 1, 2d6ab54 1, 52c88df 2, 55dd131 1, ebeaa04 1. Red-at-start holds for the AC1–AC3 and `vajra meter` rows. |
| G2 | A paid live run needs the founder's yes first | SHIPPED | No paid run was made. Every run uses a $0 stand-in. |
| G3 | Never print a guessed dollar figure as the headline | SHIPPED | No branch of `format_receipt` puts `total_dollars` on the headline. The JSONL-not-found branch in `print_receipt` prints no receipt and returns `captured_cost`, so no guess appears there. But outside the receipt, `check_budget_cap(billed_dollars())` falls back to the estimate and prints `[vajra budget] WARNING: session cost $X exceeds cap`. Vajra's own `.ai/CONSTRAINTS.yaml` caps at $5.00, so an Opus 5.5 run with no record would print "session cost $23.9100", a guess labelled as cost (rec 3). |
| G4 | Run the full `cargo test` before pushing | PARTIAL | Claimed only (695/0). Verify row 8 runs only `--lib meter::`. I could not run it, and no output was supplied. |
| Δ | Delta: F67 off STATE's broken list (if AC1–AC3 pass) | NOT-BUILT | `.ai/STATE.md` is untouched on the branch. This may belong to closeout, but as the branch stands it is not done (see rec 7 on how to word it). |

### Hunts I was asked to run

- **A guessed dollar on the top line.** None found on the interactive, `-p`, `vajra meter`, unknown-model or JSONL-not-found paths. Guessed dollars still reach the user in two other places: the unlabelled breakdown line, and the budget warning's "session cost $X".
- **Is `-p` really unchanged?** For stream/json `-p`, yes, and it is proven by comparing the output of both binaries. Text-mode `-p` changed, toward the tool's own figure.
- **Can "this run's share" go to the wrong run?** I checked the real transcript. Lines inside one run are out of order by as much as about 65 minutes (line 852 is stamped 17:03:05 while that run's first queue-op is 18:08:08), and attachment lines are stamped before queue-ops. The cut takes the first line, in file order, stamped at or after the launch. A line from an earlier run cannot carry a stamp later than this launch, so lines out of order inside a run do no harm, and lines stamped before the launch only push the cut later, which fails closed.
  - Cost-state lines have no timestamp and are skipped as cut points.
  - Duplicates are handled: the last line is taken, never a sum.
  - The one real hole is a fork. The guard assumes a fork keeps the parent's `startTime`. Nobody has verified that (the researcher said fork behaviour is unverified, and `startTime` on a fork was never checked). If Claude Code resets `startTime` on `--fork-session` while carrying over the parent's total, then with no baseline in the new file the code returns `ThisRun { dollars: whole total }`. The receipt would headline the parent's spend as "what this run cost" — exactly the F67 problem. The only test for this case is synthetic (run-2 lines with the restored startTime).
- **No source greps.** None, apart from the price-table comparison (row 5), which the Plan asked for, and the test-count row 8.

### Where the summary claims more than was done

- **"On any doubt (… a fork …) it shows no figure."** Only true if a fork keeps the parent's startTime, which is unverified. The demo's slide 2 repeats it ("a fork → 'no cost'").
- **The AC4 row says "`-p` runs unchanged".** Text-mode `-p` changed.
- **"skip lines in `## Advice`".** The prompt at ebeaa04 has no `## Advice` section. The demo itself shows `advice answered 0 of 21`.
- **"deferred → backlog, S190 GT checklist" (researcher recs 2 and 6).** No backlog or ROADMAP entry is on the branch.
- **"a stand-in `claude` writing real 2.1.280 cost-state lines".** This appears in the commit message for 52c88df and in the demo's notes. The stand-in writes a cut-down five-field line built around one real total. The fixture's second 13.94 line is made up.

### The fakest green

**The "tripwire".** The prompt's Design, the ADR addendum and the named limits all say: "Claude Code calls the line format internal, so a pinned 2.1.280 fixture is the tripwire." The design-advisor's reasoning was "if a field is renamed, the tripwire should fail CI." A static fixture checked into the repo cannot fail when Claude Code changes its format, because the fixture keeps the old field names and its tests stay green.

When Claude Code does rename `totalCostUSD`, or stops writing the line, every receipt quietly falls back to "no cost from Claude Code for this run". Nothing alerts anyone, and the F67 fix is quietly gone. Failing closed keeps the number from being wrong, but that is a separate property. As built, the "tripwire" can only catch Vajra's own code regressing. It is labelled as protection against the one risk it cannot see.

Runner-up: the fork / startTime guard, which is tested only on a synthetic file built on the very assumption it is supposed to check.

### Recommendations

rec 1 — Stop calling the pinned fixture a tripwire: either add a real drift signal, or strike the word from the ADR addendum and the Design and name the gap.
Why: a static fixture cannot detect Claude Code changing its format, so the receipt would silently fall back to "no cost" for good. A cheap real signal is a `[vajra warn]` when a main transcript whose lines carry `"version"` ≥ 2.1.275 ends normally with no readable cost-state line, or when a cost-state line has no numeric `totalCostUSD`. Then a format change shows up as a warning rather than a silent "no cost".

rec 2 — Label the price-list breakdown line (`new text $… · replies $… · re-reading context $… · saving context $…`) as part of the `[estimate]`, or drop it when Claude Code's figure is the headline.
Why: the demo shows `re-reading context $12.46` printed under a `$4.65` headline. These are ceiling-priced dollars for Opus 5.5 and claude-opus-9 with no label, which is the F67 guess split into parts.

rec 3 — When `headline_dollars()` is None, the budget line must not call the estimate "session cost": say "estimated $X (no cost from Claude Code)", or skip the cap.
Why: `format_budget_warning` prints `session cost $23.9100 exceeds cap $5.00` (Vajra's own cap) right under a receipt that says no cost is known. That is a guessed dollar presented as spend, and with `mode: kill` it changes the exit code.

rec 4 — Add "a fork's `startTime` is unverified" to the ADR's named limits, and add a `--fork-session` step to the founder's one paid check (researcher rec 5).
Why: if a fork resets `startTime` while carrying over the parent's total, `cost_state_record` returns `ThisRun` with the whole total. The receipt would then headline the parent's spend as "what this run cost", the F67 problem again. Today the only proof is a synthetic test built on the assumption itself.

rec 5 — Before the summary lands, correct its five overclaims: fork → no figure, `-p` unchanged, `## Advice` skip lines, backlog deferrals, and "real 2.1.280 cost-state lines".
Why: each is listed above with evidence. The `## Advice` and backlog claims describe records that do not exist on the branch, and `vajra next --check-advice` will hit that anyway.

rec 6 — Add real-run verify rows for the `IncludesEarlierSpend` branch (a seeded resume missing its earlier total, with startTime before launch) and the `hasUnknownModelCost: true` headline, red at 8e52d29. Replace row 8's test-name count with something that can fail for a reason.
Why: AC5 says every fix has a real-run check. These two branches have unit tests only, and row 8 would pass with eight empty tests.

rec 7 — In STATE, record F67 as "fixed on recorded lines; no live interactive run yet" rather than deleting it, until one real rudra or vajra interactive receipt shows Claude Code's figure.
Why: the Delta removes F67 "if AC1–AC3 pass", and they pass only on a stand-in. The founder's rule is that a label is not a fix: say what is proven.

Low priority, no rec number: the comments in `src/meter/mod.rs` (around lines 68, 183 and 660–666) and `src/cli/launch.rs:308` still describe the old "no authoritative cost available" / `~$… token estimate` behaviour.

Sources read:
- /Users/suman/playground/vajra/reviewer/SKILL.md
- /Users/suman/playground/vajra/prompts/189-task-receipt-tool-cost.md
- /private/tmp/claude-501/-Users-suman-playground-vajra/60ab3ed6-0a6c-4ccf-89e6-6d4754947fc8/scratchpad/s189.diff (all 1527 lines, including the three handoffs and the summary)
- /private/tmp/claude-501/-Users-suman-playground-vajra/60ab3ed6-0a6c-4ccf-89e6-6d4754947fc8/scratchpad/s189-log.txt
- /private/tmp/claude-501/-Users-suman-playground-vajra/60ab3ed6-0a6c-4ccf-89e6-6d4754947fc8/scratchpad/verify-189.out
- /private/tmp/claude-501/-Users-suman-playground-vajra/60ab3ed6-0a6c-4ccf-89e6-6d4754947fc8/scratchpad/demo-189.out
- /Users/suman/playground/vajra/src/meter/mod.rs (lines 380–860 at HEAD)
- /Users/suman/playground/vajra/src/cli/launch.rs (lines 70–390 at HEAD)
- /Users/suman/playground/vajra/src/cli/meter.rs
- /Users/suman/playground/vajra/src/budget/mod.rs (`format_budget_warning`)
- /Users/suman/playground/vajra/docs/adr/0004-meter-receipt-design.md (G11 and the S189 addendum)
- /Users/suman/playground/vajra/.ai/CONSTRAINTS.yaml (budget cap_usd 5.00)
- /Users/suman/.claude/projects/-Users-suman-playground-vajra/69ecb30e-f3ea-4691-84aa-4fe8e8630ef8.jsonl (cost-state fields and line types/timestamps only, checked against the fixture)
- A repo-wide search for the old headline strings ("estimated  (", "no authoritative cost")

---

## The release-coordinator's pass-1 recommendations (verbatim)

Pass 2 (`.ai/handoffs/session-189-release-coordinator.md`) replaced pass 1 and made no new recs; these four are answered in the prompt's `## Advice`.

rec 1 — Fix the researcher rec 4 mismatch: add one named-limit line to the ADR-0004 S189 addendum, or reword the answer.
Why: the answer cites 2d6ab54 for the ADR naming "session moved to the background", and that text is not in the ADR. The fix is one line: "a session moved to the background (agent view) exits before Claude Code's cost is final → no figure (researcher rec 4; Vajra cannot tell it from a crash)". Commit it and re-point the answer to that commit. Also say "no session started" is moot because no transcript means no receipt. The one judge then re-checks only that line. Rewording the answer to claim only "predates", plus a `refused:` for "background" with the no-text-guessing reason, is an equally good answer.

rec 2 — Remove the leftover "A tripwire too (design-advisor rec 8)" comment at `src/meter/mod.rs:1492`, or say plainly that it stays.
Why: fidelity rec 1 and the design-advisor rec 8 answer both say the fixture is not a tripwire any more. The test code still says it is, and the S189 summary row calls that exact claim the fakest green. A one-line comment change; `refused:` (cosmetic, not shipped behaviour) is acceptable.

rec 3 — Run the full `cargo test` and `scripts/verify-closeout.sh` (with `--check-advice 189` and `--check-obeyed 189`) on the branch before the PR is merged, not after.
Why: S83 found the close check cannot be re-run correctly once main absorbs the branch. S187 found CI catching what the close skips. ROADMAP's "697/0" is the builder's claim; the fidelity review saw no captured output (its G4 PARTIAL).

rec 4 — Merge with a merge commit, then return to main, pull, and prune the merged `session-*` branches, in that order.
Why: these are the three recorded gate keys. A squash merge or an early prune is the usual reason the next session (S190, the review-only session) blocks at start.

**Review-Inputs-SHA:** 24fad7cd41d249d2d5c09f2ba0ab8420c9788a4c5328e72ce1071c70b42a64f8
