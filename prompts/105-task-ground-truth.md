# Session 105 — Ground Truth (mandatory NO-CODE, every 5th)

> **Status:** APPROVED (mandatory — `105 % 5 == 0`; last GT = S100). Written at S104 closeout per
> `end_of_session.must_write_next_prompt_before_close`. Founder direction (S104 chat): after this
> GT the next BUILD target is **make it installable (B)** — the C→B→A order. This GT audits through
> the **MVP-shippability** lens the S103 pivot set.

## Goal

Run the full mandatory ground-truth audit for **S101–S104**. No source-code changes, no commits to
non-exempt branches, no PRs. Output: `sessions/session-105-ground-truth.md`. Founder signs off
before code resumes.

## Why this session

`105 % 5 == 0` — hard rule, hook-enforced. Since S100 the repo made a **founder pivot (S103):** stop
the paid multi-day Autopilot-Ladder *sessions* — sessions now = **finish a shippable MVP**; the
founder runs the long unattended test himself. S104 refaced the pipeline as a **team voice**. So the
machinery-freeze rule (`DECISION-005`) that framed the last two GTs is now **superseded**, and the
north-star question shifts from "is the ladder being climbed?" to **"is v0.1 actually shippable to a
stranger?"** S105 is the first GT under the pivot — it must judge the roadmap against that.

Sessions under audit:

| Session | Type | Headline |
|---|---|---|
| S101 | CODE | README truth-pass + crate name settled (`DECISION-006`) |
| S102 | DOGFOOD (paid) | Ladder Rung 2 burst — $0.4644 authoritative; quality gates passed |
| S103 | DOGFOOD (paid) | Rung 2 endurance + adversarial — $0.6797; FORCED commit block; **founder MVP pivot** |
| S104 | CODE | team voice over the 8 stations (roles + plain status); cold review ACCEPT |

## Scope

**NO-CODE:** no `src/` edits, no commits except the closeout bundle on the exempt
`session-105-closeout` branch, no PRs. `VAJRA_CLOSEOUT_WAIVER=105` (a GT session records no
`## Execution` shas and produces no verify/demo scripts).

## Audits Required (all 10, per `CONSTRAINTS.yaml#ground_truth.required_audits`)

| Audit | Key question |
|---|---|
| `vision_alignment` | Post-pivot, is the north-star still "provable governance"? Is "finish a shippable MVP" the shortest path? |
| `roadmap_alignment` | Does the roadmap point at **installable v0.1 (B)** next? Is that the highest-leverage item, or is the fleet (A) pulling scope early? |
| `state_drift` | Does `.ai/STATE.md` — and `ROADMAP.md`, `VISION.md`, `vajra.varta` — reflect the repo today (incl. the pivot + S104 team voice)? |
| `knowledge_staleness` | Is `KNOWLEDGE.md` current? Is §6 bloat (flagged since S60) still growing? |
| `constraint_violation_review` | Any hard rule violated in S101–S104? Any rule now blocking a shippable MVP? |
| `constitution_review` | Is `AGENTS.md` still serving the vision post-pivot? Does the machinery-freeze rule (`DECISION-005`) still apply, or is it dead letter now? |
| `cost_review` | Is spend tracked authoritatively? Reconcile S101–S104 (incl. the two paid dogfoods). |
| `dogfood_check` | Has real work run through `vajra claude` since S100? (S102 + S103 did — paid.) |
| `dogfood_staleness` | Run `vajra next --dogfood-age`. Does the live query agree with the docs? |
| `pipeline_advance_check` | `vajra next --stations NN` for S101–S104. Read the SHAPE. Is the pipeline advancing, or is the team-voice reface polish over a stalled payload? |

## Lead Lens (fixed by the S103 pivot)

**"Is v0.1 actually shippable to a stranger — and is the roadmap the shortest path there?"**

The pivot says sessions now finish the MVP and the founder owns the long real-world test. Judge:

1. **Shippability gap:** list what a stranger literally cannot yet do (install, quickstart, trust the
   receipt/governance) — the concrete gap between "works on my machine" and "release".
2. **Is the freeze rule dead?** `DECISION-005` said a session runs the ladder or fixes what a run
   broke. The pivot cancelled ladder sessions. State plainly whether the rule is now obsolete and
   should be retired/rewritten, or still governs.
3. **Meta-check (mandatory):** does this audit's own mechanism have a blind spot? Specifically — the
   `--stations` counter and the attested ledger measure *pipeline discipline*, not *installability*.
   Is there any instrument that measures "can a stranger ship with this"? If not, name that gap.

## Acceptance Criteria

1. All 10 audits run, each with an explicit 🟢/🟡/🔴 verdict and **evidence** (command output, file
   line, commit sha) — never a narrative claim.
2. `--stations` recorded for S101, S102, S103, S104; the SHAPE read, not just the number.
3. `vajra next --dogfood-age` recorded live and reconciled against **every** doc that states it.
4. A headline verdict on the lead lens, with the concrete stranger-shippability gap listed.
5. The meta-check answered — name the blind spot (is installability measured anywhere?), or state
   there is none and why.
6. Every drift found is **listed with its correction**; corrections applied to `.ai/` at closeout.
7. Exactly 3 ranked candidates for S106, each: title · one-sentence goal · why-pick-this · key risk.
   Expect **make it installable (B)** as the lead (founder's S104 pick).

## Guardrails

- **NO-CODE.** No `src/`, no `scripts/` logic edits. Doc/`.ai/` corrections only, at closeout.
- Max 3 files per commit. Commits carry `VAJRA_ALLOW_COMMIT=105`.
- Findings must be falsifiable — every 🔴/🟡 cites evidence a stranger could re-derive.
- Do not soften a finding because the fix is inconvenient; do not invent one to look thorough.
