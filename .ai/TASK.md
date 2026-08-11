# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 117 — CODE: prove the Plan Advisor dispatches by name — COMPLETE

- **Verdict: ACCEPT** (three independent cold reviews, `subagent_type: "fidelity-reviewer"` dispatched
  by name each time — final pass: 7 of 11 SHIPPED, 4 PARTIAL, 0 NOT-BUILT). Resolved by name on the
  first try, no workaround. **All three fleet roles are now proven dispatched by name**: Researcher
  (S111), Fidelity Reviewer (S115), Plan Advisor (S117) — each via the same two-file cross-check
  (parent session tool-call ID matching the subagent's own independently-written meta file).
- **Three cold-review passes, each finding something real:** pass 1 REJECTed a genuine orchestrator
  error (the diff fed to the reviewer was written to `/tmp`, not the path it was told to read); pass 2
  found a `true; score $?` no-op check and an unrun demo script (both fixed in-session); pass 3 found
  the "first try, no workaround" claim was checked only by grepping self-authored prose — fixed with
  an independent count of dispatch attempts in the real parent transcript. A fourth pass re-confirming
  only that last mechanical fix was explicitly skipped and disclosed as a judgment call.
- **A real, out-of-scope bug found live and disclosed, not fixed:** `src/planner/mod.rs::
  is_acceptance_heading` double-counts the `## Plan` heading's own instructional text ("...cite the
  acceptance criteria...") as phantom extra acceptance criteria — live since ≥S112, previously masked
  by coincidence. Flagged as background task `task_2162b487`, slated for S119.
- No `src/` changes this session (`design-significant: no`). Attested
  `a2410535d371860b27761f90f4df713891745efce96a8abda30f27a1755672e7`. Summary:
  `sessions/session-117-summary.md`. Review: `sessions/session-117-review.md`.

**🔀 FOUNDER PIVOT (S103, in force):** sessions now = **finish a shippable MVP**; founder runs the
long unattended test himself. Order **C → B → A**: C team-voice (S104 ✓) → **B installable ✓
COMPLETE** → **A real agent fleet — S109 ✓, S111 ✓, S112 ✓, S113 ✓, S114 ✓, S115 ✓, S116 ✓, S117 ✓
(the fleet build arc is essentially done: all three roles built AND proven dispatched by name).**

Between sessions. **Next = S118 — DOGFOOD (paid): the overdue `vajra claude` run** (founder pick A
at the S117 closeout, over B/C — both now combined into S119, to run right after). Target: chitra.
**WAITING ON THE FOUNDER** — chitra has uncommitted local changes as of this snapshot; the founder
said they will clean it up and then say when to start. **Do not begin S118 until told explicitly.**
Prompt not yet written (write it once given the go-ahead, per `end_of_session.must_write_next_prompt_
before_close` — this is the one legitimate exception, since the target repo's readiness is the
founder's own gate, not a fixed fact yet). **New chat** when it starts.

**Then S119 — CODE (B+C combined):** fix the Planner-gate bug (`task_2162b487`) + wire fleet handoffs
into an opt-in blocking gate (candidate C from the S116 closeout, still unpicked).

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Never work on `main`.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **Commits are ENFORCED (S93):** on a session branch, supply the un-forgeable marker —
  `VAJRA_ALLOW_COMMIT=NN git commit …`.
- **Attest LAST (S69, hit at S114, S116, AND S117):** `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff)
  and the PROMPT IS AN INPUT — recompute strictly after the prompt's Execution shas are committed and
  confirm two consecutive `verify-closeout.sh --inputs-sha NN` runs agree before embedding.
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3)** — a bullet list is BLOCKED.
  **A verdict line wrapped in a `|`-table row also fails the canonical-verdict regex (S115 finding)**
  — only a bare `**Verdict:** ACCEPT`/`REJECT` line passes. Write it as its own line, not a table cell.
- **The fleet has THREE roles built, ALL THREE proven dispatched by name** (Researcher S111, Fidelity
  Reviewer S115, Plan Advisor S117). `reviewer/SKILL.md` is CANONICAL and the Reviewer role brief is
  its summary — bound by a check reading both files (the Plan Advisor has no such counterpart).
- **A "first try, no workaround" dispatch claim needs independent evidence** — count
  `subagent_type:"<role>"` occurrences in the real parent session transcript (exactly 1 = no hidden
  retry), not a magic-phrase grep against a file the same session wrote (S117 finding).
- **`vajra next --role X --from file` hashes the TRIMMED body**, not raw file bytes — strip before
  comparing a `--from` file's sha256 against a handoff's `source-sha`.
- **A new fleet role's regression check should target the most recent COUNT-AGNOSTIC prior verify
  script**, not simply the most recent one — a prior script's hardcoded role count goes stale by
  construction as the fleet grows; that is expected staleness, not a regression, but must be named.
- **crates.io is PUBLISHED (S108): `vajractl 0.1.0` is live — the name is now BURNED (irreversible).**
  Any future crates.io action (a `0.1.1`, a yank) is still founder-gated; never `cargo publish` without
  an explicit in-chat "yes publish". `cargo login` is the founder's own step (a token — never handled by the agent).
- **Fleet dispatch = native Claude Code subagents (DECISION-007), proven end-to-end on ALL THREE
  roles (S111, S115, S117) and CONSUMED (S112):** Vajra scaffolds the role + governs the handoff; a
  fresh session's Task tool resolves `subagent_type` against the scaffolded file by name. It does NOT
  spawn `claude -p`. An unattended `claude -p` mode is deferred (`ANTHROPIC_API_KEY` is the way).
- **Cost-null checks ride `scripts/check-subagent-cost-fields.sh`** — re-runnable, local-machine-only
  (same limitation class as `--dogfood-age`); reuse it, don't re-derive the grep by hand.
- **Write `prompts/NN+1-task-<slug>.md` BEFORE closing** (`end_of_session`) — S118's prompt is the one
  disclosed exception (waiting on the founder's own go-ahead + chitra's readiness), not an oversight.
- **New session = new chat** — open a fresh chat for S118 (only when told) and S119.
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a separate founder "yes".
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions now finish a shippable MVP (S103 pivot).
