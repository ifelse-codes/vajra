# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 116 — CODE: the fleet's third role, the Plan Advisor — COMPLETE

- **Verdict: ACCEPT** (independent cold review, `subagent_type: "fidelity-reviewer"` by name — 10 of
  12 SHIPPED). Third `fleet::ROLES` entry, key `plan-advisor` (distinct from the Planner **station**,
  `src/planner/mod.rs`, S64 — the same collision the Reviewer hit at S114, now resolved a second
  time). Zero new machinery: `vajra init`, `vajra next`, and the S113 counter needed no code changes —
  confirmed by tracing the actual code, not just asserting it.
- **The 2 PARTIALs:** the read-only reviewer (no Bash tool) correctly declined to grade
  `cargo test --lib` / `verify-session-116.sh` / `demo-session-116.sh` as executed by itself. The
  builder ran all three green in this session with captured terminal evidence (323 tests; 16/16;
  10/10) — stated plainly as the builder's own claim, not independently re-run by the reviewer.
- **The one decision the prompt demanded in writing:** the role key is `plan-advisor`, not `planner`
  (`DECISION-007` S116 addendum, 2 rejected alternatives — "the role IS the station" and the two
  longer alternative spellings named in the prompt). `resolve_role("planner").is_none()` asserted.
- Attested `1b6c0159ad26b268cebef5ac003f4206deb50121b4d9dc4a7937f35fe91e5079`. Summary:
  `sessions/session-116-summary.md`. Review: `sessions/session-116-review.md`.

**🔀 FOUNDER PIVOT (S103, in force):** sessions now = **finish a shippable MVP**; founder runs the
long unattended test himself. Order **C → B → A**: C team-voice (S104 ✓) → **B installable ✓
COMPLETE** → **A real agent fleet — S109 ✓, S111 ✓, S112 ✓, S113 ✓, S114 ✓, S115 dispatch proof ✓,
S116 third role ✓.**

Between sessions. **Next = S117 — CODE: prove the Plan Advisor dispatches by name** (founder pick A
at the S116 closeout, over B: the paid dogfood, and C: wiring fleet handoffs into station gates).
Mirrors S115's proof for the Reviewer, now on the third role. Brief:
`prompts/117-task-plan-advisor-dispatch.md`. Deferred by explicit founder call: the paid dogfood
(🔴 13+ sessions) — next GT (S120) should press on it if S117–S119 don't reach it either. **New
chat** for S117.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Never work on `main`.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **Commits are ENFORCED (S93):** on a session branch, supply the un-forgeable marker —
  `VAJRA_ALLOW_COMMIT=NN git commit …`.
- **Attest LAST (S69, hit at S114 AND S116):** `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff) and
  the PROMPT IS AN INPUT — recompute strictly after the prompt's Execution shas are committed and
  confirm two consecutive `verify-closeout.sh --inputs-sha NN` runs agree before embedding. **S116
  correction:** the `diff` half excludes `prompts/`/`sessions/`, but the `prompt` half is
  `git show HEAD:<prompt file>` read whole — filling in the LAST Execution sha changed the hash
  despite the diff-exclusion, caught before embedding by re-running `--inputs-sha` after that edit.
  Never assume a prompt edit is diff-hash-neutral just because `prompts/` is excluded from the diff.
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3)** — a bullet list is BLOCKED.
  **A verdict line wrapped in a `|`-table row also fails the canonical-verdict regex (S115 finding)**
  — only a bare `**Verdict:** ACCEPT`/`REJECT` line passes. Write it as its own line, not a table cell.
- **The fleet has THREE roles built (Researcher, Fidelity Reviewer, Plan Advisor).** Researcher and
  Fidelity Reviewer are proven dispatched by name (S111, S115); the Plan Advisor is NOT yet — S117's
  whole job. `reviewer/SKILL.md` is CANONICAL and the Reviewer role brief is its summary — bound by a
  check reading both files (the Plan Advisor has no such second-source counterpart).
- **Dispatch-by-name is PROVEN for the next-session case on two roles (S111, S115), not the
  mid-creating-session case (still presumed to fail, S111).** Untested for the Plan Advisor — S117.
- **A new fleet role's regression check should target the most recent COUNT-AGNOSTIC prior verify
  script**, not simply the most recent one — a prior script's hardcoded role count (e.g.
  `verify-session-114.sh`'s "exactly 2") goes stale by construction as the fleet grows; that is
  expected staleness, not a regression, but must be named, not silently routed around (S116 finding).
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
- **New session = new chat** — open a fresh chat for S117; do NOT start it here.
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a separate founder "yes".
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions now finish a shippable MVP (S103 pivot).
