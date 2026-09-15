# Session 169 — close-gate-tightening: a session cannot close on made-up evidence

> **Status:** APPROVED — founder approval token "approved", given in chat on 2026-09-15
> ("start session 169 , all approved").

## Type
- **CODE**. Max 2 assumptions · 2 retries · ~2h · 1 story · new chat · approval token before any commit.

## Where this came from
- S166 closed self-certified: no tech-lead, no fidelity handoff, and a summary claiming a review that did not exist. Its retroactive cold review (`sessions/session-166-review.md`, REJECT) named the holes; S167 and S168 carried them here (ROADMAP row S169).
- S168 met the same gap from the other side: `vajra next --advance` needed `VAJRA_SKIP_CODER_GATE=1` because a release step can only land after the merge.

## Goal
`scripts/verify-closeout.sh` refuses to close a session whose recorded evidence is made up: prose in a `done:` sha, a sha that does not exist, a claimed review with no review file, or no tech-lead crew decision.

## Deliverables
- `scripts/verify-closeout.sh`: `check_execution_shas` word boundary + 7–40 hex length + `git cat-file -e <sha>^{commit}`; a claimed-verdict-with-no-review check; a missing-tech-lead check.
- The scaffolded close gate (`vajra init`) carries the same checks.
- `scripts/verify-session-169.sh` (exits 0; behavioral fixtures).
- `sessions/session-169-summary.md` + exactly 3 ranked next candidates.

## Acceptance (what must be answered — testable, EARS-style)
1. WHEN a prompt's `## Execution` records `done: defaced prose` (or a 6-char or 41-char hex) THEN `verify-closeout.sh` BLOCKS naming the line.
2. WHEN a `done:` sha is well-formed but no such commit exists THEN it BLOCKS naming the sha.
3. WHEN a summary claims a fidelity-reviewer verdict but `sessions/session-NN-review.md` / the fidelity handoff is absent THEN it BLOCKS, even under `VAJRA_CLOSEOUT_WAIVER`.
4. WHEN a CODE session has no `.ai/handoffs/session-NN-tech-lead.md` THEN closeout BLOCKS (today the gap shows only at the next `--advance`).
5. The session decides on the record how a plan step that can only land after the merge (a release) is recorded without a skip env var.

## Design (the Architect gate — record the decision, cite the ADR/DECISION it rests on)
- design-significant: yes — the close gate's checks change for every Vajra project, and the unwaivable tech-lead check departs from a locked record.
- Rests on DECISION-002 (no self-certification: a claimed review with no file blocks even under the waiver) and DECISION-007 (tech-lead mandatory since S135). It deliberately departs from DECISION-007's S133 clause that `VAJRA_CLOSEOUT_WAIVER` still applies at closeout: a missing tech-lead in a CODE session is no longer waivable (S169 addendum recorded in DECISION-007).
- AC5 decision (design-advisor rec 1): a numbered plan step must land before the merge; post-merge work (a release) goes in its own ROADMAP row, never a plan step. `check_execution_shas` blocks at close any real plan step with no existing `done:` sha, `pending:` included. Rejected: a `post-merge:` marker (two parsers; a row can be added just to satisfy it) and an `--advance` "landed on main" check (git sees the tag, not the publish). Limit: nothing proves the ROADMAP row is ever carried out.

## Plan (ordered steps — cite the acceptance criteria each step covers, e.g. `covers: 1, 3`)
1. Dispatch tech-lead, then design-advisor; record the AC5 decision. covers: 5
2. Tighten `check_execution_shas` (format + existence) with fixtures. covers: 1, 2
3. Add the claimed-review and missing-tech-lead checks with fixtures. covers: 3, 4
4. Carry the checks into the scaffolded close gate; write `verify-session-169.sh`; cold review; close. covers: 1, 2, 3, 4, 5

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: 07c2f2d
  note: tech-lead handoff landed in 14e6cc8; the design-advisor handoff + the AC5 decision (DECISION-007 S169 addendum) in 07c2f2d.
- step 2 — done: 14e6cc8
- step 3 — done: 14e6cc8

## Guardrails
- Slice to ONE story. Own the `.ai/` spine — no second store, no unapproved 8th command.
- Old prompts are never re-graded: the new checks bind on the session being closed.
- Darshan every human reply · Varta against the live `.ai/`.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` closeout checks: claimed review with no review file · missing tech-lead crew decision
- `~` `check_execution_shas` — word boundary, 7–40 hex length, commit existence
- `-` closing on a prose or made-up `done:` sha
