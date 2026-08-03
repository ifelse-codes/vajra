# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 111 — CODE: close the fleet's def-vs-dispatch wire — COMPLETE

- **Verdict: SHIPPED.** Proved, on disk, that a fresh `vajra claude` session dispatches the scaffolded
  `.claude/agents/researcher.md` subagent BY NAME — cross-referenced via matching tool-call IDs across
  two independently-written Claude Code files (a hand-copied single JSON blob was correctly flagged as
  too weak by a cold-review round and replaced). A real, disclosed negative result along the way: the
  SAME live session cannot hot-reload a newly-scaffolded `.claude/agents/*.md` file — Claude Code
  snapshots the available subagent list once, at session boot.
- **Cost:** `cost_usd: null` kept, now for a checked, re-runnable reason —
  `scripts/check-subagent-cost-fields.sh` scans every local subagent JSONL and finds zero carrying a
  cost key (same root cause as S77/S78).
- **No dispatch-path code changed** — S109 had already built it correctly; S111 supplied the missing
  proof. verify 9/9; demo exit 0; 304 lib tests; cold review **ACCEPT** (13/14 SHIPPED, 1 PARTIAL —
  CI-both-OS unevidenced pre-merge), attested `f98808bc…`. Report: `sessions/session-111-summary.md` +
  `sessions/session-111-review.md`.

**🔀 FOUNDER PIVOT (S103, in force):** sessions now = **finish a shippable MVP**; founder runs the
long unattended test himself. Order **C → B → A**: C team-voice (S104 ✓) → **B installable
(S106+S107+S108) ✓ COMPLETE** → **A real agent fleet — S109 first slice ✓, S111 dispatch wire ✓
CLOSED. Next: downstream handoff-consumption (S112, proposed) or a second role.**

Between sessions. **Next = S112 — CODE (proposed): downstream handoff-consumption** — nothing today
reads `.ai/handoffs/session-NN-researcher.md` automatically. Brief:
`prompts/112-task-handoff-consumption.md` (drafted, pending founder confirmation at kickoff).
**New chat** for S112.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Never work on `main`.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **Commits are ENFORCED (S93):** on a session branch, supply the un-forgeable marker —
  `VAJRA_ALLOW_COMMIT=NN git commit …`.
- **crates.io is PUBLISHED (S108): `vajractl 0.1.0` is live — the name is now BURNED (irreversible).**
  Any future crates.io action (a `0.1.1`, a yank) is still founder-gated; never `cargo publish` without
  an explicit in-chat "yes publish". `cargo login` is the founder's own step (a token — never handled by the agent).
- **Fleet dispatch = native Claude Code subagents (DECISION-007), proven end-to-end (S111):** Vajra
  scaffolds the role + governs the handoff; a fresh session's Task tool resolves `subagent_type`
  against the scaffolded file by name (confirmed on disk, not asserted). It does NOT spawn `claude -p`.
  An unattended `claude -p` mode is deferred (`ANTHROPIC_API_KEY` is the way — per the S109 handoff).
- **Cost-null checks ride `scripts/check-subagent-cost-fields.sh`** — re-runnable, local-machine-only
  (same limitation class as `--dogfood-age`); reuse it, don't re-derive the grep by hand.
- **Write `prompts/NN+1-task-<slug>.md` BEFORE closing** (`end_of_session`) — no gate catches a miss.
- **New session = new chat** — open a fresh chat for S112; do NOT start it here.
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a separate founder "yes".
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions now finish a shippable MVP (S103 pivot).
