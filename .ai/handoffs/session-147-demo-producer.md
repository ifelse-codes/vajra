# Session 147 — Demo-Producer Handoff (payload: S148 demo proposal)

## Critical finding (read first)

The existing heuristics at `src/engine/heuristic/` ALREADY implement compression for cargo test, pytest, and npm test. S148 is NOT implementing test-runner truncation from scratch. Two gaps remain:
(a) bare `jest` command is not in the dispatch table — only `npm test`/`npm run test`
(b) fail-path for medium-size runs (30–399 lines) passes through unchanged for all heuristics (FAIL_PASSTHROUGH_CAP = 400; preserves_failure_signal() defaults to false)

S148's demo must anchor before/after to whichever gap it actually closes — not to a heuristic that already works.

## demo:header

"Session 148 — test-runner output truncation gap-close: bare `jest` detection added; an 86-line green cargo test run compresses to ~3 lines; FAIL/PANIC lines never dropped; non-test-runner passthrough unchanged."

## demo:cases (5 cases, $BIN hook with crafted JSON)

- C1: cargo test green (86 lines → <10 lines via real fixture research/compression-fixtures/raw/cargo-test.txt)
- C2: cargo test FAIL with FAIL/PANIC lines that must survive (>400 lines, enter compress branch)
- C3: pytest green (50 synthetic lines → <6 lines)
- C4: jest bare detection — the NEW behavior S148 adds (exits 1 pre-S148, should pass post-S148)
- C5: non-Bash tool_name passthrough (Write tool, same 86 lines → {} guard holds)

## demo:before_after

BEFORE: bare `jest` payload → {} (passthrough, not detected pre-S148). Show line count of raw fixture.
AFTER: bare `jest` payload → compressed output with jest summary line. Show line count reduction.

## demo:summary_table

Columns: Runner | In | Out | Saved | Status — computed from live case signals, not hardcoded.

## Key recs for S148 demo

rec 1 — Before/after must anchor to the SPECIFIC gap S148 closes (bare jest or fail-path), not to already-working cargo truncation
rec 2 — Do NOT wrap Case 4 (jest detection) in || true — must show honestly if jet detection was shipped
rec 3 — State plainly what demo does NOT prove: the $11.74 cost driver is context growth over 129 turns; this reduces per-call size, not the curve
rec 4 — Use static fixture files in research/compression-fixtures/hook-payloads/ for reproducibility
rec 5 — Summary table must be computed from live signals
