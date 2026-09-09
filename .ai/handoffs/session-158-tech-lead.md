---
role: tech-lead
session: 158
agent: claude-code-subagent (verified: toolu_01TzXmAjRVuuLBXXxoHLYzJH)
source-sha: e95241425fd0ecbf855de58d53617c19789b8b131f190d208707dc1131006013
captured: 2026-09-09T14:56:07Z
cost_usd: null
---

# Tech-lead handoff — session 158

## Session 158 Tech-Lead Handoff

**Session:** 158 — Demo enforcement: make the demo step mandatory in CODE sessions
**Type:** CODE
**Branch:** session-158-demo-enforcement
**Work status:** All 4 plan steps committed at sha f28bee9
**Changed files:** `scripts/verify-closeout.sh` (added `is_code_session`, tightened `check_verify_demo_scripts`, added `check_demo_markers`), `scripts/demo-session-158.sh` (new), `scripts/verify-session-158.sh` (new)

### What was built

1. `is_code_session()` — reads the `## Type` section of the session's prompt file; returns non-code for GT (N % 5 == 0), DOCUMENT, NO-CODE, DOGFOOD, GROUND-TRUTH; defaults to CODE when absent.
2. `check_verify_demo_scripts` — now calls `is_code_session` before requiring the demo script; previously required it unconditionally or not at all.
3. `check_demo_markers` — new function that runs the demo script live and blocks when any of the 4 markers (`header`, `cases`, `summary_table`, `before_after`) is missing from output.
4. `scripts/demo-session-158.sh` — emits all 4 required markers; uses `--demo-only` and `--scripts-only` modes of `verify-closeout.sh` in its cases section.
5. `scripts/verify-session-158.sh` — checks all 5 ACs, runs cargo test + cargo build --release.

### Crew

crew requirements-analyst — deferred-budget — budget: 120,000 tokens — acceptance criteria are already locked in the prompt (5 numbered items); no ambiguity to resolve.
crew plan-advisor — deferred-budget — budget: 120,000 tokens — four-step plan is already written and ordered; covers: tags are present; plan gate will parse this without advisory.
crew implementation-advisor — deferred-budget — budget: 300,000 tokens — all 4 plan steps already committed at f28bee9; implementation is complete; advisory would add no signal.
crew qa-specialist — deferred-budget — budget: 200,000 tokens — verify-closeout.sh already runs the full test suite and the build; verify-session-158.sh provides 14 behavioral checks; a separate QA pass adds no signal the verify script does not already give.
crew demo-producer — deferred-budget — budget: 150,000 tokens — demo-session-158.sh already written and emits all 4 required markers; no advisory needed post-implementation.
crew release-coordinator — deferred-budget — budget: 120,000 tokens — no release to crates.io this session; PR open + merge is handled by the session loop itself.
crew researcher — deferred-budget — budget: 150,000 tokens — no open design questions; the grep-on-Type-section approach is an implementation decision, not a research question.

crew design-advisor — required — budget: 250,000 tokens — is_code_session() is a new shared inference contract (two gate functions call it); design-significant verdict needed; assess grep-on-free-text robustness and whether a structured key would be safer; limit to is_code_session() and check_demo_markers().
crew fidelity-reviewer — required — budget: 250,000 tokens — S69 rule: fidelity review must be a cold subagent pass; the prompt has 5 numbered ACs; fidelity-reviewer checks each maps to SHIPPED/PARTIAL/NOT-BUILT with evidence; must verify --demo-only and --scripts-only are real wired paths.

### Recommendations

rec 1 — fidelity-reviewer must confirm that `--demo-only` and `--scripts-only` are real flag paths in `verify-closeout.sh` before marking AC2 SHIPPED; the demo script's cases section calls both, and a scaffolded flag would produce a false PASS on the marker check.

rec 2 — design-advisor should rule on whether grep-on-free-text in `is_code_session` is the right long-term surface for session-type detection, or whether a structured `type:` key in the prompt frontmatter would be safer.

rec 3 — if the fidelity-reviewer finds that `check_demo_markers` only checks marker presence in a pre-captured string (not a live run), flag it as PARTIAL for AC2.

## Handoff Delta
- `~` re-run: tech-lead handoff replaced (3909 bytes now vs 2743 bytes prior)
- prior stage: this session's earlier tech-lead handoff
