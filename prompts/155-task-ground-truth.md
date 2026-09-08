# Session 155 — Ground Truth: full audit

> **Status:** APPROVED — all approved (founder, 2026-09-08)

## Type
- **NO-CODE. Mandatory (155 % 5 == 0).** No source-code edits · no commits · no PRs.
  Exception: housekeeping-only branch (`session-155-closeout`) for the GT report file if needed.

## Goal

Run the full Ground Truth audit. Catch two classes of drift:

1. **Direction drift** — are we building the right thing? Vision + roadmap still map to the north-star; current work is the shortest path, not scope creep.
2. **Discipline drift** — did we honour the contract, and does the contract still serve the vision?

**Meta-check (mandatory):** did this audit's own mechanism miss a kind of drift? Auditing rule-following while ignoring the vision is the exact trap.

Output: `sessions/session-155-ground-truth.md`. Founder signs off before code resumes.

## Required audits (from CONSTRAINTS.yaml#ground_truth.required_audits)

Run every audit below, answer its question list, give a 🟢 / 🟡 / 🔴 verdict:

| Audit | Key question |
|---|---|
| `vision_alignment` | Does the current build still map to the stated vision in `VISION.md`? |
| `roadmap_alignment` | Is the current roadmap the shortest path to the vision, or has it drifted? |
| `state_drift` | Does `STATE.md` accurately reflect the repo? Any stale claims? |
| `knowledge_staleness` | Is `KNOWLEDGE.md` accurate? Anything permanent that is missing or wrong? |
| `constraint_violation_review` | Any session in the last 5 that violated a `CONSTRAINTS.yaml` rule? |
| `constitution_review` | Does `AGENTS.md` still reflect how the project is actually run? |
| `cost_review` | What is the real cost per session? Is it trending the right direction? |
| `dogfood_check` | How old is the last paid dogfood run? Is the age acceptable by the founder's S70 decision? |
| `stranger_check` | Run `vajra next --check-crew` + `--stations` on the last 3 sessions. Do they look right to a stranger? |
| `scaffold_drift` | Is the `vajra init` scaffold still in sync with the live gates and roles? |
| `cargo_fmt` | Does `cargo fmt --check` pass on main? |
| `lib_tests` | Does `cargo test --lib` pass on main? How many tests? |

## Special inputs for S155

These are NEW since S150 (the last GT) — address each explicitly:

1. **CODER station now passes (S154)** — the pipeline stations audit should show this for the first time. Confirm `vajra next --stations 154` reads CODER as PASSED and assess whether the station is now systematically healthy or a one-off.
2. **Tech-lead provenance false-negative (S154 waiver)** — the crew check was waived because the dispatch transcript showed branch `session-135-tech-lead` instead of `session-154-*`. Is this a systemic gap in the provenance verifier, or a one-off? Should it be fixed?
3. **S152 carry-forward rules** — handoff-condensation + retirement-standard + DOCUMENT-session verify standard added at S152/S153. Have they reduced hollow advice? Check the last 3 sessions' reviews.
4. **C5 (verify-153)** — the `Brief:` check in `verify-session-153.sh` is circular (greps AGENTS.md for the keyword it added). Flag it explicitly.
5. **KNOWLEDGE.md size** — still at 475+ lines, chronically deferred. Is it now a real problem for boot performance?
6. **Cost** — still at $11.74/session (S144 baseline). Prove-then-cut-cost arc has been deferred since S145. This is the adoption blocker; assess urgency.

## Deliverables

1. `sessions/session-155-ground-truth.md` — all 12 audits answered with 🟢/🟡/🔴, meta-check, and exactly 3 ranked next-session candidates A/B/C.

## Guardrails

- No source code edits. No commits to any non-closeout branch. No PRs.
- If `cargo fmt --check` or `cargo test --lib` fails, record it as a 🔴 finding — do NOT fix it in this session.
- The GT report must answer the meta-check: "what would this audit MISS by design?"
- Present exactly 3 next options A/B/C at the end. Wait for founder pick.

## Plan

1. Run all 12 required audits (live commands where applicable). covers: 1
2. Address the 6 special S155 inputs explicitly. covers: 1
3. Write `sessions/session-155-ground-truth.md` with verdicts + meta-check + 3 next options. covers: 1
4. Wait for founder sign-off. covers: 1
