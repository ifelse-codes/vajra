# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S74 complete, S75 not yet started).
S74 = the PAYLOAD COUNTER: `vajra next --stations NN` prints a read-only per-station PASSED/ABSENT
table + a derived K-of-8 of how many governed stations a prompt DEMONSTRABLY passed — each PASS read
from that station's OWN classifier (never a self-asserted digit), and now a mandatory GT input
(`pipeline_advance_check`). Retires the S25/S60/S65/S70 meta-gap. Closeout on
`session-74-payload-counter`, PR to `main`. **S74 spend ~$0.**

## Active PRs
- S74: `session-74-payload-counter` → `main` (the `stations` module + `--stations` surface + the
  GT-input wiring + verify/demo + summary/review + S75 GT prompt + `.ai/` sync). Founder call to merge.
- Merged: S73 [#71](https://github.com/ifelse-codes/vajra/pull/71) · S72
  [#70](https://github.com/ifelse-codes/vajra/pull/70) · S71
  [#68](https://github.com/ifelse-codes/vajra/pull/68) · S70 GT
  [#67](https://github.com/ifelse-codes/vajra/pull/67) · S69
  [#66](https://github.com/ifelse-codes/vajra/pull/66).
- **⚠ The Releaser gate is LIVE:** after merging the S74 PR — checkout `main`, pull,
  `git branch -d session-74-payload-counter` and any leftover `session-73-*` locals. Skip it and the
  S75 `--advance` refuses the close (that is the feature).

## Direction (governance is the product — 8 governed stations, COMPLETE + now MEASURED)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`VISION.md` + `DECISION-001`). Fidelity is the load-bearing governance (`DECISION-002`), verdicts
  attested (`DECISION-003`), chained tamper-evident (`DECISION-004`).
- **Eight stations built + reliable (S73) + now MEASURED (S74):** Analyst WHAT (S54+61+62) ·
  Architect DESIGN (S67) · Planner HOW-plan (S64) · Coder DID (S68) · QA WORKS (S69) · Demo-er SHOW
  (S71) · Releaser SHIP (S72) · Reviewer/fidelity+ledger REVIEW (S55–59), riding one `vajra next` +
  the authoritative receipt (S66). **S74 added the payload counter** — the first PIPELINE-level
  metric across all eight stations, derived from their own classifiers.
- **S70 founder decisions (binding until revisited):** ① crew first ✓ DONE. ② dogfood: crew
  condition MET but **PARKED by founder call at the S73 pick** (`prompts/parked-dogfood-ride-along.md`,
  READY-shaped; re-enters by rename; GTs report the parked-decision's age, not as drift). ③
  compression: **never claimed until measured real**. ④ payload counter = **BUILT (S74)**. S74
  founder pick: S76 direction = **"let the GT decide"** (no pre-commitment).
- **House patterns:** recorded markers are **existence-gated** (S67/S68); an *executable* marker is
  **re-run live** (S69) **and element-scanned in its live output** (S71); a *git-derived* marker is
  **re-derived from refs at check time** (S72); a live gate run is **bounded + killed-by-process-group
  past the bound** (S73); existence = `is_file()` never readability (S71); the gate never performs the
  human act it waits for (S72); a committed script must never depend on an uncommitted source change
  (S73). **NEW (S74):** a derived metric **reuses each gate's own classifier** so it cannot drift from
  the gate (never a second, forgeable digit-tag) — and where a classifier is LIVE-executing (QA/Demo),
  a read-only derivation reads it STATICALLY and DISCLOSES the weaker read.

## What Currently Works
- **The 8-station governed pipeline** riding `vajra next` (+ station gates at `--advance`):
  scaffold/validate/intake/options (Analyst) · `--design/--check-design` (Architect) ·
  `--plan/--check-plan` (Planner) · `--exec/--check-exec` (Coder) · `--qa/--check-qa` bounded live
  re-run (QA) · `--demo/--check-demo` bounded live re-run + element scan (Demo-er) ·
  `--release/--check-release` derived git ship state (Releaser) · fidelity gate + attested, chained
  ledger (Reviewer). Receipt AUTHORITATIVE (S66).
- **The payload counter (S74):** `vajra next --stations NN` — read-only, derives per session how many
  of the 8 stations a prompt DEMONSTRABLY passed (K-of-8), each from the station's own classifier;
  placeholder/absent → ABSENT. A mandatory GT input (`pipeline_advance_check`). Live: S73 = 7/8, a
  fresh scaffold = 0/8. **Honest limit:** QA/Demo read STATICALLY (gate-eligible, not live-green).
- **`vajra claude · next · check · init · estimate · meter · hook`** — 7 commands, no 8th. `cargo
  test --lib` **248 passed** (+9 at S74). Enforcement moat (10 hooks, L1/L2/L3, fail-closed) +
  Darshan + Varta hold live. Ledger intact (S73's attested ACCEPT `1bfb4593…` + S74's ACCEPT
  `9b0d5eb7…` append on merge).

## What Is Broken / Weak
- **🟡 The self-granted-jurisdiction / can-drift class is now EIGHT+ gates wide** (Options · Planner
  digit-tag · Architect form floor · Coder deletion-dodge · QA hollow-green · Demo-er marker-stuffing ·
  Releaser refs-gone · **the S74 static-QA/Demo counter read**) — all disclosed; semantic/depth
  hardening = standing candidate (S76 lens).
- **🟡 NEW (S74, disclosed fakest green): the payload counter reads QA + Demo-er STATICALLY**
  (`script_exists` / elements-in-file), weaker than their live close gates — a `--stations` QA/Demo
  PASS is gate-*eligible*, not live-green, so AC-3 "never disagree" holds only on the static
  dimension. Also: the Reviewer station re-implements verdict parsing (no Rust reviewer classifier).
  Candidate: a third `Blocked` counter outcome + a shared reviewer classifier.
- **🟡 The S73 fakest green persists:** the QA streamed path collapses *timeout* + *spawn-failure*
  into one `None` (typed `CannotEvaluate::{Timeout, SpawnFailure}` = S76 candidate B).
- **🟡 Compression is a no-op on real CC (S63: 0 folds)** — never claim until measured (S70).
- **🟢→ Dogfood: crew complete + reliable + measured** — PARKED by founder call at S73; last paid run
  S63 ($1.27, 6-station era). Re-enters by rename.
- 🟡 `vajra init` CONSTRAINTS template does NOT carry `pipeline_advance_check` (precedent: it already
  omits dogfood_check) — new repos don't get the audit; deferred, disclosed. · Releaser minors
  (one-close deferral · origin hardcoded · empty-slug parse · init-blocks-on-open-stdin) · Demo-er
  minors (dir-at-path · empty-list fallback · static-scan comments) · QA empty-env-value skip ·
  unknown-model estimate = opus upper-bound (fable-5, S66) · ledger tamper-EVIDENT not PROOF + opt-in
  (S59) · guard nested-repo blindspot (S52) · install path (crates.io name taken) · KNOWLEDGE.md §6
  changelog bloat (GT S65+S70: leave) · readable-roadmap one-pager (backlog).

## What Is In Progress
- **S74 DONE (CODE, independent cold review ACCEPT 11/17, attested `9b0d5eb7…`), closeout committed.**
  **Next = S75 — the mandatory NO-CODE Ground Truth** (`prompts/75-task-ground-truth.md`, APPROVED;
  headline = the payload counter's first real reading across S54→S74; 3 ranked S76 candidates, founder
  "let the GT decide"). New chat for S75. **S80 = the GT after.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · Session 46: ~$3.84 · Session 51: ~$1.52 · Session 52: ~$4.95 · Session 63: ~$1.27.
- Session 53–62, 64–74: ~$0 each (docs/code + negligible cold-review subagents).
- Cumulative: **~$73.6**. Dogfood: last paid run S63 ($1.27) — PARKED by founder call at S73.
