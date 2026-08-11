# Session Boot

## Current Session
- **Number:** 117 — COMPLETE
- **Type:** CODE. Prove the fleet's THIRD named role, the Plan Advisor, dispatches by name.
- **Goal:** dispatch `subagent_type: "plan-advisor"` inside a fresh session (the first one after the
  S116 commit that scaffolded it landed on `main`), capture independent non-copyable cross-file
  evidence of the real dispatch, govern the result into `.ai/handoffs/session-117-plan-advisor.md`,
  and confirm `vajra next --stations 117` reports it beside `K of 8` with `K` unchanged.
- **Verdict:** **ACCEPT** (three independent cold reviews, each `subagent_type: "fidelity-reviewer"`
  dispatched by name — final pass: 7 of 11 SHIPPED, 4 PARTIAL, 0 NOT-BUILT). Resolved by name on the
  first try, no workaround. All three fleet roles now proven dispatched by name in three separate
  fresh sessions: Researcher (S111), Fidelity Reviewer (S115), Plan Advisor (S117). Pass 1 REJECTed
  a real orchestrator error (diff written to `/tmp`, not the path the reviewer was told to read);
  pass 2 found a `true; score $?` no-op check + an unrun demo script (both fixed); pass 3 found the
  "first try" claim was checked only by grepping self-authored prose (fixed with an independent
  transcript-count check) — a fourth pass re-confirming only that last small fix was explicitly
  skipped and disclosed, not silently omitted. No `src/` changes (`design-significant: no`). 323 lib
  tests (unchanged); verify **12/12**; demo **7/7**; attested
  `a2410535d371860b27761f90f4df713891745efce96a8abda30f27a1755672e7`.
- **Report:** `sessions/session-117-summary.md` · `sessions/session-117-review.md` · next prompt:
  `prompts/118-task-dogfood-paid-run.md` (once written). **Date last updated:** 2026-08-11.

## Repo State Snapshot
- `.ai/SESSION` = 117. 15 atomic commits on `session-117-plan-advisor-dispatch`. Closeout bundle (this
  sync + summary/review) lands on the same session branch.
- Ledger: not re-verified this session (no `--ledger-verify` run; nothing indicates drift).
- Fleet still has THREE registered roles, unchanged — this session added evidence, not machinery.
  **All three are now proven dispatched by name**, closing the last open "is it real?" question for
  the fleet build arc.
- A real, out-of-scope bug was found live and disclosed, not fixed: `src/planner/mod.rs::
  is_acceptance_heading` matches any heading whose text merely contains the word "acceptance" — this
  repo's own `## Plan (... cite the acceptance criteria ...)` heading text trips it, double-counting
  the Plan section's own numbered steps as phantom extra criteria. Live since ≥S112. Flagged as
  background task `task_2162b487`, slated for S119.

## Next Session
- **Number:** 118 — **DOGFOOD (paid): the overdue `vajra claude` run.** Founder pick A at the S117
  closeout (over B: fix the Planner-gate bug, and C: wire fleet handoffs into a blocking gate — both
  now combined into S119, to run right after S118).
- **WAITING ON THE FOUNDER — do not start until explicitly told.** Target repo: chitra. As of this
  snapshot chitra has 7 uncommitted files on branch `session-10-line-locked`; the founder said they
  will clean it up themselves and then say when to start S118. Do not touch chitra's working tree
  before that go-ahead.
- **The overdue metric:** `vajra claude` has not run a real governed session since S103 — now 14
  sessions / ~14+ calendar days. This is the single highest-leverage undone item; it has been
  deferred by explicit founder choice at S115, S116, AND S117 (each time in favor of fleet-role work)
  — S118 finally closes it.
- **Prompt not yet written** (`prompts/118-task-dogfood-paid-run.md`) — write it once the founder
  confirms chitra is clean and gives the go-ahead, mirroring the S92 ride-along shape (one real
  bounded task, authoritative receipt, `--stations`/`--dogfood-age` recorded, governance-obedience
  documented) but reading chitra's OWN `.ai/TASK.md` at write-time for its actual next-session
  candidate (as of this snapshot: continue the reference-locked line language into bar/sparkline/
  histogram, bring `lineModelToSvg` in line with the terminal renderer, or a real v0.1.0 release —
  chitra's own next-session note names all three, undecided).
- **Then S119 — CODE (B+C combined):** fix the Planner-gate double-counting bug (`task_2162b487`,
  small + contained, `src/planner/mod.rs` + a regression test) AND wire fleet handoffs into an opt-in
  blocking gate (candidate C from the S116 closeout, still unpicked).

## Carry-Forwards
- **New session = new chat** (AGENTS.md step 10) — open a fresh chat for S118 (when the founder says
  go) and again for S119.
- **Communicate in the plainest English** (founder request S103) — translate all jargon.
- **Dispatch-by-name is now proven for the next-session case on ALL THREE roles** (S111 Researcher,
  S115 Fidelity Reviewer, S117 Plan Advisor). The mid-creating-session case (a role dispatching itself
  in the same session that wrote its `.claude/agents/*.md`) remains untested for every role and is
  presumed still to fail per S111 — do not conflate the two.
- **A "first try, no workaround" claim needs independent evidence, not self-authored prose.** Count
  `subagent_type:"<role>"` occurrences in the REAL parent session transcript — exactly 1 means no
  hidden retry. Reuse this pattern (`scripts/verify-session-117.sh::first_try_independently_confirmed`)
  for any future by-name-dispatch proof.
- **`vajra next --role X --from file` hashes the TRIMMED body** (`findings.trim()` in
  `src/cli/next.rs`), not raw file bytes — a verify check comparing a `--from` file's raw sha256
  against a handoff's `source-sha` will always mismatch; strip first.
- **Three independent cold-review passes is not automatically gate-stacking** — each of S117's three
  passes found something real and different. But a fourth pass re-confirming only a small, already-
  disclosed mechanical fix is diminishing returns (S60) — stop when a pass would only re-verify
  something already independently verified twice.
- **The station/role name-collision pattern has TWO confirmed instances** (Reviewer vs
  `fidelity-reviewer` at S114; Planner vs `plan-advisor` at S116) — expect a third whenever a future
  role's natural name matches an existing station name.
- **The closeout gate counts verdict words ONLY on `|` table rows, and needs ≥3.** A verdict line
  wrapped in a `|`-table row also fails the canonical-verdict regex (S115 finding) — only a bare
  `**Verdict:** ACCEPT`/`REJECT` line passes. Held correctly across all three S117 review passes.
- **Attest LAST: `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff), and the PROMPT IS AN INPUT.**
  Compute `--inputs-sha` as the LAST step, strictly after every edit to the prompt file itself
  (Execution shas included), and confirm two consecutive runs agree before embedding.
- **Known weak check, house-wide, unfixed 6 sessions running (S111–S117, except S115 which built no
  code):** `no-eighth-command` greps a hardcoded usage banner. Not urgent; named again.
- **KNOWLEDGE §6 is well past 550 lines, still growing** — chronic since S60, still unpruned. Its own
  staleness header is itself stale.
- **Still reuse `named_test_passed()`** — a bare `cargo test --lib <filter>` exits 0 on a filter
  matching zero tests. And **`[[:space:]]`, never `\s`**, in any script check (BSD/macOS grep).
- **Launcher dogfood is 🔴 STALE — 14 sessions / ~14+ true calendar days since S103.** Approved as
  S118, waiting on the founder.
- **The fleet line counts ARTIFACTS, not agents — except where a real dispatch is independently
  proven, which is now ALL THREE roles** (S111, S115, S117). No longer a partial claim.
- **v0.1 installs FOUR ways, all measured, CONFIRMED stranger-shippable at S110 GT.** Residual 🟡s in
  STATE.md. **crates.io is PUBLISHED — `vajractl` name BURNED**; any crates.io action stays
  founder-gated.
- **Untracked stragglers** (standing founder call): `sessions/session-9*-artifacts/*`,
  `sessions/session-10{2,3,7,8,9}-artifacts/*`; `vajra-cto-audit-*.html` + `first-mate.html`.
- **Background task flagged, not yet acted on:** `task_2162b487` — the Planner-gate
  `is_acceptance_heading` double-counting bug (S117 finding), slated for S119.
