# Session Boot

## Current Session
- **Number:** 120 — COMPLETE
- **Type:** NO-CODE MANDATORY GT. Audited S116–S119.
- **Goal:** All 10 required GT audits; special lenses: grep-only verify sweep across all historical
  scripts; pipeline-advance counter for S119 (clean-room runner).
- **Verdict:** **PARTIAL PASS.** No code changes (GT rule); no `verify-session-120.sh` (exempt
  per CONSTRAINTS.yaml `ground_truth_commit_exempt_branch_suffixes`).
- **Report:** `sessions/session-120-ground-truth.md`. Prompt: `prompts/120-task-ground-truth.md`.
  **Date last updated:** 2026-08-18.

## Repo State Snapshot
- `.ai/SESSION` = 120. Work on `session-120-ground-truth`.
- **S119 PR (#129) MERGED 2026-08-17.** (STATE was stale on this at S120 open — corrected now.)
- **Key S120 findings (all NO-CODE — filed, not fixed):**
  - **Coder-dark for S119:** `## Execution` step 7 records prose ("cold fidelity-reviewer pass
    ACCEPT") not a commit sha — `git cat-file -e <sha>^{commit}` fails on it. Steps 1-6 have
    real shas; step 7 is legitimate non-commit evidence but breaks the Coder gate.
  - **3 behavioral source greps in verify-session-119.sh:** `init_scaffold_has_clean_room` (greps
    source template text), `skip_env_var_referenced` (greps for env var name in source),
    `run_location_printed` (the S119 disclosed fakest green — greps for message string in source).
    Widespread pattern found across older scripts (S19, S21) and fleet sessions (S114, S116).
  - **VISION.md stale items:** (1) clean-room runner (S119) not mentioned in body; (2) Rules
    section still says "Under the machinery-freeze rule (S98)..." — freeze was RETIRED at S103;
    VISION.md preamble correctly says SUPERSEDED but body Rules does not.
  - **KNOWLEDGE §6:** 642 lines (up from 475 at S105). Chronic, 10 GTs flagged, unfixed.
  - **Ledger:** not a directory — derived from `sessions/session-NN-review.md` via git show in
    `_ledger_read()`. By design; no fix needed.
- 334 lib tests, 7 commands, CI green on main.

## Next Session
- **Number:** 121 — **CODE.** QA specialist agent (fleet role 4).
- **Goal:** Add `qa-specialist` as the fleet's fourth role — the FIRST with full execution
  capability (Bash, Read, Write, Edit, Grep, Glob). It runs the session's verify script,
  classifies each check (behavioral source grep vs execute-based), and reports what actually
  exercised the product. Same zero-new-machinery shape as S114 and S116.
- **Full prompt:** `prompts/121-task-qa-specialist-agent.md`.
- **Why this is the founder's pick (S120 GT):** building a real executor agent treats the root
  cause of hollow verify suites, not the symptom. An agent that actually runs code cannot fake a
  pass via source grep.
- **🔒 Founder directive (S118):** README/VISION claims are the target spec — never soften them;
  no release until reality meets them.

## Carry-Forwards (NEW from S120 GT)
- **Two classes of source greps:** STRUCTURAL (one-source-of-truth architecture checks — acceptable;
  no better alternative) vs BEHAVIORAL (checks a feature works by finding its message string in
  source — the hollow class; the hollow class is widespread). Name the class explicitly in future
  fakest-green disclosures.
- **QA STATION ≠ QA ROLE:** `src/qa/mod.rs` = the pipeline's QA STATION (governs the process).
  `qa-specialist` = the fleet's QA ROLE (does the work). Same pattern as Reviewer/fidelity-reviewer
  and Planner/plan-advisor. They stay completely separate.
- **First full-execution fleet agent (S121):** Bash grant is load-bearing — document in DECISION-007
  addendum with rejected alternatives.
- **Dispatch proof is S122's job** — mid-session dispatch is invisible (S111 finding); same pattern
  as S114→S115 (fidelity-reviewer) and S116→S117 (plan-advisor).
- **S119 Coder-dark root cause:** prose in an `## Execution` step breaks `git cat-file`. Legitimate
  non-commit evidence (fidelity-reviewer ACCEPT) is not a sha; needs a different gate path or a
  documentation exception. Filed, not fixed.

## Standing Carry-Forwards (from S119 + prior)
- **New session = new chat** (AGENTS.md step 10) — open a fresh chat for S121.
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
- **Known weak check, house-wide, unfixed:** `no-eighth-command` greps a hardcoded usage banner.
- **Untracked stragglers** (standing founder call): `sessions/session-9*-artifacts/*`,
  `sessions/session-10{2,3,7,8,9}-artifacts/*`; `vajra-cto-audit-*.html` + `first-mate.html`.
- **crates.io is PUBLISHED — `vajractl` name BURNED**; any crates.io action stays founder-gated.
- **v0.1 installs FOUR ways, all measured, CONFIRMED stranger-shippable at S110 GT.**
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a
  separate founder "yes".
