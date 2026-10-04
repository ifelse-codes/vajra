---
role: design-advisor
session: 184
agent: claude-code-subagent (verified: toolu_01TqdDjmhc94cstNuxXQ2Fj2; text-sha: ac1d5d85f829fbc6185f8f9b691b037156edc3394062d4b14513a1c103f35215)
source-sha: 6b7ffc3419c8408528cd88c19c40ea4088863e8fb120a214933458f8ee9c37d4
captured: 2026-10-04T02:59:29Z
cost_usd: null
---

# Design-advisor handoff — session 184

Design-advisor brief: session 184 (F103 / F107 / F108)

I had no shell, so I could not run `git diff e1c348e..HEAD`. Instead I read the landed code directly: `Answers` / `PIPED_ANSWER_WAIT` in init.rs (lines 1225–1310), `obeyed_gate` in obeyed/mod.rs (lines 441–538), and line 48 of both close scripts. The S184 comments in that code match what you described.

**Proposed marker line:**

design-significant: yes

**Why yes:** F103 changes how a user-facing command behaves. Piped `vajra init` now has a time limit and a new rule for falling back to defaults, and the prompt itself calls that "a behaviour choice to record". F107 changes only wording and F108 is a pure fix; on their own both would be `no`.

**Proposed `## Design` body (about 190 words):**

Cites `docs/decisions/DECISION-007-agent-fleet.md`, S134 addendum ("the migration threshold is measured in the wrong units").

F103 is the design call. A terminal is read exactly as before. Any other stdin is read by one shared reader thread. Each answer waits at most 10 s. The first silence or end of input gives that question and every later one its default, each named on stderr, and a late line is dropped. Why: every in-repo script pipes its answers instantly, so 10 s is generous. Stopping at the first silence caps the hang at 10 s in total, not 10 s per question. Dropping the late line stops it landing on the wrong question.

Rejected:
- "not a terminal → defaults": breaks demo-session-08/09/143 and verify-session-46/143.
- a thread per question: a stuck read cannot be cancelled and steals the next answer.
- poll/select on stdin: Unix-only.
- a `--defaults` flag: a new option that still hangs for anyone who forgets it.

Known cost: someone typing into a non-terminal stdin who pauses 10 s gets defaults.

F107 changes wording only and DEVIATES from the cited record. The 132 threshold still counts the project's own sessions, so at its session 132 a project starts blocking unchecked `obeyed:` claims. That goes against the founder's 2026-10-03 call. Named, not closed; parked to the S185 ground truth. F108 is a pure fix.

**Recommendations:**

rec 1 — Record `design-significant: yes` on the strength of F103 alone (a changed contract for piped `vajra init`: a 10 s limit per answer, defaults from the first silence on, late lines dropped); F107 and F108 are fixes and do not change the marker.

The gate reads the marker and does not guess. Writing `no` because two of the three items are fixes would hide the one real behaviour choice, which the prompt's own Design placeholder already says must be recorded.

rec 2 — In the `## Design`, state plainly that F107 deviates from DECISION-007: the session-132 threshold still counts the PROJECT's sessions, so any project reaching its own session 132 starts BLOCKING unchecked `obeyed:` claims, against the founder's 2026-10-03 "not a blocking gate for projects" call. Name it, do not call it fixed, and park it to S185 with F110.

Evidence: `obeyed/mod.rs:499` tests `session >= OBEYED_JUDGMENT_FROM_SESSION` (132) with no check for which repo it is running in. The S134 addendum of DECISION-007 (lines 978–984) names exactly this mistake for the design-advisor threshold.

F107 also removed the one place the cut-off was "stated out loud" (the S68/S71 disclosure pattern; see the comment at obeyed/mod.rs:517). After the change, the warning text says "does not block on them", and a project at session 131 has no way to see that this will stop being true at 132. Because the gate checks only the form of a citation, citing DECISION-007 would pass even if the deviation were left unsaid. The honesty has to be in the words.

The fix options already listed in the S134 addendum (an adoption marker in the project, the prompt's git birth date, or dropping the threshold) are the S185 menu. I am not proposing a fix here.

rec 3 — Write no new DECISION record this session. The `## Design` section is the record for F103, because it is one constant plus one rule and easy to undo. If S185 picks a fix for the threshold's units, record it as a DECISION-007 addendum, not a new record.

This follows the house pattern (the S134 and S135 addenda): new information about a locked clause goes in as an addendum. F103 touches no locked record. I checked DECISION-011: it uses "stdin is not a terminal" only for `vajra approve`, which is a separate code path that F103 does not touch.

rec 4 — Keep the 10 s figure, the first-silence rule and the dropped late line as they are, and write the known cost into the Design: a person answering through a non-terminal stdin (some IDE run panels) who pauses 10 s gets defaults. The default and the reason are printed to stderr, so the user can see it happened. Revisit only if a real user hits it.

The first-silence rule and the dropped line together are what make the time limit safe. Without the first-silence rule, a pipe that never speaks costs 10 s per question. Without dropping the late line, an answer that arrives after its time ran out would be taken as the answer to the NEXT question. Those two reasons justify the choice, so they belong in the rationale.

**Files referenced:**
- /Users/suman/playground/vajra/prompts/184-task-rudra-s17-new-rules.md
- /Users/suman/playground/vajra/docs/decisions/DECISION-007-agent-fleet.md (S134 addendum lines 947–1005; S135 addendum lines 1041–1049)
- /Users/suman/playground/vajra/docs/decisions/DECISION-011-controls-the-agent-cannot-type.md (checked only; not cited)
- /Users/suman/playground/vajra/src/cli/init.rs (lines 1225–1310)
- /Users/suman/playground/vajra/src/obeyed/mod.rs (lines 72–76, 499–529)
- /Users/suman/playground/vajra/scripts/verify-closeout.sh (line 48)
- /Users/suman/playground/vajra/scripts/verify-closeout-scaffold.sh (line 48)

## Handoff Delta
- `+` new: first design-advisor handoff for this session (5791 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
