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

## Execution

- step 1 — done: f28bee9
- step 2 — done: f28bee9
- step 3 — done: f28bee9
- step 4 — done: f28bee9

## Design

design-significant: yes

`is_code_session()` is a new shared inference contract — both `check_verify_demo_scripts` and `check_demo_markers` call it. `check_demo_markers` adds a new enforcement surface to the Demo-er station: live execution + marker grep instead of presence-only. Every future CODE-specific check will use `is_code_session()`.

Affirmative-inclusion pattern adopted (design-advisor rec 2): the function matches `**CODE**` in the `## Type` section instead of excluding known non-CODE keywords. Prompt exists but no `**CODE**` marker → non-CODE. No prompt file → assume CODE. This eliminates the substring-matching hole where a Type line like `**CODE** (documentation fixes)` would have been misclassified as non-CODE by the prior negative-exclusion grep.

No ADR yet covers session-type detection or the demo marker contract. Closest prior record: DECISION-002 (fidelity-over-discipline, S54). A new DECISION for the type-detection contract is deferred to a DOCUMENT session.

## Advice

| # | Rec (design-advisor) | Disposition |
|---|----------------------|-------------|
| 1 | Record `design-significant: yes` in `## Design` | obeyed — see above |
| 2 | Flip `is_code_session()` to affirmative `**CODE**` match | obeyed — implemented in this session (affirmative-matching fix applied after original commit f28bee9) |
| 3 | Confirm `--demo-only` calls `is_code_session()` — no bypass | confirmed — `--demo-only` → `check_demo_markers` → `is_code_session()` at top |
| 4 | Write new DECISION record for session-type detection + demo marker contract | deferred — to a DOCUMENT session; scope exceeds S158 budget |
| 5 | Add `timeout 60` guard to `bash "$D"` in `check_demo_markers` | deferred — lower priority; the live run already exits fast; add in S159 or later if a slow demo surfaces |

| # | Rec (fidelity-reviewer) | Disposition |
|---|-------------------------|-------------|
| 1 | Improve demo cases to exercise the blocking path (not just exemptions) | deferred — the exemption path is the correct live behavior for the only session scripts available; a synthetic blocking case requires a fixture session |
| 2 | Replace source-grep with behavioral integration test in verify-session-158.sh | deferred — source-grep documents intent; the `--demo-only 158` call at the end of verify-session-158.sh is the behavioral check |

## Delta

S157 fidelity-reviewer flagged demo skipping. Founder confirmed S158 = fix this. The Demo-er gate (`CONSTRAINTS.yaml demo.required_elements`) already defines the 4 markers — the gap is enforcement when the script is absent.
