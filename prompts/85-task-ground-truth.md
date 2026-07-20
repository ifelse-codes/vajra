# Session 85 — Ground Truth (mandatory NO-CODE, every 5th; last = S80)

> **Status:** APPROVED (founder standing "all approved"; the 5th-session GT is mandatory —
> `NN % 5 == 0`). **Type is FIXED: NO-CODE ground-truth.** No source-code edits, no commits to
> `src/`/scripts, no PRs (hook-enforced; a `session-85-closeout`/`-enforcement` branch is the only
> code-exempt path, for authorized hardening). Lead lens = **A** (below); founder may re-aim to B
> or C in this chat with one line — but **all 9 `required_audits` run in full regardless of lens**
> (the lens is the lead question, not a scope cut).

## Goal
Run the mandatory 5th-session ground-truth over the S81→S84 arc (execution-sha closeout guard ·
Releaser ledger fallback · read-only-headless UX warning · typed `CannotEvaluate`). Answer all 9
audits, judge whether four consecutive hardening/UX sessions was the shortest path to the
north-star or a repeat of the S80-flagged "easy-green detour" pattern one level up, and hand the
founder exactly 3 ranked S86 CODE candidates. No code.

## Why this session
`NN % 5 == 0` → mandatory audit. Catch **both** classes of drift (CONSTRAINTS `drift_axes`):
1. **Direction drift** — are we building the right thing? (`vision_alignment`, `roadmap_alignment`)
2. **Discipline drift** — did we honor the contract, and does the contract still serve the vision?
   (`state_drift`, `knowledge_staleness`, `constraint_violation_review`, `constitution_review`,
   `cost_review`, `dogfood_check`, `pipeline_advance_check`)
**Meta-check:** did this audit's own mechanism miss a kind of drift? S80 found the S76→S79 receipt
arc had defaulted to easy-green rate corrections while `--stations`' other dimensions sat unread.
Check whether S81→S84 repeats that shape: four sessions of gate-hardening / UX-polish, zero new
governed stations, while dogfood aged untouched since S76.

## Lead lens — A: four sessions hardened existing gates. Did the pipeline advance, or did we default to easy-green again?
S81 added a closeout guard, S82 fixed a station-counter read, S83 added a UX warning, S84 typed an
error signal — each small, bounded, ≤3 files, ~$0 spend, clean green verify. Interrogate honestly:
- **Run `vajra next --stations NN` for S80→S84** and read the shape. Did any session add a NEW
  governed station, or did all four touch existing gates/UX only? Is "each gate is now more
  correct" the highest-leverage use of 4 sessions, or the path of least resistance (the recurring
  S60/S80 "green-every-session incentive gradient" finding)?
- **Dogfood age — state it precisely, do not guess a satisfaction verdict.** The last paid
  `vajra claude` run was **S76** (2026-07-03). By S85 that is **9 sessions** (S77–S84) and
  **calendar days** since (compute from today's date vs 2026-07-03) with **zero** real product
  usage in between — every session since has been a $0 source/doc-only change. Is "dogfood DONE at
  S76" (the S70 founder decision) still a defensible read, or has it re-aged past the point where
  any claim about "is Vajra-on-Claude satisfying" can be made without guessing?
- **The hardening arc's own honesty:** S82 and S84 both *disclosed* a related, unfixed finding —
  the attestation check (`session_attested_accept`/`reviewer_status`) is a bare substring match,
  not a recomputed hash, and it is now load-bearing for 2 stations across 3 consecutive sessions'
  worth of disclosure (S82, carried through S83, re-disclosed S84) without being fixed. Is
  "disclosed, not hidden" still sufficient at 3 sessions of standing, or has it crossed into a
  debt that should have out-ranked at least one of the smaller UX/typing fixes?

## The audits (run every one — answer its question list in CONSTRAINTS `#ground_truth`)
- `vision_alignment` · `roadmap_alignment` — is the north-star still right; after 4 hardening
  sessions, is the highest-leverage S86 work depth/dogfood, or something `--stations` surfaces?
- `state_drift` — does `.ai/STATE.md` match reality after S84 (the typed-`CannotEvaluate` fix, the
  S84 PR, the `--stations` reading since S80)?
- `knowledge_staleness` — §6 changelog length (flagged S60, unresolved since); is the
  readable-roadmap one-pager (carried since ~S69, S84's candidate C) now overdue?
- `constraint_violation_review` · `constitution_review` — any rule now blocking the vision? (meta-
  check: did "one story per session" bias 4 straight sessions toward small, certain, easy-green
  fixes over the larger standing debts — the S76 sha fix, the attestation hardening?)
- `cost_review` + `dogfood_check` — cost ledger honest? State dogfood's age precisely (sessions +
  calendar time since S76) — do not guess a satisfaction verdict without a fresh paid run.
- **`pipeline_advance_check` — the headline.** Read `--stations` across S80→S84; state plainly
  whether the pipeline advanced (a new station, a materially hardened gate) or whether 4 sessions
  polished existing gates while the counter's station-count shape stayed flat.

## Acceptance (testable — every criterion is cited by a `## Plan` step below)
1. **WHEN** the GT runs **THEN** all 9 `required_audits` are answered with a per-audit 🟢/🟡/🔴 +
   the meta-check, written to `sessions/session-85-ground-truth.md` (a non-author can read the
   verdict table).
2. **WHEN** the audits complete **THEN** the report states a verdict on lead lens A (did 4
   hardening sessions advance the pipeline, or was it an easy-green detour?) and lists **exactly 3
   ranked S86 CODE candidates** (A/B/C, each with why + risk).
3. **The headline read is measured, not guessed** — the `pipeline_advance_check` cites the actual
   `vajra next --stations NN` output for S80–S84, and `dogfood_check` states dogfood's exact age
   (sessions + calendar days since S76, computed against today's real date) — never estimated.

## Design (the Architect gate — recorded rationale)
- design-significant: no — NO-CODE ground-truth: audits + a report, no interface, module, or
  behavior change.

## Plan (ordered steps — cite the acceptance criteria each step covers)
1. Run all 9 `required_audits` + the meta-check, recording a 🟢/🟡/🔴 per audit and the evidence
   (SESSION, tests, ledger head, cost ledger, verify runs) into the GT report. covers: 1, 3
2. Run `vajra next --stations NN` across S80→S84, read the shape, and write the
   `pipeline_advance_check` verdict from that output — the headline, measured. covers: 3
3. Write the lens-A verdict and exactly 3 ranked S86 CODE candidates (A/B/C, why + risk); founder
   signs off before code resumes. covers: 1, 2

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>

## Guardrails
- **NO CODE.** No `src/`/scripts edits, no commits outside a `-closeout`/`-enforcement` branch,
  no PRs. (The QA + Demo-er gates will WARN at S85's close — no `verify-session-85.sh` / demo by
  design; that firing is itself evidence the NO-CODE path behaves as specified.)
- Own the `.ai/` spine — no second store, no unapproved 8th command. Darshan every human reply ·
  Varta live.
- The lens is the lead question, not a scope cut — every audit runs in full.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` A ninth ground-truth (S85) auditing the S81→S84 hardening/UX arc, with a fresh
  `pipeline_advance_check` reading and an explicit, precise re-check of dogfood's age.
- `~` Shifts the lead question from S80's "did 4 receipt sessions advance the pipeline?" to "did 4
  gate-hardening/UX sessions advance the pipeline, or default to the easiest green again?"
- `-` Retires (or reconfirms, if evidence disagrees) any implicit claim that "disclosed, not
  hidden" is sufficient cover for the attestation-substring finding now that it has stood for 3
  consecutive sessions (S82→S84) without being picked.

## Deliverable
- `sessions/session-85-ground-truth.md` — every audit answered, the meta-check, a verdict on lens
  A, and **3 ranked S86 CODE candidates** (standing per S84's summary: A the S76 sha retroactive
  fix · B harden the attestation check · C the readable-roadmap one-pager — the GT ranks with
  fresh evidence, not just carries these forward).
- **No** `verify-session-85.sh` / demo (NO-CODE). Closeout still runs `scripts/verify-closeout.sh`
  (exit 0).
