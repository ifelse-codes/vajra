---
role: fidelity-reviewer
session: 197
agent: claude-code-subagent (verified: toolu_01RqsKZ76ug9hA392LbShFRt; text-sha: 0a503898a2f756e95ef414e9bd9b65f527c5339d5298e4494d3e6b9a01041392)
source-sha: 6598ebe9127a4af7d3f7bd22e297d7bea5a47034d5530af29a7ace65b082dd4f
captured: 2026-10-14T17:34:50Z
cost_usd: null
---

# Fidelity-reviewer handoff — session 197

# Session 197 — fidelity review

**Verdict:** ACCEPT

**Method controls:** cold, read-only pass. I read the prompt (including "Founder call in-session" and `## Advice`), the summary, the DECISION-011 S197 addendum and the changed files in full: `scripts/hook-ground-truth-guard.sh`, `scripts/hook-pre-bash.sh`, `scripts/hook-pre-write.sh`, `scripts/verify-session-197.sh`, `scripts/scaffold-drift.sh` check 6, `src/approval/mod.rs`, `src/cli/next.rs` (the flag and the advance), `src/nextstep/mod.rs`, `src/cli/init.rs` (SYNC_HOOKS, the settings template, the merge) and `.ai/ROADMAP.md`. I could not run git or any commands, so I did not compare the eceb6d5 hooks byte for byte. I did not run `cargo test` or the verify script either. The 735-test and 11/11 figures are the builder's own claims.

**10 of 12 SHIPPED** (2 PARTIAL, 0 NOT-BUILT).

| Item | Grade | Evidence |
|---|---|---|
| D1 F125+N17: no branch name the agent picks turns the guard off | PARTIAL | The `-closeout` and `-enforcement` exemptions are gone from the guard, the session-start hook and the prompt-submit hook. N17 uses HEAD's `.ai/SESSION` + 1 (guard lines 58-66). But a branch with a different number still turns it off: in ground truth 200, `git switch -c session-201-x` is allowed, because the guard never blocks checkout or switch. After that the guard reads 201 and lets everything through. The addendum names this ("wrong number"), so it is disclosed but still open. |
| Founder call: ship the guard to every project | SHIPPED | `init.rs:40` and `:1816` list `.ai/hooks/hook-ground-truth-guard.sh` for both `init` and `--sync-fleet`. `:2239` wires it into the `Bash\|Edit\|Write\|MultiEdit\|NotebookEdit` group. Verify rows 1 and 7 cover it. |
| D2 F116 | SHIPPED | `approval::record_not_in_git` (`git cat-file -e HEAD:<rel>`); `nextstep/mod.rs:107`. |
| D3 F118 moved out | SHIPPED | ROADMAP line 781: "STILL OPEN. Moved out of S197 by the founder (2026-10-14)… on the S200 ground-truth checklist." No session claims it fixed. One loose end: the S197 status row (line 714) still lists F118 among this session's fixes. |
| D4 F119 | SHIPPED | `design_not_needed()` reuses `architect::design_gate`; `nextstep/mod.rs:143`. The how-to now offers both choices instead of telling the agent to cite a record. |
| D5 N10 | SHIPPED | `scaffold-drift.sh:310` needs a non-empty reason after `# source-claim:`. verify-189, 191 and 193 carry the marker. |
| AC1 | SHIPPED | Rows 1–7 run in temp `vajra init` projects. They cover `-closeout` blocking commit, push and PR, the record opening it, an older binary staying closed, a forged record being voided, N17 being blocked, and `--sync-fleet` wiring the guard. |
| AC2 | SHIPPED | Row 8 checks before and after the commit, plus the old binary. That control requires the ✓ line, so a silent old binary cannot pass it. |
| AC3 | SHIPPED | As D3. |
| AC4 | SHIPPED | Row 9: ✓ from `--steps`, READY from `--check-design`, and ✗ from the old binary. |
| AC5 | SHIPPED | Row 10: exit 0 on Vajra. Both the unmarked grep and the marker with no reason still fail. The old script fails on verify-189. |
| AC6 | PARTIAL | The rows really run the thing, with no greps of Vajra's source. But the push through the S196 belt has not happened yet (it comes after close), and nothing in the diff shows the `cargo test` run. The summary's "each red at eceb6d5" is too strong: rows 3, 5 and 7 have no run at eceb6d5. |

**Verify script (task 2):**
- **Rows 2 and 6 have no positive control.** Each passes when the eceb6d5 hook exits 0 on `-closeout` or `notes`. Nothing shows that the same old hook *blocks* a plain `session-05-x` branch in that project. If the old Vajra hook could not find its `lib-ground-truth.sh` inside a scaffolded project, it would exit 0 for that reason instead, and the row would still pass.
- **Row 1's eceb6d5 half checks text, not behaviour.** It greps the scaffolded hooks for missing strings and uses jq on the settings file. It does not run the hook.
- **No row runs Vajra's own `hook-pre-write.sh`** for a ground-truth write. Row 3 only runs the project copy.
- **Row 4's "founder terminal" is `script -q /dev/null`.** The builder named this; it is a pseudo-terminal any agent can start too.

**Ways the guard fails open that the addendum does not name (task 3):**
- **The write allowlist reaches project code.** `*/scripts/*` (guard line 165) matches anywhere in the path, so it covers `src/scripts/x.py` or any project's own `scripts/` code. Shipped to every project, this lets the agent edit real code during ground truth. The addendum only mentions it as "edit the guard itself".
- **The guard's settings are agent-writable.** `.ai/CONSTRAINTS.yaml` is on the allowlist. One Edit to `maturity: L1` turns the guard into a warning. One Edit to `ground_truth_next_session: <later>` makes `vajra_is_ground_truth` return "not ground truth".
- **An unknown `tool_name` exits 0.** Any name outside the five exact ones in the `case` falls through to `exit 0`. Only an *empty* name is checked by what the input carries.
- **A missing `lib-ground-truth.sh` falls back to every-5th**, which ignores an override key.
- **The working-tree `.ai/SESSION` fallback is agent-writable**, and it is used whenever HEAD has no `.ai/SESSION`.
- **If the founder commits the advance by hand during ground truth N**, HEAD reads N and a branch with no number becomes N+1. The guard is then off.
- **Common spellings slip past the text check:** `git -C <dir> commit`, or `git worktree add` followed by edits outside the project. These fall under the named "spelling" limit, but they are everyday commands, not tricks.
- **Checks dropped from Vajra's own hooks:** I could not diff the old files. The current hooks keep the destructive-command warnings, the approvals guard and the main-branch warning. NotebookEdit was never in Vajra's own matcher, and still is not.

**Approval code (task 4):**
- `close_record` reads the void the same way as an approval: a listed name, any letter case, means it does not count, and an unreadable void means closed.
- It requires `method == "close-command"` and `session == n`.
- `approve_close` has the same refusals as `vajra approve` and un-lists only its own name. `session_of` returns None for `-close.json`, so `vajra approve MM` never un-lists it.
- The unit test `the_close_record_is_read_like_an_approval` covers all of this. The one case it does not test is a close file whose body names a different session, but the code handles it.
- The guard only opens on the exact first-line sign-off message, so an older binary stays closed.

All of this matches the addendum.

## Fakest green

**The D1 checkmark "no branch name opens it."** The rows only try the one name that was fixed (`-closeout`) and a branch with no number. No row tries a session branch with a different number that the agent cuts itself. If row 1 were run on `session-06-x` during ground truth 5, the guard would exit 0 and the row would go red today. The agent can still turn the guard off by naming a branch, which was the original F125 bug; it now just has to pick a different number, and the session-start guard only catches `checkout -b` to owner+1. The addendum names the hole, but naming a hole does not close it.

## Recommendations

rec 1 — Close the wrong-number branch route: while the guard is on, block making or switching branches (`git checkout -b/-B`, `git switch -c/-C`, `git branch <new>`, `git worktree add`), or treat the session as ground truth if either the branch number or HEAD's `.ai/SESSION`+1 says so; add a verify row "session-06-x made during ground truth 5 stays blocked".
If refused, change the D1 and summary wording to "the `-closeout` suffix no longer opens it" and mark it "named, not closed".

rec 2 — Anchor the write allowlist to `$ROOT/` and narrow `scripts/` to `scripts/verify-session-*` and `demo-session-*`, or add to the addendum's Limit list that, in every project, code under any `scripts/` folder can be edited during ground truth.

rec 3 — Add to the Limit list (or close) that `.ai/CONSTRAINTS.yaml` is agent-writable during ground truth, so `maturity: L1` or a moved `ground_truth_next_session` key weakens or switches off the guard; the same goes for the working-tree `.ai/SESSION` fallback.

rec 4 — Fail closed on an unknown `tool_name`: send any name outside the five through the same input-shape check as an empty name, instead of `exit 0`.

rec 5 — Add positive controls to verify rows 2 and 6: show that the eceb6d5 hook blocks a plain `session-05-x` branch in the same project, so its exit 0 on `-closeout`/`notes` is proven to come from the bug and not from the old hook failing to find its lib.

rec 6 — Add a verify row that runs Vajra's own `scripts/hook-pre-write.sh` on a `src/` write during ground truth, and correct the summary's "each red at eceb6d5": rows 3, 5 and 7 have no run at the start commit.

rec 7 — Record evidence for AC6 at close: the full `cargo test` result and whether the S196 push belt let the GREEN push through.

rec 8 — Add `git -C <dir> commit` and `git worktree add` plus edits outside the project to the addendum's spelling limit as concrete, everyday examples.

rec 9 — Fix ROADMAP line 714 (S197 status row): it still lists F118 among this session's fixes.

## Handoff Delta
- `+` new: first fidelity-reviewer handoff for this session (9304 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
