# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S33 complete, S34 not yet started).

## Active PRs
- S33 compression-schema-fix PR — pending (open after closeout).
- S32 Darshan-enforcement PR #24 — merged. S31 dogfood docs PR #23 — merged (`79ad2fb`). S29 guard-in-init PR #21 — merged (`8c3c832`). S28 Darshan-in-init PR #19 — merged (`c65fc10`).

## Direction (set S18 … audited S25, hardened S26, human-lane S27, in-init S28/S29, gate-audited S30, dogfood-measured S31, Darshan-enforced S32, compression-enforced S33)
- **Reframe: co-pilot, not cop** — guide the agent in real time (ADAS / F1 race engineer), not catch mistakes after.
- **Two speaking skills, two lanes:** **Varta** = the agent talks to itself over the live `.ai/` (⚡ language, skill not compiler). **Darshan** = the user *sees* (glanceable, surface-adaptive; skill not renderer). The agent thinks in Varta; the human gets Darshan.
- **Second agent launcher stays parked** (S26 founder override) — gated on founder satisfaction with Vajra-on-Claude, not the audit's call. **S31 dogfood measured the gate: DO NOT promote** until the 3 core breakages are fixed.
- **S31 DOGFOOD verdict — 3 core features dead in the real loop** (S30 false-green shape, proven 3×), ranked by daily satisfaction: (1) Darshan not obeyed; (2) compression never fires; (3) brownfield unguided. **Meta:** 2 of 3 are Vajra violating its own "enforcement, not prompts" wedge. **Fix the core before breadth.** (KNOWLEDGE S31)
- **S32: finding #1 fixed — Darshan is now enforced.** **S33: finding #2 fixed — the compression schema bug is fixed** (HookInput no longer forces camelCase). Order continues: S34 brownfield (#3), then reconsider the second agent.
- **S33 build-order fork resolved:** founder chose the pinned compression fix over promoting the 2026-07-01 obedience-metric/pace-notes discovery (stays in ROADMAP Backlog, unscheduled).

## What Currently Works
- **Compression fires on real Claude Code (S33)** — `HookInput` no longer requires camelCase top-level keys; parses the real snake_case envelope (`tool_name/tool_input/tool_response`). Regression test built from a verbatim real-shaped payload reproduces the old bug (silent passthrough) and confirms the fold post-fix. verify-session-33.sh green (9/9). **advised → enforced claim → now evidenced**, closing the S03/S07 "zero savings" gap for line-count-driven heuristics (git log/status/diff-stat, generic head+tail, any ≥400-line output).
- **Darshan enforced (S32)** — `scripts/hook-session-start.sh` prints a Darshan directive into every boot packet (one rule inlined + `darshan/SKILL.md` pointer + `▶ ACK NOW` speak-back). `vajra init` embeds the canonical hook via `include_str!` (byte-identical, can't drift); `Cargo.toml` un-excludes it so it ships. verify-session-32.sh green (18/18).
- **Ground-truth hardening (S30)** — `CONSTRAINTS.yaml#ground_truth` has a **`dogfood_check`** audit + `dogfood_questions`: every future GT asks whether real work has run through `vajra claude` since the last GT (the cost ledger is the proof).
- **Session-guard in `vajra init` (S29)** + **Darshan skill in init (S28) / skill (S27)** — `include_str!` one-source propagation; the scaffolded guard actually enforces (exit 2).
- `vajra claude` · `vajra next` · `vajra check` · `vajra init` (20 files) · `vajra estimate` · `vajra meter`. Co-pilot loader (S21) fires `⚡on` mid-session (fired live on this session's `git commit`). CI green. `cargo test` green (107: 98 lib + 9 adapter), clippy clean.

## What Is Broken
> **Ranked by the gate's own lens — daily founder satisfaction — not by fix-convenience (S31 founder call).**
- ~~🔴 S31 #1 — Darshan not obeyed~~ — **FIXED S32.** Now surfaced in the boot packet every session + speak-back ACK. Machine-verified enforcement (a `Stop`-hook wall-of-text heuristic) remains a documented follow-on, not built.
- ~~🔴 S31 #2 — compression hook NEVER fires on real Claude Code~~ — **FIXED S33.** `HookInput` no longer requires camelCase top-level keys. Regression-tested against a verbatim real-shaped payload.
- **🟡 NEW (found during S33, not fixed) — `cargo`/`npm`/`pytest` heuristics key off `exit_code == Some(0)` directly**, not the engine's own inferred success — and real CC never sends `exit_code` for Bash. So those three heuristics still fall to their "\_fail" branch (passthrough unless ≥400 lines) on every real invocation, regardless of the schema fix. Only line-count-driven paths (git heuristics, generic head+tail fallback, huge output) genuinely fold today. Candidate for its own future 1-story session.
- **🟡 S31 #3 — brownfield onboarding unguided (felt once per project).** `vajra init` works on existing repos but no "learn-the-codebase" first session; hooks land in the project's own `scripts/`. Plus the S18 gap: `vajra claude` has no auth pre-check. **S34.**
- **META:** the fixes each move a feature *advised → enforced* — Vajra's own wedge. S32 (Darshan) and S33 (compression) both done this way; S34 continues.
- Second agent launcher (the north-star gap) stays parked until the core is fixed.
- **Co-pilot v0 limits** — simple-glob + `cmd:` substring (no `**`/regex); surfaces paths + why, not file contents.
- **No `serde_yaml` dep** — hooks + the varta renderer hand-parse `CONSTRAINTS.yaml` line-by-line.
- `vajra estimate` output ratio (3:1) is unvalidated placeholder.

## What Is In Progress
- **S33 DONE + closed.** Compression schema fix shipped (HookInput schema + regression tests), PR pending. **Next session (S34) = brownfield onboarding (#3)**; second agent reconsideration after that. S35 = NO-CODE ground truth. 1-story/≤3-file discipline keeps each fix to its own session.

## Cost Tracking
- Session 00–05: $0.00 (no API calls)
- Session 06: $0.00 (docs only)
- Session 07: ~$0.46 (3 test runs via `vajra claude -p`)
- Session 08–30: ~$0.00 (code/no-code sessions, no API calls)
- Session 31: first real spend since S07 — a live `vajra claude` session in `chitra` (receipt to stderr, exact $ not captured).
- Session 32: ~$0.00 (Rust code session — build/test/verify only, no `vajra claude` API run).
- Session 33: ~$0.00 (Rust code session — build/test/verify only, no `vajra claude` API run).
- Cumulative: ~$0.46 + S31 dogfood run.
