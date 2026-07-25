# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S101 complete, S102 not yet started).
S101 = **CODE (docs): release-backstop slice** (founder picked C — a knowing machinery-freeze
override, recorded in the prompt). **README truth-pass + crate-name decision.** Corrected 3 broken
install methods (crates.io/Homebrew/prebuilt now marked NOT YET PUBLISHED, not faked), retired the
stale ~8× receipt claim + the `$33.4976`/`opus-4-6` example (replaced with the real S97 `$1.2758`
fable-5 capture), updated the 45-session-stale Direction paragraph + Status table to shipped reality
(8 stations, auditor shipped/attested/chained, `vajra check` 11, all 7 commands), and recorded the
v0.1 crate name in `DECISION-006` against a live crates.io check. **Published/tagged/renamed nothing;
`Cargo.toml` untouched.** verify 24/24; independent cold review **ACCEPT**, attested `a96455ff…`.

## Active PRs
- **S101 open:** closeout bundle on `session-101-readme-truth-crate-scope` (README + DECISION-006 +
  verify/demo + review/summary + `.ai/` sync).
- Merged: S100 [#104](https://github.com/ifelse-codes/vajra/pull/104) · S99
  [#103](https://github.com/ifelse-codes/vajra/pull/103) · S98
  [#99](https://github.com/ifelse-codes/vajra/pull/99)–[#102](https://github.com/ifelse-codes/vajra/pull/102) ·
  S97 [#98](https://github.com/ifelse-codes/vajra/pull/98) · S96
  [#97](https://github.com/ifelse-codes/vajra/pull/97).

## Direction (governance is the product — sold as the autopilot trust layer)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`DECISION-001`), **sold as the AUTOPILOT TRUST LAYER** — pipeline = engine, not pitch
  (`DECISION-005`, S98). Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`),
  chained tamper-evident (`DECISION-004`). **S100 re-confirmed the north-star; no pivot.**
- **The Autopilot Ladder** (falsifiable): Rung 1 (=S97, done, hours) → **Rung 2 (=S102, next: 1 day
  unattended, zero-leak + honest receipts + spot-check)** → Rung 3 (2–3 days, ≥2 repos, +
  merge-without-review). **Guards ON every run.** **Release backstop:** v0.1 ships when Rung 3 passes
  once OR **2026-09-15**, whichever first. **Machinery-freeze rule:** a session runs the ladder or
  fixes what a run broke.
- **S100 addition:** *a ladder run's deliverable is a claim, not a diff.* Until a ladder run produces
  reviewable evidence (and is reviewed), "we ran N days unattended" is a story, not a proof.

## What Currently Works
- **README is truth-passed (S101):** one working install method (`cargo install --path .`); the three
  unpublished methods are labelled, not faked; receipt note + example match the fixed
  authoritative-cost behaviour; Direction + command table match shipped reality. **`DECISION-006`**
  settles the v0.1 crate name: crate `vajractl` (crates.io 404 = available) · binary `vajra` (the
  short name is a taken crate, HTTP 200) — on paper only, matching the current `Cargo.toml`.
- **The 8-station governed pipeline** riding `vajra next` (+ station gates at `--advance`): Analyst ·
  Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer (fidelity gate + attested, chained
  ledger). Receipt AUTHORITATIVE when `total_cost_usd` exists (S66/S78, proven S92 $0.2713 · S97
  $1.2758), HONEST when it doesn't (S77); closeout blocks unfilled execution shas (S81); Releaser
  durable across pruning (S82); attestation recompute-and-compare (S86/S88); `--dogfood-age` live git
  query (S91).
- **Ledger verified live at S100:** `verify-closeout.sh --ledger-verify` → **INTACT**, 36 records,
  head `521e66c1…`. Tamper-evident, not tamper-proof (by design, `DECISION-004`).
- **Coder station no longer dark (S100 close of the S95 finding):** PASSED in S96, S98, S99.
- **Coder reachable unattended (S99):** `vajra init`'s kickoff carries station markers; a pre-marker
  prompt reports `[LEGACY]`, never `[ABSENT]`; commit pre-authorization (`VAJRA_ALLOW_COMMIT=NN`)
  surfaced on `vajra next` + the boot packet — advisory + agent-forgeable, the L3 guard keeps the teeth.
- **CI green on `main`** (S96, both OS) · **`cargo test --lib` 293** · `vajra claude · next · check ·
  init · estimate · meter · hook` — 7 commands, no 8th.

## What Is Broken / Weak
- **🔴 Ladder runs are invisible to both GT instruments (S100 meta-check).** `--stations` reads
  DOGFOOD/GT sessions at 1–3 of 8 *by construction* (S90 1/8 · S92 2/8 · S95 3/8 · S97 1/8), and the
  fidelity gate is **waived** on them (S97 closed with no review). Fix = an **evidence contract** for
  ladder runs — **folded into S102 (A+B): `sessions/session-102-review.md` judged on run evidence.**
- **🟡 The fidelity waiver is unbounded.** `waiver_ok()` is un-forgeable in *identity*
  (`VAJRA_CLOSEOUT_WAIVER == N`) but waives the *entire* gate, including the review's existence.
  Aggravator: `sessions/session-97-summary.md:4` records the token as `dogfood-no-src-changes`.
- **🟡 `must_write_next_prompt_before_close` has no gate** — violated at S99 close (`prompts/100`
  absent). `check_session_pair` gates the *current* session's prompt, never the next.
- **🟡 `vajra check` gate gap** — no gate reads `vajra check`; it silently went red for 20 sessions
  (varta frozen at S79, re-rendered S100). Frozen backlog item.
- **🟡 S99 does NOT retro-fit prompts already on disk** — chitra's `prompts/00–03` are still legacy;
  **`vajra next --advance` chitra before the S102 Rung-2 run** or it re-hits the marker wall (`[LEGACY]`).
- **🟡 Commit-auth classification lives twice** (Rust + bash); verify asserts agreement, nothing
  structurally prevents drift.
- **🟡 Autopilot trust is the lead but proven once** (S97, Rung 1, partial 2/8). S102 climbs Rung 2.
- **🟡 KNOWLEDGE §6 bloat (chronic, flagged S60, 9th GT reporting it)** — header "Reloaded every
  session" false (load-order #7, on demand). Frozen backlog item.
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** — L3 `commit_guard: off`; L2 belt
  inline-forgeable; `--no-verify` bypasses. **Ladder runs require guards ON (DECISION-005) — arm both
  for S102.**
- **🟡 Compression no-op on real CC (S63/S76)** — never claim until measured.
- **🟡 Cross-agent breadth is still zero code** — sequenced (neutral `agent-trace` format first), not built.
- **🟡 Legacy opus ids (4.0/4.1/4.5) have no confirmed current-rate source** — held at $15/$75 (S79).
- ~~**🟡 README stale claims**~~ **RESOLVED S101** — truth-passed (install/receipt/Direction/table);
  crate name settled in `DECISION-006`. Remaining is a release *action* (publish/tag/binary/tap), not a doc gap.

## What Is In Progress
- **S101 DONE (CODE docs — README truth-pass + DECISION-006)**, closeout bundle on
  `session-101-readme-truth-crate-scope`. **Founder picked A** for next.
- **Next = S102 — Autopilot Ladder Rung 2 (+ evidence contract, B folded in):** ~1 day unattended,
  multi-task `vajra claude` on chitra, guards ON; produce `sessions/session-102-review.md` judged on
  run evidence (receipt + blocked-action log + chitra diff + fidelity verdict), closing the S100 🔴.
  Prereq: advance chitra onto modern prompts. Brief: `prompts/102-task-ladder-rung2.md`. **New chat.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- Session 53–75: ~$0 each. **S76: real but UNKNOWN** (fable-5 unpriced; opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713 authoritative** (sonnet-4-6, dogfood).
- **S93–S96: ~$0** · **S97: $1.2758 authoritative** (fable-5 e2e dogfood; + ~$0.26 nested-launch smoke
  ≈ $1.54 session total). **S98/S99: ~$0** · **S100: ~$0** (NO-CODE GT) · **S101: ~$0** (docs-only).
- Cumulative: **~$77.5 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
