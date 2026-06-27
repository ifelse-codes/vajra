# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S19 complete, S20 not yet started).

## Active PRs
S19 Varta-v0 PR pending merge to `main`.

## Direction (set S18, advanced S19)
- **Reframe: co-pilot, not cop** — guide the agent in real time (ADAS / F1 race engineer), not catch mistakes after.
- **Product direction: Varta** — a compact ⚡ C-inspired machine language the agent learns at boot and speaks all session; delivered as a **skill** (not a compiler). Co-pilot mechanism = `⚡on(x) ⚡include`. See `VISION.md`, ROADMAP Phase 2, memory `vajra-varta`.
- **Varta v0 shipped (S19)** — the skill + grammar + `vajra.varta` worked example + read-back test. Files in `varta/`.
- **Next code build = the co-pilot loader** (ROADMAP item 8) — picked for S21. Make `⚡on(x) ⚡include` actually fire mid-session.

## What Currently Works
- **Varta v0 (the skill)** — `varta/SKILL.md` teaches the 9-construct ⚡ grammar + boot ritual; `varta/GRAMMAR.varta` is the self-describing spec; `varta/vajra.varta` renders Vajra's `.ai/` in Varta (companion); `varta/READBACK.md` proves an agent answers the rules from the spec alone. verify-session-19.sh green (10/10). Nothing parses it — the agent is the runtime.
- `vajra init` scaffolds `.ai/` + hooks + cross-agent pointers (16 files, interactive, idempotent). Prompts for maturity level.
- `vajra claude` launches Claude Code with hook injection and prints a receipt on exit.
- `--settings` injection is additive — proven in Session 07.
- `vajra next` prints the `.ai/` handoff packet + VISION.md + prompt pointer (read-only).
- `vajra next --advance` bumps SESSION + SESSION-BOOT.md + prompt pointer. L3 skips confirm, L1/L2 require it.
- `vajra next` e2e loop proven: init → next → work → advance → repeat across 3 sessions.
- `vajra check` runs 10 drift-detection checks. L1 = WARN (exit 0), L2/L3 = FAIL (exit 1).
- `vajra estimate` predicts token spend before running a session. Chars/4 input, 3:1 output ratio, Opus pricing, budget warning.
- Maturity levels L1/L2/L3 parsed from `maturity:` in CONSTRAINTS.yaml (default L2).
- Compression engine + 4 heuristics (cargo, git, npm, pytest) + meter — tests pass against fixtures.
- Budget guard enforces `budget.cap_usd` after each session (warn or kill mode).
- GitHub Actions CI (test+clippy+fmt on macOS+Linux) green; release workflow (3 targets); `cargo package` as `vajractl`.
- Remote `origin` → `https://github.com/ifelse-codes/vajra`. All tests green: `cargo test` (77 unit + 26 integration), `cargo clippy`.

## What Is Broken
- Only Claude Code is wired — no second agent launcher exists.
- `vajra estimate` output ratio (3:1) is unvalidated placeholder — treat as order-of-magnitude.
- **First-run payoff is invisible** — `vajra init` produces files, not a felt win (S18 finding; Phase 2 item 9).
- **Varta is not yet wired into `vajra init`** (standalone files only, S19 decision), and `⚡on(...)` loads are read by the agent, not yet fired by a runtime (that is the S21 co-pilot loader).

## What Is In Progress
- Nothing — between sessions. Next: **S20 ground-truth audit (mandatory NO-CODE)**, then S21 = co-pilot loader.

## Cost Tracking
- Session 00–05: $0.00 (no API calls)
- Session 06: $0.00 (docs only)
- Session 07: ~$0.46 (3 test runs via `vajra claude -p`)
- Session 08–16: ~$0.00 (code/no-code sessions, no API calls)
- Session 17: ~$0.00 (code session, no API calls)
- Session 18: ~$0.00 (interactive review, no API calls)
- Session 19: ~$0.00 (docs/skill session, no API calls)
- Cumulative: ~$0.46
