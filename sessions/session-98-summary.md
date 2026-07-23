# Session 98 — Autopilot-Trust Reposition (CODE / docs) — Summary

**Goal:** reposition Vajra from "a governed 8-station SDLC pipeline" (mechanism-first) to **"the
autopilot trust layer — leave your agent working for days, come back, and trust the result"**
(outcome-first). The pipeline stops being the pitch and becomes the *engine*. Same move-class as
S53 (DECISION-001 reframed compression → governance). Docs only — no `src/`.

**Goal achieved:** YES. Three deliverables shipped; independent cold review **ACCEPT (6/6 SHIPPED)**,
attested, ledger extended. No `src/` touched.

## Evidence (what shipped)

| Deliverable | File | Commit |
|---|---|---|
| Direction lock — reframe, audit+interview provenance (founder-answer table), Ladder, freeze rule, 2026-09-15 backstop, both kills | `docs/decisions/DECISION-005-autopilot-trust.md` (new) | `8f8dcfe` |
| Autopilot-trust lead + pipeline reframed as the engine; every honesty row preserved | `VISION.md` | `7092e4b` |
| 6-Month Autopilot Plan (Ladder + backstop + content machine + signal→scale + scoreboard + 2 kills) · machinery-freeze rule in Rules · backlog frozen | `.ai/ROADMAP.md` | `fc898fe` |
| Independent cold review + summary | `sessions/session-98-review.md`, this file | (review commit) |

## Fidelity check — every Acceptance Criterion mapped (independently reviewed, cold)

Reviewed by a separate pass fed **only** the prompt + the diff (DECISION-002). Verdict verbatim in
`sessions/session-98-review.md`.

| AC# | Requirement | Verdict | Evidence |
|---|---|---|---|
| 1 | DECISION-005 records reframe, provenance (audit+interview WITH founder table), Ladder, freeze rule, 2026-09-15 backstop, Kill A + Kill B | **SHIPPED** | new file; all six elements with substance |
| 2 | VISION leads w/ autopilot trust; stations = engine; every honesty row survives verbatim-or-stronger | **SHIPPED** | new lead + "## The engine"; no `-` line softens any disclosure; "0 cross-agent code" / compression never-claim / better-work hypothesis all intact |
| 3 | ROADMAP Ladder w/ falsifiable conditions (zero-leak + spot-check + merge test) + dated backstop | **SHIPPED** | Ladder table + "2026-09-15 whichever comes FIRST" |
| 4 | ROADMAP scoreboard (wk-8/month-4/month-6) + both kills incl. Kill B pivot | **SHIPPED** | Scoreboard table + Kill A/Kill B (standalone acceptance checker) |
| 5 | Machinery-freeze rule in ROADMAP's Rules section | **SHIPPED** | Rule 6 under "Rules For This Document" |
| 6 | Docs-only (no `src/`); cold review ACCEPT, attested (`--inputs-sha 98`), ledger extended | **SHIPPED** | diff = 3 docs, zero `src/`; ACCEPT + `Review-Inputs-SHA`; ledger record added |

**Overall: ACCEPT.**

## What I did NOT build (stated plainly)

- **No `src/` change, no README, no code.** By design — the README truth-pass (retire the stale ~8×
  receipt claim + unverifiable install paths) is scheduled INSIDE the release-backstop task, not here;
  touching README in S98 would be scope creep the prompt explicitly forbade.
- **The reposition is words, not proof.** Autopilot trust is now the *lead*, but the pipeline has run
  end-to-end exactly once (S97, Rung 1, a disclosed partial). The Ladder is the plan to earn the claim
  — climbing it is S99+, not done here.
- **The machinery-freeze rule has no code teeth.** It is convention-enforced; its enforcement is
  handed to S100's ground-truth (lead lens: did machinery resume?).

## Fakest "green" here

The machinery-freeze rule — the load-bearing new constraint — is a *written rule*, not a gate. Nothing
in the binary blocks a future session from detouring into a satisfying green code session no ladder run
demanded. It is honest (disclosed as convention-enforced, by-construction at the process level) but it
is the element most likely to be quietly ignored, which is exactly why S100's GT must audit it.

## Cost

~$0 (docs-only; no `vajra claude` paid run this session).

## Next — 3 ranked S99 candidates (A/B/C)

*(S100 is a fixed mandatory NO-CODE ground-truth regardless of this pick — this chooses S99 only.
Under the new machinery-freeze rule, a session either runs the ladder or fixes what a run broke.)*

### A — Coder-marker fix (the S97 blocker Rung 2 will hit) — *recommended*
- **Goal:** make the pipeline reachable unattended — *agents write the `## Execution`/`## Delta`
  markers, Vajra verifies* + an **env-marker commit path** (`VAJRA_ALLOW_COMMIT` shape) so a headless
  `-p` run can reach a full closeout; marker slots ride the `vajra init` scaffold.
- **Why pick this:** S97 proved Rung 2 hits a wall without it (Coder doubly-blocked: no marker slots +
  headless can't approve a commit). This is the sanctioned "fix what the run broke" — the enabler that
  makes a clean Rung 2 closeout possible instead of another blocked partial.
- **Key risk:** it is machinery work; must stay strictly scoped to what S97 broke, not a Coder-station
  redesign (the freeze rule is watching).

### B — Autopilot Ladder Rung 2 (one-day unattended dogfood, chitra)
- **Goal:** run the ladder now — multi-task, one day unattended on chitra, guards ON; measure zero-leak
  + honest receipts + fidelity-verdict correctness on a founder spot-check.
- **Why pick this:** it is the crown-jewel move and the truest test; lets the run surface the next real
  break rather than pre-guessing it.
- **Key risk:** S97 says it will likely re-hit the Coder-dark wall and produce another blocked partial —
  valuable as evidence, but not a rung *pass* until A lands.

### C — Release-backstop slice (README truth-pass + crate-rename scoping)
- **Goal:** start the 2026-09-15 backstop: retire the stale ~8× receipt claim, fix unverifiable install
  paths, scope the crate rename (current name is taken).
- **Why pick this:** removes the audit's two truth-gaps early; makes "installable by a stranger" nearer.
- **Key risk:** not a ladder run and not a fix-what-broke — bends the freeze rule; better sequenced after
  Rung 2/3 give the README real numbers to tell the truth about.
