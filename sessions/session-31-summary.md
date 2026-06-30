# Session 31 — Dogfood / Verification (CODE → docs-only, option C)

## Goal
Run a real unit of work through `vajra claude` (first real usage since S07), capture the lived experience, and render the founder-satisfaction gate verdict with evidence — honoring the S30 `dogfood_check` axis.

## Goal achieved? — YES (verdict rendered, with stronger evidence than expected)

The dogfood was run **from the founder's own terminal** against a **real existing codebase** (`chitra`, a TypeScript pnpm monorepo copied from `~/Downloads/Chitra`, 4.2M, real git history) — `vajra init` into it, then `vajra claude` driving a "learn this codebase" session. The run surfaced **three** shipped `[x]`-done features that are **dead in the real loop**, not one.

## Evidence

| Finding | Evidence | Severity (daily satisfaction) |
|---|---|---|
| **#1 Darshan not obeyed** | Agent dumped walls of dense text (founder-observed, saved terminal capture). Root cause: Darshan is wired only as a prose pointer in `.ai/AGENTS.md`; the `SessionStart` boot hook never surfaces `darshan/SKILL.md`; it is not a registered CC skill. Nothing enforces it. | 🔴 felt **every reply** |
| **#2 Compression never fires** | A **captured real CC PostToolUse payload** proves the schema: snake_case top-level (`tool_name`/`tool_input`/`tool_response`/`session_id`/`tool_use_id`/`duration_ms`), camelCase only inside `tool_response` (`isImage`/`noOutputExpected`, **no `exitCode`**). The adapter's `HookInput` has `#[serde(rename_all="camelCase")]` → expects `toolName` → parse-fail → silent `{}` passthrough. Empirically: camelCase top-level folds the 181-line cargo fixture → 1 line; snake_case → passthrough. 98 tests green because fixtures encode the wrong casing. | 🔴 invisible; false claim (low daily $) |
| **#3 Brownfield onboarding unguided** | `vajra init` works on an existing repo (correctly **skipped** the existing `.gitignore`) but the kickoff is generic — no "learn the codebase" session — leaving the founder at "not sure what now"; scaffolded hooks land inside the project's own `scripts/` (a pnpm package in `chitra`). S18 auth pre-check gap reconfirmed. | 🟡 once per project |

**Meta-finding (elevated):** 2 of 3 are the same root failure — Vajra ships value as advisory *"the agent should read this file"*, which the dogfood proved the agent ignores. **Vajra violates its own "enforcement, not prompts" wedge.** Every fix must move the feature from *advised* → *enforced*.

## Gate verdict
**DO NOT promote the second agent.** Not for lack of breadth — because the core Vajra-on-Claude loop is broken in three places. Fix the core first. (Updates `vajra-second-agent-gate` memory; the dogfood is the canonical evidence the `dogfood_check` axis demanded.)

## What shipped this session
- **Docs only (option C):** findings recorded + re-ranked by satisfaction across `.ai/KNOWLEDGE.md` (permanent: the captured schema + 3 findings + exact fixes), `.ai/STATE.md` (snapshot), `.ai/ROADMAP.md` (items 7–9, Darshan first). No source code changed; no fix committed (1-story / ≤3-file discipline).
- Install reality logged: `cargo install vajractl` is not the working path (crates.io name taken) → `cargo install --path <repo>`.

## Cost
First real spend since S07 — a live `vajra claude` session in `chitra` (14 Bash tool-calls captured). Exact receipt $ not captured (founder exited before recording). The S30 "built-with-Claude, never run-through-vajra" finding is now closed.

## Next — 3 options (from ROADMAP, ranked by daily satisfaction)

- **A) Darshan enforcement (RECOMMENDED — founder-locked #1).** Goal: make the agent load + follow `darshan/SKILL.md` every session. Why pick: it's the most-felt pain (every reply) and closes the "we violate our own wedge" gap. Key risk: enforcing an output-style skill is a design problem — a hook can't read the agent's prose; the minimum (surface it at boot) may not be strong enough.
- **B) Compression schema fix.** Goal: `HookInput` → snake_case top-level + regression test from the captured payload. Why pick: exact, evidenced, 2 files, restores a true product claim. Key risk: low daily impact — fixes a claim, not a felt pain.
- **C) Brownfield onboarding.** Goal: a guided "learn-the-codebase" first session + fix hook placement + auth pre-check. Why pick: onboarding onto existing code is the primary real use case. Key risk: largest scope of the three; design-bearing.

**Locked:** S32 = option A (Darshan enforcement). Prompt written: `prompts/32-task-darshan-enforcement.md`.
