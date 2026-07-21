# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S93 complete, S94 not yet started).
S93 = **CODE** — prove the commit gate has teeth (no-autonomous-commit: voluntary → ENFORCED).
Shipped an L2 belt (`.githooks/pre-commit` blocks a session-branch commit without env
`VAJRA_ALLOW_COMMIT==NN`) + an L3 un-forgeable PreToolUse guard (`hook-commit-guard.sh`, blocks
`git commit` unless the marker is in the hook's own launch env; fires even on `--no-verify`).
Live-proven on this repo (block exit 1 → allow with marker); verify 27/27; cold review ACCEPT.
Summary: `sessions/session-93-summary.md`.

## Active PRs
- Merged: S92 [#92](https://github.com/ifelse-codes/vajra/pull/92) ·
  S91 [#90](https://github.com/ifelse-codes/vajra/pull/90)/[#91](https://github.com/ifelse-codes/vajra/pull/91) ·
  S90 (NO-CODE GT) · S89 [#88](https://github.com/ifelse-codes/vajra/pull/88).
- **S93 PR:** TBD (`session-93-prove-commit-gate-teeth`, 3 commits `4142c1f`/`5a74322`/`044ae15`).

## Direction (governance is the product — 8 governed stations; commit gate now enforced)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`VISION.md` + `DECISION-001`). Fidelity load-bearing (`DECISION-002`), verdicts attested
  (`DECISION-003`), chained tamper-evident (`DECISION-004`).
- **S93 outcome:** the standing "commit-gate obedience is VOLUNTARY" gap (S76 + S92) is CLOSED at
  two layers. The un-forgeable teeth (L3) ride the `vajra init` scaffold (ON by default) + tests;
  in *this* repo L3 is `commit_guard: off` (build-agent exemption, mirrors `publish_guard: off`) so
  the L2 belt governs and the build agent supplies the founder-approved marker per commit.
- **S70 founder decisions (binding until revisited):** ① crew DONE (8 stations) ✓. ② dogfood 🟢
  (S92 = 2026-07-21, $0.2713). ③ compression: never claimed until measured (0 folds). ④ payload
  counter = BUILT (S74) + GT-verified + hardened (S82).
- **House patterns (carried):** un-forgeable-env markers — `VAJRA_CLOSEOUT_WAIVER` (S56),
  `VAJRA_ALLOW_PUBLISH` (S37), **`VAJRA_ALLOW_COMMIT` (S93)** — a founder-supplied env var, never a
  tracked file the agent can Write. Config toggle beats code fork: `publish_guard: off` / `commit_guard:
  off` in this repo, absent from the scaffold (same byte-identical hook, gated by CONSTRAINTS).
  Fakest-green classes: jurisdiction-self-granted (S69) · hollow-green (S69) · voluntary-not-enforced
  (S76/S92 — **now closed by S93**) · un-forgeable-only-at-L3-and-L3-off-in-repo (S93, disclosed).

## What Currently Works
- **The 8-station governed pipeline** riding `vajra next` (+ station gates at `--advance`): Analyst ·
  Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer (fidelity gate + attested,
  chained ledger). Receipt AUTHORITATIVE when `total_cost_usd` exists (S66/S78, proven S92 $0.2713),
  HONEST when it doesn't (S77); closeout blocks unfilled execution shas (S81); Releaser durable
  across pruning (S82); attestation recompute-and-compare (S86/S88); `--dogfood-age` live git query
  (S91) shows S92 · $0.2713.
- **Commit gate ENFORCED (S93):** L2 `.githooks/pre-commit` blocks a session-branch commit without
  `VAJRA_ALLOW_COMMIT==NN` (fail-closed); L3 `hook-commit-guard.sh` is the un-forgeable PreToolUse
  teeth (own-launch-env marker; fires on `--no-verify`; blocks inline self-grant). Scaffolded ON;
  `commit_guard: off` in this repo.
- **`cargo test --lib` 286** (+3 S93 scaffold tests).
- **`vajra claude · next · check · init · estimate · meter · hook`** — 7 commands, no 8th.
- **CONSTRAINTS.yaml `required_audits`** — 10 audits.

## What Is Broken / Weak
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** — L3 is `commit_guard: off`
  (build-agent exemption), so an inline `VAJRA_ALLOW_COMMIT=NN git commit` passes L2 and
  `git commit --no-verify` bypasses both. Un-forgeable teeth proven by test + shipped ON in
  scaffolds (where an unattended agent runs). Disclosed (S93 fakest green).
- **🟡 Nested-repo guard blindspot (S52) — now load-bearing** — session-guard / copilot / the new
  commit-guard can't reliably tell Vajra's own `session-NN` branches from a subject repo's during a
  dogfood. **S94 (picked) closes this.**
- **🟡 Repo-wide rustfmt 1.9.0 drift** — `next.rs` / `dogfood/mod.rs` / `stations/mod.rs` (S91-era
  commits) fail a crate-wide `cargo fmt -- --check`; S93 scoped its fmt gate to `init.rs`. Housekeeping.
- **🟡 Compression is a no-op on real CC (S63/S76)** — never claim until measured; cargo/npm/pytest
  exit-code fold gap (S33/S41) still open.
- **🟡 Cross-agent breadth (original S25 ask) is still zero code** — founder-gated per S26/S70.
- **🟡 Legacy opus ids (4.0/4.1/4.5) have no confirmed current-rate source** — held at $15/$75 (S79).
- **🟡 `--ledger-verify` opt-in, not in mandatory closeout run** · `full_historical_scan` pass bar is
  a floor · `candidate_diffs` O(n·k) rescan.

## What Is In Progress
- **S93 DONE (CODE).** Next = S94 (CODE — nested-repo guard blindspot). **New chat.**
  **S95 = mandatory NO-CODE ground truth** (`95 % 5 == 0`).

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- Session 53–75: ~$0 each. **S76: real but UNKNOWN** (fable-5 unpriced; opus-estimate ≤ ~$26.6).
  **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713 authoritative** (sonnet-4-6, dogfood).
  **S93: ~$0** (CODE, no paid `vajra claude` run).
- Cumulative: **~$74.3 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
