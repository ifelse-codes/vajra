# Session 69 — Independent Cold Fidelity Review (DECISION-002)

**Method:** Fed only `prompts/69-task-qa-stage.md` and the delivery diff (merge-base main..HEAD, sessions/prompts/.ai-state excluded; 5 files, +902 lines: `src/qa/mod.rs`, `src/cli/next.rs`, `src/lib.rs`, verify+demo scripts). I built the binary myself, ran `cargo test --lib` (203 pass), ran `bash scripts/verify-session-69.sh` once, and drove `target/debug/vajra` against temp git fixtures of my own construction through 16 adversarial probes. Single pass; no builder summary, session notes, or commit messages read.

**Review-Inputs-SHA:** 4d90402d5c8da241005d54c26ebfbce7863838c51c1b41149ce22c7aeb0a0177

> Attestation correction (builder, disclosed): the hash first embedded here was emitted while
> `.ai/SESSION` still read 68, so `--inputs-sha` (no explicit N) bound the *wrong prompt file*.
> Recomputed as `--inputs-sha 69` against the byte-identical inputs the reviewer was actually fed
> (prompt 69 + the delivery diff, unchanged since the review — only excluded `sessions/` paths
> were committed after). The closeout gate caught the mismatch — working as designed.

## Acceptance criteria (reviewer's table)

| # | Criterion | Verdict | Evidence (yours) |
|---|-----------|---------|------------------|
| 1 | `--qa NN` surfaces the recorded QA contract (script path + exists/missing, recorded runs, latest, classified) from the spine | SHIPPED | My fixture: `--qa 51` printed `scripts/verify-session-51.sh (MISSING …)` then, with 2 run dirs + symlink, `2 recorded runs, latest → 20260102T000000Z`. Sentinel probe: a script that touches a file was NOT executed by `--qa` (read-only confirmed). Custom `script_pattern: 'checks/run-{NN}.sh'` in CONSTRAINTS.yaml was honored — derived from the recorded contract, not hardcoded (`src/qa/mod.rs::verify_patterns`/`gather_contract`) |
| 2 | `--check-qa NN` RE-RUNS live, exit 1 on non-zero; recorded green never accepted; passes only on live green | SHIPPED | Stale-green probe: 2 recorded runs + green `latest` symlink while the script exits 3 NOW → `NOT READY … re-ran LIVE and exited 3 — a recorded green is not accepted as proof`, exit 1. Same script flipped to `exit 0` → READY, exit 0. Real exit code surfaced (probe with exit 5 → "exited 5") |
| 3 | `--advance` QA gate blocks at L2/L3, advises at L1, honors `VAJRA_SKIP_QA_GATE=1` alone (distinct) | SHIPPED | Red verify at L3 → advance exit 1, `.ai/SESSION` stayed 51; same at L2 (`</dev/null`, exit 1). L1 red → `(L1 advise — advancing anyway.)`, SESSION 51→52. Distinctness both directions: red QA + `VAJRA_SKIP_CODER_GATE=1` (and Analyst+Architect+Planner skips all set) still blocked on QA; `VAJRA_SKIP_QA_GATE=1` + fake Coder `done:` sha still blocked on the Coder gate. Binds on the CLOSING session only: red `verify-session-52.sh` did not gate closing 51 |
| 4 | No script → WARN at most, the deletion dodge named plainly | SHIPPED | `rm` the script → `--check-qa` READY exit 0 with `⚠ … deleting the script downgrades this gate to a warning (self-granted jurisdiction, disclosed)`; `--qa` surface prints `(MISSING — … deleting the script is the named dodge)`. Runner provably never fires on NoScript (injected-panic unit test `qa_report_no_script_warns_never_runs`, in the 203 passing) |
| 5 | `verify-session-69.sh` proves surface + block-on-red + pass-on-green + legacy-warn + advance-wiring in a temp repo with real passing/failing scripts; exit 0 | SHIPPED | I ran it: 29 PASS / 1 FAIL, the sole failure being `cold-review-present` — self-referential (it waits for this very file), per the review brief. All five mandated behaviors have dedicated e2e checks (`e2e-check-qa-kills-stale-green`, `e2e-advance-blocks-live-red`, `e2e-advance-passes-live-green`, `e2e-check-qa-warns-no-script`, `e2e-advance-l1-advises`) driven by real `exit 0`/`exit 3` scripts in a temp git repo, and I independently reproduced each in my own fixture |

## Guardrails (reviewer-checked)

One story ✓ (diff is exactly the QA station: `src/qa/mod.rs` + `src/cli/next.rs` + `src/lib.rs` + verify/demo scripts, nothing else); ≤3 files per commit ✓ (4 commits on `main..HEAD`, name-only counts 2/2/1/2); no 8th command ✓ (`src/main.rs` unchanged vs main, QA rides `vajra next --qa/--check-qa`); no new dependency ✓ (`Cargo.toml` unchanged vs main); no second store ✓ (no `qa.md` — the contract is read from `CONSTRAINTS.yaml#verify` + `scripts/` + `.ai/verify/`, and the binary never writes or fixes a test); honest runtime cost ✓ (surface prints "honest cost: the live run executes the session's verify — cargo build/test — slow; that is the point", `--advance` prints "re-running … LIVE (slow, on purpose)"); fakest-green named ✓ (the gate's own output names "self-granted jurisdiction, disclosed", and the verify script's `summary_present` check greps the summary for the stale-green/live-re-run language and passed).

## Adversarial probes (16, reviewer-constructed)

- Stale-green: 2 recorded run dirs + green `latest` symlink, script exits 3 now → `--check-qa` exit 1 AND `--advance` refused, SESSION unchanged. The headline claim holds.
- Deleted script → WARN only, exit 0, dodge named in output. **The gate's jurisdiction is self-granted — but the contract mandates exactly this (AC 4).**
- **Hollow script (`exit 0` only) → live green, READY.** QA verifies the checks pass, not that they check anything — disclosed in the guardrails.
- `--qa` sentinel: surface never executes the script (read-only confirmed).
- Distinctness A: `VAJRA_SKIP_CODER_GATE=1` (plus Analyst/Architect/Planner skips) does NOT skip QA → still blocked.
- Distinctness B: `VAJRA_SKIP_QA_GATE=1` does NOT skip the Coder gate (fake `done:` sha still blocked).
- **`VAJRA_SKIP_QA_GATE=1` skips the live run ENTIRELY** (sentinel never fired), not just the block — unlike the other four stages, so no advisory red is even computed; disclosed at runtime (`⚠ [vajra qa] VAJRA_SKIP_QA_GATE set — live verify re-run skipped.`) and in a code comment.
- **`VAJRA_SKIP_QA_GATE=` (empty value) also skips** — `env::var(..).is_ok()` footgun; identical to the house pattern all other stage gates use, but undisclosed.
- L1 red → advisory + advance proceeds (SESSION 51→52); `--check-qa` at L1 still exits 1 (matches AC 2's unconditional wording).
- SIGKILL'd script (no exit code) → `could not be evaluated (no exit code) — a check that cannot evaluate FAILS`, exit 1. Fail-closed.
- Unreadable script (chmod 000) → bash 126 → BLOCK. Fail-closed.
- Live green → advance passes (51→52).
- Closing-session binding: red script for session 52 never gated closing 51 (per contract's "binds on the session being CLOSED").
- Script replaced by a directory (`is_file()` false) → NoScript READY warn — a variant of the same disclosed deletion-dodge class.
- Custom `script_pattern` honored (gate followed `checks/run-{NN}.sh`, blocked on "exited 5").
- L2 red with no stdin → blocked before any confirm prompt, SESSION unchanged.

Not probed to conclusion: a hanging verify script — there is no timeout on the live run, so `--advance`/`--check-qa` would hang. Fail-closed in effect (nothing advances), but unbounded.

## Fakest green (reviewer's words)

The fakest green is that **QA's authority is exactly as real as the author lets it be — twice over**. First, jurisdiction is self-granted: `rm scripts/verify-session-NN.sh` (or make it a non-file) and the blocking gate demotes itself to a warning — disclosed-class (AC 4 mandates it for NO-CODE/legacy sessions, and the runtime output names the dodge plainly). Second, a live green only proves the author's own checks pass: a verify script containing `exit 0` is a first-class green — disclosed-class (the guardrails say it verbatim). Third, the `VAJRA_SKIP_QA_GATE=1` override is stronger than its four siblings — it skips the check itself, not just the block, so the red evidence is never even produced; disclosed at runtime with a ⚠ line and asserted by the delivery's own e2e check, so disclosed-class. Undisclosed leftovers are minor: the empty-env-value skip (`is_ok()`, house-wide pattern), no timeout on the live run (hang = stuck gate, still fail-closed), and a dangling `latest` symlink surfacing cosmetically. What is genuinely NOT hollow: every unevaluable path I constructed (signal-kill, unreadable, missing exit code) blocks rather than passes, and the stale-green — the class this station exists to kill — is dead in every configuration I tried.

## Verdict

**Verdict:** ACCEPT — "All five acceptance criteria are shipped and survived probes I built myself: the gate re-executes evidence rather than trusting recorded green, blocks fail-closed on every unevaluable script I could construct, honors its own override without leaking into the other stages' gates in either direction, and leaves `.ai/SESSION` untouched on every refusal. The only self-check failure in `verify-session-69.sh` is the self-referential `cold-review-present`, which this document satisfies. Every hole I found — the deletion dodge, the hollow-green script, the check-skipping override — is either mandated by the contract or named plainly in the delivery's own output, and the undisclosed remainders (empty-env skip, no live-run timeout) are fail-open-free footguns, not hollow greens."
