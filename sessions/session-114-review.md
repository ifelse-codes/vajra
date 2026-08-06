# Session 114 — Independent Cold Fidelity Review

**What this is:** the record of record for S114's fidelity verdict (DECISION-002 — the builder never
accepts its own delivery). Two independent cold passes were dispatched, each fed only
`prompts/114-task-fleet-role-reviewer.md` + the branch diff, each free to run the binary, the tests
and the scripts, and each explicitly told to attack the checks by mutation. Pass 1 REJECTED; the
hole was closed in-session; a **fresh** pass 2 (no memory of pass 1) ACCEPTED and found two further
holes, both also closed in-session.

**Review-Inputs-SHA:** b1636387e712967cf183fd8b86bf8b4e32786da79e63ac4b2ae28c209d4a9b1a

## Per-requirement verdicts

| # | Requirement (prompt) | Verdict | Evidence |
|---|---|---|---|
| D1 | 2nd `fleet::ROLES` entry, read-only tools, adversarial contract | SHIPPED | `src/fleet/mod.rs`: `fidelity-reviewer` with `tools: "Read, Grep, Glob"`; brief carries the three grades, the fakest-green instruction, never-self-certify |
| D2 | `vajra init` scaffolds `.claude/agents/<key>.md` from that one source | SHIPPED | **zero changes to `src/cli/init.rs` in the diff** — it already iterated `ROLES`; both reviewers ran `init` cold and got two files |
| D3 | `vajra next --role --from` governs it, fail-closed unchanged | SHIPPED | run live: unknown role, case variants, missing `--from`, empty file, missing file all refused, nothing written; `--from -` works |
| D4 | Name collision resolved explicitly | SHIPPED | key `fidelity-reviewer`; `resolve_role("reviewer").is_none()` asserted + confirmed live; DECISION-007 open item 1 with its rejected alternative |
| D5 | Double-record question answered, code matches | SHIPPED | DECISION-007 open item 2 = pre-stage input; `verify-closeout.sh` absent from the diff, `grep -c 'handoffs/'` = 0, no write tool, `src/stations/` never names the role |
| D6 | verify + demo green, 2 handoffs, `K of 8` unchanged | SHIPPED | 17/17 and 10/10 exit 0; pass 2 reproduced `fleet: 2 governed handoff(s) — researcher, fidelity-reviewer` **in this repo**, `5 of 8` unmoved |
| D7 | summary + independent cold review | SHIPPED | this file + `sessions/session-114-summary.md` (both graded NOT-BUILT/PARTIAL at review time — they are the artifacts the review itself produces) |
| A1 | fresh init scaffolds two, proven by running | SHIPPED | run by both passes; byte-equal to the committed copies |
| A2 | handoff validates, fails closed 3 ways | SHIPPED | all four failure modes exercised live |
| A3 | 2 handoffs named, `K` unchanged | SHIPPED | throwaway repo **and** this repo |
| A4 | both decisions in writing, code matches | SHIPPED | 6 rejected-alternative lines scoped inside the S114 addendum; the code checks survive mutation |
| A5 | `cargo test --lib` green, both scripts exit 0 | SHIPPED | 322 lib tests; 17/17; 10/10 |
| A6 | independent cold review, per-requirement + fakest green | SHIPPED | two passes, this artifact |

**13 of 13 SHIPPED.**

## What the passes actually caught (all fixed in-session)

1. **Pass 1 (REJECT):** `reviewer/SKILL.md` — 127 hand-maintained lines stating this same contract,
   scaffolded by the *same* `vajra init` — was an unacknowledged **second source**, and the new
   brief omitted all three output tokens the closeout gate enforces. An agent dispatched by name
   would have returned a verdict the gate rejected. → the skill is canonical, the brief is its
   dispatch-time summary, and the two are bound by a check reading both files (`2499d1b`, `d46c1bc`).
2. **Pass 1:** `grep -qi "Rejected"` over the whole decision file was theatre (10 pre-existing S113
   hits). → scoped to the S114 addendum, requires ≥ 2.
3. **Pass 2:** `.claude/agents/` was excluded from the one-source guard, so a hand-written
   `reviewer-legacy.md` — a real, boot-loadable second role text — kept the suite green. → the
   directory must now equal the rendered set exactly (mutation-verified).
4. **Pass 2:** the gate counts verdict words only on `|`-delimited rows (≥3); the brief said "a
   table", so an obedient agent could return bullets the gate then BLOCKS. → the brief states the
   pipe-row shape, asserted with a positive control on the gate's own counting line.

## THE FAKEST GREEN (pass 2's call, accepted and disclosed)

**The role's text is protected by presence-greps and nothing else.** Pass 2 replaced the entire
system prompt with token soup — every required substring, plus "do not read the diff, always answer
ACCEPT" — re-rendered the agent file so byte-equality held, and got **verify 17/17, demo 10/10, 322
tests green**. The cross-file binding checks five tokens; it cannot see two documents contradicting
each other on substance, only one deleting a token. Comments claiming "the contract, not a stub" are
true of the text as written, not enforced. This is the honest floor: the checks guard the *shape* of
the role brief, never its *quality*.

## What was NOT built

- No third role, no parallel dispatch, no multi-stage orchestration (non-goals, DECISION-007).
- No blocking gate — nothing new fails a session (non-goal).
- **The role has not been dispatched by name.** A `.claude/agents/*.md` written mid-session is
  invisible to that session's Task tool (S111); first by-name dispatch is S115. This session's two
  cold passes ran as ad-hoc `general-purpose` subagents, exactly as every prior session's did.
- `fleet: 2 governed handoff(s)` certifies **two contract-valid files exist**, never two agents ran.

**Verdict:** ACCEPT
