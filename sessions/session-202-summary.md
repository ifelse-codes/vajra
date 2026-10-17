# Session 202 — ad-hoc bug bash

**Branch:** `session-202-bug-bash` · **Type:** AD-HOC (founder, 2026-10-17: "this is a adhoc session for vajra no rule
need to be followded this is a bug bash") · **Start commit:** `edd23e5` · **Prompt:** none · **PR:** #241

## Goal achieved?

Mostly. The founder asked for every open bug to be listed and every fixable one fixed. Round 1 fixed every open
bug that code could fix (8). Round 2 took the 8 remaining candidates and fixed 7. The one left (#8, verify-88's
`>= 16` floor) needs one full historical scan, and the founder stopped it as too slow.

There was no prompt, cold review, demo or GREEN close, by the founder's call. So the push belt stopped the agent's
push ("the last close check did not run on 9a3d501"), and the founder pushed the branch from his own terminal.
The planned pause session moved from 202 to **203** (`prompts/203-task-pause-use-elsewhere.md`).

## What shipped — round 1 (every open bug)

| Fix | What a user sees now | Commit |
|---|---|---|
| **N28** | `vajra next --advance` with an open, silent stdin waits 2 s for a piped answer, then goes on ("not asked") instead of hanging | `a670d1c` |
| Wait error | When the OS cannot say whether a check script exited, the close says `WAIT FAILURE`, not `TIMEOUT`. There is now a test for a script killed by a signal (it counts as exit 1) | `f99df89` |
| `--dogfood-age` | It finds a receipt kept one folder down (`run-*/receipt.stderr.txt`), with the cost beside it | `c717dac` |
| F127 leftovers | Untracked, non-ignored files make the close's `clean: no`, in both close scripts. `git push origin HEAD:<other>` and a bare `session-NN` branch are checked | `b4c5df7` `60a908b` |
| **F123 leftovers** | New `.githooks/reference-transaction`: an agent may move main/master only to a commit `origin/<branch>` has. A ff merge, `reset --hard`, `branch -f` or `update-ref` onto local work is refused. `git pull --ff-only` after a merged PR still works, and a person gets a note. Ships via `vajra init` / `--sync-fleet` | `03e1d23` `b802ce2` |
| `--version` | `vajra 0.2.0 (<commit>)` when built from a git checkout, so a stale install shows | `41061d9` |
| scaffold-drift | It was red on main: verify-201's two source reads now carry `# source-claim:` notes | `4f66ef4` |

## What shipped — round 2 (the 8 candidates)

| # | Fix | Commit |
|---|---|---|
| 1 | A new project gets every setting Vajra runs on (`forbid_skip_hooks`, `forbid_force_push_to`, `artifacts_dir` — `--qa` needed it — all 5 `communication.forbid`, `self_review_questions`, `end_of_session`, `state.*`, `budget`, `enforcement`, `trust`). The test `a_new_project_gets_every_setting_vajra_runs_on_or_a_stated_reason` fails on a new gap, unless `SCAFFOLD_OMITS_SETTING` names it with a reason | `09166b3` |
| 2 | `vajra check` on main passes when no tracked file changed (right after `init`, or between sessions) and fails only on an edit made on main | `4875661` |
| 3 | The brew smoke test installs from the published tap and first checks that the repo copy matches it. The repo's `Formula/vajra.rb` was stale (0.1.0 vs the tap's 0.2.0) and is now synced | `7d43806` |
| 4 | Install smoke: every step is killed, with its children, once the run's budget is spent (a 3 s budget stops in 4 s; a normal run passes 7/7) | `7d43806` |
| 5 | The start hook prints only the newest 3 session sections of SESSION-BOOT/TASK/STATE and names the rest. Vajra's boot went from 95 KB to 53 KB; the files are untouched | `5f86465` |
| 6 | The review-attestation walk stops at the first match. S201's own review went from 8.8 s to 1.1 s, with 0 verdict differences against the old binary on 25 sessions | `8b87969` |
| 7 | Close row `past-verdicts-unchanged`: a past session's verdict or Review-Inputs-SHA changed on the branch FAILS by name. A review added late may be added (S167 recorded S166's) | `a2cf092` |
| 8 | **Not fixed** — verify-88 still passes on `verified >= 16`. Pinning the exact list needs one full scan, and a review that never verifies walks every candidate (~1 min each) | — |

## Evidence

- `cargo test`: 758 passed, 0 failed · `cargo clippy --all-targets -- -D warnings` clean · `cargo fmt --check` clean.
- `scripts/scaffold-drift.sh` 20/20 · verify-188…201 green · `scripts/install-smoke.sh` 7/7.
- The new push-belt tests fail on the old hook. A flipped S200 verdict made the close row FAIL ("S200") and was
  restored. CI on PR #241 passed on ubuntu and macOS.

## Open

- #8 above. N23 (the founder's rudra `--sync-fleet`). N26 (as designed). No local hook can stop: a hand-written
  GREEN result, `git push --no-verify`, an agent that unsets its markers.

## Next

S203 — the pause: use Vajra on another project (`prompts/203-task-pause-use-elsewhere.md`). After #241 merges:
`git pull --ff-only` and `cargo install --path . --locked` on main.
