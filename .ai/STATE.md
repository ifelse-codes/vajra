# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
`session-111-fleet-dispatch-wire` — S111 complete, not yet merged (8 atomic commits).
S111 = **CODE: close the fleet's def-vs-dispatch wire** (founder pick A at S110 GT). **Verdict:
SHIPPED.** S109 had proven the scaffold (`vajra init` writes `.claude/agents/researcher.md`) and a
real subagent run **separately** — the live run was dispatched by hand-typing a copy of the canonical
prompt, not by resolving `subagent_type` against the scaffolded file. S111 closed that gap: (1) inside
the live build session, dispatching by name **failed** — Claude Code snapshots `.claude/agents/*.md`
into available subagent types once, at session boot, so a file written mid-conversation is invisible
to that same conversation (a real, disclosed finding); (2) a **fresh** `vajra claude` session in a
freshly-`vajra init`'d repo, asked to "use the researcher subagent," dispatched it **by that name** —
proven not by a single copyable JSON blob but by two independently-written Claude Code files (the
parent session's tool-call record and the subagent's own `meta.json`) agreeing on the same random
tool-call ID (a first cold-review pass correctly flagged the single-blob version as too weak; this was
fixed before the second pass). Cost: `cost_usd: null` kept, for a checked, re-runnable reason
(`scripts/check-subagent-cost-fields.sh` — zero of every local subagent transcript carries a cost key,
same root cause as S77/S78). No dispatch-path code changed — S109 had already built it correctly; S111
supplied the missing proof. verify 9/9; demo exit 0; 304 lib tests; cold review **ACCEPT** (13/14
SHIPPED, 1 PARTIAL — CI-both-OS unevidenced pre-merge; one disclosed residual fakest-green: the
cross-file check is still internal to this commit's own artifact set, no external ground-truth
reach-out), attested `f98808bc…`. Report: `sessions/session-111-summary.md` +
`sessions/session-111-review.md`.

**Proposed for S112 (not yet founder-confirmed): downstream handoff-consumption** — nothing today
reads `.ai/handoffs/session-NN-researcher.md` automatically. Recommended over a second fleet role
(S110 candidate C) because a lone unread handoff gets more orphaned, not less, if a second role
doubles the count before anything consumes the first.

**🔀 FOUNDER PIVOT (S103, still in force):** sessions now = **finish a shippable MVP**; the founder runs
the long unattended test himself, then release. Order **C → B → A**: C (team voice) = S104 ✓ →
**B (installable) = S106 + S107 + S108 ✓ COMPLETE** → **A (real named agent fleet) — S109 first slice
✓, S111 dispatch wire ✓ CLOSED.**

## Active PRs
- None open yet for S111 (branch not pushed at write time). **S109 [#115](https://github.com/ifelse-codes/vajra/pull/115) MERGED** 2026-08-03; **S110 closeout [#116](https://github.com/ifelse-codes/vajra/pull/116) MERGED** 2026-08-03; local `main` synced with `origin/main` (`b1da971`).
- Prior merges: **S108 [#113](https://github.com/ifelse-codes/vajra/pull/113)** + S108-follow-up #114
  · S107 #112 · S106 #111 · S105-follow-up #110 · S105 #109 · S104 #108.

## Direction (governance is the product — now shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust layer**.
  Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained tamper-evident
  (`DECISION-004`). The fleet = **real named agents behind the existing gates** (`DECISION-007`), now
  wired end-to-end (S109 + S111).
- **Post-pivot roadmap:** C team-voice (S104 ✓) → **B installable v0.1 (S106+S107+S108) ✓ COMPLETE,
  confirmed stranger-shippable at S110 GT** → **A fleet (S109 first slice ✓ + S111 dispatch wire ✓
  CLOSED; next: downstream handoff-consumption or a second role).** Release when v0.1 is
  stranger-shippable (it is); the founder owns the long unattended real-world test.
- **The machinery-freeze rule (`DECISION-005`) is RETIRED** (S105): the pivot cancelled ladder *sessions*.

## What Currently Works
- **v0.1 install: CONFIRMED stranger-shippable (S110 GT, live-checked).** README carries no
  "NOT YET PUBLISHED" rows; all 4 channels real: `cargo install --git|--path` (S106) · prebuilt
  `v0.1.0` release binary, no Rust (S107) · `cargo install vajractl` from crates.io (S108) ·
  `brew install ifelse-codes/tap/vajra` (S108). `install-smoke.sh` = 5 modes, all fail-closed.
- **The fleet's first named agent, now wired end-to-end (S109 + S111):** `vajra init` scaffolds
  `.claude/agents/researcher.md` from the canonical `fleet::ROLES` (one source, no drift); a **fresh**
  Claude Code session's Task tool resolves `subagent_type: "researcher"` against that scaffolded file
  **by name** (confirmed on disk via cross-referencing tool-call IDs — not asserted, not a same-session
  hand-typed copy); `vajra next --role researcher --from <findings>` governs the real brief into a
  delta-tracked, validated handoff in `.ai/handoffs/` — fail-closed on unknown role / missing `--from`
  / empty findings. Native Claude Code subagent model (DECISION-007). Real finding along the way: a
  file scaffolded mid-session is invisible to that SAME session's Task tool (Claude Code snapshots
  `.claude/agents/*.md` at boot only) — proving the wire requires a fresh session, which is also
  exactly how a real Vajra user experiences it.
- **The 8-station governed pipeline speaks like a team** (S104): `vajra next --stations` + the packet
  render named roles + plain status from one source; gates/K unchanged.
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner · Coder ·
  QA · Demo-er · Releaser · Reviewer (fidelity gate + attested, chained ledger). Receipt AUTHORITATIVE
  when `total_cost_usd` exists, HONEST when it doesn't (S77).
- **Ledger** (S100): `verify-closeout.sh --ledger-verify` → INTACT, tamper-evident (`DECISION-004`),
  live-reconfirmed at S110 GT.
- **CI green on `main`** (both OS); `vajra claude · next · check · init · estimate · meter · hook` —
  **7 commands, no 8th** (the fleet rides `init` + `next`).

## What Is Broken / Weak
- **🟡 Nothing downstream consumes the researcher handoff yet.** The handoff is written + validated,
  now proven to come from a real by-name dispatch — but no station/stage reads it automatically.
  "Fleet" and "8 stations" are still two overlapping stories. **S112 candidate (proposed, unconfirmed).**
- **🔴 The launcher (`vajra claude`) has NOT run as a real governed session since S103** (last
  confirmed live at S110 GT: `--dogfood-age` reported 6 sessions / 4 calendar days since). S111's
  scratch-repo `vajra claude` dispatch was a mechanism TEST, not a governed dogfood run — doesn't reset
  this. Not blocking, but should not run much longer without a real paid call.
- **🟡 An unattended `claude -p` dispatch mode is unbuilt** (deferred, DECISION-007). The S109 handoff
  itself researched how: **`ANTHROPIC_API_KEY`** is the only auth that survives a fresh, no-TTY,
  no-keychain shell; `claude setup-token` is the subscription alternative; interactive OAuth won't do.
- **🟡 The K-of-8 pipeline-advance counter has no unit for fleet work** (S110 GT meta-check). A
  governed subagent handoff earns no station credit of its own. Flagged, not fixed.
- **🟡 KNOWLEDGE §6 bloat GROWING** (chronic since S60): 482 lines but 242KB (lines up to 6.7KB each) —
  prune still queued, not done.
- **🟡 `vajra.varta` re-render drifts every session** — `vajra check` FAILs "varta stale" (10/11,
  live-confirmed at S110 GT); no CLOSEOUT gate reads it.
- **🟡 `vajra --version` gap** · **🟡 `--dogfood-age` durable code fix** (recurse subdirs) · **🟡 brew
  smoke tests a LOCAL formula copy** (S108) · **🟡 x86_64 prebuilt proven by checksum, never executed**.
- **🟡 `fable-5` monthly credits exhausted (S102).** Paid launcher dogfood costs real $ on sonnet/opus.
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** (L3 `commit_guard: off`; L2 belt
  active) · **Compression no-op on real CC** (never claim until measured) · **Cross-agent breadth 0 code**.
- **🟡 CI-both-OS not yet evidenced for S111** — no code changed, so it's expected to pass, but the
  cold review correctly notes the delivery itself supplies no CI run evidence pre-merge (S109 pattern:
  "SHIPPED (CI pending)").

## What Is In Progress
- **S111 DONE (CODE; SHIPPED; verify 9/9; demo exit 0; cold review ACCEPT, attested `f98808bc…`).**
  Report: `sessions/session-111-summary.md` + `sessions/session-111-review.md`. Branch
  `session-111-fleet-dispatch-wire` not yet merged.
- **Next = S112 — CODE (proposed): downstream handoff-consumption.** Prompt:
  `prompts/112-task-handoff-consumption.md` (drafted, pending founder confirmation at kickoff). **New chat.**
- **Deferred (S110 GT candidate C, still not S112 by default):** a second fleet role — wait until
  handoff-consumption is proven, unless the founder redirects.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative. S36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- S53–75: ~$0 each. **S76: real but UNKNOWN** (opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713** · **S97: $1.2758** · **S102: $0.4644** ·
  **S103: $0.6797** (all authoritative). **S104–109: ~$0 each** (S109's subagent tokens roll into the
  interactive session receipt, unitemized — `cost_usd: null`, disclosed).
- **S110: $0 (NO-CODE GT — no paid calls).**
- **S111: real but UNKNOWN in-chat** (interactive build session; the founder's own fresh-session
  dispatch test was a separate, small, real paid call the founder ran themselves — cost rolls into
  that scratch session's own receipt, not this repo's). No new dispatch-path code, so scope was small.
- Cumulative: **~$79.3 + S76 (unknown, ≤ ~$26.6 opus-estimate) + S111 (unknown, small).**
