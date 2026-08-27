---
role: fidelity-reviewer
session: 135
agent: claude-code-subagent (verified: toolu_011aHqCuJqGsKx2TNNYWAanK)
source-sha: f8d0a9d0b4484491e62ab7b82fe0615a5b5f77ce029ff10d9f386b0e9b882ccc
captured: 2026-08-27T16:03:02Z
cost_usd: null
---

# Fidelity-reviewer handoff — session 135

# Fidelity Review — Session 135 (`tech-lead` + `--check-crew`)

Independent cold review. **Two passes** (fidelity is load-bearing — DECISION-002). Pass 1 REJECTed a
mid-flight state and named a real fakest-green (a prose overclaim) + a fabricated demo tally; every
finding was addressed in-session; **pass 2 (this record) = ACCEPT.**

**Method disclosure:** the reviewer had **NO shell** (Read/Grep/Glob only). Every "verify 10/10 /
fixture 7/7 / 458 tests" figure is READ from a script, not executed. The independent execution of the
suites is the builder's + the QA/Demo-er live re-run gates at close — the reviewer read them.

## Per-requirement verdicts

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| 1 | tech-lead handoff required, named FIRST | SHIPPED | `crew_gate` call-site 1 blocks with "FIRST and MANDATORY dispatch"; verify check 1 asserts header + block |
| 2 | All nine roles: `required`/`deferred-budget` + substantive reason (S133 fn verbatim) + numeric budget; deferred carries arithmetic | SHIPPED | `parse_crew` requires all nine (`MissingRoles`); reuses `advice::substantive_reason`; tech-lead handoff carries arithmetic per deferred line |
| 3 | No off switch — inadmissible value REFUSED, msg names phase 1b, test by VALUE | SHIPPED | `CrewRowDefect::UnknownVerdict`; `an_inadmissible_verdict_is_refused_by_value` binds to the variant not text; refusal names phase 1b |
| 4 | `--check-crew` blocks missing/forged tech-lead or unsatisfied required role; 7-command floor unchanged | SHIPPED | `run_check_crew` exits 1 on block; call-site 2 loops required roles; verify check 10 asserts "of 8" + command count |
| 5 | Genericity as a NUMBER — 0 shared-ladder lines | SHIPPED | `git diff main -- src/mandate/mod.rs` empty (verify check 8); impl-advisor + summary report 0 |
| 6 | `--crew-cost` reads REAL bytes, reconciles S134 figures, missing transcript FAILS | SHIPPED | `raw_tokens` incl. cache_read+creation; reconciliation test hits 4,928,036/6,152,671/8,111,990/19,192,697; `read_dispatch_raw_tokens` Errs on missing |
| 7 | Budget carried INTO each role's brief; `--crew-cost` reports vs allowance, never blocks, described as instruction | PARTIAL | Report-vs-allowance + never-block + instruction-language all shipped (`run_crew_cost`); but NO code carries the budget into a dispatched role's brief — `run_role_handoff` never reads `budget_tokens`. The reporting half is built; the injection half is not. |
| 8 | Gate BINDS ON THIS session — 2–3 real roles dispatched, cannot close without their handoffs | SHIPPED | 3 provenance-verified required handoffs on disk; `--advance` crew block binds the closing session; the gate blocked live until they landed (pass 1 observed it) |
| 9 | No `VAJRA_SKIP_*` escape; 12+ env vars driven, blocks every time | SHIPPED | `crew_gate` reads no env var; verify check 5 drives 15 vars singly + union + structural grep |
| 10 | verify + demo exit 0 with tally; fixture RED on each plant asserting it landed + clean-exit-0 positive control | SHIPPED | 10 checks in verify; 4 plants + value-bound control + POS-exit-0 in fixture; demo emits the 4 required markers |
| 11 | Independent cold fidelity ACCEPT, attested; obeyed-judge ≠ advisor | SHIPPED | impl-advisor judged the design-advisor's 6 recs (different role, 6 implemented/0 mismatch); this pass-2 review is the attested ACCEPT |
| 12 | Summary answers 3 questions with real numbers (roles ran; RAW not new-only; phase-1b estimate) | SHIPPED | Summary Q1/Q2/Q3 with 155K/13K/368K/2.0M RAW, the ~20× NEW-only contrast, ~4–5M phase-1b |

**11 of 12 SHIPPED** (criterion 7 PARTIAL, 0 NOT-BUILT).

## The fakest green that REMAINS

**Criterion 7's "carried INTO each role's brief."** The phrase implies Vajra hands each required role
its allowance at dispatch; the mechanism only *records* the budget in the tech-lead handoff and
*reports* it after the fact via `--crew-cost`. Nothing in the dispatch path reads `budget_tokens`.
This clause would pass identically if the "carry into brief" feature were deleted, because it was
never built as code. It is honestly *reported* (the summary calls it "reports actual against
allowance"), but the criterion is not fully met as written — hence PARTIAL, not paved over.

The pass-1 fakest greens (the Decision-4 prose overclaim; the demo's hard-coded "10/10 / 7/7" tally)
are both genuinely fixed.

## Recommendations

rec 1 — Record criterion 7 as PARTIAL in the review of record, not SHIPPED: the "budget carried INTO each role's brief" clause has no code path (`run_role_handoff` never reads `budget_tokens`); only the reporting half is built. Either build the injection, or amend criterion 7's wording so it claims only what `--crew-cost` delivers.

rec 2 — In a follow-up, close the loop: make `vajra next --role <name>` (or a small read surface) echo "recorded allowance: N tokens (an instruction, not a cap)" pulled from the parsed tech-lead handoff, so the role genuinely knows its budget at dispatch. A small call-site addition on the existing `crew_gate` parse, keeping the S133 no-ladder-edit posture.

**Verdict:** ACCEPT

## Handoff Delta
- `+` new: first fidelity-reviewer handoff for this session (5132 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
