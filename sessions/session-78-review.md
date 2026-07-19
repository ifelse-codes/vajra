# Session 78 — Independent cold fidelity review

> Produced by a separate adversarial pass (general-purpose subagent) fed only the prompt + the diff
> (`git diff 074f011..HEAD`), explicitly barred from the builder's summary (DECISION-002 /
> DECISION-003). The reviewer ran `cargo test --lib`, clippy, fmt, `verify-session-78.sh`,
> `demo-session-78.sh`, and inspected the live-run artifacts itself. Verdict recorded verbatim
> below; the attestation binds it to the delivered code.

**Verdict:** ACCEPT
**Review-Inputs-SHA:** daabaa7af501dd70cffebf9fa19f89ef76db586f6f3a7b6c6522b7c833debc9f

> Attestation = `sha256(prompt ‖ delivery-diff)`, the delivery diff being the non-excluded committed
> change (`src/cli/launch.rs` + `src/meter/mod.rs` + the two S78 scripts). Bar-raising, not
> tamper-proof (DECISION-003): it kills a recycled / stale / delivery-decoupled verdict, not builder
> authorship.

## Per-requirement verdict table (reviewer's, verbatim)

| # | Criterion | Status | Evidence the reviewer re-verified |
|---|-----------|--------|-----------------------------------|
| 1 | Headless `-p` result line's `total_cost_usd` → authoritative receipt headline | SHIPPED | `is_headless()` gates `Stdio::piped()`; `tee_and_capture` → `extract_result_cost` → `apply_captured_cost` in `print_receipt` before `billed_dollars`/`format_receipt`. Live proof: `live-receipt.stderr.txt` shows `$0.0277 total` (session `45f4fe2`) matching `live-result-line.txt`'s `total_cost_usd:0.0277055`; the on-disk transcript carries no cost, so the headline can only be the captured stream. |
| 2 | Interactive / no-result unchanged from S77 (honest "no authoritative cost available") | SHIPPED | Non-headless path keeps `Stdio::inherit()`, `captured_cost=None`, `apply_captured_cost(None)` a no-op. `s76_fable_headless_…` and `missing_authoritative_…` still green; demo BEFORE panel prints the honest fallback live via `cargo run -- meter`. |
| 3 | Capture never corrupts user-visible stdout (tee, never swallow) | SHIPPED | `tee_and_capture` writes every chunk `write_all`+`flush` byte-for-byte while copying to `buf`. Only stdout piped; stdin/stderr inherited → single pipe, drain-to-EOF-then-`wait()` → no deadlock. `live-result-line.txt` shows the result line intact on stdout. |
| 4 | Regression from a REAL captured `type:"result"` fixture; no-result path honest; suite green | SHIPPED | `s78_real_captured_result_stream_…` reads the committed fixture; fixture is genuinely real (real thinking block + signature + `request_id`; result line `total_cost_usd:0.027687499999999997`; provenance `claude -p … --model haiku`, CC 2.1.183). `cargo test --lib` = **256 passed / 0 failed**. |
| 5 | `verify-session-78.sh` proves both paths; `demo-session-78.sh` shows before→after with 4 markers | SHIPPED | verify = **15/15 GREEN**; demo emits exactly 4 markers (`header`, `before_after`, `cases`, `summary_table`) with a live S77→S78 before/after. |

## Bugs / risks (reviewer, verbatim)
- **None material.** Two non-material notes: (a) in `print_receipt`, if `find_session_jsonl` returns
  `None` but a cost was captured, it returns the captured cost for the budget check without printing
  a `$… total` receipt line — an edge, not a lie, no regression vs S77. (b) `extract_result_cost`
  requires valid UTF-8; stream-json is always UTF-8 JSON, so it cannot miss a real result line in
  practice.
- Adversarial probes: `apply_captured_cost` fills only when `authoritative_dollars` is `None` (a
  transcript's own figure is never overridden); non-`result` lines with a cost-shaped field are
  ignored; `--output-format json` single-object output handled by the second branch. All covered by
  tests.

## Scope check (reviewer, verbatim)
One story (recover authoritative cost on headless). No new command. Pricing table untouched (zero
`ModelPricing` changes). No station changes. Stdout never swallowed. Only the five declared file
groups changed. Clean. `cargo fmt --check` exit 0 · clippy clean · `cargo test --lib` 256/256 ·
verify 15/15 · demo 4/4.

## Reviewer's justification (verbatim)
> Every criterion is SHIPPED with independently re-verified evidence, including genuine live-run
> artifacts (two distinct real headless captures) that prove the recovery path fires end-to-end, and
> a fixture that is authentic captured data rather than fabrication. The build is clean on all gates
> and the change stayed strictly within one story — no new command, no pricing-table edits, no
> station changes, and stdout is teed byte-for-byte rather than swallowed.
