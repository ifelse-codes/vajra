# Session 195 — Ground Truth (no code): the every-5th review of S191–S194

> **Status:** DRAFT — written by the S194 agent. S195 is review-only by the every-5th rule
> (`scripts/lib-ground-truth.sh`; S190 was the last), not a pick. The founder approves it with
> `vajra approve 195` in his own terminal; the gate reads the approval record.

## Type
session_type: GROUND_TRUTH
- **NO-CODE.** No Vajra source edits · no commits except the report on a `-closeout` branch · no PRs besides it.
- A finding is written down with a severity and a proposed fix, not fixed. The founder signs off before code resumes.

## Goal
1. **Audits** (the live list: `CONSTRAINTS.yaml#ground_truth.required_audits`), one or two lines each,
   🟢/🟡/🔴, `delivery_progress` first: what reached a user since S190 (S191 four small fixes, S192 the receipt
   proven live, S193 F117 the receipt shows only Claude Code's figure, S194 F121 the exit box shows the close check
   + F123 the merge guard + F120 the transcript refusal), and is Vajra on track?
2. **The Haiku question.** rudra S20 ran on Haiku 4.5 (founder's deliberate test): every Vajra step that is only an
   instruction was skipped (no tech-lead, no reviewer, a self-written "independent" ACCEPT), and only what Vajra
   blocks held. S16–S19 on Opus followed the steps. What does that say about Vajra's promise for a user on a cheap
   model — and is the answer more gates, fewer steps, or saying which models Vajra supports?
3. **The S195 checklist** — each with a pick: fix (which session), keep in backlog (why), or drop (founder's call):
   - the known bugs (ROADMAP backlog "🐞 KNOWN BUGS — TO FIX"): F116 (the approval record left out of git), F118
     (`--advance` keeps the old session's text; hit again S194), F119 (✗ design with `design-significant: no`; seen
     again S194), **F125** (the review-only guard turns off on any `-closeout` branch the agent names)
   - F123's remaining routes (fast-forward, `reset --hard`, `branch -f`, `update-ref`, `git merge --no-verify`)
   - F121's named limits (shows, does not stop; only at exit; the agent can write the result file)
   - Vajra's own `.ai/verify/closeout/latest` is a real folder, not a link
   - kept from S190: the rest of N7; F97's opt-out key; `tests/gt_cadence_shared.rs`'s loose assertion; S188's
     named gaps; N10; N11; S192 review rec 6; verify-131's two stale checks
   - the `/clear` receipt gap and a fork's own share (founder 2026-10-09: named, not closed)
4. **Point at the user:** the founder's order (2026-10-09): rudra sessions until he is confident, then cut the cost
   (boot diet F4, KNOWLEDGE trim). Does S191–S194's evidence say he can be confident yet?

Output: `sessions/session-195-ground-truth.md`. New findings listed with a severity for S196.

## Deliverables
1. `sessions/session-195-ground-truth.md` with every audit in `CONSTRAINTS.yaml#ground_truth.required_audits`,
   🟢/🟡/🔴 with live evidence, `delivery_progress` first.
2. An answer to the Haiku question with evidence.
3. A pick for every S195 checklist item (fix → named session, keep → why, drop → founder's call).
4. The next step toward a stranger getting value, and new findings with a severity for S196.

## Acceptance
1. The report has one row per required audit with a 🟢/🟡/🔴 and live evidence (commands run, output pasted).
2. The Haiku question is answered from rudra S20's own evidence (S194 summary), not from memory.
3. Every S195 checklist item has a pick and a one-line reason.
4. The founder signs the report off before code resumes.

## Carried in
- **From S194:** F121, F123, F120 fixed; rudra gets them only after `vajra init --sync-fleet` there. F125 parked.
  F122 (no helpers ran) is visible now through F121's `failed:` names, not prevented.
- **Parked by the founder:** non-Claude tools (F91, F94, F95), release/publish.
- Founder decisions to respect: no per-claim `obeyed:` judge (2026-10-03); Vajra's close does not run
  `cargo test` (2026-10-04); no new policing of Vajra's own paperwork (2026-09-15); read the tool's own cost, never
  grow the price list.

## Design
design-significant: no
- A review-only session picks designs; it builds none. Any design it picks names its record (ADR-0004,
  DECISION-007, DECISION-011) in the report.

## Plan
1. Run every required audit live and paste the output into `sessions/session-195-ground-truth.md`, `delivery_progress` first; the four live-evidence audits (stranger-check, scaffold-drift, `--stations`, `--dogfood-age`) before the rest. covers: 1
2. Answer the Haiku question from rudra S20's own evidence as recorded in `sessions/session-194-summary.md` (tool counts, the RED tally, F122), with the design-advisor's view on (a)–(d). covers: 2
3. Give every S195 checklist item a pick (fix → session, keep → why, drop/retire → reason), with the design-advisor's designs for F125, F123, F121 and N10. covers: 3
4. Put the report to the founder; record his sign-off and his A/B/C pick in the report before any code resumes. covers: 4

## Execution
- step 1 — done: 026323a
- step 2 — done: 026323a
- step 3 — done: 026323a
- step 4 — done: 1c35ab7

## Delta
- `+` `sessions/session-195-ground-truth.md`, `sessions/session-195-review.md`, `sessions/session-195-summary.md`
- `~` the S195 checklist items: each picked (fix / keep / drop)
- `+` `prompts/196-task-<slug>.md`

## Advice
Roles dispatched: `tech-lead` (mandatory, first), `design-advisor` (required; gate-mandated past S133, one narrow pass
on the design-type picks), `fidelity-reviewer` (gate-mandated past S131, one cold pass on the report),
`release-coordinator` (required; the one judge of every `obeyed:` answer, and stranger_check / Goal 4).

researcher: skipped — the tech-lead deferred it on budget: the Haiku evidence is already in the S194 summary (210/210 Haiku replies, 0 Agent calls, RED 17/5); a broad model-comparison brief is kept for the rudra S21 Opus-vs-Haiku comparison (~250k).
requirements-analyst: skipped — the tech-lead deferred it on budget: the prompt already lists 13 audits, the checklist and 4 acceptance lines; restating them buys no artifact (~100k).
plan-advisor: skipped — the tech-lead deferred it on budget: the plan is "fill one report", no multi-step build to sequence (~100k).
implementation-advisor: skipped — the tech-lead deferred it on budget: no source edits are allowed in a review-only session (~120k).
qa-specialist: skipped — the tech-lead deferred it on budget: no verify-195 script; the evidence is live command output pasted into the report (~100k).
demo-producer: skipped — the tech-lead deferred it on budget: a review-only session produces no demo script (~80k).

**tech-lead** (`.ai/handoffs/session-195-tech-lead.md`):
- tech-lead rec 1 — obeyed: 026323a (Goal 2 quotes the S194 summary's tool counts, RED 17/5 and F122's self-written ACCEPT; its options table has a "Class" column separating a user's-project gate from policing Vajra's paperwork; (c) weighed and picked first)
- tech-lead rec 2 — obeyed: 026323a (stranger-check 21/0, scaffold-drift 19/3, `--stations` 191–195, `--dogfood-age` pasted as run; the 22 `WAIVED` matches in close logs since 2026-10-07 read and named as quoted text, not waived checks)
- tech-lead rec 3 — obeyed: 026323a (one design-advisor pass, dispatched after the draft picks, given only F125, F123, F121, the Haiku options and N10; its 5 recs folded into the report, handoff recorded in the same commit)
- tech-lead rec 4 — obeyed: 1ac59b6 (the fidelity-reviewer dispatched after the report commit 026323a, fed the prompt's Goal/Deliverables/Acceptance and that report only, told to ignore Plan/Advice; its verdict and recs in `sessions/session-195-review.md`)
- tech-lead rec 5 — obeyed: 7453cdc (one release-coordinator pass judged every `obeyed:` line, judge lines unfenced as `obeyed-check … implemented:` in `.ai/handoffs/session-195-release-coordinator.md`; its 2 mismatches fixed, then the same judge re-judged — no per-claim judges)
- tech-lead rec 6 — obeyed: 7453cdc (all three required roles now have handoffs recorded by `vajra next --role --from` a scratch file holding the hand-back text, never a `.output` transcript — design-advisor 026323a, fidelity-reviewer 1ac59b6, release-coordinator 7453cdc, each with a `verified: toolu_…; text-sha` header) and 026323a (the report's header and N16 say this session ran on `session-195-closeout` — the F125 opening — named, not closed)

**design-advisor** (`.ai/handoffs/session-195-design-advisor.md`):
- design-advisor rec 1 — obeyed: 026323a (checklist row 1: F125's pick carries the design — the `-closeout` opening opens only on a founder's `vajra approve NN --close` record, amends DECISION-011, the fix session is design-significant: yes; the wider no-`session-NN` hole filed as N17)
- design-advisor rec 2 — obeyed: 026323a (checklist row 5: F123's routes kept named with the reflog, pre-push and the two rejected closings as the reason; no record change)
- design-advisor rec 3 — obeyed: 026323a (checklist row 6: F121 kept named; live proof first, then a Stop hook showing the newest unseen result via `systemMessage`, amending ADR-0004)
- design-advisor rec 4 — obeyed: 026323a (Goal 2: (c) as a README "tested with" fact in the founder's words, the launch-time model check dropped with its two reasons and the first draft's correction named; (d) next in its own design session; (b) as a standing GT question; (a) rejected)
- design-advisor rec 5 — obeyed: 026323a (checklist row 12: N10 → keep check 6, a `# source-claim: <why>` marker on the line, added to the 3 lines, in the known-bug session; "no record covers check 6 yet")

**fidelity-reviewer** (`.ai/handoffs/session-195-fidelity-reviewer.md`) — one cold pass, ACCEPT 6 SHIPPED / 1 PARTIAL / 1 pending:
- fidelity-reviewer rec 1 — obeyed: 1ac59b6 (knowledge_staleness, state_drift, roadmap_alignment, cost_review, dogfood_check, constitution_review, constraint_violation_review each now show the command and its raw output or tally line)
- fidelity-reviewer rec 2 — obeyed: 1ac59b6 (stranger_check recoloured 🔴: the script's 21/0 GREEN kept beside the reach result 0 stars / 0 forks / 0 issues / crates.io 0.1.0, 19 downloads)
- fidelity-reviewer rec 3 — obeyed: 1ac59b6 (Goal 2: blocks stop, the close check detects and stops nothing, steps need a model that follows them; option (a) re-argued on detection vs prevention)
- fidelity-reviewer rec 4 — obeyed: 1ac59b6 (checklist rows 13 and 15 read "Propose drop (retire, superseded) — founder's call")
- fidelity-reviewer rec 5 — obeyed: 1ac59b6 ("the known-bug session" = S196 if B, else S197, stated above the checklist; F125's row names `vajra approve NN --close` as a new founder command)
- fidelity-reviewer rec 6 — obeyed: 1ac59b6 (dogfood_staleness answers the STATE.md question — STATE keeps no dogfood-date entry; dogfood_check backs its claim with the cost rows) and 1c35ab7 (the meta-check's leftover "best dogfood cycle since S171" replaced with "a cycle with four real rudra runs"; the report and review now say the first fix missed that copy)

**release-coordinator** (`.ai/handoffs/session-195-release-coordinator.md`) — the one judge; pass 1: 14 implemented, 2 mismatch (both fixed above):
- release-coordinator rec 1 — obeyed: 1c35ab7 (the "best dogfood cycle" copy in the meta-check replaced) and 7453cdc (its handoff recorded, so tech-lead rec 6 is answered again citing it)
- release-coordinator rec 2 — obeyed: 1c35ab7 (Goal 4: "matches Claude Code's own `cost-state` figure (not the bill) on 4 rudra runs, one project, one machine; `/clear` and a fork's own share still named")
- release-coordinator rec 3 — obeyed: 1c35ab7 ("the same count S185 recorded (S190 gave none)") and db9b07f (STATE's release line now says "none of S167–S194", with the S195 re-check numbers; `cargo publish` left as the founder's parked call)
- release-coordinator rec 4 — deferred: sessions/session-195-summary.md
  why: the ship order is written as the summary's "Ship steps" (db9b07f) and followed from here — the stamp last, the full `verify-closeout.sh` before the push, the PR; the merge, sync and prune are the founder's after this session (SESSION-BOOT's Next Session, 3230561), checked again at S196's boot. Untracked `first-mate.html`, `vajra-cto-audit-*.html`, `.claude/launch.json`, the S137 scatter file are left out.
