# Vajra — Working Roadmap

**Updated:** 2026-06-24 · Session 04 closeout prepared.

**Founder direction update:** the north star is `vajra next` as the cross-agent workflow coach. The current repo is a working foundation: Claude compression rail + honest meter + `.ai` handoff packet.

## Where We Are

| Field | Value |
|---|---|
| Today | 2026-06-24 |
| Current phase | Phase 0 — Foundation |
| Last closed session | Session 04 — launcher + `vajra claude` + `vajra next` packet |
| Active session | none (between sessions) |
| Next session | Session 05 — mandatory Ground Truth audit |
| Crate | package `vajractl` · binary `vajra` |

## v1 — Compression + Honest Metering

**One sentence:** `vajra claude` compresses successful Bash output before the model sees it — and shows an honest receipt.

| Component | Status |
|---|---|
| Engine trait + heuristics | [x] done |
| Claude Code hook adapter | [x] done |
| Launcher + settings injector | [x] done |
| `vajra claude` alias | [x] done |
| Meter + receipt | [x] done |
| `vajra next` handoff packet | [x] done |
| README + product honesty pass | [x] done |

## Remaining Work Before a Real v1 Ship

| Item | Blocking? |
|---|---|
| Installer (`cargo install` path + optional one-line installer) | Yes |
| Live user-run `vajra claude` smoke test on a real Claude Code session | Yes |
| Verify `claude --settings` additive behavior empirically | Yes |
| Session 05 Ground Truth audit | Yes |
| Release packaging / first tagged cut | Yes |

## Session 05 — Ground Truth (Mandatory NO-CODE)

| Option | Goal | Why pick this | Status |
|---|---|---|---|
| A | Audit `vajra claude` + `vajra next` for ship-readiness gaps | Most direct path to the founder's stated make-or-break flow | [ ] pending user pick |
| B | Audit installer / release readiness | Best if the next code session should target first usable distribution | [ ] pending user pick |
| C | Audit cross-agent workflow gaps vs. `VISION.md` | Best if the next code session should pivot harder toward the coach product | [ ] pending user pick |

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
