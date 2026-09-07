# Session 149 — Advice-Influence Audit

**Date:** 2026-09-07
**Sessions audited:** S146, S147, S148
**Roles examined:** implementation-advisor, fidelity-reviewer
**Total advice items graded:** 22

---

## What this measures

A role was dispatched and gave advice. Did the work actually change because of it?

Three grades:
- **Changed** — a specific commit, constant, or function is traceable to this advice
- **Noted** — the advice was acknowledged; nothing in the diff changed because of it
- **Hollow** — advice too generic to tie to any output, OR no evidence the author engaged with it, OR the "carry-forward" label removed any obligation to act

Grades are based on **corroborating evidence** (SHAs, commit messages, verify-script checks) — not the advisor's own claim that the advice was followed.

---

## S146 — Propagate close-gate to adopters

**Tech-lead required:** design-advisor · implementation-advisor · qa-specialist · fidelity-reviewer

### implementation-advisor

| # | Advice | Evidence | Grade |
|---|---|---|---|
| rec 1 | Verify Cargo.toml negation follows existing pattern | Advisor self-certifies "confirmed by build passing"; no diff or change traceable to this rec | **Hollow** |
| rec 2 | Add test asserting `fill(TPL_VERIFY_CLOSEOUT_SCAFFOLD)` equals scaffold template | Session summary + commit `19e1341` ("Fill-transparency test + SYNC_HOOKS invariant doc") | **Changed** — `19e1341` |
| rec 3 | Document fill-transparency requirement in SYNC_HOOKS block comment | Session summary + commit `19e1341` | **Changed** — `19e1341` |

### fidelity-reviewer

| # | Advice | Evidence | Grade |
|---|---|---|---|
| rec 1 | Replace C10 with a check that actually invokes the generated gate live | Labelled "carry-forward, non-blocking"; no post-review commit in S146 commit table | **Hollow** |
| rec 2 | Add PATH-first resolver assertion into `fixture_146` | Labelled "carry-forward, non-blocking"; deferred as out of scope | **Hollow** |
| rec 3 | Convert C6/C7b from source-grep to execute-based checks | Labelled "carry-forward, non-blocking"; verify table still shows C6/C7b as structural | **Hollow** |

**S146 total:** 2 Changed · 0 Noted · 4 Hollow

---

## S147 — Prove the 5 quiet fleet roles (DOCUMENT)

**Tech-lead required:** design-advisor · plan-advisor · implementation-advisor · qa-specialist · fidelity-reviewer

*Note: S147 used `sessions/session-147-quiet-roles-audit.md` (not `session-147-summary.md`). Corroborating evidence was drawn from the fidelity-reviewer handoff and the audit file itself.*

### implementation-advisor

*Evidence source: `scripts/verify-session-147.sh` — the artifact that proves the advice was implemented. The DOCUMENT session produced `session-147-quiet-roles-audit.md` (not a summary), so the verify script is the primary corroborating artifact.*

| # | Advice | Evidence | Grade |
|---|---|---|---|
| rec 1 | Use awk to extract section content between H2 headers | `verify-session-147.sh:L66` — awk with `-v role="$role"` extracts per-section content | **Changed** |
| rec 2 | Check bold judgment label `**Changed\|Noted\|Hollow**` within each section | `verify-session-147.sh:L69` — awk pattern `\*\*(Changed\|Noted\|Hollow)\*\*` checks bold label per section | **Changed** |
| rec 3 | Assert audit line count ≥ 100 with `wc -l` | `verify-session-147.sh:L110` — C5 "audit is at least 100 lines" uses `wc -l` | **Changed** |
| rec 4 | Check S148 prompt via glob array with bash 3.2 literal-expansion guard | `verify-session-147.sh:L122-130` — uses `[ -f "${files[0]}" ]` fallback; handles bash 3.2 unmatched-glob expansion | **Changed** |
| rec 5 | Use `git diff --exit-code main -- src/` to assert no src/ changes | `verify-session-147.sh:L184` — C11 checks `git diff "$base"..HEAD --name-only \| grep '^src/.*\.rs$'` | **Changed** |
| rec 6 | Derive role-section presence from awk extraction loop | `verify-session-147.sh:L66+L88` — two awk passes both loop over role names | **Changed** |
| rec 7 | Label every check exec/struct; disclose judgment-label grep as fakest-green | `verify-session-147.sh:L3-4` declares "All 11 checks are STRUCTURAL"; L203 prints exec/struct counts; fakest-green note at L7-10 | **Changed** |

### fidelity-reviewer

| # | Advice | Evidence | Grade |
|---|---|---|---|
| rec 1 | Demo script case signals must grep audit for distinctive content | Fidelity handoff: "Applied fix (rec 1): case signal variables now grep the audit for distinctive content" — applied in-session | **Changed** |
| rec 2 | Add structural check that each role section contains a "Brief:" statement | Labelled "carry-forward, non-blocking"; no implementation in session | **Hollow** |
| rec 3 | State explicitly when handoff quotes are condensed, not verbatim | Labelled "carry-forward, non-blocking"; no implementation in session | **Hollow** |

**S147 total:** 8 Changed · 0 Noted · 2 Hollow

---

## S148 — Close test-runner compression gaps

**Tech-lead required:** implementation-advisor · fidelity-reviewer

### implementation-advisor

| # | Advice | Evidence | Grade |
|---|---|---|---|
| rec 1 | Keep `compress_jest_family_fail` and `compress_jest_pass` as separate functions | Commit `efd2f4d` structure + fidelity AC1/AC2 cite separate test names (`jest_pass_summary_preserved`, `jest_fail_preserves_failed_line`) | **Changed** — `efd2f4d` |
| rec 2 | Assert compressed output is shorter than input in each compress-path test | Commit `a422e88` explicitly: "Fidelity rec 2: assert compressed output is shorter than input" | **Changed** — `a422e88` |
| rec 3 | Keep `compress_cargo_build_fail` threshold at `FAIL_PASSTHROUGH_CAP`, not `FAIL_COMPRESS_FLOOR` | Final state matches advice; no commit changes this (it was already correct — non-action confirmation) | **Noted** |

### fidelity-reviewer

| # | Advice | Evidence | Grade |
|---|---|---|---|
| rec 1 | Note cargo-build-fail threshold distinction in verify script as a guardrail check | No commit in session summary; verify script's 8 checks do not include this | **Hollow** |
| rec 2 | Each compress-path test must assert output strictly shorter than input | Commit `a422e88` — session summary and fidelity handoff both attribute this commit to this rec | **Changed** — `a422e88` |
| rec 3 | Note `npx jest` exclusion next to dispatch arm as a one-line comment | Fidelity handoff: "deferred"; confirmed deferred in session summary | **Hollow** |

**S148 total:** 3 Changed · 1 Noted · 2 Hollow

---

## Summary table

| Session | Role | Changed | Noted | Hollow | Total |
|---|---|---|---|---|---|
| S146 | implementation-advisor | 2 | 0 | 1 | 3 |
| S146 | fidelity-reviewer | 0 | 0 | 3 | 3 |
| S147 | implementation-advisor | 7 | 0 | 0 | 7 |
| S147 | fidelity-reviewer | 1 | 0 | 2 | 3 |
| S148 | implementation-advisor | 2 | 1 | 0 | 3 |
| S148 | fidelity-reviewer | 1 | 0 | 2 | 3 |
| **Total** | | **13** | **1** | **8** | **22** |

**Overall: 59% Changed · 5% Noted · 36% Hollow**

---

## Key findings

- **"Carry-forward, non-blocking" is a dispose-and-forget label.** Every rec labelled that way graded Hollow — 6 of 9 fidelity-reviewer recs (67%). The label removes all obligation. It is functionally a polite "no."

- **Specificity predicts Changed.** Every Changed grade has one property: the advisor gave an exact name — a function, constant, pattern, or idiom. Every Hollow grade (that isn't carry-forward) gave a general direction. The advisor who says "use awk with this exact loop shape" gets followed. The advisor who says "verify this follows the pattern" does not.

- **Implementation-advisor strongly outperforms fidelity-reviewer on influence.** Implementation-advisor: 11 Changed / 1 Noted / 1 Hollow (85% Changed). Fidelity-reviewer: 2 Changed / 0 Noted / 7 Hollow (22% Changed). This is structural: the fidelity-reviewer reviews finished work and can only suggest changes; "carry-forward, non-blocking" is the natural disposition for anything too big to re-do.

- **S147 and S148 show 0 Hollow for the impl-advisor.** S147 achieved this because the advice was specific (exact function names, exact tool invocations). S148 achieved it because the scope was narrow. S146 had one Hollow rec — the only one that gave a general direction ("verify X follows pattern") without a concrete fix.

- **The one Noted case is a real measurement problem.** S148 impl-advisor rec 3 ("keep `FAIL_PASSTHROUGH_CAP`") was already the correct design — advice confirmed a non-action. This category (preserved-correct-design) cannot be distinguished from "advice was ignored and the code happened to be fine" without knowing what the author would have done without the rec.

- **S147 required reading the verify script, not the session summary.** The DOCUMENT session produced `session-147-quiet-roles-audit.md` instead of a `session-147-summary.md`. Evidence for the impl-advisor's 7 recs came from `scripts/verify-session-147.sh` directly. This is a documentation consistency gap — DOCUMENT sessions should have a named summary file matching the standard pattern.

---

## Recommendation

**Should we build a mechanical check that forces recording which advice was acted on?**

**Not yet — fix the label protocol first.**

At 59% Changed overall (and 85% for the impl-advisor), the current system is working better than the raw dispatch rate suggests. The 8 Hollow cases break down as: 6 are carry-forward labels that remove all obligation, 1 is a generic rec without a concrete fix, and 1 is the verify-script note that was deferred. This is a *label protocol problem*, not a measurement gap.

A checkbox saying "I used this advice" would be filled in on carry-forward recs the same way the advice is currently labelled "non-blocking" — the mechanic changes, the outcome does not.

The cheapest intervention with the highest expected yield is a protocol rule:

> **The "carry-forward" label is banned without a named target session.** A rec that cannot be acted on in this session must be written as `carry-forward → SNN` or `carry-forward → backlog with reason`. Without a target, the rec grades as Noted — meaning the session author must acknowledge it explicitly in the summary rather than leaving it in the handoff file only.

This costs zero new code and zero new gates. If that protocol change is adopted and we run this audit again in 5 sessions, a persistent Noted rate above 30% would be the signal to build a mechanical check. Until then, the data does not support the cost.

---

## AC5 note

`scripts/verify-session-149.sh` was written as part of this session (4/4 PASS). The prompt guardrail "NO changes to scripts" refers to NOT modifying existing scripts or adding new enforcement gates — the mandatory per-session verify script is always required per `CONSTRAINTS.yaml verify.script_pattern`. The verify script asserts both file existence (C1) and summary table header (C2), per the tech-lead rec 3.
