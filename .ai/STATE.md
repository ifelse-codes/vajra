# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
`session-112-handoff-consumption` — S112 complete, not yet merged (9 atomic commits).
S112 = **CODE: downstream handoff-consumption** (proposed at S111 closeout, founder-approved at S112
kickoff). **Verdict: SHIPPED.** S109 could WRITE a governed researcher handoff and S111 PROVED it came
from a real by-name subagent dispatch — but nothing ever read one back. The handoff was written,
validated, tamper-checked, and then orphaned: a human had to know to open `.ai/handoffs/` by hand.
S112 added the READ side — `fleet::parse_handoff` (pure) / `read_handoff` / `read_handoffs` (one
narrow fs-read-only edge) / `format_handoff_brief` — and wired it into **four surfaces**: the boot
packet (`vajra next`), the Analyst's intake (`--intake` and `--scaffold`), and the Analyst's gate
(`--validate NN`). Findings are **inlined**, not merely pointed at. **Absence prints nothing at all**
(a session with no fleet work reads byte-for-byte as before); an **off-contract handoff is NAMED**
(`⚠ … — not used`), never swallowed as absent; **truncation is disclosed** (`… N more line(s) — full
findings at <path>`). The **path, not the frontmatter, is the session source of truth** — a handoff
claiming `session: 999` at session 112's path is session 112's. Advisory by design: nothing blocks
(a gate firing on an artifact a session legitimately does not need would be false teeth). No
handoff-format change, no second role, no 8th command.
315 lib tests; verify **16/16**; demo exit 0; **two independent cold passes, both ACCEPT** (9/10
SHIPPED, 1 PARTIAL — CI-both-OS unevidenced pre-merge), attested `4d7b2b43…`. Report:
`sessions/session-112-summary.md` + `sessions/session-112-review.md`.

**Two-pass cold review earned its keep again.** Pass 1 (ACCEPT) found the packet and gate checks
asserted a section *header* that a REJECTED handoff prints too — they could not tell consumption from
refusal-to-consume; also found undisclosed truncation and a `Handoff` that could parse with blank
fields. Fixed (`eaff77d`). A **fresh** reviewer then graded the updated diff and found its own,
sharper hole: **`cargo test --lib <filter>` exits 0 when the filter matches ZERO tests**, so seven
named-test checks were green after a rename or deletion. Fixed (`26e5544`) with a guard-on-the-guard.

**🔀 FOUNDER PIVOT (S103, still in force):** sessions now = **finish a shippable MVP**; the founder runs
the long unattended test himself, then release. Order **C → B → A**: C (team voice) = S104 ✓ →
**B (installable) = S106 + S107 + S108 ✓ COMPLETE** → **A (real named agent fleet) — S109 first slice
✓, S111 dispatch wire ✓, S112 consumption loop ✓ CLOSED.**

## Active PRs
- None open yet for S112 (branch not pushed at write time). **S111 [#117](https://github.com/ifelse-codes/vajra/pull/117) MERGED** 2026-08-03; local `main` synced with `origin/main` (`825ca98`) at branch-cut, merged session locals pruned.
- Prior merges: S109 #115 · S110 closeout #116 · **S108 #113** + S108-follow-up #114 · S107 #112 ·
  S106 #111 · S105-follow-up #110 · S105 #109 · S104 #108.

## Direction (governance is the product — now shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust layer**.
  Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained tamper-evident
  (`DECISION-004`). The fleet = **real named agents behind the existing gates** (`DECISION-007`), now
  wired end-to-end **and consumed** (S109 write → S111 dispatch proof → S112 read).
- **Post-pivot roadmap:** C team-voice (S104 ✓) → **B installable v0.1 (S106+S107+S108) ✓ COMPLETE,
  confirmed stranger-shippable at S110 GT** → **A fleet (S109 ✓ + S111 ✓ + S112 ✓ — next: fleet credit
  in the K-of-8 counter, a second role, or an opt-in blocking gate).** Release when v0.1 is
  stranger-shippable (it is); the founder owns the long unattended real-world test.
- **The machinery-freeze rule (`DECISION-005`) is RETIRED** (S105): the pivot cancelled ladder *sessions*.

## What Currently Works
- **v0.1 install: CONFIRMED stranger-shippable (S110 GT, live-checked).** README carries no
  "NOT YET PUBLISHED" rows; all 4 channels real: `cargo install --git|--path` (S106) · prebuilt
  `v0.1.0` release binary, no Rust (S107) · `cargo install vajractl` from crates.io (S108) ·
  `brew install ifelse-codes/tap/vajra` (S108). `install-smoke.sh` = 5 modes, all fail-closed.
- **The fleet's first named agent — write, dispatch, AND read (S109 + S111 + S112):** `vajra init`
  scaffolds `.claude/agents/researcher.md` from the canonical `fleet::ROLES` (one source, no drift);
  a **fresh** Claude Code session's Task tool resolves `subagent_type: "researcher"` against that file
  **by name** (confirmed on disk via cross-referenced tool-call IDs); `vajra next --role researcher
  --from <findings>` governs the brief into a delta-tracked, validated handoff in `.ai/handoffs/`
  (fail-closed on unknown role / missing `--from` / empty findings); and **the pipeline now READS it
  back automatically** — the boot packet, the Analyst intake and the Analyst gate each surface the
  session's findings inline, silent when absent, naming an off-contract file rather than swallowing
  it. Real standing finding: a file scaffolded mid-session is invisible to that SAME session's Task
  tool (Claude Code snapshots `.claude/agents/*.md` at boot only) — the wire needs a fresh session,
  which is also exactly how a real Vajra user experiences it.
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
- **🔴 The launcher (`vajra claude`) has NOT run as a real governed session since S103** — now 9
  sessions / ~8 calendar days. S111's scratch-repo dispatch and S112's tempdir e2e are mechanism
  TESTS, not governed dogfood runs — neither resets this. Overdue; a candidate for S113.
- **🟡 Fleet consumption is ADVISORY, never blocking.** Nothing fails when a session ignores (or never
  reads) a governed handoff. Deliberate this session; an opt-in "this session requires a handoff"
  gate is the obvious next step, and equally the obvious way to build false teeth.
- **🟡 The K-of-8 pipeline-advance counter still has no unit for fleet work** (S110 GT meta-check).
  A governed subagent handoff — written OR consumed — earns no station credit of its own. Flagged
  three sessions running, not fixed.
- **🟡 An unattended `claude -p` dispatch mode is unbuilt** (deferred, DECISION-007). The S109 handoff
  itself researched how: **`ANTHROPIC_API_KEY`** is the only auth that survives a fresh, no-TTY,
  no-keychain shell; `claude setup-token` is the subscription alternative; interactive OAuth won't do.
- **🟡 `no-eighth-command` checks are a grep for a hardcoded usage banner** (S111 and S112 both) — an
  8th command whose author skipped the help text would pass. The non-goal holds structurally; the
  *check* does not enforce it. House-wide, named at S112, not fixed unilaterally.
- **🟡 KNOWLEDGE §6 bloat GROWING** (chronic since S60): 482 lines but 242KB (lines up to 6.7KB each) —
  prune still queued, not done.
- **🟡 `vajra.varta` re-render drifts every session** — `vajra check` FAILs "varta stale" (10/11,
  live-confirmed at S110 GT); no CLOSEOUT gate reads it.
- **🟡 `vajra --version` gap** · **🟡 `--dogfood-age` durable code fix** (recurse subdirs) · **🟡 brew
  smoke tests a LOCAL formula copy** (S108) · **🟡 x86_64 prebuilt proven by checksum, never executed**.
- **🟡 `fable-5` monthly credits exhausted (S102).** Paid launcher dogfood costs real $ on sonnet/opus.
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** (L3 `commit_guard: off`; L2 belt
  active) · **Compression no-op on real CC** (never claim until measured) · **Cross-agent breadth 0 code**.
- **🟡 CI-both-OS not yet evidenced for S112** — CI runs on the PR, so pre-merge delivery cannot show
  it (the same PARTIAL S109 and S111 carried).

## What Is In Progress
- **S112 DONE (CODE; SHIPPED; verify 16/16; demo exit 0; two cold passes, both ACCEPT, attested
  `4d7b2b43…`).** Report: `sessions/session-112-summary.md` + `sessions/session-112-review.md`.
  Branch `session-112-handoff-consumption` not yet merged.
- **Next = S113 — CODE: make fleet work visible to the counter, then choose the second role**
  (founder pick **A**). Prompt: `prompts/113-task-fleet-counter-and-second-role.md`. Deferred: the
  paid dogfood run (B) and an opt-in blocking consumption gate (C). **New chat.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative. S36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- S53–75: ~$0 each. **S76: real but UNKNOWN** (opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713** · **S97: $1.2758** · **S102: $0.4644** ·
  **S103: $0.6797** (all authoritative). **S104–109: ~$0 each** (S109's subagent tokens roll into the
  interactive session receipt, unitemized — `cost_usd: null`, disclosed).
- **S110: $0 (NO-CODE GT — no paid calls).**
- **S111: real but UNKNOWN in-chat** (interactive build session; the founder's own fresh-session
  dispatch test was a separate small paid call, cost in that scratch session's own receipt).
- **S112: $0 metered for the build; two cold-review subagent passes (~161k subagent tokens) roll into
  this interactive session's receipt, unitemized** — same structural reason as S109/S111
  (`scripts/check-subagent-cost-fields.sh`: no local subagent transcript carries a cost field).
- Cumulative: **~$79.3 + S76 (unknown, ≤ ~$26.6 opus-estimate) + S111/S112 (unknown, small).**
