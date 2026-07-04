# Session 42 — Git-level hooks + `jq`-preflight (CODE, founder pick C) — Gap 1 delivered

## Goal
Founder pick C, two bundled S40 findings. **Founder split at BOOT: Gap 1 first (the constitution
🔴), Gap 2 second — carry Gap 2 to S43 if it won't fit one clean session.** Gap 1 delivered; Gap 2
carried (it is a second story; `max_stories:1`).

## Delivered — Gap 1: `jq`-preflight, fail-closed (AGENTS.md L147)
The S40 constitution finding: every hook parses the CC payload with `jq`
(`X=$(echo "$INPUT" | jq -r … || echo "")`). With `jq` absent, `X` is empty → the classifiers
match nothing → `exit 0` → **the guard passes everything.** "A check that cannot evaluate FAILS."

**Fix:** one **byte-identical** fail-closed preflight, inserted right after `set -euo pipefail` in
all **five** `jq`-parsing hooks (`hook-publish-guard`, `hook-session-guard`, `hook-copilot-loader`,
`hook-pre-bash`, `hook-pre-write`):
```bash
if ! command -v jq >/dev/null 2>&1; then
  _VROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
  _VMAT="${VAJRA_GUARD_MATURITY:-$(grep -m1 '^maturity:' "$_VROOT/.ai/CONSTRAINTS.yaml" … || echo L2)}"
  [ "$_VMAT" = "L1" ] && { echo "…advise (L1)."; exit 0; }
  echo "…BLOCKED: jq required for Vajra enforcement (fail-closed)." 1>&2
  exit 2
fi
```
The block is self-contained (own `_VROOT`/`_VMAT` locals; reads maturity via `grep`/`awk`, not
`jq`), so it travels **inside** the `include_str!`'d hook copies — scaffolded projects inherit the
fix with **no `init.rs` change**. The audit found **5** hooks (the prompt named 4; `hook-pre-write.sh`
was the 5th).

## Evidence
- `scripts/verify-session-42.sh` — **31/31 GREEN.** Drives all 5 hooks under a `jq`-less `PATH`
  shim → **exit 2 at L2** (was 0), **exit 0 at L1**; asserts zero regression with `jq` present
  (real push blocks, session boundary blocks, copilot fires, benign passes); asserts the preflight
  block is byte-identical across all 5; asserts a real `vajra init` scaffolds the 3 hooks with the
  block baked in.
- `cargo test` + `clippy -D warnings` + `fmt --check` clean; `cargo build` OK.
- Commits `f3778b5` (3 scaffolded enforce hooks) + `f15edb6` (2 repo GT hooks + verify). ≤3 files
  each (`.githooks/pre-commit`-enforced). ~$0 (no paid `vajra claude` run).

## Carry-forwards
- **Gap 2 — git-level `pre-push`/`pre-commit` scaffolding into `vajra init`** (ROADMAP #17 second
  half): scaffold `.githooks/*` + `core.hooksPath` as an independent L2 belt. Second story → S43.
- **Dogfood gate still UNMEASURED** (S40) — moat + S41 compression + this S42 fix are all
  test/replay-verified, not live-verified. Re-dogfood (#17a) still owed.
- **cargo/npm/pytest exit-code fold gap** (S41 carry) — own compression session.

## Next options (exactly 3 — A/B/C, from ROADMAP)
- **A — Gap 2: git-level hooks scaffolding (ROADMAP #17b).** Goal: scaffold `.githooks/pre-push` +
  `pre-commit` + `core.hooksPath` into `vajra init` as an L2 belt beneath the L3 `.claude/` hooks.
  Why: completes founder pick C; closes the raw-`echo > .ai/SESSION` bypass. Risk: `Cargo.toml`
  un-exclude + `core.hooksPath` interplay with a project's existing hooks (idempotence).
- **B — Re-dogfood the moat live (ROADMAP #17a).** Goal: run the real `vajra claude` loop at L3 and
  prove publish-guard + session-guard block a live agent. Why: the dogfood gate is UNMEASURED since
  S36 — everything since is test-only. Risk: costs real $; needs founder `VAJRA_ALLOW_PUBLISH` care.
- **C — cargo/npm/pytest exit-code fold gap (S41 carry / backlog).** Goal: key those 3 heuristics
  off the engine's inferred success instead of `exit_code == Some(0)` so they fold on real CC. Why:
  the last dead compression path. Risk: their misleading `_fail`-on-success branch (S41-flagged).
