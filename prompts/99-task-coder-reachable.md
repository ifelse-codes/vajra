# Session 99 — Coder reachable unattended (the S97 blocker Rung 2 will hit)

> **Status:** APPROVED — founder said "start session 99 ... all approved" (chat, 2026-07-24),
> against the S98 summary's ranked candidates where **A** was the recommended pick.
> **Sequencing note:** `.ai/ROADMAP.md` line ~206 still lists S99 as "DOGFOOD — Rung 2". That row
> is stale relative to the S98 summary's recommendation (Rung 2 hits the Coder-dark wall without
> this fix). This session takes **A**; the ROADMAP row is corrected at closeout — **Rung 2 becomes
> S101** (S100 is the fixed mandatory NO-CODE ground truth).

## Type
- **CODE.** Max 2 assumptions · 2 retries · ~2h · 1 story · new chat · approval token before commit.

## Goal

Make the Coder station **reachable by an unattended run**. S97 (Ladder Rung 1) proved it is doubly
blocked: (a) the subject repo's prompt convention has no station-marker slots, so four prompt-driven
stations report `[ABSENT]` and the counter cannot tell *convention-absent* from *work-absent*; and
(b) a headless `-p` run has no channel to utter a commit-approval token, so zero commits exist to
record. This session fixes exactly those two things — nothing else. It is the sanctioned
"fix what a ladder run broke" under the machinery-freeze rule (`DECISION-005`), and it is the
enabler for Rung 2.

**Scope fence:** no Coder-station redesign, no new command, no new artifact/store, no README work.

## Deliverables
- `src/cli/init.rs` — the scaffolded session-01 prompt carries the modern marker slots, sourced
  from the single canonical `analyst::PROMPT_TEMPLATE` (no second copy, no drift).
- `src/stations/mod.rs` — a distinct **LEGACY** outcome so the counter stops conflating a
  pre-marker-convention prompt with work not done.
- `src/cli/next.rs` — the handoff packet surfaces the **commit pre-authorization** state, so a
  headless agent can learn that `VAJRA_ALLOW_COMMIT=NN` *is* the founder's approval token.
- `scripts/verify-session-99.sh` (exits 0) · `scripts/demo-session-99.sh`
- `sessions/session-99-summary.md` + exactly 3 ranked next candidates.

## Acceptance (testable, EARS-style)
1. WHEN `vajra init` scaffolds a fresh repo THEN `prompts/01-task-kickoff.md` carries the modern
   station-marker sections (`## Acceptance`, `## Design`, `## Plan`, `## Execution`, `## Delta`),
   derived from `analyst::PROMPT_TEMPLATE` — asserted by a test that fails if a second copy of the
   template text is introduced.
2. WHEN `vajra next --stations NN` reads a prompt that EXISTS but carries none of the marker
   sections THEN the four prompt-driven stations report a distinct **LEGACY** outcome naming the
   cause and the remedy (`vajra next --advance` scaffolds the modern prompt) — never the same
   `[ABSENT]` reserved for work-absent.
3. WHEN the environment carries `VAJRA_ALLOW_COMMIT=<current session>` THEN `vajra next` states in
   the handoff packet that commit approval is pre-granted for that session; WHEN it does not, the
   packet states commits still require a conversational approval token.
4. `scripts/verify-session-99.sh` exits 0 (covering 1–3) and `scripts/demo-session-99.sh` shows the
   before/after for a legacy-convention prompt.
5. The honest verdict this session must state plainly: the `vajra next` pre-auth line is
   **advisory and agent-forgeable** — the un-forgeable teeth remain the L3 `hook-commit-guard.sh`
   reading its OWN launch env; and step 1 does **not** retro-fit prompts already on disk in older
   repos (re-running `vajra init` restores missing guards; `--advance` supplies modern prompts
   going forward).

## Design (the Architect gate)
- design-significant: **yes** — a new public `Outcome` variant on the station report changes an
  interface other stations and the formatter read.
- Rests on `DECISION-001` (governed pipeline) and `DECISION-005` (autopilot trust; machinery-freeze).
  Shape chosen over the alternative of a new `vajra upgrade` command: Vajra's own mechanisms already
  cover the upgrade path — `vajra init` is skip-if-present/idempotent (it restores missing guards)
  and `vajra next --advance` already scaffolds the canonical modern prompt. Adding a command would
  violate the no-8th-command rule and the "map the concept to Vajra's own mechanism first" rule.
  The counter fix follows the house pattern of *measuring honestly rather than forcing green*: a
  legacy prompt is not a failure to work, and must not read as one.

## Plan (ordered steps — `covers:` the acceptance criteria)
1. Scaffold parity — `vajra init`'s session-01 prompt is generated from `analyst::PROMPT_TEMPLATE`
   (NN=01, slug from the goal), with a test asserting the marker sections are present and that the
   template has exactly one source. covers: 1
2. Honest measurement — add the `Legacy` outcome + classification (prompt present, zero marker
   sections) to `src/stations/mod.rs`, wire the formatter, and keep `passed()` semantics unchanged.
   covers: 2
3. Headless approval channel — surface commit pre-authorization in the `vajra next` handoff packet
   (pre-granted vs. token-required), then write `scripts/verify-session-99.sh` +
   `scripts/demo-session-99.sh` covering steps 1–3. covers: 3, 4, 5

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>

## Guardrails
- ONE story: *make the Coder reachable unattended*. No station redesign, no README, no new command.
- Own the `.ai/` spine — no second store, no 8th command, no new artifact by reflex.
- Darshan every human reply · Varta against the live `.ai/`.
- Max 3 files per atomic commit. Commits need `VAJRA_ALLOW_COMMIT=99` (S93 enforced).
- The independent cold fidelity review (DECISION-002) is fed only this prompt + the diff.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` a distinct LEGACY station outcome (convention-absent ≠ work-absent) and a commit
  pre-authorization line in the handoff packet.
- `~` `vajra init`'s session-01 prompt now carries the modern station-marker slots, from the one
  canonical template.
- `-` retires the implicit claim that `[ABSENT]` means "the work was not done".
