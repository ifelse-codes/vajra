# Session 29 — Propagate the session-guard into `vajra init`

> CODE session. Branch `session-29-session-guard-propagation` from `main`. Normal loop (BOOT→…→CLOSE).
> Chosen at S28 closeout. Closes the **second half** of the S28 split: the S26 one-session-per-chat guard, deferred so S28 could ship Darshan as a clean 1-story.
> The S22 + S28 pattern (`include_str!` the canonical artifact, wire it, add byte-identity scaffold tests) is the proven template.

## Why this session
- **The remaining gap:** S28 made fresh projects inherit **Darshan**, but a freshly-`init`ed project still gets **neither** the S26 `hook-session-guard.sh` **nor** the `one_session_per_chat: true` flag. New projects can't enforce one-session-per-chat.
- **The S22/S28 lesson:** enforcement only matters if every scaffolded project inherits it.

## What to propagate (one artifact, four wiring points)
1. **The hook** — `const TPL_HOOK_SESSION_GUARD = include_str!("../../scripts/hook-session-guard.sh")` + `fx("scripts/hook-session-guard.sh", TPL_HOOK_SESSION_GUARD)` in the emit list (executable, like the co-pilot hook).
2. **Settings wiring** — add `hook-session-guard.sh` to `TPL_CLAUDE_SETTINGS`'s PreToolUse(Bash) array (alongside `hook-copilot-loader.sh`).
3. **The flag** — emit `one_session_per_chat: true` in `TPL_CONSTRAINTS`'s `session:` block (the guard is gated on it).
4. **The gitignore** — the scaffold currently emits **no `.gitignore`**. Add a `TPL_GITIGNORE` template that ignores `.ai/.session-owner` (the guard's owner record), and add it to the emit + dir list. *(Decide in PLAN: new `.gitignore` file vs. appending — a new file is cleaner.)*

## The mechanism (PLAN-time, ≤2 assumptions)
- **Cargo.toml:** `scripts/*` is excluded with one negation (`!scripts/hook-copilot-loader.sh`). Add a second negation `!scripts/hook-session-guard.sh` so `include_str!` compiles under `cargo install`. **Verify with `cargo package --list`** (the S22 packaging gotcha — any file `include_str!`'d from outside `src/` must be in the package).
- Add scaffold tests mirroring `scaffold_ships_copilot_hook_verbatim` / `scaffold_wires_copilot_into_settings`:
  - guard hook present + **byte-identical** to canonical + executable,
  - settings has 2 Bash-matcher hooks (copilot + guard),
  - `TPL_CONSTRAINTS` has `one_session_per_chat: true`,
  - scaffolded `.gitignore` contains `.ai/.session-owner`.
- **Skill/enforcement-not-renderer holds:** `init` only copies the hook + wires config; no Rust logic added.

## Constraints / guardrails
- **Max 7 commands** — no 8th. This rides `init`.
- **≤3 files per atomic commit, max 1 story.** Likely touched: `src/cli/init.rs` (templates + emit list + tests) + `Cargo.toml`.
- `cargo test` green; clippy clean; existing scaffold tests (incl. S28's Darshan tests) must still pass.

## Definition of done
- A fresh `vajra init` in an empty repo produces `scripts/hook-session-guard.sh` (byte-identical, executable), wires it into `.claude/settings.json` PreToolUse(Bash), emits `one_session_per_chat: true`, and writes a `.gitignore` ignoring `.ai/.session-owner`.
- New scaffold tests assert each, and that Darshan (S28) + co-pilot (S22) propagation still hold (no regression).
- `scripts/verify-session-29.sh` exits 0; `scripts/demo-session-29.sh` shows a scaffolded repo inheriting the guard.
- `cargo test` green; clippy clean.

## Output
- Propagation in `init.rs` + `Cargo.toml` + verify/demo + `sessions/session-29-summary.md` ending in exactly 3 next options (A/B/C).

## Carry-forwards
- **S30 is the next ground-truth (NO-CODE)** — `NN % 5 == 0`. After S29, the next session is the audit.
- **Second agent stays parked** — owner-gated on founder satisfaction with Vajra-on-Claude.
- **Dogfood session** (run Varta+Darshan on a real project) — still in backlog; strong candidate once propagation fully lands (S29 completes it).
- **STATE.md PR-status drift** (now 5×, S15/S20/S25/S27/S28): at closeout write "open (merge after closeout)" / actual merge state, never "pending merge".
- Still open: `vajra estimate` 3:1 ratio unvalidated; `vajra claude` no auth pre-check.
