# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**`session-118-dogfood-chitra-catalog`** — S118 = **DOGFOOD (paid): the overdue `vajra claude` run**
(founder pick A at the S117 closeout, held until the founder confirmed chitra was clean; go-ahead
given in chat 2026-08-15). Founder also chose the run mode (sonnet, headless `-p`, ~$5 cap) and the
payload scope.

**Verdict: ACCEPT** — two cold `fidelity-reviewer` passes, **pass 1 REJECT → pass 2 ACCEPT**
(5 of 8 SHIPPED, 3 PARTIAL, 0 NOT-BUILT). **Spend $4.0911771 authoritative** (S78 tee path), 1331s,
under the $5 cap. No `src/` change.

**The finding:** the governed run delivered chitra S11, graded itself **8-of-8 SHIPPED** with
`verify-session-11.sh` at **14/14 ALL GREEN** — and **19 of the 20 chart pages showed an error
instead of a chart.** All 11 catalog checks in that suite were greps for source strings. Six
governance gates behaved correctly throughout; none of them asks whether the delivered thing works.
**This is the S54 fidelity-over-discipline finding reproduced on a paid run, one pipeline generation
later.**

## Active PRs
- **S118 PR not yet opened** as of this snapshot (`session-118-dogfood-chitra-catalog`).
- Prior: **S117 [#126](https://github.com/ifelse-codes/vajra/pull/126) MERGED** · S114
  [#122](https://github.com/ifelse-codes/vajra/pull/122) · S113 #120 · S112 #118 (+#119) · S111 #117 ·
  S109 #115 · S110 #116 · S108 #113/#114 · S107 #112 · S106 #111 · S116 merged inside #125.

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
- **🔴 THE finding (S118): nothing in Vajra asks whether the delivered thing WORKS.** A verify suite
  made entirely of greps returns ALL GREEN over a broken build, and both the station gates and the
  fleet's own cold review passed it. **S119 candidate A** = teach the QA station to detect a verify
  script whose checks never execute the thing they check.
- **🟡 A cold review is only as good as its inputs.** For a UI deliverable, "prompt + diff" cannot
  see a page that does not render. S118 pass 1 caught the operator's own version of this sin
  (verification delivered as prose) but needed PNGs added before pass 2 could confirm anything.
- **🟡 `vajra next --dogfood-age` does not recurse into artifact subdirectories** (named S115, still
  unfixed): S118's receipt had to be copied to the artifacts ROOT for the query to see it. S76's
  run1/run2 receipts are invisible for the same reason.
- **🟡 The S118 budget gate is real code whose one evaluation was vacuous** (`spent_before=0` vs a
  $5 cap cannot fail). Within a single `-p` stage there is no cost ceiling at all — this `claude`
  build has no `--max-turns`, so only a wall clock bounds spend.
- **🟡 The Planner-gate double-count bug** (`src/planner/mod.rs::is_acceptance_heading`,
  `task_2162b487`) — carried, still unfixed. **🟡 Fleet consumption + fleet evidence stay ADVISORY.**
- **🟡 `no-eighth-command` checks are a grep for a hardcoded usage banner** (7 consecutive CODE
  sessions flagged) · **🟡 KNOWLEDGE §6 bloat past 550 lines** · **🟡 `vajra.varta` re-render drifts
  every session** · **🟡 `vajra --version` gap** · **🟡 brew smoke tests a LOCAL formula copy** ·
  **🟡 x86_64 prebuilt proven by checksum, never executed**.
- **🟡 `fable-5` monthly credits exhausted (S102).** Paid dogfood costs real $ — S118 cost $4.09.
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** (L3 `commit_guard: off`; L2 belt
  active) · **Compression no-op on real CC** · **Cross-agent breadth 0 code**.
- **🟡 Carried from S115:** `verify-closeout.sh`'s canonical-verdict regex rejects a `|`-table-wrapped
  verdict line.

## What Is In Progress
- **S118 DONE (DOGFOOD, paid, ACCEPT).** Summary: `sessions/session-118-summary.md`. Ground truth:
  `sessions/session-118-ground-truth.md`. Review: `sessions/session-118-review.md`.
- **chitra is left on `session-11-catalog-two-panel`, LOCAL — not pushed, no PR**, by instruction.
  11 commits (6 governed run + 5 operator repair); chitra `main` never moved. The founder reviews the
  page in a browser before anything leaves the machine. The two-panel catalog page works: vim-styled
  editable buffer left, terminal preview right, live in-browser re-execution, 20 of 20 charts render.
- **Next = S119 — CODE.** Candidate A (recommended): the grep-only-verify detector. B: feed the
  fidelity reviewer the running artifact. C: the previously-planned Planner-gate fix + blocking
  fleet gate. Founder picks.

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
- **S118: $4.0911771** authoritative (sonnet, headless `-p`, 1331s) — the first paid dogfood since
  S103. Two cold-review subagent passes roll into this interactive session's receipt, unitemized.
- Cumulative: **~$83.4 + S76 (unknown, ≤ ~$26.6 opus-estimate) + S111–S118 subagents (unknown, small).**
