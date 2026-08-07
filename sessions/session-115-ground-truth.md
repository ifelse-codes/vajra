# Session 115 — Ground Truth (NO-CODE)

**Branch:** `session-115-ground-truth` · **Scope audited:** S111–S114 · **Type:** mandatory GT (`115 % 5 == 0`)

## Lens-A Verdict: **PARTIAL PASS**

The fleet arc (S109→S114) is real and now proven live, not just on paper — this session closed the
last open "is it real?" question by dispatching the new role by name and watching it work. But the
product's central promise — *leave your agent working for days, come back, trust the result* — has now
gone **12 sessions / ~11 days unmeasured**, the longest dogfood gap since the metric existed. Building
continues to be easier than proving. That imbalance, not any single defect, is why this is PARTIAL
and not PASS.

---

## The one live opportunity — dispatch by name: RESOLVED, and it WORKS

**Finding: the S111 boot-snapshot limitation does NOT block S115.** `subagent_type: "fidelity-reviewer"`
resolved on the first try, in this fresh session, with no ad-hoc `general-purpose` fallback. The two
claims the S114 closeout deliberately held apart are now both answered:

| Claim | Status |
|---|---|
| "the name appears in the agent list" | Confirmed at S114 close (not tested there, correctly) |
| "a dispatch by that name resolves to this role" | **Confirmed NOW, live, in this session** |

Tool call recorded: `subagent_type: fidelity-reviewer`, 107,664 subagent tokens, 14 tool uses, 234.8s.
The subagent read `reviewer/SKILL.md` (the canonical contract), the S114 prompt, and the S114 diff
unassisted, and returned an independent grade.

**What the brief got right:** the verdict content itself was excellent — 13 of 13 SHIPPED, matching
S114's own two-pass finding almost line for line, including independently re-deriving the same fakest
green (the presence-grep floor) by reading the check code rather than trusting the disclosure, and
independently confirming via live `grep` (not the diff's prose) that no gate reads a handoff. This is
the adversarial, non-self-certifying behavior the brief asks for, working exactly as designed.

**What the brief got wrong — the real finding:** the returned verdict's canonical line was
`| **Verdict:** | ACCEPT |` — the agent formatted it as a two-cell markdown table row (a reasonable
styling choice, and arguably *more* readable than a bare line). `verify-closeout.sh`'s canonical-verdict
regex is anchored at line-start (`^[*_[:space:]]*verdict...`) — a leading `|` breaks the anchor. I ran
the gate's actual regex against the raw output (not a paraphrase):

```
raw agent line:   | **Verdict:** | ACCEPT |
gate regex match: <none>          → "INCOMPLETE: no canonical '**Verdict:** ACCEPT|REJECT' line"
control line:     **Verdict:** ACCEPT
gate regex match: ACCEPT          → passes
```

**So: no, the raw verdict would NOT pass `verify-closeout.sh` unedited.** The per-requirement table
(≥3 `|`-rows with verdict words) and the `X of N SHIPPED` count both landed cleanly — only the
canonical-verdict line broke, and only because of a formatting choice the brief doesn't foreclose. This
is a brief-vs-gate gap that no synthetic test could have found (S114's own shape tests write the
literal required strings by hand); it only shows up once a real agent makes its own formatting
decisions. Fix (not made — GT is NO-CODE): either loosen the gate's regex to also match a
`|`-delimited two-cell verdict row, or tighten the brief to explicitly forbid table-wrapping the
verdict line. Recommend the former (the intent — "not buried in a heading" — is about hiding, and a
table row does not hide it).

**Governance mechanics (S112+S113's read/visibility machinery), tested live for the first time on the
second role:** `vajra next --role fidelity-reviewer --from -` governed the finding into
`.ai/handoffs/session-115-fidelity-reviewer.md` (validated OK). `vajra next --stations 115` now shows
`fleet: 1 governed handoff(s) — fidelity-reviewer` — the S112 read-side + the S114 second role, working
together, for the first time, on a role other than the Researcher. No drift.

*Disclosure on the governed handoff's exact text:* when feeding `--from -`, I used the corrected bare
line (`**Verdict:** ACCEPT`), not the raw table-wrapped one — the handoff is a pre-stage input, not the
gate-checked record, so this doesn't misrepresent anything gated, but the **raw** table-wrapped text
is what the fidelity-vs-gate test above was run against, and that is the honest finding.

---

## Live-query evidence (pasted, not summarized)

### `vajra next --stations NN`, every session since S110

```
=== --stations 111 ===
  [ABSENT] Analyst   WHAT   — no `## Delta`
  [ABSENT] Architect DESIGN — not design-significant
  [PASSED] Planner   HOW    — plan covers all criteria
  [ABSENT] Coder     DID    — no `## Execution` trace
  [PASSED] QA / [PASSED] Demo-er / [PASSED] Releaser / [PASSED] Reviewer
  5 of 8 stations passed
  fleet: 1 governed handoff(s) — researcher

=== --stations 112 ===
  ALL PASSED — 8 of 8
=== --stations 113 ===
  ALL PASSED — 8 of 8
=== --stations 114 ===
  ALL PASSED — 8 of 8
```

**Read the shape, not just the number.** S111's 5/8 is NOT a regression or a systemic gap — it is a
one-time template gap: `prompts/111-task-fleet-dispatch-wire.md` predates the `## Delta` / `##
Execution` marker convention that every prompt from 112 onward carries (confirmed by diffing the four
prompts' section headers directly). S111 shipped real code (PR #117, verify 9/9, cold review ACCEPT)
that the station counter structurally could not see, because the markers it needed were never in the
prompt to begin with. This is the exact "any station ABSENT... is a systemic gap, not per-session
noise — name it" case the S115 brief asked to catch, and naming it here is what confirms it is
**not** chronic: 112, 113, 114 are clean 8/8, so the gap self-healed once the prompt template caught
up. No fix needed; it is a closed, one-session artifact, not an open one.

Fleet line absent for 112/113/114 is also correct, not a regression: `read_handoffs` is scoped to the
handoff file for that exact session number, and none of 112/113/114 dispatched a new subagent under
their own session number (112 consumed a prior handoff, 113 built visibility machinery, 114 built the
second role) — so there is nothing to report. Verified against `src/fleet/mod.rs:read_handoffs`.

### `vajra next --dogfood-age`

```
last dogfood session : 103
date (git-derived)   : 2026-07-30
cost (authoritative)  : $0.6797
sessions since        : 11 (S103 → current S114; now 12 counting this S115)
calendar days since    : 8 day(s)
```

**Residual bug, newly precise-located:** the true S103 dogfood commits are dated **2026-07-27**
(git log confirms; STATE.md's `2026-07-27` is *correct*). The live tool reports **2026-07-30** — the
date of the S105-follow-up commit that added the top-level aggregate receipt file, not the date of the
actual dogfood run. The tool derives its date from the receipt file's *commit* date, which is not
always the *run* date when a receipt is backfilled by a later session. Session-count (`11`, correctly
now `12` at S115) is unaffected — only the calendar-days figure is off (true gap ≈ 11 days as of
today, not 8). **This is the tool's date field that needs the fix, not STATE.md** — do not "correct"
STATE.md over this; it is already right. Filed as a residual, not acted on (NO-CODE).

**Staleness verdict: 🔴 RED.** 12 sessions / ~11 calendar days since any real `vajra claude` run. Every
"is Vajra-on-Claude satisfying?" claim anywhere in this repo remains unmeasured by definition.

### `verify-closeout.sh --ledger-verify`

```
committed head : 908e00caffdd19b49667bfa6549d2039ca2d3880769988cba4be3196b6aef6a4
worktree  head : 908e00caffdd19b49667bfa6549d2039ca2d3880769988cba4be3196b6aef6a4
LEDGER: INTACT — every committed verdict record matches the worktree.
```

### `verify-closeout.sh` (full, for shape reference — expected FAIL, documented behavior)

11/12 PASS, `review-inputs-attested` FAIL — this is the **known, documented merge-base collapse** (S83
rule: run the full gate PRE-merge, never after; `.ai/SESSION` still reads N=114 since S115 hasn't
closed). Not a new finding; confirms the documented behavior still holds exactly as described.

---

## The 10 required audits

### 1. `vision_alignment`
**Is the north-star still right?** Yes — provable agent governance, sold as the autopilot trust layer
(DECISION-001/005), still matches every session's actual output. `VISION.md` has been corrected at
every real pivot (last: S103, 2026-07-27) and is not stale relative to STATE.md.
**Is current work the shortest path, or scope creep?** The fleet arc itself (S109–S114) is legitimate
— it is the **A** leg of the founder's own C→B→A order, not invented scope. But the *cadence* — four
CODE sessions building fleet machinery (S111–S114) with **zero** dogfood sessions in between — is the
same "easy-green detour" pattern named at S60, S65, S70, S80, S85, S90, S95, S100, S105, and S110.
This is now the **6th+ consecutive GT** to name it. **What would make us pivot?** A real Rung-2+ paid
run either (a) surfacing a leak or gap the fleet machinery didn't anticipate — genuinely valuable
information only a real run produces — or (b) working cleanly, which would finally let the founder
render the "is this satisfying?" verdict that has been undeliverable since S103. Either outcome is
strictly better than another cycle of unmeasured building.

### 2. `roadmap_alignment`
Each phase still maps to the north-star (C✓ → B✓ → A in progress, 2 of an unbounded number of roles
built, dispatch+consumption+visibility all proven). **Highest-leverage next item vs. easiest:** a third
fleet role is easier (S109→S114 proved the pattern costs ~one `fleet::ROLES` entry) but is **not** the
highest-leverage move — it would repeat the Darshan-propagation pattern (S28/S29: legitimate but
"spent leverage," polish over friction) without first learning whether the *existing* two roles survive
contact with a real unattended run. The paid dogfood is unambiguously higher-leverage: it is the only
roadmap item that can falsify anything, whereas a third role can only add more surface for a future GT
to say "unmeasured" about. Nothing on the roadmap looks obsolete; nothing looks missing that the vision
now demands beyond what's already backlogged.

### 3. `state_drift`
No false claims found. `STATE.md`'s PR/merge facts (S111–S114, #117/#118+119/#120+121/#122+123) match
`gh pr list` exactly, including the just-landed post-merge correction (commit `d4cde0f`) that
proactively downgraded an S111-derived claim to an assumption rather than letting it sit wrong in the
spine — that is the discipline working, not a violation. The one imprecision found is in a **live
tool's output**, not in `.ai/`: `--dogfood-age`'s date field (see above). No `.ai/` file needs
correction this session.

### 4. `knowledge_staleness`
`KNOWLEDGE.md` §6 = **496 lines**, up from 475 at the S105 note — growing, as flagged chronically
since S60, still unpruned. **New, small drift:** the file's own header text still reads *"475 lines /
~91K tokens as of S105"* — that self-reported count is now itself 9 sessions and 21 lines stale, a
mild irony (the doc meant to reduce staleness has a stale line about its own staleness). Not
correcting it this session (§6 is append-only by `CONSTRAINTS.yaml#state.knowledge_md_mode`, and a
header rewrite is exactly the "prune" work already queued, not a GT-session edit). §1–§5 (the
reloaded-at-boot core) remain accurate and current.

### 5. `constraint_violation_review`
Spot-checked every S114 commit (`e0730a9..d8b32e2`, 15 commits): all ≤3 files changed, consistent
with `max_files_per_atomic_change: 3`. No commits on `main`. Session branches used throughout
(`session-111-*` … `session-114-*`). No forced pushes, no `--no-verify` found in the range. Zero
violations found for S111–S114.

### 6. `constitution_review`
No rule currently blocks the vision. `no-eighth-command`'s hardcoded-banner-grep weakness is now
flagged for a **4th consecutive session (S111–S114)** without being fixed — four sessions of "flagged,
not fixed" is a real, if minor, discipline gap in its own right (a weak check that nobody has budgeted
a session to close). **Meta-check (own mechanism's blind spot):** the 10 required audits check code
fidelity, state accuracy, and roadmap direction — **none of them asks whether an approved PROMPT's own
factual premises are true.** S114's own cold-review pass 1 caught exactly this ("the prompt asserted
the reviewer's brief lived nowhere, while `reviewer/SKILL.md` had stated it all along") — but it was
caught by the two-pass adversarial review process, not by any standing GT question. This audit list
has no analog to DECISION-002's "fidelity ≠ discipline" for *prompts themselves*. Recommend (not built,
NO-CODE): either a lightweight "premise check" step folded into prompt-writing (grep-verify any claimed
absence before locking the prompt), or explicitly rely on the two-pass process and stop treating it as
happenstance — it has now caught real premise errors, not just code gaps.

### 7. `cost_review`
S111–S114: $0 metered build cost each (interactive sessions); subagent tokens (S111 cold reviews,
S114's ~215k two-pass tokens, and this session's own 107,664-token fidelity-reviewer dispatch) all
roll into their respective interactive receipts, unitemized — same structural, already-documented
limitation (`scripts/check-subagent-cost-fields.sh`: no local subagent transcript carries a cost
field). Cumulative: **~$79.3 + S76 (unknown, ≤~$26.6 opus-estimate) + S111–S115 (unknown, small)**. No
budget-cap concerns (`$5.00`/warn is scoped to `vajra claude` launches, not interactive build sessions).

### 8. `dogfood_check`
**Has real work run through `vajra claude` since the last GT (S110)?** No. Zero paid launcher runs
across S111–S115. Every claim of "is Vajra-on-Claude satisfying" anywhere in this repo remains
unmeasured by definition — flagged, not guessed at.

### 9. `pipeline_advance_check`
Covered above under live-query evidence: S111 5/8 (one-time template gap, self-healed), S112–S114
8/8. The pipeline **is** advancing — payload delivered every session, and the counter reflects it
(net of the one explained absence). No systemic per-station gap found across S111–S114.

### 10. `dogfood_staleness`
Covered above: 🔴 RED, 12 sessions / ~11 true calendar days (not the tool-reported 8 — see the
residual-bug note). STATE.md agrees with the true date; the live tool's date field does not, for a
specific, now-diagnosed reason.

---

## Meta-check: did this audit's own mechanism have a blind spot?

Two, both real:

1. **No audit checks a prompt's own premises against repo reality** (named under `constitution_review`
   above) — the gap that let S114's false "the brief doesn't exist elsewhere" premise ship approved,
   caught only by luck of the two-pass process rather than by any required GT question.
2. **`--dogfood-age`'s date field can silently use the wrong commit's date** when a receipt is
   backfilled by a later follow-up session (exactly what happened for S103/S105). This GT is the audit
   that is *supposed* to catch date drift (`dogfood_staleness_questions`) and it did — but only because
   this session happened to cross-check against `git log` by hand, not because the live tool is
   self-consistent. A future GT that trusts the tool's date field at face value would understate the
   staleness gap by several days.

Neither blind spot changes this session's verdict (dogfood is 🔴 regardless of the exact day-count),
but both are concrete, fixable gaps in the audit machinery itself — exactly the kind of "the audit's
own mechanism missed a kind of drift" this section exists to surface.

---

## Carry-ins confronted (from `prompts/115-task-ground-truth.md`)

- **🔴 Paid dogfood, stale since S103 — CONFIRMED still open, now the load-bearing finding of this GT.**
- **🟡 Fidelity Reviewer's TEXT guarded by presence-greps only — reconfirmed independently.** The live
  redispatch re-derived the exact same fakest green the S114 builder disclosed, from a cold read of the
  check code, not from trusting the disclosure. Verdict: **acceptable to leave as-is for now** — no
  mechanism can verify judgment quality without either (a) a second independent LLM grading the
  reviewer's grading (turtles, and itself gameable) or (b) empirical track record over many real runs
  (which only dogfood produces). Recommend revisiting after real dogfood data exists, not before.
- **🟡 `no-eighth-command` hardcoded-banner grep — 4th consecutive session flagged, unfixed.** Small,
  real, cheap to fix; a reasonable candidate for a future closeout-hardening slice, not urgent enough
  to interrupt the dogfood-vs-third-role fork below.
- **🟡 KNOWLEDGE §6 bloat — confirmed still growing (475→496 lines), and its own staleness header is
  now itself stale** (see `knowledge_staleness` above).
- **"A premise inside an approved prompt is not evidence" — meta-checked above; no standing audit
  covers it. Named as a real gap, not fixed (NO-CODE).**

---

## Candidates for S116

**A. The overdue paid dogfood (Autopilot Ladder Rung 2+, real `vajra claude` run)**
One-sentence goal: run a real, multi-task, unattended `vajra claude` session (chitra or similar) with
both fleet roles available, and measure whether governance holds, fleet roles get used, and the
receipt is honest.
Why pick this: it is the single highest-leverage, most overdue item on the entire roadmap — 12
sessions unmeasured, named at every GT since S105, and the only roadmap item that can actually falsify
anything rather than add more unmeasured surface.
Key risk: real $ spend, and a genuine chance it surfaces a leak or gap the S109–S114 machinery didn't
anticipate — which is the point, not a reason to avoid it.

**B. A third fleet role**
One-sentence goal: apply the now-proven `fleet::ROLES` pattern to a third named role (e.g. a Planner
or Coder subagent), continuing the **A** leg of C→B→A.
Why pick this: cheapest to execute (S109→S114 shows it costs roughly one registry entry); extends a
pattern now proven end-to-end including live by-name dispatch.
Key risk: repeats the exact "spent leverage" shape (S28/S29 Darshan propagation) — more machinery
before the existing two roles have survived a single real unattended run. This is what `roadmap_alignment`
above explicitly recommends against as the *next* pick, though it remains valid roadmap work eventually.

**C. Close the two small, cheap gaps found/reconfirmed this session**
One-sentence goal: (1) loosen `verify-closeout.sh`'s canonical-verdict regex to also accept a
`|`-delimited two-cell verdict row (the concrete gap this session's live dispatch found), and (2) fix
`no-eighth-command`'s hardcoded-banner grep (flagged 4 sessions running).
Why pick this: both are small, well-understood, real defects this and prior GTs found — cheap
closeout-hardening that removes two known-brittle spots.
Key risk: it is machinery work, not dogfood — picking this over A repeats the exact pattern this GT
just flagged as the chronic problem, for the 6th+ time running.

**Founder recommendation: A.** Every other candidate adds more unmeasured machinery on top of an
already-unmeasured pile; A is the only one that produces new information instead of new surface area.

---

## Founder pick (post-presentation addendum)

Presented A/B/C above; **founder picked B — a third fleet role**, overriding this report's
recommendation of A (the paid dogfood). Followed up and the founder named the specific role:
**Planner** — a read-only subagent that maps a session's acceptance criteria into ordered plan steps
with `covers: N` markers, staying in the same read-only/advisory shape as roles 1–2 (Researcher,
Fidelity Reviewer), rather than a code-writing role (Coder), which was flagged as a bigger, separate
governance step. This is the founder's call to make, not the audit's (the same standing they've held
since the S26 second-agent gate) — recorded here for the record, not contested further. `prompts/116-
task-fleet-role-planner.md` scopes S116 to choosing (with rejected alternatives, mirroring the
DECISION-007 S113 addendum) and building this third role. The dogfood gap (Candidate A) remains
**not deferred by neglect** — it is now flagged for the 2nd session running as the founder's own
explicit pass-over, worth surfacing again at the next GT if S116 doesn't reach it either.

---

## Attestation

No review artifact requiring `Review-Inputs-SHA` attestation is produced by a GT session
(`CONSTRAINTS.yaml#state.ground_truth_summary_in` — this file — is not a `session-NN-review.md`
fidelity review; DECISION-003 attestation applies to fidelity verdicts, not GT reports). None computed.
