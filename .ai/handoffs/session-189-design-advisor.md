---
role: design-advisor
session: 189
agent: claude-code-subagent (verified: toolu_01QazyEyBsjRAtmYeoSUvvLR; text-sha: 75db367ec466c46cb427c209abc6fd94e0baf26dfcadc5ae6e84f365a2111dae)
source-sha: dcf5fc79efcf403f239f79c4232c49245a7f9934afb5f32af9dc2268b9cf5980
captured: 2026-10-07T02:15:23Z
cost_usd: null
---

# Design-advisor handoff — session 189

Design-advisor brief: the builder's shape is right, but it needs one structural change and two fail-closed guards before it is safe.

- **The structural change.** The cost-state figure must NOT be written into `authoritative_dollars` inside `parse_jsonl`. If it is, `apply_captured_cost` becomes a no-op on `-p` runs, because it only fills an empty field. The `-p` stream would then silently lose to the transcript, which breaks AC4.
- **The two guards.** (1) A `startTime` check so a fork or an unseen resume is never headlined as "this run". (2) Strict rules that give "no figure" whenever the run can't be pinned down.
- **The record.** No record exists for S66, S77 or S78 (I searched `docs/`: `ADR-0004` has no addenda, and no DECISION covers the receipt). Record this as an S189 addendum inside `docs/adr/0004-meter-receipt-design.md`, not as a new record. It deviates from ADR-0004 §2.8, and the addendum must say so.

Sources read:
- /Users/suman/playground/vajra/prompts/189-task-receipt-tool-cost.md
- /Users/suman/playground/vajra/.ai/handoffs/session-189-researcher.md
- /Users/suman/playground/vajra/.ai/handoffs/session-189-tech-lead.md
- /Users/suman/playground/vajra/docs/adr/0004-meter-receipt-design.md (whole file)
- /Users/suman/playground/vajra/docs/adr/0005-pre-run-cost-estimate.md (first 60 lines; not relevant)
- the `docs/adr/` + `docs/decisions/` listing, plus a search of every `##` heading for S66/S77/S78 and addenda
- /Users/suman/playground/vajra/src/meter/mod.rs lines 60–660
- /Users/suman/playground/vajra/src/cli/launch.rs lines 225–355
- /Users/suman/playground/vajra/src/cli/meter.rs
- /Users/suman/playground/vajra/src/architect/mod.rs (how citations are parsed: `ADR-000N` / `DECISION-00N` must exist)
- /Users/suman/playground/vajra/Cargo.toml (there is no date/time crate; only serde_json)

---

**(a) Which record.** Records that exist: ADR-0001 to ADR-0005, and DECISION-001 to DECISION-011. None records S66, S77 or S78. Those three decisions live only in code comments in `src/meter/mod.rs` (lines 139–178 and 353–366) and in STATE. So the prompt's phrase "the S77/S78 decision" points at no record and cannot be cited.
- ADR-0004 is the record this change extends.
- ADR-0003 is not touched: no hook, no status line, no change to `--settings`. Cite it only to say it is unchanged.
- **Deviation, stated plainly:** ADR-0004 §2.8 makes the token-formula figure the headline (`$0.0859 total`), and §3.1 calls the transcript "authoritative". S66 and S77 already moved away from §2.8 with no record. S189 moves further, so the addendum must say it replaces §2.8's headline rule.

**(b) Source order** (one resolver, applied after the captured stream is fed in):
1. Transcript `type:"result"` `total_cost_usd` (existing; in practice it never fires on interactive runs).
2. The `-p` result stream captured from stdout (S78; AC4 unchanged).
3. This run's share of the transcript's `cost-state` total (new).
4. Nothing. The headline reads "no cost from Claude Code for this run", and the token figure moves to a labelled `[estimate]` line.

**(c) What is stored: nothing new.** The launch time already exists in memory as `session_start` (`launch.rs:82`). Pass it into `meter_session` as an optional value. There is no capture file, no extra file next to the transcript, no hook, no settings change, and no write to `~/.claude.json`. The transcript is only read, and only after Claude Code exits (ADR-0004 §2.1).

**(d) Behaviour in each case:**
- **Fresh run:** no baseline (0) and `startTime` is at or after launch, so the figure is the last total.
- **Resume / `--continue`:** the figure is the last total minus the last total written before this run's first timestamped line.
- **Crash or kill:** the last cost-state line comes before this run's first line, so there is no figure.
- **`/clear`:** it creates two transcripts newer than launch. `find_session_jsonl` already skips the meter with "multiple sessions detected", so this is unchanged and named as a limit.
- **Fork, or a resume Vajra didn't see:** no baseline, but `startTime` is before launch. The headline says no cost for this run, and a labelled line shows the whole conversation's total.
- **Claude Code older than 2.1.275, or a renamed field:** no figure.
- **`vajra meter <file>`:** there is no launch time. Show the last total, labelled as the whole conversation's total, never as "this run".

**(e)** The marker is `design-significant: yes`. The paragraph to paste is at the end.

---

rec 1 — Record S189's decision as an "S189 addendum" section appended to /Users/suman/playground/vajra/docs/adr/0004-meter-receipt-design.md. In the same addendum, back-fill the S66/S77/S78 rule (the tool's own figure wins; a guess is never the headline). Say plainly that it replaces §2.8's headline rule. Do not mint a new ADR or DECISION.
Why: ADR-0004 is the receipt's record, and the gate needs a citation that resolves to a real file. S66, S77 and S78 have none, so citing them would be citing nothing. A new record id named in `## Design` before its file exists would be blocked by the gate. An addendum also follows the house pattern (DECISION-007 and DECISION-011 grow by addenda). Rejected: a new docs/decisions record. It would split the receipt's rules across two files, and the meter has had one owner since DS4.

rec 2 — Keep the cost-state figure in its own field on `SessionCost`, not in `authoritative_dollars`. Pick the headline in one resolver that runs after `apply_captured_cost`, in the order result line → `-p` stream → cost-state → none. Give each source its own label. `billed_dollars()` should return the chosen figure, or else the estimate as today.
Why: `apply_captured_cost` (`src/meter/mod.rs:171`) only fills an empty `authoritative_dollars`. A headless run also exits normally and probably writes a cost-state line. If `parse_jsonl` filled that field, the stream would never win and AC4 would change silently. Even if the numbers happened to match, the behaviour would differ. Rejected: reusing `authoritative_dollars` with a "lower priority" comment. That puts the order in the call sequence rather than in one place.

rec 3 — Find this run's share with fail-closed rules:
- **The cut point** is the first line whose `timestamp` parses and is at or after the launch time. Lines with no timestamp (`last-prompt`) or an unparseable one are skipped.
- **No figure** if there is no cut point, or if the last cost-state line comes before it.
- **The baseline** is the last cost-state before the cut point, or 0 if there is none.
- **No figure** if `totalCostUSD` is not a finite number of zero or more, or if the share comes out negative.
- **Never add cost-state lines together**; take the last one.
Why: the researcher found duplicate lines at one exit and running totals across resumes. Failing closed means any doubt prints "no cost" rather than a wrong number. Rejected: recording each transcript's byte length before launch and using that as the baseline. It is exact, but it needs a scan of every transcript in the folder before Claude Code starts, plus a new value passed through `launch.rs`, and it gives the same answer as the timestamp cut. Also rejected: adding up all cost-state lines (double counts) and taking the last total as-is (charges a resume for the whole conversation).

rec 4 — Add a `startTime` check. When no baseline was found and the last cost-state's `startTime` (epoch milliseconds) is before Vajra's launch time, do not headline the number as this run's cost. Headline "no cost from Claude Code for this run" and add a labelled line: "Claude Code's total for this whole conversation: $X (includes spend before this run)".
Why: a fork, or a resume whose earlier cost-state line was never copied, would otherwise show the whole conversation as this run's cost. That is a real number with the wrong label, which is exactly what F67 is about. The check costs one comparison: on a fresh run Claude Code's `startTime` is set after Vajra's `SystemTime::now()`, so it is always later. This is the researcher's rec 3 without the hook.

rec 5 — `vajra meter <file>`: pass no launch time and make no subtraction. Headline the last cost-state as "Claude Code's total for this whole conversation (every run in this file)". If there is none, print the same "no cost from Claude Code" line plus `[estimate]`.
Why: with no launch time there is no honest way to pick a run. Calling the file "the run" would mislabel any resumed conversation. The conversation total is still the tool's own figure, labelled for what it covers, and it is what someone reading a transcript after the fact wants.

rec 6 — Read the timestamp by hand, accepting only the exact UTC shape `YYYY-MM-DDTHH:MM:SS[.fff]Z` that Claude Code writes. Add no date/time crate. Unit-test it against one real line and two malformed ones.
Why: Cargo.toml has no date/time crate, and one comparison does not justify a new dependency. A strict shape that fails closed (an unparseable stamp is skipped, so "no figure" is the worst case) cannot misattribute spend. This is a fixed machine format, not guessing from AI-written text.

rec 7 — Change the receipt wording and its tests together, and say why in the commit:
- **No figure:** the headline line has no dollar sign ("no cost from Claude Code for this run"). The next line reads `~$X  [estimate]  worked out from tokens — not the charge on your bill`. Any unknown-model tag stays only on the estimate line.
- **Warning text:** rewrite `NO_REPORTED_COST_WARNING`, which today says "the figure above is Vajra's own estimate", so it no longer refers to a headline figure. Keep it as the one constant that `apply_captured_cost` matches on.
- **`hasUnknownModelCost: true`:** the headline is still Claude Code's figure, followed by "Claude Code could not price every model in this run".
Why: AC2 and AC3. Two existing tests (`receipt_format_includes_all_fields` and `missing_authoritative_falls_back_to_labeled_estimate`) check for today's `~$X estimated` headline and must change. The fidelity-reviewer should read that as the spec changing, not as weakened tests. Do not claim "includes" or "higher" for the unknown-model case: whether Claude Code counts the unpriced model as $0 is unverified.

rec 8 — Pin a small fixture taken from a real 2.1.280 transcript (cost-state lines only, plus a few timestamped neighbours, with secrets removed) as a tripwire test in the style of ADR-0004 G11. Use it for AC1: one fresh case, one resume case, and one crash case where the last cost-state comes before the cut point. Show it is red at 8e52d29.
Why: Claude Code's sessions docs call the line format internal and say it changes between versions. If a field is renamed, the tripwire should fail CI while users see "no cost" instead of a wrong number. One fixture covers AC1, AC5 and the no-figure branch at no cost, matching the tech-lead's rec 3.

rec 9 — List the known limits in the addendum, and answer the deferrals as `deferred:` with a backlog path:
- Crash or kill gives no figure.
- `/clear` skips the meter: more than one candidate transcript means no receipt (unchanged).
- Concurrent sessions in one folder are unsolved.
- On a resume the `[estimate]` line still counts the whole file's tokens. This is existing behaviour, now shown next to a headline that covers only this run.
- `-p --resume`: the stream's `total_cost_usd` may also include earlier spend (the SDK docs say totals are restored on resume). AC4 keeps it as it is; this is unverified.
- `find_session_jsonl` only replaces `/` in the folder name, against G10's intent (researcher rec 6).
- The SessionStart-hook session-id match is deferred (researcher rec 2; it would need an ADR-0003 addendum).
- The paid `/clear` + `--continue` check is deferred (researcher rec 5; it needs the founder's yes).
- Claude Code older than 2.1.275 gives no figure.
- The per-model `costUSD` split is not shown on the receipt.
Why: the deviation and the limits must sit where a reader of ADR-0004 will see them (founder: "a label is not a fix"; name the gaps, don't call them closed). The gate checks only that the citation exists, not that the design obeys it, so the addendum is the only place the deviation gets written down.

**Alternatives rejected overall:**
- **The status line's `cost.total_cost_usd`.** Vajra would have to inject a `statusLine`, which replaces the user's own (ADR-0003, and S182's add-only rule).
- **`~/.claude.json` `lastCost`.** It is undocumented, holds one value per folder that the last session to exit overwrites, and is a shared global file other processes write to at the same time.
- **A SessionStart hook writing to a file next to the transcript, now.** It is correct but larger. It changes `--settings` and needs an ADR-0003 addendum. Deferred, not rejected forever.
- **New price rows for Opus 5.5.** The founder ruled these out (S176/S177).
- **Headlining the whole-conversation total on a resume.** It is overcounted by every earlier run.

---

**`## Design` paragraph to paste:**

```
## Design
design-significant: yes
- Changes the receipt's interface: `meter_session` takes the launch time, `SessionCost` gains Claude Code's own session record as a separate source, and the headline rule changes. Recorded as an S189 addendum to ADR-0004 (meter and receipt), which also writes down the S66/S77/S78 rule that until now lived only in code comments: the tool's own figure wins, and a guess is never the headline. This DEVIATES from ADR-0004 §2.8, whose headline was the token-formula total; the addendum replaces that rule. ADR-0003 is unchanged: no hook, no status line, no change to `--settings`.
- Source: Claude Code (2.1.275 and later) appends a `cost-state` line with the running `totalCostUSD` to the main transcript at each normal exit. The headline is picked by one resolver, in this order: the transcript's `type:"result"` `total_cost_usd`, then the captured `-p` result stream (S78, unchanged), then this run's share of the cost-state total, then none. The cost-state figure is kept in its own field, so it can never block the `-p` stream.
- This run's share is the last cost-state total minus the last total written before the first line timestamped at or after launch (0 if there is none). There is no figure if the last cost-state line comes before that line (crash or kill), if no line from this run has a readable timestamp, if the share is negative, or if the total is not a finite number. Totals are never added up. If there is no baseline and the record's `startTime` is before launch (a fork, or a resume Vajra did not see), the headline says no cost for this run and a labelled line shows the whole conversation's total. `vajra meter FILE` shows that labelled conversation total and subtracts nothing.
- Nothing new is stored: the launch time already in memory is the only input, and the transcript is only read, after exit.
- No figure: the headline reads "no cost from Claude Code for this run" and the token number is a labelled `[estimate]` line beneath it. An unknown model only ever tags the estimate line. If `hasUnknownModelCost` is true, the headline is still Claude Code's figure and says Claude Code could not price every model. No price rows are added.
- Rejected: the status line (it would replace the user's own statusLine setting; ADR-0003 and the add-only rule); `~/.claude.json` lastCost (undocumented, one value per folder, a shared global file); a SessionStart hook writing to a file beside the transcript, now (correct but larger, needs an ADR-0003 change; deferred); recording transcript byte lengths before launch (same answer, needs a scan before Claude Code starts); adding up cost-state lines (one exit can write the line twice); headlining the conversation total on a resume (overcounts); new price rows (founder, S176/S177).
- Named limits: crash or kill gives no figure; `/clear` still skips the meter; concurrent sessions in one folder; on a resume the estimate still counts the whole file's tokens; the `-p --resume` stream total may include earlier spend (unverified, unchanged by AC4); the transcript folder name only replaces `/` (deferred); Claude Code older than 2.1.275 gives no figure; Claude Code calls the line format internal, so a pinned 2.1.280 fixture is the tripwire.
```

Files relevant to the build:
- /Users/suman/playground/vajra/docs/adr/0004-meter-receipt-design.md (the addendum goes here)
- /Users/suman/playground/vajra/src/meter/mod.rs (lines 135–178 `SessionCost` / `apply_captured_cost`, 222 `meter_session`, 325 `parse_jsonl`, 465 `format_receipt`, 71 `NO_REPORTED_COST_WARNING`)
- /Users/suman/playground/vajra/src/cli/launch.rs (lines 309–347 `print_receipt`; `session_start` at line 82)
- /Users/suman/playground/vajra/src/cli/meter.rs (line 29: the `vajra meter <file>` path, no launch time)

## Handoff Delta
- `+` new: first design-advisor handoff for this session (16862 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
