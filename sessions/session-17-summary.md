# Session 17 — Pre-Run Cost Estimate

## Goal
Add `vajra estimate` command that predicts token spend before running a session.

## Goal achieved?
Yes. `vajra estimate` reads `.ai/` context files, estimates input tokens (chars/4), projects output tokens (3:1 ratio), prices against compiled-in Opus rates, and warns if estimate exceeds `budget.cap_usd`.

## Evidence
- PR [#6](https://github.com/ifelse-codes/vajra/pull/6) — merged, CI green (macOS + Ubuntu)
- 77 unit tests pass (7 new for estimate module)
- `scripts/verify-session-17.sh` — 11 checks, all green
- Live output on this repo: `~$1.93 (8.0k input + 24.1k output tokens)`
- ADR-0005 documents methodology and flags output ratio as low-confidence

## What was built
- `src/cli/estimate.rs` — estimate command (130 lines + 100 lines tests)
- `src/meter/mod.rs` — exposed `pricing_for` as `pub(crate)`
- `src/main.rs` — wired `Estimate` variant + help text
- `docs/adr/0005-pre-run-cost-estimate.md` — design record

## Known limitations
- Output token ratio (3:1) is a placeholder heuristic, not validated against real session data
- Assumes Opus pricing — no model detection from Claude config
- Does not factor in cache hit rates or historical session costs

## Commits
1. `a6f6cc6` — estimate module + pricing exposure (3 files)
2. `33329e0` — wire into CLI dispatch (1 file)
3. `f76479b` — ADR-0005 + knowledge update (3 files)
4. `865ed76` — verify + demo scripts (2 files)
5. `a357f9e` — cargo fmt fix (1 file)
