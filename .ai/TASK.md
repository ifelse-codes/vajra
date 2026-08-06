# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 114 — CODE: the fleet's second role, the Fidelity Reviewer — COMPLETE

- **Verdict: SHIPPED.** The cold fidelity review this repo has run **47 times by hand** is now a
  canonical, scaffolded, governed role. The headline is what did NOT happen: **`src/cli/init.rs` is
  untouched in the whole diff** — it already iterated `fleet::ROLES`, so one entry bought the
  scaffold, the governed handoff, the read-back and the counter. No new machinery, no 8th command.
- **Both open items closed in writing** (`DECISION-007` S114 addendum, each with rejected
  alternatives): the key is **`fidelity-reviewer`** (never `reviewer` — `K of 8` counts a Reviewer
  STATION), and the handoff is a **PRE-STAGE INPUT** while `sessions/session-NN-review.md` stays the
  **single record of record** (no gate reads a handoff; the role has no write tool).
- **A third open item was found by the review itself:** `reviewer/SKILL.md` already stated this
  contract — 127 hand-maintained lines scaffolded by the same `vajra init` — which this session's own
  approved prompt asserted did not exist. The two are now **BOUND** by a check that reads both files
  and requires every closeout-gate token in each. **A premise in an approved prompt is not evidence.**
- **322 lib tests; verify 17/17; demo 10/10 exit 0; two cold passes — pass 1 REJECT → fixed → a
  FRESH pass 2 ACCEPT (13 of 13 SHIPPED)** — attested `cbd22d3a…`. Fakest green, disclosed: the
  role's TEXT is guarded by presence-greps only; pass 2 swapped it for rubber-stamp token soup and
  the whole suite stayed green. Reports: `sessions/session-114-summary.md` + `-review.md`.

**🔀 FOUNDER PIVOT (S103, in force):** sessions now = **finish a shippable MVP**; founder runs the
long unattended test himself. Order **C → B → A**: C team-voice (S104 ✓) → **B installable ✓
COMPLETE** → **A real agent fleet — S109 ✓, S111 ✓, S112 ✓, S113 ✓, S114 second role BUILT ✓.**

Between sessions. **Next = S115 — MANDATORY NO-CODE GROUND TRUTH** (`115 % 5 == 0`): no source
edits, no code commits, no PRs beyond the GT artifact. Its one live opportunity: S115 is the **first
session that can dispatch `subagent_type: "fidelity-reviewer"` by name** (S111's boot-snapshot
limit), and doing so is evidence-gathering, not code. Brief: `prompts/115-task-ground-truth.md`.
Deferred for the founder's pick at the S115 closeout: the overdue paid dogfood (🔴 11 sessions) and
an opt-in blocking consumption gate. **New chat** for S115.

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
- **The fleet has TWO roles; `reviewer/SKILL.md` is CANONICAL and the role brief is its summary** —
  they are bound by a check reading both files. Never edit one alone.
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
- **New session = new chat** — open a fresh chat for S115; do NOT start it here.
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a separate founder "yes".
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions now finish a shippable MVP (S103 pivot).
