# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 96 — CODE (CI fmt-fix) — COMPLETE

- **Goal:** make `main`'s CI green — the only red step was `cargo fmt --check` on 3 pre-existing
  rustfmt-1.9.0-drifted files. Fix = `cargo fmt`, zero logic.
- **Results:** all 5 acceptance criteria SHIPPED. `cargo fmt --check` + `clippy -D warnings` +
  `cargo test --lib` **286** green; exactly the 3 known `src/` files reformatted (fmt-only) + 2 session
  scripts; CI green on **both** ubuntu-latest and macos-latest (PR [#97]). Cold review **ACCEPT** with a
  byte-identical `rustfmt(main)==HEAD` zero-logic proof. `verify-session-96.sh` **4/4**. Coder
  `## Execution` shas filled (Coder non-dark for the first time since S72 — trivial-mapping caveat).
- Report: `sessions/session-96-summary.md` · review: `sessions/session-96-review.md`.
  Branch: `session-96-fmt-drift-fix`.

Between sessions. **Next = S97** (DOGFOOD, paid — founder pick A, locked at S95): drive a real task
end-to-end through all 8 stations on chitra; high honest K-of-8 with **Coder PASSED live** + Coder-dark
diagnosis. `prompts/97-task-e2e-pipeline-dogfood.md`. **New chat.**

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Every 5th session is NO-CODE ground truth (**S100 is the next one**).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **Commits are ENFORCED (S93):** on a session branch, supply the un-forgeable marker —
  `VAJRA_ALLOW_COMMIT=NN git commit …`.
- **New session = new chat** — open a fresh chat for S97; do NOT start it here.
- **Direction:** product = **provable agent governance**, shaped as a **governed multi-agent SDLC
  pipeline** (`DECISION-001`); fidelity load-bearing (`DECISION-002`), verdicts attested
  (`DECISION-003`), chained tamper-evident (`DECISION-004`). **8 governed stations, dogfood-proven
  (S92, $0.27); commit gate ENFORCED (S93); guards repo-identity-aware (S94); CI green on main (S96).
  S95 GT still stands: pipeline not advanced since S72 — S97 dogfoods it end-to-end.**
