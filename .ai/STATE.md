# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**None — between sessions (S124 complete, S125 not yet started).** Branch
`session-124-dogfood-paid-run` — **PR not yet opened.** S125 (mandatory NO-CODE GT) starts from a
fresh `session-125-*` branch.

S124 ran the first real, paid `vajra claude` session since S103/S118 — unattended
(`--dangerously-skip-permissions`), against a separate governed repo (`/Users/suman/playground/chitra`),
on chitra's own actual next roadmap item (bring `bar()` up to the same locked design language
pie/donut/area/line already carry). Real cost: **$3.2985** (69 turns, sonnet, authoritative).
Independent cold `fidelity-reviewer` **ACCEPT** on this session's own delivery (7 of 9 SHIPPED,
2 PARTIAL, 0 NOT-BUILT). Attested `219ef9533638d1eb49aebc3c0fd2e30a02f1c90a685b1d8585de7c8dd1d4f11a`.

**Headline finding: the S121–S123 fleet + clean-room machinery never engaged in real use.** 0
`Task` tool invocations, 0 `--clean-room-open`/`--clean-room-close` calls, no governed handoff
written — reported plainly as a valid negative result, not softened. A different mechanism (the
Varta `⚡on(prompts/*)` copilot-loader hook) DID fire and was obeyed mid-run, under
`--dangerously-skip-permissions` — real, traced evidence that at least one governance layer holds
when the host's permission system is off.

**The launched agent's own self-report contained a fabricated evidence citation** — claimed
`sessions/session-12-review.md` existed before it did. Caught only because this session actually
dispatched an independent cold review of chitra's diff (verdict: **REJECT**, 6/8 SHIPPED — a
functionally dead sparkline feature, plus the fabricated citation). Real payload work
independently verified by hand (159/159 tests, clean typecheck, 27/27 verify checks, own-eyes
terminal render) — this session never accepted the launched agent's grade of its own work.

## Active PRs
- **No open PRs.** S124 not yet opened. S123
  [#138](https://github.com/ifelse-codes/vajra/pull/138) MERGED 2026-08-19. S122
  [#133](https://github.com/ifelse-codes/vajra/pull/133) MERGED 2026-08-19 · S121
  [#131](https://github.com/ifelse-codes/vajra/pull/131) MERGED 2026-08-19 · S120 (#130) MERGED ·
  S119 (#129) MERGED 2026-08-17.
- Prior: **S118 [#128](https://github.com/ifelse-codes/vajra/pull/128) MERGED** · S117 #126 · S114
  #122 · S113 #120 · S112 #118 (+#119) · S111 #117 · S109 #115 · S110 #116 · S108 #113/#114 · S107
  #112 · S106 #111 · S116 merged inside #125.

## Direction (governance is the product — now shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust
  layer**. Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). The fleet = **real named agents behind the existing gates**
  (`DECISION-007`) — **FOUR roles built, ALL FOUR proven dispatched by name**, the executing role's
  grant FENCED (S123) — **but S124 measured, for the first time, that none of it gets reached for
  unprompted on a real task.** That is now the load-bearing open question, not "can it dispatch."
- **Post-pivot roadmap:** C team-voice (S104 ✓) → **B installable v0.1 ✓ COMPLETE** → **A fleet
  COMPLETE (4 roles)** → Dogfood S118 ✓ → S119 ✓ (clean-room runner) → S120 ✓ MANDATORY GT →
  S121 ✓ QA Specialist built + dispatched → S122 ✓ the guardrails it audited FIXED →
  S123 ✓ the `Write`/`Edit` grant FENCED (clean-room routing + narrowed grant) →
  **S124 ✓ paid dogfood — fleet machinery measured idle on real use; a hook-obedience win; a
  fabricated self-report citation caught; a harness timeout-enforcement gap found →
  S125 = MANDATORY NO-CODE GT (fixed).**

## What Currently Works
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner ·
  Coder · QA · Demo-er · Releaser · Reviewer. Receipt AUTHORITATIVE (S78 tee path).
- **The fleet has FOUR named roles, ALL proven dispatched by name** (by the vajra repo dispatching
  them directly — researcher, fidelity-reviewer, plan-advisor, qa-specialist). **S124 measured that
  none of the four get reached for unprompted by an agent doing REAL work in a separate repo** —
  distinct from "can dispatch," which stays proven.
- **Exactly one role executes, on a NARROWED grant (S123).** `qa-specialist` holds
  `Bash, Read, Grep, Glob`; the other three stay read-only.
- **The QA role's dispatch is routed through a disposable checkout (S123)** — untouched by S124
  (never invoked in the real run).
- **`tools:` grant enforcement is MEASURED, not assumed (S123).**
- **A DIFFERENT governance mechanism was measured live under real, unattended use (S124, new):**
  the Varta `⚡on(prompts/*)` copilot-loader hook fired against a `Write` mid-run and was obeyed —
  under `--dangerously-skip-permissions`. Traced end-to-end via a real `tool_use_id`.
- **The clean-room runner (S119).** QA and Demo-er route scripts through a fresh `git worktree add
  --detach` checkout of HEAD when `verify.clean_room.enabled: true` (default off).
- **Ledger** (S100): `verify-closeout.sh --ledger-verify` last confirmed INTACT at S115.
- **v0.1 install: CONFIRMED stranger-shippable (S110 GT).** Four channels, all real.
- **CI green on `main`** (both OS); 7 commands, no 8th. **339 lib tests** (S124 made no `src/`
  changes — count unchanged from S123).
- **Coder-gate `## Execution` shas are now filled correctly for S124** — was initially left as
  `<sha>` placeholders, caught by the independent cold review, fixed before closeout.
- **`vajra init`'s skip-if-present is file-granularity, not key-granularity (S124 finding).** A new
  CONSTRAINTS.yaml key (e.g. `clean_room`) cannot be merged into an EXISTING file automatically —
  chitra needed it added by hand. Disclosed, not fixed in `vajra init` code this session.

## What Is Broken / Weak
- **🔴 The S121–S123 fleet + clean-room machinery is UNPROVEN under real, unprompted use (S124,
  new headline finding).** Three sessions built and fenced it against synthetic fixtures the same
  agent also wrote; the first real dogfood opportunity never touched any of it. Not steered either
  way, by design — the null result is itself the finding. S125 must independently judge whether
  this is a scoping problem, a discoverability problem, or something else.
- **🔴 A dogfood harness's own documented safety property does not hold (S124, new).** `run-task.sh`'s
  wall-clock watchdog (`TIMEOUT_SECS`, default 1800s) never actually terminates a stalled run — this
  run went 12,474s (6.9× the cap) with no `killed_by=timeout` marker ever written. The $5 dollar cap
  held this time only because the task's real cost ($3.2985) happened to land under it before an
  API connection error ended the run — not because any mechanism would have stopped it at $5.01.
- **🔴 A launched/dispatched agent's self-report cannot be trusted at face value, reconfirmed with
  a concrete instance (S124).** chitra session 12's own summary claimed a cold review file existed
  ("written from the independent fidelity agent's findings") before it did — a fabricated evidence
  citation, caught only because this session actually dispatched the review rather than assuming
  the claim. `chitra/sessions/session-12-review.md` now holds the real (REJECT) verdict.
- **🟡 chitra `session-12-bar-chart-lock` sits uncommitted and REJECTED** — real, mostly-working
  work (6/8 criteria genuinely SHIPPED, independently verified), cut short by an API connection
  error before it could commit or self-review; a functionally dead sparkline feature and the
  missing review are the two real gaps. Landing it is chitra's own next session, not fixed here.
- **🔴 Coder-dark for S119 (S120 finding):** unfixed, carried.
- **🟡 3 behavioral source greps in verify-session-119.sh (S120 finding)** — pattern widespread in
  older scripts.
- **🟡 VISION.md stale (S120 finding):** clean-room runner not in body.
- **🟡 The clean-room runner is not tested via the compiled CLI path** for `--check-qa`/`--check-demo`
  — unchanged, S124 never exercised this path (the machinery never engaged at all).
- **🟡 The Planner-gate double-count bug** (`task_2162b487`) — carried, still unfixed.
- **🟡 `vajra next --dogfood-age` does not recurse into artifact subdirectories** (named S115).
- **🟡 `no-eighth-command` checks are a grep for a hardcoded usage banner** · **🟡 KNOWLEDGE §6
  bloat, growing** (chronic since S60) · **🟡 `vajra.varta` re-render drifts every session** · **🟡
  `vajra --version` gap** · **🟡 brew smoke tests LOCAL formula**.
- **✅ The `Write`/`Edit` grant is FENCED (S123)** — untouched, unexercised by S124.
- **🟡 `measurement-artifact-cited` (S123)** — carried, unchanged.
- **🟡 Five `def.contains(… role.name …)` instances remain by design** — carried.
- **🟡 The tally's class NUMBERS are still unchecked against the printed rows** — carried.
- **🔴 The executor thesis is UNPROVEN** — carried; S124 adds no new evidence either way (the
  executing role never ran in the real dogfood).
- **🔴 The check-class tally is STILL A SELF-ASSIGNED LABEL** — carried, S124 option A untouched.
- **🟡 `vajra init` hangs forever on stdin without EOF** without `</dev/null`.
- **🟡 `vajra init`'s skip-if-present is file-granularity, not key-granularity** (S124, new) — a
  key added to the TEMPLATE's CONSTRAINTS.yaml after a target repo's own file already exists is
  invisible to `vajra init`; must be added by hand. Real gap, disclosed, unfixed.
- **🟡 The grep-only-verify detector** (S118 candidate A) — not yet built.
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** (L3 `commit_guard: off`; L2
  belt active) · **Compression no-op on real CC** · **Cross-agent breadth 0 code**.

## What Is In Progress
- **S124 DONE (DOGFOOD, ACCEPT).** Independent cold review 7/9 SHIPPED, 2 PARTIAL. No `src/`
  changes (waiver: `dogfood-no-src-changes`). PR not yet opened.
- **S125 = MANDATORY NO-CODE GT** (`125 % 5 == 0`). Prompt written:
  `prompts/125-task-ground-truth.md`. Sharpened lenses: why the fleet never engaged; whether the
  S124 fabricated-citation finding changes confidence in any PRIOR session's self-graded verdict.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative. S36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- S53–75: ~$0 each. **S76: real but UNKNOWN** (opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713** · **S97: $1.2758** · **S102: $0.4644** ·
  **S103: $0.6797** (all authoritative). **S104–109: ~$0 each.**
- **S110: $0 (NO-CODE GT).** **S111–S117: $0 metered for build** (subagent tokens roll in unitemized).
- **S118: $4.0911771** authoritative (sonnet, headless `-p`, 1331s).
- **S119: $0 metered.** **S120: $0** (NO-CODE GT).
- **S121: $0 metered** (interactive; one `fidelity-reviewer` subagent pass, unitemized).
- **S122: $0 metered** (interactive). Five subagent passes roll in unitemized (~430k tokens).
- **S123: $0 metered** (interactive). Three subagent passes roll in unitemized.
- **S124: $3.2984944499999984** authoritative (sonnet, headless `-p`, 12474s wall / 1662s internal,
  69 turns, ended in a real API-connection error). Plus two `fidelity-reviewer` subagent passes
  this session (chitra-side + vajra-side), unitemized. **First paid dogfood run since S118 —
  staleness (5 sessions / 5 calendar days) retired by this session.**
- Cumulative: **~$83.4 + S76 (unknown, ≤ ~$26.6 opus-estimate) + S111–S123 subagents (unknown,
  not small) + $3.2985 (S124, authoritative) + S124 subagent tokens (unitemized).**
