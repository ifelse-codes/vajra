# Session 22 — Scaffold Propagation (CODE)

**Goal:** make `vajra init` emit the S20 ground-truth hardening + the S21 co-pilot loader, so every Vajra-scaffolded project inherits them — not just this repo.

**Status:** ✅ achieved. [PR #12](https://github.com/ifelse-codes/vajra/pull/12). verify-session-22.sh **12/12 ALL GREEN**.

## What shipped

| Area | Change |
|---|---|
| `src/cli/init.rs` | `TPL_CONSTRAINTS` += `ground_truth:` (vision/roadmap/constitution audits + question-lists + `drift_axes`) + `copilot:` (2 starter `⚡on` rules); refreshed `approval_tokens` (+`"go ahead and commit"`) + added `ground_truth_commit_exempt_branch_suffixes`. `TPL_CLAUDE_SETTINGS` += `PreToolUse` wiring. Ships the hook (17 files, was 16). 4 new unit tests. |
| `Cargo.toml` | un-exclude **just** `scripts/hook-copilot-loader.sh` (`scripts/*` + `!` negation) so `include_str!` compiles under `cargo install` — verified via `cargo package --list`. |
| `scripts/verify-session-22.sh` | 12 checks incl. real `vajra init </dev/null` into temp dir. |
| `scripts/demo-session-22.sh` | cumulative; shows a fresh project enforcing day one. |

## Key decision (the prompt's required answer)

**How does `vajra init` ship the ~70-line hook without it drifting from canonical `scripts/hook-copilot-loader.sh`?**

→ **Option (b): `include_str!` the canonical file.** One source of truth, embedded at compile time; the scaffolded copy is **byte-identical** (verify's `hook-no-drift` `cmp` gate). No hand-copy — exactly the S19 no-drift rule Varta enforces.

- Rejected **(a) `const` copy** — a second copy drifts, the precise failure mode S19 fought.
- Rejected **(c) runtime template reference** — a single static binary can't read a file that isn't installed beside it, so it collapses into (b) anyway.
- **Cost of (b):** the canonical file was excluded from the published crate. Fix: un-exclude that one file. Generalizable rule recorded: *anything `include_str!`'d from outside `src/` must be in the crate package.*

## Evidence

- `verify-session-22.sh` 12/12: cargo fmt/clippy/test-init/build + real scaffold → GT audits present, copilot rules present, hook executable + wired twice + byte-identical, **propagated co-pilot fires (exit 2 at L2)**, all include targets exist.
- `cargo test` 107 pass; fmt + clippy clean.
- Dogfood: this repo's own `cmd:git commit` rule **blocked the first commit live** until STATE.md was surfaced.

## Self-review

- **What breaks?** `cargo install` compile of `include_str!` — mitigated + verified via `cargo package --list`.
- **Hidden assumptions?** `vajra init </dev/null` → L2 defaults (verified in demo); Cargo exclude negation works (verified).
- **Scope:** 1 story, 4 files across 2 atomic commits. Intact.

## Next options (pick one)

### A. First-run "aha" (Phase 2 item 9 — closes Phase 2)
- **Goal:** make `vajra init` → first session deliver a *felt* win in ~2 minutes.
- **Why pick:** the co-pilot is now a felt moment **and** (post-S22) it propagates to every project — the aha is finally real and reproducible, not repo-local. Finishes Phase 2.
- **Key risk:** "aha" is subjective; needs one concrete scripted moment, not just more files.

### B. Render `.ai/` → `.varta` (the deferred S19 follow-up)
- **Goal:** one-way generate a glanceable `.varta` artifact from the live `.ai/` (generated, never hand-kept).
- **Why pick:** completes the Varta language story; S22 just proved "generated-from-one-source" works (include_str!), so a drift-free render is now low-risk.
- **Key risk:** value — a rendered `.varta` may be a solution seeking a problem if the agent reads `.ai/` fine already.

### C. Second agent launcher (promote from backlog)
- **Goal:** wire a second agent (Codex or Cursor) so Vajra is cross-agent in practice, not just in docs.
- **Why pick:** the north-star is the *cross-agent* coach; only Claude is wired today.
- **Key risk:** big lift; enforcement is hook-shaped around Claude Code — may not port cleanly and could stall.
