# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S25 complete, S26 not yet started).

## Active PRs
None. S24 varta-render PR #15 — **merged** to `main` (`d0533f0`). S25 = NO-CODE ground-truth (no PR). S23 first-run-aha PR #13 — merged.

## Direction (set S18, advanced S19, proven S21, propagated S22, felt S23, persisted-as-render S24, audited S25)
- **Reframe: co-pilot, not cop** — guide the agent in real time (ADAS / F1 race engineer), not catch mistakes after.
- **Product direction: Varta** — a compact ⚡ C-inspired machine language the agent learns at boot and speaks all session; delivered as a **skill** (not a compiler). Co-pilot mechanism = `⚡on(x) ⚡include`.
- **The Varta arc is complete:** S19 shipped the language, S21 made it **enforce**, S22 **propagated** it to every `vajra init` project, S23 made the first run **felt**, S24 brought back a persisted `.varta` **as a one-way generated render** (drift-guarded). Phases 1–3 + the Varta story are all done.
- **S25 ground-truth verdict:** Varta was **on-wedge** (S21 proved it enforces), not scope creep — but its leverage is spent. The shortest path to the cross-agent north-star now bends to the **second agent launcher** (the only wedge pillar with zero code). **Meta-finding:** the green dashboard (`check`/verify/CI) measures Claude-depth only — no cross-agent breadth metric (false-green risk).
- **Next = S26 (CODE): enforce one-session-per-chat** (picked at S25 GT) — hardens the existing loop. **S27+ must lead with the second agent launcher** (north-star gap #1).

## What Currently Works
- **Render `.ai/` → `vajra.varta` (S24)** — `vajra check --render` regenerates a committed `vajra.varta` from the live `.ai/` (CONSTRAINTS/AGENTS/SESSION/SESSION-BOOT) in the 9 locked ⚡ constructs; hand-parsed (no `serde_yaml`), deterministic. Plain `vajra check` adds a `varta: matches render` **drift guard** (on-disk == fresh render, S22 `cmp`); missing/stale → FAIL with the fix. No 8th command. verify-session-24.sh green (21/21).
- **First-run "aha" (S23)** — `vajra init` ends by firing the just-scaffolded co-pilot once against a sample `git commit` and shows the real block + surfaced `.ai/STATE.md` (graceful fallback if bash/jq absent; init exits 0 despite child exit 2). Rides on `init` (no 8th command).
- **Scaffold propagation (S22)** — `vajra init` emits the S20 `ground_truth:` audits + the S21 `copilot:` block, ships `hook-copilot-loader.sh` via `include_str!` (byte-identical), wires it into `.claude/settings.json`.
- **Co-pilot loader (S21)** — fires `⚡on(cond) ⚡include "files"` from `copilot.on` on matching work; path-glob + `cmd:` matching, per-session debounce, maturity-gated (L1 advise / L2-L3 enforce exit 2). *(Dogfooded again this session — fired on S24's first `git commit`.)*
- **Varta v0 (the language)** — `varta/SKILL.md` + `varta/GRAMMAR.varta`; spoken from the live `.ai/`.
- `vajra claude` (launch + hook injection + receipt), `vajra next` (packet / `--advance`), `vajra check` (drift checks incl. varta render), `vajra estimate` (3:1 ratio — unvalidated placeholder), `vajra meter`. Compression engine + 4 heuristics + meter + budget guard. CI green. `cargo test` 118 pass, clippy clean.

## What Is Broken
- Only Claude Code is wired — no second agent launcher exists (the north-star's main remaining gap; the S25 GT will weigh whether to pivot here).
- **Co-pilot v0 limits** — simple-glob (`*` spans `/`) + `cmd:` substring (no `**`/regex); surfaces paths + why, not file contents; debounce keys on `session_id`.
- **No `serde_yaml` dep** — hooks + the varta renderer hand-parse `CONSTRAINTS.yaml` line-by-line.
- **`vajra.varta` reflects committed `.ai/` truth** — mid-session it renders the last-closed state (e.g. `⚡now` shows the prior session until closeout re-renders). By design (one-way render of what's on disk), drift-guarded.
- `vajra estimate` output ratio (3:1) is unvalidated placeholder — order-of-magnitude only.

## What Is In Progress
- Nothing — between sessions. Next: **S26 — enforce one-session-per-chat (CODE)**. Read `prompts/26-task-chat-guard.md`. S27 must lead with the second agent launcher (S25's #1 gap).

## Cost Tracking
- Session 00–05: $0.00 (no API calls)
- Session 06: $0.00 (docs only)
- Session 07: ~$0.46 (3 test runs via `vajra claude -p`)
- Session 08–23: ~$0.00 (code/no-code sessions, no API calls)
- Session 24: ~$0.00 (code session, no API calls)
- Session 25: ~$0.00 (NO-CODE ground-truth, no API calls)
- Cumulative: ~$0.46
