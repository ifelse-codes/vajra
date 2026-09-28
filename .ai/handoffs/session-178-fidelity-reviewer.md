---
role: fidelity-reviewer
session: 178
agent: claude-code-subagent (verified: toolu_01VzfRSu8WSK6heoZxHYB52q)
source-sha: 368b00806ef33d5b7afee263410525405b5f0dc06129de23ad7bf726689a7d70
captured: 2026-09-27T13:30:41Z
cost_usd: null
---

# Fidelity-reviewer handoff — session 178

**Cold fidelity review, pass 2: Session 178 (`dc57eb0..HEAD`)**

The delivery matches the contract: 11 of 12 SHIPPED, 1 PARTIAL, 0 NOT-BUILT. All 7 of pass 1's recommendations are really addressed in the code. Two things remain open: the F88 row has no severity, and two sibling sentences of the kind F87 fixed are still in `src/cli/next.rs`.

Method: I read only the brief and the files the diff touches, plus the close-script functions and rudra's real S13 handoff `agent:` fields to check whether the new wording is true. I had no shell, so nothing was run; every verdict comes from reading the code.

## Per-requirement grades

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| D1 | Findings table F77–F82 + the correction | SHIPPED | `prompts/178-task-keep-testing.md:50-76`. Every row has a severity and a source; the correction is at :74-76. |
| D2 | S180 prompt gains the four items, first in its Goal | SHIPPED | `prompts/180-task-ground-truth.md:19-37`: F77–F80, the `session_type` enum, experts vs checklist, the omp result. |
| D3 | rudra S12 watched; F83+ recorded; Vajra's own fixed | SHIPPED | Rows at :61-66. F83 is fixed (D4); F84/F85 go to S180 (180:43-44). |
| D4 | Tech-lead template says plain lines outside code blocks; synced to rudra | SHIPPED | `src/fleet/mod.rs:437-439`; `.claude/agents/tech-lead.md:18`; `/Users/suman/playground/rudra/.claude/agents/tech-lead.md:19` (uncommitted there, disclosed). |
| D5 | The three provenance blocks add the non-Claude line | SHIPPED | One shared constant `NON_CLAUDE_NOTE` (`src/dispatch/mod.rs:88-93`), pushed at `src/mandate/mod.rs:347,371`, `src/fidelity/mod.rs:98,123`, and crew site 2 at `src/crew/mod.rs:409-411` (site 1 gets it through the shared ladder, :306-308). It knowingly departs from the brief's "only a founder waiver" wording, because pass 1 showed that wording was false. |
| D6 | `src/crew/mod.rs` drops "No environment variable can satisfy or bypass" | SHIPPED | `src/crew/mod.rs:301-304` now reads "No `VAJRA_SKIP_*` flag turns this check off…" |
| AC1 | Every named finding has a severity and a source | SHIPPED | F77–F82, F67, F71, F74/F76 ✓ and F60 ✓ all cite a commit, log, file or "(not in git)" source (:53-72). |
| AC2 | S180 Goal item 1 names the problem plus the four items | SHIPPED | 180:19 "FIRST ITEM". It is numbered `0.`, but it is first and contains all four items. |
| AC3 | S12 findings (F83+) in the table with a severity | PARTIAL | F83–F87 have severities. **F88 (:69) says only "recorded"**, which is a status, not a severity. |
| AC4 | Template in Vajra and in rudra after the sync | SHIPPED | `scripts/verify-session-178.sh:143-156` checks Vajra's copy, a fresh `vajra init`, and rudra's copy, plus a control that fails if the OLD render already said it. I confirmed rudra's file myself. |
| AC5 | rudra S13 prints the new line; old and new give the same verdict and exit code on a listed set | SHIPPED | `cmp_gate` (verify:30-52) compares exit code and verdict line, and allows only removed lines with the false sentence and added lines with the new wording. It runs on rudra S13/S11 (note expected), S12 and Vajra S176/S177 (note must be absent): 15 comparisons. rudra S13's `agent:` fields read `claude-code-subagent (unverifiable: …)` → `claimed_tool_use_id` returns None → ProvenanceMissingId → the note is printed. |
| AC6 | The sentence is gone from `--check-crew`, and its replacement is true at close | SHIPPED | Gone (verify:101-106). "No `VAJRA_SKIP_*`" is true: no skip flag is read in the crew or mandate paths or in the close-script functions (the only env reads on the path are `VAJRA_CLAUDE_PROJECTS_DIR` and `HOME` in `src/dispatch/mod.rs:169-172`). "Waiver can waive" is true: `verify-closeout-scaffold.sh:751-752`. "No waiver replaces the file" is true: `check_claimed_evidence` :344-358 prints NOT WAIVABLE. |

**11 of 12 SHIPPED** (1 PARTIAL, 0 NOT-BUILT).

## Pass-1 recommendations, graded independently

1. **Fixed where asked, not in the sibling sentences.** The new sentence is true for crew and mandate. But `src/cli/next.rs:1650` and `:1678` still say "There is no environment variable for this one" in the `--advance` mandate and crew blocks. This session's own site-2 fixture (verify:88-89) uses `VAJRA_CLAUDE_PROJECTS_DIR` to make a copied tech-lead handoff pass the check in a different repo. By pass 1's standard, that makes those two sentences false too. `verify-session-135.sh:247` still asserts one of them.
2. **Fixed.** "Two ways through" with no "only"; both ways are real at close. It is not a complete list, though: at `--advance`, `VAJRA_SKIP_FIDELITY_GATE` also gets past the fidelity check (`next.rs:1605`); for design-advisor, deleting the handoff and recording a reasoned skip passes; the note writes `<NN>`, but `waiver_ok` compares the value to the unpadded `$N`, so `09` would not match session 9.
3. **Fixed.** The note is added at `src/crew/mod.rs:388-411`. The fixture at verify:73-98 has an OLD-has-no-note / NEW-has-note control and counts as SKIP without Claude Code history.
4. **Fixed for (b) and (c), hollow for (a).** (b) and (c) really run the close script's own functions under `VAJRA_CLOSEOUT_WAIVER=42` (verify:117-132). (a) sets three flag names that nothing reads.
5. **Fixed.** The demo says 15 (demo:83, 114), and `CMPS` = 3+3+3+6 = 15. The demo's number is typed in, not derived; it is labelled "recorded at close".
6. **Fixed.** `want=no` asserts the note is absent (verify:47-48), and rudra-dependent steps count SKIP. The Vajra S176/S177 comparisons have no SKIP guard, so a machine without this Claude Code history would fail them for the wrong reason.
7. **Fixed.** Every row now cites a source.

**Unit-test rebinding: acceptable.** The mandate and fidelity tests (`src/mandate/mod.rs:741-761`, `src/fidelity/mod.rs:203-216`) check the cause, that there are exactly 2 reasons, and that the last one equals the shared constant. That is stronger than a substring match. The S133 rename control can't break them. The note's actual words are still checked, live, by verify's `NOTE` grep. The crew test (`src/crew/mod.rs:701-709`) still matches message text, but crew is not under the S133 rename control.

## The fakest green

**AC6 (a), verify:113-116:** "VAJRA_SKIP_CREW/TECH_LEAD/MANDATE_GATE=1 set: the crew check still blocks." Nothing in `src/` reads any of those three names, so the check passes whether or not a real bypass exists under any other name. The claim is in fact true, but that rests on reading the source and on `verify-session-135.sh:206-213`, which probes the real flag names. This line adds nothing.

Runner-up: the close-script's own FAIL lines are unchanged (`verify-closeout-scaffold.sh:685-686`, `:754-755`, and the fidelity-handoff FIX text at :1105). They still tell a non-Claude run only to re-dispatch. The binary's new note does appear in the same log above them, so this is a residual, not a miss against D5's wording.

## Recommendations

rec 1 — Make `src/cli/next.rs:1650` and `:1678` ("There is no environment variable for this one") match the new "no `VAJRA_SKIP_*` flag" wording and update `verify-session-135.sh:247`, or record why `--advance` is exempt.

rec 2 — Give F88's row a real severity (LOW/MED/HIGH); "recorded" is not one (AC3).

rec 3 — Make AC6 (a) either loop over every `VAJRA_SKIP_*` name actually read in `src/` (derived by grep, not typed) or delete it and cite `verify-session-135.sh` check 5.

rec 4 — Point the close-script FAIL lines for required-crew, design-advisor-mandate and fidelity-handoff at the binary's non-Claude note above them, or record this as an S180 residual.

rec 5 — Count the Vajra S176/S177 `cmp_gate` rows as SKIP when there is no Claude Code history under `~/.claude/projects` for this repo, so verify fails for the right reason on another machine.

rec 6 — Record written dispositions for pass 1's 7 recommendations (commits d2527e3, c247b07, c0b22ad, 4aedf0f) in the prompt's `## Advice`, next to this pass's.

rec 7 — (LOW) Change `NON_CLAUDE_NOTE` from "Two ways through" to "Ways through include" (or name the `--advance` skip flag and the reasoned-skip path), and write the waiver as `=<N>` not `=<NN>`.

## Verdict

This is a faithful build of the whole, deliberately small, wording-only contract, not one slice presented as the whole. The new sentences are true where they were placed, verdicts and exit codes are held constant by a well-constrained old-vs-new comparison, and all 7 pass-1 recommendations are really in the code. What remains is one missing severity word, one hollow probe, and two sibling sentences outside the literal acceptance scope (rec 1).

**Verdict:** ACCEPT

## Handoff Delta
- `+` new: first fidelity-reviewer handoff for this session (8703 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
