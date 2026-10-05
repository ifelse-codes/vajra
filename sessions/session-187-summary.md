# Session 187 — Summary (CODE: the guard message and the S190 leftovers)

Brief: `prompts/187-task-guard-message-and-leftovers.md` — rewritten in-session with the founder (2026-10-04):
rudra S18 waits for rudra's data API, so S187 became the guard fix (founder pick **C**: a clearer
message, what blocks unchanged) + every S185 leftover offered. On 2026-10-05 the founder moved **N2 → S188**
and approved the one-line rule for F97.

## Goal achieved?
Yes for D1, D3, D4, D5, D6; D7 is PARTIAL (N7 in the three newest verify scripts + demo-187 only; N5 **named, not closed**); D2 moved
to S188 by the founder. Verify: `scripts/verify-session-187.sh` 14/14 (exit 0); verify-133 15/15, verify-186 35/35, verify-184 14/14 re-run green after the N7 retrofit. Demo: `scripts/demo-session-187.sh`.

## Fidelity map (prompt `prompts/187-task-guard-message-and-leftovers.md`)
| # | Requirement | Status | Evidence |
|---|---|---|---|
| D1 | The approvals guard's writer/interpreter/program blocks say how to get past a joined read; what blocks unchanged | SHIPPED | e88f3e5; `a_joined_read_still_blocks_and_says_split_it`, `s187_blocks_exactly_what_0071dca_blocked` (every corpus command exits the same at 0071dca and now; 40+ blocked) |
| D2 | N2 — ground-truth Write guard lets through paths outside the project | MOVED → S188 (founder, 2026-10-05) | design-advisor: Vajra-only guard (no scaffold copy), ten holes to close (its recs 12–20); this session keeps to changes that only add blocks |
| D3 | N4 — `--steps` names a missing approval | SHIPPED | e306a73; `the_list_names_a_missing_approval_record`; live: this session's list shows `✓ the founder has approved this session` |
| D4 | F97 — `--sync-fleet` adds a project's missing ground-truth audits + question blocks (one-line rule) | SHIPPED | ff2047f; DECISION-007 S187 addendum; DECISION-011 S182 §4 / S183 §3 corrected; tests `sync_fleet_only_adds_ground_truth_to_constraints` (undo = original, byte for byte), front/empty-list and unrecognised-shape tests; the S142 test renamed, not deleted |
| D5 | verify-133 green, no check deleted | SHIPPED | bb4cd4c — 15 checks before (12 PASS · 3 FAIL at 0071dca) and 15 after (15 PASS) |
| D6 | N6 — ROADMAP header derived or deleted | SHIPPED | ac3d544 + f07c875 — the header points at `.ai/SESSION-BOOT.md` / `vajra next --steps`; the S121–S166 notes kept under a history heading; rule 1 amended |
| D7 | N7 one checkout folder + N5 `--dogfood-age` | PARTIAL — N7 for the three newest verify scripts + demo-187 only; N5 named, not closed | bf2349f + 51dfd5c — `scripts/lib-old-checkout.sh`; verify-184/186/187 and demo-187 use it. N5: a rudra run leaves no record on disk (`vajra claude` prints its receipt, writes no file), so the output now says "THIS repo only"; the blind spot stays |
| AC1 | live joined read still exits 2 and names the way past; corpus exits the same | SHIPPED | verify-187 rows 1–2 |
| AC3 | ✗ line with `vajra approve NN` / ✓ with the record | SHIPPED | verify-187 rows 3–4 (0071dca: no such line) |
| AC4 | sync adds; every line byte-identical except the one list line, which equals the original once the added names are removed; dry run writes nothing; second run adds nothing | SHIPPED | verify-187 rows 5–7 (0071dca: sync left the file as it was) |
| AC5 | verify-133 exits 0, same number of checks | SHIPPED | verify-187 row 8 (the 0071dca text of verify-133 fails today's code) |
| AC6 | no hand-typed session number in ROADMAP's header | SHIPPED | verify-187 row 9 (0071dca: "Session 166") |
| AC7 | killed run's checkout in one folder, cleared next run; dogfood-age counts rudra or says "this repo only" | SHIPPED (N5 by its second branch — the label) | verify-187 rows 10–12 |
| AC8 | each fix has a real-run check red at 0071dca | SHIPPED | every verify-187 row runs the 0071dca binary, guard, script or file too |

### verify-133 — the three re-pointed checks (tech-lead rec 4)
- `real-dispatch-passes` — re-pointed: the provenance line was `(verified: <id>)` → since S181 `(verified: <id>; text-sha: <hash>)`; the check still proves the id was surfaced.
- `fixture-red-on-bypass-green-on-rename` — re-pointed: the bypass target `dispatch::reverify(root, role.name, session, &id)` → S181's `dispatch::reverify_handoff(root, role.name, &h)`; the same rung, and the bypass still turns the test red.
- `k-of-8-unchanged-and-not-a-ninth-station` — re-pointed 8 → 7: S168 (DECISION-010) added `complete` to `demo.required_elements`, and S132's demo predates it, so its Demo-er reads ABSENT. Not a regression of S132's work. The check now also requires that the ONE non-PASSED station is exactly that Demo-er, so any other move still fails.

## What I did NOT build
- **N2** (moved to S188 by the founder) — the ground-truth Write guard still blocks writes outside the project.
- **F110 itself** — the guard still blocks a harmless read joined to a write; fix C only makes the block say how to get past it. Option A (Claude Code's own sandbox, `sandbox.filesystem.denyWrite` + `allowUnsandboxedCommands: false`) is recorded for the S190 ground truth.
- **N5** is named, not closed — `--dogfood-age` still cannot see rudra's runs.
- **N7** covers verify-184/186/187 and demo-187 only; verify-176/178/179 and demo-176/178/179/184/186 still make their own checkouts → backlog — reason: housekeeping only we feel; on the S190 ground-truth checklist (cold review rec 3).
- **F97 opt-out key** (design-advisor rec 9): an audit a project removed on purpose comes back on every sync, and sync says so → S188.

## Fakest green
- **AC4's byte-undo test (the cold review's pick).** "Remove the added names and blocks and you get the original" holds for ANY edit that only inserts lines — even one that changes what the YAML means (a second `vision_questions:` key, a project's items moved under another audit). Pass 1 wrote such shapes; after rec 1 they are refused (quoted names, a key with text after its colon, an item at two spaces, a four-space line outside a block, a block with no items), each with a test. A shape nobody listed is still read by the same rules.
- **D1's "only the reason changed" is a list, not a proof** — `s187_blocks_exactly_what_0071dca_blocked` compares exit codes over the test corpus (40+ blocked commands); a command nobody listed is not compared (the S173 limit).
- **N5's PASS is a label.** The verify row proves the words "THIS repo only" are printed; nothing more is measured.
- **AC6 reads the header's words** — after rec 5 it catches `Session N` and `SN`; a number spelled another way ("one-eighty-seven") would pass.

## Found on the way
- The guard blocked my own work four times this session (the branch + list, a python edit naming the folder, a test heredoc) — the F110 cost, measured: each time one retry with a script file.
- `scripts/verify-session-186.sh` pinned "13 passed" for the guard tests — went red the moment S187 added two (the S185 N3 class, again); re-pointed to 13+ in 51dfd5c.
- `scripts/verify-session-89.sh` was already 13/16 at 0071dca (date, last-session and line-count checks of a 2026-07 ROADMAP) — unchanged by S187, left as history.

## Cost
$0 — no paid run. 4 fleet dispatches: tech-lead, design-advisor, fidelity-reviewer (one cold pass, ACCEPT 10/13 · 3 PARTIAL), release-coordinator (the judge of every `obeyed:` answer).

## Next — 3 ranked candidates
1. **(Recommended) N2 — a review-only session may write outside the project.** From the design-advisor's recs 12–20 (resolve the root, the leaf, case, `/var`, relative paths, a crash that exits 1); plus F97's opt-out key. Why: the design is done and it blocked the S185 audit. Risk: it is the one guard change that lets more through — two cold reviews of F110 (b) found holes the same way.
2. **F67 — the receipt reads the tool's own cost for interactive runs.** The one wrong number every user sees (~5× high). Risk: Claude Code may not write a cost into an interactive run's transcript.
3. **The non-Claude tools brainstorm (F91, F94, F95).** Promised since S179. Risk: a design session — nothing a user runs comes out of it.
(rudra S18 waits for rudra's data API — founder, 2026-10-04. S190 is the next ground truth.)
