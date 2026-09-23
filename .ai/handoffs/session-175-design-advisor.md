---
role: design-advisor
session: 175
agent: claude-code-subagent (verified: toolu_01XHm2bQkqShR6GqBSvN4Yhi)
source-sha: df10649c438b6073c7c1529776f5f7a367374d206c7af3f4debf18574c3386f2
captured: 2026-09-23T05:36:09Z
cost_usd: null
---

# Design-advisor handoff — session 175

## Findings brief — design review, session 175

**Scope reviewed:** `prompts/175-task-keep-testing.md`'s `## Design` section; `docs/decisions/DECISION-007-agent-fleet.md`'s "S175 addendum" (lines 1557–1623, both halves); the actual diffs in `scripts/hook-publish-guard.sh`, `scripts/hook-session-start.sh`, `scripts/verify-closeout.sh`, `scripts/hook-pre-bash.sh`, and `.ai/CONSTRAINTS.yaml`.

### (a) `design-significant: yes` — correct call

Both fixes change the *shape* of enforcement/advisory guard behavior, not just a bug in one place:

1. The ground-truth cadence changes from a single hardcoded rule to a **config-overridable rule with a fallback**, and that new decision surface (`.ai/CONSTRAINTS.yaml#ground_truth_next_session`) is now read identically by six independent scripts (`hook-session-start.sh`, `hook-pre-bash.sh`, `hook-pre-write.sh`, `hook-prompt-submit.sh`, `hook-stop.sh`, `verify-closeout.sh`) — verified directly in `hook-session-start.sh` (lines 100–114) and `verify-closeout.sh` (lines 50–61); same `GT_NEXT`/exact-match/fallback-to-`N%5` idiom confirmed in `hook-pre-bash.sh` too. That's a new interface (a config key with defined semantics), which per the design-advisor's own marker rule (`yes` = new/changed interface, new module, or deviation from a locked record) is squarely `yes`.
2. The publish-guard fix narrows a previously-blanket bypass (`VAJRA_ALLOW_PUBLISH=1`) by carving out an exception class (`IS_MERGE`) that no env var can lift — verified in `hook-publish-guard.sh` lines 98–213. This is a deviation-correction against the locked intent of F55/S173 ("merging stays with the human"), which the addendum itself frames as resolving a conflict between two enforcement mechanisms.

`no` (pure fix) would undersell this: a pure fix repairs behavior against its own stated contract without touching the contract's shape. Here the *shape* of two guard mechanisms changed (new config-driven decision point; a bypass's scope redefined). `yes` is right.

### (b) DECISION-007 S175 addendum — real, exists, apt citation, not a mismatch

- The file exists at `docs/decisions/DECISION-007-agent-fleet.md`, the addendum exists at line 1557 ("S175 addendum — the ground-truth cadence becomes config; the founder moves it to S180"), and it runs to line 1623 — read in full, not just the heading.
- It genuinely covers **both halves** the prompt's Design section claims: the cadence-config fix (lines 1557–1596) and the merge-bypass fix (lines 1598–1623).
- It states real alternatives not taken, even without a formally labeled "Alternatives considered" header (unlike the S113/S121/S123/S126 addenda's convention — a minor stylistic drift, not a substance gap): a schedule/resumption rule was considered and explicitly not built; a shared `lib-ground-truth.sh` was considered and explicitly not extracted; touching the `vajra init` scaffold template was considered and explicitly rejected.
- Independently verified the code matches the addendum's factual claims, not just its prose: the six-site fallback logic, the `IS_MERGE` carve-out excluding only `gh pr merge`/`glab mr merge` from the `VAJRA_ALLOW_PUBLISH=1` bypass while leaving `git push`/`gh pr create` untouched, and the live-set config value `ground_truth_next_session: 180` in `.ai/CONSTRAINTS.yaml`.
- Verdict: not made up, not a mismatch — a real, substantive, self-critical citation.

### (c) Concerns about the design itself

rec 1 — Treat the six-copies-no-shared-lib pattern as a tracked debt item with an explicit trigger, not just a footnote. The addendum already discloses this, but nothing in the repo currently tracks the trigger. Six independent bash copies of a ~6-line check is real drift risk: a future edit to the rule requires remembering all six sites, and nothing enforces they stay identical. Recommend a one-line backlog/`.ai/KNOWLEDGE.md` entry naming "extraction pending — trigger at site 7" so the addendum's own disclosed threshold survives past this session's memory.

rec 2 — Close the "single global integer, not a schedule" gap operationally, not just document it. `IS_GT` fires only when `session == GT_NEXT` exactly. Once S180 passes, `ground_truth_next_session: 180` stays in `.ai/CONSTRAINTS.yaml` forever unless someone edits it — meaning no session after S180 will ever again be flagged ground truth, not even by reverting to the every-5th default, until a human remembers to either delete the key or advance it. This is a live latent gap with a concrete consequence: silent, permanent disabling of the every-5th cadence past S180 if nobody remembers to act. Recommend recording a trip-wire — e.g., a boot-time note once `session > ground_truth_next_session` that says "this key is stale, no GT session is scheduled" — so the gap is visible rather than silently inert.

rec 3 — Confirm `scripts/verify-closeout-scaffold.sh` staying untouched is revisited before the next `vajra init` consumer hits it. Correctly out of scope for S175 specifically (pre-existing drift, not created here), but a fresh scaffolded project inherits an even-more-stale closeout template with each session that patches the live gate and not the scaffold. Not urgent, but worth a named owner/session rather than letting the gap compound silently across S154, S175, and whatever comes next.

### Bottom line

`design-significant: yes` is correct, the DECISION-007 S175 addendum is a real and apt citation whose factual claims were independently verified against the actual diff (not just its own prose), and the design is sound with three disclosed-but-not-fully-fenced risks worth tracking forward (shared-lib debt, the post-S180 dead-cadence gap, and scaffold-template drift).

Files:
- /Users/suman/playground/vajra/prompts/175-task-keep-testing.md
- /Users/suman/playground/vajra/docs/decisions/DECISION-007-agent-fleet.md
- /Users/suman/playground/vajra/scripts/hook-publish-guard.sh
- /Users/suman/playground/vajra/scripts/hook-session-start.sh
- /Users/suman/playground/vajra/scripts/verify-closeout.sh
- /Users/suman/playground/vajra/scripts/hook-pre-bash.sh
- /Users/suman/playground/vajra/.ai/CONSTRAINTS.yaml

## Handoff Delta
- `+` new: first design-advisor handoff for this session (6168 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
