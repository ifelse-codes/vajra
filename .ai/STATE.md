# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**None — between sessions (S117 complete, S118 approved but WAITING on the founder).** S117 = **CODE:
prove the fleet's third role, the Plan Advisor, dispatches by name** (founder pick A at the S116
closeout). Work done on `session-117-plan-advisor-dispatch`, 15 atomic commits.

**Verdict: ACCEPT** (three independent cold reviews, `subagent_type: "fidelity-reviewer"` dispatched
by name each time — final pass: 7 of 11 SHIPPED, 4 PARTIAL, 0 NOT-BUILT). The headline result: all
three fleet roles (Researcher S111, Fidelity Reviewer S115, Plan Advisor S117) are now proven
dispatched by name in three separate fresh sessions — `subagent_type: "plan-advisor"` resolved on
the first try, independently confirmed via a two-file cross-check (parent tool-call ID matches the
subagent's own `toolUseId`) plus a transcript-count check ruling out a hidden retry. Pass 1 REJECTed
a real orchestrator error (the diff fed to the reviewer was written to `/tmp`, not the path it was
told to read); passes 2 and 3 each found one real hollow-green (a no-op check, and a first-try claim
checked only by grepping self-authored prose) — both fixed in-session, disclosed rather than silently
absorbed. No `src/` changes (`design-significant: no`).

## Active PRs
- **None open yet** — `session-117-plan-advisor-dispatch` not yet pushed/opened as of this snapshot.
- Prior: **S114 [#122](https://github.com/ifelse-codes/vajra/pull/122) MERGED** 2026-08-07, CI green
  both OS · S113 [#120](https://github.com/ifelse-codes/vajra/pull/120) MERGED · S112
  [#118](https://github.com/ifelse-codes/vajra/pull/118) + closeout #119 · S111 #117 · S109 #115 ·
  S110 closeout #116 · S108 #113 + #114 · S107 #112 · S106 #111. **S116 merged as part of
  [#125](https://github.com/ifelse-codes/vajra/pull/125).**

## Direction (governance is the product — now shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust
  layer**. Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). The fleet = **real named agents behind the existing gates**
  (`DECISION-007`) — THREE roles built, **ALL THREE now proven dispatched by name** (Researcher S111,
  Fidelity Reviewer S115, Plan Advisor S117). The fleet build arc is essentially done.
- **Post-pivot roadmap:** C team-voice (S104 ✓) → **B installable v0.1 ✓ COMPLETE** → **A fleet
  (S109 ✓ + S111 ✓ + S112 ✓ + S113 ✓ + S114 ✓ + S115 ✓ + S116 ✓ + S117 ✓ — next: the overdue paid
  dogfood, THE single highest-leverage item, approved as S118 and waiting only on the founder
  cleaning chitra's working tree; then S119 = B+C combined, see below).** Release when v0.1 is
  stranger-shippable (it is).
- **The machinery-freeze rule (`DECISION-005`) is RETIRED** (S105).

## What Currently Works
- **The fleet has THREE named roles, ALL proven dispatched by name.** `vajra init` scaffolds all
  three `.claude/agents/*.md` files as *renderings* of `fleet::ROLES` (no drift); `vajra next --role
  <key> --from <file>` governs any of the three into a validated handoff; `vajra next --stations NN`
  reports fleet evidence beside `K of 8`, K unaffected. Real dispatch evidence now exists for all
  three: Researcher (S111), Fidelity Reviewer (S115), Plan Advisor (S117) — each proven via the same
  two-file cross-check (a parent session's tool-call ID matching the subagent's own independently-
  written meta file).
- **The "first try, no workaround" claim is now independently checkable**, not just self-reported
  prose: count `subagent_type:"<role>"` occurrences in the real parent session transcript — exactly 1
  means no hidden retry. Found necessary by a cold review at S117; a durable, reusable pattern for
  any future role's dispatch proof.
- **The role-key-vs-station-name collision pattern has TWO confirmed instances** (Reviewer vs
  `fidelity-reviewer` S114; Planner vs `plan-advisor` S116), both resolved the same documented way.
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner ·
  Coder · QA · Demo-er · Releaser · Reviewer. Receipt AUTHORITATIVE when `total_cost_usd` exists,
  HONEST when it doesn't (S77).
- **Ledger** (S100): `verify-closeout.sh --ledger-verify` last confirmed INTACT at S115; not re-run
  this session (no drift indicator).
- **v0.1 install: CONFIRMED stranger-shippable (S110 GT).** Four channels, all real.
- **CI green on `main`** (both OS); `vajra claude · next · check · init · estimate · meter · hook` —
  **7 commands, no 8th** (all three fleet roles ride `init` + `next`).

## What Is Broken / Weak
- **🔴 The launcher (`vajra claude`) has NOT run as a real governed session since S103** — now **14
  sessions / ~14+ calendar days**. Approved as **S118**, target chitra, but **WAITING on the founder**
  to finish cleaning chitra's working tree (7 uncommitted files as of this snapshot) before it starts.
  Do not begin S118 until the founder explicitly says to in chat.
- **🟡 A real, out-of-scope bug found live at S117, disclosed not fixed:**
  `src/planner/mod.rs::is_acceptance_heading` matches any heading whose text merely *contains* the
  word "acceptance" — since this repo's own `## Plan (... cite the acceptance criteria ...)` heading
  text contains that word, the Plan section's own numbered steps get double-counted as phantom extra
  acceptance criteria. Live since ≥S112 (checked prompts/112–116), previously masked by coincidence.
  Does not block `verify-closeout.sh` or the commit hooks (neither calls the Planner gate). Flagged as
  background task `task_2162b487`. **Slated for S119 (part B, combined with part C below).**
- **🟡 Fleet consumption + fleet evidence are ADVISORY, never blocking.** Nothing fails when a session
  ignores a governed handoff. Deliberate; wiring an opt-in blocking gate is **S119's part C.**
- **🟡 The fleet line counts ARTIFACTS, not agents — except where a real dispatch is independently
  proven** (now all three roles: S111, S115, S117). Say precisely what was proven in each case.
- **🟡 An unattended `claude -p` dispatch mode is unbuilt** (deferred, DECISION-007);
  `ANTHROPIC_API_KEY` is the only auth that survives a fresh no-TTY shell.
- **🟡 `no-eighth-command` checks are a grep for a hardcoded usage banner** (S111–S117, now 6
  consecutive CODE sessions flagged, unfixed). House-wide, still not fixed.
- **🟡 KNOWLEDGE §6 bloat GROWING** (chronic since S60) — now well past 550 lines. The file's own
  staleness-disclaimer header is itself stale.
- **🟡 `vajra.varta` re-render drifts every session** — `vajra check` FAILs "varta stale"; no CLOSEOUT
  gate reads it.
- **🟡 `vajra --version` gap** · **🟡 `--dogfood-age` durable code fix (subdirectory-recursion +
  wrong-commit-date, both named at S115)** · **🟡 brew smoke tests a LOCAL formula copy** · **🟡
  x86_64 prebuilt proven by checksum, never executed**.
- **🟡 `fable-5` monthly credits exhausted (S102).** Paid launcher dogfood costs real $.
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** (L3 `commit_guard: off`; L2 belt
  active) · **Compression no-op on real CC** (never claim until measured) · **Cross-agent breadth 0 code**.
- **🟡 Carried from S115, still unfixed:** `verify-closeout.sh`'s canonical-verdict regex rejects a
  `|`-table-wrapped verdict line. `vajra next --dogfood-age`'s date field can report the
  receipt-backfill commit's date rather than the run's own date.

## What Is In Progress
- **S117 DONE (CODE; three independent cold reviews, final ACCEPT 7 of 11 SHIPPED; all three fleet
  roles now proven dispatched by name; a real out-of-scope Planner-gate bug found and disclosed).**
  Summary: `sessions/session-117-summary.md`. Review: `sessions/session-117-review.md`.
- **Next = S118 — DOGFOOD (paid): the overdue `vajra claude` run** (founder pick A at the S117
  closeout, over B/C). Target: chitra, once the founder finishes cleaning its working tree and gives
  the explicit go-ahead. **Do not start until told.**
- **Then S119 — CODE (B+C combined)**: fix the Planner-gate double-counting bug (`task_2162b487`) +
  wire fleet handoffs into an opt-in blocking gate (candidate C from the S116 closeout).

## Cost Tracking
- Session 00–30: ~$0.46 cumulative. S36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- S53–75: ~$0 each. **S76: real but UNKNOWN** (opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713** · **S97: $1.2758** · **S102: $0.4644** ·
  **S103: $0.6797** (all authoritative). **S104–109: ~$0 each.**
- **S110: $0 (NO-CODE GT).** **S111/S112/S113: $0 metered for the build**; cold-review subagent
  tokens roll into the interactive session receipt, unitemized (`scripts/check-subagent-cost-fields.sh`:
  no local subagent transcript carries a cost field).
- **S114: $0 metered for the build; two cold-review subagent passes (~215k subagent tokens) roll into
  this interactive session's receipt, unitemized** — same structural reason as S109/S111/S112/S113.
- **S115: $0 metered (NO-CODE GT); one live `fidelity-reviewer` subagent dispatch (107,664 tokens)
  rolls into this interactive session's receipt, unitemized** — same structural reason as above.
- **S116: $0 metered for the build; one cold-review subagent dispatch (~93,694 tokens, per the
  agent's own usage report) rolls into this interactive session's receipt, unitemized** — same
  structural reason as S109/S111–S115.
- **S117: $0 metered for the build; four subagent dispatches (1 plan-advisor + 3 fidelity-reviewer
  cold-review passes) roll into this interactive session's receipt, unitemized** — same structural
  reason as S109/S111–S116.
- Cumulative: **~$79.3 + S76 (unknown, ≤ ~$26.6 opus-estimate) + S111–S117 (unknown, small).**
