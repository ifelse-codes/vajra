# Fidelity review — session 177 (`session-177-keep-testing`)

**Verdict:** ACCEPT

**Review-Inputs-SHA:** b4cb5dafe9253db627098c4fb1db863f120d9506a399ea90af106a003c1d29b8 (`scripts/verify-closeout.sh --inputs-sha 177`, run by the orchestrator against the final diff — the reviewer's pass cannot execute code)

8 of 8 numbered items SHIPPED · the only-add guardrail PARTIAL. One cold pass (`fidelity-reviewer`),
read-only. Its recs 1–2 were applied AFTER this pass (8bacfee) and judged `implemented` by the
release-coordinator; the reviewer re-read 8bacfee and confirmed it does not change the ACCEPT. Rec 3
(LOW) is deferred. The attested inputs hash above covers the final diff, including those fixes.

---


# Fidelity review: session 177 (F74 and F76, the scaffold close gate)

**How I reviewed it.** This was one cold pass. My inputs were the prompt, the files the diff touched (read at HEAD), `.git/logs/HEAD` for the commit chain, and rudra's synced gate, CONSTRAINTS and S10 prompt. I could not execute anything, so I have not run the counts the builder reports ("17 non-CODE → CODE", "598/598", "old = new at 16"). I judged the logic of the code and harness that produce them.

**Scope.** This is a faithful build of the whole contract, which is small. It is not one slice passed off as the whole. One claim goes too far ("Adds only"; see the fakest green).

## Per-requirement verdicts

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| G1 | A CODE session gets its full close checks after a moved ground truth (GT) and with a `**CODE.**` brief | SHIPPED | `scripts/verify-closeout-scaffold.sh:56-64` (helper), `:289`, `:304`, `:391` |
| D1 | Scaffold reads `ground_truth_next_session` at both sites and accepts `**CODE.**` | SHIPPED | The helper is identical to Vajra's own gate (`scripts/verify-closeout.sh:56-64`). It is used in `is_code_session:289` and `check_verify_demo_scripts:391`. No `N % 5` is left outside the helper. The regex `\*\*CODE[.:,]?\*\*` is at `:304`. |
| D2 | `tests/scaffold_gt_cadence.rs` runs the real scaffold functions on fixture projects | SHIPPED | `tests/scaffold_gt_cadence.rs:44-56` pulls the real functions out of the gate with sed. It has 4 tests covering S10/S15 with the key, no key, and the Type spellings. Caveat: it never runs under the gate's `set -euo pipefail` or its real entry point. |
| D3 | rudra gets the fixed gate before its S10 | SHIPPED | `/Users/suman/playground/rudra/scripts/verify-closeout.sh:56,289,304,391` carry the helper and the new regex. The file is uncommitted in rudra; this is disclosed. |
| AC1 | Key 15: S10 is CODE and its scripts check BLOCKS; S15 is N/A | SHIPPED | Test `:78-101`; `verify-session-177.sh:40-48`, which also runs old vs new on S10 and checks S11. |
| AC2 | No key: every session number answers as before (listed spread) | SHIPPED | `verify-session-177.sh:51-57`: 16 numbers, old from pinned 8061a52 vs new. Test `:105-116`. |
| AC3 | `**CODE.**`, `**CODE**` and `**CODE**,` read as CODE; `**NO-CODE.**` and `**DOCUMENT.**` do not; nothing goes CODE → non-CODE across both repos | SHIPPED | `verify-session-177.sh:60-87`; test `:122-139`. The regex is a strict superset of the old exact `**CODE**` match. `**NO-CODE.**` cannot match because it contains no `**CODE`. |
| AC4 | rudra's own synced gate says S10 is CODE | SHIPPED | `verify-session-177.sh:90-96` pulls the functions from rudra's file and runs them in rudra's tree. rudra's key is 15 (`rudra/.ai/CONSTRAINTS.yaml:12`) and its S10 Type is `- **CODE.**` (`prompts/10-task-persist-verdicts.md:16`). This tests the functions, not the real entry point end to end (rec 2). |
| GR | Guardrail: changes may only ADD, compared old vs new on a listed set | PARTIAL | Checked only with the key absent, or with the key at 15, a multiple of 5. The one path that loosens is never swept: key = N where N is not a multiple of 5. See the fakest green. |
| GR | Guardrail: anything unfixed goes in the findings table with a severity | SHIPPED | Prompt Findings table: F71 and F67 (parked) and F75 (LOW) are logged. |

**8 of 8 SHIPPED** for the numbered Goal, Deliverable and Acceptance items. The only-add guardrail is PARTIAL.

## The fakest green

**"Only adds / 0 CODE → non-CODE."** This claim appears in `DECISION-007-agent-fleet.md:1665-1666` ("Adds only") and in the demo (`demo-session-177.sh:92`, "Only ever adds checks").

- **On the Type-line axis it is true by construction.** The new regex matches everything the old exact match did, so the sweep could not have found a loosening there.
- **The sweep cannot see the other axis.** It empties CONSTRAINTS.yaml and skips multiples of 5 (`verify-session-177.sh:75-76`). AC1 only tests key 15, which is itself a multiple of 5.
- **So the one real removal the change makes is never tested.** Set `ground_truth_next_session` to a number that is not a multiple of 5, say 17. S17 was a CODE session under the old gate, with the scripts check and the tech-lead check. It now passes both as N/A.
- **This is the intended meaning** when the founder moves the ground truth, and nothing hits it today (rudra 15, Vajra 180). But it is a loosening, and nobody compared or disclosed it.
- **The agent can use it too.** The key sits in `.ai/CONSTRAINTS.yaml`, which the agent can write. I found no hook protecting it. An agent could write its own session number there and skip both checks at close. Vajra's own gate has had the same exposure since S175.

## Bash checks (no blocking bugs)

- **`set -euo pipefail`:** `local gt_next` is declared apart from the assignment. The grep pipeline ends in `|| true`, so a missing key or file does not abort under pipefail. Both call sites are in condition context (`if` or `! … ||`), so a non-zero return is safe under `-e`. `N` is always set before the helper runs.
- **`10#`:** `gt_next` only ever holds digits (`grep -oE '[0-9]+'`), so `$((10#$gt_next))` is safe, and leading zeros such as `015` are handled.
- **sed function extraction:** `/^f()/,/^}/` works for all four functions. None of their bodies has a `}` at column 0 before its end. In the old gate, `is_ground_truth_session` does not exist, so the extraction sources an empty string, which is harmless.
- **Regex vs `**NO-CODE.**`:** it does not match, which is correct.
- **Low:** the key value is read as the first run of digits on the line. So `ground_truth_next_session: TBD  # after S10` is read as 10. The same flaw is in Vajra's own gate (rec 3).

## Obeyed checks

For all four tech-lead recs the commit named in the disposition exists in `.git/logs/HEAD` between 8061a52 and HEAD. The rec 1 and rec 4 dispositions cite the tech-lead's own handoff commit. The actual evidence that they were obeyed is what the tree shows: only `session-177-tech-lead.md` exists under `.ai/handoffs`, and this is a single pass.

obeyed-check tech-lead rec 1 — implemented: 75ec337 — commits the tech-lead handoff naming only fidelity-reviewer as required, eight deferred-budget; no other session-177 role handoff exists in `.ai/handoffs/`
obeyed-check tech-lead rec 2 — implemented: 0de77a7 — the start commit carries the prompt's `## Design` with `design-advisor: skipped — <reason>` and cites DECISION-007; the addendum the rec asks for if design-significant landed in 2053bb7 (`DECISION-007:1651-1672`)
obeyed-check tech-lead rec 3 — implemented: f9b3387 — `verify-session-177.sh` proves key 15 + S10 → CODE + FAIL, key 15 + S15 → N/A, and no key → old = new over 16 numbers; rudra's synced copy is only checked for S10 (and S09) CODE, with no byte-equality check to the scaffold
obeyed-check tech-lead rec 4 — implemented: 75ec337 — a single fidelity-reviewer pass was dispatched (this one); no second pass unless REJECT
obeyed-check release-coordinator rec 1 — implemented: 4676488 — per its log subject it commits the ROADMAP row and both the fidelity-reviewer and release-coordinator handoffs (both paths are in `.git/index`); none of first-mate.html, .claude/launch.json, session-137-scatter-render.html or vajra-cto-audit-2026-07-22.html is in the index or any S177 commit subject; caveat: the `## Advice` answers cannot be inside the commit they cite (the release-coordinator lines cite the later 69f3145, the last logged commit), so the prompt must still be committed by path before the push
obeyed-check release-coordinator rec 5 — implemented: 69f3145 — adds the tracked `sessions/session-177-summary.md`, whose `## Deferred` section (lines 72-75) records fidelity-reviewer rec 3 (the key-parse flaw, parked); prompt line 104 answers it `deferred: sessions/session-177-summary.md`, a real path, not a bare note

## Recommendations

rec 1 — Correct the "Adds only" claim in DECISION-007 (S177 addendum) and the demo caption: with the key set to a number that is not a multiple of 5, that session loses the scripts and tech-lead checks the old gate ran (intended when the founder sets it; agent-writable otherwise).
This is disclosure only. Do not add a new guard: the founder's 2026-09-15 directive says to park loopholes. If you want the evidence, one sweep row (key 17, S17, old vs new) makes the loosening visible.

rec 2 — In `verify-session-177.sh`, check that rudra's synced file is byte-identical (`cmp`) to `scripts/verify-closeout-scaffold.sh`, and run rudra's real entry point (`scripts/verify-closeout.sh --check-claimed 10` in rudra).
Today AC4 and tech-lead rec 3 rest on functions pulled out with sed and run with stubbed `ok`/`bad`, never under the gate's own `set -euo pipefail`.

rec 3 — (LOW, parkable) Tie the key's number to the value itself, not to the first digits anywhere on the line, in both gates' shared helper.
`ground_truth_next_session: TBD # after S10` currently reads as 10.

## Handoff Delta
- `+` new: first fidelity-reviewer handoff for session 177. **Verdict: ACCEPT**, 8 of 8 numbered items SHIPPED, only-add guardrail PARTIAL.
- `+` fakest green named: "Adds only / 0 CODE → non-CODE" is true by construction on the Type axis and never swept on the key axis (key = N, N not a multiple of 5, loses checks).
- `+` 4 obeyed-checks, all `implemented:`. Rec 3 carries a note: rudra's copy has no byte-equality check.
- `+` 3 recs: correct the only-add claim, make AC4 end to end, a LOW key-parse fix.
- `+` 2 release-coordinator obeyed-checks, both `implemented:` (rec 1 at 4676488, rec 5 at 69f3145). Caveat on rec 1: the `## Advice` answers are not in any logged commit yet (HEAD = 69f3145), so the prompt still needs a commit by path before the push.
- prior stage: `.ai/handoffs/session-177-tech-lead.md` (4 recs, 1 required role). This review answers its rec 3 brief (scaffold diff, fixture, rudra sync proof).

Files: `/Users/suman/playground/vajra/scripts/verify-closeout-scaffold.sh`, `/Users/suman/playground/vajra/tests/scaffold_gt_cadence.rs`, `/Users/suman/playground/vajra/scripts/verify-session-177.sh`, `/Users/suman/playground/vajra/scripts/demo-session-177.sh`, `/Users/suman/playground/vajra/docs/decisions/DECISION-007-agent-fleet.md`, `/Users/suman/playground/rudra/scripts/verify-closeout.sh`