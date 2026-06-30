# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S30 complete, S31 not yet started).

## Active PRs
- None open. S30 = NO-CODE ground-truth; closeout + the pre-approved hardening rode on the exempt branch `session-30-closeout`.
- S29 guard-in-init PR #21 — merged (`8c3c832`). S28 Darshan-in-init PR #19 — merged (`c65fc10`). S27 Darshan PR #18 — merged (`0d7d5ba`). S26 chat-guard PR #17 — merged (`4956032`).

## Direction (set S18 … audited S25, hardened S26, human-lane S27, Darshan-in-init S28, guard-in-init S29, gate-audited S30)
- **Reframe: co-pilot, not cop** — guide the agent in real time (ADAS / F1 race engineer), not catch mistakes after.
- **Two speaking skills, two lanes:** **Varta** = the agent talks to itself over the live `.ai/` (⚡ language, skill not compiler; arc S19–S24 complete). **Darshan** = the user *sees* (glanceable, surface-adaptive output; skill not renderer; built S27, in `init` S28). The agent thinks in Varta; the human gets Darshan.
- **S26 founder override of the S25 audit:** the second agent launcher is **parked** — gated on *founder* satisfaction with Vajra-on-Claude, not the audit's call.
- **S30 ground-truth verdict:** the gate is **UNMEASURED, not unsatisfied.** ~$0.46 spend, all from S07; `vajra claude` has not run for real in 22 sessions, so "satisfying" is undeclarable from build-sessions. S27 (Darshan) plausibly moved daily satisfaction; S28/S29 moved *completeness*, not daily friction. **Next = measure it (S31 dogfood), then decide.** (memory `vajra-second-agent-gate`)

## What Currently Works
- **Ground-truth hardening (S30)** — `CONSTRAINTS.yaml#ground_truth` gained a **`dogfood_check`** audit + `dogfood_questions`: every future GT asks whether real work has run through `vajra claude` since the last GT (closes the meta-check blind spot — 7 green audits while the product sat un-dogfooded).
- **Session-guard in `vajra init` (S29)** — `vajra init` scaffolds `scripts/hook-session-guard.sh` (byte-identical via `include_str!`, executable) + wires it into `.claude/settings.json` PreToolUse(Bash) + emits `one_session_per_chat: true` + a `.gitignore` ignoring `.ai/.session-owner`. `Cargo.toml` un-excludes the hook. Scaffold **20 files**. The scaffolded guard actually enforces (exit 2). Propagation arc (co-pilot S22 + Darshan S28 + guard S29) complete.
- **Darshan in `vajra init` (S28)** + **Darshan skill (S27)** — `darshan/SKILL.md`, skill not renderer; 3 surface tiers; boot-wired via the *Speaking Skills* pointer in `.ai/AGENTS.md` (default human output).
- **One-session-per-chat enforcement (S26)** — `scripts/hook-session-guard.sh` blocks `git checkout -b session-(N+1)-*` from the owning chat (exit 2). Maturity-gated; gated on `one_session_per_chat: true`.
- **Render `.ai/` → `vajra.varta` (S24)** — `vajra check --render` regenerates a committed `vajra.varta`; plain `vajra check` drift-guards it.
- `vajra claude` · `vajra next` (packet / `--advance`) · `vajra check` · `vajra init` (20 files) · `vajra estimate` (3:1 placeholder) · `vajra meter`. Compression engine + 4 heuristics + meter + budget guard. Co-pilot loader (S21) fires `⚡on` mid-session (**fired live on this session's `git commit` — dogfooded**). CI green. `cargo test` green (98 lib), clippy clean.

## What Is Broken
- **The founder-satisfaction gate is unmeasured** — `vajra claude` (the product loop) has not been exercised in real work since S07; no audit measured this until the S30 `dogfood_check` axis. **S31 measures it.**
- Only Claude Code is wired — no second agent launcher (the north-star gap, **parked**; gate now unmeasured, not unsatisfied).
- **Co-pilot v0 limits** — simple-glob (`*` spans `/`) + `cmd:` substring (no `**`/regex); surfaces paths + why, not file contents; debounce keys on `session_id`.
- **No `serde_yaml` dep** — hooks + the varta renderer hand-parse `CONSTRAINTS.yaml` line-by-line.
- `vajra estimate` output ratio (3:1) is unvalidated placeholder. `vajra claude` has no auth pre-check before launch (S18 onboarding gap).

## What Is In Progress
- Nothing — between sessions. Next: **S31 — CODE: dogfood / verification.** Run real work through `vajra claude` (first real spend since S07), capture the lived experience + receipt, render the gate verdict. Read `prompts/31-task-dogfood-verification.md`.

## Cost Tracking
- Session 00–05: $0.00 (no API calls)
- Session 06: $0.00 (docs only)
- Session 07: ~$0.46 (3 test runs via `vajra claude -p`)
- Session 08–29: ~$0.00 (code/no-code sessions, no API calls)
- Session 30: ~$0.00 (NO-CODE ground-truth, no API calls)
- Cumulative: ~$0.46  ·  ⚠ this near-zero is itself the S30 finding — the product is built *with* Claude, not run *through* `vajra claude`. S31 will (intentionally) be the first non-zero session since S07.
