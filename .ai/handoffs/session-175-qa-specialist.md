---
role: qa-specialist
session: 175
agent: claude-code-subagent (verified: toolu_015LVxXAKsnnMJnifRhFR77h)
source-sha: 7e97a98f30c2c8d964a600c7fb5bf2456b6b0a28cafe96ab34b1112a4cf41ecd
captured: 2026-09-23T04:50:59Z
cost_usd: null
---

# Qa-specialist handoff — session 175

## QA Evidence Brief — Session 175, `scripts/verify-session-175.sh` gap investigation

**Where I ran this:** `/Users/suman/playground/vajra`, branch `session-175-keep-testing` (the path and branch the task named). This was not a fresh clean-room checkout — the task explicitly pointed me at this exact working tree with its current uncommitted diff, and Part 2 requires `git show HEAD:...` against this repo's real history, which a disposable single-commit clean room wouldn't have. Fixture repos for Part 1 were built fresh under `mktemp -d` (not reused, not in this checkout), per the task's instruction.

### Part 1 — Live-executing the 3 untested sites

`scripts/verify-session-175.sh` contained **zero references** to `hook-session-start.sh`, `hook-pre-write.sh`, or `hook-stop.sh` at the time I checked. Not even a grep-hollow check existed for these three — they were entirely unchecked by the session's own suite, exactly as the tech-lead found.

I built isolated fixture repos (`mktemp -d`, `.ai/CONSTRAINTS.yaml` with/without `ground_truth_next_session: 180`, `maturity: L2`, branch `session-<N>-x`) for N = 170, 175, 180 and ran each real script with `CLAUDE_PROJECT_DIR` pointed at the fixture:

**`hook-session-start.sh`** (no stdin; greps its own output for the GT boot line):
```
N=170 key=with    rc=0  gt_line=[]                                            → correct (overridden to CODE)
N=170 key=without rc=0  gt_line=[[REMINDER] Session 170 is GROUND TRUTH...]   → correct (old N%5 rule, unchanged)
N=175 key=with    rc=0  gt_line=[]                                            → correct (the fix — no false GT)
N=175 key=without rc=0  gt_line=[[REMINDER] Session 175 is GROUND TRUTH...]  → correct (old-rule baseline preserved)
N=180 key=with    rc=0  gt_line=[[REMINDER] Session 180 is GROUND TRUTH...]  → correct (real GT still fires)
N=180 key=without rc=0  gt_line=[[REMINDER] Session 180 is GROUND TRUTH...]  → correct
```

**`hook-pre-write.sh`** (stdin `{"tool_input":{"file_path":"src/main.rs"}}`, `maturity: L2` so it actually enforces):
```
N=170 key=with    rc=0  (allowed)                                    → correct
N=170 key=without rc=2  [HOOK BLOCK] Ground Truth Session 170 ...     → correct (old rule)
N=175 key=with    rc=0  (allowed)                                    → correct (the fix)
N=175 key=without rc=2  [HOOK BLOCK] Ground Truth Session 175 ...     → correct (baseline)
N=180 key=with    rc=2  [HOOK BLOCK] Ground Truth Session 180 ...     → correct
N=180 key=without rc=2  [HOOK BLOCK] Ground Truth Session 180 ...     → correct
```

**`hook-stop.sh`** (no stdin; checks for a missing GT output file vs. falling into the normal verify-run branch):
```
N=170 key=with    rc=0  "[hook stop] No verify script at .../verify-session-170.sh..."          → correct (CODE path, not GT)
N=170 key=without rc=0  "[HOOK STOP] Ground Truth Session 170 missing .../session-170-ground-truth.md" → correct (old rule)
N=175 key=with    rc=0  "[hook stop] No verify script at .../verify-session-175.sh..."          → correct (the fix — not GT)
N=175 key=without rc=0  "[HOOK STOP] Ground Truth Session 175 missing .../session-175-ground-truth.md" → correct (baseline)
N=180 key=with    rc=0  "[HOOK STOP] Ground Truth Session 180 missing .../session-180-ground-truth.md" → correct
N=180 key=without rc=0  "[HOOK STOP] Ground Truth Session 180 missing .../session-180-ground-truth.md" → correct
```

(First attempt at this used `timeout 30 bash ...` and every `hook-session-start.sh` run came back `rc=127` — that was my own harness, not the hook: macOS here has no `timeout`/`gtimeout` on PATH. Re-ran without it and got clean `rc=0` runs above; flagging this so it isn't misread as a product bug.)

**Verdict on Part 1: no discrepancy found.** All 18 live executions (3 sites × 3 session numbers × with/without key) behave exactly as the fix is supposed to. But the finding stood on its own: that confirmation existed only because I built it myself just now — `scripts/verify-session-175.sh` did not check these three sites at all, live or by grep, at the time I ran this.

### Part 2 — Replaying rudra S06's exact merge command, old vs new

`git log --oneline -10 -- scripts/hook-publish-guard.sh` showed the S175 fix was **not yet committed** at the time I checked — `HEAD` (pre-S175) was the old/buggy version; the fix existed only as an uncommitted working-tree edit. So "old" = `git show HEAD:scripts/hook-publish-guard.sh`, "new" = the file on disk at the time.

Fixture: fresh `mktemp -d` repo, `.ai/CONSTRAINTS.yaml` with `maturity: L2`, branch `session-06-x`. Ran rudra's exact command through both, under `VAJRA_ENFORCE_PUBLISH=1 VAJRA_ALLOW_PUBLISH=1`:

```
$ jq -n --arg c 'gh pr merge 7 --merge --delete-branch' '{tool_input:{command:$c}}' \
  | env VAJRA_ENFORCE_PUBLISH=1 VAJRA_ALLOW_PUBLISH=1 CLAUDE_PROJECT_DIR="$T" bash "$OLD"
[vajra publish-guard] ALLOWED (gh pr merge (merging a pull request)) — VAJRA_ALLOW_PUBLISH=1.
OLD exit code: 0

$ jq -n --arg c 'gh pr merge 7 --merge --delete-branch' '{tool_input:{command:$c}}' \
  | env VAJRA_ENFORCE_PUBLISH=1 VAJRA_ALLOW_PUBLISH=1 CLAUDE_PROJECT_DIR="$T" bash "$NEW"
[vajra publish-guard] BLOCKED: gh pr merge (merging a pull request)
  Merging stays with the human — always. No env var enables it, not even
  VAJRA_ALLOW_PUBLISH=1 (S175: it used to; that was the gap).
  Hand this back: the founder runs the merge themselves, in their own terminal.
NEW exit code: 2
```

**Verdict on Part 2: confirmed independently.** OLD = allowed (exit 0, reproduces rudra S06's exact bug). NEW = blocked (exit 2, "Merging stays with the human"). This matches what `verify-session-175.sh`'s own AC2a/AC3 claim — I did not just trust their self-report; I built a separate fixture and reran the identical command myself.

### Git-history proof of the "one site already dropped once" pattern

```
3eb3af6 S175: boot reminder + closeout gate read the GT cadence from config
        scripts/hook-session-start.sh | 12 +++++++++++-
        scripts/verify-closeout.sh    | 22 +++++++++++++++++++---
76f6df9 S175: 3 more hardcoded N % 5 sites — one would have blocked this session
        scripts/hook-pre-bash.sh      |  6 +++++-
        scripts/hook-pre-write.sh     |  6 +++++-
        scripts/hook-prompt-submit.sh | 10 +++++++++-
e8b23d9 S175: hook-stop.sh cadence fix + DECISION-007 S175 addendum
        scripts/hook-stop.sh          | 12 +++++++++-
```

`76f6df9`'s own message ("3 more hardcoded N % 5 sites") treats the sweep as complete at 5 sites; `hook-stop.sh` only got fixed in a third, later, separate commit. This is exactly the failure the tech-lead flagged, visible directly in the log — no source reading needed to see it, just `git log --oneline -- scripts/hook-*.sh`.

### Bottom line

- 6 of 6 sites behaved correctly under live execution (I ran all six myself: 3 already covered by the script, 3 I covered myself). No discrepancy found.
- The gap the tech-lead named was real and open at the time: `scripts/verify-session-175.sh` did not execute (or even grep) `hook-session-start.sh`, `hook-pre-write.sh`, or `hook-stop.sh`. My all-green result existed outside the session's own suite, in a scratchpad script.
- The publish-guard fix (Part 2) was real and independently reproduced, but was **uncommitted** working-tree state at the time — lost-or-diverge risk until it lands in a commit.

rec 1 — Add live-execute checks for `hook-session-start.sh`, `hook-pre-write.sh`, and `hook-stop.sh` to `scripts/verify-session-175.sh`, mirroring the AC1c–AC1f fixture pattern already used for `hook-prompt-submit.sh`/`hook-pre-bash.sh`, before closing — otherwise the only evidence these three sites work is this disposable QA brief.

rec 2 — Replace or supplement AC1a/AC1b's reimplemented `is_gt_new()`/`is_gt_old()` sweep with one that calls the real hook scripts (or extracts their shared predicate the way AC1g already does for `verify-closeout.sh`), so a future typo in one of the six real sites can't diverge from the test-writer's own model undetected.

rec 3 — Commit `scripts/hook-publish-guard.sh`'s current working-tree diff (the S175 merge-stays-human fix) before this session closes — right now it is unstaged, and the AC2/AC3 "new" behavior only exists on disk, not in history.

rec 4 — Given git log already shows one site (`hook-stop.sh`) dropped once from the "same fix copied into six files" pattern, add a cheap structural backstop: a check that asserts all six known site paths contain the `ground_truth_next_session` marker string, run alongside (never instead of) the live-execute checks in rec 1 — a grep floor that would have caught the missing-site drop immediately, without pretending to prove behavior on its own.

Files:
- /Users/suman/playground/vajra/scripts/verify-session-175.sh
- /Users/suman/playground/vajra/scripts/hook-session-start.sh
- /Users/suman/playground/vajra/scripts/hook-pre-write.sh
- /Users/suman/playground/vajra/scripts/hook-stop.sh
- /Users/suman/playground/vajra/scripts/hook-pre-bash.sh
- /Users/suman/playground/vajra/scripts/hook-prompt-submit.sh
- /Users/suman/playground/vajra/scripts/hook-publish-guard.sh
- /Users/suman/playground/vajra/docs/decisions/DECISION-007-agent-fleet.md
- /Users/suman/playground/vajra/.ai/handoffs/session-175-tech-lead.md

## Handoff Delta
- `+` new: first qa-specialist handoff for this session (9391 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
