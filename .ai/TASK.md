# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 73 — Close-path RELIABILITY: fix the brakes — COMPLETE

- **Shipped:** (a) the `tests/hook_adapter.rs` flake FIXED at the ROOT — a `static ENV_LOCK`
  isolates the process-global `VAJRA_RAW` leak across parallel test threads (no assertion
  weakened, no `#[ignore]`, no retry, no deletion; ≥10-run loop + full `cargo test` ×2 = proof);
  (b) the QA + Demo-er live gate runs BOUNDED by a recorded, fail-closed timeout — new shared
  `src/gate_run.rs` (`run_streamed`/`run_captured`) kills a run past the bound by process group
  and BLOCKS as the existing cannot-evaluate FAIL, `timeout_notice` naming the timeout + script
  (never a silent pass, never a hang). `verify/demo.timeout_secs` recorded + `vajra init`
  propagated (600s default, section-scoped, pre-S73 repos valid). No CLI change, no 8th command,
  no new dependency, no second store; normal green closes byte-identical.
- **Proof:** 240 lib tests (+11) · `verify-session-73.sh` all green (36 checks incl. verify-71 +
  verify-72 re-run green) · demo-73 green (4 markers) · independent cold review **ACCEPT 13/13**
  attested `619ce8f2…` (it caught a committed-script-depends-on-uncommitted-source inconsistency —
  fixed in-session `S73 step 2c` + re-attested). Fakest green disclosed: QA streamed path
  collapses timeout + spawn-failure into one `None` (naming rides an `eprintln!` side-channel).
  **S73 spend ~$0.**
- Read prompt: `prompts/73-task-close-path-reliability.md`

Between sessions. **Next = S74 (recommended: the payload counter, CODE)** — founder confirms/
re-picks at the board review; `prompts/74-task-payload-counter.md` (DRAFT). **New chat.**

## Next Session (S74 — payload counter [recommended], CODE)
- Record, per session, how many of the 8 governed stations a prompt DEMONSTRABLY passed —
  derived from each station's existing gate classifier (never a self-asserted digit), surfaced
  (`vajra next --stations NN`, K-of-8, read-only) and made a GT input, retiring the
  S25/S60/S65/S70 meta-gap (no gate measures whether the PIPELINE advances). No new store, no
  8th command. Alt picks: dogfood ride-along [parked] · typed cannot-evaluate + depth hardening.
- Branch `session-74-payload-counter`. **S75 = the next mandatory NO-CODE GT.**
- Dogfood ride-along = **PARKED by founder call** (`prompts/parked-dogfood-ride-along.md`,
  READY-shaped; re-enters by rename). Merge the S73 PR + sync main + prune `session-73-*` before
  the S74 close — the Releaser gate enforces it.

## Always-True Reminders
- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Every 5th session is NO-CODE ground-truth (next = **S75**).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S73; do NOT start it here.
- **Direction:** product = **provable agent governance**, shaped as a **governed multi-agent SDLC
  pipeline** (`DECISION-001`); fidelity is the load-bearing governance (`DECISION-002`), verdicts
  attested (`DECISION-003`) + chained into a tamper-evident ledger (`DECISION-004`).
  **Pipeline = 8 governed stations** (Analyst WHAT · Architect DESIGN · Planner HOW-plan ·
  Coder DID · QA WORKS · Demo-er SHOW · Releaser SHIP · Reviewer/ledger REVIEW) + the
  authoritative receipt. **The core crew is COMPLETE (S72); Monitor stays later.**
  **S70 founder decisions:** dogfood = founder-led run, crew condition MET but **PARKED by
  founder call at the S73 pick** (GTs report age against the decision) · compression =
  never claimed until measured real · payload counter = backlog.
