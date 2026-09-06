# Session 147 — Release-Coordinator Handoff (payload: S147 ship steps)

## Three blockers (verify-closeout.sh will fail without these)

1. fidelity-reviewer handoff missing — required-crew gate exits 1
2. sessions/session-147-review.md missing — fidelity-review-accept gate exits 1
3. scripts/verify-session-147.sh and scripts/demo-session-147.sh missing — demo-scripts-present gate exits 1

## Ordered ship steps

rec 1 — Dispatch fidelity-reviewer BEFORE opening PR; verify-closeout.sh must exit 0 on the branch before merge (merge-base collapses post-merge)
rec 2 — Write scripts/demo-session-147.sh even if minimal (prints demo:<element> markers); the gate reads N%5 not the AC list — no demo script = blocked
rec 3 — Run `bash scripts/verify-closeout.sh` on the session branch and confirm all 15 checks pass before opening PR
rec 4 — Open PR from session-147-prove-quiet-roles to main; record PR number in session summary
rec 5 — After merge: checkout main and pull from origin/main
rec 6 — Prune merged session-* branches locally after confirming PR merged

## Direct answers

1. Does a document-only session need a PR? YES — CONSTRAINTS.yaml forbid_direct_work_on: [main, master] applies to all sessions
2. Correct sequence: verify-closeout.sh exit 0 on branch → PR → merge → checkout main → pull → prune
3. Most likely check to fail: check_required_crew (fidelity-reviewer handoff absent)
4. Most likely to be forgotten: demo-session-147.sh (instinct: "no demo AC" = "no demo script needed" — the gate disagrees)
