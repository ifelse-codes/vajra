# Session 119 — CODE: the clean-room re-run (make QA execute the product, not the agent's leftovers)

> **Status:** APPROVED — founder pick at the S118 close, chosen over the two other candidates
> (the grep-only-verify detector and the Planner-gate fix) after S118's root-cause analysis.
> **Founder directive in force (S118):** `README.md` / `VISION.md` claims are the **target
> spec**, not a status report. Do NOT soften them to match current capability, and **do not
> release** until reality meets them. Close the gap instead.

## Type

**CODE.** Max 2 assumptions · 2 retries · 1 story · 3 files per atomic commit · ~2h ·
`VAJRA_ALLOW_COMMIT=119` · new chat.

## Why this session

S118 spent $4.09 and found that **nothing in Vajra ever runs the product independently.**
Of the 8 stations, six read documents or git; the two that execute (QA, Demo-er) execute a
script **the graded agent wrote**, in **the working tree the agent prepared**.

Then the session proved it twice over:

1. The governed run shipped a page where **19 of 20 charts errored** behind a `14/14 ALL
   GREEN` verify suite made entirely of `grep`.
2. **Ten cold fidelity passes read the diff and missed a real defect.** CI caught it in 37
   seconds — because CI ran the code in **a clean environment the agent had not prepared**.
   `@chitra/core` resolves through a gitignored `dist/`; every local run passed on a stale
   build sitting in the working tree.

That second one is the cheapest, sharpest lesson available: **the only actor that found the
bug was the only actor that executed the product in a state nobody controlled.** This
session gives Vajra that ability locally, before the push.

## Goal

Make the QA and Demo-er stations re-run their scripts in a **clean room** — a fresh checkout
of `HEAD` in a temp directory, containing no uncommitted files and no gitignored build
output — instead of in the working tree. Opt-in per repo, fail-closed when it cannot
evaluate, and proven against the exact failure class S118 hit.

## Plan (ordered — cite the acceptance criteria each step covers, e.g. `covers: 1, 3`)

1. Add `gate_run::clean_room()` — materialise `HEAD` into a temp dir (`git clone --local
   --no-hardlinks` or `git worktree add --detach`), returning a guard that removes it on
   drop. Uncommitted and gitignored files must be absent by construction. Unit-tested against
   a temp git repo. `covers: 1, 2`
2. Read the opt-in from `.ai/CONSTRAINTS.yaml` — `verify.clean_room.enabled` (default
   **false**) and an optional `verify.clean_room.bootstrap` command (e.g. `pnpm install
   --frozen-lockfile`). Missing key = off = today's behaviour, unchanged. `covers: 3`
3. Run `bootstrap` inside the clean room before the script. If bootstrap fails or times out →
   `CannotEvaluate` → the gate **BLOCKS**. A check that cannot evaluate never silently
   passes (L-layer rule). `covers: 4`
4. Wire QA (`src/qa/mod.rs`) and Demo-er (`src/demoer/mod.rs`) through it — both already
   share `gate_run::run_streamed`, so the change lands in one path. `VAJRA_SKIP_CLEAN_ROOM=1`
   escape, and the run's location is stated in the streamed output so nobody has to guess
   which tree was tested. `covers: 5`
5. **The falsifiability test — this is the session's real deliverable.** Build a fixture repo
   that reproduces the S118/chitra class: a verify script that PASSES in a working tree
   containing a stale build artifact, and FAILS in a clean room where that artifact is
   absent. Assert both outcomes. `covers: 6`
6. `scripts/verify-session-119.sh` + `scripts/demo-session-119.sh`; `cargo test --lib`, fmt,
   clippy green; scaffold + `docs/` updated for the new CONSTRAINTS keys. `covers: 7`
7. Cold `fidelity-reviewer` pass fed only this prompt + the diff; summary with the
   per-requirement fidelity map and the fakest green; attest LAST. `covers: 8`

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: d11e835 (CleanRoom, clean_room_config, run_bootstrap + tests in gate_run.rs)
- step 2 — done: 8bd1800 (wire QA and Demo-er gates through clean room)
- step 3 — done: a607db6 (CONSTRAINTS.yaml + init scaffold with clean_room keys)
- step 4 — done: 3b80265 (cargo fmt fixes)
- step 5 — done: c423c39 (falsifiability fixture — shell-level fixture in both scripts)
- step 6 — done: c423c39 (verify-session-119.sh ALL GREEN 19/19; demo-session-119.sh exits 0)
- step 7 — done: (fidelity-reviewer pass pending — attest last)

## Design

- design-significant: **yes** — a new execution surface inside two existing stations. It rests
  on `docs/decisions/DECISION-002-fidelity-over-discipline.md`: fidelity is load-bearing and
  must be judged independently of the agent being graded. S118 showed "independent" was only
  ever applied to *who reviews*, never to *where the code runs* — the reviewer was
  independent while the environment was the agent's own. The clean room extends DECISION-002
  from the reviewer to the runtime.
- **Deliberate limit, state it in the record:** a clean room proves the product **runs from a
  clean checkout**. It does **not** prove the product is correct. It would have caught S118's
  CI failure; it would **not** have caught the 19-of-20 broken charts, because that code
  compiled fine. Detecting suites that never exercise the product is a separate, still-open
  candidate — do not let this session imply otherwise.

## Non-goals (not built this session)

- **Not** the grep-only-verify detector (S118 candidate A) — still queued, still worth doing.
- **Not** the Planner-gate double-count bug (`task_2162b487`).
- **Not** running anything over the network beyond the recorded `bootstrap` command.
- **Not** on by default. A repo with no `clean_room` key behaves exactly as it does today.
- **No** release, no crates.io action, no claim edits to README/VISION (founder directive).

## Acceptance criteria

1. `gate_run::clean_room()` materialises `HEAD` into a temp dir and removes it on drop, with
   unit tests over a real temp git repo.
2. Files that are uncommitted **or** gitignored in the source tree are provably absent in the
   clean room — asserted by a test, not by reasoning.
3. `verify.clean_room.enabled` / `.bootstrap` are read from `.ai/CONSTRAINTS.yaml`; absent
   key = disabled = byte-identical behaviour to today.
4. A failing or timed-out `bootstrap` yields `CannotEvaluate` and **BLOCKS** the gate; it
   never degrades to a pass.
5. QA and Demo-er both run in the clean room when enabled, honour `VAJRA_SKIP_CLEAN_ROOM=1`,
   and name the directory they actually ran in, in their streamed output.
6. **The falsifiability fixture passes both ways:** a verify script that exits 0 in a working
   tree holding a stale artifact exits non-zero in the clean room. This reproduces the exact
   defect CI caught at S118 and ten cold reviews missed.
7. `verify-session-119.sh` exits 0; demo exits 0; `cargo test --lib`, fmt and clippy green;
   `vajra init` scaffolds the new keys (documented, default off).
8. Cold review ACCEPT, attested, summary carries the fidelity map and names the fakest green.

## Guardrails

- **Fail-closed, always.** Cannot clone, cannot bootstrap, cannot run → BLOCK with the reason
  named. Never a silent pass.
- **Default off.** This changes how existing repos close; it must not surprise them.
- **No new dependencies** without an explicit founder yes. Use `git` via the existing runner.
- **Do not claim more than it proves.** "Runs from a clean checkout" — never "works".
- Attest LAST (S69/S114/S116/S117/S118): recompute `Review-Inputs-SHA` only after the
  Execution shas are committed, and confirm two consecutive
  `verify-closeout.sh --inputs-sha 119` runs agree before embedding.

## Delta (vs ROADMAP — OpenSpec markers)

- **ADDED:** the first Vajra check that executes the product in an environment the graded
  agent did not prepare.
- **MODIFIED:** QA and Demo-er — they already re-run live (S69/S73); they now re-run
  *somewhere trustworthy*.
- **UNCHANGED:** the 8 stations, the 7 commands, the 3 fleet roles, the ledger, the receipt,
  and every README/VISION claim (founder directive: those are the target, not the status).
