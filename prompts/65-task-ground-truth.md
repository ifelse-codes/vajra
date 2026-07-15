# Session 65 — Ground Truth (mandatory NO-CODE, every 5th; last = S60)

> **Status:** APPROVED (founder standing "all approved"). **Type is FIXED: NO-CODE ground-truth.** No
> source-code edits, no commits to `src/`/scripts, no PRs (hook-enforced; a `session-65-closeout` /
> `-enforcement` branch is the only code-exempt path, for authorized hardening). Lead lens = **A** (below);
> founder may re-aim to B or C in this chat with one line — but **all 8 `required_audits` run in full
> regardless of lens** (the lens is the lead question, not a scope cut).

## Goal
Run the mandatory 5th-session ground-truth over the S61→S64 payload arc: answer all 8 audits, judge
whether the pipeline is advancing on the shortest path and whether the Planner's coverage is an honest
floor, and hand the founder exactly 3 ranked S66 CODE candidates. No code.

## Why this session
`NN % 5 == 0` → mandatory audit. Catch **both** classes of drift (CONSTRAINTS `drift_axes`):
1. **Direction drift** — are we building the right thing? (`vision_alignment`, `roadmap_alignment`)
2. **Discipline drift** — did we honor the contract, and does the contract still serve the vision?
   (`state_drift`, `knowledge_staleness`, `constraint_violation_review`, `constitution_review`,
   `cost_review`, `dogfood_check`)
**Meta-check:** did this audit's own mechanism miss a kind of drift? (The trap S20 caught.)

## Lead lens — A: is the pipeline advancing, and is the Planner's honesty holding?
The S60-GT course-correction ("payload over gate-hardening — advance the pipeline") drove S61→S64:
Analyst completed (S61 Generate+Delta · S62 Intake+Options), the loop measured (S63 paid dogfood),
the **Planner shipped (S64)** — station one → two. Interrogate honestly:
- Is **one station per session** the right cadence, or is the pipeline still too short to pitch as a
  "governed multi-agent SDLC pipeline" (DECISION-001)? What is the minimum station count that earns the name?
- The Planner's coverage is a **self-asserted digit-tag** (author types `covers: N`, gate does not check
  the step relates to the criterion — S64's named fakest green). Is that honest floor *good enough*, or a
  gate gap that undercuts the pitch?
- **Two credibility 🔴/🟡 debts sit un-fixed** (the receipt ~4.7× overstatement; the compression 0-fold
  no-op). Governance credibility is the product — are these now blocking, or still deferrable behind breadth?

## The audits (run every one — answer its question list in CONSTRAINTS `#ground_truth`)
- `vision_alignment` · `roadmap_alignment` — is the north-star still right; is the next item highest-leverage?
- `state_drift` — does `.ai/STATE.md` match reality after S64 (Planner shipped; two stations)?
- `knowledge_staleness` — KNOWLEDGE.md was flagged **large/bloated** at S60 (compression candidate) — is it
  stale, and did S61→S64 add to the bloat? Decide compress-or-leave (no hand-copied second store).
- `constraint_violation_review` · `constitution_review` — any rule now blocking the vision? (meta-check)
- `cost_review` + **`dogfood_check`:** S63 refreshed it 🟢 (paid run, $1.27). Is it still fresh after S64
  (~$0 CODE), or aging again? Per the dogfood questions, do not guess an "experience" verdict without a run.

## Acceptance (what must be answered — testable)
1. **WHEN** the GT runs **THEN** all 8 `required_audits` are answered with a per-audit 🟢/🟡/🔴 + the
   meta-check, written to `sessions/session-65-ground-truth.md` (a non-author can read the verdict table).
2. **WHEN** the audits complete **THEN** the report states a verdict on lead lens A (pipeline cadence +
   Planner-honesty) and lists **exactly 3 ranked S66 CODE candidates** (A/B/C, each with why + risk).
3. **The honest read is measured, not guessed** — the `dogfood_check` and the pipeline-payload status
   (stations built · ACCEPT'd · sessions-since-a-paid-run) are stated from the ledger/cost evidence.

## Plan (ordered steps — cite the acceptance criteria each step covers, e.g. `covers: 1, 3`)
1. Run all 8 `required_audits` + the meta-check, recording a 🟢/🟡/🔴 per audit and the evidence
   (SESSION, tests, ledger head, cost ledger) into the GT report. covers: 1, 3
2. Read the dogfood/cost + pipeline-payload evidence directly (ledger + STATE cost section) and state the
   measured status — no guessed "experience" verdict. covers: 3
3. Write the lens-A verdict and exactly 3 ranked S66 CODE candidates (A/B/C, why + risk); founder signs
   off before code resumes. covers: 1, 2

## Guardrails
- **NO CODE.** No `src/`/scripts edits, no commits outside a `-closeout`/`-enforcement` branch, no PRs.
- Own the `.ai/` spine — no second store, no unapproved 8th command. Darshan every human reply · Varta live.
- The lens is the lead question, not a scope cut — every audit runs in full.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` A fifth ground-truth (S65) auditing the S61→S64 payload arc (Analyst complete · loop measured · Planner shipped).
- `~` Shifts the lead question from S60's "is gate-work the shortest path?" to "is the pipeline long enough,
  and is the Planner's digit-tag coverage an honest-enough floor?".
- `-` Retires the S60-GT open worry that the gate arc outran the pipeline — three payload sessions have since landed.

## Deliverable
- `sessions/session-65-ground-truth.md` — every audit answered, the meta-check, a verdict on lens A, and
  **3 ranked S66 CODE candidates** (standing: the Architect stage [pipeline station 3] · make the receipt
  authoritative · fix/retire the compression no-op · strengthen Planner coverage beyond a digit-tag).
- **No** `verify-session-65.sh` / demo (NO-CODE). Closeout still runs `scripts/verify-closeout.sh` (exit 0).
