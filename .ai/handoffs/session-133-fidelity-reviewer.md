---
role: fidelity-reviewer
session: 133
agent: claude-code-subagent (verified: toolu_01Snmu6n4gJuTU13Ewb74oSh)
source-sha: 22d214de7d4ca28f6858fff0cceb32ddee6b2f9950c4b7d53f30f213e776547a
captured: 2026-08-26T06:11:04Z
cost_usd: null
---

# Fidelity-reviewer handoff — session 133

## Findings

# Fidelity review — Session 133 (`design-advisor` becomes mandatory)

**Method.** Cold read of `prompts/133-task-design-advisor-mandatory.md` against the branch's source
and scripts, plus the recorded live artifacts (`.ai/verify/session-133/20260825T183824Z/*.log`, the
9-case demo capture). No Bash: I did not execute anything, and I could not open commit objects —
every sha-bound claim below is graded on content, not on the commit it names.

## Per-requirement verdicts

| # | Requirement (D = Deliverable, A = Acceptance) | Verdict | Evidence |
|---|---|---|---|
| D1 | The gate: handoff required, existence-gated, provenance-verified through the S131 chain; ride-vs-own-command decided and recorded | SHIPPED | `mandate::mandate_gate` rungs 1-2 (`src/mandate/mod.rs:305-359`) via `fleet::read_handoff` -> `dispatch::claimed_tool_use_id` -> `dispatch::reverify`; decision + rejected alternative in `## Design` and `DECISION-007` section 4; the loser's cost recovered by the cross-reference line at `src/cli/next.rs:496-499`. Timing limit stated out loud: binds at CLOSE, not at first code commit. |
| D2 | The reasoned skip: in-repo, substantiveness-gated, visible, house pattern only | SHIPPED | Marker parsed from the session's own prompt (`parse_skip_marker`); reason gated by `advice::substantive_reason` verbatim; printed by `skip_line()` in the gate, in `--advance` and copied into the closeout log; `MANDATE_FLOOR` states the floor. No new file type, no new store. |
| D3 | Migration posture recorded; threshold governs SILENCE only | SHIPPED | `DESIGN_ADVISOR_MANDATE_FROM_SESSION = 133` read on exactly one rung; verify check 8 drives all three directions live. Fresh-project hole closed by the scaffold placeholder — proven against the REAL scaffold. |
| D4 | Falsifiability fixture, five directions, right-reason, positive controls | SHIPPED | Checks 1-5 drive (a)-(e) live; bypasses A-E each assert the target existed and vanished and that the red is a test failure not a compile error; log records all five RED and the rename control GREEN. |
| D5 | Dogfooded — a real `design-advisor` dispatch on this session's own design question | SHIPPED | `.ai/handoffs/session-133-design-advisor.md`, `agent: claude-code-subagent (verified: toolu_01FgiKkQM1U1AD6eRXth3fFv)`; live gate READY on the real repo; the brief's 15 recs visibly shaped the build. |
| D6 | Both scripts exit 0 with a printed check-class tally | SHIPPED | Demo capture: 9 exec cases, tally line, `DEMO GREEN (9 pass, 0 fail)`. Verify: 15 per-check logs all green. Honest gap: I read per-check logs, not the aggregate stdout. |
| D7 | `sessions/session-133-summary.md` + exactly 3 ranked next candidates | NOT-BUILT | No such file exists. Three shipped artifacts already cite it by path. |
| A1 | Silence BLOCKS, naming what is missing and both ways out | SHIPPED | Live logs and demo case 1. Caveat: fires at close, not when code work starts. |
| A2 | A substantive reason PASSES and the gate PRINTS it | SHIPPED | Demo line 20 with `verdict: READY`; `--advance` prints the same line; the closeout log copies the author's own words. |
| A3 | Empty / placeholder reason BLOCKS | SHIPPED | Four discriminants; demo case 3 blocks all three shapes live; blocks below the threshold too. |
| A4 | A handoff whose provenance does not re-verify BLOCKS | SHIPPED | Three distinct causes; demo case 4 exit 1 with "does not cure it", and the check asserts the output does NOT render as a skip. |
| A5 | Reason lives in the repo; no environment variable can silently satisfy or bypass | PARTIAL | Bypass half proven. Satisfy half NOT proven and contradicted by the session's own artifacts: `dispatch::reverify -> project_dir_for -> claude_projects_root` honours `VAJRA_CLAUDE_PROJECTS_DIR`, and demo case 5 + verify check 5 use exactly that variable to manufacture a `verdict: READY` from synthetic evidence. |
| A6 | Fixture drives all five directions, each probe asserting its own pattern | SHIPPED | Every probe greps a specific string and fails loudly on absence; positive controls present. |
| A7 | Traced, not asserted: K of 8, 7 commands, S131 and S132 gates unchanged | SHIPPED | Live `8 of 8 stations passed`; `--check-obeyed 127` still exit 1 MISMATCH; `--check-fidelity-handoff 133` still blocks in its own words; no `S133` reference in `src/fidelity` or `src/obeyed`. Weak spot: the K assertion accepts any K in 1..8. |
| A8 | Both scripts exit 0 with a printed check-class tally | SHIPPED | Same evidence as D6. |
| A9 | This session's own design question went to a real dispatch, handoff landed | SHIPPED | Same as D5; verify check 12 additionally asserts the pass is NOT a skip. |
| A10 | Independent cold `fidelity-reviewer` ACCEPT, attested; `implementation-advisor` dispatched as the obeyed-judge | PARTIAL | This cold pass is real and cold, but `sessions/session-133-review.md` and its `Review-Inputs-SHA` do not exist yet. Zero evidence for the judging half; `## Execution` steps 9 and 10 still read `<sha>`. |
| A11 | The summary states plainly what is NOT fixed, incl. the default-dodge risk | NOT-BUILT | No summary. The content exists elsewhere but the criterion names the summary. |

**14 of 18 SHIPPED** (2 PARTIAL, 2 NOT-BUILT)

**Verdict:** ACCEPT

Real scope: a faithful build of the whole contract's mechanism, dogfooded on itself, with the
closing paperwork (summary, review artifact, judging dispatch) still outstanding — and the
session's own gates will refuse the close until they land.

## The fakest green

**"NO environment variable satisfies or bypasses this gate"** — verify check 6 and demo case 6.
Eleven of the twelve enumerated names are variables that no code path in `src/mandate/mod.rs` has
ever read (the module contains zero `env::var` calls), so the probe asserts the absence of code
nobody wrote; it cannot go red unless a future author deliberately adds a named escape. Meanwhile
the one environment variable that DOES move this gate's verdict — `VAJRA_CLAUDE_PROJECTS_DIR`,
which redirects the provenance source — is missing from the list, and is used by the suite's own
positive control and by demo case 5, three lines above the "no env var" case, to produce
`verdict: READY` from files the test itself wrote. The green reads "the escape hatch is closed";
what it proves is "we did not add a variable with one of these twelve names."

Runners-up: `scripts/verify-session-133.sh:312` is an assertion that cannot fail
(`grep ... || true`, a leftover with no effect) inside the suite whose whole purpose is to police
exactly that; and check 11b's "K of 8 unchanged" passes at any K from 1 to 8.

Not fake, for the record: the reasoned skip IS self-granted — a session types one line into a file
it owns and passes. That is disclosed in `MANDATE_FLOOR`, in `DECISION-007`, and in both scripts'
"what this never showed" blocks. A disclosed floor is not a fake green.

## Adversarial probes and what they found

- **Marker grammar composition**: I found no way to slip a SILENT pass through. Blockquotes, HTML
  comments and backticked examples all fail closed. One undisclosed hole: `skip_fenced` only knows
  triple-backtick and tilde fences, so a 4-space-indented markdown code block containing the
  marker counts as a real record.
- **Ladder vs. implementation**: the six rungs in the module header agree with `mandate_gate` rung
  for rung, including the decided rung-1-over-rung-3 precedence.
- **Rebinding to `SkipDefect`/`MandateCause`**: this did NOT remove the tests' teeth. The variants
  are load-bearing (bypasses A-E each go red), and the wording contract moved to live binary output
  in checks 1-4 rather than disappearing.
- **Unprobed rungs**: rung 6 (WARN below threshold) and rung 1's `HandoffMalformed` arm have unit
  tests but no bypass probe.
- **All three paths for A5**: `--check-design-handoff` — no env read; `--advance` — no env read
  (uniquely among the gates), but `maturity: L1` still downgrades it to advice, and that file is
  agent-writable and tracked; `verify-closeout.sh` — `VAJRA_CLOSEOUT_WAIVER` applies. Both limits
  are disclosed; neither is probed.
- **Template blast radius**: the one new `PROMPT_TEMPLATE` line sits in `## Design` and is fully
  `<...>`, so `analyst::parse_delta(PROMPT_TEMPLATE) == Placeholder` still holds,
  `architect::design_significance` keys on `design-significant:` (no prefix collision), and
  `--check-design-handoff` is matched by exact equality AFTER `--check-design`, so no flag
  shadowing. Live `K of 8` and the 7-command banner both unmoved.
- **Overstatement sweep**: `## Design`, the `DECISION-007` addendum and the module header are
  unusually honest. The one thing that outruns the code is the absolute phrasing of the env-var
  claim, which is true of the SKIP and untrue of the SATISFY path.
- **`## Advice` spot-checks** (content only; I record no `obeyed-check` lines): rec 1's content is
  present; rec 15's content is present in both `verify-closeout.sh` branches; rec 14's deferral
  target is real. rec 10 asks for the constants to be reused by "gate, surface AND summary" — two
  of three consumers exist; the third is the missing summary.

## Hard-rule check

7 top-level commands held (live). No second store. No new artifact type. One story. I could NOT
verify the 3-files-per-commit cap, the no-main-commits rule, or the un-forgeable commit marker:
those live in commit objects and my toolset here is read-only file access.

## Recommendations

rec 1 — Land `sessions/session-133-summary.md` with exactly 3 ranked next candidates and a plain "what is NOT fixed" section before close; three shipped artifacts already cite that path and currently dangle.

rec 2 — Add `VAJRA_CLAUDE_PROJECTS_DIR` to verify check 6's enumeration as a named, disclosed exception (assert what it can and cannot do), and narrow the absolute claims in `DECISION-007` section 3 and the demo's before/after row to "no environment variable bypasses the block; the provenance evidence is machine-local and env-redirectable — S131's limit, inherited."

rec 3 — Delete or complete the dead assertion at `scripts/verify-session-133.sh:312` (`grep ... || true`). An assertion that cannot fail is the exact anti-pattern this suite exists to police.

rec 4 — Pin the K in check 11b to the value the log records (`8 of 8` at session 132) or to a recorded baseline, so "unchanged" covers the number and not just the denominator.

rec 5 — Add bypass probes for the two unprobed rungs: rung 6 (force `session >= from_session` true and prove `silence_below_the_threshold_warns_and_names_the_exemption` goes red) and rung 1's `HandoffRead::Malformed` arm (treat it as `Absent` and prove `a_malformed_handoff_fails_closed_not_silently_absent` goes red).

rec 6 — Treat a 4-space-indented block like a fence in `parse_skip_marker`, or add it beside the existing disclosure in the doc comment — today an indented markdown example is read as a real record.

rec 7 — Probe the `maturity: L1` escape once, live, in S134's suite: it is the only remaining agent-writable path that turns this gate advisory at `--advance`, and it is currently prose-only.

rec 8 — In S134, prove `implementation-advisor` lands as a call site on `mandate` (a second `*_gate` wrapper, no third ladder), and either close F2e by folding `fidelity_gate` into `mandate` in that session or record why not.

rec 9 — Write the default-dodge counting rule as a runnable command in the summary (`grep -rl "design-advisor: skipped" prompts/` vs `ls .ai/handoffs/*-design-advisor.md`, 5-session window), not as a sentence — an observable nobody can run is not an observable.

rec 10 — Make the `lib-tests-green` artifact carry cargo's own `test result: ok. N passed` line; today the log stops mid-progress and the only evidence for 427 green tests is an exit code the artifact does not show.

## Handoff Delta
- `~` re-run: fidelity-reviewer handoff replaced (11892 bytes now vs 11598 bytes prior)
- prior stage: this session's earlier fidelity-reviewer handoff
