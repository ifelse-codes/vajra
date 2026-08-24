# Session 131 — CODE: make the fidelity-reviewer handoff mandatory, and prove it's real

> **Status:** APPROVED — founder, 2026-08-24, at the S130 closeout. Locked sequence, founder's own
> words: the first role to make mandatory should be the reviewer/tester role that "ensure[s] the
> session complete[s] all acceptance criteria and what it build[s] is actually high quality work,
> not fake stamping and shortcuts." S131 -> S132 -> S133 -> S134 is locked; Rung 3 and outside
> adoption are explicitly pushed back past S134 (not code-closeable -- see Non-goals below).
>
> Founder directive in force (S118): README.md / VISION.md claims are the target spec, not a
> status report. Do NOT soften them. No release until reality meets them.

## Type

CODE. Max 2 assumptions, 2 retries, 1 story, ~2h, new chat. One story: the role that catches fake
work becomes required, not optional, and can't be satisfied by a fake itself. Commits need the
un-forgeable marker on the command line at commit time.

## Why this session

sessions/session-130-ground-truth.md (S130 GT) found the fleet of 9 helper roles trending toward
pure decoration, not toward use:

| Session | Governed handoffs dispatched |
|---|---|
| S126 | 5 |
| S127 | 3 |
| S128 | 1 |
| S129 | 0 |

Falling every session. The one gate that touches a handoff (`vajra next --check-advice`, S127) only
fires if a handoff already exists -- it never complains when a session dispatches zero advisors,
which is exactly what S129 did. And even when a handoff exists, its provenance field
(`src/cli/next.rs:283`) is the hardcoded literal string `"claude-code-subagent"` -- never derived
from any real dispatch evidence. A handoff proves nothing today except that someone ran a command.

The founder's pick for the first role to make real, in their own words: not a pre-work advisor, but
the role that ensures a session's acceptance criteria were actually met and the work is real -- not
fake stamping and shortcuts. That is `fidelity-reviewer` (DECISION-002's fidelity auditor, already
the most-used role S127-S129). Harden the role already closest to load-bearing.

## Goal

A session cannot close without a real `fidelity-reviewer` governed handoff -- and "real" is
provable, not asserted. Two parts:

1. Mandatory: closeout blocks if `.ai/handoffs/session-NN-fidelity-reviewer.md` is absent
   (mirroring how the Coder/Architect/Planner gates already block on absence, not just on content).
2. Provable: the handoff's provenance field is derived from actual subagent-dispatch evidence
   (the parent-tool-call-ID <-> subagent-`meta.json` cross-check S111 and S117 already built by
   hand, twice, and never wired into a gate) -- not a hardcoded string a hand-typed handoff can
   satisfy for free.

## Deliverables

- A new or extended gate (likely alongside `vajra next --check-advice`, or its own
  `--check-fidelity-handoff`) that BLOCKS `--advance`/closeout when no `fidelity-reviewer` handoff
  exists for the session, at the maturity-gated L2/L3 levels this repo already uses everywhere else.
- `src/cli/next.rs:283`'s hardcoded `"claude-code-subagent"` replaced with real derived provenance --
  reusing the S111/S117 cross-check design, not reinventing it.
- A written-but-unverifiable handoff (hand-typed, no matching subagent transcript) is refused or
  flagged fail-closed, not silently accepted as equivalent to a real one.
- A falsifiability fixture proving all three directions: (a) no handoff at all -> new gate FAILS,
  (b) a handoff with fabricated/unverifiable provenance -> FAILS, (c) a real dispatch -> PASSES.
- `scripts/verify-session-131.sh` + `scripts/demo-session-131.sh`, both exit 0, printed check-class
  tally.
- `sessions/session-131-summary.md` + exactly 3 ranked next candidates (S132 -- "check the advice
  was obeyed" -- is the locked default; still present it as one of the three per the standing
  end_of_session rule, not as the only option).

## Acceptance (testable, EARS-style)

1. WHEN a session reaches closeout THEN `verify-closeout.sh` (or the relevant `--check-*` gate)
   FAILS if `.ai/handoffs/session-{NN}-fidelity-reviewer.md` does not exist -- proven on a real
   session directory, not asserted in prose.
2. WHEN `vajra next --role fidelity-reviewer --from <findings>` writes a handoff THEN its provenance
   field is derived from real dispatch evidence, not the literal string `"claude-code-subagent"`.
3. WHEN the provenance cannot be verified against real subagent-dispatch evidence THEN the gate
   treats it as absent/invalid -- fail-closed, same posture as every other existence-gated marker in
   this repo (S67 Architect's ADR check, S68 Coder's `git cat-file -e`).
4. A falsifiability fixture drives all three directions in Deliverables and asserts each probe's own
   pattern matched (S127's lesson: a probe that silently no-ops is false comfort).
5. Traced, not asserted: `K of 8`'s derivation and shape are unchanged; command count stays 7
   (no 8th command); no other gate's evidence contract moves.
6. `verify-session-131.sh` and `demo-session-131.sh` both exit 0 with a printed check-class tally,
   every check execute-based or honestly labelled.
7. Independent cold `fidelity-reviewer` verdict ACCEPT, attested -- dispatched via the very
   mechanism this session is hardening, so its own handoff satisfies deliverable 1 for real.
8. The summary states plainly what is still NOT fixed -- in particular that only ONE role
   (`fidelity-reviewer`) is mandatory after this session; the other 8 stay optional, and whether its
   advice was obeyed (vs. merely answered) is explicitly S132's job, not this session's.

## Plan (ordered -- cite the acceptance criteria each step covers)

1. Reproduce the gap first: confirm live that a session can close today with zero
   `fidelity-reviewer` handoffs (S129 already did this) and that a hand-typed fake handoff passes
   whatever exists today. No fix before its own red. covers: 1, 2
2. Wire the S111/S117 provenance cross-check into `vajra next --role ... --from`, replacing the
   hardcoded string. covers: 2, 3
3. Add the existence-gate: closeout/`--advance` blocks when no `fidelity-reviewer` handoff exists
   for the session, maturity-gated like every other Vajra hook. covers: 1
4. Falsifiability fixture, all three directions, each probe asserting its own pattern matched.
   covers: 4
5. Prove nothing else moved -- `K of 8`, 7 commands, other gates' contracts. covers: 5
6. `scripts/verify-session-131.sh` + `scripts/demo-session-131.sh`. covers: 6
7. Dispatch the real `fidelity-reviewer` cold pass on this session's own diff -- the handoff this
   produces is deliverable 1's own proof. covers: 7
8. Say in the summary what is still not fixed. covers: 8

## Execution (the Coder gate -- record each plan step's landing commit as work lands)

- step 1 -- done: <sha>
- step 2 -- done: <sha>
- step 3 -- done: <sha>
- step 4 -- done: <sha>
- step 5 -- done: <sha>
- step 6 -- done: <sha>
- step 7 -- done: <sha>
- step 8 -- done: <sha>

> Fill these with real landing shas before closeout -- S119, S122, S124 all left <sha> placeholders
> once, caught only by an independent cold review. Do not record a sha that does not contain the
> work (S127 did that three times).

## Advice (every recommendation from this session's advisors, answered)

> The S127 contract. One line per recorded recommendation: `- <role> rec N -- obeyed: <sha>` /
> `refused: <reason>` / `deferred: <path>`. `vajra next --check-advice 131` BLOCKS the close until
> every one is answered. Read the S127 residual before trusting any count: four `obeyed:` labels
> there were factually wrong and passed the gate. A disposition certifies a typed word and a
> resolving sha, nothing more -- check the commit, don't count the label.

(Filled during S131 -- this session should dispatch at least the `fidelity-reviewer` cold pass per
Plan step 7, and its recommendations get answered here.)

## Design

- design-significant: yes -- this changes a closeout gate's blocking behaviour (existence-gating a
  handoff that was previously optional) and replaces a hardcoded provenance string with derived
  evidence, both real behaviour changes for anyone already relying on the current (permissive) gate.
- Spine record to cite: the nearest existing ADR/decision record naming the fidelity auditor as
  load-bearing (DECISION-002) -- verify it exists before citing it; the Architect gate checks
  existence, not obedience.
- Open design question for S131 to resolve and record here: does the new gate live inside
  `vajra next --check-advice` (extending the existing Advice gate) or as its own
  `--check-fidelity-handoff`? Either is acceptable; record the choice and why.

## Non-goals (not built this session)

- Not the other 8 roles. Only `fidelity-reviewer` becomes mandatory this session. Repeating the
  pattern for a second role is explicitly future work, only after this one is proven.
- Not "was the advice obeyed." That is S132, locked as the next session at the S130 closeout. This
  session only makes the handoff mandatory and its provenance provable.
- Not the fourth fork (`TPL_CONSTRAINTS`, S129/S130's other standing residual) -- parked, not
  dropped, per .ai/ROADMAP.md.
- Not Rung 3 or outside adoption. Both explicitly pushed back past S134 at the S130 closeout --
  neither is code-closeable; see sessions/session-130-ground-truth.md.
- No release, no crates.io action (founder directive; vajractl already burned at 0.1.0).

## Delta (vs ROADMAP -- OpenSpec markers)

- ADDED: an existence-gate on the `fidelity-reviewer` handoff; real dispatch-evidence provenance
  replacing the hardcoded string.
- MODIFIED: `vajra next --role ... --from` (provenance derivation); the closeout/`--advance` gate
  set (one new blocking check).
- UNCHANGED: the 8 stations, the 9 roles, the 7 commands, `K of 8`'s derivation, every OTHER gate's
  evidence contract, the 8 optional roles' handoff mechanism.

## Guardrails

- Un-forgeable commit marker required on every commit, session number 131. Max 3 files per atomic
  commit. Never skip hooks.
- A check that cannot evaluate FAILS (S69). A fixture must fail for the RIGHT reason (S122), and a
  probe must assert its own pattern matched (S127).
- Do not widen to a second role. One role, proven mandatory + provable, before repeating.
- Answer this session's own advisor in Advice, honestly. A `refused:` with a reason beats an
  `obeyed:` that is not true.
- Attest LAST (S69): recompute Review-Inputs-SHA strictly after the Execution shas land; two
  consecutive closeout runs with `--inputs-sha 131` must agree before embedding. Run the full
  verify-closeout.sh on the branch BEFORE merging the PR (S83) -- merge-base collapses after.
