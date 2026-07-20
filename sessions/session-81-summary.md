# Session 81 — Harden verify-closeout: execution-sha placeholder guard (CODE) — summary

**Type:** CODE — bash-only extension to `scripts/verify-closeout.sh`; retroactive fix to
`prompts/79-task-stale-opus-reprice.md`. Founder pick A at S80 GT close.

## Headline

`verify-closeout.sh` now blocks a CODE session from closing when its `## Execution` section
still contains `step N — done: <sha>` template placeholders. S80's GT caught S79 closing
with 4 unfilled placeholder shas — this check would have caught it. The S79 prompt is now
retroactively fixed. The check respects `VAJRA_CLOSEOUT_WAIVER=N` (GT/NO-CODE sessions
intentionally leave `## Execution` unfilled); warns (never blocks) when the section is absent
(backward-compat with pre-S68 prompts).

## What shipped

- **`scripts/verify-closeout.sh`** — new `check_execution_shas` function: reads the current
  session's prompt (`prompts/NN-task-*.md`), walks the `## Execution` section, fails on any
  line matching `done: <sha>` (the literal angle-bracket placeholder), warns on an absent section,
  and passes when all steps have non-placeholder shas. Wired into the main flow. Also adds
  `--check-exec-shas [N]` focused entry point (mirrors `--fidelity-only` / `--attest-only`).
- **`prompts/79-task-stale-opus-reprice.md`** — retroactive fix: 4 `<sha>` placeholders
  replaced. Step 1 annotated as research-only (no commit); steps 2–4 get real shas (`079d27f`,
  `079d27f`, `e9b6ff3`) from `sessions/session-79-summary.md`.
- **`scripts/verify-session-81.sh`** — 7-check fixture-driven suite; uses `--check-exec-shas`
  with temp fixtures; documents S76 as a true-positive (separate debt).
- **`scripts/demo-session-81.sh`** — all four `demo:<element>` markers; shows all five
  behaviors live.

## Proof

- `bash scripts/verify-session-81.sh` → **7/7 PASS**.
- `cargo test --lib` → **258 passed** (unchanged — no Rust source touched).
- `bash scripts/verify-closeout.sh --check-exec-shas 79` → **PASS** (retroactive fix confirmed).
- All 5 behaviors verified live (fixture, waiver, absent section, real sha, S79 fixed).

## Fidelity map (prompt requirement → delivery)

| # | Requirement | Verdict | Evidence |
|---|-------------|---------|----------|
| 1 | Placeholder `<sha>` in `## Execution` → FAIL (exit 1), clear message | **SHIPPED** | AC-1 in verify-81; fixture test |
| 2 | `VAJRA_CLOSEOUT_WAIVER=N` waives the new check | **SHIPPED** | AC-2 in verify-81; fixture test |
| 3 | Absent `## Execution` → WARN only (backward-compat) | **SHIPPED** | AC-3 in verify-81; fixture test |
| 4 | All real shas / absent section → PASS; zero false positives on corpus | **SHIPPED** | AC-4 in verify-81; corpus scan S68-S80 |
| 5 | S79 prompt retroactive fix; `--stations 79` Coder ABSENT only for step 1 | **SHIPPED** | `--check-exec-shas 79` PASS; step 1 annotated research-only |
| 6 | `cargo test --lib` stays green | **SHIPPED** | 258/258 |

**NOT built:** nothing from the prompt was skipped.

## Honest limits (fakest green)

- **S76 is also broken.** The corpus scan found `prompts/76-task-dogfood-ride-along.md` also
  has 4 unfilled `<sha>` placeholders (true positive — a separate historical oversight; not a
  false positive of the new check). S81's guardrail says "one story: S79 fix only" — S76 is
  not fixed here. It's the next retroactive debt.
- **`--stations 79` Coder step 1 remains `Unrecorded`.** Step 1 was research-only (no commit),
  so the Coder gate classifies it `Unrecorded` after the fix. The new `check_execution_shas`
  does NOT flag this (no `<sha>` literal present) — but `vajra next --advance 79` would still
  block on step 1 if re-invoked. This is correct behavior (the Coder gate enforces existence;
  the new check enforces non-placeholder), not a regression.

## Attestation

- **Review-Inputs-SHA:** `6823cdef1a2362d471d88002354a7f46e5bc98043fb5fcec0f3f66ee3b3d61ec`
  (`sha256(prompt ‖ delivery-diff)`; delivery diff = S81 commits `22232f7` + `84dc73e`).
  See `sessions/session-81-review.md` for the independent cold verdict.

## Coder-gate execution (plan step → landing commit)

- step 1 (add `check_execution_shas` + focused entry + main-flow wire) → `22232f7`
- step 2 (retroactive S79 fix) → `22232f7`
- step 3 (verify-session-81.sh + demo-session-81.sh) → `84dc73e`

## 3 ranked S82 candidates

- **🥇 A — S76 retroactive sha fix** (parallel to S79 fix; S81 found it as a true positive):
  fill the 4 `<sha>` placeholders in `prompts/76-task-dogfood-ride-along.md` with real S76
  shas; verify `--check-exec-shas 76` passes. Key risk: short — might bundle with another debt.
- **🥈 B — `--stations` Releaser durability** (S75 finding, confirmed S80; 2nd GT confirmation):
  Releaser dimension decays once branch refs are pruned; fix = read SHIP from the attested
  ledger, not pruned refs. Key risk: touches Rust + the ledger chain (not bash-only).
- **🥉 C — Read-only-headless UX + typed `CannotEvaluate::{Timeout,SpawnFailure}`** (carried 4
  sessions; S82 candidate C): `vajra claude -p` silently read-only; QA timeout/spawn collapse
  into one untyped `None`. Key risk: two sub-stories; may need splitting.
