# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S35 GT complete, S36 not yet started).

## Active PRs
- None open. S34 brownfield-onboarding PR [#29](https://github.com/ifelse-codes/vajra/pull/29) — merged. S33 compression-schema-fix PR #27 — merged. S32 Darshan-enforcement PR #24 — merged. S31 dogfood docs PR #23 — merged (`79ad2fb`). S29 guard-in-init PR #21 — merged (`8c3c832`).
- S35 is GT (NO-CODE): docs-only `.ai/` sync, no PR.

## Direction (set S18 … audited S25, hardened S26, human-lane S27, in-init S28/S29, gate-audited S30, dogfood-measured S31, Darshan-enforced S32, compression-enforced S33, brownfield-guided S34, gate-reaudited S35)
- **Reframe: co-pilot, not cop** — guide the agent in real time (ADAS / F1 race engineer), not catch mistakes after.
- **Two speaking skills, two lanes:** **Varta** = the agent talks to itself over the live `.ai/` (⚡ language, skill not compiler). **Darshan** = the user *sees* (glanceable, surface-adaptive; skill not renderer). The agent thinks in Varta; the human gets Darshan.
- **Second agent launcher stays parked** (S26 founder override) — gated on founder satisfaction with Vajra-on-Claude, not the audit's call. S31 measured the gate: fix the 3 core breakages first. **S35 re-measured it: still parked, still unmeasured** (zero `vajra claude` spend since S31).
- **ALL THREE S31 core breakages closed:** S32 #1 Darshan enforced · S33 #2 compression schema fixed · S34 #3 brownfield onboarding guided. Each fix moved a feature *advised → enforced* (the meta-rule, 3 instances — Vajra's own wedge). **S35 pressure-tested the wedge for structural leaks: 2 isolated debt items found (settings.json merge, exit_code heuristic), not a pattern.**
- **S35 GT verdict (lens A): gate NOT cleared.** Test-verified ≠ daily-use-verified. Recommendation: S36 = a real dogfood session before anything else, including the second agent.

## What Currently Works
- **Brownfield onboarding (S34)** — `vajra init` detects an existing codebase (`is_brownfield()`: any root entry the scaffold doesn't own) → session 00 with a guided study-the-repo brief (`prompts/00-task-brownfield-onboarding.md`); `SESSION`/`TASK.md`/`SESSION-BOOT.md` point at it; KNOWLEDGE/STATE get filled from observed reality before feature work. Scaffolded hooks land in `.ai/hooks/` (never the project's own `scripts/`). `vajra claude` fails fast without credentials (presence-only layers: env key → credentials file → `oauthAccount` marker → macOS Keychain; `VAJRA_SKIP_AUTH_CHECK=1` bypass). verify-session-34.sh green (11/11) incl. E2E of the built binary on real-shaped repos; verified on real copies of `darpan` + `TradingAgents`.
- **Compression fires on real Claude Code (S33)** — `HookInput` parses the real snake_case envelope; regression-tested against a verbatim real-shaped payload. Line-count-driven heuristics fold (git log/status/diff-stat, generic head+tail, ≥400-line output).
- **Darshan enforced (S32)** — boot packet prints the directive (one rule + skill pointer + `▶ ACK NOW`); `vajra init` embeds via `include_str!`.
- **Ground-truth hardening (S30) + re-run (S35)** — `dogfood_check` audit + questions proved out twice now: both times caught an unmeasured gate the other 7 audits missed.
- `vajra claude` · `vajra next` · `vajra check` · `vajra init` (20 files greenfield / 21 brownfield) · `vajra estimate` · `vajra meter`. Co-pilot loader (S21) fired live on this session's `git commit`. CI green. `cargo test` 133 pass (110 lib + 23 integration), clippy clean — unchanged this session (NO-CODE).

## What Is Broken
> All three S31 core breakages are FIXED (S32/S33/S34), but **unverified by daily use** (S35 finding).
- **🟡 `.claude/settings.json` merge gap (found S34, not fixed)** — a brownfield repo that already has `.claude/settings.json` gets it *skipped* on init → the scaffolded hooks in `.ai/hooks/` are never wired. Needs a merge strategy (same class as the launcher's `--settings` merge). **S35-ranked #2 for S36.**
- **🟡 `cargo`/`npm`/`pytest` heuristics key off `exit_code == Some(0)` (found S33, not fixed)** — real CC never sends `exit_code` for Bash, so those three fall to their `_fail` branch (passthrough unless ≥400 lines). Only line-count-driven paths genuinely fold today. **S35-ranked #3 for S36.**
- **Dogfood gap (S35 headline finding):** ~$0 `vajra claude` spend since S31 — satisfaction gate is unmeasured by definition, same as S30. **S35-ranked #1 for S36 (highest leverage).**
- Second agent launcher (the north-star gap) stays parked until the founder clears the gate — still unmeasured after S35.
- **Co-pilot v0 limits** — simple-glob + `cmd:` substring (no `**`/regex); surfaces paths + why, not file contents.
- **No `serde_yaml` dep** — hooks + the varta renderer hand-parse `CONSTRAINTS.yaml` line-by-line.
- `vajra estimate` output ratio (3:1) is unvalidated placeholder.

## What Is In Progress
- **S35 GT DONE + closed.** Report: `sessions/session-35-ground-truth.md`. Gate call: NOT cleared, still unmeasured. **Next session (S36)** = founder picks option A (recommended: real dogfood run) / B (settings.json merge) / C (exit_code fix) from the report, in a **new chat**.

## Cost Tracking
- Session 00–05: $0.00 (no API calls)
- Session 06: $0.00 (docs only)
- Session 07: ~$0.46 (3 test runs via `vajra claude -p`)
- Session 08–30: ~$0.00 (code/no-code sessions, no API calls)
- Session 31: first real spend since S07 — a live `vajra claude` session in `chitra` (receipt to stderr, exact $ not captured).
- Session 32–35: ~$0.00 (Rust code sessions + S35 GT docs-only — build/test/verify only, no live agent runs).
- Cumulative: ~$0.46 + S31 dogfood run. **Zero spend for 4 consecutive sessions (S32–S35) — the dogfood gap the S35 GT flagged.**
