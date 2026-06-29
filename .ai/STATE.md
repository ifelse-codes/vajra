# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S26 complete, S27 not yet started).

## Active PRs
- **PR #17** (`session-26-chat-guard`) — one-session-per-chat enforcement — **open (merge after closeout).**
- S24 varta-render PR #15 — merged (`d0533f0`). S25 = NO-CODE GT (no PR). S23 first-run-aha PR #13 — merged.

## Direction (set S18, advanced S19, proven S21, propagated S22, felt S23, persisted S24, audited S25, hardened + re-ranked S26)
- **Reframe: co-pilot, not cop** — guide the agent in real time (ADAS / F1 race engineer), not catch mistakes after.
- **Varta (agent's language)** — a compact ⚡ C-inspired machine language the agent learns at boot and speaks all session; delivered as a **skill** (not a compiler). The Varta arc (S19–S24) is complete.
- **S26 founder override of the S25 audit:** the second agent launcher is **parked back in the backlog** — gated on *founder* satisfaction with Vajra-on-Claude, **not** the audit's "condition met" call. The founder is **not yet satisfied** with Claude. (memory `vajra-second-agent-gate`)
- **New next leap = Darshan (the human's lane):** Vajra's default, surface-adaptive, **glanceable** way of *showing* the human instead of dumping walls of text. Pairs with Varta — **the agent talks to itself (Varta); the user sees (Darshan).** Skill, not a renderer. Fixes AI cognitive-overload / burnout. Name provisional (founder confirms at S27 BOOT). Built S27 — `prompts/27-task-darshan.md`.

## What Currently Works
- **One-session-per-chat enforcement (S26)** — `scripts/hook-session-guard.sh` (PreToolUse Bash, wired beside `hook-pre-bash`/`hook-copilot-loader`). Records which Claude `session_id` owns each vajra-session in a gitignored `.ai/.session-owner`; blocks `git checkout -b session-(N+1)-*` from the owning chat (exit 2, "open a new chat first"). Only the N→N+1 boundary blocks; same-session re-checkout, non-session branches, fresh chats pass. Maturity-gated (L1 advise / L2-L3 block); gated on `one_session_per_chat: true`. Test knobs: `VAJRA_SESSION_OWNER_FILE`, `VAJRA_GUARD_MATURITY`. No 8th command, no new dep. verify-session-26.sh green (13/13). **Not yet propagated to `vajra init`** (S27/S28).
- **Render `.ai/` → `vajra.varta` (S24)** — `vajra check --render` regenerates a committed `vajra.varta` from the live `.ai/`; plain `vajra check` drift-guards it (`varta: matches render`). Hand-parsed, deterministic.
- **First-run "aha" (S23)** — `vajra init` fires the just-scaffolded co-pilot once against a sample `git commit` and shows the real block + surfaced `.ai/STATE.md`. Rides on `init`.
- **Scaffold propagation (S22)** — `vajra init` emits the S20 `ground_truth:` audits + the S21 `copilot:` block, ships `hook-copilot-loader.sh` via `include_str!`, wires `.claude/settings.json`.
- **Co-pilot loader (S21)** — fires `⚡on(cond) ⚡include "files"` on matching work; maturity-gated (L1 advise / L2-L3 exit 2); per-session debounce. *(Dogfooded again this session — fired on S26's first `git commit`.)*
- **Varta v0 (the language)** — `varta/SKILL.md` + `varta/GRAMMAR.varta`; spoken from the live `.ai/`.
- `vajra claude` · `vajra next` (packet / `--advance`) · `vajra check` (drift incl. varta render) · `vajra estimate` (3:1 placeholder) · `vajra meter`. Compression engine + 4 heuristics + meter + budget guard. CI green. `cargo test` 118 pass, clippy clean.

## What Is Broken
- **Darshan does not exist yet** — the human-facing glanceable output lane is still just one line in `VISION.md`; the founder is not yet satisfied with how Vajra/the agent talks to the user (too dense). Built S27.
- Only Claude Code is wired — no second agent launcher (the north-star gap, **parked** by founder until Claude is satisfying).
- **Co-pilot v0 limits** — simple-glob (`*` spans `/`) + `cmd:` substring (no `**`/regex); surfaces paths + why, not file contents; debounce keys on `session_id`.
- **No `serde_yaml` dep** — hooks + the varta renderer hand-parse `CONSTRAINTS.yaml` line-by-line.
- **`vajra.varta` reflects committed `.ai/` truth** — mid-session it renders the last-closed state (by design; drift-guarded).
- `vajra estimate` output ratio (3:1) is unvalidated placeholder. `vajra claude` has no auth pre-check before launch (S18 onboarding gap).

## What Is In Progress
- Nothing — between sessions. Next: **S27 — Darshan** (human-facing glanceable output skill). Read `prompts/27-task-darshan.md`. Second agent stays parked until the founder declares Vajra-on-Claude satisfying.

## Cost Tracking
- Session 00–05: $0.00 (no API calls)
- Session 06: $0.00 (docs only)
- Session 07: ~$0.46 (3 test runs via `vajra claude -p`)
- Session 08–25: ~$0.00 (code/no-code sessions, no API calls)
- Session 26: ~$0.00 (code session, no API calls)
- Cumulative: ~$0.46
