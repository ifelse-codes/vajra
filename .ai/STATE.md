# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S21 complete, S22 not yet started).

## Active PRs
S21 co-pilot-loader PR #11 pending merge to `main`. S20 enforcement PR #10 — **merged**.

## Direction (set S18, advanced S19, proven S21)
- **Reframe: co-pilot, not cop** — guide the agent in real time (ADAS / F1 race engineer), not catch mistakes after.
- **Product direction: Varta** — a compact ⚡ C-inspired machine language the agent learns at boot and speaks all session; delivered as a **skill** (not a compiler). Co-pilot mechanism = `⚡on(x) ⚡include`.
- **S21 proved the wedge: Varta ENFORCES.** The co-pilot loader makes `⚡on` *fire* mid-session and, at L2/L3, **blocks the tool (exit 2) until the context is surfaced** — the same enforcement every Vajra hook uses. A spoken-only language enforces nothing; this one gates. The "enforce or merely advise?" gate (memory `vajra-varta-wedge-risk`) is **answered: enforce** → Varta stays on-wedge, not demoted.
- **Next = scaffold propagation (S22)** — push the S20 GT hardening + the S21 co-pilot into the `vajra init` scaffold so every project inherits them (today they live only in this repo).
- **S20 hardened the ground-truth audit** to catch **direction drift** (vision + roadmap), not just discipline drift. `CONSTRAINTS.yaml#ground_truth` + `AGENTS.md`.

## What Currently Works
- **Co-pilot loader (S21)** — `scripts/hook-copilot-loader.sh` is a PreToolUse(Edit|Write|Bash) hook that fires `⚡on(cond) ⚡include "files"` rules from `.ai/CONSTRAINTS.yaml#copilot.on` the moment the agent touches matching work. Path-glob + `cmd:` matching, per-session debounce, **maturity-gated**: L1 advises (exit 0), L2/L3 **enforce** (exit 2, block until surfaced). verify-session-21.sh green (10/10). Proven live: blocked a real `git commit`.
- **Varta v0 (the language)** — `varta/SKILL.md` teaches the 9-construct ⚡ grammar; `varta/GRAMMAR.varta` is the self-describing spec. The agent speaks Varta from the **live `.ai/`** — the `copilot.on` rules are its first executable use. verify-session-19.sh green (9/9).
- `vajra init` scaffolds `.ai/` + hooks + cross-agent pointers (16 files, interactive, idempotent). Prompts for maturity level. *(Does NOT yet emit the S20 GT audits or the S21 co-pilot — that is S22.)*
- `vajra claude` launches Claude Code with hook injection and prints a receipt on exit. `--settings` injection is additive (proven S07).
- `vajra next` prints the `.ai/` handoff packet (read-only); `--advance` bumps SESSION + SESSION-BOOT + prompt pointer. L3 skips confirm, L1/L2 require it.
- `vajra check` runs 10 drift-detection checks. `vajra estimate` predicts token spend (3:1 output ratio — unvalidated placeholder).
- Compression engine + 4 heuristics (cargo, git, npm, pytest) + meter; budget guard enforces `budget.cap_usd`. GitHub Actions CI green. All tests green: `cargo test` (103), `cargo clippy`.
- **Ground-truth audit (hardened S20)** — every 5th session audits **direction drift** + **discipline drift** + a meta-check. Next GT = S25.

## What Is Broken
- Only Claude Code is wired — no second agent launcher exists.
- **Scaffold lag** — `vajra init`'s `TPL_CONSTRAINTS` predates S20/S21: no `ground_truth:` block, no `copilot:` rules, stale `approval_tokens`. New projects don't inherit the hardening (S22 fixes this).
- **Co-pilot v0 limits** — simple-glob + `cmd:` substring (no `**`/regex); surfaces include **paths + why**, not file contents; debounce keys on `session_id` (shared fallback dir if absent). Wired into this repo's committed settings (dogfood); the launcher's `--settings` path injects only the PostToolUse compression hook so far.
- `vajra estimate` output ratio (3:1) is unvalidated placeholder — order-of-magnitude only.
- **First-run payoff still thin** — `vajra init` produces files, not a felt win (Phase 2 item 9).

## What Is In Progress
- Nothing — between sessions. Next: **S22 — scaffold propagation** (emit S20 GT audits + S21 co-pilot from `vajra init`).

## Cost Tracking
- Session 00–05: $0.00 (no API calls)
- Session 06: $0.00 (docs only)
- Session 07: ~$0.46 (3 test runs via `vajra claude -p`)
- Session 08–20: ~$0.00 (code/no-code sessions, no API calls)
- Session 21: ~$0.00 (code session, no API calls)
- Cumulative: ~$0.46
