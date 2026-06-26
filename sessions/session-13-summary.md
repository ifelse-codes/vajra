# Session 13 Summary — Installer / Release Path

## Goal
Ship `vajra` so anyone can install it in one command.

## Goal Achieved?
Yes. All 5 deliverables complete, CI green on first run.

## Evidence
- `cargo package --allow-dirty` → 35 KiB crate, publishes as `vajractl`
- GitHub Actions CI fires on push/PR — test + clippy + fmt on macOS + Linux
- GitHub Actions release workflow builds macOS arm64/x86_64 + Linux x86_64 on tag push
- Homebrew formula template at `Formula/vajra.rb` (SHA256 placeholders)
- README install section with 4 methods
- `scripts/verify-session-13.sh` — 13/13 checks pass
- [PR #1](https://github.com/ifelse-codes/vajra/pull/1) — CI green on both runners

## What Changed
| File | Change |
|---|---|
| `Cargo.toml` | Publish metadata + exclude list |
| `.github/workflows/ci.yml` | CI pipeline (test/clippy/fmt, macOS+Linux) |
| `.github/workflows/release.yml` | Release pipeline (3 targets, GH release) |
| `Formula/vajra.rb` | Homebrew formula template |
| `README.md` | Install section + updated status table + command reference |
| `scripts/verify-session-13.sh` | 13-check verification |
| `scripts/demo-session-13.sh` | Demo script |

## Commits
1. `a8ec0e4` — feat: add crate metadata, CI and release workflows
2. `b967989` — feat: add install docs, Homebrew formula, and verify script
3. `51a78c3` — chore: add demo script for session 13
4. `96f8ed5` — fix: update repo URLs to ifelse-codes/vajra

## Cost
- ~$0.00 (no API calls — code session)

## Next Session Options

### A. Add second agent (Codex or Cursor)
- **Goal:** Prove `vajra <agent>` works with something other than Claude Code
- **Why:** This is the core vendor-neutral promise — Phase 2 item 7
- **Risk:** Deep integration requires understanding the agent's hook/config mechanism

### B. Maturity levels (L1/L2/L3)
- **Goal:** Add `maturity: L1|L2|L3` to CONSTRAINTS.yaml with enforcement tiers
- **Why:** Gives users a growth path from report-only to auto-advance
- **Risk:** Scope creep — needs clear boundaries on what each level enforces

### C. Clean legacy references
- **Goal:** Remove `vajra launch` alias and stale references from code and docs
- **Why:** Low-risk hygiene before public release
- **Risk:** Minimal — but low impact too
