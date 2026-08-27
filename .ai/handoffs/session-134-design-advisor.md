---
role: design-advisor
session: 134
agent: claude-code-subagent (verified: toolu_018AfGGbawbcTyeFdcj9xf5x)
source-sha: 4724d22d7dc8b96d63a791591e680cc042bbc73d2f1462de229c325e24cf154d
captured: 2026-08-26T14:23:27Z
cost_usd: null
---

# Design-advisor handoff — session 134

# design-advisor brief — session 134 (paid dogfood in chitra, reviewing the mudra charts)

## What I read

`prompts/134-task-dogfood-chitra-mudra-review.md` in full, `.ai/STATE.md`, `.ai/CONSTRAINTS.yaml`,
ROADMAP F2e/F2f/F2g and the dogfood item, `src/architect/mod.rs` + `src/mandate/mod.rs` (to know
what the gates actually parse), and on the chitra side: `.ai/` (SESSION, TASK.md, STATE.md,
CONSTRAINTS.yaml, AGENTS.md), `packages/core/README.md`, `scripts/`, `.gitignore`,
`.claude/agents/`, `scripts/verify-closeout.sh` and `prompts/16-task-sparkline-histogram-lock.md`.

**Spine records verified on disk before citing:** `docs/decisions/DECISION-007-agent-fleet.md`
(exists; S133 addendum present at its end) and `docs/decisions/DECISION-005-autopilot-trust.md`
(exists; **Status: SUPERSEDED**). The Architect gate matches the literal token `DECISION-<digits>` /
`ADR-<digits>` case-insensitively inside the `## Design` section and requires the number to resolve
against a real file (`architect::cited_refs_on` + `spine_refs`), so both citations pass — but
existence is all it checks.

## Findings

rec 1 — Record `design-significant: yes`, and give the reason as "a new cross-repo evidence
interface plus a recorded re-reading of a roadmap item", not "this is a dogfood".
"It's a dogfood" is not a significance argument — S63, S118, S124 and S126 were all dogfoods and
none needed a design record. What makes THIS one significant under the marker's own definition
(`src/architect/mod.rs:21` — new/changed interface, new module, deviation from a locked record) is:
(a) it invents the first evidence contract for a Vajra gate binding to artifacts that live in a
different repository, and every future dogfood will copy its shape; (b) it resolves two open
questions that change what a locked roadmap item means. Both are interface/deviation, not fix.

rec 2 — Cite `DECISION-007` and name the S133 addendum explicitly as the primary record; it is the
record this run is the first outside test of. The addendum's section 6 ("Migration threshold 133,
governing SILENCE ONLY") is the exact clause this session measures on real outside work. Cite it by
name in the rationale line, not just the record number, so a reader lands on the clause rather than
a 940-line file.

rec 3 — Cite `DECISION-005` with its SUPERSEDED status stated in the same sentence, and say which
half is live. `DECISION-005` line 4 reads `**Status:** SUPERSEDED (2026-07-27, S103 founder
pivot...)`. The Architect gate cannot see that — it checks existence only, which is the disclosed
S67 form floor. Citing a superseded record silently is exactly the shape the S127 addendum names.
What is live and load-bearing here is the Rung-2 row — "1 day unattended, multi-task, chitra" —
which is why chitra, and not some other repo, is the dogfood subject. What is retired is the
machinery-freeze rule and ladder-as-paid-sessions.

rec 4 — Declare in `## Design` that this run DEVIATES from `DECISION-005`'s ladder in two named
ways, rather than letting the citation imply compliance. (i) This is attended, ~2h, single-task —
it is not a Rung-2 run and must never be reported as one. (ii) `DECISION-005` says "Guards ON for
every ladder run (publish_guard/commit_guard armed)". That holds inside chitra (`maturity: L3`, no
`publish_guard`/`commit_guard` keys, so guards on) and does NOT hold in the Vajra repo
(`.ai/CONSTRAINTS.yaml:194,201` — both `off`). Say which side of the run had teeth.

rec 5 — Q1, decided: a READ-ONLY pass. Do NOT take a chitra session number. The review is numbered
against Vajra's S134 and against nothing in chitra. The disk facts force this: `chitra/.ai/SESSION`
contains `15`; `chitra/.ai/TASK.md` still points at "Session 15 — COMPLETE, PR pending";
`chitra/.ai/STATE.md` says Active Branch `session-15-browser-qa`; but `.git/HEAD` is
`refs/heads/session-16-sparkline-histogram-lock` and `prompts/16-task-sparkline-histogram-lock.md`
exists with `## Execution / step 1 — pending`. Advancing to 16 would claim this review IS chitra's
S16; advancing to 17 would orphan an unclosed 16 and make three of chitra's `.ai/` files
permanently wrong. Worse, chitra is L3: a real session number drags in `scripts/verify-closeout.sh`
(which demands `sessions/session-16-review.md`, an attested verdict, a summary, a verify/demo pair,
an `.ai/` sync and a PR) — every one of which requires commits on a branch that already holds
someone else's uncommitted work, which acceptance 6 forbids outright.

rec 6 — Record the loser's reason honestly: a chitra session number would have bought a real
`K of 8` station reading and a ledger entry, and it loses only because the counter is occupied —
not because it was a bad idea. State the consolation in the same bullet, because it is nearly the
whole prize: `vajra next --stations 16`, `--check-design 16`, `--check-design-handoff 16`,
`--check-plan 16`, `--check-advice 16`, `--check-obeyed 16` and `--dogfood-age` are all read-only
derivations (only the advancing flag and `--role --from` write). Run every one of them inside
chitra and capture stdout + exit code. That yields the station reading and the live gate behaviour
with zero counter movement, so the rejected option costs almost nothing.

rec 7 — Land the founder-facing artifact at
`/Users/suman/playground/chitra/sessions/mudra-chart-review-<UTC-date>.md` — date-keyed, not
session-keyed — and say in its header "produced by Vajra session 134; this is not a chitra session;
chitra's `.ai/SESSION` is unchanged at 15." Two disk facts drive the name. First, chitra's
`.ai/CONSTRAINTS.yaml` has NO `state.session_summary_in` / `session_prompt_in` keys at all — unlike
Vajra's — so there is no recorded convention to obey, only an observed filename pattern
(`sessions/session-NN-{summary,review,ground-truth}.md`). Say that plainly rather than claiming you
followed chitra's convention. Second, chitra's `scripts/verify-closeout.sh` globs
`sessions/session-*-summary.md` (line 86) and matches `^sessions/session-\([0-9][0-9]*\)-review\.md$`
for the ledger (lines 431-435). A date-keyed name matches neither, so it cannot be mistaken for a
chitra fidelity verdict or pollute chitra's derived ledger. The brief's suggested
`session-<NN>-mudra-chart-review.md` also dodges the ledger regex, but it reads as chitra S16's own
artifact, which is the one thing rec 5 says it must not.

rec 8 — Put every capture (terminal text, browser PNGs) under
`/Users/suman/playground/chitra/.ai/verify/mudra-review-<UTC>/`, because `chitra/.gitignore:5`
ignores all of `.ai/verify/`. This is the only writable space in chitra that does NOT move
`git status --short`, and it reuses chitra's own existing artifact shape
(`.ai/verify/session-15/<ts>/chart-*.png`) without imposing a new directory. It also lines up with
the founder's own S126 rule: raw run captures stay local, git gets the review.

rec 9 — Q2, decided: split the roadmap's dogfood item in two. This session SATISFIES "governed real
work"; it does NOT satisfy "fresh-scaffold first contact", which still needs its own session. The
roadmap carries the phrase twice — `.ai/ROADMAP.md:205` ("a fresh-scaffold dogfood run") and `:660`
("S134's fresh-scaffold dogfood gets the product ready for a real ask"), both anchored to
A1/stranger-readiness. chitra is the opposite of a fresh scaffold: its `.ai/AGENTS.md` is the old
55-line constitution (no fidelity gate, no mandate, no marker rules), its `required_audits` is 7
entries against Vajra's 12, and `.claude/agents/` holds only four roles. Recommend renaming to
D1 — governed-real-work dogfood (SATISFIED at S134) — and D2 — fresh-scaffold first-contact dogfood
(OUTSTANDING, own session). D2 measures a genuinely different thing: whether a brand-new project
can reach a close under two mandatory roles. Note in the record that `scripts/stranger-check.sh` and
`scripts/scaffold-drift.sh` already cover D2's free half (both GREEN at S130), so D2's remaining
novelty is a paid run to a close, not another empty-directory smoke.

rec 10 — On the cross-repo mandate: dispatch for real on the Vajra side only, and record chitra's
side as a measured WARN, not as a skip you wrote. Two mechanical blocks, both verified:
(1) `/Users/suman/playground/chitra/.claude/agents/` contains `researcher.md`,
`fidelity-reviewer.md`, `plan-advisor.md`, `qa-specialist.md` — there is NO `design-advisor.md`.
Per DECISION-007's S111 addendum, Claude Code discovers agent files once at session start, so
`subagent_type: design-advisor` cannot resolve in chitra, and writing the file mid-run is both
invisible to that run and a tracked-tree change acceptance 6 forbids.
(2) `mandate::DESIGN_ADVISOR_MANDATE_FROM_SESSION = 133` and rung 6 (`src/mandate/mod.rs:26`)
exempts silence below the threshold — chitra's session 16 gets a WARN naming the exemption, never a
block. So do not hand-write a `design-advisor: skipped` line into chitra's prompt 16 to make a
green: that is an edit to a tracked file, and it would manufacture the very evidence this dogfood
exists to stop manufacturing. Run `vajra next --check-design-handoff 16` in chitra, capture the
literal output, and report the WARN as the finding.

rec 11 — Fix acceptance criterion 9's wording before attesting: "This session is governed by it in
BOTH repos" is FALSE as written. Per rec 10 it is governed by it in Vajra and structurally exempt
in chitra. Leaving the sentence in and then certifying criterion 9 green is a
self-granted-jurisdiction green. Rewrite it to something the run can actually satisfy — e.g. "the
mandate is exercised for real in Vajra, and its behaviour in chitra is measured and recorded,
including any exemption."

rec 12 — Record the threshold-133 result as an S134 addendum to `DECISION-007`, not a new
`DECISION-008`. The S133 addendum discloses the fresh-project case ("sessions 1..132 would all sit
below this number", closed by the scaffolded placeholder marker). It does NOT disclose the
brownfield case: an already-governed project sitting below 133 with old prompts that carry no
marker at all gets silence, so WARN forever. chitra is a live specimen. That is new information
about a locked clause, which is precisely what the S122 addendum did to its own record. A new
DECISION record on n=1 would be premature; a correction addendum is the house pattern. Write it in
terms S135 can act on, since S135 inherits the same threshold for `implementation-advisor`.

rec 13 — Make "did the mandate help?" falsifiable with three artefacts, not an adjective: a
timestamp comparison, one named change, and one named null. (a) Do F2f by hand this session (do not
build it): compare `.ai/handoffs/session-134-design-advisor.md`'s `captured:` frontmatter against
the timestamp of S134's first substantive commit, and print both. That is the only observable today
that distinguishes advice-that-shaped-work from a rubber stamp. (b) Name at least ONE concrete
thing in the delivered work that is different because of a recorded rec, pointing at the commit or
the artifact — not "the advice was useful". (c) Name at least one rec that changed nothing, and say
so. A report where every rec helped is the marketing document the guardrails already forbid.
Pre-commit to publishing an honest null: "the mandate produced a handoff and changed nothing" is a
valid, S135-actionable finding.

rec 14 — Make criterion 3 machine-checkable with one committed file in Vajra:
`sessions/session-134-artifacts/seen-manifest.tsv`, one row per chart, columns
`family, chart, method, evidence_path, sha256, captured_utc, source_mtime_utc`. `method` must come
from a closed vocabulary — `fresh-render-terminal`, `fresh-render-browser`, `screenshot-existing`,
`code-only` — and any other word FAILS. `verify-session-134.sh` then binds to real bytes: every
row's `evidence_path` must exist (missing means FAIL, never skip, per S69 cannot-evaluate), its
`sha256` must recompute equal, the row count must equal the count in the live-re-derived family
list and be non-zero (non-vacuity floor, the S126 lesson about pinned counts — use `-ge` for the
floor and `==` only against the re-derived list). Capture terminal renders as `.txt`, not PNG:
cheap, hashable, diffable, and it is literally the artifact the founder asked to see. Disclose that
the PNG bytes live in chitra's gitignored `.ai/verify/` so the binding is machine-local — the same
disclosed class as `--dogfood-age` (S91), `check-subagent-cost-fields.sh` (S111) and the S131
dispatch gate. Machine-local plus fail-on-absent is honest; machine-local plus skip-on-absent is a
fake green.

rec 15 — Add the one check that turns the brief's prose warning into a tooth: if `method` is
`screenshot-existing`, then `captured_utc` must be greater than or equal to that chart's
`source_mtime_utc`, else the row is invalid. This is not hypothetical. Every PNG under
`chitra/.ai/verify/session-15/` is stamped `20260822T...` (four runs: `054923Z`, `055753Z`,
`080323Z`, `080413Z`). The in-flight sparkline/histogram work post-dates all of them. So for
exactly the two families the founder most wants judged, an S15 screenshot is code-only evidence
wearing a picture. Back the check with `scripts/fixture-session-134.sh` planting four defects — a
mutated sha, a stale-screenshot row, an unknown `method` word, an empty manifest — each fixture
asserting its own substitution landed (S127) and the suite going RED on each (S122).

rec 16 — Re-derive the LOCKED list from `chitra/packages/core/README.md`, and record that chitra's
own two sources disagree — then drop the phrase "the six". The README declares FOUR LOCKED
sections: circular (pie/donut) S09 at line 110, area S09 at line 132, line S10 at line 151, bar S12
at line 188. The brief's list omits area entirely, and asserts `horizontalBar` as part of the S12
bar lock — the README's bar section never names `horizontalBar`. Meanwhile `chitra/.ai/STATE.md:22`
says "LOCKED families: circular (S09), line (S10), bar (S12)", agreeing with the brief and
disagreeing with the README. Criterion 2 should therefore be read as "record any disagreement with
the list above AND between chitra's own README and STATE.md". Consequently the merged set is
plausibly 5 charts (pie, donut, area, line, bar) plus 2 in flight = 7, not 6 — so "the weakest chart
of the six" in the Deliverables and criterion 4 is a pre-baked number that contradicts criterion 2's
own instruction. Replace it with "the weakest chart of the set you re-derived".

rec 17 — Correct the brief's "how to SEE them" section: chitra has NO per-chart demo scripts.
`chitra/scripts/` contains per-SESSION scripts (`demo-session-01..15.sh`,
`verify-session-01..15.sh`), plus `qa-catalog.mjs`, `post-merge.sh`, `ring-polish-handoff.mjs` and
`verify-closeout.sh`. There is no per-chart demo script. The real per-chart surfaces are: the Vite
docs app at `artifacts/chitra-docs` with its `/chart/:id` route
(`pnpm --filter @workspace/chitra-docs run dev`), and `check:catalog` — which is a docs-package
script (`artifacts/chitra-docs/package.json:13`), not a root script; root `package.json` only has
`build`, `typecheck`, `typecheck:libs`. Fix the brief before step 5, or the first ten minutes of a
paid run get spent discovering this.

rec 18 — Capture every Vajra gate invocation's raw stdout AND exit code into
`sessions/session-134-artifacts/gate-log/`, and have `verify-session-134.sh` bind criterion 8 to
those files. Otherwise criterion 8 ("every gate that fired is recorded with what it did and whether
it was right") is pure self-assertion by the agent being audited — the S54/S118 fidelity failure
reproduced on the instrument that exists to catch it. One file per invocation, named for the flag,
with the exit code on its first line.

rec 19 — Harden criterion 6 beyond `git status --short`, and scope its "diff" so the review artifact
does not break it by construction. As written, criterion 6 is both too weak and self-contradicting.
Too weak: `git status --short` misses a moved branch head, a new stash, and a staged-then-unstaged
shuffle. Borrow the S123 technique — record `git rev-parse HEAD`, `git ls-files -s | shasum -a 256`,
`git stash list`, and `git status --porcelain --untracked-files=all` before and after; all four must
match. Self-contradicting: the Deliverables ask you to land a review file inside chitra, which makes
the before/after untracked diff non-empty by construction. Resolve it explicitly — the permitted
delta is exactly one new untracked path, declared by name in advance (rec 7); every other difference
fails.

rec 20 — Pre-commit to how the receipt will be reported, before the run, so an unknown cost cannot
become a footnote. Predict the shape now: `vajra meter` reads the on-disk Claude Code transcript,
and `total_cost_usd` only rides the headless `-p` result stream (S77/S78 root cause). This run must
be interactive — you cannot look at charts headlessly, and chitra's L3 commit path needs a
conversational approval token. So the honest-null path from S77 is the likely outcome, not the
exception, and criterion 7 already permits it. Separately: report the unmetered subagent token count
beside whatever dollar figure appears. S132 recorded ~367k and S133 ~550k unmetered subagent tokens
against "$0 metered for build". A dogfood headline of "$X" that omits three Vajra-side dispatches
understates reality exactly the way the last two sessions did, and the cost of this session is the
number the pitch rests on.

rec 21 — Add an acceptance criterion for the two open design questions; right now the brief's
most-emphasised deliverable is UNGATED. Plan steps 1 and 2 both carry `covers: 9`, but criterion 9
is about the mandate's outcome, not about resolving Q1 and Q2. No criterion in the list says "the
chitra-session-number question and the roadmap-item question are decided, with the loser's reason
recorded." As the brief stands, S134 can close green having answered neither. Either add criterion
13, or widen criterion 9 to name both. Note the Architect gate will not catch this: with
`design-significant: yes` it only requires a non-placeholder `## Design` citing a record that
exists — it never checks that the design answers the questions the prompt posed.

rec 22 — Pre-commit to two honesty floors for the verdict itself, so "impressive" is falsifiable.
(a) A zero must be a searched-for zero: if the review finds no chart violating its family's locked
rules, it must quote which specific README rules it checked against which render — the README states
them literally (accent spent once, no rainbow, dashed frame, `+` tick rows, empty cells are spaces,
per-series MIN/MAX/AVG/LAST). (b) The Non-goal holds even when a fix looks like one line: any fix
goes into the review artifact as a proposal, ranked, and nothing in `chitra/packages/` is touched.
The brief's own guardrail says it; the risk is that a reviewer who can see the defect will reach
for it.

## Where the brief is internally inconsistent or unachievable

- "scripts/ in chitra has per-chart demo scripts" — false (rec 17).
- "LOCKED families, merged: circular, line, bar" — omits `area`, which the README locks at S09; and
  `horizontalBar` is asserted into the bar lock without README support. chitra's README and
  STATE.md disagree with each other (rec 16).
- "the weakest chart of the six" — a pre-baked count that criterion 2 forbids trusting; the live
  sources give 5+2 (rec 16).
- "This session is governed by it in BOTH repos" (criterion 9 / Deliverables) — not achievable:
  chitra has no `design-advisor` agent file, and session 16 is below the mandate's threshold of 133
  (rec 10, rec 11).
- Deliverable "landed in chitra as sessions/..." vs criterion 6's before/after diff — mutually
  exclusive unless the permitted delta is declared (rec 19).
- The two open design questions are unlisted in Acceptance (rec 21).
- `DECISION-005` is SUPERSEDED and the brief tells you to cite it without saying so; the gate will
  not notice (rec 3).

## Proposed `## Design` rationale for the author to record

- `design-significant: yes` — this session defines the first evidence contract for a Vajra gate
  binding to artifacts produced in a second repository, and every future dogfood will copy its
  shape; it also re-reads a locked roadmap item.
- Cites `DECISION-007`, specifically its S133 addendum section 6 (migration threshold 133, governing
  silence only) — the clause this run is the first outside test of — and `DECISION-005` (SUPERSEDED
  2026-07-27 by the S103 pivot; its machinery-freeze rule and ladder-as-paid-sessions plan are
  retired, its Rung-2 row naming chitra as the ladder repo is live and is why chitra).
- Deviation, declared: this is an attended ~2h single-task run, NOT a Rung-2 ladder run, and
  `DECISION-005`'s guards-ON clause holds only inside chitra (L3, guards armed), not in the Vajra
  repo (`publish_guard: off`, `commit_guard: off`).
- Q1 resolved — read-only pass, no chitra session number. chitra's `.ai/SESSION` is 15, its S16
  prompt and branch are in flight with uncommitted work, and at L3 a real session number would
  demand commits, a review, a summary and a PR on that branch — which acceptance 6 forbids.
  Rejected: taking chitra session 17. It would have bought a real `K of 8` reading and a chitra
  ledger entry, and it loses only because the counter is occupied and an abandoned session leaves
  `.ai/SESSION`, `TASK.md` and `STATE.md` permanently wrong. The read-only derivations recover most
  of that evidence at zero cost.
- Q2 resolved — the roadmap's dogfood item splits. D1 (governed real work in an existing
  Vajra-governed repo) is satisfied here; D2 (fresh-scaffold first contact) is not, and still needs
  its own paid session, because chitra runs the old 55-line scaffold with 4 of 9 roles and 7 of 12
  audits. Rejected: declaring the single item satisfied — it would retire the only instrument aimed
  at strangers on the strength of a run that structurally cannot exercise the mandate (threshold 133
  is greater than chitra's 16).
- New record owed: an S134 addendum to `DECISION-007` recording the brownfield threshold hole — not
  a new DECISION-008, on n=1.

## Handoff Delta
- `+` new: first design-advisor handoff for this session (22290 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
