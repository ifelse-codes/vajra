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
varta/           Varta language — SKILL.md (grammar) + GRAMMAR.varta (spec); spoken from live .ai/
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
- 2026-06-29 Session 21 (co-pilot loader): **`⚡on(cond) ⚡include "files"` now fires mid-session** via `scripts/hook-copilot-loader.sh`, a PreToolUse(Edit|Write|Bash) hook reading `copilot.on` rules from the live `.ai/CONSTRAINTS.yaml` (rule form `"PATTERN => files | why"`; PATTERN = path glob or `cmd:<substring>`). Per-session debounce (keyed on `session_id`, marker dir under `$TMPDIR`; override via `VAJRA_COPILOT_STATE_DIR`). **Maturity-gated = the enforce-vs-advise gate:** L1 prints to stdout + exit 0 (advise); L2/L3 print to stderr + **exit 2 (block until surfaced)** — the same mechanism `hook-pre-bash`/`hook-pre-write` use. **Decision gate ANSWERED: Varta ENFORCES → on-wedge** (memory `vajra-varta-wedge-risk`); proven live (the `cmd:git commit` rule blocked a real commit this session). Design choices (approved): rules live in CONSTRAINTS.yaml not a new `.varta` (honors S19 no-hand-copy); **bash hook, not a Rust matcher** — the S20 "matcher near `src/adapter/`" sketch was dropped because there is no `serde_yaml`/`glob` dep and all hooks are bash (maturity/budget are hand-parsed line-by-line). v0 limits: simple-glob (`*` spans `/`) + substring, surfaces paths+why not contents. Scaffold propagation into `src/cli/init.rs` (which has **no `ground_truth:` block at all**) split to S22. verify-session-21.sh green (10/10). PR #11.
- 2026-06-29 Session 22 (scaffold propagation): **`vajra init` now scaffolds the S20 GT audits + the S21 co-pilot.** `src/cli/init.rs`'s `TPL_CONSTRAINTS` gained `ground_truth:` (vision/roadmap/constitution audits + question-lists + `drift_axes`) + `copilot:` (2 starter `⚡on` rules), refreshed `approval_tokens` (+`"go ahead and commit"`), added `branch.ground_truth_commit_exempt_branch_suffixes`; `TPL_CLAUDE_SETTINGS` wires `hook-copilot-loader.sh` into PreToolUse (Bash + Edit|Write|MultiEdit). Scaffold = **17 files** (was 16). **Key decision (b): the ~70-line hook ships via `include_str!("../../scripts/hook-copilot-loader.sh")`** — one source of truth, byte-identical scaffolded copy, no hand-copy (honors the S19 no-drift rule). Rejected (a) `const` copy (drifts) + (c) runtime template (a single binary can't read an uninstalled file). **Packaging gotcha (permanent rule): any file `include_str!`'d from outside `src/` must be in the crate package** — `Cargo.toml` excluded `scripts/`, which would break the `cargo install` compile; fix = `scripts/*` + `!scripts/hook-copilot-loader.sh` negation, verified via `cargo package --list`. Starter `copilot.on` rules point only at scaffolded files (anti-rot holds). verify-session-22.sh green (12/12) against a real `vajra init` into a temp dir; the co-pilot fires (exit 2 at L2) in the fresh project. PR #12.
- 2026-06-29 Session 23 (first-run "aha"): **`vajra init` now ends with a live co-pilot fire** — `run()` calls `first_run_aha(&root)` after `scaffold()`, which spawns the just-scaffolded `scripts/hook-copilot-loader.sh` once against a sample `git commit` payload (isolated `VAJRA_COPILOT_STATE_DIR` under `temp_dir()/vajra-aha-<pid>`, cleaned up; `CLAUDE_PROJECT_DIR=root`) and prints the **real** block + surfaced `.ai/STATE.md`, framed as a 5-second simulation, then `Next: … vajra claude`. **Key decision: the felt moment rides on `init`** (no 8th top-level command — honors the max-7 cap) and is a real hook fire, not a mockup (dogfoods the S22-propagated co-pilot). Rejected a guided multi-step first run (needs API + user steps, slower than 2 min) and a static blurb (not felt). **Graceful degradation:** missing bash/jq → `render_aha_fallback()` static preview; the child's exit 2 is captured so **`vajra init` still exits 0**. verify-session-23.sh green (11/11): a real `vajra init </dev/null` asserts the live block in init's own output + `init-exits-zero` + `no-debounce-leak`. `cargo test` 108 pass. **Phase 2 is COMPLETE** (S19 language → S21 enforce → S22 propagate → S23 felt). PR #13.
- 2026-06-29 Session 25 (ground-truth, direction-drift lens): audited S21–S24. **Verdict: Varta was on-wedge, not scope creep** — S20's "off-wedge?" flag was honestly resolved by S21 (the co-pilot loader makes `⚡on` fire + block, proven live). **But its leverage is spent:** S22 (propagate) was necessary, S23 (felt) + S24 (render) were polish on a Claude-only mechanism. Four sessions of Claude-depth left the *only differentiating wedge pillar — vendor-neutrality — with zero code.* **The second agent launcher (Codex/Cursor) is the #1 highest-leverage move** (proves ADR-0002's adapter contract is genuinely cross-agent, or exposes hidden Claude-coupling). **Meta-finding (false-green risk):** every green signal (`vajra check` incl. `varta: matches render`, verify 21/21, 118 tests, CI) measures Claude-depth only — *no metric anywhere measures cross-agent breadth*, the actual north-star. The dashboard can be 100% green while the gap widens (the S20 trap one level up); recommend a "north-star gap" indicator (RED until ≥2 agents). **Resolved:** "grammar frozen at 9 (provisional)" → **validated** — the S24 renderer rendered the full live `.ai/` (incl. budget + maturity, the configs S20 feared lost) into the 9 constructs deterministically; the 9 held. **Still open (carry):** `vajra estimate` 3:1 ratio unvalidated. **Recurring low drift (3rd time, S15/S20/S25):** STATE.md writes PR status before the merge ("pending merge") — structural, snapshot-before-merge ordering. Zero constraint violations S21–S24; cost ~$0.46 unchanged. User picked S26 = one-session-per-chat enforcement. Report: `sessions/session-25-ground-truth.md`.
- 2026-06-29 Session 26 (one-session-per-chat enforcement): **`scripts/hook-session-guard.sh`** (PreToolUse Bash, wired beside `hook-pre-bash`/`hook-copilot-loader`) makes AGENTS.md step 10 real. Signal = Claude `session_id` (the chat); the first `git checkout -b session-NN-*` in a chat records `NN<TAB>session_id` in a **gitignored `.ai/.session-owner`**. On a later checkout it **blocks only the N→N+1 boundary FROM THE SAME CHAT**: `NN == owner_NN+1 && sid == owner_sid` → exit 2 ("open a new chat first"). Same-session re-checkout, non-session branches, and fresh chats all pass. Maturity-gated (L1 advise exit 0 / L2-L3 block exit 2); gated on `one_session_per_chat: true`; bash + hand-parsed (no new dep, honors S19/S21). Test knobs: `VAJRA_SESSION_OWNER_FILE`, `VAJRA_GUARD_MATURITY`. No 8th command. verify-session-26.sh green (13/13). **Not yet propagated to `vajra init`** (deferred S27/S28). PR #17. **Founder direction this session:** second agent **parked in backlog**, gated on *founder* satisfaction with Vajra-on-Claude (NOT the S25 audit's "condition met" — that was the audit's call, not the founder's). Memory `vajra-second-agent-gate`.
- 2026-06-29 Session 26 (founder direction — Darshan): new next leap = **Darshan** (Sanskrit *darśana* = "sight/seeing/a glance"), the **human's lane** that pairs with Varta — **the agent talks to itself (Varta); the user sees (Darshan).** Problem: AI output is a wall of dense, technical text → cognitive overload / burnout; the user must read line-by-line. Darshan = Vajra's **default human-facing speaking skill** that says *more with fewer words via visual structure* (banners, cards, tables, color, diagrams) — same meaning, nothing dropped, far less to read. **More than plain-talk:** plain-talk fixes the *words*; Darshan also fixes the *load*. **Skill, NOT a renderer** (like Varta) — Vajra ships instructions the agent internalizes at boot; nothing in Rust renders. **One rule:** *"render the richest visual this surface can handle; always glanceable; never drop meaning."* 3 surface tiers: rich chat (HTML/SVG widgets) · terminal/TUI (ANSI color, box-drawing, tables, ▇ bars) · plain/no-color (structured markdown). Portable to any agent (the rule travels; richness caps to the screen). Built S27 — `prompts/27-task-darshan.md`. Name provisional (founder confirms at BOOT, like Varta was once "VajraSpeak").
- 2026-06-28 Session 20 (ground-truth): the GT audit was **blind to direction drift** — it checked only discipline (state/knowledge/constraint/cost) + roadmap *ordering*, never "are we building the right thing?" (the exact pain Vajra fixes). **Hardened:** `CONSTRAINTS.yaml#ground_truth` now requires `vision_alignment` + `roadmap_alignment` + `constitution_review` with question-lists + a meta-check; `AGENTS.md` reframes GT as two drift classes (direction + discipline). Propagation into the `vajra init` scaffold (`src/cli/init.rs`) queued for S21. First run flagged a live risk: **Varta may be off-wedge** (a spoken language enforces nothing) — S21's co-pilot loader is the make-or-break gate. **"Grammar frozen at 9" is provisional** until exercised over real sessions. Memories: `feedback-audit-direction-drift`, `vajra-varta-wedge-risk`.

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
