# Session 101 — Summary: README truth-pass + crate-name decision

**Type:** CODE (docs) · founder pick **C** (release-backstop slice; a knowing machinery-freeze
override, recorded in the prompt Status block). **Cost:** ~$0 (no `vajra claude` run).
**Branch:** `session-101-readme-truth-crate-scope`.

## Goal — achieved

Make the README tell the truth and settle the v0.1 crate name on paper. **Done.** A stranger reading
the README now hits exactly one working install method; the three unpublished ones are labelled, not
faked; the receipt note + example reflect the fixed authoritative-cost behaviour; the Direction
paragraph and command table match shipped reality; and `DECISION-006` records the crate name against a
live, re-runnable crates.io check. **Nothing was published, tagged, or renamed.** `Cargo.toml`
untouched.

## Evidence

- `scripts/verify-session-101.sh` → **24/24, exit 0** (stale strings gone · each broken install
  command carries `NOT YET PUBLISHED` · Direction phrasing updated · DECISION-006 records the check ·
  scope holds · `cargo test --lib` green).
- `scripts/demo-session-101.sh` → emits all 4 Demo-er markers; before/after of the corrected receipt +
  install claims; exit 0.
- Live grounding (2026-07-25): `vajractl` → **HTTP 404 (available)**, `vajra` → **HTTP 200 (taken,
  v0.1.0, 1487 downloads)**; `suman/homebrew-tap` unresolvable; `gh release list` empty; `git tag`
  empty; `vajra check` = **11/11**; `vajra --help` = 7 commands.
- Independent cold review (`sessions/session-101-review.md`): **ACCEPT**, attested
  `a96455ff…3f9193d`.

## Fidelity map (every numbered requirement → what shipped)

| Requirement | Status | Note |
|---|---|---|
| D1 Install: 1 working + 3 relabelled not-yet-published | SHIPPED | source build first; markers on each broken command |
| D2 Receipt note: retire ~8× → authoritative/honest-null | SHIPPED | — |
| D3 Receipt example: real captured receipt, cite session | SHIPPED | S97 `$1.2758` fable-5 capture |
| D4 Direction para + Status table → shipped reality | SHIPPED | 8 stations; auditor shipped/attested/chained; check 11; 7 commands |
| D5 DECISION-006 (live check + chosen crate+binary+reason) | SHIPPED | vajractl (crate) / vajra (binary) |
| D6 verify + demo scripts | SHIPPED | 24/24; 4 markers |
| AC1–AC5 (testable) | SHIPPED | see review table |

**Fakest green (disclosed):** the receipt example's "real captured receipt" provenance is asserted in
prose — the verify script proves the *old* strings are gone, never that the *new* figures are
genuinely from S97. Within contract (deliverable asks only "cite the session"; numbers are internally
consistent and match the memory-recorded ~$1.27 chitra dogfood) and not grep-testable in a docs
session. Flagged, not hidden.

**NOT built (by design):** no `cargo publish`, no git tag, no binary release, no Homebrew tap, no
`Cargo.toml` rename, no VISION edit, no new command. Those are later release *actions*.

## Freeze-rule note
S101 bent the machinery-freeze rule (`DECISION-005`) — neither a ladder run nor a fix-what-broke. A
knowing founder override; recorded so the S105 GT sees the exemption was explicit, not smuggled.

## Next — 3 candidates (founder picks; new chat for S102)

- **A · Autopilot Ladder Rung 2** — *one day unattended, multi-task, on chitra; zero governance leaks
  + honest receipts + fidelity verdicts correct on founder spot-check.* Why: the actual next rung and
  the crown-jewel proof; freeze rule's active queue. Risk: chitra's on-disk prompts are still legacy
  (must `vajra next --advance`/re-init first — S99 carry-forward) or Coder re-hits the marker wall;
  guards must be ON; the run will read ~1–3/8 by construction (S100 🔴).
- **B · Ladder-run evidence contract (prompt-level)** — *define what a DOGFOOD/ladder session must
  produce (a real `session-NN-review.md` judged on run evidence — receipt, blocked-action log,
  subject-repo diff) before Rung 2 climbs.* Why: closes the S100 🔴 (ladder runs invisible to both GT
  instruments) with no code; makes Rung 2 auditable. Risk: writing process about a run not yet run;
  best folded *into* A rather than run standalone.
- **C · Finish the release-backstop slice** — *10-minute quickstart + the remaining README/VISION
  release polish (still docs, still no publish).* Why: continuity with S101; keeps the 2026-09-15
  backstop moving. Risk: extends the freeze-rule exception a second time; lower leverage than proving
  the loop (A).

**Recommendation:** **A**, with **B folded in** (write the run's evidence contract into the A prompt,
per the S100 mitigation and the backlog's "prompt-level version should ride S101-A").
