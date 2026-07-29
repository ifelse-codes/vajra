# Session 106 — CODE: make it installable (v0.1) — the first stranger-shippable slice

> **Status:** APPROVED (founder pick, S105 closeout — option ① of 3; the C→B→A order's **B**).
> Written at S105 closeout per `end_of_session.must_write_next_prompt_before_close`. This is the
> first BUILD session under the S103 pivot: **sessions now finish a shippable MVP.**

## Goal

Close the biggest slice of the **stranger-shippability gap** the S105 ground truth named: a stranger
can go from nothing to a working `vajra` in **one install path** and a **verified 10-minute
quickstart** — *and we can prove it with an instrument, not a feeling.*

**One install path, done for real** beats three half-published ones. Pick the path with the least
irreversible risk (recommend: a **tagged binary release** or a `cargo install --git` path) BEFORE
burning the crates.io name.

## Why this session (evidence from S105 GT)

- The governance **engine** is done and proven (S103 forced block, attested ledger, authoritative
  receipts). The shippable **package** is ~0%: the README marks 3 install methods "NOT YET
  PUBLISHED"; `DECISION-006` settled the crate name (`vajractl`/`vajra`) **on paper only** —
  `Cargo.toml` untouched.
- **Meta-check blind spot (S105):** `vajra next --stations` read **7/8 on S101 while every install
  path was broken.** No instrument answers *"can a stranger ship with this?"* This session must ship
  that instrument alongside the install path — else "installable" stays unmeasured.

## Scope (max 1 story; ≤3 files per commit; ~2h cap)

**In:**
1. **One install path that actually works** from a clean checkout — recommend a tagged release with a
   prebuilt binary (GH Actions release pipeline already exists, S10–S17) **or** `cargo install --git`.
   Do NOT `cargo publish` to crates.io this session unless the founder explicitly approves (the name
   burns on first publish — irreversible).
2. **An installability smoke test** — the missing instrument: a script that, in a **fresh temp dir**
   with no prior `.ai/`, runs the chosen install path → `vajra init` → `vajra next` and asserts each
   step succeeds inside a time budget. This is the falsifiable answer to the meta-check.
3. **README quickstart truth-pass** — the one working path replaces its "NOT YET PUBLISHED" row;
   the other rows stay honestly marked until they ship. No faked paths (the S101 rule holds).

**Out (defer):** crates.io publish (founder-gated, irreversible) · brew/other install paths · the
real agent fleet (A) · any pipeline-station work.

## Acceptance criteria

1. From a clean checkout, the chosen install path produces a runnable `vajra` — shown by real
   command output in the session summary (not a claim).
2. `scripts/install-smoke.sh` (or similar) runs fresh-dir install → `vajra init` → `vajra next`,
   asserts each succeeds, and **exits non-zero if any step fails** — demonstrated live.
3. The README shows exactly the path(s) that work; unshipped paths stay marked NOT YET PUBLISHED.
4. `cargo test --lib` stays green; CI green both OS; no pipeline-station logic changed.
5. Nothing published to crates.io without an explicit founder token in chat.
6. Independent cold review (`sessions/session-106-review.md`) → ACCEPT, attested; ledger appended.

## Guardrails

- Branch `session-106-<slug>`; commits carry `VAJRA_ALLOW_COMMIT=106`.
- **crates.io publish is irreversible** — treat as a prohibited action absent an explicit founder
  "yes publish" in chat. Reserving a name by publishing an empty crate still burns it.
- Every "it installs" claim must be re-derivable by a stranger from the smoke test's output.
- If the install path needs a `Cargo.toml` version/metadata change, that is in-scope; a rename of the
  package is NOT (name already settled — `DECISION-006`).
