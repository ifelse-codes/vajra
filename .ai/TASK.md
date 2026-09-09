# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Between Sessions — S157 complete, S158 not yet started

**S157 ACCEPT (CODE).** One match arm + one test in `src/dispatch/mod.rs`. Pre-branch tech-lead dispatch (`gitBranch: "main"`) now accepted. 487 lib tests. 6/6 verify PASS. Two-pass fidelity review (REJECT → ACCEPT). **Next GT: S160.**
Founder pick for S158: **demo enforcement** — make demo step mandatory in CODE sessions.
Brief: `prompts/158-task-demo-enforcement.md`.

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
