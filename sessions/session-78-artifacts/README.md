# Session 78 artifacts — recover the true $

Real evidence that the launcher now recovers the coding tool's OWN end-of-session cost on
headless runs (S78; extends ADR-0004).

- `fixtures/s78-headless-result-stream.txt` — verbatim stdout slice of
  `claude -p "Reply with exactly the single word: ok" --output-format stream-json --verbose --model haiku`
  (Claude Code 2.1.183, 2026-07-19). Its terminal `type:"result"` line carries
  `total_cost_usd`. This is the RESULT STREAM — a different artifact from the on-disk session
  transcript (cf. `../session-76-artifacts/fixtures/s76-fable-headless.jsonl`, which has no
  result line). It is the S78 regression fixture.
- `live-receipt.stderr.txt` — the receipt from a LIVE `vajra claude -p` run (debug binary). The
  headline is now a real `$… total` recovered from the teed result stream, where S77 could only
  say "no authoritative cost available".
- `live-result-line.txt` — the single `type:"result"` line as it appeared on the run's stdout,
  proving the tee passed the agent's output through untouched (criterion 3).

Two cheap haiku smoke runs, ~$0.055 total.
