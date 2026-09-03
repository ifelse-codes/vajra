---
role: tech-lead
session: 143
agent: claude-code-subagent (verified: toolu_01R6bbgT73caAhbWp5KZi9r2)
source-sha: 1df99c79a29264af2a751b64dea0213fbc53eac0723033e9102afde18862b673
captured: 2026-09-03T14:22:51Z
cost_usd: null
---

# Tech-lead handoff — session 143

# Tech-lead brief — Vajra S143 (constitution joins the smooth upgrade: header/body split)

Session 143 (CODE, 1 story) — the constitution `.ai/AGENTS.md` joins the smooth upgrade via a header/body split. The crew mirrors the S141/S142 pattern proven affordable at $0 metered on a $20/mo plan: three required (the design fork, the live/fixture QA, the binding review), six deferred as money facts.

## Crew

crew researcher — deferred-budget — budget: 40000 tokens — No open unknown to research: every input (the four-state machine, `StampSyntax`/`MarkdownComment`, the S142 addendum's rejected alternatives) is already in-repo and cited by the brief; a fourth tight dispatch is affordable only because three required already load the account — S134 measured ~6M raw tokens/dispatch when told "read the repo," and a $20/mo plan hits the cap near 19.2M, so the arithmetic, not the usefulness, defers this.

crew requirements-analyst — deferred-budget — budget: 40000 tokens — The six EARS acceptance criteria are already written and testable in the prompt (WHAT is settled); adding a fourth dispatch alongside three required does not fit the same money envelope S141/S142 held at ~$0 — deferred on the arithmetic, not on worth.

crew design-advisor — required — budget: 85000 tokens — The session's whole crux is a DESIGN fork the brief forbids the builder to assume: the exact boundary-sentinel literal that splits user-owned header from governed body, the body-scoped classify/rewrite (states computed on the body region alone), and the legacy-migration honest limit (`--overwrite-drifted` rewrites the WHOLE file and would destroy `{PROJECT_NAME}` — the session's fakest-green risk); brief it on the four named files only.

crew plan-advisor — deferred-budget — budget: 35000 tokens — The prompt's `## Plan` is already ordered with `covers:` tags per criterion and follows the proven S141/S142 shape; a fifth ordering opinion is real help but not affordable this session against three required under the $20/mo cap — deferred on money, not merit.

crew implementation-advisor — deferred-budget — budget: 45000 tokens — The code path is a known widening (reuse `MarkdownComment` `StampSyntax`, extend `classify_fleet_file`/`sync_targets` from whole-file to body-scoped) with the design-advisor settling the hard call; a separate implementation-strategy dispatch would help but repeats S134's cost lesson — three required already price the session, so this defers on the arithmetic.

crew qa-specialist — required — budget: 45000 tokens — Criterion 3 demands a falsifiability fixture that goes RED for the right reason PLUS a byte-for-byte "header survives the upgrade" assertion PLUS a clean-exit-0 positive control, and criterion 4 demands a LIVE idempotent `init`+sync in a real empty dir with the real binary — and S142 left the `MarkdownComment` variant with NO fixture (qa rec 2); an independent cold QA run is exactly this session's load.

crew demo-producer — deferred-budget — budget: 30000 tokens — `demo-session-143.sh` (>=4 sprint markers) is a mechanical follow-on of the S141/S142 demo scripts the builder can produce directly; a dedicated dispatch is nice-to-have, not affordable beside three required — deferred on money.

crew release-coordinator — deferred-budget — budget: 30000 tokens — No publish/tag this session (a PR merge to `main` after the branch passes `verify-closeout.sh`, no crates.io release); the role would matter at a real ship, and even then a fourth dispatch competes with the required three under the cap — deferred on the arithmetic.

crew fidelity-reviewer — required — budget: 90000 tokens — Mandatory by construction: `verify-closeout.sh` binds the close on a cold ACCEPT fed only prompt+diff, and criterion 6 requires every `obeyed:` disposition judged `implemented:` by a different role — it must independently confirm the header is never clobbered (the disclosed fakest-green) rather than take the summary's word.

## Recommendations

rec 1 — Make the design-advisor settle the boundary-sentinel literal BEFORE any code, and record it in a DECISION-007 S143 addendum: an HTML-comment line (inert to markdown, stable across installs, self-evidently "do not edit below") with the `<!-- vajra-render-sha: -->` stamp's position relative to it fixed, so classify/rewrite operate on the body region alone.

rec 2 — Treat the legacy migration as the fakest-green to avoid: a pre-S143 constitution has no boundary and no stamp, so it classifies `Drifted` on first contact — `--overwrite-drifted` would rewrite the whole file and destroy the project's `{PROJECT_NAME}` fill, so it is NOT safe here; require and DISCLOSE a one-time manual boundary insertion instead, and never let "smooth" mean "clobbered the project name."

rec 3 — Reuse the already-built, already-unit-tested `MarkdownComment` `StampSyntax` (src/fleet/mod.rs:686) — do NOT fork a fourth stamp/strip/verify path; the whole point of S142's syntax parameter was to make S143 a small wiring step, and a duplicate is the exact drift `--sync-fleet` exists to close.

rec 4 — Body-scope the classify/rewrite: `UpToDate` = body matches canonical body, `StaleRender` = body stamp self-verifies, `Drifted` = body edited OR no boundary/stamp; the upgrade must rewrite ONLY the body region and preserve the header bytes above the boundary verbatim, asserted byte-for-byte.

rec 5 — Have the qa-specialist drive the constitution falsifiability fixture to RED for the right reason (a planted stale body reclassifies and refuses), keep a clean-exit-0 positive control (S134), add the explicit header-survives-byte-for-byte assertion (criterion 3), and run the LIVE fresh-`init`+immediate-sync idempotence check in a real empty dir with the real release binary (criterion 4) — the property S142's summary named as not-yet-driven end-to-end.

rec 6 — Preserve the no-churn and no-8th-command invariants: an `UpToDate` constitution is never rewritten, and the constitution rides the existing `vajra init --sync-fleet` flag surface (max 7 top-level commands) — confirm `CONSTRAINTS.yaml` stays out (no canonical), do not reopen it.

rec 7 — Budget every dispatch TIGHT on the named files only (this prompt, DECISION-007's S141/S142 addenda, session-142-summary.md, src/cli/init.rs:80-233 + 948-1011, src/fleet/mod.rs:662-870) — never "read the repo"; the three-required crew is affordable precisely because each brief is a fraction of S134's ~6M-raw-per-dispatch cost.

## Handoff Delta
- `+` new: first tech-lead handoff for this session (6553 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
