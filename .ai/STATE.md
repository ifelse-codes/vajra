# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S109 complete, S110 not yet started).
S109 = **CODE: fleet slice 1 — Researcher as a governed Claude Code subagent** — the C→B→A order's
**A** (first slice). **Goal achieved:** the fleet's first named agent ships as a **native Claude Code
subagent** that Vajra scaffolds + governs. `DECISION-007` locks it. `vajra init` scaffolds
`.claude/agents/researcher.md` from the ONE canonical source (`fleet::ROLES`, no drift); `vajra next
--role researcher --from <findings>` governs a subagent brief into a **delta-tracked, validated**
handoff at `.ai/handoffs/session-NN-researcher.md` — **fail-closed** on unknown role / missing
`--from` / empty findings. Rides `init` + `next` (**no 8th command**). **Live proof:** a real
Researcher subagent (Task tool, sonnet, 58,669 tok, 4 tools) ran in-session and its brief was governed
into `.ai/handoffs/session-109-researcher.md` (validated, source-sha `ffa5b3fd…`). verify **9/9**; demo
exit 0 (4 markers); 304 lib tests; **CI green both OS**; cold review **ACCEPT**, attested `2a8d3399…`.
**PR #115.**

**🔀 MID-SESSION MECHANISM REDIRECT (founder, S109):** the first build spawned a paid `claude -p`
subprocess (`vajra claude --role`) — it hit a headless **"Not logged in" auth wall** (a bare
`claude -p` fails identically; clearing it needs a credential only the human can supply). Founder chose
**subagent-only**; the `claude -p` path was **reverted** (`launch.rs` restored to pristine). No
separate paid call — the subagent inherits the live session's auth. DECISION-007 records the subprocess
path as the rejected alternative.

**🔀 FOUNDER PIVOT (S103, still in force):** sessions now = **finish a shippable MVP**; the founder runs
the long unattended test himself, then release. Order **C → B → A**: C (team voice) = S104 ✓ →
**B (installable) = S106 + S107 + S108 ✓ COMPLETE** → **A (real named agent fleet) — S109 = first
slice ✓; more roles / handoff-consumption / an unattended mode still to come.**

## Active PRs
- **S109:** [#115](https://github.com/ifelse-codes/vajra/pull/115) (`session-109-fleet-researcher`) —
  fleet slice 1 (subagent model): DECISION-007 + `src/fleet` + init scaffold + `next --role --from`
  govern + smoke/verify/demo + live subagent handoff. CI green both OS. Cold review ACCEPT, attested
  `2a8d3399…`. To merge at founder direction.
- Merged: **S108 [#113](https://github.com/ifelse-codes/vajra/pull/113)** + S108-follow-up #114 · S107
  #112 · S106 #111 · S105-follow-up #110 · S105 #109 · S104 #108.

## Direction (governance is the product — now shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust layer**.
  Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained tamper-evident
  (`DECISION-004`). The fleet = **real named agents behind the existing gates** (`DECISION-007`, S109).
- **Post-pivot roadmap:** C team-voice (S104 ✓) → **B installable v0.1 (S106+S107+S108) ✓ COMPLETE** →
  **A fleet (S109 = first slice ✓ — the Researcher as a governed subagent).** Release when v0.1 is
  stranger-shippable (it is); the founder owns the long unattended real-world test.
- **The machinery-freeze rule (`DECISION-005`) is RETIRED** (S105): the pivot cancelled ladder *sessions*.

## What Currently Works
- **The fleet's first named agent (S109):** `vajra init` scaffolds `.claude/agents/researcher.md` from
  the canonical `fleet::ROLES` (one source, no drift); `vajra next --role researcher --from <findings>`
  governs a subagent brief into a delta-tracked, validated handoff in `.ai/handoffs/` — fail-closed on
  unknown role / missing `--from` / empty findings. Native Claude Code subagent model (DECISION-007).
- **v0.1 is installable FOUR ways, each proven by a falsifiable instrument:** `cargo install
  --git|--path` (S106) · prebuilt `v0.1.0` release binary, no Rust (S107) · `cargo install vajractl`
  from crates.io (S108) · `brew install ifelse-codes/tap/vajra` (S108). `install-smoke.sh` = 5 modes,
  all fail-closed.
- **The 8-station governed pipeline speaks like a team** (S104): `vajra next --stations` + the packet
  render named roles + plain status from one source; gates/K unchanged.
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner · Coder ·
  QA · Demo-er · Releaser · Reviewer (fidelity gate + attested, chained ledger). Receipt AUTHORITATIVE
  when `total_cost_usd` exists, HONEST when it doesn't (S77).
- **Ledger** (S100): `verify-closeout.sh --ledger-verify` → INTACT, tamper-evident (`DECISION-004`).
- **CI green on `main`** (both OS); `vajra claude · next · check · init · estimate · meter · hook` —
  **7 commands, no 8th** (the fleet rides `init` + `next`).

## What Is Broken / Weak
- **🟡 The fleet's def-vs-dispatch wire is not proven end-to-end** (S109 fakest green). `vajra init`
  scaffolds `.claude/agents/researcher.md` AND a real subagent ran — but the live subagent was
  dispatched by the orchestrator passing the canonical prompt to the Task tool, **not** by the Task
  tool reading the scaffolded `.claude/agents/researcher.md` by name. Both halves real; the wire is not.
- **🟡 A subagent's cost is `null` in the handoff** (S109). It rolls into the parent session receipt,
  not itemized per-run — so a fleet agent can't yet be priced individually (weakens autopilot-trust
  costing). Honest null (S77 pattern), disclosed.
- **🟡 Nothing downstream consumes the S109 handoff yet.** The handoff is written + validated, but no
  station/stage reads it automatically — "fleet" and "8 stations" are, for now, two overlapping stories.
- **🟡 An unattended `claude -p` dispatch mode is unbuilt** (deferred, DECISION-007). The S109 handoff
  itself researched how: **`ANTHROPIC_API_KEY`** is the only auth that survives a fresh, no-TTY,
  no-keychain shell; `claude setup-token` is the subscription alternative; interactive OAuth won't do.
- **🟡 The launcher (`vajra claude`) has NOT run since S103** — S109's headline was a *subagent* run,
  not a launcher run. `--dogfood-age` measures launcher runs; decide at S110 GT whether a subagent run
  counts as dogfood.
- **🟡 KNOWLEDGE §6 bloat GROWING** (chronic since S60): prune queued, not done.
- **🟡 `vajra.varta` re-render drifts every session** — `vajra check` FAILs "varta stale"; no CLOSEOUT
  gate reads it.
- **🟡 `vajra --version` gap** · **🟡 `--dogfood-age` durable code fix** (recurse subdirs) · **🟡 brew
  smoke tests a LOCAL formula copy** (S108) · **🟡 x86_64 prebuilt proven by checksum, never executed**.
- **🟡 `fable-5` monthly credits exhausted (S102).** Paid launcher dogfood costs real $ on sonnet/opus.
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** (L3 `commit_guard: off`; L2 belt
  active) · **Compression no-op on real CC** (never claim until measured) · **Cross-agent breadth 0 code**.

## What Is In Progress
- **S109 DONE (CODE — fleet slice 1, subagent model; ACCEPT, attested, CI green).** PR #115 to merge.
- **Next = S110 — NO-CODE GROUND TRUTH** (mandatory every 5th; audits S106–S109). **Founder-picked lead
  lens: "is the fleet REAL and advancing, or labelled machinery — and is v0.1 stranger-shippable?"**
  Prompt: `prompts/110-task-ground-truth.md`. **New chat.**
- **S111 = next CODE slice** (founder pick after the S110 GT — candidates: fleet role #2 · downstream
  handoff-consumption · the unattended `claude -p` + `ANTHROPIC_API_KEY` mode).

## Cost Tracking
- Session 00–30: ~$0.46 cumulative. S36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- S53–75: ~$0 each. **S76: real but UNKNOWN** (opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713** · **S97: $1.2758** · **S102: $0.4644** ·
  **S103: $0.6797** (all authoritative). **S104–108: ~$0 each.**
- **S109: no separately-metered paid launcher call** (the paid `claude -p` attempt hit the auth wall
  and spent **$0** — 0 tokens). The live proof was an in-session **subagent** (58,669 tokens, sonnet)
  whose cost rolls into this interactive session's receipt (not itemized here; `cost_usd: null`).
- Cumulative: **~$79.3 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
