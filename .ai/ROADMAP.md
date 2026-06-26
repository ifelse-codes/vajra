# Vajra — Working Roadmap

**Updated:** 2026-06-26 · Session 08 closeout.

**North star:** `vajra next` as the cross-agent workflow coach. One command that advances the agent to the next step with the right context.

**Wedge against GSD/SuperClaude:** enforcement, not prompts. GSD is a prompt library (64k stars, 10 agents, no enforcement). SuperClaude is a Claude-only prompt library (context bloat is its fatal flaw). Vajra is a Rust binary that actually enforces rules, meters cost honestly, and fails closed. Ship narrow, ship enforced, show receipts.

## Where We Are

| Field | Value |
|---|---|
| Today | 2026-06-26 |
| Current phase | Phase 1 — Prove the core works |
| Last closed session | Session 08 — vajra init + demo scripts |
| Active session | Between sessions (S09 pending) |
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
| `vajra next` (read-only) | [x] done — prints `.ai/` handoff packet + VISION.md + prompt pointer |

## What Does NOT Work Yet

| Component | Status |
|---|---|
| `vajra init` | [x] done — Session 08 |
| `vajra next` session advancement | [ ] stub — prints the packet, does not advance the loop |
| `vajra verify` / `vajra check` | [ ] not built (scripts exist, no CLI) |
| Settings injection — live proof | [x] CONFIRMED — Session 07, `--settings` is additive |
| Second agent launcher | [ ] not built — only Claude Code is wired |
| Budget guard / kill switch | [ ] not built |
| Installer / release pipeline | [ ] not built |

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

3. **Build `vajra check`** — drift detection + readiness scoring (inspired by Loop Engineering's `loop-audit`). Reads `.ai/STATE.md` and compares claims against actual repo state (branch, session number, file existence). Also runs `scripts/verify-session-{NN}.sh` if it exists. Prints a pass/fail checklist with a readiness score. No side effects.

4. **Make `vajra next` advance the session** — the single most important feature. Today it dumps the packet. It needs to: (a) bump `.ai/SESSION`, (b) update SESSION-BOOT.md pointer, (c) print the next step's context. Move from "dump" to "advance."

5. **Budget guard** — add `budget_cap_usd` field to CONSTRAINTS.yaml. The launcher checks cumulative spend after each session via the meter. Exceeds cap → warn or kill. Lives in the launcher run loop, not a separate command. Differentiator: GSD and SuperClaude have no cost enforcement at all.

6. **Prove `vajra next` walks a real session start to finish** — the north star test. Run a real multi-step project where `vajra next` drives the loop. If it doesn't work end-to-end, it's not done.

### Phase 2 — Prove vendor-neutral is real (2-3 agents, not 10)

7. **Add a second agent** (Codex or Cursor) — prove `vajra <agent>` works with something other than Claude Code. Deep integration, not a prompt template. The workflow commands (`init`, `next`, `check`) must work identically. The launcher is agent-specific.

8. **`vajra next` works identically across both agents** — the agent changes, the workflow doesn't. This is the proof that vendor-neutral is real, not a claim.

9. **Add a third agent** (Aider, Gemini CLI, or Kimi) — solidifies the multi-agent story.

### Phase 3 — Ship it

10. **Installer / release path** — `cargo install vajractl`, Homebrew, signed releases, `curl | bash` installer with SHA-256 verification. One-liner in the README.

11. **Maturity levels** — add `maturity: L1|L2|L3` to CONSTRAINTS.yaml. L1 = report-only (hooks log but don't block). L2 = gated (hooks can reject, human approval required). L3 = auto (next advances without confirmation). Gives users a growth path. Default: L2.

12. **Clean legacy references** — remove `vajra launch` alias and all references from code and docs.

### Phase 4 — Earn the next features (post-launch, only when users ask)

13. **Pre-run cost estimate** — predict token spend before running a session (inspired by Loop Engineering's `loop-cost`).
14. **Canned workflow patterns** — daily triage, PR babysitter, CI sweeper (inspired by Loop Engineering). Only after the core loop is proven.
15. **Audit ledger (v2)** — git-native provenance, agent-trace format. No governance claims until a working ledger exists.
16. **Additional agents** — Kilo, Windsurf, Continue, others. Add as users request.
17. **Policy enforcement, governed memory, MCP tools** — only after the core loop is proven and users exist.

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
| `vajra next` | Advance to next session step with context | 1 |
| `vajra check` | Drift detection + readiness score + verify | 1 |
| `vajra claude` | Launch Claude Code with hooks + meter | 0 (done) |
| `vajra <agent>` | Launch other agents (Codex, Cursor, etc.) | 2 |
| `vajra meter` | Print receipt for a past session | 0 (done) |

## Rules For This Document

1. Update at every closeout.
2. NO-CODE audit sessions at 05, 10, 15, 20, 25.
3. Mark items `[x]` only when they work in a real session, not just in tests.
4. Never exceed 7 top-level commands without explicit user approval.
