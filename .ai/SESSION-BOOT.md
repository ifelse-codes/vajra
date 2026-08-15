# Session Boot

## Current Session
- **Number:** 118 — COMPLETE
- **Type:** DOGFOOD (paid). The overdue `vajra claude` run, target chitra S11.
- **Goal:** run `vajra claude` headless on one real bounded task under a ~$5 cap, capture the
  authoritative receipt + station/dogfood-age/obedience evidence, and report honestly.
- **Verdict:** **ACCEPT** (two cold `fidelity-reviewer` passes — pass 1 REJECT, pass 2 ACCEPT at
  5 of 8 SHIPPED, 3 PARTIAL, 0 NOT-BUILT). **Spend: $4.0911771 authoritative, 1331s, under the $5 cap.**
  The run delivered chitra S11 and graded itself 8-of-8 SHIPPED with `verify-session-11.sh` at
  **14/14 ALL GREEN** — while **19 of its 20 chart pages showed an error instead of a chart.** All 11
  catalog checks in that suite were greps for source strings. Found by the operator clicking every
  chart in a browser; repaired to 20/20 and closed with a check that EXECUTES all 20 examples across
  3 renderers (81 checks, falsifiable: 5/81 with the defect reintroduced). Pass 1 REJECTed this
  session for the same sin one level up — verification delivered as prose, no screenshot captured;
  fixed with 5 real headless-Chrome PNGs. Pass 2 caught an inflated "six gates fired" headline
  (one gate is file-backed against the agent) — corrected. No Vajra `src/` changes.
- **Report:** `sessions/session-118-summary.md` · `sessions/session-118-ground-truth.md` ·
  `sessions/session-118-review.md` · next prompt: `prompts/119-task-qa-grep-only-detector.md`.
  **Date last updated:** 2026-08-15.

## Repo State Snapshot
- `.ai/SESSION` = 118. Work on `session-118-dogfood-chitra-catalog`. No `src/` change
  (`design-significant: no`); `VAJRA_CLOSEOUT_WAIVER=dogfood-no-src-changes`.
- **Dogfood staleness RETIRED:** the 🔴 that stood at 14 sessions / 16 days since S103 is closed.
- **chitra is left on `session-11-catalog-two-panel`, LOCAL — not pushed, no PR**, by instruction.
  11 commits: 6 from the governed run, 5 from the operator repair. chitra `main` never moved.
- Stations for 118: Analyst ✅ Planner ✅ Coder ✅ — 3 of 8 (QA/Demo-er absent by design for a
  dogfood; Releaser flips once the PR merges).

## Next Session
- **Number:** 119 — **CODE: teach the QA station to smell a grep-only verify suite** (founder pick
  pending; A from the S118 close). Goal: flag a verify script whose checks never execute the thing
  they check, so a suite that cannot fail on a broken build is visible at close.
- **Why:** this session paid $4.09 to discover that a 14/14 green verify suite proved nothing. It is
  the finding, and it generalizes to every repo Vajra governs.
- **Carried, not dropped:** the Planner-gate double-count bug (`task_2162b487`) and the opt-in
  blocking fleet gate — both were S119's plan before this run produced a sharper candidate.

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
