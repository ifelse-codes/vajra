# Session 100 — Ground Truth (mandatory NO-CODE, every 5th)

> **Status:** APPROVED (mandatory — `100 % 5 == 0`; last GT = S95). Founder: "start session 100, all approved."
> **Note on provenance:** this prompt was written at the START of S100, not at S99's closeout.
> `end_of_session.must_write_next_prompt_before_close: true` was not honored at S99 close, and no
> closeout check enforces it. That miss is itself an audit subject below (`constraint_violation_review`).

## Goal

Run the full mandatory ground-truth audit for **S96–S99**. No source-code changes, no commits to
non-exempt branches, no PRs. Output: `sessions/session-100-ground-truth.md`. Founder signs off
before code resumes.

## Why this session

`100 % 5 == 0` — hard rule, hook-enforced. Since S95 the repo repositioned (S98, `DECISION-005`:
autopilot trust layer, falsifiable Autopilot Ladder, **machinery-freeze rule**) and ran its first
ladder rung (S97, paid, $1.2758). S95 found the pipeline unadvanced since S72, the Coder station dark
4-for-4, and a **4th consecutive easy-green GT**. S98 wrote a rule intended to kill that gradient by
construction. **S100 is the first GT that can test whether the rule worked.**

Sessions under audit:

| Session | Type | Headline |
|---|---|---|
| S96 | CODE | rustfmt-1.9.0 drift fix; CI green both OS (#97) |
| S97 | DOGFOOD (paid) | Ladder Rung 1 on chitra — $1.2758 authoritative; `--stations 08` = 2/8; Coder doubly-blocked |
| S98 | CODE (docs) | Autopilot-trust reposition (`DECISION-005`) + 2 closeout-hardening follow-ups (#100/#101) |
| S99 | CODE | Coder reachable unattended (the sanctioned fix-what-broke); two-pass REJECT→ACCEPT |

## Scope

**NO-CODE:** no `src/` edits, no commits except the closeout bundle on the exempt
`session-100-closeout` branch, no PRs. `VAJRA_CLOSEOUT_WAIVER=100` (a GT session records no
`## Execution` shas and produces no verify/demo scripts).

## Audits Required (all 10, per `CONSTRAINTS.yaml#ground_truth.required_audits`)

| Audit | Key question |
|---|---|
| `vision_alignment` | Is the autopilot-trust north-star still right? Is current work the shortest path to it? |
| `roadmap_alignment` | Does the 6-Month Autopilot Plan still map to it? Is Rung 2 the highest-leverage next item? |
| `state_drift` | Does `.ai/STATE.md` — **and `ROADMAP.md`, `VISION.md`, `vajra.varta`** — reflect the repo today? |
| `knowledge_staleness` | Is `KNOWLEDGE.md` current? Is §6 bloat (flagged S60) still growing? |
| `constraint_violation_review` | Any hard rule violated in S96–S99? Any rule now blocking the vision? |
| `constitution_review` | Is `AGENTS.md` still serving the vision? Any clause creating perverse incentives? |
| `cost_review` | Is spend tracked accurately and authoritatively? Any unknown-cost session? |
| `dogfood_check` | Has real work run through `vajra claude` since S95? (S97 did — $1.2758.) |
| `dogfood_staleness` | Run `vajra next --dogfood-age`. Does the live query agree with the docs? |
| `pipeline_advance_check` | `vajra next --stations NN` for S96–S99. Advancing, or machinery growing while payload stalls? |

## Lead Lens (fixed by S98/S99)

**"Is the autopilot ladder being climbed, or did machinery resume?"**

The machinery-freeze rule (`DECISION-005`) says a session either **runs the ladder** or **fixes what a
run broke** — nothing else. It is **convention-enforced only** (no code gate), disclosed as S98's
fakest green. S99 claims the "fix what a run broke" exemption. Judge it on evidence:

1. Was S99 genuinely a fix-what-broke, or the exemption used as a doorway back to machinery?
2. How many sessions has the rule actually been tested on? State the sample size honestly.
3. **Meta-check (mandatory):** does this audit's own mechanism have a blind spot? Specifically —
   the two instruments this GT relies on (`--stations` K-of-8 and the attested fidelity ledger) were
   both built for CODE sessions. Run them against the DOGFOOD and GT sessions and report what they say.

## Acceptance Criteria

1. All 10 audits run, each with an explicit 🟢/🟡/🔴 verdict and **evidence** (command output, file
   line, commit sha) — never a narrative claim.
2. `--stations` recorded for S96, S97, S98, S99; the SHAPE read, not just the number.
3. `vajra next --dogfood-age` recorded live and reconciled against **every** doc that states it.
4. A headline verdict on the lead lens, with the freeze rule's sample size stated plainly.
5. The meta-check answered — name the blind spot this audit's own mechanism has, or state there is none
   and why.
6. Every drift found is **listed with its correction**; corrections applied to `.ai/` at closeout.
7. Exactly 3 ranked candidates for S101, each: title · one-sentence goal · why-pick-this · key risk.

## Guardrails

- **NO-CODE.** No `src/`, no `scripts/` logic edits. Doc/`.ai/` corrections only, at closeout.
- Max 3 files per commit. Commits carry `VAJRA_ALLOW_COMMIT=100`.
- Findings must be falsifiable — every 🔴/🟡 cites evidence a stranger could re-derive.
- Do not soften a finding because the fix is inconvenient; do not invent one to look thorough.
