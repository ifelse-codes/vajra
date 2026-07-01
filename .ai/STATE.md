# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S32 complete, S33 not yet started).

## Active PRs
- S32 Darshan-enforcement PR [#24](https://github.com/ifelse-codes/vajra/pull/24) — open (merge after closeout).
- S31 dogfood docs PR #23 — merged (`79ad2fb`). S29 guard-in-init PR #21 — merged (`8c3c832`). S28 Darshan-in-init PR #19 — merged (`c65fc10`). S27 Darshan PR #18 — merged (`0d7d5ba`).

## Direction (set S18 … audited S25, hardened S26, human-lane S27, in-init S28/S29, gate-audited S30, dogfood-measured S31, Darshan-enforced S32)
- **Reframe: co-pilot, not cop** — guide the agent in real time (ADAS / F1 race engineer), not catch mistakes after.
- **Two speaking skills, two lanes:** **Varta** = the agent talks to itself over the live `.ai/` (⚡ language, skill not compiler). **Darshan** = the user *sees* (glanceable, surface-adaptive; skill not renderer). The agent thinks in Varta; the human gets Darshan.
- **Second agent launcher stays parked** (S26 founder override) — gated on founder satisfaction with Vajra-on-Claude, not the audit's call. **S31 dogfood measured the gate: DO NOT promote** until the 3 core breakages are fixed.
- **S31 DOGFOOD verdict — 3 core features dead in the real loop** (S30 false-green shape, proven 3×), ranked by daily satisfaction: (1) Darshan not obeyed; (2) compression never fires; (3) brownfield unguided. **Meta:** 2 of 3 are Vajra violating its own "enforcement, not prompts" wedge. **Fix the core before breadth.** (KNOWLEDGE S31)
- **S32: finding #1 fixed — Darshan is now enforced** (surfaced in the boot packet every session). Order continues: S33 compression schema fix (#2), S34 brownfield (#3), then reconsider the second agent.

## What Currently Works
- **Darshan enforced (S32)** — `scripts/hook-session-start.sh` prints a Darshan directive into every boot packet (one rule inlined + `darshan/SKILL.md` pointer + `▶ ACK NOW` speak-back). `vajra init` embeds the canonical hook via `include_str!` (byte-identical, can't drift); `Cargo.toml` un-excludes it so it ships. verify-session-32.sh green (18/18). **advised → enforced** (the meta-rule).
- **Ground-truth hardening (S30)** — `CONSTRAINTS.yaml#ground_truth` has a **`dogfood_check`** audit + `dogfood_questions`: every future GT asks whether real work has run through `vajra claude` since the last GT (the cost ledger is the proof).
- **Session-guard in `vajra init` (S29)** + **Darshan skill in init (S28) / skill (S27)** — `include_str!` one-source propagation; the scaffolded guard actually enforces (exit 2).
- `vajra claude` · `vajra next` · `vajra check` · `vajra init` (20 files) · `vajra estimate` · `vajra meter`. Co-pilot loader (S21) fires `⚡on` mid-session (**fired live on this session's `git commit` — dogfooded again**). CI green. `cargo test` green (98 lib), clippy clean.

## What Is Broken
> **Ranked by the gate's own lens — daily founder satisfaction — not by fix-convenience (S31 founder call).**
- ~~🔴 S31 #1 — Darshan not obeyed~~ — **FIXED S32.** Now surfaced in the boot packet every session + speak-back ACK. Machine-verified enforcement (a `Stop`-hook wall-of-text heuristic) remains a documented follow-on, not built.
- **🔴 S31 #2 — compression hook NEVER fires on real Claude Code.** `HookInput` has `#[serde(rename_all="camelCase")]` (expects `toolName`) but real CC sends snake_case top-level (`tool_name/tool_input/tool_response`) → parse-fail → silent `{}` passthrough. Zero savings since S03/S07; a false product claim. 98 tests green because fixtures encode the wrong casing. **Exact 2-file fix pinned vs a captured payload** (KNOWLEDGE S31) — **S33 fixes this.**
- **🟡 S31 #3 — brownfield onboarding unguided (felt once per project).** `vajra init` works on existing repos but no "learn-the-codebase" first session; hooks land in the project's own `scripts/`. Plus the S18 gap: `vajra claude` has no auth pre-check. **S34.**
- **META:** the fixes each move a feature *advised → enforced* — Vajra's own wedge. S32 was the first (Darshan); S33/S34 continue.
- Second agent launcher (the north-star gap) stays parked until the core is fixed.
- **Co-pilot v0 limits** — simple-glob + `cmd:` substring (no `**`/regex); surfaces paths + why, not file contents.
- **No `serde_yaml` dep** — hooks + the varta renderer hand-parse `CONSTRAINTS.yaml` line-by-line.
- `vajra estimate` output ratio (3:1) is unvalidated placeholder.

## What Is In Progress
- **S32 DONE + closed.** Darshan enforcement shipped (boot-packet surfacing + speak-back + `include_str!` propagation), PR #24 open. **Next session (S33) = compression schema fix (#2)**; brownfield (#3) = S34; S35 = NO-CODE ground truth. 1-story/≤3-file discipline keeps each fix to its own session.

## Cost Tracking
- Session 00–05: $0.00 (no API calls)
- Session 06: $0.00 (docs only)
- Session 07: ~$0.46 (3 test runs via `vajra claude -p`)
- Session 08–30: ~$0.00 (code/no-code sessions, no API calls)
- Session 31: first real spend since S07 — a live `vajra claude` session in `chitra` (receipt to stderr, exact $ not captured).
- Session 32: ~$0.00 (Rust code session — build/test/verify only, no `vajra claude` API run).
- Cumulative: ~$0.46 + S31 dogfood run.
