# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S29 complete, S30 not yet started).

## Active PRs
- **PR #21** (`session-29-session-guard-propagation`) — propagate the session-guard into `vajra init` — **open (merge after closeout).**
- S28 Darshan-in-init PR #19 — merged (`c65fc10`). S27 Darshan PR #18 — merged (`0d7d5ba`). S26 chat-guard PR #17 — merged (`4956032`). S25 = NO-CODE GT (no PR).

## Direction (set S18, advanced S19, proven S21, propagated S22, felt S23, persisted S24, audited S25, hardened S26, human-lane S27, Darshan-in-init S28, guard-in-init S29)
- **Reframe: co-pilot, not cop** — guide the agent in real time (ADAS / F1 race engineer), not catch mistakes after.
- **Two speaking skills, two lanes:** **Varta** = the agent talks to itself over the live `.ai/` (⚡ language, skill not compiler; arc S19–S24 complete). **Darshan** = the user *sees* (glanceable, surface-adaptive output; skill not renderer; built S27, in `init` S28). The agent thinks in Varta; the human gets Darshan.
- **S26 founder override of the S25 audit:** the second agent launcher is **parked in the backlog** — gated on *founder* satisfaction with Vajra-on-Claude, **not** the audit's "condition met" call. The founder is **not yet satisfied** with Claude; Darshan (S27) + propagation (S28–S29) were part of making it satisfying. **S30 ground-truth leads by answering that gate.** (memory `vajra-second-agent-gate`)

## What Currently Works
- **Session-guard in `vajra init` (S29)** — a fresh `vajra init` now scaffolds `scripts/hook-session-guard.sh` (byte-identical via `include_str!`, executable) + wires it into `.claude/settings.json` PreToolUse(Bash) beside the co-pilot + emits `one_session_per_chat: true` in `TPL_CONSTRAINTS` + scaffolds a `.gitignore` ignoring `.ai/.session-owner`. `Cargo.toml` un-excludes the hook (`!scripts/hook-session-guard.sh`) so `cargo install` compiles. Scaffold **18 → 20 files**. The scaffolded guard actually enforces (blocks N→N+1 in the same chat, exit 2). No 8th command, no new dep, no `src/` guard logic (embed-only, never spawned). 4 new scaffold tests. verify-session-29.sh green (19/19). **PR #21 — open (merge after closeout).** Closes the S28 split — propagation arc (co-pilot S22 + Darshan S28 + guard S29) is now complete.
- **Darshan in `vajra init` (S28)** — scaffolds `darshan/SKILL.md` (byte-identical) + a **Speaking Skills (Load at Boot)** section in the generated `.ai/AGENTS.md` (Darshan = default human output).
- **Darshan — the human's glanceable lane (S27)** — `darshan/SKILL.md`: skill, not a renderer. One rule (*render the richest visual this surface can handle; always glanceable; never drop meaning*), 3 surface tiers (rich chat HTML/SVG · terminal ANSI/box-drawing · plain markdown). Boot-wired via the *Speaking Skills* pointer in `.ai/AGENTS.md`.
- **One-session-per-chat enforcement (S26)** — `scripts/hook-session-guard.sh` (PreToolUse Bash). Records the owning Claude `session_id` in a gitignored `.ai/.session-owner`; blocks `git checkout -b session-(N+1)-*` from the owning chat (exit 2). Maturity-gated (L1 advise / L2-L3 block); gated on `one_session_per_chat: true`. **Now propagated to `vajra init`** (S29).
- **Render `.ai/` → `vajra.varta` (S24)** — `vajra check --render` regenerates a committed `vajra.varta`; plain `vajra check` drift-guards it.
- `vajra claude` · `vajra next` (packet / `--advance`) · `vajra check` (drift incl. varta render) · `vajra init` (scaffolds 20 files) · `vajra estimate` (3:1 placeholder) · `vajra meter`. Compression engine + 4 heuristics + meter + budget guard. Co-pilot loader (S21) fires `⚡on` mid-session (fired live on this session's `git commit`). CI green. `cargo test` green (98 lib), clippy clean.

## What Is Broken
- Only Claude Code is wired — no second agent launcher (the north-star gap, **parked** by founder until Claude is satisfying; **S30 GT decides the gate**).
- **Co-pilot v0 limits** — simple-glob (`*` spans `/`) + `cmd:` substring (no `**`/regex); surfaces paths + why, not file contents; debounce keys on `session_id`.
- **No `serde_yaml` dep** — hooks + the varta renderer hand-parse `CONSTRAINTS.yaml` line-by-line.
- **`vajra.varta` reflects committed `.ai/` truth** — mid-session it renders the last-closed state (by design; drift-guarded).
- `vajra estimate` output ratio (3:1) is unvalidated placeholder. `vajra claude` has no auth pre-check before launch (S18 onboarding gap).

## What Is In Progress
- Nothing — between sessions. Next: **S30 — ground-truth (NO-CODE)**, lead lens = the founder-satisfaction gate (does Vajra-on-Claude warrant promoting the second agent?). Read `prompts/30-task-ground-truth.md`. The propagation arc is complete (S22→S29); the dogfood session is unblocked as a post-GT candidate.

## Cost Tracking
- Session 00–05: $0.00 (no API calls)
- Session 06: $0.00 (docs only)
- Session 07: ~$0.46 (3 test runs via `vajra claude -p`)
- Session 08–28: ~$0.00 (code/no-code sessions, no API calls)
- Session 29: ~$0.00 (code session, no API calls)
- Cumulative: ~$0.46
