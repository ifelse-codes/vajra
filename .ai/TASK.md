# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Between Sessions — S161 complete, S162 not yet started

**S161 ACCEPT (CODE + DOGFOOD).** AC1–AC4 all SHIPPED (DECISION-008, blocking-path demo, behavioral verify test, C5 circular check fix). AC5–AC6 PARTIAL (D2 dogfood ran, verify-closeout 15/15 with waiver, inner session gap disclosed). AC7 17/17. **Prompt: `prompts/161-task-b-closeouts-and-d2-dogfood.md`.** S162 TBD — founder pick.

## Session 161 — CODE + DOGFOOD: S158 carry-forwards + D2 dogfood — COMPLETE

- Brief: `prompts/161-task-b-closeouts-and-d2-dogfood.md`. Summary: `sessions/session-161-summary.md`. Review: `sessions/session-161-review.md`.
- AC1–AC4 SHIPPED · AC5–AC6 PARTIAL · AC7 SHIPPED (17/17). **ACCEPT (5/7 SHIPPED).**

## Session 160 — NO-CODE Ground Truth — COMPLETE

- Report: `sessions/session-160-ground-truth.md`.
- 12 audits, 🟡 PARTIAL PASS. 4 green · 4 yellow · 2 red.
- Carry-forward decisions: S158 violations → S161 (mandatory). Backlog items confirmed.
- **Verdict: 🟡 PARTIAL PASS.**

## Session 159 — DOCUMENT: advice-influence re-audit — COMPLETE

- Brief: `prompts/159-task-advice-influence-reaudit.md`. Review: `sessions/session-159-review.md`.
- 15 items graded. Audit: `sessions/session-159-advice-influence-reaudit.md`. 5/5 SHIPPED. **ACCEPT.**

## Session 158 — CODE: demo enforcement — COMPLETE

- Brief: `prompts/158-task-demo-enforcement.md`. Review: `sessions/session-158-review.md`.
- `is_code_session()` + `check_demo_markers` in `verify-closeout.sh`. Affirmative `**CODE**` matching. 5/5 SHIPPED. **ACCEPT.**

## Session 157 — CODE: fix tech-lead provenance false-negative — COMPLETE

- Brief: `prompts/157-task-crew-branch-fix.md`. Summary: `sessions/session-157-summary.md`. Review: `sessions/session-157-review.md`.
- One match arm in `cross_check` (`src/dispatch/mod.rs`). 487 tests. 6/6 verify PASS. **ACCEPT (4/5 SHIPPED · 1 PARTIAL).**

## Session 156 — DOCUMENT+admin: merge PRs + KNOWLEDGE.md prune — COMPLETE

- Brief: `prompts/156-task-admin-close.md`. Summary: `sessions/session-156-summary.md`. Review: `sessions/session-156-review.md`.
- S151–S155 PRs merged. KNOWLEDGE.md 1364 → 282 lines. STATE.md updated. verify-session-156.sh 4/4 PASS. **ACCEPT (3/5 SHIPPED · 2 PARTIAL).**

## Session 155 — NO-CODE Ground Truth (155 % 5 == 0) — COMPLETE

- Brief: `prompts/155-task-ground-truth.md`. Report: `sessions/session-155-ground-truth.md`.
- 🟡 PARTIAL PASS. 12 audits + 6 special inputs. 🟢: stranger 21/21 · scaffold-drift 17/17 · fmt · 486 tests. 🔴: KNOWLEDGE.md 1364 lines. 🟡: prove-then-cut-cost 11 sessions late; tech-lead provenance false-negative systemic gap.
- Founder pick: **C — administrative close.**
