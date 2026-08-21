---
role: requirements-analyst
session: 126
agent: claude-code-subagent
source-sha: d769b9dd80633064e7531950c9aa6d8d020491f874585a8eda6928d8ee7a638b
captured: 2026-08-21T11:26:21Z
cost_usd: null
---

# Requirements-analyst handoff — session 126

## Requirements Analyst brief — Session 127 intake proposal

### Grounding (what the repo actually shows)
- All 9 fleet roles are registered in `src/fleet/mod.rs` (`ROLES`, S126). Each can WRITE a governed, delta-tracked handoff via `vajra next --role <name> --from <file>` into `.ai/handoffs/session-NN-<role>.md`, and each handoff is validated by `fleet::validate_handoff`.
- The READ side exists but is **advisory only**. `src/cli/next.rs:737-746` and `:865-873` inline handoff findings into the Analyst view and the boot packet, with the explicit comment: *"Advisory only: it never blocks."*
- **No gate consumes a handoff.** Every `--advance` gate (Analyst, Architect, Planner, Coder, QA, Demo-er, Releaser) reads the session **prompt** or **git state**, never a role's handoff. `scripts/verify-closeout.sh` has **zero** references to `handoff`/fleet (confirmed by search). This is exactly S125 finding: *"no gate anywhere consumes a handoff... Optional by construction."*
- The house pattern for a blocking gate is well-established (`architect::design_gate`, `planner::plan_gate`): a `Verdict` with `blocked()`, wired into `--advance` with a `bail!`, fail-closed at L2/L3, advise at L1, and a `VAJRA_SKIP_<X>_GATE=1` escape hatch.

### The single-story scope
Make **one** role's handoff — the **`fidelity-reviewer`** handoff — an input a gate BLOCKS on. Rationale for picking this role over the others: its output already has a canonical downstream record (`sessions/session-NN-review.md`) and a validate contract, so a gate can check *existence + validity + linkage* without inventing new semantic judgment (staying inside "surfaces + enforces, never authors"). This is the smallest real "handoff becomes load-bearing" mechanism that fits the ~2h / 3-files budget. (If the founder prefers the `qa-specialist` handoff instead, that is a clean substitution — but pick ONE; do not gate two roles this session.)

### Proposed Goal
> Make one fleet role's handoff load-bearing: add a governance gate that BLOCKS the advance into session N+1 when that session's prompt declares a required `fidelity-reviewer` handoff but no valid governed handoff exists for it — turning a role's output from advisory into a gate input, with an existence-gated recorded marker, a nonzero-exit block, and a documented `VAJRA_SKIP_*_GATE=1` escape hatch, following the Architect/Planner gate pattern.

### Proposed acceptance criteria (numbered, testable, EARS-style)
1. **WHEN** a prompt records the required-handoff marker (e.g. `requires-handoff: fidelity-reviewer`) and NO valid handoff file exists for that role/session, **THEN** `vajra next --check-<gate> NN` exits non-zero and prints the blocking reason — verifiable by one command against a fixture prompt with no handoff (`vajra next --check-<gate> NN; echo $?` prints a nonzero code). *(The marker must be a recorded, existence-gated thing the gate reads, never guessed — mirroring `design-significant:`.)*
2. **WHEN** the same prompt is paired with a governed handoff that passes `fleet::validate_handoff` for that role/session, **THEN** the same `vajra next --check-<gate> NN` command exits 0 — verifiable by re-running the identical command after `vajra next --role fidelity-reviewer --from <file> NN` has written a valid handoff; the ONLY change between the exit-nonzero and exit-0 runs is the handoff's presence/validity, and a prompt that records no requirement is unaffected (exits 0, legacy-compatible).
3. **WHEN** the closeout falsifiability fixture is run (`scripts/verify-session-127.sh`), **THEN** it goes RED for the RIGHT reason — proving both directions live: a required-but-missing handoff BLOCKS (nonzero) AND a present-but-MALFORMED handoff (fails `validate_handoff`) also BLOCKS, so the gate cannot be satisfied by an empty or contract-violating file — verifiable because the script exits 0 only when both the block-path and the pass-path assert as specified, and setting `VAJRA_SKIP_<X>_GATE=1` demonstrably flips the block to an advisory warning.

### Notes for the author (not criteria)
- Keep the marker existence-gated and recorded (never inferred), and keep the block fail-closed at L2/L3 / advise-at-L1 with a distinct `VAJRA_SKIP_*_GATE` var, so each stage overrides alone — this is the invariant `architect::design_gate` and `planner::plan_gate` already hold.
- The falsifiability fixture is the load-bearing deliverable (per `vajra-fixture-right-reason`, S122): it must go red for the intended reason, not because a path is missing or a marker is misspelled.
- Do NOT let this session also refactor the advisory read path or gate a second role — that is the `and` to cut; a second role is a separate founder-gated session.

### Ambiguity flagged for the founder (one genuine fork)
There are two readable "make a handoff load-bearing" designs, and they produce **different sessions** — the author must pick one before scaffolding:
- **(A) Advance-time gate** — block `vajra next --advance` INTO session N+1 on N+1's prompt requiring a handoff (mirrors Architect/Planner exactly; my recommended reading, reflected above).
- **(B) Closeout gate** — block `scripts/verify-closeout.sh` at close of session N on N's own required handoff (mirrors the fidelity-review gate that already lives in closeout).

Both are one-story-sized and both make a handoff load-bearing; they are not the same mechanism. I recommend **(A)** for tightest fit with the existing `--check-*`/`--advance` house pattern, but this is a real fork, not something I should invent past.

### Relevant paths
- `/Users/suman/playground/vajra/src/fleet/mod.rs` — `ROLES`, `validate_handoff`, `read_handoff(s)`, `format_handoff_brief`
- `/Users/suman/playground/vajra/src/cli/next.rs` — advisory read (`:737-746`, `:865-873`); the `--advance` gate chain and `--check-*` handlers (`:47-55`, `:1122-1178`)
- `/Users/suman/playground/vajra/src/architect/mod.rs` — the existence-gated recorded-marker gate to mirror
- `/Users/suman/playground/vajra/scripts/verify-closeout.sh` — confirmed zero handoff references (the gap)
- `/Users/suman/playground/vajra/.ai/CONSTRAINTS.yaml` — the 3-files/1-story/~2h budget and `VAJRA_SKIP_*` posture

This is a PROPOSAL only. The Goal, the four required sections, the `## Delta`, and `Status:` belong in `prompts/127-task-<slug>.md`, written and approved by the session's author — not by me.

## Handoff Delta
- `+` new: first requirements-analyst handoff for this session (6399 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
