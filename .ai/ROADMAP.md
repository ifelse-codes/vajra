# Vajra — Working Roadmap

**Updated:** 2026-07-03 · **Session 38 — Propagate the publish-guard into `vajra init` (CODE) — DONE.** `src/cli/init.rs` now scaffolds `hook-publish-guard.sh` into `.ai/hooks/` via `include_str!` (byte-identical, the S29 one-source pattern), wired into `TPL_CLAUDE_SETTINGS`'s PreToolUse Bash array beside the session-guard; `Cargo.toml` un-excludes it so `cargo install` compiles it. **Every scaffolded project now inherits the block** on `git push` / `gh pr create` / `gh pr merge` — the S36 leak closed where it actually happened. **Proved E2E:** a real `vajra init` into a temp repo scaffolds the guard byte-identical and the scaffolded copy blocks a `git push` payload at L2 (exit 2), allows with `VAJRA_ALLOW_PUBLISH=1`. `verify-session-38.sh` 19/19 green; 3 files. **New finding:** the guard over-blocks — a trigger phrase inside a `git commit -m` message false-blocks (hit live; worked around with `git commit -F`). Report: `sessions/session-38-summary.md`. **Next = S39 (founder combined A+B): harden the guards** — B (fix the publish-guard false-positive) then A (arm the session-guard on any advance) — `prompts/39-task-harden-guards.md`. Git-level `pre-push` split off; compression fail-gate renumbered to `prompts/41-task-fix-compression-exit-gate.md`.

**Prior · Session 37 — Close the enforcement leak (CODE) — DONE.** Shipped `scripts/hook-publish-guard.sh` (PreToolUse Bash): `git push` / `gh pr create` / `gh pr merge` / `glab mr *` now **BLOCK at L2/L3 (exit 2)** unless the founder set `VAJRA_ALLOW_PUBLISH=1`; L1 advises; innocuous git passes. Approval = env var (the agent can't mutate the hook's launch env). Proved live (blocked the agent's own push). 22/22 green; repo-only. `prompts/37-task-enforce-session-boundaries.md`.

**Prior · Session 34 — Brownfield onboarding (CODE) — DONE.** Closed S31 finding #3, the last of the three core breakages (third *advised → enforced* instance): `vajra init` detects an existing codebase and boots it into a guided **session 00** (study the repo, fill KNOWLEDGE/STATE with reality) via `prompts/00-task-brownfield-onboarding.md`; scaffolded hooks moved to `.ai/hooks/` (out of the project's own `scripts/`); `vajra claude` gained a presence-only auth pre-check (fail fast, `VAJRA_SKIP_AUTH_CHECK=1` bypass — the S18 gap). verify 11/11 incl. E2E of the built binary on real-shaped repos + real brownfield copies (`darpan`, `TradingAgents`). PR [#29](https://github.com/ifelse-codes/vajra/pull/29). **New finding, out of scope:** an existing `.claude/settings.json` is skipped on init → scaffolded hooks never wired; needs a merge strategy. **Next = S35 GROUND TRUTH (NO-CODE, mandated), lens A: bet verification + second-agent gate re-measure.**

**Prior · Session 33 — Compression schema fix (CODE) — DONE.** Fixed S31 finding #2: `HookInput` no longer forces `camelCase` on its top-level keys, so it now parses real Claude Code's snake_case envelope (`tool_name/tool_input/tool_response`) instead of silently failing and passing through — zero savings since S03/S07, now fixed and regression-tested against a verbatim real-shaped payload. `HookToolResponse` keeps `camelCase` (its nested keys really are camelCase); `exit_code` stays `Option`. verify 9/9. Founder resolved the S32-deferred build-order fork in favor of the pinned fix over promoting the 2026-07-01 obedience-metric discovery (stays in Backlog). **New finding, out of scope:** `cargo`/`npm`/`pytest` heuristics key off `exit_code == Some(0)` directly rather than inferred success, and real CC never sends `exit_code` — so those three heuristics still won't fold typical output; only line-count-driven paths do today. **Next = S34 brownfield onboarding (S31 #3).**

**Prior · Session 31 — DOGFOOD / verification (CODE).** Ran the real `vajra claude` loop against an existing TS monorepo (`chitra`) — first real usage since S07. **Gate verdict: DO NOT promote the second agent.** Three shipped `[x]`-done features are dead in the real loop (the S30 false-green shape, proven 3×), **ranked by daily founder satisfaction**: (1) **Darshan not obeyed** (felt every reply — prose pointer, not enforced; agent dumps walls of text); (2) **compression never fires** on real CC (snake_case top-level vs the adapter's camelCase `HookInput` — pinned against a captured payload; low daily $ impact); (3) **brownfield onboarding unguided** (init works on existing repos but no learn-the-codebase session; hooks pollute the project's `scripts/`). **Meta:** 2 of 3 are Vajra violating its own "enforcement, not prompts" wedge. **Fix the core before adding breadth; S32 starts with Darshan.** Findings recorded option-C (docs only, no fix committed — 1-story discipline). See KNOWLEDGE S31. *(S30 context: gate was UNMEASURED at ~$0.46 spend; S31 measured it.)*

**North star:** `vajra next` as the cross-agent workflow coach. One command that advances the agent to the next step with the right context.

**Wedge against GSD/SuperClaude:** enforcement, not prompts. GSD is a prompt library (64k stars, 10 agents, no enforcement). SuperClaude is a Claude-only prompt library (context bloat is its fatal flaw). Vajra is a Rust binary that actually enforces rules, meters cost honestly, and fails closed. Ship narrow, ship enforced, show receipts.

## Where We Are

| Field | Value |
|---|---|
| Today | 2026-07-03 |
| Current phase | **Closing the S36 enforcement leak.** S37 shipped the publish-guard (repo-only); S38 propagated it into `vajra init` (scaffolded projects now covered). Next = harden the guards (S39): fix the over-block false-positive + arm the boundary on any advance |
| Last closed session | Session 38 — publish-guard now scaffolds into `vajra init` (byte-identical `include_str!`, wired into settings, `cargo install`-safe); proved E2E (scaffolded guard blocks a push at L2); 19/19 green; 3 files |
| Active session | None — S38 closed; S39 (harden the guards, founder combined A+B) not yet started |
| Crate | package `vajractl` · binary `vajra` |

## What Works Today

| Component | Status |
|---|---|
| Engine trait + heuristics | [x] done — compresses cargo/git/npm/pytest output, tests pass against fixtures |
| Claude Code hook adapter | [x] done — reads CC PostToolUse JSON, returns compressed output |
| Launcher + settings injector | [x] done — merges hook config, spawns `claude --settings <tmpfile>` |
| `vajra claude` command | [x] done — launches Claude Code with hook injection, prints receipt on exit |
| Meter + receipt | [x] done — parses session JSONL, prints honest cost breakdown |
| `vajra init` command | [x] done — scaffolds `.ai/` + hooks (in `.ai/hooks/`, S34; **+ publish-guard S38**) + pointers + Darshan skill (21 files greenfield / 22 brownfield incl. the session-0 brief, interactive, idempotent) |
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
| Compression on real Claude Code | [x] **FIXED — S33.** `HookInput` no longer forces camelCase top-level keys; parses the real snake_case envelope. Regression-tested against a verbatim real-shaped payload. **Carry-forward:** cargo/npm/pytest heuristics still key off `exit_code == Some(0)` (real CC never sends it) — only line-count-driven paths fold today; own future session. |
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
8. **[x] Compression schema fix — DONE in Session 33.** `HookInput` drops `rename_all="camelCase"` → parses real CC's snake_case top-level envelope; `HookToolResponse` keeps camelCase (its nested keys really are); `exit_code` stays `Option`. Regression test built from a verbatim real-shaped payload reproduces the old silent-passthrough bug and confirms the fold post-fix; all pre-existing fixtures (which encoded the wrong casing) rewritten to the real shape. 2 files, exact, evidenced — restores a true product claim. verify-session-33.sh green (9/9). *(S31 #2)* **New finding, out of scope:** `cargo`/`npm`/`pytest` heuristics key off `exit_code == Some(0)` directly (real CC never sends it) — those three still won't fold typical output; candidate for a future session.
9. **[x] Brownfield onboarding — DONE in Session 34.** `vajra init` detects a brownfield repo (`is_brownfield()`: any root entry the scaffold doesn't own) → boots it into **session 00** with a guided study-the-repo brief (`prompts/00-task-brownfield-onboarding.md`; SESSION=00, TASK/BOOT pointed at it; the session-01 kickoff still carries the user's goal). Scaffolded hooks land in **`.ai/hooks/`**, never the project's own `scripts/` (per-session verify/demo scripts stay in `scripts/` — contract unchanged). `vajra claude` **auth pre-check** fails fast without credentials (presence-only: env key → `~/.claude/.credentials.json` → `oauthAccount` marker → macOS Keychain; `VAJRA_SKIP_AUTH_CHECK=1` bypass) — closes the S18 gap. Third *advised → enforced* instance. verify-session-34.sh green (11/11, E2E on real-shaped repos); verified on real brownfield copies (`darpan`, `TradingAgents`). [PR #29](https://github.com/ifelse-codes/vajra/pull/29). *(S31 #3)* **New finding, out of scope:** existing `.claude/settings.json` skipped on init → scaffolded hooks never wired (merge strategy needed; backlog).

> **Meta-finding (elevate):** 2 of 3 above are the same root failure — Vajra ships value as advisory "the agent should read this file", which the dogfood proved the agent ignores. **Vajra violates its own "enforcement, not prompts" wedge.** The fixes should each move the feature from *advised* to *enforced*.

10. **[x] Ground-truth gate re-measure (NO-CODE)** — DONE in Session 35. Lens A (founder pick): verified the "fix the core before breadth" bet + re-measured the second-agent gate. **Verdict: gate NOT cleared, still unmeasured** — zero `vajra claude` spend since S31, so S32–S34 fixes are test-verified, not daily-use-verified (same honest call as S30). Pressure-tested the *advised → enforced* wedge for structural leaks: found 2 isolated debt items (`.claude/settings.json` merge, `exit_code` heuristic), not a pattern. Ranked S36 candidates: real dogfood run (recommended) · settings.json merge · exit_code fix · obedience metric. Report: `sessions/session-35-ground-truth.md`.

### Next (S36 real-dogfood verdict — re-ranked around the enforcement leak; each its own 1-story session)

11. **[x] Real dogfood run (S36)** — DONE. Ran the real `vajra claude` loop against `/private/tmp/chitra` (agent `-p` + founder interactive). Verdict: Darshan **founder-confirmed good**; brownfield+auth **hold live**; compression **dead in real use**; **enforcement moat LEAKED** (agent shipped 2 real PRs unstopped at L3). Second-agent gate NOT cleared. `prompts/36-task-real-dogfood-run.md`; report `sessions/session-36-summary.md`.
12. **[x] Close the enforcement leak (S37)** — DONE. `scripts/hook-publish-guard.sh` (PreToolUse Bash) blocks the outward/irreversible actions the S36 agent took unstopped — `git push` / `gh pr create` / `gh pr merge` / `glab mr *` — at **L2/L3 (exit 2)** unless `VAJRA_ALLOW_PUBLISH=1` was set at launch; L1 advises; innocuous git passes. Approval = env var (agent can't mutate the hook's launch env), escape hatch mirrors `VAJRA_SKIP_AUTH_CHECK`. Proved live (blocked the agent's own `git push`). Slice = the outward-actions guard (the recommended primary slice); boundary-hardening = the other slice, still open. verify 22/22, no `src/` change, 3 files. `prompts/37-task-enforce-session-boundaries.md`. **Repo-only — see #13.**
13. **[x] Propagate the guard into `vajra init` (S38 — founder pick A) — DONE.** `src/cli/init.rs`: `TPL_HOOK_PUBLISH_GUARD = include_str!("../../scripts/hook-publish-guard.sh")` (byte-identical) + emit to `.ai/hooks/` (executable) + `TPL_CLAUDE_SETTINGS` PreToolUse Bash wiring beside the session-guard; `Cargo.toml` un-excludes the hook. 2 scaffold tests + E2E (a real `vajra init` scaffolds the guard byte-identical and it blocks a push at L2). verify-session-38.sh 19/19; 3 files. `prompts/38-task-propagate-publish-guard.md`. **Git-level `pre-push` split off** (belt-and-suspenders L2 layer — follow-on). **New finding → S39 B:** the guard over-blocks on a trigger phrase inside a commit message.
14. **[ ] Harden the guards (S39 — founder combined A+B, deliberate `max 1 story` override)** — **B first:** fix the publish-guard false-positive found in S38 (match the leading command token, not the whole command string — a `git commit -m "…git push…"` message currently false-blocks). **Then A:** arm the session-guard on *any* advance (`SESSION` bump / `vajra next --advance`), not just `git checkout -b`, so the brownfield 00→01 jump can't blow the boundary unstopped (the S36 root cause). Ordered so B banks first if the 2h cap hits mid-A; A splits to S41 if it grows. `prompts/39-task-harden-guards.md`.
15. **[ ] S40 — mandatory NO-CODE ground-truth** (every 5th; last = S35). Lens TBD at boot.
16. **[ ] Fix the compression fail-gate, correctness-first (S41, leading post-GT candidate)** — unblock the safe format-aware folds (git\*) regardless of `exitCode`; keep the generic path conservative; **never hide a failure** (founder directive). Proven defect, but the quiet bonus — behind the enforcement work. `prompts/41-task-fix-compression-exit-gate.md` (renumbered 39→41).
17. **[ ] Git-level `pre-push`/`pre-commit` scaffolding** (split from S38) — scaffold a tracked `.githooks/pre-push` + `git config core.hooksPath` as a belt-and-suspenders L2 layer on scaffolded projects. No prompt yet.
18. **[ ] Trim the boot-packet cost** — the heavy constitution drove ~$32 cache-read of a $58 session; move toward the "<5% footprint" rule now that compression is shown to save ~$0. No prompt yet.

### Backlog (parked until the gate is measured + cleared by the founder)
- **Scaffold git-level `pre-push`/`pre-commit` into `vajra init`** (S36) — the vajra repo has them; scaffolded projects don't, so nothing stops push/merge there.
- **Budget cap didn't bite** (S36) — a single interactive session ran to $58 under a $5 warn cap (checked after exit; warn never kills). Reconsider per-session vs cumulative + kill-mode.
- **Silent-parse-failure blindness** (S36) — the compression hook fails open with no signal when a payload won't parse (same shape that hid the S31 bug); `#[serde(default)]` the non-optional fields + surface a 0-fold/parse-fail warning.
- **`.claude/settings.json` merge on init** (S34 finding) — a brownfield repo that already has `.claude/settings.json` gets it *skipped*, so the scaffolded `.ai/hooks/` are never wired. Needs a merge strategy (same class as the launcher's `--settings` merge, ADR-0003). 1-story candidate; S35 GT ranks it.
- **`exit_code == Some(0)` heuristic gap** (S33 finding) — `cargo`/`npm`/`pytest` heuristics key off a field real CC never sends for Bash → they fall to `_fail` passthrough under 400 lines; should key off the engine's inferred success. 1-story candidate; S35 GT ranks it.
- **Obedience metric + trace-mined co-pilot pace-notes** (2026-07-01 headroom discovery, founder-ranked — NOT scheduled; does not displace the pinned S33 compression fix). On-wedge (deepens the co-pilot/enforcement pillar) and closes the S30/S31 "no metric measures usage" gap. Staged, one story each: **(0)** measure obedience % = clean ÷ (clean+blocked/retried) from the trace; **(1)** mine repeated blocks (headroom `learn` as a *look-only* detector) → missing `⚡on` **L1 advisories** + automate 2–3 worst habit-wastes (30→80); **(2)** promote the load-bearing checkable rules L1 advise → **L2/L3 block** (80→~100); **(3)** judgment/style frontier (Darshan `Stop`-heuristic, best-effort). **Never `--apply` headroom** (its prose writes drift from `.ai/`). Writeup: `sessions/discovery-2026-07-01-headroom.md`; KNOWLEDGE 2026-07-01. **Refinements (claude-mem study, 2026-07-01 — `thedotmack/claude-mem` uses SessionStart+UserPromptSubmit+PostToolUse+Stop+SessionEnd; it injects context *mid-run*, not boot-only):** (a) **mid-run cadence** — wire the two hooks Vajra ignores today (`UserPromptSubmit`, `PostToolUse`) so the co-pilot can murmur *between* tripwires, not only on PreToolUse blocks; keep each injection tiny (honors the <5% footprint rule). (b) **learn *when* to speak** — don't hard-code cadence; start on triggers, then tune from feedback (founder now, users post-release), mem0-style. (c) **capture+compress = the pace-note source** — past sessions → small notes the co-pilot reads at the right moment. (d) **NEW idea — the every-5th NO-CODE (ground-truth) session also compresses + reorganizes the accumulated notes/memory** (docs-only, allowed under NO-CODE) so the co-pilot's notes stay small instead of bloating over time.
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
