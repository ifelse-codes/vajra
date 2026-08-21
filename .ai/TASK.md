# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 126 — CODE: FINISH THE SDLC AGENT FLEET — COMPLETE (between sessions)

- **Verdict: ACCEPT** — independent cold `fidelity-reviewer` pass, **7 of 9 SHIPPED**, 2 PARTIAL,
  0 NOT-BUILT (the two PARTIALs were the review record and this summary, which cannot exist in the
  diff the reviewer reads). Report: `sessions/session-126-summary.md`. Review:
  `sessions/session-126-review.md`. Prompt: `prompts/126-task-finish-the-fleet.md`.
- **The roster is COMPLETE: four roles → nine.** Every station has a named role, plus the
  station-less `researcher`: `requirements-analyst` (Analyst) · `design-advisor` (Architect) ·
  `plan-advisor` (Planner) · `implementation-advisor` (Coder) · `qa-specialist` (QA) ·
  `demo-producer` (Demo-er) · `release-coordinator` (Releaser) · `fidelity-reviewer` (Reviewer).
- **Five roles added, ZERO new grants of `Bash`.** The Coder role is deliberately read-only and
  deliberately not named `coder`; granting it `Write`/`Edit` would reverse S123 and the S122
  executor-thesis retraction in the same session that ships it. That grant is now a separate,
  founder-gated decision (`DECISION-007` S126 addendum).
- **All five dispatched BY NAME from five separate headless sessions**, each cross-checked the
  S111 way against two Claude-Code-written files agreeing on a random tool-call id. **$4.4482
  metered.** Zero new machinery: only `src/fleet/mod.rs` changed in `src/`, `K of 8` unmoved, no
  8th command. 340 lib tests · verify 17/17 · demo 7/7.

**🔴 THE RESIDUAL, CARRIED NOT ARGUED: the roster is complete and NOTHING DEPENDS ON IT.** No gate
consumes a handoff. Nine roles that nothing depends on is nine decorations. S126 closed the *done*
half of the founder's gate; **the *working* half is S127** — make one gate consume a handoff
(S116's unpicked candidate C + S125's F2). The S125 reboot backlog stays PARKED until it lands.

**Next = S127 — CODE: make a gate CONSUME a handoff.** Full prompt: `prompts/127-task-*.md`.
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
- **New session = new chat** — open a fresh chat for S127.
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a
  separate founder "yes". S126 added none (five roles, zero commands).
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions finish a shippable MVP (S103 pivot). **Current
  direction: FINISH THE SDLC AGENT FLEET (founder, S125 closeout) — the *done* half landed at
  S126; the *working* half (a gate that consumes a handoff) is S127.**
- **A role that PROPOSES never authors the marker its station parses (S126, nine times over).**
- **STATION ≠ ROLE:** the station governs the process (`src/qa/mod.rs`); the role does the work
  (`qa-specialist`). Same pattern for Reviewer/`fidelity-reviewer` and Planner/`plan-advisor` — a
  new role must take a distinct key, never the station's name.
