# Session 175 — rudra session 06, and the config that would have blocked itself

**Type:** CODE, interactive (the founder's own run; findings collected after it closed and fixed
here — his rule since S173).
**Branch:** `session-175-keep-testing`. **Brief:** `prompts/175-task-keep-testing.md`.
**Verify:** `scripts/verify-session-175.sh` — 18 pass, 0 fail. **Demo:** `scripts/demo-session-175.sh`
— 8 live checks, all green.

## What happened

Before the founder's run, Deliverable 0 had to land: `N % 5 == 0` ("ground truth") was hardcoded in
what the brief said were 2 scripts. It was actually **6** — the other 4 include `hook-pre-bash.sh`,
a live enforcement hook that would have exited 2 on THIS session's own first `git commit`, since
175 % 5 == 0. Not a paperwork gap; a self-block this session would have hit for real. All 6 now read
`.ai/CONSTRAINTS.yaml#ground_truth_next_session` (set to 180), falling back to the untouched old rule
when the key is absent.

He then ran rudra session 06 (`gh pr merge 7 --merge --delete-branch` twice — both merged, ACCEPT
7/7) under `VAJRA_ALLOW_PUBLISH=1 VAJRA_ALLOW_COMMIT=06 vajra claude`. What he pasted back into this
chat was only the cost-receipt tail; the substance came from mining the real Claude Code transcript
(`~/.claude/projects/-Users-suman-playground-rudra/*.jsonl`) directly. **What worked:** boot correctly
said "session 05 is merged — session 06 starts here" (F59/F62); `vajra next --steps` was re-run 3
times (not 0); the 4 waiting Vajra files were named and committed first, never reverted (F60); 15
commits, zero blocked. **What wasn't exercised:** F58 and F61/F63 — no block fired to retry from; the
`cwd`/worktree push assumption is still untested live.

**The real find:** `VAJRA_ALLOW_PUBLISH=1` — new this run, not in the brief's launch instructions —
allowed all five guarded publish actions with no distinction, so the agent merged both of its own PRs
itself, unsupervised. This contradicts F55 (S173): "merging stays with the human." Asked plainly, the
founder answered plainly: "no, merge should stay human — fix it." Fixed the same session.

## Everything found

| # | What happened | Severity | Now |
|---|---|---|---|
| Deliverable 0 | `N % 5 == 0` hardcoded in 6 places, not 2 — one would have blocked this session | 🔴 HIGH | fixed `59e1079`/`3eb3af6`/`76f6df9`/`e8b23d9` |
| F59/F62 | Boot handover + list re-read, live | — | confirmed fixed |
| F60 | Waiting Vajra files named + committed first | — | confirmed fixed |
| F58 | No PR block fired this run | — | not exercised |
| F61/F63 | No commit block fired this run | — | not exercised |
| cwd/worktree | No worktree used this run | ⚪ | still untested live |
| **F65 (new)** | `VAJRA_ALLOW_PUBLISH=1` let the agent merge its own PRs, unsupervised — contradicts F55 | 🔴 HIGH | fixed `4cf1d8d`, founder-confirmed |
| **F66 (new)** | `--check-crew` checks a handoff's disk-presence, never git-tracked-ness — rudra S06 closed with 2/8 required handoffs uncommitted, needing a same-morning fixup PR | 🟡 MED | **not fixed** — disclosed, watch-only (Guardrails: no new gate on Vajra's own paperwork without the founder's yes; tech-lead rec 5 concurs) |

## Fidelity — every deliverable

| # | Deliverable | Status | Evidence |
|---|---|---|---|
| 1 | GT cadence reads from config; S180 next; non-GT session gets full CODE checks | SHIPPED | verify AC1c-k: all 6 sites live-executed, not grepped, except AC1k's disclosed structural floor |
| 2 | `VAJRA_ALLOW_PUBLISH=1` excludes merge; push/PR-create unaffected; `VAJRA_ALLOW_COMMIT` path untouched | SHIPPED | verify AC2a-e, AC3 (old-vs-new, 0 unexpected); independently re-run by qa-specialist against a fresh fixture with rudra's exact command |
| 3 | F66 disclosed, not fixed | SHIPPED | Findings table above; independently confirmed in `src/fleet/mod.rs`/`src/crew/mod.rs` — still `path.exists()` only |
| — | Every plan step | SHIPPED | 5/5, `## Execution` in the prompt |
| — | No check looser | SHIPPED | AC3's 10-command old-vs-new diff: 6 unchanged, 4 tightened (the intended merge exclusion), 0 unexpected |

**11 of 11 numbered requirements SHIPPED** (independent cold review, `sessions/session-175-review.md`).

## What this does NOT claim

- **`scripts/verify-closeout-scaffold.sh` (the `vajra init` template) was not touched.** A new project
  has no `ground_truth_next_session` support; deliberate, disclosed (a new project has no reason to
  move its GT on day one, and this file already lags on other counts).
- **The cadence override is one integer, not a schedule.** Moving it again means editing the key
  again — matches the founder's stated one-time move, not a new recurring rule.
- **F66 is real and open.** A required session's crew can still close with real handoffs left
  uncommitted; this session named it and stopped, per its own guardrails.
- **The `cwd`/worktree push assumption is still never tested live**, five sessions running now.

## The fakest green here

Named by the independent cold review, not by the builder: `AC1a`/`AC1b` originally compared two bash
functions **reimplemented inside the verify script itself** against each other — an assertion that
would have passed even if the whole fix were deleted. Retired mid-session and rebuilt to live-execute
the real `hook-session-start.sh` instead (`50027f1`). Fixing it surfaced a second, unrelated real bug:
`AC3` was diffing `HEAD`'s publish guard against itself once this session's own fix had landed there,
silently reporting "0 expected tightenings" — pinned to `4bd8b00` (main before this session) instead.
Both are fixed in the artifact, not just disclosed in prose.

## Review

Cold review (fidelity-reviewer, fed only the prompt and diff): **ACCEPT, 11/11 SHIPPED**.
`sessions/session-175-review.md`. 13/13 `obeyed:` dispositions in the `## Advice` section
independently judged by release-coordinator (not the builder, not an advisor), 0 mismatch —
`vajra next --check-obeyed 175`: READY.

## Cost

Interactive session; no metered paid run in this repo (the founder's own rudra run supplied the
findings). 4 fleet dispatches: tech-lead, qa-specialist, fidelity-reviewer (the two it required, plus
itself), release-coordinator (as an independent judge, not for release readiness).

## 3 ranked next candidates

1. **(Recommended) Session 176 — rudra session 07, same pattern.** The founder's standing instruction:
   S175-S179 stay rudra test sessions, S180 is the next ground truth. He runs it, findings collected
   live and fixed after, same as S173-S175. Risk: findings keep arriving one at a time instead of in
   a batch — accepted cost of "run it for real first."
2. **Session 176 — fix F66 for real.** `--check-crew`/`read_handoff` would gain a `git ls-files
   --error-unmatch` check alongside the disk-presence check, closing the exact gap that cost rudra a
   same-morning fixup PR. Needs the founder's explicit yes first (Guardrails: no new gate on Vajra's
   own paperwork without it) — this session deliberately did not take that yes as read.
3. **Session 176 — the `cwd`/worktree push test, deliberately manufactured.** Five sessions running,
   never exercised live because no rudra run has happened to use a worktree. Build a throwaway
   worktree, try a push from inside it, confirm it goes to the human — closes the oldest open item in
   the Findings table on purpose rather than waiting for a run to stumble into it. Risk: a manufactured
   test proves the mechanism, not that a real agent would ever end up in a worktree unprompted.
