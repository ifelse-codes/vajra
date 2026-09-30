# Fidelity review — session 181 (`session-181-close-the-loopholes`)

**Verdict:** ACCEPT

**Review-Inputs-SHA:** e8f3bf29f1f39f1ca68e33153b4d14cf942488cdb216e940ff77b1565bd93fe4 (`scripts/verify-closeout.sh --inputs-sha 181`, run by the orchestrator against the final diff after the last prompt/handoff commit — the reviewer's pass cannot execute code)

Two cold passes (`fidelity-reviewer`, read-only, verified handoff `.ai/handoffs/session-181-fidelity-reviewer.md`). **Pass 1 REJECTed** the first build (3 of 6 SHIPPED, 2 PARTIAL, 1 NOT-BUILT): the scaffold's legacy cutoff was hard-coded at 180 (a project like rudra never got the new rules), a missing lib silently dropped the type check, the hook tests returned early without `jq` and drove 2 of 5 sites, no gate-level stamp test, the passed-override note was not printed in the close gates, and there were no verify/demo scripts. All were fixed and **pass 2 (fresh, below) ACCEPTed: 5 of 6 SHIPPED, 1 PARTIAL, 0 NOT-BUILT.**

**After the ACCEPT (carried, not fixed — code after an ACCEPT needs a fresh review, F81; the founder closes on one review):** recs 1 and 2 below go to S182 — the hollow whole-suite check at `scripts/verify-session-181.sh:75`, and a gate-level obeyed-handoff test.

---

Fresh cold pass (`fidelity-reviewer`, read-only) over the FIXED build. A first pass REJECTed. This pass confirmed each first-pass defect is fixed in source, each with a test that drives the real thing: legacy cutoff now from `session_rules_from` (`scripts/lib-ground-truth.sh:129`, `scripts/verify-closeout.sh:347`, `src/approval/mod.rs:33`, scaffold ships `session_rules_from: 1` at `src/cli/init.rs:1464`); missing lib fails closed (`verify-closeout.sh:38`, `:382`); all 5 hook sites driven and a missing `jq` fails loudly (`tests/gt_cadence_shared.rs:191-209`); a gate-level stamp test with a real capture and a hand-edit (`tests/stamp_gate.rs`); the ground-truth note printed in the close gates and four announcing hooks; verify and demo scripts exist.

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| 1 | Part 1: `claude` exception in `--help`; dry-run test can fail; three `--help` probes | SHIPPED | `src/main.rs:233`; `tests/cli_front_door.rs:261-354` commits the scaffold, edits AGENTS.md, asserts status changed before and unchanged after, and the edit survived; three probes assert exit 0, "usage:", clean repo |
| 2 | Part 2: one helper; 6 sites + scaffold use it; S181 not GT / S185 GT with key 180; passed override rolls forward and says so | SHIPPED | `scripts/lib-ground-truth.sh:26-48`; `tests/gt_cadence_shared.rs:74-115,190-234` |
| 3 | Part 3: strict `session_type`; fails closed; each value honoured; loud fallback; same in scaffold gate | SHIPPED | `lib-ground-truth.sh:59-76`, `verify-closeout.sh:361-387`, scaffold mirror; `tests/session_type_gate.rs` runs both gates (functions extracted by sed, so call order is read, not tested) |
| 4 | Part 4: approve refused marked / works unmarked; gate ignores typed APPROVED; allow-all recorded as launch-time; limit written where read | SHIPPED | `src/approval/mod.rs:147-173`, `src/analyst/mod.rs:661-685`, `src/cli/launch.rs`, `tests/approval_cli.rs`; limit in `main.rs:207`, the module doc, DECISION-011 |
| 5 | Part 5: a named waiver passes only that check; no reason refused; stamp dies when text changes; legacy waiver kept with a warning | SHIPPED | `lib-ground-truth.sh:88-120`, `tests/named_waivers.rs`, `src/dispatch/mod.rs:101-156`, `tests/stamp_gate.rs`; the obeyed gate is unit-covered only |
| 6 | Every part has verify checks that run the real thing; `verify-closeout.sh` exits 0 before merge | PARTIAL | `scripts/verify-session-181.sh` runs the real test binaries, the pinned old-vs-new stop hook and `vajra approve`; no source greps. Exit 0 of the close check is not judgeable from source; the final whole-suite check is hollow (below) |

5 of 6 SHIPPED, 1 PARTIAL, 0 NOT-BUILT.

Fakest green: `scripts/verify-session-181.sh:75`, the whole-suite check `cargo test -q 2>&1 | grep 'test result' | grep -qv ' 0 failed'`. If the suite fails to compile there are no `test result` lines, the inverted grep matches nothing and the check prints ok. The per-part checks use the sound `t()` helper, so the damage is limited to the whole-suite claim. Runner-up (disclosed limit): the approval record is byte-for-byte what an agent could write; the pty test is the disclosed fake-a-terminal route.

Defects:
- `scripts/verify-session-181.sh:75` — the hollow whole-suite check above.
- `tests/stamp_gate.rs` — the obeyed gate's text binding has no gate-level test, only the shared function's unit test; the wiring is present at `src/obeyed/mod.rs:431`.
- `scripts/verify-closeout.sh:34` and the four hook fallbacks — with the lib missing they ignore the override key; they print a warning, so loud rather than silent.

rec 1 — Replace the whole-suite check at `scripts/verify-session-181.sh:75` with a positive assertion: at least one `test result: ok` line, no `FAILED`, and fail if `cargo test` exits non-zero.
rec 2 — Add a gate-level obeyed-handoff test to `tests/stamp_gate.rs` (edit the findings, run `next --check-obeyed 181`).
rec 3 — Run the full `scripts/verify-closeout.sh` on the branch before merge and land the attested `**Review-Inputs-SHA:**` after the final commit. Any commit after this review means the review must be redone (F81).

**Verdict:** ACCEPT

A faithful build of the contract. The one PARTIAL is the unproven exit-0 close plus a hollow whole-suite check.
