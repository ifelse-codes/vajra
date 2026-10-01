# Session 182 — Cold fidelity review

Brief: `prompts/182-task-finish-s181-gaps.md`. Two passes by independent `fidelity-reviewer` dispatches, each fed the prompt, the diff from `e5db703`, the verify output and the summary's rudra block.

## Pass 1 — ACCEPT, with one `mismatch:` (13 SHIPPED · 2 PARTIAL · 0 NOT-BUILT)

| # | Verdict | Reviewer's evidence (condensed) |
|---|---|---|
| D1 | SHIPPED | `whole_suite_check` fails on non-zero exit, no `test result: ok`, cargo's own FAILED lines |
| D2 | SHIPPED | `tests/stamp_gate.rs` — real commit, captured judge, edit → `--check-obeyed` blocks |
| D3 | SHIPPED | `SYNC_HOOKS`, own PreToolUse group, `include_str!` one source, `Cargo.toml` un-excluded (caveats: recs 2, 3) |
| D4 | SHIPPED | N = `.ai/SESSION` + 1; no write path to `.ai/CONSTRAINTS.yaml` |
| D5 | SHIPPED | `approved()` is the only reader of the allow-all record; binding holds everywhere |
| D6 | PARTIAL | the fd-dup strip had no right boundary: `echo x >&1/../.ai/approvals/s.json` passed; the S181 line blocked it — breaks "only add" |
| D7 | SHIPPED | checked first-hand: rudra settings register the guard once, `session_rules_from: 16`, reflog shows no HEAD move |
| AC1–AC5, AC7, AC8 | SHIPPED | as in the table of the reviewer's report |
| AC6 | PARTIAL | closeout exit 0 cannot be shown until the review is attested |

**Fakest green (pass 1):** the "only add" superset claim — stated in the guard header and DECISION-011 §2, checked by nothing (verify P6 ran one read through the old hook, no writes). Runner-up: the "old project" fixture was today's scaffold minus one group, so "merged == fresh" was near-tautological.

**Obeyed judgments (pass 1):** 18 `implemented`, 1 `mismatch` — design-advisor rec 8 at `3a2a02e`: the fixture never exercised a partly wired group; a pre-S93 project would have three hooks listed twice.

**Recommendations (pass 1) and what was done:**
- rec 1 — anchor the fd-dup strip; add the spelling; run every write spelling through the `e5db703` hook and the new one. **Done, 4449ebb:** anchored on the right; `every_command_the_s181_guard_blocked_still_blocks` fails on the pre-fix guard (shown) and passes now.
- rec 2 — never list a hook twice for a partly wired group; rebuild the old-project fixture from a real older shape. **Done, 2967453:** only the missing entries are appended to the same-matcher group; `sync_fleet_never_lists_a_hook_twice_in_a_pre_s93_project` fails without the fix (shown) and passes now.
- rec 3 — L1 jq fallback. **Done, 4449ebb:** `no_jq_advises_at_l1_and_blocks_at_l2`.
- rec 4 — case-insensitive + quotes, or disclose. **Done, 4449ebb:** both checks lower-case; the "names it?" test reads a de-quoted copy; globs disclosed in DECISION-011.
- rec 5 — keep key order. **Done, 293796b** (founder yes to the dependency feature): rudra's settings diff is now 9 added lines, not a re-sorted file.

Code changed after an ACCEPT → a fresh pass 2 (F81).
