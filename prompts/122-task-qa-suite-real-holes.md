# Session 122 — CODE: close the four real holes the live QA run found

> **Status:** APPROVED (founder, at the S121 post-close live run).
> **Supersedes** the original S122 brief (`prompts/122-task-qa-specialist-dispatch.md`, deleted):
> its whole goal — prove `subagent_type: "qa-specialist"` dispatches by name — **was already
> achieved at the S121 close**, when the harness registered the role inside its own creating
> session. Evidence: `sessions/session-121-artifacts/qa-specialist-live-run.md`.
> **Founder directive in force (S118):** `README.md` / `VISION.md` claims are the **target spec**.
> Do NOT soften them. No release until reality meets them.

## Type
CODE — one story, ≤3 files per atomic commit, ~2h cap, new chat.
Branch: `session-122-qa-suite-real-holes`.

## Why this session

The S121 suite went 17/17 green and its cold review said ACCEPT. Then the QA role ran against it
and found **four defects in the guardrails themselves** — including one that would make the suite
fail for a reason its own error message cannot explain, and one where the check that *looks* like it
stops a write-tool leak does not.

This is the first time in this repo's history that a real finding came from an agent running the
project's own verification rather than from a cold read of a diff. The findings are the payload.

**Carry this forward and do not soften it:** none of the four needed Bash. They came from careful
independent READING. The executor thesis S121 shipped — *an executor cannot fake a pass* — is
**still unproven**; what got stronger is the independence thesis. Say so plainly wherever the QA
role is described.

## Plan (ordered — cite the acceptance criteria each step covers)

1. **Anchor the read-only guard.** `scripts/verify-session-121.sh#_scaffolds_four_roles` asserts
   `grep -q "^tools: Read, Grep, Glob"` — a PREFIX match, so a role leaking `Write`/`Edit`
   (`tools: Read, Grep, Glob, Write`) passes it. Fix the assertion to reject any write/exec tool on
   a non-allowlisted role, and add a **falsifiability fixture**: a synthetic agent file carrying the
   leak must turn the check RED. `covers: 1`
2. **Defuse the `one_source_of_role_text` booby-trap.** Its exclusion list omits `.ai/handoffs/`,
   which is exactly where this role's governed handoff lands — a QA report quoting the probe
   sentence flips the check RED with an unexplaining message. Exclude generated/handoff locations,
   and make the failure message name the carriers it found. `covers: 2`
3. **Kill the near-tautology.** `fleet::tests::render_subagent_definition_is_correct_for_every_registered_role`
   asserts `def.contains(role.system_prompt)` — the render checked against the field it renders
   from; an empty `system_prompt` satisfies `contains("")`. Assert non-empty, substantive content
   per role instead. `covers: 3`
4. **Make the check-class tally honest about nesting.** `s113-counter-still-green` is one tally slot
   hiding 14 checks, and `verify-session-113.sh` carries its OWN hollow banner grep — the true
   hollow count in the S121 run was **2, not 1**. Either propagate nested tallies or label nested
   suites explicitly as uncounted. Whichever is chosen, the printed line must stop implying a
   complete count. `covers: 4`
5. `scripts/verify-session-122.sh` + `scripts/demo-session-122.sh`, each classifying its own checks;
   every fix above carries a falsifiability fixture (the check must be shown going RED when the
   defect is present). Re-run the count-agnostic regressions. `covers: 5`
6. Cold `fidelity-reviewer` pass by name; summary with the per-requirement fidelity map + the
   fakest green. `covers: 6`

## Acceptance criteria

1. The read-only guard rejects a `Write`/`Edit` leak on a non-allowlisted role, proven by a fixture
   that turns it RED.
2. `one_source_of_role_text` cannot be tripped by a governed handoff quoting its own probe sentence,
   and its failure message names the carriers.
3. No test asserts a render against the same field it renders from; content is asserted, not wiring.
4. The printed check-class tally no longer implies a complete count while hiding a nested suite's
   checks.
5. `verify-session-122.sh` exits 0 with its own tally; every fix above has a falsifiability fixture.
6. Cold `fidelity-reviewer` ACCEPT.

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: 8c21785
- step 2 — done: 8c21785
- step 3 — done: c8c83d7
- step 4 — done: 8c21785
- step 5 — done: afdf0a8
- step 6 — done: 83737ec

**Record a real commit sha for every step.** Prose in place of a sha breaks `git cat-file` and goes
Coder-dark (the S119 defect S120 filed).

Landing shas above are the commit where each step first landed. Steps 1, 2 and 4 shipped in one
commit because all three are edits to the same file (`scripts/verify-session-121.sh`) and the
3-files-per-commit rule binds files, not plan steps. Every step was then REFINED by cold-review
repairs, which is the shape of this session and is recorded rather than hidden:

| step | landed | refined by |
|---|---|---|
| 1 anchored read-only guard | `8c21785` | `356aee9` (exact-token allowlist, not `grep -w`) |
| 2 defused handoff booby-trap | `8c21785` | `f1c7ad9`, `356aee9` (exclusion narrowed, not widened) |
| 3 killed the render tautology | `c8c83d7` | `3942538`, `233e26d` (2 more surviving instances) |
| 4 tally honest about nesting | `8c21785` | `356aee9`, `233e26d` (`fleet-smoke` reclassified) |
| 5 suite + demo + fixtures | `afdf0a8` | `19f328c`, `f1c7ad9`, `356aee9`, `233e26d`, `1398cb7` |
| 6 QA dispatch + cold review | `83737ec` | the summary + review commit at closeout |

## Design
- design-significant: **no** — four contained fixes to existing checks and one test, plus a
  reporting change to a tally the suite already prints. No new interface, no new module, no new
  artifact type.

## Non-goals (not built this session)

- **Fencing the `Write`/`Edit` grant.** The QA role can still edit the code it tests; on the S121
  live run the constraint held only because the agent chose to hold it, which is not a control.
  Fencing it is a real design decision (it rides the existing L3 `hook-pre-write.sh` surface, or it
  changes the grant) and gets its own session — **it is the leading ROADMAP candidate after this
  one.**
- Proving dispatch by name — already done, at S121. Do not re-litigate it; cite the artifact.
- A fifth fleet role, parallel dispatch, multi-stage orchestration.
- Making the check-class label machine-derived (the S121 fakest green, option B at that close) —
  step 4 makes the tally *honest about nesting*, it does not make the label *earned*. Keep saying so.
- The `no-eighth-command` banner grep (option C) — still hollow, still labelled honestly, still
  unfixed in both this suite and S113's.
- No 8th top-level command.

## Guardrails
- Max 2 assumptions, max 2 retries, 1 story, ≤3 files/commit, ~2h cap.
- Approval token required before any commit (`VAJRA_ALLOW_COMMIT=122 git commit …`).
- **Every fix needs a falsifiability fixture** — a check that has never been seen RED is not
  evidence. This is the whole lesson of the session that produced these defects.
- **`vajra init` blocks forever on stdin without EOF** (S121) — any caller needs `</dev/null`.
- **Attest LAST**: `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff); compute strictly after the
  `## Execution` shas are committed; two consecutive `verify-closeout.sh --inputs-sha 122` runs must
  agree before embedding.
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3)**, and the canonical
  `**Verdict:** ACCEPT` must be its own bare line, never inside a table cell.
- **Dispatch `qa-specialist` against this session's own suite before closing** — it is available
  same-session (proven S121), and it is now the house's cheapest source of real findings.
