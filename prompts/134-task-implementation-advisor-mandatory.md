# Session 134 — CODE: the implementation-advisor becomes mandatory, as a CALL SITE

> **Status:** APPROVED — the founder's locked sequence from the S132 closeout ("make the
> design-advisor and the implementation-advisor mandatory … and if we want to skip we have to skip
> with a valid reason"), presented and confirmed as option A of three at the S133 closeout.
>
> Founder directive in force (S118): README.md / VISION.md claims are the target spec, not a status
> report. Do NOT soften them.

## Type

CODE. Max 2 assumptions, 2 retries, 1 story, ~2h, new chat. One story: the `implementation-advisor`
becomes the fleet's THIRD mandatory role, on S133's mechanism, **without a third copy of it**.

## Why this session

S131 made `fidelity-reviewer` mandatory — a cop that grades finished work at the END. S133 made
`design-advisor` mandatory — the first advisor that can change what gets BUILT — with a recorded,
substantive, visible skip as the only way past it. `implementation-advisor` is the second of the
two the founder named, and it is the one that shapes HOW a recorded plan step is built.

**But the real reason to do it now is that it is the falsification test for S133's central claim.**
S133 asserts that `src/mandate/mod.rs` is generic over a `fleet::Role` and that a second mandatory
advisor is "a call site and not a third copy of the ladder". That is a claim in a comment until a
second role actually rides it. If S134 finds itself editing the ladder, S133's genericity was
decoration.

**The risk this session must hold in view, named in S133's own summary:** S134 is nearly free,
which is exactly what makes it look like progress. Two — now three — mandatory roles do not make
the fleet USED. If S134 ships without touching F2f, this repo will have three gates that prove a
dispatch happened and still nothing that observes whether any advice changed the work.

## Goal

`implementation-advisor` joins `design-advisor` as a mandatory role on the SAME mechanism: a
session cannot close without either its provenance-verified governed handoff or a recorded,
substantive reason. `src/mandate/mod.rs`'s ladder is not edited to make this work — only extended
at its call-site table.

## Deliverables

- **The second call site.** `implementation_advisor_gate` (or a table the two share), riding
  `vajra next` as its own sub-flag alongside `--check-design-handoff`, wired into the closing
  advance AND `scripts/verify-closeout.sh`. **No `VAJRA_SKIP_*` for it either** — the recorded
  reason IS the override, and that is the whole point of the pattern being copied.
- **Proof the mechanism was REUSED, not re-implemented.** State it as a measurable: the diff to
  `src/mandate/mod.rs`'s ladder logic (`mandate_gate`, `parse_skip_marker`,
  `classify_marker_value`) should be zero or near-zero, and the session must SAY what it actually
  was rather than claiming reuse in prose. If the ladder had to change, say why — that is a real
  finding about S133, not a failure of this session.
- **F2e — decided, not carried.** Either fold `src/fidelity/mod.rs`'s S131 gate into `mandate` so
  there is ONE ladder for all three mandatory roles, or record in `## Design` why not. S133 left it
  because its own acceptance criterion forbade touching S131's gate; S134 has no such constraint,
  so carrying it a second time needs a reason on the record.
- **F2g — the `maturity: L1` escape, probed LIVE.** It is the last agent-reachable path that turns
  these gates advisory at the closing advance, `.ai/CONSTRAINTS.yaml` is agent-writable and tracked,
  and today it is prose-only in the module header. Drive it once in the verify suite and record
  what it actually does.
- **A falsifiability fixture** covering the new call site in the same five directions S133 used,
  each probe asserting its own pattern matched (S127), failing for the right reason (S122), with
  positive controls (S132). Add one NEW direction: prove the two roles' gates are INDEPENDENT — a
  session that satisfies one does not thereby satisfy the other.
- **Dogfooded on its own session:** S134 must pass BOTH mandates by real use — a real
  `design-advisor` dispatch AND a real `implementation-advisor` dispatch, landed as governed
  handoffs. If S134 needs a reasoned skip for either, say so plainly and say why.
- `scripts/verify-session-134.sh` + `scripts/demo-session-134.sh`, both exit 0, printed check-class
  tally.
- `sessions/session-134-summary.md` + exactly 3 ranked next candidates.

## Acceptance (testable, EARS-style)

1. WHEN a session at/after the threshold records neither an `implementation-advisor` handoff nor a
   reason THEN the gate BLOCKS, naming what is missing and both ways to satisfy it.
2. WHEN a session records `implementation-advisor: skipped — <substantive reason>` THEN the gate
   PASSES and PRINTS the reason — no new grammar was needed to make this work.
3. WHEN an `implementation-advisor` handoff exists but its provenance does not independently
   re-verify THEN the gate BLOCKS.
4. The two mandates are INDEPENDENT: satisfying the `design-advisor` gate does not satisfy the
   `implementation-advisor` gate, and vice versa. Driven live, both directions.
5. No environment variable satisfies or bypasses the new gate, and the same two limits are recorded
   rather than implied (`VAJRA_CLOSEOUT_WAIVER`, `maturity: L1`).
6. The ladder logic in `src/mandate/mod.rs` is REUSED: the session reports the actual line-diff to
   `mandate_gate` / `parse_skip_marker` / `classify_marker_value`, and explains any non-zero number.
7. F2e is DECIDED — either `fidelity_gate` folds into `mandate`, or `## Design` records why it
   stays separate. Not carried silently a second time.
8. F2g is PROBED LIVE — the verify suite drives the `maturity: L1` path once and records what it
   does to these gates.
9. Traced, not asserted: `K of 8`, the 7 commands, and S131/S132/S133's gates are unchanged.
10. `verify-session-134.sh` and `demo-session-134.sh` both exit 0 with a printed check-class tally.
11. S134's own session satisfied BOTH mandates, and the summary says by which route (dispatch or
    recorded skip) for each.
12. Independent cold `fidelity-reviewer` verdict ACCEPT, attested. The judge of any `obeyed:`
    disposition may NOT be the role that made the recommendation — and note that making
    `implementation-advisor` mandatory means it is now likely to BE one of the advisors, so the
    judge must be a THIRD role again (S132's rule, one turn further round).
13. The summary states plainly what is still NOT fixed — in particular whether three mandatory
    roles have made the fleet any more USED, and what number would show it either way.

## Plan (ordered — cite the acceptance criteria each step covers)

1. Dispatch `design-advisor` on this session's own design question (share one sub-flag or take a
   second; fold F2e or not) and land its handoff before any code. covers: 7, 11
2. Record the decisions and the rejected alternatives in `## Design`. covers: 7
3. Add the second call site and its sub-flag; wire the closing advance and the closeout script.
   covers: 1, 2, 3, 5
4. Decide F2e; fold or record why not. covers: 7
5. Prove reuse: measure the ladder diff and report the real number. covers: 6
6. Falsifiability fixture, five directions plus the independence direction. covers: 4
7. Probe `maturity: L1` live. covers: 8
8. Prove nothing else moved. covers: 9
9. `scripts/verify-session-134.sh` + `scripts/demo-session-134.sh`. covers: 10
10. Dispatch `implementation-advisor` for real on this session's own build question. covers: 11
11. Cold `fidelity-reviewer` pass, then a separate third-role judging dispatch. covers: 12
12. Say in the summary what is still not fixed, including whether the fleet is any more used.
    covers: 13

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
- step 4 — done: <sha>
- step 5 — done: <sha>
- step 6 — done: <sha>
- step 7 — done: <sha>
- step 8 — done: <sha>
- step 9 — done: <sha>
- step 10 — done: <sha>
- step 11 — done: <sha>
- step 12 — done: <sha>

## Advice (every recommendation from this session's advisors, answered)

(Filled during S134. `vajra next --check-advice 134` BLOCKS the close until every recorded
recommendation is answered, and `vajra next --check-obeyed 134` BLOCKS until every `obeyed:` claim
carries an independent judgment from a role that is not the one that gave the advice.)

## Design

- design-significant: yes — this makes a third fleet role mandatory and either merges or
  permanently forks the mandatory-role ladder. Getting the merge wrong propagates to every future
  mandatory role.
- Spine record to cite: `DECISION-007` and its **S133 addendum** (the mandatory-role + recorded-skip
  pattern) and its S131 addendum (provenance) — verify both exist before citing them.
  `DECISION-002` for why an advisor informs and never certifies its own work.
- **Open design question for S134 to resolve and record here:** does the second mandatory role take
  its OWN sub-flag (`--check-implementation-handoff`), or does one flag take a role argument? S133
  chose a dedicated flag for `design-advisor` on the grounds that two gates checking genuinely
  different things should not share a command — but these two check the SAME thing about different
  roles, which is a different situation. Decide, and record the loser's reason.
- **Second open question:** F2e. One ladder for all three mandatory roles, or two? S133 recorded the
  duplication as debt precisely so this session would have to answer it on the merits.

## Non-goals (not built this session)

- **Not F2f** (the rubber-stamp detector — WARN when a handoff's `captured:` postdates the first
  code commit). It is the highest-value open item and it is a separate story; name it in the
  summary rather than letting it drift.
- Not the other six roles. The founder named two advisors; this is the second.
- Not F2 (content-binding), F2a (judge identity), F2b (the regress), F2c (three selection rules).
- Not the fresh-scaffold paid dogfood — **still the oldest un-run item on the roadmap** (last paid
  dogfood S124, 2026-08-20). Say so plainly in the summary rather than letting it fall off.
- Not the fourth fork (`TPL_CONSTRAINTS`). No release, no crates.io action.

## Guardrails

- Un-forgeable commit marker on every commit, session number 134. Max 3 files per atomic commit.
- A check that cannot evaluate FAILS (S69). A fixture must fail for the RIGHT reason (S122), a probe
  must assert its own pattern matched (S127) including positive controls (S132), and a rename
  control is meaningless unless the unit tests bind to VALUES rather than message text (S133).
- **Do not ship an env-var escape**, and do not weaken S133's by adding one "for symmetry".
- **Do not edit the ladder to make the second role fit.** If it needs editing, that is the session's
  most interesting finding — report it, do not hide it inside a refactor.
- When a brief or a prompt quotes fence syntax, never let a line START with the fence characters —
  it silently hides every `rec N` after it (S133, learned live).
- Attest LAST (S69/S131): recompute `--inputs-sha 134` after every edit to this prompt; two
  consecutive runs must agree. Run the full `verify-closeout.sh` on the branch BEFORE merging (S83).

## Delta (vs ROADMAP — OpenSpec markers)

- ADDED: `implementation-advisor` as the fleet's THIRD mandatory role, on S133's mechanism; a live
  probe of the `maturity: L1` escape (F2g).
- MODIFIED: `.ai/ROADMAP.md` F2e — decided rather than carried; what a session must have before it
  can close.
- UNCHANGED: the 8 stations, the 7 commands, `K of 8`'s derivation, S131's Fidelity gate, S132's
  Obeyed gate, S133's Mandate ladder, and the other six roles' optional status.
