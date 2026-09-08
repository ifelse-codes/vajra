# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Between Sessions — S156 complete, S157 not yet started

**S156 ACCEPT (DOCUMENT+admin).** KNOWLEDGE.md pruned 1364 → 282 lines. All S151–S155 PRs merged. verify-session-156.sh 4/4. Fakest green: SESSION-number proxy for AC1. **Next GT: S160.**
Pick for S157: (A) tech-lead provenance false-negative fix (CODE); (B) prove-then-cut-cost arc start (DOGFOOD); (C) GT S160 prep / backlog triage (DOCUMENT).
Brief for next session will live at `prompts/157-task-<slug>.md`.

## Session 156 — DOCUMENT+admin: merge PRs + KNOWLEDGE.md prune — COMPLETE

- Brief: `prompts/156-task-admin-close.md`. Summary: `sessions/session-156-summary.md`. Review: `sessions/session-156-review.md`.
- S151–S155 PRs merged. KNOWLEDGE.md 1364 → 282 lines. STATE.md updated. verify-session-156.sh 4/4 PASS. **ACCEPT (3/5 SHIPPED · 2 PARTIAL).**

## Session 155 — NO-CODE Ground Truth (155 % 5 == 0) — COMPLETE

- Brief: `prompts/155-task-ground-truth.md`. Report: `sessions/session-155-ground-truth.md`.
- 🟡 PARTIAL PASS. 12 audits + 6 special inputs. 🟢: stranger 21/21 · scaffold-drift 17/17 · fmt · 486 tests. 🔴: KNOWLEDGE.md 1364 lines. 🟡: prove-then-cut-cost 11 sessions late; tech-lead provenance systemic gap.
- Founder pick: **C — administrative close.**

## Session 154 — CODER station (step-sha traces) — COMPLETE

- Brief: `prompts/154-task-coder-station.md`.
- `check_execution_shas` tightened (BLOCK on real plan + no `## Execution`); placeholder grep fixed; AGENTS.md rule added; self-bind filled. 7/7 verify PASS. **ACCEPT (6/6 SHIPPED).**

## Session 153 — Close S153 carry-forward items — COMPLETE

- Brief: `prompts/153-task-s153-carryforward-items.md`.
- 3 AGENTS.md prose notes + 1 cargo threshold test + verify-session-153.sh. 486 lib tests. 16/16 GREEN. ACCEPT.

## Session 152 — DOCUMENT: obedience-skip + carry-forward rules — COMPLETE

- Brief: `prompts/152-task-carryforward-rule.md`.
- Obedience Protocol rule + Carry-Forward Rule added to AGENTS.md; 8 S149 hollow items audited (4 retired, 4 → S153). 16/16 GREEN. PR #182 MERGED.

## Session 151 — fix cargo fmt + guard against recurrence — COMPLETE

- Brief: `prompts/151-task-fmt-fix.md`.
- cargo fmt on 4 files; check_cargo_fmt added to verify-closeout.sh; 16/16 GREEN. PR #181 MERGED.

## Session 150 — NO-CODE Ground Truth (mandatory, 150 % 5 == 0) — COMPLETE

- Brief: `prompts/150-task-ground-truth.md`. Report: `sessions/session-150-ground-truth.md`.
- 🟡 PARTIAL PASS. 12 audits + F2f lens. One 🔴: cargo fmt fails on main (S148). Founder pick: S151 = fmt fix.
