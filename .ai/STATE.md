# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S27 complete, S28 not yet started).

## Active PRs
- **PR #18** (`session-27-darshan`) — Darshan, the human's glanceable output skill — **open (merge after closeout).**
- S26 chat-guard PR #17 — merged (`4956032`). S24 varta-render PR #15 — merged (`d0533f0`). S25 = NO-CODE GT (no PR).

## Direction (set S18, advanced S19, proven S21, propagated S22, felt S23, persisted S24, audited S25, hardened S26, human-lane S27)
- **Reframe: co-pilot, not cop** — guide the agent in real time (ADAS / F1 race engineer), not catch mistakes after.
- **Two speaking skills, two lanes:** **Varta** = the agent talks to itself over the live `.ai/` (⚡ language, skill not compiler; arc S19–S24 complete). **Darshan** = the user *sees* (glanceable, surface-adaptive output; skill not renderer; built S27). The agent thinks in Varta; the human gets Darshan.
- **S26 founder override of the S25 audit:** the second agent launcher is **parked in the backlog** — gated on *founder* satisfaction with Vajra-on-Claude, **not** the audit's "condition met" call. The founder is **not yet satisfied** with Claude; Darshan (S27) + propagation (S28) are part of making it satisfying. (memory `vajra-second-agent-gate`)

## What Currently Works
- **Darshan — the human's glanceable lane (S27)** — `darshan/SKILL.md`: skill, not a renderer (like Varta). Boot ritual (read→internalize→speak), the one rule (*render the richest visual this surface can handle; always glanceable; never drop meaning*), 3 surface tiers (rich chat HTML/SVG · terminal ANSI/box-drawing · plain markdown), worked before/after for chat + terminal, terminal-fallback + skill-not-renderer guardrails. **Boot-wired** via a *Speaking Skills* pointer in `.ai/AGENTS.md` (default human output). No `src/` change, no new dep, no 8th command. verify-session-27.sh green (18/18). **Not yet propagated to `vajra init`** (S28).
- **One-session-per-chat enforcement (S26)** — `scripts/hook-session-guard.sh` (PreToolUse Bash). Records which Claude `session_id` owns each vajra-session in a gitignored `.ai/.session-owner`; blocks `git checkout -b session-(N+1)-*` from the owning chat (exit 2). Maturity-gated (L1 advise / L2-L3 block); gated on `one_session_per_chat: true`. **Not yet propagated to `vajra init`** (S28).
- **Render `.ai/` → `vajra.varta` (S24)** — `vajra check --render` regenerates a committed `vajra.varta`; plain `vajra check` drift-guards it.
- **First-run "aha" (S23)** — `vajra init` fires the co-pilot once against a sample `git commit` and shows the real block + surfaced `.ai/STATE.md`.
- **Scaffold propagation (S22)** — `vajra init` emits the S20 `ground_truth:` audits + the S21 `copilot:` block + `hook-copilot-loader.sh` (via `include_str!`), wires `.claude/settings.json`.
- **Co-pilot loader (S21)** — fires `⚡on(cond) ⚡include "files"` on matching work; maturity-gated; per-session debounce. *(Fired again this session on S27's `git commit`.)*
- **Varta v0 (the language)** — `varta/SKILL.md` + `varta/GRAMMAR.varta`; spoken from the live `.ai/`.
- `vajra claude` · `vajra next` (packet / `--advance`) · `vajra check` (drift incl. varta render) · `vajra estimate` (3:1 placeholder) · `vajra meter`. Compression engine + 4 heuristics + meter + budget guard. CI green. `cargo test` green, clippy clean.

## What Is Broken
- **Darshan + session-guard not in `vajra init`** — a freshly-`init`ed project inherits neither the glanceable output skill (S27) nor the one-session-per-chat guard (S26). Propagation = S28.
- Only Claude Code is wired — no second agent launcher (the north-star gap, **parked** by founder until Claude is satisfying).
- **Co-pilot v0 limits** — simple-glob (`*` spans `/`) + `cmd:` substring (no `**`/regex); surfaces paths + why, not file contents; debounce keys on `session_id`.
- **No `serde_yaml` dep** — hooks + the varta renderer hand-parse `CONSTRAINTS.yaml` line-by-line.
- **`vajra.varta` reflects committed `.ai/` truth** — mid-session it renders the last-closed state (by design; drift-guarded).
- `vajra estimate` output ratio (3:1) is unvalidated placeholder. `vajra claude` has no auth pre-check before launch (S18 onboarding gap).

## What Is In Progress
- Nothing — between sessions. Next: **S28 — propagate Darshan + session-guard into `vajra init`**. Read `prompts/28-task-init-propagation.md`. Second agent stays parked until the founder declares Vajra-on-Claude satisfying.

## Cost Tracking
- Session 00–05: $0.00 (no API calls)
- Session 06: $0.00 (docs only)
- Session 07: ~$0.46 (3 test runs via `vajra claude -p`)
- Session 08–26: ~$0.00 (code/no-code sessions, no API calls)
- Session 27: ~$0.00 (code/content session, no API calls)
- Cumulative: ~$0.46
