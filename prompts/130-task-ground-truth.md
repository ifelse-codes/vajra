# Session 130 — NO-CODE GROUND TRUTH (audits S126–S129)

> **Status:** MANDATORY (`130 % 5 == 0`). Must run before any S131 CODE work.
> **Founder directive in force (S118):** `README.md` / `VISION.md` claims are the **target spec**,
> not a status report. Do NOT soften them. **No release** until reality meets them.

## Type

**NO-CODE. Max 2 assumptions · 2 retries · 1 story · ~2h · new chat.**
No `src/` changes. No commits on this branch — the hook blocks them (`130 % 5 == 0`). Closeout
commits ride a `session-130-closeout` branch. Record findings in
`sessions/session-130-ground-truth.md` only.

## Why this session

Four sessions since the last GT (S125):

- **S126** — the fleet finished on paper: nine named roles, one per station, all proven dispatched.
- **S127** — the first gate that CONSUMES a governed handoff (Advice). Its own residual: four
  `obeyed:` labels in its 51-answer ledger were factually wrong and passed the gate.
- **S128** — first contact works. The first user-reachable change since S108, twenty sessions.
  `stranger_check` became a required audit — **the first instrument that measures the PRODUCT.**
- **S129** — one source for what a stranger gets. Three governance lists derived at build time;
  `scaffold_drift_check` became the twelfth required audit.

## THIS GT IS THE FIRST THAT MUST RUN THE TWO PRODUCT-FACING AUDITS

Both `stranger_check` (S128) and `scaffold_drift_check` (S129) are REGISTERED and have **never been
executed by a ground truth**. Both sessions named that as their standing residual. **This is the
session where "registered, not run" either stops being true or is proven to be a real gap.**

Run them LIVE, paste the tallies, and answer their question lists:

```
bash scripts/stranger-check.sh
bash scripts/scaffold-drift.sh
```

**What it costs when a gate is never run — measured, not hypothesised.** S129 ran
`vajra next --check-plan` at close and found it had been mis-parsing **every prompt** since the
heading `## Plan (ordered — cite the acceptance criteria each step covers)` was adopted: the
acceptance parser matched on `contains("acceptance")`, so plan steps were counted as criteria. The
**Planner station in `K of 8` had been reporting PASSED off that parser.** Treat every other
registered-but-unrun gate as suspect until you have run it.

## The two sharpened lenses this session

1. **Does the fleet do anything yet?** S126 finished nine roles; S127 made ONE gate consume ONE
   handoff. S128 and S129 both ran a `fidelity-reviewer` and nothing else — S129 dispatched no
   advisor at all before building, and its `## Advice` was empty until the review. **Is a fleet of
   nine where two sessions in a row reached for exactly one role a fleet, or a roster?** The
   founder's S125 gate was "done AND working." Answer it with evidence, not with the roster.
2. **Cold readers keep finding what the builder cannot.** In S129 alone, two independent read-only
   passes each found a hand-typed fork the builder had missed — `drift_axes` (pass 1) and the
   `TPL_CONSTRAINTS` family (pass 2), both **inside the blast radius of the fix**. Neither reader
   had a shell. **What does that say about where review effort should go**, and is the current
   one-cold-pass-at-close ritual the right shape, or should a cold read happen mid-build too?

## Required audits — all TWELVE

Run every audit in `CONSTRAINTS.yaml#ground_truth.required_audits`, answering its question list:

`vision_alignment` · `roadmap_alignment` · `state_drift` · `knowledge_staleness` ·
`constraint_violation_review` · `constitution_review` · `cost_review` · `dogfood_check` ·
`pipeline_advance_check` · `dogfood_staleness` · **`stranger_check`** · **`scaffold_drift_check`**

Live queries that must appear in the output with their real results:

```
vajra next --dogfood-age
vajra next --stations 126
vajra next --stations 127
vajra next --stations 128
vajra next --stations 129
```

**Meta-check, mandatory:** did this audit's own mechanism miss a kind of drift? Rules exist to serve
the vision — auditing rule-following while ignoring the vision is the exact trap. Note that the
meta-check has produced a repeat finding across S25/S60/S65/S70 before it was finally built (the
pipeline counter); look for the current equivalent.

## What must be answered

1. **Did `stranger_check` and `scaffold_drift_check` actually RUN, with pasted live tallies?** If
   either is red, no other green matters to anyone outside this repo.
2. **The adoption number, stated not guessed.** Stars, forks, issues, downloads. S128 and S129 both
   improved what a stranger receives; did anything move? If not, say so plainly — a working front
   door and a correct rulebook are preconditions for adoption, never evidence of it.
3. **Dogfood.** Last paid run was S124 (`$3.2985`). Five sessions of machinery since. Is any claim
   about "Vajra-on-Claude is satisfying" measured, or unmeasured by definition?
4. **The fourth fork, refused at S129.** Is refusing it still right, or has it become a convenience?
   Two of its keys are already WRONG in a stranger's file — `communication.forbid` ships 4 of our 5,
   and `commit.forbid_skip_hooks` is absent while `src/varta/render.rs:84` reads it.
5. **Is the fleet working, or is it a roster?** (lens 1)
6. **Is the review ritual the right shape?** (lens 2)
7. **Which other registered-but-never-run gate is wrong right now?** The Planner was. Name the next
   one you checked, and say what you found — a guess is not an answer here.

## Output

`sessions/session-130-ground-truth.md`, with a verdict (PASS / PARTIAL PASS / FAIL), every audit
answered, the meta-check, and **exactly 3 ranked candidates for S131**.

**S129's own three, carried forward as the starting point — the founder may replace them:**

- **A — the fourth fork** (S129 pass-2 rec 9, refused with a reason): bring the rest of
  `TPL_CONSTRAINTS` and the scaffolded constitution under one source, and above all build a
  **KEY-SET inventory** so the drift check stops being defined by the derivation.
- **B — F2, the dispatch receipt**: gate the fidelity review on evidence a **different actor**
  produced it, replacing the hardcoded `"claude-code-subagent"` provenance in `src/cli/next.rs`.
- **C — a paid dogfood ride-along from a FRESH SCAFFOLD**, not from this repo. Every paid dogfood in
  130 sessions has run inside the repo that builds Vajra.

## Guardrails

- **NO-CODE.** No `src/` edits, no commits on this branch — hook-enforced. Closeout rides
  `session-130-closeout`.
- **Answer with evidence, not with the roster.** A count of roles is not proof any of them is used;
  a registered audit is not proof it runs; a green gate is not proof the gate parses correctly.
- **Do not soften the vision to match reality** (S118). If reality falls short, that is the finding.
