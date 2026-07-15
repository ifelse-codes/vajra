# Session 64 — The PLANNER stage (the pipeline's 2nd governed specialist) — DONE (CODE)

**Goal achieved: YES.** Shipped station two of the governed SDLC pipeline. The Analyst governs the
**WHAT** (intent → the accepted prompt); the **Planner** governs the **HOW** — it turns that accepted
prompt into an ordered, **coverage-checked `## Plan`** *before* any code, the pre-execution mirror of
the post-delivery fidelity Validator. Rides `vajra next` (no 8th command), owns the existing
`prompts/` spine (no `plan.md`, no second store). One story, independently ACCEPT'd.

## What shipped
- **`src/planner/mod.rs`** — `acceptance_criteria` (numbered items scoped to `## Acceptance`) ·
  `plan_coverage` → `PlanState{Absent, Placeholder, Uncovered(missing), Covered}` · `plan_gate` ·
  `format_plan_checklist`. Coverage = every acceptance-criterion number is cited by a real `## Plan`
  step via a recorded `covers: N` marker. **Surfaces + enforces, never authors.** 14 unit tests.
- **`src/cli/next.rs`** — `vajra next --plan NN` (surface the checklist) · `--check-plan NN` (gate,
  exit 1 on placeholder/uncovered) · the gate wired into `--advance` (L2/L3 block · L1 advise ·
  `VAJRA_SKIP_PLANNER_GATE=1` override, distinct from the Analyst's so each stage overrides alone).
- **`src/analyst/mod.rs`** — the scaffold `PROMPT_TEMPLATE` gains a placeholder `## Plan`, so a fresh
  prompt BLOCKS until a covered plan is recorded (symmetric with the S61 Delta placeholder); a
  wholly-absent `## Plan` on a legacy prompt only WARNS.
- **`scripts/verify-session-64.sh` (26/26)** + **`scripts/demo-session-64.sh`** (5 scenarios).
- **Dogfood:** the S64 prompt now carries a covering `## Plan` — the Planner ran on its own contract,
  which **surfaced a real parser gap** (a `covers:` marker on a wrapped continuation line, and prose
  that says "covers:", were missed) → fixed + regression-tested before commit.

## Evidence
- `cargo test` **168 lib** (+14); fmt + clippy `-D warnings` clean; `cargo build` OK.
- `verify-session-64.sh` **26/26** — real `--plan`/`--check-plan`/`--advance` in a temp git repo:
  surfaces criteria · BLOCKS placeholder · BLOCKS uncovered (+ names the gap) · PASSES covering ·
  WARNS absent · `--advance` refuses an uncovered contract, override clears it, covering advances 50→51.
- Live on this repo: `vajra next --plan 64` surfaces this session's 3 criteria; `--check-plan 64` READY.
- **S64 spend ~$0** (code + a negligible cold-review subagent; no paid `vajra claude` run).

## Fidelity self-review (DECISION-002 — independent cold subagent, prompt + delivery-diff only)
**Verdict = ACCEPT.** `sessions/session-64-review.md`, attested
`Review-Inputs-SHA: 293d52e9…` (`verify-closeout.sh --attest-only 64` + `--fidelity-only 64` PASS).

| Requirement | Ruling |
|---|---|
| A1 `--plan` surfaces real criteria (temp repo) | SHIPPED |
| A2 `--check-plan` blocks placeholder/uncovered, passes covering; wired into `--advance` | SHIPPED |
| A3 surfaces + enforces, never authors; placeholder = absent | SHIPPED |
| D1 `planner/mod.rs` + unit tests | SHIPPED |
| D2 CLI wiring, no 8th command | SHIPPED |
| D3 verify (exits 0, real temp-repo) | SHIPPED |
| D4 demo | SHIPPED |
| D5 summary + cold review | PARTIAL (closeout paperwork, produced at/after the review) |

**Fakest green (named by the reviewer):** coverage is a **self-asserted digit-tag** — `1. do
everything — covers: 1, 2, 3` passes on any 3-criterion prompt, because the gate enforces that the
author *typed* the numbers, not that the step relates to the criterion. Honestly disclosed in the
module doc, demo, and verify → thin-but-honest, not deceptive. It is the softest green.

## Honest limits (stated plainly)
- **Coverage ≠ semantic proof.** The Planner enforces a *recorded number mapping*, not that a step
  truly satisfies a criterion — the fidelity Validator (post-delivery) is what checks the work was
  really done. Two stages now bracket execution: Planner (before) and Validator (after).
- **Still an early pipeline.** Two stations of a longer line (Architect/Coder unbuilt); the pipeline
  is longer than at S63 but not complete.
- **Narrow vacuous-pass:** a prompt with an unrecognized Acceptance heading parses 0 criteria and any
  single real step passes — defended upstream by the Analyst gate (an APPROVED prompt has a recognized
  heading), so not exploitable in the governed flow.
- **Carried, not fixed:** the receipt ~4.7× overstatement (🔴) and the compression 0-fold no-op (🟡).

## 3 ranked candidates for **S66** (⚠ **S65 is the mandatory NO-CODE ground-truth**, every 5th)
- **🥇 A — the Architect stage (pipeline station 3).** *Goal:* one governed step turning the covered
  plan into recorded design/interface decisions before code (station two → three). *Why:* stays on the
  S60-GT locked direction — payload over gate-hardening, advance the pipeline one station per session.
  *Risk:* finding a real "surface + enforce, never author" mechanism for design (not a doc-presence
  grep) — the honest bar the Planner met.
- **🥈 B — make the receipt authoritative (retire the ~4.7× overstatement).** *Goal:* the receipt
  reports `total_cost_usd`, not the cache-miscalibrated ~4.7× figure. *Why:* it is the standing 🔴
  first-class trust bug (S51/S52/S63) — governance credibility is the product. *Risk:* the
  overstatement is non-constant, so the fix is "report the authoritative number," not "divide by a
  constant."
- **🥉 C — fix or formally retire the compression no-op.** *Goal:* make compression fold on real CC,
  or retire the savings claim honestly. *Why:* the product still implies savings the loop (0 folds,
  S63) doesn't deliver. *Risk:* may resolve to a "retire the claim" doc rather than a fold.

**Recommendation: A** — the pipeline is the payload the last five GTs asked for; one station per
session keeps the cadence. (B is the tempting 🔴, but the founder locked "advance the pipeline" at
S60-GT; B/C are credibility debt to schedule, not the north-star.) **Next = S66 after the S65 GT.**
