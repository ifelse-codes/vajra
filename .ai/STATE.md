# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**None — between sessions (S119 complete, S120 not yet started).**

S119 (`session-119-clean-room-rerun`) delivered the clean-room runner. **Verdict: ACCEPT** — cold
`fidelity-reviewer` pass, 8/8 SHIPPED. No paid spend. PR to be opened.

## Active PRs
- **S119 PR not yet opened** as of this snapshot.
- Prior: **S118 [#128](https://github.com/ifelse-codes/vajra/pull/128) MERGED** · S117 #126 · S114
  #122 · S113 #120 · S112 #118 (+#119) · S111 #117 · S109 #115 · S110 #116 · S108 #113/#114 · S107
  #112 · S106 #111 · S116 merged inside #125.

## Direction (governance is the product — now shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust
  layer**. Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). The fleet = **real named agents behind the existing gates**
  (`DECISION-007`) — THREE roles built, **ALL THREE now proven dispatched by name**.
- **Post-pivot roadmap:** C team-voice (S104 ✓) → **B installable v0.1 ✓ COMPLETE** → **A fleet
  COMPLETE** → Dogfood S118 ✓ → **S119 ✓ (CODE, clean-room runner) → S120 = mandatory GT.**

## What Currently Works
- **The clean-room runner (S119).** QA and Demo-er route scripts through a fresh `git worktree add
  --detach` checkout of HEAD when `verify.clean_room.enabled: true` (default off). A bootstrap
  command may be configured; failure → `CannotEvaluate` → BLOCK. `VAJRA_SKIP_CLEAN_ROOM=1` escape.
  `vajra init` scaffolds the new keys. Falsifiability fixture: working tree passes with stale
  artifact, clean room fails — the exact defect CI caught at S118.
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner ·
  Coder · QA · Demo-er · Releaser · Reviewer. Receipt AUTHORITATIVE (S78 tee path).
- **The fleet has THREE named roles, ALL proven dispatched by name.** `vajra init` scaffolds all
  three `.claude/agents/*.md` files; `vajra next --role <key> --from <file>` governs any of the
  three; `vajra next --stations NN` reports fleet evidence beside `K of 8`.
- **Ledger** (S100): `verify-closeout.sh --ledger-verify` last confirmed INTACT at S115.
- **v0.1 install: CONFIRMED stranger-shippable (S110 GT).** Four channels, all real.
- **CI green on `main`** (both OS); 7 commands, no 8th.

## What Is Broken / Weak
- **🔴 Fakest green (S119 disclosed):** `run-location-printed-in-output` in verify-session-119.sh
  greps source strings — the same hollow pattern S118 identified as the root cause. The feature is
  real; the verify check is not a live exercise.
- **🟡 The clean-room runner is not tested via the compiled CLI path** (`--check-qa` / `--check-demo`
  with `clean_room: true`). Unit tests inject closures; no end-to-end exercise.
- **🟡 The Planner-gate double-count bug** (`src/planner/mod.rs::is_acceptance_heading`,
  `task_2162b487`) — carried, still unfixed.
- **🟡 `vajra next --dogfood-age` does not recurse into artifact subdirectories** (named S115).
- **🟡 `no-eighth-command` checks are a grep for a hardcoded usage banner** (8 consecutive CODE
  sessions flagged) · **🟡 KNOWLEDGE §6 bloat past 550 lines** · **🟡 `vajra.varta` re-render
  drifts every session** · **🟡 `vajra --version` gap** · **🟡 brew smoke tests LOCAL formula**.
- **🟡 `fable-5` monthly credits exhausted (S102).** Paid dogfood costs real $.
- **🟡 The grep-only-verify detector** (S118 candidate A, deferred by S119) — not yet built.
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** (L3 `commit_guard: off`; L2
  belt active) · **Compression no-op on real CC** · **Cross-agent breadth 0 code**.

## What Is In Progress
- **S119 DONE (CODE, ACCEPT).** PR not yet opened. `sessions/session-119-summary.md` + review.
- **S120 = mandatory GT** (`120 % 5 == 0`). Founder picks one of S119's A/B/C options after
  reviewing the session. S120 GT may surface the grep-only-verify pattern in other verify scripts.
- **chitra is left on `session-11-catalog-two-panel`, LOCAL — not pushed, no PR**, by instruction.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative. S36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- S53–75: ~$0 each. **S76: real but UNKNOWN** (opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713** · **S97: $1.2758** · **S102: $0.4644** ·
  **S103: $0.6797** (all authoritative). **S104–109: ~$0 each.**
- **S110: $0 (NO-CODE GT).** **S111–S117: $0 metered for build** (subagent tokens roll in unitemized).
- **S118: $4.0911771** authoritative (sonnet, headless `-p`, 1331s).
- **S119: $0 metered** (interactive session; fidelity-reviewer subagent tokens roll in, unitemized).
- Cumulative: **~$83.4 + S76 (unknown, ≤ ~$26.6 opus-estimate) + S111–S119 subagents (unknown, small).**
