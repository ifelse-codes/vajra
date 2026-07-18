# Session 74 — The payload counter: measure whether the PIPELINE advances

**Type:** CODE · **Branch:** `session-74-payload-counter` · **Spend:** ~$0

## Goal — achieved?

**Yes.** `vajra next --stations NN` now prints a per-station PASSED/ABSENT table + a derived
**K-of-8**, read-only (nothing executes), and it is a mandatory GT input
(`pipeline_advance_check`). Each PASS is read from that station's OWN classifier — never a
self-asserted digit (the S64 digit-tag lesson). This retires the meta-gap recommended at
S25/S60/S65/S70: "did the PIPELINE advance?" is now a measured question.

## Evidence

- `cargo test --lib` **248 passed** (+9: the `stations` module).
- New `src/stations/mod.rs` — the counter, reusing each station's classifier:
  Analyst `validate_prompt` · Architect `design_gate` · Planner `plan_gate` · Coder `exec_gate` ·
  QA/Demo-er `gather_contract` (static) · Releaser `derive_ship_state` · Reviewer (review artifact).
- `vajra next --stations` (rides `next` — no 8th command). Live: S73 reads **7/8**, S74-in-flight
  reads lower (SHIP/REVIEW earned only at close), a fresh scaffold reads **0/8**.
- `scripts/verify-session-74.sh` (9 unit tests + E2E incl. the never-disagree property +
  no-CLI/dep/store + verify-71/72/73 re-run) · `scripts/demo-session-74.sh` (4 `demo:` markers).
- Coder gate READY on S74 (Execution trace names the 4 real step commits).

## Fidelity map (every numbered requirement → what shipped)

| # | Requirement (prompt) | Verdict | Evidence |
|---|---|---|---|
| Acc 1 | `--stations NN` prints per-station PASSED/ABSENT from the same evidence the gates use + "K of 8" | **SHIPPED** | `format_station_report`; live on S73/S74/scaffold |
| Acc 2 | placeholder/missing counts ABSENT, never PASSED | **SHIPPED** | classifiers map only substantive terminal → Passed; `placeholder_laden_prompt_counts_low` = 0/8 |
| Acc 3 | reuses each station's existing classifier; rule and counter never disagree | **SHIPPED (static scope)** | `planner_counter_agrees_with_plan_gate`; E2E `counter-agrees-with-check-gates`. **Caveat:** QA/Demo read STATICALLY (see fakest green) |
| Acc 4 | the count is an available GT input (recorded where the GT reads it) | **SHIPPED** | `pipeline_advance_check` + `pipeline_advance_questions` in `.ai/CONSTRAINTS.yaml`; derived live, no new store |
| Acc 5 | proven: verify (8/8 fixture, placeholder low, agreement) + demo + cold review + attestation | **SHIPPED** | verify-74 + demo-74; cold review + attestation below |
| Plan 1–4 | module → surface → GT-wiring → proof | **SHIPPED** | commits `921728e6` · `09ad1d63` · `418b65e8` · `ea9a017f` |
| Guardrail | one story, no station-behavior change, derive-never-assert, ≤3 files/commit | **HELD** | no gate semantics touched; per-commit-file-cap green |

**NOT-BUILT / re-scoped, stated plainly:**
- A single "fully-filled prompt → **8/8**" is not reachable in a no-remote fixture: SHIP needs a
  synced `origin/main` and REVIEW needs an attested ACCEPT artifact. The honest ceiling in the test
  repo is **7/8**; the verify asserts 7/8 and says why. (The prompt's Acc 5 said "8/8"; delivered
  7/8 + documented why 8 is unreachable offline — a scope-honest deviation, not a silent one.)
- `vajra init`'s CONSTRAINTS template was NOT updated to carry `pipeline_advance_check` (precedent:
  the template already omits `dogfood_check`). New repos don't get the audit — deferred, disclosed.

## Fakest green (the hollow-looking pass)

**QA and Demo-er are read STATICALLY by the counter** (`script_exists`, elements-in-file), because
`--stations` must not execute (Acc 1, read-only). That is WEAKER than the close gate's live green:
a `--stations` QA/Demo PASS attests the evidence is gate-**eligible**, not that a live re-run is
green. So "the counter never disagrees with the gate" (Acc 3) holds only on the STATIC dimension —
a script that exists but would fail live is counted PASSED here while the close gate BLOCKS. Fully
disclosed in the module header, the notes (`[static — not live-green]`), and the demo's honest edge.

## Independent fidelity review

`sessions/session-74-review.md` — a cold pass fed only the prompt + the diff. **Verdict: see file.**

## Next options (A/B/C) — for the S75 board (S75 is the mandatory NO-CODE GT)

**A. S75 = the Ground Truth (mandatory, every 5th) — the counter's first real reading is the
headline.** · *Goal:* run all 9 audits incl. the new `pipeline_advance_check`; read `--stations`
across S54–S74 and judge whether the pipeline is advancing or the machinery is outgrowing the
payload. · *Why:* it's mandatory (NN%5==0) and this session built the exact instrument the GT was
missing. · *Risk:* the counter's first reading may show a flat payload — that's the finding, not a
failure.

**B. Typed cannot-evaluate + station-note hardening (CODE).** · *Goal:* the S73 fakest green —
collapse-of-timeout-and-spawn-failure into one `None` — plus give the counter a third `Blocked`
outcome so a live-red QA is distinguishable from an absent one. · *Why:* sharpens two disclosed
edges. · *Risk:* low leverage; polishing, not advancing the pipeline. **(NB: S75 must be NO-CODE.)**

**C. Paid dogfood ride-along (parked).** · *Goal:* un-park `prompts/parked-dogfood-ride-along.md`
and run real work through `vajra claude`, now reading `--stations` alongside the cost ledger. ·
*Why:* last paid run was S63; the crew + counter are complete. · *Risk:* founder parked it at S73
by decision — needs an explicit un-park. **(NB: S75 must be NO-CODE; this is an S76 candidate.)**
