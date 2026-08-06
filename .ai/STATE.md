# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**None — between sessions (S114 complete, S115 not yet started).** S114 shipped on
`session-114-fleet-role-reviewer` (11 atomic commits). S114 = **CODE: build the fleet's SECOND named
role, the Fidelity Reviewer** (founder pick **A** at the S113 closeout; "all approved" at kickoff).
**Verdict: SHIPPED.**

The independent cold fidelity review this repo has run **47 times by hand** — mandated by
DECISION-002, its brief re-typed each session — is now canonical, scaffolded and governed. The
headline result is what did **not** happen:

- **`src/cli/init.rs` is untouched in the entire diff.** It already iterated `fleet::ROLES`, so one
  more entry delivered the scaffold, the governed handoff, the read-back and the counter for free.
  No second scaffolding path, no second handoff writer, no 8th command. That is the S109
  architecture paying off exactly as designed.
- **The key is `fidelity-reviewer`, never `reviewer`** — the Reviewer-STATION collision resolved
  with a distinct key; `resolve_role("reviewer")` is `None` on purpose. Rejected "the role IS the
  station's agent": false, because the station passes on an attested artifact existing, which a
  human can produce with no agent at all.
- **The handoff is a PRE-STAGE INPUT; `sessions/session-NN-review.md` stays the single record of
  record.** No gate learned to read a handoff, and the role has no write tool, so it *cannot* author
  the record. Rejected pointer-only (throws away the `source-sha`) and replace-the-artifact (trades
  the attestation + ledger chain for a newer file).
- **Role #2 flushed out two leaks hardcoded to role #1:** the subagent `tools:` grant (every future
  role would have silently inherited the Researcher's web access) and `compute_delta`'s role name (a
  Reviewer handoff would have carried the word "researcher" in its own tracked delta).

**322 lib tests; verify 17/17; demo 10/10 exit 0; two independent cold passes — pass 1 REJECT, fixed
in-session, then a FRESH pass 2 ACCEPT (13 of 13 SHIPPED) — attested `cbd22d3a…`.**
Reports: `sessions/session-114-summary.md` + `sessions/session-114-review.md`.

**Two-pass cold review earned its keep for the FIFTH session running, and this time pass 1
REJECTED.** It found that the repo *already* contained a rival statement of the reviewer contract —
`reviewer/SKILL.md`, 127 hand-maintained lines scaffolded by the same `vajra init` — which this
session's own approved prompt asserted did not exist ("re-typed from memory each time"). Worse, the
first draft of the brief omitted **all three** output tokens `verify-closeout.sh` enforces, so an
agent dispatched by name would have returned a verdict the gate then rejected. A **fresh** pass 2
then found two more: `.claude/agents/` was the one directory the no-second-source guard excluded (a
planted `reviewer-legacy.md` kept the suite green), and the gate counts verdict words only on
`|`-delimited rows, so an obedient agent could return bullets that BLOCK. All fixed in-session,
every fix mutation-verified.

**🔀 FOUNDER PIVOT (S103, still in force):** sessions now = **finish a shippable MVP**; the founder
runs the long unattended test himself, then release. Order **C → B → A**: C (team voice) = S104 ✓ →
**B (installable) = S106 + S107 + S108 ✓ COMPLETE** → **A (real named agent fleet) — S109 first slice
✓, S111 dispatch wire ✓, S112 consumption loop ✓, S113 counter-visibility + role chosen ✓, S114
second role BUILT ✓.**

## Active PRs
- **None open. S114's PR is NOT YET OPENED** — `vajra next --stations 114` = **7 of 8**, the one
  ABSENT station being the Releaser, which turns green on merge (identical to S113 pre-merge).
- Prior: **S113 [#120](https://github.com/ifelse-codes/vajra/pull/120) MERGED** 2026-08-06, CI green
  both OS · S112 [#118](https://github.com/ifelse-codes/vajra/pull/118) + closeout #119 · S111 #117 ·
  S109 #115 · S110 closeout #116 · S108 #113 + #114 · S107 #112 · S106 #111.

## Direction (governance is the product — now shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust
  layer**. Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). The fleet = **real named agents behind the existing gates**
  (`DECISION-007`) — now **two** roles, written → dispatched → read → counted.
- **Post-pivot roadmap:** C team-voice (S104 ✓) → **B installable v0.1 ✓ COMPLETE** → **A fleet
  (S109 ✓ + S111 ✓ + S112 ✓ + S113 ✓ + S114 ✓ — next: DISPATCH the new role by name, the overdue
  paid dogfood, or an opt-in blocking gate).** Release when v0.1 is stranger-shippable (it is).
- **The machinery-freeze rule (`DECISION-005`) is RETIRED** (S105).

## What Currently Works
- **The fleet has TWO named roles, both from one source (S114):** `vajra init` scaffolds
  `.claude/agents/researcher.md` **and** `.claude/agents/fidelity-reviewer.md`, each a *rendering* of
  `fleet::ROLES` (verify requires byte-equality with a live `init`, and that the directory holds
  **exactly** the rendered set — so a hand-written agent file is a red suite). `vajra next --role
  <key> --from <file>` governs either into a validated handoff; `vajra next --stations NN` reports
  **`fleet: 2 governed handoff(s) — researcher, fidelity-reviewer`** beside an unchanged `K of 8`.
- **The reviewer contract is TWO BOUND FILES, not a duplicate:** `reviewer/SKILL.md` is canonical
  (long form, boot-loaded, scaffolded via `include_str!`); the role's system prompt is its
  dispatch-time summary and names it. A unit test + a verify check read **both** files and require
  every closeout-gate token in each — mutation-verified in both directions.
- **The fleet's first named agent — write, dispatch, AND read (S109 + S111 + S112):** a fresh Claude
  Code session's Task tool resolves `subagent_type` against the scaffolded file **by name**
  (confirmed on disk via cross-referenced tool-call IDs); the boot packet, the Analyst intake and
  the Analyst gate each surface the session's findings inline, silent when absent.
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner ·
  Coder · QA · Demo-er · Releaser · Reviewer. Receipt AUTHORITATIVE when `total_cost_usd` exists,
  HONEST when it doesn't (S77).
- **Ledger** (S100): `verify-closeout.sh --ledger-verify` → INTACT, tamper-evident (`DECISION-004`).
- **v0.1 install: CONFIRMED stranger-shippable (S110 GT).** Four channels, all real.
- **CI green on `main`** (both OS); `vajra claude · next · check · init · estimate · meter · hook` —
  **7 commands, no 8th** (both fleet roles ride `init` + `next`).

## What Is Broken / Weak
- **🔴 The launcher (`vajra claude`) has NOT run as a real governed session since S103** — now 11
  sessions / ~11 calendar days. Mechanism tests do not reset it; only a real paid run does.
- **🟡 The new role has NEVER been dispatched by name.** A `.claude/agents/*.md` written mid-session
  is invisible to that session's Task tool (S111). S114's own two cold passes ran as ad-hoc
  `general-purpose` subagents, exactly as every prior session's have. **S115 is the first session
  that can call it by name — and the only way to learn whether the brief works on a real agent.**
- **🟡 The role's TEXT is guarded by presence-greps and nothing else** (S114's disclosed fakest
  green). Cold pass 2 replaced the whole system prompt with token soup instructing the agent to
  rubber-stamp, re-rendered the scaffolded file, and got verify 17/17 + demo 10/10 + 322 tests green.
  The checks guard the brief's *shape*, never its *quality*. No check in this repo can.
- **🟡 Fleet consumption + fleet evidence are ADVISORY, never blocking.** Nothing fails when a session
  ignores a governed handoff. Deliberate; an opt-in gate is the obvious next step and equally the
  obvious way to build false teeth.
- **🟡 The fleet line counts ARTIFACTS, not agents** — a contract-valid handoff proves a file, never
  a dispatch, and never that any station *read* it.
- **🟡 An unattended `claude -p` dispatch mode is unbuilt** (deferred, DECISION-007);
  `ANTHROPIC_API_KEY` is the only auth that survives a fresh no-TTY shell.
- **🟡 `no-eighth-command` checks are a grep for a hardcoded usage banner** (S111–S114) — an 8th
  command whose author skipped the help text would pass. House-wide, still not fixed.
- **🟡 KNOWLEDGE §6 bloat GROWING** (chronic since S60) — prune queued, not done.
- **🟡 `vajra.varta` re-render drifts every session** — `vajra check` FAILs "varta stale"; no CLOSEOUT
  gate reads it.
- **🟡 `vajra --version` gap** · **🟡 `--dogfood-age` durable code fix** · **🟡 brew smoke tests a
  LOCAL formula copy** · **🟡 x86_64 prebuilt proven by checksum, never executed**.
- **🟡 `fable-5` monthly credits exhausted (S102).** Paid launcher dogfood costs real $.
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** (L3 `commit_guard: off`; L2 belt
  active) · **Compression no-op on real CC** (never claim until measured) · **Cross-agent breadth 0 code**.

## What Is In Progress
- **S114 DONE (CODE; SHIPPED; 322 lib tests; verify 17/17; demo 10/10; two cold passes — REJECT then
  a fresh ACCEPT — attested `cbd22d3a…`).** PR not yet opened; `--stations 114` = **7 of 8**.
  Reports: `sessions/session-114-summary.md` + `sessions/session-114-review.md`.
- **Next = S115 — MANDATORY NO-CODE GROUND TRUTH** (`115 % 5 == 0`). Its one live opportunity: S115
  is the first session that can dispatch `subagent_type: "fidelity-reviewer"` **by name**, which is
  evidence-gathering (no code) and therefore fits a GT. Prompt: `prompts/115-task-ground-truth.md`.
  Deferred for the founder to pick at the S115 closeout: the paid dogfood and an opt-in blocking
  gate. **New chat.**

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
- Cumulative: **~$79.3 + S76 (unknown, ≤ ~$26.6 opus-estimate) + S111–S114 (unknown, small).**
