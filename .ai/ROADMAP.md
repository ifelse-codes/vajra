# Vajra — Working Roadmap

**Updated:** 2026-06-27 · Session 18 closeout.

**North star:** `vajra next` as the cross-agent workflow coach. One command that advances the agent to the next step with the right context.

**Wedge against GSD/SuperClaude:** enforcement, not prompts. GSD is a prompt library (64k stars, 10 agents, no enforcement). SuperClaude is a Claude-only prompt library (context bloat is its fatal flaw). Vajra is a Rust binary that actually enforces rules, meters cost honestly, and fails closed. Ship narrow, ship enforced, show receipts.

## Where We Are

| Field | Value |
|---|---|
| Today | 2026-06-27 |
| Current phase | Phase 2 — Varta (the agent's language) |
| Last closed session | Session 18 — product review + vision (Varta direction set) |
| Active session | Between sessions (S19 pending — Varta v0) |
| Crate | package `vajractl` · binary `vajra` |

## What Works Today

| Component | Status |
|---|---|
| Engine trait + heuristics | [x] done — compresses cargo/git/npm/pytest output, tests pass against fixtures |
| Claude Code hook adapter | [x] done — reads CC PostToolUse JSON, returns compressed output |
| Launcher + settings injector | [x] done — merges hook config, spawns `claude --settings <tmpfile>` |
| `vajra claude` command | [x] done — launches Claude Code with hook injection, prints receipt on exit |
| Meter + receipt | [x] done — parses session JSONL, prints honest cost breakdown |
| `vajra init` command | [x] done — scaffolds `.ai/` + hooks + pointers (16 files, interactive, idempotent) |
| `vajra next` (read-only + advance) | [x] done — prints packet or advances session via `--advance` |
| Installer / release pipeline | [x] done — S13: `cargo install vajractl`, GitHub Actions CI + release (3 targets) |
| Maturity levels L1/L2/L3 | [x] done — S14: L1 report / L2 gated / L3 auto, wired into check, init, next, hooks |

## What Does NOT Work Yet

| Component | Status |
|---|---|
| Second agent launcher | [ ] not built — only Claude Code is wired |

## Design Rules (from competitive analysis)

| Rule | Why |
|---|---|
| **Max 7 top-level commands** | SuperClaude's 30+ commands confuse users (their #1 complaint) |
| **Context footprint < 5%** | SuperClaude sessions start 32% full — Claude freezes. Vajra must stay light. |
| **2-3 agents deep > 10 agents shallow** | GSD supports 10 via prompt templates. Deep integration with 2-3 beats shallow support for 10. |
| **Enforcement is the wedge** | GSD/SuperClaude are prompt libraries — agents can ignore them. Vajra's hooks actually intercept. Lead with "your agent follows rules, provably." |
| **Init must be frictionless** | GSD's `npx` one-liner is why people try it. `vajra init` must be equally fast. |

## Roadmap (in priority order)

### Phase 1 — Prove the core works for real (pre-release, blocking)

1. **[x] Prove `vajra claude` in a real session** — CONFIRMED in Session 07. Settings injection is additive, hooks fire, receipt prints with real numbers.

2. **[x] Build `vajra init`** — DONE in Session 08. Scaffolds 16 files (.ai/ + hooks + pointers), interactive (2 questions), idempotent. Demo scripts formalized in CONSTRAINTS.yaml.

3. **[x] Build `vajra check`** — DONE in Session 09. Drift detection + readiness scoring. 10 checks (required files, session validity, branch pattern, boot match, verify script). Pass/fail checklist + score. Exit 0/1.

4. **[x] Make `vajra next` advance the session** — DONE in Session 09. `--advance` flag bumps `.ai/SESSION` (N → N+1), updates SESSION-BOOT.md number. Interactive confirm, refuses on main/master. Bare `vajra next` unchanged (backwards compatible).

5. **[x] Budget guard** — DONE in Session 11. `budget.cap_usd` and `budget.mode` in CONSTRAINTS.yaml, enforced in launcher after session exit. Warn mode prints warning; kill mode exits 2. 11 tests.

6. **[x] Prove `vajra next` walks a real session start to finish** — DONE in Session 12. 3-session loop proven end-to-end. Found and fixed: prompt pointer not updating on advance, SIGPIPE panic when piping output. Automated e2e proof in verify script.

### Phase 2 — Varta: the agent's language + the co-pilot (S18 direction)

**Why this phase exists (S18 finding):** running the commands produces *files*, not a *feeling* — the first-run payoff is invisible. The deeper pain across 2 months of `.ai/` use: agents forget the vision and rush to finish. Fix = **Varta**, a compact ⚡ machine-language the agent learns at boot and speaks all session, with a co-pilot that feeds the right context at the right moment. Reframe: **co-pilot, not cop.** See `VISION.md` and memory `vajra-varta`.

7. **[ ] Varta v0 — the skill** *(NEXT — picked S18)* — Write the Varta skill (`SKILL.md`, teaches the ⚡ grammar like plain-talk teaches plain English) + convert Vajra's own `.ai/` into one `.varta` spec. Prove an agent loads it, internalizes it, and speaks it for a full session. Risk: language may need 2–3 real sessions to settle.

8. **[ ] The co-pilot loader** — Make `⚡on(x) ⚡include` real: Vajra surfaces the right context mid-session based on what the agent touches (drift nudges, race-engineer calls). Build *after* Varta v0 proves the language. Risk: needs runtime hooks — harder.

9. **[ ] First-run "aha"** — Make `vajra init` → first session deliver a visible win in 2 minutes. Fixes the exact "not worth it" feeling from the S18 walkthrough. Risk: polish, not the big bet.

**Varta language spec (locked S18):** C/Java-inspired syntax + `⚡` keyword prefix. Constructs: `⚡project{⚡is ⚡stack ⚡goal ⚡now}`, `⚡forbid{}`, `⚡require{}`, `⚡max{}`, `⚡pipeline{}`, `⚡final{}`, `⚡on(cond) ⚡include "files"` (the co-pilot), `⚡assert{}`, `⚡enum next{}`. `//` comments = the human-glanceable *why*. Mechanism = **skill, not compiler** — the agent reads/writes it, nothing parses it.

### Phase 3 — Ship it — COMPLETE

8. **[x] Installer / release path** — DONE in Session 13. `cargo install vajractl`, Homebrew formula, GitHub Actions CI + release workflow (3 targets), README install section. [PR #1](https://github.com/ifelse-codes/vajra/pull/1).

9. **[x] Maturity levels** — DONE in Session 14. `maturity: L1|L2|L3` in CONSTRAINTS.yaml. L1 = report-only (warn, exit 0). L2 = gated (block, human approval). L3 = auto (skip confirm on advance). Wired into check, init, next, and hooks. [PR #2](https://github.com/ifelse-codes/vajra/pull/2).

10. **[x] Clean legacy references** — DONE in Session 16. Removed `vajra launch` alias from match arm, help text, enum. [PR #4](https://github.com/ifelse-codes/vajra/pull/4).

11. **[x] Pre-run cost estimate** — DONE in Session 17. `vajra estimate` reads context files, estimates tokens, prices against Opus rates, warns on budget. ADR-0005. [PR #6](https://github.com/ifelse-codes/vajra/pull/6).

### Backlog (when ready, not before)

- **Add second agent** (Codex or Cursor) — deferred until Claude experience is fully satisfying.
- **Add third agent** (Aider, Gemini CLI, or Kimi) — after second agent proves the pattern.
- **Canned workflow patterns** — daily triage, PR babysitter, CI sweeper. Low priority.
- **Audit ledger (v2)** — git-native provenance, agent-trace format.
- **Additional agents** — Kilo, Windsurf, Continue, others. Add as users request.
- **Policy enforcement, governed memory, MCP tools** — only after the core loop is proven and users exist.

## Competitive Reference

| Tool | Stars | Agents | Mechanism | Vajra's edge over it |
|---|---|---|---|---|
| GSD | 64k | 10+ | Prompt files + `.planning/` state | Enforcement (Rust binary, hooks, fail-closed gates) |
| SuperClaude | 23k | Claude only | Prompt injection via commands | Vendor-neutral + small footprint (no context bloat) |
| Loop Engineering | small | 3 | Scaffolding templates + skills | Runtime enforcement + honest metering |
| AxonFlow | — | Claude only | Hook-based policies | Local-first, no cloud, no retention cliff |

## v1 Command Set (max 7, add sparingly)

| Command | What it does | Phase |
|---|---|---|
| `vajra init` | Scaffold `.ai/` + hooks + pointers in any repo | 1 |
| `vajra next` | [x] Advance to next session step with context | 1 |
| `vajra check` | [x] Drift detection + readiness score + verify | 1 |
| `vajra claude` | Launch Claude Code with hooks + meter | 0 (done) |
| `vajra estimate` | [x] Predict token spend before running a session | 4 (done) |
| `vajra <agent>` | Launch other agents (Codex, Cursor, etc.) | 2 |
| `vajra meter` | Print receipt for a past session | 0 (done) |

## Rules For This Document

1. Update at every closeout.
2. NO-CODE audit sessions at 05, 10, 15, 20, 25.
3. Mark items `[x]` only when they work in a real session, not just in tests.
4. Never exceed 7 top-level commands without explicit user approval.
