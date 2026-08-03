# Session 110 — NO-CODE Ground Truth (audits S106–S109)

> **Status:** APPROVED (founder pick at S109 closeout — lead lens = "fleet real & shippable").
> Written at S109 closeout per `end_of_session.must_write_next_prompt_before_close`.

## Type
- **NO-CODE** (mandatory every 5th session; `110 % 5 == 0`). **No source-code edits, no commits, no
  PRs, no `src/` changes** — hook-enforced (`hook-pre-bash.sh`, `hook-pre-write.sh`). Hardening, if
  any, goes on a `session-110-closeout` / `-enforcement` branch (exempt by suffix).

## Goal
Ground-truth the work since the last GT (S105): **S106–S109** — the installable-v0.1 legs (S106 Rust
path · S107 prebuilt · S108 crates.io + brew) and the **fleet's first slice (S109)**. Catch BOTH
direction drift (are we building the right thing?) and discipline drift (did we honor the contract,
and does the contract still serve the vision?). Output `sessions/session-110-ground-truth.md`; the
founder signs off before code resumes.

## Lead lens (founder pick) — is the fleet REAL and advancing, or labelled machinery?
The sharpest question this cycle: **is v0.1 stranger-shippable AND does the fleet actually move the
product** (a real named agent doing scoped work behind the gates), **or did S109 add a role *file*
without advancing the pipeline it governs?** Weigh the S109 subagent pivot honestly:
- The `claude -p` paid path was built then reverted after a headless-auth wall; the fleet is now
  native subagents. Was that the right call, or did it dodge the "real paid proof" bar (`cost_usd:
  null`, def-vs-dispatch not wired end-to-end)? (See `sessions/session-109-summary.md` fakest-green +
  `session-109-review.md` — the cold reviewer flagged exactly this and ACCEPTed with a condition.)
- Nothing downstream consumes the S109 handoff yet — is "fleet" now a second story overlapping the
  "8 stations", or one coherent pipeline?

## Required audits (answer each audit's question list in `CONSTRAINTS.yaml#ground_truth`)
- `vision_alignment` · `roadmap_alignment` · `state_drift` · `knowledge_staleness` ·
  `constraint_violation_review` · `constitution_review` · `cost_review` · `dogfood_check` ·
  `pipeline_advance_check` · `dogfood_staleness`.
- **Mandatory instrument reads (record the live output verbatim):**
  - `vajra next --stations 106`, `107`, `108`, `109` — read the K-of-8 SHAPE, not just the number
    (CODE sessions on a brief that predates the full marker template read low by construction).
  - `vajra next --dogfood-age` — sessions/days since the last real `vajra claude` run; compare to
    STATE.md's dogfood entry (S91 staleness check). **Note:** S109's headline was a *subagent* run,
    not a `vajra claude` launcher run — decide honestly whether that counts as dogfood, and flag if
    the launcher hasn't run since S103.
- **Meta-check (mandatory):** did this audit's own mechanism miss a kind of drift? The pipeline-advance
  counter has a known blind spot for DOGFOOD/GT sessions and for briefs predating the marker template —
  and now possibly for the *fleet* (a handoff is real work the K-of-8 doesn't score). Name it.

## Acceptance criteria
1. `sessions/session-110-ground-truth.md` exists, runs every required audit with its question list
   answered, and states a plain **lead-lens verdict** (PASS / PARTIAL / FAIL) with 🟢/🟡/🔴 per audit.
2. Every mandatory instrument read above is recorded with its **live output** (not paraphrased).
3. Any state drift found in `.ai/` is CORRECTED on a `session-110-closeout` branch (the only writes
   allowed) and listed in the report.
4. Exactly 3 ranked next candidates (A/B/C) for S111, drawn from ROADMAP.

## Guardrails
- **NO code.** The hooks enforce it; do not fight them. Reports + `.ai/` drift-corrections only.
- **Map to Vajra's own mechanism** — the instruments (`--stations`, `--dogfood-age`) ARE the evidence;
  read them live, don't assert from memory.
- **New chat** for S110 (one session per chat).
- Communicate in the plainest English (founder standing request).
