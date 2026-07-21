# Session 90 — Ground Truth (mandatory NO-CODE, every 5th)

> **Status:** APPROVED (mandatory — `90 % 5 == 0`; last GT = S85).

## Goal

Run the full mandatory ground-truth audit for S86–S89. No source-code changes, no commits to
non-exempt branches, no PRs. Output: `sessions/session-90-ground-truth.md`. User signs off before
code resumes.

## Why this session

`90 % 5 == 0` — hard rule, hook-enforced. Last GT was S85, which found:
1. Easy-green detour (S81–S84 hardening arc, no new stations) — same pattern as S80.
2. Attestation substring-check 🔴 load-bearing for 2 stations → **fixed S86**.
3. S76 `## Execution` shas unfilled → **fixed S87**.
4. Live-bytes attestation bug → **fixed S88**.
5. `ROADMAP.md` "Where We Are" stale → **fixed S89**.
6. Dogfood 🔴 escalated at S85 — **still not refreshed through S89** (12+ sessions / 19+ days stale).

## Scope

**NO-CODE:** no `src/` edits, no commits (except the closeout bundle on the exempt
`session-90-closeout` branch), no PRs. `VAJRA_CLOSEOUT_WAIVER=90` (no `## Execution` shas to fill
in a GT session).

## Audits Required (per `CONSTRAINTS.yaml#ground_truth.required_audits`)

Run every audit. Answer its question list. Output a **`sessions/session-90-ground-truth.md`**
with one section per audit and a headline verdict.

| Audit | Key question |
|---|---|
| `vision_alignment` | Is the north-star still the right destination? Is current work the shortest path, or scope creep? |
| `roadmap_alignment` | Does each phase still map to the north-star? Is the next item highest-leverage or just easiest? Any item now obsolete or missing? |
| `state_drift` | Does `STATE.md` accurately reflect the repo's real state today? Any stale claim? |
| `knowledge_staleness` | Is `KNOWLEDGE.md` current? Any permanent fact now wrong? |
| `constraint_violation_review` | Were any hard rules violated in S86–S89? Any rule now blocking the vision? |
| `constitution_review` | Is `AGENTS.md` still serving the vision? Any clause that creates perverse incentives? |
| `cost_review` | Is cumulative spend tracked accurately? Any session where cost was unknown? |
| `dogfood_check` | Has real work run through `vajra claude` since S85? **If not, that verdict is UNMEASURED — flag it.** Compute exact sessions and calendar days stale. |
| `pipeline_advance_check` | For each of S86–S89, run `vajra next --stations NN` and read K-of-8. Is the pipeline advancing or machinery growing while payload stalls? |

## Lead Lens (per AGENTS.md Ground Truth rules)

**Catch two classes of drift:**

1. **Direction drift** — are we building the right thing? Vision + roadmap map to north-star; current
   work is the shortest path, not scope creep.
2. **Discipline drift** — did we honor the contract? Did the contract serve the vision?

**Recommended lead lens A:** dogfood. S85's GT found dogfood 🔴, then S86/S87/S88/S89 all went to
mechanism fixes — the same easy-green pattern S80 and S85 each flagged. State exactly how many
sessions and calendar days stale. Do not guess.

**Meta-check (mandatory):** did this audit's own mechanism miss a kind of drift? Auditing
rule-following while ignoring whether the vision is still correct is the trap — name it if found.

## Acceptance

1. `sessions/session-90-ground-truth.md` exists and covers all 9 required audits with a verdict
   for each.
2. No `src/` file changed.
3. `cargo test --lib` stays green (no src/ change, so trivially expected — confirm anyway).
4. The `pipeline_advance_check` section shows live `vajra next --stations NN` output for each
   session S86–S89, not self-asserted numbers.
5. The `dogfood_check` section states the exact number of sessions and calendar days stale as of
   S90's date, computed from S76's date, not guessed.

## Design

design-significant: **no** — NO-CODE audit session; no new mechanism, command, or ADR deviation.

## Plan

1. Run all 9 required audits. Answer each audit's question list from `CONSTRAINTS.yaml`. `covers: 1`
2. Run `vajra next --stations NN` live for S86, S87, S88, S89. Record K-of-8 for each. `covers: 4`
3. Compute exact dogfood staleness from S76's date (2026-07-03) to today's real date. `covers: 5`
4. Write `sessions/session-90-ground-truth.md` with all audit sections + headline verdicts +
   meta-check. `covers: 1`
5. Present 3 ranked candidates for S91+ (drawn from ROADMAP.md backlog). Wait for founder's pick.
   Write `prompts/91-task-<slug>.md` and update `TASK.md`. `covers: (end-of-session step 8)`
6. Confirm `cargo test --lib` green. `covers: 3`

## Execution (NO-CODE — `## Execution` section intentionally absent; waiver below)

`VAJRA_CLOSEOUT_WAIVER=90` — GT session; no Coder gate shas to record.

## Guardrails

- **NO-CODE:** hook-enforced. No `src/` edits, no commits on the main session branch.
- Closeout on `session-90-closeout` branch (exempt suffix).
- Max 2 assumptions · max 2 retries · max 1 story.
- **S91 = the first regular session after S90's GT.** New chat.

## Delta (Analyst gate)

- `~` `.ai/STATE.md` / `.ai/SESSION-BOOT.md` / `.ai/ROADMAP.md`: updated at closeout to reflect
  S90 GT findings — no new mechanism, pure snapshot-replace.
