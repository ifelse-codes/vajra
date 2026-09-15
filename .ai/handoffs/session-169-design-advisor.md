---
role: design-advisor
session: 169
agent: claude-code-subagent (verified: toolu_01DLHvcV4LiogWcWo8zNPNCh)
source-sha: 669a11ad0590467a9e92cee53385c99633a189e5446545396013c1519add1e37
captured: 2026-09-15T03:22:01Z
cost_usd: null
---

# Design-advisor handoff — session 169

**Brief:** For AC5, pick (b): a plan lists only work that lands before the merge, and anything that can only happen after the merge (a release) goes in its own ROADMAP row. This needs no Rust change and no new marker. It keeps the Coder gate's meaning simple: every plan step points to a real commit.

I rejected (a), a `post-merge: <row>` marker. It needs new grammar in two parsers (Rust `execution_record` and the bash script) plus the scaffold, which is too much for a ~2h session that already has four ACs. It is also weak: the author can add the ROADMAP row in the same commit that cites it, so the gate would prove only that a row exists. I rejected (c), checking at `--advance` that the step landed on main. "Landed" for a release means a tag, a crates.io publish and a brew tap. Git can see the tag and nothing else, so the check would pass on the tag alone and look stronger than it is.

What (b) cannot prove: that the ROADMAP row is ever carried out, or that it was written at all. A forgotten release is invisible, the same as any work nobody planned.

There is one real gap to close. Today `check_execution_shas` only checks lines that contain `done:`. A `pending:` line like S168 step 11 slips through closeout and blocks only at the next `--advance`. Closeout should block it.

This design departs from a record, and it should say so. DECISION-007's S133 addendum (lines 897–900) says `VAJRA_CLOSEOUT_WAIVER` "still applies at `verify-closeout.sh`" on purpose. DECISION-002 (line 57) also allows a recorded human waiver. A claimed review with no review file is a false claim, not a missing review, so refusing to waive it fits DECISION-002. A missing tech-lead that the waiver cannot excuse does go against the S133 clause.

rec 1 — Decide AC5 as (b): a plan step must land before the merge, and post-merge work (a release) gets its own ROADMAP row, not a numbered plan step.
rec 2 — In `check_execution_shas`, block at closeout any real plan step with no well-formed, existing `done:` sha, including `pending:` lines, so the Rust Coder gate's check also runs at close.
rec 3 — Make only these checks unwaivable: (i) a summary claims a verdict but the review file or fidelity handoff is missing; (ii) a CODE session has no `.ai/handoffs/session-NN-tech-lead.md`. Use plain file-exists tests, not the binary, so an unbuilt binary cannot slip past.
rec 4 — Keep this session to bash plus the scaffold. Do not change `src/coder/mod.rs`, because (b) needs no Rust change, and old prompts such as S168 step 11 are never re-graded.
rec 5 — Say in `## Design` that the unwaivable tech-lead check departs from DECISION-007's S133 addendum (lines 897–900), and append a short S169 addendum to DECISION-007 so the next reader does not trust the old clause.
rec 6 — Check whether `vajra init` pulls in `scripts/verify-closeout.sh` itself (`include_str!`) or keeps a separate template copy; if it is a copy, add a fixture that fails when the two differ.

design-significant: yes — the close gate's checks change for every Vajra project, and the unwaivable tech-lead check departs from a locked record.

Proposed `## Design` line: "Rests on DECISION-002 (no self-certification: a claimed review with no file blocks even under the waiver) and DECISION-007 (tech-lead mandatory since S135). It deliberately departs from DECISION-007's S133 clause that `VAJRA_CLOSEOUT_WAIVER` still applies at closeout: a missing tech-lead in a CODE session is no longer waivable (addendum recorded). AC5: post-merge work goes to its own ROADMAP row, not a plan step. Rejected: a `post-merge:` marker (two parsers, and a row can be added just to satisfy the check) and checking at `--advance` that it landed (git sees the tag, not the publish)."

## Handoff Delta
- `+` new: first design-advisor handoff for this session (3747 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
