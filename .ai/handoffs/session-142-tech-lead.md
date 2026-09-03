---
role: tech-lead
session: 142
agent: claude-code-subagent (verified: toolu_01CLbngxKC2eXXbkwdvcir47)
source-sha: eac319701c9641e31052f699ea3d37539f1318c1a8fc8a6f4eef3f990e62fcc5
captured: 2026-09-03T05:34:05Z
cost_usd: null
---

# Tech-lead handoff — session 142

# Tech Lead brief — Vajra S142 (scaffold-upgrade: generalise the render stamp to hooks + constitution)

This is a CODE session, 1 story: generalise the S141 `vajra-render-sha:` stamp beyond YAML frontmatter to shell hooks (`# vajra-render-sha:`) and the markdown constitution (`<!-- vajra-render-sha: -->`), widening the EXISTING `vajra init --sync-fleet` (no 8th command) to give those pure renders the same four-state upgrade. The WHAT is founder-approved and the acceptance is already EARS-style. The intellectual crux is a design fork, not a research or requirements gap.

**Is the design fork load-bearing? Yes — decisively.** Two things must be settled before code, and neither is safe to assume:
1. Per-file-type stamp placement — the S141 helpers (`stamp_render`/`strip_render_stamp`/`extract_render_stamp`/`render_stamp_verifies`, fleet 656-778) split on `\n---\n` and search only the frontmatter block. Generalising to a shell comment and an HTML comment while preserving the exact-inverse round-trip (`strip(stamp(x)) == x`) and keeping the stamp inert to the consumer is real design, not a mechanical port.
2. The AGENTS.md wrinkle the builder already found — hooks are byte-identical pure renders (clean fit), but `.ai/AGENTS.md` is a FILLED template (`{PROJECT_NAME}`, `{GOAL}`, `{MATURITY}`, `{FIRST_*}`), so its rendered bytes are project-specific and `sync_fleet(root)` (init 149) does not hold those fill values. Whether AGENTS.md is genuinely upgradeable-in-place this session or must be a disclosed remainder is the scope-defining call. That is design-advisor's to make, and it materially changes what ships.

So design-advisor is required. Beyond that, S142 mirrors S141's proven-affordable crew exactly (S141 = tech-lead + design-advisor + qa-specialist + fidelity-reviewer, $0 metered, all tight named-files dispatches). Acceptance criterion 3-4 (four-case falsifiability fixture red-for-right-reason + a LIVE idempotency proof with the real binary) is independent-QA work; criterion 6 requires a cold fidelity ACCEPT. Those three specialists are the required crew.

The remaining six are `deferred-budget` on money grounds — not unworthy. The demo script and the PR/closeout are thin artifacts the session author carries inline (as in S141); paying a demo-producer or release-coordinator subagent on top of three required dispatches is what tips a $20/mo plan, so those defer as arithmetic, not as a usefulness verdict.

## Crew

crew researcher — deferred-budget — budget: 300000 tokens — no external unknown here; the only lookup (chitra's real `.ai/` for the scope split) is a cheap read folded into design-advisor. S134 measured ~6M raw/broad dispatch; three tight required specialists already book this session's headroom on a $20/mo plan (S134 hit the monthly cap at 19.2M raw), so a fourth paid dispatch is the one that tips it.
crew requirements-analyst — deferred-budget — budget: 300000 tokens — the 6 EARS criteria are already written and founder-approved; refinement is inline, not a dispatch. Deferred as money: adding a fourth paid subagent to the three required exceeds what the $20/mo account should spend this session (S134: ~6M raw/dispatch, cap hit at 19.2M).
crew design-advisor — required — budget: 800000 tokens — LOAD-BEARING: must settle the per-file-type stamp placement (generalise the S141 helpers to shell + HTML comment syntax, exact-inverse round-trip preserved, one copy not two) AND rule whether `.ai/AGENTS.md` (a filled template `sync_fleet` cannot re-fill) is upgradeable in place or a disclosed remainder. Cite DECISION-007 + S141 addendum, write the S142 addendum, state rejected alternatives (stamp CONSTRAINTS.yaml — rejected, user-tuned; sidecar manifest — S141-rejected). Named reads: fleet 656-778, init 53-278, DECISION-007, chitra's `.ai/` (hooks + AGENTS.md). No repo read.
crew plan-advisor — deferred-budget — budget: 300000 tokens — 1 story, a linear path (generalise helpers → per-type classify → widen sync loop → fixture → live proof); design-advisor's fork is the only ordering risk and it owns that. Deferred as money: a fourth paid dispatch on top of the three required is what the $20/mo plan cannot afford this session (S134 arithmetic: ~6M raw/dispatch, 19.2M cap).
crew implementation-advisor — deferred-budget — budget: 400000 tokens — the coding subtlety (per-type comment syntax) is exactly what design-advisor resolves before code, so a separate HOW dispatch is redundant this session. Deferred on money, not merit: three required already book the account's headroom; S134 measured ~6M raw/dispatch and hit the $20/mo monthly cap at 19.2M.
crew qa-specialist — required — budget: 500000 tokens — criterion 3-4 is independent-falsification work: run `scripts/verify-session-142.sh` (exit 0) and the four-case fixture LIVE, prove it goes RED for the RIGHT reason (S122) + a clean exit-0 positive control (S134), and confirm a stamped hook still RUNS and the stamped constitution still reads (the "stamp must not change behavior" guardrail). Named reads: the fixture, verify script, fleet 656-778, init 53-278. No repo read.
crew demo-producer — deferred-budget — budget: 300000 tokens — `demo-session-142.sh` (4 sprint markers) is a thin artifact the session author carries inline, as in S141; the paid chitra full-loop dogfood is explicitly deferred to after S142. Deferred as money: paying this on top of the three required specialists is the dispatch that tips a $20/mo plan (S134: ~6M raw/dispatch, cap at 19.2M).
crew fidelity-reviewer — required — budget: 600000 tokens — MANDATORY (close runs check_required_crew, S139) and genuinely needed: cold ACCEPT/REJECT on the shipped diff vs the 6 acceptance criteria, and judge each design-advisor `obeyed:` disposition. Named reads: prompt 142, the session diff, `sessions/session-142-summary.md`, the S142 addendum. No repo read.
crew release-coordinator — deferred-budget — budget: 300000 tokens — the PR-open/attest-last/verify-closeout-before-merge path (guardrails) is handled by the closeout gate + the session author inline, as in S141; no separate paid dispatch shipped there before. Deferred as money: a fourth+ paid subagent exceeds the $20/mo account's headroom this session (S134: ~6M raw/dispatch, 19.2M monthly cap).

## Recommendations

rec 1 — Dispatch design-advisor BEFORE writing any code; its two rulings (per-type stamp placement + whether AGENTS.md upgrades in place or is a disclosed remainder) define what ships.

rec 2 — Keep the paid crew to three specialists (design-advisor, qa-specialist, fidelity-reviewer), matching S141's proven-affordable pattern; author the demo script and the PR/closeout inline rather than paying demo-producer or release-coordinator.

rec 3 — Have design-advisor do the cheap read of chitra's ACTUAL `.ai/` before locking the CONSTRAINTS.yaml-stays-out split (design Q2) — confirm against what chitra really edited, don't assume it.

rec 4 — Budget every dispatch to NAMED FILES only (fleet 656-778, init 53-278, DECISION-007, the fixture, the summary) — no "read the repo" (S134's 19.2M-token lesson on a $20/mo plan).

rec 5 — Instruct design-advisor to REUSE/generalise the S141 helpers into per-file-type comment syntax, not fork a second copy — a duplicate stamp/strip pair is exactly the drift `--sync-fleet` exists to close.

## Handoff Delta
- `~` re-run: tech-lead handoff replaced (7412 bytes now vs 7276 bytes prior)
- prior stage: this session's earlier tech-lead handoff
