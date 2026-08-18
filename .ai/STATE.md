# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**`session-121-qa-specialist` — S121 COMPLETE, PR open to `main`.**

S121 built the fleet's FOURTH role, the QA Specialist — the first that can execute. Cold
fidelity-reviewer ACCEPT (5 of 6 SHIPPED, 1 PARTIAL, 0 NOT-BUILT), attested
`c92a2dad3377f48980458e8a71252b8267948e54badf3b3c6e32683ece48e7a9`. Summary:
`sessions/session-121-summary.md`. Review: `sessions/session-121-review.md`.

## Active PRs
- **S121 — OPEN** (this session's branch → `main`). S120 (#130) MERGED · S119 (#129) MERGED
  2026-08-17.
- Prior: **S118 [#128](https://github.com/ifelse-codes/vajra/pull/128) MERGED** · S117 #126 · S114
  #122 · S113 #120 · S112 #118 (+#119) · S111 #117 · S109 #115 · S110 #116 · S108 #113/#114 · S107
  #112 · S106 #111 · S116 merged inside #125.

## Direction (governance is the product — now shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust
  layer**. Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). The fleet = **real named agents behind the existing gates**
  (`DECISION-007`) — **FOUR roles built; three proven dispatched by name; the fourth
  (`qa-specialist`, S121) not yet dispatched — that is S122.**
- **Post-pivot roadmap:** C team-voice (S104 ✓) → **B installable v0.1 ✓ COMPLETE** → **A fleet
  COMPLETE (3 roles)** → Dogfood S118 ✓ → S119 ✓ (clean-room runner) → S120 ✓ MANDATORY GT →
  **S121 ✓ QA Specialist built (fleet role 4, the first that EXECUTES) → S122 = prove its by-name
  dispatch + the FIRST LIVE QA run.**

## What Currently Works
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner ·
  Coder · QA · Demo-er · Releaser · Reviewer. Receipt AUTHORITATIVE (S78 tee path).
- **The fleet has FOUR named roles.** Researcher · Fidelity Reviewer · Plan Advisor (all three
  proven dispatched by name) · **QA Specialist (S121, built, NOT yet dispatched).** `vajra init`
  scaffolds all four `.claude/agents/*.md` files; `vajra next --role <key> --from <file>` governs
  any of them; `vajra next --stations NN` reports fleet evidence beside `K of 8`.
- **Exactly one role executes.** `qa-specialist` holds `Bash, Read, Write, Edit, Grep, Glob`; the
  other three stay read-only, enforced as a named allowlist of one (a fifth role cannot inherit
  Bash by being added to the table). `DECISION-007` S121 addendum.
- **The clean-room runner (S119).** QA and Demo-er route scripts through a fresh `git worktree add
  --detach` checkout of HEAD when `verify.clean_room.enabled: true` (default off). Bootstrap
  command support; failure → `CannotEvaluate` → BLOCK. `VAJRA_SKIP_CLEAN_ROOM=1` escape.
  `vajra init` scaffolds the new keys. Falsifiability fixture: working tree passes with stale
  artifact, clean room fails — the exact defect CI caught at S118.
- **Ledger** (S100): `verify-closeout.sh --ledger-verify` last confirmed INTACT at S115. Ledger is
  DERIVED from `sessions/session-NN-review.md` via `_ledger_read()` in verify-closeout.sh. No
  separate `.ai/ledger/` directory — by design.
- **v0.1 install: CONFIRMED stranger-shippable (S110 GT).** Four channels, all real.
- **CI green on `main`** (both OS); 7 commands, no 8th. **335 lib tests.**

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
- **🔴 The S121 check-class tally is a SELF-ASSIGNED LABEL (cold-review finding).** Nothing checks
  that a check marked `exec` executes anything — relabel them all and the summary still prints
  `behavioral source grep: 0`. Same class as S64's `covers:` digit-tag and S67's design marker.
  **Never cite that number as a measurement.** Option B at the S121 close (make it machine-derived)
  is unbuilt and unpicked.
- **🟡 `vajra init` hangs forever on stdin without EOF** (found live S121; 10 minutes lost inside
  `verify-session-113.sh`). `verify-session-121.sh` redirects `</dev/null`; older scripts do not.
- **🟡 `verify-session-116.sh` is red by construction** against S121+: the fleet grew to four and the
  every-role-is-read-only invariant was deliberately changed (test renamed, not loosened). Fourth
  session of per-session-snapshot decay; disclosed in a comment, which is not a gate.
- **🟡 The grep-only-verify detector** (S118 candidate A, deferred at S120 in favor of the QA
  specialist agent) — not yet built.
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** (L3 `commit_guard: off`; L2
  belt active) · **Compression no-op on real CC** · **Cross-agent breadth 0 code**.

## What Is In Progress
- **S121 DONE (CODE, ACCEPT).** The QA Specialist role, `verify-session-121.sh` 17/17.
- **S122 = CODE: prove `subagent_type: "qa-specialist"` dispatches by name + the FIRST LIVE QA
  run** (founder pick A at the S121 close). `prompts/122-task-qa-specialist-dispatch.md`. The
  live run is the point: S121's claim that *an executor cannot fake a pass* is untested. A flat,
  agreeable report from the agent is a REAL finding to record, never softened into a success.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative. S36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- S53–75: ~$0 each. **S76: real but UNKNOWN** (opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713** · **S97: $1.2758** · **S102: $0.4644** ·
  **S103: $0.6797** (all authoritative). **S104–109: ~$0 each.**
- **S110: $0 (NO-CODE GT).** **S111–S117: $0 metered for build** (subagent tokens roll in unitemized).
- **S118: $4.0911771** authoritative (sonnet, headless `-p`, 1331s).
- **S119: $0 metered** (interactive session; fidelity-reviewer subagent tokens roll in, unitemized).
- **S120: $0** (NO-CODE GT).
- **S121: $0 metered** (interactive; one `fidelity-reviewer` subagent pass ≈56k subagent tokens,
  rolls in unitemized). No paid dogfood run.
- Cumulative: **~$83.4 + S76 (unknown, ≤ ~$26.6 opus-estimate) + S111–S121 subagents (unknown, small).**
