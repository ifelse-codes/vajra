# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 113 — CODE: fleet work visible to the counter + the second role chosen — COMPLETE

- **Verdict: SHIPPED.** The pipeline's own progress metric could not see the fleet at all: a session
  that dispatched a named agent, governed its findings and consumed them scored the same `K of 8` as
  one that did none of it (flagged at S110 GT, carried at S111 and S112). `vajra next --stations NN`
  now reports fleet evidence **BESIDE** K — `stations::FleetEvidence` + `format_fleet_line`, derived
  from `fleet::read_handoffs` (the handoff is parsed and VALIDATED off disk, never a typed marker).
- **K-of-8 is unchanged in meaning, and it is CHECKED:** the report minus the fleet line is
  byte-identical to the pre-handoff report, and a test asserts K is invariant under *any* fleet
  evidence. Design shape **(c)** — rejected a 9th station and rejected folding it into a station's
  verdict (old and new K would look identical while measuring different things).
- **Second role CHOSEN, not built: the Reviewer** (`DECISION-007` S113 addendum) — 46 cold reviews on
  disk, mandated by DECISION-002, hand-typed every session today, output already gated + attested +
  ledgered, read-only tools. Four alternatives rejected; the `reviewer` role vs Reviewer *station*
  name collision recorded for the build session to resolve.
- **The honest limit, stated everywhere:** the line certifies *a contract-valid handoff exists*, not
  *an agent was dispatched*. 317 lib tests; verify **14/14**; demo **7/7** exit 0; **two** independent
  cold passes, both ACCEPT, attested `d478a022…`. Reports: `sessions/session-113-summary.md` +
  `sessions/session-113-review.md`.

**🔀 FOUNDER PIVOT (S103, in force):** sessions now = **finish a shippable MVP**; founder runs the
long unattended test himself. Order **C → B → A**: C team-voice (S104 ✓) → **B installable
(S106+S107+S108) ✓ COMPLETE** → **A real agent fleet — S109 first slice ✓, S111 dispatch wire ✓,
S112 consumption loop ✓, S113 counter-visibility + second role chosen ✓.**

Between sessions. **Next = S114 — founder pick pending:** A build the Reviewer role · B the overdue
paid `vajra claude` dogfood (🔴 since S103) · C an opt-in blocking consumption gate. Prompt written at
closeout. **New chat** for S114. (S115 = the next NO-CODE ground truth.)

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
- **New session = new chat** — open a fresh chat for S114; do NOT start it here.
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a separate founder "yes".
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions now finish a shippable MVP (S103 pivot).
