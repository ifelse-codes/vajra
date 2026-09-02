# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**`session-139-crew-at-close` (Vajra) — complete, closing. Next GT: S140.**

S139 shipped the **S138B committed future fix**: a `check_required_crew` gate wired into
`scripts/verify-closeout.sh` so the tech-lead's `required` verdict **binds at CLOSE**, not only at
`vajra next --advance`. **CODE** (shell-gate wiring + fixture + scripts; **0 lines of Rust**). **Cold
`fidelity-reviewer` ACCEPT** — **5 of 5 SHIPPED**, attested `5631e7a1…`.

## What was proven this session
- **The S138 hole is closed for the close path.** S138B proved live that a session could mark FOUR
  roles `required`, run ONE, self-certify, and close **12/12 green + merge to main** — because the crew
  binding (`vajra next --check-crew`) lived ONLY in `--advance`, which a real close never invokes.
  S139's `check_required_crew` runs the real `vajra next --check-crew N` inside `verify-closeout.sh`:
  a missing tech-lead handoff, or a `required` role with no governed handoff, makes the close **exit 1**.
- **Fail-closed, header-guarded, propagated.** Requires the gate's own header
  (`=== crew: tech-lead for session`) so an unknown flag routed to `run_dump` (exit 0) cannot green it;
  a missing binary FAILS (cannot-evaluate ≠ pass, S69); honors the founder-held `VAJRA_CLOSEOUT_WAIVER`;
  no agent-settable `VAJRA_SKIP_*` (the crew decision is provenance-verified). Embedded by `include_str!`,
  so the one edit reaches every `vajra init` adopter (byte-identity test proves it).
- **One correctness fix beyond the mirror:** the bare `out="$(cmd)"; code=$?` capture that all three
  binary-backed close checks used **aborts the whole script under `set -euo pipefail`** on a non-zero
  binary exit — killing the run before its FAIL reason prints. All three (`check_obeyed_judgments`,
  `check_design_advisor_mandate`, `check_required_crew`) now use the set -e-safe `&& code=0 || code=$?`
  list form. This crew gate is the first whose BLOCKING path is exercised in practice, which surfaced it.
- **Bound on S139 ITSELF (the self-bind, acc 3).** The tech-lead dispatched FIRST marked three roles
  `required` (design-advisor · implementation-advisor · fidelity-reviewer) and six `deferred-budget`
  with arithmetic; all three produced real, provenance-verified handoffs; and S139's own
  `verify-closeout.sh` passes `check_required_crew` (`--crew-only 139` → CREW: PASS).
- **Evidence:** `verify-session-139.sh` **7/7** (3 exec · 2 struct · 2 nested) · `fixture-session-139.sh`
  **8/8** (P1–P4 plants + HDR + IGN/POS controls), deterministic across repeated runs · `demo-session-139.sh`
  emits the 4 sprint markers. The cold review named the fixture P2/P3 needle as the fakest green — it
  matched the always-printed crew echo rather than the block cause — and it was **fixed in-session**
  (`3a9852e`, judged by the implementation-advisor).

## What Is Broken / Weak / Disclosed
- **🔴 Reviewer-independence self-certification stays OPEN (the S138B gap, out of scope this session by
  the prompt).** A review FILE with the right shape passes `check_fidelity_review` regardless of WHO
  wrote it — a closing agent can finalize + attest its own review. S139 binds that a fidelity-reviewer
  was *dispatched* (its handoff exists + provenance re-verifies), NOT that the review was authored by an
  independent mind. **Ranked candidate 1 for the next CODE session (S141).**
- **🟡 The "grep the binary's output for a header" house pattern has two named soft edges** (fidelity
  rec 3): (a) if `run_dump` can echo agent-authored file content, the header string could be planted to
  force exit-0-plus-header — shared with the two sibling gates; (b) the fixture's P2/P3 assertion
  originally matched the always-printed crew echo, not the block cause — **fixed in-session** (`3a9852e`).
  A future move to a structured exit-code-plus-fingerprint contract should close both at once.
- **🟡 EVERY JUDGE THIS SESSION HAD NO SHELL** (the standing S133–S139 limit). The implementation-advisor
  and fidelity-reviewer read the scripts; the live figures (`--crew-only`, fixture 8/8, verify 7/7,
  attestation) were run by the builder + the close gates. The implementation-advisor verified the
  `obeyed:` changes at the branch TIP, not each cited sha's isolated diff; the builder confirmed per-sha.
- **🔴 Carried, not touched this session:** `--sync-fleet` cannot tell a stale render from a user edit
  (S136); S135 criterion 7 (carry the recorded budget INTO the dispatch brief, still PARTIAL); the
  brownfield threshold hole (S134); **no `cargo fmt --check` every session** (S96/S136 recurrence — CI
  runs it, so a fmt slip reds main); NO VAJRA COMMAND STARTS A SESSION (the `session-NN` branch is still
  a raw `git checkout -b`).

## What Currently Works
- The 8 stations riding `vajra next` (+ gates at `--advance`) and the closeout gate
  (`verify-closeout.sh`, **now 15 checks** incl. the design-advisor mandate + attestation + **the new
  `check_required_crew`**): the crew binding now runs at every close, not only at `--advance`.
- The fleet is TEN roles, THREE mandatory (`fidelity-reviewer`, `design-advisor`, `tech-lead`) — real
  in chitra (S136), used on a real build there (S138), and **the tech-lead's `required` verdict now
  BINDS the CLOSE** (S139): a role it marks required must produce a governed handoff or the session
  cannot close green.
- Enforcement floor, ledger (S100), receipts (authoritative on headless stream-json): unchanged.

## What Is In Progress
- **Nothing mid-flight in Vajra.** S139 is complete on `session-139-crew-at-close`; PR opens at
  closeout after `.ai/` sync. chitra is untouched this session.

## Active PRs
- **S139 — PR opens at closeout, after `.ai/` sync + the full `verify-closeout.sh` pre-merge run (S83).**
- S136 [#160](https://github.com/ifelse-codes/vajra/pull/160) MERGED · S137
  [#165](https://github.com/ifelse-codes/vajra/pull/165) MERGED · S138
  [#167](https://github.com/ifelse-codes/vajra/pull/167) MERGED.

## Direction (governance is the product — shaped as a shippable MVP)
- **Product = provable agent governance** (`DECISION-001`). **Current direction, locked S130: MAKE THE
  FLEET REAL.** S131–S135 built and made-mandatory the gates; S136 made the fleet real in a project this
  repo does not own; S138 proved the governance WORKS from inside that project on a real build; **S139
  closes the S138B hole — the tech-lead's `required` verdict now binds at the CLOSE, not only at
  `--advance`, so a session cannot close green with a required role skipped.** The last self-certification
  in the close path (reviewer independence) is the named next step.
- **Next-GT: S140.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative. S36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- S53–75: ~$0 each. **S76: real but UNKNOWN** (opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713 · S97: $1.2758 · S102: $0.4644 · S103: $0.6797.**
- **S104–109: ~$0 each. S110/S120: $0 (NO-CODE GT). S118: $4.0911771 · S124: $3.2984944 · S126: $4.4482.**
- **S128–S133: $0 metered** (interactive). **S134: $1.6103385** (chitra dogfood) + ~19.2M raw subagent tokens.
- **S135/S136: $0 metered** (interactive) — 4.18M / 731,943 RAW subagent tokens.
- **S137: $0 authoritative (honest null, interactive)** — 486,695 RAW subagent tokens.
- **S138: `$2.988433749999999` AUTHORITATIVE** (headless `-p` build inside chitra) + **237,584 RAW
  subagent tokens** across 2 dispatches. The first authoritative dollar from a real outside BUILD dogfood.
- **S138B (the end-to-end close run): `$5.4050889999999985` AUTHORITATIVE** (resumed chitra session,
  closed + merged to chitra main). **S138 dogfood total ≈ $8.39** (the close alone breached the $5 cap).
- **S139: $0 metered** (interactive) — **~350K RAW subagent tokens** across 4 roles / 5 dispatches
  (tech-lead ~47K · design-advisor ~94K · implementation-advisor ~52K + ~56K follow-up · fidelity-reviewer
  ~98K), all named-files briefs, well under the S135 affordable envelope.
- Cumulative: **~$104.2 + S76 (unknown, ≤ ~$26.6) + S111–S139 subagents (unknown, growing).**
