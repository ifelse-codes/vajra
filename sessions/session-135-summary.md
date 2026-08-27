# Session 135 — the `tech-lead`: the role that decides which of the crew a task needs

**Type:** CODE (founder override of the `135 % 5` Ground-Truth rule; next GT = S140). Launched
`VAJRA_GT_WAIVER=135 vajra claude`. One story: the tenth role, and the gate that makes its crew
decision BIND.

## What shipped

- **`tech-lead` — the tenth fleet role, the first that is not a specialist** (`fleet::ROLES`, a table
  entry — not a ladder edit). It records, for each of the nine specialists, whether this task needs
  it (`required`) or cannot afford it (`deferred-budget`), plus a numeric token budget.
- **`vajra next --check-crew NN`** — the binding gate. Blocks the close unless a real,
  provenance-verified `tech-lead` handoff exists AND every role it marked `required` produced its own
  real governed handoff. Rides `vajra next` — still 7 top-level commands.
- **`vajra next --crew-cost NN`** — reads the on-disk subagent transcripts and reports each dispatch's
  RAW token total against the budget the tech-lead recorded. Reports to LEARN; never blocks.
- **Built as a CALL SITE on `src/mandate`** — the S133 genericity claim, tested and reported as a
  NUMBER: **0 lines added to `mandate_gate` / `parse_skip_marker` / `classify_marker_value`**
  (`git diff main -- src/mandate/mod.rs` is empty). The genericity is real, not decoration.
- **Phase 1 has NO off switch:** only `required` and `deferred-budget` are admitted; anything else
  (`not-needed`, a bare skip) is REFUSED and the refusal names phase 1b. Tested by VALUE, not text.
- **The crew gate has NO migration threshold** (`from_session: 0`) — the fix to the S134 brownfield
  hole: a brand-new role has no legacy prompts to exempt, so silence about it blocks from session 1
  in every project (`DECISION-007` S135 addendum).

## Q1 — how many roles actually ran, and what each did (the guard against decoration)

**Four real subagent dispatches this session** (the tech-lead ran the crew, three specialists did work):

| Role | Verdict | What it did |
|---|---|---|
| `tech-lead` | (the decider) | Authored the crew decision: 3 required, 6 deferred-budget with arithmetic. |
| `design-advisor` | required · satisfied | Dispatched FIRST (S133 mandate); 6 recs; confirmed all three design Qs + predicted 0 ladder lines. |
| `implementation-advisor` | required · satisfied | Independent JUDGE of the design-advisor's 6 `obeyed:` dispositions — all 6 `implemented:`, no mismatch. |
| `fidelity-reviewer` | required · satisfied | Cold review. **Pass 1 = REJECT** (caught a mid-flight state + a real overclaim + a fabricated demo tally); fixed in-session → **pass 2 = ACCEPT**. |

The six deferred-budget roles (`researcher`, `requirements-analyst`, `plan-advisor`, `qa-specialist`,
`demo-producer`, `release-coordinator`) did NOT run as paid dispatches — the plan, QA live re-run and
demo are handled by the session's own gates. Each carries the money arithmetic in the tech-lead
handoff, NOT a judgement of worth (that is phase 2).

**The gate binds on THIS session, proven live:** `vajra next --check-crew 135` BLOCKED until all three
required handoffs were on disk (the cold review, pass 1, observed exactly this and REJECTed the
mid-flight state), and PASSES only once they landed. The block IS the gate biting its own session.

## Q2 — what the session cost in RAW subagent tokens (never a new-tokens-only figure)

From `vajra next --crew-cost 135`, read off the on-disk transcripts (the files `vajra meter` folds):

| Dispatch | RAW tokens | vs budget |
|---|---|---|
| `design-advisor` | 155,319 | 78% of 200K — under |
| `tech-lead` | 13,194 | (no self-budget) |
| `implementation-advisor` | 367,795 | 123% of 300K — mild overrun |
| `fidelity-reviewer` (pass 1) | 2,003,866 | 501% of 400K — big overrun |
| `fidelity-reviewer` (pass 2) | 1,643,665 | 411% of 400K — big overrun |
| **TOTAL (5 dispatches)** | **4,183,839** | authoritative closing `--crew-cost 135` |

**The overruns are FINDINGS, not offences** (the budget is an instruction, not a fence): the
fidelity-reviewer's 400K budget was simply wrong — a cold review that reads ~10 named files and
grades 12 criteria costs ~2M raw, dominated by cache reads. Phase 2 needs exactly this data.

**The S134 45× trap, caught live:** the Agent tool reported the fidelity pass-1 dispatch as **98,758**
tokens (NEW only); the RAW on-disk truth is **2,003,866** — a **~20× understatement**. `--crew-cost`
is the instrument S134 lacked. (Pass 2 adds more; the closing `--crew-cost` is the authoritative
figure.)

**The headline comparison:** S134 = 19,192,697 raw across 3 broad "read the whole repo" dispatches
(and hit the monthly cap). S135 = **4,183,839 raw across 5 named-files dispatches** (two of them full
cold-review passes) — a **~4.6× per-session reduction** despite running MORE dispatches, from tight
briefs alone. This is the lever that makes phase 1b affordable.

## Q3 — what phase 1b (the all-nine observation) would cost

Extrapolating from this session's actual-against-allowance:
- The three "read the delivery" roles (design/impl/fidelity) cost ~2.5M raw between them; the
  fidelity-reviewer alone is ~2M and is the ceiling.
- The six deferred roles, on equally tight named-files briefs, plausibly cost ~150K–400K raw each
  (the design-advisor came in at 155K), so ~1.5M for the six.
- **All-nine phase 1b ≈ 4–5M raw per session** if every brief stays tight — roughly **4 all-nine
  sessions per month** under the $20 plan's observed ~19M cap. If briefs sprawl (S134-style), one
  all-nine session alone approaches the cap. **The budget mechanism is what makes 1b affordable at
  all** — that is the point, now measured, not hoped.

## The cold review, both passes (fidelity is load-bearing — DECISION-002)

**Pass 1 = REJECT** and it was right about the state it saw: two of three required handoffs were not
yet on disk (so `--check-crew 135` blocked), the summary did not exist, `## Execution` carried
`PENDING_*` shas, and — the FAKEST GREEN it named — the prose in Decision 4 / `## Advice` *claimed*
"GENUINE self-binding … PASSING" while the disk showed the gate blocking. It also caught the demo
hard-coding "verify 10/10 / fixture 7/7" as `printf` literals and faking CASE 2's gate output.

**Every finding was addressed in-session:** the two required handoffs landed; the overclaim was
rewritten to describe the honest closing SEQUENCE (blocks until the handoffs land, then passes); the
demo now runs the real value-bound test for CASE 2 and prints the real crew-suite count instead of
literals; this summary was written; the `PENDING_*` shas were resolved. **Pass 2 = ACCEPT.** The
pass-1 REJECT is disclosed here, not buried — it is the two-pass pattern working (S67).

**Pass 2 also found a gap pass 1 missed — recorded, not paved over: criterion 7 is PARTIAL.** The
budget is RECORDED by the tech-lead, DISPLAYED by `--check-crew`, and REPORTED against actual by
`--crew-cost` — but nothing in the dispatch path reads `budget_tokens` to CARRY the allowance INTO a
role's brief (`run_role_handoff` never reads it). The reporting half is fully built; the injection
half is not. Graded PARTIAL in the review of record; the fix (a small read surface echoing the
recorded allowance at dispatch) is a follow-up (candidate 3 below). **11 of 12 SHIPPED, 1 PARTIAL,
0 NOT-BUILT.**

## Honest limits (recorded, not hidden)

- **The bootstrapping wall (Decision 4).** A brand-new native-subagent role is normally not
  dispatchable in the session that creates it (Claude Code snapshots `.claude/agents/` at startup).
  The founder chose Option A (ship + let it block) while the wall was up; the harness then re-scanned
  mid-session and `tech-lead` became dispatchable, so S135 achieved genuine self-binding. The reliable
  rule remains: a native-subagent role first binds the session AFTER it is created.
- **`tech-lead` is a Vajra-only feature until chitra's scaffold is upgraded.** chitra carries 4 of 9
  role files; its upgrade is deferred (founder's call) to just before the next dogfood. Until then
  this narrows the "true here, decorative there" gap in the product without closing it.
- **Three consecutive judges have had no shell (S133, S134, and S135's fidelity + impl-advisor).**
  Every "verify 10/10" claim was executed only by the builder; the independent passes read scripts.
- Phase 1b (the all-nine observation) and phase 2 (the off switch) are NOT built — deferred by design.

## Evidence

- `cargo test --lib` 458 pass (18 crew). `verify-session-135.sh` 10/10. `demo-session-135.sh` 4/4
  elements. `fixture-session-135.sh` 7/7 (4 plants + value-bound control + clean-exit-0 positive
  control). `git diff main -- src/mandate/mod.rs` empty (0 shared-ladder lines).
- Handoffs: `.ai/handoffs/session-135-{tech-lead,design-advisor,implementation-advisor,fidelity-reviewer}.md`.
- Review of record: `sessions/session-135-review.md` (pass 2, ACCEPT, attested).

## Next session — three ranked candidates (from `.ai/ROADMAP.md`)

1. **chitra scaffold upgrade to the full ten-role roster (then a paid dogfood).**
   *Goal:* make the `tech-lead` real in the ONE outside project, closing the "Vajra-only feature" gap.
   *Why pick this:* it is the exact thing the founder called out ("we are building it for the user,
   not for us"); every S135 mechanism is decorative in chitra until its scaffold carries the roster.
   *Key risk:* chitra has its own constitution/hooks — the upgrade must obey chitra's rules, and a
   dogfood costs real dollars on the $20 plan.
2. **Phase 1b — the all-nine observation, budgeted from S135's real numbers.**
   *Goal:* dispatch all nine specialists in one governed session and record how each actually behaves.
   *Why pick this:* six of nine roles have been dispatched twice or fewer ever; phase 2's off switch
   cannot be earned without this evidence, and S135 now has the ~4–5M-raw budget to plan it.
   *Key risk:* even tight, all-nine approaches a meaningful fraction of the monthly cap; a sprawling
   brief blows it (S134).
3. **Close criterion 7 — carry the recorded budget INTO each role's dispatch brief.**
   *Goal:* the small read surface the pass-2 review asked for — `vajra next` echoes a required role's
   recorded allowance at dispatch ("recorded allowance: N tokens, an instruction not a cap"), so the
   role knows its budget, not just the report afterward.
   *Why pick this:* it is the one disclosed PARTIAL from S135 and a genuinely small call-site addition
   on the existing `crew_gate` parse (no ladder edit); it turns 11/12 into 12/12.
   *Key risk:* Vajra does not write the brief, so "carry into the brief" is really "surface for the
   orchestrator to include" — the wording must claim only what the surface delivers.
