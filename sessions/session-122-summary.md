# Session 122 — Summary

**Type:** CODE · **Branch:** `session-122-qa-suite-real-holes` · **Date:** 2026-08-19
**Goal:** close the four real holes the S121 live QA run found in S121's own guardrails — each with
a falsifiability fixture, because a check never seen RED is not evidence.
**Verdict:** **ACCEPT** — cold `fidelity-reviewer`, pass 4. 5 of 6 SHIPPED · 1 PARTIAL (procedural)
· 0 NOT-BUILT. Full brief: `sessions/session-122-review.md`.

## What shipped

| Fix | What was wrong | What landed | Fixture |
|---|---|---|---|
| 1 | The read-only guard was `grep -q "^tools: Read, Grep, Glob"` — a PREFIX match that passed `tools: Read, Grep, Glob, Write` | `read_only_outside_allowlist()`: tokenised, whole-token comparison, exact-token allowlist (not `grep -w`, which treats `-` as a boundary) | SHIPPED — plants the leak, shows the OLD grep green on it, requires the new guard RED, green on a clean fleet |
| 2 | `one_source_of_role_text` did not exclude `.ai/handoffs/` — a QA report quoting the role's own probe sentence turned the suite RED with a message that could not explain why | `.ai/handoffs/` excluded; the failure message NAMES every carrier by path; the exclusion narrowed to the one script the check lives in, never a wildcard | SHIPPED — three states in a temp repo, incl. the S121 list shown tripping, and the message asserted to name the offender |
| 3 | `def.contains(role.system_prompt)` — the render asserted against the field it renders from, true for `""` | Three instances removed (two more found by cold review); `role_prompt_substance()` is ONE function shared by the real test and the fixture; per-role literal content + cross-wiring negative; `EXPECTED_GRANTS` table | SHIPPED — the fixture calls the REAL rule against a hollow role and a stub, with a positive control over every registered role |
| 4 | The tally folded a 14-check suite into one `exec` slot; a 7-check suite too | Fourth class `nested`; `print_tally()` is a function, names each nested suite, prints "NOT a census" and "a FLOOR, never a total"; disclosure derived, never hardcoded | SHIPPED — the S121 one-liner kept verbatim as a negative control the predicate must REJECT |
| 5 (uncontracted) | The forbidden-tool policy lived in three copies and had already drifted — `Task` missing from the Rust list, so a role granted execution-by-proxy passed the unit test | `Task` added; `execution-policy-one-source` binds both halves (forbidden tools AND execution allowlist) across all three copies | SHIPPED — copies the three real files, plants drift in each half, requires RED each time, GREEN on untouched copies |

- `scripts/verify-session-122.sh` — **22 checks, exit 0.** `scripts/demo-session-122.sh` — **9 of 9**,
  classifying its own cases. Both tallies disclose their nesting. **337 lib tests.**
- **The booby-trap is ARMED in this repo.** A real governed `qa-specialist` handoff quoting the
  probe sentence sits in `.ai/handoffs/`; the S121 suite runs green with it there. That is the
  strongest evidence in the session — the trap is defused against the live case, not a mock.
- `verify-session-113.sh` gained `</dev/null` on its `vajra init`. The same defect cost 10 minutes
  at S121 and 20 minutes here.

## Fidelity map (every numbered requirement)

| # | Requirement | Verdict |
|---|---|---|
| 1 | Read-only guard rejects a leak, proven by a fixture that turns it RED | SHIPPED |
| 2 | Handoff cannot trip `one_source_of_role_text`; message names the carriers | SHIPPED |
| 3 | No test asserts a render against the field it renders from | SHIPPED |
| 4 | The tally no longer implies a complete count | SHIPPED |
| 5 | `verify-session-122.sh` exits 0; every fix has a falsifiability fixture | SHIPPED |
| 6 | Cold `fidelity-reviewer` ACCEPT | PARTIAL — graded PARTIAL because the review file was not yet landed at review time; closed by `sessions/session-122-review.md` |

## THE FAKEST GREEN (do not soften)

**Two of the five fixtures end on a "fail-closed" tooth that cannot fail.**
`read-only-guard-has-teeth` writes a `tools:`-less `mystery.md` into the directory that STILL holds
the planted `Write` leak, so the guard rejects it for the wrong reason — delete the fail-closed
branch entirely and the assertion still prints OK. `execution-policy-guard-has-teeth` repeats it
(its fail-closed case runs against a copy still carrying planted drift 3). In the session whose one
rule was "a check never seen RED is not evidence", two teeth are glued on. **Filed as S123's first
defects, deliberately unfixed here** — repairing after the ACCEPT would attest a diff no reviewer saw.

**Also still true, and not softened:**
- The check-class labels are **still typed by the author.** S122 made the tally honest about
  NESTING; it did not make one label EARNED. Unpicked option B from the S121 close.
- `no-eighth-command` is still a hardcoded-banner grep, here and in S113's suite.
- **The executor thesis is UNPROVEN.** Two live QA runs, seven real defects, every one from
  independent READING. `DECISION-007` now carries an addendum retracting the S121 claim. Nothing
  CHECKS that correction — it is typed prose that decays the day someone stops typing it.
- `print_tally()` and `tally_discloses_nesting()` are duplicated verbatim across both verify scripts
  with no check binding them — the session fixed drift-by-copy for one policy and created it for
  another, in the same diff.

## How this session actually went (recorded, not hidden)

Four cold-review passes were needed: **REJECT → ACCEPT-with-findings → REJECT → ACCEPT.** Every
rejection was correct. The same tautology was found on a **third** field after two "fixes"; the
booby-trap was re-armed **twice** inside the session closing it; the anti-hollowness demo was itself
hollow (six hardcoded `PASS` rows and a case scored by `true`). The dispatched `qa-specialist` found
three more real defects before any of that. **The independent passes, not the builder, found every
one of these.**

## Cost

`$0` metered (interactive session). One `qa-specialist` and four `fidelity-reviewer` subagent passes
roll in unitemized: ~54k + ~80k + ~97k + ~94k + ~105k subagent tokens. No paid dogfood run.

## Next — 3 options (A/B/C)

| | Title | One-sentence goal | Why pick this | Key risk |
|---|---|---|---|---|
| **A** | **Fence the `Write`/`Edit` grant** | Make it structurally impossible for the QA role to edit the code it tests, instead of asking it not to. | The standing leading candidate since S121; on both live runs the tree was unchanged only because the agent chose to hold the line, which is not a control. | It is a real design decision (ride the L3 `hook-pre-write.sh` surface, or change the grant), not a patch — could outgrow one session. |
| **B** | **Make the check-class label EARNED** | Derive `exec`/`struct`/`behav` from what a check actually does rather than from a word the author typed. | Disclosed as the fakest green four times now (S64, S67, S121, S122). Every honest tally this session prints still rests on a self-assigned label. | Deriving it may be undecidable in the general case; risk of shipping a heuristic that is itself a new fakest green. |
| **C** | **Close the glued-on teeth + bind the duplicated tally** | Fix the two fixtures that cannot fail, and make `print_tally`/`tally_discloses_nesting` one source across both suites. | Small, certain, and it closes THIS session's named fakest green plus the drift-by-copy it created. | Low ambition for a whole session; it is cleanup, not payload. |

**Picked: A** — and the pick is recorded in `prompts/123-task-fence-the-write-grant.md`. C's items ride
along inside A as the first commits, because they are cheap and they are this session's own debt;
B stays the standing backlog item it has been since S64.
