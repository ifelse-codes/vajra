# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S107 complete, S108 not yet started).
S107 = **CODE: tagged binary release v0.1.0** — the no-Rust install path; the C→B→A order's **B**
completion. **Goal achieved:** the `v0.1.0` GitHub release is live (3 prebuilt tarballs + `.sha256`);
`install-smoke.sh` gained a `VAJRA_SMOKE_SOURCE=release` mode (download → sha256 verify → extract →
`init`→`next`, **fail-closed**), proven live **11/11**; README un-marks the prebuilt row; an in-scope
`release.yml` fix cross-compiles `x86_64-apple-darwin` on `macos-latest`. **No `src/`; no crates.io
publish.** verify 7/7; demo exit 0 (4 markers); independent cold review **ACCEPT**, attested `836cdfec…`.
**PR #112.**

**Bug found + fixed (S107):** the first `v0.1.0` tag run stalled — the `macos-13` (Intel) runner sat
queued indefinitely while the other two targets built in ~22–31s. Vajra is pure Rust (no C deps), so
`x86_64-apple-darwin` now cross-compiles on the plentiful `macos-latest` Apple-Silicon runner. Reviewer
ran `file` on the released binary → genuine `Mach-O x86_64`.

**🔀 FOUNDER PIVOT (S103, still in force):** sessions now = **finish a shippable MVP**; the founder runs
the long unattended test himself, then release. Order **C → B → A**: C (team voice) = S104 ✓ →
**B (installable) = S106 (Rust path + instrument) + S107 (no-Rust prebuilt path) ✓** → **A (real named
agent fleet), the next major**. Interim **S108 = publish crates.io + brew** (finish every install channel).

## Active PRs
- **S107:** [#112](https://github.com/ifelse-codes/vajra/pull/112) (`session-107-tagged-binary-release`) —
  release smoke mode + `release.yml` fix + README un-mark + verify/demo. Cold review ACCEPT, attested
  `836cdfec…`. To merge at founder direction (use a **merge commit** — the `v0.1.0` tag points at
  `718ec68`, which must stay reachable from main).
- Merged: **S106 [#111](https://github.com/ifelse-codes/vajra/pull/111)** · S105 follow-up
  [#110](https://github.com/ifelse-codes/vajra/pull/110) · S105 #109 · S104 #108 · S103 · S102 · S101 · S100.

## Direction (governance is the product — now shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust layer**.
  Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained tamper-evident
  (`DECISION-004`). **No pivot in the product** — the S103 pivot is in HOW we spend sessions (finish the
  MVP, not run paid ladders).
- **Post-pivot roadmap:** C team-voice (S104 ✓) → **B installable v0.1 (S106 Rust path + instrument +
  S107 no-Rust prebuilt path) ✓** → **S108 publish crates.io + brew** → **A fleet**. Release when v0.1 is
  stranger-shippable; the founder owns the long unattended real-world test.
- **The machinery-freeze rule (`DECISION-005`) is RETIRED** (S105): the pivot cancelled ladder *sessions*.

## What Currently Works
- **v0.1 is installable THREE ways, each proven by a falsifiable instrument:** (1) `cargo install
  --git|--path` from a clean checkout (S106); (2) **a prebuilt binary a stranger downloads with no Rust**
  (S107) — the `v0.1.0` release ships 3 tarballs + `.sha256`; `VAJRA_SMOKE_SOURCE=release
  install-smoke.sh` downloads for the host, verifies sha256, extracts, runs `init`→`next`, **exits
  non-zero if broken** (11/11 live, fail-closed both ways). crates.io + brew stay honestly NOT YET
  PUBLISHED until S108.
- **The 8-station governed pipeline speaks like a team** (S104): `vajra next --stations` + the packet
  render named roles + plain status from one source; gates/K unchanged underneath.
- **Autopilot governance PROVEN with a FORCED block (S103):** on chitra a good-faith agent's commit was
  STOPPED by L3 `hook-commit-guard.sh` even under `--dangerously-skip-permissions`; a
  detached/resumable/budget-capped harness ran 6 tasks and its kill-switch fired on cap (Rung 2 PASS).
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner · Coder ·
  QA · Demo-er · Releaser · Reviewer (fidelity gate + attested, chained ledger). Receipt AUTHORITATIVE
  when `total_cost_usd` exists, HONEST when it doesn't (S77); closeout blocks unfilled execution shas
  (S81); `--dogfood-age` live git query (S91; un-blinded S105 follow-up).
- **Ledger** (S100): `verify-closeout.sh --ledger-verify` → INTACT, tamper-evident (`DECISION-004`).
- **CI green on `main`** (both OS); **`release.yml` fires a real tag → GH release with prebuilt binaries**
  (proven S107) · `vajra claude · next · check · init · estimate · meter · hook` — 7 commands, no 8th.

## What Is Broken / Weak
- **🟡 crates.io + Homebrew are NOT YET PUBLISHED.** The two remaining README rows. **S108 target**
  (founder pick B). crates.io publish is IRREVERSIBLE (the name burns) — hard founder gate.
- **🟡 The x86_64 prebuilt binaries are proven by architecture + checksum, never EXECUTED.** The release
  smoke runs only the host-platform tarball (aarch64 on the arm64 dev box / CI); the cross-compiled macOS
  x86_64 binary can't run on an arm64 runner. `file` + sha256 pass, so runtime failure is unlikely, but
  "an Intel-Mac stranger can install *and run*" is asserted, not executed (S107 fakest green, disclosed).
- **🟡 The blocking close-gate omits the positive live download.** `verify-session-107.sh` + the demo
  gating cases are offline (assert fail-closed + grep release-mode code); the AC2 *pass* direction is
  proven by a captured artifact + the cold reviewer, not the gate (a gate must not depend on the network).
- **🟡 `--dogfood-age` durable code fix still open.** Make `dogfood_age()` recurse into per-run subdirs
  (`src/dogfood/mod.rs:63-66`) so future dogfoods needn't add an aggregate receipt by hand.
- **🟡 `vajra --version` gap.** A stranger who types `vajra --version` gets usage, not a version string.
- **🟡 KNOWLEDGE §6 bloat GROWING** (chronic since S60): ~475 lines / ~91K tokens; prune queued, not done.
- **🟡 `vajra.varta` re-render drifts every session** — `vajra check` FAILs "varta stale"; no CLOSEOUT
  gate reads it, so fixes don't stick. A durable gate is the real fix.
- **🟡 `fable-5` monthly credits exhausted (S102).** Paid dogfood costs real $ on sonnet/opus.
- **🟡 Old repos ship without guards (S102)** · **In THIS repo the commit gate is auditable-not-un-forgeable**
  (L3 `commit_guard: off`; L2 belt active) · **Compression no-op on real CC** (never claim until measured)
  · **Cross-agent breadth 0 code** · **Legacy opus ids** held at $15/$75.

## What Is In Progress
- **S107 DONE (CODE — no-Rust prebuilt path; release live; ACCEPT, attested).** PR #112 to merge.
- **Next = S108 — CODE: publish crates.io + Homebrew tap** (founder pick B): publish `vajractl` to
  crates.io (IRREVERSIBLE, founder-gated) + a tap formula installing the `v0.1.0` release binary → un-mark
  the last two README rows. Prompt: `prompts/108-task-publish-crates-brew.md`. **New chat.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- Session 53–75: ~$0 each. **S76: real but UNKNOWN** (fable-5 unpriced; opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713** · **S97: $1.2758** · **S102: $0.4644** ·
  **S103: $0.6797** (all authoritative). **S104–107: ~$0 each** (local build/test/cold-review; no paid
  `vajra claude` run — S107 spent only a cold-review subagent + CI minutes).
- Cumulative: **~$79.3 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
