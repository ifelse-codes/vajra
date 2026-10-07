---
role: tech-lead
session: 189
agent: claude-code-subagent (verified: toolu_01ECModUwXKpVUXRUFX9sNJM; text-sha: a15955d144afcf7cecc008129e656cabc26d7a0989a9c89e82d2cf1cc50e3f2b)
source-sha: f2fe4fc9a6bc664dbb521c4dc448e5db2447de76ea71dba4e5ee1fe910f6575e
captured: 2026-10-07T02:05:00Z
cost_usd: null
---

# Tech-lead handoff — session 189

Tech-lead brief: Session 189 (CODE, one story). An interactive `vajra claude` run's receipt headline cost must be Claude Code's own figure. If the tool gives none, the headline says so plainly. The price-list figure stays a labelled `[estimate]` and is never the headline. No new price rows (F67).

Sources read:
- /Users/suman/playground/vajra/prompts/189-task-receipt-tool-cost.md
- /Users/suman/playground/vajra/.ai/handoffs/session-188-tech-lead.md (for the format)
- a count of `total_cost_usd` in src/: src/meter/mod.rs 25, src/cli/launch.rs 3, src/dogfood/mod.rs 8, src/fleet/mod.rs 1
- the two ADRs that exist: /Users/suman/playground/vajra/docs/adr/0003-settings-injector-and-compression-heuristics.md and /Users/suman/playground/vajra/docs/adr/0004-meter-receipt-design.md

How I sized this: S185–S188 each ran a crew of 3 at about 4.0M tokens, which is the line the founder has accepted. This prompt is different in one way: deliverable 1 is an unknown fact, and the prompt itself says "researcher first". The whole design depends on where Claude Code 2.1.x exposes an interactive session's cost, so the researcher is required this time and the design-advisor is trimmed to stay near 4.0M.

Required crew: researcher 0.7M + design-advisor 0.9M + fidelity-reviewer 1.8M + release-coordinator 0.6M = about 4.0M.

Each budget is a written instruction I am trusting the role to follow. Vajra cannot stop a role partway through a run, so these are not hard limits.

crew researcher — required — budget: 700000 tokens — The prompt's deliverable 1 is an open fact the design depends on: which surface of Claude Code 2.1.x carries an interactive session's cost. Candidates are the status-line JSON's cost.total_cost_usd, a hook input (SessionEnd or Stop), and the transcript JSONL. For each, find out when it is written, whether it holds the whole session's total, and whether Vajra can read it through its own injected --settings without changing the user's status line. Read only Claude Code's docs or changelog for status line, hooks and transcript, plus one recorded transcript already on disk (no new paid run). Do not read the repo beyond src/meter/mod.rs's input types.
crew requirements-analyst — deferred-budget — budget: 400000 tokens — The 4 deliverables and 5 ACs restate the founder's own F67 ask (S176/S177: the permanent fix, not new rows). A ~0.4M pass would only restate them and push a ~4.0M crew to ~4.4M. S134: three broad dispatches used 19.2M and hit the monthly limit.
crew design-advisor — required — budget: 900000 tokens — Mandatory: the prompt says design-significant: yes. Work only from the researcher's finding plus ADR-0004, ADR-0003, src/meter/mod.rs and src/cli/launch.rs. Name: (a) which record this extends, ADR-0004 or the S77/S78 decision, or whether the --settings injector change means an ADR-0003 addendum; (b) the order the receipt picks a source in: -p result stream first, then the interactive tool figure, then "no cost from Claude Code for this run"; (c) where any captured figure is kept so it is never committed; (d) what happens when a session is resumed or the capture is partial.
crew plan-advisor — deferred-budget — budget: 400000 tokens — There is one story, and the Planner gate already checks `covers: N`. rec 1 gives the one order that matters. ~0.4M more on a ~4.0M crew is money the account cannot spare.
crew implementation-advisor — deferred-budget — budget: 1000000 tokens — It would help on the meter's source-choice logic, but it would read meter, launch, the receipt tests and the injector, about 1.0M, which takes the crew to ~5.0M. Standing in for it: the design-advisor's shape, plus the real-run AC1–AC4 checks in recs 3–5.
crew qa-specialist — deferred-budget — budget: 800000 tokens — AC5 already requires scripts/verify-session-189.sh to use real runs, not source greps, and to be red at the start commit. The author writes it and the fidelity-reviewer re-runs it. A ~0.8M QA dispatch would push the crew to ~4.8M.
crew demo-producer — deferred-budget — budget: 500000 tokens — The founder sees the change on rudra's next `vajra claude` receipt (deliverable 4). The only user-facing change is one headline line, which the fidelity-reviewer reads. ~0.5M would take the crew to ~4.5M.
crew fidelity-reviewer — required — budget: 1800000 tokens — Mandatory at close since S131: one cold review. It reads the prompt and the branch diff. It re-runs `bash scripts/verify-session-189.sh` at 8e52d29 (main when the branch was cut) and at the tip, and re-runs the full `cargo test`. It checks that no price row was added (AC3, deliverable 3) and that -p runs are unchanged (AC4).
crew release-coordinator — required — budget: 600000 tokens — One release-coordinator judges every `obeyed:` answer in a single pass (founder rule). Advisors cannot grade their own recs. It reads only `## Advice` and each commit cited there.

rec 1 — Do not write a line of the design or the Plan until the researcher's finding is recorded. If the finding is "Claude Code gives an interactive session no total that Vajra can read", ship the honest branch (AC2: "no cost from Claude Code for this run" plus a labelled `[estimate]`) as the whole fix and tell the founder plainly. Do not invent a capture path.
Why: the prompt says "where the tool gives none, the receipt says so". A made-up capture would be the price-list guess under a new name.

rec 2 — Do not take over the user's status line. If the figure comes through the status line, Vajra must not replace the user's own statusLine setting. Prefer a hook input, or a file Claude Code writes itself. If the status line is the only surface, say so in the design and get the founder's yes before changing any user-visible setting.
Why: the prompt says the status line is the user's, and S182's add-only settings rule applies.

rec 3 — Make AC1 run from a recorded interactive-run fixture with a known tool figure, kept small and with no secrets, under tests/ or the verify script. It must be red at 8e52d29 because the headline shows the price-list number. Do not use a paid live run unless the founder says yes first (cheapest model, throwaway folder).
Why: AC1 and the guardrails. A fixture keeps the check free and repeatable.

rec 4 — AC3 must use a made-up model (claude-opus-9) with no price row and no tool figure. The headline must say no cost is known. Also prove the price-list file has no new rows by diffing it against 8e52d29 in the verify script. A source grep does not count.
Why: deliverable 3. "No new rows" is the founder's own rule and the easiest thing to break quietly.

rec 5 — Keep AC4 as a regression check: a -p result-stream fixture whose headline is unchanged from the start commit, in the same verify script.
Why: S77/S78's working path must not regress while the interactive path changes.

rec 6 — Dispatch order: researcher, then design-advisor, then build, then one fidelity-reviewer on the finished branch (on a REJECT, fix and run one fresh pass, not a loop), then one release-coordinator after `## Advice` answers every rec. Write reasoned skip lines in the prompt for the deferred roles, carrying the budget reasons above.
Why: S168's review loops nearly made the founder quit, and one judge for all `obeyed:` answers is his rule.

## Handoff Delta
- `+` new: first tech-lead handoff for this session (7336 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
