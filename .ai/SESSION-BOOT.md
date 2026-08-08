# Session Boot

## Current Session
- **Number:** 116 — COMPLETE
- **Type:** CODE. The fleet's THIRD named role, the Plan Advisor.
- **Goal:** add a third `fleet::ROLES` entry (key `plan-advisor`, distinct from the Planner
  *station*), read-only, contract = propose ordered plan steps citing `covers: N` — the exact marker
  `src/planner/mod.rs` already parses and grades. Resolve the key collision with the Planner station
  in writing (mirroring the `fidelity-reviewer`/Reviewer-station precedent).
- **Verdict:** **ACCEPT** (independent cold review, 10 of 12 SHIPPED — the 2 PARTIALs are the
  read-only reviewer declining to grade unexecuted scripts, not a real gap; the builder ran
  `cargo test --lib`, `verify-session-116.sh`, and `demo-session-116.sh` green in-session with
  captured terminal evidence). Same zero-new-machinery result as S114: `vajra init`, `vajra next`,
  and the S113 counter needed **no code changes** to pick up a third role — confirmed by tracing
  `src/cli/init.rs`, `src/cli/next.rs`, and `src/stations/mod.rs::fleet_evidence`, not by re-asserting
  the claim. Key collision resolved: `plan-advisor`, not `planner` (`DECISION-007` S116 addendum, 2
  rejected alternatives). 323 lib tests; verify **16/16**; demo **10/10**; attested
  `1b6c0159ad26b268cebef5ac003f4206deb50121b4d9dc4a7937f35fe91e5079`.
- **Report:** `sessions/session-116-summary.md` · `sessions/session-116-review.md` · next prompt:
  `prompts/117-task-plan-advisor-dispatch.md`. **Date last updated:** 2026-08-07.

## Repo State Snapshot
- `.ai/SESSION` = 116. 3 atomic commits on `session-116-fleet-role-planner`. Closeout bundle (this
  sync + summary/review + next prompt) lands on the same session branch (a CODE session, not GT —
  no exempt-suffix branch needed).
- Ledger: not re-verified this session (no `--ledger-verify` run; nothing indicates drift). Closeout
  gate: `fidelity-review-accept` + `review-inputs-attested` both PASS (attestation confirmed stable
  across two consecutive `--inputs-sha 116` runs before embedding, per the standing "attest LAST"
  rule).
- Fleet now has **THREE** registered roles (`researcher`, `fidelity-reviewer`, `plan-advisor`), all
  scaffolded from `fleet::ROLES` (`vajra init` proven to render exactly 3 files, byte-identical to
  this repo's committed `.claude/agents/*.md`, via `verify-session-116.sh#scaffolds_three_roles`).
  The Plan Advisor has **never been dispatched by name** — per S111, a role's agent file is invisible
  to the same session that wrote it; S117 is the earliest session that can prove it, mirroring S115's
  proof for the Reviewer.

## Next Session
- **Number:** 117 — **CODE: prove the Plan Advisor dispatches by name.** Founder pick A at the S116
  closeout (over B: the paid dogfood, and C: wiring fleet handoffs into station gates). Prompt:
  `prompts/117-task-plan-advisor-dispatch.md`.
- **Load-bearing expectation, stated plainly so a surprise gets named, not absorbed:** S115 proved the
  next-session dispatch case works cleanly for the Reviewer on the first try. S117 should confirm the
  same holds for the Plan Advisor — but if it does NOT (e.g. some role-specific reason the dispatch
  fails or needs a workaround), that is itself a real, load-bearing finding to record in writing, not
  silently smoothed over as "probably a fluke."
- **Deferred, by explicit founder call, not neglect:** the paid `vajra claude` dogfood (🔴 since S103
  — now 13+ sessions). The S116 summary recommends the next GT (S120) press on this if S117–S119
  don't reach it either.

## Carry-Forwards
- **New session = new chat** (AGENTS.md step 10) — open a fresh chat for S117.
- **Communicate in the plainest English** (founder request S103) — translate all jargon.
- **Dispatch-by-name is proven for the next-session case on TWO roles now (S115 Reviewer, presumed —
  not yet tested — for S116's Plan Advisor).** The mid-creating-session case (a role dispatching
  itself in the same session that wrote its `.claude/agents/*.md`) remains untested for every role and
  is presumed still to fail per S111 — do not conflate the two.
- **When a new fleet role lands, regression-test against the most recent COUNT-AGNOSTIC prior verify
  script, not simply the most recent one.** `verify-session-114.sh#scaffolds_two_roles` hardcodes
  "exactly 2 agent files" and goes red the moment a third role exists — expected staleness (a
  historical snapshot of S114's world), not a real regression. S116 regression-tested against
  `verify-session-113.sh` instead, which tests the counter mechanism generically. The next role (a
  4th) should regression-test against `verify-session-116.sh`'s generic checks, and check whether
  `scaffolds_three_roles`' own "exactly 3" assertion has by then gone stale in the same way.
- **A grep-based "one source of role text" probe must not straddle a Rust `\`-continuation line
  break** — invisible to grep against the source file even though the compiled string is whole. Test
  the probe against `src/fleet/mod.rs` directly before trusting a positive control.
- **The station/role name-collision pattern now has TWO confirmed instances** (Reviewer vs
  `fidelity-reviewer` at S114; Planner vs `plan-advisor` at S116) — expect a third whenever a future
  role's natural name matches an existing station name. Resolution pattern: distinct key,
  `resolve_role(<station word>).is_none()` asserted by test, decision addendum with ≥2 rejected
  alternatives.
- **The reviewer contract has TWO files and they are BOUND, not duplicated:** `reviewer/SKILL.md` is
  canonical; the role's system prompt is its dispatch-time summary. A check reads BOTH. Never edit one
  alone. (This binding exists only for the Reviewer role — the Plan Advisor has no second-source
  counterpart to bind against.)
- **The closeout gate counts verdict words ONLY on `|` table rows, and needs ≥3.** A per-requirement
  bullet list — however correct — is BLOCKED. **A verdict line wrapped in a `|`-table row also fails
  the canonical-verdict regex (S115 finding)** — only a bare `**Verdict:** ACCEPT`/`REJECT` line
  passes. S116's cold review landed this correctly on the first try — worth re-confirming at S117.
- **Attest LAST: `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff), and the PROMPT IS AN INPUT —
  CORRECTED THIS SESSION.** The `diff` component excludes `prompts/`/`sessions/`, but the `prompt`
  component is `git show HEAD:<the prompt file>` **directly**, read whole — so filling in a prompt's
  own `## Execution` shas changes the hash even though the diff-exclusion makes it look like it
  shouldn't. S116 computed the hash, then filled in the last Execution sha, and the hash CHANGED on
  the next `--inputs-sha` run — caught before embedding, not after. **Always compute
  `--inputs-sha` as the LAST step, strictly after every edit to the prompt file itself (Execution
  shas included), not just after the code diff is final.**
- **A three-element registry is the next test of "hides per-element assumptions"** — S114 found two
  leaks going from 1→2 roles; S116 found none going from 2→3 (every generic path held), which is
  itself worth recording as evidence the S109 architecture is holding up, not just asserting it.
- **Known weak check, house-wide, unfixed 5 sessions running (S111–S116, except S115 which built no
  code):** `no-eighth-command` greps a hardcoded usage banner. Not urgent; named again, not yet
  budgeted.
- **KNOWLEDGE §6 = 517 lines, growing** (was 496 at the S115 mention) — chronic since S60, still
  unpruned. Its own staleness header is now itself stale.
- **Still reuse `named_test_passed()`** — a bare `cargo test --lib <filter>` exits 0 on a filter
  matching zero tests. And **`[[:space:]]`, never `\s`**, in any script check (BSD/macOS grep).
- **Launcher dogfood is 🔴 STALE — 13 sessions / ~13+ true calendar days since S103.** Mechanism tests
  do NOT reset it.
- **The fleet line counts ARTIFACTS, not agents** — except where a real dispatch is independently
  proven (S111 Researcher, S115 Reviewer). Say precisely what was proven, don't conflate the two. The
  Plan Advisor has NOT been proven dispatched yet — S116 built the file, nothing more.
- **v0.1 installs FOUR ways, all measured, CONFIRMED stranger-shippable at S110 GT.** Residual 🟡s in
  STATE.md. **crates.io is PUBLISHED — `vajractl` name BURNED**; any crates.io action stays
  founder-gated.
- **Untracked stragglers** (standing founder call): `sessions/session-9*-artifacts/*`,
  `sessions/session-10{2,3,7,8,9}-artifacts/*`; `vajra-cto-audit-*.html` + `first-mate.html`.
