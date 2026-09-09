# Session 158 — Demo enforcement: make the demo step mandatory in CODE sessions

> **Status:** APPROVED — S157 founder pick (2026-09-09)

## Type
- **CODE** (~1.5h cap)

## Goal

The demo step gets skipped in most coding sessions — no rule enforces it. After building something, we're supposed to show it working. Nobody verifies the thing actually runs end-to-end.

Fix: make `scripts/demo-session-NN.sh` a hard requirement in every CODE session, the same way `scripts/verify-session-NN.sh` already is. The demo script must exist, must run, and must emit the required markers (`header`, `cases`, `summary_table`, `before_after`). The Demo-er gate already re-runs the script at closeout — but only if the script exists. If it does not exist, the gate passes silently. Close that hole.

## Acceptance criteria

| AC | Criterion |
|----|-----------|
| AC1 | `verify-closeout.sh` blocks (FAIL) when `scripts/demo-session-{N}.sh` is absent for a CODE session. |
| AC2 | `verify-closeout.sh` blocks when the demo script exists but the required 4 markers are missing from its output. |
| AC3 | `cargo test` passes — no regressions. |
| AC4 | `cargo build --release` succeeds. |
| AC5 | `verify-closeout.sh` exits 0 (N=158) — demo script for S158 exists and emits all 4 markers. |

## Guardrails

- The fix lives in `scripts/verify-closeout.sh` (the demo-er gate check) and `scripts/demo-session-template.sh` (update the template so future sessions get the markers by default).
- Do not break DOCUMENT or GT sessions — they are exempt from the demo requirement (no source changes = no demo).
- Do not change the Rust source unless absolutely necessary.

## Plan

1. In `scripts/verify-closeout.sh`, tighten the demo-er gate: if `scripts/demo-session-{N}.sh` does not exist AND the session type is CODE, FAIL. covers: 1
2. Add a marker-presence check: run the demo script and verify all 4 markers appear in output. covers: 2
3. Write `scripts/demo-session-158.sh` for this session (shows the S157 fix + S158 enforcement working). covers: 5
4. Run `cargo test` and `cargo build --release`. covers: 3,4

## Delta

S157 fidelity-reviewer flagged demo skipping. Founder confirmed S158 = fix this. The Demo-er gate (`CONSTRAINTS.yaml demo.required_elements`) already defines the 4 markers — the gap is enforcement when the script is absent.
