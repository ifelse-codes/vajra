# Session 35 — Ground Truth (NO-CODE): "fix the core" bet verification + second-agent gate re-measure

> **MANDATED GT** (`NN % 5 == 0`; last = S30). No source-code edits, no commits, no PRs
> (hook-enforced; authorized hardening only on a `-closeout`/`-enforcement` branch).
> Founder-picked lead lens (S34 closeout, option A).

## Lead lens (picked A)
All three S31 core breakages are now closed — S32 Darshan (enforced in the boot packet),
S33 compression (real snake_case envelope parses), S34 brownfield (session-0 onboarding +
`.ai/hooks/` placement + auth pre-check). The bet was **"fix the core before breadth."**
This GT verifies the bet paid off and re-asks the parked second-agent gate:

1. **Are the three fixes *felt*, not just green?** Each was verified `advised → enforced`
   with real-shaped evidence — but the gate's lens is daily founder satisfaction, which only
   real usage measures.
2. **`dogfood_check` will bite:** the cost ledger shows ~$0 `vajra claude` spend since S31.
   If no real work has run through the loop, the honest verdict on "is Vajra-on-Claude
   satisfying?" is **unmeasured** — say so; do not guess. The likely honest outcome is a
   directed S36 dogfood, not a gate clearance.
3. **If (and only if) the founder declares satisfaction measured and sufficient:** the
   second agent (Codex/Cursor) returns to #1 per the S26 override terms.

## Mandatory scope (regardless of lens)
Run **every** audit in `CONSTRAINTS.yaml#ground_truth.required_audits` with its question
list: vision_alignment, roadmap_alignment, state_drift, knowledge_staleness,
constraint_violation_review, constitution_review, cost_review, **dogfood_check**.
Catch BOTH direction drift and discipline drift; meta-check the audit's own mechanism.

## Specific tension to pressure-test (from S32–S34 findings)
- The *advised → enforced* meta-rule now has 3 instances — but new *advised-mode* gaps
  keep surfacing: the `.claude/settings.json` merge gap (S34 — brownfield repos with an
  existing settings.json never wire the scaffolded hooks), the `exit_code == Some(0)`
  heuristic gap (S33). Is the wedge structurally leaky, or is this normal debt?
- Backlog now has ≥4 S36 candidates: dogfood run, settings-merge, exit_code heuristics,
  obedience metric. The GT should rank them (highest-leverage, not easiest).

## Output
- `sessions/session-35-ground-truth.md` — audits, verdicts, gate call (or "unmeasured"),
  ranked S36 recommendation, exactly 3 next options A/B/C.
- User signs off before code resumes.

## Guardrails
- NO-CODE: docs under `sessions/` (and `.ai/` sync at closeout) only.
- Branch `session-35-ground-truth` from `main`; closeout commits per constitution.
- New session = new chat.
