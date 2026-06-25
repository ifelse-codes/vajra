# Competitive Learnings — What to Steal, What to Avoid

**Date:** 2026-06-25

## GSD (64k stars) — the one to beat

**What it does:** 5-phase workflow loop (discuss → plan → execute → verify → ship), 67 commands, 10+ agents via prompt files, fresh-context subagents to beat context rot, `.planning/` state files.

**Why it works:** `npx` one-liner install is frictionless. File-based state (Markdown in git) needs no server. Fresh-context subagents solve context rot. Supports many agents.

**Its weakness:** prompt-only. No enforcement. When an agent ignores instructions, GSD shrugs. `[VERIFIED]` tags without actual verification. State management edge cases (clobbering).

**Steal for Vajra:**
- Frictionless init (one command, max 2 questions) → `vajra init`
- Multi-agent via per-agent config dirs → Phase 2
- File-based Markdown state → already have `.ai/`

**Skip:** 67 commands (bloat), subagent orchestration (not our job).

## SuperClaude (23k stars) — the cautionary tale

**What it does:** 30 slash commands, 20 agent personas, 7 behavioral modes, 8 MCP server integrations. Claude Code only.

**Why it works:** pre-written prompts so users don't have to prompt-engineer. Deep Research mode (multi-hop web search). Easy install (`pipx`).

**Its weakness:** context bloat is fatal — sessions start 32% full, Claude freezes (#410, 13 comments). Too many commands confuse users (#501, 10 comments). Claude-only. Shallow integration (everything is markdown prompt injection, `settings.json` is literally `{}`).

**Steal for Vajra:**
- Easy install UX → `cargo install vajractl`
- Generate good defaults so users don't write config from scratch → `vajra init`

**Avoid at all costs:**
- Command bloat (max 7 commands in Vajra, ever)
- Context footprint > 5% of window
- Claude-only lock-in
- Prompt injection as the whole mechanism

## Loop Engineering (small but smart)

**What it does:** 7 canned patterns (daily triage, PR babysitter, CI sweeper), 3 CLI tools (`loop-init`, `loop-cost`, `loop-audit`), maturity levels L1→L2→L3, budget guards.

**Why it works:** maturity levels give users a growth path. Budget guard with kill switch. Readiness scoring. Supports Grok, Claude, Codex with per-tool config dirs.

**Its weakness:** scaffolding only, no runtime enforcement. Small community.

**Steal for Vajra:**
- Maturity levels L1/L2/L3 → CONSTRAINTS.yaml `maturity` field (Phase 3)
- Readiness scoring → `vajra check` (Phase 1)
- Budget guard with kill switch → launcher run loop (Phase 1)
- Pre-run cost estimate → Phase 4

## Expert Panel Consensus (PM + Architect + CTO)

| Decision | Consensus |
|---|---|
| Multi-agent timing | Phase 2 — 2-3 agents deep, not 10 shallow |
| `vajra init` | Phase 1 — most adoption-critical command |
| Budget guard | Phase 1 — differentiator over prompt-only tools |
| Maturity levels | Phase 3 — config flag in CONSTRAINTS.yaml |
| Max commands at v1 | 7 top-level commands, never more without user demand |
| Context footprint | Hard cap < 5% of context window |
| Vajra's wedge | Enforcement, not prompts. "Your agent follows rules. Provably." |
| First 100 users | Ship `vajra init` + `vajra claude` + receipt. One HN post with before/after cost diff. |
