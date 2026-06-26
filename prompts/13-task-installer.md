# Session 13 — Installer / Release Path

## Goal
Ship `vajra` so anyone can install it in one command.

## Context
- Phase 1 complete — all 6 core items proven.
- Binary is `vajra`, crate is `vajractl`.
- No installer, no release pipeline, no CI exists yet.
- crates.io name `vajractl` availability unconfirmed.

## Deliverables
1. `cargo install vajractl` works (publish to crates.io or confirm path)
2. Homebrew formula (tap or core)
3. GitHub release with prebuilt binaries (macOS arm64 at minimum)
4. One-liner install in README
5. CI pipeline for building + testing on push

## Constraints
- Max 1 story
- Max 3 files per atomic commit
- Branch: `session-13-installer`
- Prioritize: working install > pretty CI > cross-platform coverage
