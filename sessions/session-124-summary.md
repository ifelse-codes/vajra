# Session 124 Summary — Dogfood (paid): does S121–S123's machinery hold under real use?

**Branch:** `session-124-dogfood-paid-run` · **Type:** DOGFOOD (paid, evidence-only,
`VAJRA_CLOSEOUT_WAIVER=dogfood-no-src-changes`) · **Prompt:** `prompts/124-task-dogfood-paid-run.md`

## Criterion map

| # | Criterion | Verdict | Evidence |
|---|---|---|---|
| 1 | chitra's scaffold carries the fleet + `clean_room` CONSTRAINTS key, non-destructive | SHIPPED | `chitra-init-output.txt`: `vajra init` created exactly 4 files (`.claude/agents/*.md`), skipped 28. `clean_room` key can't be merged into an existing file by `vajra init` (skip-if-present is file-granularity, not key-granularity) — added by hand; `chitra-constraints-diff.txt` shows the single 6-line addition, nothing else touched. Disclosed as a real `vajra init` gap, not fixed in code this session. |
| 2 | `vajra next --dogfood-age` recorded pre/post-run; post-run shows S124 as most recent | PARTIAL | `pre-run-baseline.txt` recorded pre-run (S118, 5 sessions/4 days stale). `post-run-state.txt` recorded immediately post-run — **still shows S118**, because `--dogfood-age` is git-derived and this session's own evidence bundle was not yet committed at that point. Re-verified after this session's closeout commit lands (see Closeout note below). |
| 3 | Pre-run baseline: chitra HEAD/status, vajra binary sha256, `claude --version` | SHIPPED | `pre-run-baseline.txt`. **One real correction recorded in the same file**: the first sha256 taken was the PATH `vajra` binary, which was STALE (S118-era, predates S119–S123 entirely — the fence/clean-room machinery this run exists to test would not even have been present). Caught before launch, fixed via `cargo install --path . --force`, corrected sha recorded. |
| 4 | Guards ON; budget cap real (to the cent, ~$5); chitra `main` carries zero unauthorized commits | PARTIAL | Guards genuinely ON (`VAJRA_ENFORCE_PUBLISH=1 VAJRA_ENFORCE_COMMIT=1`, `run-identity.txt`). chitra `main` confirmed byte-identical before/after (`main-before.txt` = `main-after.txt` = `2057f48…`) — zero unauthorized commits, real. **But the "hard stop" claim was not true this run**: actual spend ($3.2985) stayed under the $5 cap, but not because any mechanism enforced it — see `timeout-watchdog-finding.txt`. The cross-stage budget gate (checked *before* launching a stage) is real and works; the *within*-stage wall-clock watchdog (the only thing the harness's own comment says bounds a single stage) did not fire — the run's outer wall-clock time was 12,474s against a 1,800s cap, with no `killed_by=timeout` recorded. This is the session's fakest green (see below). |
| 5 | Bar-chart payload attempt is real work against chitra's own actual next roadmap item | SHIPPED | chitra's own `SESSION-BOOT.md` (read *before* writing the task prompt) named "carry the reference-locked line language into bar/sparkline/histogram" as its own session-12 candidate — the task prompt is that item, bounded to `bar()` only. Not a synthetic task chosen to flatter the fence machinery. |
| 6 | Reported honestly whether the fleet/clean-room engaged, either way | SHIPPED | `fleet-engagement.txt`: 0 `Task` tool invocations, 0 `--clean-room-open`/`--clean-room-close` mentions, no governed-handoff files — **the S121–S123 fleet + clean-room machinery never engaged**, reported plainly as a valid finding, not softened. **A different, real governance event was also captured and reported**: the Varta `⚡on(prompts/*)` copilot-loader hook fired mid-run and was obeyed — under `--dangerously-skip-permissions` — traced end-to-end through `run.jsonl` (tool_use_id `toolu_01JdTB3oKU3zzcGKfmWFPv98`: Write denied → agent read `.ai/TASK.md` + `.ai/ROADMAP.md` → retried → succeeded). |
| 7 | Bar-chart payload outcome graded SHIPPED/PARTIAL/NOT-BUILT, backed by real evidence, never the agent's self-report | SHIPPED | Independently: ran `pnpm --filter @chitra/core run test` myself (159/159 pass), `typecheck` myself (clean), `bash scripts/verify-session-12.sh` myself (27/27 green), and rendered `bar()` myself (`bar-chart-render-verified.txt` — real terminal output; no browser needed, this chart family has no web/SVG path per the task's own scope). Dispatched an independent cold `fidelity-reviewer` against chitra's actual diff: **REJECT**, 6/8 SHIPPED, 2 PARTIAL (see below) — caught the launched agent's self-report citing a review file (`sessions/session-12-review.md`) that did not exist on disk at the time it claimed SHIPPED for that criterion. Never took the agent's own `session-12-summary.md` at face value. |
| 8 | `sessions/session-124-artifacts/` holds run-result.json, receipt, run.jsonl, cost, chitra before/after git state, fleet-dispatch evidence | SHIPPED | All present: `p1/run-result.json`, `p1/receipt.stderr.txt`, `p1/run.jsonl`, `p1/total_cost_usd.txt`, `p1/{head,status,main}-{before,after}.txt`, `post-run-state.txt`, `p1/fleet-engagement.txt`, `review-input-chitra.diff`. |
| 9 | `session-124-ground-truth.md` + this summary exist; independent cold `fidelity-reviewer` lands at `session-124-review.md` | SHIPPED | This file + `sessions/session-124-ground-truth.md`. Independent cold review of *this* session's own delivery dispatched separately from the chitra-side review; lands at `sessions/session-124-review.md`. |

**Count: 6 of 9 SHIPPED, 2 PARTIAL, 0 NOT-BUILT** (criterion 2 resolves to SHIPPED once this
session's own closeout commit lands — re-verify before final closeout).

## What was not built

- **The clean-room dispatch-evidence gap** (originally-planned S124, superseded) — untouched, per
  design.
- **The check-class label EARNED** (S124 option A from the S123 close) — untouched, per design.
- **A fix for chitra's dead sparkline or its missing review** — disclosed via the independent
  review now at `chitra/sessions/session-12-review.md`, not fixed. Chitra `session-12-bar-chart-lock`
  is left **uncommitted**, exactly where the run's own API-connection-error interruption left it,
  plus the real cold review this session produced. Landing it (fixing the dead sparkline, re-running
  to ACCEPT, committing) is chitra's own next session, not this one's job.
- **A push or PR on chitra** — never attempted, per the prompt's non-goals.

## The fakest green

**"Budget is a hard stop, not a hope."** The harness's own comment (inherited from S118, carried
into this session's `run-task.sh`) says the cross-stage gate is checked *before* a stage launches,
and *within* a stage, spend is bounded "only by TIMEOUT_SECS (wall clock)." This run measured that
claim directly: `TIMEOUT_SECS` defaulted to 1800s, but the outer process didn't return until
12,474s had elapsed — 6.9× the stated cap — with no `killed_by=timeout` marker ever written,
meaning the watchdog's kill logic never actually terminated the run. (Claude Code's own internal
`duration_ms` was 1,661,962ms / ~27.7min — the excess wall-clock time was spent stalled somewhere
between that internal completion and the wrapper actually returning, most plausibly the host
machine sleeping/losing network overnight; the run ultimately ended in a real error,
`is_error: true`, `"API Error: Unable to connect to API (ConnectionRefused)"`.) The dollar spend
($3.2985) stayed under the $5 cap — but only because this particular task happened to cost that
much before erroring out, not because any mechanism would have stopped it at $5.01. A single-stage
run that kept working (rather than erroring) past the wall-clock cap could have run past the
dollar cap with nothing to stop it. Full detail: `sessions/session-124-artifacts/timeout-watchdog-finding.txt`.

## Honest headline finding

**The S121–S123 fleet + clean-room machinery never engaged in this run** — not because it was
blocked, but because the launched agent never had a reason to reach for it (it verified its own
work with plain `pnpm test`/`tsc`/its own verify script rather than dispatching `qa-specialist`,
and never touched `--clean-room-open`). This is the honest answer to the session's central
question, and it is a real, valid finding, not a failure: three sessions of machinery, built and
fenced against synthetic fixtures, sat completely idle on its first real-use opportunity. A
*different* Vajra mechanism (the Varta copilot-loader hook) did fire and was obeyed, under
`--dangerously-skip-permissions` — real evidence that at least one governance layer holds when
the host's permission system is off, just not the one the last three sessions built.
