---
role: tech-lead
session: 188
agent: claude-code-subagent (verified: toolu_01Ukufs5wiLPi6LFzHzMUrLf; text-sha: c5263ba2ba6cc5297736c78799f2834b013769170bbc84284af1a916120856e0)
source-sha: a0921ea3f423bb6f0a78fa60f13d88c7e8989a6c5c7378f5cd48be28f4bc9c7a
captured: 2026-10-05T15:16:25Z
cost_usd: null
---

# Tech-lead handoff — session 188

# Tech-lead handoff — session 188

Tech-lead brief: Session 188 (CODE). One story. Replace the approvals guard's Bash word checks (scripts/hook-approvals-guard.sh, shipped to projects as .ai/hooks/hook-approvals-guard.sh) with a before/after check of .ai/approvals around every AI Bash command. The before and after calls are paired by tool_use_id (PreToolUse + PostToolUse + PostToolUseFailure). If the folder changed, the approval stops counting (approved() in src/approval/mod.rs reads it as missing) until the founder runs `vajra approve NN` again. The Write-tool path block stays. Deliverable 1 (N2 → backlog) is already on main, so it only needs a wording check.

Sources read:
- /Users/suman/playground/vajra/prompts/188-task-approvals-before-after-check.md
- /Users/suman/playground/vajra/.ai/handoffs/session-187-tech-lead.md (for the format)
- /Users/suman/playground/vajra/scripts/hook-approvals-guard.sh
- /Users/suman/playground/vajra/src/approval/mod.rs (`approved()`, `write_record`, `allow_all_live`)

How I sized this: the founder approved the plan himself (record at .ai/approvals/session-188.json). The prompt turns it into 5 deliverables and 6 checkable acceptance checks (ACs). Three things are still open:
- the design shape (design-advisor, mandatory because the prompt says design-significant: yes)
- one cold fidelity review
- one judge for every `obeyed:` answer

That makes a crew of three, the same as S185–S187, about 4.0M tokens in total. Each budget below is a written instruction I am trusting the role to follow. Vajra cannot stop a role partway through a run, so these are not hard limits.

crew researcher — deferred-budget — budget: 600000 tokens — Only one fact is still open: whether Claude Code's PreToolUse, PostToolUse and PostToolUseFailure inputs carry the same tool_use_id, and whether PostToolUseFailure fires on a non-zero exit. That is a single docs lookup, folded into the design-advisor's brief. A separate ~0.6M dispatch would take the crew to ~4.6M, above the founder's ~4M line (S134: three broad dispatches used 19.2M and hit the monthly limit).
crew requirements-analyst — deferred-budget — budget: 500000 tokens — The prompt's 5 deliverables and 6 ACs come straight from the founder's own approved plan (2026-10-05). A ~0.5M pass would only restate them, on top of a ~4.0M required crew.
crew design-advisor — required — budget: 1200000 tokens — Mandatory: the prompt says design-significant: yes, and this session reverses DECISION-011's S182/S186 choice for Bash. Read only five things: scripts/hook-approvals-guard.sh, src/approval/mod.rs, DECISION-011 in docs/decisions/, the S182 `--sync-fleet` settings-wiring path in src/cli/init.rs, and Claude Code's hooks reference for PostToolUse and PostToolUseFailure. Name: (a) where the "before" record lives; (b) how approved() treats a void, covering every record kind including allow-all, how `vajra approve` clears it, and what happens when both land in the same second; (c) how the new hooks run alongside the existing PreToolUse hook-pre-bash.sh and Vajra's compression PostToolUse hook (do not rely on an order between them); (d) what the after hook does when it finds no matching before record, and what it does at L1; (e) the docs facts in the researcher line. Then write the DECISION-011 S188 addendum wording. Check the founder's plan; do not redesign it.
crew plan-advisor — deferred-budget — budget: 500000 tokens — There is one story, and the Planner gate already checks `covers: N`. rec 1 below gives the one order that matters (the new check before the deletion). ~0.5M more on top of ~4.0M is money the account cannot spare.
crew implementation-advisor — deferred-budget — budget: 1200000 tokens — It would help most on the hook pair and the `--sync-fleet` wiring. But it would read the guard, its scaffold copy, init.rs and the tests, about 1.2M, which takes the crew to ~5.2M. Standing in for it: the design-advisor's shape, plus the real-run AC2/AC5 checks in recs 7–9.
crew qa-specialist — deferred-budget — budget: 1000000 tokens — AC6 already requires scripts/verify-session-188.sh to be red at the start commit and to use real runs, not source greps. The author writes it and the fidelity-reviewer re-runs it. A separate ~1M QA dispatch adds cost the founder asked to keep down (S168).
crew demo-producer — deferred-budget — budget: 600000 tokens — The founder sees the change for real on rudra's next `--sync-fleet`. The only user-facing text is the one plain message, and the fidelity-reviewer reads it. ~0.6M for a demo would push the crew to ~4.6M.
crew fidelity-reviewer — required — budget: 2000000 tokens — Mandatory at close since S131: one cold review. It reads the prompt and the branch diff. It re-runs `bash scripts/verify-session-188.sh` and the AC1/AC2 corpus at 43305fd (main when the branch was cut) and at the tip. It also re-runs the full `cargo test`. The diff touches shell, Rust, init, tests and a decision record, so this role gets the largest budget.
crew release-coordinator — required — budget: 800000 tokens — One release-coordinator judges every `obeyed:` answer in a single pass (founder rule). Advisors cannot grade their own recs, so this role covers the tech-lead's and the design-advisor's recs. It reads only `## Advice` and each commit cited there.

rec 1 — Land the after-check and the void (approved() reads a voided approval as missing) BEFORE deleting the Bash word checks, so that no commit on the branch leaves the folder with neither guard.
Why: the ≤3-files rule means several commits. If the deletion comes first, there is a commit where a write into the folder is neither blocked nor caught.

rec 2 — Keep the "before" record outside .ai/approvals and outside the tracked tree (for example under the git dir or the temp folder, keyed by session and tool_use_id), and delete it in the after hook.
Why: a record kept inside the folder changes the folder it is checking. One kept inside the tree can get committed (founder rule: no session artifacts in git).

rec 3 — Whatever shape the void takes, the AI must not be able to undo it quietly. Undoing it must itself change .ai/approvals, so the next before/after pair catches it. It must also cover every approval kind, including the allow-all record.
Why: a void kept anywhere else can be deleted by one more Bash command that nothing watches. allow-all is the branch of approved() that is easiest to miss.

rec 4 — Cover the case where the founder's `vajra approve NN` lands WHILE a long AI command is running (cargo test takes minutes). The plain message must also say "if you ran `vajra approve` yourself while this command was running, run it again". Give AC3 a second fixture for this overlap that records what actually happens.
Why: deliverable 5 assumes the founder approves between commands. During a long command his approve lands inside a pair and cancels itself. That flags the founder, which the story says never happens.

rec 5 — In the DECISION-011 addendum and in the summary, name every case where no after hook runs:
- a background Bash command (`run_in_background`) that writes after it returns
- an interrupted or timed-out command
- a hook that itself times out

For each, say which outcome it gets: caught by a later pair, looks like the founder, or missed.
Why: the prompt names two accepted gaps, and these are the same kind. Say "named, not closed" so the founder does not find them on rudra himself.

rec 6 — Before building, confirm from Claude Code's hooks docs that all three events carry the same tool_use_id and that PostToolUseFailure fires when the command exits non-zero. Cite the docs in the addendum. Then decide, with a test, what the after hook does when it finds no before record.
Why: the whole pairing rests on those two facts. A write inside a failing command (`cp x .ai/approvals/y; false`) is the one most likely to slip through if the failure hook is not wired.

rec 7 — Convert the old tests, do not delete them. Each write-command test in tests/approvals_guard.rs changes from "blocked before" to "caught after": run the real command between a real before call and a real after call of the shipped script, and rename the test to what it now checks. The Write-tool path tests stay as they are. Add two cases to the AC2 set: `cp x .ai/approvals/y; false` and a path built at run time (`d=.ai; cp x $d/approvals/y`).
Why: a deleted test is a removed check. The run-time path is the hole DECISION-011 admitted the old guard had, so catching it is the proof the new check is better.

rec 8 — For AC5, run `--sync-fleet` on a settings.json that already holds the project's own PostToolUse hooks. Those must stay byte-identical. The new after hook and the failure hook are added once, and a second run adds nothing.
Why: this is S182's add-only rule. A project's own hooks are exactly what an add-only change must never touch.

rec 9 — Run the AC1/AC2 checks against both scripts/hook-approvals-guard.sh and the copy `vajra init` ships, or prove in the verify script that they are the same bytes.
Why: same as S187 rec 2. If the copies drift, projects run a guard Vajra never tested.

rec 10 — Treat deliverable 1 as a read-only check. If ROADMAP and STATE already say "N2 → backlog, known issue" and no longer say "N2 → S188", record that in the summary and make no commit for it.
Why: closeout PR #225 already did this. A commit that changes nothing is ceremony the founder asked to cut.

rec 11 — Three dispatch rules:
- Write a reasoned skip line in the prompt for implementation-advisor (and for any role a mandate asks about), carrying the budget reason above.
- Dispatch the fidelity-reviewer once, on the finished branch. If it REJECTs, fix and run one fresh pass, not a loop.
- Dispatch the release-coordinator once, only after `## Advice` answers every rec from the tech-lead and the design-advisor.

Why: S168's review loops nearly made the founder quit, and one judge for all `obeyed:` answers is his rule.

## Handoff Delta
- `+` new: first tech-lead handoff for this session (10066 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
