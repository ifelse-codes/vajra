# Session 93 — Prove the commit gate has teeth

> **Status:** APPROVED (founder pick A, S92 close).

## Goal

Turn the **no-autonomous-commit** rule from *voluntary* (constitution-followed) into *enforced*
(fail-closed). Today `commit.autonomous: false` + `require_user_approval: true` are honored only
because the agent chooses to — the S92 dogfood proved this: under `--dangerously-skip-permissions`
the headless agent self-stopped at the commit gate (`permission_denials: []`), but **no hook
actually checks for an approval token**. The L2 `.githooks/pre-commit` blocks only `main` commits,
`>3` files, and `.ai/` drift — an autonomous commit on a clean session branch would pass. Close
that gap: make an unapproved commit attempt **BLOCK**, with approval evidence the agent cannot
self-grant.

This is a **CODE** session. Deliverable is the enforced gate + a test that proves it, not prose.

## The gap (from S92 dogfood, recurring since S76)

- Obedience at the commit boundary is **voluntary** — the same finding across S76 and S92 runs.
- The un-forgeable-env pattern already exists in this repo: `VAJRA_CLOSEOUT_WAIVER` (S56) gates
  closeout with a marker the agent cannot mint for itself. Reuse that house pattern here.

## Acceptance Criteria

1. An autonomous commit attempt on a **session branch** with **no approval evidence** is BLOCKED
   (non-zero exit) by a tracked hook, fail-closed. `covers: 1`
2. The approval evidence is **un-forgeable by the agent** — a human-supplied env marker (mirroring
   `VAJRA_CLOSEOUT_WAIVER`, S56), not a file/flag the agent can write itself. A commit WITH the
   marker present passes. `covers: 2`
3. Automated test(s) cover BOTH paths (blocked-without / allowed-with) and are wired into
   `scripts/verify-session-93.sh` (exit 0). Existing `cargo test --lib` stays green. `covers: 3`
4. The `--no-verify` (git-hook skip) residual is documented honestly; mitigated as far as feasible
   (e.g. an L3 CC `PreToolUse` guard on `git commit` so a bypass must skip BOTH layers), or the
   residual is disclosed with its exact bypass. `covers: 4`
5. `vajra init` scaffold carries the new gate so new projects inherit teeth (or the omission is a
   deliberate, disclosed choice). `covers: 5`
6. `sessions/session-93-summary.md` maps every AC to SHIPPED/PARTIAL/NOT-BUILT + names the fakest
   green; reviewed by an independent cold pass (subagent, prompt+diff only). `covers: all`

## Design

design-significant: **yes** — introduces a new enforcement boundary. Cite
`docs/decisions/DECISION-001-governance-as-product.md` (provable governance is the product) and the
`VAJRA_CLOSEOUT_WAIVER` un-forgeable-env precedent (S56). No new ADR required; this instantiates
the existing governance-as-product decision at the commit boundary. If the design departs from the
waiver pattern, record why in the summary.

## Plan

1. Reproduce the gap: show a commit succeeding on a session branch with no approval today. `covers: 1`
2. Add the approval-evidence check to `.githooks/pre-commit` (L2), fail-closed, keyed on an
   un-forgeable human env marker (waiver pattern). Keep the existing main/>3/drift checks. `covers: 1, 2`
3. Add tests for both paths + wire `scripts/verify-session-93.sh`; confirm `cargo test --lib`
   green. `covers: 3`
4. Address the `--no-verify` bypass: add/adjust an L3 guard or disclose the residual precisely. `covers: 4`
5. Propagate to the `vajra init` scaffold. `covers: 5`
6. Write summary + fidelity map; run the independent cold review. `covers: 6`

## Guardrails

- Max 2 assumptions · max 2 retries · max 1 story · max 3 files per atomic commit · ~2h cap.
- Branch: `session-93-prove-commit-gate-teeth`. **New chat.**
- Do NOT weaken any existing gate. The new check must never block a legitimate approved commit.
- The marker must be **un-forgeable by the agent** — if the agent can set it, the gate is theater
  (the S69 "jurisdiction-self-granted" fakest-green class). Design against that explicitly.
- Full closeout: `scripts/verify-closeout.sh` exits 0 before close.

## Delta (Analyst gate)

- `~` `.githooks/pre-commit` — add fail-closed approval-evidence check
- `+` `scripts/verify-session-93.sh` + `scripts/demo-session-93.sh` — prove block/allow paths
- `~` `src/cli/init.rs` (or scaffold templates) — propagate the gate to `vajra init`
- `+` tests covering blocked-without / allowed-with approval
