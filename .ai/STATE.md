# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S73 complete, S74 not yet started).
S73 = close-path RELIABILITY ("fix the brakes"): the `hook_adapter` flake is fixed at the ROOT
(a `static ENV_LOCK` isolates the process-global `VAJRA_RAW` leak across parallel test threads —
no assertion weakened, no `#[ignore]`, no retry, no deletion), and the QA + Demo-er live gate runs
are bounded by a recorded, fail-closed timeout (new shared `src/gate_run.rs`: a run past the bound
is killed by process group and BLOCKS, naming the timeout + script). Closeout on
`session-73-close-path-reliability`, PR to `main` — founder call to merge. **S73 spend ~$0.**

## Active PRs
- S73: `session-73-close-path-reliability` → `main` (the deflake + the bounded shared runner +
  CONSTRAINTS/scaffold contract + verify/demo + summary/review + S74 prompt + `.ai/` sync).
  Founder call to merge.
- Merged: S72 [#70](https://github.com/ifelse-codes/vajra/pull/70) · S71
  [#68](https://github.com/ifelse-codes/vajra/pull/68) · S70 GT
  [#67](https://github.com/ifelse-codes/vajra/pull/67) · S69
  [#66](https://github.com/ifelse-codes/vajra/pull/66) · S68
  [#65](https://github.com/ifelse-codes/vajra/pull/65).
- **⚠ The Releaser gate is LIVE (S72, from the S73 close onward):** after merging the S73 PR —
  checkout `main`, pull, `git branch -d session-73-close-path-reliability` and any leftover
  `session-72-*` locals. Skip it and the S74 `--advance` refuses the close (that is the feature).

## Direction (governance is the product — 8 governed stations; the core crew is COMPLETE)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`VISION.md` + `DECISION-001`). Fidelity is the load-bearing governance (`DECISION-002`),
  verdicts attested (`DECISION-003`), chained tamper-evident (`DECISION-004`).
- **Eight stations built + now RELIABLE:** Analyst WHAT (S54+61+62) · Architect DESIGN (S67) ·
  Planner HOW-plan (S64) · Coder DID (S68) · QA WORKS (S69) · Demo-er SHOW (S71) · Releaser SHIP
  (S72) · Reviewer/fidelity+ledger REVIEW (S55–59), riding one `vajra next` + the authoritative
  receipt (S66). **S73 hardened the close path they all ride** (deflake + bounded live runs).
- **S70 founder decisions (binding until revisited):** ① crew first ✓ DONE. ② dogfood: crew
  condition MET but **PARKED by founder call at the S73 pick** (`prompts/parked-dogfood-ride-along.md`,
  READY-shaped; re-enters by rename; GTs report the parked-decision's age, not as drift). ③
  compression: **never claimed until measured real**. ④ **payload counter = the recommended S74
  pick** (S25/S60/S65/S70 meta-gap — do not lose).
- **House patterns:** recorded markers are **existence-gated** (S67/S68); an *executable* marker is
  **re-run live** (S69) **and element-scanned in its live output** (S71); a *git-derived* marker is
  **re-derived from refs at check time** (S72); existence = `is_file()` never readability (S71); the
  gate never performs the human act it waits for (S72). **NEW (S73):** a live gate run is **bounded**
  — a run that cannot finish in the recorded time is killed (process group) and classifies as the
  existing cannot-evaluate BLOCK, never a silent pass; **a committed script must never depend on an
  uncommitted source change** (HEAD internally consistent at every commit — the cold review's
  diff-vs-disk check surfaced this live).

## What Currently Works
- **The 8-station governed pipeline** riding `vajra next` (+ station gates at `--advance`):
  scaffold/validate/intake/options (Analyst) · `--design/--check-design` (Architect) ·
  `--plan/--check-plan` (Planner) · `--exec/--check-exec` (Coder) · `--qa/--check-qa` **bounded**
  live re-run (QA) · `--demo/--check-demo` **bounded** live re-run + element scan (Demo-er) ·
  `--release/--check-release` derived git ship state (Releaser) · fidelity gate + attested, chained
  ledger (Reviewer). Receipt AUTHORITATIVE (S66).
- **The close path is now deterministic + bounded (S73):** the `hook_adapter` compression tests are
  green under repetition (root-isolated env leak); the QA + Demo-er live runs share one bounded,
  fail-closed runner (`src/gate_run.rs`) with a recorded `verify/demo.timeout_secs` (default 600s,
  scaffold-propagated). A hung script is killed and named; a green run is byte-identical.
- **`vajra claude · next · check · init · estimate · meter · hook`** — 7 commands, no 8th. `cargo
  test --lib` **239 passed** (+10 at S73). Enforcement moat (10 hooks, L1/L2/L3, fail-closed) +
  Darshan + Varta hold live. Ledger intact (S72's attested ACCEPT `40823a40…` + S73's ACCEPT
  `1bfb4593…` append on merge).

## What Is Broken / Weak
- **🟡 The self-granted-jurisdiction class is SEVEN gates wide** (Options Unrecorded→WARN · Planner
  digit-tag · Architect form floor · Coder deletion-dodge · QA hollow-green + deletion · Demo-er
  marker-stuffing + deletion · Releaser refs-gone blindness) — all disclosed; semantic/depth
  hardening = standing candidate.
- **🟡 NEW (S73, disclosed fakest green): the QA streamed path collapses *timeout* and
  *spawn-failure* into one `None`** — the block's structured reason is generic; "TIMEOUT" reaches
  the close only via an `eprintln!` side-channel (naming-is-a-print, not a typed state). Contract-
  satisfying (block output names timeout+script, two-token grep; both cases BLOCK); the captured
  path is stronger. Candidate: a typed `CannotEvaluate::{Timeout, SpawnFailure}` (S74 option C).
- **🟡 Compression is a no-op on real CC (S63: 0 folds)** — never claim until measured (S70).
- **🟢→ Dogfood: crew complete + close path reliable** — PARKED by founder call at S73; last paid
  run S63 ($1.27, 6-station era). Re-enters by rename.
- **🟡 Payload counter (S25/S60/S65/S70) — the recommended S74 pick, do not lose.**
- 🟡 Releaser minors (one-close deferral · origin hardcoded · empty-slug parse · init-blocks-on-open-
  stdin) · Demo-er minors (dir-at-path · empty-list fallback · static-scan comments) · QA
  empty-env-value skip · unknown-model estimate = opus upper-bound (fable-5, S66) · ledger
  tamper-EVIDENT not PROOF + opt-in (S59) · guard nested-repo blindspot (S52) · install path
  (crates.io name taken) · KNOWLEDGE.md §6 changelog bloat (GT S65+S70: leave) · readable-roadmap
  one-pager (backlog). **RETIRED at S73:** the `hook_adapter` flake · the unbounded live gate runs.

## What Is In Progress
- **S73 DONE (CODE, independent cold review ACCEPT 13/13, attested `1bfb4593…`), closeout
  committed.** **Next = S74** — recommended: the **payload counter**
  (`prompts/74-task-payload-counter.md`, DRAFT pending founder confirm; alt picks: dogfood [parked]
  · typed cannot-evaluate + depth hardening). New chat for S74. **S75 = next mandatory NO-CODE GT.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · Session 46: ~$3.84 · Session 51: ~$1.52 · Session 52: ~$4.95 · Session 63: ~$1.27.
- Session 53–62, 64–73: ~$0 each (docs/code + negligible cold-review subagents).
- Cumulative: **~$73.6**. Dogfood: last paid run S63 ($1.27) — PARKED by founder call at S73.
