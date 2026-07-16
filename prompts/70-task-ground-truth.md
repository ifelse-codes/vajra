# Session 70 — Ground Truth (mandatory NO-CODE, every 5th; last = S65)

> **Status:** APPROVED (founder standing "all approved"). **Type is FIXED: NO-CODE ground-truth.**
> No source-code edits, no commits to `src/`/scripts, no PRs (hook-enforced; a
> `session-70-closeout` / `-enforcement` branch is the only code-exempt path, for authorized
> hardening). Lead lens = **A** (below); founder may re-aim to B or C in this chat with one line —
> but **all 8 `required_audits` run in full regardless of lens** (the lens is the lead question,
> not a scope cut).

## Goal
Run the mandatory 5th-session ground-truth over the S66→S69 crew arc: answer all 8 audits, judge
whether "finish the crew" is still the shortest path while the measured debts age, and hand the
founder exactly 3 ranked S71 CODE candidates. No code.

## Why this session
`NN % 5 == 0` → mandatory audit. Catch **both** classes of drift (CONSTRAINTS `drift_axes`):
1. **Direction drift** — are we building the right thing? (`vision_alignment`, `roadmap_alignment`)
2. **Discipline drift** — did we honor the contract, and does the contract still serve the vision?
   (`state_drift`, `knowledge_staleness`, `constraint_violation_review`, `constitution_review`,
   `cost_review`, `dogfood_check`)
**Meta-check:** did this audit's own mechanism miss a kind of drift? (The trap S20 caught.)

## Lead lens — A: the crew is 6 stations deep; is depth-vs-breadth still honest?
The S65-GT verdict ("advancing, credibility tension sharpening") drove S66→S69: receipt made
authoritative (S66, the 🔴 retired) · Architect (S67) · Coder (S68) · QA (S69) — the core spine
COMPLETE plus a 6th station whose gate re-executes evidence live. Interrogate honestly:
- **The form-floor debt class is now FIVE gates wide** (Options `Unrecorded`→WARN · Planner
  digit-tag · Architect form floor · Coder deletion-dodge · QA hollow-green + deletion-dodge —
  all one family: **jurisdiction is self-granted**). Every one is disclosed. Is the honest-floor
  posture still honest *enough*, or does station-count-without-depth start faking the pitch?
- **Founder direction says finish the crew** (Demo-er → Releaser next). Is that still
  highest-leverage against the aging measured debts: compression 0-fold (carried since S63) ·
  the pipeline-payload counter (recommended S25+S60+S65, STILL unbuilt) · **dogfood aging — the
  last paid run is S63, seven sessions back by S70** (per the dogfood questions: no run = no
  "experience" verdict, flag it, do not guess)?
- The QA gate now RE-RUNS verify live at close (the one station whose evidence is executable).
  Did S69's close actually pay that cost (the S68 verify re-ran live at advance)? Is live-re-run
  a pattern the other stations should inherit where their markers permit, or a one-off?

## The audits (run every one — answer its question list in CONSTRAINTS `#ground_truth`)
- `vision_alignment` · `roadmap_alignment` — is the north-star still right; is Demo-er the
  highest-leverage next item, or the easiest?
- `state_drift` — does `.ai/STATE.md` match reality after S69 (6 stations; QA live-gate; S69 PR)?
- `knowledge_staleness` — §6 changelog bloat was left flat at S65; did S66→S69 compound it? The
  founder's readable-roadmap pain (ROADMAP/STATE as agent-notebook walls) is now a carried
  candidate — decide: does the GT endorse the derived one-pager as an S71+ candidate?
- `constraint_violation_review` · `constitution_review` — any rule now blocking the vision?
  (meta-check; include: is "one station per session" now cadence-theater?)
- `cost_review` + **`dogfood_check`:** cost ledger honest? Dogfood is 7 sessions stale — state
  the measured status from the ledger, and say plainly whether S71 must be a paid run.

## Acceptance (testable — every criterion is cited by a `## Plan` step below)
1. **WHEN** the GT runs **THEN** all 8 `required_audits` are answered with a per-audit 🟢/🟡/🔴 +
   the meta-check, written to `sessions/session-70-ground-truth.md` (a non-author can read the
   verdict table).
2. **WHEN** the audits complete **THEN** the report states a verdict on lead lens A (crew
   depth-vs-breadth + the five-wide form-floor class) and lists **exactly 3 ranked S71 CODE
   candidates** (A/B/C, each with why + risk).
3. **The honest read is measured, not guessed** — the `dogfood_check` (sessions since a paid run)
   and the pipeline-payload status (stations built · ACCEPT'd · live-gate firings) are stated
   from ledger/cost/verify evidence, never estimated.

## Design (the Architect gate — recorded rationale)
- design-significant: no — NO-CODE ground-truth: audits + a report, no interface, module, or
  behavior change.

## Plan (ordered steps — cite the acceptance criteria each step covers)
1. Run all 8 `required_audits` + the meta-check, recording a 🟢/🟡/🔴 per audit and the evidence
   (SESSION, tests, ledger head, cost ledger, verify runs) into the GT report. covers: 1, 3
2. Read the dogfood/cost + pipeline-payload evidence directly (ledger + STATE cost section +
   `.ai/verify/` run records) and state the measured status — no guessed verdict. covers: 3
3. Write the lens-A verdict and exactly 3 ranked S71 CODE candidates (A/B/C, why + risk); founder
   signs off before code resumes. covers: 1, 2

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: <sha — the GT report/closeout commits are recordable; the Coder gate BLOCKS closing S70 until every numbered plan step records a commit that EXISTS>

## Guardrails
- **NO CODE.** No `src/`/scripts edits, no commits outside a `-closeout`/`-enforcement` branch,
  no PRs. (The QA gate will WARN at S70's close — no `verify-session-70.sh` by design; that
  firing is itself evidence the NO-CODE path behaves as S69 specified.)
- Own the `.ai/` spine — no second store, no unapproved 8th command. Darshan every human reply ·
  Varta live.
- The lens is the lead question, not a scope cut — every audit runs in full.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` A sixth ground-truth (S70) auditing the S66→S69 crew arc (receipt truth · Architect ·
  Coder · QA — spine complete + one).
- `~` Shifts the lead question from S65's "is the pipeline long enough?" to "is the crew deep
  enough — five disclosed form-floors and a 7-session dogfood gap vs two more breadth stations?"
- `-` Retires the S65 open worry that the receipt 🔴 blocks the pitch (S66 retired it) — the
  aging debts are now compression-truth, the payload counter, and dogfood cadence.

## Deliverable
- `sessions/session-70-ground-truth.md` — every audit answered, the meta-check, a verdict on
  lens A, and **3 ranked S71 CODE candidates** (standing, from the S69 close: the Demo-er station
  [founder crew direction] · compression truth fix-or-retire · the pipeline-payload counter;
  the GT may re-rank with evidence).
- **No** `verify-session-70.sh` / demo (NO-CODE). Closeout still runs `scripts/verify-closeout.sh`
  (exit 0).
