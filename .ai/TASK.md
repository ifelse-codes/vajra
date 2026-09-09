# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Between Sessions — S158 complete, S159 not yet started

**S158 ACCEPT (CODE).** `is_code_session()` (affirmative `**CODE**` match) + `check_verify_demo_scripts` (type-aware) + `check_demo_markers` (live run + 4 markers). `demo-session-158.sh` + `verify-session-158.sh` 14/14 PASS. design-significant: yes. **Next GT: S160.**
Founder to pick S159 in a FRESH chat.

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
- 🟡 PARTIAL PASS. 12 audits + 6 special inputs. 🟢: stranger 21/21 · scaffold-drift 17/17 · fmt · 486 tests. 🔴: KNOWLEDGE.md 1364 lines. 🟡: prove-then-cut-cost 11 sessions late; tech-lead provenance systemic gap.
- Founder pick: **C — administrative close.**
