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
- step 4 — done: 59e1686
  note: scaffold carry 07c2f2d · verify-session-169.sh b9a75ed · demo aab3f30 + its VAJRA_BIN export 0b05694 · cold review pass 1 (REJECT, 7ede30b) fixed in 59e1686. The review of record, summary and closeout land in the closeout commit; sessions/ is outside the attested diff.

## Advice (every recorded recommendation, answered)
- tech-lead rec 1 — obeyed: 14e6cc8
  note: check_claimed_evidence has no waiver path; the tech-lead file is a plain `-s` test (no binary); the binary-backed checks keep their waiver unchanged.
- tech-lead rec 2 — refused: the match is lowercase-only `[0-9a-f]{7,40}`, not `[0-9a-fA-F]` — git prints lowercase shas and the S166 check it replaces was lowercase too; the word boundary, the 7–40 length and `git cat-file -e` are built as the rec says (14e6cc8), and each failing line and sha is named in the log.
- tech-lead rec 3 — refused: the design-advisor, the role that owns AC5, ruled against a `post-merge:` marker — it needs grammar in two parsers, and a ROADMAP row can be added in the same commit that cites it. Post-merge work goes in its own ROADMAP row instead (DECISION-007 S169 addendum, 07c2f2d).
- tech-lead rec 4 — obeyed: b9a75ed
  note: every verify case matches the exact block line (`grep -F`), beside pass controls; the fidelity-reviewer is asked to probe `done: defaced prose`.
- tech-lead rec 5 — obeyed: 07c2f2d
  note: `vajra init` embeds a separate copy (`scripts/verify-closeout-scaffold.sh` via include_str!), carried in its own commit.
- design-advisor rec 1 — obeyed: 07c2f2d
- design-advisor rec 2 — obeyed: 14e6cc8
- design-advisor rec 3 — obeyed: 14e6cc8
- design-advisor rec 4 — obeyed: 07c2f2d
  note: no change to src/coder/mod.rs; bash + the scaffold copy only.
- design-advisor rec 5 — obeyed: 07c2f2d
- design-advisor rec 6 — obeyed: b9a75ed
  note: verify-session-169.sh runs every case on both gates, so a check carried into one copy but not the other goes red.
- fidelity-reviewer rec 1 — obeyed: 59e1686
  note: both gates resolve the summary and handoffs zero-padded (`session-01`); the review file is read unpadded only when that file exists (check_fidelity_review still reads it that way). Fixtures `pad a` (session 01 passes) and `pad b` (session 04 blocks, named) on both gates.
- fidelity-reviewer rec 2 — obeyed: 59e1686
  note: a claim is any `verdict` line whose own line or the next names accept/reject, any case; fixtures `dodge a` (`Verdict — accept`) and `dodge b` (heading, REJECT on the next line) block on both gates.
- fidelity-reviewer rec 3 — deferred: .ai/ROADMAP.md
  reason: rec 3 asks that a `done:` sha be reachable from the session branch and not from the merge-base. That rule must still hold after the branch merges and is pruned (the Releaser's NoBranch blind spot), which is a design question of its own, not a fix to this gate. When: S171 (ROADMAP row S171).
- fidelity-reviewer rec 4 — obeyed: 59e1686
  note: the stale S166 BLOCK/FAIL lines are replaced. A byte-identity check was not added: the two copies differ on purpose (the scaffold has no cargo-fmt, demo-marker or release checks); verify runs every S169 case on both instead.
- fidelity-reviewer rec 5 — deferred: sessions/session-169-summary.md
  reason: the summary with exactly 3 ranked candidates is written after the review of record, in this session's closeout commit (sessions/ is outside the attested diff). When: S169 closeout.
- fidelity-reviewer rec 7 — deferred: .ai/ROADMAP.md
  reason: a no-claim fixture (`Verdict: pending` + an "acceptance criteria" line) changes the reviewed verify script after the ACCEPT of record; no close in flight is exposed — S170 is a ground-truth session, which writes no summary. When: S171 (ROADMAP row S171).
- fidelity-reviewer rec 8 — deferred: .ai/ROADMAP.md
  reason: a word-boundary match plus a `review …: ACCEPT` shape changes the gate after the ACCEPT of record, and needs rec 7's no-claim fixture beside it so an over-match shows red. When: S171 (ROADMAP row S171).
- fidelity-reviewer rec 9 — deferred: .ai/ROADMAP.md
  reason: padding `check_fidelity_review` and `check_review_attestation` touches two checks outside this prompt's acceptance criteria and the attestation hash path; it belongs with rec 8 in one gate change. When: S171 (ROADMAP row S171).
- fidelity-reviewer rec 10 — deferred: .ai/ROADMAP.md
  reason: the comment and DECISION-007 wording should describe the claim match S171 ships (recs 7–8), not the one it replaces. When: S171 (ROADMAP row S171).
- fidelity-reviewer rec 6 — obeyed: 7ede30b
  note: DECISION-007's S169 addendum now lists what stays open — waivable NO-DONE and made-up shas, `1)`/indented plans invisible to the parser, and existence-not-ownership (carried to S171).

## Guardrails
- Slice to ONE story. Own the `.ai/` spine — no second store, no unapproved 8th command.
- Old prompts are never re-graded: the new checks bind on the session being closed.
- Darshan every human reply · Varta against the live `.ai/`.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` closeout checks: claimed review with no review file · missing tech-lead crew decision
- `~` `check_execution_shas` — word boundary, 7–40 hex length, commit existence
- `-` closing on a prose or made-up `done:` sha
