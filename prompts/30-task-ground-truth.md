# Session 30 — Ground Truth (NO-CODE) · lead lens: founder-satisfaction gate

> **NO-CODE.** `NN % 5 == 0`. No source edits, no commits, no PRs. Hooks enforce (`hook-pre-bash.sh`, `hook-pre-write.sh`). Output is one report: `sessions/session-30-ground-truth.md`. User signs off before code resumes.
> Authorized hardening (if the audit finds a rule/scaffold gap) goes on a `session-30-closeout` or `session-30-enforcement` branch (exempt by suffix) — **only after** the user approves it.

## Lead lens (picked at S29 closeout): the founder-satisfaction gate

The S26 founder override parked the second agent **gated on the founder's judgment that Vajra-on-Claude is "satisfying"** — explicitly *not* the S25 audit's "condition met" call. Three sessions of propagation (S27 Darshan → S28 Darshan-in-init → S29 guard-in-init) were framed as *making Claude satisfying*. **S30 leads by answering that gate.**

Lead the audit with these, then run every required audit below:
- **Is Vajra-on-Claude now satisfying enough to promote the second agent?** What concretely is still un-satisfying (name it), or what is the evidence it's ready?
- **Did S27–S29 actually move satisfaction, or just add scaffold surface?** Distinguish "the loop is more complete" from "the founder's day-to-day pain is lower."
- **If still not satisfying:** what is the *single* highest-leverage Claude-depth item left — and is it real depth or polish S25 already called "spent leverage"?
- **If satisfying:** the second agent returns to #1; sanity-check ADR-0002's adapter contract is genuinely vendor-neutral before committing to it.

## Required audits (all of them — `CONSTRAINTS.yaml#ground_truth.required_audits`)

Answer each audit's question-list:
- **vision_alignment** — north-star still right? current work the shortest path, or intellectually-fun scope creep? what evidence would make us pivot?
- **roadmap_alignment** — each phase maps to the north-star? next item highest-leverage or just easiest? anything now obsolete / newly-demanded?
- **state_drift** — does `.ai/STATE.md` match reality? (Watch the recurring PR-status drift — now 5×, S15/S20/S25/S27/S28.)
- **knowledge_staleness** — any KNOWLEDGE.md fact stale or contradicted?
- **constraint_violation_review** — any S26–S29 constraint breach? (files/commit, assumptions, retries, command count.)
- **constitution_review** — is any rule now blocking the vision instead of protecting it? **meta-check: did this audit's own mechanism miss a kind of drift?**
- **cost_review** — cumulative spend (~$0.46) still accurate?

## Two drift classes (don't audit one and miss the other)

1. **Direction drift** — *are we building the right thing?* (vision + roadmap)
2. **Discipline drift** — *did we honor the contract, and does the contract still serve the vision?* (state + knowledge + constraints + constitution + cost)

The S20 trap: auditing rule-following while ignoring whether the vision is still right. Rules serve the vision, not the reverse.

## Definition of done

- `sessions/session-30-ground-truth.md` written, covering all required audits + the founder-satisfaction lead lens + the meta-check.
- A clear verdict on the gate: **promote the second agent (Y/N)** + the one highest-leverage next item.
- Zero code, zero commits, zero PRs. User signs off.

## Carry-forwards into S30

- **STATE.md PR-status drift (5×)** — verify the report flags it; at closeout write "open (merge after closeout)" / actual merge state, never "pending merge".
- **Propagation arc is complete** (S22 co-pilot → S28 Darshan → S29 guard all in `init`) — the dogfood session is now unblocked and a strong post-GT candidate.
- Still open: `vajra estimate` 3:1 ratio unvalidated; `vajra claude` no auth pre-check.
- After S30, the next session is CODE again (S31).
