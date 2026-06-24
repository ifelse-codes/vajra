# Vajra — Working Roadmap

**Updated:** 2026-06-24 · Session 05 Ground Truth closed; Session 06 prepared.

**Founder direction update:** the north star is `vajra next` as the cross-agent workflow coach. The current repo is a working foundation: Claude compression rail + honest meter + `.ai` handoff packet.

## Where We Are

| Field | Value |
|---|---|
| Today | 2026-06-24 |
| Current phase | Phase 0 — Foundation |
| Last closed session | Session 05 — Ground Truth ship-readiness audit |
| Active session | none (between sessions) |
| Next session | Session 06 — real `vajra claude` proof |
| Crate | package `vajractl` · binary `vajra` |

## Current Working Slice

| Component | Status |
|---|---|
| Engine trait + heuristics | [x] done |
| Claude Code hook adapter | [x] done |
| Launcher + settings injector | [x] done |
| `vajra claude` alias | [x] done |
| Meter + receipt | [x] done |
| `vajra next` handoff packet | [x] done |
| README + product honesty pass | [x] done |

## Session 05 Audit Findings

| Finding | Severity |
|---|---|
| `vajra claude` works locally, but additive `--settings` behavior still lacks real-session proof | Blocker |
| No installer / release path exists | Blocker |
| `vajra next` prints a large packet (`610` lines) and does not advance the loop | Blocker for founder story |
| README still has a few legacy `vajra launch` references | Minor |

## Session 06 Plan

| Option | Goal | Why pick this | Status |
|---|---|---|---|
| A | Prove `vajra claude` in a real session and verify additive behavior | Fastest path to current-slice ship-readiness | [x] selected |
| B | Build the installer / release path | Needed before sharing beyond this machine | [ ] deferred |
| C | Make `vajra next` actually advance the workflow | Closest move toward the founder vision | [ ] deferred |

## v2 — Audit Ledger (earns its way in)

- Repo-native provenance that travels with git.
- Adopt/emit agent-trace where useful.
- Bundle honest meter + governance once the ledger exists for real.

## v3+ — Parked Honestly

- Multi-agent launchers (Codex, Cursor, Aider, Kimi)
- Policy enforcement
- Governed memory
- MCP retrieval/audit tools

## Rules For This Document

1. Update at every closeout.
2. NO-CODE audit sessions at 05, 10, 15, 20, 25.
3. New workstreams emerging mid-flight — add here with a discussion note.
