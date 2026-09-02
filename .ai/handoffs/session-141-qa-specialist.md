---
role: qa-specialist
session: 141
agent: claude-code-subagent (verified: toolu_011GUPPRDGMdNdPNVUzaK9oT)
source-sha: 4ddf000e192674510ccc6705ece564ab634909c86dc1ba5d6078e3c094adeb96
captured: 2026-09-02T14:01:13Z
cost_usd: null
---

# Qa-specialist handoff — session 141

QA Evidence Brief — Session 141 (best install + upgrade-in-place).

Exit codes (live, against the pre-built release binary):
- bash scripts/verify-session-141.sh → exit 0, "session 141 verify: 10 passed, 0 failed", RESULT: PASS.
- bash scripts/fixture-session-141.sh → exit 0, "fixture-141: 8 passed, 0 failed".

Check-class tally (independent classification of verify-session-141.sh — agrees with the script's own):
- EXECUTE-BASED — 7: the four cargo-test runs, live-real-dir-round-trip, live-stamp-in-frontmatter-not-body, seven-commands-no-eighth.
- STRUCTURAL grep (asserts architecture, NOT hollow) — 2: source-has-fourth-state-and-stamp (asserts StaleRender + render_stamp_verifies wiring + RENDER_STAMP_KEY exist; the behaviour is separately execute-tested), decision-007-s141-addendum (asserts a design RECORD exists).
- BEHAVIORAL SOURCE GREP (hollow) — 0. No hollow checks in this suite.
- NESTED — 1: falsifiability-fixture-four-states; its own checks all drive the real binary (zero source greps), so 0 hollow holds across both suites.

Fixture goes RED for the right reason — confirmed: RRS (same body UNSTAMPED → exit 1 refused) and EDT (stamped-but-edited → exit 1 refused) prove the stamp is load-bearing (only the stamp differs between STA's auto-upgrade and RRS's refusal); POS and END positive controls assert a clean exit 0 (S134 bar).

Falsification — broke the product and observed a real RED: bypassed the StaleRender arm of classify_fleet_file (routed StaleRender→Drifted), cargo build --release, re-ran the fixture → "STA stale render did not auto-upgrade (exit 1) FAIL", fixture-141: 7 passed, 1 failed, exit 1. Then git checkout -- src/cli/init.rs && cargo build --release; fixture GREEN again 8/8 exit 0; git status --short src/ empty. Nothing committed.

What the suite does NOT exercise: it proves the sync/stamp/classify plumbing end to end, but never proves a live coding agent actually loads and is dispatched by the rendered role files — the "dispatch untouched" claim rests on a frontmatter-placement grep of one role's output (researcher), not an actual agent run.

rec 1 — Record in sessions/session-141-review.md (and summary) that this suite verifies the render/stamp/upgrade plumbing but exercises NO live agent dispatch; the "stamp is inert, dispatch untouched" claim is proven only by stamp placement in one role's output, not by an agent consuming the file.
rec 2 — The falsification break only reddens the STA plant; RRS/EDT stay green under it (routing StaleRender→Drifted keeps them refused). An inverse break (make render_stamp_verifies always true) would show RRS/EDT fail in their own direction, giving all four states a demonstrated red.
rec 3 — Both live checks and the fixture mutate only the researcher role; the per-role round-trip/inert property is unit-tested for ALL roles but only spot-checked live on one. Consider rotating/parameterizing the live role so a stamp bug isolated to a non-researcher template would not slip past the live layer.

## Handoff Delta
- `+` new: first qa-specialist handoff for this session (3039 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
