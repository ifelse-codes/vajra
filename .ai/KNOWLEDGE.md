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
- **Positioning:** One CLI that guides any AI coding agent through a project step by step. Vendor-neutral workflow coaching is the product; token saving is the quiet bonus.
- **Implemented slices today:** `vajra claude` (launches Claude Code with workflow context + compression hook + receipt) + `vajra next` (prints `.ai/` handoff packet or advances via `--advance`) + `vajra check` (drift detection + readiness scoring) + `vajra init` (scaffolds `.ai/` workflow). Only Claude Code is wired; other agents are planned.

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
- research/COMPETITIVE-LEARNINGS.md (GSD/SuperClaude/Loop teardown — what to steal, what to avoid, expert panel consensus on build order)
- research/COMPETITOR-TEARDOWN.md (AxonFlow + agent-trace spec analysis)

## 6. Solved Problems / Decisions Made

- ADR-0001: Hook wins over shim for v1 compression delivery
- ADR-0002: Engine trait + enum return + single crate + no adapter trait in v1
- ADR-0003: Tempfile settings merge + LINE_CAP=30 + FAIL_PASSTHROUGH_CAP=400
- ADR-0004: On-exit receipt to stderr + sidecar env var + compiled-in pricing
- ADR-0005: Pre-run cost estimate — chars/4 for input tokens, 3:1 output ratio (placeholder heuristic, not validated), Opus pricing default. Output ratio is low-confidence and dominates the estimate; treat as order-of-magnitude guidance until historical JSONL ratios replace it.
- 2026-06-24 founder direction: `vajra next` + cross-agent workflow coach is the north star; current repo is a partial foundation, not the finished product.
- Session 04 delivered `vajra claude` as the main Claude launcher alias and `vajra next` as the first agent-agnostic handoff packet command.
- Launcher injection now resolves the current executable path instead of assuming `vajractl hook` is globally available.
- 2026-06-25 competitive analysis: GSD (64k stars, prompt-only, 10 agents), SuperClaude (23k, Claude-only, context bloat), Loop Engineering (maturity levels, budget guards). Vajra's wedge = enforcement, not prompts. Design rules: max 7 commands, <5% context footprint, 2-3 agents deep > 10 shallow. Full teardown at `research/COMPETITIVE-LEARNINGS.md`.
- Headroom lesson: keep Vajra governance/audit-first; learn from reversible compression, wrapper UX, cache safety, benchmarks, memory/MCP, and output-token shaping without copying.
- 2026-06-25 Session 07: `claude --settings <file>` is **additive** — it merges with project `.claude/settings.json`, does not replace. All hook types from both sources fire. Verified via `--output-format stream-json --include-hook-events`.
- 2026-06-27 Session 19: **Varta v0 shipped** as a skill (not a compiler) in `varta/` — the **language only**: `SKILL.md` (teaches the 9-construct ⚡ grammar + boot ritual read→internalize→speak, modeled on plain-talk) + `GRAMMAR.varta` (canonical self-describing spec, dogfood). Grammar frozen at 9: `⚡project ⚡forbid ⚡require ⚡max ⚡pipeline ⚡final ⚡on ⚡assert ⚡enum`; anything else goes in a `//` comment. **Key decision (corrected mid-session):** Varta is a *language the agent speaks from the live `.ai/`*, NOT a persisted file. A hand-written `vajra.varta` companion was built then **dropped** — a second copy of the rules drifts from `.ai/` and silently loses config (the first pass had already dropped budget cap, maturity, max_bullets). A persisted `.varta` returns only when it can be **generated** from `.ai/` (one-way render; doesn't break skill-not-compiler). `scripts/verify-session-19.sh` (9 checks) includes a structural guard that no hand-copy exists; demo shows a live read-back from `.ai/CONSTRAINTS.yaml`. S21 = the co-pilot loader (make `⚡on` fire at runtime).
- 2026-06-27 Session 18 (founder direction): product reframe **co-pilot, not cop** — guide the agent in real time (ADAS / F1 race engineer), not catch mistakes after. New direction = **Varta**, a compact ⚡ C/Java-inspired machine language the agent learns at boot and speaks all session; delivered as a **skill, not a compiler** (the agent reads/writes it, nothing parses it). Co-pilot mechanism = `⚡on(cond) ⚡include "files"` (load context only when that work is touched). Constructs: `⚡project/⚡is/⚡stack/⚡goal/⚡now`, `⚡forbid`, `⚡require`, `⚡max`, `⚡pipeline`, `⚡final`, `⚡on…⚡include`, `⚡assert`, `⚡enum next`; `//` comments = human-glanceable why. Pattern discovered in `kreeda/.ai/KREEDA-BOOT.yaml`. Design in `VISION.md` + ROADMAP Phase 2 + memory `vajra-varta`.

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
- Breadcrumb format: `[vajra: N lines folded — VAJRA_RAW=1 before 'vajra claude' to see full output]` (appended to stdout).

## 8. Maturity Levels

| Level | Name | `vajra check` | Hooks | `vajra next --advance` |
|---|---|---|---|---|
| L1 | Report | WARN (exit 0) | Log violations, never block | Interactive confirm |
| L2 | Gated | FAIL (exit 1) | Can reject (exit 2) | Interactive confirm |
| L3 | Auto | FAIL (exit 1) | Strict enforcement | Skips confirm |

- Set via `maturity: L1|L2|L3` in `.ai/CONSTRAINTS.yaml`. Default: L2.
- `vajra init` prompts for maturity level during scaffolding.
- Hook scripts (`hook-pre-bash.sh`, `hook-pre-write.sh`) read `maturity:` and downgrade blocks to warnings at L1.

## 9. Known Limitations

- **stderr-on-exit-0:** `cargo build` with warnings (exit 0) compresses stdout, folding individual warning details. stderr summary ("N warnings emitted") is preserved. Agent may need to re-run to see warning specifics.
- **Savings estimate:** receipt uses ~12 tokens/line to estimate saved tokens. Rough, labeled as estimate.
- **Pricing compiled-in:** binary update needed when Anthropic changes pricing. Stale pricing shows slightly wrong numbers but the receipt's `[estimated]` marker flags schema drift.
