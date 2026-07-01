# Session 33 — Compression schema fix (CODE)

## Goal
Fix S31 finding #2 — the compression hook has produced zero savings in every real Claude Code session since S03/S07 because `HookInput` expects camelCase top-level keys, but real CC sends snake_case.

## Goal achieved? ✅ Yes
`HookInput` no longer forces `camelCase` on its top-level fields, so it now correctly parses the real CC envelope (`tool_name/tool_input/tool_response`) instead of silently failing to `"{}"` passthrough.

## Founder decision at BOOT
S32 deferred a build-order fork to this session: ship the pinned compression fix, or promote the 2026-07-01 obedience-metric/pace-notes discovery instead. **Founder chose the pinned fix.** The discovery stays in ROADMAP Backlog, unscheduled.

## What shipped
| File | Change |
|---|---|
| `src/adapter/claude_code.rs` | Removed `#[serde(rename_all = "camelCase")]` from `HookInput` only. `HookToolResponse` keeps it (its nested keys really are camelCase). `exit_code` stays `Option<i32>` unchanged. |
| `tests/hook_adapter.rs` | Rewrote all fixtures from the wrong camelCase-top-level shape to the real snake_case shape. Added `real_cc_payload_folds_not_passthrough` (verbatim real-shaped envelope — reproduced the bug before the fix, confirms the fold after) and `camel_case_top_level_is_not_the_real_shape_and_still_passthroughs` (documents the old shape correctly fails open, not a supported format). |
| `scripts/verify-session-33.sh` | 9 checks — schema attributes, exit_code type, regression tests present, ≤3-file cap, full fmt/clippy/test gate. |

Commits (≤3 files each): `a6ce868` (schema fix) · `c7cf212` (verify) · `1f4787e` (SESSION/BOOT/STATE) · `10cd1a1` (ROADMAP/TASK/KNOWLEDGE).

## Evidence
- Reproduced the bug first: a real-shaped payload (snake_case top level) against the *old* code returned bare `"{}"` — confirmed the root cause empirically, not just from the KNOWLEDGE S31 write-up.
- Applied the fix, reran: the same payload now folds (`hookSpecificOutput.updatedToolOutput.stdout` contains the "lines folded" breadcrumb).
- `scripts/verify-session-33.sh` → **ALL GREEN (9 pass, 0 fail)**.
- `cargo test` → 107 pass (98 lib + 9 adapter, up from 6 adapter tests pre-session), fmt clean, clippy clean (`-D warnings`).

## New finding surfaced, deliberately not fixed
Even with the schema fix, `cargo`/`npm`/`pytest` heuristics (`src/engine/heuristic/{cargo,npm,pytest}.rs`) check `exit_code == Some(0)` **directly**, not the engine's own inferred success — and real CC never sends `exit_code` for Bash. So those three heuristics still fall to their "\_fail" branch (passthrough unless stdout ≥400 lines) on every real invocation, regardless of this fix. Separately, `infer_success`'s tail-matching only recognizes cargo/pytest markers, so any other command with no exit_code defaults to "failure" too. **Net effect:** the schema fix genuinely restores folding for line-count-driven paths (git heuristics, generic head+tail fallback, any output ≥400 lines) — but typical cargo/npm/pytest build/test output still won't fold on real CC. Left undone per 1-story/≤3-file discipline; documented as a carry-forward, not bundled into S34 (which stays brownfield-only).

## Limits / carry-forward
- The `exit_code == Some(0)` heuristic gap above is real and user-visible but out of this session's scope.
- Brownfield onboarding (S31 #3) is next (S34) — the last of the three S31 core breakages.
- Second agent stays parked until S34 closes.

## Next options (pick one)
- **A — Brownfield onboarding (S31 #3, recommended — the pinned queue order).** Guided "session 0: study this existing codebase" kickoff + rethink hook placement so scaffolded hooks don't land inside the project's own `scripts/` package + a `vajra claude` auth pre-check. Risk: largest scope of the three S31 findings; easy to exceed 1 story — needs a tight cut.
- **B — Fix the `exit_code == Some(0)` heuristic gap found this session.** Make `cargo`/`npm`/`pytest` heuristics use the engine's inferred success instead of a raw exit_code equality check, so they actually fold on real CC (not just line-count-driven paths). Risk: touches 3+ heuristic files, may exceed the 3-file cap in one commit; also touches `infer_success`'s narrow tail-matching, which is its own can of worms.
- **C — Promote the second agent launcher now.** Two of three S31 core breakages (Darshan, compression) are fixed; argue the gate is close enough to re-open. Risk: contradicts the explicit "all 3 before reconsidering" carry-forward and the founder's own gate framing (satisfaction, not fix-convenience) — likely premature.
