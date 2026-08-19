# Session 122 — Independent Fidelity Review (cold `fidelity-reviewer`, pass 4)

> **Dispatched by name** (`subagent_type: "fidelity-reviewer"`), fed only two things: the session
> prompt `prompts/122-task-qa-suite-real-holes.md` and the full branch diff
> `sessions/session-122-artifacts/review-input.diff`. Not self-certified. Read-only tools.
>
> **Four passes were needed.** Pass 1 **REJECT** · pass 2 **ACCEPT with findings** · pass 3
> **REJECT** · pass 4 **ACCEPT**. Every rejection was correct and every finding was closed in
> session before the next pass. The passes are recorded, not hidden — the reshaping is the honest
> shape of this session. Earlier pass briefs are summarised in `sessions/session-122-summary.md`.

## Per-requirement verdict

| # | Acceptance criterion | Verdict | Evidence |
|---|---|---|---|
| 1 | Read-only guard rejects a `Write`/`Edit` leak on a non-allowlisted role, proven by a fixture that turns it RED | SHIPPED | `read_only_outside_allowlist()` tokenises `tools:` on commas and compares WHOLE tokens against `FORBIDDEN_TOOLS`; the old prefix grep is deleted from `_scaffolds_four_roles`, which now calls the real function against what `vajra init` actually rendered. `read_only_guard_has_teeth` plants `tools: Read, Grep, Glob, Write`, **shows the old grep going green on it**, requires the new guard RED, and requires GREEN on a clean fleet. `fix1_independent` re-derives it with a second parser against the real binary. Real implementation, planted defect, both directions. |
| 2 | `one_source_of_role_text` cannot be tripped by a governed handoff quoting its own probe sentence; failure message names the carriers | SHIPPED | `role_text_carriers()` excludes `.ai/handoffs/`; the FAIL branch prints each offending path. `one_source_guard_has_teeth` drives the **real** `_one_source_of_role_text` through three states (canonical GREEN → handoff GREEN, with the S121 list shown tripping → genuine second carrier RED, message asserted to name it). Verified independently: the trap is genuinely armed. Credit for narrowing rather than widening the exclusion. |
| 3 | No test asserts a render against the same field it renders from; content is asserted, not wiring | SHIPPED | All three content-field tautologies gone from `src/fleet/mod.rs` (`r.system_prompt`, `role.system_prompt`/`role.description`, and `format!("tools: {}", role.tools)` → a literal `EXPECTED_GRANTS` table with a `len() == ROLES.len()` guard). Replaced by `role_prompt_substance()` shared by the real test **and** the fixture — not retyped — plus per-role literal phrases and a cross-wiring negative. The guard's field list is derived from `pub struct Role`. |
| 4 | Printed check-class tally no longer implies a complete count while hiding a nested suite's checks | SHIPPED | Fourth class `nested` in both suites; `fleet-smoke`, `s113-counter-still-green`, `s121-suite-green` reclassified; `print_tally()` names each nested suite from the derived array and prints "NOT a census" / "is a FLOOR". `tally_disclosure_has_teeth` keeps the S121 one-liner verbatim as a negative control that must be REJECTED, and requires no disclosure when nothing was nested. |
| 5 | `verify-session-122.sh` exits 0 with its own tally; every fix has a falsifiability fixture | SHIPPED | 22 checks with its own `print_tally`; the demo classifies its own cases and hard-errors on an unknown class. All five fixtures invoke real implementations against planted defects. Transcript in `run-evidence.md` is arithmetically self-consistent (16 exec + 2 struct + 1 behav + 3 nested = 22). The reviewer cannot execute, so "exits 0" rests on that transcript. |
| 6 | Cold `fidelity-reviewer` ACCEPT | PARTIAL | The diff carried the QA-dispatch half of plan step 6 (findings artifact + sha-bound governed handoff) but no `sessions/session-122-review.md` — the reviewer declined to grade its own output as landed evidence. Closed by this file. |

**5 of 6 SHIPPED · 1 PARTIAL (procedural) · 0 NOT-BUILT.**

## THE FAKEST GREEN

**The "fail-closed" tooth inside `read-only-guard-has-teeth` — an assertion that cannot fail, in a
check whose name is literally "has teeth."**

The fixture writes a `mystery.md` with no `tools:` line into `$TMP/leak` and asserts the guard
rejects the directory. But `$TMP/leak` still contains the `researcher.md` leak planted three
assertions earlier and never cleaned. The call returns non-zero because of the LEAK, not because
of the missing `tools:` line. **Delete the `[ -n "$TOOLS" ]` fail-closed branch from
`read_only_outside_allowlist` entirely and this assertion still prints "OK: an unreadable grant
fails closed."** Planting `mystery.md` into `$TMP/clean` would have made it real.

The identical defect repeats in `execution_policy_guard_has_teeth`: its fail-closed case runs
against `$TMP/s122.sh`, which still carries planted drift 3 (never restored, unlike drifts 1 and 2).
Remove the emptiness guard and the comparison still returns 1.

**Two of the session's five fixtures end on a tooth that is glued on** — in the session whose one
rule was that a check never seen RED is not evidence. Filed as S123's first defects, unfixed here:
repairing them after the ACCEPT would attest a diff no reviewer saw.

## Adversarial sweep (findings that do not change a grade)

1. **Five surviving "render asserted against its own role's field" instances remain, on `role.name`**
   — the guard exempts the join key by `grep -vx 'name'` and its fixture requires the `name` line
   NOT to match. Judged defensible and disclosed, not a dodge (the key's correctness is pinned by
   literal-string assertions elsewhere, and criterion 3's second clause scopes the target to
   content) — but it is an exclusion reasoned only in a comment, and `assert!(def.contains(role.name))`
   would sail through today.
2. **The guard also excludes by spelling:** `grep -v 'hollow\.'` exempts any line containing the
   text `hollow.`. And it scans exactly one file, while criterion 3's wording is repo-wide. The
   pattern is shape-bound; the escape hatch is spelling-bound.
3. **Criterion 4's honesty is verified by grepping prose the same author typed.** The derived parts
   (`NESTED_N`, `NESTED_NAMES`) are real, but nothing checks the class numbers against the printed
   rows — a check given the wrong `CLASS` string still yields a fully "honest" tally.
4. **The session fixed drift-by-copy for one policy and created fresh drift-by-copy for another, in
   the same diff.** `print_tally()` and `tally_discloses_nesting()` are now duplicated verbatim in
   both verify scripts with no check binding them — the exact failure mode this session shipped a
   check against.
5. **A comment claims more than its code proves.** `fix2_trap_is_live_and_defused` says the handoff
   is "written by the binary, not hand-placed", then proves it with a frontmatter grep plus a sha
   recompute. The sha genuinely raises the bar; nothing distinguishes binary authorship from a
   hand-written file plus `shasum`. Trim the claim.
6. **The probe-sentence question: clean.** No NEW hand-maintained, non-excluded file carries the
   full sentence; the demo and the S122 suite deliberately carry only a fragment.
7. **Scope.** A fifth, uncontracted fix landed (three-copy execution-policy binding + `Task` in the
   Rust forbidden list) plus a `</dev/null` in `verify-session-113.sh`. Both justified by real
   findings; neither violates a stated non-goal. The fifth fix carried the diff's strongest fixture,
   so the trade was net positive. Every declared non-goal held.
8. **"Do not soften" — held.** The executor thesis is corrected to UNPROVEN in the `src/fleet/mod.rs`
   module header, the `qa-specialist` doc comment, both verify headers, the demo, and a
   `DECISION-007` addendum that names the S121 claim it retracts. **No check enforces any of it** —
   it is typed prose, and it will decay the day someone stops typing it.
9. **Stale evidence, disclosed.** The landed `qa-specialist-run.md` and its handoff describe a suite
   that no longer exists (they report `fix3-no-self-referential-assert` RED and call fix 3's fixture
   "retyped"; both were fixed after). `run-evidence.md` carries the later green run, but a reader
   hitting the handoff first is misled.

## Is the real scope one narrow slice presented as the whole?

No. This is a faithful build of the whole contract, and unusually self-hostile: three cold passes
and a live QA dispatch are visible in the code as named repairs, the fixtures mostly invoke real
implementations against planted defects rather than retyped copies, and the biggest surviving
weaknesses are disclosed in the delivery's own output rather than hidden. The delivery is not short.
What it is, is over-confident in its comments: two "has teeth" fixtures end on assertions that
cannot fail, and one comment claims binary authorship it does not test.

**Verdict:** ACCEPT

**Review-Inputs-SHA:** `9998bd3f8f62a6ea7c8b0bdfc5da485ca9e8e93dd51b33ec20c1cc4126eb3daf`
