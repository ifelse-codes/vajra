# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S17 complete, S18 not yet started).

## Active PRs
None — PR #6 (S17) merged.

## What Currently Works
- `vajra init` scaffolds `.ai/` + hooks + cross-agent pointers (16 files, interactive, idempotent). Prompts for maturity level.
- `vajra claude` launches Claude Code with hook injection and prints a receipt on exit.
- `--settings` injection is additive — proven in Session 07.
- `vajra next` prints the `.ai/` handoff packet + VISION.md + prompt pointer (read-only).
- `vajra next --advance` bumps SESSION + SESSION-BOOT.md + prompt pointer. L3 skips confirm, L1/L2 require it.
- `vajra next` e2e loop proven: init → next → work → advance → repeat across 3 sessions.
- `vajra check` runs 10 drift-detection checks. L1 = WARN (exit 0), L2/L3 = FAIL (exit 1).
- `vajra estimate` predicts token spend before running a session. Chars/4 input, 3:1 output ratio, Opus pricing, budget warning.
- Maturity levels L1/L2/L3 parsed from `maturity:` in CONSTRAINTS.yaml (default L2).
- Hook scripts respect maturity — L1 = warn-only, L2/L3 = can block.
- Compression engine + 4 heuristics (cargo, git, npm, pytest) — tests pass against fixtures.
- Meter parses session JSONL and prints honest cost breakdown — tests pass against fixtures.
- Budget guard enforces `budget.cap_usd` from CONSTRAINTS.yaml after each session (warn or kill mode).
- SIGPIPE handled gracefully — piping vajra output through head/grep works.
- GitHub Actions CI (test+clippy+fmt on macOS+Linux) — green.
- GitHub Actions release workflow (tag-triggered, 3 targets: macOS arm64/x86_64 + Linux x86_64).
- `cargo package` produces publish-ready crate as `vajractl`.
- Remote configured: `origin` → `https://github.com/ifelse-codes/vajra`.
- All tests green: `cargo test` (77 unit + 26 integration), `cargo clippy`.
- Legacy `vajra launch` alias removed (S16).

## What Is Broken
- Only Claude Code is wired — no second agent launcher exists.
- `vajra estimate` output ratio (3:1) is unvalidated placeholder — treat as order-of-magnitude.

## What Is In Progress
- Nothing — between sessions.

## Cost Tracking
- Session 00–05: $0.00 (no API calls)
- Session 06: $0.00 (docs only)
- Session 07: ~$0.46 (3 test runs via `vajra claude -p`)
- Session 08–16: ~$0.00 (code/no-code sessions, no API calls)
- Session 17: ~$0.00 (code session, no API calls)
- Cumulative: ~$0.46
