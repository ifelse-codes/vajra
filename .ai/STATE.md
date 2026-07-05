# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S44 complete, S45 not yet started). S44 delivered on
`session-44-settings-json-merge` (commit `8a78ca6` feature+proof). PR pending (founder pushes — the
publish-guard blocks the agent, by design).

## Active PRs
- S44 settings-json-merge PR — **pending** (founder pushes: the publish-guard blocks the agent).
  Push: `VAJRA_ALLOW_PUBLISH=1 git push -u origin session-44-settings-json-merge`, then open PR to `main`.
- Merged: S43 git-level-belt [#38](https://github.com/ifelse-codes/vajra/pull/38) · S42 `jq`-preflight
  [#37](https://github.com/ifelse-codes/vajra/pull/37) · S41 compression fail-gate
  [#36](https://github.com/ifelse-codes/vajra/pull/36) · S40 GT closeout [#35](https://github.com/ifelse-codes/vajra/pull/35).

## Direction (set S18 … enforcement-hardened S37–S39, audited S40, compression fixed S41, jq fail-closed S42, git-belt scaffolded S43, brownfield-settings merged S44)
- **Co-pilot, not cop** — guide the agent in real time; **Varta** = the agent's lane, **Darshan** = the human's lane.
- **Enforcement is the moat — S40 verdict stands: the S36 harm is closed, the proof is not.** Every S36
  outward action (push / 2× PR create+merge) BLOCKS, scaffolded (S38); the moat is **test-verified, not
  live-verified** — the dogfood gate is UNMEASURED (~$0 `vajra claude` since S36). A live re-dogfood
  (ROADMAP #17a) stays the missing verification.
- **S44 closed the last silent L3 leak** — `vajra init` now MERGES Vajra's hooks into a pre-existing
  `.claude/settings.json` instead of skipping it, so brownfield repos that already own one get the L3
  moat wired (Darshan boot, co-pilot, session-guard, publish-guard). Additive + idempotent; malformed →
  left untouched + warn. Completes the S37→S44 enforcement-completeness arc across both L2 (git) and L3
  (`.claude/`) belts, greenfield **and** brownfield.
- **S43 added the git-level L2 belt** to scaffolded projects; **S42 closed the constitution 🔴** (`jq`
  fail-open, fail-closed on all 5 hooks); **S41 fixed the compression fail-gate** (git family folds
  regardless of `exitCode`; generic path stays conservative).
- **Second agent stays parked** — cross-agent breadth still zero code (S25, 19 sessions stale); the
  S40 meta-check flags Claude-only depth accumulating. S45 (all-lens GT) re-examines this.

## What Currently Works
- **`.claude/settings.json` merge on `vajra init` (S44).** A pre-existing `.claude/settings.json` (only)
  routes through `merge_claude_settings_file` → the pure `merge_claude_settings(existing, template)`:
  appends Vajra's `SessionStart` + `PreToolUse` hook groups additively (Vajra's SessionStart rides as a
  separate array entry beside the user's — both fire), preserving every user key/hook. **Idempotent:** a
  group is appended only if the event array lacks a structurally-equal group AND doesn't already
  reference its `.ai/hooks/*.sh` paths (checked vs a pre-merge snapshot so the shared co-pilot hook can't
  self-cancel). **Malformed / non-object existing JSON → left untouched + loud warn**, init still exits 0.
  Greenfield path unchanged. Launcher's ADR-0003 `--settings` merge NOT reused (different shape).
  verify-session-44.sh 24/24. **Accepted cosmetic:** `serde_json` sorts object keys (no `preserve_order`
  feature) → key *order* may shift on merge; zero content dropped, array/execution order preserved.
- **Git-level belt scaffolded into `vajra init` (S43).** `.githooks/pre-commit` + `pre-push`
  byte-identical to canonical (via `include_str!`) + `core.hooksPath=.githooks` (`configure_githooks_path`:
  idempotent; non-git = no-op). Independent L2 layer beneath the L3 `.claude/` hooks. verify-session-43.sh 22/22.
  **NOTE (intended):** after `vajra init` on a fresh greenfield repo on `main`, the first `git commit` is
  blocked by the scaffolded main-guard — branch `session-NN-*` first.
- **`jq`-preflight, fail-closed on all 5 `jq`-parsing hooks (S42).** `jq` missing → L2/L3 `exit 2`
  (block), L1 `exit 0` (advise); travels inside the `include_str!`'d copies. verify-session-42.sh 31/31.
- **Compression folds the git family regardless of `exitCode` (S41).** Fail-gate applies only when
  `!heuristic.preserves_failure_signal()`; the git family declares it `true`. verify-session-41.sh 20/20.
- **Publish-guard, correct + scaffolded (S37→S39-B).** Blocks `git push` / `gh pr create|merge` / `glab mr *`
  at L2/L3 unless `VAJRA_ALLOW_PUBLISH=1`; strips quoted spans first. **Session-guard, armed on advance
  (S39-A) + scaffolded (S29).** Fires on `git checkout -b session-(N+1)` and `vajra next --advance`.
- **The vajra repo's own git belt** — `.githooks/pre-commit` + `pre-push`, `core.hooksPath=.githooks`.
  **Scaffolded into `vajra init` too (S43).**
- `vajra claude` · `vajra next` · `vajra check` · `vajra init` · `vajra estimate` · `vajra meter`.
  `cargo test` 117 lib (+6) + 12 adapter + integration pass; clippy clean; fmt clean.

## What Is Broken
- **🟡 cargo/npm/pytest never fold on real CC (S33/S41 carry).** Those heuristics branch on
  `exit_code == Some(0)`, which real CC never sends → `_fail` passthrough under 300/400 lines. Own future
  compression session.
- **🟡 Accepted publish-guard v0 limits.** Heredoc-body phrase over-blocks (fail-safe); obfuscated
  `g=push; git $g` evades (non-adversarial threat model); one env var authorizes the whole launch (coarse).
- **🟡 Merge reorders top-level JSON keys (S44, cosmetic).** `serde_json` sorts object keys (no
  `preserve_order` feature) → a merged `.claude/settings.json` may reorder the user's top-level keys.
  Zero content dropped, array/hook execution order preserved; enabling `preserve_order` is a dep change (out of scope).
- **🟡 Budget cap didn't bite / silent-parse-failure blindness / boot-packet cost** — backlog.

## What Is In Progress
- **S44 DONE + closed.** `.claude/settings.json` merge on init (`8a78ca6`); verify 24/24; ~$0. **Next
  (S45)** = mandatory NO-CODE ground-truth, **all three lenses combined** (dogfood/enforcement,
  direction/vision, process-cost) — `prompts/45-task-combined-ground-truth.md`, in a **new chat**.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 31: first real `vajra claude` dogfood since S07 (chitra; exact $ not captured).
- Session 36: ~$61.4 — two real runs against `/private/tmp/chitra`. Compression saved $0.
- Session 32–35, 37–44: ~$0.00 each — build/code + NO-CODE GT sessions; S41–S44 proven via replay /
  `PATH`-shim / temp-repo E2E, no paid `vajra claude` run.
- Cumulative: ~$62. **No real `vajra claude` spend since S36 — the dogfood gate stays UNMEASURED
  (S40 flagged it; live re-verify still owed for the S41–S44 changes).**
