# Session 114 — CODE: the fleet's second role, the Fidelity Reviewer

**Verdict: SHIPPED.** Type: CODE. Founder pick **A** at the S113 closeout; "all approved" at kickoff.
Branch: `session-114-fleet-role-reviewer`. 7 atomic commits. 322 lib tests · verify **17/17** ·
demo **10/10** exit 0 · **two independent cold passes** (pass 1 REJECT → fixed → fresh pass 2
ACCEPT), attested `adae11e1…`.

## Goal achieved?

Yes. The independent cold fidelity review this repo has run **47 times by hand** is now a canonical,
scaffolded, governed fleet role. The headline result is what did **not** happen: adding it required
**zero changes to `src/cli/init.rs`**, zero changes to the handoff writer, zero new commands. One
more entry in `fleet::ROLES` and every existing path — scaffold, govern, read back, count — picked
it up. That is the S109 architecture paying off exactly as designed.

## What shipped

| Thing | Where | Note |
|---|---|---|
| The role | `src/fleet/mod.rs` — `fidelity-reviewer` | read-only (`Read, Grep, Glob`); the adversarial contract |
| Per-role tool grant | `Role.tools` | was hardcoded to the Researcher — every future role would have silently inherited web access |
| Role-aware delta | `compute_delta(role, …)` | was hardcoded to the word "researcher" — a Reviewer handoff would have carried the wrong name in its own tracked delta |
| Decision record | `DECISION-007` S114 addendum | three open items closed, each with rejected alternatives |
| Scaffold | `.claude/agents/fidelity-reviewer.md` | copied byte-for-byte out of a fresh `vajra init`, never hand-written |
| Proof | `scripts/verify-session-114.sh` (17) · `scripts/demo-session-114.sh` (10) | behavioural; every negative guard has a positive control |

## The two decisions the prompt demanded in writing

1. **The role key is `fidelity-reviewer`, not `reviewer`.** `K of 8` already counts a Reviewer
   *station*; one word must not mean two things in adjacent lines of one report. Rejected "the role
   IS the station's agent" because it is false — the station passes on an attested artifact
   existing, which a human can produce with no agent at all. `vajra next --role reviewer` now fails
   closed with the known-roles list.
2. **The handoff is a PRE-STAGE INPUT; `sessions/session-NN-review.md` stays the single record of
   record.** Rejected pointer-only (throws away the `source-sha` that makes a handoff evidence) and
   rejected replacing the artifact (trades the attestation + ledger chain for a newer file). The
   code matches: no gate learned to read a handoff, and the role has no write tool.

## Fidelity map (every numbered requirement)

D1 SHIPPED · D2 SHIPPED · D3 SHIPPED · D4 SHIPPED · D5 SHIPPED · D6 SHIPPED · D7 SHIPPED ·
A1–A6 SHIPPED. **13 of 13 SHIPPED.** Full evidence + the reviewers' own words:
`sessions/session-114-review.md`.

## The fakest green (disclosed, not buried)

**The role's text is guarded by presence-greps and nothing else.** Cold pass 2 replaced the whole
system prompt with token soup that told the agent to rubber-stamp — every required substring intact —
re-rendered the scaffolded file, and got verify 17/17, demo 10/10, 322 tests green. The checks guard
the *shape* of the brief, never its *quality*. No check in this repo can.

## What I did NOT build

- No third role, no parallel dispatch, no blocking gate (all non-goals).
- **The role has never been dispatched by name.** Per S111, an agent file written mid-session is
  invisible to that session's Task tool. This session's two cold passes ran as ad-hoc
  `general-purpose` subagents, exactly as every prior session's have. First real by-name dispatch is
  S115 — and that is the only thing that will prove the brief works in the wild.
- `fleet: 2 governed handoff(s)` certifies two contract-valid **files**, never two agents.

## The uncomfortable finding worth carrying

This session's own prompt said the reviewer's brief "is re-typed from memory each time". **That was
partly false** — `reviewer/SKILL.md` (127 lines, scaffolded by the same `vajra init`) had stated the
contract all along, and nobody noticed until an adversarial reader was pointed at the diff. The
first draft therefore shipped a rival second source of the exact thing this session exists to
de-duplicate, and its brief omitted all three output tokens the closeout gate enforces — a
dispatched agent would have produced a review the gate rejected. **A premise in an approved prompt
is not evidence.** Both cold passes earned their cost here; the two-pass pattern is now five
sessions running.

## Next session — three options (A/B/C)

**A. Dispatch the Reviewer for real (close the loop).**
*Goal:* S115 runs its own mandatory cold review through `subagent_type: "fidelity-reviewer"` and
governs the verdict with `vajra next --role fidelity-reviewer --from`, then lands it as the record of
record.
*Why:* it is the only thing that proves the brief works — the role is text until an agent obeys it,
and the gate-shape bug pass 2 found is exactly the class of defect a live dispatch surfaces.
*Risk:* S115 is the mandatory NO-CODE ground truth (`115 % 5 == 0`), so this must ride the GT as
evidence-gathering, not as a code change — or wait for S116.

**B. The overdue paid dogfood — 🔴 since S103, now 11 sessions / ~11 days.**
*Goal:* run real work through `vajra claude` and report the receipt.
*Why:* every "is Vajra-on-Claude good to use?" claim has been unmeasured for eleven sessions; the
cost ledger is the only proof and it is stale.
*Risk:* costs real dollars (fable-5 credits exhausted); measures the launcher, not the fleet.

**C. An opt-in blocking consumption gate.**
*Goal:* let a session declare "this one requires a governed handoff" and fail closed without it.
*Why:* fleet work is advisory end-to-end; nothing fails when findings are ignored.
*Risk:* the obvious way to build false teeth — a gate that checks a file exists is the fakest green
this project keeps re-inventing.

**Recommendation: A**, sequenced into S115's ground truth as live evidence (no code), with the build
half at S116 if it needs one.
