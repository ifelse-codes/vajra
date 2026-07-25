# Session 101 — Release backstop slice: README truth-pass + crate-rename scoping

> **Status:** APPROVED — founder picked **C** from `sessions/session-100-ground-truth.md` (chat,
> 2026-07-24), in reply to the S100 ground-truth options presented in plain English.
> **Freeze-rule note:** C is neither a ladder run nor a fix-what-broke, so it **bends the
> machinery-freeze rule** (`DECISION-005`). That is a founder override, made knowingly — the report
> named this as C's key risk and the founder chose it anyway. Recorded here so the S105 GT sees the
> exemption was explicit, not smuggled.

## Type
- **CODE (docs).** No `src/` logic. Max 2 assumptions · 2 retries · ~2h · 1 story · new chat ·
  `VAJRA_ALLOW_COMMIT=101` on every commit · independent cold fidelity review (`DECISION-002`).

## Goal

Make the README tell the truth, and settle the crate name on paper. Today `README.md` promises three
install methods that do not work and prints receipt claims two fixes out of date. This is the first
slice of the **2026-09-15 release backstop** (`.ai/ROADMAP.md`): a stranger who reads the README
should be able to trust every sentence, and the v0.1 crate name should be a decided fact, not a TODO.

**This session does NOT publish, tag, or rename anything.** It corrects docs and records a decision.
The actual `cargo publish` / git tag / `Cargo.toml` rename are release *actions* for a later session.

**Scope fence:** README + one decision doc + this session's verify/demo scripts. No `src/`, no
`Cargo.toml` edit, no new command, no VISION edit (its body was already corrected in S100).

## The gaps, grounded (verified 2026-07-24 — evidence a reviewer can re-run)

| Line(s) | Claim in README today | Reality | How to re-check |
|---|---|---|---|
| 9 | `cargo install vajractl` | **not published** — crates.io has no `vajractl` | `curl -fsS https://crates.io/api/v1/crates/vajractl` → empty |
| 15 | `brew install suman/tap/vajra` | tap repo **does not exist** | `gh repo view suman/homebrew-tap` → "Could not resolve" |
| 18 | `curl …/releases/latest/download/…` | **no releases, no tags** → 404 | `gh release list` → empty · `git tag` → empty |
| 44 | receipt "overstates real spend by ~8× (cache-pricing bug)" | **fixed** — receipt is authoritative from `total_cost_usd` (S66/S78), honest-null when absent (S77) | `sessions/session-97-artifacts/total_cost_usd.txt` = $1.2758 real |
| 94–99 | example receipt `$33.4976  total (opus-4-6 …)` | stale figure + a model id that isn't priced; oversells the old bug | replace with a real captured receipt (S97 $1.2758 fable-5, or S92 $0.2713) |
| 30 | "first stage (Analyst) ships today … next build is the fidelity auditor — in build, not shipped" | **45 sessions stale** — all 8 stations shipped (S54–S72); fidelity auditor shipped + attested + chained (S55–S59) | `vajra next --stations 99` → 8/8 · `verify-closeout.sh --ledger` → 36 records |
| 39, 34–42 | `vajra check` "10 checks"; table omits `estimate` + `hook` | check is **11** now; 7 commands exist | `vajra check` → Score /11 · `vajra --help` |

Only `cargo install --path .` from source (line 12) currently works — keep it.

## Deliverables
- `README.md` — corrected so every claim is verifiable today:
  1. **Install:** keep the source build as the one working method; relabel crates.io / Homebrew /
     prebuilt-binary as **"planned for v0.1 — not yet published"** (do not delete — they are the
     release target), so no reader hits a 404.
  2. **Receipt honesty note (line 44):** retire the ~8× claim; state the current truth — the receipt
     reports the tool's own `total_cost_usd` when present and says so honestly when it is not.
  3. **Receipt example (lines 94–99):** replace with a real captured receipt (cite the session).
  4. **Direction paragraph (line 30) + Current Status table:** update to shipped reality (8-station
     pipeline; fidelity auditor shipped/attested/chained; `vajra check` 11 checks; list all 7
     commands). Keep every honesty row (compression $0/unproven stays — it is true).
- `docs/decisions/DECISION-006-crate-name.md` — the crate-name decision: definitively check
  availability of `vajractl` and `vajra` on crates.io, state the chosen v0.1 name (crate + binary),
  and the reason. Decision only — no `Cargo.toml` change this session.
- `scripts/verify-session-101.sh` (exits 0) · `scripts/demo-session-101.sh`.
- `sessions/session-101-summary.md` + exactly 3 ranked next candidates.

## Acceptance (testable)
1. WHEN `scripts/verify-session-101.sh` runs THEN it asserts `README.md` contains **none** of the
   stale strings — no `~8×`/`~8x` receipt-bug claim, no `opus-4-6`, no `$33.4976` — and exits 0.
2. WHEN the README's Install section is read THEN exactly one method is presented as working today
   (`cargo install --path .`), and crates.io / Homebrew / prebuilt-binary are each explicitly marked
   not-yet-published; the verify script asserts each currently-broken command line carries that marker.
3. WHEN the Direction paragraph and Current Status table are read THEN they match the shipped reality
   (8 stations; fidelity auditor shipped; `vajra check` = 11; all 7 commands listed) — the verify
   script asserts the "next build is the fidelity auditor" phrasing is gone and `estimate` + `hook`
   are present in the table.
4. `docs/decisions/DECISION-006-crate-name.md` exists, records the live crates.io availability check
   for both names with the command used, and states the chosen v0.1 crate + binary name with a reason.
5. The honest verdict this session must state plainly: nothing was **published, tagged, or renamed** —
   the README's not-yet-published labels are a promise to a future release session, and the crate name
   is decided on paper only. `Cargo.toml` is untouched.

## Design (the Architect gate)
- design-significant: **no** — docs + one decision record; no interface, no code path, no new command.
- Rests on `.ai/ROADMAP.md` (2026-09-15 release backstop) and `DECISION-005`. Follows the house
  "measure/state honestly rather than force green" pattern: broken install paths are labelled, not
  hidden, so the README is honest *before* the release makes them true.

## Plan (ordered steps — `covers:` the acceptance criteria)
1. README truth-pass — fix Install (one working method + not-yet-published labels), retire the ~8×
   note, replace the receipt example with a real captured one, update the Direction paragraph + Status
   table to shipped reality. covers: 1, 2, 3
2. Crate-name decision — run the live crates.io availability check for `vajractl` and `vajra`, write
   `docs/decisions/DECISION-006-crate-name.md` (availability + chosen name + reason), and make the
   README crates.io line consistent with it. covers: 4
3. Verify + demo — `scripts/verify-session-101.sh` (asserts the stale strings are gone, the
   not-yet-published markers are present, the fidelity-auditor phrasing is gone, `estimate`+`hook`
   listed) and `scripts/demo-session-101.sh` (before/after of a corrected claim). covers: 1, 2, 3, 5

## Execution (the Coder gate — fill each step's landing commit as work lands)
- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>

## Guardrails
- ONE story: *make the README true + settle the crate name on paper*. No `src/`, no `Cargo.toml`, no
  publish/tag/rename, no new command, no VISION edit.
- Own the `.ai/` spine — no second store, no 8th command, no new artifact by reflex.
- Darshan every human reply · Varta against the live `.ai/`.
- Max 3 files per atomic commit. Commits need `VAJRA_ALLOW_COMMIT=101` (S93 enforced).
- The independent cold fidelity review (`DECISION-002`) is fed only this prompt + the diff.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` `docs/decisions/DECISION-006-crate-name.md` (the v0.1 crate name, decided).
- `~` `README.md` install methods, receipt note + example, Direction paragraph, and Status table
  corrected to what is verifiable today.
- `-` retires three non-working install commands as if they worked, the stale ~8× receipt-bug claim,
  and the 45-session-stale "the pipeline is the next build" framing.
