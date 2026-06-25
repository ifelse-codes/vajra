# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
`session-07-live-claude-proof` — live proof of `vajra claude`.

## Active PRs
None (no remote configured).

## What Currently Works
- `vajra claude` launches Claude Code with hook injection and prints a receipt on exit.
- **`--settings` injection is additive** — proven in Session 07 with stream-json hook event capture.
- `vajra next` prints the `.ai/` handoff packet + VISION.md + prompt pointer (read-only).
- Compression engine + 4 heuristics (cargo, git, npm, pytest) — tests pass against fixtures.
- Meter parses session JSONL and prints honest cost breakdown — tests pass against fixtures.
- All tests green: `cargo test`, `cargo clippy`.

## What Is Broken
- `vajra next` does not advance the workflow — it only dumps the packet.
- `vajra init`, `vajra verify`, `vajra check` do not exist as CLI commands.
- Only Claude Code is wired — no second agent launcher exists.
- No installer or release pipeline.

## What Is In Progress
- Session 07: live proof complete, awaiting user pick for session 08.

## Cost Tracking
- Session 00–05: $0.00 (no API calls)
- Session 06: $0.00 (docs only)
- Session 07: ~$0.46 (3 test runs via `vajra claude -p`)
- Cumulative: ~$0.46
