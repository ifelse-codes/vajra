# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S110 complete, S111 not yet started).
S110 = **NO-CODE GROUND TRUTH** (mandatory every 5th; audits S106–S109). **Verdict: PARTIAL.** v0.1
install confirmed **real, stranger-shippable** — 4 channels live, README clean, the clean win of the
cycle. The fleet (S109) confirmed **real but thin**: one honest, fail-closed subagent proof — not
labelled machinery, but not yet advancing the pipeline the instruments can see either (def-vs-dispatch
still two facts, not one wire; `cost_usd: null`). Launcher dogfood **🔴** — zero `vajra claude` runs
since S103 (4 calendar days / 6 sessions, live-confirmed, agrees with prior STATE flag). Score: 5🟢
4🟡 1🔴. No state drift found anywhere in `.ai/` — all cross-checked live against git/gh and agreed.
Meta-check: the K-of-8 pipeline-advance counter has no unit for fleet work (flagged, not fixed —
NO-CODE). Report: `sessions/session-110-ground-truth.md`.

**Founder pick for S111: A — close the def-vs-dispatch wire** (make the live subagent dispatch
demonstrably read `.claude/agents/researcher.md` by name — the real Claude Code subagent mechanism —
not a duplicated in-process prompt string; itemize the subagent's cost into the handoff or document
precisely why not).

**🔀 FOUNDER PIVOT (S103, still in force):** sessions now = **finish a shippable MVP**; the founder runs
the long unattended test himself, then release. Order **C → B → A**: C (team voice) = S104 ✓ →
**B (installable) = S106 + S107 + S108 ✓ COMPLETE** → **A (real named agent fleet) — S109 = first
slice ✓ (confirmed real-but-thin at S110 GT) → S111 closes the def-vs-dispatch wire.**

## Active PRs
- None open. **S109 [#115](https://github.com/ifelse-codes/vajra/pull/115) MERGED** 2026-08-03; local
  `main` synced with `origin/main` (`9d5d638`), no stray merged session branches locally.
- Prior merges: **S108 [#113](https://github.com/ifelse-codes/vajra/pull/113)** + S108-follow-up #114
  · S107 #112 · S106 #111 · S105-follow-up #110 · S105 #109 · S104 #108.

## Direction (governance is the product — now shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust layer**.
  Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained tamper-evident
  (`DECISION-004`). The fleet = **real named agents behind the existing gates** (`DECISION-007`, S109).
- **Post-pivot roadmap:** C team-voice (S104 ✓) → **B installable v0.1 (S106+S107+S108) ✓ COMPLETE,
  confirmed stranger-shippable at S110 GT** → **A fleet (S109 first slice ✓, confirmed real-but-thin at
  S110 GT; S111 closes the dispatch wire).** Release when v0.1 is stranger-shippable (it is); the
  founder owns the long unattended real-world test.
- **The machinery-freeze rule (`DECISION-005`) is RETIRED** (S105): the pivot cancelled ladder *sessions*.

## What Currently Works
- **v0.1 install: CONFIRMED stranger-shippable (S110 GT, live-checked).** README carries no
  "NOT YET PUBLISHED" rows; all 4 channels real: `cargo install --git|--path` (S106) · prebuilt
  `v0.1.0` release binary, no Rust (S107) · `cargo install vajractl` from crates.io (S108) ·
  `brew install ifelse-codes/tap/vajra` (S108). `install-smoke.sh` = 5 modes, all fail-closed.
- **The fleet's first named agent (S109), confirmed real-but-thin at S110 GT:** `vajra init` scaffolds
  `.claude/agents/researcher.md` from the canonical `fleet::ROLES` (one source, no drift); `vajra next
  --role researcher --from <findings>` governs a subagent brief into a delta-tracked, validated
  handoff in `.ai/handoffs/` — fail-closed on unknown role / missing `--from` / empty findings. Native
  Claude Code subagent model (DECISION-007). **Open gap S111 must close:** the def (scaffolded file)
  and the live dispatch (Task tool call) are proven separately, not as one wired path.
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
- **🟡→S111 target: The fleet's def-vs-dispatch wire is not proven end-to-end** (S109 fakest green,
  re-confirmed still open at S110 GT). `vajra init` scaffolds `.claude/agents/researcher.md` AND a
  real subagent ran — but the live subagent was dispatched by the orchestrator passing the canonical
  prompt to the Task tool, **not** by the Task tool reading the scaffolded file by name. S111 closes this.
- **🟡 A subagent's cost is `null` in the handoff** (S109). It rolls into the parent session receipt,
  not itemized per-run — so a fleet agent can't yet be priced individually. Honest null (S77 pattern),
  disclosed. **S111 attempts to itemize it; if the API genuinely can't, keep the null with a cited reason.**
- **🟡 Nothing downstream consumes the S109 handoff yet.** The handoff is written + validated, but no
  station/stage reads it automatically — "fleet" and "8 stations" are, for now, two overlapping stories.
  (S110 GT candidate B — deferred, not this session.)
- **🔴 The launcher (`vajra claude`) has NOT run since S103** (confirmed live at S110 GT: `--dogfood-age`
  reports 6 sessions / 4 calendar days since, agrees with this file). Zero launcher dogfood across
  S106–S109. Not blocking, but should not run much longer without a real paid call.
- **🟡 An unattended `claude -p` dispatch mode is unbuilt** (deferred, DECISION-007). The S109 handoff
  itself researched how: **`ANTHROPIC_API_KEY`** is the only auth that survives a fresh, no-TTY,
  no-keychain shell; `claude setup-token` is the subscription alternative; interactive OAuth won't do.
- **🟡 The K-of-8 pipeline-advance counter has no unit for fleet work** (S110 GT meta-check, new
  finding): a governed subagent handoff earns no station credit of its own. Flagged, not fixed.
- **🟡 KNOWLEDGE §6 bloat GROWING** (chronic since S60): 482 lines but 242KB (lines up to 6.7KB each) —
  prune still queued, not done. Confirmed still true at S110 GT.
- **🟡 `vajra.varta` re-render drifts every session** — `vajra check` FAILs "varta stale" (10/11,
  live-confirmed at S110 GT); no CLOSEOUT gate reads it.
- **🟡 `vajra --version` gap** · **🟡 `--dogfood-age` durable code fix** (recurse subdirs) · **🟡 brew
  smoke tests a LOCAL formula copy** (S108) · **🟡 x86_64 prebuilt proven by checksum, never executed**.
- **🟡 `fable-5` monthly credits exhausted (S102).** Paid launcher dogfood costs real $ on sonnet/opus.
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** (L3 `commit_guard: off`; L2 belt
  active) · **Compression no-op on real CC** (never claim until measured) · **Cross-agent breadth 0 code**.

## What Is In Progress
- **S110 DONE (NO-CODE GROUND TRUTH; PARTIAL, 5🟢/4🟡/1🔴, no drift found/corrected).** Report:
  `sessions/session-110-ground-truth.md`.
- **Next = S111 — CODE: close the fleet's def-vs-dispatch wire** (founder pick A). Prompt:
  `prompts/111-task-fleet-dispatch-wire.md`. **New chat.**
- **S112+ backlog (deferred at S110 GT, ranked B/C):** downstream handoff-consumption (B) · fleet
  role #2 (C) — both explicitly deferred until the dispatch wire (A) is proven.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative. S36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- S53–75: ~$0 each. **S76: real but UNKNOWN** (opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713** · **S97: $1.2758** · **S102: $0.4644** ·
  **S103: $0.6797** (all authoritative). **S104–109: ~$0 each** (S109's subagent tokens roll into the
  interactive session receipt, unitemized — `cost_usd: null`, disclosed).
- **S110: $0 (NO-CODE GT — no paid calls).**
- Cumulative: **~$79.3 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
