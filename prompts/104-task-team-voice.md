# Session 104 — Make the pipeline speak like a team (roles, not gates)

> **Status:** APPROVED (direction) — founder picked **C** from the S103 closeout options
> (chat, 2026-07-27), ordering **C now → B (release/installable) next → A (real agent fleet) later,
> after the MVP ships**. This is the cheap bridge toward the fleet vision: reface the 8 internal
> stations as a human-natural **team**, keep the mechanism identical.

## Type
- **CODE (presentation/UX; small).** No new command, no new store, no change to gate logic. One story:
  *the product talks like a team instead of "station K-of-8."* Max 2 assumptions · 2 retries · ~2h ·
  new chat · `VAJRA_ALLOW_COMMIT=104` for commits · full VERIFY + DEMO scripts (this IS a CODE session).

## Why this session
The founder's own critique (S103): "gates named like *station 5 of 8* look OK for an MVP, not for a
real product." FirstMate's demo *feels* alive because you watch named agents (researcher/coder/QA) do
work. We already have those roles as gates — they just **narrate like plumbing.** This session gives
them a human voice so the product feels like a team, **without** building the real fleet yet (that is
Option A, later). The gates stay exactly as they are underneath — the invisible trust-engine.

## The change (plain)
Today `vajra next --stations NN` prints a bare `K-of-8`. After this session it reads like a **team
roster**: each of the 8 stations shown as a **named role** with a **plain-language status line** —
e.g. *"Analyst ✓ framed the goal · Architect ✓ recorded the design · Coder ⧗ 0 commits yet · QA —
not run."* Same for the boot packet's station line. **The K-of-8 may remain as a small subtitle.**

## Pass condition (ALL — falsifiable)
- **Reface only:** the 8 stations' internal pass/fail logic + existing tests are UNCHANGED (this is
  presentation, not a mechanism change) — the same K is computed; only how it is *shown* changes.
- **One source of truth:** the role names + status phrasing live in ONE place and are reused by both
  `vajra next --stations NN` and the boot packet — no second copy (honors the S19 no-drift rule).
- **Reads like a team:** `vajra next --stations NN` output names each role and states in plain English
  what it did / has not done — not a bare number.

## Deliverables
- `src/` change: a role-narration layer over the existing station results (naming + per-role plain
  status), wired into `vajra next --stations` and the boot packet.
- `scripts/verify-session-104.sh` (asserts: roster names present · plain status per role · K unchanged
  vs the pre-refactor value · single-source reuse) + `scripts/demo-session-104.sh` (shows the before →
  after: bare `K-of-8` vs the team roster).
- `sessions/session-104-summary.md` (fidelity map: every requirement → SHIPPED/PARTIAL/NOT-BUILT) +
  independent cold review (ACCEPT, attested) + 3 ranked next options (expect **B — make it installable**
  as the lead, per the founder's C→B→A order).

## Acceptance (testable)
1. `vajra next --stations NN` prints the 8 stations as **named roles with plain-language status**, not
   a bare `K-of-8` (K may remain as a subtitle).
2. The role names + phrasing are defined **once** and reused by `--stations` and the boot packet.
3. The station **gate logic is untouched**: `cargo test --lib` green, the computed K for a given session
   equals the pre-refactor K (a test pins this).
4. `scripts/verify-session-104.sh` exits 0; `scripts/demo-session-104.sh` shows before→after.

## Design (the Architect gate)
- design-significant: **no** — presentation/naming only, no new decision record. Rests on `.ai/ROADMAP.md`
  (the S103 pivot banner + the fleet-vs-gates fork) and the founder's C→B→A ordering. If a clean role
  vocabulary turns out to warrant a recorded decision, add a short `docs/decisions/` note and cite it.

## Plan (ordered — `covers:` the acceptance criteria)
1. Add a single role-narration map (station → role name + plain status phrasing) in one module. covers: 2
2. Render `vajra next --stations NN` as the team roster from that map; keep K as a subtitle. covers: 1
3. Reuse the same map in the boot packet's station line. covers: 2
4. Pin gate logic: a test asserts K is unchanged for a fixture session; run full suite. covers: 3
5. verify + demo scripts (before→after); summary + cold review. covers: 4

## Execution (the Coder gate — fill each step's landing commit sha as work lands)
- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
- step 4 — done: <sha>
- step 5 — done: <sha>

## Guardrails
- ONE story: *reface the stations as a team voice.* Do NOT change any gate's pass/fail logic, do NOT add
  a command or a store, do NOT build real parallel agents (that is Option A, later).
- Own the `.ai/` spine · Darshan every human reply · plainest English (founder S103) · Varta vs live `.ai/`.
- Fidelity review (`DECISION-002`) is independent + not self-certified.

## Delta (vs ROADMAP — OpenSpec markers)
- `~` the 8-station pipeline gains a human-facing **team voice** (roles + plain status); mechanism unchanged.
- `+` `scripts/verify-session-104.sh` + `scripts/demo-session-104.sh`.
- `-` retires the "station K-of-8 reads like plumbing" UX wart (founder S103 critique).
