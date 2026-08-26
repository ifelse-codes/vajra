# Session 133 — independent fidelity review

**Reviewer:** cold `fidelity-reviewer` dispatch, fed only the session prompt, the branch diff, and
the recorded live run artifacts. Not the builder. Governed handoff:
`.ai/handoffs/session-133-fidelity-reviewer.md`, provenance
`claude-code-subagent (verified: toolu_01Snmu6n4gJuTU13Ewb74oSh)`.

**Method limit, stated by the reviewer itself:** the role has `Read`/`Grep`/`Glob` only — no shell.
It did not execute anything, and it could not open commit objects; every sha-bound claim it makes
is graded on content, not on the commit it names. Its evidence for live behaviour is the recorded
output of the real binary under `.ai/verify/session-133/` and the captured demo run.

**Verdict:** ACCEPT

14 of 18 SHIPPED · 2 PARTIAL · 2 NOT-BUILT, at the time of the review. The two NOT-BUILT (the
summary and its "what is not fixed" section) and one PARTIAL (the closing review/judging paperwork)
were the closing artifacts this session's own gates refuse to let it skip — they landed after the
review, which is why the review could not see them.

| # | Requirement | Verdict |
|---|---|---|
| D1 | The gate: required, existence-gated, provenance-verified; command choice decided and recorded | SHIPPED |
| D2 | The reasoned skip: in-repo, substantiveness-gated, visible, house pattern only | SHIPPED |
| D3 | Migration posture recorded; threshold governs SILENCE only | SHIPPED |
| D4 | Falsifiability fixture, five directions, right reason, positive controls | SHIPPED |
| D5 | Dogfooded — a real `design-advisor` dispatch on this session's own design question | SHIPPED |
| D6 | Both scripts exit 0 with a printed check-class tally | SHIPPED |
| D7 | `sessions/session-133-summary.md` + exactly 3 ranked next candidates | NOT-BUILT at review time — landed after |
| A1 | Silence BLOCKS, naming what is missing and both ways out | SHIPPED |
| A2 | A substantive reason PASSES and the gate PRINTS it | SHIPPED |
| A3 | Empty or placeholder reason BLOCKS | SHIPPED |
| A4 | Provenance that does not re-verify BLOCKS | SHIPPED |
| A5 | Reason lives in the repo; no env var silently satisfies or bypasses | PARTIAL — the SATISFY half; see below |
| A6 | Fixture drives all five directions, each probe asserting its own pattern | SHIPPED |
| A7 | Traced: `K of 8`, 7 commands, S131 and S132 gates unchanged | SHIPPED |
| A8 | Both scripts exit 0 with a printed tally | SHIPPED |
| A9 | S133's own design question went to a real dispatch | SHIPPED |
| A10 | Cold `fidelity-reviewer` ACCEPT, attested; separate judging dispatch | PARTIAL at review time — landed after |
| A11 | The summary states plainly what is NOT fixed | NOT-BUILT at review time — landed after |

## The fakest green, in the reviewer's words

**"NO environment variable satisfies or bypasses this gate."** Eleven of the twelve enumerated
names are variables no code path in `src/mandate/mod.rs` ever reads, so the probe asserts the
absence of code nobody wrote. Meanwhile the one environment variable that DOES move this gate's
verdict — `VAJRA_CLAUDE_PROJECTS_DIR`, which redirects the provenance source — was missing from the
list, and is used by the suite's own positive control and by demo case 5, three lines above the
"no env var" case, to produce `verdict: READY` from files the test itself wrote.

Runners-up it named: a `grep … || true` assertion that could not fail, inside the suite whose whole
job is to police exactly that; and a `K of 8` check that passed at any K from 1 to 8.

It also recorded, explicitly, what is NOT a fake green: the reasoned skip is self-granted, and that
is disclosed in `MANDATE_FLOOR`, in `DECISION-007` and in both scripts' closing notes. A disclosed
floor is not a fake green.

## What was done about it, in-session

| rec | Disposition |
|---|---|
| 1 — land the summary with 3 ranked candidates | obeyed |
| 2 — name `VAJRA_CLAUDE_PROJECTS_DIR`, narrow the absolute claims | obeyed — the check now asserts what it cannot do and discloses what it can; `DECISION-007` §3 and the demo were narrowed |
| 3 — the dead `|| true` assertion | obeyed — made real |
| 4 — pin `K` to the recorded baseline | obeyed |
| 5 — bypass probes for the two unprobed rungs | obeyed — 5 bypasses became 7 |
| 6 — a 4-space-indented example read as a real record | obeyed — markdown's own indented-code rule, plus the nested-list direction tested |
| 7 — probe the `maturity: L1` escape live | deferred — `.ai/ROADMAP.md` F2g |
| 8 — S134 as a call site; close or record F2e | deferred — `.ai/ROADMAP.md` F2e, and named in the summary's option A |
| 9 — the counting rule as a runnable command | obeyed — in the summary, as two shell lines |
| 10 — the lib-tests artifact must carry cargo's own result line | obeyed |

Running rec 5 surfaced a further defect in the suite's own probe machinery: `grep -F` with a
multi-line pattern is an alternation of its lines, not one literal, so the new two-line bypass
reported a false "did not land". Fixed with a perl substring check — the probe that polices false
comfort was itself giving a false red.

## Hard rules

7 top-level commands held (live). No second store — the reason lives in `prompts/`, inside what
`Review-Inputs-SHA` already hashes. No new artifact type. One story. The reviewer recorded that it
**could not** verify the 3-files-per-commit cap, the no-main-commits rule, or the un-forgeable
commit marker, because those live in commit objects its read-only toolset cannot open. Stated as
unverified rather than clean.

## The independent judgment on the `obeyed:` claims

The 22 `obeyed:` dispositions this session records were graded by a THIRD dispatch —
`implementation-advisor`, which is neither of the roles being graded, so it is admissible under
S132's no-self-grading rule. Handoff: `.ai/handoffs/session-133-implementation-advisor.md`,
provenance `verified: toolu_01G9SF9B1Uw7dJ1wQCDcCgzc`. `vajra next --check-obeyed 133` → READY.

**All 22 graded `implemented:`, and the judge stated in writing where it came closest to a
mismatch:** `fidelity-reviewer rec 5 — 3bc6759`. That rec asked not merely for two bypass probes to
be written but for each to be PROVEN red. At the recorded sha both probes exist, but the second
one's two-line target tripped a bug in the suite's own `apply_bypass` presence check, so it would
have reported "the substitution did not land" and proved nothing. The proof arrived one commit
later at `6a67ef0`. The judge called it `implemented:` because the substance the rec named is in
the recorded commit and `6a67ef0` fixed a SHARED helper — and said the split out loud rather than
smoothing it. `6a67ef0` is now named in the prompt's `## Advice` so it is not invisible.

**The judge's own method limit, in its words:** it had no shell in that dispatch, so it could not
run `git show`. It resolved all 22 shas against `.git/logs/HEAD`, read the content at the tip, and
inferred attribution from commit messages and ordering. It states that its evidence is "consistent"
rather than "verified", and that a session wanting the stronger claim should re-run the 22 against
real diffs with a Bash-enabled judge. That limit is the S132 ceiling one notch lower than usual and
is recorded here rather than in a footnote.

**Review-Inputs-SHA:** dd25ad4cbbcb42a1fa39a5fe2ac8d6fa9c0decdaf4d182114af021a0ddd70df4
