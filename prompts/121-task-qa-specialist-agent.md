# Session 121 — CODE: the QA specialist agent (fleet role 4)

> **Status:** APPROVED — founder pick at S120 GT closeout.
> **Founder directive in force (S118):** `README.md` / `VISION.md` claims are the **target
> spec**. Do NOT soften them. No release until reality meets them.

## Type

**CODE.** Max 2 assumptions · 2 retries · 1 story · ~2h · new chat.
Branch: `session-121-qa-specialist`.

## Why this session

Every fleet agent built so far (Researcher, Fidelity Reviewer, Plan Advisor) can only READ.
None of them can run anything. So the only way to produce "real evidence" today is a
verify script — and S118 proved that verify scripts can be made entirely of grep checks
that miss a broken product.

The QA specialist is the first fleet agent that can actually **execute** the product and
report what it saw. This means it cannot physically fake a pass — it either ran the thing
and got output, or it didn't.

The hollow-test problem goes away naturally when the agent doing QA is a real executor,
not a text search.

## Goal

Add `qa-specialist` as the fleet's **fourth role** — the first with full execution
capability. It runs the session's verify script, classifies each check (behavioral
source-grep vs execute-based), and reports what actually exercised the product.

Same zero-new-machinery shape as S114 and S116: `vajra init` / `vajra next` / the station
counter pick it up without code changes — trace before assuming otherwise.

## What is different about this agent

All three prior fleet agents are granted: `Read, Grep, Glob` (advisory, read-only).

The QA specialist is granted: **`Bash, Read, Write, Edit, Grep, Glob`** — full execution.
This is intentional and load-bearing. An agent that cannot run code cannot produce
trustworthy QA evidence. Record the grant decision in `DECISION-007`'s S121 addendum
with the rejected alternatives (read-only QA agent).

## Plan

1. Register `qa-specialist` in `src/fleet/mod.rs` — the ONE canonical source. Tool grant:
   `Bash, Read, Write, Edit, Grep, Glob`. Role prompt must specify:
   - Run the session's `verify-session-NN.sh`
   - Classify each check: "behavioral source grep" (greps src/ for a message/flag string) vs
     "execute-based" (runs the binary / cargo test / a script and checks real output)
   - Report: how many checks in each class; which checks are hollow; what the live output was
   - Govern the findings into a handoff via `vajra next --role qa-specialist --from <file>` `covers: 1`

2. `vajra init` scaffolds `.claude/agents/qa-specialist.md` — byte-identical rendering of
   the `fleet::ROLES` entry. `covers: 2`

3. `vajra next --role qa-specialist --from <file>` governs the handoff. Fail-closed on:
   unknown role / missing `--from` / empty findings. `covers: 3`

4. `DECISION-007` gains an S121 addendum: key = `qa-specialist`; tool grant rationale;
   rejected alternative (read-only); the station-collision non-issue (QA STATION ≠ QA ROLE,
   same pattern as Reviewer/fidelity-reviewer and Planner/plan-advisor). `covers: 4`

5. `verify-session-121.sh` — key checks:
   - `scaffolds_four_roles`: `vajra init` into a temp dir produces exactly 4 agent files
   - `qa_agent_has_bash`: the scaffolded `qa-specialist.md` grants Bash
   - `one_source_of_role_text`: the QA agent's prompt text lives in exactly one
     hand-maintained file (`src/fleet/mod.rs`)
   - `fail_closed`: `--role qa-specialist` without `--from`, with empty findings, with a
     missing file → all fail closed
   - `handoff_governed`: a real `vajra next --role qa-specialist --from <file>` produces
     a governed handoff with correct frontmatter + source-sha
   - `no_station_collision`: nothing in `src/qa/` (the QA STATION) knows about the role key
   - `decision_recorded`: DECISION-007 S121 addendum exists with ≥2 rejected alternatives
   - `no_eighth_command`: `vajra --help` still lists exactly 7 commands `covers: 5`

6. Cold `fidelity-reviewer` pass before close. `covers: 6`

## Acceptance criteria

1. `qa-specialist` is registered in `src/fleet/mod.rs` with `Bash, Read, Write, Edit, Grep, Glob`.
2. `vajra init` scaffolds 4 agent files; `qa-specialist.md` carries the Bash grant.
3. `vajra next --role qa-specialist --from <file>` produces a governed handoff; fail-closed on bad inputs.
4. `DECISION-007` S121 addendum records the key, the Bash-grant rationale, and ≥2 rejected alternatives.
5. All `verify-session-121.sh` checks green; `no_eighth_command` holds.
6. Cold `fidelity-reviewer` ACCEPT.

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: 98528b2 (register qa-specialist in fleet::ROLES with full tool grant)
- step 2 — done: 985efdd (vajra init scaffolds 4th agent file)
- step 3 — done: 2ef285f (vajra next --role qa-specialist --from governs handoff, proven e2e)
- step 4 — done: 88b7c35 (DECISION-007 S121 addendum)
- step 5 — done: 05a9ad5 (verify-session-121.sh all green, 17/17, honest class tally)
- step 6 — done: 36abdb4 (cold fidelity-reviewer ACCEPT; sessions/session-121-review.md)

Note: steps 3 and 5 both land in `scripts/verify-session-121.sh` — step 3's proof IS the
end-to-end check inside that script. `2ef285f` is where both first went green; `05a9ad5` is the
cold-review fix on top, recorded against step 5 because that is the check it reclassified. Every
sha above resolves to a real commit (`git cat-file -e <sha>^{commit}`) — no prose in place of a
sha, the S119 Coder-dark defect S120 filed.

## Design

- design-significant: **no** — same zero-new-machinery shape as S114 and S116. The tool
  grant change (Bash added) is a data change to the ROLES table, not a new code path.
  One design decision to record: the Bash grant (with DECISION-007 addendum).

## Non-goals

- Do NOT dispatch the agent in this session (mid-session dispatch is invisible — the
  S111 finding). S122 = fresh session, dispatch proof, first live run.
- Do NOT redesign the existing QA STATION (`src/qa/mod.rs`). The STATION governs the
  process; the AGENT does the work. They stay separate.
- Do NOT add a 4th fleet agent to the `--stations` K counter. Fleet work is reported
  BESIDE K (S113 decision), never inside it.

## Guardrails

- **One source of role text.** The `qa-specialist` prompt lives ONLY in `src/fleet/mod.rs`.
  No hand-written `.claude/agents/qa-specialist.md` — that file is a rendering of the
  canonical source, emitted by `vajra init`, identical byte-for-byte.
- **No 8th command.** The QA specialist rides `init` + `next` — no new top-level command.
- **Attest LAST** (S69 lesson, S114/S116/S117/S118/S119 hit): compute Review-Inputs-SHA
  strictly after every edit to the prompt file's execution shas is committed; confirm two
  consecutive `verify-closeout.sh --inputs-sha 121` runs agree before embedding.
- **Dispatch proof is S122's job** — do not chase dispatch in this session.
