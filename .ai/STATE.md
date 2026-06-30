# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S28 complete, S29 not yet started).

## Active PRs
- **PR #19** (`session-28-init-propagation`) — propagate Darshan into `vajra init` — **merged (`c65fc10`).**
- S27 Darshan PR #18 — merged (`0d7d5ba`). S26 chat-guard PR #17 — merged (`4956032`). S25 = NO-CODE GT (no PR).

## Direction (set S18, advanced S19, proven S21, propagated S22, felt S23, persisted S24, audited S25, hardened S26, human-lane S27, Darshan-in-init S28)
- **Reframe: co-pilot, not cop** — guide the agent in real time (ADAS / F1 race engineer), not catch mistakes after.
- **Two speaking skills, two lanes:** **Varta** = the agent talks to itself over the live `.ai/` (⚡ language, skill not compiler; arc S19–S24 complete). **Darshan** = the user *sees* (glanceable, surface-adaptive output; skill not renderer; built S27, propagated into `vajra init` S28). The agent thinks in Varta; the human gets Darshan.
- **S26 founder override of the S25 audit:** the second agent launcher is **parked in the backlog** — gated on *founder* satisfaction with Vajra-on-Claude, **not** the audit's "condition met" call. The founder is **not yet satisfied** with Claude; Darshan (S27) + propagation (S28–S29) are part of making it satisfying. (memory `vajra-second-agent-gate`)

## What Currently Works
- **Darshan in `vajra init` (S28)** — a fresh `vajra init` now scaffolds `darshan/SKILL.md` (byte-identical via `include_str!`) + a **Speaking Skills (Load at Boot)** section in the generated `.ai/AGENTS.md` (Darshan = default human output). Same one-source-of-truth pattern as the S22 co-pilot hook. Scaffold 17 → 18 files. No `Cargo.toml` change (`darshan/` not excluded), no 8th command, no new dep, no `src/` renderer. verify-session-28.sh green (12/12). **Session-guard still NOT in `init`** (S29).
- **Darshan — the human's glanceable lane (S27)** — `darshan/SKILL.md`: skill, not a renderer (like Varta). One rule (*render the richest visual this surface can handle; always glanceable; never drop meaning*), 3 surface tiers (rich chat HTML/SVG · terminal ANSI/box-drawing · plain markdown), worked before/after, terminal-fallback guardrail. Boot-wired via the *Speaking Skills* pointer in `.ai/AGENTS.md`.
- **One-session-per-chat enforcement (S26)** — `scripts/hook-session-guard.sh` (PreToolUse Bash). Records which Claude `session_id` owns each vajra-session in a gitignored `.ai/.session-owner`; blocks `git checkout -b session-(N+1)-*` from the owning chat (exit 2). Maturity-gated (L1 advise / L2-L3 block); gated on `one_session_per_chat: true`. **Not yet propagated to `vajra init`** (S29).
- **Render `.ai/` → `vajra.varta` (S24)** — `vajra check --render` regenerates a committed `vajra.varta`; plain `vajra check` drift-guards it.
- **First-run "aha" (S23)** — `vajra init` fires the co-pilot once against a sample `git commit` and shows the real block + surfaced `.ai/STATE.md`.
- **Scaffold propagation (S22)** — `vajra init` emits the S20 `ground_truth:` audits + the S21 `copilot:` block + `hook-copilot-loader.sh` (via `include_str!`), wires `.claude/settings.json`.
- **Co-pilot loader (S21)** — fires `⚡on(cond) ⚡include "files"` on matching work; maturity-gated; per-session debounce. *(Fired again this session on S28's `git commit`.)*
- **Varta v0 (the language)** — `varta/SKILL.md` + `varta/GRAMMAR.varta`; spoken from the live `.ai/`.
- `vajra claude` · `vajra next` (packet / `--advance`) · `vajra check` (drift incl. varta render) · `vajra estimate` (3:1 placeholder) · `vajra meter`. Compression engine + 4 heuristics + meter + budget guard. CI green. `cargo test` green, clippy clean.

## What Is Broken
- **Session-guard not in `vajra init`** — a freshly-`init`ed project inherits Darshan (S28) but still not the S26 one-session-per-chat guard, nor `one_session_per_chat: true`, nor a `.gitignore` for `.ai/.session-owner`. Propagation = S29.
- Only Claude Code is wired — no second agent launcher (the north-star gap, **parked** by founder until Claude is satisfying).
- **Co-pilot v0 limits** — simple-glob (`*` spans `/`) + `cmd:` substring (no `**`/regex); surfaces paths + why, not file contents; debounce keys on `session_id`.
- **No `serde_yaml` dep** — hooks + the varta renderer hand-parse `CONSTRAINTS.yaml` line-by-line.
- **`vajra.varta` reflects committed `.ai/` truth** — mid-session it renders the last-closed state (by design; drift-guarded).
- `vajra estimate` output ratio (3:1) is unvalidated placeholder. `vajra claude` has no auth pre-check before launch (S18 onboarding gap).

## What Is In Progress
- Nothing — between sessions. Next: **S29 — propagate the session-guard into `vajra init`**. Read `prompts/29-task-session-guard-propagation.md`. Then **S30 = ground-truth (NO-CODE)**. Second agent stays parked until the founder declares Vajra-on-Claude satisfying.

## Cost Tracking
- Session 00–05: $0.00 (no API calls)
- Session 06: $0.00 (docs only)
- Session 07: ~$0.46 (3 test runs via `vajra claude -p`)
- Session 08–27: ~$0.00 (code/no-code sessions, no API calls)
- Session 28: ~$0.00 (code session, no API calls)
- Cumulative: ~$0.46
