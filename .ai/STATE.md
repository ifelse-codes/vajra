# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**None — between sessions (S123 complete, S124 not yet started).** Branch
`session-123-fence-the-write-grant` — **PR not yet opened.** S124 starts from a fresh
`session-124-*` branch once the founder picks one of the three options at the S123 close.

S123 fenced the `qa-specialist` role's `Write`/`Edit` grant: closed S122's own two glued-on
fixtures, bound the duplicated tally to one source, MEASURED (not assumed) that Claude Code's
harness enforces a role's `tools:` grant, routed the role's dispatch through a disposable
`git worktree` checkout, and narrowed the grant itself. Cold `fidelity-reviewer` **pass 2 ACCEPT**
(5 of 6 SHIPPED, 0 PARTIAL, 0 NOT-BUILT). Summary: `sessions/session-123-summary.md`. Review:
`sessions/session-123-review.md`.

**Two cold passes were needed — REJECT → ACCEPT.** Pass 1 correctly rejected the `tools:`
enforcement claim as true-but-unfalsifiable prose (no artifact to check it against). Fixed in one
commit: a real cross-verified artifact reusing the S111 evidentiary shape (two independently-
written files agreeing on a tool-call ID neither side controlled). The dispatched `qa-specialist`,
running under the STALE pre-fence grant (S111 boot-snapshot limit), still found a real defect in
this session's own suite before the cold review ran, and changed nothing itself.

## Active PRs
- **No open PRs.** S123 not yet opened. S122
  [#133](https://github.com/ifelse-codes/vajra/pull/133) MERGED 2026-08-19 (CI green both OS;
  branch pruned local + remote). S121 [#131](https://github.com/ifelse-codes/vajra/pull/131)
  MERGED 2026-08-19 · S120 (#130) MERGED · S119 (#129) MERGED 2026-08-17.
- Prior: **S118 [#128](https://github.com/ifelse-codes/vajra/pull/128) MERGED** · S117 #126 · S114
  #122 · S113 #120 · S112 #118 (+#119) · S111 #117 · S109 #115 · S110 #116 · S108 #113/#114 · S107
  #112 · S106 #111 · S116 merged inside #125.

## Direction (governance is the product — now shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust
  layer**. Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). The fleet = **real named agents behind the existing gates**
  (`DECISION-007`) — **FOUR roles built, ALL FOUR proven dispatched by name**, and the last
  self-granted jurisdiction in the fleet (the executing role's `Write`/`Edit` grant) is now FENCED,
  not just documented (`DECISION-007` S123 addendum).
- **Post-pivot roadmap:** C team-voice (S104 ✓) → **B installable v0.1 ✓ COMPLETE** → **A fleet
  COMPLETE (4 roles)** → Dogfood S118 ✓ → S119 ✓ (clean-room runner) → S120 ✓ MANDATORY GT →
  S121 ✓ QA Specialist built + dispatched → S122 ✓ the guardrails it audited FIXED →
  **S123 ✓ the `Write`/`Edit` grant FENCED (clean-room routing + narrowed grant) →
  S124 = TBD (3 options presented, awaiting founder pick) →
  S125 = MANDATORY NO-CODE GT (fixed regardless of the S124 pick).**

## What Currently Works
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner ·
  Coder · QA · Demo-er · Releaser · Reviewer. Receipt AUTHORITATIVE (S78 tee path).
- **The fleet has FOUR named roles, ALL proven dispatched by name.** Researcher · Fidelity
  Reviewer · Plan Advisor · **QA Specialist (built + dispatched S121; three live runs now — four
  defects at S121, three at S122, one at S123).** `vajra init` scaffolds all four
  `.claude/agents/*.md` files; `vajra next --role <key> --from <file>` governs any of them;
  `vajra next --stations NN` reports fleet evidence beside `K of 8`.
- **Exactly one role executes, on a NARROWED grant (S123).** `qa-specialist` holds
  `Bash, Read, Grep, Glob` (was `Bash, Read, Write, Edit, Grep, Glob`); the other three stay
  read-only, enforced as a named allowlist of one. `DECISION-007` S121+S123 addenda.
- **The QA role's dispatch is routed through a disposable checkout (S123).** `vajra next --role
  qa-specialist --clean-room-open`/`--clean-room-close` materialise/remove a `git worktree` of
  HEAD, reusing S119's `CleanRoom` primitive split into a cross-process-persistent form
  (`open_persistent`/`remove_persistent`) since the actual dispatch happens in a separate,
  longer-lived Claude Code session, not inside a single `vajra` CLI call.
- **`tools:` grant enforcement is MEASURED, not assumed (S123).** A read-only role, dispatched live
  and instructed to attempt a write by any means, had no `Write`/`Edit`/`Bash` tool in its callable
  schema at all — mechanical enforcement at the harness level, not a prompt-level convention.
- **The clean-room runner (S119).** QA and Demo-er route scripts through a fresh `git worktree add
  --detach` checkout of HEAD when `verify.clean_room.enabled: true` (default off). Bootstrap
  command support; failure → `CannotEvaluate` → BLOCK. `VAJRA_SKIP_CLEAN_ROOM=1` escape.
- **Ledger** (S100): `verify-closeout.sh --ledger-verify` last confirmed INTACT at S115. Ledger is
  DERIVED from `sessions/session-NN-review.md` via `_ledger_read()` in verify-closeout.sh.
- **v0.1 install: CONFIRMED stranger-shippable (S110 GT).** Four channels, all real.
- **CI green on `main`** (both OS); 7 commands, no 8th (S123 added two flags to `next`, not a
  command). **339 lib tests.**
- **The guardrails themselves stay guarded (S122, extended S123).** The read-only tool-grant check
  is token-exact; the one-source check excludes generated/handoff paths; no test asserts a render
  against a content field of the role it rendered; the check-class tally names what it hides.
  `scripts/lib-tally.sh` is now the ONE source for `print_tally`/`tally_discloses_nesting` across
  THREE suites (S123), each independently proving it via `declare -F`/`extdebug`.
- **Both S122 fixtures now fail for the RIGHT reason (S123).** Isolated to a clean baseline plus
  exactly one planted defect; confirmed live that neutering the guarded branch flips each red.

## What Is Broken / Weak
- **🔴 Coder-dark for S119 (S120 finding):** `## Execution` step 7 records prose, not a commit sha.
  Legitimate non-commit evidence breaks the gate; filed not fixed.
- **🟡 3 behavioral source greps in verify-session-119.sh (S120 finding)** — pattern widespread in
  older scripts.
- **🟡 VISION.md stale (S120 finding):** clean-room runner not in body; Rules section still
  references the retired machinery-freeze rule.
- **🟡 The clean-room runner is not tested via the compiled CLI path** (`--check-qa`/`--check-demo`
  with `clean_room: true`). Unit tests inject closures; no end-to-end exercise. (The S123
  `--clean-room-open`/`--clean-room-close` CLI flags ARE exercised end-to-end, live, by
  `verify-session-123.sh` — a different code path from this one, not a fix for it.)
- **🟡 The Planner-gate double-count bug** (`src/planner/mod.rs::is_acceptance_heading`,
  `task_2162b487`) — carried, still unfixed.
- **🟡 `vajra next --dogfood-age` does not recurse into artifact subdirectories** (named S115).
- **🟡 `no-eighth-command` checks are a grep for a hardcoded usage banner** (9+ consecutive CODE
  sessions flagged, incl. S123) · **🟡 KNOWLEDGE §6 bloat, growing** (chronic since S60) · **🟡
  `vajra.varta` re-render drifts every session** · **🟡 `vajra --version` gap** · **🟡 brew
  smoke tests LOCAL formula**.
- **✅ Both S122 fixtures that could not fail are CLOSED (S123)** — isolated to fail for the right
  reason, confirmed live via neutering the guarded branch in each.
- **✅ `print_tally()`/`tally_discloses_nesting()` duplication CLOSED (S123)** — one source
  (`scripts/lib-tally.sh`), with a bound check in each of the three suites that use it.
- **✅ The `Write`/`Edit` grant is FENCED, not merely documented (S123)** — see "What Currently
  Works." Residual, stated plainly: the clean room isolates the REPO, not the MACHINE (`Bash`
  remains granted); nothing in code structurally forces a dispatch to use `--clean-room-open`
  before being accepted as a governed handoff (named S124 option B).
- **🟡 `measurement-artifact-cited` (S123) only proves two committed documents agree with each
  other, not that the underlying dispatch happened** — the raw transcript
  (`~/.claude/projects/.../*.jsonl` + `.meta.json`) lives outside the repo, uncommitted. This
  session's own fakest green; not softened.
- **🟡 Five `def.contains(… role.name …)` instances remain by design** — the join key is exempt from
  the tautology guard, reasoned only in a comment.
- **🟡 The tally's class NUMBERS are still unchecked against the printed rows** — a check given the
  wrong `CLASS` string still yields a fully "honest" tally.
- **🔴 The executor thesis is UNPROVEN — still, after S123.** `DECISION-007` carries the S122
  correction and S123 does not restore the claim: fencing removes one way `qa-specialist` could
  cheat, it does not establish that no executor can fake a pass by any means.
- **🔴 The check-class tally is STILL A SELF-ASSIGNED LABEL.** **Fifth disclosure of this class**
  now (S64 `covers:` digit-tag, S67 `design-significant:` marker, S121, S122, S123 the tally).
  Named as S124 option A. Never cite the number as a measurement.
- **🟡 `vajra init` hangs forever on stdin without EOF** without `</dev/null`. Older scripts
  (pre-S113) still lack the redirect — the binary itself is unchanged, the real fix is in
  `vajra init`.
- **🟡 `verify-session-116.sh` is red by construction** against S121+ — the every-role-is-read-only
  invariant was deliberately changed. Per-session-snapshot decay, disclosed in a comment.
- **🟡 The grep-only-verify detector** (S118 candidate A) — not yet built.
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** (L3 `commit_guard: off`; L2
  belt active) · **Compression no-op on real CC** · **Cross-agent breadth 0 code**.

## What Is In Progress
- **S123 DONE (CODE, ACCEPT at cold pass 2).** `verify-session-123.sh` 14/14 exit 0; demo 6/6;
  339 lib tests. PR not yet opened.
- **S124 = TBD.** Three options presented at the S123 close (`sessions/session-123-summary.md`):
  (A) make the check-class label EARNED, (B) close the dispatch-side clean-room gap, (C) a paid
  dogfood ride-along. Awaiting the founder's pick before the next prompt is written.

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
- **S123: $0 metered** (interactive). Three subagent passes roll in unitemized — one `researcher`
  (~17k, the `tools:` measurement) and two `fidelity-reviewer` passes (~88k, ~97k) and one
  `qa-specialist` pass (~50k).
  No paid dogfood run **in this session**; the last one was **S118 ($4.0912, 2026-08-15)** — 5
  sessions / 4 calendar days ago, confirmed live by `vajra next --dogfood-age`. Staleness 🟡
  (named as S124 option C).
- Cumulative: **~$83.4 + S76 (unknown, ≤ ~$26.6 opus-estimate) + S111–S123 subagents (unknown, and
  no longer small — S122 alone spent ~430k, S123 ~250k, subagent tokens).**
