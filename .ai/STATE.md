# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S108 complete, S109 not yet started).
S108 = **CODE: publish to crates.io + Homebrew tap** — the C→B→A order's **B**, now COMPLETE (every
install channel is real). **Goal achieved:** `vajractl 0.1.0` published to crates.io (proven live by a
fresh-dir `cargo install vajractl` → `init`→`next`, **7/7 SMOKE PASS**; API confirms `max_version
0.1.0`) + a public Homebrew tap `ifelse-codes/homebrew-tap` (`Formula/vajra.rb` with real `v0.1.0`
sha256 for arm64/x86_64 macOS + x86_64 Linux; proven `brew install ifelse-codes/tap/vajra`, **11/11
SMOKE PASS**, sha256-verified). `install-smoke.sh` gained `crates` + `brew` modes, both **fail-closed**.
README un-marks both rows (nothing left `NOT YET PUBLISHED`). `Cargo.toml` excludes two stray root HTML
files from the package. **No `src/`; no station logic changed.** verify **10/10**; demo exit 0 (4
markers); independent cold review **ACCEPT**, attested `f5a97e8b…`. **PR #113.**

**Irreversible step done with founder gate (S108):** `cargo publish` ran ONLY after an explicit in-chat
"yes publish"; the founder ran `cargo login` themselves (the token was never handled by the agent). The
public tap repo was created only after an explicit "yes tap". The name `vajractl` is now BURNED.

**🔀 FOUNDER PIVOT (S103, still in force):** sessions now = **finish a shippable MVP**; the founder runs
the long unattended test himself, then release. Order **C → B → A**: C (team voice) = S104 ✓ →
**B (installable) = S106 (Rust path) + S107 (prebuilt) + S108 (crates.io + brew) ✓ — B COMPLETE** →
**A (real named agent fleet), the next major (S109 = first slice).**

## Active PRs
- **S108:** [#113](https://github.com/ifelse-codes/vajra/pull/113) (`session-108-publish-crates-brew`) —
  crates+brew smoke modes + real formula shas + README truth-pass + verify/demo. Cold review ACCEPT,
  attested `f5a97e8b…`. To merge at founder direction.
- Merged: **S107 [#112](https://github.com/ifelse-codes/vajra/pull/112)** · S106 #111 · S105 follow-up
  #110 · S105 #109 · S104 #108 · S103 · S102 · S101 · S100.

## Direction (governance is the product — now shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust layer**.
  Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained tamper-evident
  (`DECISION-004`). **No pivot in the product** — the S103 pivot is in HOW we spend sessions (finish the
  MVP, not run paid ladders).
- **Post-pivot roadmap:** C team-voice (S104 ✓) → **B installable v0.1 (S106 + S107 + S108) ✓ COMPLETE**
  → **A fleet (S109 = fleet slice 1, a real named Researcher agent behind the gates).** Release when
  v0.1 is stranger-shippable (it now is); the founder owns the long unattended real-world test.
- **The machinery-freeze rule (`DECISION-005`) is RETIRED** (S105): the pivot cancelled ladder *sessions*.

## What Currently Works
- **v0.1 is installable FOUR ways, each proven by a falsifiable instrument:** (1) `cargo install
  --git|--path` from a clean checkout (S106); (2) **a prebuilt binary a stranger downloads with no Rust**
  (S107 — `v0.1.0` release, 3 tarballs + `.sha256`); (3) **`cargo install vajractl` from crates.io**
  (S108 — `vajractl 0.1.0` live, 7/7 smoke); (4) **`brew install ifelse-codes/tap/vajra`** (S108 —
  public tap, sha256-verified, 11/11 smoke). `install-smoke.sh` has 5 modes (`path`/`git`/`release`/
  `crates`/`brew`), all **fail-closed**.
- **The 8-station governed pipeline speaks like a team** (S104): `vajra next --stations` + the packet
  render named roles + plain status from one source; gates/K unchanged underneath.
- **Autopilot governance PROVEN with a FORCED block (S103):** on chitra a good-faith agent's commit was
  STOPPED by L3 `hook-commit-guard.sh` even under `--dangerously-skip-permissions`; a
  detached/resumable/budget-capped harness ran 6 tasks and its kill-switch fired on cap (Rung 2 PASS).
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner · Coder ·
  QA · Demo-er · Releaser · Reviewer (fidelity gate + attested, chained ledger). Receipt AUTHORITATIVE
  when `total_cost_usd` exists, HONEST when it doesn't (S77); closeout blocks unfilled execution shas
  (S81); `--dogfood-age` live git query (S91; un-blinded S105 follow-up).
- **Ledger** (S100): `verify-closeout.sh --ledger-verify` → INTACT, tamper-evident (`DECISION-004`);
  43 records incl. S108 ACCEPT.
- **CI green on `main`** (both OS); `release.yml` fires a real tag → GH release with prebuilt binaries
  (S107) · `vajra claude · next · check · init · estimate · meter · hook` — **7 commands, no 8th**.

## What Is Broken / Weak
- **🟡 The `brew` smoke tests a LOCAL copy of the formula, not the published tap** (S108 fakest green).
  The gating instrument stands up a throwaway local tap from `Formula/vajra.rb`, so it would stay green
  if the public `homebrew-tap` repo ever drifts from the in-repo formula. Proven byte-identical + the
  public-tap path run live this session (by the agent + the cold reviewer); durable fix = point the
  brew smoke at the published tap.
- **🟡 The x86_64 prebuilt binaries are proven by architecture + checksum, never EXECUTED** (S107). The
  smoke runs only the host-platform tarball; the cross-compiled x86_64 macOS binary can't run on arm64.
- **🟡 The blocking close-gate omits the positive live install.** verify + demo gating cases are offline
  (assert fail-closed + grep mode code); the positive crates/brew installs are captured as artifacts +
  re-run by the cold reviewer, not by the gate (a gate must not depend on the network).
- **🟡 `--dogfood-age` durable code fix still open.** Make `dogfood_age()` recurse into per-run subdirs
  (`src/dogfood/mod.rs:63-66`) so future dogfoods needn't add an aggregate receipt by hand. (S109-alt C)
- **🟡 `vajra --version` gap.** A stranger who types `vajra --version` gets usage, not a version string.
  (S109-alt B)
- **🟡 KNOWLEDGE §6 bloat GROWING** (chronic since S60): ~475 lines / ~91K tokens; prune queued, not done.
- **🟡 `vajra.varta` re-render drifts every session** — `vajra check` FAILs "varta stale"; no CLOSEOUT
  gate reads it, so fixes don't stick. A durable gate is the real fix.
- **🟡 `fable-5` monthly credits exhausted (S102).** Paid dogfood costs real $ on sonnet/opus.
- **🟡 Old repos ship without guards (S102)** · **In THIS repo the commit gate is auditable-not-un-forgeable**
  (L3 `commit_guard: off`; L2 belt active) · **Compression no-op on real CC** (never claim until measured)
  · **Cross-agent breadth 0 code** · **Legacy opus ids** held at $15/$75.

## What Is In Progress
- **S108 DONE (CODE — crates.io + brew published + proven; ACCEPT, attested).** PR #113 to merge. **B
  (installable) is COMPLETE.**
- **Next = S109 — CODE: fleet slice 1 — one real named agent (Researcher) as a governed step** (founder
  pick A, "start the fleet"): dispatch one named role with a role-scoped prompt + delta-tracked handoff,
  proven with a stub agent (no paid call); design-significant → author `DECISION-007`; ride an existing
  command (no 8th). Prompt: `prompts/109-task-fleet-slice-1-researcher.md`. **New chat.**
- **S110 = next mandatory NO-CODE ground truth** (lead lens: is v0.1 shippable to a stranger — proven by
  an instrument, not a feeling — and is the fleet advancing or just labelled?).

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- Session 53–75: ~$0 each. **S76: real but UNKNOWN** (fable-5 unpriced; opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713** · **S97: $1.2758** · **S102: $0.4644** ·
  **S103: $0.6797** (all authoritative). **S104–108: ~$0 each** (local build/test/cold-review; no paid
  `vajra claude` run — S108 spent only a cold-review subagent + `cargo publish` upload + brew/cargo installs).
- Cumulative: **~$79.3 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
