# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S23 complete, S24 not yet started).

## Active PRs
S23 first-run-aha PR #13 pending merge to `main`. S22 scaffold-propagation PR #12 — **merged**.

## Direction (set S18, advanced S19, proven S21, propagated S22, felt S23)
- **Reframe: co-pilot, not cop** — guide the agent in real time (ADAS / F1 race engineer), not catch mistakes after.
- **Product direction: Varta** — a compact ⚡ C-inspired machine language the agent learns at boot and speaks all session; delivered as a **skill** (not a compiler). Co-pilot mechanism = `⚡on(x) ⚡include`.
- **The arc is complete end-to-end:** S19 shipped the language, S21 made it **enforce**, S22 **propagated** it to every `vajra init` project, S23 made the first run **felt** (init ends by firing the co-pilot live). **Phase 2 is complete.**
- **Next = render `.ai/` → generated `.varta` (S24)** — bring back a persisted `.varta` *only* as a one-way generated render (the S19 condition), drift-guarded. Lean ahead of the S25 ground-truth.

## What Currently Works
- **First-run "aha" (S23)** — `vajra init` ends with `first_run_aha()`: it fires the just-scaffolded `hook-copilot-loader.sh` once against a sample `git commit` and shows the real co-pilot block + surfaced `.ai/STATE.md`, framed as a 5-second simulation, then points to `vajra claude`. Rides on `init` (no 8th command); graceful static fallback if bash/jq absent; init exits 0 despite the child's exit 2. verify-session-23.sh green (11/11).
- **Scaffold propagation (S22)** — `vajra init` emits the S20 `ground_truth:` audits + the S21 `copilot:` block, ships `hook-copilot-loader.sh` via `include_str!` (byte-identical, no drift), wires it into `.claude/settings.json`. 17 files. verify-session-22.sh green (12/12).
- **Co-pilot loader (S21)** — fires `⚡on(cond) ⚡include "files"` from `.ai/CONSTRAINTS.yaml#copilot.on` on matching work; path-glob + `cmd:` matching, per-session debounce, maturity-gated (L1 advise / L2-L3 enforce exit 2).
- **Varta v0 (the language)** — `varta/SKILL.md` + `varta/GRAMMAR.varta`; spoken from the live `.ai/`. verify-session-19.sh green (9/9).
- `vajra claude` (launch + hook injection + receipt), `vajra next` (packet / `--advance`), `vajra check` (10 drift checks), `vajra estimate` (3:1 ratio — unvalidated placeholder), `vajra meter`. Compression engine + 4 heuristics + meter + budget guard. CI green. `cargo test` 108 pass, clippy clean.

## What Is Broken
- Only Claude Code is wired — no second agent launcher exists (the north-star's main remaining gap; backlog).
- **Co-pilot v0 limits** — simple-glob (`*` spans `/`) + `cmd:` substring (no `**`/regex); surfaces paths + why, not file contents; debounce keys on `session_id`. Scaffolded settings wire only the co-pilot in PreToolUse.
- **No `serde_yaml` dep** — hooks + any future renderer hand-parse `CONSTRAINTS.yaml` line-by-line (relevant to S24).
- `vajra estimate` output ratio (3:1) is unvalidated placeholder — order-of-magnitude only.

## What Is In Progress
- Nothing — between sessions. Next: **S24 — render `.ai/` → generated `.varta`** (lean), then **S25 — ground-truth (NO-CODE)**.

## Cost Tracking
- Session 00–05: $0.00 (no API calls)
- Session 06: $0.00 (docs only)
- Session 07: ~$0.46 (3 test runs via `vajra claude -p`)
- Session 08–22: ~$0.00 (code/no-code sessions, no API calls)
- Session 23: ~$0.00 (code session, no API calls)
- Cumulative: ~$0.46
