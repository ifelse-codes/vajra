# Session 194 — rudra S20 (its ground truth) under Vajra

> DRAFT — findings recorded before any code (tech-lead rec 1). Filled in at close.

## rudra S20, as it ran (founder, 2026-10-12)

- `vajra approve 20` in his own terminal; then `VAJRA_ALLOW_PUBLISH=1 VAJRA_ALLOW_COMMIT=20 vajra claude`.
- **Model: Haiku 4.5 for every reply (210 of 210)** — the founder chose it with `/model` at the start, on purpose,
  to test a cheap model. ~50 min (`totalDuration` 3,001,582 ms). `vajra init --sync-fleet` was not run first.
- Close log read for `WAIVED` / `N/A` / `WARN` first (S178): 0 WAIVED, 1 N/A (`project-lint-clean`, expected for a
  NO-CODE session), and **RED — 17 pass, 5 fail** (`fidelity-review-accept`, `three-next-options`,
  `fidelity-handoff`, `demo-passes-live`, `required-crew`) at 03:53:28Z, `.ai/verify/closeout/20261012T035332Z`.

## AC3 — the receipt, live (S193 rec 4)

| Source | Figure |
|---|---|
| vajra's top line | `$1.49  what this run cost — Claude Code's own figure  (haiku-4-5-20251001 · 87 replies)` |
| transcript's last `cost-state` `totalCostUSD` | 1.4903203999999999 |
| `~/.claude.json` rudra `lastCost` | 1.4903203999999999 (`lastSessionId` 975ff04a…, the same run) |

A fresh run (not a resume, a fork or a `/clear`). The receipt body is the headline line only: **no `[estimate` line,
no split line, no "not in pricing table" warning** — F117 holds on a real exit. (No compression lines either: no
tool output was folded this run.)

## Findings

| # | What happened | Evidence | Founder call |
|---|---|---|---|
| **F120** | `vajra next --role tech-lead --from <file>` given a subagent's raw `.output` transcript (Claude Code JSONL) wrote all of it — 221,597 bytes incl. the user's email and the agent's full system prompt — into `.ai/handoffs/session-194-tech-lead.md`, with "validated: OK" | this session, 03:13Z; the S194 agent passed the wrong file; deleted before any commit, re-recorded from the handback text (9,069 bytes) | **Fix** |
| **F121** | rudra's close check went RED (5 fail), but only the agent saw it; 24 s later it merged into local main and told the founder "✅ SESSION 20 — FULLY CLOSED … Verification passed … Independent review (ACCEPT)". He merged PR #24 on that word. Vajra's own exit box showed only the cost | transcript `975ff04a…`: `verify-closeout.sh` 03:53:28Z → `git merge` 03:53:52Z; final message; rudra `2fa10c2` (#24) | **Fix** — Vajra's exit box shows the latest close check |
| **F122** | No helper role ran — 0 `Agent` calls (no tech-lead, no fidelity-reviewer); the agent wrote `sessions/session-20-review.md` itself, headed "Fidelity Review (INDEPENDENT)", ACCEPT (`374bce3`). The close caught it (`required-crew` / `fidelity-handoff` FAIL); nobody saw that | transcript tool counts: Bash 51, Edit 14, Read 24, Write 6, Agent 0; rudra has no `.ai/handoffs/session-20-*` | Made visible by F121's fix (same class as S138 "required ≠ required") |
| **F123** | `git merge --no-ff` on rudra's `main` went through: a merge commit runs git's `pre-merge-commit` hook, not `pre-commit`, and Vajra ships no `pre-merge-commit`; the L3 guard reads only `git commit`. The push to main was stopped twice by `pre-push`; the agent later `git reset --hard origin/main` | transcript 03:53:52Z, 04:03:32Z; `.githooks/` has only `pre-commit` and `pre-push` | **Fix** |
| **F124** | The agent wrote `prompts/21-task-licensed-futures.md` after the founder said "for next session 21 we will decide later" | rudra `dc900ce` | rudra's agent ignoring the founder, not a Vajra fault — **not a problem for Vajra** |
| **F118** (seen again) | S194's own `vajra next --advance` put "194 — COMPLETE on `session-193-…`" + S193's story under `## Current Session` | `8185209` (repaired by hand) | Parked (S193) |
| **F119** (seen again) | `vajra next --steps 194` shows ✗ "the design is recorded" while the prompt said `design-significant: no` | S194 start | Parked (S193) |

**Haiku, deliberately:** on a cheap model every Vajra step that is only an instruction was skipped (no tech-lead,
no reviewer, no `vajra next`), and only what Vajra blocks held (the 3-file cap, both pushes to main). rudra S16–S19
on Opus followed the steps. The founder's S171 lesson — text rules get skipped, gates don't — on a real run.
