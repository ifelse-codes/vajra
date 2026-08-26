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
- **⚠ CORRECTION, from the design-advisor (rec 16): the line above is WRONG, and chitra's own two
  sources disagree with each other.** `packages/core/README.md` declares **four** LOCKED sections —
  circular (S09), **`area` (S09)**, line (S10), bar (S12) — while `chitra/.ai/STATE.md` names only
  three and omits `area`. The README's bar section never mentions `horizontalBar`. So the merged set
  may be **5 charts** (pie, donut, area, line, bar) + 2 in flight = **7**, not 6. Re-derive it, and
  **record the README-vs-STATE.md disagreement as a finding for chitra** — criterion 2 covers it.
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

- **Terminal output:** the charts render ANSI. **⚠ CORRECTION (rec 17): chitra has NO per-chart demo
  scripts.** `chitra/scripts/` holds per-SESSION scripts (`demo-session-01..15.sh`,
  `verify-session-01..15.sh`) plus `qa-catalog.mjs`, `post-merge.sh`, `ring-polish-handoff.mjs`,
  `verify-closeout.sh`. Render the charts directly from `packages/core` instead.
- **Browser:** `artifacts/chitra-docs` is a Vite app with a `/chart/:id` route for every chart
  (`pnpm --filter @workspace/chitra-docs run dev`). **`check:catalog` is a DOCS-PACKAGE script**
  (`artifacts/chitra-docs/package.json`), **not** a root script — the root only has `build`,
  `typecheck`, `typecheck:libs`.
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
  - Either way: name the **weakest chart of the set you re-derived** (never a pre-baked count — rec 16) and the **single change** that would most
    improve the set. A review with no ranked opinion is a description.
- **Presented visually, not as a wall of text** — an interactive HTML deck or artifact the founder
  can look at with the charts IN it (memory: `feedback-demo-presentation`). Terminal output shown as
  terminal output.
- Landed in chitra at **`sessions/mudra-chart-review-<UTC-date>.md` — date-keyed, NOT session-keyed**
  (rec 7), with a header saying "produced by Vajra session 134; this is not a chitra session;
  chitra's `.ai/SESSION` is unchanged at 15". chitra's `.ai/CONSTRAINTS.yaml` has **no**
  `session_summary_in` / `session_prompt_in` keys at all, so there is no recorded convention to
  obey — only an observed filename pattern. Say that plainly rather than claiming chitra's
  convention was followed. A date-keyed name also matches neither of chitra's `verify-closeout.sh`
  globs (`sessions/session-*-summary.md`, `^sessions/session-N-review\.md$`), so it can never be
  mistaken for a chitra fidelity verdict or pollute chitra's derived ledger.
- **Raw captures** (terminal `.txt`, browser PNGs) go under
  `chitra/.ai/verify/mudra-review-<UTC>/` — the one writable space in chitra that `chitra/.gitignore`
  already ignores, so it cannot move `git status` (rec 8, and the founder's S126 rule: raw captures
  stay local, git gets the review).

### For Vajra — the dogfood measurement

- **A real, authoritative dollar figure.** The run goes through `vajra claude` so the receipt is
  real. If the cost comes back unknown, that is a FINDING about S77–S79's receipt work, not a
  footnote — record it either way.
- **Pre-committed BEFORE the run, so an unknown cost cannot quietly become a footnote (rec 20):**
  `vajra meter` reads the on-disk Claude Code transcript, and `total_cost_usd` rides only the
  headless `-p` result stream (the S77/S78 root cause). This run must be **interactive** — charts
  cannot be looked at headlessly. **So the S77 honest-null is the LIKELY outcome here, not the
  exception**, and predicting it in advance is what stops it being spun either way afterwards.
- **Report the unmetered subagent token count BESIDE whatever dollar figure appears.** S132 recorded
  ~367k and S133 ~550k unmetered subagent tokens against "$0 metered for build". A dogfood headline
  of "$X" that omits the Vajra-side dispatches understates reality exactly as the last two sessions
  did — and this number is the one the pitch rests on.
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
   this with **four** recordings before AND after, all of which must match (rec 19 — `git status
   --short` alone misses a moved branch head, a new stash, and a staged/unstaged shuffle):
   `git rev-parse HEAD` · `git ls-files -s | shasum -a 256` · `git stash list` ·
   `git status --porcelain --untracked-files=all`.
   **The ONE permitted delta, declared here in advance:** exactly one new untracked path, the
   review artifact named in the Deliverables. Every other difference FAILS. (Without this the
   criterion contradicts the Deliverables by construction.)
7. The receipt reports a real cost, or the session records plainly that it could not — with the
   reason, as a finding.
8. Every Vajra gate that fired during the run is recorded with what it did and whether it was right.
9. **The mandate is exercised FOR REAL in Vajra, and its behaviour in chitra is MEASURED and
   recorded, including any exemption.** (rec 11 — the original wording, "governed by it in BOTH
   repos", is FALSE and unachievable: chitra has no `design-advisor.md` in `.claude/agents/`, so the
   subagent type cannot resolve there, and chitra's session 16 sits below
   `DESIGN_ADVISOR_MANDATE_FROM_SESSION = 133`, so silence gets a WARN and never a block. Certifying
   the old wording green would be a self-granted-jurisdiction green.) Do **not** hand-write a skip
   marker into chitra's tracked prompt to manufacture a pass; run the gate, capture its literal
   output, and report the WARN as the finding.
   **"Did it help?" must be falsifiable, not an adjective (rec 13) — three artefacts:**
   (a) the F2f timestamp comparison done BY HAND (this session does not build F2f): the handoff's
   `captured:` frontmatter printed beside the timestamp of S134's first substantive commit;
   (b) at least ONE named thing in the delivered work that is different because of a recorded rec,
   pointed at a commit or an artifact; (c) at least ONE rec that changed nothing, named as such.
   An honest null — "the mandate produced a handoff and changed nothing" — is a valid, S135-actionable
   result and must be published if that is what happened.
10. `verify-session-134.sh` and `demo-session-134.sh` both exit 0 with a printed check-class tally,
    and their checks bind to this session's real artifacts.
11. Independent cold `fidelity-reviewer` verdict ACCEPT, attested. The judge of any `obeyed:`
    disposition may not be the role that made the recommendation.
12. The summary states plainly what is still NOT fixed, and answers one question directly: **after
    nine sessions of governance machinery, did any of it make this real piece of work better?**
13. **Both open design questions are DECIDED in `## Design`, each with the loser's reason on the
    record** — (Q1) whether the chitra review takes a chitra session number, and (Q2) what the
    roadmap's dogfood item now means. (rec 21: without this criterion the brief's most-emphasised
    deliverable is ungated — steps 1 and 2 both cite criterion 9, which is about the mandate's
    outcome, not about resolving Q1/Q2. The Architect gate will not catch it either: it checks only
    that a non-placeholder `## Design` cites a record that exists, never that the design answers the
    questions the prompt posed.)
14. **Criterion 3 is machine-checkable, not self-asserted (recs 14, 15).**
    `sessions/session-134-artifacts/seen-manifest.tsv` carries one row per chart
    (`family, chart, method, evidence_path, sha256, captured_utc, source_mtime_utc`); `method` comes
    from the closed vocabulary `fresh-render-terminal | fresh-render-browser | screenshot-existing |
    code-only` and any other word FAILS; every `evidence_path` must exist (absent → FAIL, never
    skip) and its `sha256` must recompute equal; the row count must equal the live re-derived family
    list and be non-zero. **The stale-screenshot tooth:** a `screenshot-existing` row whose
    `captured_utc` is older than its `source_mtime_utc` is INVALID — every chitra S15 PNG is stamped
    `20260822T…` and the in-flight sparkline/histogram work post-dates all of them, so for exactly
    the two families the founder most wants judged, an S15 screenshot is code-only evidence wearing
    a picture. `scripts/fixture-session-134.sh` plants four defects (mutated sha · stale-screenshot
    row · unknown `method` word · empty manifest), each asserting its own substitution landed, and
    the suite goes RED on each.
15. **Every Vajra gate invocation's raw stdout AND exit code is captured to
    `sessions/session-134-artifacts/gate-log/`**, one file per invocation named for the flag, exit
    code on the first line — and `verify-session-134.sh` binds criterion 8 to those files rather
    than to the agent's own account of them (rec 18).

## Plan (ordered — cite the acceptance criteria each step covers)

1. Put this session's own design question to a real `design-advisor` dispatch and land its handoff
   FIRST — the S133 mandate, met by real use. covers: 9
2. Record BOTH resolved design questions and each loser's reason in `## Design`, and correct the
   brief where the advisor showed it to be factually wrong. covers: 13
3. Capture chitra's four-way state fingerprint BEFORE anything, as the baseline for criterion 6.
   covers: 6
4. Re-derive the mudra-locked chart list live from chitra. covers: 2
5. Run the paid session in chitra through `vajra claude`; review every chart, looking at each one.
   covers: 1, 3, 5
6. Write the design verdict — position, reasons, weakest chart, highest-impact change — and present
   it visually. covers: 4
7. Capture chitra's four-way fingerprint AFTER; diff against the baseline, allowing exactly the one
   declared path. covers: 6
8. Record the receipt (with the unmetered subagent tokens beside it), every gate invocation's raw
   stdout + exit code to the gate-log, and the mandate's outcome with its three falsifiable
   artefacts. covers: 7, 8, 9, 15
9. Write `seen-manifest.tsv` and `scripts/fixture-session-134.sh`; `scripts/verify-session-134.sh` +
   `scripts/demo-session-134.sh` bind to those real artifacts and go RED on each planted defect.
   covers: 10, 14
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

- design-significant: yes — **not because it is a dogfood** (S63, S118, S124 and S126 were all
  dogfoods and none needed a design record), but because it defines the **first evidence contract
  for a Vajra gate binding to artifacts produced in a SECOND repository**, a shape every future
  dogfood will copy, and because it re-reads a locked roadmap item. Interface + deviation, not fix.
  (design-advisor rec 1.)
- **Spine records, both verified to exist on disk before citing:**
  - `DECISION-007` — specifically its **S133 addendum, section 6** ("migration threshold 133,
    governing SILENCE only"), the exact clause this run is the first outside test of.
  - `DECISION-005` — **SUPERSEDED 2026-07-27 by the S103 founder pivot.** What is RETIRED is its
    machinery-freeze rule and ladder-as-paid-sessions plan. What is LIVE, and the reason this
    dogfood runs in chitra and not somewhere else, is its Rung-2 row naming **chitra** as the
    ladder repo. Cited with the status said out loud, because the Architect gate checks existence
    only and cannot see a SUPERSEDED banner (the disclosed S67 form floor). (rec 3.)
- **Deviation from `DECISION-005`, declared rather than implied (rec 4):** (i) this is an attended,
  ~2h, single-task run — it is **not** a Rung-2 ladder run and must never be reported as one;
  (ii) `DECISION-005`'s "guards ON for every ladder run" holds **inside chitra** (`maturity: L3`,
  no `publish_guard`/`commit_guard` keys → armed) and does **not** hold in the Vajra repo
  (both `off`). Say which side of the run had teeth.
- **Q1 — RESOLVED: a READ-ONLY pass. The review takes NO chitra session number** and is numbered
  against Vajra's S134 only. chitra's `.ai/SESSION` says `15`, its `TASK.md` and `STATE.md` still
  describe session 15, yet `HEAD` is on `session-16-sparkline-histogram-lock` with an in-flight
  prompt 16. Advancing to 16 would claim this review IS chitra's S16; advancing to 17 would orphan
  an unclosed 16 and leave three of chitra's `.ai/` files permanently wrong. And chitra is **L3** —
  a real session number drags in its own `verify-closeout.sh` (a review, an attested verdict, a
  summary, a verify/demo pair, an `.ai/` sync, a PR), every one of which needs **commits on a
  branch already holding someone else's uncommitted work**, which criterion 6 forbids outright.
  - **The loser, and its reason, honestly:** taking chitra session 17 would have bought a real
    `K of 8` station reading and a chitra ledger entry. It loses **only because the counter is
    occupied**, not because it was a bad idea. Most of that evidence is recoverable for free:
    `--stations`, `--check-design`, `--check-design-handoff`, `--check-plan`, `--check-advice`,
    `--check-obeyed` and `--dogfood-age` are all read-only derivations. Run them inside chitra and
    capture stdout + exit code. (recs 5, 6.)
- **Q2 — RESOLVED: the roadmap's dogfood item SPLITS in two.**
  - **D1 — governed-real-work dogfood: SATISFIED by S134.** Vajra measured on real work inside an
    already-governed project.
  - **D2 — fresh-scaffold first-contact dogfood: STILL OUTSTANDING, owns its own session.** chitra
    is the opposite of a fresh scaffold: it runs the **old 55-line constitution** (no fidelity gate,
    no mandate, no marker rules), 4 of 9 roles in `.claude/agents/`, 7 required audits against
    Vajra's 12. D2 measures a different thing — whether a brand-new project can reach a **close**
    under two mandatory roles. `stranger-check.sh` and `scaffold-drift.sh` already cover D2's free
    half; what remains is a **paid run to a close**.
  - **Rejected:** declaring the single item satisfied here. That would retire the only instrument
    aimed at strangers on the strength of a run that structurally *cannot* exercise the mandate
    (threshold 133 > chitra's 16). (rec 9.)
- **New record owed by this session:** an **S134 addendum to `DECISION-007`** recording the
  **brownfield threshold hole** — the S133 addendum disclosed the fresh-project case and closed it
  with a scaffolded placeholder marker, but never the case of an *already-governed* project sitting
  below 133 whose old prompts carry no marker at all: silence → WARN forever. chitra is the live
  specimen. An addendum, not a `DECISION-008`, on n=1. S135 inherits the same threshold. (rec 12.)

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
- **Two honesty floors on the verdict itself, so "impressive" is falsifiable (rec 22):**
  (a) **a zero must be a SEARCHED-FOR zero** — if the review finds no chart violating its family's
  locked rules, it must quote which specific README rules it checked against which render (the
  README states them literally: accent spent once · no rainbow · dashed frame · `+` tick rows ·
  empty cells are spaces · per-series MIN/MAX/AVG/LAST);
  (b) **the Non-goal holds even when a fix looks like one line** — every fix is a ranked PROPOSAL in
  the review artifact, and nothing under `chitra/packages/` is touched. The risk is precisely that a
  reviewer who can see the defect reaches for it.
- When a brief quotes fence syntax, never let a line START with the fence characters — it silently
  hides every `rec N` after it (S133, learned live).
- Attest LAST (S69/S131): recompute `--inputs-sha 134` after every edit to this prompt; two
  consecutive runs must agree. Run the full `verify-closeout.sh` on the branch BEFORE merging (S83).
