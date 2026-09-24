# Session 177 — rudra session 09, and a close check that skipped a coding session's checks

**Type:** CODE, interactive. The founder ran rudra session 09 under Vajra; this session fixed what it
found. **Branch:** `session-177-keep-testing`. **Brief:** `prompts/177-task-keep-testing.md`.
**Verify:** `scripts/verify-session-177.sh` — 12 pass, 0 fail, 0 skipped. **Demo:**
`scripts/demo-session-177.sh` — 6 live checks, complete.

## What happened

- **rudra S09 (3h20m in chat):** close check 21/21 on the branch before the PR; the agent pushed and
  opened PR #11 itself; the founder merged. ~1h50m of the run was the agent waiting on his answers;
  the 13 code steps took 25 minutes; Vajra's advisors + reviews + the 6-minute close check ≈ 50.
- **F74 (found by the agent, live):** at the S09 close the founder moved rudra's next review-only
  session from S10 to S15 (`ground_truth_next_session: 15`). rudra's start hook obeyed; its close check
  — the scaffold `vajra init` hands every project — still said `N % 5 == 0`, so rudra S10 (CODE) would
  have passed "verify + demo scripts exist" and "tech-lead recorded" as N/A. It already had at rudra
  S05. The agent could not fix a Vajra-owned file and wrote the gap into S10's prompt.
- **F76 (found while fixing F74):** the same check only recognised `**CODE**`. Every rudra brief writes
  `- **CODE.** …`, so all of rudra's coding sessions (S02–S09) read as non-CODE and its tech-lead check
  never ran (S09's log: `N/A: session 9 is not a CODE session`).
- **The fix:** the scaffold carries S175's `is_ground_truth_session` helper at both sites and accepts
  `**CODE.**`/`**CODE:**`/`**CODE,**`. Rebuilt, installed, synced into rudra before its S10.

## Everything found

| # | What | Outcome |
|---|---|---|
| F74 | scaffold close check ignores a moved ground truth | **FIXED** (2053bb7), synced into rudra |
| F76 | scaffold close check reads `**CODE.**` briefs as non-CODE | **FIXED** (2053bb7), synced into rudra |
| F71 | remote branch left after a GitHub-button merge (2nd time) | PARKED by founder |
| F67 | exit receipt ~$118.69 for an Opus 5.5 run (~5× over, 3rd time) | PARKED by founder — permanent fix wanted |
| F75 | design-advisor proposed a 4-file commit no agent can make; the ≤3 rule forced a one-commit stale proof | LOW, recorded |
| F31, F66, F58 | tech-lead first (9th) · 7/7 handoffs tracked · agent opened its own PR | confirmed |
| F70, F73 | nothing to catch (brief intact; Acceptance uses `1.`) | not exercised |

## Fidelity — every deliverable

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| G1 | a CODE session gets its full close checks (moved GT, `**CODE.**`) | SHIPPED | `scripts/verify-closeout-scaffold.sh`; verify AC1, AC3, AC4 |
| D1 | scaffold reads the key at both sites; accepts `**CODE.**` | SHIPPED | 2053bb7 |
| D2 | tests run the real scaffold functions | SHIPPED | `tests/scaffold_gt_cadence.rs`, 4 tests |
| D3 | rudra has the fixed gate before its S10 | SHIPPED | `vajra init --sync-fleet` upgraded rudra's `scripts/verify-closeout.sh` (render 275e18f0 → e85af5ff); verify AC4 |
| AC1 | key 15: S10 CODE + blocks; S15 N/A | SHIPPED | verify AC1 (old `code=no PASS` → new `code=yes FAIL`) |
| AC2 | no key: old = new | SHIPPED | verify AC2, 16 session numbers |
| AC3 | spellings; nothing CODE → non-CODE | SHIPPED | verify AC3: 134 same · 17 non-CODE → CODE · 0 CODE → non-CODE |
| AC4 | rudra's own gate calls S10 CODE | SHIPPED | verify AC4: functions in rudra's tree, body `cmp`-identical to the scaffold, rudra's real `--check-claimed 10` → `CODE session 10` |

## What this does NOT claim

- Vajra's OWN `scripts/verify-closeout.sh` still matches only `**CODE**` (10 old Vajra prompts, e.g.
  S171, write `**CODE.**`). Current prompts write `**CODE**`; changing it is a check on Vajra's own
  paperwork — not done without the founder's yes.
- rudra's upgraded gate is uncommitted in rudra's tree; its S10 agent commits it first (the sync
  message tells it to). A stranger gets the fix only after `cargo install` from source + `--sync-fleet`
  (crates.io still serves 0.1.0).
- **It checks LESS in one place (cold review rec 1):** a key naming a session that is not a multiple of
  5 (say 17) makes that session review-only, so it loses the scripts + tech-lead checks the old gate
  ran. That is what the key means when the founder sets it; but `.ai/CONSTRAINTS.yaml` is
  agent-writable and nothing guards the key — the same exposure Vajra's own gate has had since S175.
  Parked, not guarded (founder directive 2026-09-15). Verify shows the key-17 row.
- rudra S10's close will now check more. If S10 skips its scripts or the tech-lead, the close BLOCKS
  where it used to pass — that is the point, but it is new friction.

## The fakest green here

`is_code_session` still decides by a spelling in the brief. A CODE brief written `CODE session` or
`**Code**` still reads as non-CODE and skips the tech-lead check — the classifier widened by the
spellings seen, not closed. Runner-up: AC4 proves rudra's gate *classifies* S10 as CODE; nothing has
yet run a real rudra close under it.

## Deferred

- fidelity-reviewer rec 3 (LOW) — the key is read as the first digits on its line, so
  `ground_truth_next_session: TBD  # after S10` reads as 10. Same in Vajra's own gate. Parked.

## Ship steps (release-coordinator recs 2–4)

- rec 2 — the full `scripts/verify-closeout.sh` runs on this branch, exit 0, BEFORE the PR (S83).
- rec 3 — after the founder merges: `git checkout main && git pull --ff-only && git fetch --prune`,
  `git branch -d session-177-keep-testing`, `git push origin --delete session-177-keep-testing` (F71
  for this session).
- rec 4 — older `origin/session-*` branches are deleted only after `git branch -r --merged
  origin/main` confirms each one, never in bulk.

## Review

Cold review (fidelity-reviewer, fed only the prompt and the diff): **ACCEPT, 8 of 8 numbered items
SHIPPED · the only-add guardrail PARTIAL** (the key=N loosening, since disclosed). Its recs 1–2 were
applied after the pass (8bacfee) and judged `implemented` by the release-coordinator; the reviewer
confirmed 8bacfee does not change its ACCEPT. `sessions/session-177-review.md`.

## Cost

Interactive; no metered paid run in this repo. The founder's rudra S09 run read `~$118.69 estimated`
(F67-overstated ~5×). Fleet dispatches: tech-lead, fidelity-reviewer, release-coordinator (judge + ship steps).

## 3 ranked next candidates

1. **(Recommended) Session 178 — rudra session 10 under Vajra, same pattern.** The first rudra run
   whose close check really checks a coding session (tech-lead recorded, verify + demo scripts). S175–
   S179 stay rudra test sessions; S180 is the next ground truth. Risk: the fuller check blocks
   something it used to wave through — which is a finding, not a failure.
2. **Session 178 — F67 for good: the receipt reads Claude Code's own cost.** Three runs in a row have
   shown ~5× the real money on exit. Find the tool's own figure for interactive runs (e.g. the
   status-line `cost.total_cost_usd`). Risk: the tool may not expose it after exit.
3. **Session 178 — finish the 0.2.0 release.** crates.io still serves 0.1.0, so a stranger's
   `cargo install` gets none of S167–S177, today's fix included. Risk: the publish and the brew smoke
   are founder-only steps.
