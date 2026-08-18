# Session Boot

## Current Session
- **Number:** 121 — COMPLETE
- **Type:** CODE. The fleet's FOURTH role, the QA Specialist — the first that can execute.
- **Goal:** Register `qa-specialist` in `src/fleet/mod.rs` with `Bash, Read, Write, Edit, Grep,
  Glob`; scaffold it via `vajra init`; govern its handoff through the unchanged `--role --from`
  path; record the grant in `DECISION-007`.
- **Verdict:** **ACCEPT** — cold `fidelity-reviewer`, 5 of 6 SHIPPED, 1 PARTIAL, 0 NOT-BUILT.
  Attested `c92a2dad3377f48980458e8a71252b8267948e54badf3b3c6e32683ece48e7a9`.
- **Report:** `sessions/session-121-summary.md` · `sessions/session-121-review.md`.
  Prompt: `prompts/121-task-qa-specialist-agent.md`. **Date last updated:** 2026-08-18.

## Repo State Snapshot
- `.ai/SESSION` = 121. Work on `session-121-qa-specialist`. **PR [#131](https://github.com/ifelse-codes/vajra/pull/131) open to `main`.**
- **335 lib tests** (was 334); `verify-session-121.sh` **17/17 green**; 7 commands, no 8th.
- **The fleet is FOUR roles:** researcher · fidelity-reviewer · plan-advisor · **qa-specialist**.
  Three proven dispatched by name (S111/S115/S117); **the fourth has NEVER been dispatched** —
  that is S122's whole job.
- **Exactly one role executes.** `qa-specialist` = `Bash, Read, Write, Edit, Grep, Glob`; the other
  three stay read-only, enforced as a named allowlist of one so a fifth role cannot inherit Bash.
- **Key S121 findings:**
  - **🔴 The check-class tally is a SELF-ASSIGNED LABEL.** `verify-session-121.sh` prints
    `13 execute-based · 3 structural · 1 behavioral`, but nothing verifies a check marked `exec`
    executes anything. Never quote it as a measurement. (Cold-review fakest green.)
  - The cold pass caught `no-eighth-command` labelled `exec` while asserting on a hardcoded help
    banner → reclassified BEHAVIORAL, so the `NOTE:` disclosure branch now fires on every run.
  - **`vajra init` blocks forever on stdin without EOF** — cost 10 minutes live, inside
    `verify-session-113.sh`. Any non-interactive caller must redirect `</dev/null`.
  - `verify-session-116.sh` is red by construction against this branch (fleet grew to four; the
    read-only invariant was deliberately changed, hence the test was RENAMED not loosened).

## Next Session
- **Number:** 122 — **CODE.** Prove the QA Specialist dispatches by name + the FIRST LIVE QA run.
- **Goal:** Dispatch `subagent_type: "qa-specialist"` by name in a fresh session, hand it a REAL
  verify script, capture non-copyable dispatch evidence, and record honestly what the executing
  agent produced that a read-only agent could not.
- **Full prompt:** `prompts/122-task-qa-specialist-dispatch.md`.
- **Why this is the founder's pick (S121 close, option A):** S121's central claim — *an executor
  cannot fake a pass* — is untested. This is the only session that can test it. Same S114→S115 and
  S116→S117 pattern, plus the live-run half those had no analogue for.
- **The trap to avoid:** a flat, agreeable report from the agent is a **REAL FINDING** to record,
  never softened into a success.
- **🔒 Founder directive (S118):** README/VISION claims are the target spec — never soften them;
  no release until reality meets them.

## Carry-Forwards (NEW from S121)
- **The self-asserted-label class has now been disclosed THREE times:** S64 (`covers:` digit-tag),
  S67 (`design-significant:` marker), S121 (the check-class tally). Option B at the S121 close
  (make the tally machine-derived) is the named, unpicked fix.
- **Running the product is not enough to earn the `exec` label** — the ASSERTION has to bind to the
  behaviour. `no-eighth-command` runs the binary and still greps a banner string.
- **`vajra init` needs `</dev/null`** from any non-interactive caller.
- **Per-session verify snapshots decay** — S114's, S116's now red by construction. They are
  historical snapshots, not living suites; the count-agnostic ones (S113, `fleet-smoke.sh`) are the
  real regressions.
- **The QA STATION (`src/qa/mod.rs`) and the QA ROLE (`qa-specialist`) stay separate** — the station
  governs the process, the role does the work. Third instance of that collision, same resolution.

## Carry-Forwards (from S120 GT)
- **Two classes of source greps:** STRUCTURAL (one-source-of-truth architecture checks — acceptable;
  no better alternative) vs BEHAVIORAL (checks a feature works by finding its message string in
  source — the hollow class; the hollow class is widespread). Name the class explicitly in future
  fakest-green disclosures.
- **QA STATION ≠ QA ROLE:** `src/qa/mod.rs` = the pipeline's QA STATION (governs the process).
  `qa-specialist` = the fleet's QA ROLE (does the work). Same pattern as Reviewer/fidelity-reviewer
  and Planner/plan-advisor. They stay completely separate.
- **First full-execution fleet agent (S121): DONE.** Bash grant recorded in the `DECISION-007` S121
  addendum with three rejected alternatives + the residual risk.
- **Dispatch proof is S122's job** — mid-session dispatch is invisible (S111 finding); same pattern
  as S114→S115 (fidelity-reviewer) and S116→S117 (plan-advisor). **S121 honoured this: the role was
  built and never dispatched.**
- **S119 Coder-dark root cause:** prose in an `## Execution` step breaks `git cat-file`. Legitimate
  non-commit evidence (fidelity-reviewer ACCEPT) is not a sha; needs a different gate path or a
  documentation exception. Filed, not fixed.

## Standing Carry-Forwards (from S119 + prior)
- **New session = new chat** (AGENTS.md step 10) — open a fresh chat for S122.
- **Communicate in the plainest English** (founder request S103) — translate all jargon.
- **Dispatch-by-name proven for ALL THREE roles** (Researcher S111, Fidelity Reviewer S115, Plan
  Advisor S117). Mid-creating-session dispatch still fails per S111 — do not conflate.
- **Attest LAST:** `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff), the PROMPT IS AN INPUT.
  Compute strictly after every edit to the prompt file itself and confirm two consecutive
  `verify-closeout.sh --inputs-sha NN` runs agree before embedding.
- **`vajra next --role X --from file` hashes the TRIMMED body** — strip before sha256 comparison.
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3).** A bullet list is BLOCKED.
  A verdict wrapped in a `|`-table row also fails — only a bare `**Verdict:** ACCEPT` line passes.
- **Still reuse `named_test_passed()`** — a bare `cargo test --lib <filter>` exits 0 on a filter
  matching zero tests. And **`[[:space:]]`, never `\s`**, in any script check (BSD/macOS grep).
- **Background task flagged, not yet acted on:** `task_2162b487` — the Planner-gate
  `is_acceptance_heading` double-counting bug (S117 finding).
- **KNOWLEDGE §6 is at 642 lines, growing** — chronic since S60, still unpruned.
- **Known weak check, house-wide, unfixed:** `no-eighth-command` greps a hardcoded usage banner —
  now formally classified BEHAVIORAL (hollow) at S121. Option C at the S121 close is the fix.
- **Untracked stragglers** (standing founder call): `sessions/session-9*-artifacts/*`,
  `sessions/session-10{2,3,7,8,9}-artifacts/*`; `vajra-cto-audit-*.html` + `first-mate.html`.
- **crates.io is PUBLISHED — `vajractl` name BURNED**; any crates.io action stays founder-gated.
- **v0.1 installs FOUR ways, all measured, CONFIRMED stranger-shippable at S110 GT.**
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a
  separate founder "yes".
