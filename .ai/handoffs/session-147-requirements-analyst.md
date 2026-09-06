# Session 147 — Requirements-Analyst Handoff (payload: S148 acceptance criteria)

## Proposed S148 Acceptance Criteria

AC1 — Detection triggers on known test-runner output: cargo test, pytest, jest — one fixture per framework; unit tests verify each.

AC2 — Summary line preserved verbatim in compressed output (e.g., `test result: ok. N passed` for cargo; `N passed in Xs` for pytest).

AC3 — FAIL/ERROR/PANIC lines not dropped: every line matching the framework's failure-marker pattern appears unchanged in the hook's return value.

AC4 — Truncation notice present and well-formed: return value contains exactly one line matching the canonical notice format (to be specified in the prompt).

AC5 — Passthrough on non-matching output: byte-level diff confirms input == output.

AC6 — S144 replay produces a positive token reduction: verify script reports `tokens before: N  tokens after: M` where M < N, exits 0.

AC7 — All-pass run produces short output: compressed output is at most [threshold] lines (threshold to be defined in prompt).

AC8 — `cargo test` exits 0 across detection, truncation, failure-preservation, and passthrough paths.

## Gaps the S148 prompt must resolve (7)

Gap 1 — Pattern definition is prose, not spec: needs exact regex or normative fixture for cargo/pytest/jest detection trigger.

Gap 2 — Truncation notice format unspecified: AC4 cannot be a script assertion without the exact format string.

Gap 3 — S144 JSONL replay file path unknown: may not be committed to the repo; AC6 needs a real path.

Gap 4 — Green-run output cap is illustrative ("5–20 lines"), not normative: AC7 needs a hard number.

Gap 5 — FAIL/ERROR/PANIC line-matching rule is ambiguous: cargo=FAILED, jest=FAIL, pytest=FAILED — case-sensitive? substring?

Gap 6 — No truncation floor: without a minimum input line count, an implementation could truncate trivially small outputs.

Gap 7 — "Before claiming savings" is advice, not a gate: the prompt must state whether zero/negative token reduction blocks or is informational.
