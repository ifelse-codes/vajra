# Vajra — Knowledge Base

**Permanent facts only. Reloaded every session.**

## 1. System Information

| Item | Value |
|---|---|
| Working directory | /Users/suman/playground/vajra |
| OS | macOS |
| Shell | /bin/zsh |
| Git | initialized 2026-06-17 |
| Owner | Suman — suman@sumanairbook.local |

## 2. Product Identity

- **Name:** Vajra
- **Positioning:** The vendor-neutral control plane for AI-written code: it audits and governs what your coding agent does — and makes it cheaper on the way in.

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

Rust, single static binary (vajractl), Apache-2.0 OSS

## 5. Source Documents

- VAJRA-MASTER.md (single source of truth)
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

## 8. Known Discrepancies / Deferred Issues

- **LINE_CAP discrepancy:** code has `LINE_CAP = 200`; ADR-0003 §2.2 specifies `LINE_CAP = 30`.
  The ADR value (30) is the validated split point from the real fixture corpus. Resolve in S04.
- **FAIL_PASSTHROUGH_CAP discrepancy:** code has `FAIL_PASSTHROUGH_CAP = 50`; ADR-0003 §2.2 specifies 400.
  Resolve in S04 alongside LINE_CAP.
