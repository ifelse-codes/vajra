# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**None — between sessions (S143 complete, S144 not yet started).** S143 shipped on
`session-143-constitution-upgrade` (CODE), ACCEPT + attested (`173da680`); PR opened/merged at close.
**Next: A (chitra full-loop dogfood) or B (prove the 5 quiet roles). Next GT: S145.**

## What shipped this session (S143 — the constitution joins the smooth upgrade)
- **`.ai/AGENTS.md` splits into a user-owned FILLED header + a byte-identical GOVERNED body**, divided by
  `GOVERNED_BODY_SENTINEL` (`<!-- vajra:governed-body - do not edit below this line ... -->`, HTML-legal,
  no fill). `TPL_AGENTS` → `TPL_AGENTS_HEADER` (fill lives here only) + `TPL_AGENTS_BODY` (no fill,
  asserted) + `governed_body_canonical()` (sentinel first, `MarkdownComment` stamp last, covering the
  sentinel). Scaffolded already stamped, so a fresh `init` + immediate `--sync-fleet` is `UpToDate`.
- **`--sync-fleet` upgrades ONLY the governed body (a boundary target).** A sync target carries
  `boundary: Option<&'static str>`; roles/hooks pass `None` (byte-identical S141/S142 whole-file path),
  the constitution passes `Some(sentinel)`. `body_region()` slices from the sentinel; `classify_fleet_file`
  runs the state machine on that region against a body-only canonical; `write_target` keeps the header
  above the sentinel VERBATIM and bails if the sentinel is absent (defense-in-depth).
- **The fifth state, `FleetFileState::NeedsBoundary`.** A pre-S143 boundaryless constitution is refused
  even under `--overwrite-drifted` (that flag would destroy the fill), with the exact sentinel printed for
  a one-time paste. A DELETED constitution warns "run `vajra init`" (sync upgrades; init scaffolds). Still
  the SINGLE `vajra init --sync-fleet` — report line reads "N roles + N hooks + 1 constitution", no 8th command.
- **DECISION-007 S143 addendum** records the boundary sentinel, body-scoped classify/rewrite, the legacy
  migration, header preservation, `CONSTRAINTS.yaml` out, 8 rejected alternatives, and the honest limits.

## What was proven this session (live probes, not claims)
- `verify-session-143.sh` **13/13** (11 execute-based · 2 structural · 1 nested) · `fixture-143` **9/9**
  (five states on the CONSTITUTION vs the REAL binary; **HDR proves the header survives byte-for-byte**,
  **NB proves the boundaryless refusal even under `--overwrite-drifted`**, RRS/EDT prove the body stamp is
  load-bearing, END a clean-exit-0 control) · **469 lib tests** (8 new) · fmt+clippy.
- **Independent qa-specialist:** ran verify (13/13), fixture (9/9), 469 tests LIVE; classified **0 hollow**;
  ran a REAL falsification — clobbered the header in `write_target` → fixture RED on HDR/MIG for the exact
  right reason → reverted, tree byte-clean.
- **Cold fidelity-reviewer: ACCEPT** (6/6 at close), all 15 `obeyed:` dispositions (design-advisor 1–10 +
  tech-lead 1,2,3,4,6) judged `implemented:`. Found 3 under-disclosed gaps → **all closed in-session** (b9679b5).

## What Is Broken / Weak / Disclosed
- **🟡 The sentinel is located by an EXACT-match `find`, first occurrence.** A mangled sentinel →
  `NeedsBoundary` (restore the exact line); a header that QUOTES the exact sentinel would have everything
  after it treated as governed body (pathological, disclosed in the addendum).
- **🟡 The constitution write is not atomic** — `write_target` bails BEFORE writing on a missing sentinel
  (the fill is safe), but once it commits it does a non-atomic `fs::write` (qa rec 4, deferred).
- **🟡 No double-sentinel falsification fixture** — the first-occurrence contract is disclosed, not pinned
  by a red-going plant (qa rec 2, deferred).
- **🟡 Legacy backward-compat stays honest, not retroactive.** Every pre-S143 install has a boundaryless
  constitution → `NeedsBoundary` on first contact → one manual sentinel paste + `--overwrite-drifted`.
- **🟡 The stamp is a content hash, not a keyed signature** — tamper-EVIDENT, not tamper-PROOF (S141).
- **🔴 Adoption = zero external reach, 90+ days public.** 0 stars / 19 downloads flat / 0 issues (S140).
- **🔴 The 5 quiet fleet roles remain under-proven** (a bound dispatch ≠ good advice — S140); all six
  non-required roles were deferred-budget again this session.
- **🔴 Carried, not touched:** reviewer-independence self-certification at close (S138B); `--dogfood-age`
  blind to in-chitra dogfoods (S140, LOW); brownfield threshold hole (S134); NO VAJRA COMMAND STARTS A SESSION.

## What Currently Works
- `vajra init --sync-fleet` is a real UPGRADE path for BOTH the fleet role files AND the shell hooks AND
  the constitution's governed body — one command, one code path, four/five states. The S136 add-only floor
  is lifted for EVERY pure render Vajra owns; only `CONSTRAINTS.yaml` stays add-only, by design.
- The 8 stations riding `vajra next` (+ gates at `--advance`) and the closeout gate
  (`verify-closeout.sh`, incl. design-advisor mandate + attestation + `check_required_crew`).
- The fleet is TEN roles, THREE mandatory (`fidelity-reviewer`, `design-advisor`, `tech-lead`); the
  tech-lead's `required` verdict binds the CLOSE (S139); all four exercised on S143.
- Enforcement floor, tamper-evident ledger (S100), receipts (authoritative on headless stream-json).

## What Is In Progress
- **Nothing mid-flight in Vajra.** S143 complete on `session-143-constitution-upgrade`, ACCEPT + attested +
  merged. **The fresh-user / upgrade-in-place arc is COMPLETE** (roles S141 · hooks S142 · constitution S143).

## Active PRs
- **S143 PR** opened + merged at close (the constitution joins the smooth upgrade). S142 MERGED · S141
  [#170](https://github.com/ifelse-codes/vajra/pull/170) MERGED · S139
  [#168](https://github.com/ifelse-codes/vajra/pull/168) MERGED.

## Direction (governance is the product — shaped as a shippable MVP)
- **Product = provable agent governance** (`DECISION-001`), sold as the autopilot trust layer
  (`DECISION-005`). **Direction, locked S130: MAKE THE FLEET REAL.**
- **Founder's completeness order (S140):** (1) **fresh-user / upgrade-in-place — roles DONE (S141), hooks
  DONE (S142), constitution DONE (S143) → the arc is COMPLETE**, (2) one or two chitra dogfoods (the
  natural next test of the whole upgrade loop), (3) prove the loop works even expensively THEN cut cost
  (after S145), (4) the dogfood-age gauge = low, someday. See `[[vajra-s140-completeness-priorities]]`.
- **Next: A (chitra full-loop dogfood) or B (prove the 5 quiet roles). Next GT: S145.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative. S36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- S53–75: ~$0 each. **S76: real but UNKNOWN** (opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713 · S97: $1.2758 · S102: $0.4644 · S103: $0.6797.**
- **S104–109: ~$0 each. S110/S120: $0 (NO-CODE GT). S118: $4.0911771 · S124: $3.2984944 · S126: $4.4482.**
- **S128–S133: $0 metered** (interactive). **S134: $1.6103385** (chitra dogfood) + ~19.2M raw subagent tokens.
- **S135/S136: $0 metered** — 4.18M / 731,943 RAW subagent tokens. **S137: $0 (honest null)** — 486,695 RAW.
- **S138: $2.988 AUTHORITATIVE** + 237,584 RAW. **S138B: $5.405 AUTHORITATIVE.** **S139/S140/S141/S142: $0 metered.**
- **S143: $0 metered** (interactive) — four tight named-files subagent dispatches (tech-lead, design-advisor,
  qa-specialist, fidelity-reviewer; ~262K subagent tokens total); no `vajra claude` paid run.
- Cumulative: **~$104.2 + S76 (unknown, ≤ ~$26.6) + S111–S143 subagents (unknown, growing).**
