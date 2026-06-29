# Session 28 — Propagate Darshan + session-guard into `vajra init`

> CODE session. Branch `session-28-init-propagation` from `main`. Normal loop (BOOT→…→CLOSE).
> Chosen at S27 closeout. Closes two deferrals: the **S27 Darshan** propagation and the **S26 session-guard** rider. The S22 pattern (propagate the co-pilot into `init`) is the proven template.

## Why this session
- **The gap:** `vajra init` scaffolds the `.ai/` workflow + co-pilot loader + ground-truth audits (S22), but a freshly-`init`ed project gets **neither Darshan** (S27 — the human's glanceable output skill) **nor the S26 one-session-per-chat guard.** New projects inherit the old loop, not the current one.
- **The S22 lesson:** enforcement/skills only matter if every project inherits them. Propagation is how a one-repo win becomes the product.

## What to propagate (two artifacts)
1. **Darshan** — emit `darshan/SKILL.md` (via `include_str!` of the canonical file, like `TPL_HOOK_COPILOT_LOADER`) + the `.ai/AGENTS.md` Speaking Skills boot pointer into the scaffolded constitution.
2. **Session-guard** — ship `scripts/hook-session-guard.sh` (`include_str!`), wire it into the scaffolded `.claude/settings.json` PreToolUse(Bash), gitignore `.ai/.session-owner`, and emit `one_session_per_chat: true` in the scaffolded `CONSTRAINTS.yaml`.

## The mechanism (PLAN-time, ≤2 assumptions)
- Follow `src/cli/init.rs` exactly as it already does for the co-pilot: `const TPL_* = include_str!(...)`, add to the file-emit list (~line 265), un-exclude any newly-shipped file in `Cargo.toml` so `cargo install` compiles it.
- Add scaffold tests mirroring `scaffold_ships_copilot_hook_verbatim` / `scaffold_wires_copilot_into_settings` for both new artifacts.
- **Skill-not-renderer holds:** still no rendering in Rust — `init` only *copies* the skill file and wires the pointer.

## Constraints / guardrails
- **Max 7 commands** — no 8th. This rides `init`.
- **≤3 files per atomic commit, max 1 story.** Likely touched: `src/cli/init.rs` + `Cargo.toml` + the scaffolded-template strings (in `init.rs`).
- **SCOPE RISK — split if needed:** propagating *both* Darshan and the session-guard may exceed 1 story. **If so, do Darshan-only this session (S28) and split the session-guard to S29** — decide in PLAN and say which.
- `cargo test` green; clippy clean; the existing scaffold tests must still pass.

## Definition of done
- A fresh `vajra init` in an empty repo produces `darshan/SKILL.md`, the AGENTS.md Speaking Skills pointer, and (if not split) the session-guard hook + settings wiring + gitignore + `one_session_per_chat: true`.
- New scaffold tests assert each propagated artifact is present and byte-identical to the canonical source.
- `scripts/verify-session-28.sh` exits 0; `scripts/demo-session-28.sh` shows a scaffolded repo inheriting Darshan (+ guard).
- `cargo test` green; clippy clean.

## Output
- Propagation in `init.rs` + verify/demo + `sessions/session-28-summary.md` ending in exactly 3 next options (A/B/C).

## Carry-forwards
- **Second agent stays parked** — owner-gated on founder satisfaction with Vajra-on-Claude.
- **Dogfood session** (run Varta+Darshan on a real project) — still in backlog; strong candidate once propagation lands.
- **STATE.md PR-status drift** (now 4×, S15/S20/S25/S27): at closeout write "open (merge after closeout)", never "pending merge".
- **S30 is the next ground-truth (NO-CODE)** — `NN % 5 == 0`.
- Still open: `vajra estimate` 3:1 ratio unvalidated; `vajra claude` no auth pre-check.
