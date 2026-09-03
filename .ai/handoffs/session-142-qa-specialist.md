---
role: qa-specialist
session: 142
agent: claude-code-subagent (verified: toolu_019fYWTAip1tUVYtJ4g6mUaJ)
source-sha: f1aebd60a36a04009472ae82aa8dc5425e1e90873384f04df78f82067ac43cd0
captured: 2026-09-03T05:41:11Z
cost_usd: null
---

# Qa-specialist handoff — session 142

# QA Evidence Brief — Session 142 (independent execution + classification)

## Suites RAN LIVE — real exit codes
- `bash scripts/verify-session-142.sh` → exit 0, 11 passed / 0 failed (PASS).
- `bash scripts/fixture-session-142.sh` → exit 0, 9 passed / 0 failed (PASS).
- `cargo test --lib` → exit 0, 460 passed / 0 failed / 0 ignored.

Verify per-check all PASS: unit-stamp-round-trips-per-file-type, unit-stamp-inverse-and-falsifiable,
unit-hooks-no-fill-placeholders, unit-scaffolded-hooks-stamped-uptodate, unit-classify-four-states,
falsifiability-fixture-hook-four-states (nested), live-hook-round-trip, live-stamp-inert-hook-still-runs,
source-has-shell-stamp-wiring, decision-007-s142-addendum, seven-commands-no-eighth.
Fixture 9 cases all PASS: POS, UTD, STA, RRS, EDT, RUN, DRF, OVR, END.

## Classification of the 11 verify checks
- EXECUTE-BASED — 8: the five unit-* (cargo test against real product), live-hook-round-trip +
  live-stamp-inert-hook-still-runs (spawn the REAL release binary in a throwaway dir, assert on
  file output/mtime/exit), seven-commands-no-eighth (runs vajra --help, counts commands).
- STRUCTURAL grep — 2: source-has-shell-stamp-wiring (asserts architecture: StampSyntax/ShellComment/
  SYNC_HOOKS/render_stamped_hook/syntax-aware classify), decision-007-s142-addendum (design-record
  existence — exactly what criterion 5 claims). Neither is hollow.
- BEHAVIORAL SOURCE GREP (HOLLOW) — 0. None to name.
- NESTED — 1: fixture-session-142.sh; its 9 cases all drive the real binary, 0 hollow. The "0 hollow"
  floor holds for the whole run. The two structural greps' behavior is ALSO covered by execute-based
  unit tests + live round-trips, so nothing rests on the greps alone.

## Falsification — the fixture BITES
Inserted at the top of render_stamp_verifies (src/fleet/mod.rs):
`if matches!(syntax, StampSyntax::ShellComment) { return false; }` — a correctly-stamped shell hook can
never verify. Rebuilt release. `bash scripts/fixture-session-142.sh` → exit 1, 8 passed / 1 failed. The
failing case was STA: the correctly-stamped stale hook was reclassified StaleRender→Drifted and REFUSED
("DRIFT .ai/hooks/hook-publish-guard.sh ... NOT touched") — exactly the load-bearing property. The other
8 cases correctly stayed green (unstamped/edited/foreign refused regardless). Restored via
`git checkout src/fleet/mod.rs`, rebuilt; `git status --porcelain src/ scripts/` empty; fixture re-run
9 passed / 0 failed exit 0. Nothing committed.

## What this green suite did NOT exercise
- .ai/AGENTS.md (the filled constitution) — the S143 follow-up, NOT stamped/upgraded/tested here.
- CONSTRAINTS.yaml left-untouched is recorded in the addendum but not execute-verified by a live check.
- Only 1 hook stands in for the type in the four-state proof (fixture mutates hook-publish-guard.sh;
  live mutates hook-session-guard/commit-guard); a per-hook exhaustive upgrade is not run.
- MarkdownComment stamp exists + is unit-tested for round-trip but has no falsifiability fixture.
- No real Claude/agent invocation, no vajra next pipeline, no cost/receipt path — scaffold plumbing only.

## Recommendations
rec 1 — Add a live/fixture assertion that --sync-fleet leaves CONSTRAINTS.yaml and any pre-existing
.ai/AGENTS.md byte-unchanged, so "user-owned / deferred" is execute-verified, not only recorded.
rec 2 — Extend the four-state fixture (or a unit case) to cover MarkdownComment with the same
red-on-broken-stamp falsification, matching ShellComment coverage.
rec 3 — Before S143 wires the filled .ai/AGENTS.md into --sync-fleet, add a fixture that a hand-edited
AGENTS.md is REFUSED — a filled template is where a stamp-over-filled-content scheme most likely
misclassifies; QA should see that fixture go red before the feature lands.

## Handoff Delta
- `+` new: first qa-specialist handoff for this session (3813 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
