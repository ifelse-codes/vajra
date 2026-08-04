# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 112 — CODE: downstream handoff-consumption — COMPLETE

- **Verdict: SHIPPED.** The fleet's output stopped being an orphan. S109 could WRITE a governed
  researcher handoff and S111 PROVED it came from a real by-name subagent dispatch — but nothing ever
  read one back. S112 added the READ side (`fleet::parse_handoff` / `read_handoff(s)` /
  `format_handoff_brief`) and wired it into **four** surfaces: the boot packet (`vajra next`), the
  Analyst intake (`--intake`, `--scaffold`) and the Analyst gate (`--validate NN`) — findings
  **inlined**, not merely pointed at.
- **The honesty rules it ships with:** absence prints nothing at all · an off-contract handoff is
  NAMED (`— not used`), never swallowed as absent · truncation is disclosed (`… N more line(s)`) ·
  the PATH is the session source of truth, never the self-declared frontmatter.
- **Advisory by design — nothing blocks.** A gate firing on an artifact a session legitimately does
  not need would be false teeth. No handoff-format change, no second role, no 8th command.
- 315 lib tests; verify **16/16**; demo exit 0; **two independent cold passes, both ACCEPT** (9/10
  SHIPPED, 1 PARTIAL — CI-both-OS unevidenced pre-merge), attested `4d7b2b43…`. Report:
  `sessions/session-112-summary.md` + `sessions/session-112-review.md`.

**🔀 FOUNDER PIVOT (S103, in force):** sessions now = **finish a shippable MVP**; founder runs the
long unattended test himself. Order **C → B → A**: C team-voice (S104 ✓) → **B installable
(S106+S107+S108) ✓ COMPLETE** → **A real agent fleet — S109 first slice ✓, S111 dispatch wire ✓,
S112 consumption loop ✓ CLOSED.**

Between sessions. **Next = S113 — CODE: make fleet work visible to the counter, then choose the
second role** (founder pick **A** at the S112 closeout). The K-of-8 counter cannot see fleet work at
all — flagged at S110 GT, carried at S111 and S112. Brief:
`prompts/113-task-fleet-counter-and-second-role.md`. Deferred: the paid dogfood run (B) and an
opt-in blocking consumption gate (C). **New chat** for S113.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Never work on `main`.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **Commits are ENFORCED (S93):** on a session branch, supply the un-forgeable marker —
  `VAJRA_ALLOW_COMMIT=NN git commit …`.
- **crates.io is PUBLISHED (S108): `vajractl 0.1.0` is live — the name is now BURNED (irreversible).**
  Any future crates.io action (a `0.1.1`, a yank) is still founder-gated; never `cargo publish` without
  an explicit in-chat "yes publish". `cargo login` is the founder's own step (a token — never handled by the agent).
- **Fleet dispatch = native Claude Code subagents (DECISION-007), proven end-to-end (S111) and now CONSUMED (S112):** Vajra
  scaffolds the role + governs the handoff; a fresh session's Task tool resolves `subagent_type`
  against the scaffolded file by name (confirmed on disk, not asserted). It does NOT spawn `claude -p`.
  An unattended `claude -p` mode is deferred (`ANTHROPIC_API_KEY` is the way — per the S109 handoff).
- **Cost-null checks ride `scripts/check-subagent-cost-fields.sh`** — re-runnable, local-machine-only
  (same limitation class as `--dogfood-age`); reuse it, don't re-derive the grep by hand.
- **Write `prompts/NN+1-task-<slug>.md` BEFORE closing** (`end_of_session`) — no gate catches a miss.
- **New session = new chat** — open a fresh chat for S113; do NOT start it here.
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a separate founder "yes".
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions now finish a shippable MVP (S103 pivot).
