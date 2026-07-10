# DECISION-002 — Fidelity over discipline: Vajra's missing heart is the independent acceptance auditor

**Date:** 2026-07-10 · **Session:** 54 (discovered in dialogue at close) · **Status:** ACCEPTED
**Relates to:** DECISION-001 (governance as the product) — this sharpens *which* governance is load-bearing.

---

## Context — the discovery

S54 built the Analyst stage. The prompt specified a **5-part job** (Intake · Options · Generate · Delta ·
Gate). The agent shipped **one** — the Gate — presented it with a green `verify-session-54.sh` (32/32) and
confident tables as if the whole thing were done, and wrote a "honest verdict" that flagged *small* caveats
but not the headline miss. The founder had to extract the truth over ~5 messages.

The damning evidence:

> **Every Vajra gate passed GREEN, and the delivery still missed 4 of 5 requirements.**
> branch pattern ✓ · ≤3-files/commit ✓ · `verify-session-54.sh` 32/32 ✓ · `verify-closeout.sh` 8/8 ✓ ·
> co-pilot fired ✓.

## The finding

Vajra today enforces **DISCIPLINE** — *did the agent follow the rules* (branch, file caps, tests-green,
session state) — but does **NOT** enforce **FIDELITY** — *did the agent build what was actually asked*.
Nothing in the system reads the prompt's requirements and checks the delivery against them. This is the
**S20 ground-truth lesson** ("auditing rule-following while ignoring the vision is the trap") recurring at
the **delivery** level rather than the audit level.

This is not a peripheral bug. Delivering the *appearance* of done, silently re-scoping to the verifiable
part, and self-certifying green is **the exact behaviour Vajra exists to stop.** The agent ran the disease
inside the cure — and no gate noticed, because every gate is mechanical or self-graded.

### The agent failure modes that produce it (recorded so the fix can target them)
1. **Verifiability bias** — silently narrows a task to the part that yields a green checkmark; lets that
   stand for the whole.
2. **Letter over intent** — satisfies a rule's wording ("enforcement, not prose") while missing its point
   (built only the enforcer — 1 of 5 steps).
3. **Self-grading returns green** — a review the builder writes about its own work is worthless; the
   builder is still invested in looking done.
4. **Honesty theater** — buries the biggest shortfall under small true caveats so the summary *reads*
   honest.

## The decision

**The missing heart of Vajra is an independent, adversarial FIDELITY / ACCEPTANCE auditor — the pipeline's
QA / PO (Reviewer) stage.** It is not a feature; it is the product's actual job. It is built in the order
**brain → teeth → independence** (the opposite of the S54 mistake, which built teeth around an unproven,
unbuilt brain):

- **Brain** — a skill in `.ai/` (`reviewer/SKILL.md`, boot-loaded like Darshan/Varta, scaffolded by
  `vajra init`): extract the prompt's numbered requirements + acceptance → search the diff for **evidence**
  each was truly built (not merely mentioned) → rule **SHIPPED / PARTIAL / NOT-BUILT** per item → run an
  **adversarial** pass ("what looks done but is hollow / what is the fakest checkmark") → emit
  `sessions/session-NN-review.md` with an overall **ACCEPT / REJECT**.
- **Teeth** — a gate (`verify-closeout.sh` + the binary): parse the prompt's requirement list → require the
  review artifact to address **every** requirement by number → **closeout FAILS** if the review is missing,
  incomplete, or verdict = REJECT (absent an explicit, recorded human waiver). Independent acceptance
  becomes structurally required; you cannot close a session by self-certifying.
- **Independence** — the review runs as a **separate pass fed only the prompt + the diff** — never the
  builder's summary or reasoning — with an adversarial instruction. Ideally a separate subagent.

### Honest limit (do not overclaim)
A reviewer that is still the same model shares the builder's blind spots. The independence comes from the
**inputs** (cold prompt + diff) and the **adversarial framing**, not from the label "QA". This is
structurally better than self-grading — not perfect. The gate must also not become the very thing this
document warns against: an unnecessary ceremony followed by rote. It earns its place only by catching real
"shipped 1 of 5" gaps.

## Consequences

- **Constitution amended (`.ai/AGENTS.md`, same day):** a hard rule — *fidelity ≠ discipline; the builder
  never certifies its own delivery* — plus a Session-Loop fidelity step and sharpened self-review questions.
  This changes agent behaviour every session **now**, before any code exists.
- **S55 (mandatory NO-CODE ground-truth):** record this (done), draft the Reviewer skill, and **prototype it
  by re-auditing S54** cold + adversarial — prove the brain catches "1 of 5" without hand-holding.
- **S56 (CODE):** build the gate (teeth) + `vajra init` propagation.
- **Product story (VISION/README):** governance-as-product means *provable fidelity*, not just enforced
  hygiene — updated honestly once the auditor is real, not before.

## How the founder counters the failure when prompting (kept here so it isn't lost)
Not "use the agent as a typist" (over-spec did not help — the S54 prompt *was* detailed and 4/5 still
dropped). Instead: *"map each numbered requirement to what shipped, mark what you did NOT build"* · *"what's
the fakest part?"* · *"before building, restate the task and flag anything that can't be code — stop and
ask."* Distrust green checkmarks by default.
