# Session 32 — Darshan enforcement (CODE)

## Goal
Move Darshan from *advised* → *enforced*: make the agent actually load + follow `darshan/SKILL.md` every session (S31 finding #1, founder-ranked first — the most-felt daily pain).

## Goal achieved? ✅ Yes
The `SessionStart` boot packet now **surfaces the Darshan speaking skill in-context every session** (was only a prose row in AGENTS.md the agent skipped), and `vajra init` propagates it byte-identically via the `include_str!` one-source pattern.

## What shipped
| File | Change |
|---|---|
| `scripts/hook-session-start.sh` | Prints a Darshan directive into every boot packet: one rule (inlined) + `darshan/SKILL.md` pointer + `▶ ACK NOW` speak-back. |
| `src/cli/init.rs` | `TPL_HOOK_SESSION_START` inline copy → `include_str!` of the canonical hook (kills the pre-existing drift; S22/S28/S29 pattern). |
| `Cargo.toml` | Un-exclude the hook so `include_str!` ships with `cargo install`. |
| `scripts/verify-session-32.sh` | 18 checks — boot surfacing, speak-back, cargo-package, byte-identical scaffold, regressions. |

Commits (≤3 files each): `ff951de` (enforcement) · `4c9d8d7` (verify).

## Evidence
- `scripts/verify-session-32.sh` → **ALL GREEN (18 pass, 0 fail)**.
- Real boot hook output prints the `┌─ SPEAKING SKILL · DARSHAN ─┐` block above the load-order files.
- `cargo test` 98 pass · fmt · clippy clean.
- A real `vajra init` into a temp repo inherits the hook byte-identical (`cmp -s` PASS).
- Meta: this fix moves a feature *advised → enforced* — the S31 meta-rule.
- PR [#24](https://github.com/ifelse-codes/vajra/pull/24).

## Design note (the "stronger enforcement" ask)
A hook cannot read the agent's prose, so true enforcement is a design problem. Chosen: **loud-at-boot directive + speak-back ACK** (load it every session = ~80% of the win). Follow-on, documented not built: a `Stop`-hook heuristic that flags wall-of-text replies (word-count / paragraph-count over a threshold).

## Limits / carry-forward
- The speak-back is agent-honored, not machine-verified (no output-reading hook yet).
- Compression schema fix (S31 #2) still pending — pre-pinned, do NOT fold (1-story).
- Brownfield onboarding (S31 #3) after that. Second agent stays parked.

## Next options (pick one)
- **A — Compression schema fix (S31 #2, recommended).** Remove `rename_all="camelCase"` from `HookInput` only; keep it on `HookToolResponse`; add a regression test from a verbatim captured real CC payload. Highest-ranked remaining core breakage; pre-pinned exact 2-file fix. Risk: fixtures encode the wrong casing — must add the real-payload test or it stays false-green.
- **B — Brownfield onboarding (S31 #3).** A guided "session 0: study this existing codebase" kickoff + rethink hook placement so they don't land in the project's own `scripts/` package + `vajra claude` auth pre-check. Risk: largest scope of the three; easy to exceed 1 story.
- **C — Darshan speak-back hardening (S32 follow-on).** Build the `Stop`-hook wall-of-text heuristic so Darshan is machine-enforced, not agent-honored. Risk: heuristics on free-form output are noisy; may fight legitimate long replies (code blocks, tables).
