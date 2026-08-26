# Session 135 — `implementation-advisor` becomes the fleet's THIRD mandatory role, as a CALL SITE

> **Status:** LOCKED by the founder in chat at the S133 closeout, and re-confirmed by S134's own
> summary: nothing the dogfood found outranks it. But S134 **changed what it must contain** — it
> hands S135 a named, recorded hole that did not exist when this was locked.
>
> Founder directive in force (S118): README.md / VISION.md claims are the target spec, not a status
> report. Do NOT soften them.

## Type

CODE. Max 2 assumptions, 2 retries, 1 story, ~2h, new chat. One story: **the fleet's third role
becomes unskippable-in-silence on the EXISTING mechanism, and the threshold's brownfield hole is
either fixed or refused in writing.**

## Why this session

S133 shipped `src/mandate/mod.rs` deliberately **generic over a `fleet::Role`** so that the next
mandatory role would be a call site and not a third copy of the ladder. That claim has never been
tested. **This session is its falsification test**, and the test has a sharp edge:

> **If S135 finds itself editing `mandate_gate`, `parse_skip_marker` or `classify_marker_value`,
> the genericity was decoration — and that is this session's most interesting finding.** Report it
> as the headline, do not paper over it.

S134 then found something nobody had reasoned about. The full record is the **DECISION-007 S134
addendum**; the short version is below, because S135 inherits it.

## What S134 handed this session (read this before designing anything)

**The brownfield threshold hole.** `mandate::DESIGN_ADVISOR_MANDATE_FROM_SESSION = 133` exempts
silence below the threshold. S133 disclosed the FRESH-project case and closed it by making
`analyst::PROMPT_TEMPLATE` carry the marker as a placeholder, so a scaffolded session 1 blocks. It
never reasoned about the **brownfield** case: an already-governed project sitting below 133 whose
existing prompts were written before the marker existed. Captured live in chitra
(`sessions/session-134-artifacts/gate-log/chitra-check-design-handoff-16.txt`, exit 0):

    === mandate: design-advisor for session 16 ===
    prompt:  prompts/16-task-sparkline-histogram-lock.md
    handoff: (none)
    verdict: READY
      ⚠ session 16 predates the design-advisor mandate (threshold 133) — silence is exempt
        below it, and only below it.

chitra's session 16 was **actively locking two chart families to a reference design language** — the
exact session the mandate exists for. **The threshold counts the wrong units:** it counts the
governed project's session numbers, when what it means is *"prompts written before this rule
existed."* For Vajra it is a closing window. For a project adopting Vajra at its session 40 it is a
**permanent exemption with nothing that ever ends it.**

**The second thing, harder to act on.** `vajra next --stations 16` in chitra reads **`0 of 8`**, at
`maturity: L3`. Every surfacing gate WARNs; `--check-plan 16` reports no `## Plan` section at all.
The governance is installed and unused. **A third unskippable role does not obviously move that
number. If this session believes it does, it must say how — and if it does not, it must say that too.**

## Goal

Make `implementation-advisor` the fleet's third mandatory role **by adding a call site on
`src/mandate`, not a third ladder** — and decide the brownfield threshold, either by fixing the
units or by recording in writing why a second mandatory role ships with a known permanent exemption.

## Deliverables

- **A second `*_gate` wrapper and a table entry.** That should be close to the whole diff in
  `src/mandate`. Every line you add to the ladder ITSELF is evidence against S133's genericity claim
  — count those lines and report the number.
- **`vajra next --check-implementation-handoff NN`**, bound at `--advance` AND at
  `scripts/verify-closeout.sh`, exactly as `--check-design-handoff` is. **No 8th top-level command.**
- **The reasoned skip inherited with NO new parser.** S133 keyed the marker on the ROLE NAME
  precisely so `implementation-advisor: skipped — <reason>` works with zero parser changes. If it
  does not, say so loudly — that is the genericity failing.
- **No `VAJRA_SKIP_*` escape**, on purpose, matching S133. Prove it: drive the environment variables
  live, one at a time and all together, and show it blocks every time.
- **ROADMAP F2e decided** — one ladder for all three mandatory roles, or two, **with the reason on
  the record** either way.
- **ROADMAP F2g probed LIVE** — `maturity: L1` is the last agent-reachable way to make these gates
  advisory, and `.ai/CONSTRAINTS.yaml` is agent-writable. Nothing has ever probed it. Do it.
- **The threshold decision, recorded.** Fix the units, or refuse with a written reason. The three
  candidates DECISION-007's S134 addendum names, none endorsed:
  - a per-project adoption marker in `.ai/` — honest, but agent-writable, so it is a self-granted
    exemption of exactly the S133 "jurisdiction is self-granted" class;
  - compare the prompt file's git birth date against the rule's landing date — un-forgeable-ish, but
    costs a git call per gate and dies in a shallow clone;
  - drop the threshold entirely and let pre-existing projects fail loudly until they record a
    reasoned skip — simplest, most honest, worst first-run experience.
- `scripts/verify-session-135.sh` + `scripts/demo-session-135.sh`, both exit 0 with a printed
  check-class tally, plus a falsifiability fixture. `sessions/session-135-summary.md` + exactly 3
  ranked next candidates.

## Acceptance (testable, EARS-style)

1. `implementation-advisor` is mandatory: a session cannot reach its close without either a real
   governed handoff or a recorded, substantive `implementation-advisor: skipped — <reason>`.
2. The gate binds at BOTH `--advance` and `scripts/verify-closeout.sh`, and rides `vajra next` —
   the 7-command floor is unchanged.
3. **The genericity claim is tested and the result reported as a NUMBER:** lines added to
   `src/mandate`'s shared ladder (`mandate_gate`, `parse_skip_marker`, `classify_marker_value`)
   versus lines added as call-site/table. If the shared ladder had to change, that is the headline.
4. The reasoned-skip grammar works for the new role with **no new parser**, proved by a test that
   binds to VALUES rather than to message text (S133).
5. No environment variable satisfies or bypasses the gate. At least twelve are driven live, singly
   and together, and it blocks every time; the module contains zero `env::var` calls.
6. **The brownfield threshold is DECIDED** — fixed, with the mechanism and its own falsifiability
   fixture; or refused, with the reason recorded in a DECISION addendum. "Deferred" is not a
   decision unless it names what would settle it.
7. **F2e is decided** with the reason on the record, either way.
8. **F2g is probed LIVE**: set `maturity: L1` in a throwaway copy, run the gate, capture the literal
   output and exit code, and record whether the escape is real.
9. `verify-session-135.sh` + `demo-session-135.sh` both exit 0 with a printed check-class tally, and
   a falsifiability fixture goes RED on each planted bypass, each asserting its own substitution
   landed **and its positive control asserting a clean exit 0** (S134: a sandbox missing one file
   made the exit-code half of every assertion meaningless).
10. Independent cold `fidelity-reviewer` verdict ACCEPT, attested. **The judge of any `obeyed:`
    disposition may not be the role that made the recommendation** — and since
    `implementation-advisor` is the role being made mandatory, the judge for ITS advice must be a
    third role again.
11. The summary states plainly what is still NOT fixed, names the fakest green, and answers one
    question directly: **does a third unskippable role move `0 of 8` in the one real outside
    project — and if not, what would?**

## Plan (ordered — cite the acceptance criteria each step covers)

1. Dispatch `design-advisor` FIRST and land its handoff — the S133 mandate, met by real use.
   covers: 10
2. Record the design and the threshold decision's rationale in `## Design`. covers: 6, 7
3. Add the call site on `src/mandate` and count the shared-ladder lines touched. covers: 1, 3
4. Bind at `--advance` and `verify-closeout.sh`; confirm the 7-command floor. covers: 2
5. Prove the skip grammar inherits with no new parser, with value-bound tests. covers: 4
6. Drive twelve-plus environment variables live against the gate. covers: 5
7. Decide the brownfield threshold and land its mechanism or its written refusal. covers: 6
8. Decide F2e; probe F2g live and capture its literal output. covers: 7, 8
9. `verify-session-135.sh` + `demo-session-135.sh` + the fixture with a clean-exit control.
   covers: 9
10. Cold `fidelity-reviewer` pass, then a separate judging dispatch by a third role. covers: 10
11. Answer the `0 of 8` question in the summary, plainly. covers: 11

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
- step 4 — done: <sha>
- step 5 — done: <sha>
- step 6 — done: <sha>
- step 7 — done: <sha>
- step 8 — done: <sha>
- step 9 — done: <sha>
- step 10 — done: <sha>
- step 11 — done: <sha>

## Advice (every recommendation from this session's advisors, answered)

(Filled during S135. `vajra next --check-advice 135` BLOCKS the close until every recorded
recommendation is answered, and `vajra next --check-obeyed 135` BLOCKS until every `obeyed:` claim
carries an independent judgment from a role that is not the one that gave the advice.)

## Design

- design-significant: yes — this session changes a gate's jurisdiction (a third role becomes
  unskippable) and may change the migration threshold that governs every mandatory role in every
  adopting project. Interface plus a possible deviation from a locked record, not a fix.
- Spine record to cite: `DECISION-007` and specifically its **S133 addendum** (the ladder, the
  reasoned skip, the threshold) and its **S134 addendum** (the brownfield hole this session
  inherits). Verify both exist before citing them.
- **Open design question 1:** one ladder for all three mandatory roles, or two? (`src/mandate` and
  `src/fidelity` are the two that exist — ROADMAP F2e.) Decide and record the loser's reason.
- **Open design question 2:** the brownfield threshold. Decide and record the loser's reason.

## Non-goals (not built this session)

- **Not F2f** (the rubber-stamp detector). Still the highest-value open governance item — and S134
  did its comparison BY HAND and found it genuinely informative, which is an argument for building
  it, not a substitute.
- **Not D2** — the fresh-scaffold first-contact paid dogfood, split out and made explicitly
  outstanding by S134's Q2. It needs its own paid session driven to a close.
- **Not fixing chitra**, and not acting on the ranked proposals S134's review handed it. That is
  chitra's own next session's work.
- Not the other six roles, not compression, not F2/F2a/F2b/F2c, not the fourth fork.

## Delta (vs ROADMAP — OpenSpec markers)

- ADDED: a third mandatory fleet role; a decision on the brownfield threshold; a live F2g probe.
- MODIFIED: ROADMAP F2e (decided, one way or the other); the migration threshold's semantics, if
  the units are fixed.
- UNCHANGED: the 8 stations, the 7 commands, `K of 8`'s derivation, S131's Fidelity gate, S132's
  Obeyed gate, S133's ladder shape, and the mandatory/optional status of the other six roles.

## Guardrails

- Un-forgeable commit marker on every commit, session number 135. Max 3 files per atomic commit.
- **Count the shared-ladder lines honestly.** The temptation is to call a change to `mandate_gate` a
  "small refactor". It is not — it is the falsification.
- A check that cannot evaluate FAILS (S69). A probe must assert its own pattern matched (S127),
  including positive controls (S132), **and a fixture's positive control must assert a clean exit 0**
  (S134).
- **A forward reference is not a number (S134).** Report subagent token counts as figures in the
  summary, not as "see the review".
- **Three consecutive judges have had no shell (S133, S134 ×2).** Every "verify N/N" claim in those
  sessions was executed only by the builder. If this session's judge also has no shell, say so in
  the review rather than letting the reader assume otherwise.
- When a brief quotes fence syntax, never let a line START with the fence characters — it silently
  hides every `rec N` after it (S133, learned live).
- Attest LAST (S69/S131): recompute `--inputs-sha 135` after every edit to this prompt; two
  consecutive runs must agree. Run the full `verify-closeout.sh` on the branch BEFORE merging (S83).
