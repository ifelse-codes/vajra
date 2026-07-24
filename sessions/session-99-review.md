# Session 99 — Independent Cold Fidelity Review

**Mode:** two-pass (DECISION-002). A separate Opus subagent was fed ONLY the contract
(`prompts/99-task-coder-reachable.md`) + the delivery diff (`git diff main...HEAD -- src/ scripts/`),
adversarially framed, with no expected score and no access to the summary/STATE/history.

## Pass 1 — REJECT (four real defects; all fixed in-session)

The first cold pass rejected. The findings were real, not sequencing noise:

| # | Finding | Fix (commit) |
|---|---|---|
| 1 (fakest green) | `kickoff_prompt_carries_goal_and_markers` was a **tautology** — asserted `render_scaffold()` against a string built from it | Ratchet now ties the kickoff to `## ` heading lines authored in `analyst::PROMPT_TEMPLATE` (cross-module) + a line-anchored source check that no second `const TPL_PROMPT` returns (`b76ff58`) |
| 2 | verify's Rust/bash "drift" check was a **no-op** (compared two booleans already asserted equal) | Extracts the category word from each surface and compares per env case (`a385e1e`) |
| 3 | "mirrors the guard" asserted in 3 places, **verified in 0** | verify + demo now DRIVE `hook-commit-guard.sh` (enforcement forced) under all three envs and assert its real allow(0)/block(2) matches the packet word (`a385e1e`) |
| 4 | AC5 "agent-forgeable" lived only in a **doc comment** | Stated on-surface in the demo disclosure (`a385e1e`) |

## Pass 2 — ACCEPT (fresh subagent, re-fed the corrected diff)

Verdict per requirement (verbatim shape from the auditor):

| # | Requirement | Ruling | Evidence |
|---|---|---|---|
| D1 | init kickoff from canonical template, no second copy | SHIPPED | `f("prompts/01-task-kickoff.md", &kickoff_prompt(goal, slug))`; old `const TPL_PROMPT` deleted |
| D2 | LEGACY outcome | SHIPPED | `Outcome::Legacy`; `StationStatus::legacy()`; `is_legacy_prompt()`; wired into all four station fns |
| D3 | packet surfaces commit pre-auth | SHIPPED | `CommitAuth` + `commit_authorization()` + `render_commit_auth()`, printed in `run_dump()` |
| D4 | verify + demo scripts | SHIPPED | both `new file mode 100755` |
| D5 | summary + 3 candidates | PENDING (closeout, excluded by design) | — |
| A1 | kickoff markers + anti-second-copy test | SHIPPED | `scaffolded_kickoff_file_is_station_measurable` + `kickoff_is_the_one_canonical_template_no_second_copy` |
| A2 | LEGACY ≠ ABSENT, cause+remedy | SHIPPED | `legacy()` note + `legacy_convention_prompt_is_unmeasurable_not_absent` (`passed()==0`) + over-fire guards |
| A3 | pre-granted vs token-required | SHIPPED | `PreGranted`/`TokenRequired`/`Mismatch` render lines |
| A4 | verify exits 0 (A1–A3) + demo before/after | SHIPPED | `[AC1]/[AC2]/[AC3]` blocks + `demo:before_after` |
| A5 | advisory + agent-forgeable + no retro-fit, stated | SHIPPED | on-surface demo disclosure + "retro-fitted → NONE" |
| G1–G6 | guardrails / scope | SHIPPED | no new subcommand/store/README/Coder redesign |

**The fakest green (pass 2):** `commit_authorization_mirrors_the_guard` — a unit test whose name
asserts guard parity while only checking the Rust classifier against hardcoded expectations. **Disclosed,
not hidden**: the test's own doc points to the live guard execution in `verify-session-99.sh`, which runs
`hook-commit-guard.sh` and asserts its `0/2/2` exits match the packet. Flagged AND backstopped.

**What was NOT built:** nothing in Deliverables/Acceptance. Only `sessions/session-99-summary.md` (D5)
is pending — the contract's own closeout-deferred item.

**Verdict:** ACCEPT

**Review-Inputs-SHA:** 6dbcf20a0b92ec806e7175fafbd15b6c33090e06343f6d693bcf12d8ba44da15
