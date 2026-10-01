# Session 182 — Summary (CODE, interactive: ship S181's controls into existing projects)

**Branch:** `session-182-finish-s181-gaps` · **Brief:** `prompts/182-task-finish-s181-gaps.md` (approved: `vajra approve 182`, founder's own terminal) · **Review:** `sessions/session-182-review.md` · **Decision:** DECISION-011 S182 addendum

## Goal achieved?
Yes. A project that already uses Vajra now gets S181's approvals guard. It is switched on in the project's Claude settings, and the project is told the one rules line it is missing. rudra was upgraded for real, and its own registered guard blocks an agent write. The guard stopped falsely blocking reads (it did so twice at the start of this session), and its message now reaches the agent. The two test gaps carried from S181 are closed, and `--allow-all=NN` approves one session. `scripts/verify-session-182.sh` 15/15 real-run checks, demo 6/6 live checks, 562 lib tests, every integration suite green.

## Fidelity map (prompt `prompts/182-task-finish-s181-gaps.md`)
| # | Requirement | Status | Evidence |
|---|---|---|---|
| 1 | Whole-suite verify check is positive; fails when the suite does not compile | SHIPPED | `scripts/verify-session-181.sh` `whole_suite_check` (8aed970, 91b7380); verify-182 P1: a stub `cargo` that cannot compile → RED; the same stub on the old check → GREEN |
| 2 | Gate-level obeyed-handoff stamp test | SHIPPED | `tests/stamp_gate.rs::an_edited_judgment_stops_being_trusted_by_the_obeyed_gate` (3fce2eb) |
| 3 | Approvals guards shipped to scaffolded projects; old projects upgraded by `--sync-fleet` | SHIPPED | `scripts/hook-approvals-guard.sh` (one source), `SYNC_HOOKS` + settings template (86499ec); `--sync-fleet` settings merge (3a2a02e); `tests/approvals_scaffold.rs` runs the hook as the settings register it |
| 4 | `--sync-fleet` reports a missing `session_rules_from`, never edits | SHIPPED | 3a2a02e; test compares `.ai/CONSTRAINTS.yaml` bytes before/after |
| 5 | `--allow-all` tied to one session | SHIPPED | `--allow-all=NN` (233e669); `approval::tests::allow_all_approves_only_the_session_it_names`; bare form refused (`tests/approval_cli.rs`) |
| 6 | Guard's false blocks fixed (reads pass, writes still block) | SHIPPED | 71f7c68; `tests/approvals_guard.rs` (23 writes block, 7 reads pass); verify-182 old-vs-new on the real hook |
| 7 | rudra upgraded for real, no commit there | SHIPPED | live run below; rudra HEAD `5ab6e83` before and after |
| AC6 | Every check runs the real thing; `verify-closeout.sh` exits 0 on the branch before merge | SHIPPED at close | verify-182 has no source greps; closeout run recorded in the review |

## rudra, live (step 7) — branch build, `/Users/suman/playground/rudra`
```
== rudra BEFORE: 5ab6e83   (M .ai/CONSTRAINTS.yaml — the founder's F93 edit)
$ /Users/suman/playground/vajra/target/debug/vajra init --sync-fleet
  upgrade .ai/hooks/hook-session-start.sh (stale render 280e59f8 → af3985c4)
  create  .ai/hooks/lib-ground-truth.sh
  create  .ai/hooks/hook-approvals-guard.sh
  upgrade scripts/verify-closeout.sh (stale render e85af5ff → 16e2fd88)
  merge   Vajra's missing hooks into .claude/settings.json (your keys and hooks kept)
  ACTION  .ai/CONSTRAINTS.yaml has no `session_rules_from:` … add this line under `session:`
              session_rules_from: 16
added `session_rules_from: 16` by hand, as reported → a re-run prints no ACTION
== rudra's settings register the guard for:
   matcher Bash|Edit|Write|MultiEdit|NotebookEdit  →  bash "$CLAUDE_PROJECT_DIR/.ai/hooks/hook-approvals-guard.sh"

== agent tries: {"command":"echo '{\"approved\":true}' > .ai/approvals/session-16.json"}
[HOOK BLOCK] .ai/approvals holds the founder's approvals, and this command redirects output while naming it.
  Only `vajra approve NN`, typed by the founder in their own terminal, writes there. Reading is fine: run the read on its own (cat/ls/jq), without a redirect in the same command.
   exit: 2

== agent tries: {"file_path":"/Users/suman/playground/rudra/.ai/approvals/session-16.json","content":"{}"}
[HOOK BLOCK] /Users/suman/playground/rudra/.ai/approvals/session-16.json is an approval record. Only the founder writes it: `vajra approve NN` in their own terminal.
   exit: 2

== agent tries: {"command":"ls .ai/approvals 2>&1"}
   exit: 0

== rudra AFTER: 5ab6e83 (unchanged); 6 files changed, uncommitted, for the founder's S16 first commit
```
**Re-syncs after later guard changes** (same branch build, same command, rudra HEAD still `5ab6e83` each time):
- after 540db79 (backticks): `upgrade .ai/hooks/hook-approvals-guard.sh (stale render c12e4d65 → f002611a)`
- after 4449ebb (review pass 1 fixes): `upgrade .ai/hooks/hook-approvals-guard.sh (stale render f002611a → 21333991)`
- after 293796b (key order): `git checkout -- .claude/settings.json` restored rudra's committed settings, then `merge   Vajra's missing hooks into .claude/settings.json (your keys and hooks kept)` — `git diff --stat`: `.claude/settings.json | 9 +++++++++`, the guard group only.

Verify P7 re-runs rudra's registered command live on every run (exit 2).

**Cold review pass 1 (ACCEPT, one `mismatch:`):** found that the guard let one write spelling through that S181 blocked (`>&1/../<folder>/x`). It also found that `--sync-fleet` would list three hooks twice in a pre-S93 project, that an L1 project with no jq was blocked on every edit, and that capitals and quotes reached the folder. All four were fixed with tests that fail without the fix (4449ebb, 2967453). With the founder's yes, the settings rewrite now keeps the project's key order (293796b), so rudra's settings diff is 9 added lines. Pass 2 is a fresh review (`sessions/session-182-review.md`).

**Not built:** nothing from the brief. **Found and fixed on the way:** the S181 guard printed its block message to stdout, so the agent saw "No stderr output" and no reason; my first step-2 check was too strict (a test prints the word FAILED as its own output); a `cd .ai` inside backticks got past the guard (found while writing the addendum).
**Fakest green:** the guard still decides by reading command text. A folder path built at run time (`d=.ai; … "$d/approvals"`) or a glob gets past it. "Only add" is now checked against the S181 hook, but only for the 27 listed spellings. That is a list, not a proof (the S173 lesson). It is also blunt the other way: a command that names the folder and redirects anywhere is blocked, even a harmless one.

## Disclosed limits
Bar-raising, **not tamper-proof** (DECISION-011): same OS user, run-time paths, `env -u` the mark. The obeyed-gate test proves an edited judge record is refused; it does not prove a judge read the diff (the S132 ceiling). `--allow-all=NN` still relies on the launch pid being alive. For rudra's S16 the founder now approves with `vajra approve 16`, because the brief's own words no longer count.

## 3 ranked next candidates
1. **(Recommended) rudra session 16 under the new rules (interactive).** The founder runs S16 with `vajra approve 16`, the guard on, and named waivers, and brings back what breaks. Why: S182's controls get their first real use on a real project. Risk: new refusals mid-session, which are themselves the findings.
2. **F67 — the receipt reads the tool's own cost for interactive runs.** rudra receipts show ~5× the real cost. The founder parked this three times and wants the permanent fix, not new price rows. Risk: Claude Code may not write a cost into the transcript an interactive run leaves.
3. **Finish 0.2.0: crates.io publish.** A stranger gets S167–S182. Risk: founder-only steps; the founder said not until he is confident and nothing is pending.
