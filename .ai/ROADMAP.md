# Vajra — Working Roadmap

**Updated:** 2026-06-29 · Session 25 — ground-truth (NO-CODE, direction-drift lens). Verdict: Varta was on-wedge but its leverage is spent; the **second agent launcher** is the highest-leverage next move (north-star gap). S26 (one-session-per-chat enforcement) hardens the loop first.

**North star:** `vajra next` as the cross-agent workflow coach. One command that advances the agent to the next step with the right context.

**Wedge against GSD/SuperClaude:** enforcement, not prompts. GSD is a prompt library (64k stars, 10 agents, no enforcement). SuperClaude is a Claude-only prompt library (context bloat is its fatal flaw). Vajra is a Rust binary that actually enforces rules, meters cost honestly, and fails closed. Ship narrow, ship enforced, show receipts.

## Where We Are

| Field | Value |
|---|---|
| Today | 2026-06-29 |
| Current phase | Phases 1–3 COMPLETE — Varta arc done; S25 GT says next leap = cross-agent |
| Last closed session | Session 25 — ground-truth (NO-CODE, direction drift); verdict → second agent launcher is #1 |
| Active session | Between sessions (S26 pending — CODE: one-session-per-chat enforcement) |
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

### Phase 2 — Varta: the agent's language + the co-pilot (S18 direction) — COMPLETE

**Why this phase exists (S18 finding):** running the commands produces *files*, not a *feeling* — the first-run payoff is invisible. The deeper pain across 2 months of `.ai/` use: agents forget the vision and rush to finish. Fix = **Varta**, a compact ⚡ machine-language the agent learns at boot and speaks all session, with a co-pilot that feeds the right context at the right moment. Reframe: **co-pilot, not cop.** See `VISION.md` and memory `vajra-varta`.

7. **[x] Varta v0 — the skill** — DONE in Session 19. Ships the **language only**: `varta/SKILL.md` teaches the ⚡ grammar (boot ritual read→internalize→speak), `varta/GRAMMAR.varta` is the self-describing spec. 9 constructs, skill not compiler. The agent speaks Varta from the **live `.ai/`** — a hand-written `vajra.varta` companion was built then dropped (a second copy drifts + loses config). verify-session-19.sh green. *Follow-ups: render `.ai/` → `.varta` (generated, drift-free) + wire into `vajra init`.*

8. **[x] The co-pilot loader** — DONE in Session 21. `⚡on(cond) ⚡include "files"` fires via a PreToolUse hook (`scripts/hook-copilot-loader.sh`) reading `copilot.on` rules from the live `.ai/CONSTRAINTS.yaml`. **Gate answered: Varta ENFORCES** — L2/L3 block the tool (exit 2) until the context is surfaced; L1 advises. Proven live (blocked a real `git commit`). verify-session-21.sh green (10/10). [PR #11](https://github.com/ifelse-codes/vajra/pull/11). *Rider (scaffold propagation) split to item 8a.*

8a. **[x] Scaffold propagation** — DONE in Session 22. `vajra init` emits the S20 GT audits (`ground_truth:` block) + the S21 co-pilot (`copilot.on` + `hook-copilot-loader.sh` + settings wiring); every project inherits them. The hook ships via `include_str!` of the canonical script (byte-identical, no drift); `Cargo.toml` un-excludes that one file so `cargo install` compiles. verify-session-22.sh green (12/12). [PR #12](https://github.com/ifelse-codes/vajra/pull/12).

9. **[x] First-run "aha"** — DONE in Session 23. `vajra init` ends with `first_run_aha()`: it fires the just-scaffolded co-pilot once against a sample `git commit` and shows the real block + surfaced `.ai/STATE.md` (graceful fallback if bash/jq absent). Rides on `init` — no 8th command. **Closes Phase 2.** verify-session-23.sh green (11/11). [PR #13](https://github.com/ifelse-codes/vajra/pull/13).

9a. **[x] Render `.ai/` → generated `.varta`** — DONE in Session 24. `vajra check --render` renders the live `.ai/` into the 9 ⚡ constructs as a committed `vajra.varta`; plain `vajra check` drift-guards it (`varta: matches render`, the S22 `cmp` pattern). Hand-parsed (no `serde_yaml` dep), deterministic, no 8th command. The S19 deferred follow-up — closes the Varta story. verify-session-24.sh green (21/21). [PR #15](https://github.com/ifelse-codes/vajra/pull/15).

**Varta language spec (locked S18):** C/Java-inspired syntax + `⚡` keyword prefix. Constructs: `⚡project{⚡is ⚡stack ⚡goal ⚡now}`, `⚡forbid{}`, `⚡require{}`, `⚡max{}`, `⚡pipeline{}`, `⚡final{}`, `⚡on(cond) ⚡include "files"` (the co-pilot), `⚡assert{}`, `⚡enum next{}`. `//` comments = the human-glanceable *why*. Mechanism = **skill, not compiler** — the agent reads/writes it, nothing parses it.

### Phase 3 — Ship it — COMPLETE

10. **[x] Installer / release path** — DONE in Session 13. `cargo install vajractl`, Homebrew formula, GitHub Actions CI + release workflow (3 targets), README install section. [PR #1](https://github.com/ifelse-codes/vajra/pull/1).

11. **[x] Maturity levels** — DONE in Session 14. `maturity: L1|L2|L3` in CONSTRAINTS.yaml. L1 = report-only (warn, exit 0). L2 = gated (block, human approval). L3 = auto (skip confirm on advance). Wired into check, init, next, and hooks. [PR #2](https://github.com/ifelse-codes/vajra/pull/2).

12. **[x] Clean legacy references** — DONE in Session 16. Removed `vajra launch` alias from match arm, help text, enum. [PR #4](https://github.com/ifelse-codes/vajra/pull/4).

13. **[x] Pre-run cost estimate** — DONE in Session 17. `vajra estimate` reads context files, estimates tokens, prices against Opus rates, warns on budget. ADR-0005. [PR #6](https://github.com/ifelse-codes/vajra/pull/6).

### Next leap (S25 GT verdict — in priority order)

1. **Enforce one-session-per-chat** *(S26 — picked)* — record the Claude `session_id` that opens each vajra-session; a maturity-gated hook refuses to start session N+1 from the same chat ("open a new chat first"). Closes the gap that AGENTS.md step 10 is convention-only (S23 finding). `prompts/26-task-chat-guard.md`.
2. **Add second agent** (Codex or Cursor) — **#1 north-star gap (S25 GT).** The only wedge pillar with zero code; proves ADR-0002's adapter contract is genuinely vendor-neutral. Deferral condition ("until Claude is satisfying") is now met. **Must lead the S27 options.**
3. **North-star breadth indicator** (S25 meta-finding) — a RED-until-≥2-agents signal so the green dashboard can't imply health while the cross-agent gap widens.

### Backlog (after the leap)
- **Add third agent** (Aider, Gemini CLI, or Kimi) — after second agent proves the pattern.
- **Audit ledger (v2)** — git-native provenance, agent-trace format (meaningful only once ≥2 agents exist).
- **Canned workflow patterns** — daily triage, PR babysitter, CI sweeper. Low priority.
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
