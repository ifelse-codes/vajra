# Session 76 — The founder-led dogfood RIDE-ALONG (paid): measure the 8-station pipeline as lived experience

> **Status:** APPROVED — un-parked at the S75 ground-truth close (`sessions/session-75-ground-truth.md`),
> founder pick **A** of 3 ranked candidates. Executes the founder's recorded S70 decision ② ("finish the
> crew, then a founder-led manual run"); the crew's core completed at S72 with the Releaser and is now,
> as of S74, **measured structurally** by the payload counter (`vajra next --stations NN`) — this session
> measures it as **lived experience** instead.
> **Type: MEASURE — paid dogfood, founder at the wheel.**
> The standing risk every GT since S60 has named is machinery-without-measurement: the 8-station pipeline
> is built, attested, and ~$0-proven — and **unmeasured as experience since S63** ($1.2662, 6-station era,
> **12 sessions stale** at the S75 GT that picked this). This session measures it; it builds no station.

## Goal
One real task runs through `vajra claude` end-to-end with the **founder driving** the governed instance
and the agent riding along: preparing the measurement harness, capturing artifacts live, deriving the
numbers (authoritative cost, receipt fidelity, compression folds, gates fired/helped/hindered, obedience,
and — new since S74 — a `--stations` reading of the session this run produces), and writing the honest
dogfood report. Refreshes `dogfood_check` with measured evidence. Bugs found are RECORDED as debt, not
fixed (the S63 stance — 1-story discipline).

## Why this session
- The founder's own recorded sequence (S70 decision ②): crew first → founder-led manual run. The core
  crew completed at S72 (Releaser) and is now measured (S74's payload counter) — this is the next step
  BY STANDING DECISION, sharpened by the S75 GT's own pick, not a new direction.
- Machinery-without-measurement is the risk every GT since S60 has named; `dogfood_check` last measured
  S63 — before Architect, Coder, QA, Demo-er, and Releaser existed, and before the payload counter.
- Map-to-Vajra: the measurement rides existing surfaces (run JSONL `total_cost_usd`, the S66 authoritative
  receipt, hook logs, the cost ledger, the S74 `--stations` counter) — no new artifact class, no new
  command.

design-significant: no

## Acceptance (testable — every criterion is cited by a `## Plan` step below)
1. **WHEN** the paid run happens **THEN** it is founder-led — the founder issues the prompts to the
   governed instance; the agent never drives the paid session — and the run is PAID with evidence: the
   run JSONL's `total_cost_usd` line captured verbatim into the artifacts.
2. **WHEN** the run completes **THEN** a gates-fired table records, for each station and hook that can
   bind on the run (Darshan ack · Varta co-pilot loader · session-guard · no-commit gate · compression
   hook fold count · receipt), FIRED / DORMANT plus helped / neutral / hindered — each cell derived from
   a captured artifact, never from memory.
3. **WHEN** the receipt prints **THEN** its headline is compared against the JSONL `total_cost_usd` on
   this live run (the S66 authoritative behavior verified in the wild) and the compression fold count is
   recorded as measured (0 folds = a recorded 0; the never-claim-until-measured rule holds either way).
4. **WHEN** the session reports **THEN** `sessions/session-76-dogfood.md` + a
   `sessions/session-76-artifacts/` dir carry the raw evidence (cost line, receipt capture, fold count,
   gate/obedience log) and an honest verdict that names what HINDERED, any nulls, and every bug found
   (recorded, not fixed).
5. **WHEN** S76 closes **THEN** `scripts/verify-session-76.sh` proves the artifacts + report exist and
   are internally consistent (the recorded cost equals the artifact's line), and `scripts/demo-session-76.sh`
   shows before → after ("8 stations attested + structurally measured, unmeasured as experience" →
   "measured on a paid run") with the four `demo:<element>` markers; no `src/` change is in scope.

## Design (the Architect gate — recorded rationale)
- design-significant: no — a measurement session: no station code, no gate change, no new store; any fix
  the run demands is recorded as an S77 candidate instead (the S63 stance, DECISION-002's independence
  preserved by measuring rather than patching mid-run).

## Plan (ordered steps — cite the acceptance criteria each step covers)
1. Prepare the ride-along with the founder: pick the one real task + target repo, stage the artifact
   capture paths (`sessions/session-76-artifacts/`), and write down the measurement checklist before any
   paid token is spent. covers: 1
2. The founder drives the paid `vajra claude` run; the agent captures live: run JSONL cost line, receipt
   output, hook/gate firings, fold count, commit/branch behavior. covers: 1, 2, 3
3. Derive the numbers from the artifacts: the gates-fired table, receipt-headline vs `total_cost_usd`,
   measured folds, obedience note — every claim traced to a file. covers: 2, 3
4. Write `sessions/session-76-dogfood.md` (honest verdict: helped / hindered / nulls / bugs recorded) +
   `verify-session-76.sh` + `demo-session-76.sh`, then summary + independent cold review + attestation
   (`--inputs-sha 76` at review time). covers: 4, 5

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
- step 4 — done: <sha>

## Guardrails
- **One story:** measure the pipeline as experience. No `src/` changes, no station work, no compression
  fixes — bugs and gaps become recorded S77 candidates.
- **Founder-led is load-bearing:** the agent prepares, captures, derives, reports — it never issues the
  paid prompts (that would measure the agent, not the product).
- Budget: the run stays inside `budget.cap_usd` ($5); the authoritative cost is the JSONL line, never the
  estimate. Max 3 files per commit · branch `session-76-dogfood-ride-along` · ~2h cap.
- Honest-nulls rule (S63): "no gate fired" and "0 folds" are results, recorded plainly — never dressed
  up, never omitted.

## Delta (vs ROADMAP — OpenSpec markers)
- `~` `dogfood_check`: measured-stale-since-S63 (12 sessions at the S75 pick) → refreshed on the full
  8-station, now-measured pipeline (founder-led per the S70 decision).
- `+` `sessions/session-76-dogfood.md` + `sessions/session-76-artifacts/` (raw evidence) — the
  compression-truth dataset for a later fix-or-retire session.
- `-` Nothing removed; compression claims unchanged (never-claim-until-measured holds).

## Deliverable
- `sessions/session-76-dogfood.md` + `sessions/session-76-artifacts/` · `scripts/verify-session-76.sh` +
  `scripts/demo-session-76.sh` · `sessions/session-76-summary.md` + independent cold
  `sessions/session-76-review.md` (attested) · closeout `.ai/` sync + exactly 3 ranked S77 candidates
  (standing: typed cannot-evaluate + depth hardening · ship-evidence durability for `--stations`
  [S75 GT finding] · compression fix-or-retire on this run's data).
