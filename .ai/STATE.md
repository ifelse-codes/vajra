# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S22 complete, S23 not yet started).

## Active PRs
S22 scaffold-propagation PR #12 pending merge to `main`. S21 co-pilot-loader PR #11 — **merged**.

## Direction (set S18, advanced S19, proven S21, propagated S22)
- **Reframe: co-pilot, not cop** — guide the agent in real time (ADAS / F1 race engineer), not catch mistakes after.
- **Product direction: Varta** — a compact ⚡ C-inspired machine language the agent learns at boot and speaks all session; delivered as a **skill** (not a compiler). Co-pilot mechanism = `⚡on(x) ⚡include`.
- **S21 proved the wedge: Varta ENFORCES** (L2/L3 exit-2 block until context surfaced; L1 advises). **S22 propagated it** — every `vajra init` project now inherits the enforcing co-pilot + the S20 direction-drift audits, so the hardening is no longer repo-local.
- **Next = first-run "aha" (S23)** — make `vajra init` → first session deliver a *felt* win in ~2 min. Closes Phase 2.

## What Currently Works
- **Scaffold propagation (S22)** — `vajra init` now emits the S20 `ground_truth:` audits (vision/roadmap/constitution + question-lists + `drift_axes`) **and** the S21 `copilot:` block (2 starter `⚡on` rules), refreshed `approval_tokens` + `ground_truth_commit_exempt_branch_suffixes`, ships `scripts/hook-copilot-loader.sh`, and wires it into the scaffolded `.claude/settings.json` PreToolUse. The hook is embedded via `include_str!` of the canonical script (byte-identical, no drift). 17 files. verify-session-22.sh green (12/12); a real `vajra init` into a temp dir enforces day one.
- **Co-pilot loader (S21)** — `scripts/hook-copilot-loader.sh` fires `⚡on(cond) ⚡include "files"` from `.ai/CONSTRAINTS.yaml#copilot.on` the moment matching work is touched. Path-glob + `cmd:` matching, per-session debounce, maturity-gated (L1 advise / L2-L3 enforce exit 2). Proven live (blocked a real `git commit` this session too).
- **Varta v0 (the language)** — `varta/SKILL.md` + `varta/GRAMMAR.varta`; spoken from the live `.ai/`. verify-session-19.sh green (9/9).
- `vajra claude` launches Claude Code with hook injection + receipt. `vajra next` prints the handoff packet (read-only) or `--advance` bumps the session. `vajra check` runs 10 drift checks. `vajra estimate` predicts spend (3:1 ratio — unvalidated placeholder).
- Compression engine + 4 heuristics + meter; budget guard; CI green. `cargo test` 107 pass, `cargo clippy` clean.

## What Is Broken
- Only Claude Code is wired — no second agent launcher exists.
- **First-run payoff still thin** — `vajra init` produces files (now S20+S21-hardened), but not yet a *felt* win (S23 fixes this — Phase 2 item 9).
- **Co-pilot v0 limits** — simple-glob (`*` spans `/`) + `cmd:` substring (no `**`/regex); surfaces paths + why, not file contents; debounce keys on `session_id`. Scaffolded settings wire only the co-pilot in PreToolUse (the launcher's `--settings` path still injects only the PostToolUse compression hook).
- `vajra estimate` output ratio (3:1) is unvalidated placeholder — order-of-magnitude only.

## What Is In Progress
- Nothing — between sessions. Next: **S23 — first-run "aha"** (a felt win in ~2 min from `vajra init`).

## Cost Tracking
- Session 00–05: $0.00 (no API calls)
- Session 06: $0.00 (docs only)
- Session 07: ~$0.46 (3 test runs via `vajra claude -p`)
- Session 08–21: ~$0.00 (code/no-code sessions, no API calls)
- Session 22: ~$0.00 (code session, no API calls)
- Cumulative: ~$0.46
