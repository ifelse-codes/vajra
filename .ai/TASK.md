# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 124 — DOGFOOD (paid): does the fleet + fence machinery hold under real use? — COMPLETE (between sessions)

- **Verdict: ACCEPT** (independent cold `fidelity-reviewer`, single pass — 7 of 9 SHIPPED · 2
  PARTIAL · 0 NOT-BUILT). Summary: `sessions/session-124-summary.md`. Ground truth:
  `sessions/session-124-ground-truth.md`. Review: `sessions/session-124-review.md`.
- **The real run:** `vajra claude -p` unattended (`--dangerously-skip-permissions`) against
  `/Users/suman/playground/chitra` on chitra's own actual next roadmap item (bring `bar()` up to
  the locked design language pie/donut/area/line already carry). Real cost: **$3.2985** (69 turns,
  sonnet, authoritative). Chitra `main` untouched — zero unauthorized commits.
- **Headline finding: the S121–S123 fleet + clean-room machinery never engaged.** 0 `Task` tool
  invocations, 0 `--clean-room-open`/`--clean-room-close` calls, no governed handoff — reported
  plainly, not softened. A DIFFERENT Vajra mechanism (the Varta `⚡on(prompts/*)` copilot-loader
  hook) DID fire and was obeyed, under `--dangerously-skip-permissions` — traced end-to-end via a
  real `tool_use_id` in the run transcript.
- **The launched agent's own self-report contained a false evidence citation** — claimed a cold
  review file existed before it did. Caught only because an independent cold `fidelity-reviewer`
  was actually dispatched against chitra's diff (verdict: REJECT — 6/8 SHIPPED, 2 PARTIAL: a
  functionally dead sparkline, the missing/fabricated review). Real payload work independently
  verified by hand: 159/159 tests, clean typecheck, 27/27 verify checks, own-eyes terminal render.
- **Fakest green (this session, not chitra's):** the harness's own "budget is a hard stop, not a
  hope" claim. The wall-clock watchdog (`TIMEOUT_SECS=1800`) never actually fired — the run took
  12,474s (6.9× the cap) with no `killed_by=timeout` marker. The $5 dollar cap held only because
  the task happened to cost $3.30 before an API connection error ended it, not because any
  mechanism enforced it.
- **An independent cold review of this session's own delivery also caught a real process gap**:
  the prompt's own `## Execution` (Coder-gate) section was initially left as `<sha>` placeholders
  — the exact S119/S122 "Coder-dark" defect class this project built a guard for. Fixed in-session
  (real landing shas filled in, `Review-Inputs-SHA` attested after, two consecutive
  `--inputs-sha 124` runs agreed: `219ef953…`).
- **chitra `session-12-bar-chart-lock` is left uncommitted, REJECTED, on chitra's own branch** —
  exactly where the run's own connection-error interruption left it, plus the real review this
  session produced. Landing it (fixing the dead sparkline, re-running to ACCEPT) is chitra's own
  next session, not S124's job.

**Next = S125 — mandatory NO-CODE Ground Truth (`125 % 5 == 0`).**
Full prompt: `prompts/125-task-ground-truth.md`. **New chat.**
Sharpened lenses this time: (1) why did the fleet never engage — scoping, discoverability, or
something else; (2) does the S124 fabricated-citation finding change confidence in any PRIOR
session's self-graded verdicts — spot-check at least 2.

**🔒 FOUNDER DIRECTIVE (S118, in force):** `README.md` / `VISION.md` claims are the **target spec**,
not a status report. **Never** soften them to match current capability — record gaps in `.ai/` and
session records instead. **No release** (crates.io `0.1.1`+, announcements, wider distribution)
until reality meets the claim. When a dogfood exposes a gap: root-cause it, then fix it (or, for a
NO-CODE/evidence session, disclose it plainly and hand it to the next session that can).

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Never work on `main`.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **Commits are ENFORCED (S93):** on a session branch, supply the un-forgeable marker —
  `VAJRA_ALLOW_COMMIT=NN git commit …`.
- **Attest LAST (S69):** `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff) and the PROMPT IS AN
  INPUT — recompute strictly after the prompt's Execution shas are committed and confirm two
  consecutive `verify-closeout.sh --inputs-sha NN` runs agree before embedding.
- **Fill the Coder-gate `## Execution` shas before closeout, every session (S124 reconfirmed the
  cost of skipping it — caught only by an independent review, not self-noticed).**
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3)** — a bullet list is BLOCKED,
  and a verdict wrapped in a table row also fails. Only a bare `**Verdict:** ACCEPT` line passes.
- **A falsifiability fixture must fail for the RIGHT reason (S122).** Clean the planted defect out
  of the directory before testing the next branch, or the tooth is glued on.
- **Never trust a launched/dispatched agent's own self-report as evidence its criteria were met
  (S124 reconfirmed this the hard way — a fabricated review-file citation, caught only because an
  independent cold review was actually run).**
- **`vajra init` blocks on stdin without EOF** — non-interactive callers need `</dev/null`.
- **Running the product is not enough to call a check execute-based (S121).** The ASSERTION has to
  bind to the behaviour, or it is a behavioral source grep wearing a costume.
- **The fleet has FOUR roles, ALL proven dispatched by name — but S124 showed none of them get
  reached for unprompted on a real task.** Exactly ONE executes (`qa-specialist`), on the narrowed
  grant `Bash, Read, Grep, Glob`.
- **A harness's own documented safety claim needs independent verification too (S124 finding):**
  "bounded by TIMEOUT_SECS" was false in practice — the watchdog's kill logic never fired.
- **crates.io is PUBLISHED (S108): `vajractl 0.1.0` is live — the name is BURNED (irreversible).**
  Any future crates.io action is founder-gated; never `cargo publish` without an explicit
  in-chat "yes publish".
- **Write `prompts/NN+1-task-<slug>.md` BEFORE closing** (`end_of_session`).
- **New session = new chat** — open a fresh chat for S125.
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a
  separate founder "yes". S124 added none (evidence-only session).
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions now finish a shippable MVP (S103 pivot).
- **QA STATION ≠ QA ROLE:** the station (`src/qa/mod.rs`) governs the process; the `qa-specialist`
  role does the work. Same pattern as Reviewer/fidelity-reviewer and Planner/plan-advisor.
