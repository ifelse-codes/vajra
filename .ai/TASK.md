# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 125 — NO-CODE GROUND TRUTH + FULL-STACK REVIEW — COMPLETE (between sessions)

- **Verdict: PARTIAL PASS.** Discipline intact, direction drifted. All 10 required audits run ·
  ledger re-verified INTACT (`7862ebd4…`) · 339 lib tests green · zero `src/` changes · zero commits
  on the GT branch. Report: `sessions/session-125-ground-truth.md`. Prompt:
  `prompts/125-task-ground-truth.md`. Fidelity gate waived `VAJRA_CLOSEOUT_WAIVER=125` (NO-CODE —
  the report *is* the deliverable; no build exists to cold-review).
- **The founder widened the brief** beyond the standard GT into a four-layer diagnostic: execution
  audit · gap & bottleneck analysis · code & architecture review · vision re-alignment · a
  prioritized reboot plan.

**The headline: the loop is closed.** Vajra is graded by Vajra, in the repo that builds Vajra — and
nothing inside that loop can report that the wrong thing is being built. **16 consecutive sessions
(S109–S124) added no capability a new user can reach**; last user-reachable change was S108
(2026-08-01). Adoption after 55 days public: **0 stars · 0 forks · 0 issues · 0 external
contributors · 19 crates.io downloads.**

**Both sharpened lenses, answered independently:**
- **Why the fleet never engaged — STRUCTURAL, not discoverability.** S124's task prompt named all
  four roles AND required an independent cold review. It also said *"do not use it just because it
  is there"*; the one hard requirement named an **artifact** not an **actor**; and no gate anywhere
  consumes a handoff. Optional by construction.
- **Do S124's fabricated citations discredit prior verdicts? NO** — S122 + S123 suites re-run live,
  exit 0, 23/23 and 14/14. **But all twelve of their criteria were about the test suite testing
  itself** — reliable measurements of the wrong thing.

**🅿️ FOUNDER CALL AT CLOSEOUT: the S125 findings are PARKED, not worked.** Gate to unpark: **the
SDLC agent fleet is done AND working.** Recorded in three places so they surface at every boot:
`.ai/ROADMAP.md` §Backlog "🅿️ S125 REBOOT BACKLOG" (F1–F5, K1–K4, A1) · `.ai/KNOWLEDGE.md` §S125
(permanent facts) · `.ai/STATE.md` "What Is Broken / Weak" (🔴/🟡 rows).

**Recorded caveat, carried not argued:** findings 1–3 say the four roles already built are never
reached for, because the shipped scaffold never asks and no gate depends on them. Roles 5–9 inherit
that unless F1/F2 land — so *"and working"* is the load-bearing half of the gate, and proving the
fleet works may **be** F2.

**Next = S126 — CODE: finish the SDLC agent fleet.** Four roles exist (`researcher`,
`fidelity-reviewer`, `plan-advisor`, `qa-specialist`); five stations still have no named role:
**Analyst · Architect · Coder · Demo-er · Releaser.** Full prompt: `prompts/126-task-*.md`.
**New chat.**

**🔒 FOUNDER DIRECTIVE (S118, in force):** `README.md` / `VISION.md` claims are the **target spec**,
not a status report. **Never** soften them to match current capability — record gaps in `.ai/` and
session records instead. **No release** (crates.io `0.1.1`+, announcements, wider distribution)
until reality meets the claim.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Never work on `main`.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **Commits are ENFORCED (S93):** on a session branch, supply the un-forgeable marker —
  `VAJRA_ALLOW_COMMIT=NN git commit …`.
- **A GT session (`NN % 5 == 0`) cannot commit on its own branch** — the hook blocks it. Closeout
  commits ride a `session-NN-closeout` branch (the exempt suffix).
- **Attest LAST (S69):** `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff), recomputed strictly after
  the prompt's Execution shas are committed; two consecutive `verify-closeout.sh --inputs-sha NN`
  runs must agree before embedding.
- **Fill the Coder-gate `## Execution` shas before closeout, every session (S124).**
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3)** — a bullet list is BLOCKED,
  and a verdict wrapped in a table row also fails. Only a bare `**Verdict:** ACCEPT` line passes.
- **A falsifiability fixture must fail for the RIGHT reason (S122).**
- **Never trust a launched/dispatched agent's own self-report as evidence its criteria were met
  (S124).**
- **Never test the product only in the repo that builds it (S125).** Every bug S125 found was
  invisible for 125 sessions because no audit ever ran `vajra init` in an empty directory.
- **A role no gate consumes is decoration (S125).** Before adding role N, ask what blocks without it.
- **A block whose reason goes to stdout is invisible to the agent (S125).** Exit 2 stops the action;
  **stderr is what teaches.**
- **The "PR not yet opened" field is stale by construction every session (S125, 2nd sighting).**
- **`vajra init` blocks on stdin without EOF** — non-interactive callers need `</dev/null`.
- **Running the product is not enough to call a check execute-based (S121).** The ASSERTION has to
  bind to the behaviour.
- **crates.io is PUBLISHED (S108): `vajractl 0.1.0` is live — the name is BURNED (irreversible).**
  Any future crates.io action is founder-gated; never `cargo publish` without an explicit
  in-chat "yes publish".
- **Write `prompts/NN+1-task-<slug>.md` BEFORE closing** (`end_of_session`).
- **New session = new chat** — open a fresh chat for S126.
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a
  separate founder "yes". S125 added none (NO-CODE).
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions finish a shippable MVP (S103 pivot). **Current
  direction: FINISH THE SDLC AGENT FLEET (founder, S125 closeout).**
- **STATION ≠ ROLE:** the station governs the process (`src/qa/mod.rs`); the role does the work
  (`qa-specialist`). Same pattern for Reviewer/`fidelity-reviewer` and Planner/`plan-advisor` — a
  new role must take a distinct key, never the station's name.
