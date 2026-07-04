# Session 42 — Git-level hooks scaffolding + `jq`-preflight (fail-closed)

> Founder pick C (locked at S40, confirmed at S41 close). Two S40 findings, bundled: the
> high-leverage bounded gap (git-level hooks not scaffolded) + the one real latent leak
> (`jq`-missing → fail-open). Both are enforcement-completeness — the moat. Branch:
> `session-42-git-level-hooks-jq-preflight`.

## ⛔ Guiding principle (non-negotiable — AGENTS.md L147)
**A check that cannot evaluate FAILS. Never silently pass.** The suite-wide `jq`-missing →
fail-open is a direct violation. Fail-closed is the correctness direction (over-block > leak,
the S39 founder directive). Enforcement is the moat; this session hardens it, it does not add
surface.

## The two gaps (both S40, ranked)

### Gap 1 — `jq`-missing → fail-open (the real latent leak, constitution violation)
Every Vajra hook parses the payload with `jq` (`CMD=$(echo "$INPUT" | jq -r '…' || echo "")`).
If `jq` is absent, `CMD` is empty → the classifiers match nothing → `exit 0` → **the guard passes
everything.** Affected: `hook-publish-guard.sh`, `hook-session-guard.sh`, `hook-copilot-loader.sh`,
`hook-pre-bash.sh` (audit the set). **Fix = a `jq`-preflight:** if `jq` is not on `PATH`, **fail
closed** for the enforce path (L2/L3 → exit 2 with a one-line "jq required for Vajra enforcement"
message; L1 → advise + exit 0, consistent with the maturity gate). Decide once, factor it so every
hook shares it (a sourced helper, or a copied preflight block — but keep it byte-identical / one
source if propagated into `vajra init`).

### Gap 2 — git-level `pre-push`/`pre-commit` not scaffolded (high-leverage bounded)
The **vajra repo** already has `.githooks/pre-commit` (blocks main-commits / >3 staged / `.ai/`
drift) + `.githooks/pre-push` (blocks push to main/master) with `core.hooksPath=.githooks`.
Scaffolded **projects** get only the `.claude/` L3 hooks — so a raw `echo N > .ai/SESSION` write
or a direct `git push` bypasses the Bash guards. **Fix = scaffold the git-level belt into
`vajra init`** (ROADMAP #17): emit `.githooks/pre-push` + `.githooks/pre-commit` via `include_str!`
(byte-identical, the S22/S29/S38 one-source pattern), and set `core.hooksPath` for the scaffolded
project. This is an **independent L2 layer** beneath the L3 `.claude/` hooks — belt and suspenders.

## Scope discipline (the S41-flagged risk)
This is **two concerns**. The 1-story / ≤3-file cap is real. **Recommended split at BOOT:**
- **Primary slice (do first): Gap 1 (`jq`-preflight)** — smaller, closes the constitution 🔴, banks
  first. Repo hooks only, or repo + scaffolded if it stays ≤3 files.
- **Second slice: Gap 2 (git-level scaffolding)** — the `include_str!` + `core.hooksPath` wiring +
  packaging (`Cargo.toml` un-exclude if `include_str!`'d from outside `src/`) + scaffold tests.
If both won't fit one clean session, **ship Gap 1, carry Gap 2 to S43** (the S37→S38 precedent).
Founder confirms the split at BOOT.

## Proof discipline (required)
- **Gap 1:** drive each hook with `jq` removed from `PATH` (e.g. `PATH=/usr/bin env -i` or a shim
  dir) and assert **exit 2 at L2/L3** (was exit 0), **exit 0 at L1** (advise). Assert a real payload
  still classifies correctly when `jq` IS present (zero regression).
- **Gap 2:** a real `vajra init` into a temp git repo → assert `.githooks/pre-push` + `pre-commit`
  are byte-identical to the canonical source, executable, and `core.hooksPath` is set; drive the
  scaffolded `pre-commit` to block a main-commit / >3-staged / `.ai/`-drift, and `pre-push` to block
  a push to main.
- `scripts/verify-session-42.sh` green; `cargo test` + clippy + fmt clean.

## Guardrails
- Branch `session-42-git-level-hooks-jq-preflight` from `main`.
- Max 2 assumptions / 2 retries / ≤3 files / ~2h. New chat.
- To push/PR, the founder launches with `VAJRA_ALLOW_PUBLISH=1` (the publish-guard blocks the agent).

## Explicitly OUT of scope (carry-forwards)
- **cargo/npm/pytest exit-code fold gap** (S41 carry) — key those heuristics off inferred success
  instead of `exit_code == Some(0)`. Own session (compression, not enforcement).
- **Live re-dogfood of the moat** (S40 GT candidate A / ROADMAP #17a) — the moat is still
  live-unverified; S41 compression is replay-proven only. Own session, costs real $.
- **Silent-parse-failure blindness** / **boot cache-write cost** / **`.claude/settings.json` merge**
  — backlog, unchanged.
