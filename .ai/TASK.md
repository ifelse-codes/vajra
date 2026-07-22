# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 94 — CODE — COMPLETE

- **Goal:** close the S52 nested-repo guard blindspot — make the PreToolUse guards
  repo-identity-aware so each acts only on the project it was scaffolded into, never an enclosing
  repo during a nested dogfood.
- **Results:** commit-guard + copilot-murmur pin git facts to the project's OWN git top-level
  (`OWN_GIT` iff `--show-toplevel == $ROOT`, canonical `pwd -P`); a subject with no git of its own
  is fail-CLOSED (no marker authorizes a commit there); the governed project is surfaced on every
  advise/block; session-guard gains surfacing + a nesting flag (already file-pinned). Guards ride
  `include_str!` (no `init.rs` edit). **verify 23/23**; **cargo test 286**; two-pass cold review
  (pass 1 caught a fail-open → fixed → pass 2 **ACCEPT**, `8a05903e…`). Report:
  `sessions/session-94-summary.md`; review: `sessions/session-94-review.md`.
- Branch: `session-94-nested-repo-guard`. Commits `5218091`/`1e6d664`/`363e90c`.

Between sessions. **Next = S95** (**NO-CODE ground truth**, `95 % 5 == 0`):
`prompts/95-task-ground-truth.md`. **New chat.**

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Every 5th session is NO-CODE ground truth (**S95 = the next one**).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **Commits are ENFORCED (S93):** on a session branch, supply the un-forgeable marker —
  `VAJRA_ALLOW_COMMIT=NN git commit …`. (S95 is NO-CODE — no commits at all.)
- **New session = new chat** — open a fresh chat for S95; do NOT start it here.
- **Direction:** product = **provable agent governance**, shaped as a **governed multi-agent SDLC
  pipeline** (`DECISION-001`); fidelity load-bearing (`DECISION-002`), verdicts attested
  (`DECISION-003`), chained tamper-evident (`DECISION-004`). **8 governed stations, dogfood-proven
  (S92, $0.27); commit gate ENFORCED (S93); guards repo-identity-aware (S94).**
