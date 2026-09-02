# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**None — between sessions (S141 complete, S142 not yet started).** S141 shipped on
`session-141-best-install-upgrade` (CODE), ACCEPT + attested; PR opened/merged at close. **Next: S142
(pending founder pick — recommended A: chitra dogfood). Next GT: S145.**

## What shipped this session (S141 — best install + upgrade-in-place)
- **Recorded render provenance.** `fleet::render_subagent_definition` now emits a `vajra-render-sha:`
  stamp as the LAST frontmatter line = sha256 of the render with the stamp line removed. `stamp_render` /
  `strip_render_stamp` are exact inverses; `render_stamp_verifies` re-hashes body-minus-stamp and
  compares. The stamp lives in frontmatter (an unknown key), so Claude Code's loader ignores it and it
  never reaches the model — dispatch-by-name is untouched (asserted per role).
- **The fourth `FleetFileState`.** `classify_fleet_file` returns FOUR states: `Missing` · `UpToDate` ·
  **`StaleRender`** (bytes differ from the current render, but body-minus-stamp re-hashes to its embedded
  stamp → an untouched OLDER render) · `Drifted` (no stamp or a stamp that does not verify). Pure
  function, unit-tested without a filesystem.
- **Smooth upgrade.** `vajra init --sync-fleet` **auto-upgrades a `StaleRender` with NO
  `--overwrite-drifted`** (reported by name + old→new stamp), still **refuses `Drifted`** (exit 1) unless
  the human passes `--overwrite-drifted`, creates `Missing`, no-ops `UpToDate` (no mtime churn).
- **The design is RECORDED, not inferred** — DECISION-007 S141 addendum: this is not the git-blame/
  timestamp classifier S136 rejected; it WRITES a dedicated signal at render time.

## What was proven this session (live probes, not claims)
- `verify-session-141.sh` **10/10** (7 execute-based · 2 structural · 1 nested) · `fixture-141` **8/8**
  (four states against the REAL binary; RRS/EDT plants prove the stamp is load-bearing; POS/END assert a
  clean exit 0) · **457 lib tests** (3 new + classify rewritten to four states) · **fmt + clippy clean**.
- **Independent qa-specialist:** ran both suites (exit 0), classified all checks (**0 hollow**), and ran
  a REAL falsification — broke the `StaleRender` guard → fixture went RED (STA plant) → restored, tree
  clean, nothing committed.
- **Cold fidelity-reviewer: ACCEPT**, all 3 design-advisor `obeyed:` dispositions judged `implemented:`.

## What Is Broken / Weak / Disclosed
- **🟡 Legacy unstamped files stay `Drifted` on first contact.** Every pre-S141 install (chitra's 4 stale
  renders included) is unstamped; its FIRST upgrade still needs one `--overwrite-drifted` (which writes
  the first stamp). Smoothness is **going-forward, not retroactive.** Not a bug — the honest limit,
  disclosed in `## Design` + the addendum + summary. **Candidate A (chitra dogfood) exercises exactly
  this first-contact path in the wild.**
- **🟡 "Claude Code ignores an unknown frontmatter key" is an untested ASSUMPTION** (fidelity rec 2). The
  stamp's inertness is proven by PLACEMENT (frontmatter, not body), not by a live agent dispatch. Strong
  guarantee, not an end-to-end proof; a known risk if a future CC surfaced unknown keys.
- **🟡 The stamp is a content hash, not a keyed signature** — tamper-EVIDENT, not tamper-PROOF (a user
  could forge it by hand). Enough to auto-upgrade the untouched-render case safely; not cryptographic.
- **🔴 Adoption = zero external reach, 90+ days public.** 0 stars / 19 downloads flat / 0 issues (S140).
  The fleet is real inside this repo + chitra; it reaches no one outside.
- **🔴 The 5 quiet fleet roles remain under-proven** (a bound dispatch ≠ good advice — S140).
- **🔴 Carried, not touched:** reviewer-independence self-certification at close (S138B, candidate C);
  non-fleet scaffold files still add-only (candidate B); `--dogfood-age` blind to in-chitra dogfoods
  (S140, LOW); brownfield threshold hole (S134); NO VAJRA COMMAND STARTS A SESSION.

## What Currently Works
- The fleet render now carries recorded provenance; `--sync-fleet` is a real UPGRADE path (four states)
  — the S136 floor is lifted for stamped files.
- The 8 stations riding `vajra next` (+ gates at `--advance`) and the closeout gate
  (`verify-closeout.sh`, 15 checks incl. design-advisor mandate + attestation + `check_required_crew`).
- The fleet is TEN roles, THREE mandatory (`fidelity-reviewer`, `design-advisor`, `tech-lead`) — real in
  chitra (S136), the tech-lead's `required` verdict binding the CLOSE (S139), all exercised on S141.
- Enforcement floor, tamper-evident ledger (S100), receipts (authoritative on headless stream-json).

## What Is In Progress
- **Nothing mid-flight in Vajra.** S141 is complete on `session-141-best-install-upgrade`, ACCEPT +
  attested + merged. **S142 is not yet picked** — three candidates presented (A recommended).

## Active PRs
- **S141 PR** opened + merged at close (best install + upgrade-in-place). S140 was a NO-CODE GT (no PR).
  S139 [#168](https://github.com/ifelse-codes/vajra/pull/168) MERGED · S138
  [#167](https://github.com/ifelse-codes/vajra/pull/167) MERGED.

## Direction (governance is the product — shaped as a shippable MVP)
- **Product = provable agent governance** (`DECISION-001`), sold as the autopilot trust layer
  (`DECISION-005`). **Direction, locked S130: MAKE THE FLEET REAL** — installed + dispatchable is not the
  same as proven to give good advice (S140).
- **Founder's completeness order (S140):** (1) **fresh-user / upgrade-in-place — DONE (S141)**, (2) one or
  two chitra dogfoods (NEXT), (3) prove the loop works even expensively THEN cut cost (after S145), (4)
  the dogfood-age gauge = low, someday. Rung 3 runs only once building is done.
  See `[[vajra-s140-completeness-priorities]]`.
- **Next: S142 (pending pick — recommended A: chitra dogfood). Next GT: S145.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative. S36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- S53–75: ~$0 each. **S76: real but UNKNOWN** (opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713 · S97: $1.2758 · S102: $0.4644 · S103: $0.6797.**
- **S104–109: ~$0 each. S110/S120: $0 (NO-CODE GT). S118: $4.0911771 · S124: $3.2984944 · S126: $4.4482.**
- **S128–S133: $0 metered** (interactive). **S134: $1.6103385** (chitra dogfood) + ~19.2M raw subagent tokens.
- **S135/S136: $0 metered** — 4.18M / 731,943 RAW subagent tokens. **S137: $0 (honest null)** — 486,695 RAW.
- **S138: $2.988 AUTHORITATIVE** + 237,584 RAW. **S138B: $5.405 AUTHORITATIVE.** **S139/S140: $0 metered.**
- **S141: $0 metered** (interactive) — four tight named-files subagent dispatches (tech-lead,
  design-advisor, qa-specialist, fidelity-reviewer); no `vajra claude` paid run (that is S142).
- Cumulative: **~$104.2 + S76 (unknown, ≤ ~$26.6) + S111–S141 subagents (unknown, growing).**
