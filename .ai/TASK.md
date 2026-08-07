# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 115 — NO-CODE GROUND TRUTH (audits S111–S114) — COMPLETE

- **Verdict: PARTIAL PASS.** The session's one live opportunity worked: `subagent_type:
  "fidelity-reviewer"` dispatched by name on the first try, in this fresh session, retiring the S111
  "invisible until next session" limitation for that case. Its verdict content matched S114's own
  two-pass finding almost exactly (13 of 13 SHIPPED, independently re-derived the same fakest green).
- **New real finding:** the raw dispatched verdict's canonical line — `| **Verdict:** | ACCEPT |`
  (table-formatted) — does **not** match `verify-closeout.sh`'s line-anchored regex; confirmed by
  running the actual regex against the actual raw output, not a paraphrase. A bare `**Verdict:**
  ACCEPT` line passes. Only findable on a live agent's own formatting choices; filed, not fixed
  (NO-CODE). Governance mechanics (S112 read-side + S113 counter) worked cleanly on the new role.
- **PARTIAL, not PASS, because:** launcher dogfood is now **12 sessions / ~11 calendar days** stale —
  longest gap since the metric existed, flagged at every GT since S105 (6th+ consecutive), and this
  session's top recommendation (a real paid dogfood run) was explicitly passed over by the founder for
  a third fleet role. `--dogfood-age`'s date field also has a diagnosed residual bug (uses the
  receipt-backfill commit's date, not the run date) — STATE.md's own date was already correct.
- **Meta-check finding:** no standing GT audit checks whether an approved prompt's own factual
  premises are true (only ad hoc two-pass review caught S114's false premise) — named as a real gap in
  the audit list, not fixed. Report: `sessions/session-115-ground-truth.md`.

**🔀 FOUNDER PIVOT (S103, in force):** sessions now = **finish a shippable MVP**; founder runs the
long unattended test himself. Order **C → B → A**: C team-voice (S104 ✓) → **B installable ✓
COMPLETE** → **A real agent fleet — S109 ✓, S111 ✓, S112 ✓, S113 ✓, S114 second role ✓, S115 dispatch
proof ✓ (GT).**

Between sessions. **Next = S116 — CODE: the fleet's THIRD named role, the Planner** (founder pick B at
the S115 closeout, over the recommended paid-dogfood A; role named Planner specifically, read-only/
advisory shape, not the code-writing Coder). Load-bearing open item: the role key collides with the
existing Planner **station** — resolve in writing (distinct key or explicit "IS the station"
statement), mirroring the S114 Reviewer-key precedent. Brief: `prompts/116-task-fleet-role-planner.md`.
Deferred by explicit founder call: the paid dogfood (🔴 12+ sessions) — next GT should revisit if S116
doesn't reach it. **New chat** for S116.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Never work on `main`.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **Commits are ENFORCED (S93):** on a session branch, supply the un-forgeable marker —
  `VAJRA_ALLOW_COMMIT=NN git commit …`.
- **Attest LAST (S69, hit twice at S114):** `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff) and the
  PROMPT IS AN INPUT — recompute after the prompt's Execution shas are committed, and confirm two
  consecutive `verify-closeout.sh --inputs-sha NN` runs agree before embedding.
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3)** — a bullet list is BLOCKED.
  **NEW (S115): a verdict line wrapped in a `|`-table row also fails the canonical-verdict regex** —
  only a bare `**Verdict:** ACCEPT`/`REJECT` line passes. Write it as its own line, not a table cell.
- **The fleet has TWO roles built (Researcher, Fidelity Reviewer), a THIRD (Planner) approved for
  S116; `reviewer/SKILL.md` is CANONICAL and the role brief is its summary** — bound by a check
  reading both files. Never edit one alone.
- **Dispatch-by-name is PROVEN for the next-session case (S115), not just the boot-list case.** A role
  created mid-session is still presumed undispatchable in that same session (S111); untested, not
  retested.
- **crates.io is PUBLISHED (S108): `vajractl 0.1.0` is live — the name is now BURNED (irreversible).**
  Any future crates.io action (a `0.1.1`, a yank) is still founder-gated; never `cargo publish` without
  an explicit in-chat "yes publish". `cargo login` is the founder's own step (a token — never handled by the agent).
- **Fleet dispatch = native Claude Code subagents (DECISION-007), proven end-to-end (S111, S115) and
  CONSUMED (S112):** Vajra scaffolds the role + governs the handoff; a fresh session's Task tool
  resolves `subagent_type` against the scaffolded file by name. It does NOT spawn `claude -p`. An
  unattended `claude -p` mode is deferred (`ANTHROPIC_API_KEY` is the way — per the S109 handoff).
- **Cost-null checks ride `scripts/check-subagent-cost-fields.sh`** — re-runnable, local-machine-only
  (same limitation class as `--dogfood-age`); reuse it, don't re-derive the grep by hand.
- **Write `prompts/NN+1-task-<slug>.md` BEFORE closing** (`end_of_session`) — no gate catches a miss.
- **New session = new chat** — open a fresh chat for S116; do NOT start it here.
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a separate founder "yes".
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions now finish a shippable MVP (S103 pivot).
