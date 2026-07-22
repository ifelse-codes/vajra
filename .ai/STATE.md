# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S96 complete, S97 not yet started).
S96 = **CODE** (founder-directed after S95): fixed the repo-wide rustfmt 1.9.0 drift making CI red.
`cargo fmt` on 3 files (`src/cli/next.rs`, `src/dogfood/mod.rs`, `src/stations/mod.rs`), **zero logic
change**; `cargo fmt --check` + `clippy -D warnings` + `cargo test --lib` **286** all green; CI green
on **both** ubuntu-latest and macos-latest (PR [#97]). Cold review ACCEPT (byte-identical
`rustfmt(main)==HEAD` proof). `verify-session-96.sh` 4/4.

## Active PRs
- **S96 PR:** [#97](https://github.com/ifelse-codes/vajra/pull/97) — `session-96-fmt-drift-fix` (fmt
  + verify/demo scripts; CI green both OS).
- Merged: S95 [#95](https://github.com/ifelse-codes/vajra/pull/95)/[#96](https://github.com/ifelse-codes/vajra/pull/96) ·
  S94 [#94](https://github.com/ifelse-codes/vajra/pull/94) · S93 [#93](https://github.com/ifelse-codes/vajra/pull/93).

## Direction (governance is the product — 8 governed stations; enforcement arc complete)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`VISION.md` + `DECISION-001`). Fidelity load-bearing (`DECISION-002`), verdicts attested
  (`DECISION-003`), chained tamper-evident (`DECISION-004`).
- **Standing S95 GT verdict (still binding):** the ENFORCEMENT arc is complete (S93 obedience
  enforced, S94 identity-aware, fail-closed) — but the **pipeline has not advanced since S72**. This
  is the **4th consecutive GT** flagging the machinery-vs-payload gradient (S80/S85/S90/S95). S96 was
  a bounded hygiene fix (green CI), NOT a pipeline advance. **S97 = the pattern-break: end-to-end paid
  dogfood** (founder pick A) — drive a real task through all 8 stations; diagnose why Coder stays dark.
- **Coder station:** S96 populated its own `## Execution` shas and `vajra next --stations 96` reports
  Coder passed — but this is a formatting-only session where the step→commit mapping is near-trivial;
  it is NOT proof the pipeline executes hard work. S97 is the real Coder test.
- **S70 founder decisions (binding until revisited):** ① crew DONE (8 stations) ✓. ② dogfood 🟢
  (S92 = 2026-07-21, $0.2713) — LAUNCHER only (2/8); pipeline never dogfooded end-to-end (S95). ③
  compression: never claimed until measured (0 folds). ④ payload counter = BUILT (S74), hardened
  (S82); S95 meta-check: read its per-station SHAPE, not just the K number.
- **House patterns (carried):** un-forgeable-env markers — `VAJRA_CLOSEOUT_WAIVER` (S56),
  `VAJRA_ALLOW_PUBLISH` (S37), `VAJRA_ALLOW_COMMIT` (S93); repo-identity resolution — a guard derives
  git facts only from the project's OWN git top-level, cannot-evaluate ⇒ fail-CLOSED (S94). Config
  toggle beats code fork: `publish_guard: off` / `commit_guard: off` in this repo, absent from the
  scaffold. Fakest-green classes: jurisdiction-self-granted (S69) · hollow-green (S69) ·
  voluntary-not-enforced (S76/S92, closed S93) · fail-open-on-cannot-evaluate (S94).

## What Currently Works
- **The 8-station governed pipeline** riding `vajra next` (+ station gates at `--advance`): Analyst ·
  Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer (fidelity gate + attested,
  chained ledger). Receipt AUTHORITATIVE when `total_cost_usd` exists (S66/S78, proven S92 $0.2713),
  HONEST when it doesn't (S77); closeout blocks unfilled execution shas (S81); Releaser durable
  across pruning (S82); attestation recompute-and-compare (S86/S88); `--dogfood-age` live git query
  (S91) shows S92 · $0.2713 · 2026-07-21.
- **CI is green on `main`** (S96): `cargo fmt --check` + `clippy -D warnings` + `cargo test --lib`
  all pass on both ubuntu-latest and macos-latest. rustfmt pinned/verified 1.9.0-stable.
- **Commit gate ENFORCED (S93):** L2 `.githooks/pre-commit` (`VAJRA_ALLOW_COMMIT==NN`); L3
  `hook-commit-guard.sh` un-forgeable teeth. Scaffolded ON; `commit_guard: off` in this repo.
- **Guards repo-identity-aware (S94):** commit-guard + copilot-murmur pin git facts to the
  project's own git top-level; session-guard surfaces the governed project + flags nesting;
  fail-CLOSED when a project has no git of its own.
- **`cargo test --lib` 286** (unchanged — S96 was formatting-only, no new tests).
- **`vajra claude · next · check · init · estimate · meter · hook`** — 7 commands, no 8th.
- **CONSTRAINTS.yaml `required_audits`** — 10 audits; all run in S95.

## What Is Broken / Weak
- **🟡 Pipeline never dogfooded end-to-end** — S92 was 2/8 (launcher loop only). The stations
  (Coder/QA/Demo-er/Releaser driving a real task) are unmeasured live. **S97 targets this.**
- **🟡 Machinery-vs-payload gradient — 4th consecutive GT** — enforcement arc complete; pipeline
  unchanged since S72. S97 (dogfood) is the mandated pattern-breaker.
- **🟡 Coder/EXECUTE station: honest-green only under trivial mapping** — S96 made it PASS on a
  formatting-only session; the gate proves a real sha was recorded per plan step, not that a commit
  *semantically* executes the step. Real hard-work execution still unproven (S97).
- **🟡 KNOWLEDGE §6 bloat (chronic, flagged S60)** — 416 lines / 69 dated entries / ~85K tokens;
  header "Reloaded every session" is false (it's load-order #7, on-demand). Prune candidate (S97 opt B).
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** — L3 `commit_guard: off`; L2 belt
  inline-forgeable; `--no-verify` bypasses both. Teeth proven by test + shipped ON in scaffolds.
- **🟡 Own-git non-session-branch marker fallthrough** + **exotic git shapes untested** (S94 residual).
- **🟡 Compression no-op on real CC (S63/S76)** — never claim until measured; cargo/npm/pytest fold gap.
- **🟡 Cross-agent breadth (original S25 ask) is still zero code** — founder-gated (S26/S70).
- **🟡 Legacy opus ids (4.0/4.1/4.5) have no confirmed current-rate source** — held at $15/$75 (S79).

## What Is In Progress
- **S96 DONE (CODE — CI fmt-fix).** Next = **S97 = end-to-end paid pipeline dogfood** (founder pick
  A). **New chat.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- Session 53–75: ~$0 each. **S76: real but UNKNOWN** (fable-5 unpriced; opus-estimate ≤ ~$26.6).
  **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713 authoritative** (sonnet-4-6, dogfood).
  **S93/S94/S95: ~$0** · **S96: ~$0** (formatting-only, no `vajra claude`).
- Cumulative: **~$74.3 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
