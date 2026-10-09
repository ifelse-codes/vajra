---
role: design-advisor
session: 193
agent: claude-code-subagent (verified: toolu_01DwmQsVyHdzUd5YTVP498qB; text-sha: 9434f52557aebbd839b738ac2e54dae964223883a80b116fbe633e6b7487f98c)
source-sha: 5e1bb7433852dff67736a1a87f0a990821e3990584b15e1c33b6b399de097ef5
captured: 2026-10-09T15:15:57Z
cost_usd: null
---

# Design-advisor handoff — session 193

Design-advisor brief: S193, F117 (drop the token estimate when Claude Code gives its own cost)

I read `src/meter/mod.rs` (lines 140-195, 198-281, 480-564, 708-845, and the tests at 1270-1314, 1539-1558, 1645-1658), `docs/adr/0004-meter-receipt-design.md` (the S189 and S192 addenda) and `scripts/verify-session-189.sh`. Both records I cite below exist.

rec 1 — Count three cases as "Claude Code gave its own figure": `authoritative_dollars` Some, `ToolRecord::ThisRun` (even when `unpriced`), and `ToolRecord::WholeConversation`. `IncludesEarlierSpend` and None stay "no figure". Decide this in one place, a `SessionCost` method (e.g. `has_tool_figure()`), and use it everywhere.
- **Why WholeConversation counts:** it only happens in `vajra meter FILE`, which has no launch time. The receipt there describes the whole file, and Claude Code's total covers exactly the whole file. So it is the tool's own figure for exactly what is shown. The code already treats it as a figure: `tool_has_figure` at line 538 drops `NO_REPORTED_COST_WARNING` for it.
- **Why IncludesEarlierSpend does not count:** the headline already says "no cost from Claude Code for this run". The founder's rule ("estimates appear only when there is no real figure") keeps the estimate there.
- **Reuse, don't copy:** the line-538 check should call the same method. A second hand-written `matches!` is the drift pattern (derive the default, don't copy it).

rec 2 — In those three cases, drop the `~$… [estimate…] Vajra's own estimate` line, the `[estimate] split:` line and the "not in pricing table" warning. This includes the `Some(authoritative)` arm's `$X  Vajra's own estimate from tokens` line (line 755), which has the same problem. Keep the headline, the "Claude Code could not price every model" note, the two compression lines, the bottom rule and every other warning.

rec 3 — Decide the unknown-model warning when the receipt is printed, not in `meter_session` (line 521).
- **The problem:** `apply_captured_cost` fills `authoritative_dollars` after `meter_session` returns. Today it only removes `NO_REPORTED_COST_WARNING` (line 192).
- **What goes wrong:** a `-p` run that has a stream figure but no cost-state line would keep the warning beside a real figure.
- **Fix:** build the warning in `format_receipt` from `cost.unknown_models` when `!has_tool_figure()`, or remove it in `apply_captured_cost` as well. The first option is a single place and is preferred.

rec 4 — Also drop the `[estimated] cache tier split unavailable` warning when there is a figure. It only describes the estimate, which is no longer shown. The founder did not name it, so the author may refuse this one in writing.

rec 5 — Mark the session `design-significant: yes` and write an S193 addendum to ADR-0004 that says it deviates from the S189 addendum.
- **Why yes:** this changes a promise a record makes. The S189 addendum's "Receipt wording" paragraph says "The token figure only ever rides the line beneath", and the code comment at lines 727-728 says it is "always a labelled `[estimate]` line beneath". A pure fix would not contradict a locked record.
- **Why a new addendum:** a citation alone would pass the gate (it checks the form, not obedience), but the record would then be wrong. The addendum replaces only that paragraph's estimate rule. The source order, the share rule, "No price rows are added" and the S192 folder rule stay as they are.

rec 6 — The addendum should list these limits as named, not closed:
- (a) The `~$… saved` compression line is still priced from the price list. For opus-5-5 that means the unknown-model upper bound, now disclosed only by its own "est." text. Kept per the founder.
- (b) When Claude Code reports `hasUnknownModelCost`, its figure may undercount, and no estimate is shown next to it.
- (c) `IncludesEarlierSpend` (a fork) still shows the whole-file token estimate beside "no cost for this run". This is unchanged from S189.

rec 7 — Flip the two unit tests that pin the old rule; do not delete them.
- Lines 1291-1310: the authoritative figure with an unknown model now asserts there is no `Vajra's own estimate` line, no upper-bound tag and no "not in pricing table" warning.
- Lines 1654-1657: the ThisRun case asserts that line 2 is not `[estimate`.

Add one unit test for WholeConversation (no estimate), plus one each for `IncludesEarlierSpend` and None that require the estimate and split lines to still be there.

rec 8 — Add `scripts/verify-session-193.sh`, modelled on `verify-session-189.sh`. It should build the real binary, use the stand-in `claude`, and compare against an old binary built at the pinned commit S193 started from (the last commit before the fix; the receipt code has not changed since d2ec218). Checks:
1. **Fresh run, opus-5-5, red at the start commit.** Use `STUB_MODEL=claude-opus-5-5` and `STUB_TOTAL=37.27`. The stand-in also appends `{"lines_in":18,"lines_out":1,"command":"cargo"}` to `$VAJRA_SESSION_STATS`, which `launch.rs:93` passes to the child.
   - Now: the block between the two rules is exactly 3 lines: the headline `$37.27  what this run cost — Claude Code's own figure  (opus-5-5 …`, `17 lines folded across 1 tool calls`, and `~$… saved`. There is no `not in pricing table` warning.
   - At the start commit: the same run shows `[estimate · opus-5-5 priced at the unknown-model upper bound` and the warning. That is F117 itself.
   - Assert the exact line count with the headline present, not just that a grep finds nothing (a missing receipt would also find nothing).
2. **A `-p` stream run:** no `Vajra's own estimate` line now; the old binary printed `$X  Vajra's own estimate from tokens`.
3. **`vajra meter tests/fixtures/meter/cost-state-2.1.280.jsonl`** (WholeConversation): the `$13.94 … whole conversation` headline with no estimate line now; the old binary had one.
4. **Controls that must not change:**
   - Crash (`STUB_CRASH=1`, opus-5-5): still the estimate, the split and the "not in pricing table" warning.
   - Fork (`STUB_SEED_START` before the launch): still the estimate line.
   - In both cases the output after the headline is the same for the new and old binaries.
5. **Price list unchanged:** the price list matches the start commit row by row, reusing 189's check 5 (no price rows, standing founder rule).

**Alternatives I rejected:**
- **Keep the estimate but shrink it to one line:** the founder explicitly said drop it.
- **Keep the estimate when `hasUnknownModelCost` is true:** for that same model the estimate is only the upper-bound guess, and the headline note already discloses the gap.
- **Add an opus-5-5 price row so the estimate is closer:** this breaks the standing rule to read the tool's own cost and never grow the price list.
- **Treat WholeConversation as "no figure" because it is not "this run":** in `meter FILE` the scope is the file, and the code already counts it as a figure.
- **Drop the estimate for IncludesEarlierSpend too:** there is no figure for this run, and the founder's rule keeps the estimate there.
- **Keep the warning-push in `meter_session` (line 521) and gate it on `tool_record` there:** the late `apply_captured_cost` path (rec 3) would still leave the warning beside a stream figure.

**Proposed `## Design` text:**

```
design-significant: yes

Cites docs/adr/0004-meter-receipt-design.md (S189 addendum, "Receipt wording") and DEVIATES from it:
S189 kept Vajra's token recompute as a labelled [estimate] line beneath Claude Code's own figure.
The founder's F117 call (rudra S19: $37.27 headline beside a ~$167.44 upper-bound estimate) replaces
that: when Claude Code gave its own figure — a result-line / -p stream total, this run's cost-state
share, or the whole-conversation total `vajra meter FILE` shows — the receipt prints only that
headline and the compression lines; the [estimate] line, the [estimate] split line and the
"not in pricing table" warning appear only when there is no figure (no record, or a fork /
earlier-spend total). One SessionCost predicate decides "has a figure", used by both the receipt
and the no-reported-cost warning; the unknown-model warning is decided at render time so a late
-p stream figure also suppresses it. No price rows are added. Recorded as an S193 addendum to
ADR-0004. Rejected: a shrunk estimate line (founder said drop), keeping it on hasUnknownModelCost
(same upper-bound guess), a new opus-5-5 price row (standing rule), treating meter FILE's
whole-conversation total as no figure (it is the tool's figure for exactly that scope).
```

Files:
- /Users/suman/playground/vajra/src/meter/mod.rs (lines 172-195, 521-544, 708-792, 816-819; tests 1291-1310, 1654-1657)
- /Users/suman/playground/vajra/docs/adr/0004-meter-receipt-design.md (S189 addendum at lines 385-475, S192 at 477-528)
- /Users/suman/playground/vajra/scripts/verify-session-189.sh (template for the new script)
- /Users/suman/playground/vajra/src/cli/launch.rs:93 (`VAJRA_SESSION_STATS`, so the stand-in can feed the compression lines)

## Handoff Delta
- `+` new: first design-advisor handoff for this session (9031 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
