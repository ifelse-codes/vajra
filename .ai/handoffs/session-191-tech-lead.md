---
role: tech-lead
session: 191
agent: claude-code-subagent (verified: toolu_015fg9sNN4ucFMmK8bBofBfv; text-sha: a99b92da53879f075e80f4a3b515332c9e5a7ad0b7d648573b6456eb894b8a90)
source-sha: a7aa41b23c37095b4ab99d20b3e2c69cca25d5659685def570b88a00f4c7b84e
captured: 2026-10-08T14:27:37Z
cost_usd: null
---

# Tech-lead handoff — session 191

Tech-lead brief: Session 191 (CODE, one story made of four small fixes). (1) N2: during a ground truth, the write guard lets a Write go through when the target is really outside the project. Recs 12–20 of the S187 design-advisor handoff already specify how, and the session records it in a DECISION-011 S191 addendum. (2) `update_session_boot` replaces only the number right after `**Number:**`. (3) `verify-session-133.sh` uses its own fixture worktree each time it runs, so two runs at once do not collide. (4) `hook-session-guard.sh` stops reading a heredoc body as a command, except when that heredoc is fed to a shell. Item 4 carries the risk and has a cut line.

Sources read:
- /Users/suman/playground/vajra/prompts/191-task-small-fixes.md
- /Users/suman/playground/vajra/.ai/handoffs/session-189-tech-lead.md (for the format)
- /Users/suman/playground/vajra/.ai/handoffs/session-187-design-advisor.md, only the rec 12–20 lines
- /Users/suman/playground/vajra/scripts/hook-session-guard.sh lines 55–104 (the S173 note at lines 65–68 says a heredoc exception was tried and taken out)
- a grep: src/cli/next.rs:1951 `update_session_boot` and its one test at :2336; src/cli/init.rs:2276 builds `hook-session-guard.sh` into every `vajra init` with `include_str!`

How I sized this: S185–S189 each ran a crew of 3–4 for about 4.0M tokens, which the founder has accepted. Nothing in this session is an open fact. N2's design was finished at S187, and items 2 and 3 are plain bugs, so no researcher is needed. The only design work still open is the heredoc rule, which is where S173 needed five cold-review passes. So the design-advisor is required: the prompt makes it mandatory anyway, and its brief points it at the heredoc rule. The fidelity-reviewer gets the largest budget because it has two guard changes to re-run at the start commit and at the tip.

Required crew: design-advisor 1.0M + fidelity-reviewer 2.0M + release-coordinator 0.6M = about 3.6M.

Each budget is a written instruction I am trusting the role to follow. Vajra cannot stop a role partway through a run, so these are not hard limits.

crew researcher — deferred-budget — budget: 400000 tokens — No open facts this session. N2 was fully specified at S187 (recs 12–20), and items 2 and 3 are local bugs with the cause already named. A ~0.4M dispatch would take the crew from ~3.6M to ~4.0M without answering anything new. S134: three broad dispatches used 19.2M tokens and hit the monthly limit.
crew requirements-analyst — deferred-budget — budget: 400000 tokens — The 4 deliverables and AC1–AC5 restate the founder's S190 pick ("option A, approved as written"). ~0.4M on top of ~3.6M is ~4.0M, and it would buy only a restatement. That leaves no money for the one role below that would really help (implementation-advisor).
crew design-advisor — required — budget: 1000000 tokens — Mandatory: design-significant: yes. Read only the prompt, recs 12–20 of the S187 design-advisor handoff, docs/decisions/DECISION-011-controls-the-agent-cannot-type.md, scripts/hook-pre-write.sh (the GT_PW=1 branch) and scripts/hook-session-guard.sh. Spend about 0.2M on N2: confirm the S191 addendum text, and settle the one placement conflict. S187 rec 17 says "after the approvals-guard call"; the prompt says "after today's allowlist match". Spend the rest on item 4: name which heredoc shapes may have their body removed from SCAN (see rec 2), and say whether one KNOWLEDGE line is enough given that this guard ships to user projects.
crew plan-advisor — deferred-budget — budget: 400000 tokens — The prompt's Plan already covers every AC with `covers: N`, and it has a cut line. rec 1 gives the one ordering point that matters. ~0.4M would take ~3.6M to ~4.0M for no new order.
crew implementation-advisor — deferred-budget — budget: 800000 tokens — This would really help on item 4's perl/sed parsing. But a real look at hook-session-guard.sh, the S173 corpus and the bash 3.2 quirks costs ~0.8M and takes the crew to ~4.4M, over the ~4.0M line. Standing in for it: the design-advisor's heredoc rule (recs 2–3), the required old-vs-new corpus test, and the prompt's cut line.
crew qa-specialist — deferred-budget — budget: 800000 tokens — AC5 already makes the author write scripts/verify-session-191.sh with every fix red at the start commit for its named reason, and the fidelity-reviewer re-runs it at the start commit and at the tip. A separate ~0.8M QA pass would take the crew to ~4.4M.
crew demo-producer — deferred-budget — budget: 400000 tokens — Nothing changes on screen except one guard message (item 1's "create the folder in Bash first" text), which the fidelity-reviewer reads. ~0.4M would take the crew to ~4.0M for a demo of four bug fixes.
crew fidelity-reviewer — required — budget: 2000000 tokens — Mandatory at close: one cold review. Read the prompt and the branch diff. Re-run `bash scripts/verify-session-191.sh` at the start commit (main at f37b0fe when this brief was written; confirm with `git merge-base main HEAD`) and at the tip, and re-run the full `cargo test`. Check that each rec 19 fixture case for N2 is red at the start commit. Check that item 4's corpus covers every command the old guard blocked, run under /bin/bash 3.2 on macOS. Check that items 2 and 3 really fix the bug and do not just pass the test.
crew release-coordinator — required — budget: 600000 tokens — Founder rule: one release-coordinator judges every `obeyed:` answer, in one pass. An advisor cannot grade its own recs. Read only `## Advice` and the commit each answer names.

rec 1 — Build in the order cheapest-first: item 2, then item 3, then item 1 (N2), then item 4 last, in its own commit. Keep to the cut line: if item 4 and its corpus are not green by about 1h30, ship 1–3 and move item 4 to its own session, and say so plainly.
Why: the prompt's guardrail. Item 4 is the only guard-parsing change, and S173 shows these need several passes. The three safe fixes must not wait on it.

rec 2 — For item 4, use an allow-list, not a deny-list. Remove a heredoc body from SCAN only when the command is a plain file writer (`cat > file <<…`, `cat >> file <<…`, `tee file <<…`) with no pipe and no shell reading the input. Every other heredoc shape stays scanned: `| bash`, `| sh`, `bash <<EOF`, `sh -s <<EOF`, `source /dev/stdin <<EOF`, `| xargs`, `ssh host <<EOF`, and any shape not on the list. Remove it from SCAN only. EXTRA must still be built from the raw command, so a `$( )` inside an unquoted heredoc body (which the shell runs) can still add a reason to block. If perl is missing, remove nothing and fall back to today's rule.
Why: hook-session-guard.sh lines 65–68 say an earlier heredoc exception was tried and taken out, because "each version hid something a shell runs". The prompt's one named exception (`| bash`) is only one of many ways a heredoc gets run.

rec 3 — Item 4's old-vs-new corpus must include S173's cases. That means the macOS /bin/bash 3.2 case, where `$( )` ends at a `)"` line inside a heredoc, and the `git commit -m "$(cat <<'EOF' … EOF)"` commit-message form, which must KEEP blocking: S173's decision was "write the message to a file and use `git commit -F`". Run the corpus under /bin/bash, not a newer Homebrew bash.
Why: AC4 says every command blocked before S191 must still block. These are the exact cases that broke S173's earlier tries.

rec 4 — For AC2, put the real S188 `**Number:**` line straight into the Rust unit test as a literal. Do not read it from git history while the test runs. Add two edge cases: a line with no `**Number:**` changes nothing, and the same digits appearing BEFORE the field on that line are left alone.
Why: `cargo test` must not depend on what is in the git history. The two edge cases are how an anchored replace usually goes wrong.

rec 5 — For AC3, have the test start the two runs at the same time for at least 3 rounds, not once. Give each run its own worktree (`mktemp -d`) and clean it up with a trap on every way out (`git worktree remove --force`, then `git worktree prune`), so runs that overlap do not leave old `.git/worktrees` entries behind.
Why: a race test that runs once can pass by luck. Leftover worktree records are the next thing two runs at once would trip on.

rec 6 — Say in the summary that the item 4 change reaches only NEW projects. `vajra init` builds hook-session-guard.sh in with `include_str!` (src/cli/init.rs:2276). Projects that already exist, rudra included, keep the old copy. Call this "named, not closed". Do not build an updater this session.
Why: S136 found that copying a file only when it is missing cannot update it later. The founder's rule: renaming or disclosing a gap is not fixing it.

rec 7 — Run the crew in this order: design-advisor first, then the build, then one fidelity-reviewer on the finished branch. On a REJECT, fix it and run one fresh pass, not a loop. Then one release-coordinator, after `## Advice` answers every rec. In the prompt, write a reasoned skip line for each deferred role, carrying the money reasons above.
Why: S168's review loops nearly made the founder quit. One judge for every `obeyed:` answer is his rule.

## Handoff Delta
- `+` new: first tech-lead handoff for this session (9237 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
