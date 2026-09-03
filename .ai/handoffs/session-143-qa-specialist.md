---
role: qa-specialist
session: 143
agent: claude-code-subagent (verified: toolu_01HptvnM16UfM1moUM7GjCYd)
source-sha: 62bc3918e6a244d3e50bd77a8275444838561c0c6af572527dd35f80fb829c2c
captured: 2026-09-03T15:01:22Z
cost_usd: null
---

# Qa-specialist handoff — session 143

# QA Evidence Brief — Session 143 (constitution joins the smooth upgrade)

All commands run LIVE against the real release binary in /Users/suman/playground/vajra.

## Real exit codes (observed, not claimed)

- `cargo test --lib` → 468 passed, 0 failed (now 469 after the added missing-constitution test) — exit 0.
- `bash scripts/verify-session-143.sh` → 12 passed, 0 failed, RESULT: PASS, exit 0 (now 13 with the added check).
- `bash scripts/fixture-session-143.sh` → 9 passed, 0 failed, RESULT: PASS, exit 0.

## Classification of every verify check — 0 hollow

9 execute-based (cargo test / real binary), 1 nested (the fixture — all 9 of ITS checks drive the real
binary), 2 structural greps (`source-has-boundary-wiring`, `decision-007-s143-addendum` — assert
architecture / a recorded design decision, NOT behavior-via-string). No check greps source for a
message/flag and treats finding it as proof the feature works. Hollow count: 0. The behavioral core
claim (header preserved byte-for-byte; boundaryless refused) is carried by real unit tests + a live
binary round-trip + the nested fixture.

## Falsification — the suite BITES (fired, then reverted)

Broke the core property directly: in `write_target` boundary branch, replaced
`format!("{}{}", &on_disk[..idx], item.canonical)` with `item.canonical.clone()` (clobber the header).
Rebuilt release, ran the fixture → HDR and MIG went RED for the exact right reason (header clobbered),
fixture 7/9 exit 1. The stamp-verification cases (RRS/EDT) and NeedsBoundary (NB) stayed green — they
never reach write_target. Then `git checkout -- src/cli/init.rs`, rebuilt, re-ran → 9/9 exit 0. Tree
byte-clean (`git diff --stat src/` empty). Confirms HDR/MIG are load-bearing, not decorative.

## Recommendations

rec 1 — Add coverage for the ABSENT-constitution path (a deleted `.ai/AGENTS.md`): sync must warn "run
`vajra init`", skip it, and NOT write a headerless body, while roles/hooks still sync (exit 0). That
Missing→boundary branch had zero coverage in either the unit tests or the two scripts.

rec 2 — Add a falsification plant for a DOUBLE-sentinel file (the sentinel appearing in the header AND as
the real boundary) to pin `find`-first-occurrence as the intended contract; today nothing distinguishes
"split at first" from "split at last".

rec 3 — Keep `source-has-boundary-wiring` and `decision-007-s143-addendum` labeled `struct`, never
promoted to `exec` — they are honest structural/record greps; the behavior must stay proven by the
unit/live/nested checks (as it is today).

rec 4 — Consider making the constitution write atomic (temp file + rename) so an interrupted
`--sync-fleet` can never leave a half-written or headerless constitution. Current `fs::write` bails
before writing on a missing sentinel (good), but still does a non-atomic overwrite once it commits.

No blocking QA defect: all three suites pass at their real exit codes, 0 hollow, and the falsification
proves the header-preservation assertions bite.

## Handoff Delta
- `+` new: first qa-specialist handoff for this session (3027 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
