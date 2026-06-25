# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
`session-06-align-vision` — vision alignment pass.

## Active PRs
None (no remote configured).

## What Currently Works
- `vajra claude` launches Claude Code with hook injection and prints a receipt on exit.
- `vajra next` prints the `.ai/` handoff packet + VISION.md + prompt pointer (read-only).
- Compression engine + 4 heuristics (cargo, git, npm, pytest) — tests pass against fixtures.
- Meter parses session JSONL and prints honest cost breakdown — tests pass against fixtures.
- All tests green: `cargo test`, `cargo clippy`.

## What Does NOT Work Yet
- `vajra next` does not advance the workflow — it only dumps the packet.
- `vajra init`, `vajra verify`, `vajra check` do not exist as CLI commands.
- Settings injection (`--settings` additive behavior) has never been proven in a full live session.
- Only Claude Code is wired — no second agent launcher exists.
- No installer or release pipeline.

## What Is In Progress
- Session 06: aligning all docs and roadmap to the vendor-neutral, workflow-first vision.

## Cost Tracking
- Session 00: $0.00 (bootstrap, no API calls)
- Session 01: $0.00 (no API calls)
- Session 02: $0.00 (no API calls)
- Session 03: $0.00 (no API calls)
- Session 04: $0.00 (local dev + validation only)
- Session 05: $0.00 (audit only)
- Cumulative: $0.00
