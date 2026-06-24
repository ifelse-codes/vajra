# Vajra — Knowledge Base

**Permanent facts only. Reloaded every session.**

## 1. System Information

| Item | Value |
|---|---|
| Working directory | /Users/suman/playground/vajra |
| OS | macOS |
| Shell | /bin/zsh |
| Git | initialized 2026-06-17 |
| Claude CLI | `/opt/homebrew/bin/claude` present as of 2026-06-24 |
| Owner | Suman — suman@sumanairbook.local |

## 2. Product Identity

- **Name:** Vajra
- **Positioning:** CLI coach for AI coding agents. North star: guide workflow, memory, and discipline with `vajra next`.
- **Implemented slices today:** `vajra claude` (Claude launch/compression/receipt) + `vajra next` (prints `.ai/` handoff packet + `VISION.md`).

## 3. Repo Layout (Agent Workflow)

```
.ai/             Agent constitution + machine state
.claude/         Claude Code config (settings.json)
.githooks/       Tracked git hooks (pre-commit, pre-push)
scripts/         hook-*.sh, verify-session-NN.sh, verify-closeout.sh, init-session.sh, rollback-closeout.sh
prompts/         Session input contracts (NN-task-<slug>.md)
sessions/        Session output reports (session-NN-summary.md)
docs/adr/        Architecture decision records
research/        Competitor teardown, Headroom lessons, JSONL recon, compression fixtures
AGENTS.md        Root pointer (Codex)
CLAUDE.md        Root pointer (Claude Code)
.cursorrules     Root pointer (Cursor)
```

## 4. Planned Tech Stack

Rust, single static binary (package `vajractl`, binary `vajra`), Apache-2.0 OSS

## 5. Source Documents

- VISION.md (target product vision)
- VAJRA-MASTER.md (single source of truth for the original compression-first thesis)
- DESIGN-BRIEF.html (visual design brief)
- docs/adr/0001-compression-delivery-mechanism.md
- docs/adr/0002-engine-trait-adapter-contract-module-layout.md
- docs/adr/0003-settings-injector-and-compression-heuristics.md
- docs/adr/0004-meter-receipt-design.md
- research/HEADROOM-LESSONS.md (learn-only reference; no code/docs/names/claims copied)

## 6. Solved Problems / Decisions Made

- ADR-0001: Hook wins over shim for v1 compression delivery
- ADR-0002: Engine trait + enum return + single crate + no adapter trait in v1
- ADR-0003: Tempfile settings merge + LINE_CAP=30 + FAIL_PASSTHROUGH_CAP=400
- ADR-0004: On-exit receipt to stderr + sidecar env var + compiled-in pricing
- 2026-06-24 founder direction: `vajra next` + cross-agent workflow coach is the north star; current repo is a partial foundation, not the finished product.
- Session 04 delivered `vajra claude` as the main Claude launcher alias and `vajra next` as the first agent-agnostic handoff packet command.
- Launcher injection now resolves the current executable path instead of assuming `vajractl hook` is globally available.
- Headroom lesson: keep Vajra governance/audit-first; learn from reversible compression, wrapper UX, cache safety, benchmarks, memory/MCP, and output-token shaping without copying.

## 7. Engine + Adapter Type Shapes (S03 — permanent)

```rust
// EngineDecision — Compress renamed Compressed; carries lines_removed
pub enum EngineDecision {
    Passthrough,
    Compressed { output: String, lines_removed: usize },
}

// ToolOutput — tool field removed; interrupted + Option<i32> added
pub struct ToolOutput {
    pub stdout: String,
    pub stderr: String,
    pub exit_code: Option<i32>,
    pub interrupted: bool,
}

// CompressionRequest — command is the shell command string (was tool_output.tool)
pub struct CompressionRequest {
    pub command: String,
    pub tool_output: ToolOutput,
}
```

- `DefaultEngine` returns `Passthrough` (not `Compressed`) when `lines_removed == 0`.
- `ClaudeCodeHookAdapter` lives in `src/adapter/claude_code.rs`.
- Hook wire types use `#[serde(rename_all = "camelCase")]` (CC JSON is camelCase).
- Breadcrumb format: `[N lines hidden — set VAJRA_RAW=1 to disable]` (appended to stdout).

## 8. Known Limitations

- **stderr-on-exit-0:** `cargo build` with warnings (exit 0) compresses stdout, folding individual warning details. stderr summary ("N warnings emitted") is preserved. Agent may need to re-run to see warning specifics.
- **Savings estimate:** receipt uses ~12 tokens/line to estimate saved tokens. Rough, labeled as estimate.
- **Pricing compiled-in:** binary update needed when Anthropic changes pricing. Stale pricing shows slightly wrong numbers but the receipt's `[estimated]` marker flags schema drift.
