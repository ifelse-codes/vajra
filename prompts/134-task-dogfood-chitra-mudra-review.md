# Session 134 — PAID DOGFOOD: a real governed session in chitra, reviewing the mudra charts

> **Status:** APPROVED — founder, in chat at the S133 closeout. This REPLACES the previously-written
> S134 (`implementation-advisor` mandatory), which is **deferred to S135 — LOCKED by the founder in
> the same conversation, not merely "not dropped"**: it is an hour's work, it will keep, and its
> brief survives in this file's Non-goals ready to be restored.
>
> **The founder's own framing:** run it on **chitra**, and the task inside chitra is *"take all the
> new charts implemented in mudra design and review them and see them, and then tell me if it is
> impressive or not — or if not, what can be fixed; if yes, why and what we made good."*
>
> Founder directive in force (S118): README.md / VISION.md claims are the target spec, not a status
> report. Do NOT soften them.

## Type

DOGFOOD (paid). Max 2 assumptions, 2 retries, 1 story, ~2h, new chat. One story: **one real,
paid, Vajra-governed session runs in chitra and produces a design verdict a human actually wants** —
and Vajra's own behaviour during it is measured rather than assumed.

## Why this session — and why it beats making a third role mandatory

Nine sessions have passed since the last paid run (**S124, `$3.2985`, 2026-08-20**). Every
instrument in this repo measures Vajra governing itself. That blind spot once hid four
first-contact defects for 125 sessions; all four were visible in ten seconds from an empty
directory (S128).

**S133 sharpened the reason to do this NOW.** It shipped a gate that BLOCKS a session which has not
consulted the `design-advisor` — including, by design, the very first session of a brand-new
project, because the scaffolded prompt carries the marker as a placeholder. **Nobody has lived
through that.** It has only ever been exercised by this repo's own test scripts, against fixtures
this repo wrote.

And the honest counter-argument to the alternative, taken from S133's own summary: making
`implementation-advisor` mandatory is cheap, tidy, and closes green — but three unskippable roles
is not a used fleet, and it would be the tenth consecutive session with nothing a user could see.

**This session has two audiences and owes both a real answer.**

| Audience | The question | The deliverable |
|---|---|---|
| The founder, about **chitra** | Are the mudra charts impressive? | A design verdict with reasons, and the fixes if not |
| The founder, about **Vajra** | Did the governance help, or get in the way? | A measured dogfood report with a real dollar figure |

## Goal

Run **one real paid session inside `/Users/suman/playground/chitra`, through `vajra claude`**, whose
payload is a design review of every chart chitra has locked to the mudra reference language — looked
at, not just read — and report (a) the design verdict for the founder and (b) what Vajra did well
and badly while governing it.

## What "the new charts in mudra design" means, concretely

Verified live at the time of writing (do NOT trust this list — re-derive it, and record what you
actually found):

- **LOCKED families, merged:** circular (`pie`, `donut`) — chitra S09 · line (`line`) — S10 ·
  bar (`bar`, `horizontalBar`) — S12.
- **In flight, uncommitted on chitra's `session-16-sparkline-histogram-lock` branch:** `sparkline`
  and `histogram`, which chitra's own S16 brief describes as taking the count to "6 of 20 charts
  speak the reference dialect".
- The design language itself is `design-reference/` + the "Design Style" section of
  `packages/core/README.md`: dashed panel frame, mono-first, series identity = tone + dash + glyph
  (never rainbow), ONE accent hue per theme spent once, thin dashed gridlines with a solid baseline,
  eyebrow captions, metric summary cells, and SVG mirroring the terminal model.

**Review the merged families and the in-flight pair, clearly SEPARATED.** Never present unmerged
work as shipped.

## How to actually SEE them (the founder said "see them", and that word is load-bearing)

chitra already carries everything needed; nothing new should be built to look at a chart:

- **Terminal output:** the charts render ANSI. `scripts/` in chitra has per-chart demo scripts.
- **Browser:** `artifacts/chitra-docs` is a Vite app with a `/chart/:id` route for every chart, and
  `pnpm check:catalog` executes all catalog examples.
- **Screenshots already on disk:** `.ai/verify/session-15/<ts>/chart-*.png` — one PNG per chart from
  chitra's Playwright QA run. These are the fastest way to look at all of them at once, but they
  are **from S15 and may predate the in-flight work** — check the timestamp before trusting a PNG,
  and re-capture rather than reason about a stale image.
- Compare against `design-reference/` — the review is against chitra's OWN stated target, not
  against personal taste.

**A review that never renders a chart is not a review.** Say in the report exactly how each verdict
was formed: looked at a fresh render, looked at an existing screenshot, or read the code.

## Deliverables

### For the founder — the thing that was actually asked for

- **A design verdict on the mudra charts**, in plain English, that answers the founder's question in
  their own terms: **impressive or not.** Take a position; "it depends" is not a verdict.
  - **If yes — say WHY, and name what was made good**, specifically, per chart family. Which
    decisions paid off, and what they cost.
  - **If no — say what can be FIXED**, ranked, with the cheapest high-impact fix first.
  - Either way: name the **weakest chart of the six** and the **single change** that would most
    improve the set. A review with no ranked opinion is a description.
- **Presented visually, not as a wall of text** — an interactive HTML deck or artifact the founder
  can look at with the charts IN it (memory: `feedback-demo-presentation`). Terminal output shown as
  terminal output.
- Landed in chitra as `sessions/session-<NN>-mudra-chart-review.md` (or chitra's own convention —
  read chitra's `.ai/CONSTRAINTS.yaml`, do not impose Vajra's).

### For Vajra — the dogfood measurement

- **A real, authoritative dollar figure.** The run goes through `vajra claude` so the receipt is
  real. If the cost comes back unknown, that is a FINDING about S77–S79's receipt work, not a
  footnote — record it either way.
- **Which Vajra gates actually fired, and what each one did to the work.** Name every one that
  blocked, warned, or was silent, and say whether the block was RIGHT.
- **S133's brand-new mandate, tested by its first non-self use.** This session is governed by it in
  BOTH repos. Record what happened: did the design-advisor mandate help the chart review, get in
  the way, or sit inert? **This is the first evidence about it that this repo did not manufacture.**
- **Every place the governance cost more than it gave**, named without softening. A dogfood that
  reports only wins is a marketing document.
- `scripts/verify-session-134.sh` + `scripts/demo-session-134.sh` in **Vajra**, both exit 0, printed
  check-class tally, asserting on the REAL evidence this session produced (the receipt, the review
  artifact, the recorded gate outcomes) — not on fixtures.
- `sessions/session-134-summary.md` + exactly 3 ranked next candidates. **S135 is already LOCKED by
  the founder** — `implementation-advisor` mandatory, the brief in this file's Non-goals. Present
  three anyway, and say plainly whether anything this dogfood found should outrank it. A locked
  next session is a default, not a gag order: if the run surfaces something that matters more,
  the summary's job is to say so and let the founder decide.

## Acceptance (testable, EARS-style)

1. A real session ran in chitra **through `vajra claude`**, and the session records which binary was
   used (installed release vs this repo's build) and its version.
2. The mudra-locked chart families were re-derived live from chitra — never taken from this brief —
   and the list found is recorded, including any disagreement with the list above.
3. Every chart reviewed was **SEEN**, and the report states per family how (fresh render / existing
   screenshot + its timestamp / code only). A family judged from code alone is labelled as such.
4. The design verdict takes a POSITION — impressive or not — with reasons tied to chitra's own
   `design-reference/` target, plus the weakest chart and the single highest-impact change.
5. Merged work and chitra's in-flight `session-16` work are reported SEPARATELY, and nothing
   unmerged is presented as shipped.
6. **chitra's own in-flight state is not disturbed.** No commit, no stash, no branch switch, and no
   edit to chitra's uncommitted `session-16` files without the founder saying so in chat. Verify
   this by recording `git status --short` in chitra before AND after, and diffing the two.
7. The receipt reports a real cost, or the session records plainly that it could not — with the
   reason, as a finding.
8. Every Vajra gate that fired during the run is recorded with what it did and whether it was right.
9. S133's design-advisor mandate is exercised in this session and the outcome is recorded — whether
   satisfied by a real dispatch or by a recorded reasoned skip, and whether it helped.
10. `verify-session-134.sh` and `demo-session-134.sh` both exit 0 with a printed check-class tally,
    and their checks bind to this session's real artifacts.
11. Independent cold `fidelity-reviewer` verdict ACCEPT, attested. The judge of any `obeyed:`
    disposition may not be the role that made the recommendation.
12. The summary states plainly what is still NOT fixed, and answers one question directly: **after
    nine sessions of governance machinery, did any of it make this real piece of work better?**

## Plan (ordered — cite the acceptance criteria each step covers)

1. Put this session's own design question to a real `design-advisor` dispatch and land its handoff
   FIRST — the S133 mandate, met by real use. covers: 9
2. Record the choice and the rejected alternative in `## Design`. covers: 9
3. Capture chitra's `git status --short` BEFORE anything, as the baseline for criterion 6. covers: 6
4. Re-derive the mudra-locked chart list live from chitra. covers: 2
5. Run the paid session in chitra through `vajra claude`; review every chart, looking at each one.
   covers: 1, 3, 5
6. Write the design verdict — position, reasons, weakest chart, highest-impact change — and present
   it visually. covers: 4
7. Capture chitra's `git status --short` AFTER; diff against the baseline. covers: 6
8. Record the receipt, the gates that fired, and the mandate's outcome. covers: 7, 8, 9
9. `scripts/verify-session-134.sh` + `scripts/demo-session-134.sh`, binding to real artifacts.
   covers: 10
10. Cold `fidelity-reviewer` pass, then a separate judging dispatch for the dispositions. covers: 11
11. Say in the summary what is still not fixed, and answer the did-it-help question. covers: 12

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

(Filled during S134. `vajra next --check-advice 134` BLOCKS the close until every recorded
recommendation is answered, and `vajra next --check-obeyed 134` BLOCKS until every `obeyed:` claim
carries an independent judgment from a role that is not the one that gave the advice.)

## Design

- design-significant: yes — this session decides how Vajra is measured on real outside work, and
  the shape of that measurement will be copied by every future dogfood. It also touches a second
  repo, which no prior session's mechanism has had to reason about.
- Spine record to cite: `DECISION-005` (the autopilot trust layer — the pitch this dogfood tests)
  and `DECISION-007` with its **S133 addendum** (the mandate this session is the first outside test
  of). Verify both exist before citing them.
- **Open design question for S134 to resolve and record here:** does the chitra review take a chitra
  SESSION NUMBER (a real chitra session, advancing its `.ai/SESSION`), or run as a read-only pass
  that lands only an artifact? chitra is **mid-session-16 with uncommitted work**, so advancing its
  counter would collide. Decide, record the loser's reason, and remember criterion 6: chitra's
  in-flight state is not this session's to disturb.
- **Second open question:** this is NOT the fresh-scaffold dogfood the roadmap has been carrying —
  chitra is already Vajra-governed, so this measures Vajra on REAL WORK in a governed project, not
  first contact for a stranger. Say which of the two the roadmap item should now mean, and whether
  the other still needs its own session.

## Non-goals (not built this session)

- **Not `implementation-advisor` mandatory — that is S135, LOCKED by the founder**, immediately
  after this dogfood. Its brief was written at the S133 closeout and is preserved here verbatim so
  restoring it costs nothing: make it the fleet's third mandatory role **as a CALL SITE on
  `mandate`** (a second `*_gate` wrapper and a table entry, never a third copy of the ladder — it
  is the falsification test for S133's claim that the ladder is generic; if S135 finds itself
  editing `mandate_gate`, `parse_skip_marker` or `classify_marker_value`, the genericity was
  decoration and that is the session's most interesting finding). It must also decide
  `.ai/ROADMAP.md` **F2e** — one ladder for all three mandatory roles, or two, with a reason on the
  record — and probe the `maturity: L1` escape (**F2g**) live, since that is the last
  agent-reachable way to make these gates advisory.
  **What this session owes S135:** if the dogfood shows the mandate helping, getting in the way, or
  sitting inert on real outside work, S135's design has to answer for it. Write that finding down
  in terms S135 can act on, not as a general impression.
- **Not F2f** (the rubber-stamp detector). Still the highest-value open governance item.
- **Not fixing chitra.** This session REVIEWS chitra's charts. Any fix it proposes is chitra's own
  next session's work, and proposing is not doing. If a fix is irresistible, write it down and stop.
- Not the other seven roles, not compression, not F2/F2a/F2b/F2c, not the fourth fork. No release,
  no crates.io action.

## Delta (vs ROADMAP — OpenSpec markers)

- ADDED: the first paid dogfood in nine sessions; the first evidence about S133's mandate that this
  repo did not manufacture; a design verdict on chitra's mudra charts.
- MODIFIED: what "the fresh-scaffold paid dogfood" roadmap item means — this session must say
  whether it is satisfied, split, or still outstanding.
- UNCHANGED: the 8 stations, the 7 commands, `K of 8`'s derivation, S131's Fidelity gate, S132's
  Obeyed gate, S133's Mandate ladder, and every role's mandatory/optional status.

## Guardrails

- Un-forgeable commit marker on every Vajra commit, session number 134. Max 3 files per atomic
  commit. **chitra has its own constitution and its own hooks — read `chitra/.ai/` and obey chitra's
  rules inside chitra.** Do not import Vajra's.
- **Do not disturb chitra's uncommitted `session-16` work.** Baseline `git status --short` first,
  diff it at the end, and stop and ask if anything moved.
- **Spend real money on purpose.** Budget cap is `$5.00` (warn mode); S124 cost `$3.2985`. If the
  run is heading past the cap, say so in chat rather than quietly continuing.
- A check that cannot evaluate FAILS (S69). A probe must assert its own pattern matched (S127),
  including positive controls (S132).
- **Report the losses.** A dogfood whose findings are all favourable has not been run honestly.
- When a brief quotes fence syntax, never let a line START with the fence characters — it silently
  hides every `rec N` after it (S133, learned live).
- Attest LAST (S69/S131): recompute `--inputs-sha 134` after every edit to this prompt; two
  consecutive runs must agree. Run the full `verify-closeout.sh` on the branch BEFORE merging (S83).
