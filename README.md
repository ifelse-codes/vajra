# Vajra

> The vendor-neutral control plane for AI-written code: it audits and governs what your coding agent does — and makes it cheaper on the way in.

## What It Is

Vajra wraps your AI coding assistant. You type `vajra claude` instead of `claude`. Your agent works exactly the same — but Vajra watches what it does, keeps the expensive parts cheap, records everything it changed, and lets you set rules it can't ignore.

## This Repo

This repo uses an **agent-first session workflow** to stay disciplined across sessions. Key conventions:

- `.ai/` — agent constitution + machine state
- `prompts/` — session input contracts
- `sessions/` — session output reports
- `docs/adr/` — architecture decision records (4 ADRs, design complete)
- `scripts/hook-*.sh` — Claude Code + git hooks
- `scripts/verify-closeout.sh` — fail-closed closeout gate

## Source Docs

| Doc | What |
|---|---|
| `VAJRA-MASTER.md` | Single source of truth: full brainstorm + locked decisions |
| `DESIGN-BRIEF.html` | Visual design brief |
| `docs/adr/0001-0004.md` | Architecture Decision Records |
| `research/` | Competitor teardown, Headroom lessons, JSONL recon, compression fixtures |

## Quick Start (Agent Workflow)

```bash
git config core.hooksPath .githooks
source scripts/ai-session
```

## License

Apache-2.0
