# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S106 complete, S107 not yet started).
S106 = **CODE: make it installable (v0.1)** — the C→B→A order's **B**. **Goal achieved:** one install
path that works from a clean checkout (`cargo install --git|--path` → `vajractl` crate, `vajra`
binary), the **missing installability instrument** (`scripts/install-smoke.sh`), and a README
truth-pass. **No `src/` changes; no crates.io publish; no tag.** verify 5/5 GREEN; demo exit 0 (4
markers); independent cold review **ACCEPT**, attested `07b962af…`. **PR #111.**

**Discovery:** `Cargo.toml` was **already release-correct** (`vajractl`/bin `vajra`/v0.1.0) — the S105
"paper-only / Cargo.toml untouched" note was **stale**. The gap was never the crate metadata; it was
the **absence of proof**, which the instrument now supplies.

**🔀 FOUNDER PIVOT (S103, still in force):** no more paid multi-day Autopilot-Ladder *sessions* —
sessions now = **finish a shippable MVP**; the founder runs the long unattended test himself, then
release. Order **C → B → A**: C (team voice) = S104 ✓ → **B (installable)** = S106 (Rust path +
instrument) → **S107 the no-Rust prebuilt-binary path** → A (real named agent fleet) after the MVP ships.

## Active PRs
- **S106:** [#111](https://github.com/ifelse-codes/vajra/pull/111) (`session-106-installable-v01`) —
  install instrument + README truth-pass + verify/demo. Cold review ACCEPT, attested `07b962af…`.
  To merge at founder direction.
- Merged: **S105 follow-up [#110](https://github.com/ifelse-codes/vajra/pull/110)** (un-blind
  `--dogfood-age`: aggregate receipts + root-cause corrections) · **S105 [#109](https://github.com/ifelse-codes/vajra/pull/109)** ·
  **S104 [#108](https://github.com/ifelse-codes/vajra/pull/108)** · S103 · S102 · S101 · S100.

## Direction (governance is the product — now shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust layer**.
  Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained tamper-evident
  (`DECISION-004`). **No pivot in the product** — the pivot (S103) is in HOW we spend sessions (finish
  the MVP, not run paid ladders).
- **Post-pivot roadmap:** C team-voice (S104 ✓) → **B installable v0.1** (S106 ✓ Rust path + the
  installability instrument; **S107 = tagged prebuilt binaries so a stranger without Rust can install**)
  → A fleet. Release when v0.1 is stranger-shippable; the founder owns the long unattended real-world test.
- **The machinery-freeze rule (`DECISION-005`) is RETIRED** (S105): the pivot cancelled ladder
  *sessions*. The new law is the pivot itself — a session finishes a shippable-MVP slice.

## What Currently Works
- **v0.1 installs from a clean checkout AND an instrument proves it (S106):** `cargo install --git`
  (no clone) or clone + `cargo install --path .` → `vajra` on PATH; `scripts/install-smoke.sh` runs
  fresh install → `vajra init` → `vajra next`, asserts each, **exits non-zero if broken** (falsifiable,
  proven both ways). The README shows only proven paths; unshipped ones stay NOT YET PUBLISHED.
- **The 8-station governed pipeline speaks like a team** (S104): `vajra next --stations` + the packet
  render named roles + plain status from one source; gates/K unchanged underneath.
- **Autopilot governance PROVEN with a FORCED block (S103):** on chitra a good-faith agent's commit
  was STOPPED by L3 `hook-commit-guard.sh` even under `--dangerously-skip-permissions`; a
  detached/resumable/budget-capped harness ran 6 tasks and its kill-switch fired on cap (Rung 2 PASS).
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner ·
  Coder · QA · Demo-er · Releaser · Reviewer (fidelity gate + attested, chained ledger). Receipt
  AUTHORITATIVE when `total_cost_usd` exists, HONEST when it doesn't (S77); closeout blocks unfilled
  execution shas (S81); `--dogfood-age` live git query (S91; un-blinded for S102/S103 in the S105 follow-up).
- **Ledger** (S100): `verify-closeout.sh --ledger-verify` → INTACT, tamper-evident (`DECISION-004`).
- **CI green on `main`** (both OS) · `vajra claude · next · check · init · estimate · meter · hook`
  — 7 commands, no 8th.

## What Is Broken / Weak
- **🟡 v0.1 is not YET installable without Rust.** S106 shipped the `cargo install` path (needs a Rust
  toolchain) + the instrument. The **prebuilt-binary path** (`release.yml`, tag `v*`) has never fired
  for a real tag; a stranger without Rust still cannot install. **S107 target** (founder pick A).
- **🟢 Installability is now MEASURED (S106).** `scripts/install-smoke.sh` is the instrument the S105
  meta-check found missing (`--stations` read 7/8 while every install path was broken). Residual (🟡):
  its **default** proves `cargo install --path`; the README headline `--git` remote path runs only under
  `VAJRA_SMOKE_SOURCE=git` (structurally identical crate/bin, disclosed). Also `within-budget` is a
  post-hoc check, not a hard per-step timeout (a true infinite hang wouldn't be killed).
- **🟡 `--dogfood-age` durable code fix still open.** S105 follow-up un-blinded S102/S103 via a
  hand-added top-level aggregate receipt; the durable fix = make `dogfood_age()` recurse into per-run
  subdirs (`src/dogfood/mod.rs:63-66`) so future dogfoods needn't add an aggregate by hand. **S107-alt C.**
- **🟡 `vajra --version` gap.** A stranger who installs and types `vajra --version` gets usage, not a
  version string (exit 0, falls through to help). Minor installability polish. **S107-alt B.**
- **🟡 KNOWLEDGE §6 bloat GROWING** (chronic since S60): ~475 lines / ~91K tokens; header "Reloaded
  every session" still false. Prune queued, not done.
- **🟡 `vajra.varta` re-render drifts every session** — `vajra check` FAILs "varta stale"; no CLOSEOUT
  gate reads it, so fixes don't stick. A durable gate is the real fix.
- **🟡 `fable-5` monthly credits exhausted (S102).** Paid dogfood costs real $ on sonnet/opus.
- **🟡 Old repos ship without guards (S102)** · **In THIS repo the commit gate is
  auditable-not-un-forgeable** (L3 `commit_guard: off`; L2 belt active; chitra's re-init'd guards ARE
  on, proven S102/S103) · **Compression no-op on real CC** (never claim until measured) · **Cross-agent
  breadth 0 code** (sequenced) · **Legacy opus ids** held at $15/$75.

## What Is In Progress
- **S106 DONE (CODE — installable v0.1 Rust path + instrument; ACCEPT, attested).** PR #111 to merge.
- **Next = S107 — CODE: tagged binary release v0.1.0** (founder pick A): push a `v0.1.0` tag →
  `release.yml` builds 3-target prebuilt binaries + GH release → a download-and-run smoke proves the
  no-Rust path → un-mark that README row. Prompt: `prompts/107-task-tagged-binary-release-v010.md`.
  **Tag push is founder-gated (public release).** **New chat.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- Session 53–75: ~$0 each. **S76: real but UNKNOWN** (fable-5 unpriced; opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713** · **S97: $1.2758** · **S102: $0.4644** ·
  **S103: $0.6797** (all authoritative). **S104: ~$0** · **S105: ~$0** (NO-CODE GT) · **S106: ~$0**
  (local build/test/cold-review; no `vajra claude` paid run).
- Cumulative: **~$79.3 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
