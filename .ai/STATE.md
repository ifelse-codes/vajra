# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S13 complete, S14 not yet started).

## Active PRs
[PR #1](https://github.com/ifelse-codes/vajra/pull/1) — S13 installer (CI green, pending merge).

## What Currently Works
- `vajra init` scaffolds `.ai/` + hooks + cross-agent pointers (16 files, interactive, idempotent).
- `vajra claude` launches Claude Code with hook injection and prints a receipt on exit.
- `--settings` injection is additive — proven in Session 07.
- `vajra next` prints the `.ai/` handoff packet + VISION.md + prompt pointer (read-only).
- `vajra next --advance` bumps SESSION + SESSION-BOOT.md + prompt pointer, interactive confirm, main guard.
- `vajra next` e2e loop proven: init → next → work → advance → repeat across 3 sessions.
- `vajra check` runs 10 drift-detection checks and prints pass/fail + readiness score.
- Compression engine + 4 heuristics (cargo, git, npm, pytest) — tests pass against fixtures.
- Meter parses session JSONL and prints honest cost breakdown — tests pass against fixtures.
- Demo scripts formalized in CONSTRAINTS.yaml and session loop.
- Budget guard enforces `budget.cap_usd` from CONSTRAINTS.yaml after each session (warn or kill mode).
- SIGPIPE handled gracefully — piping vajra output through head/grep works.
- GitHub Actions CI (test+clippy+fmt on macOS+Linux) — green on first run.
- GitHub Actions release workflow (tag-triggered, 3 targets: macOS arm64/x86_64 + Linux x86_64).
- `cargo package` produces 35 KiB crate, publish-ready as `vajractl`.
- Homebrew formula template at `Formula/vajra.rb`.
- README install section with 4 methods.
- Remote configured: `origin` → `https://github.com/ifelse-codes/vajra`.
- All tests green: `cargo test` (85 tests), `cargo clippy`.

## What Is Broken
- Only Claude Code is wired — no second agent launcher exists.

## What Is In Progress
- Nothing — between sessions.

## Cost Tracking
- Session 00–05: $0.00 (no API calls)
- Session 06: $0.00 (docs only)
- Session 07: ~$0.46 (3 test runs via `vajra claude -p`)
- Session 08: ~$0.00 (no API calls — code session)
- Session 09: ~$0.00 (no API calls — code session)
- Session 10: ~$0.00 (no-code ground truth audit)
- Session 11: ~$0.00 (no API calls — code session)
- Session 12: ~$0.00 (no API calls — code session)
- Session 13: ~$0.00 (no API calls — code session)
- Cumulative: ~$0.46
