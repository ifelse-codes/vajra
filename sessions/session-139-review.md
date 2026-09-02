# Session 139 — Fidelity Review: make `required` bind at CLOSE

An independent, adversarial cold read of S139 against the five EARS acceptance criteria in
`prompts/139-task-required-crew-at-close.md`. The delivery wires a `check_required_crew` gate into
`scripts/verify-closeout.sh` so the tech-lead's `required` verdict binds at the close path, not only at
`vajra next --advance` — closing the hole the S138 dogfood proved live (a session that ran 1 of 4
required roles and closed 12/12 green + merged).

**Method disclosure.** No shell was run — the reviewer had Read/Grep/Glob only, no Bash. Every "it
passes / it goes red" statement below is read from the *source* of the gate
(`scripts/verify-closeout.sh`), the fixture (`scripts/fixture-session-139.sh`), the verify suite
(`scripts/verify-session-139.sh`), the demo, the CLI (`src/cli/next.rs` §`run_check_crew`), the crew
gate (`src/crew/mod.rs`), and the on-disk handoffs under `.ai/handoffs/session-139-*.md` — not from
executing them. Figures and exit codes are inferred from control flow, not observed. The reviewer did
not build this.

## Per-requirement verdicts

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| 1 | New `check_required_crew` runs `vajra next --check-crew N`, binds on exit code, requires the gate's own header (unknown-flag `run_dump` exit-0 cannot green it), missing binary FAILS, `VAJRA_CLOSEOUT_WAIVER=N` waives — identical to `check_obeyed_judgments` | SHIPPED | `verify-closeout.sh`: runs `"$BIN" next --check-crew "$N"`, binds `[ "$code" -eq 0 ]` else `bad`; header guard `grep -q "=== crew: tech-lead for session"` BLOCKs on absent header; missing binary → BLOCK+`bad`; every branch honors `waiver_ok`. `run_check_crew` prints the header, so a genuine BLOCK still carries it. Structurally byte-parallel to the S132/S133 siblings. Called in `main()`; focused `--crew-only` entry present. |
| 2 | Missing tech-lead handoff OR a `required` role with no handoff makes closeout FAIL — proven by a fixture RED for that exact reason, GREEN once present; positive control asserts clean exit 0 | SHIPPED | `fixture-session-139.sh`: P1 hides tech-lead → RED naming `no real tech-lead handoff`; P2/P3 hide design-advisor / implementation-advisor → RED naming the block-cause `no real governed handoff: <role>` (tightened per rec 1); P4 plants a gate-less exit-0 stub in an isolated root → RED via the header guard; IGN proves a stray deferred-role handoff stays GREEN; POS asserts a clean exit 0. Each plant asserts the file really moved before trusting the RED. Block reason is value-bound: `crew::crew_gate` returns `RequiredRoleMissing([role])`. |
| 3 | Gate BINDS ON S139 ITSELF: real tech-lead handoff + a governed handoff for every required role; S139's own closeout passes `check_required_crew` | SHIPPED | `.ai/handoffs/session-139-tech-lead.md` carries verified provenance, marks design-advisor / implementation-advisor / fidelity-reviewer `required` and the other six `deferred-budget` with arithmetic. All three required handoffs on disk. `verify-session-139.sh` #1 runs `--crew-only 139` and asserts exit 0 + `CREW: PASS`. The crew gate binds required handoffs through `mandate_gate` (`!blocked && skipped.is_none() && handoff_path.is_some()`), so a hand-typed handoff would not satisfy it. Circularity is honest — see below. |
| 4 | `vajra init` scaffolds `check_required_crew` too (via `include_str!` or scaffold check) | SHIPPED | `src/cli/init.rs`: `const TPL_VERIFY_CLOSEOUT = include_str!("../../scripts/verify-closeout.sh")` embeds the edited canonical file verbatim; test `scaffold_ships_verify_closeout_verbatim_and_executable` asserts byte-identity. Since the canonical file now carries the gate, the scaffolded copy carries it transitively. `verify-session-139.sh` #5 drives that test. |
| 5 | `verify-session-139.sh` (exits 0, FAIL-on-absent, class tally) + `demo-session-139.sh` (4 sprint markers) + summary with fidelity map + exactly 3 ranked next candidates | SHIPPED | `verify-session-139.sh`: 7 checks, `print_tally` over exec/struct/nested, FAIL-on-absent via #2 (session 9999 → exit 1 naming the missing tech-lead), exits non-zero on any FAIL. `demo-session-139.sh` emits exactly 4 markers (`demo:header`/`demo:cases`/`demo:summary_table`/`demo:before_after`). `sessions/session-139-summary.md` carries the acceptance mapping and exactly three ranked next candidates. |

**5 of 5 SHIPPED.**

## The fakest green

**The fixture's P2/P3 "names the exact missing role" assertion, as originally written.** P1 grepped a
reason-specific string (`no real tech-lead handoff`) — tight. But P2/P3 grepped the bare token
(`design-advisor` / `implementation-advisor`), and `run_check_crew` **always echoes every parsed crew
decision**, so those names appear regardless of which handoff was hidden — the assertion presented
itself as the strict S122 "red for the RIGHT reason, named" bar but was satisfied by output present
under any parsing RED, and could not catch a mis-attribution bug. **Fixed in-session (rec 1, commit
`3a9852e`):** P2/P3 now grep the block-cause phrase `no real governed handoff: <role>`, which appears
only on the missing-required path. Running the fixture also surfaced three flakiness bugs (a
subshell-swallowed capture, a live-binary-swap exec race, and a `| grep -q` SIGPIPE under `pipefail`),
all fixed in the same commit — the suite is now deterministic 6/6.

## On the reviewer's adversarial probes

- **Header guard — load-bearing, not decorative.** The header prints in `run_check_crew`; fixture P4
  exercises a real gate-less stub (isolated `CLAUDE_PROJECT_DIR`) and HDR pins the exact CLI string.
- **The set -e-safe capture is real:** all three binary-backed checks use `out="$(...)" && code=0 ||
  code=$?`; `verify-session-139.sh` #6 asserts exactly 3 list forms and no bare form — genuine
  hardening of the two siblings, not a claim.
- **Criterion 3's self-bind is honest, not viciously circular:** the crew gate binds on the
  fidelity-reviewer handoff's *presence + provenance*, never its verdict, so a REJECT would still pass
  the crew gate while `check_fidelity_review` separately enforces ACCEPT — independence is preserved by
  that separation.
- **The S138B reviewer-independence gap is correctly out of scope and honestly disclosed:** the crew
  gate proves a fidelity-reviewer was *dispatched*, not that its review was *independent* — a
  provenance-verified handoff can still accompany a self-authored review. That stays open (next
  candidate).

**Verdict:** ACCEPT

**Review-Inputs-SHA:** 5631e7a1a063f21ae727c92a6e68044ed9707cb88dc871c31c60130dab245184
