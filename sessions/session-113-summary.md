# Session 113 — CODE: make fleet work visible to the counter, then choose the second role

**Verdict: SHIPPED.** Type: CODE (founder pick **A** at the S112 closeout; "all approved" at kickoff).
Branch: `session-113-fleet-counter-visibility`.

## Goal achieved?

**Yes.** `vajra next --stations NN` could not see the fleet at all: a session that dispatched a named
agent, governed its findings and consumed them downstream scored exactly the same `K of 8` as one
that did none of it (flagged at the S110 ground truth, carried unfixed through S111 and S112).

The counter now reports fleet work **beside** `K` — design shape **(c)**, picked at kickoff and
recorded in the prompt's `## Design`:

```
  5 of 8 stations passed (derived from each gate's evidence — read-only, nothing executed)
  fleet: 1 governed handoff(s) — researcher (derived from the validated handoff on disk;
         reported beside K, NOT counted in it)
```

**K's meaning is unchanged, and that is checked, not claimed:** the verify script strips the fleet
line from the "after" output and requires the remainder to be **byte-identical** to the "before"
output. So S74's K and S113's K mean the same thing by construction — no 9th station (would break
the 8-station spine), no folding into an existing station's verdict (old and new K would look
identical while measuring different things).

## Evidence

| What | Evidence |
|---|---|
| Code | `src/stations/mod.rs` — `FleetEvidence`, `fleet_evidence()`, `format_fleet_line()`; `StationReport.fleet` |
| Derived, never asserted | evidence comes from `fleet::read_handoffs` — the handoff is **parsed and validated** off disk; a malformed file is named and counts as nothing |
| Tests | **316 lib tests** (313 → 316; 3 new, all in `stations::tests`), `cargo fmt`/`clippy` clean |
| Verify | `scripts/verify-session-113.sh` — **13/13 ALL GREEN** |
| Demo | `scripts/demo-session-113.sh` — **7/7 ALL GREEN**, exit 0, all 4 required markers |
| Real data | this repo: `--stations 111` shows the fleet line (S111's handoff came from a real by-name subagent dispatch); `--stations 110` says nothing about the fleet |
| Second role | `docs/decisions/DECISION-007-agent-fleet.md` → **S113 addendum: the Reviewer**, chosen with evidence, not built |

## Fidelity map — every numbered requirement in `prompts/113-task-fleet-counter-and-second-role.md`

### Deliverables

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| 1 | Fleet work visible in `--stations NN`, derived from real evidence on disk | **SHIPPED** | `fleet_evidence()` calls `fleet::read_handoffs`; verify `e2e-counter`, `real-handoff-beside-k` |
| 2 | K-of-8 stays comparable across sessions | **SHIPPED** | shape (c); verify strips the fleet line and asserts byte-equality with the pre-handoff output |
| 3 | Recorded decision on the second fleet role, as a DECISION-007 addendum | **SHIPPED** | S113 addendum — the Reviewer; 5 pieces of repo evidence + 4 rejected alternatives + disclosed limits |
| 4 | `verify-session-113.sh` + `demo-session-113.sh`, both green, both proving behaviour | **SHIPPED** | 13/13 and 7/7; same repo, same command, output differs only by the fleet line |
| 5 | `sessions/session-113-summary.md` + independent cold review | **SHIPPED** | this file + `sessions/session-113-review.md` |

### Acceptance criteria

| # | Criterion | Verdict | Evidence |
|---|---|---|---|
| 1 | Surfaces fleet evidence when a governed handoff exists, nothing new when it does not | **SHIPPED** | `e2e-counter` (same tempdir, before/after); real data S111 vs S110 |
| 2 | Evidence derived from the validated handoff — malformed must not read as fleet work | **SHIPPED** | `fleet_evidence_names_a_malformed_handoff_and_never_counts_it`; verify + demo case 3 |
| 3 | K-of-8 unchanged in meaning, or the change explicitly recorded | **SHIPPED** | unchanged — preserved by construction, asserted byte-for-byte; stated in `## Design`, STATE and ROADMAP |
| 4 | Second role chosen, reasoning recorded, no role built | **SHIPPED** | addendum; `second-role-chosen-only` check fails if a `reviewer` role or `.claude/agents/reviewer.md` appears |
| 5 | `cargo test --lib` green; verify + demo pair exit 0 | **SHIPPED** | 316 passed; 13/13; 7/7 |
| 6 | Independent cold review (prompt + diff only), per-requirement, fakest green disclosed | **SHIPPED** | `sessions/session-113-review.md` |

### Non-goals — honored

- The second role was **not built** (no `fleet::ROLES` entry, no `.claude/agents/reviewer.md`) — and
  a verify check fails if either appears.
- No 8th command (`no-eighth-command` green) · no blocking gate (the fleet line reports, nothing
  fails) · no handoff-format or dispatch change · no retroactive K "fixes".

## What I did NOT build

- **Nothing blocks.** A session can still ignore a governed handoff completely; the counter now says
  it exists, and that is all. The opt-in blocking gate stays deferred (S112 candidate C).
- **No consumption signal.** The line proves a handoff was **written and is contract-valid**, not
  that any station actually read it. "Governed" ≠ "used".
- **The Reviewer role itself** — chosen, not built (an explicit non-goal).
- **No K credit for fleet work**, by design. If the founder later wants fleet work to *count*, that
  is a deliberate K redefinition and needs its own decision.

## The fakest green here

**The fleet line counts ARTIFACTS, not agents.** It attests that a contract-valid handoff file
exists at the session's path — nothing in it proves a real subagent produced those findings. Anyone
who runs `vajra next --role researcher --from notes.md` with hand-typed notes gets the same line.
S111's proof of by-name dispatch lives in that session's evidence trail, not in this counter, and the
counter cannot re-derive it. Second (smaller): "1 governed handoff(s)" is a count of registered
roles with a valid file — with exactly one role in `fleet::ROLES` today, the number can only ever be
0 or 1, so the plural machinery is untested against a real second role.

## Cost

`$0` metered for the build (no `vajra claude` run). The cold-review subagent's tokens roll into this
interactive session's receipt, unitemized — the same structural reason as S109/S111/S112
(`scripts/check-subagent-cost-fields.sh`: no local subagent transcript carries a cost field).

## Small correction to carry into closeout

STATE.md recorded **315** lib tests at S112; the real count on `main` was **313**
(`git grep -c '#\[test\]' main -- 'src/*'`). Now **316**. Corrected in STATE at closeout.

## Next session — 3 options (A/B/C)

**A. Build the Reviewer role (the second fleet role, now chosen).**
- *Goal:* scaffold `.claude/agents/reviewer.md` from `fleet::ROLES` and govern its verdict as a
  handoff, so the cold review every session already runs stops being a hand-typed prompt.
- *Why pick this:* it is the fleet's busiest real job (46 reviews on disk), mandated by DECISION-002,
  and its output is already gated, attested and ledgered — the shortest path from "role" to "teeth".
- *Key risk:* the review verdict already has a governed home (`sessions/session-NN-review.md`);
  adding a handoff could create a second, competing record of the same judgment.

**B. The overdue paid dogfood run (`vajra claude`).**
- *Goal:* run a real governed session through the launcher — 🔴 stale since S103, now 10 sessions
  and ~10 calendar days.
- *Why pick this:* every "is Vajra good to use?" claim is unmeasured until this runs; mechanism tests
  do not reset it.
- *Key risk:* costs real dollars (fable-5 credits exhausted), and a run that goes badly consumes the
  session with debugging rather than shipping.

**C. The opt-in blocking consumption gate.**
- *Goal:* let a session declare "this one requires a handoff", and fail closeout when it is missing
  or unread.
- *Why pick this:* turns advisory fleet evidence into enforcement — the product's whole thesis.
- *Key risk:* the classic false-teeth trap — a gate that fires on sessions that legitimately need no
  research, which is exactly why S112 and S113 both left it advisory.
