# DECISION-011 — Controls the agent cannot type

**Status:** Accepted
**Date:** 2026-09-30
**Session:** S181
**Supersedes in part:** DECISION-008 (the prose search for `**CODE**` is now only a dated fallback)
**Extends:** DECISION-007 (S169 waiver addendum, S173 launch approval), DECISION-003 (hash binding), DECISION-002

---

## Context

S180's ground truth found one root cause behind F77–F80, F84, F85 and F92: a control means something
only if the agent cannot produce it. Four of Vajra's founder controls were text the agent could write —
the `APPROVED` word in a brief, the "verified" stamp on a helper's record, `VAJRA_CLOSEOUT_WAIVER=N`
typed inline, and the session type read from prose.

## Decision

1. **Session type is one strict field.** `session_type: CODE | DOCUMENT | GROUND_TRUTH | INTERACTIVE` on
   a line of its own. Missing, unknown or conflicting fails the close gate. `INTERACTIVE` gets the CODE
   checks. A session cannot label itself `GROUND_TRUTH` off the cadence. No prose is read.
2. **Approval is a record, never words.** From the project's `session_rules_from` the gate reads
   `.ai/approvals/session-NN.json`, written by `vajra approve NN` (refused when the process carries
   `VAJRA_AGENT_MARK`, which `vajra claude` sets on everything it spawns, and when stdin is not a
   terminal), by `VAJRA_APPROVE=NN` at launch, or by `vajra claude --allow-all` (live only while that
   launch runs). The agent's Write and Bash hooks refuse to write there.
3. **A waiver names what it skips.** `VAJRA_WAIVE=<check>,…` with a required `VAJRA_WAIVE_REASON`,
   logged as launch-time (a copy `vajra claude` took from the founder's terminal) or set later.
   `VAJRA_CLOSEOUT_WAIVER=N` keeps working with a printed warning until the founder says remove it.
   No waiver path exists for `claimed-evidence-real` (unchanged, S169).
4. **A stamp is bound to its text.** The `verified:` stamp carries `text-sha:` of the findings as
   written; the mandate, obeyed and fidelity gates recompute it. This extends DECISION-003's hash binding
   from the verdict to helper records (F84).
5. **Old work keeps working, loudly.** Everything below a project's `session_rules_from` (default 181, new
   scaffolds 1) reads the old way through a dated fallback that prints its name every time it is used.

## Proof recorded for the cadence part

With `.ai/CONSTRAINTS.yaml` still saying `ground_truth_next_session: 180` and `sessions/session-180-ground-truth.md`
present, session 181 is NOT a review-only session and session 185 IS — with no edit to the key
(`tests/gt_cadence_shared.rs`, and the old-vs-new Stop-hook check in `scripts/verify-session-181.sh`). A passed
override with no report rolls forward to the next multiple of 5 and says so at session start, prompt submit,
the Stop hook and both close gates.

## Limit — stated where a reader will see it

Bar-raising, **not tamper-proof.** The agent runs as the same OS user. It can strip the mark
(`env -u`), fake a terminal, write the record with a shell path the hook does not match, set both waiver
variables, or re-record its own text through `vajra next --role` and receive a fresh stamp for text the
helper never wrote. What the controls buy: the easy paths are closed, every use is labelled, and the
trail is a file in git a reviewer can read. Scaffolded projects do not yet get the Write/Bash hooks that
guard `.ai/approvals/`.

## Alternatives rejected

- Signed approvals or stamps — need a key store the agent could also read (DECISION-003 rejected the same).
- A second environment-variable scheme — the existing `VAJRA_ALLOW_COMMIT` refuse-agent-set pattern is reused.
- Removing the old waiver now — the founder has not said to.
- Guessing the type from more keywords — still text guessing.
