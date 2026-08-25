# Session 132 — CODE: verify the recorded `obeyed:` disposition is actually true

> **Status:** APPROVED — founder, at the S130 closeout. Locked sequence: S131 -> **S132** -> S133 ->
> S134. S131 made the `fidelity-reviewer` handoff mandatory and its provenance provable; this
> session closes the OTHER half of "recorded ceq real" for the fleet: whether a disposition a
> session writes against a recommendation (`obeyed: <sha>`) is actually true, not merely a sha that
> resolves.
>
> Founder directive in force (S118): README.md / VISION.md claims are the target spec, not a
> status report. Do NOT soften them. No release until reality meets them.

## Type

CODE. Max 2 assumptions, 2 retries, 1 story, ~2h, new chat. One story: close the S127 residual --
`obeyed:` today certifies a typed word and a resolving sha, nothing more. Commits need the
un-forgeable marker on the command line at commit time.

## Why this session

The Advice gate (S127, `src/advice/mod.rs`) proves every numbered recommendation was ANSWERED, and
that the answer's evidence is existence-real -- the sha resolves, the deferral target exists, the
refusal reason is non-empty. It does **not** prove an `obeyed:` claim is TRUE. DECISION-007's own
S127 addendum records a live specimen from the very session that shipped the contract: the
`implementation-advisor`'s rec 9 said "delete the `_uses` stub"; the ledger recorded
`obeyed: 8cd3bea`; the stub was still in `src/advice/mod.rs`. The sha resolved, so the gate scored
it ANSWERED. Only an independent cold reader caught it -- the same class S131's own rec 4 found one
level out (a real dispatch proves a role ran, not that its findings are what got ingested).

**The pattern repeats at every layer of this repo's governance: a recorded claim and a verified one
are not the same thing**, and each session that closes one instance tends to surface the next.

S131 made `fidelity-reviewer` mandatory and its own EXISTENCE provable. That gives this session a
tool it did not have before: a MANDATORY, real cold-review pass already runs every session. This
session's job is to make that pass (or an equivalent independently-derived check) actually GRADE
whether each `obeyed:` disposition is true, and wire that grade into a gate.

## Goal

An `obeyed: <sha>` disposition that does not actually implement its recommendation can no longer
pass silently. "Actually true" here means: an INDEPENDENT judge (never the author, never the
advisor that made the recommendation) looks at the recommendation text and the cited commit's real
diff, and says whether the commit does what the recommendation asked -- the same posture
DECISION-002 already requires for fidelity itself, applied one level down to individual
dispositions instead of the whole delivery.

## Deliverables

- A recorded, existence-gated JUDGMENT per `obeyed:` disposition -- not a new free-text field
  invented ad hoc; reuse the same "recorded marker, existence-gated" house pattern this repo has
  used five times already (Delta S61, `covers:` S64, `design-significant:` S67, `done: <sha>` S68,
  disposition S127). Decide and RECORD (in `## Design`) whether this judgment:
  (a) rides the ALREADY-MANDATORY `fidelity-reviewer` handoff (S131) -- e.g. the handoff itself
      names which dispositions it checked and its verdict on each, or
  (b) is a new, narrower dispatch scoped ONLY to grading dispositions.
  Either is acceptable; a THIRD option is not (do not invent a new mechanism family without an
  explicit reason the first two are insufficient).
- A gate (own command or an extension of `--check-advice` -- make and record the same kind of
  explicit design choice S131 made for its own gate) that BLOCKS when an `obeyed:` disposition has
  no recorded independent judgment, or when that judgment says the commit does NOT do what the
  recommendation asked.
- Re-graded, as a live test case: the S127 addendum's own historical specimen
  (`implementation-advisor` rec 9, `obeyed: 8cd3bea`, the stub still present) -- prove the new
  mechanism WOULD have caught it, on the real historical data, not a synthetic fixture alone.
- A falsifiability fixture: (a) a TRUE `obeyed:` (the commit really does it) -> PASSES: (b) a FALSE
  `obeyed:` (sha resolves, commit does something else) -> BLOCKS; (c) no judgment recorded at all
  -> BLOCKS or WARNs, a DELIBERATE choice, recorded and reasoned (existing dispositions predate this
  gate -- decide and state the migration posture, do not silently break every past session).
- `scripts/verify-session-132.sh` + `scripts/demo-session-132.sh`, both exit 0, printed check-class
  tally.
- `sessions/session-132-summary.md` + exactly 3 ranked next candidates (S133 -- compression
  keep/kill -- is the locked default; still present it as one of the three, not as the only option).

## Acceptance (testable, EARS-style)

1. WHEN a session records `obeyed: <sha>` against a recommendation THEN closeout/the relevant
   `--check-*` gate requires a recorded, independent judgment of whether that commit actually
   implements the recommendation -- not merely that the sha resolves.
2. WHEN the independent judgment says the commit does NOT do what the recommendation asked THEN the
   gate BLOCKS, naming the role, the recommendation number, and the disagreement.
3. WHEN re-run against the S127 historical specimen (`implementation-advisor` rec 9,
   `obeyed: 8cd3bea`) THEN the new mechanism reports it as a MISMATCH -- proven on the real
   historical record, not asserted in prose.
4. The judgment is produced by an INDEPENDENT party -- never the session's own builder, never the
   advisor whose recommendation is being graded (mirrors DECISION-002's no-self-certification rule,
   applied to a disposition instead of a whole delivery).
5. A falsifiability fixture drives TRUE / FALSE / ABSENT judgment, each probe asserting its own
   pattern matched (S127's lesson: a probe that silently no-ops is false comfort).
6. Traced, not asserted: `K of 8`, 7 commands, S131's Fidelity gate and every other gate's evidence
   contract are unchanged by this session.
7. `verify-session-132.sh` and `demo-session-132.sh` both exit 0 with a printed check-class tally,
   every check execute-based or honestly labelled.
8. Independent cold `fidelity-reviewer` verdict ACCEPT, attested -- via the now-MANDATORY S131 gate,
   so this session's own close satisfies its target the same way S131's did.
9. The summary states plainly what is still NOT fixed -- in particular whether `refused:` and
   `deferred:` dispositions get the same treatment or are explicitly out of scope, and whether the
   judgment mechanism this session ships could itself be gamed (name the honest ceiling, do not
   overclaim "obedience is now provable" the way S131's own addendum had to correct itself on
   "provable" meaning "tamper-proof").

## Plan (ordered -- cite the acceptance criteria each step covers)

1. Reproduce the gap first: confirm live, on the real historical record, that
   `implementation-advisor` rec 9's `obeyed: 8cd3bea` still passes `vajra next --check-advice` today
   despite the stub still being present. No fix before its own red. covers: 1, 3
2. Resolve the design question in Deliverables (a) vs (b) and record the choice + why in
   `## Design`, citing DECISION-007 and DECISION-002. covers: 1, 4
3. Build the judgment-recording mechanism chosen in step 2, existence-gated like every prior marker
   in this repo. covers: 1
4. Wire the gate: BLOCKS on a missing judgment (per the migration posture decided in Deliverables)
   or a judgment that disagrees. covers: 2
5. Re-run against the S127 historical specimen and confirm it is caught. covers: 3
6. Falsifiability fixture, all three directions (TRUE / FALSE / ABSENT), each probe asserting its
   own pattern matched. covers: 5
7. Prove nothing else moved -- `K of 8`, 7 commands, S131's Fidelity gate, other gates' contracts.
   covers: 6
8. `scripts/verify-session-132.sh` + `scripts/demo-session-132.sh`. covers: 7
9. Dispatch the real `fidelity-reviewer` cold pass on this session's own diff (now mandatory, S131)
   -- its handoff is this session's own proof that the mandate holds under real use, not just the
   builder's. covers: 8
10. Say in the summary what is still not fixed, including the honest ceiling on this mechanism
    itself. covers: 9

## Execution (the Coder gate -- record each plan step's landing commit as work lands)

- step 1 — done: 27927f2
- step 2 — done: 27927f2
- step 3 — done: 12cbaed
- step 4 — done: 9bb50ed
- step 5 — done: b2facd4
- step 6 — done: 008a86f
- step 7 — done: b2facd4
- step 8 — done: 00966aa
- step 9 — done: 0e2214b
- step 10 — done: 0e2214b

> Steps 1+2 and 9+10 landed together, and three steps were completed across two commits: step 3
> (`12cbaed`, hardened in `12c8686`), step 6 (`008a86f`, probes hardened in `b2facd4`) and step 8
> (verify `008a86f`, demo `00966aa`, both retimed in `9eb8491`). Each sha above CONTAINS the work
> its step claims; the extra commits are named here rather than hidden.

> Fill these with real landing shas before closeout -- S119, S122, S124 all left <sha> placeholders
> once, caught only by an independent cold review. Do not record a sha that does not contain the
> work (S127 did that three times).

## Advice (every recommendation from this session's advisors, answered)

> The S127 contract. One line per recorded recommendation: `- <role> rec N -- obeyed: <sha>` /
> `refused: <reason>` / `deferred: <path>`. `vajra next --check-advice 132` BLOCKS the close until
> every one is answered. Read the S127 residual before trusting any count: four `obeyed:` labels
> there were factually wrong and passed the gate -- exactly what this session exists to stop
> happening again. A disposition certifies a typed word and a resolving sha, nothing more -- check
> the commit, don't count the label.

- fidelity-reviewer rec 1 — obeyed: b2facd4
- fidelity-reviewer rec 2 — obeyed: 5ca0b82
- fidelity-reviewer rec 3 — obeyed: b2facd4
- fidelity-reviewer rec 4 — obeyed: b2facd4
- fidelity-reviewer rec 5 — obeyed: 12c8686
- fidelity-reviewer rec 6 — obeyed: 9eb8491
- fidelity-reviewer rec 7 — obeyed: 0e2214b
- fidelity-reviewer rec 8 — refused: already true, checked before answering -- both sides of the join lower-case the role through the same `advice::split_role_rec`, so a mixed-case judgment already joined. `12c8686` makes the comparison say so explicitly and adds the regression test, but calling that "obeyed" would claim a fix for a defect that did not exist; the honest answer is a refusal with the evidence.

## Design

- design-significant: yes -- this changes what evidence the Advice gate (or a new gate beside it)
  requires for an `obeyed:` disposition to pass, a real behaviour change for anyone relying on the
  current existence-only check, and it decides how the fleet's now-mandatory `fidelity-reviewer`
  role's output is consumed a second way.
- Spine record to cite: DECISION-007's S127 addendum (the `implementation-advisor` rec 9 specimen,
  "the disposition word carries all the meaning and none of the checking") and DECISION-002
  (no-self-certification) -- verify both exist before citing them.
- **Step 1 — the gap, REPRODUCED LIVE before any fix** (2026-08-24, release binary, this repo):
  `vajra next --check-advice 127` prints `[✓] implementation-advisor rec 9 — obeyed: 8cd3bea` and
  `verdict: READY`. `git show 8cd3bea | grep -n -A3 _uses` shows `fn _uses(_r: &Path)` as a
  CONTEXT line (a leading space, not `-`): the commit adds 168 lines of parser and does not delete
  the stub rec 9 asked it to delete. The sha resolves, so today's gate scores it ANSWERED. That is
  the whole defect, on the real historical record, no fixture involved.

### Step 2 — the two open questions, RESOLVED and recorded (S132's design call)

**Q1 — (a) ride the mandatory handoff, or (b) a new narrower dispatch? → (a), the handoff.**
The judgment is recorded as an `obeyed-check` marker inside a governed handoff body, and the
handoff this session's own close depends on is already `fidelity-reviewer`'s (S131, mandatory).
Why (a):
- (b) would add a second dispatch shape whose independence has to be re-proved from scratch, while
  (a) inherits S131's `dispatch::reverify` provenance chain unchanged — the judge is already cold
  (prompt + diff only), already not the builder, and already existence-gated as a REAL dispatch.
- DECISION-007's own line — "a role that PROPOSES never authors the marker its station parses"
  (S126) — is respected either way, but (a) adds no new role and no new mandatory role, which this
  prompt's Non-goals require.
- DECISION-002 (no self-certification) is what makes the judge admissible at all; the gate enforces
  it structurally, not by trust: a judgment is REFUSED when the judging handoff's role equals the
  advisor role whose recommendation is being graded.
- The marker is not fidelity-reviewer-only by construction — ANY provenance-verified handoff from a
  role other than the graded advisor may carry it. (a) is where it lands today, not a lock.

**Q2 — migration posture for every disposition recorded S1-S131 → an explicit, recorded threshold,
never a silent exemption.**
- `OBEYED_JUDGMENT_FROM_SESSION = 132`. For sessions **≥ 132** a missing judgment BLOCKS. For
  sessions **< 132** a missing judgment WARNS and the warning NAMES the exemption and its reason
  (the disposition was recorded under a contract that had no judgment marker; retro-grading 131
  sessions is not this session's one story) — the S68/S71 self-granted-jurisdiction class,
  disclosed in the output itself rather than hidden in a constant.
- A recorded `mismatch:` judgment BLOCKS at ANY session number, including historical ones. The
  threshold governs SILENCE, never a judgment that actually exists — which is exactly what makes
  the S127 specimen (`--check-obeyed 127`) reportable as a MISMATCH on the real record.
- The exemption is therefore not permanent: any later session may grade an older one by qualifying
  the marker with `session NN`.

**Q3 — own gate or an extension of `--check-advice`? → its own flag, `vajra next --check-obeyed NN`,
the same call S131 made for `--check-fidelity-handoff`, for the same reason.** `--check-advice`
answers "was every recommendation ANSWERED?" and must keep answering exactly that (a session
mid-flight is legitimately answered-but-not-yet-judged); this gate answers "is the `obeyed:` answer
TRUE?" — a different question, a different evidence source (a judgment in a handoff vs. a
disposition in the prompt), and a different blocking message. No 8th top-level command: it rides
`vajra next`, like every station gate since S64.

**Q5 — RESOLVED IN-SESSION, after the second cold pass found it (its rec 9): who may judge the
MANDATORY role's own advice?** `obeyed::admit` rule 1 refuses a judgment whose judging ROLE equals
the graded advisor's role (DECISION-002, one level down). `fidelity-reviewer` is the one role every
session is guaranteed to hear from, so its own recommendations can never be graded by another
`fidelity-reviewer` dispatch — this session's own seven dispositions hit exactly that, and the gate
correctly refused them. **Resolution taken: dispatch a DIFFERENT registered role
(`implementation-advisor`) as the independent judge** — works today, costs one dispatch, changes no
code, and keeps the no-self-certification rule intact rather than widening it under closeout
pressure. The alternative (narrow rule 1 from role identity to DISPATCH identity, so a distinct
provenance-verified dispatch may grade an earlier one of the same role) is recorded as an OPEN
design question at `.ai/ROADMAP.md` F2a — it needs its own design record and falsifiability probe,
not a patch at close. Explicitly refused: `VAJRA_SKIP_OBEYED_GATE=1` or a closeout waiver, which
would be skipping the gate on the session that built it.

**Q4 — what stops a STALE judgment (not asked, but the same class one level down; S131 rec 4).**
The marker records the sha it judged, and the gate refuses a judgment whose sha does not match the
disposition's recorded sha. Editing `obeyed:` to a different commit after the review therefore
invalidates the judgment instead of silently inheriting it.

## Non-goals (not built this session)

- Not a second role made mandatory. `fidelity-reviewer` stays the only mandatory role; this session
  consumes its output a second way, it does not add a second mandatory role.
- Not S131's own rec 4 residual (binding a dispatch's returned content to the specific `--from`
  findings file) -- named, deferred, `.ai/ROADMAP.md` F2, a different mechanism than this session's.
- Not `refused:`/`deferred:` dispositions' soundness, unless Deliverables explicitly scopes them in
  -- the locked ask is `obeyed:` truth first (the S127 specimen is an `obeyed:` case).
- Not the fourth fork (`TPL_CONSTRAINTS`) -- parked, not dropped, per `.ai/ROADMAP.md`.
- Not S133 (compression keep/kill) or S134 (fresh-scaffold paid dogfood) -- both explicitly next,
  not this session's.
- No release, no crates.io action (founder directive; `vajractl` already burned at 0.1.0).

## Delta (vs ROADMAP -- OpenSpec markers)

- ADDED: an independent-judgment marker for `obeyed:` dispositions, existence-gated; a gate
  consuming it.
- MODIFIED: the Advice gate's evidence contract for `obeyed:` specifically (`refused:`/`deferred:`
  unchanged unless Deliverables says otherwise); how the mandatory `fidelity-reviewer` handoff is
  consumed (a second consumer, S131's `fidelity_gate` being the first).
- UNCHANGED: the 9 roles (still one mandatory), the 8 stations, the 7 commands, `K of 8`'s
  derivation, S131's Fidelity gate and every OTHER gate's evidence contract.

## Guardrails

- Un-forgeable commit marker required on every commit, session number 132. Max 3 files per atomic
  commit. Never skip hooks.
- A check that cannot evaluate FAILS (S69). A fixture must fail for the RIGHT reason (S122), and a
  probe must assert its own pattern matched (S127).
- Do not silently exempt every pre-S132 disposition without an explicit, recorded reason.
- Answer this session's own advisor in Advice, honestly. A `refused:` with a reason beats an
  `obeyed:` that is not true -- the exact failure this session exists to stop.
- Attest LAST (S69, and S131's own lesson): the `--inputs-sha` preimage hashes the LIVE PROMPT
  FILE directly, not only the (prompts-excluded) diff -- recompute AFTER every edit to this prompt,
  including `## Execution`/`## Advice`/`## Design`, not just after the code diff stabilises. Two
  consecutive `verify-closeout.sh --inputs-sha 132` runs must agree before embedding. Run the full
  `verify-closeout.sh` on the branch BEFORE merging the PR (S83) -- merge-base collapses after.
