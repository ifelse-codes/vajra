# Vajra — Working Roadmap

**Updated:** 2026-07-01 · **Session 32 — Darshan enforcement (CODE) — DONE.** Moved Darshan *advised → enforced*: the `SessionStart` boot packet now surfaces the skill (one rule + `darshan/SKILL.md` pointer + `▶ ACK NOW` speak-back) every session, and `vajra init` inherits it byte-identical via `include_str!`. Closes S31 finding #1 (most-felt). verify 18/18. [PR #24](https://github.com/ifelse-codes/vajra/pull/24). **Next = S33 compression schema fix (S31 #2).**

**Prior · Session 31 — DOGFOOD / verification (CODE).** Ran the real `vajra claude` loop against an existing TS monorepo (`chitra`) — first real usage since S07. **Gate verdict: DO NOT promote the second agent.** Three shipped `[x]`-done features are dead in the real loop (the S30 false-green shape, proven 3×), **ranked by daily founder satisfaction**: (1) **Darshan not obeyed** (felt every reply — prose pointer, not enforced; agent dumps walls of text); (2) **compression never fires** on real CC (snake_case top-level vs the adapter's camelCase `HookInput` — pinned against a captured payload; low daily $ impact); (3) **brownfield onboarding unguided** (init works on existing repos but no learn-the-codebase session; hooks pollute the project's `scripts/`). **Meta:** 2 of 3 are Vajra violating its own "enforcement, not prompts" wedge. **Fix the core before adding breadth; S32 starts with Darshan.** Findings recorded option-C (docs only, no fix committed — 1-story discipline). See KNOWLEDGE S31. *(S30 context: gate was UNMEASURED at ~$0.46 spend; S31 measured it.)*

**North star:** `vajra next` as the cross-agent workflow coach. One command that advances the agent to the next step with the right context.

**Wedge against GSD/SuperClaude:** enforcement, not prompts. GSD is a prompt library (64k stars, 10 agents, no enforcement). SuperClaude is a Claude-only prompt library (context bloat is its fatal flaw). Vajra is a Rust binary that actually enforces rules, meters cost honestly, and fails closed. Ship narrow, ship enforced, show receipts.

## Where We Are

| Field | Value |
|---|---|
| Today | 2026-06-30 |
| Current phase | Phases 1–3 + Varta + propagation COMPLETE; **fixing the core (S31 items 7–9): S32 Darshan enforcement DONE**; next = S33 compression schema fix, then S34 brownfield |
| Last closed session | Session 32 — Darshan enforcement: boot packet now surfaces `darshan/SKILL.md` (one rule + speak-back) every session + `vajra init` inherits it via `include_str!`; advised → enforced. verify 18/18. PR #24 |
| Active session | None — S32 closed; S33 (compression schema fix) not yet started |
| Crate | package `vajractl` · binary `vajra` |

## What Works Today

| Component | Status |
|---|---|
| Engine trait + heuristics | [x] done — compresses cargo/git/npm/pytest output, tests pass against fixtures |
| Claude Code hook adapter | [x] done — reads CC PostToolUse JSON, returns compressed output |
| Launcher + settings injector | [x] done — merges hook config, spawns `claude --settings <tmpfile>` |
| `vajra claude` command | [x] done — launches Claude Code with hook injection, prints receipt on exit |
| Meter + receipt | [x] done — parses session JSONL, prints honest cost breakdown |
| `vajra init` command | [x] done — scaffolds `.ai/` + hooks + pointers + Darshan skill (18 files, interactive, idempotent) |
| `vajra next` (read-only + advance) | [x] done — prints packet or advances session via `--advance` |
| Installer / release pipeline | [x] done — S13: `cargo install vajractl`, GitHub Actions CI + release (3 targets) |
| Maturity levels L1/L2/L3 | [x] done — S14: L1 report / L2 gated / L3 auto, wired into check, init, next, hooks |
| Darshan (human's glanceable output skill) | [x] done — S27: `darshan/SKILL.md` + AGENTS.md boot pointer; skill, not renderer; 3 surface tiers |
| One-session-per-chat guard | [x] done — S26: `hook-session-guard.sh` blocks N→N+1 in the same chat; **propagated into `vajra init` S29 (PR #21)** |

## What Does NOT Work Yet

| Component | Status |
|---|---|
| Darshan in `vajra init` scaffold | [x] done — S28: `include_str!` + Speaking Skills boot pointer; every project inherits it (PR #19) |
| Second agent launcher | [ ] not built — only Claude Code is wired (**parked**: **S31 dogfood decided the gate → do NOT promote** until the 3 core breakages are fixed) |
| Compression on real Claude Code | [ ] **BROKEN** — adapter `HookInput` camelCase vs real CC snake_case; never fires (S31). Tests green on wrong-cased fixtures. Fix = item 8 (S33) |
| Darshan obeyed in real sessions | [x] **ENFORCED — S32.** Boot packet surfaces the skill (one rule + `darshan/SKILL.md` pointer + `▶ ACK NOW` speak-back) every session; `vajra init` inherits it via `include_str!`. Machine-verified speak-back = follow-on. |

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

### Next leap (re-ranked S26 — USER override of the S25 audit)

> **S26 owner decision:** the second agent is **parked back in the backlog.** The S25 audit
> declared "Claude experience is satisfying → promote second agent." The owner disagrees:
> **Vajra-on-Claude is NOT yet satisfying.** The gate is the owner's judgment, not the audit's.
> Next sessions deepen/polish the Claude experience until the owner declares it satisfying;
> only then does the second agent return to #1.

1. **[x] Enforce one-session-per-chat** — DONE in Session 26. `scripts/hook-session-guard.sh` (PreToolUse Bash) records the Claude `session_id` that owns each vajra-session in a gitignored `.ai/.session-owner`; blocks `git checkout -b session-(N+1)-*` from the same chat that owns N (exit 2, "open a new chat first"). Maturity-gated (L1 advise / L2-L3 block), gated on `one_session_per_chat: true`. No 8th command. Closes the AGENTS.md step-10 convention gap (S23 finding). verify-session-26.sh green (13/13). Scaffold propagation to `vajra init` deferred to S27.
2. **[x] Darshan — the human's lane** — DONE in Session 27. `darshan/SKILL.md`: skill, not a renderer (like Varta). One rule: *"render the richest visual this surface can handle; always glanceable; never drop meaning."* 3 tiers: rich chat (HTML/SVG) · terminal (ANSI/box-drawing) · plain (structured markdown), with worked before/after for chat + terminal. Boot-wired via a *Speaking Skills* pointer in `.ai/AGENTS.md` (default human output). `VISION.md` gained the human lane. No 8th command, no `src/` change. Name **Darshan** confirmed at BOOT. verify-session-27.sh green (18/18). [PR #18](https://github.com/ifelse-codes/vajra/pull/18). *Propagation to `vajra init` deferred to S28.*
3. **[x] Propagate Darshan into `vajra init`** — DONE in Session 28. `src/cli/init.rs`: `TPL_DARSHAN = include_str!("../../darshan/SKILL.md")` + emit `darshan/SKILL.md` (byte-identical) + a **Speaking Skills (Load at Boot)** section in `TPL_AGENTS`. Scaffold 17 → 18 files. No `Cargo.toml` change (`darshan/` already ships), no 8th command, no new dep, no `src/` renderer. 2 new scaffold tests. **Darshan-only** (the prompt's pre-authorized scope-split — the session-guard half = S29). verify-session-28.sh green (12/12). [PR #19](https://github.com/ifelse-codes/vajra/pull/19).
4. **[x] Propagate the session-guard into `vajra init`** — DONE in Session 29. `src/cli/init.rs`: `TPL_HOOK_SESSION_GUARD = include_str!("../../scripts/hook-session-guard.sh")` (byte-identical, executable) + emit + PreToolUse(Bash) wiring + `one_session_per_chat: true` in `TPL_CONSTRAINTS` + a new `TPL_GITIGNORE` (`.ai/.session-owner`); `Cargo.toml` un-excludes the hook so `cargo install` compiles. Scaffold 18 → 20 files; the scaffolded guard actually enforces (exit 2). No 8th command, no new dep, no `src/` guard logic. 4 new scaffold tests. verify-session-29.sh green (19/19). [PR #21](https://github.com/ifelse-codes/vajra/pull/21). **Closes the S28 split — propagation arc (S22+S28+S29) complete.**
5. **[x] S30 — ground-truth (NO-CODE)** — DONE. Founder-satisfaction gate: **verdict = defer the second agent, the gate is UNMEASURED** (`vajra claude` unrun since S07). Hardened `ground_truth.required_audits` with a **`dogfood_check`** axis; retired the PR-status "drift". Report: `sessions/session-30-ground-truth.md`.
6. **[x] Dogfood / verification session (S31)** — DONE. Ran the real loop against existing `chitra` repo. **Verdict: do NOT promote the second agent — the core Claude loop is broken in 3 places** (below). Findings recorded (option C, docs only). `prompts/31-task-dogfood-verification.md`.

### Next (S31 dogfood verdict — fix the core, **ranked by daily founder satisfaction**, not fix-convenience; each its own 1-story session)

7. **[x] Darshan enforcement — DONE in Session 32.** The `SessionStart` boot hook (`scripts/hook-session-start.sh`) now prints a Darshan directive into every boot packet: the one rule (inlined) + `darshan/SKILL.md` pointer + a `▶ ACK NOW` speak-back (mirrors Varta's read→internalize→speak). `src/cli/init.rs`: `TPL_HOOK_SESSION_START` inline copy → `include_str!` of the canonical hook (kills the pre-existing drift; S22/S28/S29 pattern); `Cargo.toml` un-excludes it. **advised → enforced** (the meta-rule). Follow-on (documented, not built): a `Stop`-hook wall-of-text heuristic for machine enforcement. verify-session-32.sh green (18/18). [PR #24](https://github.com/ifelse-codes/vajra/pull/24). *(S31 #1)*
8. **Compression schema fix (S33 — next)** — `HookInput` drops `rename_all="camelCase"` → snake_case top-level; keep camelCase on `HookToolResponse`; add a regression test from a **verbatim captured real CC payload**. 2 files, exact, evidenced — restores a true product claim. Ranked #2 (low daily $ impact — the "quiet bonus", not the moat). *(S31 #2)*
9. **Brownfield onboarding** — a guided "session 0: study this existing codebase, fill KNOWLEDGE + STATE" kickoff template; rethink hook placement so they don't land inside the project's own `scripts/` package; add the S18 `vajra claude` auth pre-check. *(S31 #3)*

> **Meta-finding (elevate):** 2 of 3 above are the same root failure — Vajra ships value as advisory "the agent should read this file", which the dogfood proved the agent ignores. **Vajra violates its own "enforcement, not prompts" wedge.** The fixes should each move the feature from *advised* to *enforced*.

### Backlog (parked until the gate is measured + cleared by the founder)
- **Add second agent** (Codex or Cursor) — **the north-star gap (S25 GT), owner-gated.** Only wedge pillar with zero code; proves ADR-0002's adapter contract is vendor-neutral. Returns to #1 **only when the founder declares Vajra-on-Claude satisfying** — gate now **unmeasured** (S30); S31 measures it.
- **North-star breadth indicator** (S25 meta-finding) — a RED-until-≥2-agents signal so the green dashboard can't imply health while the cross-agent gap widens. Pairs with the second agent.
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
