# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**None — between sessions (S120 GT complete, S121 not yet started).**

S120 was a mandatory NO-CODE Ground Truth (120 % 5 == 0). Verdict: PARTIAL PASS. Full report at
`sessions/session-120-ground-truth.md`. Key findings filed, not fixed (GT rule).

## Active PRs
- **No open PRs.** S119 (#129) MERGED 2026-08-17.
- Prior: **S118 [#128](https://github.com/ifelse-codes/vajra/pull/128) MERGED** · S117 #126 · S114
  #122 · S113 #120 · S112 #118 (+#119) · S111 #117 · S109 #115 · S110 #116 · S108 #113/#114 · S107
  #112 · S106 #111 · S116 merged inside #125.

## Direction (governance is the product — now shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust
  layer**. Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). The fleet = **real named agents behind the existing gates**
  (`DECISION-007`) — THREE roles built, **ALL THREE proven dispatched by name**.
- **Post-pivot roadmap:** C team-voice (S104 ✓) → **B installable v0.1 ✓ COMPLETE** → **A fleet
  COMPLETE (3 roles)** → Dogfood S118 ✓ → S119 ✓ (clean-room runner) → **S120 ✓ MANDATORY GT →
  S121 = CODE: QA specialist (fleet role 4, first full-execution agent).**

## What Currently Works
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner ·
  Coder · QA · Demo-er · Releaser · Reviewer. Receipt AUTHORITATIVE (S78 tee path).
- **The fleet has THREE named roles, ALL proven dispatched by name.** `vajra init` scaffolds all
  three `.claude/agents/*.md` files; `vajra next --role <key> --from <file>` governs any of the
  three; `vajra next --stations NN` reports fleet evidence beside `K of 8`.
- **The clean-room runner (S119).** QA and Demo-er route scripts through a fresh `git worktree add
  --detach` checkout of HEAD when `verify.clean_room.enabled: true` (default off). Bootstrap
  command support; failure → `CannotEvaluate` → BLOCK. `VAJRA_SKIP_CLEAN_ROOM=1` escape.
  `vajra init` scaffolds the new keys. Falsifiability fixture: working tree passes with stale
  artifact, clean room fails — the exact defect CI caught at S118.
- **Ledger** (S100): `verify-closeout.sh --ledger-verify` last confirmed INTACT at S115. Ledger is
  DERIVED from `sessions/session-NN-review.md` via `_ledger_read()` in verify-closeout.sh. No
  separate `.ai/ledger/` directory — by design.
- **v0.1 install: CONFIRMED stranger-shippable (S110 GT).** Four channels, all real.
- **CI green on `main`** (both OS); 7 commands, no 8th. 334 lib tests.

## What Is Broken / Weak
- **🔴 Coder-dark for S119 (S120 finding):** `## Execution` step 7 records prose ("cold
  fidelity-reviewer pass ACCEPT") not a commit sha — `git cat-file -e <sha>^{commit}` fails.
  Steps 1-6 have real shas. Legitimate non-commit evidence breaks the gate; filed not fixed.
- **🟡 3 behavioral source greps in verify-session-119.sh (S120 finding):** `init_scaffold_has_clean_room`
  (greps source template), `skip_env_var_referenced` (greps env var name in src), `run_location_printed`
  (the S119 disclosed fakest green). Pattern widespread in older scripts (S19, S21) + fleet sessions.
- **🟡 VISION.md stale (S120 finding):** (1) clean-room runner not in body; (2) Rules section still
  references the retired machinery-freeze rule (freeze RETIRED at S103; preamble says SUPERSEDED
  but Rules body does not).
- **🟡 The clean-room runner is not tested via the compiled CLI path** (`--check-qa` / `--check-demo`
  with `clean_room: true`). Unit tests inject closures; no end-to-end exercise.
- **🟡 The Planner-gate double-count bug** (`src/planner/mod.rs::is_acceptance_heading`,
  `task_2162b487`) — carried, still unfixed.
- **🟡 `vajra next --dogfood-age` does not recurse into artifact subdirectories** (named S115).
- **🟡 `no-eighth-command` checks are a grep for a hardcoded usage banner** (8+ consecutive CODE
  sessions flagged) · **🟡 KNOWLEDGE §6 bloat at 642 lines** (10 GTs flagged, unfixed) · **🟡
  `vajra.varta` re-render drifts every session** · **🟡 `vajra --version` gap** · **🟡 brew
  smoke tests LOCAL formula**.
- **🟡 The grep-only-verify detector** (S118 candidate A, deferred at S120 in favor of the QA
  specialist agent) — not yet built.
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** (L3 `commit_guard: off`; L2
  belt active) · **Compression no-op on real CC** · **Cross-agent breadth 0 code**.

## What Is In Progress
- **S120 DONE (MANDATORY GT, PARTIAL PASS).** Report: `sessions/session-120-ground-truth.md`.
- **S121 = CODE: QA specialist agent (fleet role 4).** `prompts/121-task-qa-specialist-agent.md`.
  First fleet agent with full execution capability (Bash, Read, Write, Edit, Grep, Glob). Runs
  the session's verify script, classifies checks, reports what actually exercised the product.
  Same zero-new-machinery shape as S114 and S116. Dispatch proof is S122's job.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative. S36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- S53–75: ~$0 each. **S76: real but UNKNOWN** (opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713** · **S97: $1.2758** · **S102: $0.4644** ·
  **S103: $0.6797** (all authoritative). **S104–109: ~$0 each.**
- **S110: $0 (NO-CODE GT).** **S111–S117: $0 metered for build** (subagent tokens roll in unitemized).
- **S118: $4.0911771** authoritative (sonnet, headless `-p`, 1331s).
- **S119: $0 metered** (interactive session; fidelity-reviewer subagent tokens roll in, unitemized).
- **S120: $0** (NO-CODE GT).
- Cumulative: **~$83.4 + S76 (unknown, ≤ ~$26.6 opus-estimate) + S111–S120 subagents (unknown, small).**
