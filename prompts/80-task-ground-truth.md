# Session 80 — Ground Truth (mandatory NO-CODE, every 5th; last = S75)

> **Status:** APPROVED (founder standing "all approved"; the 5th-session GT is mandatory —
> `NN % 5 == 0`). **Type is FIXED: NO-CODE ground-truth.** No source-code edits, no commits to
> `src/`/scripts, no PRs (hook-enforced; a `session-80-closeout` / `-enforcement` branch is the only
> code-exempt path, for authorized hardening). Lead lens = **A** (below); founder may re-aim to B or
> C in this chat with one line — but **all 9 `required_audits` run in full regardless of lens** (the
> lens is the lead question, not a scope cut).

## Goal
Run the mandatory 5th-session ground-truth over the S76→S79 arc (the paid dogfood ride-along ·
receipt truth · recover the true $ · re-price the stale opus rate). Answer all 9 audits, judge
whether four sessions closing the receipt-accuracy story was the shortest path to the north-star
or a comfortable, easy-green detour from the pipeline-payload question S60/S70/S75 kept raising, and
hand the founder exactly 3 ranked S81 CODE candidates. No code.

## Why this session
`NN % 5 == 0` → mandatory audit. Catch **both** classes of drift (CONSTRAINTS `drift_axes`):
1. **Direction drift** — are we building the right thing? (`vision_alignment`, `roadmap_alignment`)
2. **Discipline drift** — did we honor the contract, and does the contract still serve the vision?
   (`state_drift`, `knowledge_staleness`, `constraint_violation_review`, `constitution_review`,
   `cost_review`, `dogfood_check`, `pipeline_advance_check`)
**Meta-check:** did this audit's own mechanism miss a kind of drift? S75 found the gate arc had
outrun the pipeline it governs (lens-A PARTIAL SCOPE-CREEP) — check whether the S76→S79 receipt arc
repeats that pattern: four consecutive sessions on the SAME weak station (the receipt), zero on the
other 7, while `--stations` sat unread since S75.

## Lead lens — A: four sessions polished the receipt. Did the pipeline advance, or did we default to easy-green?
S76 measured the pipeline as lived experience and found the receipt the weak station; S77→S79 then
spent three more sessions fixing it (fable pricing → headless capture → opus re-pricing), each at
~$0 spend and a clean green gate. Interrogate honestly:
- **Run `vajra next --stations NN` for S75→S79** and read the shape. Did any session touch a station
  other than the receipt/meter? Is "the receipt is now fully correct" actually the highest-leverage
  use of 4 sessions, or did the low-risk/high-certainty nature of rate corrections make them the
  path of least resistance (the S60 "green-every-session incentive gradient" finding, recurring)?
- **Dogfood age:** S76 was itself the last paid `vajra claude` run. By S80 that is 4 sessions back
  (S77/S78/S79 were all $0). Is "dogfood DONE at S76" (S70 founder decision) still the right read,
  or has it quietly re-aged into the same 🟡→🔴 drift S60 and S75 both caught? State the age from the
  cost ledger, do not guess a satisfaction verdict.
- **The receipt arc's own honesty:** S79's summary/review disclose that legacy opus ids (4.0/4.1/4.5)
  keep an *unconfirmed* historical rate. Is that disclosure sufficient, or does "receipt arc fully
  closed" (as S79's carried language claims) overstate what was actually verified?

## The audits (run every one — answer its question list in CONSTRAINTS `#ground_truth`)
- `vision_alignment` · `roadmap_alignment` — is the north-star still right; after 4 receipt-focused
  sessions, is the highest-leverage S81 work depth/dogfood, or something `--stations` surfaces?
- `state_drift` — does `.ai/STATE.md` match reality after S79 (the receipt arc's final rate fix, the
  S79 PR, the `--stations` reading since S75)?
- `knowledge_staleness` — §6 changelog length (KNOWLEDGE.md, flagged at S60 and unresolved since);
  is the readable-roadmap one-pager (carried since S69, S79 candidate C) now overdue?
- `constraint_violation_review` · `constitution_review` — any rule now blocking the vision? (meta-
  check: did "one story per session" bias 4 straight sessions toward the same easy station?)
- `cost_review` + `dogfood_check` — cost ledger honest? State dogfood's age precisely (sessions +
  calendar time since S76) — do not guess a satisfaction verdict without a fresh paid run.
- **`pipeline_advance_check` — the headline.** Read `--stations` across S75→S79; state plainly
  whether the pipeline advanced (a new station, a hardened gate) or whether 4 sessions moved the
  SAME dial (receipt accuracy) while the counter's other 7 dimensions sat unread.

## Acceptance (testable — every criterion is cited by a `## Plan` step below)
1. **WHEN** the GT runs **THEN** all 9 `required_audits` are answered with a per-audit 🟢/🟡/🔴 +
   the meta-check, written to `sessions/session-80-ground-truth.md` (a non-author can read the
   verdict table).
2. **WHEN** the audits complete **THEN** the report states a verdict on lead lens A (did 4 receipt
   sessions advance the pipeline, or was it an easy-green detour?) and lists **exactly 3 ranked S81
   CODE candidates** (A/B/C, each with why + risk).
3. **The headline read is measured, not guessed** — the `pipeline_advance_check` cites the actual
   `vajra next --stations NN` output for S75→S79, and `dogfood_check` states dogfood's exact age
   (sessions + calendar days since S76) from the cost ledger — never estimated.

## Design (the Architect gate — recorded rationale)
- design-significant: no — NO-CODE ground-truth: audits + a report, no interface, module, or
  behavior change.

## Plan (ordered steps — cite the acceptance criteria each step covers)
1. Run all 9 `required_audits` + the meta-check, recording a 🟢/🟡/🔴 per audit and the evidence
   (SESSION, tests, ledger head, cost ledger, verify runs) into the GT report. covers: 1, 3
2. Run `vajra next --stations NN` across S75→S79, read the shape, and write the
   `pipeline_advance_check` verdict from that output — the headline, measured. covers: 3
3. Write the lens-A verdict and exactly 3 ranked S81 CODE candidates (A/B/C, why + risk); founder
   signs off before code resumes. covers: 1, 2

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>

## Guardrails
- **NO CODE.** No `src/`/scripts edits, no commits outside a `-closeout`/`-enforcement` branch,
  no PRs. (The QA + Demo-er gates will WARN at S80's close — no `verify-session-80.sh` / demo by
  design; that firing is itself evidence the NO-CODE path behaves as specified.)
- Own the `.ai/` spine — no second store, no unapproved 8th command. Darshan every human reply ·
  Varta live.
- The lens is the lead question, not a scope cut — every audit runs in full.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` An eighth ground-truth (S80) auditing the S76→S79 receipt-accuracy arc, with a fresh
  `pipeline_advance_check` reading and an explicit re-check of dogfood's age.
- `~` Shifts the lead question from S75's "did the gate arc outrun the pipeline?" to "did four
  receipt-accuracy sessions advance the pipeline, or default to the easiest green?"
- `-` Retires (or reconfirms, if evidence disagrees) the S79 closing claim that the receipt arc is
  "fully closed" — verify that claim independently rather than carrying it forward unaudited.

## Deliverable
- `sessions/session-80-ground-truth.md` — every audit answered, the meta-check, a verdict on lens A,
  and **3 ranked S81 CODE candidates** (standing per S79's summary: A `--stations` ship-evidence
  durability · B read-only-headless UX + typed `CannotEvaluate` · C readable-roadmap one-pager — the
  GT ranks with fresh evidence, not just carries these forward).
- **No** `verify-session-80.sh` / demo (NO-CODE). Closeout still runs `scripts/verify-closeout.sh`
  (exit 0).
