# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S45 complete, S46 not yet started). S45 was the mandatory NO-CODE ground-truth;
audit on `session-45-combined-ground-truth`, doc-only closeout on the exempt `session-45-closeout` branch.
Output: `sessions/session-45-ground-truth.md`.

## Active PRs
- None open. Merged: S44 settings-json-merge [#39](https://github.com/ifelse-codes/vajra/pull/39) · S43
  git-level-belt [#38](https://github.com/ifelse-codes/vajra/pull/38) · S42 `jq`-preflight
  [#37](https://github.com/ifelse-codes/vajra/pull/37) · S41 compression fail-gate
  [#36](https://github.com/ifelse-codes/vajra/pull/36).
- Housekeeping: one stale `origin/session-42-*` remote branch lingers (local branches pruned cleanly).

## Direction (set S18 … enforcement arc completed S37–S44, audited-complete-but-unproven S45)
- **Co-pilot, not cop** — guide the agent in real time; **Varta** = the agent's lane, **Darshan** = the human's lane.
- **Enforcement is the moat — S45 verdict: the arc is COMPLETE, the proof is OWED.** The S37→S44
  enforcement-completeness arc is done (publish-guard + session-guard + jq-preflight + git-belt +
  settings-merge, across L2+L3, greenfield+brownfield, all scaffolded byte-identical). But the moat is
  **test/replay-verified, not live-verified** — proven live exactly once (S37); S38–S44 have only
  `verify-*.sh` + payload-replay + `cmp` evidence. **`dogfood_check` 🔴 UNMEASURED for the 4th
  consecutive GT** (S30, S35, S40, S45); ~$0 `vajra claude` since S36.
- **S46 = the live re-dogfood (#17a, founder pick A)** — run the real loop at L3 and prove ≥1 guard blocks
  an autonomous agent live (or find the next leak). The dollar figure in the ledger IS the proof.
- **Second agent stays parked** — cross-agent code still zero (S25, 20 sessions stale). The S26 founder
  gate (2nd agent returns only when Vajra-on-Claude is declared satisfying) **cannot be judged until the
  dogfood is measured** — so S46 (A) is the forced unblocker for the 2nd-agent decision.
- **MVP framing (S45):** honest value story ✅ launch-ready; enforcement-holds-live 🔴 the blocking gap
  (S46 closes it); frictionless install 🟡 (crates.io path broken); cross-agent claim 🔴 (narrow the pitch
  to "your Claude Code follows your rules" or build the 2nd agent first).

## What Currently Works
- **Enforcement moat, complete + scaffolded (S37→S44), test/replay-verified.** publish-guard
  (`git push`/`gh pr create`/`merge` block at L2/L3 unless `VAJRA_ALLOW_PUBLISH=1`) + session-guard (arms
  on `git checkout -b session-(N+1)` and `vajra next --advance`) + jq-preflight fail-closed on all 5 hooks
  + git-level L2 belt (`.githooks/pre-commit`+`pre-push`, `core.hooksPath=.githooks`) + `.claude/settings.json`
  merge on `vajra init`. All scaffolded byte-identical via `include_str!`; greenfield + brownfield.
- **`.claude/settings.json` merge on `vajra init` (S44).** A pre-existing settings routes to
  `merge_claude_settings_file` → the pure `merge_claude_settings`: appends Vajra's `SessionStart` +
  `PreToolUse` groups additively, preserving every user key/hook; idempotent (structural-equality OR
  `.ai/hooks/*.sh` path vs a pre-merge snapshot); malformed → left untouched + loud warn, init exits 0.
  verify-session-44.sh 24/24. **Accepted cosmetic:** `serde_json` sorts object keys → top-level key order
  may shift; zero content dropped, array/execution order preserved.
- **Compression folds the git family regardless of `exitCode` (S41).** Fail-gate applies only when
  `!heuristic.preserves_failure_signal()`; the git family declares it `true`. **Live-unconfirmed** (S46 checks).
- **Darshan (S32) founder-confirmed live good** (S36); brownfield onboarding + auth (S34) hold live.
- `vajra claude` · `vajra next` · `vajra check` · `vajra init` · `vajra estimate` · `vajra meter`.
  **`cargo test` = 135 green** (117 lib + 12 adapter + 6 integration; re-verified S45); clippy + fmt clean.

## What Is Broken
- **🔴 The moat is live-UNVERIFIED (S45 load-bearing finding).** Every S37–S44 guard is test/replay-green,
  none proven against a live autonomous agent since S36 (when it leaked). Same cliff compression sat on
  before S31/S36 falsified it. **S46 (#17a) is the paid run that closes it.**
- **🟡 cargo/npm/pytest never fold on real CC (S33/S41 carry).** Branch on `exit_code == Some(0)`, which
  real CC never sends → `_fail` passthrough under 300/400 lines. Own future compression session.
- **🟡 Boot-packet cost missing the `<5% footprint` rule (#18).** S36's $58 run was ~$32 cache-read of the
  heavy `.ai/`. Bites only in paid runs (≈0 since S36); S46 captures the cache-read share as evidence.
- **🟡 Install path: `cargo install vajractl` (README) is not the working install** (crates.io name
  taken/unpublished) — real install = `cargo install --path`. Launch-blocking for "frictionless install".
- **🟡 Accepted publish-guard v0 limits + merge key-reorder + budget-cap-didn't-bite** — backlog.

## What Is In Progress
- **S45 DONE + closed** (NO-CODE ground-truth, all 3 lenses). Report `sessions/session-45-ground-truth.md`;
  verdict = moat complete-but-live-unproven, dogfood 🔴 4th time. **Next (S46)** = live re-dogfood (#17a,
  founder pick A, PAID) — `prompts/46-task-live-redogfood.md`, in a **new chat**.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 31: first real `vajra claude` dogfood since S07 (chitra; exact $ not captured).
- Session 36: ~$61.4 — two real runs against `/private/tmp/chitra`. Compression saved $0; ~$32 was cache-read.
- Session 32–35, 37–45: ~$0.00 each — build/code + NO-CODE GT sessions; S41–S44 proven via replay /
  `PATH`-shim / temp-repo E2E; S45 = read-only audit. No paid `vajra claude` run.
- Cumulative: ~$62. **No real `vajra claude` spend since S36 — the dogfood gate stays UNMEASURED
  (flagged S30/S35/S40/S45). S46 is the run that finally measures it.**
