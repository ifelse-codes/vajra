# Session Boot

## Current Session
- **Number:** 119 — COMPLETE
- **Type:** CODE. QA + Demo-er clean-room runner.
- **Goal:** Make QA and Demo-er re-run their scripts in a fresh `git worktree add --detach` checkout
  of HEAD — absent of uncommitted files and gitignored build artifacts — instead of in the tree the
  agent prepared. Opt-in per repo; fail-closed; proven by a falsifiability fixture.
- **Verdict:** **ACCEPT** (cold `fidelity-reviewer` pass: **8 of 8 SHIPPED**). Fakest green
  honestly named: `run-location-printed-in-output` in `verify-session-119.sh` greps source strings
  rather than capturing from a live gate run. No paid spend.
- **Report:** `sessions/session-119-summary.md` · `sessions/session-119-review.md` ·
  prompt: `prompts/119-task-clean-room-rerun.md`.
  **Date last updated:** 2026-08-17.

## Repo State Snapshot
- `.ai/SESSION` = 119. Work on `session-119-clean-room-rerun`. **S119 PR not yet opened.**
- **Key changes:** `src/gate_run.rs` (CleanRoom, clean_room_config, run_bootstrap + 11 unit
  tests); `src/qa/mod.rs` + `src/demoer/mod.rs` (route through CleanRoom when enabled);
  `.ai/CONSTRAINTS.yaml` + `src/cli/init.rs` (scaffold the new keys, default off); two shell
  scripts: `verify-session-119.sh` (19/19 ALL GREEN) + `demo-session-119.sh`.
- Stations for 119: Analyst ✅ Architect ✅ Planner ✅ Coder ✅ QA ✅ Demo-er ✅ Reviewer (fidelity
  pass ACCEPT). Releaser flips once the PR merges.
- **chitra is left on `session-11-catalog-two-panel`, LOCAL — not pushed, no PR**, by instruction.

## Next Session
- **Number:** 120 — **MANDATORY GT** (`120 % 5 == 0`). NO-CODE. Audits S116–S119.
- **Goal:** Run all required GT audits (vision, roadmap, state, knowledge, constitution, cost,
  dogfood, pipeline-advance, dogfood-staleness). Special focus: does the grep-only-verify pattern
  (S118/S119 root cause) appear in **other** historical verify scripts? Does the clean-room runner
  change the pipeline-advance picture?
- Founder picks one of S119's A/B/C options for S121 after reviewing the session.
- **🔒 Founder directive (S118):** README/VISION claims are the target spec — never soften them;
  no release until reality meets them.

## Carry-Forwards (NEW from S119)
- **CleanRoom = `git worktree add --detach HEAD`** (not `git clone`). The pattern: RAII `Drop`
  removes the worktree via `git worktree remove --force`. Bootstrap failure or timeout →
  `CannotEvaluate::SpawnFailure` → BLOCKS. `VAJRA_SKIP_CLEAN_ROOM=1` escape hatch, disclosed.
- **The falsifiability fixture pattern** (S119): a test that ASSERTS BOTH DIRECTIONS — the old
  path passes (artifact present), the new path fails (artifact absent). This is how to prove a
  clean-room check is not vacuous. Re-use for any future environment-isolation feature.
- **Fakest green class from S119:** a verify check that greps source strings to confirm a runtime
  message exists — finds the string in the code but does not prove the message reaches the caller's
  output during a live run. Identical to the S118 pattern but at one level up (source grep vs.
  product run). Name it explicitly in future session summaries when this pattern appears.
- **The grep-only-verify detector (S118 candidate A, still queued):** S119 fixed the clean-room
  side; it did NOT fix suites that compile and run clean but prove nothing about the product. That
  detector is still unbuilt.
- **`run_bootstrap_blocks_on_timeout` uses a 100ms timeout in tests** — the timeout machinery is
  real, but the production `Duration` comes from the caller; document the coupling if the caller
  ever exposes a config knob.

## Standing Carry-Forwards (from S118 + prior)
- **New session = new chat** (AGENTS.md step 10) — open a fresh chat for S120.
- **Communicate in the plainest English** (founder request S103) — translate all jargon.
- **Dispatch-by-name proven for ALL THREE roles** (Researcher S111, Fidelity Reviewer S115, Plan
  Advisor S117). The mid-creating-session case still fails per S111 — do not conflate.
- **Attest LAST:** `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff), the PROMPT IS AN INPUT.
  Compute strictly after every edit to the prompt file itself and confirm two consecutive
  `verify-closeout.sh --inputs-sha NN` runs agree before embedding.
- **`vajra next --role X --from file` hashes the TRIMMED body** — strip before sha256 comparison.
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3).** A bullet list is BLOCKED.
  A verdict wrapped in a `|`-table row also fails — only a bare `**Verdict:** ACCEPT` line passes.
- **Still reuse `named_test_passed()`** — a bare `cargo test --lib <filter>` exits 0 on a filter
  matching zero tests. And **`[[:space:]]`, never `\s`**, in any script check (BSD/macOS grep).
- **Background task flagged, not yet acted on:** `task_2162b487` — the Planner-gate
  `is_acceptance_heading` double-counting bug (S117 finding).
- **KNOWLEDGE §6 is well past 550 lines, still growing** — chronic since S60, still unpruned.
- **Known weak check, house-wide, unfixed 7 sessions running (S111–S119, except S115 which built
  no code):** `no-eighth-command` greps a hardcoded usage banner. Named again.
- **Untracked stragglers** (standing founder call): `sessions/session-9*-artifacts/*`,
  `sessions/session-10{2,3,7,8,9}-artifacts/*`; `vajra-cto-audit-*.html` + `first-mate.html`.
- **crates.io is PUBLISHED — `vajractl` name BURNED**; any crates.io action stays founder-gated.
- **v0.1 installs FOUR ways, all measured, CONFIRMED stranger-shippable at S110 GT.**
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a
  separate founder "yes".
