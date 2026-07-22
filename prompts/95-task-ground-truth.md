# Session 95 — Ground Truth (mandatory NO-CODE, every 5th)

> **Status:** APPROVED (mandatory — `95 % 5 == 0`; last GT = S90).

## Goal

Run the full mandatory ground-truth audit for **S91–S94**. No source-code changes, no commits to
non-exempt branches, no PRs. Output: `sessions/session-95-ground-truth.md`. Founder signs off before
code resumes.

## Why this session

`95 % 5 == 0` — hard rule, hook-enforced. Last GT was S90, which found:
1. `state_drift` 🔴 — a stale S76 date; corrected.
2. S89 Reviewer hash mismatch — **fixed S91**.
3. Dogfood 🔴 (13 sessions / 2–3 days stale) — **refreshed S92** (paid, $0.2713 authoritative) → 🟢.
4. "Easy-green detour" flagged for the **3rd** consecutive GT (mechanism/gate work over payload).
5. The **pipeline-payload counter** meta-finding (S25/S60) — was BUILT S74; verify it is still a
   live GT input (`vajra next --stations NN`).

Since S90: **S91** (CODE — Reviewer hash fix + `--dogfood-age`), **S92** (DOGFOOD — paid ride-along,
dogfood 🔴→🟢, found commit obedience VOLUNTARY), **S93** (CODE — commit gate voluntary→ENFORCED),
**S94** (CODE — nested-repo guard blindspot closed). Three of the four are CODE hardening; one is the
overdue paid dogfood. Judge whether the pipeline is ADVANCING or the machinery is still growing.

## Scope

**NO-CODE:** no `src/` edits, no commits (except the closeout bundle on the exempt
`session-95-closeout` branch), no PRs. `VAJRA_CLOSEOUT_WAIVER=95` (no `## Execution` shas to fill in
a GT session; the fidelity gate still requires this GT's own review or a waiver).

## Audits Required (per `CONSTRAINTS.yaml#ground_truth.required_audits` — all 10)

Run every audit. Answer its question list. Output `sessions/session-95-ground-truth.md` with one
section per audit and a headline verdict.

| Audit | Key question |
|---|---|
| `vision_alignment` | Is the north-star still right? Is current work the shortest path, or scope creep? |
| `roadmap_alignment` | Does each phase still map to the north-star? Is the next item highest-leverage or just easiest? Any item obsolete or missing? |
| `state_drift` | Does `STATE.md` reflect the repo's real state today? Any stale claim? (S90 caught a date error here.) |
| `knowledge_staleness` | Is `KNOWLEDGE.md` current? Any permanent fact now wrong? Is the §6 changelog bloat (flagged S60) still growing unbounded? |
| `constraint_violation_review` | Were any hard rules violated in S91–S94? Any rule now blocking the vision? |
| `constitution_review` | Is `AGENTS.md` still serving the vision? Any clause creating perverse incentives (e.g. the easy-green gradient)? |
| `cost_review` | Is cumulative spend tracked accurately? Any session where cost was unknown? |
| `dogfood_check` | Has real work run through `vajra claude` since S90? (S92 did — $0.2713.) Is it still fresh enough given the direction? |
| `dogfood_staleness` | Run `vajra next --dogfood-age`. Record the live output. Does it agree with STATE.md? Is the staleness level acceptable? |
| `pipeline_advance_check` | For each of S91–S94, run `vajra next --stations NN` and read K-of-8. Is the pipeline advancing (stations passed), or is machinery growing while the payload stalls? |

## Lead Lens (per AGENTS.md Ground Truth rules)

**Catch two classes of drift:** (1) direction — building the right thing? (2) discipline — honored
the contract, and does the contract still serve the vision?

**Recommended lead lens A: "machinery vs. payload."** S90 flagged the easy-green detour for the 3rd
time; S93 + S94 are both guard/enforcement hardening (real, but not new pipeline payload). The
product thesis is a governed multi-agent SDLC **pipeline** — has the PIPELINE advanced since S90, or
only its guardrails? Use `vajra next --stations NN` for S91–S94 as the evidence, not a narrative.
Weigh honestly: S93/S94 closed genuine, load-bearing governance holes (commit obedience was VOLUNTARY;
the nested blindspot could cross-authorize commits) — is that the right shortest-path work, or a
comfortable detour from harder pipeline/dogfood/cross-agent bets?

**Meta-check (mandatory):** did this audit's own mechanism miss a kind of drift? Naming rule-following
while ignoring whether the vision is still correct is the trap. The pipeline-payload counter was the
S60/S65/S70 meta-finding — confirm it is actually consulted, not just present.

## Acceptance Criteria

1. `sessions/session-95-ground-truth.md` exists and covers all **10** required audits with a verdict
   for each. `covers: 1`
2. No `src/` file changed (confirm `git status` clean of `src/`). `covers: 2`
3. `cargo test --lib` stays green (no `src/` change — confirm anyway, don't assume). `covers: 3`
4. The `pipeline_advance_check` section shows live `vajra next --stations NN` output for each of
   S91–S94, not self-asserted numbers. `covers: 4`
5. The `dogfood_staleness` section shows live `vajra next --dogfood-age` output and compares it
   against STATE.md's dogfood entry. `covers: 5`
6. A headline verdict + the lead-lens finding + the mandatory meta-check are stated plainly. `covers: 6`

## Design

design-significant: **no** — NO-CODE audit session; no new mechanism, command, or ADR deviation.
Cite `docs/decisions/DECISION-001-governance-as-product.md`.

## Plan

1. Run all 10 required audits; answer each question list from `CONSTRAINTS.yaml`. `covers: 1`
2. Run `vajra next --stations NN` live for S91, S92, S93, S94; record K-of-8 each. `covers: 4`
3. Run `vajra next --dogfood-age` live; compare against STATE.md. `covers: 5`
4. Write `sessions/session-95-ground-truth.md` — all audit sections + headline verdict + lead-lens
   finding + meta-check. `covers: 1, 6`
5. Confirm `cargo test --lib` green and `src/` untouched. `covers: 2, 3`
6. Present 3 ranked candidates for S96+ (from ROADMAP backlog). Wait for founder's pick. Write
   `prompts/96-task-<slug>.md`; update `TASK.md`. `covers: (end-of-session)`

## Execution (NO-CODE — `## Execution` section intentionally absent; waiver below)

`VAJRA_CLOSEOUT_WAIVER=95` — GT session; no Coder gate shas to record.

## Guardrails

- **NO-CODE:** hook-enforced (`hook-pre-bash.sh` / `hook-pre-write.sh`). No `src/` edits, no commits
  on the main session branch.
- Closeout on `session-95-closeout` branch (exempt suffix).
- Max 2 assumptions · max 2 retries · max 1 story · ~2h cap.
- **S96 = the first regular session after S95's GT.** New chat.

## Delta (Analyst gate)

- `~` `.ai/STATE.md` / `.ai/SESSION-BOOT.md` / `.ai/ROADMAP.md` / `.ai/TASK.md`: updated at closeout
  to reflect S95 GT findings — no new mechanism, pure snapshot-replace.
- `+` `sessions/session-95-ground-truth.md` — the audit output (the deliverable).
