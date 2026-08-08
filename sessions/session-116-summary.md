# Session 116 — CODE: the fleet's third role, the Plan Advisor

**Verdict: ACCEPT (cold review).** Type: CODE. Founder pick **B** at the S115 closeout (over the
report's recommended A: the paid dogfood), then named the role **Planner** specifically; built here
as the distinctly-keyed `plan-advisor`. "All approved" at kickoff. Branch:
`session-116-fleet-role-planner`. 3 atomic commits. 323 lib tests · verify **16/16** · demo **10/10**
exit 0 · one independent cold pass (ACCEPT on the first try), attested
`1b6c0159ad26b268cebef5ac003f4206deb50121b4d9dc4a7937f35fe91e5079…`.

## Goal achieved?

Yes. The fleet's third role — the Plan Advisor — is a `fleet::ROLES` entry, scaffolded, and governed
exactly like roles 1–2. The headline result, again: adding it required **zero changes to
`src/cli/init.rs`, `src/cli/next.rs`, or `src/stations/mod.rs`** — confirmed by tracing all three
(not just asserting it in a doc-comment) and by `vajra init` producing three byte-identical agent
files from a fresh repo. One more entry in the single role source, and every existing path picked
it up, at a THIRD count for the first time.

## What shipped

| Thing | Where | Note |
|---|---|---|
| The role | `src/fleet/mod.rs` — `plan-advisor` | read-only (`Read, Grep, Glob`); proposes `covers: N` citations |
| The `covers: N` contract | `PLAN_ADVISOR_SYSTEM_PROMPT` | states the exact shape `src/planner/mod.rs::cited_criteria` already parses — no new parser, no new grading path |
| Decision record | `DECISION-007` S116 addendum | the key collision resolved in writing, 2 rejected alternatives |
| Scaffold | `.claude/agents/plan-advisor.md` | copied byte-for-byte out of a fresh `vajra init`, never hand-written |
| Proof | `scripts/verify-session-116.sh` (16) · `scripts/demo-session-116.sh` (10) | behavioural; every negative guard has a positive control |

## The one decision the prompt demanded in writing

**The role key is `plan-advisor`, not `planner`.** `K of 8` already counts a Planner *station*
(`src/planner/mod.rs`, S64) — the exact same collision the Reviewer hit at S114 against the Reviewer
station, now hit a second time. Rejected "the role IS the station's agent" (false — the station
grades a recorded `covers: N` marker inside the prompt's own `## Plan` section; a human author can
satisfy it with no agent at all). Rejected the two longer alternative spellings named in the prompt
(`planner-advisor`, `planning-assistant`) in favor of the shorter non-colliding option.
`vajra next --role planner` now fails closed with the known-roles list, exactly as `--role reviewer`
already does.

## Fidelity map (every numbered requirement)

D1 SHIPPED · D2 SHIPPED · D3 SHIPPED · D4 SHIPPED · D5 SHIPPED · D6 PARTIAL (review/summary land in
this closeout commit, necessarily after the review that produces them) · A1 SHIPPED · A2 SHIPPED ·
A3 SHIPPED · A4 SHIPPED · A5 PARTIAL (reviewer traced but did not execute the scripts itself — see
below) · A6 PARTIAL (same reason). **10 of 12 SHIPPED** by the independent reviewer's own count.
Full evidence + the reviewer's own words: `sessions/session-116-review.md`.

**Builder's note on the two execution-related PARTIALs (A5/A6):** the reviewer is read-only
(`Read, Grep, Glob`, no `Bash`) and correctly declined to grade from an unexecuted script. I *did*
run all three in this session, with terminal evidence: `cargo test --lib` → 323 passed, 0 failed;
`bash scripts/verify-session-116.sh` → ALL GREEN (16 pass, 0 fail); `bash scripts/demo-session-116.sh`
→ ALL GREEN (10 pass, 0 fail). This is the builder's own claim, not independently re-run by the
reviewer — stated plainly, not smoothed over.

## The fakest green (disclosed, not buried)

The reviewer named `fleet::tests::plan_advisor_is_registered_with_a_non_colliding_key`'s substring
assertions: it checks that a constant written in this same commit contains phrases also chosen from
that same constant in this same commit — it can only fail if a *future* session deletes the phrase,
never a check on whether the prompt is well-formed or matches what `cited_criteria` actually parses
(I confirmed that match by hand-reading both; the test itself doesn't establish it). A close second:
`verify-session-116.sh`'s `NREJ -ge 2` rejected-alternative count is a keyword tally that would pass
on two vacuous one-liners — the addendum's actual reasoning here is substantive, but the check can't
tell the difference.

## What I did NOT build

- No fourth role, no parallel dispatch, no blocking gate (all non-goals).
- **The role has never been dispatched by name.** Per S111, an agent file written mid-session is
  invisible to that session's Task tool. This session's cold review ran as `fidelity-reviewer` (which
  *was* dispatchable by name, proven at S115) — the Plan Advisor itself is first dispatchable by name
  no earlier than the next session.
- The Plan Advisor's output is not consumed by the Planner station's own gate this session — deferred
  by design (a separate, larger consumption story, mirroring S112's Researcher-handoff arc).
- `fleet: 3 governed handoff(s)` certifies three contract-valid **files**, never three agents.

## Next session — three options (A/B/C)

**A. Dispatch the Plan Advisor for real (close the loop, third time).**
*Goal:* the next session dispatches `subagent_type: "plan-advisor"` by name on a real planning
question and governs the result with `vajra next --role plan-advisor --from`.
*Why:* mirrors exactly what S115 proved for the Reviewer — a role is text until an agent obeys it,
and by-name dispatch is only proven for the next-session case, never assumed.
*Risk:* low; S117 (`117 % 5 != 0`) is not a forced NO-CODE session, so this can ride as a normal
build session's live evidence.

**B. The overdue paid dogfood — 🔴 since S103, now 13 sessions / ~13+ calendar days.**
*Goal:* run real work through `vajra claude` and report the receipt.
*Why:* every "is Vajra-on-Claude good to use?" claim has been unmeasured for thirteen sessions
running; the cost ledger is the only proof and it keeps getting deferred by founder choice.
*Risk:* costs real dollars (fable-5 credits exhausted per S102); measures the launcher, not the fleet.

**C. Consume the fleet's handoffs into their stations (start with the Planner).**
*Goal:* wire `fleet::read_handoff(plan-advisor)` into `src/planner/mod.rs` so a governed plan-advisor
handoff can inform (never auto-author) the station's own coverage check — the deferred non-goal named
explicitly in this session's prompt.
*Why:* three roles now produce advisory-only output with no consumer; this is the first real
consumption arc since S112's Researcher-handoff read side.
*Risk:* the biggest of the three — genuinely new station-side logic, not a rendering of existing
machinery like S109/S114/S116 were.

**Recommendation: A** — the by-name dispatch proof is cheap, low-risk, and this project's own pattern
(S111 → S115) shows it is the only thing that actually validates a role's brief in the wild, not its
shape.
