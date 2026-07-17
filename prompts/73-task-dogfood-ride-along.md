# Session 73 — The founder-led dogfood RIDE-ALONG (paid): measure the 8-station pipeline as lived experience

> **Status:** APPROVED (executes the founder's recorded S70 decision ② — "finish the crew,
> then a founder-led manual run"; the crew's core completed at S72 with the Releaser. Standing
> approval "all approved" recorded at the S72 kickoff; swap is one message if the founder
> prefers B/C from the S72 summary.) **Type: MEASURE — paid dogfood, founder at the wheel.**
> The standing risk every GT since S60 names is machinery-without-measurement: the 8-station
> pipeline is built, attested, and ~$0-proven — and UNMEASURED as experience since S63
> ($1.27, 6-station era). This session measures it; it builds no station.

## Goal
One real task runs through `vajra claude` end-to-end with the **founder driving** the
governed instance and the agent riding along: preparing the measurement harness, capturing
artifacts live, deriving the numbers (authoritative cost, receipt fidelity, compression
folds, gates fired/helped/hindered, obedience), and writing the honest dogfood report.
Refreshes `dogfood_check` with measured evidence and produces the real-run dataset that
compression-truth (fix-or-retire) needs. Bugs found are RECORDED as debt, not fixed
(the S63 stance — 1-story discipline).

## Why this session
- The founder's own recorded sequence (S70 decision ②): crew first → founder-led manual run.
  The Releaser (S72) completed the core crew; this is the next step BY STANDING DECISION,
  not a new direction.
- Machinery-without-measurement is the S70 lens-A verdict's named risk; `dogfood_check` last
  measured S63 — before Architect, Coder, QA, Demo-er, and Releaser existed.
- Map-to-Vajra: the measurement rides existing surfaces (run JSONL `total_cost_usd`, the S66
  authoritative receipt, hook logs, the cost ledger) — no new artifact class, no new command.

design-significant: no

## Acceptance (testable — every criterion is cited by a `## Plan` step below)
1. **WHEN** the paid run happens **THEN** it is founder-led — the founder issues the prompts
   to the governed instance; the agent never drives the paid session — and the run is PAID
   with evidence: the run JSONL's `total_cost_usd` line captured verbatim into the artifacts.
2. **WHEN** the run completes **THEN** a gates-fired table records, for each station and hook
   that can bind on the run (Darshan ack · Varta co-pilot loader · session-guard · no-commit
   gate · compression hook fold count · receipt), FIRED / DORMANT plus helped / neutral /
   hindered — each cell derived from a captured artifact, never from memory.
3. **WHEN** the receipt prints **THEN** its headline is compared against the JSONL
   `total_cost_usd` on this live run (the S66 authoritative behavior verified in the wild)
   and the compression fold count is recorded as measured (0 folds = a recorded 0; the
   never-claim-until-measured rule holds either way).
4. **WHEN** the session reports **THEN** `sessions/session-73-dogfood.md` + a
   `sessions/session-73-artifacts/` dir carry the raw evidence (cost line, receipt capture,
   fold count, gate/obedience log) and an honest verdict that names what HINDERED, any nulls,
   and every bug found (recorded, not fixed).
5. **WHEN** S73 closes **THEN** `scripts/verify-session-73.sh` proves the artifacts + report
   exist and are internally consistent (the recorded cost equals the artifact's line), and
   `scripts/demo-session-73.sh` shows before → after ("8 stations attested, unmeasured" →
   "measured on a paid run") with the four `demo:<element>` markers; no `src/` change is in
   scope.

## Design (the Architect gate — recorded rationale)
- design-significant: no — a measurement session: no station code, no gate change, no new
  store; any fix the run demands is recorded as an S74 candidate instead (the S63 stance,
  DECISION-002's independence preserved by measuring rather than patching mid-run).

## Plan (ordered steps — cite the acceptance criteria each step covers)
1. Prepare the ride-along with the founder: pick the one real task + target repo, stage the
   artifact capture paths (`sessions/session-73-artifacts/`), and write down the measurement
   checklist before any paid token is spent. covers: 1
2. The founder drives the paid `vajra claude` run; the agent captures live: run JSONL cost
   line, receipt output, hook/gate firings, fold count, commit/branch behavior. covers: 1, 2, 3
3. Derive the numbers from the artifacts: the gates-fired table, receipt-headline vs
   `total_cost_usd`, measured folds, obedience note — every claim traced to a file. covers: 2, 3
4. Write `sessions/session-73-dogfood.md` (honest verdict: helped / hindered / nulls / bugs
   recorded) + `verify-session-73.sh` + `demo-session-73.sh`, then summary + independent cold
   review + attestation (`--inputs-sha 73` at review time). covers: 4, 5

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
- step 4 — done: <sha>

## Guardrails
- **One story:** measure the pipeline as experience. No `src/` changes, no station work, no
  compression fixes — bugs and gaps become recorded S74 candidates.
- **Founder-led is load-bearing:** the agent prepares, captures, derives, reports — it never
  issues the paid prompts (that would measure the agent, not the product).
- Budget: the run stays inside `budget.cap_usd` ($5); the authoritative cost is the JSONL
  line, never the estimate. Max 3 files per commit · branch `session-73-dogfood-ride-along`
  · ~2h cap.
- Honest-nulls rule (S63): "no gate fired" and "0 folds" are results, recorded plainly —
  never dressed up, never omitted.

## Delta (vs ROADMAP — OpenSpec markers)
- `~` `dogfood_check`: measured-stale-since-S63 → refreshed on the full 8-station pipeline
  (founder-led per the S70 decision, so the deferral clause retires).
- `+` `sessions/session-73-dogfood.md` + `sessions/session-73-artifacts/` (raw evidence) —
  the compression-truth dataset for a later fix-or-retire session.
- `-` Nothing removed; compression claims unchanged (never-claim-until-measured holds).

## Deliverable
- `sessions/session-73-dogfood.md` + `sessions/session-73-artifacts/` ·
  `scripts/verify-session-73.sh` + `scripts/demo-session-73.sh` ·
  `sessions/session-73-summary.md` + independent cold `sessions/session-73-review.md`
  (attested) · closeout `.ai/` sync + exactly 3 ranked S74 candidates (standing: compression
  fix-or-retire on this run's data · payload counter [backlog] · semantic/depth hardening of
  the seven-wide marker floor).
