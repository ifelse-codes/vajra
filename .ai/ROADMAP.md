# Vajra — Working Roadmap

**Agent-facing backlog. Updated at every closeout.**

## Where We Are

| Field | Value |
|---|---|
| Today | 2026-06-20 |
| Current phase | Phase 0 — Foundation |
| Completed sessions | 3 |
| Active session | Session 03 — Complete |
| Next session | Session 04 — CLI Launcher + `--settings` Injector |

## Phase 0 — Foundation

| Workstream | Target session(s) | Status |
|---|---|---|
| Agent protocol bootstrap | Session 00 | [x] complete |
| Cargo project scaffold | Session 01 | [x] complete |
| Engine trait + types + StubEngine | Session 01 | [x] complete |
| Compression heuristics (cargo, git, pytest, npm, generic) | Session 02 | [x] complete |
| DefaultEngine dispatch + pre-rules | Session 03 | [x] complete |
| ClaudeCodeHookAdapter + wire types | Session 03 | [x] complete |
| CLI launcher + `--settings` injector | Session 04 | [ ] planned |
| Meter / receipt | Session 04–05 | [ ] planned |
| Bench fixtures + tripwire | Session 05 | [ ] planned |
| Session 05 NO-CODE audit | Session 05 | [ ] planned |
| Headroom lessons integration | Session 04 docs | [x] complete |

## Phase 1 — v1 Ship

| Workstream | Target session(s) | Status |
|---|---|---|
| Integration tests + end-to-end | Session 06–07 | [ ] planned |
| Measurement harness (bench/) | Session 07–08 | [ ] planned |
| Raw-output recovery design | Session 07–08 | [ ] planned |
| Installer (`curl | bash`) | Session 08 | [ ] planned |
| OSS release prep | Session 09–10 | [ ] planned |

## Phase 2 — Governance / Audit Ledger (v2+)

| Workstream | Target session(s) | Status |
|---|---|---|
| Cross-agent shim rail | TBD | [ ] planned |
| Agent-trace format adoption | TBD | [ ] planned |
| Git-native tamper-evident ledger | TBD | [ ] planned |
| Policy engine | TBD | [ ] planned |
| Governed memory + MCP audit/recovery surface | TBD | [ ] planned |

## Research Inputs To Revisit

| Input | Use When |
|---|---|
| `research/HEADROOM-LESSONS.md` | Launcher UX, raw recovery, benchmark harness, future memory/MCP/output-token policy decisions |
| `research/COMPETITOR-TEARDOWN.md` | Governance/audit positioning and competitor differentiation |
| `research/AGENT-TRACE-AND-AXONFLOW.md` | Agent-trace adoption, policy engine, ledger design |
| `research/JSONL-RECON.md` | Meter and receipt implementation |
| `research/compression-fixtures/SPEC.md` | Compression heuristic changes and regression tests |

## What Currently Works

- Cargo project scaffold (`Cargo.toml`, `src/`, `tests/`)
- `Engine` trait with `decide()` interface
- Core types: `CompressionRequest::command`, `ToolOutput` (interrupted, Option<i32>), `EngineDecision::Compressed { lines_removed }`
- CLI skeleton with subcommands (`hook`, `launch`, `meter`)
- G3 conformance test
- Compression heuristics for cargo, git, pytest, npm, and generic workloads
- DefaultEngine with fail-open catch_unwind; Passthrough when lines_removed == 0
- ClaudeCodeHookAdapter: reads CC hook JSON, compresses, writes hookSpecificOutput or {}
- hook CLI subcommand wired to real adapter

## Next Session

Session 04: CLI launcher + `--settings` injector. Read `prompts/04-task-launcher.md`.

## Rules For This Document

1. Update at every closeout.
2. Session numbers aspirational, not contracts.
3. NO-CODE audit sessions at 05, 10, 15, 20, 25.
4. New workstreams emerging mid-flight — add here with a discussion note.
