# Session 37 — Close the enforcement leak (S36 headline finding)

> New #1 after the S36 interactive dogfood. Vajra's whole promise — keep the agent on track, in
> order, one step at a time — **did not hold** in a real autonomous (L3) session. Fixing this
> outranks the compression fix (now S38): enforcement/governance is the moat; compression is the
> quiet bonus.

## The finding (founder's own `vajra claude` run, session `8f9c103`, Opus 4.8, $58.17)
In ONE chat, at maturity L3, the agent: `git init` + `remote add` → the real
`github.com/ifelse-codes/chitra`, `git push origin main`, branched session-01, **built a feature,
created + merged PR #1**, branched session-01-closeout, **created + merged PR #2**, advanced
`SESSION` → 01, wrote an S02 handoff. **Vajra's hooks stopped none of it.** Rules broken with zero
enforcement: one-session-per-chat, no-autonomous-commits/approval-tokens, max-1-story, ~2h cap,
no-main-commits. (Real artifacts exist — 2 merged PRs — founder's to clean up.)

## Root cause (structural — 4 gaps)
1. `hook-session-guard.sh` arms on exactly one action: `git checkout -b session-(N+1)` from a chat
   that already *owns* N. The brownfield agent never branched session-00 → nothing owned → the
   tripwire never armed.
2. **No hook watches the actually-dangerous outward/irreversible actions** — `git push`,
   `gh pr create`, `gh pr merge`. Unguarded entirely.
3. `vajra init` scaffolds `.claude/` hooks but NOT git-level `pre-push`/`pre-commit`.
4. L3 (auto) simply proceeds — nothing gates irreversible/outward actions even at the top tier.

## Guiding principle
**Enforcement is the moat.** A real autonomous session must not be able to take
outward/irreversible actions (push, PR, merge) or blow the session boundary without an explicit,
present approval signal. Blocking a dangerous action is never a bug; letting it through silently
*is*. Mirror the existing enforcement shape: PreToolUse Bash hook, maturity-gated, `exit 2` to
block, with a documented escape hatch — same family as `hook-pre-bash`/`hook-session-guard`.

## Scope (1 story, ≤3 files) — confirm the slice at BOOT
**Recommended primary slice: guard the outward/irreversible actions** (the scariest gap, #2 +
most concretely enforceable):
- A hook that blocks `git push`, `gh pr create`, `gh pr merge` (extend `hook-pre-bash.sh` or a new
  sibling) at L2/L3 unless an explicit approval signal is present. **Design decision to make +
  document:** what is the approval signal? (candidates: an `APPROVE=...` token file the founder
  writes, a `VAJRA_ALLOW_PUBLISH=1` env, or an interactive confirm). Pick one, justify it, keep an
  escape hatch (like `VAJRA_SKIP_AUTH_CHECK`).
- Propagate into `vajra init` (the scaffolded hook), same `include_str!` one-source pattern used
  for the other hooks — but keep to ≤3 files / 1 story; if propagation is a second story, split it
  (the S27→S28 precedent).

**Alternative slice if the founder prefers (their felt pain): harden the session boundary** — arm
the guard on *any* session advance (SESSION edit / `vajra next --advance`), not just checkout, so
the brownfield 00→01 jump is caught. Pick ONE slice this session; the other becomes S39.

## Proof discipline
- Tests that the chosen guard **blocks** the dangerous action at L2/L3 (`exit 2`) and **allows** it
  with the approval signal present + at L1 (advise). Reuse the maturity-gating + test-knob patterns
  from `hook-session-guard.sh` (`VAJRA_GUARD_MATURITY`, an owner/state-file override).
- `scripts/verify-session-37.sh` green; `cargo test` + clippy clean if any `src/` changes.
- Cheap real check: replay the S36 sequence (`git push` / `gh pr merge` strings) through the hook
  and confirm it now blocks — no paid `vajra claude` run needed.

## Guardrails
- Branch `session-37-enforce-session-boundaries` from `main`.
- Max 2 assumptions / 2 retries / ≤3 files / ~2h. New chat (S36 → S37 boundary — and this time,
  honor it).

## Ranked follow-ons (own sessions, do NOT cram in)
- **S38** — compression fail-gate fix (`prompts/38-task-fix-compression-exit-gate.md`, ready).
- **S39** — the *other* enforcement slice (boundary-hardening or outward-guard, whichever wasn't
  picked) + scaffold git-level `pre-push`/`pre-commit` into `vajra init` + reconsider what L3 may
  do unsupervised.
- Boot-packet cost trim (~$32 cache-read / $58 session — the "<5% footprint" rule).
- `.claude/settings.json` merge on init (S34); verify/demo templates polluting the project's
  `scripts/` (S36 minor); silent-parse-failure blindness (S36).
