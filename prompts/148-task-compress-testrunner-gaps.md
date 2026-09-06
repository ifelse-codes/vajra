# Session 148 — Close the Test-Runner Compression Gaps

**Type:** CODE (Rust `src/` changes)
**Branch:** `session-148-compress-testrunner-gaps`
**Session:** 148

**Sourced from S147 quiet-roles audit. Changed advice from five roles incorporated below.**

---

## Context

The existing PostToolUse compression hook already covers cargo test, pytest, and npm test/npm run test via `src/engine/heuristic/cargo.rs`, `pytest.rs`, and `npm.rs`. Two gaps remain that the S147 demo-producer identified by reading the heuristic dispatch table directly:

- **Gap A:** bare `jest` command is not in the dispatch table (only `npm test`/`npm run test` are detected)
- **Gap B:** failing test output in the 30–399 line range passes through unchanged for all heuristics (`FAIL_PASSTHROUGH_CAP = 400`; `preserves_failure_signal()` defaults to `false`), meaning a medium-size failing run is not compressed even though failure lines can be isolated

S148 closes one or both gaps. Before implementing, Step 1 confirms the root cause by measuring the S144 JSONL transcript — the plan-advisor asserted context growth over 129 turns is the cost driver, and the researcher confirmed this is plausible but unverified. The measurement gates the savings claim.

---

## Goal

1. Measure where the $11.74 went in S144 by inspecting the S144 JSONL per-turn `usage` fields.
2. Close Gap A (bare `jest` detection) and/or Gap B (fail-path for 30–399 line outputs) in the existing hook, with a token-reduction measurement on the S144 transcript.

---

## Design

`design-significant: yes`

Covering record: `docs/adr/0003-settings-injector-and-compression-heuristics.md` — ADR-0003 specifies the heuristics contract (LINE_CAP, FAIL_PASSTHROUGH_CAP, per-tool contracts). Changes to the heuristic dispatch table and passthrough thresholds are within ADR-0003 scope; a deviation must cite the ADR and record the reason.

Rejected alternative: add truncation as a new hook outside the existing engine — rejected. ADR-0003 established the single-engine architecture; a second hook duplicates the adapter wiring and breaks the composability invariant.

---

## Acceptance Criteria

*(Sourced from S147 requirements-analyst — 8 criteria, 7 gaps resolved below)*

1. **Detection triggers on known test-runner output.** The PostToolUse hook receives tool output containing the canonical summary line of `cargo test`, `pytest`, or `jest` (bare) and returns a compressed value. One unit-test fixture per framework.

2. **Summary line preserved verbatim.** The compressed return value contains the framework's own pass/fail count summary line (e.g., `test result: ok. N passed; 0 failed` for cargo; `N passed in Xs` for pytest; `Tests: N passed, 0 failed, N total` for jest) copied verbatim from the input.

3. **FAIL/ERROR/PANIC lines not dropped.** Every line in the input that contains `FAILED` (cargo/pytest) or `✕` / `● ●` (jest) appears in the return value unchanged. Pattern: case-sensitive substring match on `FAILED`, `PANIC`, `panicked at`, or `✕` — one or more of these in any line is sufficient to preserve the line verbatim.

4. **Truncation notice present and well-formed.** When the hook drops any lines, the return value contains exactly one line matching: `[vajra] N lines folded — set VAJRA_RAW=1 to see full output`, where N is the count of dropped lines.

5. **Passthrough on non-matching output.** When the hook receives tool output that does not contain any test-runner summary pattern, the return value is byte-identical to the input. Verified by `diff` on a non-test-runner fixture (e.g., a file listing or compiler error output).

6. **S144 JSONL replay measurement.** `scripts/verify-session-148.sh` reads the S144 session JSONL file (path: `~/.claude/projects/*/chitra/*/session.jsonl` or the closest equivalent on the local machine — the session resolves the path and records it in the verify script), applies the new hook rules to all Bash tool outputs in the replay, and prints `tokens before: N  tokens after: M`. This check exits 0 if M < N (positive reduction) and exits 1 if M >= N (no reduction or regression). If the S144 JSONL file is not available on the local machine, this AC is recorded as CANNOT-EVALUATE (not a blocking failure, but must be stated plainly — not silently skipped).

7. **Truncation floor: passthrough below 20 lines.** The hook does not truncate test-runner output shorter than 20 lines, even if the pattern matches. This prevents vacuously compliant truncation of already-short outputs.

8. **`cargo test` exits 0.** All existing tests pass after the change, plus new unit tests covering detection, truncation, failure-line preservation, and passthrough for each of the three frameworks.

---

## Gap Resolutions (S147 requirements-analyst — 7 gaps)

| Gap | Resolution |
|---|---|
| 1 — pattern not spec | Detection pattern: presence of the framework's canonical summary line in the tool output (cargo: `test result:`; pytest: `passed in`; jest bare: `Tests:.*passed`) |
| 2 — notice format | `[vajra] N lines folded — set VAJRA_RAW=1 to see full output` |
| 3 — S144 JSONL path | Resolve at implement time; record in verify script; mark CANNOT-EVALUATE if not available |
| 4 — green-run cap not normative | Maximum 10 lines for a zero-failure run (includes summary line + truncation notice + up to 8 preserved lines) |
| 5 — FAIL line matching rule | Case-sensitive substring: `FAILED`, `PANIC`, `panicked at`, `✕` — any of these in a line triggers preservation |
| 6 — no truncation floor | Floor: 20 lines — passthrough below this regardless of pattern match |
| 7 — "measure before claiming" not gated | AC6 is a hard gate: M < N required for exit 0; CANNOT-EVALUATE allowed if JSONL unavailable |

---

## Measurement Step (First Action)

**Before writing any Rust code**, inspect the S144 session JSONL transcript:

```bash
# Find S144 chitra JSONL
ls ~/.claude/projects/*/chitra/*/session.jsonl 2>/dev/null | head -5
```

If found: count per-turn token usage (`usage.input_tokens` + `usage.output_tokens` across all turns) and identify the 5 largest individual tool outputs by character count. This establishes whether the plan-advisor's root cause (context growth, not test-runner tokens) is confirmed. If the S144 JSONL is not available, record "JSONL not available locally" and proceed — but do NOT claim a cost-reduction number. The measurement must precede any savings assertion.

---

## Guardrails

- No changes outside `src/engine/heuristic/` and `src/adapter/` — the engine boundary is ADR-0003's jurisdiction
- Never drop a line containing `FAILED`, `PANIC`, `panicked at`, or `✕` — correctness-first (S36 principle)
- If Gap B (fail-path) is addressed, `preserves_failure_signal()` must return `true` for the modified heuristic — the passthrough cap then does not apply
- S144 JSONL measurement must happen before any savings claim, even an informal one
- The demo script must anchor its before/after to the specific gap S148 closes — not to already-working cargo truncation (demo-producer rec 1)

---

## Plan

*(To be written after tech-lead dispatch — following S147 plan-advisor template)*
