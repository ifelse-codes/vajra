# Session 55 — ground-truth: prove the fidelity auditor (Vajra's missing heart) by re-auditing S54

> **Status:** APPROVED — reshaped at S54 close after the founder-led discovery (DECISION-002): Vajra
> enforces discipline but not fidelity. This is the mandatory every-5th ground-truth *and* the first
> prototype of the fix. Recorded here as the gate's sign-off; tamper-evidence is the later ledger.

## Type
- **NO-CODE ground truth** (mandatory every 5th; last GT = S50). No `src/` edits, no commits, no PRs.
  Max 2 assumptions · ~2h · 1 story · new chat. Closeout on an exempt `-closeout` branch.

## Goal
Prove — by hand, before any code — that an **independent, adversarial fidelity auditor** (the pipeline's
QA/PO/Reviewer stage) can catch what every green Vajra gate missed in S54: **the agent shipped 1 of the
prompt's 5 requirements and self-certified.** If the *brain* of this auditor works when run cold, S56 is
justified in building the *teeth* (the closeout gate). If it does not, we learned that before writing code.

## Deliverables
- `sessions/session-55-ground-truth.md` — all 8 `required_audits` (vision · roadmap · state · knowledge ·
  constraints · constitution · cost · dogfood) + the meta-check, each with a 🟢/🟡/🔴 verdict.
- **`sessions/session-55-review.md`** — the fidelity-auditor PROTOTYPE: re-audit **S54** against
  `prompts/54-task-analyst-stage.md`, mapping **every** numbered requirement to `SHIPPED / PARTIAL /
  NOT-BUILT` + evidence from the git diff, + the "fakest green" callout + overall ACCEPT/REJECT. Run it as a
  **separate cold pass** (fed only the prompt + the diff, adversarial framing — ideally a subagent).
- **`reviewer/SKILL.md`** (draft) — the brain: how to run that audit repeatably (the S56 code will enforce
  its artifact, not replace it). Boot-loaded like Darshan/Varta; propagated by `vajra init` later.
- `scripts/verify-session-55.sh` (exits 0) — presence/consistency checks only (NO-CODE).
- Exactly **3 ranked candidates for S56**; **top = build the fidelity-audit GATE (teeth) + `vajra init`
  propagation** (DECISION-002).

## Acceptance (what must be answered — testable, EARS-style)
1. WHEN the cold fidelity pass re-audits S54 THEN it independently reports "≈1 of 5 requirements shipped"
   **without** being told the answer — i.e. the brain catches the gap on its own, or we record that it can't.
2. A non-author can read `session-55-review.md` and see, per S54 requirement, the verdict + the diff evidence.
3. Honest verdict stated plainly: is the pipeline still the right north-star; is the fidelity auditor the
   real missing heart (not scope-creep); and did the constitution amendment (DECISION-002) actually change
   behaviour this session, or is it still prose?

## Guardrails
- NO-CODE — hooks enforce; audit + draft-docs only. Own the `.ai/` spine — no second store, no 8th command.
- Darshan every human reply · Varta against the live `.ai/`.
- **Eat the dog food:** run THIS session's own summary through the fidelity check (map every requirement
  above to what shipped). If S55 itself ships 1 of N and self-certifies, the auditor has already failed.
- Do NOT build the gate code here (that is S56 — teeth after the brain is proven; building teeth first was
  the S54 mistake).

## Delta (vs ROADMAP — OpenSpec markers)
- `+` The fidelity/acceptance auditor (QA/PO stage) — brain drafted + prototyped; DECISION-002 recorded.
- `~` Reframes the every-5th ground-truth from a generic audit into a fidelity-first audit; sharpens the
  pipeline's #1 from "next stage" to "the acceptance stage that makes governance *provable*, not just green".
- `-` Retires the assumption that green verify/closeout gates evidence a faithful delivery (S54 disproved it).
