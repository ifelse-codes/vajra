# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 121 — CODE: the QA Specialist, the fleet's 4th role — COMPLETE

- **Verdict: ACCEPT** (cold `fidelity-reviewer`, 5 of 6 SHIPPED · 1 PARTIAL · 0 NOT-BUILT).
  Attested `c92a2dad3377f48980458e8a71252b8267948e54badf3b3c6e32683ece48e7a9`.
  Summary: `sessions/session-121-summary.md`. Review: `sessions/session-121-review.md`.
- **What shipped:** `qa-specialist` registered in `src/fleet/mod.rs` — **the fleet's first EXECUTING
  role** (`Bash, Read, Write, Edit, Grep, Glob`), keyed to avoid the QA-STATION collision (third
  instance). `vajra init` scaffolds a 4th agent file, byte-identical to the render, with zero
  `src/cli/init.rs` changes. `vajra next --role qa-specialist --from` governs its handoff,
  fail-closed. `DECISION-007` S121 addendum: the key, the Bash rationale, **three** rejected
  alternatives, and the residual risk stated plainly. 335 lib tests; `verify-session-121.sh` 17/17.
- **Fakest green (never soften this):** the check-class tally
  (`13 execute-based · 3 structural · 1 behavioral`) is **a label the author typed**. Nothing checks
  that a check marked `exec` executes anything. Do NOT cite it as a measurement anywhere.
- **POST-CLOSE (founder-directed):** the agent WAS dispatched after all — the harness registered it
  inside its own creating session, contradicting S111 (second observation). It resolved by name,
  first try; ran the suite (exit 0, 17/17); agreed with all 17 self-assigned labels; **and found
  four defects this session missed.** It changed nothing (HEAD sha, index hash and porcelain
  byte-identical, checked not trusted). Brief:
  `sessions/session-121-artifacts/qa-specialist-live-run.md`.
- **🔴 The executor thesis is UNPROVEN.** All four findings came from careful independent READING,
  not from Bash. Evidenced: an INDEPENDENT agent finds real defects. Not evidenced: that an executor
  cannot fake a pass. Never pitch the executor claim as measured.
- **Found live:** `vajra init` blocks forever on stdin when its runner sends no EOF (10 minutes lost
  inside `verify-session-113.sh`). Non-interactive callers must redirect `</dev/null`.

**Next = S122 — CODE: close the four real holes the live QA run found.**
Full prompt: `prompts/122-task-qa-suite-real-holes.md`. **New chat.** The original S122 brief
(dispatch proof) is SUPERSEDED and deleted — its goal was achieved at the S121 close.
**Every fix needs a falsifiability fixture: a check never seen RED is not evidence.**
Leading candidate after S122: **fence the `Write`/`Edit` grant** — the QA role can still edit the
code it tests, and on the live run that held only because the agent chose to hold it.

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
- **Attest LAST (S69, hit at S114–S119):** `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff) and the
  PROMPT IS AN INPUT — recompute strictly after the prompt's Execution shas are committed and
  confirm two consecutive `verify-closeout.sh --inputs-sha NN` runs agree before embedding.
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3)** — a bullet list is BLOCKED,
  and a verdict wrapped in a table row also fails. Only a bare `**Verdict:** ACCEPT` line passes.
- **The fleet has FOUR roles, ALL proven dispatched by name** (Researcher S111, Fidelity Reviewer
  S115, Plan Advisor S117, QA Specialist S121-post-close). **The S111 "invisible in its own creating
  session" rule did NOT hold** — re-test it before planning around it again.
- **Exactly ONE role may execute** — `qa-specialist`. Enforced as a named allowlist so a fifth role
  cannot inherit Bash by being added to the table.
- **A "first try, no workaround" dispatch claim needs independent evidence** — count
  `subagent_type:"<role>"` occurrences in the real parent session transcript (exactly 1 = no hidden
  retry), not a magic-phrase grep against a file the same session wrote (S117 finding).
- **`vajra next --role X --from file` hashes the TRIMMED body** — strip before comparing.
- **`vajra init` blocks on stdin without EOF (S121)** — non-interactive callers need `</dev/null`.
- **Running the product is not enough to call a check execute-based (S121)** — the ASSERTION has to
  bind to the behaviour, or it is a behavioral source grep wearing a costume.
- **crates.io is PUBLISHED (S108): `vajractl 0.1.0` is live — the name is BURNED (irreversible).**
  Any future crates.io action is founder-gated; never `cargo publish` without an explicit
  in-chat "yes publish".
- **Write `prompts/NN+1-task-<slug>.md` BEFORE closing** (`end_of_session`).
- **New session = new chat** — open a fresh chat for S122.
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a separate
  founder "yes".
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions now finish a shippable MVP (S103 pivot).
- **QA STATION ≠ QA ROLE:** the station (`src/qa/mod.rs`) governs the process; the `qa-specialist`
  role does the work. Same pattern as Reviewer/fidelity-reviewer and Planner/plan-advisor.
