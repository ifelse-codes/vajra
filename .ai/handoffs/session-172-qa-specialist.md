---
role: qa-specialist
session: 172
agent: claude-code-subagent (verified: toolu_01U9qNvk1iSixisEKhi5WKyo)
source-sha: 033b4cc5ae1c23998f3cd1bff2e5c831b6cff94f6a155ee2a66b5b1829908659
captured: 2026-09-20T18:10:05Z
cost_usd: null
---

# Qa-specialist handoff — session 172

obeyed-check fidelity-reviewer rec 1 — implemented: 2261cae — `shipped_close()` now asks `refs/remotes/origin/<main>` first and only falls back to local main when no such ref exists (saying "no origin/main ref to check against" when it does), and the un-forgeability sentence in `docs/decisions/DECISION-007-agent-fleet.md` is replaced by an explicit "Corrected by this session's cold review (rec 1)" paragraph that names the `git checkout main && git merge` route.

obeyed-check fidelity-reviewer rec 2 — implemented: ccd1b21 — adds `check_live_gate fidelity-handoff --check-fidelity-handoff "=== fidelity: fidelity-reviewer handoff for session"` to the main check sequence of both `scripts/verify-closeout.sh` (line 1284) and `scripts/verify-closeout-scaffold.sh` (line 1086), so an absent handoff now blocks pre-merge.

obeyed-check fidelity-reviewer rec 3 — implemented: 36c5725 — rewrites the prose `obeyed:` dispositions in `prompts/172-task-keep-testing.md` to name resolvable shas (`ff8145a`, `4f1ce0f`, `53601d2`) and gives `design-advisor rec 7` the parseable word `obeyed:` in place of `obeyed in part:`.

obeyed-check fidelity-reviewer rec 4 — implemented: ccd1b21 — `check_live_gate` in `verify-closeout.sh` now resolves `BIN` PATH-first so the harness's fake `vajra` is reachable, the harness `cat`s the gate log, and the `AC2 same-check-in-vajras-own-gate` assertion additionally requires `binary: .*/bin/vajra`, distinguishing a real block from the missing-binary branch.

obeyed-check fidelity-reviewer rec 5 — implemented: ccd1b21 — replaces the `grep -c '#[test]' … = 6` count check with a live negative control that seds `agent_shell=1` → `agent_shell=0` in a copy of the real `.githooks/pre-commit` and asserts an unapproved agent commit then succeeds.

obeyed-check fidelity-reviewer rec 6 — implemented: 2261cae — the Releaser step in `src/nextstep/mod.rs` now reads "run scripts/verify-closeout.sh ON THE BRANCH first — since S172 nothing re-checks it after the merge — then open the pull request, merge it, prune the branch", reversing the previous merge-then-verify order.

obeyed-check fidelity-reviewer rec 7 — implemented: ccd1b21 — the missing-`$RUDRA` branch of `verify-session-172.sh` swaps `echo "N/A…"; ok …` for `bad "AC7 sync-fleet-upgrades-a-real-project-cleanly — no project at $RUDRA to sync into; set VAJRA_SYNC_TARGET"`.

obeyed-check fidelity-reviewer rec 8 — implemented: ccd1b21 — both scripts' `check_live_gate` now use the identical `BIN="$(command -v vajra 2>/dev/null || echo "target/release/vajra")"` resolution, retry with the locally built binary when the resolved one does not emit the gate header, log `binary: $BIN`, and the FAIL text names the remedy (`cargo install --path . / brew upgrade`); the four other binary-resolving checks in `verify-closeout.sh` were aligned to the same line.

obeyed-check fidelity-reviewer rec 9 — implemented: ccd1b21 — `scripts/verify-session-172.sh:5` no longer claims "No check greens by grepping source" and instead discloses that source-reading checks exist and are named `*-wires-*`.

obeyed-check fidelity-reviewer rec 10 — implemented: 2261cae — adds residual-risk item 3 to the DECISION-007 S172 addendum: "The demo template WARNS against comparing with `main`; nothing enforces it. Older demo scripts in this repo still read `git show main:` (cold review rec 10)."

---

## What I ran, and what it printed

All of the below ran from `/Users/suman/playground/vajra` at `HEAD=b517ec1`. I wrote nothing to the repo; `git status --short` is unchanged (only the four pre-existing untracked files). Probe scripts and a separate `CARGO_TARGET_DIR` build live in the scratchpad.

- `bash /Users/suman/playground/vajra/scripts/verify-session-172.sh` → `=== Session 172 verify: 30 pass, 0 fail ===`, including `AC2 same-check-in-vajras-own-gate`, all seven `*-wires-*` checks, `AC4 the-tests-would-go-red-if-agent-detection-were-removed`, `AC7 cargo-test-green (528 passed)`, `AC7 cargo-fmt-clean`, `AC7 sync-fleet-upgrades-a-real-project-cleanly (6 files)`.
- `cargo test -q --lib releaser` → `21 passed; 0 failed`, including the new `shipped_close_prefers_origin_so_a_local_merge_does_not_count`.
- **rec 1, live** — on a fixture with an `origin/main` whose close is committed on local `main` only: the gate still blocks (`[vajra fidelity] session 02 cannot close`); after `git push origin main` it flips to `already merged by you — sessions/session-02-summary.md is on origin/main; reporting, not blocking.` On a remote-less fixture the message is `sessions/session-02-summary.md is on main — no origin/main ref to check against`. The DECISION-007 text and the code agree.
- **rec 2, live** — `vajra next --check-fidelity-handoff 172` in this repo exits 0 (`verdict: READY`); in a fixture with no handoff it exits 1 with `verdict: NOT READY` and names the missing `.ai/handoffs/session-172-fidelity-reviewer.md`. `check_live_gate`'s non-zero path calls `bad`.
- **rec 4, mutation probe** — I ran the AC2 `own` harness against a copy of `verify-closeout.sh` with the final `else echo "FAIL: $FIX"; bad "$NAME"` branch replaced by `ok "$NAME"`. Unmutated: `AC2 -> PASS`. Mutant: `AC2 -> FAIL (no block at all)`. I also ran the harness against `ccd1b21^`'s script and reproduced the review's diagnosis exactly — `RESULT=FAIL` came from `BLOCK: target/release/vajra not found`, i.e. the old check greened without ever running the binary.
- **rec 5, two-sided check** — same fixture, real `.githooks/pre-commit`: `commit BLOCKED` (so AC4 would report FAIL); mutated copy with `agent_shell=0`: `commit SUCCEEDED` (AC4 reports PASS). The control genuinely goes the other way.
- **rec 7, live** — `VAJRA_SYNC_TARGET=/nonexistent/no-such-project bash scripts/verify-session-172.sh` → `FAIL: AC7 sync-fleet-upgrades-a-real-project-cleanly — no project at /nonexistent/no-such-project to sync into` and `29 pass, 1 fail`.
- **rec 3, live** — `vajra next --check-advice 172` exits 0 with `verdict: READY`; every disposition resolves.

Four things I observed that sit beside the judgments rather than changing them:

1. `/Users/suman/playground/vajra/target/release/vajra` is dated Sep 18 and **predates all three of these commits** — it still prints the old `is already on main` message. `scripts/verify-session-172.sh` uses that binary by default, so the binary-driven checks in the 30/30 run above exercised a pre-fix build. I rebuilt into the scratchpad and re-ran the rec 1 probes against the fresh binary; the origin-preference behaviour is only present in the fresh build. (`verify-closeout.sh` now resolves `command -v vajra` = `/Users/suman/.cargo/bin/vajra`, which may be staler still — the rec 8 retry covers it only when `target/release/vajra` is itself current.)
2. rec 3's fix at `36c5725` left `tech-lead rec 3 — obeyed: PENDING_REVIEW`, which `advice::check_evidence` scores as no sha; that last line was filled with `da508e1` in `b517ec1`. Ten of the eleven prose dispositions were resolvable at the named commit, eleven at the tip.
3. rec 9's replacement header says "**Three** checks DO read source" — the live run emits **seven** `*-wires-*` checks (three `own-gate-wires`, four `project-gate-wires`). The false blanket claim is gone and the checks are named, but the count that replaced it is wrong.
4. rec 5's other half — "replace the count check with a check that binds the eleven cases" — was not built: the count check was deleted, and the mutation control never reads `tests/commit_belt.rs`, so emptying all six test bodies would still leave `AC4 the-tests-would-go-red-if-agent-detection-were-removed` green. Its name claims more than it tests. Relatedly, rec 10's literal target — Deliverable 3 in `/Users/suman/playground/vajra/prompts/172-task-keep-testing.md:68` — still reads "**The demo cannot rot at merge (F40)**"; the downgrade landed in the DECISION addendum (`2261cae`) and in `/Users/suman/playground/vajra/sessions/session-172-summary.md:117` (`da508e1`), which are the two places rec 10 named.

## Handoff Delta
- `~` re-run: qa-specialist handoff replaced (8107 bytes now vs 6906 bytes prior)
- prior stage: this session's earlier qa-specialist handoff
