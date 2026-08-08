# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**None — between sessions (S116 complete, S117 not yet started).** S116 = **CODE: the fleet's third
role, the Plan Advisor** (founder pick B at the S115 closeout, over the recommended paid dogfood;
named Planner, built as the distinctly-keyed `plan-advisor`). Work done on
`session-116-fleet-role-planner`, 3 atomic commits.

**Verdict: ACCEPT** (independent cold review, `subagent_type: "fidelity-reviewer"` dispatched by
name — 10 of 12 SHIPPED). The headline result, same shape as S114: adding a third role required
**zero changes to `src/cli/init.rs`, `src/cli/next.rs`, or `src/stations/mod.rs::fleet_evidence`** —
confirmed by tracing all three (not just re-asserting the doc-comment's claim) and by `vajra init`
producing three byte-identical agent files from a fresh repo. The role's `covers: N` contract states
the exact shape `src/planner/mod.rs::cited_criteria` already parses and grades — no new parser, no
new station-side logic. The 2 PARTIALs in the reviewer's own table are the read-only reviewer (no
Bash tool) correctly declining to grade scripts it could not execute itself; the builder ran
`cargo test --lib` (323 passed), `verify-session-116.sh` (16/16), and `demo-session-116.sh` (10/10)
green in-session, stated plainly as the builder's own claim.

## Active PRs
- **None open yet** — `session-116-fleet-role-planner` not yet pushed/opened as of this snapshot.
- Prior: **S114 [#122](https://github.com/ifelse-codes/vajra/pull/122) MERGED** 2026-08-07, CI green
  both OS · S113 [#120](https://github.com/ifelse-codes/vajra/pull/120) MERGED · S112
  [#118](https://github.com/ifelse-codes/vajra/pull/118) + closeout #119 · S111 #117 · S109 #115 ·
  S110 closeout #116 · S108 #113 + #114 · S107 #112 · S106 #111.

## Direction (governance is the product — now shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust
  layer**. Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). The fleet = **real named agents behind the existing gates**
  (`DECISION-007`) — THREE roles built; two proven dispatched by name (Researcher S111, Fidelity
  Reviewer S115); the third (Plan Advisor, S116) not yet dispatched — S117's job.
- **Post-pivot roadmap:** C team-voice (S104 ✓) → **B installable v0.1 ✓ COMPLETE** → **A fleet
  (S109 ✓ + S111 ✓ + S112 ✓ + S113 ✓ + S114 ✓ + S115 ✓ + S116 ✓ — next: S117 proves the third role
  dispatches by name; the overdue paid dogfood remains the single highest-leverage item not yet
  picked, deferred by explicit founder choice at S115 AND S116).** Release when v0.1 is
  stranger-shippable (it is).
- **The machinery-freeze rule (`DECISION-005`) is RETIRED** (S105).

## What Currently Works
- **The fleet has THREE named roles.** Researcher and Fidelity Reviewer are proven end-to-end
  INCLUDING by-name dispatch (S111, S115); the Plan Advisor (S116) is scaffolded and governable but
  **not yet dispatched by name** — a real, disclosed gap, not an oversight (S111's mid-creating-session
  limit means S116 itself could not test it; S117 is the earliest session that can). `vajra init`
  scaffolds all three `.claude/agents/*.md` files as *renderings* of `fleet::ROLES` (no drift, proven
  by running `vajra init` fresh and diffing byte-for-byte against this repo's committed copies);
  `vajra next --role <key> --from <file>` governs any of the three into a validated handoff;
  `vajra next --stations NN` reports fleet evidence beside `K of 8` — confirmed at THREE governed
  handoffs in one session for the first time (`fleet: 3 governed handoff(s) — researcher,
  fidelity-reviewer, plan-advisor`), `K` byte-identical to the no-fleet report.
- **The role-key-vs-station-name collision pattern now has TWO confirmed instances**, both resolved
  the same way: distinct key + `resolve_role(<station word>).is_none()` asserted by test + a decision
  addendum with ≥2 rejected alternatives. Reviewer vs `fidelity-reviewer` (S114); Planner vs
  `plan-advisor` (S116, `DECISION-007` addendum).
- **The Plan Advisor's `covers: N` contract is a direct match to the Planner station's own parser**
  (`src/planner/mod.rs::cited_criteria`) — verified by hand-reading both, not merely asserted; the
  role proposes citations in that exact shape and has no Write/Edit tool, so it cannot author the
  session's own `## Plan` even if asked.
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner ·
  Coder · QA · Demo-er · Releaser · Reviewer. Receipt AUTHORITATIVE when `total_cost_usd` exists,
  HONEST when it doesn't (S77).
- **Ledger** (S100): `verify-closeout.sh --ledger-verify` last confirmed INTACT at S115; not re-run
  this session (no drift indicator; S117 should re-confirm as routine hygiene).
- **v0.1 install: CONFIRMED stranger-shippable (S110 GT).** Four channels, all real.
- **CI green on `main`** (both OS); `vajra claude · next · check · init · estimate · meter · hook` —
  **7 commands, no 8th** (all three fleet roles ride `init` + `next`).

## What Is Broken / Weak
- **🔴 The launcher (`vajra claude`) has NOT run as a real governed session since S103** — now **13
  sessions / ~13+ calendar days**. Mechanism tests do not reset it; only a real paid run does.
  Deferred again at the S116 closeout by explicit founder choice (picked the third role's dispatch
  proof instead) — flagged, not neglected; the next GT (S120) should press on this if S117–S119 don't
  reach it either.
- **🟡 The Plan Advisor has never been dispatched by name.** S116 built and governed the scaffold; per
  the S111 limit, a role's agent file is invisible to the session that wrote it. S117 is the earliest
  session that can supply this evidence, mirroring S115's proof for the Reviewer. Until then,
  `fleet: 1 governed handoff(s) — plan-advisor` (if produced) would certify a contract-valid FILE,
  never a dispatched agent — say so precisely if this comes up before S117 closes it.
- **🟡 Carried from S115, still unfixed (NO-CODE at S115, not this session's scope):**
  `verify-closeout.sh`'s canonical-verdict regex rejects a `|`-table-wrapped verdict line (only a
  bare `**Verdict:** ACCEPT`/`REJECT` line passes — S116's own cold review landed correctly on the
  first try, but the regex itself is still unhardened). `vajra next --dogfood-age`'s date field can
  report the receipt-backfill commit's date rather than the run's own date (S103's true gap is ~13
  calendar days, not necessarily what the tool reports). Neither fixed (both NO-CODE findings from a
  prior session; this session did not touch either).
- **🟡 No standing GT audit checks a prompt's own factual premises against repo reality** (S115 meta-
  check finding, still unfixed — named again as still-relevant, not re-derived this session).
- **🟡 Fleet consumption + fleet evidence are ADVISORY, never blocking.** Nothing fails when a session
  ignores a governed handoff. Deliberate; an opt-in gate remains an obvious, still-unpicked next step
  (named as candidate C at the S116 closeout, not picked).
- **🟡 The fleet line counts ARTIFACTS, not agents — except where a real dispatch is independently
  proven** (S111 Researcher, S115 Reviewer). Say precisely what was proven in each case.
- **🟡 An unattended `claude -p` dispatch mode is unbuilt** (deferred, DECISION-007);
  `ANTHROPIC_API_KEY` is the only auth that survives a fresh no-TTY shell.
- **🟡 `no-eighth-command` checks are a grep for a hardcoded usage banner** (S111–S116, now 5
  consecutive CODE sessions flagged, unfixed). House-wide, still not fixed.
- **🟡 KNOWLEDGE §6 bloat GROWING** (chronic since S60) — now **517 lines** (was 496 at the S115
  mention). The file's own staleness-disclaimer header is itself stale.
- **🟡 `vajra.varta` re-render drifts every session** — `vajra check` FAILs "varta stale"; no CLOSEOUT
  gate reads it.
- **🟡 `vajra --version` gap** · **🟡 `--dogfood-age` durable code fix (subdirectory-recursion +
  wrong-commit-date, both named at S115)** · **🟡 brew smoke tests a LOCAL formula copy** · **🟡
  x86_64 prebuilt proven by checksum, never executed**.
- **🟡 `fable-5` monthly credits exhausted (S102).** Paid launcher dogfood costs real $.
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** (L3 `commit_guard: off`; L2 belt
  active) · **Compression no-op on real CC** (never claim until measured) · **Cross-agent breadth 0 code**.

## What Is In Progress
- **S116 DONE (CODE; independent cold review ACCEPT, 10 of 12 SHIPPED; the fleet's third role
  built, governed, and scaffolded; zero new machinery confirmed by tracing; one key collision resolved
  in writing).** Summary: `sessions/session-116-summary.md`. Review: `sessions/session-116-review.md`.
- **Next = S117 — CODE: prove the Plan Advisor dispatches by name** (founder pick A at the S116
  closeout, over B: the paid dogfood, and C: wiring fleet handoffs into station gates). Mirrors S115's
  proof for the Reviewer, now on the third role — real evidence the role's brief works in the wild,
  not just its shape. Prompt: `prompts/117-task-plan-advisor-dispatch.md`. Deferred by explicit
  founder call: the paid dogfood (🔴 13+ sessions) — next GT (S120) should press on it if S117–S119
  don't reach it either. **New chat.**

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
- Cumulative: **~$79.3 + S76 (unknown, ≤ ~$26.6 opus-estimate) + S111–S116 (unknown, small).**
