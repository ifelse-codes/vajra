# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 122 — CODE: close the four real holes the live QA run found — COMPLETE

- **Verdict: ACCEPT** (cold `fidelity-reviewer`, **pass 4** — 5 of 6 SHIPPED · 1 PARTIAL · 0
  NOT-BUILT). Summary: `sessions/session-122-summary.md`. Review: `sessions/session-122-review.md`.
- **What shipped:** the read-only guard is token-exact (the prefix grep passed a `Write` leak) ·
  the `.ai/handoffs/` booby-trap is defused and the failure message names its carriers · three
  render-against-its-own-field tautologies removed, substance asserted through ONE shared rule ·
  the tally has a fourth class `nested`, names what it hides, and calls its behavioral count a
  FLOOR · plus an uncontracted fifth fix: the forbidden-tool policy had already drifted (`Task`
  missing from the Rust list) and both halves are now bound across all three copies.
  `verify-session-122.sh` **22 checks exit 0**; demo **9 of 9**; **337 lib tests**.
- **The booby-trap is ARMED in this repo** — a real governed `qa-specialist` handoff quoting the
  probe sentence sits in `.ai/handoffs/`, and the S121 suite runs green with it there.
- **Fakest green (never soften this):** **two of the five fixtures end on a "fail-closed" tooth that
  cannot fail** — the planted defect from an earlier assertion was never cleaned out of the
  directory under test, so the guard rejects for the wrong reason. Delete the fail-closed branch and
  the assertion still prints OK. Deliberately UNFIXED: repairing after the ACCEPT would attest a
  diff no reviewer saw. **S123's first payload item.**
- **FOUR cold passes were needed:** REJECT → ACCEPT-with-findings → REJECT → ACCEPT. Every rejection
  was correct. The same tautology was found on a THIRD field after two "fixes"; the booby-trap was
  re-armed TWICE inside the session closing it; the anti-hollowness demo was itself hollow.
- **🔴 The executor thesis is UNPROVEN and `DECISION-007` now says so** (S122 addendum retracting the
  S121 claim). Two live QA runs, seven real defects, every one from independent READING. What is
  evidenced is INDEPENDENCE, not execution. **Nothing CHECKS that correction** — it is typed prose.

**Next = S123 — CODE: fence the `Write`/`Edit` grant** (founder option A of three).
Full prompt: `prompts/123-task-fence-the-write-grant.md`. **New chat.**
Steps 1–2 clear S122's own debt (the glued-on teeth, the duplicated tally) before the payload.

**🔒 FOUNDER DIRECTIVE (S118, in force):** `README.md` / `VISION.md` claims are the **target spec**,
not a status report. **Never** soften them to match current capability — record gaps in `.ai/` and
session records instead. **No release** (crates.io `0.1.1`+, announcements, wider distribution)
until reality meets the claim. When a dogfood exposes a gap: root-cause it, then fix it.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Never work on `main`.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **Commits are ENFORCED (S93):** on a session branch, supply the un-forgeable marker —
  `VAJRA_ALLOW_COMMIT=NN git commit …`.
- **Attest LAST (S69):** `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff) and the PROMPT IS AN
  INPUT — recompute strictly after the prompt's Execution shas are committed and confirm two
  consecutive `verify-closeout.sh --inputs-sha NN` runs agree before embedding.
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3)** — a bullet list is BLOCKED,
  and a verdict wrapped in a table row also fails. Only a bare `**Verdict:** ACCEPT` line passes.
- **A falsifiability fixture must fail for the RIGHT reason (S122).** Clean the planted defect out
  of the directory before testing the next branch, or the tooth is glued on.
- **Expect more than one cold pass (S122).** Four were needed; every rejection was correct.
- **`vajra init` blocks on stdin without EOF** — non-interactive callers need `</dev/null`. Cost 10
  minutes at S121 and 20 at S122. `verify-session-113.sh` is fixed; older scripts are not.
- **Running the product is not enough to call a check execute-based (S121)** — the ASSERTION has to
  bind to the behaviour, or it is a behavioral source grep wearing a costume.
- **The fleet has FOUR roles, ALL proven dispatched by name.** Exactly ONE executes
  (`qa-specialist`), enforced as a named allowlist whose forbidden-tool list AND allowlist are now
  bound across all three copies (`verify-session-122.sh#execution-policy-one-source`).
- **crates.io is PUBLISHED (S108): `vajractl 0.1.0` is live — the name is BURNED (irreversible).**
  Any future crates.io action is founder-gated; never `cargo publish` without an explicit
  in-chat "yes publish".
- **Write `prompts/NN+1-task-<slug>.md` BEFORE closing** (`end_of_session`).
- **New session = new chat** — open a fresh chat for S123.
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a separate
  founder "yes".
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions now finish a shippable MVP (S103 pivot).
- **QA STATION ≠ QA ROLE:** the station (`src/qa/mod.rs`) governs the process; the `qa-specialist`
  role does the work. Same pattern as Reviewer/fidelity-reviewer and Planner/plan-advisor.
