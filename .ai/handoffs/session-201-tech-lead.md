---
role: tech-lead
session: 201
agent: claude-code-subagent (verified: toolu_014upzjxVWGfoE7tLzJ44CAo; text-sha: 3d3af4075159282cf68e723dbd733fb7c3ce9da156f8774b06998fb9d41bcfe8)
source-sha: 9cbb37cd644b6b9160af2ccf7ecf5ba8119d34ac6e91814cbf4b82be87cf7e82
captured: 2026-10-16T18:41:54Z
cost_usd: null
---

# Tech-lead handoff — session 201

Tech-lead brief: Session 201

Session 201 is a small CODE session with four items, done in order: N24 (step wording), N22 (retire two history scripts), N25 (an after-merge reinstall note) and the README "tested with" line, which needs the founder's own words. The prompt says `design-significant: no` and changes no design record. As in S198–S200, the close needs two roles: one cold fidelity-reviewer, and one release-coordinator to judge every `obeyed:` answer. The release-coordinator's own recs are judged in a narrow second pass by that same fidelity-reviewer. Those two are the required crew, and the other seven are deferred for money reasons.

This is the same scope as S198 (two real fixes plus a note and a README line), so I size it the same: fidelity-reviewer 1.0M + release-coordinator 0.4M, about 1.4M required. S134's three broad dispatches used 19.2M raw tokens (17.5M of it cache reads) and hit the monthly cap. These budgets are instructions I am trusting each role to follow. Vajra cannot stop a role partway through a run, so they are not hard limits.

What I read:
- /Users/suman/playground/vajra/prompts/201-task-small-fixes.md (in full), plus /Users/suman/playground/vajra/.ai/handoffs/session-199-tech-lead.md and session-200-tech-lead.md for the pattern and the sizing.
- N24, first half. /Users/suman/playground/vajra/src/nextstep/mod.rs:123-140 is the review-only sign-off step. Its how, at lines 134-138, always starts "show the founder sessions/session-{nn}-ground-truth.md", whether or not that file exists. Nothing on the list says "write the report". The step only appears when `review_only()` (mod.rs:319-335) returns true. That function runs the shared `vajra_is_ground_truth` helper from lib-ground-truth.sh.
- N24, second half. The steps are mod.rs:194-198 (QA, "the checks run and pass", how "write scripts/verify-session-{nn}.sh") and mod.rs:199-207 (Demo-er, "a demo script exists…"). Neither looks at the session type. The close gate's own rule is in /Users/suman/playground/vajra/scripts/verify-closeout.sh:
  - Line 432-435, `check_verify_demo_scripts`: "if is_ground_truth_session; then … N/A: session $N is a NO-CODE ground-truth — no session scripts expected … ok". Neither the verify script nor the demo script is required.
  - Line 620-623, `check_demo_markers`: non-CODE sessions are N/A.
  - `is_ground_truth_session` (line 78-80) calls the same `vajra_is_ground_truth` helper as `review_only()`. So the step list can reuse `review_only(root, session)` and needs no new rule. The gate's word is "N/A … no session scripts expected".
- N25: where the after-merge text lives. The step list the agent reads at every boot is /Users/suman/playground/vajra/src/nextstep/mod.rs:255-267, the Releaser step "the work is merged and the branch is gone". At line 265 its how says "…ask the human to merge it, then prune the branch. If main has commits GitHub lacks, `vajra next --release NN` names them…". That is the line that hands the founder the after-merge steps, so the note goes there. Other places that mention merge/sync:
  - /Users/suman/playground/vajra/.ai/SESSION-BOOT.md:4 already says `git pull --ff-only`, then `cargo install --path . --locked` (N25). S200's closing agent wrote that by hand; no code writes it.
  - src/cli/next.rs:1905-1910 (the `--advance` Releaser refusal), scripts/verify-closeout.sh:1071 (the close FAIL line), src/fleet/mod.rs:391 (the release-coordinator's system prompt: "merge, return to main and pull, then prune") and scripts/hook-publish-guard.sh:210. These are refusals or role prompts, not the hand-off text.
  - A trap: this step list ships to every project (rudra too). "Reinstall vajra when the branch touched src/" is only true when the repo IS Vajra (Cargo.toml:2 `name = "vajractl"`, Cargo.toml:55 bin `vajra`). In rudra, a merged `src/` change has nothing to do with the installed vajra. See rec 2.
- N22: /Users/suman/playground/vajra/scripts/verify-session-178.sh:1-6 and scripts/demo-session-178.sh:1-6 have plain headers with no retired mark. The precedent the prompt cites did not edit the script headers:
  - verify-182/186/187 were retired in sessions/session-190-ground-truth.md:53. It quotes the AGENTS.md "RETIRED (superseded)" standard, names S188 / DECISION-011 S188 addendum, and says "Left as history (same as verify-175)". The ROADMAP marks them at .ai/ROADMAP.md:707.
  - verify-175's only note is an in-line comment (verify-session-175.sh:33-37) about two rows it replaced.
  - The standard itself is .ai/AGENTS.md:170-178. Its "RETIRED (superseded)" form needs the superseding session and item cited, with evidence.
  - The ROADMAP entry to update is .ai/ROADMAP.md:838-842.
  - So the S201 header note is new (the prompt asks for it). It should follow the S190 wording: superseded by which sessions' wording changes, left as history.
- Standing founder rules: no new policing of Vajra's own paperwork, no `cargo test` in the close (the agent runs the full suite before the push), one release-coordinator judges every `obeyed:` answer, and the release-coordinator's own recs get a narrow fidelity pass.

crew researcher — deferred-budget — budget: 100000 tokens — I have already named every code site (mod.rs:123-140, 194-207, 255-267; verify-closeout.sh:432-435, 620-623; ROADMAP:838; GT-190:53). ~0.1M on top of the ~1.4M required would find them again. S134: three broad dispatches came to 19.2M and hit the cap.
crew requirements-analyst — deferred-budget — budget: 80000 tokens — The founder approved the prompt (`vajra approve 201`), and AC1–AC5 each name a real-run check. ~0.08M (to ~1.48M) would restate them.
crew design-advisor — deferred-budget — budget: 150000 tokens — `design-significant: no`, and no design record changes. N25's one real choice (show the note only in Vajra's own repo) is a one-line condition, covered in rec 2. ~0.15M (to ~1.55M) is not worth it for that. Record `design-advisor: skipped — <reason>` under `## Design` (the mandate's recorded-skip rung).
crew plan-advisor — deferred-budget — budget: 80000 tokens — The prompt fixes the order and the split rule. ~0.08M (to ~1.48M) would add nothing.
crew implementation-advisor — deferred-budget — budget: 150000 tokens — Two string branches in one file plus two header comments. I have named the traps in recs 1–3. ~0.15M (to ~1.55M) would repeat them. Write a reasoned skip line.
crew qa-specialist — deferred-budget — budget: 200000 tokens — AC5 already requires scripts/verify-session-201.sh with real-run rows that are red at the start commit, and the fidelity-reviewer runs them at both ends. ~0.2M (to ~1.6M) would do that twice.
crew demo-producer — deferred-budget — budget: 100000 tokens — The demo is a before/after of `vajra next --steps` output, built from scripts/demo-session-template.sh. ~0.1M (to ~1.5M) buys nothing the main session cannot draw.
crew fidelity-reviewer — required — budget: 1000000 tokens — One cold review, mandatory at close. It reads only the prompt (with `## Advice`), sessions/session-201-summary.md and the branch diff. It runs scripts/verify-session-201.sh at the start commit and at the tip, and checks that each row goes red for its own bug's reason. It checks four things: AC1's two fixtures (report absent and report present) and the QA/Demo wording on a review-only fixture; that the N25 note does not appear in a non-Vajra project; that verify-178/demo-178 changed only in their header comments (the diff shows no check line moved); and that the README line is quoted with the founder's yes. It runs the full `cargo test` once. In a narrow second pass it also judges any recs the release-coordinator makes.
crew release-coordinator — required — budget: 400000 tokens — The one judge of every `obeyed:` answer, in a single pass. It reads only `## Advice` and the commit each answer names. It writes the judge lines unfenced, in the `obeyed-check … implemented:` shape.

rec 1 — For N24, split the sign-off step's how on whether `sessions/session-{nn}-ground-truth.md` exists. If it is absent, the how starts "write sessions/session-{nn}-ground-truth.md (every audit, live), then show it to the founder…". If it exists, keep today's text from mod.rs:134-138. On the QA (mod.rs:194-198) and Demo-er (mod.rs:199-207) steps, use the same `review_only(root, session)` reading. On a review-only session, mark them done and use the gate's own words, e.g. "not needed — the close passes this N/A on a review-only session (verify-closeout.sh check_verify_demo_scripts)". Do not add a new condition.
Why: AC1 and the prompt's "the close gate's own rule decides, not a new one". `review_only()` and verify-closeout.sh's `is_ground_truth_session` call the same `vajra_is_ground_truth` helper, so the two cannot drift. Marking the steps done, rather than removing them, keeps the list's step count and order the same for every type.

rec 2 — For N25, add the reinstall note to the Releaser step's how in src/nextstep/mod.rs:255-267, right after "ask the human to merge it, then prune the branch". Show it only when the project is Vajra's own repo, read from structure (Cargo.toml has `[package] name = "vajractl"`, or the `vajra` bin target), never by searching prose. Word it as: "if the merged branch touched src/, the human then runs `cargo install --path . --locked` on main, or the next boot runs the old vajra". Leave SESSION-BOOT.md:4's hand-written line as the precedent. Name mod.rs:255-267 as the site in the summary (AC3).
Why: this step list ships to every project. Telling a rudra user to `cargo install` their own app after a `src/` change would be wrong advice. The founder's "no text guessing" rule means the Vajra check has to be structural. It stays a note, not a gate (the prompt). Whether the branch touched `src/` is decided by the human at merge time; the step does not compute it, so no new git logic is needed.

rec 3 — For N22, add a RETIRED block to the top comment of both scripts/verify-session-178.sh and scripts/demo-session-178.sh, in the "RETIRED (superseded)" form from .ai/AGENTS.md:175. Cite the later wording changes that broke the rows (the `--check-crew` / `--check-design-handoff` / `--check-fidelity-handoff` messages and today's required-crew message, as listed at ROADMAP:838-841), the founder's "Retire it" (S200), and "left as history". Change no line below the header. Update .ai/ROADMAP.md:838 to "RETIRED S201". In the summary, say that verify-182/186/187 were retired in sessions/session-190-ground-truth.md:53 and ROADMAP:707, not in their headers, so this header note goes one step past the precedent, as the prompt asked.
Why: AC2 says "nothing else changed in them". A diff limited to comment lines proves it. Being honest about the precedent avoids a fidelity finding on the claim "the way verify-175/182/186/187 were retired".

rec 4 — For the README line, write one proposed line from the observed facts: instruction-only steps were followed on Opus (rudra S16–S19, S21) and skipped on Haiku 4.5 (rudra S20), and the blocks held on both. Show it to the founder and wait for his words. Commit only his text, and quote it with his yes in the summary. If he has not answered by ~2h, move it to S202 under the split rule, with his yes written in the summary.
Why: AC4 and S118 (the README is his spec, never softened). It is last in the order, so it is the natural item to split.

rec 5 — Build AC1 as real runs in scripts/verify-session-201.sh, using temp projects made by `vajra init`:
- a review-only project with no report, where the first open step names "write sessions/session-NN-ground-truth.md";
- the same project with the report present, which shows today's how;
- a review-only project where the QA and Demo-er steps are not ✗;
- a CODE project where the QA and Demo-er steps keep today's how and ✗;
- for N25, a Vajra-shaped project (Cargo.toml name vajractl) that shows the `cargo install --path . --locked` note, and a non-Vajra project that does not.
Pin the "before" binary to the commit S201 started from (the prompt says `0caedc3`; confirm it with `git log` before pinning). Use scripts/lib-old-checkout.sh, never `main`.
Why: AC1/AC3/AC5, and S122 ("fixtures must fail for the right reason"). The non-Vajra row proves rec 2's condition, and the CODE row proves N24 did not weaken the steps a code session still owes.

rec 6 — Order and close: build in the prompt's order, at most 3 files per commit. Record each `step N — done: <sha>`. Keep `## Delta` above `## Advice`. Write a reasoned skip line for each deferred role. Record handoffs from the handback text, never from `.output` (F120). Run the crew in this order: build, then one fidelity-reviewer (one fresh pass on a REJECT), then answer every rec in `## Advice`, then one release-coordinator pass. Answer its own recs with a bare `deferred: <path>` where you can, or the narrow fidelity pass judges them. Run the full `cargo test` before the push (S187), then stamp → close GREEN → push through the S196 belt. In the closeout's SESSION-BOOT next-session line, keep the hand-written "pull, then `cargo install --path . --locked`" whenever this PR touches src/ (it will).
Why: CLAUDE.md hard rules, the founder rulings on one review and one judge, and the N25 lesson itself: S201's own fixes must be installed before S202's boot can show them.

Files:
- /Users/suman/playground/vajra/prompts/201-task-small-fixes.md
- /Users/suman/playground/vajra/src/nextstep/mod.rs (lines 123-140, 194-207, 255-267, 319-335)
- /Users/suman/playground/vajra/scripts/verify-closeout.sh (lines 78-84, 427-454, 615-623, 1071)
- /Users/suman/playground/vajra/scripts/verify-session-178.sh, /Users/suman/playground/vajra/scripts/demo-session-178.sh (headers, lines 1-6)
- /Users/suman/playground/vajra/.ai/ROADMAP.md (lines 707, 838-842, 849-855)
- /Users/suman/playground/vajra/.ai/AGENTS.md (lines 170-178)
- /Users/suman/playground/vajra/sessions/session-190-ground-truth.md (line 53)
- /Users/suman/playground/vajra/.ai/SESSION-BOOT.md (line 4)
- /Users/suman/playground/vajra/Cargo.toml (lines 2, 54-55)

## Handoff Delta
- `+` new: first tech-lead handoff for this session (14146 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
