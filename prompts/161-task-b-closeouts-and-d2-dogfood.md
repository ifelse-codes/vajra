# Session 161 — Close S158 carry-forwards + D2 first-contact dogfood

> **Status:** APPROVED — founder pick (2026-09-10, S160 GT closeout)

## Type
- **CODE + DOGFOOD** (~2h cap; paid run ~$5–12)

## Goal

Two things, in order:

**Part 1 — B items (mandatory, ~30–60 min, $0):** Four items from S158 have been deferred twice without a named session, violating the S152 carry-forward rule. They must close here.

1. Write a DECISION record (`docs/decisions/DECISION-008-session-type-detection.md`) for the `is_code_session()` contract and the demo marker enforcement pattern (S158-DA-r4).
2. Add a blocking-path fixture to `scripts/demo-session-158.sh` — a synthetic CODE session with no demo script, proving the gate blocks it (S158-FR-r1).
3. Replace the source-proximity grep in `scripts/verify-session-158.sh` with a behavioral integration test that calls `check_demo_markers` on a marker-free synthetic session (S158-FR-r2).
4. Fix the C5 circular check: `check_required_crew` currently greps AGENTS.md for the `Brief:` requirement note; it must instead grep a real handoff file for a `Brief:` line (S153-FR carry-forward, missed at S155).

**Part 2 — D2 dogfood (founder priority 2, $5–12):** Run `vajra init` on a brand-new empty directory (not chitra, not vajra — a genuinely new repo). Then run a full `vajra claude -p` session inside it, governed by its own scaffold's fleet, through to a complete close — with at least the 3 mandatory roles (tech-lead, design-advisor, fidelity-reviewer) producing real handoffs and `verify-closeout.sh` exiting 0. Record the authoritative cost from the `-p` result stream.

This is the test the pre-ship audit (Sept 9) named as the one thing that must happen before Sept 15.

## Acceptance criteria

| AC | Criterion |
|----|-----------|
| AC1 | `docs/decisions/DECISION-008-session-type-detection.md` exists, cites DECISION-002 as motivation, describes the `is_code_session()` affirmative-match contract and the demo marker enforcement pattern |
| AC2 | `scripts/demo-session-158.sh` includes a case that exercises the blocking path — a synthetic CODE session with a missing demo script — and confirms it blocks (exit non-zero or explicit BLOCK output) |
| AC3 | `scripts/verify-session-158.sh` behavioral check calls `check_demo_markers` (or equivalent) on a marker-free synthetic session and asserts it fails, rather than grepping source proximity |
| AC4 | `scripts/verify-closeout.sh` `check_required_crew` greps for a `Brief:` line in a real handoff file path, not in AGENTS.md |
| AC5 | D2 dogfood run completes: a fresh empty repo is `vajra init`'d, a `vajra claude -p` session runs inside it, `verify-closeout.sh` exits 0 inside the new repo, and the authoritative cost (`total_cost_usd` from the `-p` result stream) is recorded in this session's summary |
| AC6 | At least 3 mandatory fleet roles (tech-lead, design-advisor, fidelity-reviewer) produced governed handoffs inside the D2 repo's session |
| AC7 | `scripts/verify-session-161.sh` exits 0 — at minimum: DECISION-008 file exists; AC4 grep change present in verify-closeout.sh; D2 cost field present in session summary |

## Guardrails

- **Part 1 is not optional.** Do not skip to the dogfood run without completing AC1–AC4. These are S152 violations that cannot slip again.
- **D2 repo must be genuinely new** — not chitra, not vajra, not a clone of either. A temporary directory with a real but trivial codebase (e.g. a one-file Rust or Python project) is fine.
- **Do not disturb the D2 repo's `.ai/` after `vajra init`** — the scaffold is what a stranger gets; no manual edits to give it an advantage.
- **Cost cap:** $5 hard cap per run; if the D2 run exhausts the cap before closing, stop, record what happened, and document the partial result. Do not run a second paid attempt without founder approval.
- **Authoritative cost only.** Record `total_cost_usd` from the `-p` result stream. If the stream carries no cost, record `null` and explain why — do not estimate.
- **Part 2 evidence is recorded here (vajra repo) only.** Do not commit any code changes into the D2 repo from this session.
- Max 3 files per atomic commit in this (vajra) repo.

## Plan

1. Write `docs/decisions/DECISION-008-session-type-detection.md`. covers: 1
2. Add blocking-path case to `scripts/demo-session-158.sh`. covers: 2
3. Replace source-proximity grep in `scripts/verify-session-158.sh` with behavioral integration test. covers: 3
4. Fix C5 in `scripts/verify-closeout.sh`: `check_required_crew` greps real handoff file for `Brief:`. covers: 4
5. Run D2 dogfood: `mkdir /tmp/d2-test && cd /tmp/d2-test && vajra init && vajra claude -p "<task>"`. Record authoritative cost + handoff evidence. covers: 5, 6
6. Write `scripts/verify-session-161.sh`. covers: 7

## Design

design-significant: yes — DECISION-008 is a new decision record establishing the `is_code_session()` contract as a permanent interface; any future session-type gate must cite it.

Closest existing record: DECISION-002 (fidelity-over-discipline motivation). DECISION-008 is a peer, not a refinement — it governs the enforcement surface (when a gate fires and why), where DECISION-002 governs the measurement surface (what counts as delivered).

## Crew

tech-lead to dispatch first (mandatory). design-advisor required (design-significant: yes — new DECISION record). fidelity-reviewer required (two deliverables: code changes + dogfood evidence). qa-specialist optional but recommended for AC3 (behavioral test verification).

## Execution

_Fill in as steps land:_

step 1 — done: 375edcf
step 2 — done: ec301d0
step 3 — done: ec301d0
step 4 — done: 08bbb04
step 5 — done: 6e98553
step 6 — done: fadbaa0

## Delta

S158 closed demo enforcement but left 3 recs deferred without named sessions (S152 violation). S153's C5 circular-check carry-forward was missed at S155 GT. This session closes all four B items — not as cleanup but as the mandatory precondition before the D2 run. D2 itself is founder priority 2 since S140, outstanding for 21 sessions. The pre-ship audit (2026-09-09, 14 findings) names the first-contact test as the one that must run before Sept 15. This session is that test.
