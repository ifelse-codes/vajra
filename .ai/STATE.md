# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S08 complete, S09 not yet started).

## Active PRs
None (no remote configured).

## What Currently Works
- `vajra init` scaffolds `.ai/` + hooks + cross-agent pointers (16 files, interactive, idempotent).
- `vajra claude` launches Claude Code with hook injection and prints a receipt on exit.
- `--settings` injection is additive — proven in Session 07.
- `vajra next` prints the `.ai/` handoff packet + VISION.md + prompt pointer (read-only).
- Compression engine + 4 heuristics (cargo, git, npm, pytest) — tests pass against fixtures.
- Meter parses session JSONL and prints honest cost breakdown — tests pass against fixtures.
- Demo scripts formalized in CONSTRAINTS.yaml and session loop.
- All tests green: `cargo test` (24 tests), `cargo clippy`.

## What Is Broken
- `vajra next` does not advance the workflow — it only dumps the packet.
- `vajra check` does not exist as a CLI command.
- Only Claude Code is wired — no second agent launcher exists.
- No installer or release pipeline.

## What Is In Progress
- Nothing — between sessions.

## Cost Tracking
- Session 00–05: $0.00 (no API calls)
- Session 06: $0.00 (docs only)
- Session 07: ~$0.46 (3 test runs via `vajra claude -p`)
- Session 08: ~$0.00 (no API calls — code session)
- Cumulative: ~$0.46
