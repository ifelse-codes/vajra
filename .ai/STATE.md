# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S31 complete, S32 not yet started).

## Active PRs
- S31 = dogfood / verification, **docs-only** (option C — findings recorded, no code fix). Closeout rode on `session-31-dogfood-verification`; open a PR to `main` for the doc updates (or fold into S32).
- S29 guard-in-init PR #21 — merged (`8c3c832`). S28 Darshan-in-init PR #19 — merged (`c65fc10`). S27 Darshan PR #18 — merged (`0d7d5ba`). S26 chat-guard PR #17 — merged (`4956032`).

## Direction (set S18 … audited S25, hardened S26, human-lane S27, Darshan-in-init S28, guard-in-init S29, gate-audited S30)
- **Reframe: co-pilot, not cop** — guide the agent in real time (ADAS / F1 race engineer), not catch mistakes after.
- **Two speaking skills, two lanes:** **Varta** = the agent talks to itself over the live `.ai/` (⚡ language, skill not compiler; arc S19–S24 complete). **Darshan** = the user *sees* (glanceable, surface-adaptive output; skill not renderer; built S27, in `init` S28). The agent thinks in Varta; the human gets Darshan.
- **S26 founder override of the S25 audit:** the second agent launcher is **parked** — gated on *founder* satisfaction with Vajra-on-Claude, not the audit's call.
- **S30 ground-truth verdict:** the gate is **UNMEASURED, not unsatisfied.** ~$0.46 spend, all from S07; `vajra claude` has not run for real in 22 sessions, so "satisfying" is undeclarable from build-sessions. S27 (Darshan) plausibly moved daily satisfaction; S28/S29 moved *completeness*, not daily friction. **Next = measure it (S31 dogfood), then decide.** (memory `vajra-second-agent-gate`)
- **S31 DOGFOOD verdict — gate now MEASURED: DO NOT promote the second agent.** First real `vajra claude` usage since S07, against an existing TS monorepo (`chitra`). Three shipped `[x]`-done features are **dead in the real loop** (all the S30 false-green shape, proven 3×): (1) **compression never fires** on real CC (snake/camel schema bug, pinned vs a captured payload — see KNOWLEDGE S31); (2) **Darshan not obeyed** (prose pointer, not enforced — agent dumps walls of text, contradicting the "enforcement not prompts" wedge); (3) **brownfield onboarding unguided** (init works on existing repos but no "learn the codebase" session; hooks pollute the project's own `scripts/`). **Fix the core before adding breadth.** (KNOWLEDGE S31)

## What Currently Works
- **Ground-truth hardening (S30)** — `CONSTRAINTS.yaml#ground_truth` gained a **`dogfood_check`** audit + `dogfood_questions`: every future GT asks whether real work has run through `vajra claude` since the last GT (closes the meta-check blind spot — 7 green audits while the product sat un-dogfooded).
- **Session-guard in `vajra init` (S29)** — `vajra init` scaffolds `scripts/hook-session-guard.sh` (byte-identical via `include_str!`, executable) + wires it into `.claude/settings.json` PreToolUse(Bash) + emits `one_session_per_chat: true` + a `.gitignore` ignoring `.ai/.session-owner`. `Cargo.toml` un-excludes the hook. Scaffold **20 files**. The scaffolded guard actually enforces (exit 2). Propagation arc (co-pilot S22 + Darshan S28 + guard S29) complete.
- **Darshan in `vajra init` (S28)** + **Darshan skill (S27)** — `darshan/SKILL.md`, skill not renderer; 3 surface tiers; boot-wired via the *Speaking Skills* pointer in `.ai/AGENTS.md` (default human output).
- **One-session-per-chat enforcement (S26)** — `scripts/hook-session-guard.sh` blocks `git checkout -b session-(N+1)-*` from the owning chat (exit 2). Maturity-gated; gated on `one_session_per_chat: true`.
- **Render `.ai/` → `vajra.varta` (S24)** — `vajra check --render` regenerates a committed `vajra.varta`; plain `vajra check` drift-guards it.
- `vajra claude` · `vajra next` (packet / `--advance`) · `vajra check` · `vajra init` (20 files) · `vajra estimate` (3:1 placeholder) · `vajra meter`. Compression engine + 4 heuristics + meter + budget guard. Co-pilot loader (S21) fires `⚡on` mid-session (**fired live on this session's `git commit` — dogfooded**). CI green. `cargo test` green (98 lib), clippy clean.

## What Is Broken
> **Ranked by the gate's own lens — daily founder satisfaction — not by fix-convenience (S31 founder call).**
- **🔴 S31 #1 — Darshan not obeyed in real sessions (felt EVERY reply).** Wired only as a prose pointer in `.ai/AGENTS.md`; the boot hook never surfaces `darshan/SKILL.md`; it is not a registered CC skill. Agent dumps walls of dense text — the exact daily load Darshan (S27) exists to kill. **Most-felt pain; S32 tackles it first.** Design Q: how to enforce an output-style skill a hook can't read (min: surface it in the SessionStart boot packet).
- **🔴 S31 #2 — compression hook NEVER fires on real Claude Code.** `HookInput` has `#[serde(rename_all="camelCase")]` (expects `toolName`) but real CC sends snake_case top-level (`tool_name/tool_input/tool_response`) → parse-fail → silent `{}` passthrough. Zero savings since S03/S07; a false product claim. 98 tests green because fixtures encode the wrong casing. **Exact 2-file fix pinned vs a captured payload** (KNOWLEDGE S31) — but low daily impact (compression is the "quiet bonus", ~6–8% $, not the moat), so ranked below Darshan.
- **🟡 S31 #3 — brownfield onboarding unguided (felt once per project).** `vajra init` works on existing repos (skips existing `.gitignore`) but no "learn-the-codebase" first session; hooks land in the project's own `scripts/` (a pnpm package in `chitra`). Plus the S18 gap reconfirmed: `vajra claude` has no auth pre-check.
- **META (above all three):** 2 of 3 findings are the same root failure — **Vajra ships value as advisory "the agent should read this file", which the dogfood proved the agent ignores. Vajra violates its own "enforcement, not prompts" wedge.**
- **The founder-satisfaction gate is now MEASURED (S31) → second agent stays parked**, not for lack of breadth but because the core Claude loop is broken (above). No second agent launcher (the north-star gap).
- **Co-pilot v0 limits** — simple-glob (`*` spans `/`) + `cmd:` substring (no `**`/regex); surfaces paths + why, not file contents; debounce keys on `session_id`.
- **No `serde_yaml` dep** — hooks + the varta renderer hand-parse `CONSTRAINTS.yaml` line-by-line.
- `vajra estimate` output ratio (3:1) is unvalidated placeholder. `vajra claude` has no auth pre-check before launch (S18 onboarding gap).

## What Is In Progress
- **S31 dogfood DONE; findings recorded + re-ranked by satisfaction (option C — docs only, no code-fix this session).** Three findings in KNOWLEDGE S31 + ROADMAP. **No fix committed yet** — the 1-story/≤3-file discipline keeps the three fixes to separate sessions. **Next session (S32) = Darshan enforcement (#1, most-felt)**; compression schema fix = #2; brownfield = #3. Branch `session-31-dogfood-verification` carries only the doc updates.

## Cost Tracking
- Session 00–05: $0.00 (no API calls)
- Session 06: $0.00 (docs only)
- Session 07: ~$0.46 (3 test runs via `vajra claude -p`)
- Session 08–29: ~$0.00 (code/no-code sessions, no API calls)
- Session 30: ~$0.00 (NO-CODE ground-truth, no API calls)
- Session 31: **first real spend since S07** — a live `vajra claude` session in `chitra` (14 Bash tool-calls captured). Exact receipt $ not captured (founder exited; the receipt prints to stderr). Update with the figure at closeout if recoverable.
- Cumulative: ~$0.46 + S31 dogfood run  ·  the S30 "built-with-Claude-not-run-through-vajra" finding is now closed — S31 ran the real loop and it surfaced 3 core breakages.
