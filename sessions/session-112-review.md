# Session 112 — Independent fidelity review (cold, two passes)

> **DECISION-002 artifact.** The builder does not grade itself. Two separate cold subagents were run,
> each in its own fresh context, each fed EXACTLY two files — the contract
> (`prompts/112-task-handoff-consumption.md`) and the delivery diff — and denied everything else in
> the repo: no summary, no `.ai/STATE.md`, no `SESSION-BOOT.md`, no roadmap, no git, no build.
> Neither was told the expected score. Both were framed adversarially: *assume the builder silently
> re-scoped to whatever yields a green checkmark; find the fakest checkmark.*

## Method controls (what the reviewers were fed, and what it cost)

| Control | Pass 1 | Pass 2 |
|---|---|---|
| Contract fed | `prompts/112-task-handoff-consumption.md` | same (final, unchanged since pass 1) |
| Diff fed | 937 lines, 6 files, excludes `sessions/` + `.ai/` state | 1011 lines — the SAME diff plus pass 1's fixes |
| Denied | repo, git, build, all self-narrative | same |
| Told the answer? | no | no |
| Verdict | **ACCEPT** (14 of 20 SHIPPED) | **ACCEPT** (16 of 20 SHIPPED) |

**Stated cost of the controls (both reviewers raised it, unprompted):** a cold reviewer cannot
observe greenness. "`cargo test --lib` green", "CI both OS", and "both scripts exit 0" are claims a
diff cannot settle. They graded the *assertions*, never the *outcomes*. The builder's own live runs:
`cargo test --lib` 315 passed / 0 failed · `scripts/verify-session-112.sh` 16/16 ALL GREEN ·
`scripts/demo-session-112.sh` exit 0. CI on both OS is unevidenced pre-merge (same PARTIAL S109 and
S111 carried).

## Two passes, because pass 1 found a real hole

Pass 1 returned ACCEPT but named a genuine defect: the two surfaces this session is *about* — the
packet and the Analyst gate — were certified by **header** greps (`grep -q "fleet handoffs (session
112)"`) that a **rejected** handoff would satisfy identically, since the header prints for a
`⚠ … — not used` block too. "A hollow *proof*, not a hollow *feature*." It also found two honesty
gaps: truncated findings had no "N more lines" marker, and `parse_handoff` could produce a `Handoff`
with blank fields (because `validate_handoff` scans all lines, not just the frontmatter block).

All three were fixed in-session (`eaff77d`), then a **fresh** reviewer with no knowledge of pass 1
graded the updated diff. Pass 2 confirmed the fixes ("a real hole found and closed, not a comment")
and found its own, sharper one — see Fakest green — which was also fixed (`26e5544`) before close.

## Per-requirement table (pass 2, the final grading)

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| D1 | Reader in `src/fleet/` — three honest outcomes, renderer inlines findings | SHIPPED | `parse_handoff` · `enum HandoffRead {Absent, Malformed, Found}` · `read_handoff`/`read_handoffs` · `format_handoff_brief` emits body text, not a pointer |
| D2 | Analyst consumes it (`--intake`, `--scaffold`) | SHIPPED | `Intake.fleet_handoffs`; both call sites pass `current_session(&root)`. *Reviewer caveat: `--scaffold` is wired by shared code path, exercised by no test.* |
| D3 | Packet + Analyst gate surface it | SHIPPED | `run_dump` header-guarded block; `run_validate` prints the brief before the exit decision |
| D4 | verify + demo, both green, both proving behaviour | SHIPPED | `_e2e_consumption` drives the REAL writer; `real_handoff_surfaced` asserts content, not just a path |
| D5 | summary + independent cold review | PARTIAL | Definitionally outside the diff — the review cannot appear inside the diff it reviews |
| NG1 | No second fleet role | SHIPPED (honored) | `ROLES` untouched |
| NG2 | Handoff format unchanged | SHIPPED (honored) | Writer functions called, never modified; additive hunks only |
| NG3 | No unattended `claude -p` mode | SHIPPED (honored) | No spawn added; only `fs::read_to_string` |
| NG4 | No 8th command | SHIPPED (honored) | All wiring inside existing `next` handlers |
| NG5 | No blocking gate — advisory only | SHIPPED (honored) | Brief printed outside `verdict`; no exit path touched |
| P1 | Reader + unit tests (absent/malformed/found, path-is-SoT) | SHIPPED | 7 fleet tests named in the diff |
| P2 | Intake renders inline; absent silent; malformed named | SHIPPED | Header inside the `!brief.is_empty()` guard; both tests present |
| P3 | Packet + gate wiring | SHIPPED | as D3 |
| P4 | Scripts with live before/after + real-data check | SHIPPED | `e2e-consumption` + `real-handoff-surfaced` with a negative control |
| P5 | Summary + fidelity map + cold review | PARTIAL | as D5 |
| AC1 | A station surfaces the handoff with findings INLINED | SHIPPED | Four surfaces; content asserted after the pass-1 fix |
| AC2 | Absence silent; off-contract handoff NAMED | SHIPPED | `! grep -qi "handoff"` over the whole BEFORE output — a whole-output negative, stronger than a targeted one |
| AC3 | Real end-to-end proof through the real writer | SHIPPED | Throwaway repo, real `vajra next --role`, not a planted fixture; cross-session negative control |
| AC4 | tests green · CI both OS · both scripts exit 0 | PARTIAL | Greenness + CI unobservable from a diff (see method controls) |
| AC5 | Independent cold review | PARTIAL | Satisfied by this document; not evidenced in the diff |

**16 of 20 SHIPPED** (4 PARTIAL, 0 NOT-BUILT). All four PARTIALs are the same two things: closeout
paperwork that cannot exist inside the diff being reviewed, and greenness/CI a cold reviewer cannot
observe.

## Fakest green (pass 2 — fixed before close)

> **`cargo test --lib <filter>` exits 0 when the filter matches ZERO tests.**

Seven of the verify script's checks named a specific test (`test-truncation-disclosed`, …). Each
asserted "no test *by this name* failed" — satisfied identically by a passing test, a **renamed**
test, and a **deleted** test. Half the PASS count was padding, and the two checks added to lock down
pass 1's fixes were themselves the most vacuous-on-deletion lines in the file.

Fixed in `26e5544`: `named_test_passed()` now requires `test result: ok. N passed` with N ≥ 1, and a
guard-on-the-guard (`test-filter-guard-has-teeth`) runs a deliberately nonexistent filter and
requires it to FAIL. Verify went 15 → 16 checks, all green.

**Runner-up (NOT fixed, disclosed):** `no-eighth-command` greps a hardcoded usage banner
(`vajra <init|claude|check|next|estimate|hook|meter>`), so it would keep passing for an 8th command
whose author simply did not update the help text. The non-goal genuinely holds — both reviewers
confirmed it structurally in the diff — but the *check* does not enforce it. This is a house-wide
pattern (S111 carries the identical check); left as-is rather than fixed unilaterally in one session.

**Pass 1's fakest green, for the record:** the packet check asserting a section header that a
rejected handoff also prints. Fixed in `eaff77d`.

## Residual holes named by pass 2 and NOT fixed (disclosed, not hidden)

1. **An empty-bodied `Found` would render a path with zero findings and no warning.** Analysed as
   unreachable: `validate_handoff` (locked, S109) rejects an empty findings body, and `parse_handoff`
   calls it first. No defensive patch added without repro evidence (`self_review_questions`).
2. **`--validate NN` prints the brief with no section label** — functionally consumption,
   cosmetically an orphan next to the other two surfaces.
3. **A misfiled handoff is consumed silently** — path-is-SoT is implemented as contracted, but a
   frontmatter `session: 999` at session 112's path is never reported as a mismatch. Contract-blessed;
   an undisclosed asymmetry until now.
4. **`frontmatter_value` requires a literal `---\n`** — CRLF or a leading blank line fails closed to
   `Malformed`. Safe, but a Windows/`autocrlf` checkout would flip `real-handoff-surfaced` to FAIL.
5. **`--scaffold` has no coverage of its own.**

**Review-Inputs-SHA:** PENDING

**Verdict:** ACCEPT

The real scope is a faithful build of the whole contract, not one narrow slice presented as the
whole — the reader, all four consuming surfaces, the absent/malformed/found trichotomy, path-as-SoT,
and truncation disclosure are each in shipping code paths and pinned by tests, with an end-to-end
proof that drives the real writer rather than a planted fixture.
