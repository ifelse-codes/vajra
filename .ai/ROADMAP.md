# Vajra — Working Roadmap

**Agent-facing backlog. Updated at every closeout.**

## Where We Are

| Field | Value |
|---|---|
| Today | 2026-06-18 |
| Current phase | Phase 0 — Foundation |
| Completed sessions | 2 |
| Active session | Session 02 — Complete |
| Next session | Session 03 — pending option selection |

## Phase 0 — Foundation

| Workstream | Target session(s) | Status |
|---|---|---|
| Agent protocol bootstrap | Session 00 | [x] complete |
| Cargo project scaffold | Session 01 | [x] complete |
| Engine trait + types + StubEngine | Session 01 | [x] complete |
| Compression heuristics (cargo, git, pytest, npm, generic) | Session 02 | [x] complete |
| DefaultEngine dispatch + pre-rules | Session 03 | [ ] planned |
| ClaudeCodeHookAdapter + wire types | Session 03–04 | [ ] planned |
| CLI hook + launcher | Session 04 | [ ] planned |
| Meter / receipt | Session 04–05 | [ ] planned |
| Bench fixtures + tripwire | Session 05 | [ ] planned |
| Session 05 NO-CODE audit | Session 05 | [ ] planned |

## Phase 1 — v1 Ship

| Workstream | Target session(s) | Status |
|---|---|---|
| Integration tests + end-to-end | Session 06–07 | [ ] planned |
| Measurement harness (bench/) | Session 07–08 | [ ] planned |
| Installer (`curl | bash`) | Session 08 | [ ] planned |
| OSS release prep | Session 09–10 | [ ] planned |

## Phase 2 — Governance / Audit Ledger (v2+)

| Workstream | Target session(s) | Status |
|---|---|---|
| Cross-agent shim rail | TBD | [ ] planned |
| Agent-trace format adoption | TBD | [ ] planned |
| Git-native tamper-evident ledger | TBD | [ ] planned |
| Policy engine | TBD | [ ] planned |

## What Currently Works

- Cargo project scaffold (`Cargo.toml`, `src/`, `tests/`)
- `Engine` trait with `compress`/`decompress` interface
- Core types: `CompressionAlgorithm`, `CompressionLevel`, `Strategy`
- CLI skeleton with subcommands (`compress`, `decompress`, `benchmark`)
- G3 conformance test
- Compression heuristics for cargo, git, pytest, npm, and generic workloads
- DefaultEngine wired to heuristics with fail-open catch_unwind

## Next Session

Session 03: Pick compression option (A/B/C/D) from `sessions/session-02-summary.md`, then read `prompts/03-task-<slug>.md`.

## Rules For This Document

1. Update at every closeout.
2. Session numbers aspirational, not contracts.
3. NO-CODE audit sessions at 05, 10, 15, 20, 25.
4. New workstreams emerging mid-flight — add here with a discussion note.