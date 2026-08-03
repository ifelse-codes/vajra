# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 109 — CODE: fleet slice 1 — Researcher as a governed Claude Code subagent — COMPLETE

- **Delivered (goal achieved):** the fleet's first named agent ships as a **native Claude Code
  subagent**, scaffolded + governed by Vajra. `DECISION-007` locks it. `vajra init` scaffolds
  `.claude/agents/researcher.md` from the ONE canonical source (`fleet::ROLES`, no drift); `vajra next
  --role researcher --from <findings>` governs a subagent's brief into a **delta-tracked, validated
  handoff** at `.ai/handoffs/session-NN-researcher.md` — **fail-closed** on unknown role / missing
  `--from` / empty findings. Rides `init` + `next` (**no 8th command**; `--help` still 7). **Live
  proof:** a real Researcher subagent (Task tool, sonnet, 58,669 tok, 4 tools) ran in-session and its
  brief was governed into the S109 handoff (validated, source-sha `ffa5b3fd…`). verify **9/9**; demo
  exit 0 (4 markers); 304 lib tests; **CI green both OS**; cold review **ACCEPT**, attested
  `2a8d3399…`. **PR #115.**
- **🔀 MID-SESSION MECHANISM REDIRECT (founder):** the first build spawned a paid `claude -p`
  subprocess (`vajra claude --role`) — it hit a headless "Not logged in" auth wall only the human can
  clear. Founder chose **subagent-only**; the `claude -p` path was **reverted** (no separate paid
  call — the subagent inherits the session auth). Fakest green (disclosed): the scaffolded def and the
  live run are proven *separately*, not as one wired "dispatch-by-name" flow; `cost_usd: null`.

**🔀 FOUNDER PIVOT (S103, in force):** sessions now = **finish a shippable MVP**; founder runs the
long unattended test himself. Order **C → B → A**: C team-voice (S104 ✓) → **B installable
(S106+S107+S108) ✓ COMPLETE** → **A real agent fleet — S109 = first slice ✓, more to come**.

Between sessions. **Next = S110 — NO-CODE GROUND TRUTH** (mandatory every 5th; audits S106–S109).
**Founder-picked lead lens: "is the fleet REAL and advancing, or labelled machinery — and is v0.1
stranger-shippable?"** Brief: `prompts/110-task-ground-truth.md`. **New chat** for S110.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. **S110 = NO-CODE GT** — no `src/`, no commits/PRs; drift-corrections
  only, on a `session-110-closeout` branch (exempt by suffix).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **Commits are ENFORCED (S93):** on a session branch, supply the un-forgeable marker —
  `VAJRA_ALLOW_COMMIT=NN git commit …`.
- **crates.io is PUBLISHED (S108): `vajractl 0.1.0` is live — the name is now BURNED (irreversible).**
  Any future crates.io action (a `0.1.1`, a yank) is still founder-gated; never `cargo publish` without
  an explicit in-chat "yes publish". `cargo login` is the founder's own step (a token — never handled by the agent).
- **Fleet dispatch = native Claude Code subagents (DECISION-007):** Vajra scaffolds the role +
  governs the handoff; it does NOT spawn `claude -p` (that path was tried + reverted — headless-auth
  wall). An unattended `claude -p` mode is deferred (`ANTHROPIC_API_KEY` is the way — per the S109 handoff).
- **Write `prompts/NN+1-task-<slug>.md` BEFORE closing** (`end_of_session`) — no gate catches a miss.
- **New session = new chat** — open a fresh chat for S110; do NOT start it here.
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a separate founder "yes".
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions now finish a shippable MVP (S103 pivot).
