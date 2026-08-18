# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 120 — NO-CODE MANDATORY GT (audits S116–S119) — COMPLETE

- **Verdict: PARTIAL PASS.** Full report: `sessions/session-120-ground-truth.md`.
- **What was audited:** S116 (Plan Advisor built) · S117 (Plan Advisor dispatch proven) · S118
  (paid dogfood — grep-only verify root cause) · S119 (clean-room runner). Special lens: grep-only
  verify sweep across ALL historical scripts; pipeline-advance counter.
- **Key findings:**
  - S119 PR (#129) merged 2026-08-17 (STATE was stale on this — now corrected).
  - **Coder-dark for S119:** `## Execution` step 7 uses prose ("cold fidelity-reviewer pass
    ACCEPT") not a commit sha → `git cat-file` fails; steps 1-6 have real shas.
  - **3 behavioral source greps in verify-session-119.sh:** `init_scaffold_has_clean_room`
    (greps source template), `skip_env_var_referenced` (greps for env var name), and
    `run_location_printed` (the S119 disclosed fakest green — greps for the message string).
  - **VISION.md stale items:** (1) clean-room runner not mentioned in body; (2) "Under the
    machinery-freeze rule (S98)..." in Rules section — freeze was RETIRED at S103; body not updated.
  - **KNOWLEDGE §6 bloat:** 642 lines (up from 475 at S105), 10 GTs flagged, still unfixed.
  - **No `.ai/ledger/` directory** — ledger is DERIVED (via `_ledger_read()` in
    verify-closeout.sh from `sessions/session-NN-review.md` files via git show). By design.
  - Three STATE/KNOWLEDGE spot-checks all CORRECT. Constitution: no stale rules found (aside
    from VISION body's retired freeze reference).
- **Grep-only verify sweep finding:** behavioral source greps are widespread in older scripts
  (S19, S21) and fleet-role sessions (S114, S116). Two classes distinguished: STRUCTURAL (checks
  code architecture — acceptable) vs BEHAVIORAL (checks feature behavior by finding a message
  string in source — the hollow class). S119's verify has 3 behavioral; S118's had 11.
- **Founder pick:** build the QA specialist agent (fleet role 4) — the first fleet agent with
  full execution capability (Bash, Read, Write, Edit, Grep, Glob). Treats the root cause
  directly: an executor agent cannot fake a pass by grepping source.

**Next = S121 — CODE: QA specialist agent (fleet role 4).** Full prompt:
`prompts/121-task-qa-specialist-agent.md`. **New chat.**

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
- **Attest LAST (S69, hit at S114, S116, S117, S118):** `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff)
  and the PROMPT IS AN INPUT — recompute strictly after the prompt's Execution shas are committed and
  confirm two consecutive `verify-closeout.sh --inputs-sha NN` runs agree before embedding.
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3)** — a bullet list is BLOCKED.
  **A verdict line wrapped in a `|`-table row also fails the canonical-verdict regex (S115 finding)**
  — only a bare `**Verdict:** ACCEPT`/`REJECT` line passes. Write it as its own line, not a table cell.
- **The fleet has THREE roles built, ALL THREE proven dispatched by name** (Researcher S111, Fidelity
  Reviewer S115, Plan Advisor S117). `reviewer/SKILL.md` is CANONICAL and the Reviewer role brief is
  its summary — bound by a check reading both files.
- **A "first try, no workaround" dispatch claim needs independent evidence** — count
  `subagent_type:"<role>"` occurrences in the real parent session transcript (exactly 1 = no hidden
  retry), not a magic-phrase grep against a file the same session wrote (S117 finding).
- **`vajra next --role X --from file` hashes the TRIMMED body**, not raw file bytes — strip before
  comparing a `--from` file's sha256 against a handoff's `source-sha`.
- **crates.io is PUBLISHED (S108): `vajractl 0.1.0` is live — the name is now BURNED (irreversible).**
  Any future crates.io action (a `0.1.1`, a yank) is still founder-gated; never `cargo publish` without
  an explicit in-chat "yes publish". `cargo login` is the founder's own step (a token — never handled by the agent).
- **Fleet dispatch = native Claude Code subagents (DECISION-007), proven end-to-end on ALL THREE
  roles (S111, S115, S117).** Vajra scaffolds the role + governs the handoff.
- **Write `prompts/NN+1-task-<slug>.md` BEFORE closing** (`end_of_session`).
- **New session = new chat** — open a fresh chat for S121.
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a separate founder "yes".
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions now finish a shippable MVP (S103 pivot).
- **QA STATION ≠ QA ROLE** (S120 finding): the QA station (`src/qa/mod.rs`) governs the process;
  the `qa-specialist` fleet role DOES the work. Same pattern as Reviewer/fidelity-reviewer and
  Planner/plan-advisor. They stay separate.
- **First full-execution fleet agent (S121):** `qa-specialist` gets Bash, Read, Write, Edit, Grep,
  Glob. This is the first role that can run code, not just read it. Document in DECISION-007 addendum.
