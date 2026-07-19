# Session 78 — Recover the true $ (CODE) — summary

**Type:** CODE — extends ADR-0004 (meter/receipt) with a capture path in the launcher; no new
command. Founder pick **A** of the 3 ranked S77 candidates. **Closes the receipt arc: S77 stopped
the lie, S78 recovers the truth.**

## Headline
On a headless `vajra claude -p` run, the receipt now shows the coding tool's OWN end-of-session
cost as the authoritative headline — a real `$0.0277 total` in the live smoke run — where S77 could
only say *"no authoritative cost available"*. The figure is read from the terminal `type:"result"`
line of the run's stdout stream (the artifact S77 identified as the only place `total_cost_usd`
lives), not from Vajra's price list.

## What shipped
- **`src/cli/launch.rs`** — `is_headless(args)` (a `-p`/`--print` arg scan) gates a byte-level tee:
  headless runs pipe stdout, stream every byte straight through (never swallowed — criterion 3),
  and keep a copy; interactive runs keep an inherited TTY, unchanged (criterion 2). `tee_and_capture`
  drains to EOF before `wait()`; stderr stays inherited so there is no second pipe to deadlock on.
- **`src/meter/mod.rs`** — `extract_result_cost(&[u8])` reads `total_cost_usd` from the terminal
  `type:"result"` line (line-delimited stream-json; also a single `--output-format json` object);
  returns `None` for text-mode/interactive/non-JSON — never guesses from a non-result line.
  `SessionCost::apply_captured_cost` promotes a captured figure to `authoritative_dollars` (S66
  path) and drops the "no authoritative" warning, but never overrides a transcript that already
  carried its own figure.
- **Real captured fixture** `sessions/session-78-artifacts/fixtures/s78-headless-result-stream.txt`
  + live-run evidence (`live-receipt.stderr.txt`, `live-result-line.txt`) — committed before→after.

## Proof
- `cargo test --lib` **256 passed** (+7 over S77's 249: `is_headless`, 3× `extract_result_cost`,
  2× `apply_captured_cost`, the S78 real-captured-stream regression). clippy + fmt clean.
- `verify-session-78.sh` **15/15**; `demo-session-78.sh` all four `demo:<element>` markers.
- **LIVE end-to-end** (verify-skill discipline — behaviour observed, not just unit tests): a real
  `vajra claude -p … --output-format stream-json` run produced a receipt headlined `$0.0277 total`;
  the teed stdout carried the `type:"result"` line through untouched.
- **Spend:** two cheap haiku smoke runs, **~$0.055** total.

## Honest limits (disclosed)
- **Headless-only.** Interactive runs genuinely have no result stream, so they keep S77's honest
  "no authoritative cost available" — correct, not a gap (criterion 2).
- **Whole-stdout buffered in memory** for the scan. Bounded by a run's output size (typically a few
  MB); a pathologically long run buffers more. The tee streams through regardless, so the user's
  live output is unaffected — a memory note, not a correctness one.
- **Claude Code only.** Reading Codex/Grok's own end-of-session cost is future work (memory
  `vajra-receipt-pricing-from-tool`), gated with cross-agent breadth (S26/S70).
- **The stale static `claude-opus-4` rate ($15/$75 → opus-4-8 $5/$25) is untouched** — out of this
  one-story scope; a standing S79 candidate.

## Attestation
- **Review-Inputs-SHA:** `daabaa7af501dd70cffebf9fa19f89ef76db586f6f3a7b6c6522b7c833debc9f`
  (`sha256(prompt ‖ delivery-diff)`; delivery diff = `src/cli/launch.rs` + `src/meter/mod.rs` +
  the two S78 scripts). See `sessions/session-78-review.md` for the independent cold verdict.

## Coder-gate execution (plan step → landing commit)
- step 1 & 2 (capture + feed to meter) → `46b2352`
- step 3 (real-data regression) → `46b2352`
- step 4 (verify + demo) → `613f7d1`
